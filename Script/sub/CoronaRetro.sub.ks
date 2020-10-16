// Gaia Corona Retro A
// Retro routine for Corona
// v 1.0 (kOS 1.2.0)
@LAZYGLOBAL OFF.

RUNONCEPATH("0:/lib/lib_UI.ks").

CLEARSCREEN.
GLOBAL verNum IS "1.0.0".       //Script version number
uiLanding().  									//Print the UI
PRINT "                 Landing to "+SHIP:BODY:NAME+"           "      AT (0,2).
statusUpdate("Warping to apoapsis").
addMessage("Coasting to apoapsis").
SET WARP TO 2.
WAIT UNTIL ETA:APOAPSIS < 120.
SET WARP TO 0.
statusUpdate("Retrograde fire").
addMessage("Orient for retrograde burn ").
RCS ON.
LOCK STEERING TO RETROGRADE.
wait until vdot(facing:forevector, PROGRADE:forevector) <= -0.995.
WAIT 5.
addMessage("Lowering periapsis").
STAGE.													// Retro engines
LOCK THROTTLE TO 1.
WAIT UNTIL PERIAPSIS < 50000.
LOCK THROTTLE TO 0.
addMessage("Burning complete").
WAIT 5.
RCS OFF.
WAIT 5.
statusUpdate("Warping to atmosphere").
addMessage("Coasting to atmospheric entry").
SAS ON.
SET WARP TO 2.
WAIT UNTIL ALTITUDE < 140000.
// Automatically collects data to return capsule instead of the experiment
FOR harddrive IN SHIP:MODULESNAMED("HardDrive") {
	IF harddrive:PART:NAME = "RP0-SampleReturnCapsule" {
		IF harddrive:HASEVENT("transfer data here") {
			harddrive:DOEVENT("transfer data here").
			addMessage("Transfering data to return capsule").
		}
	}
}.
WAIT 1.
STAGE. //Drop Service Module
addMessage("Service module dropped").
FOR antenna IN SHIP:MODULESNAMED("ModuleDeployableAntenna") {
	IF antenna:HASEVENT("retract antenna") {
		antenna:DOEVENT("retract antenna").
		addMessage("Retracted Antennas").
	}.
}.
FOR rcsfx IN SHIP:MODULESNAMED("ModuleRCSFX") {
	IF rcsfx:PART:NAME = "RP0-SampleReturnCommand" {
		IF rcsfx:HASFIELD("rcs") {
			rcsfx:SETFIELD("rcs",TRUE).
			addMessage("Enabled RCS on Command module").
		}
	}
}.
SAS OFF.
statusUpdate("In atmosphere").
addMessage("Descenting").
LOCK STEERING TO RETROGRADE.
UNTIL ALTITUDE < 100000 {
	IF vdot(facing:forevector, PROGRADE:forevector) <= -0.995 {
		RCS OFF.
	} ELSE {
		RCS ON.
	}
	WAIT 5.
}
LOCK STEERING TO SRFRETROGRADE.
UNTIL ALTITUDE < 30000 {
	IF vdot(facing:forevector, PROGRADE:forevector) <= -0.995 {
		RCS OFF.
	} ELSE {
		RCS ON.
	}
	WAIT 5.
}
UNLOCK STEERING.
UNLOCK RCS.