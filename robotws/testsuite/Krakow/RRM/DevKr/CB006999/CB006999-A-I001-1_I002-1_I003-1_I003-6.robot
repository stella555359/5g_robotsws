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
CB006999-A-I001-1-ASI_received_during_UE_Attach_procedure
    [Tags]    AI001-1
    [Documentation]
    ...  DESCRIPTION:
    ...  == Info ==
    ...  This testcase shows that:
    ...  - old AMF is used till the end of an ongoing UE Attach procedure when NGAP:ASI is sent before attach has finished
    ...  - new AMF is used in the next uplink procedure after NGAP:ASI
    ...  == Precondition ==
    ...  - Real gNB up and running
    ...  - NRBTS.actNgcFlexSaMode=true (5GC000740)
    ...  - NRBTS.actAmfPlannedRemoval=true
    ...  - NRBTS.amfPlannedRemovalTimer=0
    ...  - NRBTS.timerRRCGuard=2500 (ms)
    ...  - Established NG connections AMF-gNB
    ...  - AMF-1 is configured with 2 GUAMIs (GUAMI1, GUAMI2)
    ...  - AMF-2 is configured with 1 GUAMI (GUAMI3)
    ...  - AMF-3 is configured with 1 GUAMI (GUAMI4)
    ...  - 3 AMFs up and running
    ...  == Flow ==
    ...  1.	Attach UE:1 to AMF1:GUAMI:1 with delayed NR-RRC response
    ...     a.	NR-RRC: RRC Reconfiguration Complete is sent 2s (less than NRBTS.timerRRCGuard) after NR-RRC: RRC Reconfiguration
    ...  2.	Send NGAP: AMF STATUS INDICATION from AMF1 with partial GUAMI
    ...  3.	Verify that UE1 ended ICS procedure with AMF1 while AMF sent ASI
    ...  4.	Run 20MBps UL and DL traffic on UE1 PDU1 QFI1 and wait 5 seconds
    ...  5.	Verify SERVEDAMF-1 object is correctly updated
    ...  6.	Trigger UE1 to send PDU Session Modification for PDU1 (backup AMF2 is selected)
    ...  7. Stop and verify 20MBps UL and DL traffic on UE1 PDU1 QFI1
    ...  == Postcondition ==
    ...  - Alarm with faultID=7325 is cleared
    ...  - NGAP links are in active state
    ...  - Traffic on both UEs not impacted
    ...  == TESTING TOOLS ==
    ...  AirPhone, EPCSIM, UTE
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode
    ...  - HARDWARE ID: gNB(ABIO + ASIL) with simulated AEQE radio module - NR_BAND: n78
    ...  == REQUIREMENTS COVERAGE ==
    ...  CB006999-A-I001, 5G_RAN_USR_RRM_6826
    ...  == REQUIRED LOGS ==
    ...  NGAP
    ...  == AUTHOR ==
    ...  - Marek Kieltyka <marek.kieltyka@nokia.com>
    ...  == REFERENCES ==
    ...  CB006999-2769

    [Setup]  Prepare test environment AI001-1
    Attach UE:1 to AMF1:GUAMI:1 with delayed NR-RRC response
    Send ASI from AMF1 with one GUAMI:1 backupAMF:2 timerApproach:off
    Verify that UE1 ended ICS procedure with old AMF1 while AMF sent ASI
    Run 20MBps UL and DL traffic on UE1 PDU1 QFI1 and wait 5 seconds

    Verify that alarm with NG AMF Status Indication fault and fault ID=7325 is raised for AMF1
    Verify SERVEDAMF-1:GUAMI_index-1 is correctly updated: backupAmfName=AMF2, guamiStatus=unavailable
    Verify SERVEDAMF-1:GUAMI_index-2 is correctly updated: backupAmfName=None, guamiStatus=available

    Expect that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-1
    Expect that after PDU Session Modification Request from UE1 gNB performs AMF reselection and AMF2 is selected
    Trigger UE1 to send PDU Session Modification for PDU1
    Verify that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-1
    Verify that after PDU Session Modification Request from UE1 gNB performs AMF reselection and AMF2 is selected

    Stop and verify 20MBps UL and DL traffic on UE1 PDU1 QFI1
    Wait until PM counters file is ready and saved
    Verify PM counters for gNB initiated AMF reselection are incremented successfully: attempts:1, fails:0, successes:1
    [Teardown]  Teardown test environment AI001-1

