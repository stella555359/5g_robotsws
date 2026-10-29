*** Settings ***
Documentation    For 6137_C_B27_01 case.
Resource   ./CB006137_keywords.robot


*** Keywords ***
C_B27_01_S1_Adjust pcell signal from good to bad and verify transform Precoder is enabled for pcell
    [Documentation]  Author: Ding Binmei
    ...    Adjust PA for pcell gradually to trigger transform Precoder enabled for pcell
    ...    1.1 Monitor aasyslog about whether transform Precoder reconfig is triggered
    ...    1.2 Double confirm from F1AP to check transform Precoder is enabled for pcell
    [Arguments]    ${pa_start_retry}=${PA_PCELL_BAD_RETRY_START}    ${pa_end_retry}=${PA_PCELL_BAD_RETRY_END}    ${pa_interval}=1
    Log to console    S1 Adjust pcell signal from good to bad and verify transform Precoder is enabled for pcell
    ${file_name_f1ap_good_to_bad}    Set variable    S1_f1ap_good_to_bad_PA_${pa_end_retry}
    Start capture F1AP log    tcpdump_collector_name=${file_name_f1ap_good_to_bad}   options=-i any sctp
    Teardown the Aasyslog save progress
    Aasyslog precondition
    ${aasyslog_gnb_log_path}    Start the Aasyslog save progress    filter=L2\\|cp    log_name=aasyslog_pcell_good_to_bad.txt
    ...    is_ssh_con_released=${False}
    ${status_aasyslog_result}    run keyword and return status    Adjust PA gradualy for provided cells and verify if TP reconfig is triggered
    ...    pa_start=0    pa_end=${pa_start_retry}    pa_interval=10    list_cell_id=${PCELL_ID}    aasyslog_log_path=${aasyslog_gnb_log_path}
    ${pa_start_retry}    Evaluate    int(${pa_start_retry})+1
    ${status_aasyslog_result_retry}    Run keyword and return status    Run keyword if    ${status_aasyslog_result}==${False}
    ...    Retry retrigger if transform Precoder reconfig not happened
    ...        pa_start_retry=${pa_start_retry}    pa_end_retry=${pa_end_retry}    pa_interval=${pa_interval}
    ...        aasyslog_log_path=${aasyslog_gnb_log_path}    list_cell_id=${PCELL_ID}
    Sleep    2s    reason=Waiting for F1AP log capturing, in case log print delay
    ${tcpdump_log_file_path_f1ap}    Stop tcpdump log collection    tcpdump_collector_name=${file_name_f1ap_good_to_bad}
    ${transformPrecoder}    Get transformPrecoder from rrc reconfiguration msg for pcell    log_file_path=${tcpdump_log_file_path_f1ap}
    ${status_f1ap_result}    run keyword and return status    Should be equal as strings    ${transformPrecoder}    enabled
    ${status_final}    Evaluate    ${status_aasyslog_result_retry} or ${status_f1ap_result}
    Run keyword and continue on failure    should be true  ${status_final}
    [Teardown]    Run keyword and ignore error    Run keywords    Stop Tcpdump via collector    collector_name=${file_name_f1ap_good_to_bad}    AND
    ...    Teardown aasyslog with log downloaded to ute    gnb_log_path=${aasyslog_gnb_log_path}
    ...        ute_log_folder=${TS_CASE_LOG_PATH}

C_B27_01_S2_Verify Scell ul transmission suspend after transform Precoder enabled for pcell
    [Documentation]  Author Ding Binmei
    Log to console    S2 Verify Scell ul transmission suspend after transform Precoder enabled for pcell
    ${tput_log_path}    power_ue.Collect Tput     ue_type=${UE_TYPE}    duration=60s
    ...    ignore_time=30s    filter=L2Lo
    ${exp_tput_ul_scell_suspend}    set variable if  '${CC_NUM}'=='3'    5,0,-1    5,0,-1,-1
    @{exp_tput_dl_idv_with_pcell_bad}    Copy list    list_=${EXP_DL_INDIV}    deepcopy=${True}
    Set list value    ${exp_tput_dl_idv_with_pcell_bad}    0    5       # Update pcell dl tput expect value to 5M
    Check tput via power UE optimized     cell_index=${CELL_INDEX_LIST}     tput_log_path=${tput_log_path}    direction=both
    ...    exp_ul=1    exp_dl=1    target_avg_percent=${TPUT_AVG_PERCENT_PEAK}    min_percent=${TPUT_MIN_PERCENT_PEAK}
    ...    exp_ul_indiv=${exp_tput_ul_scell_suspend}    exp_dl_indiv=${exp_tput_dl_idv_with_pcell_bad}    connection=GNB_OAM
    ...    customized_log_name=S3_L3_call_scell_ul_transmission_suspend    is_need_to_fail_keyword=${True}
    ...    is_analysis_log_captured=${False}

