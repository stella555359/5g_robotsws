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
${lua_cfg_file}=   ${CURDIR}/config/egate_SA_2c_3amf_APoABIO.lua

*** Test Cases ***
CB006999-A-B901-1-ACU_received_after_ASI_for_the_same_AMF_before_timer_expiry
    [Tags]    AB901-1
    [Documentation]
    ...  DESCRIPTION:
    ...  == Info ==
    ...  This testcase shows that:
    ...  - UE cannot be attached to AMF that sent NGAP: ASI with all unavailable GUAMIs so attach is redirected then to other available AMFs
    ...  - UE is connected to AMF that sent NGAP: ASI, but then NGAP: AMF CONFIGURATION UPDATE is sent so UE is not a candidate for reselection,
    ...  irrespective of timer approach or backupAMF being set in NGAP: ASI
    ...  - GUAMIs indicated in NGAP: AMF CONFIGURATION UPDATE have status set to AVAILABLE
    ...  - new UE can be attached to AMF which sent consecutive NGAP: ASI and NGAP: AMF CONFIGURATION UPDATE
    ...  == Precondition ==
    ...  - NRBTS.actNgcFlexSaMode=true (5GC000740)
    ...  - NRBTS.actAmfPlannedRemoval=true
    ...  - NRBTS.amfPlannedRemovalTimer = 30
    ...  - Established NG connections AMF1-gNB, AMF2-gNB
    ...  - AMF-1 is configured with 2 GUAMIs (GUAMI1, GUAMI2)
    ...  - AMF-2 is configured with 1 GUAMI (GUAMI3)
    ...  - AMF-3 is configured with 1 GUAMI (GUAMI4)
    ...  - AMF-1, AMF-2 up and running
    ...  - SERVEDAMF-3.administrativeState = Locked
    ...  - GUAMI1, GUAMI2, GUAMI3, GUAMI4 have no backup AMF
    ...  == Flow ==
    ...  1. Attach UE4 to gNB (AMF1, GUAMI1)
    ...  2. Attach UE5 to gNB (AMF1, GUAMI2)
    ...  3. Connect PDU Session with one QoS Flow (non-GBR) for both UEs
    ...  4. Run UL and DL traffic on UE4 and UE5
    ...  5. Verify UEs attached, PDU sessions connected, traffic started.
    ...  6. Send NGAP: AMF STATUS INDICATION from AMF1 with partial timer approach
    ...  7. Trigger attach UE-6 to AMF1:GUAMI:1  (UE is attached finally to AMF-2)
    ...  8. Connect UE-6 PDU session 3 with QOS flow
    ...  9. Verify that UE-6 is attached to AMF2 (not AMF1 as all AMF1 GUAMIs are unavailable)
    ...  10. Run 20MBps UL and DL traffic on UE6 PDU6 QFI1 and wait 5 seconds
    ...  11. Restore GUAMI1 and GUAMI2 on AMF1 by sending NGAP: AMF CONFIGURATION UPDATE
    ...  12. Trigger UE4 to send PDU Session Modification for PDU4 (backup AMF2 is selected)
    ...  13. Trigger UE5 to send PDU Session Modification for PDU5 (AMF1 is selected)
    ...  14. Wait until amfPlannedRemovalTimer expiration
    ...  15. Trigger UE5 to send PDU Session Modification for PDU5 (AMF1 is selected)
    ...  16. Stop and verify 20MBps UL and DL traffic on UE4-6
    ...  == Postcondition ==
    ...  - Traffic on UEs are not impacted during AMFs reselection
    ...  - PM counters are incremented correctly
    ...  == TESTING TOOLS ==
    ...  AirPhone, EPCSIM, UTE
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode
    ...  - HARDWARE ID: gNB(ASIL + ABIO)
    ...  == REQUIREMENTS COVERAGE ==
    ...  USCB006999-A#9, 5G_RAN_USR_RRM_14493
    ...  == REQUIRED LOGS ==
    ...  NGAP
    ...  == AUTHOR ==
    ...  Marek Kieltyka <marek.kieltyka@nokia.com>
    ...  == REFERENCES ==
    ...  CB006999-2775

    [Setup]  Prepare test environment AB901-1
    Attach UE4 to AMF1:GUAMI:1 and run traffic on PDU 4
    Attach UE5 to AMF1:GUAMI:2 and run traffic on PDU 5
    Send ASI from AMF1 with two GUAMI:1 backupAMF:None timerApproach:off GUAMI:2 backupAMF:None timerApproach:on
    Verify SERVEDAMF-1:GUAMI_index-1 is correctly updated: backupAmfName=None, guamiStatus=unavailable
    Verify SERVEDAMF-1:GUAMI_index-2 is correctly updated: backupAmfName=None, guamiStatus=unavailable

    Expect that UE-6 is attached to AMF2
    Attach UE-6 to AMF1:GUAMI:1  # try to attach to AMF1 which has all GUAMIs unavailable
    Connect UE-6 PDU session 6 with QOS flow
    Verify that UE-6 is attached to AMF2
    Run 20MBps UL and DL traffic on UE6 PDU6 QFI1 and wait 5 seconds

    Restore GUAMIs on AMF1 and set GUAMI1 backupAMF to AMF2 by sending NGAP: AMF CONFIGURATION UPDATE
    Verify SERVEDAMF-1:GUAMI_index-1 is correctly updated: backupAmfName=AMF2, guamiStatus=available
    Verify SERVEDAMF-1:GUAMI_index-2 is correctly updated: backupAmfName=None, guamiStatus=available

    Expect that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-1
    Expect that after PDU Session Modification Request from UE4 gNB performs AMF reselection and AMF2 is selected
    Trigger UE4 to send PDU Session Modification for PDU4
    Verify that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-1
    Verify that after PDU Session Modification Request from UE4 gNB performs AMF reselection and AMF2 is selected

    Expect that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-2
    Expect that after PDU Session Modification Request from UE5 gNB does not perform AMF reselection and AMF1 is selected
    Trigger UE5 to send PDU Session Modification for PDU5
    Verify that after PDU Session Modification Request from UE5 gNB does not perform AMF reselection and AMF1 is selected
    Verify that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-2

    Wait until amfPlannedRemovalTimer expiration

    Expect that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-2
    Expect that after PDU Session Modification Request from UE5 gNB does not perform AMF reselection and AMF1 is selected
    Trigger UE5 to send PDU Session Modification for PDU5
    Verify that after PDU Session Modification Request from UE5 gNB does not perform AMF reselection and AMF1 is selected
    Verify that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-2

    Stop and verify 20MBps UL and DL traffic on UE4 PDU4 QFI1
    Stop and verify 20MBps UL and DL traffic on UE5 PDU5 QFI1
    Stop and verify 20MBps UL and DL traffic on UE6 PDU6 QFI1

    Wait until PM counters file is ready and saved
    Verify PM counters for AMF selection are incremented successfully: attempts:3, fails:0, successes:3
    Verify PM counters for gNB initiated AMF reselection are incremented successfully: attempts:2, fails:0, successes:2
    [Teardown]  Teardown test environment AB901-1

