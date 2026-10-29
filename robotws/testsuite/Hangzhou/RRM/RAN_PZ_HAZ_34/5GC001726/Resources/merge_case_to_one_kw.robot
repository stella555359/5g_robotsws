*** Settings ***
Documentation
...   This is for 1726-GA TA common keywords for UTE cloud
...   squad group: MMW_SG1
Resource    ./5GC001726_keywords.robot
Library     ./check_counter.py


*** Keywords ***
# *********************************this part is for 1726_GA_Contiguous.robot******************************
update parameters for CA and attach and verify
    [Arguments]    ${cell_index_for_attach}    ${log_prefix}    ${verification_type}    ${parameters_to_update_via_api}
    ...    ${expected_dl_scell_number}=${7}    ${expected_ul_scell_number}=${1}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${parameters_to_update_via_api}
    Attach to pcells and do verification for configured IE    cell_index_for_attach=${cell_index_for_attach}
    ...    log_prefix=${log_prefix}    verification_type=${verification_type}

8CCDL_2CCUL_maxScell7DL1UL_caConfigurationSupport_online_modify
    Attach to pcells and do verification for configured IE     cell_index_for_attach=${1}    log_prefix=1726_GA107    is_need_to_detach_ue=${False}

    log to console     Modify caConfigurationSupport from 8CCDL_4CCUL to 4CCDL_2CCUL online and ue will not detach
    COAM Update several parameters via rest api    parameters_to_update_via_api=${MODIFY_caConfigurationSupport_4DL2UL_VIA_API}
    ${log_full_path_enb}    Wait until keyword succeeds    3X    3 s    Start x2 trace capturing from enb    log_prefix=1726_GA107
    sleep    3s
    Stop Trace Capturing    log_prefix=1726_GA107    connection_alias=ENB
    ${log_full_path_ute}    Download trace log    log_full_path=${log_full_path_enb}    log_dir_ute=${TS_CASE_LOG_PATH}    connection_alias=ENB
    run keyword and continue on failure    Verify ul and dl scell number    file_path=${log_full_path_ute}
    ...    expected_dl_scell_number=${7}    expected_ul_scell_number=${1}

    log to console    Perform ue detach and then attach again...
    power_ue.UE Detach    ue_type=${UE_TYPE}
    log to console    Perform ue attach again...
    Attach to pcells and do verification for configured IE    cell_index_for_attach=${1}    log_prefix=1726_GA107
    ...    expected_dl_scell_number=${3}    expected_ul_scell_number=${1}

8CCDL_2CCUL_maxScell7DL1UL_caConfigurationSupport_value_4DL2UL
    COAM Update several parameters via rest api    parameters_to_update_via_api=${MODIFY_caConfigurationSupport_4DL2UL_VIA_API}
    FOR    ${pcell_index}    IN    @{PCELL_INDEX}
      Attach to pcells and do verification for configured IE    cell_index_for_attach=${pcell_index}    log_prefix=1726_GA105
      ...    expected_dl_scell_number=${3}    expected_ul_scell_number=${1}
    END

# *********************************this part is for 1726_GA_Contiguous.robot******************************

