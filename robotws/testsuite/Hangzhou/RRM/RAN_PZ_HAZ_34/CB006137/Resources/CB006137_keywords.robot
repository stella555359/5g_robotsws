*** Settings ***
Documentation      CB006137 common keywords
Resource     5GC006137_variables.robot
Resource     CB006137_powerSplit_keywords.robot
Variables    commissionings/HGZ/${testline_name}/__init_6137__.py
Variables    ../TestData/swconfig_modify.py
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/CA/Resources/CA_Common_New/Check_CA_via_tcpdump_log.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/CA/Resources/CA_Common_New/ca_specifical_step.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/CA/Resources/CA_keywords.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/CA/TestData/Parameters_modify_lib.py    WITH NAME    param_modify_lib
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/lib/online_nidd_process.py    WITH NAME    nidd_modify

*** Keywords ***
Import NIDD variables for 6137
    ${cur_program}    gnb_classical_hangzhou.Get program version based on stream version
    set suite variable    ${PROGRAM}    ${cur_program}
    Wait until keyword succeeds    3min    5 sec    Connect to gnb coam via ssl
    &{NR_CELL_ID_MAPPING}    coam_gnb_classical.get_relation_mapping_between_cell_index_and_other_ids
    set suite variable    ${NR_CELL_ID_MAPPING}
    ${is_tl_delta_file_exists}    Run keyword and return status    File should exist    ${commissionings_path}/HGZ/${testline_name}/TLDelta.py
    Run keyword if    ${is_tl_delta_file_exists}
    ...    Import variables  ${commissionings_path}/HGZ/${testline_name}/TLDelta.py
    import variables    ${CURDIR}/../TestData/NIDD_modify_scf.py
    import variables    ${CURDIR}/../TestData/NIDD_modify_rest_api_6137.py
    import variables    ${CURDIR}/../TestData/NIDD_modify_rest_api_scellSwap_iwk_RRE.py
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections

6137 Suite preparation
    [Documentation]  Author: Ding Binmei
    ...    exp_cc_num_in_use: refers to 3CC/4CC/${None}, if set as 3CC or 4CC will return the input value directly,
    ...        otherwise will judge based on ue type. sdx65: 3CC, sdx70: 4CC, other ue type will default to 3CC
    ...    Added new parameter for ${ca_group_mapping_3cc} and ${ca_group_mapping_4cc}, parameter need to be added based on exp_cc_num_in_use
    ...    ${ca_group_mapping_3cc} equals to ${ca_group_mapping} by default,
    ...    ToDo: ${ca_group_mapping} can be removed when all cases has removed this param
    [Arguments]    ${enb_default_scf_file}=${None}    ${cell_chbw_config}=3CC_F20M_T100M_T60M
    ...    ${swconfig_modify}=${None}    ${scf_modify_parameters}=${PARAMS_TO_MODIFY_SCF}    ${ca_group_mapping_3cc}=${F1_T1_T3_3CC_CA_GROUP_COMMON}
    ...    ${pa_values_mapping}=${INIT_PA_F1_T1_F2_T3}
    ...    ${ca_group_mapping_4cc}=${F1_T1_F2_T3_4CC_CA_GROUP_COMMON}    ${exp_cc_num_in_use}=${None}
    Decode CA group mapping and set global variable    is_called_in_suite_level=${True}
    ...    ca_group_mapping_3cc=${ca_group_mapping_3cc}    ca_group_mapping_4cc=${ca_group_mapping_4cc}    exp_cc_num_in_use=${exp_cc_num_in_use}

    # when X75, two FDD's arfcn must be continous if expected 4CC comb are F1F2T1T3 and F1F2T1T2
    ${F2_ARFCN}   Set variable if   'sdx75' in @{tl.ues[0].capabilities}    ${FDD2_ARFCNDL_CONTINUOUS}    ${FDD2_ARFCNDL_NON_CONTINUOUS}
    Set suite variable   ${F2_ARFCN}

    Import NIDD variables for 6137
    run keyword if    '${cell_chbw_config}'!='${None}'    import variables    ${CURDIR}/../TestData/NIDD_modify_scf_${cell_chbw_config}.py

    Set suite variable    ${PARAMS_TO_DELETE}    ${DELETE_SCF_DEFAULT}
    Set suite variable    ${PARAMS_TO_ADD}       ${ADD_SCF_DEFAULT}
    Set suite variable    ${PARAMS_TO_MODIFY}    ${MODIFY_SCF_DEFAULT}

    CA Suite preparation    prepare_ue=${True}    NSA_SA=${NSA_SA}    enb_default_scf_file=${enb_default_scf_file}
    ...    swconfig_modify=${swconfig_modify}
    ...    prepare_ue=${True}
    ...    scf_modify_parameters=${scf_modify_parameters}
    ...    pa_values_mapping=${pa_values_mapping}

    Prepare NRREL under specific cell    ca_group_mapping=${CA_GROUP_MAPPING}

