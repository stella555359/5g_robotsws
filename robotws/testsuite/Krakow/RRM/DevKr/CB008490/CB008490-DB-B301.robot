*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...
...      == INTRODUCTION ==
...      This sub-feature describes scenarios with sk-Counter incrementation and reset, unsuccesful PSCell Addition resulting in takeback.
...
...      == TEST SET NAME ==
...      CB008490-DB PSCell Addition (functionality requiring takeback)
...
...      == TESTING SPLIT ==
...      CB008490-DB#B101: sk-Counter incrementation and reset
...      CB008490-DB#B201: Unsuccessful inter-gNB NR-DC PSCell Addition in MN
...      CB008490-DB#B301: Unsuccessful inter-gNB NR-DC PSCell Addition in SN
...      CB008490-DB#B401: Concurrency handling in SN
...
...      == TESTING SCOPE ==
...      CB008490-DB#B201: Unsuccessful inter-gNB NR-DC PSCell Addition in MN
...      1. CB008490-SR-DB-B301_2 - Unsuccessful SNodeAddition after XnAP SNodeAdditionRequestAck was sent - incorrect XnUAddressIndication
...      2. CB008490-SR-DB-B301_3 - Unsuccessful SNodeAddition after XnAP SNodeAdditionRequestAck was sent - incorrect SNodeReconfigurationComplete
...      3. CB008490-SR-DB-B301_4 - Unsuccessful SNodeAddition after XnAP SNodeAdditionRequestAck was sent - incorrect SNStatusTransfer
...      4. CB008490-SR-DB-B301_5 - Unsuccessful SNodeAddition after XnAP SNodeAdditionRequestAck was sent - XnUAddressIndication not received
...      4. CB008490-SR-DB-B301_6 - Unsuccessful SNodeAddition after XnAP SNodeAdditionRequestAck was sent - SNStatusTransfer not received
...
...      == CONTACTS ==
...         - Malgorzata Konior     <malgorzata.konior@nokia.com>
...         - Tomasz Pyrek          <tomasz.pyrek@nokia.com>
...         - Maciej Madej          <maciej.madej@nokia.com>
...
...      == MAINTAINER ==
...         - Malgorzata Konior     <malgorzata.konior@nokia.com>
...         - Tomasz Pyrek          <tomasz.pyrek@nokia.com>
...         - Maciej Madej          <maciej.madej@nokia.com>
...
...      == REFERENCES ==
...         CB008490 CFAM
...
...      == HISTORY ==
...      [17.12.2024] - Create Test Suite
...      [26.11.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=922695)

Resource    resources/CB008490-common_keywords.robot
Resource    resources/CB008490_setup_and_teardowns.robot
Resource    resources/CB008490-flows_with_sim_gNB.robot

Force Tags    CONFIGURED    CRT    PY39    RAN_5G    RAN_5G_TDD    SBTS00
...    CLOUD_5G_I_LO_AP_LO
...    VARIANT_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup    Run setup    f1ap_gNBs=SN    sim_gNB=MN

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/egate_3c_n257_simMN.lua
${SCF_gnb3_SN}=           Krakow/CB008490/scf_D_B301_SN_1xAWEUB.xml
${AP_XML}=                Krakow/CB008490/iphy_3cells_n257_1xAWEUB_simMN.xml
${SKIP_COUNTERS}=         ${FALSE}

