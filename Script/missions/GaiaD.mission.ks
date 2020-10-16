// Gaia D
// Atmospheric Analysis Satellite
// v 1.2 (kOS 1.2.0)
@LAZYGLOBAL OFF.

//Variables
LOCAL targetInclination TO 0.
LOCAL targetApoapsis TO 650000.
LOCAL targetPeriapsis TO 300000.

// Automatically start ascent
IF (SHIP:STATUS = "PRELAUNCH") {
	RUNONCEPATH("0:/lib/LaunchRGS.ks",targetInclination,targetApoapsis,targetPeriapsis).
}