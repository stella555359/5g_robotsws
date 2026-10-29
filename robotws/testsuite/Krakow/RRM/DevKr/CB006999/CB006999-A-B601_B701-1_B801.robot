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
CB006999-A-B601-1-ASI_received_without_timer_approach_and_with_partial_backupAMF
    [Tags]    AB601-1
    [Documentation]
    ...  DESCRIPTION:
    ...  == Info ==
    ...  Test shows thatAMF is reselected after NGAP: AMF Status Indication without timer approach and without backupAMF,
    ...  just after UE sends RRC: UL INFORMATION TRANSFER TRANSFER (UE traffic is not impacted)
    ...  AMF can be selected if it is indicated as backupAMF, even though it has relativeAMFCapacity set to 0
    ...  == Precondition ==
    ...  - Real gNB up and running
    ...  - NRBTS.actNgcFlexSaMode=true (5GC000740)
    ...  - NRBTS.actAmfPlannedRemoval=true
    ...  - NRBTS.amfPlannedRemovalTimer is set to 0
    ...  - Established NG connections AMF-gNB
    ...  - AMF-1 is configured with 2 GUAMIs (GUAMI1, GUAMI2)
    ...  - AMF-2 is configured with 1 GUAMI (GUAMI3)
    ...  - AMF-3 is configured with 1 GUAMI (GUAMI4)
    ...  - 3 AMFs up and running
    ...  - GUAMIs of AMF-1 have backup AMF set to AMF-2 and AMF-3
    ...  - GUAMIs of AMF-2 and AMF-3 have no backup AMF
    ...  - SERVEDAMF-2.relativeAMFCapacity = 0
    ...  - SERVEDAMF-3.relativeAMFCapacity > 0
    ...  == Flow ==
    ...  1. Attach UE1 to gNB (AMF1, GUAMI1)
    ...  2. Attach UE2 to gNB (AMF1, GUAMI2)
    ...  3. Connect PDU Session with one QoS Flow (non-GBR) for both UEs
    ...  4. Run UL and DL traffic on UE1 and UE2
    ...  5. Send NGAP: AMF STATUS INDICATION from AMF1 with partial backupAMF
    ...  6. Trigger UE1 to send NR-RRC: UL INFORMATION TRANSFER (with PDU Session Modification Request)
    ...  7. gNB performs AMF reselection for UE1 - gNB sends NGAP: UL NAS TRANSPORT to new AMF2
    ...     (relative capacity 0 on backup AMF does not prevent backup AMF selection)
    ...  8. Trigger UE2 to send NR-RRC: UL INFORMATION TRANSFER (with PDU Session Modification Request)
    ...  9. gNB performs AMF reselection for UE2 - gNB sends NGAP: UL NAS TRANSPORT to new AMF3
    ...     (load balancing, AMF3 is the last active AMF with relative capacity > 0)
    ...  == Postcondition ==
    ...  - Alarm with faultID=7325 is cleared
    ...  - NGAP links are in active state
    ...  - Traffic on both UEs not impacted
    ...  == TESTING TOOLS ==
    ...  AirPhone, EPCSIM, UTE
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode
    ...  - HARDWARE ID: gNB(ASIL + ABIO)
    ...  == REQUIREMENTS COVERAGE ==
    ...  CB006999-A#US06, 5G_RAN_USR_RRM_6826
    ...  == REQUIRED LOGS ==
    ...  NGAP
    ...  == AUTHOR ==
    ...  - Marek Kieltyka <marek.kieltyka@nokia.com>
    ...  == REFERENCES ==
    ...  CB006999-2767

    [Setup]  Prepare test environment AB601-1
    Attach UE1 to AMF1:GUAMI:1 and run traffic on PDU 1
    Attach UE2 to AMF1:GUAMI:2 and run traffic on PDU 2
    Send ASI from AMF1 with two GUAMI:1 backupAMF:2 timerApproach:off GUAMI:2 backupAMF:None timerApproach:off
    Verify that alarm with NG AMF Status Indication fault and fault ID=7325 is raised for AMF1
    Verify SERVEDAMF-1:GUAMI_index-1 is correctly updated: backupAmfName=AMF2, guamiStatus=unavailable
    Verify SERVEDAMF-1:GUAMI_index-2 is correctly updated: backupAmfName=None, guamiStatus=unavailable

    Expect that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-1
    Expect that after PDU Session Modification Request from UE1 gNB performs AMF reselection and AMF2 is selected
    Trigger UE1 to send PDU Session Modification for PDU1
    Verify that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-1
    Verify that after PDU Session Modification Request from UE1 gNB performs AMF reselection and AMF2 is selected

    Expect that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-1
    Expect that after PDU Session Modification Request from UE2 gNB performs AMF reselection and AMF3 is selected
    Trigger UE2 to send PDU Session Modification for PDU2
    Verify that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-1
    Verify that after PDU Session Modification Request from UE2 gNB performs AMF reselection and AMF3 is selected

    Stop and verify 20MBps UL and DL traffic on UE1 PDU1 QFI1
    Stop and verify 20MBps UL and DL traffic on UE2 PDU2 QFI1

    Wait until PM counters file is ready and saved
    Verify PM counters for gNB initiated AMF reselection are incremented successfully: attempts:2, fails:0, successes:2
    [Teardown]  Teardown test environment AB601-1

