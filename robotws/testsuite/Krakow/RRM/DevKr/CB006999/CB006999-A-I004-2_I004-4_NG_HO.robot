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

Force Tags    CONFIGURED    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4    SKIPRUN
    ...    CLOUD_5G_I_KL_AP_KL_SANSA_FS_CPRI_CMWV_TDD

Suite Setup  Run Keywords
...  Setup emss    node_id=1
...  AND  Create all devices aliases
...  AND  Configure CB006999 basic params via yaml    pcmd_config=${True}    inter_gnb_ho=${True}
#...  AND  Setup egate  egate_port=20000  alias=default
...  AND  ute_admin.Setup admin    bts_host=192.168.255.1    bts_port=443    use_ssl=True
...  AND  Setup NG HO on gNB
...  AND  Reach OnAir with retries    lua_cfg=${lua_cfg_file}

*** Variables ***
${lua_cfg_file}=   ${CURDIR}/config/egate_SA_1c_1gNBSim_3amf.lua

*** Test Cases ***
CB006999-A-I004-2-ASI_received_during_NG_Handover_on_SRC_gNB_Handover_Preparation_Failure
    [Tags]    AI004-2
    [Documentation]
    ...  DESCRIPTION:
    ...  == Info ==
    ...  This test scenario shows that UE stays on source gNB, when source gNB received NGAP: AMF STATUS INDICATION
    ...  after sending NGAP: HANDOVER REQUIRED and AMF responded with NGAP: HANDOVER PREPARATION FAILURE.
    ...  After unsuccessful HO trigger, next UL NG message will trigger AMF reselection for UE1
    ...  == Precondition ==
    ...  - NRBTS.actNgcFlexSaMode=true (5GC000740)
    ...  - NRBTS.amfPlannedRemovalTimer = 30
    ...  - NRBTS.actAmfPlannedRemoval=true
    ...  - NG HO is supported between real and simulated gNB
    ...  -- NRBTS.NRCELL.NRREL.handoverAllowedSA=onlyNG
    ...  -- NRBTS.actIntraNrNgHo=sourceAndTarget
    ...  - Established all NG connections (3 links up for real gNB and 3 links for simulated gNB)
    ...  - AMF-1 is configured with 2 GUAMIs (GUAMI1, GUAMI2)
    ...  - AMF-2 is configured with 1 GUAMI (GUAMI3)
    ...  - AMF-3 is configured with 1 GUAMI (GUAMI4)
    ...  - 3 AMFs up and running
    ...  - AMF-1 have backup AMF set to AMF-2 and AMF-3
    ...  - AMF-2 and AMF-3 have no backup AMFs
    ...  == Flow ==
    ...  1.	Attach UE1 to AMF-1 (GUAMI1) to real gNB2
    ...  2.	Connect PDU Session with one QoS Flow (non-GBR)
    ...  3.	Trigger failure NG HO from real_gNB to simulated_gNB for UE1 while AMF1 sent concurrent ASI
    ...  4.	Trigger UE1 to send PDU Session Modification for PDU1 (gNB does not perform AMF reselection and AMF1 is selected)
    ...  5.	Wait until amfPlannedRemovalTimer expiration
    ...  6.	Run DL and UL 20MBps traffic on PDU 1
    ...  7.	Trigger UE1 to send PDU Session Modification for PDU1 (backup AMF2 is selected)
    ...  8.	Trigger successful NG HO from real_gNB to simulated_gNB for UE1 with backup AMF2
    ...  == Postcondition ==
    ...  - Alarm with faultID=7325 is cleared
    ...  - Traffic on UE1 is not impacted during AMFs reselection
    ...  - All NGAP links gNB-AMF are in active state
    ...  == TESTING TOOLS ==
    ...  AirPhone, EPCSIM, UTE
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode
    ...  - HARDWARE ID: gNB(ABIL + ASIK) with simulated AEQA radio module - NR_BAND: n78
    ...  == REQUIREMENTS COVERAGE ==
    ...  5G_RAN_USR_RRM_6832
    ...  == REQUIRED LOGS ==
    ...  NGAP
    ...  == AUTHOR ==
    ...  Marek Kieltyka <marek.kieltyka@nokia.com>
    ...  == REFERENCES ==
    ...  CB006999-2772
    ...  == HISTORY ==
    ...  [01.03.2022] CRT optimization - SKIPRUN added, .qc file removed

    [Setup]  Prepare test environment AI004-2
    Attach UE1 to AMF1:GUAMI:1 without starting traffic

    Trigger failure NG HO from real to sim gNB for UE1 while AMF1 sent concurrent AMFStatusIndication
    Verify that alarm with NG AMF Status Indication fault and fault ID=7325 is raised for AMF1

    Expect that after PDU Session Modification Request from UE1 gNB does not perform AMF reselection and AMF1 is selected
    Trigger UE1 to send PDU Session Modification for PDU1
    Verify that after PDU Session Modification Request from UE1 gNB does not perform AMF reselection and AMF1 is selected

    Wait until amfPlannedRemovalTimer expiration

    Run 20MBps UL and DL traffic on UE1 PDU1 QFI1 and wait 5 seconds

    Expect that after PDU Session Modification Request from UE1 gNB performs AMF reselection and AMF2 is selected
    Trigger UE1 to send PDU Session Modification for PDU1
    Verify that after PDU Session Modification Request from UE1 gNB performs AMF reselection and AMF2 is selected

    Trigger successful NG HO from real_gNB to simulated_gNB for UE1 with backup AMF2
