// Selene A
// Moon Flyby and Impactor
// v 1.2 (kOS 1.2.0)
@LAZYGLOBAL OFF.

//Variables
SET TARGET TO ("Moon").
LOCAL targetInclination TO 0.
LOCAL targetApoapsis TO 150000.
LOCAL targetPeriapsis TO 150000.

// Wait for proper Launch Window
WAIT 1.
RUNONCEPATH("0:/lib/LaunchWindow.ks").

// Automatically start ascent
IF (SHIP:STATUS = "PRELAUNCH") {
	RUNONCEPATH("0:/lib/LaunchRGS.ks",targetInclination,targetApoapsis,targetPeriapsis).
}

// COPYPATH("0:/lib/ExecNode.ks","node.ks").
// RUNONCEPATH("0:/lib/Transfer.ks").
// SWITCH TO 1.
// FOR avioncs IN SHIP:MODULESNAMED("ModuleAvioncs") {
// 	IF avioncs:HASEVENT("Shutdown Avionics") {
// 		avioncs:DOEVENT("Shutdown Avionics").
// 	}.
// }.

// IF (SHIP:BODY = BODY("Moon")) {
// 	PRINT "T+" + round(missiontime) + "Welcome to Moon SOI".
// 	FOR avioncs IN SHIP:MODULESNAMED("ModuleAvioncs") {
// 		IF avioncs:HASEVENT("Activate Avionics") {
// 			avioncs:DOEVENT("Activate Avionics").
// 		}.
// 	}.
// }
