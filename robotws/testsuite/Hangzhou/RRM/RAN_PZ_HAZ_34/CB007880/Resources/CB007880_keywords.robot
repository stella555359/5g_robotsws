*** Settings ***
Documentation      CB007880 common keywords
Resource     ./CB007880_variables.robot
Resource     ./trigger_from_lmf.robot
Resource     ./verify_from_pcap.robot
Library    ../TestData/online_modify_lib_for_feature.py    WITH NAME    param_modify_lib_7880


*** Variables ***
@{LIST_CELL_ID_WITH_SHARED_TRP}    401    402    403    406


*** Keywords ***
Suite preparation
    [Documentation]  Author: Ding Binmei
    Suite common setup preparation
    ...    prepare_ue=${True}
    ...    is_pdl_checking_needed=${True}    scf_modify_parameters=${None}    NSA_SA=${NSA_SA}
    ${scf_file_path_for_restore}    Download SCF file and return with file path    extended_name=for_restore
    ...    local_dir=${SUITE_LOG_PATH}
    Set suite Variable    ${scf_file_path_for_restore}
    ${trigger_config_file_path}    Update attributes in config file and return new file path
    Set suite Variable    ${trigger_config_file_path}

Suite teardown
    [Documentation]  Author: Ding Binmei
    [Arguments]    ${is_log_required}=${False}
    Common suite recovery    is_log_required=${is_log_required}

