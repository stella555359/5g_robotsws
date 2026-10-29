*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...
...      == INTRODUCTION ==
...      This sub-feature introduces successful procedure of inter-gNB NR-DC UE context release. UE should be transmitted from RRC-CONNECTED
...      to RRC_IDLE state after procedure.
...
...      == TEST SET NAME ==
...      CB008490-E: UE Context Release
...
...      == TESTING SPLIT ==
...      CB008490-E#B1 - UE Context Release - RRC Reestablishment
...      CB008490-E#B2 - UE Context Release - due to preemption
...      CB008490-E#B3 - UE Context Release - due to failure in AMF reselection
...      CB008490-E#B4 - UE Context Release - due to Xn-U Error (UP Error Indication from SN gNB-CU-UP to MN gNB-DU)
...
...      == TESTING SCOPE ==
...      CB008490-E#B3 - UE Context Release - due to failure in AMF reselection
...
...      == CONTACTS ==
...         - Malgorzata Konior     <malgorzata.konior@nokia.com>
...         - Konrad Krzyzak        <konrad.krzyzak@nokia.com>
...         - Tomasz Pyrek          <tomasz.pyrek@nokia.com>
...         - Michal Szymakowski    <michal.szymakowski@nokia.com>
...         - Grzegorz Szymik       <grzegorz.szymik@nokia.com>
...
...      == MAINTAINER ==
...         - Malgorzata Konior     <malgorzata.konior@nokia.com>
...         - Konrad Krzyzak        <konrad.krzyzak@nokia.com>
...         - Tomasz Pyrek          <tomasz.pyrek@nokia.com>
...         - Michal Szymakowski    <michal.szymakowski@nokia.com>
...         - Grzegorz Szymik       <grzegorz.szymik@nokia.com>
...
...      == REFERENCES ==
...         CB008490 CFAM - https://gates.nsn-net.net/view/00025ee1#o=9047
...
...      == HISTORY ==
...      [29.02.2024] - Create Test Suite
...      [08.03.2024] - Final Test Suite shape
...      [08.03.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=905538))
...
Resource    resources/CB008490-common_keywords.robot
Resource    resources/CB008490_setup_and_teardowns.robot

Force Tags    CONFIGURED    CRT    PY39    RAN_5G    RAN_5G_TDD    SBTS00
...    CLOUD_5G_I_[LO][LO]_AP_[LOO]
...    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD

Suite Setup    Run setup

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/E/egate_3amf_2c_n78_n257_TDD_SA.lua
${SCF_gnb2_MN}=           Krakow/CB008490/scf_MN_GA_ABIP_3xsimSN_GMC.xml
${SCF_gnb3_SN}=           Krakow/CB008490/scf_SN_GA_ABIP.xml
${AP_XML}=                Krakow/CB008490/iphy_2cells_n78_n257.xml
${yaml_E_B3}=             ${CURDIR}/config/E/yaml/E_B3_amf_reselection.yaml