CB006999-A-B901-2-NGSetup_after_ASI_for_the_same_AMF_before_timer_expiry
    [Tags]    AB901-2
    [Documentation]
    ...  DESCRIPTION:
    ...  == Info ==
    ...  This testcase shows that:
    ...  - AMF and GUAMI statuses set with NGAP: ASI are changeable with NGAP: NG SETUP RESPONSE
    ...  - it is possible for UE to select AMF that sent NGAP: NG SETUP RESPONSE with GUAMIs on ServedGUAMIList
    ...  - UE, which is attached to GUAMI with timerApproachForGUAMIRemoval, will be reselected to backup AMF
    ...  in case of NGAP: NG SETUP RESPONSE after NGAP: ASI
    ...  == Precondition ==
    ...  - gNB up and running
    ...  - NRBTS.actNgcFlexSaMode=true (5GC000740)
    ...  - NRBTS.actAmfPlannedRemoval=true
    ...  - NRBTS.amfPlannedRemovalTimer = 50
    ...  - NRBTS.ngUeRetentionEnabled = true
    ...  - AMF-1 supports UE Retention (UERetentionInformation = ues-retained)
    ...  - AMF-2.relativeCapacity = 255
    ...  - Established NG connections AMF1-gNB, AMF2-gNB
    ...  - AMF-1 is configured with 2 GUAMIs (GUAMI1, GUAMI2)
    ...  - AMF-2 is configured with 1 GUAMI (GUAMI3)
    ...  - AMF-3 is configured with 1 GUAMI (GUAMI4)
    ...  - AMF-1, AMF-2, AMF-3 up and running
    ...  == Flow ==
    ...  1.	Attach UE1 to gNB (AMF1, GUAMI1)
    ...  2.	Attach UE2 to gNB (AMF1, GUAMI2)
    ...  3.	Connect PDU Session with one QoS Flow (non-GBR) for both UEs
    ...  4.	Run UL and DL traffic on UE1 and UE2
    ...  5.	Verify UEs attached, PDU sessions connected, traffic started.
    ...  6.	Send NGAP: AMF STATUS INDICATION from AMF1 with GUAMI1 timerApproach=on
    ...  7.	Verify alarm 7115 (fault ID 7325) is raised for SERVEDAMF-1
    ...  8.	Trigger SCTP SHUTDOWN between AMF1 and gNB
    ...  9.	Verify that NG link to AMF-1 recovered
    ...  a.	AMF1 sends NGAP: NG SETUP RESPONSE:
    ...      > GUAMI2
    ...      > UERetentionInformation = ues-retained
    ...  10. Trigger UE1 to send PDU Session Modification for PDU1 (AMF2 is reselected due to higher relativeCapacity)
    ...  11. Trigger UE2 to send PDU Session Modification for PDU2 (old AMF1 is selected)
    ...  12. Wait until amfPlannedRemovalTimer expiration
    ...  13. Trigger UE1 to send PDU Session Modification for PDU1 (AMF2 is still selected)
    ...  14. Attach UE7 to gNB (AMF1, GUAMI1) without starting traffic
    ...  == Postcondition ==
    ...  - Traffic on UEs are not impacted during AMFs reselection
    ...  - PM counters are incremented correctly
    ...  == TESTING TOOLS ==
    ...  AirPhone, EPCSIM, UTE
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode
    ...  - HARDWARE ID: gNB(ASIL + ABIO)
    ...  == REQUIREMENTS COVERAGE ==
    ...  CB006999-A-B901, 5G_RAN_USR_RRM_14493
    ...  == REQUIRED LOGS ==
    ...  NGAP
    ...  == AUTHOR ==
    ...  Marek Kieltyka <marek.kieltyka@nokia.com>
    ...  == REFERENCES ==
    ...  CB006999-2775

    [Setup]  Prepare test environment AB901-2
    Attach UE1 to AMF1:GUAMI:1 and run traffic on PDU 1
    Attach UE2 to AMF1:GUAMI:2 and run traffic on PDU 2
    Send ASI from AMF1 with one GUAMI:1 backupAMF:None timerApproach:on
    Verify that alarm with NG AMF Status Indication fault and fault ID=7325 is raised for AMF1
    Verify SERVEDAMF-1:GUAMI_index-1 is correctly updated: backupAmfName=None, guamiStatus=unavailable
    Verify SERVEDAMF-1:GUAMI_index-2 is correctly updated: backupAmfName=AMF3, guamiStatus=available

    TEMPORARY BYPASS: Reset NG link between AMF1 and gNB
    Verify that NG link to AMF-1 recovered
    Verify that NGSetupResponse from AMF1 includes UERetentionInformation
    Verify SERVEDAMF-1:GUAMI_index-1 is correctly updated: backupAmfName=AMF2, guamiStatus=available

    Expect that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-1
    Expect that after PDU Session Modification Request from UE1 gNB performs AMF reselection and AMF2 is selected
    Trigger UE1 to send PDU Session Modification for PDU1
    Verify that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-1
    Verify that after PDU Session Modification Request from UE1 gNB performs AMF reselection and AMF2 is selected

    Expect that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-3
    Expect that after PDU Session Modification Request from UE2 gNB does not perform AMF reselection and AMF1 is selected
    Trigger UE2 to send PDU Session Modification for PDU2
    Verify that after PDU Session Modification Request from UE2 gNB does not perform AMF reselection and AMF1 is selected
    Verify that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-3

    Wait until amfPlannedRemovalTimer expiration

    Expect that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-1
    Expect that after PDU Session Modification Request from UE1 gNB does not perform AMF reselection and AMF2 is selected
    Trigger UE1 to send PDU Session Modification for PDU1
    Verify that after PDU Session Modification Request from UE1 gNB does not perform AMF reselection and AMF2 is selected
    Verify that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-1

    Stop and verify 20MBps UL and DL traffic on UE1 PDU1 QFI1
    Stop and verify 20MBps UL and DL traffic on UE2 PDU2 QFI1

    Restore AMF1 guamiStatus and backupAMFs
    Attach UE7 to AMF1:GUAMI:1 without starting traffic

    Wait until PM counters file is ready and saved
    Verify PM counters for AMF selection are incremented successfully: attempts:3, fails:0, successes:3
    Verify PM counters for gNB initiated AMF reselection are incremented successfully: attempts:1, fails:0, successes:1
    [Teardown]  Teardown test environment AB901-2
