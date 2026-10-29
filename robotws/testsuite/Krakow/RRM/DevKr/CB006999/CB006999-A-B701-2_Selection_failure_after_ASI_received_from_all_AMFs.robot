*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == INTRODUCTION ==
...      This feature introduces gNB support for planned AMF removal (maintenance, SW upgrades).
...      Upon receipt of the AMF STATUS INDICATION message over NG interface,
...      the gNB considers GUAMI(s), will be unavailable and performs AMF reselection as follows:
...      - gNB marks this source AMF as unavailable and does not consider this AMF for selection for subsequent N2 transactions
...      - if the source AMF included the Timer Approach indicator, the gNB starts a timer to control the release of NGAP UE-TNLA-binding
...      == TEST SET NAME ==
...      CB006999-A AMF STATUS INDICATION Handling
...      == TESTING SPLIT ==
...      CB006999-A AMF STATUS INDICATION Handling
...      CB006999-B	UE TNLA BINDING RELEASE REQUEST handling
...      == AUTHORS ==
...      - Cezary Dudek <cezary.dudek@nokia.com>
...      - Marek Kieltyka <marek.kieltyka@nokia.com>
...      - Konrad Krzyzak <konrad.krzyzak@nokia.com>
...      - Karolina Sroczyk <karolina.sroczyk@nokia.com>
...      - Gabriela Stasiuk <gabriela.stasiuk@nokia.com>
...      - Grzegorz Szymik <grzegorz.szymik@nokia.com>
...      - Agnieszka Wlodarczyk <agnieszka.wlodarczyk@nokia.com>
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
...         [02.09.2021] - Created TC

Resource    ./resources/CB006999.robot
Resource    ./resources/CB006999-A_setups_teardowns.robot

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup  Run Keywords
...  Setup emss    node_id=1
...  AND  Create all devices aliases
...  AND  Configure CB006999 basic params via yaml
#...  AND  Setup egate  egate_port=20000  alias=default
...  AND  ute_admin.Setup admin    bts_host=192.168.255.1    bts_port=443    use_ssl=True
...  AND  Reach OnAir with retries    lua_cfg=${lua_cfg_file}

*** Variables ***
${lua_cfg_file}=   ${CURDIR}/config/egate_SA_2c_1gNBSim_3amf_backup_for_AMF3.lua

