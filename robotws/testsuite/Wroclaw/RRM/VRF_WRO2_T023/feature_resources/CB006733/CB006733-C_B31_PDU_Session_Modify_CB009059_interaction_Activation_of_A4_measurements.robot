*** Settings ***
Documentation    Keywords for the CB006733_C_B31

Library     ta5g_ue_mobility
Library     ta5g_pm_counters
Resource    resources/CB006733_keywords.robot


*** Variables ***
${ue_id_6733_b31}=    4

${PDUSessionResourceSetupRequest_6733_b31}=
...    ngap.PDUSessionResourceSetupRequest_element &&
...    ngap.QosFlowSetupRequestList==1 &&
...    ngap.fiveQI==6

${PDUSessionResourceSetupResponse_6733_b31}=
...    ngap.PDUSessionResourceSetupResponse_element &&
...    ngap.pDUSessionID==3 &&
...    ngap.associatedQosFlowList==1 &&
...    ngap.qosFlowIdentifier==1

${PDUSessionResourceModifyRequest_6733_b31}=
...    ngap.PDUSessionResourceModifyRequest_element &&
...    ngap.pDUSessionID==3 &&
...    ngap.QosFlowAddOrModifyRequestList==1 &&
...    ngap.qosFlowIdentifier==2 &&
...    ngap.fiveQI==5

${UeContextModReqWithEligibleDRB_6733_b31}=
...    f1ap.UEContextModificationRequest_element &&
...    f1ap.dRBID==5 &&
...    f1ap.fiveQI==5

${UeContextModRespWithEligibleDRB_6733_b31}=
...    f1ap.UEContextModificationResponse_element &&
...    f1ap.DRBs_SetupMod_List==1 &&
...    f1ap.dRBID==5

${PDUSessionResourceModifyResponse_6733_b31}=
...    ngap.PDUSessionResourceModifyResponse_element &&
...    ngap.pDUSessionID==3 &&
...    ngap.qosFlowAddOrModifyResponseList==1 &&
...    ngap.qosFlowIdentifier==2

${UeContextModReqWithA4_6733_b31}=
...    f1ap.UEContextModificationRequest_element &&
...    nr-rrc.measObjectToAddModList==3 &&
...    nr-rrc.reportConfigToAddModList==2 &&
...    nr-rrc.measIdToAddModList==3

${UeContextModRespWithMeasGap_6733_b31}=
...    f1ap.UEContextModificationResponse_element &&
...    nr-rrc.gapUE==1

${RRCReconfigurationWithA4_6733_b31}=
...    nr-rrc.rrcReconfiguration_element &&
...    nr-rrc.measObjectToAddModList==2 &&
...    nr-rrc.reportConfigToAddModList==2 &&
...    nr-rrc.measIdToAddModList==3 &&
...    nr-rrc.gapUE==1

${LOCAL_MOID_6733_b31}=    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-4


*** Keywords ***
TC__CB006733-C_B31_PDU_Session_Modify_CB009059_interaction_Activation_of_A4_measurements_for_FR1_CA_SCell_Addition
    Register UE To gNB without PDU session setup    ue_id=${ue_id_6733_b31}
    Setup PDU session with non CA eligible DRB    ue_id=${ue_id_6733_b31}
    Verify PDU Session Resource Setup Request With non CA eligible DRB    ${PDUSessionResourceSetupRequest_6733_b31}
    Verify PDU Session Resource Setup Response    ${PDUSessionResourceSetupResponse_6733_b31}
    Modify PDU session with CA eligible DRB    ue_id=${ue_id_6733_b31}
    Verify PDU Session Resource Modify Request With CA eligible DRB    ${PDUSessionResourceModifyRequest_6733_b31}
    Verify CA eligible DRB Addition    ${UeContextModReqWithEligibleDRB_6733_b31}
    Verify CA eligible DRB Addition    ${UeContextModRespWithEligibleDRB_6733_b31}
    Verify PDU Session Resource Modify Response    ${PDUSessionResourceModifyResponse_6733_b31}
    Verify A4 Measurement Configuration    ${UeContextModReqWithA4_6733_b31}
    Verify Measurement Gap Configuration    ${UeContextModRespWithMeasGap_6733_b31}
    Verify RRC A4 Measurement Configuration    ${RRCReconfigurationWithA4_6733_b31}
    Verify Pm Counter For Number Of A4 Measurements Activations    local_moid=${LOCAL_MOID_6733_b31}

    [Teardown]    Deregister Ue    ue_id=${ue_id_6733_b31}

Verify Pm Counter For Number Of A4 Measurements Activations
    [Arguments]    ${local_moid}
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55118C00030    >0    A4_MEASUR_ACT_SCELL_ADD_SA
    ...    local_moid=${local_moid}
    ...    file_path=${pm_counter_file}
