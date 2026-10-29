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

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup  Run Keywords
...  Setup emss    node_id=1
...  AND  Create all devices aliases
...  AND  Configure CB006999 basic params via yaml
#...  AND  Setup egate  egate_port=20000  alias=default
...  AND  ute_admin.Setup admin    bts_host=192.168.255.1    bts_port=443    use_ssl=True
...  AND  Reach OnAir with retries   lua_cfg=${lua_cfg_file}

*** Variables ***
${lua_cfg_file}=   ${CURDIR}/config/egate_SA_2c_1gNBSim_3amf_duplicated_GUAMI_APoABIO.lua

*** Test Cases ***
CB006999-A-I002-3-Core_Network_triggered_AMF_reselection-gNB_receives_PDUSessionResourceModifyRequest_from_new_AMF-ASI_without_timer
    [Tags]    AI002-3    SKIPRUN
    [Documentation]
    ...  DESCRIPTION:
    ...  == Info ==
    ...  This test scenario describes the gNB behavior when AMF reselection is triggered by Core Network
    ...   by sending NGAP: PDU SESSION RESOURCE MODIFY REQUEST from other AMF (in this case AMF2) after ASI
    ...   without timerApproachForGUAMIRemoval set..
    ...  == Precondition ==
    ...  - gNB up and running
    ...  - NRBTS.actNgcFlexSaMode=true (5GC000740)
    ...  - NRBTS.actAmfPlannedRemoval=true
    ...  - NRBTS.amfPlannedRemovalTimer=0
    ...  - Established NG connections AMF-gNB
    ...  - AMF-1 is configured with 2 GUAMIs (GUAMI1, GUAMI2) - SERVEDAMF-1
    ...  - AMF-2 is configured with 1 GUAMI (GUAMI1) - SERVEDAMF-2
    ...  - AMF-3 is configured with 1 GUAMI (GUAMI4) - SERVEDAMF-3
    ...  - AMF-1 (GUAMI1, GUAMI2)  have backup: AMF2 and AMF3
    ...  - AMF-2 (GUAMI1), AMF-3 (GUAMI4) have no backup AMF
    ...  - 3 AMFs up and running
    ...  - SERVEDAMF-1.relativeAMFCapacity=10
    ...
    ...  == Flow ==
    ...  1.	Attach UE1 to AMF-1:GUAMI-1
    ...  2.	Verify that UE1 is connected to AMF1
    ...  3.	UE1 connects PDU Session
    ...  4.	Verify that PDU Session established successfully for UE1
    ...  5.	5.	Run UL and DL traffic on UE1
    ...  6.	AMF1 sends NGAP: AMF STATUS INDICATION with UnavailableGUAMIList:
    ...  -	GUAMI1,
    ...  -	timerApproachForGUAMIRemoval is not present
    ...  -	backupAMFName is present (EMPTY STRING)
    ...  -	GUAMI2,
    ...  -	timerApproachForGUAMIRemoval is not present
    ...  -	backupAMFName is present (EMPTY STRING)
    ...  7.	Verify SERVEDAMF-1 object is correctly updated:
    ...  -	SERVEDAMF-1.guAMI[1].guamiStatus is set to UNAVAILABLE
    ...  -	SERVEDAMF-1.guAMI[1].backupAMF is not updated
    ...  -	SERVEDAMF-2.guAMI[1].guamiStatus is set to UNAVAILABLE
    ...  -	SERVEDAMF-2.guAMI[1].backupAMF is not updated
    ...  8.	Verify that alarm 7115 (fault ID 7325) is raised  for SERVEDAMF-1
    ...  9. Verify that gNB sends NGAP: UPLINK NAS TRANSPORT to AMF-2
    ...  10.Trigger AMF2 to send NGAP: PDU SESSION RESOURCE MODIFY REQUEST for UE1 to gNB
    ...  11.Verify that gNB stops sending NGAP messages to SERVEDAMF-1
    ...  12.Verify that gNB performs reselection to AMF-2 for UE1
    ...  13.Verify that gNB sends NGAP: UPLINK NAS TRANSPORT to AMF-2
    ...  14.Verify that gNB sends NGAP: PDU SESSION RESOURCE MODIFY RESPONSE to AMF2
    ...  15.Verify that PM counters are incremented:
    ...  -  M55155C00007 (AMF_RESELECTION_5GC_RCV) = 1
    ...  -  M55155C00008 (AMF_RESELECTION_5GC_REF) = 0
    ...  == Postcondition ==
    ...  UE1 is active
    ...  UE1 data traffic is not impacted
    ...  NGAP link gNB-AMF1 is active
    ...  NGAP link gNB-AMF2 is active
    ...  NGAP link gNB-AMF3 is active

    ...  == TESTING TOOLS ==
    ...  AirPhone, EPCSIM, UTE
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode
    ...  - HARDWARE ID: gNB(ABIO + ASIL) with simulated AEQE radio module - NR_BAND: n78
    ...  == REQUIREMENTS COVERAGE ==
    ...  CB006999-A-I002 AMF Status Indication handling is ongoing and interacting with incoming procedures (without timer)
    ...  US#1: AMF Status Indication handling is ongoing and interacting with incoming procedures (without timer)
    ...
    ...  == REQUIRED LOGS ==
    ...  NGAP
    ...  == AUTHOR ==
    ...  - Gabriela Stasiuk <gabriela.stasiuk@nokia.com>
    ...  == REFERENCES ==
    ...  CFAM_CB006999

    [Setup]  Prepare test environment AI002-3

    Attach UE1 to AMF1:GUAMI:1 and run traffic on PDU 1
    Set target GUAMI to GUAMI1 for relocation to other AMF after PDU Session Modification

    Expect that gNB sends NGAP: UPLINK NAS TRANSPORT to AMF2
    Send ASI from AMF1 with two GUAMI:1 backupAMF:None timerApproach:off GUAMI:2 backupAMF:None timerApproach:off
    Verify that alarm with NG AMF Status Indication fault and fault ID=7325 is raised for AMF1
    Verify SERVEDAMF-1:GUAMI_index-1 is correctly updated: backupAmfName=None, guamiStatus=unavailable
    Verify SERVEDAMF-1:GUAMI_index-2 is correctly updated: backupAmfName=None, guamiStatus=unavailable
    Verify that gNB sends NGAP: UPLINK NAS TRANSPORT to AMF2

    Expect that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-1
    Expect that AMF2 starts PDU Session Modification procedure without UEContextModification
    Trigger UE1 to send PDU Session Modification to start reselection triggerd by core- for PDU1
    Verify that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-1
    Verify that AMF2 starts PDU Session Modification procedure without UEContextModification

    Stop and verify 20MBps UL and DL traffic on UE1 PDU1 QFI1

    Wait until PM counters file is ready and saved
    Verify PM counters for 5GC initiated AMF reselection are incremented successfully: received:1, refused:0

    [Teardown]  Teardown test environment AI002-3


