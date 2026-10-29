*** Settings ***
Documentation    This is the regression cases robot for supercell function parity in cloud feature CB012219.

Resource     testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB010413/Resources/CB010413_CB08985_keywords.robot
Force Tags        5G_RRM    PY310    RF50

Suite Setup    CB012219 Suite preparation
Suite Teardown    run keyword and ignore error    Aic Suite teardown

*** Variables ***
${DL_TPUT_IPERF}     3200M

*** Test Cases ***
CB012219-CR-G_01_CB008985-CA_T-T_Single_UE_connection_setup_and_DL_UL_data_scheduling_in_SA_option_2_with_2_supercells
    [Documentation]    Author: Lingxue Cui
    ...    This case verify the setup of 2 supercells, for each contains 3 subcells.
    ...    T+T CA is setup between 2 supercells. Scell addition method is covBasedA1+bufferBased.
    ...    UE switch between different subcells and verify the tput is not interrupted.
    ...    Verify BF change counter after UE switch (BF Counter not available for Scell).
    [Setup]    CB012219 Case Setup
    ${scf_file_path}    vdu.get_current_plan_file  local_dir_path=${TS_CASE_LOG_PATH}
    ...    filename=vdu_scf_case_setup.xml  vdu_connection=${DU_CONNECTION}

    Block whole attenuator ports for testline    attenuator_out_ports=${PA_OUT_PORTS}
    ...     attenuator_rows=${PA_ROWS}    attenuator_max_column_num=${PA_MAX_COLUMN_NUM}
    ${candidate_subcells_all}    Create List
    ${subcell_mapping_list}    create list
    FOR    ${nrcell}    IN    @{CELL_INDEX_LIST}
        ${subcell_mapping}    scf_analysis.get_mapping_relations_between_subcellId_and_rmodIdx    lcr_id=${nrcell}    scf_file_path=${scf_file_path}
        ${candidate_subcell_list}    Generate random subcell numbers    total_subcell_number=${3}    count=${2}
        ${subcell_mapping_list}    Combine Lists    ${subcell_mapping_list}    ${subcell_mapping}
        Append To List    ${candidate_subcells_all}    ${candidate_subcell_list}
        Initialize RU ports of PA for specific subcell    subcell_id=${candidate_subcell_list[${0}]}    subcell_mapping=${subcell_mapping}
        ...   exp_pa_value=${10}
    END

    L3call with Supercell CA    customized_log_name=L3call_with_supercell_CA    is_need_to_stop_traffic=${False}

    ${counter_pre_timestamp}    Waiting time for new counter update period For Cloud   bts_type=du
    ${counter_list}    Create List
    FOR    ${i}    ${nrcell}    IN ENUMERATE    @{CELL_INDEX_LIST}
        ${source_subcell}    Set Variable    ${candidate_subcells_all[${i}][${0}]}
        ${target_subcell}    Set Variable    ${candidate_subcells_all[${i}][${1}]}
        ${subcell_mapping}    scf_analysis.get_mapping_relations_between_subcellId_and_rmodIdx    lcr_id=${nrcell}    scf_file_path=${scf_file_path}
        ${counter_subcell_switch}    run keyword if    ${nrcell}==${PCELL_ID}
        ...    Generate counter list for subcell switch    candidate_subcell_list=${candidate_subcells_all[${i}]}
        ...    expect_value=${1}    cell_index=${nrcell}
        ${counter_list}    run keyword if    ${nrcell}==${PCELL_ID}    Combine Lists    ${counter_list}    ${counter_subcell_switch}
        ...    ELSE    set variable    ${counter_list}

        Adjust PA to trigger subcell switch  source_subcell_id=${source_subcell}  target_subcell_id=${target_subcell}
        ...    subcell_mapping=${subcell_mapping}
        run keyword and continue on failure  Verify Thput reach expectation
        ...    customized_log_name=Tput_after_subcell_switch_from_NRCELL-${nrcell}_${source_subcell}_to_${target_subcell}
    END
    ${counter_post_timestamp}    Waiting time for new counter update period For Cloud   bts_type=du
    Check Counter Value match expectations    counter_list=${counter_list}    bts_type=du
    ...    start_time_lower_limit=${counter_pre_timestamp['log_generator_timestamp']}
    ...    start_time_upper_limit=${counter_post_timestamp['log_generator_timestamp']}
    [Teardown]    run keyword and ignore error  Aic Common case teardown    pa_values_mapping=${INIT_PA}