Verify counters after positioning procedure
    [Documentation]  Author: Ding Binmei
    ...    Verify counters after positioning procedure
    ...    BTS level:
    ...        NRPPA_TRP_INFO_REQ       M55119C02513(WA:counter >=1 due to env limitation)
    ...        NRPPA_TRP_INFO_RESP      M55119C02514(WA:counter >=1 due to env limitation)
    ...    On serving cell:
    ...        NRPPA_POSIT_INFO_REQ     M55125C13079
    ...        NRPPA_POSIT_INFO_RESP    M55125C13080
    ...    BTS level:
    ...        NRPPA_MEAS_REQ_P         M55119C02503
    ...        NRPPA_MEAS_RESP_P        M55119C02504
    ...        NRPPA_MEAS_REPORT        M55119C02505
    ...    Check points:
    ...    1. Counters for NRPPA_TRP_INFO_REQ, NRPPA_TRP_INFO_RESP, NRPPA_POSIT_INFO_REQ, NRPPA_POSIT_INFO_RESP, NRPPA_MEAS_REQ_P, NRPPA_MEAS_RESP_P
    ...    should be increased for once for all checked durations
    ...    2. Counter for NRPPA_POSIT_INFO_REQ and NRPPA_POSIT_INFO_RESP should be increased for once for serving cell in first duration
    ...    3. Counter for NRPPA_MEAS_REPORT should be around 300s/1.28s=234.375, tolerance is 5 in second duration
    ...    ${pm_files_local_path_first_duration}: PM files downloaded after first duration
    ...    ${pm_files_local_path_second_duration}: PM files downloaded after second duration
    ...    ${cell_id_for_attach}: cell id where UE is attached
    ...    ${measurement_period}: current value is 1280. Get ${MEASUREMENT_PERIOD_FROM_F1AP} value from keyword:
    ...        _Get measurement info from f1ap.PositioningMeasurementRequest based on pci for ru access
    ...    ${meas_report_tolerance}: tolerance for measurement report counter check, default is 5
    [Arguments]    ${pm_files_local_path_first_duration}    ${pm_files_local_path_second_duration}    ${cell_id_for_attach}
    ...     ${measurement_period}=${MEASUREMENT_PERIOD_FROM_F1AP}    ${meas_report_tolerance}=5
    ${list_measurement_ids}    Create list    M55119C02513    M55119C02514    M55125C13079    M55125C13080
    ...    M55119C02503    M55119C02504
    ${pm_files_all_durations}    Combine lists    ${pm_files_local_path_first_duration}    ${pm_files_local_path_second_duration}
    ${dict_total_counters}    counter.get_total_counter_from_multiple_files    list_file_path=${pm_files_all_durations}
    ...    list_measurement_ids=${list_measurement_ids}
    Log to console    Verify counters increased for once for bellow measurement ids: ${list_measurement_ids}
    FOR    ${measurement_id}    IN    @{list_measurement_ids}
        Run keyword and continue on failure    Run keyword if    '${measurement_id}' in ['M55119C02513', 'M55119C02514']
        ...    Should Be True    ${dict_total_counters['${measurement_id}']} >= 1
        ...    msg=WA: For counter ${measurement_id}, the actual value ${dict_total_counters['${measurement_id}']} is less than expected value 1
        ...    ELSE    Should Be Equal As Integers    ${dict_total_counters['${measurement_id}']}    1
        ...    msg=For counter ${measurement_id}, the actual value ${dict_total_counters['${measurement_id}']} is not equal to expected value 1
    END
    Log to console    Verify counter for NRPPA_POSIT_INFO_REQ and NRPPA_POSIT_INFO_RESP increased for once for serving cell
    ${list_measurement_ids_serving_cell}    Create list    M55125C13079    M55125C13080
    ${list_cell_id_for_attach}    Create list    ${cell_id_for_attach}
    ${dict_counters_serving_cell}    counter.get_total_cell_counter_from_multiple_files    list_file_path=${pm_files_local_path_first_duration}
    ...    list_cell=${list_cell_id_for_attach}
    ...    list_measurement_ids=${list_measurement_ids_serving_cell}
    FOR    ${measurement_id}    IN    @{list_measurement_ids_serving_cell}
        ${counter_value}    Set variable    ${dict_counters_serving_cell['${cell_id_for_attach}']['${measurement_id}']}
        Run keyword and continue on failure    Should Be Equal As Integers    ${counter_value}    1
        ...    msg=For serving cell ${cell_id_for_attach}, the actual value ${counter_value} for ${measurement_id} is not equal to expected value 1
    END
    Log to console    Verify counter for NRPPA_MEAS_REPORT, value should be around 234 with tolerance bigger or less than ${meas_report_tolerance}
    ${expect_num_meas_report}    Evaluate    int(300/(${measurement_period}/1000))
    ${list_measurement_id_meas_report}    Create list    M55119C02505
    ${dict_counter_meas_report}    counter.get_total_counter_from_multiple_files    list_file_path=${pm_files_local_path_second_duration}
    ...    list_measurement_ids=${list_measurement_id_meas_report}
    ${act_num_meas_report}    Set variable    ${dict_counter_meas_report['M55119C02505']}
    ${tolerance}    Evaluate    abs(${act_num_meas_report}-${expect_num_meas_report})
    Should Be True    ${tolerance} <= ${meas_report_tolerance}
    ...    msg=For counter NRPPA_MEAS_REPORT,The actual tolerance ${tolerance} is larger than expect tolerance ${meas_report_tolerance}


