// Periapsis Change
// v 1.1 (kOS 1.2.0)
// Constandinos Iezekiel
@LAZYGLOBAL OFF.

PARAMETER newPeriapsis.

RUNONCEPATH("0:/lib/lib_UI.ks").
RUNONCEPATH("0:/lib/lib_Ship.ks").
RUNONCEPATH("0:/lib/lib_Utils.ks").
CLEARSCREEN.

uiOrbitalManeuver().
//PRINT "                 Periapsis Change                   "      AT (0,2).
addMessage("Periapsis: " + round(periapsis/1000) + "km -> " + round(newPeriapsis/1000) + "km").
statusUpdate("Calculating ...").
// present orbit properties
LOCAL rb to BODY:RADIUS.
LOCAL mu to BODY:MU.
LOCAL vom to velocity:orbit:mag.  // actual velocity
LOCAL r to rb + altitude.         // actual distance to body
LOCAL ra to rb + apoapsis.        // radius in apoapsis
LOCAL va to sqrt( vom^2 + 2*mu*(1/ra - 1/r) ). // velocity in apoapsis
LOCAL a to (periapsis + 2*rb + apoapsis)/2. // semi major axis present orbit
// future orbit properties
LOCAL r2 to rb + apoapsis.    // distance after burn at apoapsis
LOCAL a2 to (newPeriapsis + 2*rb + apoapsis)/2. // semi major axis target orbit
LOCAL v2 to sqrt( vom^2 + (mu * (2/r2 - 2/r + 1/a - 1/a2 ) ) ).
// setup node
LOCAL deltav to v2 - va.
addMessage("Apoapsis burn: " + round(va) + ", dv:" + round(deltav) + " -> " + round(v2) + "m/s").
LOCAL nd to node(time:seconds + eta:apoapsis, 0, 0, deltav).
add nd.
statusUpdate("Ready to execute node").
addMessage("Node created.").
WAIT 1.
RUNPATH("0:/lib/Node.ks").
WAIT 10.
CLEARSCREEN.