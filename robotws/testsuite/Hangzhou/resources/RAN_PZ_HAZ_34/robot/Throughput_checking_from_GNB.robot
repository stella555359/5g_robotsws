*** Settings ***
Documentation    Author: Ding Binmei
...              Description: Common keyword for throughput checking from GNB
...              Mainly focus on checking for single cell for single GNB
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource    taf/rfrl/common_resources/robot/TTI_Trace.robot
Library    taf.rfrl.common_resources.python.ssh_common_commands    WITH NAME    ssh_common_commands
Library    ../python/aasyslog.py
Library    ../python/check_average_throughput.py
Library    testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.export_data_to_csv.Export_data     WITH NAME    export_to_csv
Library    ../python/coam_gnb_classical.py


*** Variables ***
#expected percentage of given theoretical throuput
${EXP_TPUT_PERCENTAGE}                0.95


*** Keywords ***
Retry log capturing if file content is empty
    [Documentation]  Author: Ding Binmei
    ...              Description: Retry with log capturing if throughput file content is empty
    [Arguments]    ${gnb_index}=0    ${duration}=300s    ${max_retry_time}=5    ${asik_alias}=ASIK Master    ${du_index}=0
    ${tput_log_file_path_gnb}    Start tput log capture    gnb_index=${gnb_index}    asik_alias=${asik_alias}    du_index=${du_index}
    Sleep    ${duration}
    FOR    ${time}    IN RANGE    ${max_retry_time}
        @{saved_tput_file_list}    Split tput log to ul and dl files    gnb_index=${gnb_index}    asik_alias=${asik_alias}
        ...    tput_log_file_path_gnb_combined=${tput_log_file_path_gnb}
        ${are_tput_file_generated_successfully}    check_average_throughput.are_tuput_files_neither_empty
        ...    list_file_path=${saved_tput_file_list}    asik_alias=${asik_alias}
        Run keyword if    ${are_tput_file_generated_successfully}==${False}
        ...    Run keywords    Log to console    No content captured in throughput file, will try capturing for another ${duration}    AND
        ...        Sleep    ${duration}
        ...    ELSE    exit for loop
    END
    wait until keyword succeeds    10s    200ms    check_average_throughput.stop_tput_aasyslog_capturing    asik_alais=${asik_alias}
    ${are_tput_file_generated_successfully}    check_average_throughput.are_tuput_files_neither_empty
    ...    list_file_path=${saved_tput_file_list}    asik_alias=${asik_alias}
    Should be true    ${are_tput_file_generated_successfully}
    ...     msg=Throughput file are not generated with content even with ${max_retry_time} times retry for ${duration}
    [Return]  ${saved_tput_file_list}

Verify if nc process is killed
    [Documentation]  Author: Ding Binmei  [PRIVATE]
    [Arguments]  ${asik_alias}=ASIK Master
    ${is_nc_process_started}    ssh_common_commands.is_process_exist    process_name=51000    connection=${asik_alias}
    Should not be true    ${is_nc_process_started}

Start tput log capture
    [Documentation]    Author: Ding Binmei
    ...                Description: Start L2LO throughput log capturing from aasyslog and return the log path in GNB
    ...                             It can only support for 1 GNB currently,
    ...                             due to the limitation for common keyword 'Connect to Capacity Unit Master'
    ...                             If started separate nc processes for UL and DL, then log records will be influenced.
    ...                             So captured both UL and DL tput log in one log file at the same time.
    ...                Return the tput file path on GNB: /tmp/Tput_ul_dl.txt
    ...                2020/07/28 Liu Zheng: update the host username and password from CU to DU.
    [Timeout]   10min
    [Arguments]  ${gnb_index}=0    ${asik_alias}=ASIK Master    ${tput_log_file_path_gnb_combined}=/tmp/Tput_ul_dl.txt    ${du_index}=0
    Wait until keyword succeeds    5s    200ms    aasyslog.aasyslog_realtime_output_configuration
    ...    host=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.addr}
    ...    username=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    password=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}    type=mcu
    ${is_nc_process_started}    ssh_common_commands.is_process_exist    process_name=51000    connection=${asik_alias}
    Run keyword if    ${is_nc_process_started}
    ...    Run keywords    Log to console    Existing aasys log process exists, will close it before starting tput log capturing    AND
    ...    ssh.send_command    command=ps -ef |grep 51000|grep -v grep| awk '{print $2}'|xargs kill -9    connection=${asik_alias}
    Wait until keyword succeeds    10s    200ms    Verify if nc process is killed    asik_alias=${asik_alias}
    ${cmd_start_tput_capture}    Catenate    nc -u -w 100 -l 127.0.0.1 51000|grep -a -i 'SentDataMeasurementCounting\\|UlCounterUpdate'
    ...    >${tput_log_file_path_gnb_combined} &
    ssh.send_command    command=${cmd_start_tput_capture}    connection=${asik_alias}
