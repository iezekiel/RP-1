// "Tries" to find a transfer burn to target
// v 1.0 (kOS 1.2.0)
// Constandinos Iezekiel
@LAZYGLOBAL OFF.

PARAMETER targetPeriapsis IS 0.
PARAMETER targetInclination IS -1.
PARAMETER targetLAN IS -1.

RUNONCEPATH("0:/lib/lib_UI.ks").
LOCAL t_time IS TIME:SECONDS+600.
GLOBAL CURRENT_BODY IS BODY.
GLOBAL MAX_SCORE IS 99999.
GLOBAL MIN_SCORE IS -999999999.
GLOBAL TIME_TO_NODE IS 900.

FUNCTION mAngle
{
  PARAMETER a.
  UNTIL a >= 0 { SET a TO a + 360. }
  RETURN MOD(a,360).
}

FUNCTION nodeDV
{
  PARAMETER n.
  RETURN SQRT(n:RADIALOUT^2 + n:NORMAL^2 + n:PROGRADE^2).
}

FUNCTION targetDist
{
  PARAMETER t, u_time.
  RETURN (POSITIONAT(SHIP,u_time)-POSITIONAT(t,u_time)):MAG.
}

FUNCTION targetCA
{
  PARAMETER t, u_time1, u_time2, min_step IS 1, num_slices IS 20.
  LOCAL time_diff IS u_time2 - u_time1.
  LOCAL step IS time_diff / num_slices.
  IF step < min_step { RETURN ((u_time1 + u_time2) / 2). }

  LOCAL ca_time IS u_time1.
  LOCAL ca_dist IS targetDist(t,ca_time).

  LOCAL temp_time IS u_time1 + step.
  UNTIL temp_time > u_time2 {
    LOCAL temp_dist IS targetDist(t,temp_time).
    IF temp_dist < ca_dist {
      SET ca_dist TO temp_dist.
      SET ca_time TO temp_time.
    }
    SET temp_time TO temp_time + step.
  }
  SET u_time1 TO MAX(u_time1, ca_time-step).
  SET u_time2 TO MIN(u_time2, ca_time+step).
  RETURN targetCA(t, u_time1, u_time2, min_step, num_slices).
}

FUNCTION posAt
{
  PARAMETER c, u_time.
  LOCAL b IS ORBITAT(c,u_time):BODY.
  LOCAL p IS POSITIONAT(c, u_time).
  IF b <> BODY { SET p TO p - POSITIONAT(b,u_time). }
  ELSE { SET p TO p - BODY:POSITION. }
  RETURN p.
}

FUNCTION minAltForBody
{
  PARAMETER b.
  RETURN MAX(25000, b:RADIUS / 4).
}

FUNCTION nodeCopy
{
  PARAMETER n1, n2.
  SET n2:PROGRADE TO n1:PROGRADE.
  SET n2:NORMAL TO n1:NORMAL.
  SET n2:RADIALOUT TO n1:RADIALOUT.
  SET n2:ETA TO n1:ETA.
}

FUNCTION velAt
{
  PARAMETER c, u_time.
  RETURN VELOCITYAT(c,u_time):ORBIT.
}

FUNCTION futureOrbit
{
  PARAMETER init_orb, count.

  LOCAL orb IS init_orb.
  LOCAL i IS 0.
  UNTIL i >= count {
    IF NOT orb:HASNEXTPATCH {
      addMessage("WARNING: futureOrbit("+count+") called but patch "+i+" is the last.").
      SET i TO count.
    } ELSE { SET orb TO orb:NEXTPATCH. }
    SET i TO i + 1.
  }

  RETURN orb.
}

FUNCTION updateBest
{
  PARAMETER score_func, nn, bn, bs.
  LOCAL ns IS score_func(nn, bs).
  IF ns > bs { nodeCopy(nn, bn). }
  RETURN MAX(ns, bs).
}

FUNCTION newNodeByDiff
{
  PARAMETER n, eta_diff, rad_diff, nrm_diff, pro_diff.
  RETURN NODE(TIME:SECONDS+n:ETA+eta_diff, n:RADIALOUT+rad_diff, n:NORMAL+nrm_diff, n:PROGRADE+pro_diff).
}

FUNCTION orbitReachesBody
{
  PARAMETER orb, dest, count IS 0.

  IF orb:BODY = dest { RETURN count. }
  ELSE IF orb:HASNEXTPATCH { RETURN orbitReachesBody(orb:NEXTPATCH,dest,count+1). }
  ELSE { RETURN -1. }
}