# *********************************this part is for 1726_GF_counter.robot******************************************
GF_608_GNB-8CCDL_2CCUL_maxScell7DL1UL_non-contiguous_UE8DL2UL_1UE_enhanced_csi-rs_configure_and_simultaneousCSI-ReportsAllCC
    ${cur_program}    gnb_classical.Get program version based on stream version
    set suite variable    ${PROGRAM}    ${cur_program}
    import library      event_trace_log_analysis.Event_trace_log_analysis_1726    program=${PROGRAM}     WITH NAME    event_trace_analysis
    &{NR_CELL_ID_MAPPING}    coam_gnb_classical.get_relation_mapping_between_cell_index_and_other_ids
    Set suite variable    ${NR_CELL_ID_MAPPING}
    Verify SIM card state and reboot UE if SIM not loaded
    Switch pcell for attach based on cell index    cell_index_for_attach=${1}

    Run Keyword And Ignore Error    csn.disconnect    connection=ASIK Master
    COAM Update several parameters via rest api    parameters_to_update_via_api=${PARA_TO_MODIFY_VIA_API_GF_608}
    ...    timeout=${TIMEOUT_REST_API_RESTART}
    Wait until cluster is on cell on air status    timeout=${TIMEOUT_CLUSTER}    is_all_cells_checking_needed=${True}
    Connect to Capacity Unit Master case
	Qcom attach UE and start traffic      dl_tput_size=2500M     ul_tput_size=200M

    ${tput_log}    power_ue.Collect Tput     ue_type=${ue_type}    duration=2m   ignore_time=30s    filter=L2Lo

    ${info}   get dictionary values    ${NR_CELL_ID_MAPPING}
    ${list_of_cell_ids}    create list
    FOR    ${cur_info}    IN    @{info}
           ${cur_nridentiity}    set variable   ${cur_info}[nrCellIdentity]
           ${cur_nridentiity}   convert to string    ${cur_nridentiity}
           append to list    ${list_of_cell_ids}   ${cur_nridentiity}
    END
    power_ue.Check Bi Tput
    ...    ue_type=${ue_type}   log=${tput_log}    cells=${list_of_cell_ids}    min_percent=0.7
    ...    ultarget_throughput=100   dltarget_throughput=2500    actCarrierAggregation=${True}

#    Capture log and verify CSI-ReportsAllCC and DL HARQ feedback success anb bler    cell_id=1,2,3,4,5,6,7,8

# *****************************************************************************************************************

# *********************************this part is for 1726_GA_counter.robot******************************************
1726_GA_122_M55118C02008_M55118C03008
    [Arguments]    ${cell_id}    ${num_cells_with_expected_counter_work}=${1}
    ${cur_program}    gnb_classical.Get program version based on stream version
    set suite variable    ${PROGRAM}    ${cur_program}
    import library      event_trace_log_analysis.Event_trace_log_analysis_1726    program=${PROGRAM}     WITH NAME    event_trace_analysis
    &{NR_CELL_ID_MAPPING}    coam_gnb_classical.get_relation_mapping_between_cell_index_and_other_ids
    Set suite variable    ${NR_CELL_ID_MAPPING}
    Verify SIM card state and reboot UE if SIM not loaded
    Switch pcell for attach based on cell index    cell_index_for_attach=${1}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${MODIFY_VIA_API_COUNTER}
    Set suite counter list
    Run Keyword And Ignore Error    csn.disconnect    connection=ASIK Master
    Wait until cluster is on cell on air status    timeout=${TIMEOUT_CLUSTER}    is_all_cells_checking_needed=${True}
    Connect to Capacity Unit Master case

    ${parameters_to_update_via_api}    combine lists    ${MODIFY_maxNumScellsDL_5_VIA_API}   ${MODIFY_maxNumScellsUl_0_VIA_API}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${parameters_to_update_via_api}
    ${local_counter_file_path}    Attach to pcells and collect counter logs

    @{list_RRC_RECONF_X_SCELL_ATT_counter}    create list   M55118C02001    M55118C02006    M55118C02008    M55118C02010    M55118C02012
    @{list_RRC_RECONF_X_SCELL_SUCC_counter}    create list   M55118C03001    M55118C03006    M55118C03008    M55118C03010    M55118C03012

    ${dict_measurements_value_att}    counter.get_total_cell_counter_from_multiple_files    list_file_path=${local_counter_file_path}
    ...      list_cell=${cell_id}          list_measurement_ids=${list_RRC_RECONF_X_SCELL_ATT_counter}

    ${dict_measurements_value_succ}    counter.get_total_cell_counter_from_multiple_files    list_file_path=${local_counter_file_path}
    ...      list_cell=${cell_id}          list_measurement_ids=${list_RRC_RECONF_X_SCELL_SUCC_counter}

    ${SCELL_ATT_NUMBER}    create list    ${SCELL_ATT_NUMBER}
    ${SCELL_SUCC_NUMBER}    create list    ${SCELL_SUCC_NUMBER}

    log to console    check counter M55118C02008 works on ${num_cells_with_expected_counter_work} cell only
    check_one_expected_counter_works_for_each_cell    expect_counter_id=M55118C02008
    ...    expect_counter_value=${SCELL_ATT_NUMBER}    cell_id=${cell_id}
    ...    cell_counters_dict=${dict_measurements_value_att}
    ...    num_cells_with_expected_counter_work=${num_cells_with_expected_counter_work}

    check_several_counters_remian_idle_for_each_cell    list_all_interested_counter_ids=${LIST_RRC_RECONF_x_SCELL_ATT_COUNTER}
    ...    expect_work_counter_id=M55118C02008    cell_id=${cell_id}
    ...    cell_counters_dict=${dict_measurements_value_att}


    log to console    check counter M55118C03008 works on ${num_cells_with_expected_counter_work} cell only
    check_one_expected_counter_works_for_each_cell    expect_counter_id=M55118C03008
    ...    expect_counter_value=${SCELL_SUCC_NUMBER}   cell_id=${cell_id}
    ...    cell_counters_dict=${dict_measurements_value_succ}
    ...    num_cells_with_expected_counter_work=${num_cells_with_expected_counter_work}

    check_several_counters_remian_idle_for_each_cell    list_all_interested_counter_ids=${LIST_RRC_RECONF_x_SCELL_SUCC_COUNTER}
    ...    expect_work_counter_id=M55118C03008    cell_id=${cell_id}
    ...    cell_counters_dict=${dict_measurements_value_succ}