CB006999-A-I002-1-Receiving_two_ASI_with_different_parameters_without_timer_running
    [Tags]    AI002-1    SKIPRUN
    [Documentation]
    ...  DESCRIPTION:
    ...  == Info ==
    ...  This test scenario describes the gNB behavior during receiving two NGAP: AMF Status Indication from the same
    ...  AMF with different parameters and without timerApproachForGUAMIRemoval set. The test shows following several
    ...  things:
    ...  - NGAP:ASI messages do not update GUAMIs that are set as UNAVAILABLE
    ...  - NGAP:ASI messages update only GUAMIs that are set as AVAILABLE
    ...  - NGAP:ASI can be sent multiple times from the same AMF
    ...  - UEs traffic is not impacted during reselection
    ...  - backup AMF indicated in the first NGAP:ASI message is chosen as AMF in the reselection process
    ...  - reselections for different UEs do not interfere with each other
    ...  == Precondition ==
    ...  Real gNB up and running
    ...  NRBTS.actNgcFlexSaMode=true (5GC000740)
    ...  NRBTS.actAmfPlannedRemoval=true
    ...  NRBTS.amfPlannedRemovalTimer=0
    ...  Established NG connections AMF-gNB
    ...  3 AMFs up and running
    ...  AMF1 is configured with 2 GUAMIs (GUAMI1, GUAMI2)
    ...  AMF2 is configured with GUAMI (GUAMI3)
    ...  AMF3 is configured with GUAMI (GUAMI4)
    ...  GUAMI1, GUAMI2, GUAMI3 and GUAMI4 have no backup AMFs
    ...  GUAMI1, GUAMI2, GUAMI3 and GUAMI4 have status set to AVAILABLE
    ...  == Flow ==
    ...  1.	Attach UE1 to AMF1:GUAMI1.
    ...  2.	Attach UE2 to AMF1:GUAMI2.
    ...  3.	Verify that UE1 is attached to AMF1:GUAMI1.
    ...  4.	Verify that UE2 is attached to AMF1:GUAMI2..
    ...  5.	Connect PDU Session with one QoS Flow (non-GBR) for UE1.
    ...  6.	Connect PDU Session with one QoS Flow (non-GBR) for UE2.
    ...  7.	Run UL and DL traffic on UE1.
    ...  8.	Run UL and DL traffic on UE2.
    ...  Send first NGAP: AMF STATUS INDICATION from AMF1 with unavailableGuamiList:
    ...  - GUAMI1
    ...   -	timerApproachForGUAMIRemoval is not present
    ...   -	backupAMFName is set to AMF2
    ...  9.	Verify that after first NGAP:ASI reception all relevant AMF1 objects are correctly updated:
    ...  - SERVEDAMF-1.guAMI[1].guamiStatus is set to UNAVAILABLE
    ...  - SERVEDAMF-1.guAMI[2].guamiStatus is set to AVAILABLE
    ...  - SERVEDAMF-1.guAMI[1].backupAMF is set to AMF2
    ...  - SERVEDAMF-1.guAMI[2].backupAMF is not present
    ...  10. Verify that alarm 7115 with faultID=7325 is active for AMF1.
    ...  11. Send second NGAP: AMF STATUS INDICATION from AMF1 with unavailableGuamiList:
    ...  - GUAMI1
    ...   - timerApproachForGUAMIRemoval is not present
    ...   - backupAMFName is set to AMF3
    ...  - GUAMI2:
    ...   - timerApproachForGUAMIRemoval is not present
    ...   - backupAMFName is set to AMF3
    ...  12. Verify that after second NGAP:ASI reception all relevant AMF1 objects are correctly updated:
    ...  - SERVEDAMF-1.guAMI[1].guamiStatus is set to UNAVAILABLE
    ...  - SERVEDAMF-1.guAMI[2].guamiStatus is set to UNAVAILABLE
    ...  - SERVEDAMF-1.guAMI[1].backupAMF is set to AMF2 - not updated
    ...  - SERVEDAMF-1.guAMI[2].backupAMF is set to AMF3
    ...  13. Trigger UE1 to send NR-RRC: UL INFORMATION TRANSFER with PDU Session Modification Request.
    ...  14. Verify that gNB stops sending NGAP messages to AMF1 related with UE1.
    ...  15. Verify that gNB performs successful AMF reselection for UE1 and new AMF2 is selected as backup AMF received
    ...  in first NGAP: AMF STATUS INDICATION.
    ...  16. Trigger UE2 to send NR-RRC: UL INFORMATION TRANSFER with PDU Session Modification Request.
    ...  17. Verify that gNB stops sending NGAP messages to AMF1 related with UE2.
    ...  18. Verify that gNB performs successful AMF reselection for UE2 and new AMF3 is selected as backup AMF received
    ...  in second NGAP: AMF STATUS INDICATION.
    ...  19. Verify that UE1 traffic is not impacted during the whole procedure.
    ...  20. Verify that UE2 traffic is not impacted during the whole procedure.
    ...  21. Verify that PM counters are incremented:
    ...  - M55155C00004 - AMF_RESELECTION_GNB_ATT = 2
    ...  - M55155C00005 - AMF_RESELECTION_GNB_FAIL = 0
    ...  - M55155C00006 - AMF_RESELECTION_GNB_SUCC = 2
    ...  22. Teardown:
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
    ...  - HARDWARE ID: gNB(ABIO + ASIL) with simulated AEQE radio module - NR_BAND: n78
    ...  == REQUIREMENTS COVERAGE ==
    ...  CB006999-A#US05
    ...  == REQUIRED LOGS ==
    ...  NGAP
    ...  NR-RRC
    ...  == AUTHOR ==
    ...  - Grzegorz Szymik <grzegorz.szymik@nokia.com>
    ...  == REFERENCES ==
    ...  CB006999-2770

    [Setup]  Prepare test environment AI002-1

    Attach UE1 to AMF1:GUAMI:1 and run traffic on PDU 1
    Attach UE2 to AMF1:GUAMI:2 and run traffic on PDU 2

    Send ASI from AMF1 with one GUAMI:1 backupAMF:2 timerApproach:off
    Verify that alarm with NG AMF Status Indication fault and fault ID=7325 is raised for AMF1
    Verify SERVEDAMF-1:GUAMI_index-1 is correctly updated: backupAmfName=AMF2, guamiStatus=unavailable
    Verify SERVEDAMF-1:GUAMI_index-2 is correctly updated: backupAmfName=None, guamiStatus=available
    Wait until alarm with fault ID=7325 disappears

    Send ASI from AMF1 with two GUAMI:1 backupAMF:3 timerApproach:off GUAMI:2 backupAMF:3 timerApproach:off
    Verify that alarm with NG AMF Status Indication fault and fault ID=7325 is raised for AMF1
    Verify SERVEDAMF-1:GUAMI_index-1 is correctly updated: backupAmfName=AMF2, guamiStatus=unavailable
    Verify SERVEDAMF-1:GUAMI_index-2 is correctly updated: backupAmfName=AMF3, guamiStatus=unavailable

    Expect that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-1
    Expect that after PDU Session Modification Request from UE1 gNB performs AMF reselection and AMF2 is selected
    Trigger UE1 to send PDU Session Modification for PDU1
    Verify that after PDU Session Modification Request from UE1 gNB performs AMF reselection and AMF2 is selected
    Verify that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-1

    Expect that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-1
    Expect that after PDU Session Modification Request from UE2 gNB performs AMF reselection and AMF3 is selected
    Trigger UE2 to send PDU Session Modification for PDU2
    Verify that after PDU Session Modification Request from UE2 gNB performs AMF reselection and AMF3 is selected
    Verify that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-1

    Wait until PM counters file is ready and saved
    Verify PM counters for gNB initiated AMF reselection are incremented successfully: attempts:2, fails:0, successes:2

    Stop and verify 20MBps UL and DL traffic on UE1 PDU1 QFI1
    Stop and verify 20MBps UL and DL traffic on UE2 PDU2 QFI1

    [Teardown]  Teardown test environment AI002-1