Get CC num in use based on UE type from test line config file
    [Documentation]  Author: Ding Binmei
    ...    exp_cc_num_in_use: 3CC, 4CC, ${None}
    ...    if set as 3CC or 4CC will return the input value directly, otherwise will judge based on ue type.
    ...    sdx65: 3CC
    ...    sdx70: 4CC
    ...    return: 3CC / 4CC
    [Arguments]  ${exp_cc_num_in_use}=${None}
    @{supported_cc_num}    Create List    3CC    4CC
    ${act_cc_num_in_use}    Run keyword if    '${exp_cc_num_in_use}' in @{supported_cc_num}
    ...    Set variable    ${exp_cc_num_in_use}
    ...    ELSE IF    'sdx75' in @{tl.ues[0].capabilities}    Set variable    4CC
    ...    ELSE IF    'sdx70' in @{tl.ues[0].capabilities}    Set variable    4CC
    ...    ELSE IF    'sdx65' in @{tl.ues[0].capabilities}    Set variable    3CC
    ...    ELSE    Set variable    3CC
    [Return]  ${act_cc_num_in_use}

Decode CA group mapping and set global variable
    [Documentation]  Author: Ding Binmei
    ...    exp_cc_num_in_use: refers to 3CC/4CC/${None}, if set as 3CC or 4CC will return the input value directly,
    ...        otherwise will judge based on ue type. sdx65: 3CC, sdx70: 4CC, other ue type will default to 3CC
    ...    Added new parameter for ${ca_group_mapping_3cc} and ${ca_group_mapping_4cc}, parameter need to be added based on exp_cc_num_in_use
    ...    ${ca_group_mapping_3cc} equals to ${ca_group_mapping} by default,
    [Arguments]  ${exp_cc_num_in_use}=${None}    ${ca_group_mapping_3cc}=${None}
    ...    ${ca_group_mapping_4cc}=${None}    ${is_called_in_suite_level}=${False}
    ${CC_NUM}    Get CC num in use based on UE type from test line config file    exp_cc_num_in_use=${exp_cc_num_in_use}
    ${ca_group_mapping_in_use}    Set variable if    '${CC_NUM}'=='3CC'    ${ca_group_mapping_3cc}
    ...    ${ca_group_mapping_4cc}

    ${pcell_id_list}    create list    ${ca_group_mapping_in_use['pcell_id']}
    ${CELL_INDEX_LIST}    combine lists    ${pcell_id_list}    ${ca_group_mapping_in_use['verify_scell_add_dl']}

    run keyword if    ${is_called_in_suite_level}    Run keywords
    ...    Set suite variable    ${CA_GROUP_MAPPING}    ${ca_group_mapping_in_use}    AND
    ...    Set suite variable    ${PCELL_ID}    ${ca_group_mapping_in_use['pcell_id']}    AND
    ...    Set suite variable    ${SCELL_ID_UL_ADD}    ${ca_group_mapping_in_use['verify_scell_add_ul']}    AND
    ...    Set suite variable    ${SCELL_ID_DL_ADD}    ${ca_group_mapping_in_use['verify_scell_add_dl']}    AND
    ...    Set suite variable    ${CELL_INDEX_LIST}    AND
    ...    Set suite variable    ${CC_NUM}
    ...    ELSE    Run keywords
    ...    Set test variable    ${CA_GROUP_MAPPING}    ${ca_group_mapping_in_use}    AND
    ...    Set test variable    ${PCELL_ID}    ${ca_group_mapping_in_use['pcell_id']}    AND
    ...    Set test variable    ${SCELL_ID_UL_ADD}    ${ca_group_mapping_in_use['verify_scell_add_ul']}    AND
    ...    Set test variable    ${SCELL_ID_DL_ADD}    ${ca_group_mapping_in_use['verify_scell_add_dl']}    AND
    ...    Set test variable    ${CELL_INDEX_LIST}    AND
    ...    Set test variable    ${CC_NUM}

