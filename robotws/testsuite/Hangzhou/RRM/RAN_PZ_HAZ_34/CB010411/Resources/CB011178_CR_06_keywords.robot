*** Settings ***
Documentation
...   Author: Ding Binmei
...   Description: Test case steps implementation


*** Keywords ***
S1 Remove sCellAdditionMethod and verify no CA
    [Documentation]  Author: Ding Binmei
    ...        1.1 Remove NRREL.sCellAdditionMethod and sCellOperationalMode
    ...        1.2 Verify No CA exist
    Log to console    ======S1 Remove sCellAdditionMethod and verify no CA======
    &{dict_params_to_modify}    Create dictionary
    &{dict_remove_sCellAdditionMethod}    Create dictionary    sCellAdditionMethod=${None}    sCellOperationalMode=${None}
    ${list_params_modify}    create list

    FOR    ${scell_index}    IN    @{SCELL_ID_DL_ADD}
        ${dict_nrrel_update}    cloud_nrrel_operations.get_nrrel_params_for_online_update_cloud    source_cell_id=${PCELL_ID}
        ...    neighbor_cell_id=${scell_index}    dict_exp_config=${dict_remove_sCellAdditionMethod}
        ${list_params_modify}    combine lists    ${list_params_modify}    ${dict_nrrel_update['param_to_del']}
    END
    Set to dictionary    ${dict_params_to_modify}    param_to_del=${list_params_modify}
    cloud_online_modify.online_modify_for_params_update_with_non_provision_method    params_to_modify=${dict_params_to_modify}
    common_setup_teardown.Aic Close all connection
    common_setup_teardown.Aic Check CU and DUs Onair
    ca_specifical_step.L3 call with UL or DL CA exist    cell_index=${CELL_INDEX_LIST}
    ...    scell_index_ul=${None}    scell_index_dl=${None}
    ...    exp_ul_indiv=${EXP_UL_INDIV_NO_CA}    exp_dl_indiv=${EXP_DL_INDIV_NO_CA}
    ...    target_avg_percent=${TPUT_AVG_PERCENT_COMMON}    min_percent=${TPUT_MIN_PERCENT_COMMON}
    ...    tcpdump_log_name=S1_DL_UL_No_CA    is_need_to_stop_traffic=${True}
    ...    customized_log_name=S1_L3_call_No_CA
    ...    actBufferBasedScellAddition=oneShot_Dl_Fr1        scell_addition_method=blind
    ...    is_analysis_log_captured=${IS_LOG_CAPTURED_WHEN_CHECK_TPUT_FAILED}

S2 Add back sCellAdditionMethod and verify UL DL CA is OK
    [Documentation]  Author: Ding Binmei
    ...    2.1 Add sCellAdditionMethod as blind, sCellOperationalMode as dlAndUl for scell with UL CA exist
    ...    2.2 Add sCellAdditionMethod as blind, sCellOperationalMode as dlOnly for other scells
    ...    2.3 Verify both UL DL CA exist
    Log to console    ======S2 Add back sCellAdditionMethod and verify UL DL CA is OK======
    &{dict_params_to_modify}    Create dictionary
    ${list_params_modify}    run keyword if  ${SCELL_ID_UL_ADD}    _NRRel_For_Sell_UL_Support
    ...    ELSE    Create list
    &{dict_add_sCellAdditionMethod_scell_exclude_ul}    Create dictionary    sCellAdditionMethod=blind    sCellOperationalMode=dlOnly

    ${scell_ids_exclude_ul}    run keyword if  ${SCELL_ID_UL_ADD}
    ...         Evaluate    list(set(${SCELL_ID_DL_ADD})-set(${SCELL_ID_UL_ADD}))
    ...    ELSE          Evaluate    list(set(${SCELL_ID_DL_ADD}))

    FOR    ${scell_index}    IN    @{scell_ids_exclude_ul}
        ${dict_nrrel_update}    cloud_nrrel_operations.get_nrrel_params_for_online_update_cloud    source_cell_id=${PCELL_ID}
        ...    neighbor_cell_id=${scell_index}    dict_exp_config=${dict_add_sCellAdditionMethod_scell_exclude_ul}
        ${list_params_modify}    combine lists    ${list_params_modify}    ${dict_nrrel_update['param_to_add']}
    END
    Set to dictionary    ${dict_params_to_modify}    param_to_add=${list_params_modify}
    cloud_online_modify.online_modify_for_params_update_with_non_provision_method    params_to_modify=${dict_params_to_modify}
    common_setup_teardown.Aic Close all connection
    common_setup_teardown.Aic Check CU and DUs Onair
    ca_specifical_step.L3 call with UL or DL CA exist    cell_index=${CELL_INDEX_LIST}
    ...    exp_ul_indiv=${EXP_UL_INDIV}    exp_dl_indiv=${EXP_DL_INDIV}
    ...    target_avg_percent=${TPUT_AVG_PERCENT_COMMON}    min_percent=${TPUT_MIN_PERCENT_COMMON}
    ...    tcpdump_log_name=S2_UL_DL_CA_after_add_back_scellAdditionMethod    is_need_to_stop_traffic=${True}
    ...    customized_log_name=S2_L3_call_UL_DL_CA
    ...    actBufferBasedScellAddition=oneShot_Dl_Fr1        scell_addition_method=blind
    ...    is_analysis_log_captured=${IS_LOG_CAPTURED_WHEN_CHECK_TPUT_FAILED}