CB012219-CR-G_11_CB008985-SiSo_Operations
    [Setup]    CB012219 Case Setup
    Initialize attenuator values for testline    if_change_ENB_PA=${True}    NSA_SA=SA    pa_values_mapping=${INIT_PA}
    L3call with Supercell CA    is_need_to_stop_traffic=${True}

    Operation NRCELL block unblock one by one    cells_list=${SUPERCELLS}    customized_log_name=Supercell_L3call
    Operation RMOD lock unlock one by one    rmods_list=${SUPERCELL_RMODS}    customized_log_name=Supercell_L3call
    Operation RMOD reset one by one    rmods_list=${SUPERCELL_RMODS}    customized_log_name=Supercell_L3call
    Operation RANNIC reset one by one    customized_log_name=Supercell_L3call    is_l3call_needed=${True}

    [Teardown]    run keyword and ignore error   Aic Common case teardown    pa_values_mapping=${INIT_PA}

CB012219_CR_G_12_CB008985_Online_Modification_of_Subcell_number
    [Setup]    CB012219 Case Setup    cu_scf_template_path=${CU_SCF_TEMPLATE_PATH}    du_scf_template_path=${DU_SCF_TEMPLATE_PATH}
    L3call with Supercell CA    is_need_to_stop_traffic=${True}

    FOR    ${cell_id}    IN    @{SUPERCELLS}
        log to console    \n Change subcell number of NRCELL-${cell_id} to 2.
        Add list of allowed alarms    allowed_faults_ids=7504,7505,4405,4681
        Reduce subcell number in Supercell    lcr_id=${cell_id}    cell_group_id=${cell_id}    target_subcell_number=${2}
        Aic Check CU and DUs Onair
        Remove list of allowed alarms    allowed_faults_ids=7504,7505,4405,4681
        L3call with Supercell CA    is_need_to_stop_traffic=${True}    customized_log_name=NRCELL-${cell_id}_2subcells
    END

    FOR    ${cell_id}    IN    @{SUPERCELLS}
        log to console    \n Change NRCELL-${cell_id} to normal cell.
        Add list of allowed alarms    allowed_faults_ids=7504,7505,4405,4681
        Switch supercell to normal cell    cell_id=${cell_id}    cell_group_id=${cell_id}
        Aic Check CU and DUs Onair
        Remove list of allowed alarms    allowed_faults_ids=7504,7505,4405,4681
        L3call with Supercell CA    is_need_to_stop_traffic=${True}    customized_log_name=NRCELL-${cell_id}_normalCell
    END
    [Teardown]    run keyword and ignore error  Aic Common case teardown    pa_values_mapping=${INIT_PA}

*** Keywords ***
CB012219 Suite preparation
    [Arguments]
    ...    ${gnb_index}=${0}
    ...    ${is_prepare_ue_needed}=${True}    ${detach_request}=${True}    ${ue_index}=${0}

    Import NIDD variables for 12219
    &{dict_cu_parameters}    create dictionary    param_to_del=${CU_SCF_DELETE_CA}  param_to_upd=${CU_SCF_MODIFY_CA}  param_to_add=${CU_SCF_ADD_CA}
    &{dict_du_parameters}    create dictionary    param_to_del=${DU_SCF_DELETE_CA}  param_to_upd=${DU_SCF_MODIFY_CA}  param_to_add=${DU_SCF_ADD_CA}
    ${list_du_parameters}    create list    ${dict_du_parameters}

    Aic Suite common setup preparation    gnb_index=${gnb_index}
    ...    cu_dict_params_modify=${dict_cu_parameters}    cu_scf_file_path=${CU_SCF_TEMPLATE_PATH}
    ...    du_scf_params_modify_list=${list_du_parameters}    du_scf_file_path_list=${LIST_DU_SCF_FILE_PATH}
    ...    is_prepare_ue_needed=${is_prepare_ue_needed}    detach_request=${detach_request}    ue_index=${ue_index}
    ...    pa_values_mapping=${INIT_PA}    attenuator_out_ports=${PA_OUT_PORTS}
    ${vcu_program}    Get vCU Program via rest api    connection=${CU_CONNECTION}
    Set Suite Variable    ${PROGRAM}    ${vcu_program}

