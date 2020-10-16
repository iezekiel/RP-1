// UI Scipt
// Manages UI
// v 1.2 (kOS 1.2.0)
// Constandinos Iezekiel
@LAZYGLOBAL OFF.

LOCAL shipName IS SHIP:NAME.    //Mission Name
LOCAL mCount IS TERMINAL:HEIGHT - 2.
LOCAL rCount IS 14.
LOCAL iCount IS 14.
LOCAL mTime IS "".
LOCK mTime to "T+" + convertTime(MISSIONTIME).

FUNCTION uiLaunchSounding
{
	PRINT "===================================================="      AT (0,0).
	PRINT "   Sounding Rocket Launch System (Ver "+verNum+")   "      AT (0,1).
	PRINT "                 Launch Sequence                    "      AT (0,2).
	PRINT "===================================================="      AT (0,3).
	PRINT " "                                                         AT (0,4).
	PRINT "Mission Name:     " + shipName + " (" + CORE:TAG + ")"     AT (0,5).
	PRINT "Status:           "                                        AT (0,6).
	PRINT "Countdown:        "                                        AT (0,7).
	PRINT " "                                                         AT (0,8).
	PRINT "                     EVENT LOG                      "      AT (0,9).
	PRINT "===================================================="      AT (0,10).
	PRINT " TIME           MESSAGE                             "      AT (0,11).
	PRINT " "                                                         AT (0,12).
}

FUNCTION uiProgradeLaunch
{
	PRINT "===================================================="      AT (0,0).
	PRINT "      Prograde Launch System (Ver "+verNum+")       "      AT (0,1).
	PRINT "                 Launch Sequence                    "      AT (0,2).
	PRINT "===================================================="      AT (0,3).
	PRINT " "                                                         AT (0,4).
	PRINT "Mission Name:     " + shipName + " (" + CORE:TAG + ")"     AT (0,5).
	PRINT "Status:           "                                        AT (0,6).
	PRINT "Countdown:        "                                        AT (0,7).
	PRINT " "                                                         AT (0,8).
	PRINT "                     EVENT LOG                      "      AT (0,9).
	PRINT "===================================================="      AT (0,10).
	PRINT " TIME           MESSAGE                             "      AT (0,11).
	PRINT " "                                                         AT (0,12).
}

FUNCTION uiLaunchRGS
{
  PRINT "===================================================="      AT (0,0).
  PRINT "      RGS - Rocket Guidance System (Ver "+verNum+")    "   AT (0,1).
  PRINT "                 Launch Sequence                    "      AT (0,2).
  PRINT "===================================================="      AT (0,3).
  PRINT " "                                                         AT (0,4).
  PRINT "Mission Name:     " + shipName + " (" + CORE:TAG + ")"     AT (0,5).
  PRINT "Status:           "                                        AT (0,6).
  PRINT "Countdown:        "                                        AT (0,7).
  PRINT " "                                                         AT (0,8).
  PRINT "                     EVENT LOG                      "      AT (0,9).
  PRINT "===================================================="      AT (0,10).
  PRINT " TIME           MESSAGE                             "      AT (0,11).
  PRINT " "                                                         AT (0,12).
}

FUNCTION uiBTS
{
  PRINT "===================================================="      AT (0,0).
  PRINT "        Body Transfer System (Ver "+verNum+")       "      AT (0,1).
  PRINT "                                                    "      AT (0,2).
  PRINT "===================================================="      AT (0,3).
  PRINT " "                                                         AT (0,4).
  PRINT "Mission Name:     " + shipName                             AT (0,5).
  PRINT "Status:           "                                        AT (0,6).
  PRINT " "                                                         AT (0,7).
  PRINT " "                                                         AT (0,8).
  PRINT "                     EVENT LOG                      "      AT (0,9).
  PRINT "===================================================="      AT (0,10).
  PRINT " TIME           MESSAGE                             "      AT (0,11).
  PRINT " "                                                         AT (0,12).
}

FUNCTION uiNodeSingle
{
  PRINT "===================================================="      AT (0,0).
  PRINT "      Maneuver Execute System (Ver "+verNum+")      "       AT (0,1).
  PRINT "                                                    "      AT (0,2).
  PRINT "===================================================="      AT (0,3).
  PRINT " "                                                         AT (0,4).
  PRINT "Mission Name:     " + shipName                             AT (0,5).
  PRINT "Status:           "                                        AT (0,6).
  PRINT " "                                                         AT (0,7).
  PRINT " "                                                         AT (0,8).
  PRINT "                     EVENT LOG                      "      AT (0,9).
  PRINT "===================================================="      AT (0,10).
  PRINT " TIME           MESSAGE                             "      AT (0,11).
  PRINT " "                                                         AT (0,12).
}