#    Sleep    200ms
    Sleep    2s
    ${is_nc_process_started}    ssh_common_commands.is_process_exist    process_name=51000    connection=${asik_alias}
    Should be true    ${is_nc_process_started}
    [Return]    ${tput_log_file_path_gnb_combined}

Split tput log to ul and dl files
    [Documentation]  Author: Ding Binmei
    ...              Description: Split UL/DL tput log to separate files on GNB
    ...              ${tput_log_file_path_gnb_combined}: log path returned from 'Start tput log capture'
    ...              Return list for tput file paths on GNB. Example output:
    ...              ['tmp/Tput_UL_L2LO_20200507064924.txt', '/tmp/Tput_DL_L2LO_20200507064924.txt']
    [Arguments]  ${gnb_index}=0    ${asik_alias}=ASIK Master    ${tput_log_file_path_gnb_combined}=/tmp/Tput_ul_dl.txt
    ${timestamp}=    Get Current Date    result_format=%Y%m%d%H%M%S
    ${ul_tput_file_path}    Set variable    /tmp/Tput_UL_L2LO_${timestamp}.txt
    ${dl_tput_file_path}    Set variable    /tmp/Tput_DL_L2LO_${timestamp}.txt
    ${cmd_export_ul_tput_log}    Set variable  cat ${tput_log_file_path_gnb_combined}|grep -a -i 'UlCounterUpdate'>${ul_tput_file_path}
    ${cmd_export_dl_tput_log}    Set variable  cat ${tput_log_file_path_gnb_combined}|grep -a -i 'SentDataMeasurementCounting'>${dl_tput_file_path}
    ${output1}    ssh.execute    command=${cmd_export_ul_tput_log}    connection=${asik_alias}
    ${output2}    ssh.execute    command=${cmd_export_dl_tput_log}    connection=${asik_alias}
    @{ul_dl_tput_file_paths}    Create list    ${ul_tput_file_path}    ${dl_tput_file_path}
    [Return]    ${ul_dl_tput_file_paths}

