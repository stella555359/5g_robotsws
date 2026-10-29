*** Settings ***
Documentation
...   Author: I_NSB_MN_RAN_RD_VRF_HAZ3_01
...   Description: Keyword for PM counters

Library     taf.config.testline.info.testline_info.TestlineInfo    WITH NAME    testline_info
Library     taf.collectors.pmcounters    WITH NAME    collect_pm
Library     taf.converters.pmtocsv       WITH NAME    pmtocsv
Library     taf.analyzer.pmcounter       WITH NAME    check_pm
Library     ./lib/pmcounters_parse.py
Library     ./lib/PM_Counter.py
Library     PM_Counter.PMCounter    WITH NAME    counter
Resource    ./mmw_coam_gnb_cloud.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/Cloud_VRAN40/vCU.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/Cloud_VRAN40/vDU.robot


*** Keywords ***
Wait until PM counter file is genereated
    [Documentation]  Author: Ding Binmei
    ...              Description: Wait until PM counter file is generated and Return the file path for PM counter files
    ...              :para${timeout}: should be written value with unit, eg, 1min
    [Arguments]  ${log_generate_timestamp}    ${pm_counter_file_folder}=/tmp    ${file_indicator}=PM.BTS*.xml.gz    ${asik_alias}=ASIK Master
    ...   ${timeout}=1min
    ${remote_file_path}    Wait until keyword succeeds    ${timeout}    5s    Verify PM counter file is generated
    ...    log_generate_timestamp=${log_generate_timestamp}    pm_counter_file_folder=${pm_counter_file_folder}    file_indicator=${file_indicator}
    ...    asik_alias=${asik_alias}
    [Return]  ${remote_file_path}

Verify PM counter file is generated
    [Documentation]  Author: Ding Binmei    [PRIVATE]
    ...              Verify PM counter file is generated
    [Arguments]  ${log_generate_timestamp}    ${pm_counter_file_folder}=/tmp    ${file_indicator}=PM.BTS*.xml.gz    ${asik_alias}=ASIK Master
    ${remote_file_path}    counter.get_pm_counter_files_by_create_time    timestamp=${log_generate_timestamp}   asik_alias=${asik_alias}
    ...    pm_counter_file_folder=${pm_counter_file_folder}    file_indicator=${file_indicator}
    Should not be empty  ${remote_file_path}    msg=No PM counter files generated after timestamp ${log_generate_timestamp}
    [Return]  ${remote_file_path}

Wait for next PM counter file is generated
    [Documentation]    Author: Cui Lingxue
    ...    This keyword will get current time on gnb and wait for next PM file is generated, the generated pm file path will be return.
    ...    :param ${pm_counter_file_folder}: on classical is /tmp; on CU is /mnt/services/PM9/storage/results
    ...    :param ${file_indicator}: on classical is PM.BTS*.xml.gz; on CU is *.xml.gz
    [Arguments]    ${reporting_interval}    ${pm_counter_file_folder}=/tmp    ${file_indicator}=PM.BTS*.xml.gz    ${alias}=ASIK Master
    ...   ${timeout}=1min
    ${wait_time_info}    counter.calculate_waiting_time_for_log_capturing_or_log_generation    reporting_interval=${reporting_interval}
    ...    asik_alias=${alias}
    Sleep    ${wait_time_info['wait_time']} min
    ${remote_file_path}    Wait until PM counter file is genereated    log_generate_timestamp=${wait_time_info['log_generator_timestamp']}
    ...    asik_alias=${alias}    pm_counter_file_folder=${pm_counter_file_folder}    file_indicator=${file_indicator}    timeout=${timeout}
    [Return]    ${remote_file_path}    ${wait_time_info}

