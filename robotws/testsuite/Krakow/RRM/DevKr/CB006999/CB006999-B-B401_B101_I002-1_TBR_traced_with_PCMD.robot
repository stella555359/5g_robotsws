*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == INTRODUCTION ==
...      This feature introduces gNB support for planned AMF removal (maintenance, SW upgrades).
...      Upon sending the TNLA UE BINDING RELEASE REQUEST message by AMF over NG interface,
...      the gNB considers GUAMI(s) for reselection according to AMF reselection algorithm,
...      and directs UE to use that GUAMI.
...
...      == TEST SET NAME ==
...      CB006999-B	UE TNLA BINDING RELEASE REQUEST handling with PCMD and cell tracing
...      == TESTING SPLIT ==
...      CB006999-A AMF STATUS INDICATION Handling
...      CB006999-B	UE TNLA BINDING RELEASE REQUEST handling
...      == AUTHORS ==
...      - Marek Kieltyka <marek.kieltyka@nokia.com>
...      - Karolina Sroczyk <karolina.sroczyk@nokia.com>
...      - Gabriela Stasiuk <gabriela.stasiuk@nokia.com>
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
...      == REFERENCES ==
...      - CB006999 CFAM
...      https://nokia.sharepoint.com/:f:/r/sites/ASCOP/AS%20Documents/FS1TAs-CFAMs/CB/CB006800%20-%20CB006999/CFAM/
...      CB006999%20gNB%20support%20for%20AMF%20Status%20Indication/CP2/CP2_Approved?csf=1&web=1
...      - L3 Testplan
...      https://nokia-my.sharepoint.com/:x:/r/personal/agnieszka_wlodarczyk_nokia_com/_layouts/15/
...      guestaccess.aspx?e=GxcEku&share=ESPUb8cGM2dMsgKohhtKI5gBg7y0YwPVpncWZIE9fxBKmg
...      == HISTORY ==
...         [26.10.2021] - Created TC

Resource    ./resources/CB006999.robot
Resource    ./resources/CB006999-B_setups_teardowns.robot

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup  Run Keywords
...  Setup emss    bts_id=1
...  AND  Create all devices aliases
...  AND  Configure CB006999 basic params via yaml    pcmd_config=${True}
#...  AND  Setup egate  egate_port=20000  alias=default
...  AND  ute_admin.Setup admin    bts_host=192.168.255.1    bts_port=443    use_ssl=True
...  AND  Reach OnAir with retries    lua_cfg=${lua_cfg_file}

*** Variables ***
${lua_cfg_file}=   ${CURDIR}/config/egate_SA_2c_3amf_APoABIO.lua