6137 Case setup
    [Documentation]    Author: Cui Lingxue
    ...    If ca relationship need to be modified, input by ${ca_group_mapping}, NRREL will be updated accordingly.
    ...    If other NIDD parameters need to be modified, input by ${dict_params_to_modify}.
    ...    ${exp_cc_num_in_use}: refers to 3CC/4CC/${None}, if set as 3CC or 4CC will return the input value directly,
    ...        otherwise will judge based on ue type. sdx65: 3CC, sdx70: 4CC, other ue type will default to 3CC
    ...    Added new parameter for ${ca_group_mapping_3cc} and ${ca_group_mapping_4cc}, parameter need to be added based on exp_cc_num_in_use
    ...    ${ca_group_mapping_3cc} equals to ${ca_group_mapping} by default,
    [Arguments]    ${dict_params_to_modify}=${None}    ${is_log_required}=${False}
    ...    ${timeout_restapi}=${TIMER_FOR_MODIFY_VIA_API}    ${ca_group_mapping_3cc}=${F1_T1_T3_3CC_CA_GROUP_COMMON}
    ...    ${ca_group_mapping_4cc}=${F1_T1_F2_T3_4CC_CA_GROUP_COMMON}    ${exp_cc_num_in_use}=${None}
    Common case setup    is_log_required=${is_log_required}    NSA_SA=${NSA_SA}    is_scf_backup_needed=${False}
    Decode CA group mapping and set global variable    is_called_in_suite_level=${False}
    ...    ca_group_mapping_3cc=${ca_group_mapping_3cc}    ca_group_mapping_4cc=${ca_group_mapping_4cc}    exp_cc_num_in_use=${exp_cc_num_in_use}
    Prepare NRREL under specific cell    ca_group_mapping=${CA_GROUP_MAPPING}

    run keyword if    ${dict_params_to_modify}!=${None}
    ...    Run keywords    nidd_modify.online_modify_nidd_parameters_via_restapi    params_modify_dict=${dict_params_to_modify}
    ...        timeout=${timeout_restapi}    AND
    ...        Wait until cluster ready based on NSA_SA type   NSA_SA=${NSA_SA}    is_need_to_setup_gnb_connection=${False}
    # download SCF file to log path for mannual rerun or mannual debug issue
    run keyword and ignore error    Download SCF file to log path

Prepare NRREL under specific cell
    [Documentation]    Author: Cui Lingxue
    ...    Generate and activate parameters for nrrel update based on ca_group_mapping.
    [Arguments]    ${ca_group_mapping}    ${timeout_restapi}=${TIMER_FOR_MODIFY_VIA_API}    ${connection}=GNB_OAM
    &{dict_nrrel_params}    param_modify_lib.get_nrrel_params_for_online_update_based_on_ca_group_mapping_config
    ...    ca_group_mapping=${ca_group_mapping}    program=${PROGRAM}
    ${result}    nidd_modify.online_modify_nidd_parameters_via_restapi    params_modify_dict=${dict_nrrel_params}
    ...    skip_parameter_relation_errors=${False}    should_activate=${True}    connection=${connection}    timeout=${timeout_restapi}
    Wait until cluster ready based on NSA_SA type   NSA_SA=${NSA_SA}    is_need_to_setup_gnb_connection=${False}
