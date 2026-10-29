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
...      1. CB008490-SR-DB-B201_1 - Unsuccessful SNodeAddition due to timeout before XnAP SNodeAdditionRequestAcknowledge is received
...      2. CB008490-SR-DB-B201_2 - Successful SNodeAddition to different SN gNB after XnAP SNodeAdditionRequestAcknowledge not received
...      3. CB008490-SR-DB-B201_4 - AMF initiated UE release during SNodeAddition before XnAP SNodeAdditionRequestAcknowledge
...      4. CB008490-SR-DB-B201_6 - gNB initiated UE release during SNodeAddition before XnAP SNodeAdditionRequestAcknowledge
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
...      [04.12.2024] - Create Test Suite
...      [26.11.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=922695)

Resource    resources/CB008490-common_keywords.robot
Resource    resources/CB008490_setup_and_teardowns.robot
Resource    resources/CB008490-flows_with_sim_gNB.robot

Force Tags    CONFIGURED    CRT    PY39    RAN_5G    RAN_5G_TDD    SBTS00
...    CLOUD_5G_I_LO_AP_LO
...    VARIANT_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup    Run setup    f1ap_gNBs=MN    sim_gNB=SN

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/egate_2c_n78_n257_TDD_SA_3xsimSN.lua
${SCF_gnb2_MN}=           Krakow/CB008490/scf_MN_GA_ABIP_3xsimSN_GMC.xml
${AP_XML}=                Krakow/CB008490/iphy_2cells_n78_n257_simSN.xml
&{NRCELL_ID_TO_PHYSCELL_ID}=  1=50  3=52  4=53  5=54
${SKIP_COUNTERS}=         ${FALSE}

*** Test Cases ***
CB008490-SR-DB_B201_1_2_4_6
    [Tags]
    [Documentation]
    ...  == DESCRIPTION ==
    ...  Test scenario contains following test cases:
    ...    - CB008490-SR-DB-B201_1 - Unsuccessful SNodeAddition due to timeout before XnAP SNodeAdditionRequestAcknowledge is received
    ...         Test scenario verifies that MN gNB cancels PSCell Addition procedure when timerXnDcPrep expires
    ...         while waiting for XnAP: SNodeAdditionRequestAcknowledge.
    ...    - CB008490-SR-DB-B201_2 - Successful SNodeAddition to different SN gNB after XnAP SNodeAdditionRequestAcknowledge not received
    ...         Test scenario verifies that MN gNB cancels PSCell Addition procedure when timerXnDcPrep expires while waiting for
    ...         XnAP: SNodeAdditionRequestAcknowledge, then selects different gNB as SN and PSCell Addition procedure succeeds.
    ...    - CB008490-SR-DB-B201_4 - AMF initiated UE release during SNodeAddition before XnAP SNodeAdditionRequestAcknowledge
    ...         Test scenario verifies that MN gNB cancels PSCell Addition procedure when AMF initiated UE release happens before
    ...         XnAP SNodeAdditionRequestAcknowledge.
    ...    - CB008490-SR-DB-B201_6 - gNB initiated UE release during SNodeAddition before XnAP SNodeAdditionRequestAcknowledge
    ...         Test scenario verifies that MN gNB cancels PSCell Addition procedure when gNB initiated UE release happens before
    ...         XnAP SNodeAdditionRequestAcknowledge.
    ...
    ...  == PRECONDITION ==
    ...    - CB008490-SR-DB-B201_1:
    ...      - UE1 is connected to MN gNB and NR-DC A4 measurements are installed
    ...      - Airphone command executed to skip sending XnAP: SNodeAdditionRequestAcknowledge
    ...    - CB008490-SR-DB-B201_2:
    ...      - UE2 is connected to MN gNB and NR-DC A4 measurements are installed for cells hosted at gNB3 and gNB4
    ...      - Airphone command executed to skip sending XnAP: SNodeAdditionRequestAcknowledge for gNB3
    ...    - CB008490-SR-DB-B201_4:
    ...      - UE3 is connected to MN gNB and NR-DC A4 measurements are installed
    ...      - Airphone command executed to skip sending XnAP: SNodeAdditionRequestAcknowledge
    ...    - CB008490-SR-DB-B201_6:
    ...      - MN gNB NRBTS.actGnbInitRlf = true
    ...      - UE4 is connected to MN gNB and NR-DC A4 measurements are installed
    ...      - Airphone command executed to skip sending XnAP: SNodeAdditionRequestAcknowledge
    ...
    ...  == POSTCONDITION ==
    ...    - CB008490-SR-DB-B201_1:
    ...      - UE1 is not configured with the NR-DC
    ...    - CB008490-SR-DB-B201_2:
    ...      - UE2 is configured with the NR-DC with sim SN gNB4
    ...    - CB008490-SR-DB-B201_4:
    ...      - UE3 is released
    ...    - CB008490-SR-DB-B201_6:
    ...      - UE4 is released
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, 5GCSim, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode as MN
    ...  - simulated gNB as SN
    ...  - gNB module MN (ASIL + ABIO / ASIM + ABIP)
    ...  - UEs configured in SA, TDD
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_26059; 5G_RAN_USR_RRM_26069
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC,NGAP,F1AP,E1AP
    ...
    ...  == CONTACTS ==
    ...  - Tomasz Pyrek <tomasz.pyrek@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  Related CFAM US:
    ...  - US CB008490-DB#EC1: Unsuccessful inter-gNB NR-DC PSCell Addition due to timeout before response
    ...    XnAP: SNodeAdditionRequestAcknowledge is received - main scenario + ALT1
    ...  - US CB008490-DB#EC2: inter-gNB NR-DC PSCell Addition interrupted by the UE Release (AMF or gNB initiated) - ALT1 + ALT3
    ...
    ...  == HISTORY ==
    ...  [04.12.2024] - Create Test Suite
    ...  [26.11.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=922695)

    [Setup]  Prepare test environment CB008490-DB-201

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm Before Test

