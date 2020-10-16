// Generic Launch Program
// Launches Rocket to the designated orbit
// v 1.2 (kOS 1.2.0)
@LAZYGLOBAL OFF.

//Variables
LOCAL targetInclination TO 0.
LOCAL targetApoapsis TO 150000.
LOCAL targetPeriapsis TO 150000.

// Automatically start ascent
IF (SHIP:STATUS = "PRELAUNCH") {
	RUNONCEPATH("0:/lib/LaunchRGS.ks",targetInclination,targetApoapsis,targetPeriapsis).
}