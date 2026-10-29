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
CB006999-A-B301-1-Reselection_after_ASI_received_with_partial_timer_approach_and_with_changed_backupAMF
    [Tags]    AB301-1    SKIPRUN
    [Documentation]
    ...  DESCRIPTION:
    ...  == Info ==
    ...  This test scenario describes the gNB behavior when AMF reselection is performed after receiving AMF Status
    ...  Indication with partial timerApproachForGUAMIRemoval set and with changed backup AMF.
    ...  Traffic on UE is not impacted during successful AMF reselection. Backup AMF is used after reselection.
    ...  == Precondition ==
    ...  Real gNB up and running
    ...  NRBTS.actNgcFlexSaMode=true (5GC000740)
    ...  NRBTS.actAmfPlannedRemoval=true
    ...  NRBTS.amfPlannedRemovalTimer > 0
    ...  Established NG connections AMF-gNB
    ...  AMF1 is configured with 2 GUAMIs (GUAMI1, GUAMI2)
    ...  AMF2 is configured with GUAMI (GUAMI3)
    ...  AMF3 is configured with GUAMI (GUAMI4)
    ...  3 AMFs up and running
    ...  GUAMIs of AMF-1 have backup AMF set to AMF-2 and AMF-3
    ...  GUAMIs of AMF-2 and AMF-3 have no backup AMF
    ...  == Flow ==
    ...  1.	Attach UE1 to AMF1:GUAMI1.
    ...  2.	Attach UE2 to AMF1:GUAMI2.
    ...  3.	Verify that UE1 is attached to AMF1:GUAMI1.
    ...  4.	Verify that UE2 is attached to AMF1:GUAMI2..
    ...  5.	Connect PDU Session with one QoS Flow (non-GBR) for UE1.
    ...  6.	Connect PDU Session with one QoS Flow (non-GBR) for UE2.
    ...  7.	Run UL and DL traffic on UE1.
    ...  8.	Run UL and DL traffic on UE2.
    ...  9. Send NGAP: AMF STATUS INDICATION from AMF1 with unavailableGuamiList:
    ...  - GUAMI1
    ...   - timerApproachForGUAMIRemoval = apply timer
    ...   - backupAMFName is set to AMF3
    ...  - GUAMI2:
    ...   - timerApproachForGUAMIRemoval is not present
    ...   - backupAMFName is set to AMF2
    ...  10. Verify that after NGAP:ASI reception all relevant AMF-1 objects are correctly updated:
    ...  - SERVEDAMF-1.guAMI[1].guamiStatus is set to UNAVAILABLE
    ...  - SERVEDAMF-1.guAMI[2].guamiStatus is set to UNAVAILABLE
    ...  - SERVEDAMF-1.guAMI[1].backupAMF is set to AMF3
    ...  - SERVEDAMF-1.guAMI[2].backupAMF is set to AMF2
    ...  11. Check if alarm 7115 with faultID=7325 is active.
    ...  12. During timer running, trigger UE1 to send NR-RRC: UL INFORMATION TRANSFER with PDU Session Modification Request.
    ...  13. Verify that for the duration of amfPlannedRemovalTimer UE1 sends messages to AMF1.
    ...  14. During timer running, trigger UE2 to send NR-RRC: UL INFORMATION TRANSFER with PDU Session Modification Request.
    ...  15. Verify that while amfPlannedRemovalTimer is running gNB performs successful AMF reselection for UE2 and backup AMF2 is selected.
    ...  16. Verify that gNB stops sending NGAP messages to AMF-1 related with UE2.
    ...  17. Wait until amfPlannedRemovalTimer expiration.
    ...  18. Trigger UE1 to send NR-RRC: UL INFORMATION TRANSFER with PDU Session Modification Request.
    ...  19. Verify that gNB performs successful AMF reselection for UE1 after second NGAP UL message and backup AMF3 is selected.
    ...  20. Verify that gNB stops sending NGAP messages to AMF-1 related with UE1.
    ...  21. Verify that UE1 traffic is not impacted during the whole procedure.
    ...  22. Verify that UE2 traffic is not impacted during the whole procedure.
    ...  23. Verify that PM counters are incremented:
    ...  - M55155C00004 - AMF_RESELECTION_GNB_ATT = 2
    ...  - M55155C00005 - AMF_RESELECTION_GNB_FAIL = 0
    ...  - M55155C00006 - AMF_RESELECTION_GNB_SUCC = 2
    ...  24. Teardown:
    ...  - Detach UE1
    ...  - Detach UE2
    ...  - SERVEDAMF-1.guAMI[1].guamiStatus = available
    ...  - SERVEDAMF-1.guAMI[2].guamiStatus = available
    ...  == Postcondition ==
    ...  - Alarm with faultID=7325 is cleared
    ...  - NGAP link gNB-AMF1 active
    ...  - NGAP link gNB-AMF2 active
    ...  - NGAP link gNB-AMF3 active
    ...  - UE1 is detached
    ...  - UE2 is detached
    ...  == TESTING TOOLS ==
    ...  AirPhone, EPCSIM, UTE
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode
    ...  - HARDWARE ID: gNB(ABIO + ASIL) with 2 simulated AEQE radio modules - NR_BAND: n78
    ...  == REQUIREMENTS COVERAGE ==
    ...  CB006999-A#US10
    ...  == REQUIRED LOGS ==
    ...  NGAP
    ...  == AUTHOR ==
    ...  - Grzegorz Szymik <grzegorz.szymik@nokia.com>
    ...  == REFERENCES ==
    ...  CB006999-2757

    [Setup]  Prepare test environment AB301-1

    Attach UE1 to AMF1:GUAMI:1 and run traffic on PDU 1
    Attach UE2 to AMF1:GUAMI:2 and run traffic on PDU 2

    Send ASI from AMF1 with two GUAMI:1 backupAMF:3 timerApproach:on GUAMI:2 backupAMF:2 timerApproach:off

    Verify that alarm with NG AMF Status Indication fault and fault ID=7325 is raised for AMF1
    Verify SERVEDAMF-1:GUAMI_index-1 is correctly updated: backupAmfName=AMF3, guamiStatus=unavailable
    Verify SERVEDAMF-1:GUAMI_index-2 is correctly updated: backupAmfName=AMF2, guamiStatus=unavailable

    Expect that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-3
    Expect that after PDU Session Modification Request from UE1 gNB does not perform AMF reselection and AMF1 is selected
    Trigger UE1 to send PDU Session Modification for PDU1
    Verify that after PDU Session Modification Request from UE1 gNB does not perform AMF reselection and AMF1 is selected
    Verify that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-3

    Expect that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-1
    Expect that after PDU Session Modification Request from UE2 gNB performs AMF reselection and AMF2 is selected
    Trigger UE2 to send PDU Session Modification for PDU2
    Verify that after PDU Session Modification Request from UE2 gNB performs AMF reselection and AMF2 is selected
    Verify that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-1

    Wait until amfPlannedRemovalTimer expiration

    Expect that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-1
    Expect that after PDU Session Modification Request from UE1 gNB performs AMF reselection and AMF3 is selected
    Trigger UE1 to send PDU Session Modification for PDU1
    Verify that after PDU Session Modification Request from UE1 gNB performs AMF reselection and AMF3 is selected
    Verify that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-1

    Verify that NG link to AMF-1 is established
    Verify that NG link to AMF-2 is established
    Verify that NG link to AMF-3 is established

    Stop and verify 20MBps UL and DL traffic on UE1 PDU1 QFI1
    Stop and verify 20MBps UL and DL traffic on UE2 PDU2 QFI1

    Wait until PM counters file is ready and saved
    Verify PM counters for gNB initiated AMF reselection are incremented successfully: attempts:2, fails:0, successes:2

    [Teardown]  Teardown test environment AB301-1