FUNCTION uiOrbitalManeuver
{
  PRINT "===================================================="      AT (0,0).
  PRINT "      Orbital Maneuver System (Ver "+verNum+")      "      AT (0,1).
  PRINT "                                                    "      AT (0,2).
  PRINT "===================================================="      AT (0,3).
  PRINT " "                                                         AT (0,4).
  PRINT "Mission Name:     " + shipName                             AT (0,5).
  PRINT "Status:           "                                        AT (0,6).
  PRINT " "                                                         AT (0,7).
  PRINT " "                                                         AT (0,8).
  PRINT "                     EVENT LOG                      "      AT (0,9).
  PRINT "===================================================="      AT (0,10).
  PRINT " TIME           MESSAGE                             "      AT (0,11).
  PRINT " "                                                         AT (0,12).
}

FUNCTION uiLanding
{
  PRINT "===================================================="      AT (0,0).
  PRINT "           Landing System (Ver "+verNum+")          "      AT (0,1).
  PRINT "                                                    "      AT (0,2).
  PRINT "===================================================="      AT (0,3).
  PRINT " 																									 "			AT (0,4).
  PRINT "Mission Name:     " + shipName                             AT (0,5).
  PRINT "Status:           "                                        AT (0,6).
  PRINT "																										 "      AT (0,7).
  PRINT " "                                                         AT (0,8).
  PRINT "                     EVENT LOG                      "      AT (0,9).
  PRINT "===================================================="      AT (0,10).
  PRINT " TIME           MESSAGE                             "      AT (0,11).
  PRINT " "                                                         AT (0,12).
}

FUNCTION addMessage {
  PARAMETER msg.

  IF iCount <= mCount {
    PRINT mTime AT (0,iCount).
    PRINT msg AT (14,iCount).
    SET iCount TO iCount + 1.
    RETURN.
  } ELSE {
    FROM {LOCAL x IS rCount.} UNTIL x = iCount STEP {SET x TO x + 1.} DO {
      PRINT "                                                    " AT (0,x).
    }
    SET iCount TO rCount.
    PRINT mTime AT (0,iCount).
    PRINT msg AT (14,iCount).
    SET iCount TO iCount + 1.
    RETURN.
  }
}

FUNCTION addMessageWithTime {
  PARAMETER msgTime.
  PARAMETER msg.

  IF iCount <= mCount {
    PRINT msgTime AT (0,iCount).
    PRINT msg AT (14,iCount).
    SET iCount TO iCount + 1.
    RETURN.
  } ELSE {
    FROM {LOCAL x IS rCount.} UNTIL x = iCount STEP {SET x TO x + 1.} DO {
      PRINT "                                                    " AT (0,x).
    }
    SET iCount TO rCount.
    PRINT msgTime AT (0,iCount).
    PRINT msg AT (14,iCount).
    SET iCount TO iCount + 1.
    RETURN.
  }
}

FUNCTION statusUpdate {
  PARAMETER newStatus.
  PRINT "                                "  AT (18,6).
  PRINT newStatus AT (18,6).
}

FUNCTION timerUpdate {
  PRINT "                            "  AT (18,7).
  PRINT mTime AT (18,7).
}

FUNCTION timerUpdateWithTime {
  PARAMETER newTime.
  PRINT "                            "  AT (18,7).
  PRINT newTime AT (18,7).
}

FUNCTION padZ {
  PARAMETER t.
    RETURN (""+t):PADLEFT(2):REPLACE(" ","0").
}

FUNCTION convertTime {
  PARAMETER cTime.

  LOCAL hpd IS KUNIVERSE:HOURSPERDAY.
  LOCAL s TO FLOOR(cTime).
  LOCAL m TO FLOOR(s/60).
  SET s TO MOD(s,60).
  LOCAL h TO FLOOR(m/60).
  SET m TO MOD(m,60).
  LOCAL d TO FLOOR(h/hpd).
  SET h TO MOD(h,hpd).
  IF d = 0 {
    RETURN padZ(h) + ":" + padZ(m) + ":" + padZ(s).
  } ELSE {
    RETURN d + "d " + padZ(h) + ":" + padZ(m) + ":" + padZ(s).
  }
}