CB006999-A-I002-4-ASI_without_timer_received_before_5GCore_triggered_Downlink_NAS_Transport
    [Tags]    AI002-4
    [Documentation]
    ...  DESCRIPTION:
    ...  == Info ==
    ...  This testcase shows gNB behavior when receiving NGAP: AMF STATUS INDICATION (with backup AMF set
    ...  and without timer approach) from AMF with attached UE, and Class 2 NGAP message (NGAP: DOWNLINK NAS
    ...  TRANSPORT) for UE from another AMF. gNB performs 5GCore-triggered reselection and AMF sending
    ...  Class 2 NGAP message is chosen for UE.
    ...  This testcase also shows that UE traffic is not impacted after AMF reselection triggered by Core Network.
    ...  == Precondition ==
    ...  - gNB is up and running
    ...  - NRBTS.actNgcFlexSaMode=true (5GC000740)
    ...  - NRBTS.amfPlannedRemovalTimer = 0
    ...  - NRBTS.actAmfPlannedRemoval=true
    ...  - Established NG connections AMF-gNB
    ...  - AMF-1 is configured with 2 GUAMIs (GUAMI1, GUAMI2)
    ...  - AMF-2 is configured with 1 GUAMI (GUAMI1)
    ...  - AMF-3 is configured with 1 GUAMI (GUAMI4)
    ...  - 3 AMFs up and running
    ...  - GUAMI1, GUAMI2, GUAMI3 and GUAMI4 have no backup AMF
    ...  == Flow ==
    ...  1.  Attach UE1 to AMF-1:GUAMI-1 and run traffic
    ...  2.  Send NGAP:AMF STATUS INDICATION from AMF1 with unavailableGuamiList:
    ...  3.  Trigger AMF2 to send Class 2 message (NGAP: DOWNLINK NAS TRANSPORT) for UE1 to gNB
    ...  4.  Verify that NGAP: DOWNLINK NAS TRANSPORT was sent from AMF2
    ...  5.  Trigger UE1 to send NR-RRC: UPLINK INFORMATION TRANSFER with PDU SESSION MODIFICATION REQUEST
    ...  6.  Verify that 5GCore reselection is made to AMF2 for UE1
    ...  7.  Verify that UE1 traffic is ongoing
    ...  8.  Verify that PM counters are incremented:
    ...  -   M55155C00007 (AMF_RESELECTION_5GC_RCV) = 1
    ...  -   M55155C00008 (AMF_RESELECTION_5GC_REF) = 0
    ...  == Postcondition ==
    ...  - UE1 is active
    ...  - Alarm with faultID=7325 is cleared
    ...  - All NGAP links gNB-AMF are in active state
    ...  == TESTING TOOLS ==
    ...  AirPhone, 5GCSim, UTE
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode
    ...  - HARDWARE ID: gNB(ABIO + ASIL) with simulated AEQE radio module - NR_BAND: n78
    ...  == REQUIREMENTS COVERAGE ==
    ...  -  CB006999-A-I002 AMF Status Indication handling is ongoing and interacting with incoming procedures (without timer)
    ...  == REQUIRED LOGS ==
    ...  NGAP
    ...  == AUTHOR ==
    ...  - Cezary Dudek <cezary.dudek@nokia.com>
    ...  == REFERENCES ==
    ...  - CB006999 CFAM
    ...  https://nokia.sharepoint.com/:f:/r/sites/ASCOP/AS%20Documents/FS1TAs-CFAMs/CB/CB006800%20-%20CB006999
    ...  /CFAM/CB006999%20gNB%20support%20for%20AMF%20Status%20Indication/CP2/CP2_Approved?csf=1&web=1
    ...  - L3 Testplan
    ...  https://nokia-my.sharepoint.com/:x:/r/personal/agnieszka_wlodarczyk_nokia_com/_layouts/15/
    ...  guestaccess.aspx?e=GxcEku&share=ESPUb8cGM2dMsgKohhtKI5gBg7y0YwPVpncWZIE9fxBKmg

    [Setup]  Prepare test environment AI002-4
    Attach UE4 to AMF1:GUAMI:1 and run traffic on PDU 4

    Send ASI from AMF1 with two GUAMI:1 backupAMF:3 timerApproach:off GUAMI:2 backupAMF:3 timerApproach:off
    Verify that alarm with NG AMF Status Indication fault and fault ID=7325 is raised for AMF1
    Verify SERVEDAMF-1:GUAMI_index-1 is correctly updated: backupAmfName=AMF3, guamiStatus=unavailable
    Verify SERVEDAMF-1:GUAMI_index-2 is correctly updated: backupAmfName=AMF3, guamiStatus=unavailable

    Send NGAP: DOWNLINK NAS TRANSPORT from AMF2 for UE4 to gNB
    Verify that NGAP: DOWNLINK NAS TRANSPORT is sent from AMF2 for UE4
    Verify that NGAP: UE CONTEXT MODIFICATION REQUEST is not sent from AMF2

    Expect that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-1
    Expect that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-3
    Expect that after PDU Session Modification Request from UE4 gNB performs AMF reselection and AMF2 is selected
    Trigger UE4 to send PDU Session Modification for PDU4
    Verify that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-1
    Verify that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-3
    Verify that after PDU Session Modification Request from UE4 gNB performs AMF reselection and AMF2 is selected

    Stop and verify 20MBps UL and DL traffic on UE4 PDU4 QFI1

    Wait until PM counters file is ready and saved
    Verify PM counters for 5GC initiated AMF reselection are incremented successfully: received:1, refused:0

    [Teardown]    Teardown test environment AI002-4