FUNCTION futureOrbitETATime
{
  PARAMETER init_orb, count.

  LOCAL eta_time IS TIME:SECONDS.
  LOCAL orb IS init_orb.
  LOCAL i IS 0.
  UNTIL i >= count {
    IF orb:HASNEXTPATCH {
      SET eta_time TO eta_time + orb:NEXTPATCHETA.
      SET orb TO orb:NEXTPATCH.
    } ELSE {
      SET eta_time TO eta_time + orb:PERIOD.
      SET i TO count.
    }
    SET i TO i + 1.
  }
  RETURN eta_time.
}

FUNCTION improveNode
{
  PARAMETER n, score_func.
  LOCAL ubn IS updateBest@:BIND(score_func).

  LOCAL best_node IS newNodeByDiff(n,0,0,0,0).
  LOCAL best_score IS score_func(best_node,MIN_SCORE).
  LOCAL orig_score IS best_score.

  LOCAL dv_delta_power IS 4.
  FOR dv_power IN RANGE(-2,5,1) {
    FOR mult IN LIST(-1,1) {
      LOCAL curr_score IS best_score.
      LOCAL dv_delta IS mult * 2^dv_power.

      SET best_score TO ubn(newNodeByDiff(n,0,0,0,dv_delta), best_node, best_score).
      SET best_score TO ubn(newNodeByDiff(n,0,0,dv_delta,0), best_node, best_score).
      SET best_score TO ubn(newNodeByDiff(n,0,dv_delta,0,0), best_node, best_score).

      IF best_score > curr_score { SET dv_delta_power TO dv_power. }
    }
  }
  IF best_score > orig_score { nodeCopy(best_node, n). }

  LOCAL dv_delta IS 2^dv_delta_power.
  LOCAL done IS FALSE.
  UNTIL done {
    LOCAL curr_score IS best_score.

    FOR p_loop IN RANGE(-1,2,1) { FOR n_loop IN RANGE(-1,2,1) { FOR r_loop IN RANGE(-1,2,1) {
      LOCAL p_diff IS dv_delta * p_loop.
      LOCAL n_diff IS dv_delta * n_loop.
      LOCAL r_diff IS dv_delta * r_loop.
      SET best_score TO ubn(newNodeByDiff(n,0,r_diff,n_diff,p_diff), best_node, best_score).
    } } }

    IF ROUND(best_score,3) > ROUND(curr_score,3) { nodeCopy(best_node, n). }
    ELSE IF dv_delta < 0.02 { SET done TO TRUE. }
    ELSE { SET dv_delta TO dv_delta / 2. }
  }
}

FUNCTION nodeHohmann
{
  PARAMETER t, u_time, t_pe IS 0.

  LOCAL o1 IS ORBITAT(SHIP,u_time).
  LOCAL o2 IS ORBITAT(t,u_time).
  LOCAL b IS o1:BODY.
  LOCAL r1 IS o1:SEMIMAJORAXIS.
  LOCAL r2 IS o2:SEMIMAJORAXIS + t_pe.

  LOCAL dv IS SQRT(b:MU/r1) * (SQRT((2*r2)/(r1+r2)) -1).
  IF r2 < r1 { SET dv TO -dv. }

  LOCAL transfer_t IS CONSTANT:PI * SQRT( ((r1+r2)^3) / (8 * b:MU) ).
  LOCAL desired_phi IS 180 - (transfer_t * 360 / o2:PERIOD).

  LOCAL rel_angv IS (360 / o1:PERIOD) - (360 / o2:PERIOD).

  LOCAL s_pos IS posAt(SHIP, u_time).
  LOCAL t_pos IS posAt(t, u_time).
  LOCAL s_normal IS VCRS(velAt(SHIP,u_time),s_pos).
  LOCAL s_t_cross IS VCRS(s_pos,t_pos).

  LOCAL start_phi IS VANG(s_pos,t_pos).
  IF VDOT(s_normal, s_t_cross) > 0 { SET start_phi TO 360 - start_phi. }

  LOCAL phi_delta IS mAngle(start_phi - desired_phi).
  IF rel_angv < 0 { SET phi_delta TO phi_delta - 360. }

  LOCAL hnode IS NODE(u_time + (phi_delta / rel_angv), 0, 0, dv).

  ADD hnode. WAIT 0.
  UNTIL NOT hnode:ORBIT:HASNEXTPATCH OR ETA:TRANSITION > hnode:ETA + transfer_t
        OR hnode:ORBIT:NEXTPATCH:BODY:NAME = t:NAME {
    SET hnode:ETA TO hnode:ETA + ABS(360/rel_angv).
    WAIT 0.
  }
  REMOVE hnode. WAIT 0.

  RETURN hnode.
}