Download tput file to test pc
    [Documentation]  Author: Ding Binmei
    ...             Description: Download tput files to test pc and remove logs on GNB
    ...             ${ul_dl_tput_file_paths_gnb}: List value returned from 'Split tput log to ul and dl files'
    ...             ${tput_log_file_path_gnb_combined}: Value returned from 'Start tput log capture'
    ...             ${local_log_folder}: Refer to the tput log folder in test pc
    ...             Return a dict with tput file path in test pc. Example output:
    ...             { UL_L2LO=/home/ute/Tput_Test/Tput_UL_L2LO_20200507064924.txt,
    ...               DL_L2LO=/home/ute/Tput_Test/Tput_DL_L2LO_20200507064924.txt }
    [Arguments]  ${ul_dl_tput_file_paths_gnb}    ${tput_log_file_path_gnb_combined}=/tmp/Tput_ul_dl.txt    ${local_log_folder}=${TS_CASE_LOG_PATH}
    ...    ${asik_alias}=ASIK Master
    Log to console    \n Download tput files to from GNB to test pc
    ssh.download file    remote_path=${ul_dl_tput_file_paths_gnb}    local_path=${local_log_folder}    connection=${asik_alias}
    &{dict_local_file_paths}    Create dictionary
    FOR    ${file_path}    IN    @{ul_dl_tput_file_paths_gnb}
        ${file_name}    Fetch from right    string=${file_path}    marker=/
        ${direct}    check_average_throughput.get_direction_by_file_name    tput_file=${file_path}
        ${direct}    Convert to upper case    ${direct}
        ${local_file_path}    Join path    ${local_log_folder}    ${file_name}
        Set to dictionary    ${dict_local_file_paths}    ${direct}_L2LO    ${local_file_path}
    END
    ${cmd_remove_combined_tput_file_on_gnb}    Set variable    rm -rf ${tput_log_file_path_gnb_combined}
    ${cmd_remove_split_tput_files_on_gnb}    Set variable    rm -rf /tmp/Tput*.txt
    Run keyword and continue on failure    ssh.execute    command=${cmd_remove_combined_tput_file_on_gnb}    connection=${asik_alias}
    Run keyword and continue on failure    ssh.execute    command=${cmd_remove_split_tput_files_on_gnb}    connection=${asik_alias}
    @{remove_tput_log_paths_on_gnb}    Copy list    ${ul_dl_tput_file_paths_gnb}
    Append to list    ${remove_tput_log_paths_on_gnb}    ${tput_log_file_path_gnb_combined}
    FOR    ${file_path}    IN    ${remove_tput_log_paths_on_gnb}
        ${check_tput_log_is_removed}    ssh.execute    command=ls ${file_path}    connection=${asik_alias}
        Run keyword and continue on failure    Should contain    ${check_tput_log_is_removed}    No such file or director
        ...    msg=Fail to remove log file ${file_path} on ${asik_alias}
    END
    [Return]  ${dict_local_file_paths}

Get time from GNB
    [Documentation]    Author: Ding Binmei
    ...                Description: Get the real time from GNB,return as '2019-01-29-17:40:36'
    [Arguments]    ${asik_alias}=ASIK Master
    csn.send command    command=date +%F-%T    connection=${asik_alias}
    ${date_time}    csn.read output    connection=${asik_alias}
    ${date_time}    Strip String   ${date_time}
    [Return]    ${date_time}

Verify tput is as expected
    [Documentation]  Author: Ding Binmei
    ...              Description: Verify tput is as expected
    ...              If no need to check for ul or dl, please set the related expected value to 0
    [Arguments]    ${dict_act_tput_info}    ${exp_dl_tput}    ${exp_ul_tput}    ${tput_percentage}=${EXP_TPUT_PERCENTAGE}
    ...    ${exp_min_ul}=1    ${exp_min_dl}=1
    ${ul_tput_exp}    Evaluate    ${exp_ul_tput}*${tput_percentage}
    ${dl_tput_exp}    Evaluate    ${exp_dl_tput}*${tput_percentage}
    Run keyword and continue on failure    Should be true    ${dict_act_tput_info['ul_tput_avg']} >= ${ul_tput_exp}
    Run keyword and continue on failure    Should be true    ${dict_act_tput_info['dl_tput_avg']} >= ${dl_tput_exp}
    ${ul_tput_detail_act}    Copy list    ${dict_act_tput_info['ul_tput_detail']}
    Sort list    ${ul_tput_detail_act}
    ${dl_tput_detail_act}    Copy list    ${dict_act_tput_info['dl_tput_detail']}
    Sort list    ${dl_tput_detail_act}
    Run keyword and continue on failure    Should be true    ${ul_tput_detail_act[0]} >= ${exp_min_ul}
    Run keyword and continue on failure    Should be true    ${dl_tput_detail_act[0]} >= ${exp_min_dl}