CB006999-A-I003-4-ASI_with_timer_received_before_5GCore_triggered_Downlink_NAS_Transport
    [Tags]    AI003-4    SKIPRUN
    [Documentation]
    ...  DESCRIPTION:
    ...  == Info ==
    ...  This test scenario describes the gNB behavior during receiving NGAP: DOWNLINK NAS TRANSPORT class 2 message
    ...  (without response) from new AMF after receiving NGAP: AMF STATUS INDICATION with timerApproachForGUAMIRemoval.
    ...  The gNB should perform reselection to new AMF which sent DL NGAP message
    ...  before expiration of amfPlannedRemovalTimer.
    ...  == Precondition ==
    ...  Real gNB up and running
    ...  NRBTS.actNgcFlexSaMode=true (5GC000740)
    ...  NRBTS.actAmfPlannedRemoval=true
    ...  NRBTS.amfPlannedRemovalTimer=60
    ...  Established NG connections AMF-gNB
    ...  3 AMFs up and running
    ...  AMF1 is configured with 2 GUAMIs (GUAMI1, GUAMI2)
    ...  AMF2 is configured with GUAMI (GUAMI1)
    ...  AMF3 is configured with GUAMI (GUAMI4)
    ...  GUAMI1, GUAMI2, GUAMI3 and GUAMI4 have no backup AMFs
    ...  GUAMI1, GUAMI2, GUAMI3 and GUAMI4 have status set to AVAILABLE
    ...  SERVEDAMF-1.relativeAMFCapacity = 10
    ...  SERVEDAMF-2.relativeAMFCapacity = 1
    ...  SERVEDAMF-3.relativeAMFCapacity = 1
    ...  == Flow ==
    ...  1.	Attach UE1 to AMF1:GUAMI1.
    ...  2.	Verify that UE1 is attached to AMF1:GUAMI1.
    ...  3.	Connect PDU Session with one QoS Flow (non-GBR) for UE1.
    ...  4.	Run UL and DL traffic on UE1.
    ...  5.	Send NGAP: AMF STATUS INDICATION from AMF1 with unavailableGuamiList:
    ...  -	GUAMI1
    ...   -	timerApproachForGUAMIRemoval is present
    ...   -	backupAMFName is set to AMF3
    ...  -	GUAMI2:
    ...   - timerApproachForGUAMIRemoval is present
    ...   - backupAMFName is set to AMF3
    ...  6.	Verify that after NGAP:ASI reception all relevant AMF1 objects are correctly updated:
    ...  - SERVEDAMF-1.guAMI[1].guamiStatus is set to UNAVAILABLE
    ...  - SERVEDAMF-1.guAMI[2].guamiStatus is set to UNAVAILABLE
    ...  - SERVEDAMF-1.guAMI[1].backupAMF is set to AMF3
    ...  - SERVEDAMF-1.guAMI[2].backupAMF is set to AMF3
    ...  7.	Verify that alarm 7115 with faultID=7325 is active for AMF1.
    ...  8.	During timer running, trigger 5GCore to send Class 2 message NGAP: DOWNLINK NAS TRANSPORT from AMF2 for UE1.
    ...  9.	During timer running, trigger UE1 to send NR-RRC: UL INFORMATION TRANSFER with PDU Session Modification
    ...     Request.
    ...  10. Verify that 5GCore reselection is made for UE1 and AMF2 is selected (as AMF from which
    ...      gNB received NGAP: DOWNLINK NAS TRANSPORT) before timer expiration.
    ...  11. Verify that gNB stops sending NGAP messages to AMF1 related with UE1 before timer expiration.
    ...  12. Verify that UE1 traffic is not impacted during the whole procedure.
    ...  13. Verify that PM counters are incremented:
    ...  - M55155C00004 - AMF_RESELECTION_GNB_ATT = 0
    ...  - M55155C00005 - AMF_RESELECTION_GNB_FAIL = 0
    ...  - M55155C00006 - AMF_RESELECTION_GNB_SUCC = 0
    ...  - M55155C00007 - AMF_RESELECTION_5GC_RCV = 1
    ...  - M55155C00008 - AMF_RESELECTION_5GC_REF = 0
    ...  14. Teardown:
    ...  - Detach UE1
    ...  - SERVEDAMF-1.guAMI[1].guamiStatus = available
    ...  - SERVEDAMF-1.guAMI[2].guamiStatus = available
    ...  == Postcondition ==
    ...  - Alarm with faultID=7325 is cleared
    ...  - NGAP link gNB-AMF1 active
    ...  - NGAP link gNB-AMF2 active
    ...  - NGAP link gNB-AMF3 active
    ...  - UE1 is detached
    ...  SERVEDAMF-1.relativeAMFCapacity = 1
    ...  SERVEDAMF-2.relativeAMFCapacity = 1
    ...  SERVEDAMF-3.relativeAMFCapacity = 1
    ...  == TESTING TOOLS ==
    ...  AirPhone, EPCSIM, UTE
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode
    ...  - HARDWARE ID: gNB(ABIO + ASIL) with simulated AEQE radio module - NR_BAND: n78
    ...  == REQUIREMENTS COVERAGE ==
    ...  CB006999-A#US11
    ...  == REQUIRED LOGS ==
    ...  NGAP
    ...  NR-RRC
    ...  == AUTHOR ==
    ...  - Grzegorz Szymik <grzegorz.szymik@nokia.com>
    ...  == REFERENCES ==
    ...  CB006999-2771

    [Setup]  Prepare test environment AI003-4

    Attach UE1 to AMF1:GUAMI:1 and run traffic on PDU 1

    Send ASI from AMF1 with two GUAMI:1 backupAMF:3 timerApproach:on GUAMI:2 backupAMF:3 timerApproach:on
    Verify SERVEDAMF-1:GUAMI_index-1 is correctly updated: backupAmfName=AMF3, guamiStatus=unavailable
    Verify SERVEDAMF-1:GUAMI_index-2 is correctly updated: backupAmfName=AMF3, guamiStatus=unavailable

    Verify that alarm with NG AMF Status Indication fault and fault ID=7325 is raised for AMF1

    Send NGAP: DOWNLINK NAS TRANSPORT from AMF2 for UE1 to gNB
    Verify that NGAP: DOWNLINK NAS TRANSPORT is sent from AMF2 for UE1
    Verify that NGAP: UE CONTEXT MODIFICATION REQUEST is not sent from AMF2

    Expect that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-1
    Expect that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-3
    Expect that after PDU Session Modification Request from UE1 gNB performs AMF reselection and AMF2 is selected
    Trigger UE1 to send PDU Session Modification for PDU1
    Verify that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-1
    Verify that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-3
    Verify that after PDU Session Modification Request from UE1 gNB performs AMF reselection and AMF2 is selected

    Expect that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-3
    Wait until amfPlannedRemovalTimer expiration
    Verify that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-3

    Stop and verify 20MBps UL and DL traffic on UE1 PDU1 QFI1

    Wait until PM counters file is ready and saved
    Verify PM counters for 5GC initiated AMF reselection are incremented successfully: received:1, refused:0
    Verify PM counters for gNB initiated AMF reselection are incremented successfully: attempts:0, fails:0, successes:0

    [Teardown]  Teardown test environment AI003-4


