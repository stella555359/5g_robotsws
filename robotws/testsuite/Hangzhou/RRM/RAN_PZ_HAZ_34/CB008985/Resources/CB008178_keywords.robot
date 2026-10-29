*** Settings ***
Resource    ./CB008985_keywords.robot
Library    ./preamble_power_PRACH_level.py

Documentation
...   This is for Supercell CB008178 keywords.
...   author: Liu Zheng
...   contact: zheng.4.liu@nokia-sbell.com
...   squad group: MMW_SG1

*** Variables ***
${testline_name}    null
${ENB_SCF_DEFAULT_FILE_PATH}   ${None}

*** Keywords ***
CB008178 Case setup
    [Arguments]  ${NSA_SA}=SA   ${is_pdl_checking_needed}=${true}    ${scf_template_path}=${SCF_DEFAULT_FILE_PATH}
    Set test variable    ${NSA_SA}    ${NSA_SA}

    COAM Create log directory    is_set_to_test_case_level=${True}
    Common case setup   NSA_SA=${NSA_SA}   is_pdl_checking_needed=${is_pdl_checking_needed}     is_log_required=${false}
    ...           scf_template_path=${scf_template_path}

    Change status for parameter cellBarred on GNB    exp_status=notBarred   timeout=2min
    Enable CB008178 via restAPI


Enable CB008178 via restAPI
    [Arguments]    ${timeout}=${TIMER_FOR_MODIFY_VIA_API}
    ${miNrSSBPM}    evaluate
    ...    dict(dist_name='NRBTS-${NRBTS_ID}/NRPMRNL-1', parameter='miNrSSBPM', value='5min')
    ${miNrUlSignalQuality2}    evaluate
    ...    dict(dist_name='NRBTS-${NRBTS_ID}/NRPMRNL-1', parameter='miNrUlSignalQuality2', value='5min')
    ${params_to_upd}    create list    ${miNrSSBPM}    ${miNrUlSignalQuality2}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${params_to_upd}    timeout=${timeout}
    Wait until cluster ready based on NSA_SA type      NSA_SA=${NSA_SA}

Set higher qRxLevMin via restAPI
    [Arguments]    ${cell_id}    ${timeout}=${TIMER_FOR_MODIFY_VIA_API}
    ${qRxLevMin}    evaluate
    ...    dict(dist_name='NRBTS-${NRBTS_ID}/NRCELL-${cell_id}', parameter='qRxLevMin', value='-45')
    ${params_to_upd}    create list    ${qRxLevMin}    ${qRxLevMin}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${params_to_upd}    timeout=${timeout}
    Wait until cluster ready based on NSA_SA type      NSA_SA=${NSA_SA}