Get tput info from GNB
    [Documentation]  Author: Ding Binmei
    ...              Description:Capture L2Lo tput info from GNB
    ...              Return with a dict: {nr_cell_id:1, timestamp: 2019-12-05-13:31:01, ul_tput_avg: 19.9,ul_tput_detail: [XX, XX]
    ...                                   dl_tput_avg: 50.9, dl_tput_detail: [XX,XX]}
    [Arguments]    ${nr_cell_index}=1    ${duration}=300s    ${max_retry_time}=5    ${local_log_folder}=${TS_CASE_LOG_PATH}    ${gnb_index}=0
    ...    ${gnb_ssl_connection}=GNB_OAM    ${asik_alias}=ASIK Master    ${du_index}=0
    ${nr_cell_index}    Convert to integer    ${nr_cell_index}
    ${timestamp}    Get time from GNB    asik_alias=${asik_alias}
    @{saved_tput_file_list}    Run keyword and continue on failure    Retry log capturing if file content is empty     gnb_index=${gnb_index}
    ...    duration=${duration}    max_retry_time=${max_retry_time}    asik_alias=${asik_alias}    du_index=${du_index}
    &{dict_local_tput_file_path}    Download tput file to test pc    ul_dl_tput_file_paths_gnb=${saved_tput_file_list}
    ...    local_log_folder=${local_log_folder}    asik_alias=${asik_alias}
    &{ul_tput}    check_average_throughput.get_tput_info_for_l2lo    tput_file=${dict_local_tput_file_path['UL_L2LO']}
    &{dl_tput}    check_average_throughput.get_tput_info_for_l2lo    tput_file=${dict_local_tput_file_path['DL_L2LO']}
    &{cell_mapping}    coam_gnb_classical.get_relation_mapping_between_cell_index_and_other_ids    connection_alias=${gnb_ssl_connection}
    ${nrCellIdentity}    Set variable    ${cell_mapping[${nr_cell_index}]['nrCellIdentity']}
    &{dict_tput_info}    Create dictionary
    Set to dictionary    ${dict_tput_info}    timestamp=${timestamp}
    Set to dictionary    ${dict_tput_info}    nr_cell_id=${nr_cell_index}
    Set to dictionary    ${dict_tput_info}    ul_tput_avg=${ul_tput[${nrCellIdentity}]['average_tput']}
    Set to dictionary    ${dict_tput_info}    dl_tput_avg=${dl_tput[${nrCellIdentity}]['average_tput']}
    Set to dictionary    ${dict_tput_info}    ul_tput_detail=${ul_tput[${nrCellIdentity}]['detail_tput_info']}
    Set to dictionary    ${dict_tput_info}    dl_tput_detail=${dl_tput[${nrCellIdentity}]['detail_tput_info']}
    [Return]    ${dict_tput_info}
    [Teardown]    Run keyword and ignore error    check_average_throughput.stop_tput_aasyslog_capturing    asik_alais=${asik_alias}

Capture event trace log if tput can not reach the expected value
    [Documentation]  Author: Ding Binmei
    ...              Description: Capturing event trace log if tput can not reach expected value. Also will check the tput value by that time
    [Arguments]    ${gnb_index}=0    ${local_log_folder}=${TS_CASE_LOG_PATH}    ${asik_alias}=ASIK Master
    ${tput_log_file_path_gnb}    Start tput log capture    gnb_index=${gnb_index}    asik_alias=${asik_alias}
    Start TTI trace log capturing
    Sleep    3s
    wait until keyword succeeds    10s    200ms    check_average_throughput.stop_tput_aasyslog_capturing    asik_alais=${asik_alias}
    Stop TTI trace log capturing
    &{dict_csv_file_path}    Convert TTI trace log and download combined csv logs to test pc    local_path=${local_log_folder}
    @{saved_tput_file_list}    Split tput log to ul and dl files    gnb_index=${gnb_index}    asik_alias=${asik_alias}
    ...    tput_log_file_path_gnb_combined=${tput_log_file_path_gnb}
    &{dict_local_tput_file_path}    Download tput file to test pc    ul_dl_tput_file_paths_gnb=${saved_tput_file_list}
    ...    local_log_folder=${local_log_folder}    asik_alias=${asik_alias}
    &{ul_tput}    check_average_throughput.get_tput_info_for_l2lo    tput_file=${dict_local_tput_file_path['UL_L2LO']}
    &{dl_tput}    check_average_throughput.get_tput_info_for_l2lo    tput_file=${dict_local_tput_file_path['DL_L2LO']}
    Log to console    ul_tput:${ul_tput}, dl_tput:${dl_tput}
    [Teardown]  Run keyword and ignore error    Run keywords    check_average_throughput.stop_tput_aasyslog_capturing
    ...    asik_alais=${asik_alias}    AND    Stop TTI trace log capturing