#    run keyword if    '${result}'=='PASS'    sleep    2min    msg=This is WA for cell is not really 'usable' even after cell on air. Need to wait
#    ...    for 1-2 min to access.

    [Return]    ${result}

ULCA_peak_tput_verification
    [Documentation]    Author: Cui Lingxue
    ...    This keyword is to verify UE can reach peak throughput for ul only direction, dl only direction and bi-direction.
    ...    The execution order will be:
    ...      1) UE attach and verify scell addition
    ...      2) Start UL traffic and verify UL throughput
    ...      3) Stop UL traffic
    ...      4) Start DL traffic and verify DL throughput
    ...      5) Start UL traffic and verify bi-direction throughput,and check UL RTWP PM counter for Scell TDD UL
    ...      6) Stop data transmission and detach UE.
    [Arguments]    ${cell_index}    ${scell_index_ul}=${SCELL_ID_UL_ADD}    ${scell_index_dl}=${SCELL_ID_DL_ADD}
    ...    ${exp_ul_indiv}=${EXP_UL_INDIV}    ${exp_dl_indiv}=${EXP_DL_INDIV}
    ...    ${tcpdump_log_name}=basic_l3_call    ${exp_ul}=${EXP_UL_TOTAL}    ${exp_dl}=${EXP_DL_TOTAL}
    ...    ${scell_addition_method}=blind   ${connection}=GNB_OAM
    ...    ${dl_tput_iperf}=${DL_TPUT_IPERF}    ${ul_tput_iperf}=${UL_TPUT_IPERF}    ${protocol}=udp    ${iperf_duration}=3000s
    ...    ${tput_duration}=300s    ${check_tput_ignore_time}=1min    ${target_avg_percent}=0.98
    ...    ${min_percent}=0.85    ${reporting_interval}=5

    # UE attach, start UL traffic and verify
    run keyword and continue on failure     L3 call with UL or DL CA exist
    ...    cell_index=${cell_index}
    ...    scell_index_ul=${scell_index_ul}
    ...    scell_index_dl=${scell_index_dl}
    ...    exp_ul_indiv=${EXP_UL_INDIV_NO_CA}    exp_ul=${EXP_UL_INDIV_NO_CA_TOTAL}
    ...    exp_dl_indiv=${None}    exp_dl=-1
    ...    tcpdump_log_name=${tcpdump_log_name}
    ...    scell_addition_method=${scell_addition_method}
    ...    actBufferBasedScellAddition=oneShot_Dl_Fr1
    ...    ul_tput_iperf=${ul_tput_iperf}
    ...    dl_tput_iperf=${dl_tput_iperf}
    ...    protocol=${protocol}
    ...    data_transfer_direction=ul
    ...    tput_duration=${tput_duration}
    ...    target_avg_percent=${target_avg_percent}
    ...    min_percent=${min_percent}
    ...    customized_log_name=no_ULCA_tput_UL_only
    ...    is_need_to_stop_traffic=${False}

    run keyword and continue on failure     Stop data transfer based on direction    data_transfer_direction=ul    protocol=${protocol}

    run keyword and ignore error     check iperf process on appserver
    # start DL traffic and verify
    Start data transfer based on direction    data_transfer_direction=dl    protocol=${protocol}
    ...    dl_tput=${dl_tput_iperf}     ul_tput=${ul_tput_iperf}    duration=${iperf_duration}
    run keyword and ignore error     check iperf process on appserver
    ${tput_log_path}    power_ue.Collect Tput     ue_type=${UE_TYPE}    duration=${tput_duration}
    ...    ignore_time=${check_tput_ignore_time}    filter=L2Lo
    run keyword and continue on failure     Check tput via power UE optimized     cell_index=${cell_index}    direction=dl
    ...    tput_log_path=${tput_log_path}    connection=${connection}
    ...    exp_dl=${exp_dl}    exp_dl_indiv=${exp_dl_indiv}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    ...    customized_log_name=ULCA_tput_DL_only

    ${start_time}    Prepare for counter log    reporting_interval=${reporting_interval}
    # Start UL traffic and verify bi-direction traffic
    Start data transfer based on direction    data_transfer_direction=ul    protocol=${protocol}
    ...    dl_tput=${dl_tput_iperf}     ul_tput=${ul_tput_iperf}    duration=${iperf_duration}
    ${tput_log_path}    power_ue.Collect Tput     ue_type=${UE_TYPE}    duration=${tput_duration}
    ...    ignore_time=${check_tput_ignore_time}    filter=L2Lo
    ${pm_files_local_path}    Wait for PM file generated and download    starting_log_timestamp=${start_time['log_generator_timestamp']}

    Check tput via power UE optimized     cell_index=${cell_index}    direction=both
    ...    tput_log_path=${tput_log_path}    connection=${connection}
    ...    exp_dl=${exp_dl}    exp_dl_indiv=${exp_dl_indiv}    exp_ul=${exp_ul}    exp_ul_indiv=${exp_ul_indiv}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    ...    customized_log_name=ULCA_tput_Bi_diretion
    Check UL RTWP PM counter for Scell TDD UL    cell_id=${scell_index_ul}    pm_files_local_path=${pm_files_local_path}
    [Teardown]  Run keyword and ignore error    Stop data transfer and detach UE    data_transfer_direction=both