UE attach several times then check AVG_RX_PREAMBLE_POWER_SSB and RX_PREAMBLE_PWR_PRACH_LEVEL counters
    [Documentation]    Author: Liu Zheng
    ...    adjust PA to make UE attach to specific subcell
    ...    UE attach detach 10 times
    ...    check the AVG_RX_PREAMBLE_POWER_SSB and RX_PREAMBLE_PWR_PRACH_LEVEL counters are correct
    ...    BIP log check message
    ...    (uldata_prachreceiveind) && (UlData_prachReceiveIndSubcell_t.detectedPrachPreambles.Length == 1)
    ...    or (UlData_prachReceiveIndSubcell_t.prachPreambleTimeOccasion.Length == 1) when ssb_beam_id_list is given
    ...    subcell_id: scalar or list, not a dictionary
    [Arguments]    ${cell_id}    ${subcell_id}    ${reporting_interval}=5    ${attach_times}=${10}
    ...    ${ue_type}=${UE_TYPE}   ${ue_index}=${0}    ${connection}=GNB_OAM    ${gnb_index}=${0}
    ...    ${target_file_name}=bip_log_attach_10_times     ${mirroring_filter}=SpecificL1L2Messages
    ...    ${specific_message_ids}=0xe24d    ${ssb_beam_needed}=${False}    ${ssb_id_list}=${None}

    ${subcell_id_list}    create list    ${subcell_id}
    ${start_time}    Prepare for counter log    reporting_interval=${reporting_interval}

    run keyword and continue on failure     Collect Interface Mirroring Bip Collector    target_file_name=${target_file_name}
                                          ...    mirroring_filter=${mirroring_filter}
                                          ...    specific_message_ids=${specific_message_ids}
                                          ...    gnb_index=${gnb_index}

    FOR    ${i}    IN RANGE    ${attach_times}
        retry commercial ue attach if failed     prepare_ue_needed=${False}    ue_index=${ue_index}
        ...    connection=${connection}    ue_type=${ue_type}    retry_time=1
        sleep    2s
        power_ue.UE Detach    ue_type=${UE_TYPE}    ue_index=${ue_index}
        sleep    2s
    END

    ${bip_log}    Get Bip Log Via Interface Mirroring Collector    target_file_name=${target_file_name}
    ${pm_files_local_path}    Wait for PM file generated and download    starting_log_timestamp=${start_time['log_generator_timestamp']}
    ${peak_metric_list}    get peakMetric list from BIP log    log_path=${bip_log}

    run keyword if    ${ssb_beam_needed} == ${True}    Process SSB Beam ID List    cell_id=${cell_id}   bip_log=${bip_log}
                                                ...    ssb_id_list=${ssb_id_list}    pm_files_local_path=${pm_files_local_path}
    ...    ELSE    Check PM counters for preamble power    cell_id=${cell_id}    should_update=${True}    subcell_id_list=${subcell_id_list}
                   ...    pm_files_local_path=${pm_files_local_path}    peak_metric_list=${peak_metric_list}
    Check PM counters for preamble power PRACH level    cell_id=${cell_id}    should_update=${True}
    ...    pm_files_local_path=${pm_files_local_path}    peak_metric_list=${peak_metric_list}
    [Teardown]    run keyword and ignore error    run keywords    Stop Bip Log Via Interface Mirroring Collector
    ...    target_file_name=${target_file_name}
    ...    AND    run keyword and ignore error    power_ue.UE Detach    ue_type=${UE_TYPE}    ue_index=${ue_index}

UE attach start DL and UL traffic then check PDSCH_INIRE_VOL_SSB and PUSCH_INIRE_VOL_SSB counters
    [Arguments]  ${dl_iperf_tput}=800M    ${ul_iperf_tput}=200M    ${exp_ul_indiv}=60     ${exp_dl_indiv}=705
    ...    ${ue_type}=${UE_TYPE}   ${ue_index}=${0}    ${connection}=GNB_OAM
    ...    ${cell_id}=1    ${subcell_id}=0    ${data_transfer_direction}=both
    ...    ${customized_log_name}=supercell_dl_ul_tput_check    ${reporting_interval}=5
    ...    ${detach_ue}=${False}    ${duration}=60    ${ignore_time}=30s
    ...    ${normalCell_2TCA}=${False}    ${normalCell_ssb_list}=${None}
    retry commercial ue attach if failed     prepare_ue_needed=${False}    ue_index=${ue_index}
        ...    connection=${connection}    ue_type=${ue_type}
    ${start_time}    Prepare for counter log    reporting_interval=${reporting_interval}

    Start data transfer based on direction    data_transfer_direction=${data_transfer_direction}    dl_tput=${dl_iperf_tput}
    ...        ul_tput=${ul_iperf_tput}       duration=${DURATION_OF_TPUT_SEND}

    ${pm_files_local_path}    Wait for PM file generated and download    starting_log_timestamp=${start_time['log_generator_timestamp']}

    ${scell_id}    Evaluate    ${cell_id} + 1
    ${cell_id_list}    run Keyword If    ${normalCell_2TCA}    Set Variable    ${cell_id},${scell_id}
    run keyword if    ${normalCell_2TCA}==${False}    Collect Tput and Check Tput As Expected    cell_id=${cell_id}
    ...    direction=${data_transfer_direction}    exp_ul_indiv=${exp_ul_indiv}    exp_dl_indiv=${exp_dl_indiv}
    ...    customized_log_name=${customized_log_name}    duration=${duration}    ignore_time=${ignore_time}
    ...    ELSE    Collect Tput and Check Tput As Expected    cell_id=${cell_id_list}
    ...    direction=${data_transfer_direction}    exp_ul_indiv=${exp_ul_indiv}    exp_dl_indiv=${exp_dl_indiv}
    ...    customized_log_name=${customized_log_name}    duration=${duration}    ignore_time=${ignore_time}

    Check PM counters for traffic volumes    cell_id=${cell_id}    source_subcell_id=${subcell_id}    traffic_with_subcell_switch=${False}
    ...    pm_files_local_path=${pm_files_local_path}    normalCell_2TCA=${normalCell_2TCA}     normalCell_ssb_list=${normalCell_ssb_list}
    # run Keyword If    ${normalCell_2TCA}    Check PM counters for traffic volumes    cell_id=${scell_id}    source_subcell_id=${subcell_id}
    # ...    traffic_with_subcell_switch=${False}    pm_files_local_path=${pm_files_local_path}
    run keyword if    ${detach_ue}    run keyword and ignore error    Stop data transfer based on direction
    run keyword if    ${detach_ue}    run keyword and ignore error    power_ue.UE Detach    ue_type=${UE_TYPE}    ue_index=${ue_index}

