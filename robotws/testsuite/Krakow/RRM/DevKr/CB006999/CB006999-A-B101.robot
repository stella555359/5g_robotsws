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
${lua_cfg_file}=               ${CURDIR}/config/egate_SA_2c_3amf_APoABIO.lua

*** Test Cases ***
CB006999-A-B101-1-Handling_ASI_when_feature_is_not_activated
    [Tags]    AB101-1
    [Documentation]
    ...  DESCRIPTION:
    ...  == Info ==
    ...  This test scenario describes the gNB behavior when feature flag NRBTS.actAmfPlannedRemoval
    ...  is deactivated and AMF receives NGAP: ERROR INDICATION.
    ...  == Precondition ==
    ...  - Both simulated and real gNB up and running
    ...  - 3 AMFs up and running
    ...  - Established NG connections AMF-gNB
    ...  - AMF-1 is configured with 2 GUAMIs (GUAMI1, GUAMI2)
    ...  - AMF-2 is configured with 2 GUAMIs (GUAMI3, GUAMI4)
    ...  - AMF-3 is configured with 2 GUAMIs (GUAMI1, GUAMI2)
    ...  - All GUAMIs have status set to AVAILABLE
    ...  - None of GUAMIs have backup AMF set
    ...  - NRBTS.actNgcFlexSaMode=true (5GC000740)
    ...  - NRBTS.actAmfPlannedRemoval=false
    ...  == Flow ==
    ...  1. Attach UE1 to (AMF-1, GUAMI1)
    ...  2. Connect UE1 PDU Session with two QOS Flows
    ...  3. Run UL and DL traffic on UE1
    ...  4. Send ASI from AMF-1 with all GUAMIs without backup and without timer approach
    ...  5. Attach UE2 to (AMF-1, GUAMI1)
    ...  6. Set NRBTS.actAmfPlannedRemoval=true
    ...  7. Send ASI from AMF-1 with all GUAMIs without backup and without timer approach
    ...  == Postcondition ==
    ...  - Alarm 7115 is raised
    ...  - UE2 is in RRC_CONNECTED state
    ...  - NRBTS.actAmfPlannedRemoval=true
    ...  == TESTING TOOLS ==
    ...  AirPhone, 5GCSim, UTE
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode
    ...  - HARDWARE ID: gNB(ABIO + ASIL) with simulated AEQE radio module - NR_BAND: n78
    ...  == REQUIREMENTS COVERAGE ==
    ...  USCB006999-A#O1
    ...  == REQUIRED LOGS ==
    ...  NGAP
    ...  == AUTHOR ==
    ...  - Marek Kieltyka <marek.kieltyka@nokia.com>
    ...  == REFERENCES ==
    ...  CB006999-2426

    [Setup]  Prepare test environment AB101-1

    Attach UE1 to AMF1:GUAMI:1 and run traffic on PDU 1

    Expect NGAP: ERROR INDICATION sent after ASI with cause=${cause_notCompatible}
    Send ASI from AMF1 with two GUAMI:1 backupAMF:None timerApproach:off GUAMI:2 backupAMF:None timerApproach:off
    Verify gNB sends NGAP: ERROR INDICATION after ASI
    Verify that alarm with NG AMF Status Indication fault and fault ID=7325 is raised for AMF1
    Wait until alarm with fault ID=7325 disappears

    Expect UE2 is not released
    Restore AMF1 GUAMIs
    Attach UE-2 to AMF1:GUAMI:1

    Set Planned AMF Removal feature flag to ${true}

    Expect gNB does not send NGAP: ERROR INDICATION after Planned AMF Removal feature enabling
    Send ASI from AMF1 with two GUAMI:1 backupAMF:None timerApproach:off GUAMI:2 backupAMF:None timerApproach:off
    Verify gNB does not send NGAP: ERROR INDICATION after Planned AMF Removal feature enabling
    Verify that alarm with NG AMF Status Indication fault and fault ID=7325 is raised for AMF1

    Verify UE2 is not released

    Stop and verify 20MBps UL and DL traffic on UE1 PDU1 QFI1
    Wait until PM counters file is ready and saved
    Verify PM counters for ErrorIndication are incremented successfully: count: 1
    [Teardown]  Teardown test environment AB101-1