Verify throughput as expect
    [Documentation]  Author: Wang Yixiang
    ...   The keyword is for no peak case checking.
    ...   No peak paras:
    ...      ${TPUT_AVG_PERCENT_COMMON}=0.7     ${TPUT_MIN_PERCENT_COMMON}=0.5
    ...   Peak paras:
    ...      ${TPUT_AVG_PERCENT_COMMON}=0.95     ${TPUT_MIN_PERCENT_COMMON}=0.85
    ...   ${cell_index}: global cell id, can be 1 or 1,2
    ...   ${exp_ul}/${exp_dl}: expected tput of UL/DL, Can only be single value.
    ...   ${exp_ul_indiv}/${exp_dl_indiv}:
    ...        If not to check for individual cells, then remain it as ${None}
    ...        If check, then input tput should be set for each cell. like: 90,100
    ...    Notes for input expected tput:
    ...       -1: Means not to check tput
    ...        0: Means tput should < 2M
    ...       Negative value: Means tput should < exp_value
    ...       Positive value: Means tput should >= exp_value
    ...    ${connection}: Refer to the SSL connection alias for GNB
    ...    ${data_transfer_direction}: ul, dl, both
    ...    ${UE_TYPE}: Suite varaible defined in suite setup. Get from : ue.translate_power_ue_type_from_testline
    ...    ${tput_duration}: duration for check tput
    ...    ${check_tput_ignore_time}: ignore time for check tput to wait for tput stable
    ...    ${customized_log_name}: For generated tput image file name
    [Arguments]    ${cell_index}    ${exp_ul_indiv}=${EXP_UL_INDIV}    ${exp_dl_indiv}=${EXP_DL_INDIV}
    ...    ${exp_ul}=1    ${exp_dl}=1    ${ue_index}=${0}   ${connection}=GNB_OAM
    ...    ${data_transfer_direction}=both    ${tput_duration}=60s    ${check_tput_ignore_time}=30s
    ...    ${target_avg_percent}=${TPUT_AVG_PERCENT_COMMON}
    ...    ${min_percent}=${TPUT_MIN_PERCENT_COMMON}    ${customized_log_name}=check_throughput
    ...    ${is_need_to_stop_traffic}=${False}

    ${tput_log_path}    power_ue.Collect Tput     ue_type=${UE_TYPE}    duration=${tput_duration}
    ...    ignore_time=${check_tput_ignore_time}    filter=L2Lo
    run keyword and ignore error    check iperf process on appserver
    Check tput via power UE optimized     cell_index=${cell_index}     tput_log_path=${tput_log_path}    direction=${data_transfer_direction}
    ...    exp_ul=${exp_ul}    exp_dl=${exp_dl}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    ...    exp_ul_indiv=${exp_ul_indiv}    exp_dl_indiv=${exp_dl_indiv}    connection=${connection}
    ...    customized_log_name=${customized_log_name}    is_need_to_fail_keyword=${True}
    ...    is_analysis_log_captured=${False}
    [Teardown]  Run keyword and ignore error    run keyword if    '${is_need_to_stop_traffic}'=='${True}'
    ...    Stop data transfer and detach UE    data_transfer_direction=${data_transfer_direction}    ue_index=${ue_index}