Adjust PA to trigger subcell switch check counters
    [Documentation]
    ...      need update traffic volumes when subcell switch
    ...      counter_name:which counter you want to check, details please refer to couner define.
    ...      counter_expected_number: expected value.
    [Arguments]
    ...    ${exp_ul_indiv}=1       ${exp_dl_indiv}=1     ${cell_id}=1
    ...    ${gnb_index}=${0}    ${target_file_name}=bip_log_include_subcell_switch    ${mirroring_filter}=SpecificL1L2Messages
    ...    ${source_subcell_id}=0    ${target_subcell_id}=1    ${reporting_interval}=5
    ...    ${specific_message_ids}=0xe24d
    ...    ${source_target_subcell_pa_info}=${NONCA_Supercell1_Subcell_0_Switch_To_Subcell_2}
    ...    ${PA_back_after_subcell_switch}=${NONCA_Supercell1_SUBCELL2_ATTACH_PA_INIT}
    ...    ${duration}=${DURATION_OF_SUBCELL_SWITCH_TPUT_CHECK}    ${ignore_time}=1s
    ...    ${traffic_with_subcell_switch}=${True}
    ...    ${ue_type}=${UE_TYPE}   ${ue_index}=${0}
    ${subcell_id_list}    create list    ${source_subcell_id}    ${target_subcell_id}
    ${start_time}    Prepare for counter log    reporting_interval=${reporting_interval}

    run keyword and continue on failure     Collect Interface Mirroring Bip Collector    target_file_name=${target_file_name}
                                          ...    mirroring_filter=${mirroring_filter}
                                          ...    specific_message_ids=${specific_message_ids}
                                          ...    gnb_index=${gnb_index}

    _Adjust PA Value For Source And Target Subcell
    ...    source_subcell_pa=${source_target_subcell_pa_info['source_subcell']}
    ...    target_subcell_pa=${source_target_subcell_pa_info['target_subcell']}

    Initialize attenuator values for testline    pa_values_mapping=${PA_back_after_subcell_switch}
    sleep    3s
    ${bip_log}    Get Bip Log Via Interface Mirroring Collector    target_file_name=${target_file_name}

    ${pm_files_local_path}    Wait for PM file generated and download    starting_log_timestamp=${start_time['log_generator_timestamp']}

    Collect Tput and Check Tput As Expected    cell_id=${cell_id}     direction=both
    ...       exp_ul_indiv=${exp_ul_indiv}    exp_dl_indiv=${exp_dl_indiv}
    ...       customized_log_name=nonca_cell_subcell_switch_tput    duration=${duration}
    ...      ignore_time=${ignore_time}Collect Tput and Check Tput As Expected    cell_id=${cell_id}     direction=both
    ...       exp_ul_indiv=${exp_ul_indiv}    exp_dl_indiv=${exp_dl_indiv}
    ...       customized_log_name=nonca_cell_subcell_switch_tput    duration=${duration}
    ...      ignore_time=${ignore_time}Collect Tput and Check Tput As Expected    cell_id=${cell_id}     direction=both
    ...       exp_ul_indiv=${exp_ul_indiv}    exp_dl_indiv=${exp_dl_indiv}
    ...       customized_log_name=nonca_cell_subcell_switch_tput    duration=${duration}
    ...      ignore_time=${ignore_time}

    ${peak_metric_list}    get peakMetric list from BIP log    log_path=${bip_log}

    Check PM counters for preamble power    cell_id=${cell_id}    should_update=${False}    subcell_id_list=${subcell_id_list}
    ...    pm_files_local_path=${pm_files_local_path}    peak_metric_list=${peak_metric_list}
    Check PM counters for preamble power PRACH level    cell_id=${cell_id}    should_update=${False}
    ...    pm_files_local_path=${pm_files_local_path}        peak_metric_list=${peak_metric_list}
    Check PM counters for traffic volumes    cell_id=${cell_id}    source_subcell_id=${source_subcell_id}    target_subcell_id=${target_subcell_id}
    ...    pm_files_local_path=${pm_files_local_path}    traffic_with_subcell_switch=${traffic_with_subcell_switch}
    [Teardown]    run keywords    run keyword and ignore error    Stop data transfer based on direction
    ...    AND    run keyword and ignore error    power_ue.UE Detach    ue_type=${UE_TYPE}    ue_index=${ue_index}