CB006999-A-B301-2-Selection_after_ASI_received_with_partial_timer_approach_and_with_changed_backupAMF
    [Tags]    AB301-2
    [Documentation]
    ...  DESCRIPTION:
    ...  == Info ==
    ...  This test scenario describes the gNB behavior when AMF selection is performed after receiving
    ...  AMF Status Indication with partial timerApproachForGUAMIRemoval set and with changed backup AMF.
    ...  UE is attached with registeredAMF present in NR-RRC: RRC SETUP COMPLETE. UE attach is redirected to backupAMF,
    ...  since AMF1.guami[1].guamiStatus is unavailable. AMF is chosen from AMFs sent in ASI by gNB loadbalancing
    ...  algorithm during timer running.
    ...  == Precondition ==
    ...  Real gNB up and running
    ...  NRBTS.actNgcFlexSaMode=true (5GC000740)
    ...  NRBTS.actAmfPlannedRemoval=true
    ...  NRBTS.amfPlannedRemovalTimer > 0
    ...  Established NG connections AMF-gNB
    ...  AMF1 is configured with 2 GUAMIs (GUAMI1, GUAMI2)
    ...  AMF2 is configured with GUAMI (GUAMI3)
    ...  AMF3 is configured with GUAMI (GUAMI4)
    ...  3 AMFs up and running
    ...  GUAMIs of AMF-1 have backup AMF set to AMF-2 and AMF-3
    ...  GUAMIs of AMF-2 and AMF-3 have no backup AMF
    ...  SERVEDAMF-2.relativeAMFCapacity = 100
    ...  SERVEDAMF-3.relativeAMFCapacity = 0
    ...  == Flow ==
    ...  1. Send NGAP: AMF STATUS INDICATION from AMF1 with unavailableGuamiList:
    ...  - GUAMI1
    ...   - timerApproachForGUAMIRemoval = apply timer
    ...   - backupAMFName is set to AMF3
    ...  - GUAMI2:
    ...   - timerApproachForGUAMIRemoval is not present
    ...   - backupAMFName is set to AMF2
    ...  2. Verify that after NGAP:ASI reception all relevant AMF-1 objects are correctly updated:
    ...  - SERVEDAMF-1.guAMI[1].guamiStatus is set to UNAVAILABLE
    ...  - SERVEDAMF-1.guAMI[2].guamiStatus is set to UNAVAILABLE
    ...  - SERVEDAMF-1.guAMI[1].backupAMF is set to AMF3
    ...  - SERVEDAMF-1.guAMI[2].backupAMF is set to AMF2
    ...  3. Verify that alarm 7115 with faultID=7325 is active.
    ...  4. During timer running, attach UE1 with registeredAMF (AMF1:GUAMI1) present in NR-RRC: RRC SETUP COMPLETE
    ...  5. Verify that UE1 is not attached to AMF1.
    ...  6. Verify that gNB does not send NGAP messages to AMF1.
    ...  7. Verify that UE1 is attached to AMF2 due to gNB loadbalancing algorithm.
    ...  8. Verify that gNB sends NGAP messages to AMF2.
    ...  9. Verify that PM counters are incremented:
    ...  - M55155C00001 - AMF_SELECTION_GNB_ATT = 1
    ...  - M55155C00002 - AMF_SELECTION_GNB_FAIL = 0
    ...  - M55155C00003 - AMF_SELECTION_GNB_SUCC = 1
    ...  10. Teardown:
    ...  - Detach UE1
    ...  - SERVEDAMF-1.guAMI[1].guamiStatus = available
    ...  - SERVEDAMF-1.guAMI[2].guamiStatus = available
    ...  == Postcondition ==
    ...  - Alarm with faultID=7325 is cleared
    ...  - NGAP link gNB-AMF1 active
    ...  - NGAP link gNB-AMF2 active
    ...  - UE1 is detached
    ...  == TESTING TOOLS ==
    ...  AirPhone, EPCSIM, UTE
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode
    ...  - HARDWARE ID: gNB(ABIO + ASIL) with 2 simulated AEQE radio modules - NR_BAND: n78
    ...  == REQUIREMENTS COVERAGE ==
    ...  CB006999-A#US36
    ...  == REQUIRED LOGS ==
    ...  NGAP
    ...  == AUTHOR ==
    ...  - Grzegorz Szymik <grzegorz.szymik@nokia.com>
    ...  == REFERENCES ==
    ...  CB006999-2757
    ...  == HISTORY ==
    ...  [01.03.2022] - CRT optimization - coverage for AB302-1

    [Setup]  Prepare test environment AB301-2

    Send ASI from AMF1 with two GUAMI:1 backupAMF:3 timerApproach:on GUAMI:2 backupAMF:2 timerApproach:off

    Verify that alarm with NG AMF Status Indication fault and fault ID=7325 is raised for AMF1
    Verify SERVEDAMF-1:GUAMI_index-1 is correctly updated: backupAmfName=AMF3, guamiStatus=unavailable
    Verify SERVEDAMF-1:GUAMI_index-2 is correctly updated: backupAmfName=AMF2, guamiStatus=unavailable

    Expect that UE-3 is attached to AMF2
    Attach UE-3 to AMF1:GUAMI:1
    Connect UE-3 PDU session 1 with QOS flow
    Verify that UE-3 is attached to AMF2
    Detach UE3

    Wait until amfPlannedRemovalTimer expiration

    Wait until PM counters file is ready and saved
    Verify PM counters for AMF selection are incremented successfully: attempts:1, fails:0, successes:1

    #add coverage for AB302-1
    Restore AMF1 GUAMIs
    Cleanup Backup AMF Name from SERVEDAMF-1
    Verify SERVEDAMF-1:GUAMI_index-1 is correctly updated: backupAmfName=None, guamiStatus=available
    Verify SERVEDAMF-1:GUAMI_index-2 is correctly updated: backupAmfName=None, guamiStatus=available
    Attach UE4 to AMF1:GUAMI:1 and run traffic on PDU 1
    Attach UE5 to AMF1:GUAMI:2 and run traffic on PDU 2

    Send ASI from AMF1 with two GUAMI:1 backupAMF:None timerApproach:on GUAMI:2 backupAMF:None timerApproach:off

    Verify that alarm with NG AMF Status Indication fault and fault ID=7325 is raised for AMF1
    Verify SERVEDAMF-1:GUAMI_index-1 is correctly updated: backupAmfName=None, guamiStatus=unavailable
    Verify SERVEDAMF-1:GUAMI_index-2 is correctly updated: backupAmfName=None, guamiStatus=unavailable

    Expect that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-2
    Expect that after PDU Session Modification Request from UE4 gNB does not perform AMF reselection and AMF1 is selected
    Trigger UE4 to send PDU Session Modification for PDU1
    Verify that after PDU Session Modification Request from UE4 gNB does not perform AMF reselection and AMF1 is selected
    Verify that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-2

    Expect that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-1
    Expect that after PDU Session Modification Request from UE5 gNB performs AMF reselection and AMF2 is selected
    Trigger UE5 to send PDU Session Modification for PDU2
    Verify that after PDU Session Modification Request from UE5 gNB performs AMF reselection and AMF2 is selected
    Verify that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-1

    Stop and verify 20MBps UL and DL traffic on UE4 PDU1 QFI1
    Stop and verify 20MBps UL and DL traffic on UE5 PDU2 QFI1

    Wait until PM counters file is ready and saved
    Verify PM counters for gNB initiated AMF reselection are incremented successfully: attempts:1, fails:0, successes:1

    [Teardown]  Teardown test environment AB301-2