FUNCTION scoreNodeDestOrbit
{
  PARAMETER dest, pe, i, lan, n, bs.
  LOCAL score IS 0.
  LOCAL min_pe IS minAltForBody(TARGET).
  ADD n. WAIT 0.
  LOCAL orb IS n:ORBIT.
  LOCAL orb_count IS orbitReachesBody(orb,TARGET).
  IF orb_count >= 0 {
    SET score TO MAX_SCORE - nodeDV(n).

    LOCAL next_orb IS futureOrbit(orb,orb_count).
    LOCAL next_pe IS next_orb:PERIAPSIS.
    LOCAL next_i IS next_orb:INCLINATION.
    LOCAL next_lan IS next_orb:LAN.

    IF pe < min_pe {

      LOCAL pe_diff IS ABS(next_pe - pe).
      IF pe_diff < 2500 { SET score TO score + (10 * SQRT(2500-pe_diff)). }
      ELSE { SET score TO score - SQRT(pe_diff / 10). }

    } ELSE {

      IF next_pe < min_pe {
        SET score TO score - SQRT((min_pe - next_pe) / 10).
      }

      LOCAL r0 IS dest:RADIUS + next_pe.
      LOCAL r1 IS dest:RADIUS + pe.

      LOCAL a0 IS dest:RADIUS + ((next_pe + next_orb:APOAPSIS) / 2).
      LOCAL a1 IS dest:RADIUS + ((next_pe + pe) / 2).
      LOCAL v0 IS SQRT(dest:MU * ((2/r0)-(1/a0))).
      LOCAL v1 IS SQRT(dest:MU * ((2/r0)-(1/a1))).
      LOCAL dv_oi IS ABS(v1 - v0).
      SET score TO score - dv_oi.

      LOCAL v2 IS SQRT(dest:MU * ((2/r1)-(1/a1))).
      LOCAL v3 IS SQRT(dest:MU/r1).
      LOCAL dv_pe IS ABS(v3 - v2).
      SET score TO score - dv_pe.

      IF i >= 0 {
        IF lan < 0 { SET lan TO next_lan. }
        LOCAL ang IS VANG(orbitNormal(dest,i,lan),orbitNormal(dest,next_i,next_lan)).
        LOCAL v_circ IS SQRT(dest:MU/r1).
        LOCAL dv_inc IS 2 * v_circ * SIN(ang/2).
        SET score TO score - dv_inc.
      }
    }

  } ELSE IF bs < 0 AND dest:HASBODY {
    LOCAL pb IS dest:BODY.
    SET orb_count TO orbitReachesBody(orb,pb).
    UNTIL orb_count >= 0 OR NOT pb:HASBODY {
      SET dest TO pb.
      SET pb TO pb:BODY.
      SET orb_count TO orbitReachesBody(orb,pb).
    }
    IF orb_count >= 0 {
      LOCAL u_time1 IS futureOrbitETATime(orb,orb_count).
      LOCAL u_time2 IS futureOrbitETATime(orb,orb_count+1).
      SET score TO -targetDist(dest,targetCA(dest,u_time1,u_time2,5,10)) / 1000.
    } ELSE { SET score TO MIN_SCORE. }

  } ELSE { SET score TO MIN_SCORE. }
  REMOVE n.

  RETURN score.
}

uiBTS().
PRINT "           Transfering to "+TARGET:NAME+"           "      AT (0,2).
statusUpdate("Calculating ...").
addMessage("Seeking the best Injection node.").
LOCAL t_pe IS (TARGET:RADIUS + targetPeriapsis) * COS(MAX(targetInclination,0)).
LOCAL node IS nodeHohmann(TARGET, t_time, t_pe).
improveNode(node,scoreNodeDestOrbit@:BIND(TARGET,targetPeriapsis,targetInclination,targetLAN)).
ADD node.
statusUpdate("Ready to execute node").
addMessage("Trans-"+TARGET:NAME+" Injection node added.").
addMessage("Dv: "+round(node:deltav:mag, 1)+" m/s.").
WAIT 1.
RUNPATH("0:/lib/Node.ks").
WAIT 10.
CLEARSCREEN.