get peakMetric list from BIP log
    [Documentation]    Author: Liu Zheng
    ...    log_path:    bip log path
    ...    filter:      (uldata_prachreceiveind) && (UlData_prachReceiveIndSubcell_t.detectedPrachPreambles.Length == 1)
    [Arguments]    ${log_path}    ${filter}=(uldata_prachreceiveind) && (UlData_prachReceiveIndSubcell_t.detectedPrachPreambles.Length == 1)
    ${rim_rs_detection_request}    set variable    ${False}
    pcap.setup    infile=${log_path[0]}    display_filter=${filter}
    sleep    1s
    ${result}    pcap.get_field_value_by_name   field_name=UlData_detectedPrachPreambles_t.peakMetric
                                            ...    attribute_name=show
    ${count}    Get Length    ${result}
    [Return]    ${result}

Process SSB Beam ID List
    [Documentation]    Author: Jiang Xian
    [Arguments]    ${cell_id}    ${bip_log}    ${ssb_id_list}    ${pm_files_local_path}    ${should_update}=${True}
    ${peak_metric_list}    get peakMetric list from BIP log    log_path=${bip_log}
    ...    filter=UlData_detectedPrachPreambles_t.peakMetric
    ${length}    Get Length    ${peak_metric_list}
    run keyword if     ${length} > 0    Check preamble power avg from PM counters
    ...    cell_id=${cell_id}     should_update=${should_update}   ssb_id_list=${ssb_id_list}
    ...    pm_files_local_path=${pm_files_local_path}    peak_metric_list=${peak_metric_list}

get timeoccasion_id list from BIP log
    [Documentation]    Author: Jiang Xian
    ...    log_path:    bip log path
    ...    filter:      (uldata_prachreceiveind) && (UlData_prachReceiveIndSubcell_t.detectedPrachPreambles.Length == 1)
    [Arguments]    ${log_path}    ${filter}=(uldata_prachreceiveind) && (UlData_prachReceiveIndSubcell_t.detectedPrachPreambles.Length == 1)
    ${rim_rs_detection_request}    set variable    ${False}
    pcap.setup    infile=${log_path[0]}    display_filter=${filter}
    sleep    1s
    ${result}    pcap.get_field_value_by_name   field_name=UlData_detectedPrachPreambles_t.prachPreambleTimeOccasion
                                            ...    attribute_name=show
    ${last}    Get From List    ${result}    -1
    [Return]    ${last}

Check PM counters for preamble power
    [Documentation]    Author: Liu Zheng
    ...    M55202C00006: AVG_RX_PREAMBLE_PWR_SSB, Average received preamble power per SSB
    ...    KW need to update due to counter under ssbpm
    [Arguments]    ${cell_id}    ${subcell_id_list}    ${pm_files_local_path}    ${peak_metric_list}
    ...    ${should_update}=${True}
    ${list_measurement_ids_preamble_power}    create list   M55202C00006
    ${cell_check_list}    create list    ${cell_id}
    FOR    ${file_path}    IN    @{pm_files_local_path}
        ${dict_meas_val}    get_cell_SSB_counters_from_file    file_path=${file_path}    list_cell_ids=${cell_check_list}
        ...    list_ssb_ids=${subcell_id_list}    list_measurement_ids=${list_measurement_ids_preamble_power}
    END
    run keyword if    ${should_update} == ${True}    M55202C00006 value on webUI should equal to the value calculated based on BIP log
    ...    cell_id=${cell_id}    subcell_id_list=${subcell_id_list}    peak_metric_list=${peak_metric_list}    dict_meas_val=${dict_meas_val}
    ...    ELSE    M55202C00006 value on webUI should not update
    ...    cell_id=${cell_id}    subcell_id_list=${subcell_id_list}    dict_meas_val=${dict_meas_val}

