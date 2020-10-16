// Utilities Library
// v 1.0 (kOS 1.2.0)
// Constandinos Iezekiel
@LAZYGLOBAL OFF.

FUNCTION Warp
{
	PARAMETER dt.
	LOCAL warp_physics is true.
	LOCAL warp_t0 is time:seconds.
	LOCAL warp_t1 is warp_t0 + dt - 1.
	RCS OFF.
	SAS ON.
	if dt < 0 {
			set warp_t1 to warp_t0.
	}
	lock warp_dt to warp_t1 - time:seconds.
	until time:seconds >= warp_t1 {
			set warpmode to "rails".
			warpto(warp_t1).
			wait warp_dt.
			set warp_physics to false.
	}
	RCS ON.
	SAS OFF.
	UNLOCK warp_dt.
}