Download PM counter files of a period
    [Documentation]    Author: Cui Lingxue
    ...    Download PM counter files from ASIK to local test pc. All files generated during starting time specified by ${starting_log_timestamp}
    ...    to now will be downloaded.
    [Arguments]    ${starting_log_timestamp}    ${pm_counter_file_folder}=/tmp    ${file_indicator}=PM.BTS*.xml.gz    ${asik_alias}=ASIK Master
    ...    ${local_file_folder}=${TS_CASE_LOG_PATH}
    ${remote_file_path}    counter.get_pm_counter_files_by_create_time    timestamp=${starting_log_timestamp}   asik_alias=${asik_alias}
    ...    pm_counter_file_folder=${pm_counter_file_folder}    file_indicator=${file_indicator}
    @{local_file_path}    counter.download_pm_counter_files_to_test_pc    remote_file_path=${remote_file_path}
    ...    local_file_folder=${local_file_folder}
    [Return]    ${local_file_path}

#The keyword only used for classical
Collect PM Counter logs from CU
    [Documentation]    :Author: Wang Yixiang
    ...    Get pm counter logs from cloud cu
    ...    counter log path:/mnt/services/PM9/storage/results
    ...    counter log mapping:/mnt/services/PM9/storage/results/resultMapping.json
    ...    return: return the lastest counter file
    ...    usage example:
    ...        Waiting time for new counter file generated period CU
    ...        Your case operations
    ...        Waiting time for new counter file generated period CU
    ...        Collect PM Counter logs from CU    counter_group=55110
    [Arguments]    ${counter_group}    ${log_path}=${TS_CASE_LOG_PATH}
    @{counter_file_list}    create list
    ${remote_counter_log_path}    set variable    /mnt/services/PM9/storage/results
    ${local_counter_log_path}    set variable    ${log_path}/counters
    Create Directory    path=${local_counter_log_path}
    CU SSH To OAM    alias=CU_VM
    csn.download_file   remote_path=${remote_counter_log_path}/resultMapping.json
    ...    local_path=${local_counter_log_path}/resultMapping.json
    ...    connection=CU_VM
    @{counter_file_name_list}   pmcounters_parse.get_counter_file_name    filepath=${local_counter_log_path}/resultMapping.json
    ...    counter_group=${counter_group}

    FOR    ${counter_file_name}    IN    @{counter_file_name_list}
       csn.download_file   remote_path=${remote_counter_log_path}/${counter_file_name}
       ...    local_path=${local_counter_log_path}/${counter_file_name}
       ...    connection=CU_VM
       ${counter_file}    pmcounters_parse.unzip_and_return_xml    counter_gz_file_path=${local_counter_log_path}/${counter_file_name}
       Append to list    ${counter_file_list}    ${counter_file}
    END
    [Return]    @{counter_file_list}
    [Teardown]    Teardown SSH Connections    alias=CU_VM

Waiting time for new counter file generated period CU
    [Documentation]    :Author: Wang Yixiang
    ...    Order pm counter file by time and get the latest counter file
    ...    :param ${reporting_interval}: how long a pm file will be generated, in minute unit
    [Arguments]    ${reporting_interval}=5
    CU SSH To OAM    alias=CU_VM
    &{pre_case_time_info}    counter.calculate_waiting_time_for_log_capturing_or_log_generation
    ...    reporting_interval=${reporting_interval}    asik_alias=CU_VM
    Sleep    ${pre_case_time_info['wait_time']} min
    [Teardown]    Teardown SSH Connections    alias=CU_VM