CB012219 Case Setup
    [Arguments]
    ...    ${ca_group_mapping}=${CA_GROUP_MAPPING}
    ...    ${gnb_index}=${0}   ${du_index}=${0}
    ...    ${pa_values_mapping}=${INIT_PA}
    ...    ${du_params_modify_via_api}=&{EMPTY_DICT}
    ...    ${cu_scf_template_path}=${None}
    ...    ${du_scf_template_path}=${None}
    ...    ${cu_parameter_update}=${CU_SCF_MODIFY_CA}    ${cu_parameter_add}=${CU_SCF_ADD_CA}    ${cu_parameter_delete}=${CU_SCF_DELETE_CA}
    ...    ${du_parameter_update}=${DU_SCF_MODIFY_CA}    ${du_parameter_add}=${DU_SCF_ADD_CA}    ${du_parameter_delete}=${DU_SCF_DELETE_CA}
    ...    ${NSA_SA}=SA    ${serving_cell_id}=${1}
    ...    ${fail_with_alarms}=${True}    ${allowed_faults_ids}=${None}

    Decode CA group mapping    ca_group_mapping_in_use=${ca_group_mapping}    is_called_in_suite_level=${False}
    Set Test Variable    ${PCELL_RU_LIST}    ${CA_GROUP_MAPPING['pcell_ru_list']}
    Set Test Variable    ${SCELL_RU_LIST}    ${CA_GROUP_MAPPING['scell_ru_list'][${0}]}

    # build up parameters for CA NRREL modify
    wait until keyword succeeds    1min    10s
    ...    Connect to vcu via rest api    gnb_index=${gnb_index}    connection=OAM_CU${gnb_index}
    &{cu_params_to_modify}    get_nrrel_params_for_online_update_based_on_ca_group_mapping_no_increasePUSCHPrepTimeULCA
    ...    ca_group_mapping=${ca_group_mapping}    program=${PROGRAM}    bts_type=cu    is_nrrel_id_needed=True
    Run Keyword And Ignore Error    Teardown vcu connection    connection=OAM_CU${gnb_index}
    ${du_index_list}    Create list    ${du_index}
    @{du_scf_file_path_list}    Run keyword if    '${du_scf_template_path}'=='${None}'    Create list
    ...    ELSE    Create list    ${du_scf_template_path}

    &{cu_scf_dict_params_modify}    run keyword if    '${cu_scf_template_path}'=='${None}'    Create Dictionary
    ...    ELSE    create dictionary    param_to_del=${cu_parameter_delete}    param_to_upd=${cu_parameter_update}  param_to_add=${cu_parameter_add}
    &{du_scf_dict_params_modify}    run keyword if    '${du_scf_template_path}'!='${None}'
    ...    create dictionary    param_to_del=${du_parameter_delete}    param_to_upd=${du_parameter_update}  param_to_add=${du_parameter_add}
    @{du_scf_params_modify_list}    run keyword if    '${du_scf_template_path}'=='${None}'    Create List
    ...    ELSE    Create list    ${du_scf_dict_params_modify}

    Aic Common case setup
    ...    gnb_index=${gnb_index}
    ...    cu_params_modify_dict_via_api=${cu_params_to_modify}    du_params_modify_via_api_list=${du_params_modify_via_api}
    ...    cu_scf_dict_params_modify=${cu_scf_dict_params_modify}    cu_scf_file_path=${cu_scf_template_path}
    ...    du_scf_params_modify_list=${du_scf_params_modify_list}    du_scf_file_path_list=${du_scf_file_path_list}
    ...    is_scf_backup_needed=${True}    pa_values_mapping=${pa_values_mapping}
    ...    if_change_ENB_PA=${True}    NSA_SA=${NSA_SA}
    ...    fail_with_alarms=${fail_with_alarms}    allowed_faults_ids=${allowed_faults_ids}

    run keyword if    '${NSA_SA}'=='NSA'
    ...    Change status for parameter cellBarred on GNB DU    exp_status=barred   list_cell_ids=all
    ...    gnb_index=${gnb_index}    du_index=${du_index}   connection=${DU_CONNECTION}
    ...    ELSE    Change status for parameter cellBarred on GNB DU    exp_status=notBarred   list_cell_ids=${serving_cell_id}
    ...    gnb_index=${gnb_index}    du_index=${du_index}   connection=${DU_CONNECTION}