*** Test Cases ***
CB008490-SR-DB_B301_2_3_5_6
    [Tags]
    [Documentation]
    ...  == DESCRIPTION ==
    ...  Test scenario contains following test cases:
    ...    - CB008490-SR-DB-B301_2 - Unsuccessful SNodeAddition after XnAP SNodeAdditionRequestAck was sent - incorrect XnUAddressIndication
    ...         Test scenario verifies that SN gNB initiates takeback procedure after sending
    ...         XnAP: SNodeAdditionRequestAcknowledge and content of XnAP: XnUAddressIndication is incorrect.
    ...    - CB008490-SR-DB-B301_3 - Unsuccessful SNodeAddition after XnAP SNodeAdditionRequestAck was sent - incorrect SNodeReconfigurationComplete
    ...         Test scenario verifies that SN gNB initiates takeback procedure after sending
    ...         XnAP: SNodeAdditionRequestAcknowledge and content of XnAP: SNodeReconfigurationComplete is incorrect.
    ...    - CB008490-SR-DB-B301_4 - Unsuccessful SNodeAddition after XnAP SNodeAdditionRequestAck was sent - incorrect SNStatusTransfer
    ...         # not in regression
    ...         Test scenario verifies that SN gNB initiates takeback procedure after sending
    ...         XnAP: SNodeAdditionRequestAcknowledge and content of XnAP: SNStatusTransfer is incorrect.
    ...    - CB008490-SR-DB-B301_5 - Unsuccessful SNodeAddition after XnAP SNodeAdditionRequestAck was sent - XnUAddressIndication not received
    ...         Test scenario verifies that SN gNB initiates takeback procedure after sending
    ...         XnAP: SNodeAdditionRequestAcknowledge and timerXnDcOverall expires while waiting for XnUAddressIndication.
    ...    - CB008490-SR-DB-B301_6 - Unsuccessful SNodeAddition after XnAP SNodeAdditionRequestAck was sent - SNStatusTransfer not received
    ...         Test scenario verifies that SN gNB initiates takeback procedure after sending
    ...         XnAP: SNodeAdditionRequestAcknowledge and timerXnDcOverall expires while waiting for SNStatusTransfer.
    ...
    ...  == PRECONDITION ==
    ...    - CB008490-SR-DB-B301_2:
    ...      - UE1 and UE2 are connected to MN gNB and NR-DC A4 measurements are installed
    ...      - Airphone command executed to modify XnAP: XnUAddressIndication
    ...    - CB008490-SR-DB-B301_3:
    ...      - UE3 is connected to MN gNB and NR-DC A4 measurements are installed
    ...      - Airphone command executed to modify XnAP: SNodeReconfigurationComplete
    ...    - CB008490-SR-DB-B301_4:
    ...      - UE1 is connected to MN gNB and NR-DC A4 measurements are installed
    ...      - Airphone command executed to modify XnAP: SNStatusTransfer
    ...    - CB008490-SR-DB-B301_5:
    ...      - UE2 is connected to MN gNB and NR-DC A4 measurements are installed
    ...      - Airphone command executed to skip sending XnAP: XnUAddressIndication
    ...    - CB008490-SR-DB-B301_6:
    ...      - UE3 is connected to MN gNB and NR-DC A4 measurements are installed
    ...      - Airphone command executed to skip sending XnAP: SNStatusTransfer
    ...
    ...  == POSTCONDITION ==
    ...    - CB008490-SR-DB-B301_2:
    ...      - UE1 and UE2 are not configured with the NR-DC
    ...    - CB008490-SR-DB-B301_3:
    ...      - UE3 is not configured with the NR-DC
    ...    - CB008490-SR-DB-B301_4:
    ...      - UE1 is not configured with the NR-DC
    ...    - CB008490-SR-DB-B301_5:
    ...      - UE2 is not configured with the NR-DC
    ...    - CB008490-SR-DB-B301_6:
    ...      - UE3 is not configured with the NR-DC
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, 5GCSim, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode as SN
    ...  - simulated gNB as MN
    ...  - gNB module MN (ASIL + ABIO / ASIM + ABIP)
    ...  - UEs configured in SA, TDD
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_26069; 5G_RAN_USR_RRM_26074; 5G_RAN_USR_RRM_26521
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC,NGAP,F1AP,E1AP
    ...
    ...  == CONTACTS ==
    ...  - Tomasz Pyrek <tomasz.pyrek@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  Related CFAM US:
    ...  - US CB008490-DB#EC2: inter-gNB NR-DC PSCell Addition interrupted by the UE Release (AMF or gNB initiated) - main scenario
    ...  - US CB008490-DB#EC3: Unsuccessful inter-gNB NR-DC PSCell Addition on SN side due to problems after
    ...    XnAP: SNodeAdditionRequestAcknowledge was sent to MN - ALT1 - ALT4
    ...  - US CB008490-DB#EC5: Unsuccessful inter-gNB NR-DC PSCell Addition on SN side due to missing
    ...    XnAP: SNStatusTransfer after XnAP: SNodeAdditionRequestAcknowledge was sent to MN
    ...
    ...  == HISTORY ==
    ...  [17.12.2024] - Create Test Suite
    ...  [26.11.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=922695)

    [Setup]  Prepare test environment CB008490-DB-B301