Get Initial Status For Counter From Cloud gNB WebEM
    [Documentation]    Author: Dandan Fang
    ...    list_counters : dictionary object for each counter, one example as following
    ...            ${M55316C09000}    create dictionary      counter_id=value    dimension_dist_name=value
    ...            expect_value=value    count_all_values=value
    ...    gnb_index : default value is ${0}
    ...    vdu_index : default value is ${0}
    ...    bts_type  :  cloud gnb, value should be cu or du
    [Arguments]      ${list_counters}   ${bts_type}    ${gnb_index}=${0}   ${vdu_index}=${0}
    ${counter_num}    Get Length    ${list_counters}
    Should be True   ${counter_num}

    ${oam_connection}=    _build connection with cloud cu or du   bts_type=${bts_type}
    ...      gnb_index=${gnb_index}    vdu_index=${vdu_index}

    @{init_counter_list}   create list
    FOR  ${i}  IN RANGE  ${counter_num}
       ${counter_info}    set variable   ${list_counters[${i}]}
       ${dict_counter_check_result}=   Get Counter Value From Cloud gNB WebEM
       ...     bts_type=${bts_type}
       ...     counter_info=${counter_info}
       ...     count_all_values=${False}
       ...     oam_connection=${oam_connection}

       Set To Dictionary    ${counter_info}
       ...        start_time=${dict_counter_check_result['start_time']}
       ...        init_value=${dict_counter_check_result['value']}
       Append to list  ${init_counter_list}     ${counter_info}
    END
    [Return]    ${init_counter_list}
    [Teardown]    Run keyword if   '${bts_type}'=='du'     Teardown vdu connection     connection=${oam_connection}
    ...     ELSE        Teardown vcu connection    connection=${oam_connection}

