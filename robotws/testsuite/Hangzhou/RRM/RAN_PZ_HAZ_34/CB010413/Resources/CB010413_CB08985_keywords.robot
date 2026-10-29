*** Settings ***
Documentation    This is keyword file used for feature CB008985 parity in CB010413.

Resource     CB010413_CB008985_variables.robot
Resource     Counter_Id.robot
Variables    commissionings/HGZ/${testline_name}/__init__10413_8985.py
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/Cloud_VRAN40/common_setup_teardown.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/CA/Resources/CA_Common_New/ca_specifical_step.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/CA/Resources/CA_keywords.robot
Library      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/Cloud_VRAN40/python/cloud_online_modify.py
Library      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/Cloud_VRAN40/python/cloud_nrrel_operations.py
Library      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/CA/TestData/Parameters_modify_lib.py    WITH NAME    param_modify_lib
Library      testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB010413/TestData/scf_analysis_lib.py    WITH NAME    scf_analysis

*** Keywords ***
Import NIDD variables for 8985
    [Documentation]    Author: Lingxue Cui
    ...    import common variable for CB010413-8985.
    #This parameter is open by taf to indicate the absolute path for commission folder
    get variable value  ${commissionings_path}
    ${is_tl_delta_file_exists}    Run keyword and return status    File should exist    ${commissionings_path}/HGZ/${testline_name}/TLDelta.py
    Run keyword if    ${is_tl_delta_file_exists}
    ...    Import variables  ${commissionings_path}/HGZ/${testline_name}/TLDelta.py
    import variables    ${CURDIR}/../TestData/NIDD_modify_scf.py

Suite preparation
    [Documentation]    Author: Lingxue Cui
    ...    Will do vCU and vDU commission, check cell on-air, PA initialization and prepare UE.
    [Arguments]    ${gnb_index}=${0}
    ...    ${is_prepare_ue_needed}=${True}    ${detach_request}=${True}    ${ue_index}=${0}

    Import NIDD variables for 8985

    &{dict_cu_parameters}    create dictionary    param_to_del=${CU_SCF_DELETE}    param_to_upd=${CU_SCF_MODIFY}    param_to_add=${DU_SCF_ADD}
    &{dict_du_parameters}    create dictionary    param_to_del=${DU_SCF_DELETE}    param_to_upd=${DU_SCF_MODIFY}    param_to_add=${DU_SCF_ADD}
    ${list_du_parameters}    create list    ${dict_du_parameters}

    Aic Suite common setup preparation    gnb_index=${gnb_index}
    ...    cu_dict_params_modify=${dict_cu_parameters}    cu_scf_file_path=${CU_SCF_TEMPLATE_PATH}
    ...    du_scf_params_modify_list=${list_du_parameters}    du_scf_file_path_list=${LIST_DU_SCF_FILE_PATH}
    ...    is_prepare_ue_needed=${is_prepare_ue_needed}    detach_request=${detach_request}    ue_index=${ue_index}
    ...    pa_values_mapping=${INIT_PA}    attenuator_out_ports=${PA_OUT_PORTS}

