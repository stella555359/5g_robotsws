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

Force Tags    CONFIGURED    PY36    RAN_5G    RAN_5G_TDD    SKIPRUN
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup  Run Keywords
...  Setup emss    node_id=1
...  AND  Create all devices aliases
...  AND  Configure CB006999 basic params via yaml
#...  AND  Setup egate  egate_port=20000  alias=default
...  AND  ute_admin.Setup admin    bts_host=192.168.255.1    bts_port=443    use_ssl=True
...  AND  Reach OnAir with retries    lua_cfg=${lua_cfg_file}

*** Variables ***
${lua_cfg_file}=   ${CURDIR}/config/egate_SA_1c_3amf.lua

*** Test Cases ***
CB006999-A-B001-1-guamiStatus_updates_with_ASI_and_ACU
    [Tags]    AB001-1
    [Documentation]
    ...  DESCRIPTION:
    ...  == Info ==
    ...  This test scenario describes the working on CB006999 NIDD related parameters.
    ...  Check for FAF: actamfplannedremoval; amfplannedremovaltimer;
    ...  New parameter inside SERVEDAMF MOC: guamiStatus
    ...  New BTSFault: 7325:EFaultId_NgamfStatusIndicationAl
    ...  == Precondition ==
    ...  - 3 AMFs up and running
    ...  - Established NG connections AMF-gNB
    ...  - AMF-1 is configured with 2 GUAMIs (GUAMI1, GUAMI2)
    ...  - AMF-2 is configured with 1 GUAMI (GUAMI3)
    ...  - AMF-3 is configured with 1 GUAMI (GUAMI4)
    ...  - All GUAMIs have status set to AVAILABLE
    ...  - None of GUAMIs have backup AMF set
    ...  - NRBTS.actNgcFlexSaMode=true (5GC000740)
    ...  - NRBTS.actAmfPlannedRemoval=true
    ...  - NRBTS.amfPlannedRemovalTimer=0
    ...  == Flow ==
    ...  1. Send ASI from AMF1 with one GUAMI:1 backupAMF:2 timerApproach:on
    ...  2. Send ASI from AMF1 with two GUAMI:1 backupAMF:2 timerApproach:on GUAMI:2 backupAMF:2 timerApproach:on
    ...  3. Disable CB006999 FAF (actAmfPlannedRemoval)
    ...  4. Send AMF Configuration Update from AMF1 with GUAMI2 and GUAMI3 on ServedGUAMIList
    ...  == Postcondition ==
    ...  - backupAMF and GUAMI are correctly updated on AMF1
    ...  - Alarm 7115 is raised and cleared
    ...  == TESTING TOOLS ==
    ...  AirPhone, 5GCSim, UTE
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode
    ...  - HARDWARE ID: gNB(ASIB + ABIO)
    ...  == REQUIREMENTS COVERAGE ==
    ...  USCB006999-A#O1
    ...  CB006999-A-B001 AMF Status Indication NIDD parameters support
    ...  == REQUIRED LOGS ==
    ...  NGAP
    ...  == AUTHOR ==
    ...  - Konrad Krzyzak  <konrad.krzyzak@nokia.com>
    ...  == REFERENCES ==
    ...  CFAM_CB006999
    ...  == HISTORY ==
    ...  [23.09.2021] - Created TC description and flow
    ...  [01.03.2022] - Test optimized in CRT-scope in CB006999-A-B901-1

    [Setup]  Prepare test environment AB001-1

    Send ASI from AMF1 with one GUAMI:1 backupAMF:2 timerApproach:on
    Verify SERVEDAMF-1:GUAMI_index-1 is correctly updated: backupAmfName=AMF2, guamiStatus=unavailable
    Verify SERVEDAMF-1:GUAMI_index-2:guamiStatus is set to available
    Verify that alarm with NG AMF Status Indication fault and fault ID=7325 is raised for AMF1
    Wait until alarm with fault ID=7325 disappears

    Send ASI from AMF1 with two GUAMI:1 backupAMF:2 timerApproach:on GUAMI:2 backupAMF:2 timerApproach:on
    Verify SERVEDAMF-1:GUAMI_index-2 is correctly updated: backupAmfName=AMF2, guamiStatus=unavailable
    Verify that alarm with NG AMF Status Indication fault and fault ID=7325 is raised for AMF1
    Wait until alarm with fault ID=7325 disappears

    Set Planned AMF Removal feature flag to ${false}
    Send AMF Configuration Update from AMF1 with GUAMI2 and GUAMI3 on ServedGUAMIList
    Verify SERVEDAMF-1:GUAMI_index-1 is correctly updated: backupAmfName=None, guamiStatus=available
    Verify SERVEDAMF-1:GUAMI_index-2 is correctly updated: backupAmfName=None, guamiStatus=available
    Verify SERVEDAMF-1:GUAMI_index-2 points to GUAMI3

    [Teardown]  Teardown test environment AB001-1