Check preamble power avg from PM counters
    [Documentation]    Author: Catherine Cheng
    ...    Check preamble power avg from PM counters
    ...    M55202C00006: AVG_RX_PREAMBLE_PWR_SSB, Average received preamble power per SSB
    ...    M55202C00003: Number of CBRA setup attempts corresponding to SSB beam
    ...    KW need to update due to counter under ssbpm
    [Arguments]    ${cell_id}    ${ssb_id_list}    ${pm_files_local_path}    ${peak_metric_list}
    ...    ${should_update}=${True}
    ${list_measurement_ids_preamble_power}    create list   M55202C00003    M55202C00006
    ${cell_check_list}    create list    ${cell_id}
    FOR    ${file_path}    IN    @{pm_files_local_path}
        ${dict_meas_val}    get_cell_SSB_counters_from_file    file_path=${file_path}    list_cell_ids=${cell_check_list}
        ...    list_ssb_ids=${ssb_id_list}    list_measurement_ids=${list_measurement_ids_preamble_power}
    END
    run keyword if    ${should_update} == ${True}   Check preamble power avg from PM counters should equals to value calculated from BIP log
    ...    cell_id=${cell_id}    ssb_id_list=${ssb_id_list}    peak_metric_list=${peak_metric_list}    dict_meas_val=${dict_meas_val}
    ...    ELSE    M55202C00006 value on webUI should not update
    ...    cell_id=${cell_id}    subcell_id_list=${ssb_id_list}    dict_meas_val=${dict_meas_val}

Check preamble power avg from PM counters should equals to value calculated from BIP log
    [Documentation]    Author: Catherine Cheng
    ...    Check preamble power avg from PM counters should equals to value calculated from BIP log
    ...    M55202C00006: AVG_RX_PREAMBLE_PWR_SSB, Average received preamble power per SSB
    ...    M55202C00003: Number of CBRA setup attempts corresponding to SSB beam
    ...    KW need to update due to counter under ssbpm
    [Arguments]    ${cell_id}    ${ssb_id_list}    ${peak_metric_list}    ${dict_meas_val}
    ${peamMetric_dbm_average}    get_average_peakMetric_dbm_value    peak_metric_list=${peak_metric_list}
    ${peakMetric_dbm_low}    Evaluate    ${peamMetric_dbm_average}-${0.01}
    ${peakMetric_dbm_low}    Evaluate    round(${peakMetric_dbm_low},2)
    ${peakMetric_dbm_high}    Evaluate    ${peamMetric_dbm_average}+${0.01}
    ${peakMetric_dbm_high}    Evaluate    round(${peakMetric_dbm_high},2)
    ${pm_peakMetric_dbm_sum}  set variable    ${0}
    ${pm_prach_attempts_sum}  set variable    ${0}
    FOR    ${ssb_id}    IN    @{ssb_id_list}
        ${pm_peakMetric_dbm_avg}    set variable    ${dict_meas_val['${cell_id}']['${ssb_id}']['M55202C00006']}
        ${pm_prach_attempts}    set variable    ${dict_meas_val['${cell_id}']['${ssb_id}']['M55202C00003']}
        Continue For Loop If     ${pm_prach_attempts} <= 0
        ${pm_peakMetric_dbm_sum}   Evaluate    ${pm_peakMetric_dbm_sum} + ${pm_peakMetric_dbm_avg} * ${pm_prach_attempts}
        ${pm_prach_attempts_sum}   Evaluate    ${pm_prach_attempts_sum} + ${pm_prach_attempts}
    END
    ${pm_peakMetric_dbm_avg}    Evaluate    ${pm_peakMetric_dbm_sum} / ${pm_prach_attempts_sum}
    Should be true    ${peakMetric_dbm_low} <= ${pm_peakMetric_dbm_avg} <= ${peakMetric_dbm_high}

M55202C00006 value on webUI should not update
    [Arguments]    ${cell_id}    ${subcell_id_list}    ${dict_meas_val}
    FOR    ${subcell_id}    IN    @{subcell_id_list}
        run keyword and continue on failure     should be true    ${dict_meas_val['${cell_id}']['${subcell_id}']['M55202C00006']} == ${None}
    END