#   CB008490-SR-DB-B201_1 - Unsuccessful SNodeAddition due to timeout before XnAP SNodeAdditionRequestAcknowledge is received
    Attach UE1 and add initial PDU session to MN gNB NRCELL-1
    Set expected messages flows for canceled SNodeAddition
    UE1 sends A4 measurement with id=1 and PCIs [52]
    Verify expected messages flows for canceled SNodeAddition
    Verify that XNAP SNodeReleaseRequest contains only id-M-NG-RANnodeUEXnAPID and id-Cause, gNB2
    Verify that XNAP SNodeReleaseRequest contains cause:radioNetwork:unspecified, gNB2

#   CB008490-SR-DB-B201_2 - Successful SNodeAddition to different SN gNB after XnAP SNodeAdditionRequestAcknowledge not received
    Attach UE2 and add initial PDU session to MN gNB NRCELL-1
    Set expected messages flows for SNodeAddition to other gNB for UE2, MN gNB2
    UE2 sends A4 measurement with id=1 and PCIs [52,53]
    Verify expected messages flows for SNodeAddition to other gNB for UE2, MN gNB2
    Verify that XNAP SNodeReleaseRequest contains only id-M-NG-RANnodeUEXnAPID and id-Cause, gNB2
    Verify that XNAP SNodeReleaseRequest contains cause:radioNetwork:unspecified, gNB2
    Verify physCellId eq 53 in RRCReconfiguration message for UE2

#   CB008490-SR-DB-B201_4 - AMF initiated UE release during SNodeAddition before XnAP SNodeAdditionRequestAcknowledge
    Attach UE3 and add initial PDU session to MN gNB NRCELL-1
    Set expected messages flows for UE Release during SNodeAddition
    UE3 sends A4 measurement with id=1 and PCIs [52]
    sleep    1
    Release UE3 initiedted by AMF with Cause:RN_CauseRadioNetwork_unspecified
    Verify expected messages flows for UE Release during SNodeAddition
    Verify that XNAP SNodeReleaseRequest contains only id-M-NG-RANnodeUEXnAPID and id-Cause, gNB2
    Verify that XNAP SNodeReleaseRequest contains cause:radioNetwork:unspecified, gNB2