*** Test Cases ***
CB006999-B-B401-AMF_reselection_performed_after_TBR
    [Tags]    BB401
    [Documentation]
    ...  DESCRIPTION:
    ...  == Info ==
    ...  This testcase describes the gNB behavior when NRBTS.actAmfPlannedRemoval feature flag is deactivated,
    ...  and NGAP: UE TNLA Binding Release Request (TBR) is sent for attached UE. Expected behavior is that UE gets
    ...  released as result of receiving and applying TBR regardless of NRBTS.actAmfPlannedRemoval feature flag status.
    ...  Testcase also shows that NGAP cell trace now includes NGAP: UE TNLA Binding Release Request messages.
    ...  == Precondition ==
    ...  - gNB up and running
    ...  - NRBTS.actNgcFlexSaMode=true (5GC000740)
    ...  - NRBTS.actAmfPlannedRemoval=false
    ...  - NRBTS.actCellTraceReport=true
    ...  - NRMTRACECU.jobType=TraceOnly
    ...  - NRMTRACECU.traceNGAPSetting=all
    ...  - Trace Collection Entity (TCE) is configured under MNL.TCEADM.TCE MOC
    ...  - Established NG connections AMF-gNB
    ...  - AMF-1 is configured with 2 GUAMIs (GUAMI1, GUAMI2) - SERVEDAMF-1
    ...  - AMF-2 is configured with 1 GUAMI (GUAMI3) - SERVEDAMF-2
    ...  - AMF-3 is configured with 1 GUAMI (GUAMI4) - SERVEDAMF-3
    ...  - GUAMI1 has backup AMF set to AMF-2
    ...  - 3 AMFs up and running
    ...  == Flow ==
    ...  1.  Attach UE1 to AMF-1:GUAMI-1
    ...  2.  Verify that UE1 is attached to AMF-1:GUAMI-1
    ...  3.  Send NGAP: UE TNLA Binding Release Request from AMF-1 for UE1
    ...  4.  Verify that NGAP: UE TNLA Binding Release Request is sent
    ...  5.  Verify that NGAP: UE TNLA Binding Release Request is traced with TCE
    ...  6.  Send NR-RRC: UL Information Transfer with PDU Session Modification Request from UE1
    ...  7.  Verify that gNB performs successful AMF reselection for UE1, resulting in choosing backup AMF-2 as new AMF
    ...  8.  Verify that UE is attached to AMF-2:GUAMI-1
    ...  9.  Send NR-RRC: UL Information Transfer with PDU Session Modification Request from UE1
    ...  10. Verify that gNB sends NGAP messages to AMF-2
    ...  11. Verify that PM counters are incremented
    ...  == Postcondition ==
    ...  -  NGAP link gNB-AMF1 is active
    ...  -  NGAP link gNB-AMF2 is active
    ...  -  UE1 is detached
    ...  -  Cell tracing is turned off
    ...  == TESTING TOOLS ==
    ...  AirPhone, 5GCSIM, UTE
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode
    ...  - HARDWARE ID: gNB(ABIL + ASIK) with simulated AEQA radio module - NR_BAND: n78
    ...  == REQUIREMENTS COVERAGE ==
    ...  -  USCB006999-B#4
    ...  -  CB006999-B-B401
    ...  == REQUIRED LOGS ==
    ...  NGAP
    ...  == AUTHOR ==
    ...  - Marek Kieltyka <marek.kieltyka@nokia.com>
    ...  == REFERENCES ==
    ...  -  CFAM CB006999-2445
    ...  -  CFAM CB006999-2777

    [Setup]  Prepare test environment BB401

    Attach UE1 to AMF1:GUAMI:1 and run traffic on PDU 1
    Verify that NGAP: Initial Context Setup Request is traced with TCE

    Send UE TNLA BRR for UE1 from AMF1 with both valid UE NGAP ID
    Verify that UE TNLA BRR is traced with TCE

    Expect that UE-1 uses AMF2 after NGAP: UPLINK NAS TRANSPORT
    Trigger UE1 to send PDU Session Modification for PDU1
    Verify that UE-1 uses AMF2 after NGAP: UPLINK NAS TRANSPORT

    Trigger UE1 to send PDU Session Modification for PDU1
    Verify that PDU Session Modification sent to AMF2 is traced with TCE

    Wait until PM counters file is ready and saved
    Verify PM counters for gNB initiated AMF reselection are incremented successfully: attempts:1, fails:0, successes:1

    Stop and verify 20MBps UL and DL traffic on UE1 PDU1 QFI1

    [Teardown]  Teardown test environment BB401

