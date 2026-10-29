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
...         [24.10.2023] - Extend with legacy counters

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
CB006999-A-B201-1-AMF_selection_after_receiving_ASI_without_timer_with_backupAMF_and_AMFRegistered_in_RRCSetupComplete
    [Tags]    AB201-1    SKIPRUN
    [Documentation]
    ...  DESCRIPTION:
    ...  == Info ==
    ...  This test scenario describes the gNB behavior when AMF selection is performed after receiving
    ...  AMF Status Indication without timerApproachForGUAMIRemoval set and with backup AMF set.
    ...  UE is attached with registeredAMF present in NR-RRC: RRC SETUP COMPLETE.
    ...  == Precondition ==
    ...  - Both simulated and real gNB up and running
    ...  - 3 AMFs up and running
    ...  - Established NG connections AMF-gNB
    ...  - AMF-1 is configured with 2 GUAMIs (GUAMI1, GUAMI2)
    ...  - AMF-2 is configured with 2 GUAMIs (GUAMI3, GUAMI4)
    ...  - AMF-3 is configured with 2 GUAMIs (GUAMI1, GUAMI2)
    ...  - All GUAMIs have status set to AVAILABLE
    ...  - AMF-1 have backup AMF set to AMF-2 and AMF-3
    ...  - NRBTS.actNgcFlexSaMode=true (5GC000740)
    ...  - NRBTS.actAmfPlannedRemoval=true
    ...  == Flow ==
    ...  1. Send ASI from AMF-1 with GUAMIs backup set to AMF-3 and without timer approach
    ...  2. Attach UE1 with registeredAMF set to (AMF-1, GUAMI1)
    ...  == Postcondition ==
    ...  - Alarm 7115 is raised
    ...  - UE1 is attached to AMF-3
    ...  == TESTING TOOLS ==
    ...  AirPhone, 5GCSim, UTE
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode
    ...  - HARDWARE ID: gNB(ABIO + ASIL) with simulated AEQE radio module - NR_BAND: n78
    ...  == REQUIREMENTS COVERAGE ==
    ...  CB006999-A#US01
    ...  == REQUIRED LOGS ==
    ...  NGAP
    ...  == AUTHOR ==
    ...  - Karolina Sroczyk <karolina.sroczyk@nokia.com>
    ...  == REFERENCES ==
    ...  CB006999-2426

    [Setup]  Prepare test environment AB201-1

    Send ASI from AMF1 with two GUAMI:1 backupAMF:3 timerApproach:off GUAMI:2 backupAMF:3 timerApproach:off
    Verify SERVEDAMF-1:GUAMI_index-1 is correctly updated: backupAmfName=AMF3, guamiStatus=unavailable
    Verify SERVEDAMF-1:GUAMI_index-2 is correctly updated: backupAmfName=AMF3, guamiStatus=unavailable
    Verify that alarm with NG AMF Status Indication fault and fault ID=7325 is raised for AMF1

    Expect that UE-1 is attached to AMF3
    Attach UE-1 to AMF1:GUAMI:1
    Connect UE-1 PDU session 1 with QOS flow
    Verify that UE-1 is attached to AMF3

    Wait until PM counters file is ready and saved
    Verify PM counters for AMF selection are incremented successfully: attempts:1, fails:0, successes:1
    [Teardown]  Teardown test environment AB201-1