_NRRel_For_Sell_UL_Support
    [Documentation]  Author: Dandan Fang
    ...     use to get params for ulca.
    ${list_params_modify}    create list
    &{dict_add_sCellAdditionMethod_scell_ul}    Create dictionary    sCellAdditionMethod=blind    sCellOperationalMode=dlAndUl
    FOR    ${scell_index}    IN    @{SCELL_ID_UL_ADD}
        ${dict_nrrel_update}    cloud_nrrel_operations.get_nrrel_params_for_online_update_cloud    source_cell_id=${PCELL_ID}
        ...    neighbor_cell_id=${scell_index}    dict_exp_config=${dict_add_sCellAdditionMethod_scell_ul}
        ${list_params_modify}    combine lists    ${list_params_modify}    ${dict_nrrel_update['param_to_add']}
    END
    [Return]   ${list_params_modify}

S3 Remove NRREL and verify no CA exists
    [Documentation]  Author: Ding Binmei
    ...       a). Verify Pcell lock unlock happened---Not to check in cloud, as status changes too fast.
    ...       b). Verify no dl tput for scell
    Log to console    ======S3 Remove NRREL and verify no CA exists======
    ${list_params_to_delete}    create list
    FOR    ${scell_index}    IN    @{SCELL_ID_DL_ADD}
        ${delete_nrrel_mo_rest_api}    cloud_nrrel_operations.get_remove_nrrel_mo_for_online_update_cloud    source_cell_id=${PCELL_ID}
        ...    neighbor_cell_id=${scell_index}
        ${list_params_to_delete}    combine lists    ${list_params_to_delete}    ${delete_nrrel_mo_rest_api}
    END
    cloud_online_modify.delete_mo_on_cu    list_mo_to_delete=${list_params_to_delete}
    common_setup_teardown.Aic Close all connection
    common_setup_teardown.Aic Check CU and DUs Onair
    ${file_name_f1ap_check_ca}    Set variable    S3_DL_UL_No_CA_when_delete_nrrel
    run keyword and continue on failure  ca_specifical_step.L3 call with UL or DL CA exist    cell_index=${CELL_INDEX_LIST}
    ...    scell_index_ul=${None}    scell_index_dl=${None}
    ...    exp_ul_indiv=${EXP_UL_INDIV_NO_CA}   exp_dl_indiv=${EXP_DL_INDIV_NO_CA}
    ...    target_avg_percent=${TPUT_AVG_PERCENT_COMMON}    min_percent=${TPUT_MIN_PERCENT_COMMON}
    ...    tcpdump_log_name=${file_name_f1ap_check_ca}    is_need_to_stop_traffic=${True}
    ...    customized_log_name=S3_L3_call_No_CA
    ...    actBufferBasedScellAddition=oneShot_Dl_Fr1        scell_addition_method=blind
    ...    is_analysis_log_captured=${IS_LOG_CAPTURED_WHEN_CHECK_TPUT_FAILED}

S4 Add back NRREL and verify UL DL CA is OK
    [Documentation]  Author: Ding Binmei
    [Arguments]    ${ca_group_mapping}=${CA_GROUP_MAPPING}
    Log to console    ======S4 Add back NRREL and verify UL DL CA is OK======
    CB010411_keywords.Prepare NRREL under specific cell for Cloud    ca_group_mapping=${ca_group_mapping}
    run keyword and continue on failure  ca_specifical_step.L3 call with UL or DL CA exist    cell_index=${CELL_INDEX_LIST}
    ...     exp_ul_indiv=${EXP_UL_INDIV}    exp_dl_indiv=${EXP_DL_INDIV}
    ...    target_avg_percent=${TPUT_AVG_PERCENT_COMMON}    min_percent=${TPUT_MIN_PERCENT_COMMON}
    ...    tcpdump_log_name=S4_DL_UL_CA_when_NRREL_Added_back    is_need_to_stop_traffic=${True}
    ...    customized_log_name=S4_L3_call_UL_DL_CA
    ...    actBufferBasedScellAddition=oneShot_Dl_Fr1        scell_addition_method=blind
