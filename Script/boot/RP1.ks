// Boot script
// Initializes terminal and all dependencies then starts program.
// v 1.2 (kOS 1.2.0)
@LAZYGLOBAL OFF.

SET CONFIG:IPU TO 2000.
CORE:DOEVENT("Open Terminal").
SET TERMINAL:BRIGHTNESS TO 0.8.
SET TERMINAL:CHARHEIGHT TO 10.
SET TERMINAL:WIDTH TO 52.
SET TERMINAL:HEIGHT TO 40.
CLEARSCREEN.

LOCAL missionFile IS CORE:TAG + ".mission.ks".
SWITCH TO 0.
RUNONCEPATH("0:/missions/"+missionFile).