#   CB008490-SR-DB-B301_2 - Unsuccessful SNodeAddition after XnAP SNodeAdditionRequestAck was sent - incorrect XnUAddressIndication
    Configure sim MN gNB2 to send XNAP:XnUAddressIndication without mandatory IE

    Attach UE1 and add initial PDU session to MN gNB NRCELL-1
    Set expected messages flows for SNodeAddition and takeback for SN gNB, B301_2
    UE1 sends A4 measurement with target cells [2] for NR-DC PSCell addition with sim MN
    Verify expected messages flows for SNodeAddition and takeback for SN gNB, B301_2
    Verify that XNAP SNodeReleaseRequired contains cause:radioNetwork:unspecified, gNB3

    Configure sim MN gNB2 to send XNAP:XnUAddressIndication with mandatory IE
    Configure sim MN gNB2 to send XNAP:XnUAddressIndication with additional DRB

    Attach UE2 and add initial PDU session to MN gNB NRCELL-1
    Set expected messages flows for SNodeAddition and takeback for SN gNB, B301_2
    UE2 sends A4 measurement with target cells [2] for NR-DC PSCell addition with sim MN
    Verify expected messages flows for SNodeAddition and takeback for SN gNB, B301_2
    Verify that XNAP SNodeReleaseRequired contains cause:radioNetwork:unspecified, gNB3

    Configure sim MN gNB2 to send XNAP:XnUAddressIndication without additional DRB

#   CB008490-SR-DB-B301_3 - Unsuccessful SNodeAddition after XnAP SNodeAdditionRequestAck was sent - incorrect SNodeReconfigurationComplete
    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm Before Test

    Configure sim MN gNB2 to send XNAP:SNodeReconfigurationComplete without Container IE

    Attach UE3 and add initial PDU session to MN gNB NRCELL-1
    Set expected messages flows for SNodeAddition and takeback for SN gNB, B301_3
    UE3 sends A4 measurement with target cells [2] for NR-DC PSCell addition with sim MN
    Verify expected messages flows for SNodeAddition and takeback for SN gNB, B301_3
    Verify that XNAP SNodeReleaseRequired contains cause:radioNetwork:unspecified, gNB3

    Configure sim MN gNB2 to send XNAP:SNodeReconfigurationComplete with Container IE
    Detach and kill UEs from 1 to 3

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm After Test

    Omit when SKIP_COUNTERS present
    ...  Run keywords
    ...  Check RTPM counter on bts_id=2: NRCELL-2 IE_NRDC_SN_SNODE_ADD_REQ (M55116C00039) is equal 1
    ...  Check RTPM counter on bts_id=2: NRCELL-2 IE_NRDC_SN_SNODE_ADD_ACK (M55116C00047) is equal 1
    ...  Check RTPM counter on bts_id=2: NRCELL-2 IE_NRDC_SN_SNODE_ADD_SUC (M55116C00053) is equal 0
    ...  Check RTPM counter on bts_id=2: NRCELL-2 IE_NRDC_SN_SNODE_RECNF_COMP (M55116C00051) is equal 0

##   CB008490-SR-DB-B301_4 - Unsuccessful SNodeAddition after XnAP SNodeAdditionRequestAck was sent - incorrect SNStatusTransfer
#    Configure sim MN gNB2 to send XNAP:SNStatusTransfer with abstract syntax error
#
#    Attach UE1 and add initial PDU session to MN gNB NRCELL-1
#    Set expected messages flows for SNodeAddition and takeback for SN gNB, B301_4
#    UE1 sends A4 measurement with target cells [2] for NR-DC PSCell addition with sim MN
#    Verify expected messages flows for SNodeAddition and takeback for SN gNB, B301_4
#    Verify that XNAP SNodeReleaseRequired contains cause:radioNetwork:unspecified, gNB3
#
#    Configure sim MN gNB2 to send XNAP:SNStatusTransfer without abstract syntax error