M55202C00006 value on webUI should equal to the value calculated based on BIP log
    [Documentation]
    ...    convert the peakMetric from m
    ...    element_100 = 100 * 10 * math.log10(element_bip_float)
    ...    element_floor = math.floor(element_100)
    ...    element = element_floor/100
    [Arguments]    ${cell_id}    ${subcell_id_list}    ${peak_metric_list}    ${dict_meas_val}
    ${peamMetric_dbm_average}    get_average_peakMetric_dbm_value    peak_metric_list=${peak_metric_list}
    ${peakMetric_dbm_low}    Evaluate    ${peamMetric_dbm_average}-${0.01}
    ${peakMetric_dbm_low}    Evaluate    round(${peakMetric_dbm_low},2)
    ${peakMetric_dbm_high}    Evaluate    ${peamMetric_dbm_average}+${0.01}
    ${peakMetric_dbm_high}    Evaluate    round(${peakMetric_dbm_high},2)
    FOR    ${subcell_id}    IN    @{subcell_id_list}
        run keyword and continue on failure     should be true
        ...    ${peakMetric_dbm_low} <= ${dict_meas_val['${cell_id}']['${subcell_id}']['M55202C00006']} <= ${peakMetric_dbm_high}
    END


Check PM counters for preamble power PRACH level
    [Documentation]    Author: Liu Zheng
    ...    M55340C00026:RX_PREAMBLE_PWR_PRACH_LEVEL_01, level 1 <= -114dBm;
    ...    M55340C00027:RX_PREAMBLE_PWR_PRACH_LEVEL_02, -114dbm < level 2 <= -112 dBm;
    ...    M55340C00028:RX_PREAMBLE_PWR_PRACH_LEVEL_03, -112dBm < level 3 <= -110dBm;
    ...    M55340C000**:RX_PREAMBLE_PWR_PRACH_LEVEL_**
    ...    M55340C00069:RX_PREAMBLE_PWR_PRACH_LEVEL_44, -30 dBm < level 44.
    [Arguments]    ${cell_id}    ${pm_files_local_path}    ${peak_metric_list}    ${should_update}=${True}
    ${list_measurement_ids_preamble_power_on_PRACH_level}    create list    M55340C00026    M55340C00027    M55340C00028    M55340C00029
    ...    M55340C00030    M55340C00031    M55340C00032    M55340C00033    M55340C00034    M55340C00035    M55340C00036    M55340C00037
    ...    M55340C00038    M55340C00039    M55340C00040    M55340C00041    M55340C00042    M55340C00043    M55340C00044    M55340C00045
    ...    M55340C00046    M55340C00047    M55340C00048    M55340C00049    M55340C00050    M55340C00051    M55340C00052    M55340C00053
    ...    M55340C00054    M55340C00055    M55340C00056    M55340C00057    M55340C00058    M55340C00059    M55340C00060    M55340C00061
    ...    M55340C00062    M55340C00063    M55340C00064    M55340C00065    M55340C00066    M55340C00067    M55340C00068    M55340C00069

    ${cell_check_list}    create list    ${cell_id}
    FOR    ${file_path}    IN    @{pm_files_local_path}
        ${dict_meas_val}    counter.get_cell_counters_from_file    file_path=${file_path}
                                                        ...      list_cell=${cell_check_list}
                                                        ...      list_measurement_ids=${list_measurement_ids_preamble_power_on_PRACH_level}
    END

    run keyword if    ${should_update} == ${True}    RX_PREAMBLE_PWR_PRACH_LEVEL counter value on webUI match the value calculated based on BIP log
    ...    cell_id=${cell_id}    peak_metric_list=${peak_metric_list}      dict_meas_val=${dict_meas_val}
    ...    ELSE    RX_PREAMBLE_PWR_PRACH_LEVEL counter value on webUI should not updated    cell_id=${cell_id}
    ...    counter_list=${list_measurement_ids_preamble_power_on_PRACH_level}    dict_meas_val=${dict_meas_val}

RX_PREAMBLE_PWR_PRACH_LEVEL counter value on webUI match the value calculated based on BIP log
    [Arguments]    ${cell_id}    ${peak_metric_list}    ${dict_meas_val}
    ${dict_based_on_bip_log}    get_the_updated_preamble_power_PRACH_level_based_on_peakmetric    peak_metric_list=${peak_metric_list}
    FOR    ${key}    IN    @{dict_based_on_bip_log.keys()}
        run keyword and continue on failure     should be true    ${dict_based_on_bip_log['${key}']} == ${dict_meas_val['${cell_id}']['${key}']}
    END