*** Test Cases ***
CB006999-A-B701-2-Selection_failure_after_ASI_received_from_all_AMFs_with_partial_timer_approach_and_without_backupAMF
    [Tags]    AB701-2
    [Documentation]
    ...  DESCRIPTION:
    ...  == Info ==
    ...  This test scenario describes the AMF unsuccessful selection for UE after NGAP:ASI without timer approach
    ...  and without backup AMF is sent from all AMFs and for all GUAMIs. UE can't exit IDLE mode as all GUAMIs
    ...  in each AMF are set as UNAVAILABLE.
    ...  == Precondition ==
    ...  - gNB up and running
    ...  - NRBTS.actNgcFlexSaMode=true (5GC000740)
    ...  - NRBTS.actAmfPlannedRemoval=true
    ...  - NRBTS.amfPlannedRemovalTimer=0
    ...  - Established NG connections AMF-gNB
    ...  - AMF-1 is configured with 2 GUAMIs (GUAMI1, GUAMI2) - SERVEDAMF-1
    ...  - AMF-2 is configured with 1 GUAMI (GUAMI3) - SERVEDAMF-2
    ...  - AMF-3 is configured with 1 GUAMI (GUAMI4) - SERVEDAMF-3
    ...  - GUAMI1, GUAMI2, GUAMI3 have no backup
    ...  - GUAMI4 has backup AMF set to AMF-1
    ...  - 3 AMFs up and running
    ...  - SERVEDAMF-1.relativeAMFCapacity=0
    ...  - NRBTS.drbInactivityTimerSA=60
    ...  - NRBTS.srbInactivityTimerSA=60
    ...  == Flow ==
    ...  1.	Attach UE1 to AMF-3:GUAMI-1
    ...  2.	Attach UE2 to AMF-3:GUAMI-1
    ...  3.	Verify that UE1 is connected to AMF3
    ...  4.	Verify that UE2 is connected to AMF3
    ...  5.	UE1 connects PDU Session
    ...  6.	UE2 connects PDU Session
    ...  7.	Verify that PDU Session established successfully for both UEs
    ...  8.	Run UL and DL traffic on UE2
    ...  9.	Wait until UE1 goes to IDLE state
    ...  10. AMF3 sends NGAP: AMF STATUS INDICATION with UnavailableGUAMIList:
    ...  -	GUAMI1,
    ...  -	timerApproachForGUAMIRemoval is not present
    ...  -	backupAMFName is present (EMPTY STRING)
    ...  11. Verify SERVEDAMF-3 object is correctly updated:
    ...  -	SERVEDAMF-3.guAMI[1].guamiStatus is set to UNAVAILABLE
    ...  -	SERVEDAMF-3.guAMI[1].backupAMF is not updated
    ...  12. Verify that alarm 7115 (fault ID 7325) is raised  for SERVEDAMF-3
    ...  13. Verify that gNB stops sending NGAP messages to SERVEDAMF-3
    ...  14. AMF2 sends NGAP: AMF STATUS INDICATION with UnavailableGUAMIList:
    ...  -	GUAMI1,
    ...  -	timerApproachForGUAMIRemoval is not present
    ...  -	backupAMFName is present (EMPTY STRING)
    ...  15. Verify SERVEDAMF-2 object is correctly updated:
    ...  -	SERVEDAMF-2.guAMI[1].guamiStatus is set to UNAVAILABLE
    ...  -	SERVEDAMF-2.guAMI[1].backupAMF is not updated
    ...  16. Verify that alarm 7115 (fault ID 7325) is raised  for SERVEDAMF-2
    ...  17. AMF1 sends NGAP: AMF STATUS INDICATION with UnavailableGUAMIList:
    ...  -	GUAMI2,
    ...  -	timerApproachForGUAMIRemoval is not present
    ...  -	backupAMFName is present (EMPTY STRING)
    ...  18. Verify SERVEDAMF-1 object is correctly updated:
    ...  -	SERVEDAMF-1.guAMI[2].guamiStatus is set to UNAVAILABLE
    ...  -	SERVEDAMF-1.guAMI[2].backupAMF is not updated
    ...  19. Trigger UE2 to send NR-RRC: UL INFORMATION TRANSFER with PDU Session Modification Request.
    ...  20. Verify that gNB performs reselection to AMF-1 (GUAMI-1) for UE2
    ...  21. Verify that gNB sends NGAP: UPLINK NAS TRANSPORT to AMF-1
    ...  22. AMF1 sends NGAP: AMF STATUS INDICATION with UnavailableGUAMIList:
    ...  -	GUAMI1,
    ...  -	timerApproachForGUAMIRemoval is not present
    ...  -	backupAMFName is present (EMPTY STRING)
    ...  23. Verify SERVEDAMF-1 object is correctly updated:
    ...  -	SERVEDAMF-1.guAMI[1].guamiStatus is set to UNAVAILABLE
    ...  -	SERVEDAMF-1.guAMI[1].backupAMF is not updated
    ...  24. Verify that alarm 7115 (fault ID 7325) is raised  for SERVEDAMF-1
    ...  25. Trigger UE1 to exit IDLE mode.
    ...  26. Verify that UE1 reattach is unsuccessful due to all AMFs GUAMIs are unavailable
    ...  27. Verify that PM counters are incremented:
    ...  -	M55155C00004 (AMF_RESELECTION_GNB_ATT) = 1
    ...  -	M55155C00005 (AMF_RESELECTION_GNB_FAIL) = 0
    ...  -	M55155C00006 (AMF_RESELECTION_GNB_SUCC) = 1
    ...  -	M55155C00001 (AMF_SELECTION_ATT) = 3
    ...  -	M55155C00002 (AMF_SELECTION_FAIL) = 1
    ...  -	M55155C00003 (AMF_SELECTION_SUCC) = 2
    ...  == Postcondition ==
    ...  UE1 is detached
    ...  AMFs are back in operable state
    ...  == TESTING TOOLS ==
    ...  AirPhone, EPCSIM, UTE
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode
    ...  - HARDWARE ID: gNB(ABIL + ASIK) with simulated AEQA radio module - NR_BAND: n78
    ...  == REQUIREMENTS COVERAGE ==
    ...  CB006999-A-B701 AMF Status Indication send from last active AMF
    ...  CB006999-A-B203 AMF Selection and Reselection after AMF Status Indication without timer and without 'backup AMF'
    ...
    ...  == REQUIRED LOGS ==
    ...  NGAP
    ...  == AUTHOR ==
    ...  - Gabriela Stasiuk <gabriela.stasiuk@nokia.com>
    ...  == REFERENCES ==
    ...  CFAM_CB006999

    [Setup]  Prepare test environment AB701-2

    Attach UE1 to AMF3:GUAMI:1 without starting traffic
    Attach UE2 to AMF3:GUAMI:1 and run traffic on PDU 2

    Expect that UEContextRelease procedure is made with AMF3 for UE1
    Verify that UEContextRelease procedure is made with AMF3 for UE1

    Expect that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-3

    Send ASI from AMF3 with one GUAMI:1 backupAMF:None timerApproach:off
    Verify that alarm with NG AMF Status Indication fault and fault ID=7325 is raised for AMF3
    Verify SERVEDAMF-3:GUAMI_index-1 is correctly updated: backupAmfName=None, guamiStatus=unavailable
    Verify that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-3

    Send ASI from AMF2 with one GUAMI:1 backupAMF:None timerApproach:off
    Verify that alarm with NG AMF Status Indication fault and fault ID=7325 is raised for AMF2
    Verify SERVEDAMF-2:GUAMI_index-1 is correctly updated: backupAmfName=None, guamiStatus=unavailable

    Send ASI from AMF1 with one GUAMI:2 backupAMF:None timerApproach:off
    Verify SERVEDAMF-1:GUAMI_index-2 is correctly updated: backupAmfName=None, guamiStatus=unavailable
    Verify SERVEDAMF-1:GUAMI_index-1:guamiStatus is set to available

    Expect that after PDU Session Modification Request from UE2 gNB performs AMF reselection and AMF1 is selected

    Expect that after PDU Session Modification Request from UE2 gNB performs AMF reselection - AMF1 with GUAMI1 is selected
    Expect that UE-2 uses AMF1 after NGAP: UPLINK NAS TRANSPORT
    Trigger UE2 to send PDU Session Modification for PDU2
    Verify that after PDU Session Modification Request from UE2 gNB performs AMF reselection - AMF1 with GUAMI1 is selected
    Verify that UE-2 uses AMF1 after NGAP: UPLINK NAS TRANSPORT

    Send ASI from AMF1 with one GUAMI:1 backupAMF:None timerApproach:off
    Verify that alarm with NG AMF Status Indication fault and fault ID=7325 is raised for AMF1
    Verify SERVEDAMF-1:GUAMI_index-1 is correctly updated: backupAmfName=None, guamiStatus=unavailable

    Expect that UE1 is released by gNB
    Trigger UE1 IDLE mode exit
    Verify that UE1 is released by gNB

    Wait until PM counters file is ready and saved
    Verify PM counters for AMF selection are incremented successfully: attempts:3, fails:1, successes:2
    Verify PM counters for gNB initiated AMF reselection are incremented successfully: attempts:1, fails:0, successes:1

    [Teardown]  Teardown test environment AB701-2