#   CB008490-SR-DB-B301_5 - Unsuccessful SNodeAddition after XnAP SNodeAdditionRequestAck was sent - XnUAddressIndication not received
    Configure sim MN gNB2 to not send XNAP:XnUAddressIndication

    Attach UE2 and add initial PDU session to MN gNB NRCELL-1
    Set expected messages flows for SNodeAddition and takeback for SN gNB, B301_5
    UE2 sends A4 measurement with target cells [2] for NR-DC PSCell addition with sim MN
    Verify expected messages flows for SNodeAddition and takeback for SN gNB, B301_5
    Verify that XNAP SNodeReleaseRequired contains cause:radioNetwork:unspecified, gNB3

    Configure sim MN gNB2 to send XNAP:XnUAddressIndication

#   CB008490-SR-DB-B301_6 - Unsuccessful SNodeAddition after XnAP SNodeAdditionRequestAck was sent - SNStatusTransfer not received
    Configure sim MN gNB2 to not send XNAP:SNStatusTransfer

    Attach UE3 and add initial PDU session to MN gNB NRCELL-1
    Set expected messages flows for SNodeAddition and takeback for SN gNB, B301_6
    UE3 sends A4 measurement with target cells [2] for NR-DC PSCell addition with sim MN
    Verify expected messages flows for SNodeAddition and takeback for SN gNB, B301_6
    Verify that XNAP SNodeReleaseRequired contains cause:radioNetwork:unspecified, gNB3

    Configure sim MN gNB2 to send XNAP:SNStatusTransfer

    [Teardown]  CB008490-DB-B301 cleanup


*** Keywords ***
Attach UE${ue_id:\d+} and add initial PDU session to MN gNB NRCELL-${cell_id:\d+}
    Attach UE${ue_id} without ICS to gNB2 cell${cell_id}
    Add to UE${ue_id} initial PDU session on sim gNB with ICS and indexToRFSP equal 1

Set expected messages flows for SNodeAddition and takeback for SN gNB, B301_2
    EXPECT FLOW[timeout=5]: gNB3 XNAP sNGRANnodeAdditionPreparation
    EXPECT FLOW[timeout=5]: gNB3 E1AP bearerContextSetup
    EXPECT FLOW[timeout=5]: gNB3 F1AP uEContextSetup
    EXPECT FLOW[timeout=5]: gNB3 XNAP xnUAddressIndication

    # SN initiated takeback
    EXPECT FLOW[timeout=5]: gNB3 XNAP sNGRANnodeinitiatedSNGRANnodeRelease
    EXPECT FLOW[timeout=5]: gNB3 E1AP bearerContextModification
    EXPECT FLOW[timeout=5]: gNB3 F1AP uEContextModification
    EXPECT FLOW[timeout=5]: gNB3 XNAP 2*sNStatusTransfer    # one from SNodeAdd, one from takeback

    EXPECT FLOW[timeout=5]: gNB3 XNAP uEContextRelease
    EXPECT FLOW[timeout=5]: gNB3 F1AP uEContextRelease
    EXPECT FLOW[timeout=5]: gNB3 E1AP bearerContextRelease

    # flows to fail
    EXPECT FLOW[timeout=5]: gNB3 E1AP bearerContextInactivityNotification
    EXPECT FLOW[timeout=5]: gNB3 NGAP uEContextRelease

