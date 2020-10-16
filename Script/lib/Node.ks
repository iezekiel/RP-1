// Executes a node on an existing script
// v 1.2 (kOS 1.2.0)
// Constandinos Iezekiel
@LAZYGLOBAL OFF.

PARAMETER stageAllow is false.

IF HASNODE {
	statusUpdate("Executing node.").
	LOCAL node IS NEXTNODE.
	LOCAL nodeDob IS burnTime(node).
	addMessage("Orient to burn for " + ROUND(nodeDob,1) + "s.").
	RCS ON.
	SAS OFF.
	lock steering to lookdirup(node:deltav, ship:facing:topvector).
	LOCAL nodeFacing is lookdirup(node:deltav, ship:facing:topvector).
	LOCAL nodeAccel is ship:maxthrust / ship:mass.
	wait until vdot(facing:forevector, nodeFacing:forevector) >= 0.995 or node:eta <= nodeDob / 2.
	LOCAL nodeHang is (node:eta - nodeDob/2) - 11.
	if nodeHang > 0 {
		statusUpdate("Warping...").
		Warp(nodeHang).
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
	lock throttle to 0.
	unlock steering.
	if node:deltav:mag > 0.1 {
		addMessage("Fine tune with RCS").
		SET throttle TO 0.
		local t0 is time.
		until (node:deltav:mag < 0.1 or (time - t0):seconds > 15) AND HASNODE {
			local sense is ship:facing.
			local dirV is V(
					vdot(node:deltav, sense:starvector),
					vdot(node:deltav, sense:upvector),
					vdot(node:deltav, sense:vector)
			).
			set ship:control:translation to dirV:normalized.
		}
	}
	if node:deltav:mag > 0.1 {
		addMessage("BURN FAULT " + round(node:deltav:mag, 1) + " m/s").
	}
	IF HASNODE{
		remove node.
	}
	statusUpdate("Done").
	addMessage("Node executed").
	releaseControls().
}