CB006999-A-B202-1-Successful_AMF_reselection_after_ASI_received_without_timer_and_with_backup_AMF
    [Tags]    AB202-1    SKIPRUN
    [Documentation]
    ...  DESCRIPTION:
    ...  == Info ==
    ...  This test scenario describes the gNB behavior when AMF reselection is performed
    ...  after receiving AMF Status Indication without timerApproachForGUAMIRemoval set
    ...  and with backup AMF set.
    ...  Traffic on UE is not impacted during successful AMF reselection.
    ...  Backup AMF is used at reselection.
    ...  == Precondition ==
    ...  - Real gNB up and running
    ...  - NRBTS.actNgcFlexSaMode=true (5GC000740)
    ...  - NRBTS.actAmfPlannedRemoval=true
    ...  - NRBTS.amfPlannedRemovalTimer is set to 0
    ...  - Established NG connections AMF-gNB
    ...  - AMF-1 is configured with 2 GUAMIs (GUAMI1, GUAMI2)
    ...  - AMF-2 is configured with 2 GUAMIs (GUAMI3, GUAMI4)
    ...  - AMF-3 is configured with 2 GUAMIs (GUAMI1, GUAMI2)
    ...  - 3 AMFs up and running
    ...  - GUAMIs of AMF-1 have backup AMF set to AMF-2 and AMF-3
    ...  - GUAMIs of AMF-2 and AMF-3 have no backup AMF
    ...  == Flow ==
    ...  1. Attach UE1 to gNB using AMF1 and GUAMI1.
    ...  2. Verify that UE1 is correctly attached to AMF1 and GUAMI1.
    ...  3. Connect PDU Session with one QoS Flow (non-GBR).
    ...  4. Run UL and DL traffic on UE1.
    ...  5. Send NGAP: AMF STATUS INDICATION from AMF1 with unavailableGuamiList:
    ...  - GUAMI1
    ...   - timerApproachForGUAMIRemoval is not present
    ...   - backupAMFName is set to AMF-2
    ...  - GUAMI2:
    ...   - timerApproachForGUAMIRemoval is not present
    ...   - backupAMFName is set to AMF-2
    ...  6. Verify that after NGAP:ASI reception all relevant AMF-1 objects are correctly updated:
    ...  - SERVEDAMF-1.guAMI[1].guamiStatus is set to unavailable
    ...  - SERVEDAMF-1.guAMI[2].guamiStatus is set to unavailable
    ...  - SERVEDAMF-1.guAMI[1].backupAMF is set to AMF-2
    ...  - SERVEDAMF-1.guAMI[2].backupAMF is set to AMF-2
    ...  7. Check if alarm 7115 with faultID=7325 is active.
    ...  8. Trigger UE1 to send NR-RRC: UL INFORMATION TRANSFER with PDU Session Modification Request.
    ...  9. Verify that gNB performs reselection and sends NGAP: UPLINK NAS TRANSPORT to AMF-2.
    ...  10. Verify that gNB stops sending NGAP messages to AMF-1.
    ...  11. Verify that AMF-2 starts PDU Session Modification procedure.
    ...  12. Verify that PDU Session Modification procedure is performed successfully.
    ...  13. Verify that UE1 traffic is not impacted during reselection.
    ...  14. Verify that PM counters are incremented:
    ...  - M55155C00004 - AMF_RESELECTION_GNB_ATT = 1
    ...  - M55155C00005 - AMF_RESELECTION_GNB_FAIL = 0
    ...  - M55155C00006 - AMF_RESELECTION_GNB_SUCC = 1
    ...  15.	Teardown:
    ...  - Detach UE1
    ...  - SERVEDAMF-1.guAMI[1].guamiStatus = available
    ...  - SERVEDAMF-1.guAMI[2].guamiStatus = available
    ...  == Postcondition ==
    ...  - Alarm with faultID=7325 is cleared
    ...  - NGAP links gNB-AMF1 and gNB-AMF2 are in active state
    ...  == TESTING TOOLS ==
    ...  AirPhone, EPCSIM, UTE
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode
    ...  - HARDWARE ID: gNB(ABIO + ASIL) with simulated AEQE radio module - NR_BAND: n78
    ...  == REQUIREMENTS COVERAGE ==
    ...  CB006999-A#US06
    ...  == REQUIRED LOGS ==
    ...  NGAP
    ...  == AUTHOR ==
    ...  - Grzegorz Szymik <grzegorz.szymik@nokia.com>
    ...  == REFERENCES ==
    ...  CB006999-2753

    [Setup]  Prepare test environment AB202-1

    Attach UE1 to AMF1:GUAMI:1 and run traffic on PDU 1

    Send ASI from AMF1 with two GUAMI:1 backupAMF:2 timerApproach:off GUAMI:2 backupAMF:2 timerApproach:off

    Verify SERVEDAMF-1:GUAMI_index-1 is correctly updated: backupAmfName=AMF2, guamiStatus=unavailable
    Verify SERVEDAMF-1:GUAMI_index-2 is correctly updated: backupAmfName=AMF2, guamiStatus=unavailable
    Verify that alarm with NG AMF Status Indication fault and fault ID=7325 is raised for AMF1

    Expect that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-1
    Expect that after PDU Session Modification Request from UE1 gNB performs AMF reselection and AMF2 is selected
    Trigger UE1 to send PDU Session Modification for PDU1
    Verify that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-1
    Verify that after PDU Session Modification Request from UE1 gNB performs AMF reselection and AMF2 is selected

    Verify that NG link to AMF-1 is established
    Verify that NG link to AMF-2 is established

#    Wait until PM counters file is ready and saved
#    Verify PM counters for gNB initiated AMF reselection are incremented successfully: attempts:1, fails:0, successes:1

    Stop and verify 20MBps UL and DL traffic on UE1 PDU1 QFI1

    [Teardown]  Teardown test environment AB202-1