Case setup
    [Documentation]    Author: Lingxue Cui
    [Arguments]    ${subcell_number}=${6}    ${gnb_index}=${0}    ${du_index}=${0}    ${pa_values_mapping}=${INIT_PA}
    ...    ${cu_parameter_update}=${CU_SCF_MODIFY}    ${cu_parameter_add}=${CU_SCF_ADD}    ${cu_parameter_delete}=${CU_SCF_DELETE}
    ...    ${du_parameter_update}=${DU_SCF_MODIFY}    ${du_parameter_add}=${DU_SCF_ADD}    ${du_parameter_delete}=${DU_SCF_DELETE}
    ...    ${cu_scf_template_path}=${CU_SCF_TEMPLATE_PATH}
    ...    ${du_scf_template_path}=${DU_SCF_TEMPLATE_PATH}
    ...    ${cu_params_modify_dict_via_api}=&{EMPTY_DICT}    ${du_params_modify_via_api_list}=@{EMPTY_LIST}
    ...    ${lcr_id}=${1}    ${serving_cell_id}=${1}    ${NSA_SA}=SA
    ...    ${fail_with_alarms}=${True}    ${allowed_faults_ids}=${None}

    set test variable    ${NUM_OF_SUBCELLS}    ${subcell_number}
    ${du_index_list}    Create list    ${du_index}

    &{cu_scf_dict_params_modify}    create dictionary  param_to_del=${cu_parameter_delete}    param_to_upd=${cu_parameter_update}
    ...    param_to_add=${cu_parameter_add}
    &{du_scf_dict_params_modify}    create dictionary  param_to_del=${du_parameter_delete}    param_to_upd=${du_parameter_update}
    ...    param_to_add=${du_parameter_add}

    @{du_scf_params_modify_list}    Run keyword if    ${du_scf_dict_params_modify}    Create list    ${du_scf_dict_params_modify}
    ...    ELSE    Create list
    @{du_scf_file_path_list}    Run keyword if    '${du_scf_template_path}'=='${None}'    Create list
    ...    ELSE    Create list    ${du_scf_template_path}
    ${cu_connection}    ${du_connection_list}    common_setup_teardown.Create CU And DU Connections    gnb_index=${gnb_index}
    ...    du_index_list=${du_index_list}

    Aic Common case setup
    ...    gnb_index=${gnb_index}
    ...    cu_params_modify_dict_via_api=${cu_params_modify_dict_via_api}    du_params_modify_via_api_list=${du_params_modify_via_api_list}
    ...    cu_scf_dict_params_modify=${cu_scf_dict_params_modify}    cu_scf_file_path=${cu_scf_template_path}
    ...    du_scf_params_modify_list=${du_scf_params_modify_list}    du_scf_file_path_list=${du_scf_file_path_list}
    ...    is_scf_backup_needed=${True}    pa_values_mapping=${pa_values_mapping}
    ...    if_change_ENB_PA=${True}    NSA_SA=${NSA_SA}
    ...    fail_with_alarms=${fail_with_alarms}    allowed_faults_ids=${allowed_faults_ids}

    run keyword if    '${NSA_SA}'=='NSA'
    ...    Change status for parameter cellBarred on GNB DU    exp_status=barred   list_cell_ids=all
    ...    gnb_index=${gnb_index}    du_index=${du_index}   connection=${du_connection_list[0]}
    ...    ELSE    Change status for parameter cellBarred on GNB DU    exp_status=notBarred   list_cell_ids=${serving_cell_id}
    ...    gnb_index=${gnb_index}    du_index=${du_index}   connection=${du_connection_list[0]}

    ${scf_file_path}    vdu.get_current_plan_file  local_dir_path=${TS_CASE_LOG_PATH}
    ...    filename=vdu_scf_case_setup.xml  vdu_connection=${du_connection_list[0]}
    ${subcell_mapping}    scf_analysis.get_mapping_relations_between_subcellId_and_rmodIdx    lcr_id=${lcr_id}    scf_file_path=${scf_file_path}
    set test variable  ${SUBCELL_MAPPING_TO_RMOD}    ${subcell_mapping}

