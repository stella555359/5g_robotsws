*** Settings ***

Resource    ta_messaging/flow.robot
Library    CB006733.py
Variables    filters.py

*** Keywords ***

Verify that UEContextModificationRequest_${msg_num:\d+} of ${all:\d+} contains measConfig with A4 configuration for gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextModification
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    verify_if_measConfig_contains  ${flow_alias}  UEContextModificationRequest_${msg_num}  ${ue_context_modification_string_filter}


Set expected messages flows for A4 measurement configuration for UE${ue_id:\d+}, gNB${gnb_id:\d+} and AMF${amf_id:\d+}
    EXPECT FLOW[timeout=10]: gNB${gnb_id} F1AP 3*uEContextModification


Verify in UECtxModResp_${n:\d+} out of ${all:\d+} that measGapConfigIE is present for gNB${gnb_id}
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextModification
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     measGapConfig is present
    ...     message_alias=UEContextModificationResponse_${n}
    ...     flow_alias=${flow_alias}

Verify that UEContextModificationRequest_${msg_num:\d+} of ${all:\d+} contains measConfig with A4 and A2 configuration for gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextModification
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    verify_if_measConfig_contains  ${flow_alias}  UEContextModificationRequest_${msg_num}  ${ue_context_modification_string_filter_A2_A4_A4}

Verify that UEContextModificationRequest_${msg_num:\d+} of ${all:\d+} contains measConfig with A4 configuration after HO for gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextModification
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    verify_if_measConfig_contains  ${flow_alias}  UEContextModificationRequest_${msg_num}  ${ue_context_modification_string_filter_B_B1_A4}

Verify that UEContextModificationResponse_${msg_num:\d+} of ${all:\d+} contains measGapConfig for gNB${gnb_id:\d+}
    [Documentation]    message filters in BB9 scenario are similar to BB10
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextModification
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    verify_if_information_element_contains  measGapConfig  ${flow_alias}  UEContextModificationResponse_${msg_num}  0x80C06C007000

Verify that UEContextModificationRequest_${msg_num:\d+} of ${all:\d+} contains measConfig with only A2 configuration for gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextModification
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    verify_if_measConfig_contains  ${flow_alias}  UEContextModificationRequest_${msg_num}  ${ue_context_modification_string_filter_A2_only}

Verify that UEContextModificationResponse_${msg_num:\d+} of ${all:\d+} contains measGapConfig release for gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextModification
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    verify_if_information_element_contains  measGapConfig  ${flow_alias}  UEContextModificationResponse_${msg_num}  0x80C02800

Verify that UEContextModificationRequest_${msg_num:\d+} of ${all:\d+} contains measConfig with A4 and A2 2nd configuration for gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextModification
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    verify_if_measConfig_contains  ${flow_alias}  UEContextModificationRequest_${msg_num}
    ...    ${ue_context_modification_string_filter_A2_A4_A4_reactivation}

Verify that UEContextModificationRequest_${msg_num:\d+} of ${all:\d+} contains measConfig with A4 configuration after HO via XN for gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextModification
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    verify_if_measConfig_contains  ${flow_alias}  UEContextModificationRequest_${msg_num}  ${ue_context_modification_string_filter_B_B2}

Verify that UEContextModificationRequest_${msg_num:\d+} of ${all:\d+} contains measConfig with A4 and A2 configuration for 3CC
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextModification
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    verify_if_measConfig_contains  ${flow_alias}  UEContextModificationRequest_${msg_num}  ${ue_context_modification_string_filter_B_B12}

Verify that UEContextModificationRequest_${msg_num:\d+} of ${all:\d+} contains measConfig with A4 configuration for 3CC
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextModification
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    verify_if_measConfig_contains  ${flow_alias}  UEContextModificationRequest_${msg_num}  ${ue_context_modification_string_filter_A_B12_A4_A4}

Verify that UEContextModificationRequest_${msg_num:\d+} of ${all:\d+} contains measConfig with A4 reactivation
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextModification
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    verify_if_measConfig_contains  ${flow_alias}  UEContextModificationRequest_${msg_num}  ${ue_context_modification_string_filter_A_B12_A4_A4_react}

Verify that UEContextModificationRequest_${msg_num:\d+} of ${all:\d+} contains measConfig with A4 event after Ng Inter-Gnb HO for gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextModification
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    verify_if_measConfig_contains  ${flow_alias}  UEContextModificationRequest_${msg_num}  ${ue_context_modification_string_filter_B_B3}

Verify that UEContextModificationRequest_${msg_num:\d+} of ${all:\d+} contains measConfig with A2,3,5 events during Ng HO for gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextModification
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    verify_if_measConfig_contains  ${flow_alias}  UEContextModificationRequest_${msg_num}  ${ue_context_modification_with_A2_A3_A5_meas_B_B10}

