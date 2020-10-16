// Launch Library
// Various functions about launch
// v 1.2 (kOS 1.2.0)
// Constandinos Iezekiel
@LAZYGLOBAL OFF.

PARAMETER cdIgnite IS 3.    //Engine ignition timer

LOCAL prevMaxThrust TO 0.   //Used in Autostage
LOCAL maxQ IS 0.            //Max Q
LOCAL maxQ_found IS 0.      //Max Q found variable
LOCAL towerHeight IS shipHeight() + ALT:RADAR.  // Determine Tower Height

FUNCTION countdownSequence
{
	//Pre-launch Countdown Sequence
	statusUpdate("Commencing Countdown Sequence").
	addMessageWithTime("T-" + convertTime(11), "All systems are Go!").
	WAIT 1.
	// Final Countdown Sequence
	FROM {LOCAL x IS 10.} UNTIL x = 0 STEP {SET x TO x - 1.} DO {
		IF x = 10 addMessageWithTime("T-" + convertTime(x), "Guidance is internal").
		timerUpdateWithTime("T-" + convertTime(x)).
		// Pre-ignition for engine spooling
		IF x = CEILING(cdIgnite) {
			WAIT (CEILING(cdIgnite) - cdIgnite).
			addMessageWithTime("T-" + convertTime(ROUND(cdIgnite,1)), "Ignition Sequence Start").
			statusUpdate("Ignition Sequence").
			STAGE.
			WAIT (1 - (CEILING(cdIgnite) - cdIgnite)).
		} ELSE {
			WAIT 1.
		}
	}// Countdown Sequence
}

FUNCTION liftSequence
{
  PARAMETER doStage IS TRUE.

  // Check thrust before releasing clamps - abort if engine failure.
  IF TWRCalc(current) > 1 {
		addMessage("All Engines Running - Releasing Clamps").
		LOCK STEERING TO HEADING(0,90).   // Keep at initial orientation until guidance active
		IF DOSTAGE {
			STAGE.
		}
		WAIT 0.001.
  }	ELSE {
		addMessage("Engine Failure. Launch Aborted").
		LOCK THROTTLE TO 0.
		WAIT 5.
  }	// End engine check
  WHEN SHIP:AIRSPEED > 3 THEN {
		PRINT "MET:              "                                   AT (0,7).
		statusUpdate("Lift-off").
    addMessage("LIFT OFF of " + shipName).
    addMessage("Thrust - " + ROUND(MAXTHRUST,0) + "kN / TWR - " + ROUND(TWRCalc(current),2)).
  }
  UNTIL FALSE {
		timerUpdate().
		WAIT 0.001.
		IF ALT:RADAR > towerHeight {
			addMessage("Tower Clear.").
			WAIT 0.001.
			BREAK.
		}
  } // End lift_mode
}

FUNCTION checkMaxQ {
	IF maxQ_found = 0 {
		LOCAL newQ IS 0.
		SET newQ TO SHIP:DYNAMICPRESSURE.
		IF newQ >= maxQ {
			SET maxQ TO newQ.
		} ELSE {
			SET maxQ_found TO 1.
			addMessage("Passing MaxQ - " + ROUND(maxQ*CONSTANT:ATMtokPa,0) + "kPa").
		}
	}
}

FUNCTION flameOut {
  PARAMETER waitTime IS 1.

  LOCAL thrustDv IS ROUND(prevMaxThrust*0.5,2). //Set thrustDv to half
  IF MAXTHRUST < (prevMaxThrust - thrustDv) {
    STAGE.
    addMessage("Autostage to " + STAGE:NUMBER).
    WAIT waitTime.
  }
  SET prevMaxThrust TO MAXTHRUST.
}

//Activates parts on certain altitudes
FUNCTION activators {
  IF SHIP:ALTITUDE > 100000 {
    FOR module IN SHIP:MODULESNAMED("ProceduralFairingDecoupler") {
			if module:hasevent("jettison fairing") {
				module:doevent("jettison fairing").
				addMessage("Jettisoning Fairings").
			}
    }.
    WAIT 0.2.
  }.
  IF SHIP:ALTITUDE > 140000 {
    FOR antenna IN SHIP:MODULESNAMED("ModuleDeployableAntenna") {
      IF antenna:HASEVENT("extend antenna") {
        antenna:DOEVENT("extend antenna").
        addMessage("Extended Antennas").
      }.
    }.
  }.
}

//Arm Parachute
FUNCTION chute{
	PARAMETER event.

	FOR RealChute IN SHIP:modulesNamed("RealChuteModule") {
    addMessage("Real Chute: " + event).
    RealChute:doevent(event).
    BREAK.
	}.
}