############## Case steps for bellow 2 cases:
# CB007880_A_TC03_B1_UL-TDOA_Positioning_service_for_one_Supercell_with_RU-ACCESS_different_srs_configuration
# CB007880_A_TC13_B2_UL-TDOA_Positioning_service_for_one_normal_Cell_with_RU-ACCESS_different_srs_configuration
Common case steps for UL TDOA positioning service for Supercell or normal Cell with RU-ACCESS
    [Documentation]    Author: Ding Binmei
    ...    S1 UE attach and trigger MT-LR procedure from LMF
    ...    S2 Verify for counters. Details refer to documentation in keyword: Verify counters after positioning procedure
    ...    S3 Backup current srs pos config for restore config in case teardown
    ...    S4 Detach UE and update srs pos config for all cells with shared TRP
    ...    S5 UE attach and trigger MT-LR procedure from LMF again
    ...    S6 Verify positioning procedure again after srs pos config update
    [Arguments]    ${cell_id_for_attach}    ${exp_TRP_num}    ${exp_TRP_num_for_measurement_report}
    Change status for parameter cellBarred on GNB    exp_status=notBarred   list_cell_ids=${cell_id_for_attach}
    ...        timeout=${TIMER_FOR_MODIFY_VIA_API}
    Wait until cluster ready based on NSA_SA type   NSA_SA=${NSA_SA}    timeout=${TIMER_FOR_ONLINE_STATUS_CHECK}
    ${backup_srs_pos_conf}    Get current srs pos config for restore
    Set test variable    ${backup_srs_pos_conf}

    ${start_log_timestamp}    Prepare for counter log
    ${f1ap_log_path}    UE attach and trigger MT-LR procedure from LMF    cell_id_for_attach=${cell_id_for_attach}
    ...    tcpdump_log_name=S1_f1ap_attach_and_trigger_positioning_procedures
    ${pm_files_local_path_first_duration}    Wait for PM file generated and download
    ...    starting_log_timestamp=${start_log_timestamp['log_generator_timestamp']}
    Connect to Common Unit Master
    ${start_log_timestamp_second_duration}    counter.calculate_waiting_time_for_log_capturing_or_log_generation    reporting_interval=5
    ${pm_files_local_path_second_duration}    Wait for PM file generated and download
    ...    starting_log_timestamp=${start_log_timestamp_second_duration['log_generator_timestamp']}
    Run keyword and continue on failure    Verify positioning procedures    log_file_path=${f1ap_log_path}    cell_id_for_attach=${cell_id_for_attach}
    ...    exp_TRP_num=${exp_TRP_num}    exp_TRP_num_for_measurement_report=${exp_TRP_num_for_measurement_report}
    Run keyword and continue on failure    Verify counters after positioning procedure
    ...    pm_files_local_path_first_duration=${pm_files_local_path_first_duration}
    ...    pm_files_local_path_second_duration=${pm_files_local_path_second_duration}    cell_id_for_attach=${cell_id_for_attach}

    Detach UE and update srs pos config for all cells
    ${f1ap_log_path_after_srs_update}    UE attach and trigger MT-LR procedure from LMF    cell_id_for_attach=${cell_id_for_attach}
    ...    tcpdump_log_name=S2_f1ap_after_srs_update
    Verify positioning procedures    log_file_path=${f1ap_log_path_after_srs_update}    cell_id_for_attach=${cell_id_for_attach}
    ...    exp_TRP_num=${exp_TRP_num}    exp_TRP_num_for_measurement_report=${exp_TRP_num_for_measurement_report}

Get current srs pos config for restore
    [Documentation]    Author: Ding Binmei
    ...    Get current srs pos config for restore
    ...    Choose one cell from list_cell_id to get the srs pos config, because all cells with shared TRP have same srs pos config
    ...    ${list_cell_id}: cell id list to choose from. Default is all cells with shared TRP
    ...    Return: dictionary with keys: cSRS, comb, numberOfCS, srsUePeriodicity
    ...    E.G: {'comb': 'comb2', 'cSRS': 63, 'numberOfCS': '4 cycle shifts', 'srsUePeriodicity': 'slots40'}
    [Arguments]    ${list_cell_id}=@{LIST_CELL_ID_WITH_SHARED_TRP}    ${connection}=GNB_OAM
    ${list_nrcell_info}    coam.get_parameter_by_class    class_name=NRCELL    connection=${connection}
    FOR    ${nrcell_info}    IN    @{list_nrcell_info}
        ${cell_id}    Get Regexp Matches    ${nrcell_info['distName']}    NRCELL-(\\d+)$    1
        Return From Keyword If    "${cell_id[0]}" in ${list_cell_id}    ${nrcell_info['parameters']['srsForPositioning'][0]}
    END
    Fail    Can not find srs pos config for cell ids: ${list_cell_id}