CB006999-A-I003-1-Receiving_two_ASI_with_different_parameters_with_timer_running
    [Tags]    AI003-1    SKIPRUN
    [Documentation]
    ...  DESCRIPTION:
    ...  == Info ==
    ...  This test scenario describes the gNB behavior during receiving two NGAP: AMF Status Indication from the same
    ...  AMF with different parameters and with timerApproachForGUAMIRemoval set.
    ...  The test shows following several things:
    ...  - NGAP:ASI messages do not update GUAMIs that are set as UNAVAILABLE
    ...  - NGAP:ASI messages update only GUAMIs that are set as AVAILABLE
    ...  - NGAP:ASI can be sent multiple times from the same AMF
    ...  - UEs traffic is not impacted during reselection after timer expiration
    ...  - backup AMF indicated in the first NGAP:ASI message is chosen as AMF in the reselection process
    ...  - reselections for different UEs do not interfere with each other
    ...  == Precondition ==
    ...  Real gNB up and running
    ...  NRBTS.actNgcFlexSaMode=true (5GC000740)
    ...  NRBTS.actAmfPlannedRemoval=true
    ...  NRBTS.amfPlannedRemovalTimer=60
    ...  Established NG connections AMF-gNB
    ...  3 AMFs up and running
    ...  AMF1 is configured with 2 GUAMIs (GUAMI1, GUAMI2)
    ...  AMF2 is configured with GUAMI (GUAMI3)
    ...  AMF3 is configured with GUAMI (GUAMI4)
    ...  GUAMI1, GUAMI2, GUAMI3 and GUAMI4 have no backup AMFs
    ...  GUAMI1, GUAMI2, GUAMI3 and GUAMI4 have status set to AVAILABLE
    ...  == Flow ==
    ...  1.	Attach UE1 to AMF1:GUAMI1.
    ...  2.	Verify that UE1 is attached to AMF1:GUAMI1.
    ...  3.	Connect PDU Session with one QoS Flow (non-GBR) for UE1.
    ...  4.	Run UL and DL traffic on UE1.
    ...  5. Send first NGAP: AMF STATUS INDICATION from AMF1 with unavailableGuamiList:
    ...  - GUAMI1
    ...   -	timerApproachForGUAMIRemoval is present
    ...   -	backupAMFName is set to AMF2
    ...  6.	Verify that after first NGAP:ASI reception all relevant AMF1 objects are correctly updated:
    ...  - SERVEDAMF-1.guAMI[1].guamiStatus is set to UNAVAILABLE
    ...  - SERVEDAMF-1.guAMI[2].guamiStatus is set to AVAILABLE
    ...  - SERVEDAMF-1.guAMI[1].backupAMF is set to AMF2
    ...  - SERVEDAMF-1.guAMI[2].backupAMF is not present
    ...  7. Send second NGAP: AMF STATUS INDICATION from AMF1 with unavailableGuamiList:
    ...  - GUAMI1
    ...   - timerApproachForGUAMIRemoval is not present
    ...   - backupAMFName is set to AMF3
    ...  - GUAMI2:
    ...   - timerApproachForGUAMIRemoval is present
    ...   - backupAMFName is not present
    ...  8. Verify that after second NGAP:ASI reception all relevant AMF1 objects are correctly updated:
    ...  - SERVEDAMF-1.guAMI[1].guamiStatus is set to UNAVAILABLE
    ...  - SERVEDAMF-1.guAMI[2].guamiStatus is set to UNAVAILABLE
    ...  - SERVEDAMF-1.guAMI[1].backupAMF is set to AMF2 - not updated
    ...  - SERVEDAMF-1.guAMI[2].backupAMF is not present
    ...  9. During timer running, trigger UE1 to send NR-RRC: UL INFORMATION TRANSFER with PDU Session Modification
    ...  Request.
    ...  10. Verify that for the duration of amfPlannedRemovalTimer, UE1 sends messages to AMF1.
    ...  11. Wait until amfPlannedRemovalTimer expiration.
    ...  12. After timer expiration, trigger UE1 to send NR-RRC: UL INFORMATION TRANSFER with PDU Session Modification
    ...  Request.
    ...  13. Verify that gNB performs successful AMF reselection for UE1 after second NGAP UL message and backup AMF2
    ...  is selected (as backup AMF received in first NGAP: AMF STATUS INDICATION).
    ...  14. Verify that gNB stops sending NGAP messages to AMF1 related with UE1.
    ...  15. Verify that UE1 traffic is not impacted during the whole procedure.
    ...  16. Verify that PM counters are incremented:
    ...  - M55155C00004 - AMF_RESELECTION_GNB_ATT = 1
    ...  - M55155C00005 - AMF_RESELECTION_GNB_FAIL = 0
    ...  - M55155C00006 - AMF_RESELECTION_GNB_SUCC = 1
    ...  17. Teardown:
    ...  - Detach UE1
    ...  - SERVEDAMF-1.guAMI[1].guamiStatus = available
    ...  - SERVEDAMF-1.guAMI[2].guamiStatus = available
    ...  == Postcondition ==
    ...  - Alarm with faultID=7325 is cleared
    ...  - NGAP link gNB-AMF1 active
    ...  - NGAP link gNB-AMF2 active
    ...  - NGAP link gNB-AMF3 active
    ...  - UE1 is detached
    ...  == TESTING TOOLS ==
    ...  AirPhone, EPCSIM, UTE
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode
    ...  - HARDWARE ID: gNB(ABIO + ASIL) with simulated AEQE radio module - NR_BAND: n78
    ...  == REQUIREMENTS COVERAGE ==
    ...  CB006999-A#US05
    ...  == REQUIRED LOGS ==
    ...  NGAP
    ...  NR-RRC
    ...  == AUTHOR ==
    ...  - Grzegorz Szymik <grzegorz.szymik@nokia.com>
    ...  == REFERENCES ==
    ...  CB006999-2771

    [Setup]  Prepare test environment AI003-1

    Attach UE1 to AMF1:GUAMI:1 and run traffic on PDU 1

    Send ASI from AMF1 with one GUAMI:1 backupAMF:2 timerApproach:on
    Verify that alarm with NG AMF Status Indication fault and fault ID=7325 is raised for AMF1
    Verify SERVEDAMF-1:GUAMI_index-1 is correctly updated: backupAmfName=AMF2, guamiStatus=unavailable
    Verify SERVEDAMF-1:GUAMI_index-2 is correctly updated: backupAmfName=None, guamiStatus=available

    Send ASI from AMF1 with two GUAMI:1 backupAMF:3 timerApproach:off GUAMI:2 backupAMF:None timerApproach:on
    Verify SERVEDAMF-1:GUAMI_index-1 is correctly updated: backupAmfName=AMF2, guamiStatus=unavailable
    Verify SERVEDAMF-1:GUAMI_index-2 is correctly updated: backupAmfName=None, guamiStatus=unavailable

    Expect that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-2
    Expect that after PDU Session Modification Request from UE1 gNB does not perform AMF reselection and AMF1 is selected
    Trigger UE1 to send PDU Session Modification for PDU1
    Verify that after PDU Session Modification Request from UE1 gNB does not perform AMF reselection and AMF1 is selected
    Verify that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-2

    Wait until amfPlannedRemovalTimer expiration

    Expect that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-1
    Expect that after PDU Session Modification Request from UE1 gNB performs AMF reselection and AMF2 is selected
    Trigger UE1 to send PDU Session Modification for PDU1
    Verify that after PDU Session Modification Request from UE1 gNB performs AMF reselection and AMF2 is selected
    Verify that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-1

    Wait until PM counters file is ready and saved
    Verify PM counters for gNB initiated AMF reselection are incremented successfully: attempts:1, fails:0, successes:1

    Stop and verify 20MBps UL and DL traffic on UE1 PDU1 QFI1

    [Teardown]  Teardown test environment AI003-1