CB006999-A-B302-Reselection_after_ASI_partial_timer_approach_and_without_backupAMF
    [Tags]    AB302-1    SKIPRUN
    [Documentation]
    ...  DESCRIPTION:
    ...  == Info ==
    ...  This test scenario describes the gNB behavior when AMF reselection is performed after receiving
    ...  AMF Status Indication with partial timerApproachForGUAMIRemoval set and without backup AMF.
    ...  Timer working is checked in test scenario.
    ...  == Precondition ==
    ...  Real gNB up and running
    ...  NRBTS.actNgcFlexSaMode=true (5GC000740)
    ...  NRBTS.actAmfPlannedRemoval=true
    ...  NRBTS.amfPlannedRemovalTimer = 30
    ...  Established NG connections AMF-gNB
    ...  AMF1 is configured with 2 GUAMIs (GUAMI1, GUAMI2)
    ...  AMF2 is configured with GUAMI (GUAMI3)
    ...  AMF3 is configured with GUAMI (GUAMI4)
    ...  3 AMFs up and running
    ...  GUAMIs of AMF-1, AMF-2 and AMF-3 have no backup AMF
    ...  SERVEDAMF-2.relativeAMFCapacity = 100
    ...  SERVEDAMF-3.relativeAMFCapacity = 0
    ...  == Flow ==
    ...  1. Attach UE1 to AMF1/GUAMI1
    ...  2. Attach UE2 to AMF1/GUAMI2
    ...  3. Establishment of PDU and UL/DL traffic for UE1/UE2
    ...  4. Send NGAP: AMF STATUS INDICATION from AMF1 with unavailableGuamiList:
    ...  - GUAMI1
    ...   - timerApproachForGUAMIRemoval = apply timer
    ...   - backupAMFName is not set
    ...  - GUAMI2:
    ...   - timerApproachForGUAMIRemoval is not present
    ...   - backupAMFName is not set
    ...  5. Verify that after NGAP:ASI reception all relevant AMF-1 objects are correctly updated:
    ...  - SERVEDAMF-1.guAMI[1].guamiStatus is set to UNAVAILABLE
    ...  - SERVEDAMF-1.guAMI[2].guamiStatus is set to UNAVAILABLE
    ...  6. Verify that alarm 7115 with faultID=7325 is active.
    ...  7. During timer running, trigger UE1 to send UL INFORMATION TRANSFER with PDU Session Modification Request
    ...  8.	Verify that gNB does not perform AMF reselection for UE1
    ...  9. During timer running, trigger UE2 to send UL INFORMATION TRANSFER with PDU Session Modification Request
    ...  10. Verify that gNB performs AMF reselection for UE2 with AMF2 (as result of relativeAMFCapacity settings)
    ...  11. Wait till amfPlannedRemovalTimer expires.
    ...  12. Trigger UE1 to send NR-RRC: UL INFORMATION TRANSFER with PDU Session Modification Request
    ...  13. Verify that gNB performs AMF reselection for UE1 with AMF2 (as result of relativeAMFCapacity settings)
    ...  14. Verify that PM counters are incremented:
    ...  - M55155C00001 - AMF_SELECTION_GNB_ATT = 2
    ...  - M55155C00002 - AMF_SELECTION_GNB_FAIL = 0
    ...  - M55155C00003 - AMF_SELECTION_GNB_SUCC = 2
    ...  15. Teardown:
    ...  - Detach UE1 and UE2
    ...  - SERVEDAMF-1.guAMI[1].guamiStatus = available
    ...  - SERVEDAMF-1.guAMI[2].guamiStatus = available
    ...  == Postcondition ==
    ...  - Alarm with faultID=7325 is cleared
    ...  - NGAP link gNB-AMF1 active
    ...  - NGAP link gNB-AMF2 active
    ...  - UE1 and UE2 detached
    ...  == TESTING TOOLS ==
    ...  AirPhone, EPCSIM, UTE
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode
    ...  - HARDWARE ID: gNB(ABIO + ASIL) with 2 simulated AEQE radio modules - NR_BAND: n78
    ...  == REQUIREMENTS COVERAGE ==
    ...  CB006999-A-B302 AMF Status Indication with partial timer approach and without backup AMF
    ...  == REQUIRED LOGS ==
    ...  NGAP
    ...  == AUTHOR ==
    ...  - Konrad Krzyzak <konrad.krzyzak@nokia.com>
    ...  == REFERENCES ==
    ...  CB006999-2757
    ...  == HISTORY ==
    ...  [01.03.2022] - CRT optimization - coverage moved to AB301-2

    [Setup]  Prepare test environment AB302-1

    Attach UE1 to AMF1:GUAMI:1 and run traffic on PDU 1
    Attach UE2 to AMF1:GUAMI:2 and run traffic on PDU 2

    Send ASI from AMF1 with two GUAMI:1 backupAMF:None timerApproach:on GUAMI:2 backupAMF:None timerApproach:off

    Verify that alarm with NG AMF Status Indication fault and fault ID=7325 is raised for AMF1
    Verify SERVEDAMF-1:GUAMI_index-1 is correctly updated: backupAmfName=None, guamiStatus=unavailable
    Verify SERVEDAMF-1:GUAMI_index-2 is correctly updated: backupAmfName=None, guamiStatus=unavailable

    Expect that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-2
    Expect that after PDU Session Modification Request from UE1 gNB does not perform AMF reselection and AMF1 is selected
    Trigger UE1 to send PDU Session Modification for PDU1
    Verify that after PDU Session Modification Request from UE1 gNB does not perform AMF reselection and AMF1 is selected
    Verify that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-2

    Expect that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-1
    Expect that after PDU Session Modification Request from UE2 gNB performs AMF reselection and AMF2 is selected
    Trigger UE2 to send PDU Session Modification for PDU2
    Verify that after PDU Session Modification Request from UE2 gNB performs AMF reselection and AMF2 is selected
    Verify that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-1

    Wait until amfPlannedRemovalTimer expiration

    Expect that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-1
    Expect that after PDU Session Modification Request from UE1 gNB performs AMF reselection and AMF2 is selected
    Trigger UE1 to send PDU Session Modification for PDU1
    Verify that after PDU Session Modification Request from UE1 gNB performs AMF reselection and AMF2 is selected
    Verify that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-1

    Stop and verify 20MBps UL and DL traffic on UE1 PDU1 QFI1
    Stop and verify 20MBps UL and DL traffic on UE2 PDU2 QFI1

    Wait until PM counters file is ready and saved
    Verify PM counters for gNB initiated AMF reselection are incremented successfully: attempts:2, fails:0, successes:2

    [Teardown]  Teardown test environment AB302-1