Get Counter Value From Cloud gNB WebEM
    [Arguments]    ${counter_info}    ${bts_type}    ${oam_connection}   ${count_all_values}=${True}
    ...            ${start_time_lower_limit}=${None}      ${start_time_upper_limit}=${None}
    [Documentation]    Get latest counter value from webUI via rest API.
    ...    Author: Dandan FangGet TimeZone From DU Master
    ...    | Input Parameters | Man. | Description |
    ...    | counter_info | Yes | ${M55118C09502}    create dictionary      counter_id=value    dimension_dn=value
    ...    | bts_type     | Yes |  cloud gnb, value should be cu or du  |
    ...    | gnb_index | No |  gnb index to indicate which gnb will be used, 0 in default  |
    ...    | vdu_index | No |  vdu_index index to indicate which vdu will be used, 0 in default  |
    ...    | start_time_lower_limit| No | from which timestamp to start check, default date format 2024-01-17T19:50:00+08:00 |
    ...    | start_time_upper_limit| No | from which timestamp to end check, default date format 2024-01-17T19:50:00+08:00 |
    ...    | Return Value | Description |
    ...    | ${dict_counter_check_result} | [{'start_time': '2024-03-05T14:30:00+08:00', 'value': '0'} |
    ...    Note: Dictionary Key start_time is added after first check the counter value.
    ...    Action done by keywords : Get Initial Time For Counter Update on WebEM For DU
    ${counter_values_from_webem}=    Run keyword if   '${bts_type}'=='du'    vdu.get_counter_values
    ...     counter_id=${counter_info}[counter_id]
    ...     dimension_dn=${counter_info}[dimension_dn]
    ...     start_time_lower_limit=${start_time_lower_limit}    start_time_upper_limit=${start_time_upper_limit}
    ...     vdu_connection=${oam_connection}
    ...     ELSE         cu.get_counter
    ...     measurement_id=${None}
    ...     dimension_dist_name=${counter_info}[dimension_dist_name]
    ...     counter_id=${counter_info}[counter_id]
    ...     connection=${oam_connection}
    ...     start_time_lower_limit=${start_time_lower_limit}    start_time_upper_limit=${start_time_upper_limit}

    should not be empty    ${counter_values_from_webem}
    ${counter_values}=     Run keyword if   '${bts_type}'=='cu'
    ...       set variable    ${counter_values_from_webem["values"]}
    ...     ELSE      set variable       ${counter_values_from_webem}

    ${values_len}    Get Length    ${counter_values}
    Should Be True     ${values_len}>0

    ${dict_counter_check_result}=    run keyword if   ${count_all_values}
    ...   _Calculate Counter Total Value  dict_counter_values=${counter_values}
    ...   ELSE       set variable   ${counter_values[-1]}
    [Return]    ${dict_counter_check_result}

Check Counter Value After Scenario Triggered For Cloud GNB
    [Documentation]    Author: Dandan Fang
    ...    list_counters : dictionary object for each counter, one example as following
    ...            ${M55118C09502}    create dictionary      measurement_id=value    counter_id=value    dimension_dist_name=value
    ...            expect_value=value    count_all_values=value
    ...    gnb_index : default value is ${0}
    ...    vdu_index : default value is ${0}
    ...    bts_type  :  cloud gnb, value should be cu or du
    [Arguments]     ${list_counters}   ${bts_type}   ${gnb_index}=${0}  ${vdu_index}=${0}
    ${counter_num}    Get Length    ${list_counters}
    Should be True   ${counter_num}

    #wait for next pm counter files update, the time is for pm files
    ${pre_case_time_info}=  Waiting time for new counter update period For Cloud  gnb_index=${gnb_index}
    ...     bts_type=${bts_type}       vdu_index=${vdu_index}
#    ${start_time_upper_limit}     set variable    ${pre_case_time_info['log_generator_timestamp']}
#    ${timezone}=  counter.get_timezone_from_gnb_cloud
#    ...    gnb_index=${gnb_index}   vdu_index=${vdu_index}    bts_type=${bts_type}
#
#    ${start_time_upper_limit} =  Run Keyword If  '${start_time_upper_limit}'!='${None}'
#    ...     _Combine Time and TimeZone   time_stamp=${start_time_upper_limit}   time_zone=${timezone}
#    ...    ELSE     set variable   ${None}

    ${oam_connection}=    _build connection with cloud cu or du   bts_type=${bts_type}
    ...      gnb_index=${gnb_index}    vdu_index=${vdu_index}

    FOR  ${i}  IN RANGE  ${counter_num}
       ${dict_counter_info}    set variable   ${list_counters[${i}]}
       ${start_time_provided}    Run Keyword and Return Status
       ...     Dictionary Should Contain Key    ${dict_counter_info}    start_time
       ${start_time_lower_limit}    Run Keyword If  ${start_time_provided}
       ...    set variable       ${dict_counter_info['start_time']}
       ...    ELSE     set variable   ${None}

       ${dict_counter_check_result}=   Get Counter Value From Cloud gNB WebEM
       ...     bts_type=${bts_type}
       ...     counter_info=${dict_counter_info}
       ...     count_all_values=${dict_counter_info['count_all_values']}
       ...     start_time_lower_limit=${start_time_lower_limit}
       ...     start_time_upper_limit=${start_time_upper_limit}
       ...     oam_connection=${oam_connection}

       ${expect_value}     convert to string     ${dict_counter_info['expect_value']}

       ${init_value_provided}    Run Keyword and Return Status
       ...     Dictionary Should Contain Key    ${dict_counter_info}    init_value

       ${counter_final_value}    Run Keyword If   ${init_value_provided}
       ...    Evaluate     ${dict_counter_check_result['value']}-${dict_counter_info['init_value']}
       ...    ELSE     set variable   ${dict_counter_check_result['value']}
       ${counter_final_value}    convert to string     ${counter_final_value}

       Run Keyword And Continue On Failure    should be equal     ${counter_final_value}   ${expect_value}
    END
    [Teardown]    Run keyword if   '${bts_type}'=='du'     Teardown vdu connection     connection=${oam_connection}
    ...     ELSE        Teardown vcu connection    connection=${oam_connection}

_build connection with cloud cu or du
    [Documentation]    :Author: Dandan Fang vRan4.0
    ...    use to create oam connection with cu or du according to bts_type
    ...    bts_type  :  cloud gnb, value should be cu or du
    [Arguments]    ${bts_type}
    ...            ${gnb_index}=${0}    ${vdu_index}=${0}
    ${timestamp}=    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    ${connection}=     Run keyword if   '${bts_type}'=='du'   Connect to vdu via rest api
    ...    gnb_index=${gnb_index}    du_index=${vdu_index}    connection=vdu_oam_conn_${timestamp}
    ...    ELSE       Connect to vcu via rest api
    ...    gnb_index=${gnb_index}       connection=vcu_oam_conn_${timestamp}
    [Return]    ${connection}

Waiting time for new counter update period For Cloud
    [Documentation]    :Author: Dandan Fang vRan4.0
    ...    Order pm counter file by time and get the latest counter file
    ...    param ${reporting_interval}: how long a pm file will be generated, in minute unit
    ...    bts_type  :  cloud gnb, value should be cu or du
    [Arguments]   ${bts_type}     ${gnb_index}=${0}    ${vdu_index}=${0}  ${reporting_interval}=5
    ${ocp_master_conn_alias}=  Run keyword if   '${bts_type}'=='du'
    ...     set variable     gnb_${gnb_index}_vdu${vdu_index}_ocp_master_timezone_get
    ...     ELSE      set variable     gnb_${gnb_index}_vcu_ocp_master_timezone_get
    &{wait_time_info}    counter.calculate_waiting_time_for_log_capturing_or_log_generation
    ...    reporting_interval=${reporting_interval}    asik_alias=${ocp_master_conn_alias}
    ...    gnb_index=${gnb_index}   vdu_index=${vdu_index}    bts_type=${bts_type}
    Sleep    ${wait_time_info['wait_time']} min    Reason=wait for pm file created.
    Sleep   1min  Reason=Wait for webem updated according to pm file

    ${log_generator_timestamp}     set variable    ${wait_time_info['log_generator_timestamp']}
    ${timezone}=  counter.get_timezone_from_gnb_cloud
    ...    gnb_index=${gnb_index}   vdu_index=${vdu_index}    bts_type=${bts_type}

    ${log_generator_timestamp}     _Combine Time and TimeZone   time_stamp=${log_generator_timestamp}   time_zone=${timezone}
    set_to_dictionary    ${wait_time_info}    log_generator_timestamp=${log_generator_timestamp}
    [Return]    ${wait_time_info}

_Calculate Counter Total Value
    [Documentation]    : Author: Dandan Fang vRan4.0
    ...  hanle counter result returned through webem
    ...  Counte all values in the counter dict
    ...  return result:  {'start_time': '2024-03-06T14:40:00+08:00', 'value': '1'}
    ...  Note: here start_time is the last time got from webem, match with original dictionary key.
    [Arguments]     ${dict_counter_values}
    ${values_len}    Get Length    ${dict_counter_values}
    ${value_last_index}    evaluate     ${values_len}-1
    ${counter_total_value}    set variable    ${0}
    ${counter_last_timestamp}  set variable
    FOR  ${i}  IN RANGE  ${values_len}
       ${temp_dic}    set variable   ${dict_counter_values[${i}]}
       ${temp_value}   Get From Dictionary    dictionary=${temp_dic}    key=value
       ${counter_value}    Convert To Integer    ${temp_value}
       ${counter_total_value}   evaluate     ${counter_total_value}+${temp_value}
       ${counter_last_timestamp}   run keyword if   ${i}==${value_last_index}
       ...      Get From Dictionary    dictionary=${temp_dic}    key=start_time
    END
    ${counter_total_value}    convert to string     ${counter_total_value}
    ${dict_counter_check_result}    create dictionary   start_time=${counter_last_timestamp}    value=${counter_total_value}
    [Return]   ${dict_counter_check_result}

_Combine Time and TimeZone
    [Documentation]
    ...    Author: Dandan Fang  Cloud WebEM check counter, time format as 2024-01-17T19:50:00+08:00
    ...    return time format: 2024-01-17T19:50:00+08:00
    [Arguments]    ${time_stamp}   ${time_zone}
    ${time_stamp}=   DateTime.Convert Date    ${time_stamp}   result_format=%Y-%m-%dT%H:%M:%S
    ${timestamp_with_timezone}     set variable    ${time_stamp}${time_zone}
    [Return]    ${timestamp_with_timezone}

Check Counter Value match expectations
    [Documentation]    Author: Lingxue Cui
    ...    ${counter_list}: list of counters to be checked .  Data structure should be as :
    ...    For DU counters
    ...        [{'count_all_values': True,
    ...          'counter_info': {'counter_id': 'M55305C03027',
    ...                           'dimension_dn': 'MRBTS-37241/NRBTS-37241/NRCELL-1'},
    ...          'expect_value': 1},
    ...         {'count_all_values': True,
    ...          'counter_info': {'counter_id': 'M55305C03036',
    ...                           'dimension_dn': 'MRBTS-37241/NRBTS-37241/NRCELL-1'},
    ...          'expect_value': 1}] ]
    ...    For CU counters
    ...        [{'count_all_values': True,
    ...          'counter_info': {'counter_id': 'M55305C03027',
    ...                           'dimension_dist_name': 'MRBTS-37241/NRBTS-37241/NRCELL-1'},
    ...          'expect_value': 1}]
    ...    ${bts_type}: cloud gnb, value should be cu or du
    ...    ${start_time_lower_limit}: from which timestamp to start check, default date format 2024-01-17T19:50:00+08:00
    ...    ${start_time_upper_limit}: from which timestamp to end check, default date format 2024-01-17T19:50:00+08:00
    ...    ${compare_value_1} ${expression_1} ${expression_2} ${compare_value_2}:If the value of the counter is a range value,
    ...        these parameters to determine the range that the counter checks, set the 'expect_value' which defined in 'counter_info' to 'None'.
    ...        If the expected counter value is larger or smaller than 'compare_value_1', for example ${actual_counter_value}>${compare_value_1},
    ...        then use arguments ${compare_value_1} and ${expression_1}.
    ...        If the expected counter value is within an range, for example ${compare_value_1}<${actual_counter_value}<${compare_value_2},
    ...        then use arguments ${compare_value_1} ${expression_1} ${expression_2} ${compare_value_2}

    [Arguments]     ${counter_list}    ${bts_type}    ${expression_1}=${None}    ${expression_2}=${None}
    ...    ${compare_value_1}=${0}    ${compare_value_2}=${1}
    ...    ${start_time_lower_limit}=${None}    ${start_time_upper_limit}=${None}

    ${is_list}    evaluate    isinstance(${counter_list},list)
    ${counter_list}    run keyword if    ${is_list}==${False}    create list    ${counter_list}
    ...    ELSE    set variable    ${counter_list}
    ${counter_num}    Get Length    ${counter_list}
    Should be True   ${counter_num}

    ${oam_connection}=    _build connection with cloud cu or du   bts_type=${bts_type}
    ...      gnb_index=${gnb_index}    vdu_index=${vdu_index}

    FOR    ${counter}    IN   @{counter_list}
        ${dict_counter_check_result}     Get Counter Value From Cloud gNB WebEM
        ...     bts_type=${bts_type}
        ...     counter_info=${counter['counter_info']}
        ...     count_all_values=${counter['count_all_values']}
        ...     start_time_lower_limit=${start_time_lower_limit}
        ...     start_time_upper_limit=${start_time_upper_limit}
        ...     oam_connection=${oam_connection}

        ${expect_value}    set variable    ${counter['expect_value']}
        ${counter_actual_value}    set variable    ${dict_counter_check_result['value']}
        ${counter_actual_value}    Convert To Integer    ${counter_actual_value}
        log to console    The value of counter ${counter['counter_info']} is ${counter_actual_value}, expected value is ${expect_value}.
        Run keyword if     '${expect_value}' != '${None}'     should be equal    ${counter_actual_value}     ${expect_value}
        ...    ELSE     Run keyword if      '${expression_1}' != '${None}' and '${expression_2}' != '${None}'
	    ...    should be true     ${compare_value_1} ${expression_1} ${counter_actual_value} ${expression_2} ${compare_value_2}
        ...    ELSE     should be true    ${compare_value_1} ${expression_1} ${counter_actual_value}
		...    msg=The counter value does not match with its expected value.
    END
    [Teardown]    Run keyword if   '${bts_type}'=='du'     Teardown vdu connection     connection=${oam_connection}
    ...     ELSE        Teardown vcu connection    connection=${oam_connection}
