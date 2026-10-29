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
...      CB006999-B UE TNLA BINDING RELEASE REQUEST handling
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

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_KL_AP_KL_SANSA_FS_CPRI_CMWV_TDD
    ...    CONFIGS_Krakow/CB006999/SA_1c_1gNBSim_3AMF.yml

Suite Setup  Run Keywords
...  Setup emss    node_id=1
...  AND  Create all devices aliases
#...  AND  Setup egate  egate_port=20000  alias=default
...  AND  ute_admin.Setup admin    bts_host=192.168.255.1    bts_port=443    use_ssl=True
...  AND  Reach OnAir with retries   lua_cfg=${lua_cfg_file}

*** Variables ***
${lua_cfg_file}=   ${CURDIR}/config/egate_SA_1c_1gNBSim_3amf_I003-2.lua

*** Test Cases ***
CB006999-A-I003-2-ASI_with_timer_running_received_before_Xn_Handover_procedure
    [Tags]    AI003-2    SKIPRUN
    [Documentation]
    ...  DESCRIPTION:
    ...  == Info ==
    ...  This test scenario shows that XNAP: Handover Request, during which AMF Status Indication is sent with timerApproachForGUAMIRemoval
    ...  and with backup AMF, result in XNAP: Handover Acknowledge. Test verify that ASI doesn't interrupt XNAP Handover procedure.
    ...  == Precondition ==
    ...  - Both real gNB and simulated gNB are up and running
    ...  - 3 AMFs up and running
    ...  - Established NG connections AMF-gNB
    ...  - AMF-1 is configured with 2 GUAMIs (GUAMI1, GUAMI2)
    ...  - AMF-2 is configured with 2 GUAMIs (GUAMI1, GUAMI2)
    ...  - AMF-3 is configured with 1 GUAMI (GUAMI4)
    ...  - AMF-1, AMF-2 and AMF-3 have SetId = 2
    ...  - All GUAMIs have status set to AVAILABLE
    ...  - AMF-1 have backup AMF set to AMF-2 and AMF-3
    ...  - NRBTS.actNgcFlexSaMode=true (5GC000740)
    ...  - NRBTS.actAmfPlannedRemoval=true
    ...  - NRBTS.amfPlannedRemovalTimer = 50
    ...  == Flow ==
    ...  1. Attach UE1 with registeredAMF set to (AMF-1, GUAMI1)
    ...  2. Perform XN HO from real gNB to sim gNB
    ...  3. Send ASI from AMF-1 with GUAMI-1 backup NOT set and timer approach set
    ...  4. Send ASI from AMF-1 with:
    ...         GUAMI-1 backup NOT set and timer approach NOT set,
    ...         GUAMI-2 backup NOT set and timer approach set,
    ...  5. Perform XN HO from sim gNB to real gNB
    ...  6. Verify that sim gNB sends XNAP: HANDOVER REQUEST to real gNB for UE1: Id-GUAMI equals - GUAMI1
    ...  7. Verify that real gNB sends XNAP: HANDOVER REQUEST ACKNOWLEDGE to sim gNB for UE1.
    ...  8. Verify that real gNB sends NGAP: PATH SWITCH REQUEST to new AMF-2 (AMF-1 and AMF-2 have the same set of GUAMIs).
    ...  9. Verify that AMF-2 sends NGAP: PATH SWITCH ACKNOWLEDGE to real gNB.
    ...  10. Wait until amfPlannedRemovalTimer expiration
    ...  11. Trigger UE1 to send NR-RRC: UL INFORMATION TRANSFER with PDU Session Modification Request.
    ...  == Postcondition ==
    ...  - Alarm 7115 is raised
    ...  == TESTING TOOLS ==
    ...  AirPhone, 5GCSim, UTE
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode
    ...  - HARDWARE ID: gNB(ABIL + ASIK) with simulated AEQA radio module - NR_BAND: n78
    ...  == REQUIREMENTS COVERAGE ==
    ...  CB006999-A#US01
    ...  == REQUIRED LOGS ==
    ...  NGAP
    ...  == AUTHOR ==
    ...  - Karolina Sroczyk <karolina.sroczyk@nokia.com>
    ...  == REFERENCES ==
    ...  CB006999-2784

    [Setup]  Prepare test environment AI003-2

    Set Support Guami Unavailability to ON for AMF1
    Locate UE1 at real_gNB

    Expect that UE-1 is attached to AMF1
    Attach UE-1 to AMF1:GUAMI:1
    Connect UE-1 PDU session 1 with QOS flow
    Verify that UE-1 is attached to AMF1

    Expect that handover from real_gNB to sim_gNB with AMF1:GUAMI1 for UE1 ends with HandoverRequestAcknowledge
    Trigger XN HO from real_gNB to sim_gNB with AMF1:GUAMI1 for UE1
    Verify that real_gNB sends XNAP: Handover Request to simulated_gNB for UE1
    Verify that simulated_gNB sends XNAP: Handover Request Acknowledge to real_gNB for UE1

    Set up HO for UE1

    Send ASI from AMF1 with one GUAMI:1 backupAMF:None timerApproach:on
    Verify SERVEDAMF-1:GUAMI_index-1 is correctly updated: backupAmfName=None, guamiStatus=unavailable
    Verify SERVEDAMF-1:GUAMI_index-2 is correctly updated: backupAmfName=None, guamiStatus=available
    Verify that alarm with NG AMF Status Indication fault and fault ID=7325 is raised for AMF1

    Send ASI from AMF1 with two GUAMI:1 backupAMF:3 timerApproach:off GUAMI:2 backupAMF:None timerApproach:on
    Verify SERVEDAMF-1:GUAMI_index-1 is correctly updated: backupAmfName=None, guamiStatus=unavailable
    Verify SERVEDAMF-1:GUAMI_index-2 is correctly updated: backupAmfName=None, guamiStatus=unavailable

    Expect that handover from sim_gNB to real_gNB with AMF1:GUAMI1 for UE1 ends with HandoverRequestAcknowledge
    Expect that NGAP_PathSwitchRequest is sent to AMF2 for UE1
    Trigger XN HO from sim_gNB to real_gNB with AMF1:GUAMI1 for UE1
    Verify that simulated_gNB sends XNAP: Handover Request to real_gNB for UE1
    Verify that simulated_gNB sends XNAP: Handover Request Acknowledge to real_gNB for UE1
    Verify that NGAP_PathSwitchRequest is sent to AMF2 for UE1

    Wait until amfPlannedRemovalTimer expiration

    Expect that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-1
    Expect that after PDU Session Modification Request from UE1 gNB performs AMF reselection and AMF2 is selected
    Trigger UE1 to send PDU Session Modification for PDU1
    Verify that after PDU Session Modification Request from UE1 gNB performs AMF reselection and AMF2 is selected
    Verify that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-1

    Wait until PM counters file is ready and saved
    Verify PM counters for AMF selection are incremented successfully: attempts:2, fails:0, successes:2
    Verify PM counters for gNB initiated AMF reselection are incremented successfully: attempts:0, fails:0, successes:0
    Verify PM counters for 5GC initiated AMF reselection are incremented successfully: received:0, refused:0

    [Teardown]  Teardown test environment AI003-2