CB006999-B-B101-1-TBR_for_GUAMI_with_timerApproachForGUAMIRemoval_after_ASI_backupAMF_not_used
    [Tags]    BB101-1    SKIPRUN
    [Documentation]
    ...  DESCRIPTION:
    ...  == Info ==
    ...  This test scenario describes handling UE TNLA BINDING RELEASE REQUEST message after AMF STATUS INDICATION
    ...  with CellTrace validation when NRBTS.actAmfPlannedRemoval feature flag is activated. Also it shows that
    ...  NGAP:TNLA BINDING RELEASE has higher priority over timer approach set by NGAP: AMF STATUS INDICATION and that
    ...  NGAP:TNLA BINDING RELEASE affects only indicated UE.
    ...
    ...  == Precondition ==
    ...  - gNB up and running
    ...  - NRBTS.actNgcFlexSaMode=true (5GC000740)
    ...  - NRBTS.actAmfPlannedRemoval=true
    ...  - NRBTS.amfPlannedRemovalTimer=50
    ...  - NRBTS.actCellTraceReport=true
    ...  - NRMTRACECU.jobType=TraceOnly
    ...  - NRMTRACECU.traceNGAPSetting=all
    ...  - SERVEDAMF-2.relativeAMFCapacity=1
    ...  - SERVEDAMF-3.relativeAMFCapacity=100
    ...  - Trace Collection Entity (TCE) is configured under MNL.TCEADM.TCE MOC
    ...  - Established NG connections AMF-gNB
    ...  - AMF-1 is configured with 2 GUAMIs (GUAMI1, GUAMI2) - SERVEDAMF-1
    ...  - AMF-2 is configured with 1 GUAMI (GUAMI3) - SERVEDAMF-2
    ...  - AMF-3 is configured with 1 GUAMI (GUAMI4) - SERVEDAMF-3
    ...  - GUAMI1, GUAMI2, GUAMI3, GUAMI4 have no backup AMF
    ...  - 3 AMFs up and running
    ...  == Flow ==
    ...  1.  Attach UE1 to AMF-1:GUAMI-1
    ...  2.  Verify that UE1 is attached to AMF-1:GUAMI-1
    ...  3.  Attach UE2 to AMF-1:GUAMI-2
    ...  4.  Verify that UE1 is attached to AMF-1:GUAMI-2
    ...  5.	 Verify that NGAP: Initial Context Setup Request is traced with TCE for UE1
    ...  6.  Verify that NGAP: Initial Context Setup Request is traced with TCE for UE2
    ...  7.	 UE1 connects PDU Session
    ...  8.	 UE2 connects PDU Session
    ...  9.	 Verify that PDU Session established successfully for both UEs
    ...  10. AMF1 sends NGAP: AMF STATUS INDICATION with UnavailableGUAMIList:
    ...      - GUAMI1,
    ...      - timerApproachForGUAMIRemoval= apply timer
    ...      - backupAMFName is not present
    ...      - GUAMI2,
    ...      - timerApproachForGUAMIRemoval= apply timer
    ...      - backupAMFName is not present
    ...  11. Verify that after NGAP:ASI reception all relevant AMF-1 objects are correctly updated:
    ...      - SERVEDAMF-1.guAMI[1].guamiStatus is set to UNAVAILABLE
    ...      - SERVEDAMF-1.guAMI[2].guamiStatus is set to UNAVAILABLE
    ...      - SERVEDAMF-1.guAMI[1].backupAMF is not set
    ...      - SERVEDAMF-1.guAMI[2].backupAMF is not set
    ...  12. Verify that alarm 7115 (fault ID 7325) is raised  for SERVEDAMF-1
    ...  13. During amfPlannedRemovalTimer timer trigger AMF-1 to send NGAP: UE TNLA Binding Release Request for UE1
    ...  14. Verify that NGAP: UE TNLA Binding Release Request is sent
    ...  15. Verify that NGAP: UE TNLA Binding Release Request is traced with TCE for UE1
    ...  16. Trigger UE1 to send NR-RRC: UL INFORMATION TRANSFER with PDU Session Modification Request.
    ...  17. Verify that gNB performs reselection to AMF-3 for UE1 (due to relativeAMFCapacity setting for AMF3).
    ...  18. Verify that NGAP messages sent to AMF-3 are traced with TCE
    ...  19. Wait until amfPlannedRemovalTimer expires
    ...  20. Trigger UE1 to send NR-RRC: UL INFORMATION TRANSFER with PDU Session Modification Request.
    ...  21. Trigger UE2 to send NR-RRC: UL INFORMATION TRANSFER with PDU Session Modification Request.
    ...  22. Verify that gNB performs reselection and sends NGAP: UPLINK NAS TRANSPORT to AMF-2 for UE2
    ...  23. Verify that gNB sends NGAP messages to AMF-2
    ...  24. Verify that NGAP messages sent to AMF-2 are traced with TCE
    ...  25. Verify that PM counters are incremented:
    ...      - M55155C00004 (AMF_RESELECTION_GNB_ATT) = 2
    ...      - M55155C00005 (AMF_RESELECTION_GNB_FAIL) = 0
    ...      - M55155C00006 (AMF_RESELECTION_GNB_SUCC) = 2
    ...  == Postcondition ==
    ...  -  NGAP link gNB-AMF1 is active
    ...  -  NGAP link gNB-AMF2 is active
    ...  -  NGAP link gNB-AMF3 is active
    ...  == TESTING TOOLS ==
    ...  AirPhone, 5GCSIM, UTE
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode
    ...  - HARDWARE ID: gNB(ABIL + ASIK) with simulated AEQA radio module - NR_BAND: n78
    ...  == REQUIREMENTS COVERAGE ==
    ...  -  USCB006999-B#
    ...  -  CB006999-B-B101
    ...  == REQUIRED LOGS ==
    ...  NGAP
    ...  == AUTHOR ==
    ...  - Gabriela Stasiuk <gabriela.stasiuk@nokia.com>
    ...  == REFERENCES ==
    ...  -  CFAM CB006999-2445
    ...  -  CFAM CB006999-2777

    [Setup]  Prepare test environment BB101-1
    Attach UE1 to AMF1:GUAMI:1 without starting traffic
    Attach UE2 to AMF1:GUAMI:2 without starting traffic
    Send ASI from AMF1 with two GUAMI:1 backupAMF:None timerApproach:on GUAMI:2 backupAMF:None timerApproach:on

    Verify SERVEDAMF-1:GUAMI_index-1 is correctly updated: backupAmfName=None, guamiStatus=unavailable
    Verify SERVEDAMF-1:GUAMI_index-2 is correctly updated: backupAmfName=None, guamiStatus=unavailable
    Verify that alarm with NG AMF Status Indication fault and fault ID=7325 is raised for AMF1

    Send UE TNLA BRR for UE1 from AMF1 with both valid UE NGAP ID
    Verify that UE TNLA BRR is traced with TCE

    Expect that UE-1 uses AMF3 after NGAP: UPLINK NAS TRANSPORT
    Expect that after PDU Session Modification Request from UE1 gNB performs AMF reselection and AMF3 is selected
    Trigger UE1 to send PDU Session Modification for PDU1
    Verify that UE-1 uses AMF3 after NGAP: UPLINK NAS TRANSPORT
    Verify that after PDU Session Modification Request from UE1 gNB performs AMF reselection and AMF3 is selected
    Verify that PDU Session Modification sent to AMF3 is traced with TCE

    Wait until amfPlannedRemovalTimer expiration

    Expect that after PDU Session Modification Request from UE1 gNB does not perform AMF reselection for AMF2
    Trigger UE1 to send PDU Session Modification for PDU1
    Verify that after PDU Session Modification Request from UE1 gNB does not perform AMF reselection for AMF2
    Expect that after PDU Session Modification Request from UE2 gNB performs AMF reselection and AMF3 is selected
    Trigger UE2 to send PDU Session Modification for PDU2
    Verify that after PDU Session Modification Request from UE2 gNB performs AMF reselection and AMF3 is selected

    Wait until PM counters file is ready and saved
    Verify PM counters for gNB initiated AMF reselection are incremented successfully: attempts:2, fails:0, successes:2
    [Teardown]  Teardown test environment BB101-1

