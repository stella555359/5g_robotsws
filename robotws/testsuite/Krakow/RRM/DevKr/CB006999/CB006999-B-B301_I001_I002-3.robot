*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == INTRODUCTION ==
...      This feature introduces gNB support for planned AMF removal (maintenance, SW upgrades).
...      AMF may release (using NGAP UE TNLA BINDING RELEASE REQUEST) or rebind the NGAP UE-TNLA binding on per UE basis.
...
...      == TEST SET NAME ==
...      CB006999-B	UE TNLA BINDING RELEASE REQUEST handling
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
...         [21.04.2022] - Migrate to APoABIO

Resource    ./resources/CB006999.robot
Resource    ./resources/CB006999-B_setups_teardowns.robot

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
CB006999-B-B301-Error_Indication_send_after_receiving_invalid_TBR
    [Tags]    BB301
    [Documentation]
    ...  DESCRIPTION:
    ...  == Info ==
    ...  This test scenario describes the gNB behavior when feature flag actAmfPlannedRemoval is deactivated
    ...  and AMF sends NGAP: UE TLNA BINDING RELEASE REQUEST with wrong IDs combination.
    ...  Expected behavior is that AMF receives from gNB NGAP: ERROR INDICATION as result of not correct NGAP UE id mapping.
    ...  == Precondition ==
    ...  gNB up and running
    ...  NRBTS.actNgcFlexSaMode=true (5GC000740)
    ...  NRBTS.actAmfPlannedRemoval=false
    ...  Established NG connections AMF-gNB
    ...  AMF-1 is configured with 2 GUAMIs (GUAMI1, GUAMI2)
    ...  AMF-2 is configured with 1 GUAMI (GUAMI3)
    ...  AMF-3 is configured with 1 GUAMI (GUAMI4)
    ...  3 AMFs up and running
    ...  == Flow ==
    ...  1.	UE1-3 to AMF1
    ...  2.	Verify that UE1-3 is connected to AMF1
    ...  3.	UE1-3 connects PDU Session
    ...  4.	Verify that PDU Session established successfully
    ...  5.	Run UL and DL traffic on UE1-3
    ...  7.	AMF1 generates NGAP:UE TNLA BINDING RELEASE REQUEST with both invalid UE NGAP ID
    ...  8.	Verify that gNB sends NGAP: ERROR INDICATION with cause=unknown-local-UE-NGAP-ID to AMF1
    ...  9.	Verify that UE1 is in RRC CONNECTED state
    ...  10. AMF1 generates NGAP:UE TNLA BINDING RELEASE REQUEST with valid AMF UE NGAP ID and invalid RAN UE NGAP ID related to UE2
    ...  11. Verify that gNB sends NGAP: ERROR INDICATION with cause=unknown-local-UE-NGAP-ID to AMF1
    ...  12. AMF1 generates NGAP:UE TNLA BINDING RELEASE REQUEST with valid RAN UE NGAP ID and invalid AMF UE NGAP ID related to UE3
    ...  13. Verify that gNB sends NGAP: ERROR INDICATION with cause=inconsistent-remote-UE-NGAP-ID to AMF1
    ...  14. Verify that UE3 is released by gNB via RRC: RRC RELEASE
    ...  15. Verify that counter value for M55119C00021 NG_CU_ERROR_IND_SENT equals 3
    ...  == Postcondition ==
    ...  UE1 in active state
    ...  NGAP link gNB-AMF1 active
    ...  == TESTING TOOLS ==
    ...  AirPhone, EPCSIM, UTE
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode
    ...  - HARDWARE ID: gNB(ASIL + ABIO)
    ...  == REQUIREMENTS COVERAGE ==
    ...  USCB006999-B#3, 5G_RAN_USR_RRM_7003
    ...  == REQUIRED LOGS ==
    ...  NGAP
    ...  == AUTHOR ==
    ...  Marek Kieltyka <marek.kieltyka@nokia.com>
    ...  == REFERENCES ==
    ...  CB006999-2776
    ...  == HISTORY ==
    ...  [23.09.2021] - Created TC description and flow
    ...  [10.05.2022] - Remove RRC: RRC RELEASE verification for UE2

    [Setup]  Prepare test environment BB301
    Attach UE1 to AMF1:GUAMI:1 and run traffic on PDU 1
    Attach UE2 to AMF1:GUAMI:1 and run traffic on PDU 2
    Attach UE3 to AMF1:GUAMI:1 and run traffic on PDU 3
    Send UE TNLA BRR for UE1 from AMF1 with both invalid UE NGAP ID
    Send UE TNLA BRR for UE2 from AMF1 with valid AMF UE NGAP ID and invalid RAN UE NGAP ID
    Send UE TNLA BRR for UE3 from AMF1 with valid RAN UE NGAP ID and invalid AMF UE NGAP ID
    Stop and verify 20MBps UL and DL traffic on UE1 PDU1 QFI1
    Wait until PM counters file is ready and saved
    Verify PM counters for ErrorIndication are incremented successfully: count: 3
    [Teardown]  Teardown test environment BB301

