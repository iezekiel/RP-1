// Sounding Rockets Program
// Rocket goes up
// v 1.2 (kOS 1.2.0)
@LAZYGLOBAL OFF.

//Variables
LOCAL targetAzimuth TO 90.
LOCAL flameOutWait TO 1.
LOCAL cdIgnite TO 0.1.

// Automatically start ascent
IF SHIP:STATUS = "PRELAUNCH" {
	RUNPATH("0:/lib/LaunchSounding.ks", targetAzimuth, flameOutWait, cdIgnite).
}