Verify tput from GNB within duration and record data to csv
    [Documentation]  Author: Ding Binmei
    ...    Check tput for period and user can define the duration for checking in each time,
    ...    will capture event trace log if tput not reached the expected value and will export captured logs to csv file.
    ...    ${total_time}: is the duration time in which the throughput need to be checked. The time unit is second.
    ...    ${duration_time_for_once}: is the duration time for calculating average tput in one capturing
    ...    ${interval}: refers to the sleep time between tput checking, can be mins, hours, or secs
    ...    ${tput_percentage}: refers to the acceptable tput percentage for checking
    ...    ${is_need_to_capture_log}: will capture log if set to ${True}
    ...    ${exp_min_ul}: refer to the minimum tput value that need to be reached for UL
    ...    ${exp_min_dl}: refer to the minimum tput value that need to be reached for DL
    [Arguments]  ${total_time}    ${exp_dl_tput}    ${exp_ul_tput}    ${interval}    ${duration_time_for_once}=300s
    ...    ${tput_percentage}=${EXP_TPUT_PERCENTAGE}    ${local_log_folder}=${TS_CASE_LOG_PATH}    ${nr_cell_index}=1
    ...    ${gnb_ssl_connection}=GNB_OAM    ${asik_alias}=ASIK Master    ${is_need_to_capture_log}=${True}
    ...    ${exp_min_ul}=1    ${exp_min_dl}=1    ${du_index}=0
    ${time_stamp}    DateTime.get current date    result_format=epoch    exclude_millis=True
    ${end_time}    Evaluate    ${time_stamp}+${total_time}
    @{list_tput_info_all}    Create list
    Wait until keyword succeeds    1 min    10 sec    Connect to Common Unit Master    alias=${asik_alias}
    FOR    ${i}    IN RANGE    ${time_stamp}    ${end_time}
        ${trouble_shooting_log_path}    Join path    ${local_log_folder}    Tput_issue_Logs${i}
        &{dict_tput_info}    Run keyword and continue on failure    Get tput info from GNB    duration=${duration_time_for_once}
        ...    nr_cell_index=${nr_cell_index}    gnb_ssl_connection=${gnb_ssl_connection}    asik_alias=${asik_alias}    du_index=${du_index}
        Log to console    tput info: ${dict_tput_info}
        Append to list    ${list_tput_info_all}    ${dict_tput_info}
        ${status}    Run keyword and return status    Verify tput is as expected    dict_act_tput_info=${dict_tput_info}
        ...    exp_dl_tput=${exp_dl_tput}    exp_ul_tput=${exp_ul_tput}    tput_percentage=${tput_percentage}
        ...    exp_min_ul=${exp_min_ul}    exp_min_dl=${exp_min_dl}
        Run keyword if  ${status}==${False} and ${is_need_to_capture_log}
        ...    Run keywords    Create directory    ${trouble_shooting_log_path}    AND
        ...        Run keyword and continue on failure    Capture event trace log if tput can not reach the expected value
        ...        local_log_folder=${trouble_shooting_log_path}    asik_alias=${asik_alias}
        Run keyword and continue on failure    Should be true    ${status}
        Sleep    ${interval}
        ${current_time_stamp}    DateTime.get current date    result_format=epoch    exclude_millis=True
        Exit for loop if    ${current_time_stamp}>${end_time}
    END
    ${timestamp}    Get time from GNB    asik_alias=${asik_alias}
    ${csv_log_file_path}    Join path    ${local_log_folder}    throughput_records_${time_stamp}_NRCELL_${nr_cell_index}.csv
    export_to_csv.write_data_to_csv    input_data=${list_tput_info_all}    csv_file_path=${csv_log_file_path}
    [Return]    ${dict_tput_info['dl_tput_avg']}    ${dict_tput_info['ul_tput_avg']}