CB006999-B-I001-1_TBR_with_UE_ongoing_procedure_send_2_times_from_the_same_old_AMF
    [Tags]    BI001-1    SKIPRUN
    [Documentation]
    ...  DESCRIPTION:
    ...  == Info ==
    ...  This testcase shows that gNB properly handle case where AMF duplicates NGAP: UETNLABindingReleaseRequest for the same UE instance.
    ...  == Precondition ==
    ...  gNB up and running
    ...  NRBTS.actNgcFlexSaMode=true (5GC000740)
    ...  NRBTS.actAmfPlannedRemoval=true
    ...  NRBTS.amfPlannedRemovalTimer = 80
    ...  Established NG connections AMF-gNB
    ...  AMF-1 is configured with 2 GUAMIs (GUAMI1, GUAMI2)
    ...  AMF-2 is configured with 2 GUAMIs (GUAMI3, GUAMI4)
    ...  AMF-3 is configured with 2 GUAMIs (GUAMI1, GUAMI2)
    ...  3 AMFs up and running
    ...  GUAMI1, GUAMI2 have backup AMF2 and AMF3
    ...  GUAMI3, GUAMI4 have no backup AMF
    ...  == Flow ==
    ...  1.	Attach UE1 to AMF1:GUAMI1 and set PDU session
    ...  2.	AMF1 generates NGAP:UE TNLA BINDING RELEASE REQUEST with both valid UE NGAP ID
    ...  3.	Send second NGAP:UE TNLA BINDING RELEASE REQUEST for UE1 from AMF1
    ...  4. Trigger UE1 to send NR-RRC: UL INFORMATION TRANSFER with PDU Session Modification Request
    ...  5. Verify that gNB performs AMF reselection for UE1 with AMF2 (as it is backupAMF)
    ...  6. Verify that gNB does not send NGAP: ERROR INDICATION
    ...  7. Verify that PM counters are incremented:
    ...  - M55155C00004 - AMF_RESELECTION_GNB_ATT = 1
    ...  - M55155C00005 - AMF_RESELECTION_GNB_FAIL = 0
    ...  - M55155C00006 - AMF_RESELECTION_GNB_SUCC = 1
    ...  == Postcondition ==
    ...  UE1 in active state
    ...  NGAP link gNB-AMF1 active
    ...  == TESTING TOOLS ==
    ...  AirPhone, EPCSIM, UTE
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode
    ...  - HARDWARE ID: gNB(ASIB + ABIO)
    ...  == REQUIREMENTS COVERAGE ==
    ...  == REQUIRED LOGS ==
    ...  NGAP
    ...  == AUTHOR ==
    ...  Konrad Krzyzak <konrad.krzyzak@nokia.com>
    ...  == REFERENCES ==
    ...      - CB006999 CFAM
    ...      https://nokia.sharepoint.com/:f:/r/sites/ASCOP/AS%20Documents/FS1TAs-CFAMs/CB/CB006800%20-%20CB006999/CFAM/
    ...      CB006999%20gNB%20support%20for%20AMF%20Status%20Indication/CP2/CP2_Approved?csf=1&web=1
    ...      - L3 Testplan
    ...      https://nokia-my.sharepoint.com/:x:/r/personal/agnieszka_wlodarczyk_nokia_com/_layouts/15/
    ...      guestaccess.aspx?e=GxcEku&share=ESPUb8cGM2dMsgKohhtKI5gBg7y0YwPVpncWZIE9fxBKmg
    ...  == HISTORY ==
    ...  [17.11.2021] - Created TC description and flow
    ...  [19.11.2021] - final implementation and review
    ...  [01.03.2022] - CRT optimization - coverage moved to CB006999-B-I001-2

    [Setup]  Prepare test environment BI001-1
    Attach UE1 to AMF1:GUAMI:1 and run traffic on PDU 1

    Expect gNB does not send NGAP: ERROR INDICATION after TBRR to AMF1
    Send UE TNLA BRR for UE1 from AMF1 with both valid UE NGAP ID
    Verify gNB does not send NGAP: ERROR INDICATION to AMF1

    Expect gNB does not send NGAP: ERROR INDICATION after TBRR to AMF1
    Send UE TNLA BRR for UE1 from AMF1 with both valid UE NGAP ID
    Verify gNB does not send NGAP: ERROR INDICATION to AMF1

    Expect that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-1
    Expect that after PDU Session Modification Request from UE1 gNB performs AMF reselection and AMF2 is selected
    Expect no NGAP: ERROR INDICATION to AMF1
    Expect that AMF2 generates newGUAMI for UE
    Trigger UE1 to send PDU Session Modification for PDU1
    Verify that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-1
    Verify that after PDU Session Modification Request from UE1 gNB performs AMF reselection and AMF2 is selected
    Verify gNB does not send NGAP: ERROR INDICATION to AMF1
    Verify that AMF2 allocates newGUAMI

    Wait until PM counters file is ready and saved
    Verify PM counters for gNB initiated AMF reselection are incremented successfully: attempts:1, fails:0, successes:1

    [Teardown]  Teardown test environment BI001-1