_Get tput value for all cells based on individul input
    [Documentation]    Author: Ding Binmei
    ...    ${indiv_tput}: should be a list of individual tput for each cell, -1 means no tput
    [Arguments]    ${indiv_tput}
    ${tput_for_all_cells}    Set variable    0
    FOR  ${tput}    IN    @{indiv_tput}
        ${tput}    Set variable if    ${tput}==-1    0    ${tput}
        ${tput_for_all_cells}    Evaluate    ${tput_for_all_cells}+${tput}
    END
    [Return]    ${tput_for_all_cells}

_Get A6 scell swap parameters for add
    [Documentation]    Author: Jin Journey
    ...    Ding Binmei: Move this keyword out to generate A6 params for cells
    [Arguments]    ${cell_id}    ${a6MeasSCellSwapParams}    ${thresholdSCellSwap}
    ${a6MeasSCellSwapEnabled}    evaluate
    ...    dict(dist_name='NRBTS-${NRBTS_ID}/NRCELL-${cell_id}', parameter='a6MeasSCellSwapEnabled', value='rsrp')
    ${a6MeasSCellSwapSsbRsrp}    evaluate
    ...    dict(dist_name='NRBTS-${NRBTS_ID}/NRCELL-${cell_id}', parameter='a6MeasSCellSwapSsbRsrp', value=${a6MeasSCellSwapParams})
    ${reportAmountA6MeasSCellSwap}    evaluate
    ...    dict(dist_name='NRBTS-${NRBTS_ID}/NRCELL-${cell_id}', parameter='reportAmountA6MeasSCellSwap', value='r4')
    ${reportIntervalA6MeasSCellSwap}    evaluate
    ...    dict(dist_name='NRBTS-${NRBTS_ID}/NRCELL-${cell_id}', parameter='reportIntervalA6MeasSCellSwap', value='ms1024')
    ${thresholdSCellSwapSourceRsrp}    evaluate
    ...    dict(dist_name='NRBTS-${NRBTS_ID}/NRCELL-${cell_id}', parameter='thresholdSCellSwapSourceRsrp', value='${thresholdSCellSwap}')
    ${list_a6MeasSCellSwapEnabled_params}    Create list    ${a6MeasSCellSwapEnabled}    ${a6MeasSCellSwapSsbRsrp}
    ...    ${reportAmountA6MeasSCellSwap}    ${reportIntervalA6MeasSCellSwap}    ${thresholdSCellSwapSourceRsrp}
    [Return]    ${list_a6MeasSCellSwapEnabled_params}