L3call with DL or UL tput
    [Documentation]    Author: Cui Lingxue
    [Arguments]    ${prepare_ue_needed}=${False}    ${4G_check}=${False}    ${cell_index}=1
    ...    ${direction}=both    ${iperf_ul_tput}=${UL_TPUT_IPERF}    ${iperf_dl_tput}=${DL_TPUT_IPERF}
    ...    ${exp_ul}=${EXP_UL_TPUT}    ${exp_dl}=${EXP_DL_TPUT}
    ...    ${traffic_duration}=${DURATION_OF_TRAFFIC}    ${check_duration}=${DURATION_OF_TPUT_CHECK}
    ...    ${customized_log_name}=L3_Call_tput    ${cu_connection}=${CU_CONNECTION}    ${du_connection}=${DU_CONNECTION}
    ...    ${actCarrierAggregation}=${False}    ${cell_mapping}=${NR_CELL_ID_MAPPING}
    ...    ${is_need_to_stop_traffic}=${False}    ${is_need_to_detach_ue}=${False}    ${NSA_SA}=SA

    run keyword if    '${NSA_SA}'=='NSA'    Start X2 log capture from eNB    log_name=${customized_log_name}_eNB
    Start capture F1AP log   gnb_id=${0}
    ${attach_status}    run keyword and return status    Retry commercial ue attach if failed
    ...    prepare_ue_needed=${prepare_ue_needed}    4G_check=${4G_check}    connection=${cu_connection}
    ${ute_log_path_f1ap}    logs.Stop capture F1AP log    gnb_id=${0}    target_dir=${TS_CASE_LOG_PATH}
    ${ute_log_path_x2ap}    run keyword if    '${NSA_SA}'=='NSA'
    ...    Stop X2 log capture from eNB    log_name=${customized_log_name}_eNB    log_path=${TS_CASE_LOG_PATH}
    run keyword if    '${attach_status}'=='${False}'    Fail

    Start data transfer based on direction    data_transfer_direction=${direction}    ul_tput=${iperf_ul_tput}    dl_tput=${iperf_dl_tput}
    ...    duration=${traffic_duration}
    ${tput_log_path}    Cloud Standard Capturing Kubectl Throughput    duration=${check_duration}    check_tput_ignore_time=30s
    check tput via power ue optimized
    ...    cell_index=${cell_index}    direction=${direction}
    ...    tput_log_path=${tput_log_path}    cell_mapping=${cell_mapping}
    ...    exp_ul=${exp_ul}    exp_dl=${exp_dl}    target_avg_percent=${TPUT_AVG_PERCENT_COMMON}    min_percent=${TPUT_MIN_PERCENT_COMMON}
    ...    customized_log_name=${customized_log_name}_${direction}    actCarrierAggregation=${actCarrierAggregation}
    ...    connection=${du_connection}    is_need_to_fail_keyword=${True}    is_analysis_log_captured=${True}
    [Teardown]    run keyword and ignore error    run keywords    Stop Tcpdump via collector    collector_name=${customized_log_name}
    ...    AND    run keyword if    '${NSA_SA}'=='NSA'
    ...               Stop X2 log capture from eNB    log_name=${customized_log_name}_eNB    overwrite_local_file=${False}
    ...    AND    run keyword if    ${is_need_to_stop_traffic}    Stop data transfer based on direction
    ...               data_transfer_direction=${direction}
    ...    AND    run keyword if    ${is_need_to_detach_ue}    Retry commercial ue detach if failed

Get current value of numOfSuperSubCells and numberOfTransmittedSsBlocks
    [Documentation]    Author: Cui Lingxue
    ...    Get current value of NIDD parameters numOfSuperSubCells and numberOfTransmittedSsBlocks from vDU WebEM.
    [Arguments]    ${cell_id}=${1}    ${cell_group_id}=${1}    ${du_connection}=${DU_CONNECTION}
    ${dn_du_cell}    set variable    ${vDU_DN_NRBTS}/NRCELL-${cell_id}
    ${dn_du_cell_group}    set variable    ${vDU_DN_NRBTS}/NRCELLGRP-${cell_group_id}
    ${subcell}    vdu.search_parameter_of_current_plan    mo_dn=${dn_du_cell}
    ...    para_name=numOfSuperSubCells
    ...    vdu_connection=${du_connection}
    ${ssb_number}    vdu.search_parameter_of_current_plan    mo_dn=${dn_du_cell_group}
    ...    para_name=numberOfTransmittedSsBlocks
    ...    vdu_connection=${du_connection}
    [Return]  ${subcell}  ${ssb_number}

Verify the subcell number and numberOfTransmittedSsBlocks
    [Documentation]    Author: Lingxue Cui
    ...    Get current value of numberOfTransmittedSsBlocks and compare with subcell number.
    [Arguments]    ${cell_id}=${1}    ${cell_group_id}=${1}    ${du_connection}=${DU_CONNECTION}
    ${subcell}  ${ssb_number}  Get current value of numOfSuperSubCells and numberOfTransmittedSsBlocks  cell_id=${cell_id}
    ...  cell_group_id=${cell_group_id}  du_connection=${du_connection}
    should be equal as integers  ${subcell}  ${NUM_OF_SUBCELLS}
    should be equal as strings  ${ssb_number}  ${NUM_OF_SUBCELLS} beams

