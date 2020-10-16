// Executes a node
// v 1.2 (kOS 1.2.0)
// Constandinos Iezekiel
@LAZYGLOBAL OFF.

PARAMETER stageAllow is false.

FUNCTION Warpee
{
	PARAMETER dt.

	// Number of seconds to sleep during physics-warp loop
	LOCAL warp_tick is 5.
	LOCAL warp_physics is true.
	LOCAL warp_t0 is time:seconds.
	LOCAL warp_t1 is warp_t0 + dt - 1.

	// special case: negative interval means skip all loop iterations & return
	if dt < 0 {
		set warp_t1 to warp_t0.
	}

	lock warp_dt to warp_t1 - time:seconds.
	lock warp_atmo to ship:altitude / max(ship:altitude, body:atm:height).

	until time:seconds >= warp_t1 {
		if ship:altitude < body:atm:height and ship:status <> "PRELAUNCH" and ship:status <> "LANDED" {
			set warpmode to "physics".
			set warp_physics to true.

			if warp_atmo > 0.8 {
			set warp to 3.
			} else if warp_atmo > 0.6 {
			set warp to 2.
			} else if warp_atmo > 0.2 {
			set warp to 1.
			} else {
			set warp to 0.
			}

			wait warp_tick.
		} else if warp_physics = true {
			// advance warp in case it was interrupted
			set warpmode to "rails".
			warpto(warp_t1).
			wait warp_dt.
			set warp_physics to false.
		}
	}

	UNLOCK warp_dt.
	UNLOCK warp_atmo.
}

FUNCTION getISP
{
	local isp is 0.
	LOCAL enginesList IS "".
	LIST ENGINES IN enginesList.
	for eng in enginesList{
		if eng:stage=stage:number and eng:flameout=false{
			eng:activate.
			set isp to isp + eng:VISP.
		}
	}
	RETURN isp.
}

FUNCTION burnTime
{
	PARAMETER n.

	LOCAL CMAS IS SHIP:MASS.
	LOCAL EISP IS getISP().
	LOCAL MAXT IS SHIP:MAXTHRUST.
	LOCAL CVEL IS n:DELTAV:MAG.
	LOCAL E IS CONSTANT():E.
	LOCAL G IS 9.80665.             // Gravity for ISP Conv
	LOCAL I IS EISP * G.            // ISP in m/s units.
	LOCAL M IS CMAS * 1000.         // Mass in kg.
	LOCAL T IS MAXT * 1000.         // Thrust in N.
	LOCAL F IS T/I.                 // Fuel flow in kg/s.
	RETURN (M/F)*(1-E^(-CVEL/I)).   // Burn time in seconds
}

IF HASNODE {
	statusUpdate("Executing node.").
	LOCAL node IS NEXTNODE.
	LOCAL nodeDob IS burnTime(node).
	addMessage("Orient to burn for " + ROUND(nodeDob,1) + "s.").
	IF node:deltav:mag < 5 {
			SET SHIP:CONTROL:FORE TO 0.01.
	}
	RCS ON.
	lock steering to lookdirup(node:deltav, ship:facing:topvector).
	LOCAL nodeFacing is lookdirup(node:deltav, ship:facing:topvector).
	LOCAL nodeAccel is ship:maxthrust / ship:mass.
	wait until vdot(facing:forevector, nodeFacing:forevector) >= 0.995 or node:eta <= nodeDob / 2.
	// warp to burn time; give 3 seconds slack for final steering adjustments
	LOCAL nodeHang is (node:eta - nodeDob/2) - 11.
	if nodeHang > 0 {
		statusUpdate("Warping...").
		Warpee(nodeHang).
		wait 3.
	}
	set ship:control:fore to 1.
	wait 5.
	LOCAL nodeDone  is false.
	LOCAL nodeDv0   is node:deltav.
	LOCAL nodeDvMin is nodeDv0:mag.
	statusUpdate("Executing node").
	addMessage("Begin burn.").
	lock throttle to 1.
	wait 1.
	set ship:control:fore to 0.
	until nodeDone
	{
		set nodeAccel to ship:availablethrust / ship:mass.
		if(node:deltav:mag < nodeDvMin) {
			set nodeDvMin to node:deltav:mag.
		}
		if nodeAccel > 0 {
			set nodeDone to (vdot(nodeDv0, node:deltav) < 0) or
											(node:deltav:mag > nodeDvMin + 1) or
											(node:deltav:mag <= 1).
		} else {
			if stageAllow {
				// no nodeAccel -- out of fuel; time to auto stage!
				addMessage("Stage " + stage:number + " separation during burn.").
				local now is time:seconds.
				if ship:maxthrust=0 {
						stage.
						wait until stage:ready.
				}
			} else {
				addMessage("Stage " + stage:number + " failed during burn. Retrying").
				lock throttle to 0.
				set ship:control:fore to 1.
				wait 3.
				lock throttle to 1.
				set ship:control:fore to 0.
			}
		}
	}
	UNLOCK RCS.
	UNLOCK THROTTLE.
	RCS OFF.
	lock throttle to 0.
	set ship:control:pilotmainthrottle to 0.
	unlock steering.

	// Make fine adjustments using RCS (for up to 15 seconds)
	if node:deltav:mag > 0.1 {
		addMessage("Fine tune with RCS").
		RCS ON.
		local t0 is time.
		until node:deltav:mag < 0.1 or (time - t0):seconds > 15 {
			local sense is ship:facing.
			local dirV is V(
					vdot(node:deltav, sense:starvector),
					vdot(node:deltav, sense:upvector),
					vdot(node:deltav, sense:vector)
			).
			set ship:control:translation to dirV:normalized.
		}
		set ship:control:translation to 0.
	}
	// Fault if remaining dv > 5% of initial AND mag is > 0.1 m/s
	if node:deltav:mag > 0.1 {
			addMessage("BURN FAULT " + round(node:deltav:mag, 1) + " m/s").
	}
	IF HASNODE{
			remove node.
	}
	statusUpdate("Done").
	addMessage("Node executed").
	UNLOCK RCS.
	UNLOCK THROTTLE.
	set ship:control:translation to 0.
	RCS OFF.
}