CB006999-B-B101-2-TBR_for_GUAMI_with_timerApproachForGUAMIRemoval_after_ASI_backupAMF_used
    [Tags]    BB101-2
    [Documentation]
    ...  DESCRIPTION:
    ...  == Info ==
    ...  Test scenario describes handling UE TNLA BINDING RELEASE REQUEST message after AMF STATUS INDICATION
    ...  with CellTrace validation when NRBTS.actAmfPlannedRemoval feature flag is activated.
    ...  Also it shows that NGAP:TNLA BINDING RELEASE has higher priority over timer approach set by
    ...  NGAP: AMF STATUS INDICATION and that NGAP:TNLA BINDING RELEASE affects only indicated UE.
    ...  == Precondition ==
    ...  - Real gNB up and running
    ...  - 3 AMFs up and running
    ...  - Established NG connections AMF-gNB
    ...  - AMF-1 is configured with 2 GUAMIs (GUAMI1, GUAMI2)
    ...  - AMF-2 is configured with 1 GUAMI (GUAMI3)
    ...  - AMF-3 is configured with 1 GUAMI (GUAMI4)
    ...  - All GUAMIs have status set to AVAILABLE
    ...  - AMF-1 have backup AMF set to AMF-2 and AMF-3
    ...  - NRBTS.actNgcFlexSaMode=true (5GC000740)
    ...  - NRBTS.actAmfPlannedRemoval=true
    ...  - NRBTS.amfPlannedRemovalTimer = 50
    ...  - NRBTS.actCellTraceReport=true
    ...  - NRMTRACECU.jobType=TraceOnly
    ...  - NRMTRACECU.traceNGAPSetting=all
    ...  - Trace Collection Entity (TCE) is configured under MNL.TCEADM.TCE MOC
    ...  == Flow ==
    ...  1.	Attach UE1 to AMF-1:GUAMI-1 and run traffic on PDU 1
    ...  2.	Attach UE2 to AMF-1:GUAMI-2 and run traffic on PDU 1
    ...  3.	AMF1 sends NGAP: AMF STATUS INDICATION with UnavailableGUAMIList:
    ...     GUAMI1:
    ...         timerApproachForGUAMIRemoval = apply timer
    ...         backupAMFName is set to AMF-3
    ...     GUAMI2:
    ...         timerApproachForGUAMIRemoval is not present
    ...         backupAMFName is set to AMF-2
    ...  4.	During amfPlannedRemovalTimer timer trigger AMF-1 to send NGAP: UE TNLA Binding Release Request for UE1
    ...  5.	Trigger UE1 to send NR-RRC: UL INFORMATION TRANSFER with PDU Session Modification Request.
    ...  6.	Trigger UE2 to send NR-RRC: UL INFORMATION TRANSFER with PDU Session Modification Request.
    ...  7.	Wait until amfPlannedRemovalTimer expires
    ...  8.	Trigger UE1 to send second NR-RRC: UL INFORMATION TRANSFER with PDU Session Modification Request.
    ...  == Postcondition ==
    ...  - Alarm 7115 is raised
    ...  - All NGAP links gNB-AMF are in active state
    ...  == TESTING TOOLS ==
    ...  AirPhone, 5GCSim, UTE
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode
    ...  - HARDWARE ID: gNB(ABIL + ASIK) with simulated AEQA radio module - NR_BAND: n78
    ...  == REQUIREMENTS COVERAGE ==
    ...  == REQUIRED LOGS ==
    ...  NGAP
    ...  == AUTHOR ==
    ...  - Karolina Sroczyk <karolina.sroczyk@nokia.com>
    ...  == REFERENCES ==
    ...  CB006999-2778

    [Setup]  Prepare test environment BB101-2

    Attach UE1 to AMF1:GUAMI:1 without starting traffic
    Attach UE2 to AMF1:GUAMI:2 without starting traffic
    Send ASI from AMF1 with two GUAMI:1 backupAMF:3 timerApproach:on GUAMI:2 backupAMF:2 timerApproach:off

    Verify that alarm with NG AMF Status Indication fault and fault ID=7325 is raised for AMF1
    Verify SERVEDAMF-1:GUAMI_index-1 is correctly updated: backupAmfName=AMF3, guamiStatus=unavailable
    Verify SERVEDAMF-1:GUAMI_index-2 is correctly updated: backupAmfName=AMF2, guamiStatus=unavailable

    Send UE TNLA BRR for UE1 from AMF1 with both valid UE NGAP ID
    Verify that UE TNLA BRR is traced with TCE

    Expect that after PDU Session Modification Request from UE2 gNB performs AMF reselection and AMF2 is selected
    Trigger UE2 to send PDU Session Modification for PDU2
    Verify that after PDU Session Modification Request from UE2 gNB performs AMF reselection and AMF2 is selected

    Expect that after PDU Session Modification Request from UE1 gNB performs AMF reselection and AMF3 is selected
    Trigger UE1 to send PDU Session Modification for PDU1
    Verify that after PDU Session Modification Request from UE1 gNB performs AMF reselection and AMF3 is selected

    Wait until amfPlannedRemovalTimer expiration

    Expect that after PDU Session Modification Request from UE1 gNB does not perform AMF reselection for AMF2
    Trigger UE1 to send PDU Session Modification for PDU1
    Verify that after PDU Session Modification Request from UE1 gNB does not perform AMF reselection for AMF2

    Wait until PM counters file is ready and saved
    Verify PM counters for gNB initiated AMF reselection are incremented successfully: attempts:2, fails:0, successes:2
    [Teardown]  Teardown test environment BB101-2