Switch supercell to normal cell
    [Documentation]    Author: Cui Lingxue
    ...    Change supercell to normal cell via delta plan method. vDU reset is expected.
    ...    Parameters need to modify:
    ...      1. delete additional channel groups of cell mapping
    ...      2. modify actSuperCell from true to false
    ...      3. modify numberOfTransmittedSsBlocks to 1 beam
    [Arguments]    ${cell_id}=${1}    ${cell_group_id}=${1}
    ...    ${du_connection}=${DU_CONNECTION}
    ${timestamp}    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    ${scf_file_path}    vdu.get_current_plan_file    local_dir_path=${TS_CASE_LOG_PATH}    filename=active_scf_vdu_${timestamp}.xml
    ...    vdu_connection=${du_connection}
    ${channel_group_list}    scf_analysis.get_all_channel_groups_under_specific_cell_from_scf    lcr_id=${cell_id}    scf_file_path=${scf_file_path}
    sort list    ${channel_group_list}
    remove from list    ${channel_group_list}    0

    ${list_objects_delete}    create list
    FOR    ${dn_channel_group}    IN    @{channel_group_list}
        ${dict_remove_channel_groups}    create dictionary    dist_name=${dn_channel_group}
        append to list    ${list_objects_delete}    ${dict_remove_channel_groups}
    END

    ${list_parameter_update}    create list
    ${dict_disable_supercell}    create dictionary    dist_name=${vDU_DN_NRBTS}/NRCELL-${cell_id}    parameter=actSuperCell    value=false
    ${dict_modify_numberOfTransmittedSsBlocks}    create dictionary    dist_name=${vDU_DN_NRBTS}/NRCELLGRP-${cell_group_id}
    ...    parameter=numberOfTransmittedSsBlocks    value=1 beam
    append to list  ${list_parameter_update}   ${dict_disable_supercell}  ${dict_modify_numberOfTransmittedSsBlocks}

    ${dict_du_parameters}    create dictionary      param_to_upd=${list_parameter_update}    object_to_del=${list_objects_delete}
    ${du_params_modify_list}    create list    ${dict_du_parameters}

    Online modify on cu du    du_params_modify_list=${du_params_modify_list}

Reduce subcell number in Supercell
    [Documentation]    Author: Lingxue Cui
    ...    Reduce subcell numbers by deleting channel groups under supercell associated CELLMAPPING-x/LCELNR-x.
    ...    The deleting order is from the largest channel group number.
    [Arguments]    ${target_subcell_number}    ${lcr_id}=${1}    ${cell_group_id}=${1}
    ...    ${du_connection}=${DU_CONNECTION}
    ${timestamp}    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    ${scf_file_path}    vdu.get_current_plan_file    local_dir_path=${TS_CASE_LOG_PATH}    filename=active_scf_vdu_${timestamp}.xml
    ...    vdu_connection=${du_connection}
    ${channel_group_list}    scf_analysis.get_all_channel_groups_under_specific_cell_from_scf    lcr_id=${lcr_id}    scf_file_path=${scf_file_path}
    sort list    ${channel_group_list}
    repeat keyword  ${target_subcell_number}    remove from list    ${channel_group_list}    0

    ${list_objects_delete}    create list
    FOR    ${dn_channel_group}    IN    @{channel_group_list}
        ${dict_remove_channel_groups}    create dictionary    dist_name=${dn_channel_group}
        append to list    ${list_objects_delete}    ${dict_remove_channel_groups}
    END

    ${list_parameter_update}    create list
    ${dict_modify_numberOfTransmittedSsBlocks}    create dictionary    dist_name=${vDU_DN_NRBTS}/NRCELLGRP-${cell_group_id}
    ...    parameter=numberOfTransmittedSsBlocks    value=${target_subcell_number} beams
    append to list  ${list_parameter_update}   ${dict_modify_numberOfTransmittedSsBlocks}

    ${dict_du_parameters}    create dictionary      param_to_upd=${list_parameter_update}    object_to_del=${list_objects_delete}
    ${du_params_modify_list}    create list    ${dict_du_parameters}

    Online modify on cu du    du_params_modify_list=${du_params_modify_list}