CB006999-A-B701-1-ASI_send_from_last_active_AMF_failure
    [Tags]    AB701-1
    [Documentation]
    ...  DESCRIPTION:
    ...  == Info ==
    ...  This test scenario describes the gNB behavior when last AMF sends NGAP : AMF Status Indication with GUAMIs
    ...  without timerApproachForGUAMIRemoval set and without backup AMFs. NG links towards  AMF2 and AMF3 are locked.
    ...  The scenario shows that gNB does not perform reselection and UE is released on first NGAP UL message sent.
    ...  == Precondition ==
    ...  Real gNB up and running
    ...  NRBTS.actNgcFlexSaMode=true (5GC000740)
    ...  NRBTS.actAmfPlannedRemoval=true
    ...  NRBTS.amfPlannedRemovalTimer=0
    ...  Established NG connection AMF1-gNB
    ...  NG links towards AMF2 and AMF3 are locked
    ...  3 AMFs up and running
    ...  AMF1 is configured with 2 GUAMIs (GUAMI1, GUAMI2)
    ...  AMF2 is configured with 1 GUAMI (GUAMI3)
    ...  AMF3 is configured with 1 GUAMI (GUAMI4)
    ...  GUAMI1, GUAMI2, GUAMI3 and GUAMI4 have no backup AMFs
    ...  == Flow ==
    ...  1. Attach UE1 to AMF1:GUAMI1.
    ...  2. Verify that UE1 is attached to AMF1:GUAMI1.
    ...  3. Connect PDU Session with one QoS Flow (non-GBR) for UE1.
    ...  4. Run UL and DL traffic on UE1.
    ...  5. Send NGAP: AMF STATUS INDICATION from AMF1 with unavailableGuamiList:
    ...  - GUAMI1
    ...   - timerApproachForGUAMIRemoval is not present
    ...   - backupAMFName is not present
    ...  - GUAMI2:
    ...   - timerApproachForGUAMIRemoval is not present
    ...   - backupAMFName is not present
    ...  6. Verify that after NGAP:ASI reception all relevant AMF-1 objects are correctly updated:
    ...  - SERVEDAMF-1.guAMI[1].guamiStatus is set to UNAVAILABLE
    ...  - SERVEDAMF-1.guAMI[2].guamiStatus is set to UNAVAILABLE
    ...  7. Verify that alarm 7115 with faultID=7325 is active.
    ...  8.	Trigger UE1 to send NR-RRC: UL INFORMATION TRANSFER with PDU Session Modification Request.
    ...  9.	Verify that gNB fails to perform AMF reselection for UE1 as there are not available GUAMIs.
    ...  10. Verify that gNB stops sending NGAP messages to AMF1 related with UE1.
    ...  11. Verify that UE1 release is performed.
    ...  12. Verify that PM counters are incremented:
    ...  - M55155C00004 - AMF_RESELECTION_GNB_ATT = 1
    ...  - M55155C00005 - AMF_RESELECTION_GNB_FAIL = 1
    ...  - M55155C00006 - AMF_RESELECTION_GNB_SUCC = 0
    ...  13. Teardown:
    ...  - SERVEDAMF-1.guAMI[1].guamiStatus = available
    ...  - SERVEDAMF-1.guAMI[2].guamiStatus = available
    ...  - Unlock NGAP link to AMF2
    ...  - Unlock NGAP link to AMF3
    ...  - Detach UE1
    ...  == Postcondition ==
    ...  - Alarm with faultID=7325 is cleared
    ...  - NGAP link gNB-AMF1 active
    ...  - NGAP link gNB-AMF2 active
    ...  - UE1 is detached
    ...  == TESTING TOOLS ==
    ...  AirPhone, EPCSIM, UTE
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode
    ...  - HARDWARE ID: gNB(ASIL + ABIO)
    ...  == REQUIREMENTS COVERAGE ==
    ...  CB006999-A#US06
    ...  == REQUIRED LOGS ==
    ...  NGAP
    ...  == AUTHOR ==
    ...  - Grzegorz Szymik <grzegorz.szymik@nokia.com>
    ...  == REFERENCES ==
    ...  CB006999-2773

    [Setup]  Prepare test environment AB701-1

    Attach UE1 to AMF1:GUAMI:1 and run traffic on PDU 1

    Send ASI from AMF1 with two GUAMI:1 backupAMF:None timerApproach:off GUAMI:2 backupAMF:None timerApproach:off
    Verify that alarm with NG AMF Status Indication fault and fault ID=7325 is raised for AMF1
    Verify SERVEDAMF-1:GUAMI_index-1 is correctly updated: backupAmfName=None, guamiStatus=unavailable
    Verify SERVEDAMF-1:GUAMI_index-2 is correctly updated: backupAmfName=None, guamiStatus=unavailable

    Expect that gNB does not send NGAP: UPLINK NAS TRANSPORT to all AMFs
    Expect UE1 is released by gNB
    Trigger UE1 to send PDU Session Modification for PDU1
    Verify UE1 is released by gNB
    Verify that gNB does not send NGAP: UPLINK NAS TRANSPORT to all AMFs

    Wait until PM counters file is ready and saved
    Verify PM counters for gNB initiated AMF reselection are incremented successfully: attempts:1, fails:1, successes:0

    [Teardown]  Teardown test environment AB701-1

