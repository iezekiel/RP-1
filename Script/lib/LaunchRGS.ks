// Launch RGS
// Launches Rocket to a the designated Orbit
// v 1.3 (kOS 1.2.0)
// Constandinos Iezekiel
// Original Script https://www.reddit.com/r/Kos/comments/4oswqg/i_wrote_a_launch_script_for_rorp0_based_on/
@LAZYGLOBAL OFF.

PARAMETER targetInclination IS 0.
PARAMETER targetApoapsis IS 200000.
PARAMETER targetPeriapsis IS 200000.

RUNONCEPATH("0:/lib/lib_UI.ks").
RUNONCEPATH("0:/lib/lib_Ship.ks").
RUNONCEPATH("0:/lib/lib_LaunchUtils.ks").

CLEARSCREEN.
GLOBAL verNum IS "1.3.0".        	//Script version number
uiLaunchRGS().  									//Print the UI
RCS OFF.
SAS OFF.
LOCK THROTTLE TO 1.
countdownSequence().    					//Countdown
liftSequence().         					//Lift Rocket

statusUpdate("Passive Guidance Mode").
LOCAL targetApoeta IS 84.
LOCAL waitPitch is 40.
LOCAL maxCorrection is 60.
IF targetPeriapsis >= 200000 { SET waitPitch TO 45. SET maxCorrection TO 100. }
IF targetPeriapsis >= 300000 { SET waitPitch TO 50. }
IF targetPeriapsis >= 400000 { SET waitPitch TO 60. }
IF targetPeriapsis >= 500000 { SET waitPitch TO 70. }
IF targetPeriapsis >= 600000 { SET waitPitch TO 70. }
GLOBAL enginesList IS LIST().
LIST ENGINES IN enginesList.
LOCAL launchLoc to SHIP:GEOPOSITION.
LOCAL initAzimuth TO arcsin(max(min(cos(targetInclination) / cos(launchLoc:LAT),1),-1)).
LOCAL targetOrbitSpeed TO SQRT(SHIP:BODY:MU / (targetPeriapsis+SHIP:BODY:RADIUS)).
LOCAL rotvelx to targetOrbitSpeed*sin(initAzimuth) - (6.2832*SHIP:BODY:RADIUS/SHIP:BODY:ROTATIONPERIOD).
LOCAL rotvely to targetOrbitSpeed*cos(initAzimuth).
LOCAL azimuth to arctan(rotvelx / rotvely).
IF targetInclination < 0 {SET azimuth to 180-azimuth.}.
LOCAL fullySteeredAngle to 90 - waitPitch.
LOCAL atmpGround TO SHIP:BODY:ATM:ALTITUDEPRESSURE(0).
LOCK firstPhasePitch to fullySteeredAngle - (fullySteeredAngle * atmoDensity).
LOCK altitude to ALT:RADAR.
LOCK atmp TO SHIP:BODY:ATM:ALTITUDEPRESSURE(altitude).
LOCK atmoDensity to atmp / atmpGround.
LOCK apoeta to max(0,ETA:APOAPSIS).
// Start Roll Program once Tower Clear
addMessage("Executing Roll Program").
LOCK STEERING to HEADING(azimuth, 90 - firstPhasePitch).
WHEN abs(navRoll() + 180) < 1 THEN { addMessage("Roll Complete"). }
// Set Pitching Start Speed
LOCAL pitchStart IS 0.
IF TWRCalc(maximum) > 1.7
	SET pitchStart to 50.
ELSE IF TWRCalc(maximum) < 1.7 AND TWRCalc(maximum) > 1.3
	SET pitchStart TO 60.
ELSE
	SET pitchStart TO 70.
// Start Pitch Program at correct speed
WHEN SHIP:AIRSPEED >= pitchStart THEN {
	addMessage("Executing Pitch Program at " + pitchStart + "m/s").
	LOCK STEERING to HEADING(azimuth, 90 - firstPhasePitch).
}
//UNTIL apoeta >= targetApoeta {
UNTIL APOAPSIS >= targetPeriapsis {
	timerUpdate().
	flameOut(3).
	ACTIVATORS().
	checkMaxQ().
	// Limit acceleration (doesn't limit to exactly 5g, but it's close enough)
	LOCK THROTTLE to MAX(0, MIN(1, MASS * 5 * 9.82 / MAX(0.1, MAXTHRUST))).
	WAIT 0.1.
}
LOCAL endTurnAltitude to 0.
LOCAL endRurnOrbitSpeed to 0.
LOCAL secondPhasePitch to firstPhasePitch.
addMessage("Passive Guidance Complete").
addMessage("Switching to Active Guidance").
statusUpdate("Active Guidance Mode").
LOCAL atmoEndAltitude to 110000.
LOCAL tolerance to targetApoeta * 0.5.
LOCK shipAngle to VANG(SHIP:UP:VECTOR, SHIP:SRFPROGRADE:VECTOR).
LOCK correctiondAmp to (altitude - endTurnAltitude) / (atmoEndAltitude - endTurnAltitude).
LOCK mx to shipAngle + (maxCorrection * correctiondAmp).
LOCK mi to shipAngle - (maxCorrection * correctiondAmp).
LOCK orbitSpeedFactor to ((targetOrbitSpeed - SHIP:VELOCITY:ORBIT:MAG) / (targetOrbitSpeed - endRurnOrbitSpeed)).
LOCK tApoEta to targetApoeta * orbitSpeedFactor.
LOCAL ae to 0.
LOCK correction to max(-maxCorrection*0.3,((tApoEta - ae) / tolerance) * maxCorrection).
LOCK secondPhasePitch to max(mi,min(mx, shipAngle - correction )).
LOCK STEERING to HEADING(azimuth, 90 - secondPhasePitch).
UNTIL ALT:PERIAPSIS >= targetPeriapsis {
	checkMaxQ().
	timerUpdate().
	flameOut(3).
	ACTIVATORS().
	if SHIP:VERTICALSPEED > 0 {
		SET ae to apoeta.
	} else {
		SET ae to 0.
	}
	WAIT 0.1.
}
IF APOAPSIS <= targetApoapsis {
	addMessage("Active Guidance Complete").
	addMessage("Now Raising apoapsis").
	statusUpdate("Raising apoapsis").
	RCS ON.
	UNTIL APOAPSIS >= targetApoapsis {
		timerUpdate().
		flameOut(3).
		ACTIVATORS().
		LOCK STEERING to HEADING(azimuth, 0).
	}
	LOCK THROTTLE TO 0.
	WAIT 0.1.
}
releaseControls().
WAIT 5.
addMessage( "Launch Program Complete").
addMessage("Final Orbit: " + ROUND(APOAPSIS/1000) + "km x " + ROUND(PERIAPSIS/1000) + "km").
chute("Arm parachute").
WAIT 15.
CLEARSCREEN.