CB006999-A-I002-5-ASI_without_timer_received_before_UE_become_IDLE-UE_Context_Release_with_backup_AMF
    [Tags]    AI002-5    SKIPRUN
    [Documentation]
    ...  DESCRIPTION:
    ...  == Info ==
    ...  This test scenario describes the gNB behavior when NGAP:ASI with backup AMF set
    ...  (without timerApproachForGUAMIRemoval) is send and UE becomes inactive. During UE state transition
    ...  from CONNECTED to IDLE reselection occurs and backup AMF is selected.
    ...
    ...  == Precondition ==
    ...  - gNB up and running
    ...  - NRBTS.actNgcFlexSaMode=true (5GC000740)
    ...  - NRBTS.actAmfPlannedRemoval=true
    ...  - NRBTS.amfPlannedRemovalTimer=0
    ...  -	NRBTS.drbInactivityTimerSA = 60
    ...  -	NRBTS.srbInactivityTimerSA = 60
    ...  - Established NG connections AMF-gNB
    ...  - AMF-1 is configured with 2 GUAMIs (GUAMI1, GUAMI2) - SERVEDAMF-1
    ...  - AMF-2 is configured with 1 GUAMI (GUAMI1) - SERVEDAMF-2
    ...  - AMF-3 is configured with 1 GUAMI (GUAMI4) - SERVEDAMF-3
    ...  - GUAMI1, GUAMI2, GUAMI3, GUAMI4 have no backup AMF
    ...  - 3 AMFs up and running
    ...  - SERVEDAMF-1.relativeAMFCapacity=10
    ...
    ...  == Flow ==
    ...  1.	Attach UE1 to AMF-1:GUAMI-1
    ...  2.	Verify that UE1 is connected to AMF1
    ...  3.	UE1 connects PDU Session
    ...  4.	Verify that PDU Session established successfully for UE1
    ...  5.	AMF1 sends NGAP: AMF STATUS INDICATION with UnavailableGUAMIList:
    ...  -	GUAMI1,
    ...  -	timerApproachForGUAMIRemoval is not present
    ...  -	backupAMFName = AMF2
    ...  -	GUAMI2,
    ...  -	timerApproachForGUAMIRemoval is not present
    ...  -	backupAMFName = AMF2
    ...  6.	Verify SERVEDAMF-1 object is correctly updated:
    ...  -	SERVEDAMF-1.guAMI[1].guamiStatus is set to UNAVAILABLE
    ...  -	SERVEDAMF-1.guAMI[1].backupAMF is set to AMF2
    ...  -	SERVEDAMF-2.guAMI[1].guamiStatus is set to UNAVAILABLE
    ...  -	SERVEDAMF-2.guAMI[1].backupAMF is set to AMF2
    ...  7.	Verify that alarm 7115 (fault ID 7325) is raised  for SERVEDAMF-1
    ...  8. Wait until UE1 goes to IDLE state
    ...  9.	Verify that gNB sends NGAP: UE CONTEXT RELEASE REQUEST to AMF2
    ...  10.Verify that AMF2 sends NGAP: UE CONTEXT RELEASE COMMAND to gNB
    ...  11.Verify that gNB sends NGAP: UE CONTEXT RELEASE COMPLETE to new AMF2
    ...  12.Verify that PM counters are incremented:
    ...  -  M55155C00004 (AMF_RESELECTION_GNB_ATT) = 1
    ...  -	M55155C00005 (AMF_RESELECTION_GNB_FAIL) = 0
    ...  -	M55155C00006 (AMF_RESELECTION_GNB_SUCC) = 1
    ...  == Postcondition ==
    ...  UE1 is in IDLE state
    ...  NGAP link gNB-AMF1 is active
    ...  NGAP link gNB-AMF2 is active
    ...  NGAP link gNB-AMF3 is active

    ...  == TESTING TOOLS ==
    ...  AirPhone, EPCSIM, UTE
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode
    ...  - HARDWARE ID: gNB(ABIO + ASIL) with simulated AEQE radio module - NR_BAND: n78
    ...  == REQUIREMENTS COVERAGE ==
    ...  CB006999-A-I002 AMF Status Indication handling is ongoing and interacting with incoming procedures (without timer)
    ...  US#1: AMF Status Indication handling is ongoing and interacting with incoming procedures (without timer)
    ...
    ...  == REQUIRED LOGS ==
    ...  NGAP
    ...  == AUTHOR ==
    ...  - Gabriela Stasiuk <gabriela.stasiuk@nokia.com>
    ...  == REFERENCES ==
    ...  CFAM_CB006999

    [Setup]  Prepare test environment AI002-5

    Attach UE1 to AMF1:GUAMI:1 without starting traffic
    Send ASI from AMF1 with two GUAMI:1 backupAMF:2 timerApproach:off GUAMI:2 backupAMF:2 timerApproach:off
    Verify that alarm with NG AMF Status Indication fault and fault ID=7325 is raised for AMF1
    Verify SERVEDAMF-1:GUAMI_index-1 is correctly updated: backupAmfName=AMF2, guamiStatus=unavailable
    Verify SERVEDAMF-1:GUAMI_index-2 is correctly updated: backupAmfName=AMF2, guamiStatus=unavailable

    Expect that UEContextRelease procedure is made with AMF2 for UE1
    Verify that UEContextRelease procedure is made with AMF2 for UE1

    Wait until PM counters file is ready and saved
    Verify PM counters for gNB initiated AMF reselection are incremented successfully: attempts:1, fails:0, successes:1

    [Teardown]  Teardown test environment AI002-5