Adjust PA to trigger subcell switch
    [Documentation]    Author: Lingxue Cui
    ...    Increase PA of source subcell to make radio condition bad, then decrease PA of target subcell to make radio condition good, to trigger
    ...    UE move to target subcell.
    ...    ${source_subcell_id}, ${target_subcell_id}: subcell id, starting from 0 and consecutive within supercell
    ...    ${subcell_mapping}: fetch by get_mapping_relations_between_subcellId_and_rmodIdx
    [Arguments]    ${source_subcell_id}    ${target_subcell_id}    ${subcell_mapping}=${SUBCELL_MAPPING_TO_RMOD}    ${gnb_index}=${0}
    ...    ${pa_value_bad}=${30}    ${pa_value_good}=${10}
    ${source_subcell_id}    evaluate    str(${source_subcell_id})
    ${target_subcell_id}    evaluate    str(${target_subcell_id})
    ${source_rmod_index}    set variable    ${subcell_mapping}[${source_subcell_id}][rmod_index]
    ${target_rmod_index}    set variable    ${subcell_mapping}[${target_subcell_id}][rmod_index]
    ${source_rmod_index}    evaluate    ${source_rmod_index}-1
    ${target_rmod_index}    evaluate    ${target_rmod_index}-1

    log to console    \n Adjust PA to trigger UE switch from subcell ${source_subcell_id} to ${target_subcell_id}.
    _set attenuator ports of specified RU to same value    exp_pa_value=${pa_value_good}    gnb_index=${gnb_index}
    ...    ru_index=${target_rmod_index}    is_enb=${False}
    _set attenuator ports of specified RU to same value    exp_pa_value=${pa_value_bad}    gnb_index=${gnb_index}
    ...    ru_index=${source_rmod_index}    is_enb=${False}

Generate random subcell numbers
    [Documentation]    Author: Lingxue Cui
    ...    Randomly pick ${count} numbers from all subcell IDs.
    ...    ${count}: number of pick
    [Arguments]    ${count}=${3}    ${total_subcell_number}=${NUM_OF_SUBCELLS}
    ${subcell_list}    create list
    FOR    ${subcell}    IN RANGE    ${total_subcell_number}
        append to list  ${subcell_list}    ${subcell}
    END
    ${candidate_subcell_list}    Evaluate   random.sample(${subcell_list}, ${count})    random
    [Return]    ${candidate_subcell_list}

Verify Thput reach expectation
    [Documentation]    Author: Cui Lingxue
    [Arguments]    ${cell_index}=1    ${direction}=both
    ...    ${exp_ul}=${EXP_UL_TPUT}    ${exp_dl}=${EXP_DL_TPUT}
    ...    ${check_duration}=${DURATION_OF_TPUT_CHECK}
    ...    ${customized_log_name}=L3_Call_tput    ${du_connection}=${DU_CONNECTION}
    ...    ${actCarrierAggregation}=${False}    ${cell_mapping}=${NR_CELL_ID_MAPPING}
    ...    ${is_need_to_stop_traffic}=${False}    ${is_need_to_detach_ue}=${False}

    ${tput_log_path}    Cloud Standard Capturing Kubectl Throughput    duration=${check_duration}    check_tput_ignore_time=30s
    check tput via power ue optimized
    ...    cell_index=${cell_index}    direction=${direction}
    ...    tput_log_path=${tput_log_path}    cell_mapping=${cell_mapping}
    ...    exp_ul=${exp_ul}    exp_dl=${exp_dl}    target_avg_percent=${TPUT_AVG_PERCENT_COMMON}    min_percent=${TPUT_MIN_PERCENT_COMMON}
    ...    customized_log_name=${customized_log_name}_${direction}    actCarrierAggregation=${actCarrierAggregation}
    ...    connection=${du_connection}    is_need_to_fail_keyword=${True}
    [Teardown]    run keywords    run keyword if    ${is_need_to_stop_traffic}    Stop data transfer based on direction
    ...    data_transfer_direction=${direction}
    ...    AND    run keyword if    ${is_need_to_detach_ue}    Retry commercial ue detach if failed