CB006999-A-I003-6-ASI_with_timer_running_received_before_PDU_Session_Modify_Request_from_old_AMF
    [Tags]    AI003-6    SKIPRUN
    [Documentation]
    ...  DESCRIPTION:
    ...  == Info ==
    ...  This testcase shows gNB behavior when NGAP: AMF STATUS INDICATION without backup and
    ...  with timer approach is sent from AMF before PDU Session Setup procedure is started
    ...  on the same AMF. After receiving NGAP: PDU SESSION RESOURCE MODIFY REQUEST from AMF,
    ...  waiting until amfPlannedRemovalTimer expires, and receiving NR-RRC: UL INFORMATION TRANSFER
    ...  from UE - gNB performs AMF reselection for UE.
    ...  == Precondition ==
    ...  - gNB is up and running
    ...  - NRBTS.actNgcFlexSaMode=true (5GC000740)
    ...  - NRBTS.amfPlannedRemovalTimer = 30
    ...  - NRBTS.actAmfPlannedRemoval=true
    ...  - Established NG connections AMF-gNB
    ...  - AMF-1 is configured with 2 GUAMIs (GUAMI1, GUAMI2)
    ...  - AMF-2 is configured with 1 GUAMI (GUAMI3)
    ...  - AMF-3 is configured with 1 GUAMI (GUAMI4)
    ...  - 3 AMFs up and running
    ...  - GUAMI1, GUAMI2, GUAMI3 and GUAMI4 have no backup AMF
    ...  - SERVEDAMF-2.relativeAMFCapacity = 100
    ...  == Flow ==
    ...  1.  Attach UE1 to AMF-1:GUAMI-1
    ...  2.  Verify that UE1 is attached to AMF-1:GUAMI-1
    ...  3.  Connect PDU Session to UE1
    ...  4.  Verify that PDU Session is established successfully for UE1
    ...  5.  Run UL and DL traffic on UE1
    ...  6.  Send NGAP:AMF STATUS INDICATION from AMF1 with unavailableGuamiList:
    ...     a.  GUAMI[1]:
    ...         -  timerApproachForGUAMIRemoval = apply timer
    ...         -  backupAMFName is set to AMF2
    ...     b.  GUAMI[2]:
    ...         -  timerApproachForGUAMIRemoval = apply timer
    ...         -  backupAMFName is set to AMF3
    ...  7.  Verify that alarm with faultID=7325 is raised on SERVEDAMF-1
    ...  8.  Verify that SERVEDAMF-1 object is updated as follows:
    ...     -   GUAMI[1].guamiStatus = unavailable
    ...     -   GUAMI[1].backupAmfName is set to AMF2
    ...     -   GUAMI[2].guamiStatus = unavailable
    ...     -   GUAMI[2].backupAmfName is set to AMF3
    ...  9.  During timer running, trigger AMF1 to send NGAP: PDU SESSION RESOURCE MODIFY REQUEST for UE1 to gNB
    ...  10. Verify that AMF1 sends NGAP: PDU SESSION RESOURCE MODIFY REQUEST to gNB
    ...  11. Verify that gNB sends NGAP: PDU SESSION RESOURCE MODIFY RESPONSE to AMF1
    ...  12. Wait until actAmfPlannedRemovalTimer expires
    ...  13. Trigger UE1 to send NR-RRC: UPLINK INFORMATION TRANSFER (with PDU SESSION MODIFICATION REQUEST)
    ...  14. Verify that after PDU Session Modification Request from UE1 gNB performs AMF reselection and AMF2 is selected
    ...  15. Verify that gNB stops sending NGAP messages to AMF1
    ...  16. Verify that UE1 traffic is ongoing
    ...  17. Verify that PM counters are incremented:
    ...     -   M55155C00004 (AMF_RESELECTION_GNB_ATT) = 1
    ...     -   M55155C00005 (AMF_RESELECTION_GNB_FAIL) = 0
    ...     -   M55155C00006 (AMF_RESELECTION_GNB_SUCC) = 1
    ...     -   M55155C00006 (AMF_RESELECTION_5GC_RCV) = 0
    ...     -   M55155C00006 (AMF_RESELECTION_5GC_REF) = 0
    ...  == Postcondition ==
    ...  - UE1 is active
    ...  - Alarm with faultID=7325 is cleared
    ...  - All NGAP links gNB-AMF are in active state
    ...  == TESTING TOOLS ==
    ...  AirPhone, 5GCSIM, UTE
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode
    ...  - HARDWARE ID: gNB(ABIO + ASIL) with simulated AEQE radio module - NR_BAND: n78
    ...  == REQUIREMENTS COVERAGE ==
    ...  -  5G_RAN_USR_RRM_6830
    ...  == REQUIRED LOGS ==
    ...  NGAP
    ...  == AUTHOR ==
    ...  - Cezary Dudek <cezary.dudek@nokia.com>
    ...  == REFERENCES ==
    ...  - CB006999-2771

    [Setup]  Prepare test environment AI003-6

    Attach UE9 to AMF1:GUAMI:1 and run traffic on PDU 9

    Send ASI from AMF1 with two GUAMI:1 backupAMF:2 timerApproach:on GUAMI:2 backupAMF:3 timerApproach:on
    Verify that alarm with NG AMF Status Indication fault and fault ID=7325 is raised for AMF1
    Verify SERVEDAMF-1:GUAMI_index-1 is correctly updated: backupAmfName=AMF2, guamiStatus=unavailable
    Verify SERVEDAMF-1:GUAMI_index-2 is correctly updated: backupAmfName=AMF3, guamiStatus=unavailable

    Expect that AMF1 sends PDU Session Resource Modify Request
    Trigger AMF1 to send NGAP: PDU SESSION RESOURCE MODIFY REQUEST for UE9 and PDU9
    Verify that AMF1 sends PDU Session Resource Modify Request

    Wait until amfPlannedRemovalTimer expiration

    Expect that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-1
    Expect that after PDU Session Modification Request from UE9 gNB performs AMF reselection and AMF2 is selected
    Trigger UE9 to send PDU Session Modification for PDU9
    Verify that after PDU Session Modification Request from UE9 gNB performs AMF reselection and AMF2 is selected
    Verify that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-1

    Stop and verify 20MBps UL and DL traffic on UE9 PDU9 QFI1

    Wait until PM counters file is ready and saved
    Verify PM counters for gNB initiated AMF reselection are incremented successfully: attempts:1, fails:0, successes:1
    Verify PM counters for 5GC initiated AMF reselection are incremented successfully: received:0, refused:0

    [Teardown]  Teardown test environment AI003-6