CB006999-A-B801-1-Error_Indication_send_after_invalid_ASI
    [Tags]    AB801-1    SKIPRUN
    [Documentation]
    ...  DESCRIPTION:
    ...  == Info ==
	...	This test scenario describes the gNB behavior when feature flag NRBTS.actAmfPlannedRemoval
	...	is activated and AMF sends two AMF STATUS INDICATION with wrong details
	...	(unknown GUAMI and with no mandatory UnavailableGUAMIList).No SERVEDAMF objects (SERVEDAMF-1.guAMI) are updated.
	...	Expected behavior is that AMF receives from gNB two times NGAP: ERROR INDICATION,
	...	one after each AMF STATUS INDICATION as a result of:
    ...  - not matching GUAMI (unknown ID)
	...  - no mandatory UnavailableGUAMIList.
    ...  == Precondition ==
    ...  - 3 AMFs up and running
    ...  - Established NG connections AMF-gNB
    ...  - AMF-1 is configured with 2 GUAMIs (GUAMI1, GUAMI2) - SERVEDAMF-1
    ...  - AMF-2 is configured with 2 GUAMIs (GUAMI3, GUAMI4) - SERVEDAMF-2
    ...  - AMF-3 is configured with 2 GUAMIs (GUAMI1, GUAMI2) - SERVEDAMF-3
    ...  - All GUAMIs have status set to AVAILABLE
    ...  - None of GUAMIs have backup AMF set
    ...  - NRBTS.actNgcFlexSaMode=true (5GC000740)
    ...  - NRBTS.actAmfPlannedRemoval=true
    ...  - NRBTS.AmfPlannedRemovaltimer=0
    ...  == Flow ==
    ...  1. Attach UE1 to (AMF-1, GUAMI1)
    ...  2. Connect UE1 PDU Session with QOS Flow
    ...  3. Run UL and DL traffic on UE1
    ...  4.	Verify that PDU Session established successfully
    ...  5.Run UL and DL traffic on UE1
    ...  6.	Verify that data traffic is ongoing
    ...  7.	AMF1 sends NGAP: AMF STATUS INDICATION with UnavailableGUAMIList:
    ...     -	GUAMI7, (unknown GUAMI)
    ...     -	timerApproachForGUAMIRemoval is not present
    ...     -	backupAMFName is not present
    ...  8.	Verify that gNB responds NGAP: ERROR INDICATION to AMF1 with cause="Message not compatible with receiver state"
    ...  9.	Verify that alarm 7115 (fault ID 7325) is raised for SERVEDAMF-1
    ...  10.AMF1 sends NGAP: AMF STATUS INDICATION with no mandatory UnavailableGUAMIList
    ...  11.Verify that gNB responds NGAP: ERROR INDICATION to AMF1 with cause="abstract-syntax-error-reject"
    ...  12.Verify that SERVEDAMF-1.guAMI[1].guamiStatus is set to AVAILABLE
    ...  13.Verify that SERVEDAMF-1.guAMI[2].guamiStatus is set to AVAILABLE
    ...  14.Verify that PM counters are incremented:
    ...     -	M55119C00021 (NG_CU_ERROR_IND_SENT)  = 2
    ...     -	M55155C00004 (AMF_RESELECTION_GNB_ATT) = 0
    ...     -	M55155C00005 (AMF_RESELECTION_GNB_FAIL) = 0
    ...     -	M55155C00006 (AMF_RESELECTION_GNB_SUCC) = 0
    ...  == Postcondition ==
    ...  - Alarm 7115 (fault ID 7325) is raised for SERVEDAMF-1
	...  - SERVEDAMF-1.guAMI[1].guamiStatus is set to AVAILABLE
	...  - SERVEDAMF-1.guAMI[2].guamiStatus is set to AVAILABLE
	...  - PM counter is incremented: M55119C00021
    ...  - UE1 in ACTIVE state
    ...  == TESTING TOOLS ==
    ...  AirPhone, 5GCSim, UTE
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode
    ...  - HARDWARE ID: gNB(ASIL + ABIO)
    ...  == REQUIREMENTS COVERAGE ==
    ...  USCB006999-A#O8
    ...  CB006999-A-B801 ERROR INDICATION send after invalid AMF Status Indication
	...  US#1: ERROR INDICATION send after invalid AMF Status Indication
	...  USCB006999-A#8: Feature Activated.  Logical Error in content of AMF STATUS INDICATION message
    ...  == REQUIRED LOGS ==
    ...  NGAP
    ...  == AUTHOR ==
    ...  - Gabriela Stasiuk <gabriela.stasiuk@nokia.com>
    ...  == REFERENCES ==
    ...  CFAM_CB006999

    [Setup]  Prepare test environment AB801-1
    Attach UE1 to AMF1:GUAMI:1 and run traffic on PDU 1

    Expect NGAP: ERROR INDICATION sent after ASI with cause=${cause_notCompatible}
    Expect UE1 is not released
    Send ASI from AMF1 with unknown GUAMI backupAMF:None timerApproach:off
    Verify gNB sends NGAP: ERROR INDICATION after ASI
    Verify that alarm with NG AMF Status Indication fault and fault ID=7325 is raised for AMF1
    Wait until alarm with fault ID=7325 disappears

    Expect NGAP: ERROR INDICATION sent after ASI with cause=${cause_abstract_sytax_err}
    Send ASI from AMF1 with missing UnavailableGUAMIList
    Verify gNB sends NGAP: ERROR INDICATION after ASI
    Verify that alarm with NG AMF Status Indication fault and fault ID=7325 is raised for AMF1

    Verify SERVEDAMF-1:GUAMI_index-1:guamiStatus is set to available
    Verify SERVEDAMF-1:GUAMI_index-2:guamiStatus is set to available
    Verify UE1 is not released

    Wait until PM counters file is ready and saved
    Verify PM counters for ErrorIndication are incremented successfully: count: 2
    Verify PM counters for gNB initiated AMF reselection are incremented successfully: attempts:0, fails:0, successes:0

    [Teardown]  Teardown test environment AB801-1
