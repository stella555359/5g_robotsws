*** Settings ***
Force Tags    CONFIGURED   CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00
...    CLOUD_5G_I_BOO_AP_LOO

Documentation   :copyright: Nokia
...             :authors: Edyta Rudnik
...             :contact: edyta.rudnik@nokia.com

Resource    ../resources/feature_keywords.robot
Resource    ../../resources/testing_env.robot
Resource    ../../keywords/traffic.robot

Library        taf.ul.ettf.setups
Library        ../resources/KeywordsCB008490.py
Library        testsuite/Wroclaw/RRM/resources/scout_report.py
Variables      ../../resources/custom_policy.py

Suite Setup        Run Keywords
...                Verify If Admin Faults Are Down    fault_id_list=@{FAULT_IDS_LIST}
...    AND         Enable C-Plane Debug Logs       with_reboot=${false}
...    AND         Start Vm Ethernet Interfaces For Simulated gNB2
...    AND         Update And Put Iphy Xml         input_filepath=${IPHY}
...    AND         Find Scfc And Fix And Send Full Commissioning    scfc_filename=${SCFC_GNB_MN}
...    AND         With Simulator Configuration    config=${cfg}

Test Setup    Run Keywords
...                Enable Tshark Verification
...    AND         Setup devices aliases for realMN simSN


Test Teardown      Run Keywords
...                Deregister UE    ue_id=1
...    AND         Verify If Admin Faults Are Down    fault_id_list=@{FAULT_IDS_LIST}
...    AND         Add Scout Scf Id To Test Data

*** Variables ***
${LOGGING_POLICY}=          BASIC_POLICY
${SCFC_GNB_MN}=             scf_MN_n78A_AEQE.xml
${IPHY}=                    ${CURDIR}/config/iphy_MN_AEQE.xml
${cfg}=                     ${CURDIR}/config/cfg_realMN_n78A_simSN_n257A.cfg
@{FAULT_IDS_LIST}=          6450    4383
${ue_id}=                   1
${amf_id}=                  1
${pdu_id}=                  1

*** Test Cases ***
CB008490_FA_EC101_inter-gNB_NR-DC_takeback_procedure_with_timer_expiry_before_XnAP_SNodeReleaseRequestAck_is_received
    Attach Ue    ue_id=${ue_id}    enb=2    cell=1
    Set Internal Traffic Type To UE    ue_id=${ue_id}    pdu_id=${pdu_id}
    Set Scg UL Dist Percent
    Establish Pdu Session
    Send Data Traffic    inactive_timer=1
    Set Expected Message Flow For A4 Meas Based Inter-gNB PSCell Addition On MN Side For UE${ue_id} GNB2
    Send Ue Measurement Nr    ue_id=${ue_id}    meas_id=1    phycell_id=52    nrsrp_nr=60    event=A4
    Verify Expected Message Flow For A4 Meas Based Inter-gNB PSCell Addition On MN Side For UE${ue_id} GNB2
    Get Values From APIDs In SNnodeAddPrep
    Send Command To Delay SNodeReleaseRequestAcknowledge Message
    Set Expected Message Flow For Takeback On MN Side Without SNodeReleaseRequestAcknowledge
    Set Expected Delayed SNodeReleaseRequestAck
    Trigger RRC SCGFailureInformation With FailureType Set To T310-Expiry
    Verify Expected Delayed SNodeReleaseRequestAck
    Verify Expected Message Flow For Takeback On MN Side Without SNodeReleaseRequestAcknowledge
    Verify Message Contents Of Successfull NR-DC Bearer Takeback
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue_id}    expected_throughput=10Kbps
                                       ...       direction=dl    cell_group=MCG    selection_type=Average    margin=10%
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue_id}   expected_throughput=10Mbps      cell_index_min=0    cell_index_max=0
                                       ...     direction=ul    cell_group=MCG    selection_type=Average    margin=10%

CB008490_FA_EC203_ALT4_Unsuccessful_inter-gNB_NR-DC_SN-initiated_takeback_upon_detection_of_RLF_by_gNB-DU_SN_due_to_error_in_RRCReconfComplete
    Attach Ue    ue_id=${ue_id}    enb=2    cell=1
    Establish Pdu Session
    Set Expected Message Flow For A4 Meas Based Inter-gNB PSCell Addition On MN Side For UE${ue_id} GNB2
    Wait 2s For Measurement To Configure
    Send Ue Measurement Nr    ue_id=${ue_id}    meas_id=1    phycell_id=52    nrsrp_nr=60    event=A4
    Verify Expected Message Flow For A4 Meas Based Inter-gNB PSCell Addition On MN Side For UE${ue_id} GNB2
    Delay RRCReconfigurationComplete
    Set Expected Message Flow For RLF Triggered NR-DC Bearer Takeback Iterruped By Lack Of RRCReconfigurationComplete Message From UE
    Trigger Radio Link Failure On Sim gNB    cause=CauseRadioNetworkLayer_unspecified
    Verify Expected Message Flow For RLF Triggered NR-DC Bearer Takeback Iterruped By Lack Of RRCReconfigurationComplete Message From UE
    Verify Message Contents Of NR-DC Bearer Takeback Interrupted By Lack Of RRCReconfigurationComplete Message From UE