CB006999-B-I001-2-TBR_with_UE_ongoing_procedure_send_during_PDU_Session_Setup
    [Tags]    BI001-2
    [Documentation]
    ...  DESCRIPTION:
    ...  == Info ==
    ...  This testcase shows that:
    ...  -	PDU Session Setup procedure is performed successfully using old AMF,
    ...  regardless of AMF sending NGAP: UETNLABindingReleaseRequest during PDU Session Setup procedure
    ...  -	reselection procedure is queued and executed after ongoing procedure ends
    ...  == Precondition ==
    ...  - gNB up and running
    ...  - NRBTS.actNgcFlexSaMode=true (5GC000740)
    ...  - NRBTS.actAmfPlannedRemoval=false
    ...  - NRBTS.timerRRCGuard = 2500 (ms)
    ...  - Established NG connections AMF1-gNB, AMF2-gNB, AMF3-gNB
    ...  - AMF-1 is configured with 2 GUAMIs (GUAMI1, GUAMI2)
    ...  - AMF-2 is configured with 1 GUAMI (GUAMI3)
    ...  - AMF-3 is configured with 1 GUAMI (GUAMI4)
    ...  - GUAMI1, GUAMI2 have backup AMF2 and AMF3
    ...  - GUAMI3, GUAMI4 have no backup AMF
    ...  == Flow ==
    ...  1.	Attach UE1 to AMF1:GUAMI:1 and run traffic on PDU 1
    ...  2.	Verify that first PDU session for UE1 is established (InitialContextSetup procedure is finished)
    ...  3.	Expect that UE1 ends second PDU session setup procedure with old AMF1 while AMF1 sent UE TNLA BRR
    ...  4.	Setup delay before sending NR-RRC: RRC Reconfiguration Complete from UE1
    ...     a. NR-RRC: RRC Reconfiguration Complete is sent 2s (less than NRBTS.timerRRCGuard) after NR-RRC: RRC Reconfiguration
    ...  5.	Connect UE-1 second PDU session with QOS Flow
    ...  6.	Send UE TNLA BRR for UE1 from AMF1 with both valid UE NGAP ID (NGAP: UETNLABindingReleaseRequest sent after
    ...     NGAP: PDUSessionResourceSetupRequest and before NGAP: PDUSessionResourceSetupResponse)
    ...  7.	Verify that UE1 ended second PDU session setup procedure with old AMF1 while AMF sent UE TNLA BRR
    ...  8.	Expect that after PDU Session Modification Request from UE1 gNB performs AMF reselection and AMF2 is selected
    ...  9.	Trigger UE1 to send PDU Session Modification for PDU1
    ...  10. Verify that after PDU Session Modification Request from UE1 gNB performs AMF reselection and AMF2 is selected
    ...  == Postcondition ==
    ...  - Traffic on UE is not impacted during AMFs reselection
    ...  - PM counters are incremented correctly
    ...  == TESTING TOOLS ==
    ...  AirPhone, EPCSIM, UTE
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode
    ...  - HARDWARE ID: gNB(ASIL + ABIO)
    ...  == REQUIREMENTS COVERAGE ==
    ...  5G_RAN_USR_RRM_6838
    ...  == REQUIRED LOGS ==
    ...  NGAP
    ...  == AUTHOR ==
    ...  Marek Kieltyka <marek.kieltyka@nokia.com>
    ...  == REFERENCES ==
    ...  CB006999-2779
    ...  == HISTORY ==
    ...  [01.03.2022] - Add part from BI001-1

    [Setup]  Prepare test environment BI001-2
    Attach UE1 to AMF1:GUAMI:1 and run traffic on PDU 1

    Expect that UE1 ends PDU session setup procedure with old AMF1 while AMF sent UE TNLA BRR
    Setup delay before sending NR-RRC: RRC Reconfiguration Complete from UE1
    Connect UE-1 PDU session 2 with QOS Flow  # second PDU session
    Send UE TNLA BRR for UE1 from AMF1 with both valid UE NGAP ID
    Verify that UE1 ended PDU session setup procedure with old AMF1 while AMF sent UE TNLA BRR

    #add coverage for BI001-1
    Expect gNB does not send NGAP: ERROR INDICATION after TBRR to AMF1
    Send UE TNLA BRR for UE1 from AMF1 with both valid UE NGAP ID
    Verify gNB does not send NGAP: ERROR INDICATION to AMF1

    Expect that after PDU Session Modification Request from UE1 gNB performs AMF reselection and AMF2 is selected
    Trigger UE1 to send PDU Session Modification for PDU1
    Verify that after PDU Session Modification Request from UE1 gNB performs AMF reselection and AMF2 is selected

    Stop and verify 20MBps UL and DL traffic on UE1 PDU1 QFI1
    Wait until PM counters file is ready and saved
    Verify PM counters for gNB initiated AMF reselection are incremented successfully: attempts:1, fails:0, successes:1
    [Teardown]  Teardown test environment BI001-2