RX_PREAMBLE_PWR_PRACH_LEVEL counter value on webUI should not updated
    [Arguments]    ${cell_id}    ${counter_list}    ${dict_meas_val}
    ${sum_rx_preamble_pwr_prach_level}    get sum value of the counter list    cell_id=${cell_id}    counter_list=${counter_list}
    ...    dict_meas_val=${dict_meas_val}
    run keyword and continue on failure     should be true       ${sum_rx_preamble_pwr_prach_level}==${0}

Check PM counters for traffic volumes
    [Documentation]    Author: Liu Zheng
    ...    KW need to update due to counter under ssbpm   for subcell switch scenarios, need check two subcells counters
    ...    Traffic volumes per synchronization signal block (SSB) beam (​2 counters)
    ...    M55202C00007 Initial and retransmission volume on PDSCH per SSB
    ...    M55202C00007 should equal to SUM(M55304C06000,…, M55304C06031)+SUM(M55304C02000,…, M55304C02031)
    ...    M55202C00008 Initial and retransmission volume on PUSCH per SSB
    ...    M55202C000008 should equal to SUM(M55304C10000,...,M55304C10031)+SUM(M55304C04000,…, M55304C04031)
    [Arguments]    ${cell_id}    ${source_subcell_id}    ${pm_files_local_path}     ${target_subcell_id}=${None}
    ...    ${traffic_with_subcell_switch}=${False}    ${normalCell_2TCA}=${False}     ${normalCell_ssb_list}=${None}
    ${subcell_id_list_without_subcell_switch}    create list    ${source_subcell_id}
    ${subcell_id_list_subcell_switch}    create list    ${source_subcell_id}    ${target_subcell_id}
    ${subcell_id_list}    set variable if    ${traffic_with_subcell_switch}==${True}    ${subcell_id_list_subcell_switch}
    ...    ${normalCell_2TCA}==${True}    ${normalCell_ssb_list}
    ...    ${traffic_with_subcell_switch}==${False} and ${normalCell_2TCA}==${False}     ${subcell_id_list_without_subcell_switch}
    ${list_measurement_ids_traffic_volumes}    create list    M55202C00007    M55202C00008
    ${list_measurement_ids_DL_traffic_256QAM_legacy}    create list    M55304C06000    M55304C06001    M55304C06002    M55304C06003
    ...    M55304C06004    M55304C06005    M55304C06006    M55304C06007    M55304C06008    M55304C06009    M55304C06010    M55304C06011
    ...    M55304C06012    M55304C06013    M55304C06014    M55304C06015    M55304C06016    M55304C06017    M55304C06018    M55304C06019
    ...    M55304C06020    M55304C06021    M55304C06022    M55304C06023    M55304C06024    M55304C06025    M55304C06026    M55304C06027
    ...    M55304C06028    M55304C06029    M55304C06030    M55304C06031

    ${list_measurement_ids_DL_traffic_64QAM_legacy}    create list    M55304C02000    M55304C02001    M55304C02002    M55304C02003
    ...    M55304C02004    M55304C02005    M55304C02006    M55304C02007    M55304C02008    M55304C02009    M55304C02010    M55304C02011
    ...    M55304C02012    M55304C02013    M55304C02014    M55304C02015    M55304C02016    M55304C02017    M55304C02018    M55304C02019
    ...    M55304C02020    M55304C02021    M55304C02022    M55304C02023    M55304C02024    M55304C02025    M55304C02026    M55304C02027
    ...    M55304C02028    M55304C02029    M55304C02030    M55304C02031

    ${list_measurement_ids_UL_traffic_256QAM_legacy}    create list    M55304C10000    M55304C10001    M55304C10002    M55304C10003
    ...    M55304C10004    M55304C10005    M55304C10006    M55304C10007    M55304C10008    M55304C10009    M55304C10010    M55304C10011
    ...    M55304C10012    M55304C10013    M55304C10014    M55304C10015    M55304C10016    M55304C10017    M55304C10018    M55304C10019
    ...    M55304C10020    M55304C10021    M55304C10022    M55304C10023    M55304C10024    M55304C10025    M55304C10026    M55304C10027
    ...    M55304C10028    M55304C10029    M55304C10030    M55304C10031

    ${list_measurement_ids_UL_traffic_64QAM_legacy}    create list    M55304C04000    M55304C04001    M55304C04002    M55304C04003
    ...    M55304C04004    M55304C04005    M55304C04006    M55304C04007    M55304C04008    M55304C04009    M55304C04010    M55304C04011
    ...    M55304C04012    M55304C04013    M55304C04014    M55304C04015    M55304C04016    M55304C04017    M55304C04018    M55304C04019
    ...    M55304C04020    M55304C04021    M55304C04022    M55304C04023    M55304C04024    M55304C04025    M55304C04026    M55304C04027
    ...    M55304C04028    M55304C04029    M55304C04030    M55304C04031

    ${list_measurement_ids_DL_legacy}     combine lists    ${list_measurement_ids_DL_traffic_256QAM_legacy}
    ...    ${list_measurement_ids_DL_traffic_64QAM_legacy}

    ${list_measurement_ids_UL_legacy}     combine lists    ${list_measurement_ids_UL_traffic_256QAM_legacy}
    ...    ${list_measurement_ids_UL_traffic_64QAM_legacy}

    ${list_measurement_ids_legacy}     combine lists    ${list_measurement_ids_DL_legacy}    ${list_measurement_ids_UL_legacy}
    ${cell_check_list}    create list    ${cell_id}
    FOR    ${file_path}    IN    @{pm_files_local_path}
        ${dict_meas_val}    get_cell_SSB_counters_from_file    file_path=${file_path}    list_cell_ids=${cell_check_list}
        ...    list_ssb_ids=${subcell_id_list}    list_measurement_ids=${list_measurement_ids_traffic_volumes}
    END

    FOR    ${file_path}    IN    @{pm_files_local_path}
        ${dict_meas_val_legacy}    counter.get_cell_counters_from_file    file_path=${file_path}
                                                        ...      list_cell=${cell_check_list}
                                                        ...      list_measurement_ids=${list_measurement_ids_legacy}
    END

    ${sum_dl_legacy}    get sum value of the counter list    cell_id=${cell_id}    counter_list=${list_measurement_ids_DL_legacy}
    ...    dict_meas_val=${dict_meas_val_legacy}

    ${sum_ul_legacy}    get sum value of the counter list    cell_id=${cell_id}    counter_list=${list_measurement_ids_UL_legacy}
    ...    dict_meas_val=${dict_meas_val_legacy}

    run keyword and continue on failure     traffic volume check should be correct
    ...      cell_id=${cell_id}    sum_dl_legacy=${sum_dl_legacy}    sum_ul_legacy=${sum_ul_legacy}    subcell_id_list=${subcell_id_list}
    ...      dict_meas_val=${dict_meas_val}