CB006999-A-I003-3-Core_Network_triggered_AMF_reselection-gNB_receives_PDUSessionResourceModifyRequest_from_new_AMF-ASI_with_timer
    [Tags]    AI003-3    SKIPRUN
    [Documentation]
    ...  DESCRIPTION:
    ...  == Info ==
    ...   This test scenario describes the gNB behavior when ASI with timerApproachForGUAMIRemoval set is send
    ...   and AMF reselection is triggered by Core Network. Reselection to AMF indicated in NGAP: PDU SESSION
    ...   RESOURCE MODIFY REQUEST (triggerd by other AMF- in this case AMF2) is made before expiration
    ...   of amfPlannedRemovalTimer.
    ...
    ...  == Precondition ==
    ...  - gNB up and running
    ...  - NRBTS.actNgcFlexSaMode=true (5GC000740)
    ...  - NRBTS.actAmfPlannedRemoval=true
    ...  - NRBTS.amfPlannedRemovalTimer=50
    ...  - Established NG connections AMF-gNB
    ...  - AMF-1 is configured with 2 GUAMIs (GUAMI1, GUAMI2) – SERVEDAMF-1
    ...  - AMF-2 is configured with 1 GUAMI (GUAMI1) – SERVEDAMF-2
    ...  - AMF-3 is configured with 1 GUAMI (GUAMI4) – SERVEDAMF-3
    ...  - AMF-1 (GUAMI1, GUAMI2)  have backup: AMF2 and AMF3
    ...  - AMF-2 (GUAMI1), AMF-3 (GUAMI4) have no backup AMF
    ...  - 3 AMFs up and running
    ...  - SERVEDAMF-1.relativeAMFCapacity=10
    ...
    ...  == Flow ==
    ...  1.	Attach UE1 to AMF-1:GUAMI-1
    ...  2.	Verify that UE1 is connected to AMF1
    ...  3.	UE1 connects PDU Session
    ...  4.	Verify that PDU Session established successfully for UE1
    ...  5.	Run UL and DL traffic on UE1
    ...  6.	AMF1 sends NGAP: AMF STATUS INDICATION with UnavailableGUAMIList:
    ...  -	GUAMI1,
    ...  -	timerApproachForGUAMIRemoval = apply timer
    ...  -	backupAMFName is not present
    ...  -	GUAMI2,
    ...  -	timerApproachForGUAMIRemoval = apply timer
    ...  -	backupAMFName is not present
    ...  7.	Verify SERVEDAMF-1 object is correctly updated:
    ...  -	SERVEDAMF-1.guAMI[1].guamiStatus is set to UNAVAILABLE
    ...  -	SERVEDAMF-1.guAMI[1].backupAMF is not updated
    ...  -	SERVEDAMF-2.guAMI[1].guamiStatus is set to UNAVAILABLE
    ...  -	SERVEDAMF-2.guAMI[1].backupAMF is not updated
    ...  8. Verify that alarm 7115 (fault ID 7325) is raised  for SERVEDAMF-1
    ...  9. Verify that gNB stops sending NGAP messages to SERVEDAMF-1
    ...  10.Verify that gNB sends NGAP: UPLINK NAS TRANSPORT to AMF-2
    ...  11.During amfPlannedRemovalTimer timer trigger AMF2 to send NGAP: PDU SESSION RESOURCE MODIFY REQUEST for UE1 to gNB
    ...  12.Verify that 5GCore reselection is made to AMF-2 for UE1
    ...  13.Verify that gNB sends NGAP: PDU SESSION RESOURCE MODIFY RESPONSE to AMF2
    ...  14.Verify that PM counters are incremented:
    ...  -  M55155C00007 (AMF_RESELECTION_5GC_RCV) = 1
    ...  -	M55155C00008 (AMF_RESELECTION_5GC_REF) = 0
    ...  == Postcondition ==
    ...  UE1 is active
    ...  UE1 data traffic is not impacted
    ...  NGAP link gNB-AMF1 is active
    ...  NGAP link gNB-AMF2 is active
    ...  NGAP link gNB-AMF3 is active

    ...  == TESTING TOOLS ==
    ...  AirPhone, EPCSIM, UTE
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode
    ...  - HARDWARE ID: gNB(ABIO + ASIL) with simulated AEQE radio module - NR_BAND: n78
    ...  == REQUIREMENTS COVERAGE ==
    ...  CB006999-A-I003 AMF Status Indication handling is ongoing and interacting with incoming procedures (with timer running)
    ...  US#1: AMF Status Indication handling is ongoing and interacting with incoming procedures (with timer running)
    ...
    ...  == REQUIRED LOGS ==
    ...  NGAP
    ...  == AUTHOR ==
    ...  - Gabriela Stasiuk <gabriela.stasiuk@nokia.com>
    ...  == REFERENCES ==
    ...  CFAM_CB006999

    [Setup]  Prepare test environment AI003-3

    Attach UE1 to AMF1:GUAMI:1 and run traffic on PDU 1
    Set target GUAMI to GUAMI1 for relocation to other AMF after PDU Session Modification

    Expect that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-1
    Expect that gNB sends NGAP: UPLINK NAS TRANSPORT to AMF2
    Send ASI from AMF1 with two GUAMI:1 backupAMF:None timerApproach:on GUAMI:2 backupAMF:None timerApproach:on
    Verify that alarm with NG AMF Status Indication fault and fault ID=7325 is raised for AMF1
    Verify SERVEDAMF-1:GUAMI_index-1 is correctly updated: backupAmfName=None, guamiStatus=unavailable
    Verify SERVEDAMF-1:GUAMI_index-2 is correctly updated: backupAmfName=None, guamiStatus=unavailable
    Verify that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-1
    Verify that gNB sends NGAP: UPLINK NAS TRANSPORT to AMF2

    Expect that AMF2 starts PDU Session Modification procedure without UEContextModification
    Trigger UE1 to send PDU Session Modification to start reselection triggerd by core- for PDU1
    Verify that AMF2 starts PDU Session Modification procedure without UEContextModification

    Wait until amfPlannedRemovalTimer expiration
    Stop and verify 20MBps UL and DL traffic on UE1 PDU1 QFI1

    Wait until PM counters file is ready and saved
    Verify PM counters for 5GC initiated AMF reselection are incremented successfully: received:1, refused:0

    [Teardown]  Teardown test environment AI003-3


