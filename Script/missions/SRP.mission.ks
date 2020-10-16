// Sounding Rockets Program
// Rocket prograde tragectory
// v 1.2 (kOS 1.2.0)
@LAZYGLOBAL OFF.

//Variables
LOCAL targetAzimuth TO 90.
LOCAL flameOutWait IS 0.1.
LOCAL cdIgnite TO 3.
LOCAL pitchStart IS 50.
LOCAL pitchMultiplier IS 1.15.

// Automatically start ascent
IF SHIP:STATUS = "PRELAUNCH" {
	RUNPATH("0:/lib/LaunchPrograde.ks",targetAzimuth,flameOutWait,cdIgnite,pitchStart,pitchMultiplier).
}