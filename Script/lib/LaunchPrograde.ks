// Launch Prograde
// Launches Rocket to a prograde tragectory set by pitch start variable.
// v 1.2 (kOS 1.2.0)
// Constandinos Iezekiel
@LAZYGLOBAL OFF.

PARAMETER targetAzimith IS 90.
PARAMETER flameOutWait IS 0.2.
PARAMETER cdIgnite TO 3.
PARAMETER pitchStart IS 50.
PARAMETER pitchMultiplier IS 1.

RUNONCEPATH("0:/lib/lib_UI.ks").
RUNONCEPATH("0:/lib/lib_Ship.ks").
RUNONCEPATH("0:/lib/lib_LaunchUtils.ks", cdIgnite).

CLEARSCREEN.
GLOBAL verNum IS "1.2.0".        //Script version number
uiProgradeLaunch().  //Print the UI
RCS OFF.
SAS OFF.
LOCK THROTTLE TO 1.
countdownSequence().    //Countdown
liftSequence().     //Lift Rocket
statusUpdate("Prograde Guidance Mode").
// Start Roll Program once Tower Clear
addMessage("Executing Roll Program").
LOCK STEERING to HEADING(targetAzimith, 90).
WHEN abs(navRoll() + 180) < 1 THEN { addMessage("Roll Complete"). }
// Set Pitching Start Speed
IF pitchStart = 0 {
	IF TWRCalc(maximum) > 1.7
		SET pitchStart to 60.
	ELSE IF TWRCalc(maximum) < 1.7 AND TWRCalc(maximum) > 1.5
		SET pitchStart TO 65.
	ELSE IF TWRCalc(maximum) < 1.5 AND TWRCalc(maximum) > 1.3
		SET pitchStart TO 70.
	ELSE
		SET pitchStart TO 75.
}
// Start Pitch Program at correct speed
UNTIL SHIP:AIRSPEED >= pitchStart {
	timerUpdate().
	WAIT 0.1.
}
addMessage("Executing Pitch Program at " + pitchStart + "m/s").
LOCAL i TO 1.
UNTIL i = 10 {
  timerUpdate().
	LOCK STEERING TO HEADING(targetAzimith, 90 - i*pitchMultiplier).
	SET i TO i + 1.
	WAIT 1.
}
LOCK STEERING TO SRFPROGRADE.
UNTIL ETA:APOAPSIS < 10 {
	timerUpdate().
	ACTIVATORS().
	flameOut(flameOutWait).
	checkMaxQ().
	WAIT 0.1.
}
SET WARP TO 0.
releaseControls().
WAIT 5.
statusUpdate("Launch Program Complete").
addMessage("Launch Program Complete").
addMessage("Final Orbit: " + ROUND(APOAPSIS/1000) + "km x " + ROUND(PERIAPSIS/1000) + "km").
chute("Arm parachute").
UNTIL FALSE {
	timerUpdate().
	WAIT 0.1.
	IF (SHIP:STATUS = "LANDED" OR SHIP:STATUS = "SPLASHED") {
		statusUpdate("Landed").
		addMessage("Landed").
		WAIT 10.
		BREAK.
	}
}