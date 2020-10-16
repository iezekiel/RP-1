// Gaia Corona
// Early Orbital Return Satellite
// v 1.2 (kOS 1.2.0)
@LAZYGLOBAL OFF.

//Variables
LOCAL targetInclination TO 65.
LOCAL targetApoapsis TO 200000.
LOCAL targetPeriapsis TO 200000.

// Automatically start ascent
IF (SHIP:STATUS = "PRELAUNCH") {
	RUNONCEPATH("0:/lib/LaunchRGS.ks",targetInclination,targetApoapsis,targetPeriapsis).
	STAGE.
	COPYPATH("0:/sub/CoronaRetro.sub.ks","1:/retro.ks").
	PRINT "T+" + round(missiontime) + " When ready run retro.".
	SWITCH TO 1.
}