CB006999-B-B101-3-TBR_for_GUAMI_without_timerApproachForGUAMIRemoval_after_ASI_backupAMF_used_but_unavailable
    [Tags]    BB101-3    SKIPRUN
    [Documentation]
    ...  DESCRIPTION:
    ...  == Info ==
    ...  - Show that sending NGAP: AMF STATUS INDICATION on all AMFs and releasing UE from it's AMF will result in
    ...  failure of AMF reselection for UE and thus UE's context will be released
    ...  - Show that NGAP:TNLA BINDING RELEASE after NGAP:ASI doesn't break functionality of the latter
    ...  == Precondition ==
    ...  - NRBTS.actNgcFlexSaMode=true (5GC000740)
    ...  - NRBTS.actAmfPlannedRemoval=true
    ...  - NRBTS.amfPlannedRemovalTimer > 0
    ...  - CellTrace configured
    ...  - Established NG connections AMF-gNB
    ...  - AMF-1 is configured with 2 GUAMIs (GUAMI1, GUAMI2)
    ...  - AMF-2 is configured with 1 GUAMI (GUAMI3)
    ...  - AMF-3 is configured with 1 GUAMI (GUAMI4)
    ...  - 3 AMFs up and running
    ...  - GUAMI1 backup is AMF-2
    ...  - GUAMI2 backup is AMF-3
    ...  - GUAMI3, GUAMI4 have no backup AMF
    ...  == Flow ==
    ...  1.	Attach UE1 to AMF1:GUAMI:1 without starting traffic
    ...  2.	Send ASI from AMF1
    ...  3.	Send UE TNLA BRR for UE1 from AMF1 with valid AMF-UE-NGAP-ID and RAN-UE-NGAP-ID
    ...  4.	Verify that UE TNLA BRR is traced with TCE
    ...  5.	Send ASI from AMF2
    ...  6. Send ASI from AMF3
    ...  7. Trigger UE1 to send ULInformationTransfer to AMF1
    ...  8. Verify UE1 is released by gNB
    ...  == Postcondition ==
    ...  - UE1 context has been released as there's no available GUAMIs
    ...  - NGAP link gNB-AMF1 active
    ...  - NGAP link gNB-AMF2 active
    ...  - NGAP link gNB-AMF3 active
    ...  == TESTING TOOLS ==
    ...  AirPhone, EPCSIM, UTE
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode
    ...  - HARDWARE ID: gNB(ABIL + ASIK) with simulated AEQA radio module - NR_BAND: n78
    ...  == REQUIREMENTS COVERAGE ==
    ...  5G_RAN_USR_RRM_6836
    ...  == REQUIRED LOGS ==
    ...  NGAP, NR-RRC
    ...  == AUTHOR ==
    ...  Marek Kieltyka <marek.kieltyka@nokia.com>
    ...  == REFERENCES ==
    ...  CB006999-2778
    ...  == HISTORY ==
    ...  [01.03.2022] CRT optimization - SKIPRUN added

    [Setup]  Prepare test environment BB101-3
    Attach UE1 to AMF1:GUAMI:1 without starting traffic
    Send ASI from AMF1 with two GUAMI:1 backupAMF:None timerApproach:off GUAMI:2 backupAMF:None timerApproach:on
    Send UE TNLA BRR for UE1 from AMF1 with both valid UE NGAP ID
    Verify that UE TNLA BRR is traced with TCE
    Send ASI from AMF2 with one GUAMI:1 backupAMF:None timerApproach:on
    Send ASI from AMF3 with one GUAMI:1 backupAMF:None timerApproach:off

    Verify that alarm with NG AMF Status Indication fault and fault ID=7325 is raised for AMF1
    Verify that alarm with NG AMF Status Indication fault and fault ID=7325 is raised for AMF2
    Verify that alarm with NG AMF Status Indication fault and fault ID=7325 is raised for AMF3

    Expect UE1 is released by gNB
    Try to send NGAP: UPLINK NAS TRANSPORT from UE1 to AMF1
    Verify UE1 is released by gNB
    [Teardown]  Teardown test environment BB101-3