CB006999-A-B202-2-Failure_AMF_reselection_after_ASI_received_without_timer_and_with_backup_AMF
    [Tags]    AB202-2
    [Documentation]
    ...  DESCRIPTION:
    ...  == Info ==
    ...  This testcase shows the behavior of UE when AMF Status Indication is sent and
    ...  all AMFs specified as backup AMFs in GUAMI are unavailable. UE is released.
    ...  Also, testcase shows that GUAMI's backupAMFName is overwritable by backupAMFName
    ...  received in NGAP: AMF Status Indication without timer approach and with backup AMF.
    ...  == Precondition ==
    ...  - gNB up and running
    ...  - NRBTS.actNgcFlexSaMode=true (5GC000740)
    ...  - NRBTS.actAmfPlannedRemoval=true
    ...  - NRBTS.amfPlannedRemovalTimer=0
    ...  - Established NG connections AMF-gNB
    ...  - AMF-1 is configured with 2 GUAMIs (GUAMI1, GUAMI2) - SERVEDAMF-1
    ...  - AMF-2 is configured with 2 GUAMIs (GUAMI3, GUAMI4) - SERVEDAMF-2
    ...  - GUAMI1, GUAMI2 have backup AMF set to AMF-3
    ...  - 3 AMFs up and running
    ...  == Flow ==
    ...  1. Attach UE1 to AMF-1:GUAMI-1 and run traffic
    ...  2. Send ASI from AMF-1:[(GUAMI[1, 2]: without TA, backup AMF set to AMF-2)]
    ...  3. Send ASI from AMF-2:[(GUAMI[1, 2]: without TA, backup AMF not set)]
    ...  4. Verify that alarm with faultID=7325 is raised
    ...  5. Send NR-RRC: UL Information Transfer with PDU Session Modification Request from UE1
    ...  6. Verify that UE1 is released
    ...  7. Verify that PM counters for AMF reselection by gNB are incremented - fail case
    ...  == Postcondition ==
    ...  - Alarm with faultID=7325 is cleared
    ...  - NGAP link gNB-AMF1 is active
    ...  - NGAP link gNB-AMF2 is active
    ...  - UE1 is detached
    ...  == TESTING TOOLS ==
    ...  AirPhone UE, 5GCSim, UTE
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode
    ...  - HARDWARE ID: gNB(ABIO + ASIL) with simulated AEQE radio module - NR_BAND: n78
    ...  == REQUIREMENTS COVERAGE ==
    ...  - USCB006999-A#2
    ...  == REQUIRED LOGS ==
    ...  NGAP
    ...  == AUTHOR ==
    ...  - Cezary Dudek <cezary.dudek@nokia.com>
    ...  == REFERENCES ==
    ...  - CB006999-2753

    [Setup]  Prepare test environment AB202-2
    Attach UE1 to AMF1:GUAMI:1 and run traffic on PDU 1

    Send ASI from AMF1 with two GUAMI:1 backupAMF:2 timerApproach:false GUAMI:2 backupAMF:2 timerApproach:false
    Verify that alarm with NG AMF Status Indication fault and fault ID=7325 is raised for AMF1

    Verify SERVEDAMF-1:GUAMI_index-1 is correctly updated: backupAmfName=AMF2, guamiStatus=unavailable
    Verify SERVEDAMF-1:GUAMI_index-2 is correctly updated: backupAmfName=AMF2, guamiStatus=unavailable

    Send ASI from AMF2 with one GUAMI:1 backupAMF:None timerApproach:false
    Verify that alarm with NG AMF Status Indication fault and fault ID=7325 is raised for AMF2

    Verify SERVEDAMF-2:GUAMI_index-1 is correctly updated: backupAmfName=None, guamiStatus=unavailable

    Expect UE1 is released by gNB
    Expect that UE-1 is not attached to AMF2
    Try to send NGAP: UPLINK NAS TRANSPORT from UE1 to AMF1
    Verify UE1 is released by gNB
    Verify that UE-1 is not attached to AMF2

    Wait until PM counters file is ready and saved
    Verify PM counters for gNB initiated AMF reselection are incremented successfully: attempts:1, fails:1, successes:0
    Verify counter value on NRCELL-1 for M55125C08504 - NG_FLOW_REL_NORMAL equals 0
    Verify counter value on NRCELL-1 for M55125C09006 - NG_FLOW_REL_GNB_UNSPECIFIED equals 0
    Verify counter value on NRCELL-1 for M55125C09028 - NG_FLOW_REL_ABNORMAL equals 1
    Verify counter value on NRCELL-1 for M55125C08503 - NG_FLOW_REL equals 1

    [Teardown]  Teardown test environment AB202-2