Detach UE and update srs pos config for all cells
    [Documentation]    Author: Ding Binmei
    ...    Detach UE and update srs pos config for all cells
    [Arguments]    ${list_cell_id}=@{LIST_CELL_ID_WITH_SHARED_TRP}
    Retry commercial ue detach if failed
    ${list_params_to_modify}    param_modify_lib_7880.get_srs_pos_config_params_for_update    list_cell_id=${list_cell_id}
    ${dict_params_to_modify}    Create dictionary    param_to_upd=${list_params_to_modify}
    Log to console    Update srs pos config as bellow: ${dict_params_to_modify}
    nidd_modify.online_modify_nidd_parameters_via_restapi    params_modify_dict=${dict_params_to_modify}
    ...        timeout=${TIMER_FOR_MODIFY_VIA_API}
    Wait until cluster ready based on NSA_SA type   NSA_SA=${NSA_SA}    is_need_to_setup_gnb_connection=${False}


############## Case steps for bellow 1 case:
# CB007880_A_TC21_B9_Successful_UL-TDOA_Positioning_service_with_RU-ACCESS_Measurement_session_stop_Measurement_Abort_by_LMF
UL TDOA positioning service for one normal Cell with RU-ACCESS different srs configuration CB007880_A_TC21_B9
    [Documentation]    Author: Qi Xin
    ...    S1 UE attach and trigger MT-LR procedure from LMF
    [Arguments]    ${cell_id_for_attach}    ${exp_TRP_num}    ${exp_TRP_num_for_measurement_report}
    Change status for parameter cellBarred on GNB    exp_status=notBarred   list_cell_ids=${cell_id_for_attach}
    ...        timeout=${TIMER_FOR_MODIFY_VIA_API}
    Wait until cluster ready based on NSA_SA type   NSA_SA=${NSA_SA}    timeout=${TIMER_FOR_ONLINE_STATUS_CHECK}
    ${f1ap_log_path}    UE attach and trigger MT-LR procedure from LMF    cell_id_for_attach=${cell_id_for_attach}
    ...    tcpdump_log_name=f1ap_attach_and_trigger_positioning_procedures

    Run keyword and continue on failure    Verify positioning procedures    log_file_path=${f1ap_log_path}    cell_id_for_attach=${cell_id_for_attach}
    ...    exp_TRP_num=${exp_TRP_num}    exp_TRP_num_for_measurement_report=${exp_TRP_num_for_measurement_report}

F1AP and BIP log capture started then trigger MT-LR abort procedure from LMF
    [Documentation]    Author: Qi Xin
    ...    F1AP and BIP log capture started then trigger MT-LR measurement abort procedure from LMF
    ...    ${tcpdump_log_name}: F1AP log name prefix
    [Arguments]    ${tcpdump_log_name}
    ${timestamp}    DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${tcpdump_log_name}    Set variable    ${tcpdump_log_name}_${timestamp}
    Start capture F1AP log    tcpdump_collector_name=${tcpdump_log_name}
    ${bip_log_name}    Set variable    bip_log_${timestamp}
    Collect Interface Mirroring Bip Collector    target_file_name=${bip_log_name}
    Log To Console    Start collect BIP log
    Trigger MT-LR abort procedure from LMF    trigger_config_file_path=${trigger_config_file_path}    retry_time=3
    Sleep    10s    reason=Wait for MT-LR measurement abort triggered
    ${f1ap_log_path}    logs.Stop capture F1AP log    tcpdump_collector_name=${tcpdump_log_name}
    Log To Console    Stop and collect BIP log
    ${bip_log_file_path}    Get Bip Log Via Interface Mirroring Collector    target_file_name=${bip_log_name}
    [Return]    ${f1ap_log_path}
    [Teardown]  Run keyword and ignore error    Run keywords    Stop Tcpdump via collector    tcpdump_collector_name=${tcpdump_log_name}    AND
    ...    Stop Bip Log Via Interface Mirroring Collector    target_file_name=${bip_log_name}