#   CB008490-SR-DB-B201_6 - gNB initiated UE release during SNodeAddition before XnAP SNodeAdditionRequestAcknowledge
    Attach UE4 and add initial PDU session to MN gNB NRCELL-1
    Run 10Mbps UL and DL traffic on UE4 PDU1 QFI1 and wait 2 seconds
    Set expected messages flows for UE RLF during SNodeAddition
    UE4 sends A4 measurement with id=1 and PCIs [52]
    Trigger Radio Link Failure for UE4
    Verify expected messages flows for UE RLF during SNodeAddition
    Verify that F1AP:UEContextModificationRequired contains cause:radioNetwork:rl-failure-others, gNB2
    Verify that XNAP SNodeReleaseRequest contains only id-M-NG-RANnodeUEXnAPID and id-Cause, gNB2
    Verify that XNAP SNodeReleaseRequest contains cause:radioNetwork:radio-connection-with-UE-lost, gNB2

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm After Test

    Omit when SKIP_COUNTERS present
    ...  Run keywords
    ...  Check RTPM counter on bts_id=1: NRCELL-1 IE_NRDC_MN_SNODE_ADD_REQ (M55116C00038) is equal 5
    ...  Check RTPM counter on bts_id=1: NRCELL-1 IE_NRDC_MN_SNODE_ADD_TEXP (M55116C00046) is equal 4
    ...  Check RTPM counter on bts_id=1: NRCELL-1 IE_NRDC_MN_SNODE_ADD_ACK (M55116C00048) is equal 1

    [Teardown]  CB008490-DB-201 cleanup


*** Keywords ***
Attach UE${ue_id:\d+} and add initial PDU session to MN gNB NRCELL-${cell_id:\d+}
    Attach UE${ue_id} without ICS to gNB2 cell${cell_id}
    Set expected messages flows for PDU session and A4 measurement configuration for UE${ue_id} and AMF1
    Add to UE${ue_id} initial PDU session with ICS and indexToRFSP equal 1
    Verify expected messages flows for PDU session and A4 measurement configuration for UE${ue_id} and AMF1

Set expected messages flows for canceled SNodeAddition
    Expect message flow
    ...    gNB2:XNAP_SNodeAdditionRequest
    ...    alias=SNodeAdd
    ...    overall_timeout=10

    Expect message will not occur
    ...    gNB2:XNAP_SNodeAdditionRequestAcknowledge
    ...    alias=SNodeAdd_without_ack
    ...    overall_timeout=10

    EXPECT FLOW[timeout=10]: gNB2 XNAP mNGRANnodeinitiatedSNGRANnodeRelease
    EXPECT FLOW[timeout=10]: gNB2 XNAP uEContextRelease

Verify expected messages flows for canceled SNodeAddition
    Flow occurred as expected    alias=SNodeAdd
    Flow not occurred for message    alias=SNodeAdd_without_ack
    PASS FLOW[timeout=10]: gNB2 XNAP mNGRANnodeinitiatedSNGRANnodeRelease
    FAIL FLOW[timeout=10]: gNB2 XNAP uEContextRelease

Set expected messages flows for SNodeAddition to other gNB for UE${ue_id}, MN gNB2
    Expect message flow
    ...    gNB2:XNAP_SNodeAdditionRequest
    ...    alias=SNodeAdd
    ...    overall_timeout=2

    Expect message will not occur
    ...    gNB2:XNAP_SNodeAdditionRequestAcknowledge
    ...    alias=SNodeAdd_without_ack
    ...    overall_timeout=2

    EXPECT FLOW[timeout=10]: gNB2 XNAP mNGRANnodeinitiatedSNGRANnodeRelease
    EXPECT FLOW[timeout=10]: gNB2 XNAP uEContextRelease
    Set expected messages flows for SNodeAddition for UE${ue_id}, MN real gNB2 and SN sim gNB4

