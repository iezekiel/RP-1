// Launch Sounding
// Program to guide a rocket to 90 azimuth (up).
// v 1.2 (kOS 1.2.0)
// Constandinos Iezekiel
@LAZYGLOBAL OFF.

PARAMETER targetAzimuth IS 90.      //Azimuth Direction
PARAMETER flameOutWait IS 0.1.			//Flameout for staging
PARAMETER cdIgnite TO 0.1.      		//Engine ignition timer

LOCAL doStage TO TRUE.
IF cdIgnite < 1 {
	SET doStage TO FALSE.
}

RUNONCEPATH("0:/lib/lib_UI.ks").
RUNONCEPATH("0:/lib/lib_Ship.ks").
RUNONCEPATH("0:/lib/lib_LaunchUtils.ks", cdIgnite).

CLEARSCREEN.
GLOBAL verNum IS "1.2.0".        	//Script version number
uiLaunchSounding(). 							//Print the UI
RCS OFF.
SAS OFF.
LOCK THROTTLE TO 1.
LOCK STEERING TO HEADING(90, targetAzimuth).
countdownSequence().    					//Countdown
liftSequence(doStage).     				//Lift Rocket
statusUpdate("Coasting").
UNTIL ETA:APOAPSIS < 1 {
	timerUpdate().
	ACTIVATORS().
	flameOut(flameOutWait).
	checkMaxQ().
	WAIT 0.01.
}
SET WARP TO 0.
releaseControls().
addMessage("Apoapsis reached: " + ROUND(APOAPSIS/1000) + "km").
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