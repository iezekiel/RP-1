// Gaia C
// First Solar and Scientific Satellite
// v 1.2 (kOS 1.2.0)
@LAZYGLOBAL OFF.

//Variables
LOCAL targetAzimuth TO 90.
LOCAL targetPeriapsis IS 450000.
LOCAL flameOutWait IS 0.1.
LOCAL cdIgnite TO 3.
LOCAL pitchStart IS 80.
LOCAL pitchMultiplier IS 1.2.

// Automatically start ascent
IF (SHIP:STATUS = "PRELAUNCH") {
	RUNPATH("0:/lib/LaunchProgradeOrbit.ks",targetAzimuth, targetPeriapsis,flameOutWait,cdIgnite,pitchStart,pitchMultiplier).
}