CB006999-A-B303-1-5GCore_trigger_AMF_reselection_after_receiving_ASI_with_timer_approach_and_with_backup_AMF
    [Tags]    AB303-1
    [Documentation]
    ...  DESCRIPTION:
    ...  == Info ==
    ...  This test scenario describes the gNB behavior when AMF reselection triggered by 5GCore is performed after
    ...  receiving AMF Status Indication with timerApproachForGUAMIRemoval set and with backup AMF set.
    ...  Due to 5GCore reselection UE is relocated to another GUAMI of the same AMF.
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
    ...  == Flow ==
    ...  1.	Attach UE1 to AMF-1 (GUAMI 1) and run traffic on PDU 1
    ...  2.	Send ASI from AMF-1 with unavailableGuamiList=[(GUAMI1, timer approach set, backup AMF set to AMF-3)]
    ...  3.	Trigger sending NGAP: UE CONTEXT MODIFICATION REQUEST from old AMF-1 for UE1 with SERVEDAMF-1.GUAMI2
    ...  4.	gNB sends UE CONTEXT MODIFICATION RESPONSE to AMF-1
    ...  5.	Wait until amfPlannedRemovalTimer expiration
    ...  6. Trigger UE1 to send NR-RRC: UL INFORMATION TRANSFER with PDU Session Modification Request.
    ...  7. Send ASI from AMF-1 with unavailableGuamiList=[(GUAMI2, timer approach not set, backup AMF set to AMF-2)]
    ...  8. Trigger UE1 to send NR-RRC: UL INFORMATION TRANSFER with PDU Session Modification Request.
    ...  == Postcondition ==
    ...  - Alarm 7115 is raised
    ...  - All NGAP links gNB-AMF are in active state
    ...  == TESTING TOOLS ==
    ...  AirPhone, 5GCSim, UTE
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode
    ...  - HARDWARE ID: gNB(ABIO + ASIL) with 2 simulated AEQE radio modules - NR_BAND: n78
    ...  == REQUIREMENTS COVERAGE ==
    ...  == REQUIRED LOGS ==
    ...  NGAP
    ...  == AUTHOR ==
    ...  - Karolina Sroczyk <karolina.sroczyk@nokia.com>
    ...  == REFERENCES ==
    ...  CB006999-2761

    [Setup]  Prepare test environment AB303-1

    Attach UE1 to AMF1:GUAMI:1 and run traffic on PDU 1

    Set Support Guami Unavailability to ON for AMF1
    Send ASI from AMF1 with one GUAMI:1 backupAMF:3 timerApproach:on
    Verify that alarm with NG AMF Status Indication fault and fault ID=7325 is raised for AMF1
    Verify SERVEDAMF-1:GUAMI_index-1 is correctly updated: backupAmfName=AMF3, guamiStatus=unavailable
    Verify SERVEDAMF-1:GUAMI_index-2 is correctly updated: backupAmfName=AMF3, guamiStatus=available

    Expect that UE Context Modification was sent from AMF1 for UE1 with aMFPointer equal to 2
    Send NGAP: UE Context Modification Request from old AMF1 for UE1
    Verify that UE Context Modification was sent from AMF1 for UE1 with aMFPointer equal to 2

    Wait until amfPlannedRemovalTimer expiration

    Expect that after PDU Session Modification Request from UE1 gNB does not perform AMF reselection and AMF1 is selected
    Trigger UE1 to send PDU Session Modification for PDU1
    Verify that after PDU Session Modification Request from UE1 gNB does not perform AMF reselection and AMF1 is selected

    Send ASI from AMF1 with one GUAMI:2 backupAMF:2 timerApproach:off
    Verify that alarm with NG AMF Status Indication fault and fault ID=7325 is raised for AMF1
    Verify SERVEDAMF-1:GUAMI_index-1 is correctly updated: backupAmfName=AMF3, guamiStatus=unavailable
    Verify SERVEDAMF-1:GUAMI_index-2 is correctly updated: backupAmfName=AMF2, guamiStatus=unavailable

    Expect that after PDU Session Modification Request from UE1 gNB performs AMF reselection and AMF2 is selected
    Trigger UE1 to send PDU Session Modification for PDU1
    Verify that after PDU Session Modification Request from UE1 gNB performs AMF reselection and AMF2 is selected

    Stop and verify 20MBps UL and DL traffic on UE1 PDU1 QFI1

    Wait until PM counters file is ready and saved
    Verify PM counters for 5GC initiated AMF reselection are incremented successfully: received:0, refused:0
    Verify PM counters for gNB initiated AMF reselection are incremented successfully: attempts:1, fails:0, successes:1

    [Teardown]  Teardown test environment AB303-1