*** Keywords ***
Start Vm Ethernet Interfaces For Simulated gNB2
    Start Vm Ethernet Interface    if_name=eth3:GNB2_NG_ADDR    ip_with_mask=10.0.1.6/24
    Start Vm Ethernet Interface    if_name=eth3:GNB2_XN_ADDR    ip_with_mask=10.0.1.7/24

Set Expected Delayed SNodeReleaseRequestAck
    EXPECT FLOW[timeout=2]: gNB2 XNAP 1*mNGRANnodeinitiatedSNGRANnodeRelease

Verify Expected Delayed SNodeReleaseRequestAck
    Run Keyword And Expect Error    MessageObserverTimeout*    PASS FLOW[timeout=2]: gNB2 XNAP 1*mNGRANnodeinitiatedSNGRANnodeRelease

Verify Message Contents Of Successfull NR-DC Bearer Takeback
    Verify In XNAP SNodeReleaseRequest_1 Out Of 1 That Cause Has radioNetwork Set To 'action-desirable-for-radio-reasons' For GNB2
    Verify In XNAP SNodeReleaseRequest_1 Out Of 1 That pduSessionId Is Set To 1 For GNB2
    Verify In RRC RRCReconfiguration_1 Out Of 1 That mrdc-SecondaryCellGroupConfig Has 'release' For UE1
    Verify In F1AP UEContextModificationRequest_2 Out Of 2 That RRCReconfigurationCompleteIndicator Is Set To 'true' For GNB2
    Verify In F1AP UEContextModificationRequest_2 Out Of 2 That GNB-DUConfigurationQuery Is Set To 'true' For GNB2
    Verify In F1AP UEContextModificationResponse_2 Out Of 2 That cellGroupConfig Is Present For GNB2
    Check Values From APIDs In SNodeReleaseRequest
    Check Values From APIDs in XnapUEContextRelease

Set Expected Message Flow For Takeback On MN Side Without SNodeReleaseRequestAcknowledge
     Set expected message flow    bearerCtxMod=2    xnUAddressInd=1
        ...     sNStatusTransfer=1     XNAPuECtxRelease=1    uECtxMod=2    rrcReconf=1     rrcReconfCompl=1
        ...     pduSessResModInd=1     SCGFailureInfo=1

Verify Expected Message Flow For Takeback On MN Side Without SNodeReleaseRequestAcknowledge
     Verify expected message flow    bearerCtxMod=2    xnUAddressInd=1
        ...     sNStatusTransfer=1     XNAPuECtxRelease=1    uECtxMod=2      rrcReconf=1    rrcReconfCompl=1
        ...     pduSessResModInd=1     SCGFailureInfo=1

Set Expected Message Flow For RLF Triggered NR-DC Bearer Takeback Iterruped By Lack Of RRCReconfigurationComplete Message From UE
     Set expected message flow     sNnodeReleaseRequired=1     bearerCtxMod=2       sNStatusTransfer=1    uECtxMod=1    rrcReconf=1
     ...    XNAPuECtxRelease=1    NGAPueCtxReleaseReq=1    NGAPueCtxRelease=1    F1APuECtxRelease=1    bearerCtxRelease=1
     ...    rrcRelease=1

Verify Expected Message Flow For RLF Triggered NR-DC Bearer Takeback Iterruped By Lack Of RRCReconfigurationComplete Message From UE
     Verify expected message flow    sNnodeReleaseRequired=1    bearerCtxMod=2     sNStatusTransfer=1    uECtxMod=1    rrcReconf=1
     ...    XNAPuECtxRelease=1    NGAPueCtxReleaseReq=1    NGAPueCtxRelease=1    F1APuECtxRelease=1    bearerCtxRelease=1
     ...    rrcRelease=1

Verify Message Contents Of NR-DC Bearer Takeback Interrupted By Lack Of RRCReconfigurationComplete Message From UE
    Verify In XNAP SNodeReleaseRequired_1 Out Of 1 That Cause Has radioNetwork Set To 'unspecified' For GNB2
    Verify In F1AP UEContextModificationRequest_1 Out Of 1 That SCGIndicator Is Set To 'released' For GNB2
    Verify In RRC RRCReconfiguration_1 Out Of 1 That mrdc-SecondaryCellGroupConfig Has 'release' For UE1
    Verify In NGAP UEContextReleaseRequest_1 Out Of 1 Cause Is Set To "radioNetwork: radio-connection-with-ue-lost" For AMF${amf_id}
    Verify In NGAP UEContextReleaseCommand_1 Out Of 1 Cause Is Set To "radioNetwork: radio-connection-with-ue-lost" For AMF${amf_id}
    Verify In F1AP UEContextReleaseCommand_1 Out Of 1 Cause Is Set To "radioNetwork: normal-release" For GNB2
    Verify In E1AP BearerContextReleaseCommand_1 Out Of 1 Cause Is Set To "radioNetwork: normal-release" For GNB2