Verify expected messages flows for SNodeAddition and takeback for SN gNB, B301_2
    PASS FLOW[timeout=5]: gNB3 XNAP sNGRANnodeAdditionPreparation
    PASS FLOW[timeout=5]: gNB3 E1AP bearerContextSetup
    PASS FLOW[timeout=5]: gNB3 F1AP uEContextSetup
    PASS FLOW[timeout=5]: gNB3 XNAP xnUAddressIndication

    PASS FLOW[timeout=5]: gNB3 XNAP sNGRANnodeinitiatedSNGRANnodeRelease
    PASS FLOW[timeout=5]: gNB3 E1AP bearerContextModification
    PASS FLOW[timeout=5]: gNB3 F1AP uEContextModification
    PASS FLOW[timeout=5]: gNB3 XNAP 2*sNStatusTransfer

    PASS FLOW[timeout=5]: gNB3 XNAP uEContextRelease
    PASS FLOW[timeout=5]: gNB3 F1AP uEContextRelease
    PASS FLOW[timeout=5]: gNB3 E1AP bearerContextRelease

    FAIL FLOW[timeout=5]: gNB3 E1AP bearerContextInactivityNotification
    FAIL FLOW[timeout=5]: gNB3 NGAP uEContextRelease

Set expected messages flows for SNodeAddition and takeback for SN gNB, B301_3
    EXPECT FLOW[timeout=5]: gNB3 XNAP sNGRANnodeAdditionPreparation
    EXPECT FLOW[timeout=5]: gNB3 E1AP bearerContextSetup
    EXPECT FLOW[timeout=5]: gNB3 F1AP uEContextSetup
    EXPECT FLOW[timeout=5]: gNB3 XNAP xnUAddressIndication
    EXPECT FLOW[timeout=5]: gNB3 XNAP sNGRANnodeReconfigurationCompletion
    EXPECT FLOW[timeout=5]: gNB3 E1AP bearerContextInactivityNotification

    # SN initiated takeback
    EXPECT FLOW[timeout=5]: gNB3 XNAP sNGRANnodeinitiatedSNGRANnodeRelease
    EXPECT FLOW[timeout=5]: gNB3 E1AP 3*bearerContextModification     # one from SNodeAdd, two from takeback
    EXPECT FLOW[timeout=5]: gNB3 F1AP uEContextModification
    EXPECT FLOW[timeout=5]: gNB3 XNAP 2*sNStatusTransfer    # one from SNodeAdd, one from takebacks

    EXPECT FLOW[timeout=5]: gNB3 XNAP uEContextRelease
    EXPECT FLOW[timeout=5]: gNB3 F1AP uEContextRelease
    EXPECT FLOW[timeout=5]: gNB3 E1AP bearerContextRelease

    EXPECT FLOW[timeout=5]: gNB3 NGAP uEContextRelease

Verify expected messages flows for SNodeAddition and takeback for SN gNB, B301_3
    PASS FLOW[timeout=5]: gNB3 XNAP sNGRANnodeAdditionPreparation
    PASS FLOW[timeout=5]: gNB3 E1AP bearerContextSetup
    PASS FLOW[timeout=5]: gNB3 F1AP uEContextSetup
    PASS FLOW[timeout=5]: gNB3 XNAP xnUAddressIndication
    PASS FLOW[timeout=5]: gNB3 XNAP sNGRANnodeReconfigurationCompletion
    PASS FLOW[timeout=5]: gNB3 E1AP bearerContextInactivityNotification

    # SN initiated takeback
    PASS FLOW[timeout=5]: gNB3 XNAP sNGRANnodeinitiatedSNGRANnodeRelease
    PASS FLOW[timeout=5]: gNB3 E1AP 3*bearerContextModification
    PASS FLOW[timeout=5]: gNB3 F1AP uEContextModification
    PASS FLOW[timeout=5]: gNB3 XNAP 2*sNStatusTransfer

    PASS FLOW[timeout=5]: gNB3 XNAP uEContextRelease
    PASS FLOW[timeout=5]: gNB3 F1AP uEContextRelease
    PASS FLOW[timeout=5]: gNB3 E1AP bearerContextRelease

    FAIL FLOW[timeout=5]: gNB3 NGAP uEContextRelease

