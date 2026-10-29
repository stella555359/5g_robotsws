*** Settings ***
Documentation    Keywords for the CB006733_C_B30

Library     ta5g_ue_mobility
Resource    resources/CB006733_keywords.robot


*** Variables ***
${ue_id_6733_b30}=             4
${additional_qos_6733_b30}=    2

${gw_id_for_CA_eligible_6733_b30}=               3
${gw_id_for_CA_incompatible_6733_b30}=           1
${pdu_id_with_CA_eligible_DRB_6733_b30}=         3
${pdu_id_with_CA_incompatible_DRB_6733_b30}=     1

${a4_retry_timer_6733_b30}=    1

${PDUSessionResourceSetupRequest_6733_b30}=
...    ngap.PDUSessionResourceSetupRequest_element &&
...    ngap.pDUSessionID==1 &&
...    ngap.QosFlowSetupRequestList==2 &&
...    ngap.fiveQI==6 &&
...    ngap.fiveQI==5

${PDUSessionResourceSetupResponse_6733_b30}=
...    ngap.PDUSessionResourceSetupResponse_element &&
...    ngap.pDUSessionID==1 &&
...    ngap.associatedQosFlowList==2 &&
...    ngap.qosFlowIdentifier==1 &&
...    ngap.qosFlowIdentifier==2

${PDUSessionResourceReleaseCommand_6733_b30}=
...    ngap.PDUSessionResourceReleaseCommand_element &&
...    ngap.PDUSessionResourceToReleaseListRelCmd == 1 &&
...    ngap.pDUSessionID==1

${UEContextModificationRequest_6733_b30}=
...    f1ap.UEContextModificationRequest_element &&
...    f1ap.DRBs_ToBeReleased_List == 2 &&
...    f1ap.dRBID == 5 &&
...    f1ap.dRBID == 6

${UEContextModificationResponse_6733_b30}=
...    f1ap.UEContextModificationResponse_element &&
...    nr-rrc.rlc_BearerToReleaseList == 2 &&
...    nr-rrc.LogicalChannelIdentity == 5 &&
...    nr-rrc.LogicalChannelIdentity == 6

${PDUSessionResourceReleaseResponse_6733_b30}=
...    ngap.PDUSessionResourceReleaseResponse_element &&
...    ngap.pDUSessionID==1

${UeContextModReqWithA4_6733_b30}=
...    f1ap.UEContextModificationRequest_element &&
...    nr-rrc.measObjectToAddModList==3 &&
...    nr-rrc.reportConfigToAddModList==2 &&
...    nr-rrc.measIdToAddModList==3

${UeContextModRespWithMeasGap_6733_b30}=
...    f1ap.UEContextModificationResponse_element &&
...    nr-rrc.gapUE==1

${RRCReconfigurationWithA4_6733_b30}=
...    nr-rrc.rrcReconfiguration_element &&
...    nr-rrc.measObjectToAddModList==2 &&
...    nr-rrc.reportConfigToAddModList==2 &&
...    nr-rrc.measIdToAddModList==3 &&
...    nr-rrc.gapUE==1


*** Keywords ***
TC__CB006733-C_B30_PDU_Session_Release_CB009059_interaction_A4_measurement_activation_for_FR1_CA_SCell_Addition
    Register UE To gNB without PDU session setup    ue_id=${ue_id_6733_b30}
    Setup PDU Session With CA Eligible DRB    ue_id=${ue_id_6733_b30}    pdu_id=${pdu_id_with_CA_eligible_DRB_6733_b30}
    ...    gw_id=${gw_id_for_CA_eligible_6733_b30}
    Setup Additional DRB    additional_qos=${additional_qos_6733_b30}
    Setup PDU session with non CA eligible DRB    ue_id=${ue_id_6733_b30}    pdu_id=${pdu_id_with_CA_incompatible_DRB_6733_b30}
    ...    gw_id=${gw_id_for_CA_incompatible_6733_b30}

    Verify PDU Session Resource Setup Request With non CA eligible DRB    ${PDUSessionResourceSetupRequest_6733_b30}
    Verify PDU Session Resource Setup Response    ${PDUSessionResourceSetupResponse_6733_b30}

    Release PDU Session With Non CA Eligible DRB    ue_id=${ue_id_6733_b30}    pdu_id=${pdu_id_with_CA_incompatible_DRB_6733_b30}

    Verify PDU Session Resource Release Command    ${PDUSessionResourceReleaseCommand_6733_b30}
    Verify UE Context Modification Request During PDU Session Release    ${UEContextModificationRequest_6733_b30}
    Verify UE Context Modification Response During PDU Session Release    ${UEContextModificationResponse_6733_b30}
    Verify PDU Session Resource Release Response    ${PDUSessionResourceReleaseResponse_6733_b30}

    Wait For A4 Retry Timer Expiration    a4_retry_timer=${a4_retry_timer_6733_b30}

    ## Verification of the second A4 Measurement and Measurement GAP configurations after the configurations during PDU Session Setup
    Verify A4 Measurement Configuration    ${UeContextModReqWithA4_6733_b30}     number_of_messages=1
    Verify Measurement Gap Configuration    ${UeContextModRespWithMeasGap_6733_b30}      number_of_messages=1
    Verify RRC A4 Measurement Configuration    ${RRCReconfigurationWithA4_6733_b30}

    [Teardown]    Deregister Ue    ue_id=${ue_id_6733_b30}
