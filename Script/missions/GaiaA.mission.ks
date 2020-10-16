// Gaia A
// Frist orbital Rocket
// v 1.2 (kOS 1.2.0)
@LAZYGLOBAL OFF.

//Variables
LOCAL targetAzimuth TO 90.
LOCAL targetApoapsis TO 250000.
LOCAL flameOutWait IS 0.1.
LOCAL cdIgnite TO 3.
LOCAL pitchStart IS 70.
LOCAL pitchMultiplier IS 1.

// Automatically start ascent
IF (SHIP:STATUS = "PRELAUNCH") {
	RUNPATH("0:/lib/LaunchProgradeHB.ks",targetAzimuth, targetApoapsis,flameOutWait,cdIgnite,pitchStart,pitchMultiplier).
}