traffic volume check should be correct
    [Arguments]    ${cell_id}    ${sum_dl_legacy}    ${sum_ul_legacy}    ${subcell_id_list}      ${dict_meas_val}
    ${traffic_volume_in_cb008178_dl}    set variable    ${0}
    ${traffic_volume_in_cb008178_ul}    set variable    ${0}
    FOR    ${subcell_id}    IN    @{subcell_id_list}
        ${traffic_volume_in_cb008178_dl}  evaluate  ${traffic_volume_in_cb008178_dl}+${dict_meas_val['${cell_id}']['${subcell_id}']['M55202C00007']}
        ${traffic_volume_in_cb008178_ul}  evaluate  ${traffic_volume_in_cb008178_ul}+${dict_meas_val['${cell_id}']['${subcell_id}']['M55202C00008']}
    END
    run keyword and continue on failure     should be true    ${traffic_volume_in_cb008178_dl} == ${sum_dl_legacy}
    run keyword and continue on failure     should be true    ${traffic_volume_in_cb008178_ul} == ${sum_Ul_legacy}

get sum value of the counter list
    [Documentation]    Author: Liu Zheng
    [Arguments]    ${cell_id}    ${counter_list}    ${dict_meas_val}
    ${sum_counters}    set variable    ${0}
    FOR    ${counter}    IN    @{counter_list}
        ${value}    evaluate    ${dict_meas_val['${cell_id}']['${counter}']}
        ${sum_counters}    evaluate    ${sum_counters}+${value}
    END
    [Return]    ${sum_counters}