CB006999-B-I002-1-TBR_ongoing_and_interacting_with_incoming_UE_Context_Modification_Request_from_new_AMF
    [Tags]    BI002-1
    [Documentation]
    ...  DESCRIPTION:
    ...  == Info ==
    ...  This test scenario shows that NGAP: UE CONTEXT MODIFICATION procedure is performed successfully using source
    ...  AMF, regardless of being sent during AMF sending NGAP: UE TNLA BINDING RELEASE REQUEST. One PCMD record
    ...  is generated after two UE CONTEXT MODIFICATION procedure.
    ...
    ...  == Precondition ==
    ...  - gNB up and running
    ...  - NRBTS.actNgcFlexSaMode=true (5GC000740)
    ...  - NRBTS.actAmfPlannedRemoval=true
    ...  - NRBTS.amfPlannedRemovalTimer=0
    ...  - NRBTS.actPCMDReport=true
    ...  - NRBTS.actCellTraceReport=true
    ...  - NRMTRACECU.jobType=TraceOnly
    ...  - NRMTRACECU.traceNGAPSetting=all
    ...  - Trace Collection Entity (TCE) is configured under MNL.TCEADM.TCE MOC
    ...  - Established NG connections AMF-gNB
    ...  - AMF-1 is configured with 2 GUAMIs (GUAMI1, GUAMI2) - SERVEDAMF-1
    ...  - AMF-2 is configured with 1 GUAMI (GUAMI3) - SERVEDAMF-2
    ...  - AMF-3 is configured with 1 GUAMI (GUAMI4) - SERVEDAMF-3
    ...  - GUAMI1, GUAMI2, GUAMI3, GUAMI4 have no backup AMF
    ...  - 3 AMFs up and running
    ...  - SERVEDAMF-2.relativeCapacity = 100
    ...  == Flow ==
    ...  1.  Attach UE2 to AMF1: GUAMI:2
    ...  2.  Attach UE1 to AMF-1:GUAMI-1
    ...  3.  UE1 connects PDU Session
    ...  4.	UE2 connects PDU Session
    ...  5.	Verify that PDU Session established successfully for both UEs
    ...  6.	Trigger AMF-1 to send NGAP: UE TNLA Binding Release Request for UE1
    ...  7.	Verify that NGAP: UE TNLA BINDING RELEASE REQUEST is sent
    ...  8.	Trigger AMF-2 to send NGAP: UE CONTEXT MODIFICATION REQUESTs for UE1 to gNB
    ...  9. Verify that gNB responds to AMF-2 with two NGAP: UE CONTEXT MODIFICATION RESPONSE
    ...  -	first with:
    ...     o	id-NewAMF-UE-NGAP-ID
    ...  -	second with:
    ...     o	NewGUAMI (GUAMI3)
    ...  10.Verify that PCMD report from gNB-CU on UE Setup Record has updated:
    ...  -	'result ' set to 'success'
    ...  -	'trigger ' set to 'other'
    ...  -	'RAN UE NGAP ID'
    ...  -	'AMF UE NGAP ID' set to newly received 'AMF UE NGAP ID'
    ...  -	'Globally Unique AMF ID' set to GUAMI3
    ...  11.Trigger UE1 to send RRC: UL INFORMATION TRANSFER (with PDU Session Modification Request)
    ...  12.Verify that gNB performs reselection to AMF-2 for UE1
    ...  13.Verify that gNB sends NGAP: PDU SESSION RESOURCE MODIFY RESPONSE to AMF2
    ...  14.Verify that gNB sends NGAP messages to AMF-2
    ...  15.Verify that PM counters are incremented:
    ...  -	M55155C00007 (AMF_RESELECTION_5GC_RCV) = 1
    ...  -	M55155C00008 (AMF_RESELECTION_5GC_REF) = 0

    ...  == Postcondition ==
    ...  -  UE1 is active
    ...  -  NGAP link gNB-AMF1 is active
    ...  -  NGAP link gNB-AMF2 is active
    ...  -  NGAP link gNB-AMF3 is active
    ...  == TESTING TOOLS ==
    ...  AirPhone, 5GCSIM, UTE
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode
    ...  - HARDWARE ID: gNB(ABIL + ASIK) with simulated AEQA radio module - NR_BAND: n78
    ...  == REQUIREMENTS COVERAGE ==
    ...  -  CB006999-B-I002 UE TNLA BINDING RELEASE REQUEST handling is ongoing and interacting with incoming procedures
    ...  -  US#1: UE TNLA BINDING RELEASE REQUEST handling is ongoing and interacting with incoming procedures
    ...  == REQUIRED LOGS ==
    ...  NGAP
    ...  == AUTHOR ==
    ...  - Gabriela Stasiuk <gabriela.stasiuk@nokia.com>
    ...  == REFERENCES ==
    ...  -  CFAM CB006999-2445
    ...  -  CFAM CB006999-2777

    [Setup]  Prepare test environment BI002-1
    Attach UE2 to AMF1:GUAMI:2 without starting traffic
    Attach UE1 to AMF1:GUAMI:1 without starting traffic

    Send UE TNLA BRR for UE1 from AMF1 with both valid UE NGAP ID

    Reset PCMD Database
    Expect that UE Context Modification was sent from AMF2 with UE1 with NewAMF
    Expect that NGAP: DOWNLINK NAS TRANSPORT is sent from AMF2 for UE1
    Expect that gNB sends NGAP: UPLINK NAS TRANSPORT to AMF2
    Expect that UE Context Modification was sent from AMF2 with UE1 with aMFPointer equal to 3 in payload

    Send NGAP: UE Context Modification Request from new AMF2 for UE1 currently using AMF1
    Verify that UE Context Modification was sent from AMF2 with UE1 with NewAMF
    Verify that NGAP: DOWNLINK NAS TRANSPORT is sent from AMF2 for UE1
    Verify that gNB sends NGAP: UPLINK NAS TRANSPORT to AMF2
    Verify that UE Context Modification was sent from AMF2 with UE1 with aMFPointer equal to 3 in payload
    Run keyword and Continue on Failure     Verify CuUeSetupTraceRecord in BI002-1

    Expect that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-1
    Expect that after PDU Session Modification Request from UE1 gNB performs AMF reselection and AMF2 is selected
    Trigger UE1 to send PDU Session Modification for PDU1
    Verify that after PDU Session Modification Request from UE1 gNB performs AMF reselection and AMF2 is selected
    Verify that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-1

    Wait until PM counters file is ready and saved
    Verify PM counters for 5GC initiated AMF reselection are incremented successfully: received:1, refused:0
    [Teardown]  Teardown test environment BI002-1