Verify expected messages flows for SNodeAddition to other gNB for UE${ue_id}, MN gNB2
    Flow occurred as expected    alias=SNodeAdd
    Flow not occurred for message    alias=SNodeAdd_without_ack
    PASS FLOW[timeout=10]: gNB2 XNAP mNGRANnodeinitiatedSNGRANnodeRelease
    FAIL FLOW[timeout=10]: gNB2 XNAP uEContextRelease
    Verify expected messages flows for SNodeAddition for UE${ue_id}, MN real gNB2 and SN sim gNB4

Set expected messages flows for UE Release during SNodeAddition
    Expect message flow
    ...    gNB2:XNAP_SNodeAdditionRequest
    ...    alias=SNodeAdd
    ...    overall_timeout=2

    Expect message will not occur
    ...    gNB2:XNAP_SNodeAdditionRequestAcknowledge
    ...    alias=SNodeAdd_without_ack
    ...    overall_timeout=2

    EXPECT FLOW[timeout=10]: gNB2 XNAP mNGRANnodeinitiatedSNGRANnodeRelease
    EXPECT FLOW[timeout=10]: gNB2 XNAP uEContextRelease
    EXPECT FLOW[timeout=10]: gNB2 NGAP uEContextRelease
    EXPECT FLOW[timeout=10]: gNB2 F1AP uEContextRelease
    EXPECT FLOW[timeout=10]: gNB2 E1AP bearerContextRelease

Verify expected messages flows for UE Release during SNodeAddition
    Flow occurred as expected    alias=SNodeAdd
    Flow not occurred for message    alias=SNodeAdd_without_ack
    PASS FLOW[timeout=10]: gNB2 XNAP mNGRANnodeinitiatedSNGRANnodeRelease
    FAIL FLOW[timeout=10]: gNB2 XNAP uEContextRelease
    PASS FLOW[timeout=10]: gNB2 NGAP uEContextRelease
    PASS FLOW[timeout=10]: gNB2 F1AP uEContextRelease
    PASS FLOW[timeout=10]: gNB2 E1AP bearerContextRelease

Set expected messages flows for UE RLF during SNodeAddition
    Expect message flow
    ...    gNB2:XNAP_SNodeAdditionRequest
    ...    alias=SNodeAdd
    ...    overall_timeout=2

    Expect message will not occur
    ...    gNB2:XNAP_SNodeAdditionRequestAcknowledge
    ...    alias=SNodeAdd_without_ack
    ...    overall_timeout=2

    EXPECT FLOW[timeout=10]: gNB2 F1AP uEContextModificationRequired
    EXPECT FLOW[timeout=10]: gNB2 XNAP mNGRANnodeinitiatedSNGRANnodeRelease
    EXPECT FLOW[timeout=10]: gNB2 XNAP uEContextRelease
    EXPECT FLOW[timeout=10]: gNB2 NGAP uEContextRelease
    EXPECT FLOW[timeout=10]: gNB2 F1AP uEContextRelease
    EXPECT FLOW[timeout=10]: gNB2 E1AP bearerContextRelease

Verify expected messages flows for UE RLF during SNodeAddition
    Flow occurred as expected    alias=SNodeAdd
    Flow not occurred for message    alias=SNodeAdd_without_ack
    PASS FLOW[timeout=10]: gNB2 F1AP uEContextModificationRequired
    PASS FLOW[timeout=10]: gNB2 XNAP mNGRANnodeinitiatedSNGRANnodeRelease
    FAIL FLOW[timeout=10]: gNB2 XNAP uEContextRelease
    PASS FLOW[timeout=10]: gNB2 NGAP uEContextRelease
    PASS FLOW[timeout=10]: gNB2 F1AP uEContextRelease
    PASS FLOW[timeout=10]: gNB2 E1AP bearerContextRelease