C_B27_01_S3_Adjust pcell signal from bad to good and verify traffic all back to normal
    [Documentation]  Author: Ding Binmei
    ...    Adjust PA for pcell from bad to good to trigger transform Precoder disabled for pcell
    ...    1.1 Monitor aasyslog about whether transform Precoder reconfig is triggered
    ...    1.2 Double confirm from F1AP to check transform Precoder is enabled for pcell
    Log to console    S3 Adjust pcell signal from bad to good and verify traffic all back to normal
    ${file_name_f1ap_bad_to_good}    Set variable    S3_f1ap_bad_to_good_PA_0
    Start capture F1AP log    tcpdump_collector_name=${file_name_f1ap_bad_to_good}   options=-i any sctp
    Teardown the Aasyslog save progress
    Aasyslog precondition
    ${aasyslog_gnb_log_path}    Start the Aasyslog save progress    filter=L2\\|cp    log_name=aasyslog_pcell_bad_to_good.txt
    ...    is_ssh_con_released=${False}
#    Update PA from bad to 0 directly
    ${status_aasyslog_result}    run keyword and return status    Adjust PA gradualy for provided cells and verify if TP reconfig is triggered
    ...    pa_start=0    pa_end=0    pa_interval=1    list_cell_id=${PCELL_ID}    aasyslog_log_path=${aasyslog_gnb_log_path}
    Sleep    2s    reason=Waiting for F1AP log capturing, in case log print delay
    ${tcpdump_log_file_path_f1ap}    Stop tcpdump log collection    tcpdump_collector_name=${file_name_f1ap_bad_to_good}
    ${transformPrecoder}    Get transformPrecoder from rrc reconfiguration msg for pcell    log_file_path=${tcpdump_log_file_path_f1ap}
    ${status_f1ap_result}    run keyword and return status    Should be equal as strings    ${transformPrecoder}    disabled
    ${status_final}    Evaluate    ${status_aasyslog_result} or ${status_f1ap_result}
    Run keyword and continue on failure    should be true  ${status_final}
    [Teardown]  Run keyword and ignore error    Run keywords    Stop Tcpdump via collector    collector_name=${file_name_f1ap_bad_to_good}    AND
    ...    Teardown aasyslog with log downloaded to ute    gnb_log_path=${aasyslog_gnb_log_path}
    ...        ute_log_folder=${TS_CASE_LOG_PATH}

C_B27_01_S4_Verify tput recovered after TP disabled when signal change back to good
    [Documentation]  Author Ding Binmei
    Log to console    S4 Verify tput recovered after TP disabled when signal change back to good
    ${tput_log_path}    power_ue.Collect Tput     ue_type=${UE_TYPE}    duration=60s
    ...    ignore_time=30s    filter=L2Lo
    Check tput via power UE optimized     cell_index=${CELL_INDEX_LIST}     tput_log_path=${tput_log_path}    direction=both
    ...    exp_ul=1    exp_dl=1    target_avg_percent=${TPUT_AVG_PERCENT_PEAK}    min_percent=${TPUT_MIN_PERCENT_PEAK}
    ...    exp_ul_indiv=${EXP_UL_INDIV}    exp_dl_indiv=${EXP_DL_INDIV}    connection=GNB_OAM
    ...    customized_log_name=S4_L3_call_tput_recovered    is_need_to_fail_keyword=${True}
    ...    is_analysis_log_captured=${False}

C_B27_01_Case_setup
    ${param_to_upd}    create dictionary  param_to_upd=${RESTAPI_ACT_actUlDftSOfdm_AND_SET_THRESH_FOR_ulTransPrecodeCtl}
     6137 Case setup    dict_params_to_modify=${param_to_upd}    is_log_required=${False}

_Get ru index based on input cell index
    [Documentation]  Author: Ding Binmei
    ...    ${NR_CELL_ID_MAPPING}: Suite variable set in case suite setup step
    [Arguments]    ${list_cell_id}
    ${list_cell_id}    string_list.string2list    input_str=${list_cell_id}
    @{list_ruIndex}    Create list
    FOR    ${cell_id}    IN    @{list_cell_id}
        Append to list    ${list_ruIndex}    ${NR_CELL_ID_MAPPING[${cell_id}]['ruIndex_in_init']}
    END
    [Return]  ${list_ruIndex}

