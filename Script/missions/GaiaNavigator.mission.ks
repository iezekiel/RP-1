// Gaia Navigator
// Early Weather Satellite
// v 1.2 (kOS 1.2.0)
@LAZYGLOBAL OFF.

//Variables
LOCAL targetInclination TO 50.
LOCAL targetApoapsis TO 600000.
LOCAL initialPeriapsis TO 150000.
//LOCAL targetPeriapsis TO 600000.

// Automatically start ascent
IF (SHIP:STATUS = "PRELAUNCH") {
	RUNONCEPATH("0:/lib/LaunchRGS.ks",targetInclination,targetApoapsis,initialPeriapsis).
	STAGE.
	RUNPATH("0:/lib/Periapsis.ks",APOAPSIS).
	SWITCH TO 1.
	COPYPATH("0:/lib/Noda.ks", "1:/node.ks").
}