Configure A1 meas and A6 scell swap parameters
    [Documentation]   author: Jin Journey
    ...    Online modify NIDD parameters to configure scell addition method to covBasedA1.
    ...    Update parameter list:
    ...        MRBTS-255/NRBTS-10063/actMeasBasedSCellAddition=true
    ...        MRBTS-255/NRBTS-10063/actSCellSwapFr1=a6BasedSa
    ...    New parameter list:
    ...        MRBTS-255/NRBTS-10063/NRCELL-2/a1MeasSCellAddEnabled=rsrp
    ...        MRBTS-255/NRBTS-10063/NRCELL-2/a1MeasSCellAddSsbRsrp:
    ...            a1HysteresisSCellAddSsbRsrp=0
    ...            a1ThresholdSCellAddSsbRsrpFDD=70
    ...            a1ThresholdSCellAddSsbRsrpTDD=70
    ...            a1TimeToTriggerSCellAddSsbRsrp=320ms
    ...        MRBTS-255/NRBTS-10063/NRCELL-4/a6MeasSCellSwapEnabled=rsrp
    ...        MRBTS-255/NRBTS-10063/NRCELL-4/a6MeasSCellSwapSsbRsrp:
    ...            a6HysteresisSCellSwapSsbRsrp=0
    ...            a6OffsetSCellSwapSsbRsrp=6
    ...            a6TimeToTrigSCellSwapSsbRsrp=ms480
    ...        MRBTS-255/NRBTS-10063/NRCELL-4/reportAmountA6MeasSCellSwap=r4
    ...        MRBTS-255/NRBTS-10063/NRCELL-4/reportIntervalA6MeasSCellSwap=ms1024
    ...        MRBTS-255/NRBTS-10063/NRCELL-4/thresholdSCellSwapSourceRsrp=70
    ...    Ding Binmei 2025-1-24: In order to cover regression for 04307958, need to trigger scell swap between source and target scells
    ...   for multiple times, so config A6 for both source and target scells
    [Arguments]    ${ca_group_mapping}=${None}    ${timeout}=${TIMER_FOR_MODIFY_VIA_API}
    ...    ${a1HysteresisSCellAddSsbRsrp}=${0}
    ...    ${a1ThresholdSCellAddSsbRsrp}=${70}
    ...    ${a1TimeToTriggerSCellAddSsbRsrp}=320ms
    ...    ${a6HysteresisSCellSwapSsbRsrp}=${0}
    ...    ${a6OffsetSCellSwapSsbRsrp}=${4}
    ...    ${a6TimeToTrigSCellSwapSsbRsrp}=ms480
    ...    ${useAllowedCellListRsrp}=${false}
    ...    ${thresholdSCellSwap}=${70}
    ...    ${NSA_SA}=SA

    Set test variable    ${PCELL_ID}    ${ca_group_mapping['pcell_id']}
    Set test variable    ${SOURCE_SCELL_ID}    ${ca_group_mapping['verify_scell_add_ul'][0]}

    ${actMeasBasedSCellAddition_legacy}    evaluate
    ...    dict(dist_name='NRBTS-${NRBTS_ID}', parameter='actMeasBasedSCellAddition', value='true')
    ${measBased_list}    create list    A1-based
    ${actMeasBasedSCellAdditionSA}    evaluate
    ...    dict(dist_name='NRBTS-${NRBTS_ID}', parameter='actMeasBasedSCellAdditionSa', value=${measBased_list})
    ${actMeasBasedSCellAddition}   set variable if    '${program}'=='24R1' or '${program}'=='23R3' or '${program}'=='23R4' or '${program}'=='23R2'
    ...    ${actMeasBasedSCellAddition_legacy}     ${actMeasBasedSCellAdditionSA}

    ${actSCellSwapFr1}    evaluate
    ...    dict(dist_name='NRBTS-${NRBTS_ID}', parameter='actSCellSwapFr1', value='a6BasedSa')
    ${params_to_upd}    create list    ${actMeasBasedSCellAddition}    ${actSCellSwapFr1}

    ${a1Hysteresis}    set variable     a1HysteresisSCellAddSsbRsrp='${a1HysteresisSCellAddSsbRsrp}'
    ${a1RsrpThreshold_FDD}     set variable      a1ThresholdSCellAddSsbRsrpFDD='${a1ThresholdSCellAddSsbRsrp}'
    ${a1RsrpThreshold_TDD}     set variable      a1ThresholdSCellAddSsbRsrpTDD='${a1ThresholdSCellAddSsbRsrp}'
    ${a1TimeToTrigger}    set variable     a1TimeToTriggerSCellAddSsbRsrp='${a1TimeToTriggerSCellAddSsbRsrp}'

    ${a6Hysteresis}    set variable     a6HysteresisSCellSwapSsbRsrp='${a6HysteresisSCellSwapSsbRsrp}'
    ${a6OffsetRsrp}     set variable      a6OffsetSCellSwapSsbRsrp='${a6OffsetSCellSwapSsbRsrp}'
    ${a6TimeToTrigger}     set variable      a6TimeToTrigSCellSwapSsbRsrp='${a6TimeToTrigSCellSwapSsbRsrp}'
    ${useAllowedCellListRsrp}    Set variable    useAllowedCellListRsrp='${useAllowedCellListRsrp}'

    ${a1_value}    evaluate    [dict(${a1Hysteresis}, ${a1RsrpThreshold_FDD}, ${a1RsrpThreshold_TDD}, ${a1TimeToTrigger})]
    ${a6_value_since_23R4}    evaluate    [dict(${a6Hysteresis}, ${a6OffsetRsrp}, ${a6TimeToTrigger}, ${useAllowedCellListRsrp})]
    ${a6_value}    Set variable    ${a6_value_since_23R4}

    ${a1MeasSCellAddEnabled}    evaluate
    ...    dict(dist_name='NRBTS-${NRBTS_ID}/NRCELL-${PCELL_ID}', parameter='a1MeasSCellAddEnabled', value='rsrp')
    ${a1MeasSCellAddSsbRsrp}    evaluate
    ...    dict(dist_name='NRBTS-${NRBTS_ID}/NRCELL-${PCELL_ID}', parameter='a1MeasSCellAddSsbRsrp', value=${a1_value})
    ${list_a6MeasSCellSwapEnabled_params_source_scell}    _Get A6 scell swap parameters for add    cell_id=${SOURCE_SCELL_ID}
    ...    a6MeasSCellSwapParams=${a6_value}    thresholdSCellSwap=${thresholdSCellSwap}
    ${list_a6MeasSCellSwapEnabled_params_target_scell}    _Get A6 scell swap parameters for add    cell_id=${ca_group_mapping['scell_swap_ul'][0]}
    ...    a6MeasSCellSwapParams=${a6_value}    thresholdSCellSwap=${thresholdSCellSwap}

    ${list_a1MeasSCellAddEnabled_params}    create list    ${a1MeasSCellAddEnabled}    ${a1MeasSCellAddSsbRsrp}
    ${params_to_add_tmp}    Combine lists    ${list_a1MeasSCellAddEnabled_params}    ${list_a6MeasSCellSwapEnabled_params_source_scell}
    ${params_to_add}    Run keyword if    '${PROGRAM}'=='master'
    ...    Combine lists    ${params_to_add_tmp}    ${list_a6MeasSCellSwapEnabled_params_target_scell}
    ...    ELSE    Set variable    ${params_to_add_tmp}
    Connect to gnb coam via ssl
    COAM add several parameters via rest api    parameters_to_add_via_api=${params_to_add}    timeout=${timeout}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${params_to_upd}    timeout=${timeout}

    Wait until cluster ready based on NSA_SA type        NSA_SA=${NSA_SA}