Set expected messages flows for SNodeAddition and takeback for SN gNB, B301_4
    EXPECT FLOW[timeout=5]: gNB3 XNAP sNGRANnodeAdditionPreparation
    EXPECT FLOW[timeout=5]: gNB3 E1AP bearerContextSetup
    EXPECT FLOW[timeout=5]: gNB3 F1AP uEContextSetup
    EXPECT FLOW[timeout=5]: gNB3 XNAP xnUAddressIndication
    EXPECT FLOW[timeout=5]: gNB3 XNAP sNGRANnodeReconfigurationCompletion
    EXPECT FLOW[timeout=5]: gNB3 E1AP bearerContextInactivityNotification
    EXPECT FLOW[timeout=5]: gNB3 XNAP sNStatusTransfer

    # SN initiated takeback
    EXPECT FLOW[timeout=5]: gNB3 XNAP sNGRANnodeinitiatedSNGRANnodeRelease
    EXPECT FLOW[timeout=5]: gNB3 E1AP bearerContextModification
    EXPECT FLOW[timeout=5]: gNB3 F1AP uEContextModification

    EXPECT FLOW[timeout=5]: gNB3 XNAP uEContextRelease
    EXPECT FLOW[timeout=5]: gNB3 F1AP uEContextRelease
    EXPECT FLOW[timeout=5]: gNB3 E1AP bearerContextRelease

    EXPECT FLOW[timeout=5]: gNB3 NGAP uEContextRelease

Verify expected messages flows for SNodeAddition and takeback for SN gNB, B301_4
    PASS FLOW[timeout=5]: gNB3 XNAP sNGRANnodeAdditionPreparation
    PASS FLOW[timeout=5]: gNB3 E1AP bearerContextSetup
    PASS FLOW[timeout=5]: gNB3 F1AP uEContextSetup
    PASS FLOW[timeout=5]: gNB3 XNAP xnUAddressIndication
    PASS FLOW[timeout=5]: gNB3 XNAP sNGRANnodeReconfigurationCompletion
    PASS FLOW[timeout=5]: gNB3 E1AP bearerContextInactivityNotification
    PASS FLOW[timeout=5]: gNB3 XNAP sNStatusTransfer

    # SN initiated takeback
    PASS FLOW[timeout=5]: gNB3 XNAP sNGRANnodeinitiatedSNGRANnodeRelease
    PASS FLOW[timeout=5]: gNB3 E1AP bearerContextModification
    PASS FLOW[timeout=5]: gNB3 F1AP uEContextModification

    PASS FLOW[timeout=5]: gNB3 XNAP uEContextRelease
    PASS FLOW[timeout=5]: gNB3 F1AP uEContextRelease
    PASS FLOW[timeout=5]: gNB3 E1AP bearerContextRelease

    FAIL FLOW[timeout=5]: gNB3 NGAP uEContextRelease

Set expected messages flows for SNodeAddition and takeback for SN gNB, B301_5
    EXPECT FLOW[timeout=10]: gNB3 XNAP sNGRANnodeAdditionPreparation
    EXPECT FLOW[timeout=10]: gNB3 E1AP bearerContextSetup
    EXPECT FLOW[timeout=10]: gNB3 F1AP uEContextSetup
    EXPECT FLOW[timeout=10]: gNB3 XNAP xnUAddressIndication
    EXPECT FLOW[timeout=10]: gNB3 XNAP sNGRANnodeReconfigurationCompletion
    EXPECT FLOW[timeout=10]: gNB3 E1AP bearerContextInactivityNotification

    # SN initiated takeback
    EXPECT FLOW[timeout=10]: gNB3 XNAP sNGRANnodeinitiatedSNGRANnodeRelease
    EXPECT FLOW[timeout=10]: gNB3 E1AP 2*bearerContextModification     # two from takeback
    EXPECT FLOW[timeout=10]: gNB3 F1AP uEContextModification
    EXPECT FLOW[timeout=10]: gNB3 XNAP 2*sNStatusTransfer    # one from SNodeAdd, one from takebacks

    EXPECT FLOW[timeout=10]: gNB3 XNAP uEContextRelease
    EXPECT FLOW[timeout=10]: gNB3 F1AP uEContextRelease
    EXPECT FLOW[timeout=10]: gNB3 E1AP bearerContextRelease

    EXPECT FLOW[timeout=10]: gNB3 NGAP uEContextRelease