Initialize RU ports of PA for specific subcell
    [Documentation]    Author: Lingxue Cui
    [Arguments]    ${subcell_id}    ${exp_pa_value}    ${subcell_mapping}=${SUBCELL_MAPPING_TO_RMOD}
    ${subcell_id}    evaluate    str(${subcell_id})
    ${rmod_index}    set variable    ${subcell_mapping}[${subcell_id}][rmod_index]
    ${rmod_index}    evaluate    ${rmod_index}-1

    log to console    Initialize PA ports for RU ${rmod_index}.
    _set attenuator ports of specified RU to same value    exp_pa_value=${exp_pa_value}    gnb_index=${0}
    ...    ru_index=${rmod_index}    is_enb=${False}

Generate counter list for subcell switch
    [Documentation]    Author: Lingxue Cui
    ...    ${candidate_subcell_list}: list of subcells to be switched, should be in the order of switch sequence.
    ...    Return: corresponding counter ID list of each beam change. eg
    ...      eg. [{'count_all_values': True,
    ...            'counter_info': {'counter_id': 'M55305C03014',
    ...                             'dimension_dn': 'MRBTS-37241/NRBTS-37241/NRCELL-1'},
    ...            'expect_value': 1},
    ...            {'count_all_values': True,
    ...             'counter_info': {'counter_id': 'M55305C03018',
    ...                              'dimension_dn': 'MRBTS-37241/NRBTS-37241/NRCELL-1'},
    ...             'expect_value': 1}]
    [Arguments]    ${candidate_subcell_list}    ${cell_index}=${1}    ${expect_value}=${1}
    ${dimension_dn}    set variable    ${vDU_DN_NRBTS}/NRCELL-${cell_index}
    ${counter_list}    create list
    ${exit_index}    evaluate    len(${candidate_subcell_list}) - 2
    FOR    ${index}    ${subcell_id}    IN ENUMERATE   @{candidate_subcell_list}
        ${counter_id}    catenate    ${BEAM_CHANGE_${candidate_subcell_list[${index}]}_${candidate_subcell_list[${index+1}]}}
        ${counter_info}    create dictionary    counter_id=${counter_id}    dimension_dn=${dimension_dn}
        ${counter}   create dictionary    counter_info=${counter_info}    expect_value=${expect_value}    count_all_values=${True}
        append to list    ${counter_list}    ${counter}
        exit for loop if    ${index}==${exit_index}
    END
    [Return]    ${counter_list}

