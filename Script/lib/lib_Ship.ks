// SHIP Library
// Various functions about current ship
// v 1.2 (kOS 1.2.0)
// Constandinos Iezekiel
@LAZYGLOBAL OFF.

// Set TWR function variables
GLOBAL current IS "current".
GLOBAL maximum IS "maximum".

// Return current/maximum TWR
FUNCTION TWRCalc {
  PARAMETER type.

	LOCAL engList IS list().
  LOCAL currentThrust IS 0.
  LOCAL maximumThrust IS 0.
  LOCAL availableThrust IS 0.

  LOCK g TO SHIP:BODY:MU / (SHIP:ALTITUDE + SHIP:BODY:RADIUS)^2.
  LIST ENGINES IN engList.
  FOR eng in engList {
    SET currentThrust TO currentThrust + eng:THRUST.
    IF eng:IGNITION = TRUE AND eng:FLAMEOUT = FALSE {
      SET maximumThrust TO maximumThrust + eng:MAXTHRUST.
    }
  }
  IF type = "current"
    RETURN (currentThrust/(SHIP:MASS*g)).
  IF type = "maximum"
    RETURN (maximumThrust/(SHIP:MASS*g)).
}

// Get current Roll from navball
FUNCTION navRoll {
	IF VANG(SHIP:FACING:VECTOR, SHIP:UP:VECTOR) < 0.2 { RETURN 0. } //	deadzone against gimbal lock (when vehicle is too vertical, roll angle becomes indeterminate)
	ELSE {
		LOCAL raw IS VANG(VXCL(SHIP:FACING:VECTOR, SHIP:UP:VECTOR), SHIP:FACING:STARVECTOR).
		IF VANG(SHIP:UP:VECTOR, SHIP:FACING:TOPVECTOR) > 90 {
			RETURN 270-raw.
		} ELSE {
			RETURN -90-raw.
		}
	}
}

FUNCTION getISP
{
	local isp is 0.
	LOCAL enginesList IS "".
	LIST ENGINES IN enginesList.
	for eng in enginesList{
		if eng:stage=stage:number and eng:flameout=false{
			eng:activate.
			set isp to isp + eng:VISP.
		}
	}
	RETURN isp.
}

FUNCTION burnTime
{
	PARAMETER n.
	LOCAL CMAS IS SHIP:MASS.
	LOCAL EISP IS getISP().
	IF EISP = 0 {
			Return 6.
	}
	LOCAL MAXT IS SHIP:MAXTHRUST.
	LOCAL CVEL IS n:DELTAV:MAG.
	LOCAL E IS CONSTANT():E.
	LOCAL GI IS 9.80665.             // Gravity for ISP Conv
	LOCAL I IS EISP * GI.            // ISP in m/s units.
	LOCAL M IS CMAS * 1000.         // Mass in kg.
	LOCAL T IS MAXT * 1000.         // Thrust in N.
	LOCAL F IS T/I.                 // Fuel flow in kg/s.
	RETURN (M/F)*(1-E^(-CVEL/I)).   // Burn time in seconds
}

// Determine height of the current craft
FUNCTION shipHeight {
  LOCAL partList IS list().
  LIST PARTS IN partList.
  LOCK r3 TO FACING:FOREVECTOR.
  LOCAL highestPart TO 0.
  LOCAL lowestPart TO 0.
  FOR part in partList{
		LOCAL v TO part:position.
		LOCAL currentPart TO r3:x*v:x + r3:y*v:y + r3:z*v:z.
		IF currentPart > highestPart
			SET highestPart TO currentPart.
		ELSE IF currentPart < lowestPart
			SET lowestPart TO currentPart.
  }
  LOCAL height TO highestPart - lowestPart.
  RETURN height.
}

FUNCTION releaseControls {
  LOCK THROTTLE TO 0.
  WAIT 0.1.
  SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
  WAIT 0.1.
  SET SHIP:CONTROL:NEUTRALIZE to TRUE.
  WAIT 0.1.
  UNLOCK RCS.
  UNLOCK SAS.
  UNLOCK THROTTLE.
  UNLOCK STEERING.
}