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
    ...    CLOUD_5G_I_KL_AP_KL_SANSA_FS_CPRI_CMWV_TDD
    ...    CONFIGS_Krakow/CB006999/SA_1c_1gNBSim_3AMF_multiple_PLMN.yml

Suite Setup  Run Keywords
...  Setup emss    node_id=1
...  AND  Create all devices aliases
#...  AND  Setup egate  egate_port=20000  alias=default
...  AND  ute_admin.Setup admin    bts_host=192.168.255.1    bts_port=443    use_ssl=True
...  AND  Reach OnAir with retries    lua_cfg=${lua_cfg_file}

*** Variables ***
${lua_cfg_file}=   ${CURDIR}/config/egate_SA_1c_1gNBSim_3amf_multiple_PLMN.lua

*** Test Cases ***
CB006999-A-AMF_Status_Indication_sent_with_backup_AMF_while_multiple_plmn_configured
    [Tags]    multiple_plmn    SKIPRUN
    [Documentation]
    ...  DESCRIPTION:
    ...  == Info ==
    ...  This test scenario shows that backup AMF2 is chosen instead of having different PLMN then home AMF1.
    ...  Show that UE's traffic is unimpacted for the duration of timer running after NGAP:ASI with timer approach
    ...  and without backup AMF is sent.
    ...  == Precondition ==
    ...  - Real gNB up and running
    ...  - 3 AMFs up and running
    ...  - Established NG connections AMF-gNB
    ...  - POINTER-1 - PLMN=311:489,311:402
    ...  - POINTER-3 - PLMN=311:489
    ...  - AMF-1 is configured with 2 GUAMIs (GUAMI1, GUAMI2), POINTER-1
    ...  - AMF-2 is configured with 1 GUAMI (GUAMI3), POINTER-3
    ...  - AMF-3 is configured with 2 GUAMIs (GUAMI1, GUAMI2), POINTER-1
    ...  - All GUAMIs have status set to AVAILABLE
    ...  - AMF-1 have NO backup AMF set
    ...  - NRBTS.actNgcFlexSaMode=true (5GC000740)
    ...  - NRBTS.actAmfPlannedRemoval=true
    ...  - NRBTS.amfPlannedRemovalTimer = 0
    ...  == Flow ==
    ...  1. Attach UE1 to gNB (AMF1, GUAMI1(PLMN1))
    ...  2. Connect PDU Session with one QoS Flow (non-GBR) for UE1
    ...  3. Run UL and DL traffic on UE1
    ...  4. Send NGAP: AMF STATUS INDICATION from AMF1:
    ...     UnavailableGUAMIList as below:
    ...         > GUAMI1
    ...             > timerApproachForGUAMIRemoval is not present
    ...             > backupAMFName is set to AMF2
    ...         > GUAMI2
    ...             > timerApproachForGUAMIRemoval is not present
    ...             > backupAMFName is set to AMF3
    ...  5. UE1 starts using AMF2, GUAMI1(PLMN2)
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

    [Setup]  Prepare test environment A-multiple_plmn

    Attach UE1 to AMF1:GUAMI:1 and run traffic on PDU 1

    Send ASI from AMF1 with two GUAMI:1 backupAMF:2 timerApproach:off GUAMI:2 backupAMF:3 timerApproach:off
    Verify that alarm with NG AMF Status Indication fault and fault ID=7325 is raised for AMF1
    Verify SERVEDAMF-1:GUAMI_index-1 is correctly updated: backupAmfName=AMF2, guamiStatus=unavailable
    Verify SERVEDAMF-1:GUAMI_index-2 is correctly updated: backupAmfName=AMF3, guamiStatus=unavailable

    Expect that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-1
    Expect that after PDU Session Modification Request from UE1 gNB performs AMF reselection and AMF2 is selected
    Trigger UE1 to send PDU Session Modification for PDU1
    Verify that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-1
    Verify that after PDU Session Modification Request from UE1 gNB performs AMF reselection and AMF2 is selected

    Stop and verify 20MBps UL and DL traffic on UE1 PDU1 QFI1

    [Teardown]  Teardown test environment A-multiple_plmn