CB006999-A-B001-2-guamiStatus_updates_online_change_for_amfplannedremovaltimer
    [Tags]    AB001-2
    [Documentation]
    ...  DESCRIPTION:
    ...  == Info ==
    ...  This test scenario describes the working on CB006999 NIDD related parameters.
    ...  Check for FAF: actamfplannedremoval; amfplannedremovaltimer;
    ...  New parameter inside SERVEDAMF MOC: guamiStatus
    ...  New BTSFault: 7325:EFaultId_NgamfStatusIndicationAl
    ...  == Precondition ==
    ...  - 3 AMFs up and running
    ...  - Established NG connections AMF-gNB
    ...  - AMF-1 is configured with 2 GUAMIs (GUAMI1, GUAMI2)
    ...  - AMF-2 is configured with 1 GUAMI (GUAMI3)
    ...  - AMF-3 is configured with 1 GUAMI (GUAMI4)
    ...  - All GUAMIs have status set to AVAILABLE
    ...  - None of GUAMIs have backup AMF set
    ...  - NRBTS.actNgcFlexSaMode=true (5GC000740)
    ...  - NRBTS.actAmfPlannedRemoval=true
    ...  - NRBTS.amfPlannedRemovalTimer=0
    ...  == Flow ==
    ...  1. Attach UE1 to (AMF-1, GUAMI1)
    ...  2. Connect UE1 PDU Session with two QOS Flows
    ...  3. Run UL and DL traffic on UE1
    ...  4. Send ASI from AMF1 with two GUAMI:1 backupAMF:2 timerApproach:on GUAMI:2 backupAMF:2 timerApproach:on
    ...  5. Trigger UE1 to send PDU Session Modification for PDU1 (verify that AMF2 is reselected)
    ...  6. Restore AMF1 GUAMIs (guamiStatus=available)
    ...  7. Set NRBTS.amfPlannedRemovalTimer=80 (seconds)
    ...  8. Attach UE2 to (AMF-1, GUAMI1)
    ...  9. Connect UE2 PDU Session with two QOS Flows
    ...  10. Run UL and DL traffic on UE2
    ...  11. Trigger UE2 to send PDU Session Modification for PDU2 (verify that AMF1 is still selected due to amfPlannedRemovalTimer running)
    ...  12. Wait until amfPlannedRemovalTimer expiration
    ...  13. Trigger UE2 to send PDU Session Modification for PDU2(verify that AMF2 is reselected due to amfPlannedRemovalTimer expiration)
    ...  == Postcondition ==
    ...  - Alarm 7115 is raised and cleared
    ...  - UE1 and UE2 in ACTIVE state
    ...  == TESTING TOOLS ==
    ...  AirPhone, 5GCSim, UTE
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode
    ...  - HARDWARE ID: gNB(ASIB + ABIO)
    ...  == REQUIREMENTS COVERAGE ==
    ...  USCB006999-A#O1
    ...  CB006999-A-B001 AMF Status Indication NIDD parameters support
    ...  == REQUIRED LOGS ==
    ...  NGAP
    ...  == AUTHOR ==
    ...  - Konrad Krzyzak  <konrad.krzyzak@nokia.com>
    ...  == REFERENCES ==
    ...  CFAM_CB006999
    ...  == HISTORY ==
    ...  [23.09.2021] - Created TC description and flow
    ...  [01.03.2022] - Test optimized in CRT-scope in CB006999-A-B901-1

    [Setup]  Prepare test environment AB001-2

    Attach UE1 to AMF1:GUAMI:1 and run traffic on PDU 1
    Send ASI from AMF1 with two GUAMI:1 backupAMF:2 timerApproach:on GUAMI:2 backupAMF:2 timerApproach:on
    Verify SERVEDAMF-1:GUAMI_index-1 is correctly updated: backupAmfName=AMF2, guamiStatus=unavailable
    Verify SERVEDAMF-1:GUAMI_index-2 is correctly updated: backupAmfName=AMF2, guamiStatus=unavailable

    Expect that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-1
    Expect that after PDU Session Modification Request from UE1 gNB performs AMF reselection and AMF2 is selected
    Trigger UE1 to send PDU Session Modification for PDU1
    Verify that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-1
    Verify that after PDU Session Modification Request from UE1 gNB performs AMF reselection and AMF2 is selected

    Restore AMF1 GUAMIs

    Set Planned AMF Removal Timer to 80 seconds in gNB
    Verify that amfPlannedRemovaltimer is set to 80

    Attach UE2 to AMF1:GUAMI:2 and run traffic on PDU 2
    Send ASI from AMF1 with two GUAMI:1 backupAMF:2 timerApproach:on GUAMI:2 backupAMF:2 timerApproach:on
    Verify SERVEDAMF-1:GUAMI_index-1 is correctly updated: backupAmfName=AMF2, guamiStatus=unavailable
    Verify SERVEDAMF-1:GUAMI_index-2 is correctly updated: backupAmfName=AMF2, guamiStatus=unavailable

    Expect that gNB sends NGAP: UPLINK NAS TRANSPORT to AMF1
    Expect that AMF1 sends PDU Session Resource Modify Request
    Trigger UE2 to send PDU Session Modification for PDU2
    Verify that gNB sends NGAP: UPLINK NAS TRANSPORT to AMF1
    Verify that AMF1 sends PDU Session Resource Modify Request

    Wait until amfPlannedRemovalTimer expiration

    Expect that gNB sends NGAP: UPLINK NAS TRANSPORT to AMF2
    Expect that AMF2 sends PDU Session Resource Modify Request
    Trigger UE2 to send PDU Session Modification for PDU2
    Verify that gNB sends NGAP: UPLINK NAS TRANSPORT to AMF2
    Verify that AMF2 sends PDU Session Resource Modify Request

    [Teardown]  Teardown test environment AB001-2
