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
...         [05.05.2022] - Migrated to APoABIO

Resource    ./resources/CB006999.robot
Resource    ./resources/CB006999-A_setups_teardowns.robot

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup  Run Keywords
...  Setup emss    node_id=1
...  AND  Create all devices aliases
...  AND  Configure CB006999 basic params via yaml    pcmd_config=${True}    inter_gnb_ho=${True}
#...  AND  Setup egate  egate_port=20000  alias=default
...  AND  ute_admin.Setup admin    bts_host=192.168.255.1    bts_port=443    use_ssl=True
...  AND  Setup NG HO on gNB
...  AND  Reach OnAir with retries   lua_cfg=${lua_cfg_file}

*** Variables ***
${lua_cfg_file}=   ${CURDIR}/config/egate_SA_2c_1gNBSim_3amf_I004-5.lua

*** Test Cases ***
CB006999-A-I004-5-ASI_received_during_NG_Handover_on_SRC_gNB_Handover_Preparation_Failure_redirect_in_5GC
    [Tags]    AI004-5
    [Documentation]
    ...  DESCRIPTION:
    ...  == Info ==
    ...  This test scenario shows that source gNB receives NGAP: AMF STATUS INDICATION and then sends NGAP: HANDOVER REQUIRED to unavailable AMF.
    ...  5GCore redirects NGAP: HANDOVER REQUIRED to new available AMF, which sends NGAP: HANDOVER PREPARATION FAILURE. UE stays on the same
    ...  source gNB but with new 5GCore reselected AMF. Next UL NG message doesn't trigger AMF gNB-reselection for UE. Test shows that
    ...  amfPlannedRemovalTimer doesn't have an impact when 5GC reselection is performed.
    ...  == Precondition ==
    ...  - Both real gNB and simulated gNB are up and running
    ...  - NRBTS.actNgcFlexSaMode=true (5GC000740)
    ...  - NRBTS.amfPlannedRemovalTimer = 30
    ...  - NRBTS.actAmfPlannedRemoval=true
    ...  - NG HO is supported between real and simulated gNB
    ...  - NRBTS.NRCELL.NRREL.handoverAllowedSA=onlyNG
    ...  - NRBTS.actIntraNrNgHo=sourceAndTarget
    ...  - Established all NG connections (3 links up for real gNB and 3 links for simulated gNB)
    ...  - AMF-1 is configured with 2 GUAMIs (GUAMI1, GUAMI2)
    ...  - AMF-2 is configured with 1 GUAMI (GUAMI3)
    ...  - AMF-3 is configured with 1 GUAMI (GUAMI1)
    ...  - 3 AMFs up and running
    ...  - AMF-1 have backup AMF set to AMF-2 and AMF-3
    ...  - AMF-2 and AMF-3 have no backup AMFs
    ...  == Flow ==
    ...  1. Attach UE1 to AMF-1 (GUAMI1) to real gNB2.
    ...  2.	Connect PDU Session with one QoS Flow (non-GBR).
    ...  3.	Modify 5GCore behaviour by using redirect_amf_index param set to AMF-3.
    ...  4.	Send ASI from AMF-1 with UnavailableGUAMIList as below:
    ...     GUAMI1:
    ...         - timerApproachForGUAMIRemoval=apply-timer
    ...         - backup AMF set to AMF-2
    ...  5.	Trigger failure NG HO from real_gNB to simulated_gNB for UE1.
    ...     - Source gNB sends NGAP: HANDOVER REQUIRED to AMF-1(unavailable)
    ...     - 5GCore redirects NGAP: HANDOVER REQUIRED to new AMF-3
    ...     - AMF-3 sends NGAP: HANDOVER PREPARATION FAILURE to source gNB
    ...  6.	Trigger UE1 to send PDU Session Modification for PDU1
    ...  7. Wait until amfPlannedRemovalTimer expiration
    ...  8. Trigger UE1 to send PDU Session Modification for PDU1
    ...  == Postcondition ==
    ...  - Alarm 7115 is raised
    ...  == TESTING TOOLS ==
    ...  AirPhone, 5GCSim, UTE
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode
    ...  - HARDWARE ID: gNB(ABIO + ASIL) with simulated AEQA radio module - NR_BAND: n78
    ...  == REQUIREMENTS COVERAGE ==
    ...  CB006999-A#US01
    ...  == REQUIRED LOGS ==
    ...  NGAP
    ...  == AUTHOR ==
    ...  - Karolina Sroczyk <karolina.sroczyk@nokia.com>
    ...  == REFERENCES ==
    ...  CB006999-2785

    [Setup]  Prepare test environment AI004-5

    Set Support Guami Unavailability to ON for AMF1

    Attach UE1 to AMF1:GUAMI:1 without starting traffic

    Setup amf_status_indication interaction sent before Handover Required

    Send ASI with redirection to other AMF3 from AMF1 with one GUAMI:1 backupAMF:2 timerApproach:on
    Verify that alarm with NG AMF Status Indication fault and fault ID=7325 is raised for AMF1
    Verify SERVEDAMF-1:GUAMI_index-1 is correctly updated: backupAmfName=AMF2, guamiStatus=unavailable

    Trigger failure NG HO from real to sim gNB with AMF1:GUAMI1 for UE1 then 5GCore redirects message to new AMF3

    Expect that after PDU Session Modification Request from UE1 gNB does not perform AMF reselection and AMF3 is selected
    Trigger UE1 to send PDU Session Modification for PDU1
    Verify that after PDU Session Modification Request from UE1 gNB does not perform AMF reselection and AMF3 is selected

    Wait until amfPlannedRemovalTimer expiration

    Wait until PM counters file is ready and saved
    Verify PM counters for gNB initiated AMF reselection are incremented successfully: attempts:0, fails:0, successes:0
    Verify PM counters for 5GC initiated AMF reselection are incremented successfully: received:1, refused:0

    [Teardown]  Teardown test environment AI004-5