# 12219 related kw
Decode CA group mapping
    [Arguments]  ${ca_group_mapping_in_use}=${CA_GROUP_COMMON}    ${is_called_in_suite_level}=${False}
    ${pcell_id_list}    create list    ${ca_group_mapping_in_use['pcell_id']}
    ${CELL_INDEX_LIST}    combine lists    ${pcell_id_list}    ${ca_group_mapping_in_use['verify_scell_add_dl']}

    ${INIT_PA_VALUE}   Set variable    ${ca_group_mapping_in_use['init_pa_value']}
    ${EXP_UL_INDIV_NO_CA}  ${EXP_DL_INDIV_NO_CA}    _generate individual tput value for cells when no CA exist based on ca group mapping
    ...    ca_group_mapping=${ca_group_mapping_in_use}

    run keyword if    ${is_called_in_suite_level}    Run keywords
    ...    Set suite variable    ${CA_GROUP_MAPPING}    ${ca_group_mapping_in_use}    AND
    ...    Set suite variable    ${PCELL_ID}    ${ca_group_mapping_in_use['pcell_id']}    AND
    ...    Set suite variable    ${SCELL_ID_UL_ADD}    ${ca_group_mapping_in_use['verify_scell_add_ul']}    AND
    ...    Set suite variable    ${SCELL_ID_DL_ADD}    ${ca_group_mapping_in_use['verify_scell_add_dl']}    AND
    ...    Set suite variable    ${CELL_INDEX_LIST}    AND
    ...    Set suite variable    ${EXP_DL_INDIV}       ${ca_group_mapping_in_use['exp_dl_indiv']}       AND
    ...    Set suite variable    ${EXP_UL_INDIV}        ${ca_group_mapping_in_use['exp_ul_indiv']}     AND
    ...    Set suite variable    ${INIT_PA_VALUE}    AND
    ...    Set suite variable    ${EXP_UL_INDIV_NO_CA}    AND
    ...    Set suite variable    ${EXP_DL_INDIV_NO_CA}
    ...    ELSE    Run keywords
    ...    Set test variable    ${CA_GROUP_MAPPING}    ${ca_group_mapping_in_use}    AND
    ...    Set test variable    ${PCELL_ID}    ${ca_group_mapping_in_use['pcell_id']}    AND
    ...    Set test variable    ${SCELL_ID_UL_ADD}    ${ca_group_mapping_in_use['verify_scell_add_ul']}    AND
    ...    Set test variable    ${SCELL_ID_DL_ADD}    ${ca_group_mapping_in_use['verify_scell_add_dl']}    AND
    ...    Set test variable    ${CELL_INDEX_LIST}    AND
    ...    Set test variable    ${EXP_DL_INDIV}       ${ca_group_mapping_in_use['exp_dl_indiv']}     AND
    ...    Set test variable    ${EXP_UL_INDIV}       ${ca_group_mapping_in_use['exp_ul_indiv']}    AND
    ...    Set test variable    ${INIT_PA_VALUE}    AND
    ...    Set test variable    ${EXP_UL_INDIV_NO_CA}    AND
    ...    Set test variable    ${EXP_DL_INDIV_NO_CA}

Import NIDD variables for 12219
    [Documentation]    Author: Lingxue Cui
    ...    import common variable for CB012219-8985.
    #This parameter is open by taf to indicate the absolute path for commission folder
    get variable value  ${commissionings_path}

    ${is_tl_delta_file_exists}    Run keyword and return status    File should exist    ${commissionings_path}/HGZ/${testline_name}/TLDelta.py
    Run keyword if    ${is_tl_delta_file_exists}
    ...    Import variables  ${commissionings_path}/HGZ/${testline_name}/TLDelta.py
    import variables    ${commissionings_path}/HGZ/${testline_name}/__init__12219_8985.py
    import variables    ${CURDIR}/../TestData/CB012219_NIDD_modify_scf.py

L3call with Supercell CA
    [Arguments]    ${customized_log_name}=L3call_with_supercell_CA    ${is_need_to_stop_traffic}=${False}
    Run keyword and continue on failure    ca_specifical_step.L3 call with UL or DL CA exist    cell_index=${CELL_INDEX_LIST}
    ...    tcpdump_log_name=${customized_log_name}
    ...    customized_log_name=${customized_log_name}  NSA_SA=SA
    ...    actBufferBasedScellAddition=oneShot_Dl_Fr1        scell_addition_method=covBasedA1
    ...    target_avg_percent=${TPUT_AVG_PERCENT_COMMON}    min_percent=${TPUT_MIN_PERCENT_COMMON}
    ...    is_analysis_log_captured=${False}
    ...    protocol=udp    tput_duration=30s   process_num=${3}
    ...    is_need_to_stop_traffic=${is_need_to_stop_traffic}

Operation RMOD lock unlock one by one
    [Arguments]    ${rmods_list}    ${is_l3call_needed}=${True}    ${customized_log_name}=${None}
    ...    ${timeout}=1min     ${connection}=OAM_gnb0_du0

    FOR    ${rmod_index}    IN    @{rmods_list}
        log to console    Going to Lock RMOD ${rmod_index}
        Perform RMOD lock    rmods_list=${rmod_index}    timeout=${timeout}    connection=${connection}
        log to console    Going to Unlock RMOD ${rmod_index}
        Perform RMOD unlock    rmods_list=${rmod_index}    timeout=${timeout}    connection=${connection}
        run keyword and ignore error    Aic Close all connection
        Aic Check CU and DUs Onair
        run keyword and continue on failure    run keyword if    ${is_l3call_needed}
        ...    L3call with Supercell CA    customized_log_name=${customized_log_name}_after_RMOD_${rmod_index}_lock_unlock
        ...    is_need_to_stop_traffic=${True}
    END