Adjust PA gradualy for provided cells and verify if TP reconfig is triggered
    [Documentation]  Author: Ding Binmei
    [Arguments]    ${pa_start}    ${pa_end}    ${pa_interval}    ${list_cell_id}    ${aasyslog_log_path}    ${connection}=ASIK Master
    @{list_ruIndex}    _Get ru index based on input cell index    list_cell_id=${list_cell_id}
    ${info_before_trigger}    Get filter info from aasyslog    aasyslog_log_path=${aasyslog_log_path}
    ...    filter=complete TransformPrecoder reconfig    connection=${connection}
    @{pa_values}    Generate pa values based on provided range    pa_start=${pa_start}    pa_end=${pa_end}    pa_interval=${pa_interval}
    FOR    ${pa_value}    IN    @{pa_values}
        Set attenuator ports of specified RUs to same value    exp_pa_value=${pa_value}    ru_idx_list=${list_ruIndex}
    END
    wait until keyword succeeds    10s    200ms    _Verify transform Precoder reconfig happened
        ...    info_before_trigger=${info_before_trigger}    aasyslog_log_path=${aasyslog_log_path}    connection=${connection}

Get filter info from aasyslog
    [Documentation]  Author: Ding Binmei
    ...    ${filter}: grep criteria in aasyslog. e.g: cp\\|l2
    ...    ${connection}: if local: then support to execute on ute
    ...    Example output: dict with bellow format:
    ...    {records_num:1, timestamp_for_all:[time1, time2], timestamp_latest=time2}

    [Arguments]  ${aasyslog_log_path}    ${filter}    ${connection}=ASIK Master
    ${cmd_verify_tp_reconfig_exist}    Set variable   cat ${aasyslog_log_path}|grep -ai "${filter}"|grep -av grep
    ${output}    Run keyword if    '${connection}'=='local'    Run    command=${cmd_verify_tp_reconfig_exist}
    ...    ELSE    csn.execute    command=${cmd_verify_tp_reconfig_exist}    connection=${connection}
    @{list_records}    split string    ${output}    \n
    Remove Values From List    ${list_records}   ${empty}
    ${len}    Get Length    ${list_records}
    &{dict_filter_info}    create dictionary    records_num=${len}
    @{list_time}    create list
    FOR    ${line}    IN    @{list_records}
        ${time}    Get Regexp Matches    ${line}    \\d{2}\\:\\d{2}\\:\\d{2}\\.[\\d|\\w]*
        append to list    ${list_time}    ${time}
    END
    Set to dictionary    ${dict_filter_info}    timestamp_for_all=${list_time}
    Run keyword if    '${len}'=='0'    Set to dictionary    ${dict_filter_info}    timestamp_latest=${EMPTY}
    ...    ELSE    Set to dictionary    ${dict_filter_info}    timestamp_latest=${list_time[-1]}
    [Return]  ${dict_filter_info}

_Verify transform Precoder reconfig happened
    [Documentation]  Author: Ding Binmei
    [Arguments]    ${info_before_trigger}    ${aasyslog_log_path}    ${connection}=ASIK Master
    ${info_after_trigger}    Get filter info from aasyslog    aasyslog_log_path=${aasyslog_log_path}
        ...    filter=complete TransformPrecoder reconfig    connection=${connection}
    ${num_result}    Run keyword and return status
    ...    Should be true    ${info_after_trigger['records_num']}>${info_before_trigger['records_num']}
    ${time_result}    Run keyword and return status
    ...    should not be equal  ${info_after_trigger['timestamp_latest']}    ${info_after_trigger['timestamp_latest']}
    Run keyword if    '${num_result}'=='False'    Run keyword if    '${time_result}'=='False'
    ...               Fail    Transform Precoder reconfig not happened from aasyslog
    Log to console    Found Transform Precoder reconfig from aasyslog


Retry retrigger if transform Precoder reconfig not happened
    [Documentation]  Author: Ding Binmei
    [Arguments]  ${pa_start_retry}    ${pa_end_retry}    ${pa_interval}    ${aasyslog_log_path}    ${list_cell_id}    ${connection}=ASIK Master
    @{list_ruIndex}    _Get ru index based on input cell index    list_cell_id=${list_cell_id}
    ${info_before_trigger}    Get filter info from aasyslog    aasyslog_log_path=${aasyslog_log_path}
    ...    filter=complete TransformPrecoder reconfig    connection=${connection}
    @{pa_values}    Generate pa values based on provided range    pa_start=${pa_start_retry}    pa_end=${pa_end_retry}    pa_interval=${pa_interval}
    FOR    ${pa_value}    IN    @{pa_values}
        Set attenuator ports of specified RUs to same value    exp_pa_value=${pa_value}    ru_idx_list=${list_ruIndex}
        ${result}    Run keyword and return status    wait until keyword succeeds    10s    200ms    _Verify transform Precoder reconfig happened
        ...    info_before_trigger=${info_before_trigger}    aasyslog_log_path=${aasyslog_log_path}    connection=${connection}
        Exit for loop if    ${result}
    END
    Should be true    ${result}    msg=transform Precoder reconfig is not triggered
    [Return]  ${pa_value}