Verify that UEContextModificationRequest_${msg_num:\d+} of ${all:\d+} contains measConfig with A2,3,4,5 events after Ng HO for gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextModification
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    verify_if_measConfig_contains  ${flow_alias}  UEContextModificationRequest_${msg_num}  ${ue_context_modification_with_A2_A3_A4_A5_meas_B_B10}

Verify that UEContextModificationRequest_${msg_num:\d+} of ${all:\d+} contains measConfig with A2 configuration only for gNB${gnb_id:\d+} B_B7
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextModification
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    verify_if_measConfig_contains  ${flow_alias}  UEContextModificationRequest_${msg_num}  ${ue_context_modification_string_filter_A2_only_B_B7}

Verify that UEContextModificationRequest_${msg_num:\d+} of ${all:\d+} contains measConfig with A4 and 2nd A2 configuration for gNB${gnb_id:\d+} B_B7
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextModification
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    verify_if_measConfig_contains  ${flow_alias}  UEContextModificationRequest_${msg_num}
    ...    ${ue_context_modification_string_filter_A2_A4_A4_reactivation_B_B7}

Verify that UEContextModificationRequest_${msg_num:\d+} of ${all:\d+} contains measConfig with A2,3,5 events during XN HO for gNB${gnb_id:\d+}
    [Documentation]    message filters in BB9 scenario are similar to BB10
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextModification
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    verify_if_measConfig_contains  ${flow_alias}  UEContextModificationRequest_${msg_num}  ${ue_context_modification_with_A2_A3_A5_meas_B_B10}

Verify that UEContextModificationRequest_${msg_num:\d+} of ${all:\d+} contains measConfig with A2,3,4,5 events after XN HO for gNB${gnb_id:\d+}
    [Documentation]    message filters in BB9 scenario are similar to BB10
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextModification
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    verify_if_measConfig_contains  ${flow_alias}  UEContextModificationRequest_${msg_num}  ${ue_context_modification_with_A2_A3_A4_A5_meas_B_B10}

Verify that UEContextModificationRequest_${msg_num:\d+} of ${all:\d+} contains Scell Addition Cells for gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextModification
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...  ${selected_SCells_for_2CC_CA_in_UE_CON_MOD_REQ_BB13}
    ...  message_alias=UEContextModificationRequest_${msg_num}
    ...  flow_alias=${flow_alias}

Verify that UEContextModificationResponse_${msg_num:\d+} of ${all:\d+} contains Scell Addition Cells for gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextModification
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...  ${selected_SCells_for_sCellToAddModList_BB13}
    ...  message_alias=UEContextModificationResponse_${msg_num}
    ...  flow_alias=${flow_alias}

Verify that UEContextModificationRequest_${msg_num:\d+} of ${all:\d+} contains Scell Swap Messages for gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextModification
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP
    Verify That Message Fulfills Query
    ...  ${selected_SCells_for_2CC_CA_in_UE_CON_MOD_REQ_after_Scell_Swap_BB13}
    ...  message_alias=UEContextModificationRequest_${msg_num}
    ...  flow_alias=${flow_alias}
    Verify That Message Fulfills Query
    ...  ${SCell_ToBeRemoved_List_in_UE_CON_MOD_REQ_after_Scell_Swap_BB13}
    ...  message_alias=UEContextModificationRequest_${msg_num}
    ...  flow_alias=${flow_alias}

Verify that UEContextModificationResponse_${msg_num:\d+} of ${all:\d+} contains Scell Swap Messages for gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextModification
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP
    Verify That Message Fulfills Query
    ...  ${selected_SCells_for_sCellToAddModList_after_SCell_Swap_BB13}
    ...  message_alias=UEContextModificationResponse_${msg_num}
    ...  flow_alias=${flow_alias}
    Verify That Message Fulfills Query
    ...  ${spCellConfig_in_UE_CON_MOD_RESP_Cell1_release_BB13}
    ...  message_alias=UEContextModificationResponse_${msg_num}
    ...  flow_alias=${flow_alias}
    Verify That Message Fulfills Query
    ...  ${downlinkConfigCommon_in_UE_CON_MOD_RESP_after_SCell_Swap_B13}
    ...  message_alias=UEContextModificationResponse_${msg_num}
    ...  flow_alias=${flow_alias}

Verify that UEContextSetupRequest contains measConfig with A1 configuration for UE${ue_id:\d+}
    verify_if_measConfig_contains  EN-DC_UE${ue_id}  ContextSetupReq  ${ue_context_setup_string_filter_B_B14}
    Verify That Message Fulfills Query
    ...     ${candidateCellInfoListMN_during_SgNBAdditionReq}
    ...     message_alias=ContextSetupReq
    ...     flow_alias=EN-DC_UE${ue_id}