Verify expected messages flows for SNodeAddition and takeback for SN gNB, B301_5
    PASS FLOW[timeout=10]: gNB3 XNAP sNGRANnodeAdditionPreparation
    PASS FLOW[timeout=10]: gNB3 E1AP bearerContextSetup
    PASS FLOW[timeout=10]: gNB3 F1AP uEContextSetup
    FAIL FLOW[timeout=10]: gNB3 XNAP xnUAddressIndication
    PASS FLOW[timeout=10]: gNB3 XNAP sNGRANnodeReconfigurationCompletion
    PASS FLOW[timeout=10]: gNB3 E1AP bearerContextInactivityNotification

    # SN initiated takeback
    PASS FLOW[timeout=10]: gNB3 XNAP sNGRANnodeinitiatedSNGRANnodeRelease
    PASS FLOW[timeout=10]: gNB3 E1AP 2*bearerContextModification
    PASS FLOW[timeout=10]: gNB3 F1AP uEContextModification
    PASS FLOW[timeout=10]: gNB3 XNAP 2*sNStatusTransfer    # one from SNodeAdd, one from takeback

    PASS FLOW[timeout=10]: gNB3 XNAP uEContextRelease
    PASS FLOW[timeout=10]: gNB3 F1AP uEContextRelease
    PASS FLOW[timeout=10]: gNB3 E1AP bearerContextRelease

    FAIL FLOW[timeout=10]: gNB3 NGAP uEContextRelease

Set expected messages flows for SNodeAddition and takeback for SN gNB, B301_6
    EXPECT FLOW[timeout=10]: gNB3 XNAP sNGRANnodeAdditionPreparation
    EXPECT FLOW[timeout=10]: gNB3 E1AP bearerContextSetup
    EXPECT FLOW[timeout=10]: gNB3 F1AP uEContextSetup
    EXPECT FLOW[timeout=10]: gNB3 XNAP xnUAddressIndication
    EXPECT FLOW[timeout=10]: gNB3 XNAP sNGRANnodeReconfigurationCompletion
    EXPECT FLOW[timeout=10]: gNB3 E1AP bearerContextInactivityNotification

    # SN initiated takeback
    EXPECT FLOW[timeout=10]: gNB3 XNAP sNGRANnodeinitiatedSNGRANnodeRelease
    EXPECT FLOW[timeout=10]: gNB3 E1AP bearerContextModification
    EXPECT FLOW[timeout=10]: gNB3 F1AP uEContextModification
    EXPECT FLOW[timeout=10]: gNB3 XNAP sNStatusTransfer

    EXPECT FLOW[timeout=10]: gNB3 XNAP uEContextRelease
    EXPECT FLOW[timeout=10]: gNB3 F1AP uEContextRelease
    EXPECT FLOW[timeout=10]: gNB3 E1AP bearerContextRelease

    EXPECT FLOW[timeout=10]: gNB3 NGAP uEContextRelease

Verify expected messages flows for SNodeAddition and takeback for SN gNB, B301_6
    PASS FLOW[timeout=10]: gNB3 XNAP sNGRANnodeAdditionPreparation
    PASS FLOW[timeout=10]: gNB3 E1AP bearerContextSetup
    PASS FLOW[timeout=10]: gNB3 F1AP uEContextSetup
    PASS FLOW[timeout=10]: gNB3 XNAP xnUAddressIndication
    PASS FLOW[timeout=10]: gNB3 XNAP sNGRANnodeReconfigurationCompletion
    PASS FLOW[timeout=10]: gNB3 E1AP bearerContextInactivityNotification

    # SN initiated takeback
    PASS FLOW[timeout=10]: gNB3 XNAP sNGRANnodeinitiatedSNGRANnodeRelease
    PASS FLOW[timeout=10]: gNB3 E1AP bearerContextModification
    PASS FLOW[timeout=10]: gNB3 F1AP uEContextModification
    FAIL FLOW[timeout=10]: gNB3 XNAP sNStatusTransfer

    PASS FLOW[timeout=10]: gNB3 XNAP uEContextRelease
    PASS FLOW[timeout=10]: gNB3 F1AP uEContextRelease
    PASS FLOW[timeout=10]: gNB3 E1AP bearerContextRelease

    FAIL FLOW[timeout=10]: gNB3 NGAP uEContextRelease