1726_GA_126_M55118C04006_M55118C05006
    ${cur_program}    gnb_classical.Get program version based on stream version
    set suite variable    ${PROGRAM}    ${cur_program}
    import library      event_trace_log_analysis.Event_trace_log_analysis_1726    program=${PROGRAM}     WITH NAME    event_trace_analysis
    &{NR_CELL_ID_MAPPING}    coam_gnb_classical.get_relation_mapping_between_cell_index_and_other_ids
    Set suite variable    ${NR_CELL_ID_MAPPING}
    Verify SIM card state and reboot UE if SIM not loaded
    Switch pcell for attach based on cell index    cell_index_for_attach=${1}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${MODIFY_VIA_API_COUNTER}
    Set suite counter list
    Run Keyword And Ignore Error    csn.disconnect    connection=ASIK Master
    Wait until cluster is on cell on air status    timeout=${TIMEOUT_CLUSTER}    is_all_cells_checking_needed=${True}
    Connect to Capacity Unit Master case

    ${parameters_to_update_via_api}    combine lists    ${MODIFY_maxNumScellsDL_4_VIA_API}    ${MODIFY_maxNumScellsUl_0_VIA_API}
    Update parameters which will cause bts restart via api    parameters_to_update_via_api=${parameters_to_update_via_api}
    @{local_counter_file_path}    Attach to pcells and collect counter logs
    ...    is_need_to_keep_ue_attach=${True}    duration_of_ue_attach=10min
    @{all_check_value_status}    create list
    FOR  ${cur_counter_file}  IN  @{local_counter_file_path}
         log to console    ${cur_counter_file}
         ${cur_check_value_status}    run keyword and return status     run keywords
         ...    Expect one counter works while other counters remain idle
         ...    local_counter_log_path=${cur_counter_file}    list_all_interested_counter_ids=${LIST_UE_PSCELL_X_CONF_SCELL_COUNTER}
         ...    expect_work_counter_value=299,300,301    expect_work_counter_id=M55118C04006
         ...    cell_id=1-8      num_cells_with_expected_counter_work=1    AND
         ...    Expect one counter works while other counters remain idle
         ...    local_counter_log_path=${cur_counter_file}    list_all_interested_counter_ids=${LIST_UE_SCELL_X_CONF_SCELL_COUNTER}
         ...    expect_work_counter_value=299,300,301    expect_work_counter_id=M55118C05006
         ...    cell_id=1-8      num_cells_with_expected_counter_work=4
         append to list   ${all_check_value_status}    ${cur_check_value_status}
         exit for loop if    ${cur_check_value_status}
    END
    list should contain value     ${all_check_value_status}    ${True}
# *****************************************************************************************************************