CB006999-A-B303-2-5GCore_trigger_AMF_reselection_after_receiving_ASI_without_timer_approach_and_with_backup_AMF
    [Tags]    AB303-2
    [Documentation]
    ...  DESCRIPTION:
    ...  == Info ==
    ...  This test scenario describes the gNB behavior when AMF reselection triggered by 5GCore is performed, after
    ...  receiving AMF Status Indication without timerApproachForGUAMIRemoval set and with backup AMF set.
    ...  Due to 5GCore reselection, UE is relocated to another AMF.
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
    ...  - NRBTS.amfPlannedRemovalTimer = 0
    ...  == Flow ==
    ...  1.	Attach UE1 to AMF-1 (GUAMI 1) and run traffic on PDU 1
    ...  2.	Send ASI from AMF-1 with unavailableGuamiList=[(GUAMI1, timer approach NOT set, backup AMF set to AMF-3)]
    ...  3.	Trigger sending NGAP: UE CONTEXT MODIFICATION REQUEST from new AMF-2 for UE1 with SERVEDAMF-2.GUAMI3
    ...  4. gNB sends UE CONTEXT MODIFICATION RESPONSE to AMF-2
    ...  5. Trigger UE1 to send NR-RRC: UL INFORMATION TRANSFER with PDU Session Modification Request.
    ...  == Postcondition ==
    ...  - Alarm 7115 is raised
    ...  - All NGAP links gNB-AMF are in active state
    ...  == TESTING TOOLS ==
    ...  AirPhone, 5GCSim, UTE
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode
    ...  - HARDWARE ID: gNB(ABIO + ASIL) with 2 simulated AEQE radio modules - NR_BAND: n78
    ...  == REQUIREMENTS COVERAGE ==
    ...  == REQUIRED LOGS ==
    ...  NGAP
    ...  == AUTHOR ==
    ...  - Karolina Sroczyk <karolina.sroczyk@nokia.com>
    ...  == REFERENCES ==
    ...  CB006999-2761

    [Setup]  Prepare test environment AB303-2

    Attach UE1 to AMF1:GUAMI:1 and run traffic on PDU 1

    Send ASI from AMF1 with one GUAMI:1 backupAMF:3 timerApproach:off
    Verify that alarm with NG AMF Status Indication fault and fault ID=7325 is raised for AMF1
    Verify SERVEDAMF-1:GUAMI_index-1 is correctly updated: backupAmfName=AMF3, guamiStatus=unavailable
    Verify SERVEDAMF-1:GUAMI_index-2 is correctly updated: backupAmfName=AMF3, guamiStatus=available

    Expect that UE Context Modification was sent from new AMF2 for UE1
    Send NGAP: UE Context Modification Request from new AMF2 for UE1 currently using AMF1
    Verify that UE Context Modification was sent from new AMF2 for UE1

    Expect that after PDU Session Modification Request from UE1 gNB does not perform AMF reselection and AMF2 is selected
    Trigger UE1 to send PDU Session Modification for PDU1
    Verify that after PDU Session Modification Request from UE1 gNB does not perform AMF reselection and AMF2 is selected

    Stop and verify 20MBps UL and DL traffic on UE1 PDU1 QFI1

    Wait until PM counters file is ready and saved
    Verify PM counters for 5GC initiated AMF reselection are incremented successfully: received:1, refused:0
    Verify PM counters for gNB initiated AMF reselection are incremented successfully: attempts:0, fails:0, successes:0

    [Teardown]  Teardown test environment AB303-2