CB006999-B-I002-3-TBR_ongoing_and_interacting_with_incoming_PDU_Session_Resource_Modify_Request_from_the_same_AMF
    [Tags]    BI002-3    SKIPRUN
    [Documentation]
    ...  DESCRIPTION:
    ...  == Info ==
    ...  This test scenario describes the gNB behavior during receiving two messages, one after another: NGAP: UE TNLA BINDING RELASE REQUEST
    ...  first and then NGAP: PDU SESSION RESOURCE MODIFY REQUEST from the same AMF. After that procedure gNB should response to 5GCore with
    ...  NGAP: PDU SESSION MODIFY RESPONSE and UE should use the same AMF back.
    ...  == Precondition ==
    ...  Real gNB up and running
    ...  NRBTS.actNgcFlexSaMode=true (5GC000740)
    ...  NRBTS.actAmfPlannedRemoval=true
    ...  Established NG connections AMF-gNB
    ...  3 AMFs up and running
    ...  AMF1 is configured with 2 GUAMIs (GUAMI1, GUAMI2)
    ...  AMF2 is configured with GUAMI (GUAMI3)
    ...  AMF3 is configured with GUAMI (GUAMI4)
    ...  GUAMI1, GUAMI2, GUAMI3 and GUAMI4 have no backup AMFs
    ...  GUAMI1, GUAMI2, GUAMI3 and GUAMI4 have status set to AVAILABLE
    ...  == Flow ==
    ...  1.	Attach UE1 to AMF1:GUAMI1.
    ...  3.	Verify that UE1 is attached to AMF1:GUAMI1.
    ...  5.	Connect PDU Session with one QoS Flow (non-GBR) for UE1.
    ...  7.	Run UL and DL traffic on UE1.
    ...  5.	Trigger AMF1 to send NGAP: UE TNLA Binding Release Request for UE1.
    ...  6.	Trigger AMF1 to send NGAP: PDU SESSION RESOURCE MODIFY REQUEST for UE1.
    ...  7.	Verify that gNB responds to AMF1 with NGAP: PDU SESSION RESOURCE MODIFY RESPONSE.
    ...  8.	Verify that UE1 uses the same AMF1.
    ...  9.	Verify that UE1 traffic is not impacted during the whole procedure.
    ...  10. Verify that PM counters are incremented:
    ...  - M55155C00004 - AMF_RESELECTION_GNB_ATT  = 1
    ...  - M55155C00005 - AMF_RESELECTION_GNB_FAIL = 0
    ...  - M55155C00006 - AMF_RESELECTION_GNB_SUCC = 1
    ...  - M55155C00007 - AMF_RESELECTION_5GC_RCV  = 0
    ...  - M55155C00008 - AMF_RESELECTION_5GC_REF  = 0
    ...  11. Teardown:
    ...  - Detach UE1
    ...  == Postcondition ==
    ...  - NGAP link gNB-AMF1 active
    ...  - NGAP link gNB-AMF2 active
    ...  - NGAP link gNB-AMF3 active
    ...  - UE1 is detached
    ...  == TESTING TOOLS ==
    ...  AirPhone, EPCSIM, UTE
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode
    ...  - HARDWARE ID: gNB(ABIL + ASIK) with simulated AEQA radio module - NR_BAND: n78
    ...  == REQUIREMENTS COVERAGE ==
    ...  CB006999-B#US33
    ...  == REQUIRED LOGS ==
    ...  NGAP
    ...  NR-RRC
    ...  == AUTHOR ==
    ...  - Grzegorz Szymik <grzegorz.szymik@nokia.com>
    ...  == REFERENCES ==
    ...  CB006999-2780

    [Setup]  Prepare test environment BI002-3

    Attach UE1 to AMF1:GUAMI:1 without starting traffic

    Send UE TNLA BRR for UE1 from AMF1 with both valid UE NGAP ID

    Expect that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-2
    Expect that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-3
    Expect that AMF1 starts PDU Session Modification procedure without UEContextModification
    Trigger UE1 to send PDU Session Modification to start reselection triggerd by core- for PDU1
    Verify that AMF1 starts PDU Session Modification procedure without UEContextModification
    Verify that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-2
    Verify that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-3

    Expect that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-2
    Expect that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-3
    Expect that after PDU Session Modification Request from UE1 gNB does not perform AMF reselection and AMF1 is selected
    Trigger UE1 to send PDU Session Modification for PDU1
    Verify that after PDU Session Modification Request from UE1 gNB does not perform AMF reselection and AMF1 is selected
    Verify that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-2
    Verify that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-3

    Wait until PM counters file is ready and saved
    Verify PM counters for gNB initiated AMF reselection are incremented successfully: attempts:1, fails:0, successes:1
    Verify PM counters for 5GC initiated AMF reselection are incremented successfully: received:0, refused:0

    [Teardown]  Teardown test environment BI002-3