Verify that UEContextSetupResponse contains reconfigurationWithSync for UE${ue_id:\d+}
    Verify That Message Fulfills Query
    ...     ${reconfigurationWithSync_sgnb_addition}
    ...     message_alias=ContextSetupResp
    ...     flow_alias=EN-DC_UE${ue_id}

Verify that triggered A1 report contains requested parametrers for gNB${gNB_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=rRCTransfer
    ...     device=gNB${gnb_id}
    ...     protocol=X2AP

    verify_if_information_element_contains  uENRMeasurements  ${flow_alias}  RRCTransfer  0000008436D2D40400


Verify that UEContextModificationRequest and Response ${msg_num:\d+} of ${all:\d+} contain SCell Addition for gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextModification
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    Verify That Message Fulfills Query
        ...     ${selected_SCells_in_UE_CON_MOD_REQ_B_B14}
        ...     message_alias=UEContextModificationRequest_${msg_num}
        ...     flow_alias=${flow_alias}

    Verify That Message Fulfills Query
        ...     ${selected_SCells_in_UE_CON_MOD_RES_B_B14}
        ...     message_alias=UEContextModificationResponse_${msg_num}
        ...     flow_alias=${flow_alias}

Verify that UEContextSetupRequest contains measConfig with A2 configuration for UE${ue_id:\d+}
    verify_if_measConfig_contains  EN-DC_UE${ue_id}  ContextSetupReq  ${ue_context_setup_string_filter_B_B15_A2_meas_configuration}
    Verify That Message Fulfills Query
    ...     ${candidateCellInfoListMN_during_SgNBAdditionReq_BB15}
    ...     message_alias=ContextSetupReq
    ...     flow_alias=EN-DC_UE${ue_id}

Verify that UEContextSetupResponse contains reconfigurationWithSync for UE${ue_id:\d+} BB15
    Verify That Message Fulfills Query
    ...     ${reconfigurationWithSync_before_HO_BB15}
    ...     message_alias=ContextSetupResp
    ...     flow_alias=EN-DC_UE${ue_id}

Verify that triggered A2 measurement report for BB15 contains requested parametrers for gNB${gNB_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=rRCTransfer
    ...     device=gNB${gnb_id}
    ...     protocol=X2AP

    verify_if_information_element_contains  uENRMeasurements  ${flow_alias}  RRCTransfer  0000008433D0CC0400

Verify that triggered A3 measurement report for BB15 contains requested parametrers for gNB${gNB_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=rRCTransfer
    ...     device=gNB${gnb_id}
    ...     protocol=X2AP

    verify_if_information_element_contains  uENRMeasurements  ${flow_alias}  RRCTransfer  0042008433C2020004365320

Verify that UEContextModificationRequest_${msg_num:\d+} of ${all:\d+} contains measConfig with A1 for SCell Add in NSA mode for gNB${gnb_id:\d+} B_B15
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextModification
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    verify_if_measConfig_contains  ${flow_alias}  UEContextModificationRequest_${msg_num}
    ...    ${ue_context_smodification_req_B15_A1_meas_configuration_after_ho}

Verify that UEContextModificationRequest_${msg_num:\d+} of ${all:\d+} contains measGapConfig release for gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextModification
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    Verify That Message Fulfills Query
        ...     ${meas_gap_release_after_HO_to_target_cell_B_B15}
        ...     message_alias=UEContextModificationRequest_${msg_num}
        ...     flow_alias=${flow_alias}

Verify that triggered A1 measurement report for BB15 contains requested parametrers for gNB${gNB_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=rRCTransfer
    ...     device=gNB${gnb_id}
    ...     protocol=X2AP

    verify_if_information_element_contains  uENRMeasurements  ${flow_alias}  RRCTransfer  0000008436D2D40400

Verify that UEContextModificationRequest and Response ${msg_num:\d+} of ${all:\d+} contain SCell Addition after HO for gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextModification
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    Verify That Message Fulfills Query
        ...     ${selected_SCells_for_2CC_CA_in_UE_CON_MOD_REQ_after_HO_BB15}
        ...     message_alias=UEContextModificationRequest_${msg_num}
        ...     flow_alias=${flow_alias}

    Verify That Message Fulfills Query
        ...     ${selected_SCells_for_sCellToAddModList_B_B15}
        ...     message_alias=UEContextModificationResponse_${msg_num}
        ...     flow_alias=${flow_alias}

Verify That UEContextModificationRequest_${msg_num:\d+} Of ${all:\d+} Contains MeasConfig With A1 A3 A5 Removal After HO For GNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextModification
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    verify_if_measConfig_contains_when_key_not_unique_inside_container  ${flow_alias}  UEContextModificationRequest_${msg_num}
    ...    ${ue_context_modification_string_filter_C_B28}  0