Check UL RTWP PM counter for Scell TDD UL
    [Documentation]    Author: Jiang Xian
    ...    This keyword is to check the UL RTWP PM counter for Scell TDD UL after ULCA traffic test.
    ...    The PM counter name is "	M55369C00100 Maximum RTWP for UL Spatial stream 0 ".
    ...    The PM counter name is "	M55369C00102 Maximum RTWP for UL Spatial stream 2 ".
    ...    For UL RTWP PM counter, there are more 2 counters- M55369C00104 Maximum RTWP for UL Spatial stream 4
    ...    and M55369C00106 Maximum RTWP for UL Spatial stream 6.
    ...    In this case-UL CA and observing Scell TDD, only have values for stream 0 and 2 so only check them.
    [Arguments]    ${cell_id}    ${pm_files_local_path}
    ${list_measurement_ids_rtwp_counters}    create list   M55369C00100    M55369C00102
    FOR    ${file_path}    IN    @{pm_files_local_path}
        ${dict_meas_val}    counter.get_cell_counters_from_file    file_path=${file_path}
                                                        ...      list_cell=${cell_id}
                                                        ...      list_measurement_ids=${list_measurement_ids_rtwp_counters}
    END
    ${cell}    Get From List    ${cell_id}    0
    FOR    ${counter}    IN    @{list_measurement_ids_rtwp_counters}
        run keyword and continue on failure     should be true     -74 <= ${dict_meas_val['${cell}']['${counter}']} <= -60
    END