*** Test Cases ***
CB008490-E-B3_UE_Context_release_due_to_failure_in_AMF_reselection
    [Tags]
    [Documentation]
    ...  == DESCRIPTION ==
    ...  This user scenario describes the gNB behavior for transition of the UE with established inter-gNB NR-DC connection (with established
    ...  SN-terminated split bearer) to RRC IDLE triggered by failure in AMF reselection.
    ...
    ...  == PRECONDITION ==
    ...  - USR_RRM_23633 - Common text (Precondition) to all CB008490-E User Scenarios
    ...  - 2 AMFs are configured according to 5G_RAN_USR_RRM_1896
    ...  - Attach UE1 to SA cell in MN gNB and start DL/UL data transfer
    ...  - UE1 has inter-gNB NRDC connection established with SN gNB
    ...  - NG-C Flex (SA mode) Feature activation parameter set to true: SA calls are connected with both AMFs
    ...  - AMF reselection is allowed: NRBTS.actNgcFlexSaMode is set to true
    ...  - AMF2 has been identified as backup of AMF1 for UE1
    ...  - NG-C link is setup with AMF1
    ...  - NG-C link with AMF2 is locked
    ...
    ...  == POSTCONDITION ==
    ...  - UE1 is in RRC-IDLE state
    ...  - XnAP interface connection for the inter-gNB NR-DC UE is removed
    ...  - All resources related to UE1 are released successfully
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB2 (ASIL + ABIO) with simulated 1x AEQE (band n78)
    ...  - HARDWARE ID:  gNB3 (ASIL + ABIO) with simulated 1x AEQE (band n78) and 1x AWEUB (band n257)
    ...  - UE configured in SA, TDD
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_23633, 5G_RAN_USR_RRM_23640
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC, NGAP, F1AP, E1AP, XNAP
    ...
    ...  == CONTACTS ==
    ...     - Malgorzata Konior     <malgorzata.konior@nokia.com>
    ...     - Konrad Krzyzak        <konrad.krzyzak@nokia.com>
    ...     - Tomasz Pyrek          <tomasz.pyrek@nokia.com>
    ...     - Michal Szymakowski    <michal.szymakowski@nokia.com>
    ...     - Grzegorz Szymik       <grzegorz.szymik@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  Related CFAM US:
    ...  CB008490-E#B3 - UE Context Release - due to failure in AMF reselection
    ...
    ...  == HISTORY ==
    ...  [29.02.2024] - Create Test Suite
    ...  [08.03.2024] - Final Test Case shape
    ...  [08.03.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=905538))

    [Setup]  Prepare test environment CB008490-E-B3

    Lock NG-C link to AMF2

    Attach UE1 without ICS to MN gNB2 NRCELL-1

    Set expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1
    Add to UE1 initial PDU session with ICS and indexToRFSP equal 1
    Verify expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1

    Run 1Mbps UL and DL traffic on UE1 PDU1 QFI1 and wait 5 seconds

    Set expected messages flows for SNodeAddition for SN gNB3
    Set expected messages flows for SNodeAddition for UE1, MN gNB2

    UE1 sends A4 measurement with id=1 for NR-DC PSCell addition

    Verify expected messages flows for SNodeAddition for SN gNB3
    Verify expected messages flows for SNodeAddition for UE1, MN gNB2

    Lock NG-C link to AMF1

    Set expected message flows for UE1 Release due to AMF reselection failure, MN gNB2
    Set expected message flows for UE1 Release due to AMF reselection failure, SN gNB3

    Trigger UE1 to send RRC ULInformationTransfer

    Verify expected message flows for UE1 Release due to AMF reselection failure, MN gNB2
    Verify expected message flows for UE1 Release due to AMF reselection failure, SN gNB3

    Verify that XnAP:SNodeReleaseRequest contains id-M-NG-RANnodeUEXnAPID same as in XnAP:SNodeAdditionRequestAck
    Verify that XNAP:SNodeReleaseRequest contains id-S-NG-RANnodeUEXnAPID same as in XnAP:SNodeAdditionRequestAck
    Verify that XNAP:SNodeReleaseRequest contains pduSessionID same as in XnAP:SNodeAdditionRequestAck
    Verify that XNAP SNodeReleaseRequest contains cause:misc:unspecified, gNB2

    Verify that XNAP:SNodeReleaseRequestAcknowledge contains id-M-NG-RANnodeUEXnAPID same as in XnAP:SNodeReleaseRequest
    Verify that XNAP:SNodeReleaseRequestAcknowledge contains id-S-NG-RANnodeUEXnAPID same as in XnAP:SNodeReleaseRequest
    Verify that XNAP:SNodeReleaseRequestAcknowledge contains pduSessionID same as in XnAP:SNodeReleaseRequest
    Verify that XNAP SNodeReleaseRequestAcknowledge dRBtoBeReleasedList contains 'drb-ID', gNB3
    Verify that XNAP SNodeReleaseRequestAcknowledge dRBtoBeReleasedList contains 'rLC-Mode', gNB3
    Verify that XNAP SNodeReleaseRequestAcknowledge dRBtoBeReleasedList contains 'qfi', gNB3

    Verify that XNAP:UeContextRelease contains id-M-NG-RANnodeUEXnAPID same as in XnAP:SNodeReleaseRequest
    Verify that XNAP:UeContextRelease contains id-S-NG-RANnodeUEXnAPID same as in XnAP:SNodeReleaseRequest

     Verify that E1AP:BearerContextModificationRequest pduSessionID same as in XNAP:SnodeReleaseRequest
     Verify that E1AP:BearerContextModificationRequest cell-Group-To-Modify includes 2 items, gNB3
     Verify that E1AP:BearerContextModificationRequest cell-Group-ID eq 0 and dL-TX-Stop eq stop, gNB3
     Verify that E1AP:BearerContextModificationRequest cell-Group-ID eq 1 and dL-TX-Stop eq stop, gNB3

     Verify that E1AP:BearerContextModificationResponse pduSessionID same as in E1AP:BearerContextModificationRequest
     Verify that E1AP:BearerContextModificationResponse contains size of PDU-Session-Resource-Modified-List equal 1
     Verify that E1AP:BearerContextModificationResponse dRB-ID same as in E1AP:BearerContextModificationRequest
     Verify that E1AP:BearerContextModificationResponse contains size of dRB-Modified-List-NG-RAN equal 1

     Verify that F1AP:UEContextModificationRequest TransmissionActionIndicator is set to 'stop' for SN gNB3

     Verify that F1AP:UEContextReleaseCommand contains cause:misc:unspecified for SN gNB3
     Verify that F1AP:UEContextReleaseCommand does NOT contain RRC-Container for SN gNB3
     Verify that F1AP:UEContextReleaseCommand does NOT contain SRB-ID for SN SN gNB3

     Verify that E1AP:BearerContextReleaseCommand contains cause:misc:unspecified for SN gNB3
     Verify that in E1AP:BearerContextReleaseComplete RetainabilityMeasurementsInfo is present for gNB3

     Verify that F1AP:UEContextReleaseCommand contains cause:misc:unspecified for MN gNB2
     Verify that F1AP:UEContextReleaseCommand contains RRCContainer for MN gNB2
     Verify that F1AP:UEContextReleaseCommand contains SRB-ID eq 1 for MN gNB2

     Verify that E1AP:BearerContextReleaseCommand contains cause:misc:unspecified for MN gNB2
     Verify that E1AP:BearerContextReleaseComplete contains RetainabilityMeasurementsInfo with dRB-ID eq 4 for gNB2

    [Teardown]  E-B3 cleanup