Operation RMOD reset one by one
    [Arguments]    ${rmods_list}    ${is_l3call_needed}=${True}    ${customized_log_name}=${None}
    ...    ${timeout}=5min     ${connection}=OAM_gnb0_du0

    FOR    ${rmod_index}    IN    @{rmods_list}
        log to console    Going to Reset RMOD ${rmod_index}
        Perform reset RUs    rmods_list=${rmod_index}    timeout=${timeout}    connection=${connection}     expected_status=success

        run keyword and ignore error    Aic Close all connection
        Aic Check CU and DUs Onair
        run keyword and continue on failure    run keyword if    ${is_l3call_needed}
        ...    L3call with Supercell CA    customized_log_name=${customized_log_name}_after_RMOD_${rmod_index}_reset
        ...    is_need_to_stop_traffic=${True}
    END

Operation NRCELL block unblock one by one
    [Arguments]    ${cells_list}    ${is_l3call_needed}=${True}    ${customized_log_name}=${None}
    ...    ${timeout}=3min     ${connection}=OAM_gnb0_du0

    FOR    ${nrcell}    IN    @{cells_list}
        AlarmWatchdog.add_allow_alarms     fault_id=49
        log to console    Going to block NRCELL ${nrcell}
        Perform Cells block    cells_list=${nrcell}    timeout=${timeout}    timeout_cell_blocked=${timeout}    connection=${connection}
        log to console    Going to Unblock NRCELL ${nrcell}
        Perform Cells unblock    cells_list=${nrcell}    timeout=${timeout}    timeout_cell_unblocked=${timeout}  connection=${connection}

        run keyword and ignore error    Aic Close all connection
        Aic Check CU and DUs Onair
        AlarmWatchdog.remove_allow_alarms     fault_id=49
        run keyword and continue on failure    run keyword if    ${is_l3call_needed}
        ...    L3call with Supercell CA    customized_log_name=${customized_log_name}_after_NRCELL_${nrcell}_block_unblock
        ...    is_need_to_stop_traffic=${True}
    END

Verify there should be no active alarm on vDU
    [Documentation]    Author: Lingxue Cui
    [Arguments]    ${connection}=${DU_CONNECTION}
    ${active_alarms}    vdu.vdu_get_active_alarms    vdu_connection=${connection}
    Should Be Empty    ${active_alarms['alarms']}

Operation RANNIC reset one by one
    [Documentation]    Author: Lingxue Cui
    [Arguments]    ${mrbts_dn}=${vDU_DN_MRBTS}    ${is_l3call_needed}=${True}    ${customized_log_name}=${None}
    ...    ${timeout}=5min     ${timeout_for_alarm}=5min    ${connection}=OAM_gnb0_du0

    ${list_rannic_r_dn}    Get RANNIC runtime DN    mrbts_dn=${mrbts_dn}
    FOR    ${rannic_r}    IN    @{list_rannic_r_dn}
        Add list of allowed alarms    allowed_faults_ids=4405,61631,1898,4647
        ${list_rannic_r}    create list    ${rannic_r}
        Perform RANNIC reset    mrbts_id=${mrbts_dn}    list_rannic_r_dn=${list_rannic_r}    timeout=${timeout}    connection=${connection}
        run keyword and ignore error    Aic Close all connection
        Aic Check CU and DUs Onair
        Wait Until Keyword Succeeds    ${timeout_for_alarm}    10s    Verify there should be no active alarm on vDU    connection=${connection}
        Remove list of allowed alarms    allowed_faults_ids=4405,61631,1898,4647
        run keyword and continue on failure    run keyword if    ${is_l3call_needed}
        ...    L3call with Supercell CA    customized_log_name=${customized_log_name}_after_RANNIC_reset    is_need_to_stop_traffic=${True}
    END