#    TODO: Flooding logs after HO:  ERR: GNB-3: UE1: Failed to send UL data for EBI-5.

    Stop and verify 20MBps UL and DL traffic on UE1 PDU1 QFI1
    Wait until PM counters file is ready and saved
    Verify PM counters for gNB initiated AMF reselection are incremented successfully: attempts:1, fails:0, successes:1
    [Teardown]  Teardown test environment AI004-2


CB006999-A-I004-4-ASI_received_during_NG_Handover_on_SRC_gNB_Handover_Preparation_Failure
    [Tags]    AI004-4
    [Documentation]
    ...  DESCRIPTION:
    ...  == Info ==
    ...  This testcase shows gNB behavior during interaction between NGAP: AMF STATUS INDICATION sent from AMF
    ...  and NG Handover procedure started on gNB. AMF which serves UE sends NGAP: AMF STATUS INDICATION
    ...  (without timerApproachForGUAMIRemoval set) after NG Handover procedure has started (NGAP: HANDOVER REQUIRED
    ...  message has been sent). Successful handover is performed using AMF which serves UE. No AMF reselection occurs.
    ...
    ...  == Precondition ==
    ...  - Both real gNB2 and simulated gNB3 are up and running
    ...  - NRBTS.actNgcFlexSaMode=true (5GC000740)
    ...  - NRBTS.amfPlannedRemovalTimer = 0
    ...  - NRBTS.actAmfPlannedRemoval=true
    ...  - NG HO is supported between real and simulated gNB
    ...      - NRBTS.actNrNgHOSA = true (5GC000705)
    ...      - NRBTS.actIntraNrNgHo=sourceAndTarget
    ...  - Established all NG connections (3 links up for real gNB and 3 links for simulated gNB)
    ...  - AMF-1 is configured with 2 GUAMIs (GUAMI1, GUAMI2)
    ...  - AMF-2 is configured with 1 GUAMI (GUAMI3)
    ...  - AMF-3 is configured with 1 GUAMI (GUAMI4)
    ...  - 3 AMFs up and running
    ...  - AMF-1, AMF-2 and AMF-3 have no backup AMFs set
    ...
    ...  == Flow ==
    ...  1.  Attach UE1 to AMF-1 (GUAMI1) to real gNB2.
    ...  2.  Verify that UE1 is attached to AMF-1:GUAMI-1
    ...  3.  Connect PDU Session with one QoS Flow (non-GBR).
    ...  4.  Verify that PDU Session is established successfully for UE1
    ...  5.  Run UL and DL traffic on UE1
    ...  6.  Trigger NG HO from real_gNB to simulated_gNB using AMF-1 for UE1, intercepted by NGAP: AMF STATUS INDICATION:
    ...      - Real gNB sends NGAP: HANDOVER REQUIRED to AMF-1
    ...      - Send NGAP:AMF STATUS INDICATION from AMF1 with unavailableGuamiList:
    ...          - GUAMI[1]:
    ...              - timerApproachForGUAMIRemoval is not set
    ...              - backupAMFName is set to AMF-2
    ...  7.  Verify that alarm with faultID=7325 is raised on SERVEDAMF-1
    ...  8.  Verify that SERVEDAMF-1 object is updated as follows:
    ...      - GUAMI[1].guamiStatus = unavailable
    ...      - GUAMI[1].backupAmfName is set to AMF-2
    ...  9.  Verify that real gNB receives NGAP: HANDOVER COMMAND from AMF-1
    ...  10. Verify that real gNB receives NGAP: UE CONTEXT RELEASE COMMAND from AMF-1
    ...  11. Verify that real gNB sends NGAP: UE CONTEXT RELEASE COMPLETE to AMF-1
    ...  12. Stop and verify UL and DL traffic on UE1
    ...  13. Verify that PM counters are not incremented:
    ...      - M55155C00004 (AMF_RESELECTION_GNB_ATT) = 0
    ...      - M55155C00005 (AMF_RESELECTION_GNB_FAIL) = 0
    ...      - M55155C00006 (AMF_RESELECTION_GNB_SUCC) = 0
    ...
    ...  == Postcondition ==
    ...  - Alarm with faultID=7325 is cleared
    ...  - Traffic on UE1 is not impacted during NG Handover and AMF reselection
    ...  - All NGAP links gNB-AMF are in active state
    ...
    ...  == TESTING TOOLS ==
    ...  AirPhone, EPCSIM, UTE
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode
    ...  - HARDWARE ID: gNB(ABIL + ASIK) with simulated AEQA radio module - NR_BAND: n78
    ...  == REQUIREMENTS COVERAGE ==
    ...  - CB006999-A-I004
    ...  - US07
    ...  == REQUIRED LOGS ==
    ...  NGAP
    ...  == AUTHOR ==
    ...  Cezary Dudek <cezary.dudek@nokia.com>
    ...  == REFERENCES ==

    [Setup]  Prepare test environment AI004-4

    Attach UE2 to AMF1:GUAMI:1 and run traffic on PDU 2

    Run 20MBps UL and DL traffic on UE2 PDU2 QFI1 and wait 5 seconds

    Trigger successful NG HO from real_gNB to simulated_gNB for UE2 without reselection while AMF1 sent concurrent AMFStatusIndication
    Verify that alarm with NG AMF Status Indication fault and fault ID=7325 is raised for AMF1
    Verify SERVEDAMF-1:GUAMI_index-1 is correctly updated: backupAmfName=AMF2, guamiStatus=unavailable

    Stop and verify 20MBps UL and DL traffic on UE2 PDU2 QFI1

    Wait until PM counters file is ready and saved
    Verify PM counters for gNB initiated AMF reselection are incremented successfully: attempts:0, fails:0, successes:0
    Verify PM counters for 5GC initiated AMF reselection are incremented successfully: received:0, refused:0

    [Teardown]    Teardown test environment AI004-4