CB006999-A-I003-5-ASI_with_timer_before_UE_become_IDLE-UE_Context_Release_with_source_AMF_triggered_before_timer_expires
    [Tags]    AI003-5
    [Documentation]
    ...  DESCRIPTION:
    ...  == Info ==
    ...  This test scenario describes the gNB behavior when NGAP:ASI with backup AMF set
    ...  (with timerApproachForGUAMIRemoval) is send and UE becomes inactive. Next incoming procedure (UE CONTEXT
    ...  RELEASE procedure) is performed with source AMF before timerApproachForGUAMIRemoval expires.
    ...
    ...  == Precondition ==
    ...  - gNB up and running
    ...  - NRBTS.actNgcFlexSaMode=true (5GC000740)
    ...  - NRBTS.actAmfPlannedRemoval=true
    ...  - NRBTS.amfPlannedRemovalTimer>0
    ...  - NRBTS.drbInactivityTimerSA < NRBTS.amfPlannedRemovalTimer
    ...  - NRBTS.drbInactivityTimerSA == NRBTS.srbInactivityTimerSA
    ...  - Established NG connections AMF-gNB
    ...  - AMF-1 is configured with 2 GUAMIs (GUAMI1, GUAMI2) - SERVEDAMF-1
    ...  - AMF-2 is configured with 1 GUAMI (GUAMI1) - SERVEDAMF-2
    ...  - AMF-3 is configured with 1 GUAMI (GUAMI4) - SERVEDAMF-3
    ...  - GUAMI1, GUAMI2, GUAMI3, GUAMI4 have no backup AMF
    ...  - 3 AMFs up and running
    ...  - SERVEDAMF-1.relativeAMFCapacity=10
    ...
    ...  == Flow ==
    ...  1.	Attach UE1 to AMF-1:GUAMI-1
    ...  2.	Verify that UE1 is connected to AMF1
    ...  3.	UE1 connects PDU Session
    ...  4.	Verify that PDU Session established successfully for UE1
    ...  4.a drbInactivityTimerSA  is starting
    ...  5.	AMF1 sends NGAP: AMF STATUS INDICATION with UnavailableGUAMIList:
    ...  -	GUAMI1,
    ...  -	timerApproachForGUAMIRemoval = apply timer
    ...  -	backupAMFName = AMF2
    ...  -	GUAMI2,
    ...  -	timerApproachForGUAMIRemoval = apply timer
    ...  -	backupAMFName = AMF2
    ...  6.	Verify SERVEDAMF-1 object is correctly updated:
    ...  -	SERVEDAMF-1.guAMI[1].guamiStatus is set to UNAVAILABLE
    ...  -	SERVEDAMF-1.guAMI[1].backupAMF is set to AMF2
    ...  -	SERVEDAMF-2.guAMI[1].guamiStatus is set to UNAVAILABLE
    ...  -	SERVEDAMF-2.guAMI[1].backupAMF is set to AMF2
    ...  7.	Verify that alarm 7115 (fault ID 7325) is raised  for SERVEDAMF-1
    ...  8. During amfPlannedRemovalTimer timer running wait until UE1 goes to IDLE state
    ...  9. Verify that gNB sends NGAP: UE CONTEXT RELEASE REQUEST to source AMF1
    ...  10.Verify that AMF1 sends NGAP: UE CONTEXT RELEASE COMMAND to gNB
    ...  11.Verify that gNB sends NGAP: UE CONTEXT RELEASE RESPONSE to source AMF1
    ...  12.Wait until amfPlannedRemovalTimer expires
    ...  13.Verify that PM counters are incremented:
    ...  -  M55155C00004 (AMF_RESELECTION_GNB_ATT) = 0
    ...  -  M55155C00005 (AMF_RESELECTION_GNB_FAIL) = 0
    ...  -  M55155C00006 (AMF_RESELECTION_GNB_SUCC) = 0

    ...  == Postcondition ==
    ...  UE1 is in IDLE state
    ...  NGAP link gNB-AMF1 is active
    ...  NGAP link gNB-AMF2 is active
    ...  NGAP link gNB-AMF3 is active

    ...  == TESTING TOOLS ==
    ...  AirPhone, EPCSIM, UTE
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode
    ...  - HARDWARE ID: gNB(ABIO + ASIL) with simulated AEQE radio module - NR_BAND: n78
    ...  == REQUIREMENTS COVERAGE ==
    ...  CB006999-A-I003 AMF Status Indication handling is ongoing and interacting with incoming procedures (with timer running)
    ...  US#1: AMF Status Indication handling is ongoing and interacting with incoming procedures (with timer running)
    ...
    ...  == REQUIRED LOGS ==
    ...  NGAP
    ...  == AUTHOR ==
    ...  - Gabriela Stasiuk <gabriela.stasiuk@nokia.com>
    ...  == REFERENCES ==
    ...  CFAM_CB006999

    [Setup]  Prepare test environment AI003-5

    Attach UE1 to AMF1:GUAMI:1 without starting traffic
    Send ASI from AMF1 with two GUAMI:1 backupAMF:2 timerApproach:on GUAMI:2 backupAMF:2 timerApproach:on
    Verify that alarm with NG AMF Status Indication fault and fault ID=7325 is raised for AMF1
    Expect that UEContextRelease procedure is made with AMF1 for UE1
    Verify SERVEDAMF-1:GUAMI_index-1 is correctly updated: backupAmfName=AMF2, guamiStatus=unavailable
    Verify SERVEDAMF-1:GUAMI_index-2 is correctly updated: backupAmfName=AMF2, guamiStatus=unavailable

    Verify that UEContextRelease procedure is made with AMF1 for UE1
    Wait until amfPlannedRemovalTimer expiration

    Wait until PM counters file is ready and saved
    Verify PM counters for gNB initiated AMF reselection are incremented successfully: attempts:0, fails:0, successes:0

    [Teardown]  Teardown test environment AI003-5
