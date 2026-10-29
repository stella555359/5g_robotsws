#*** Settings ***
#Documentation
#...   This is for 1726 TA common keywords
#...   squad group: MMW_SG1
#Resource    ../../5GC000517/Resources/Cobham_Pre.robot
#Resource    ./5GC001726_keywords.robot
#Resource    ./5GC001726_keywords_GH.robot
#Library     ./verify_throughput_from_cobham_log.py
#
#
#*** Keywords ***
#Cobham attach UE and start traffic
#    [Documentation]    Author: Wang Yixiang
#    [Arguments]    ${e500_script_path}    ${cell_index_for_attach}=1    ${dl_tput_size}=10    ${ul_tput_size}=10
#    ...            ${is_need_to_check_mul_drb_established}=${False}    ${mul_drb_code_stream}=${None}
#    ...            ${delta}=0    ${dl_bler_threshold}=${None}
#    ${dl_tput_size}    evaluate    ${dl_tput_size}+${delta}
#    ${ul_tput_size}    evaluate    ${ul_tput_size}+${delta}
#    Switch pcell for attach based on cell index    cell_index_for_attach=${cell_index_for_attach}
#    Cobham connection and start logging    e500_script_path=${e500_script_path}    connection=${TMA_SSH_ALIAS}
#    Connect to Capacity Unit Master case
#    wait until keyword succeeds    2 min    10 s    Connect to cobham control pc via ssh    tma_ssh_alias=${TMA_SSH_ALIAS}
#    Synchron gNB and cobham    alias=ASIK Master
#    sleep    10s
#    tm500.Perform cell search    cell_search_script_path=${e500_script_path}/NSA_5G_Cell_Config.txt    tm500_alias=${TMA_APP_ALIAS}
#    Cobham Retry ue attach if failed    e500_script_path=${e500_script_path}    mul_drb_code_stream=${mul_drb_code_stream}
#    ...                                     is_need_to_check_mul_drb_established=${is_need_to_check_mul_drb_established}
#
#    Iperf send UL traffic with real epc    throughput=${ul_tput_size}    traffic_time=${99999}  port=${IPERF_UL_PORT}
#    Iperf send DL traffic with real epc    throughput=${dl_tput_size}    traffic_time=${99999}  port=${IPERF_DL_PORT}
#
#    run keyword if    '${is_need_to_check_mul_drb_established}' == '${True}'    run keywords
#    ...   Iperf send UL traffic with real epc   throughput=${ul_tput_size}  traffic_time=${TRAFFIC_TIME}  port=${IPERF_UL_DEDIC_PORT}  AND
#    ...   Iperf send DL traffic with real epc   throughput=${dl_tput_size}  traffic_time=${TRAFFIC_TIME}  port=${IPERF_DL_DEDIC_PORT}
#    sleep    2s
#    run keyword if    ${dl_bler_threshold}!=${None}    Cobham check DL bler    dl_bler_threshold=${dl_bler_threshold}
#
#Cobham get DL throughput
#    [Documentation]    Author: Wang Yixiang
#    ...                Description: Evaluate throughput for DL data transfer
#    [Arguments]    ${ue_index}=0    ${throughput_log_file_path}=${TS_CASE_LOG_PATH}
#    &{dict_result}=    Get values on cobham by executing check GNB throughput command
#    ...                throughput_log_file_path=${throughput_log_file_path}    ue_index=${ue_index}
#    [Return]    ${dict_result['dl_average_tput']}
#
#Cobham get UL and DL throughput for some time
#    [Documentation]    Author: Wang Yixiang
#    ...                Description: get UL and DL throughput for some time.
#    ...                ${capture_time} is the duration time in which the throughput need to be checked. The time unit is second.
#    ...                ${interval} is the sleep time.
#    ...                Return a list with all tput info returned.
#    ...                                       Example output: [{'dl_tput_gnb': 19.809, 'dl_tput_iperf': 19.488, 'timestamp': '2019-12-05-13:31:01',
#    ...                                        'ul_tput_gnb': 4.503, 'ul_tput_iperf': 4.490},{....}]
#    [Arguments]    ${ue_index}=${0}    ${capture_time}=${300}    ${interval}=${10}
#    ...            ${ul_port}=${None}     ${dl_port}=${None}    ${direction}=both
#    ${time_stamp}    DateTime.get current date    result_format=epoch    exclude_millis=True
#    ${end_time}    Evaluate    ${time_stamp}+${capture_time}
#    @{ul_gnb_tput_list}    Create list
#    @{dl_gnb_tput_list}    Create list
#    @{ul_iperf_tput_list}    Create list
#    @{dl_iperf_tput_list}    Create list
#    @{list_tput_info_all}    Create list
#    :FOR    ${i}    IN RANGE    ${time_stamp}    ${end_time}
#        &{dict_tput_info}    Create dictionary
#        ${timestamp}    Get time from GNB
#        Set to dictionary    ${dict_tput_info}    timestamp=${timestamp}
#        ${ul_tput_gnb}    Run keyword unless    '${direction}'=='DL'    Run keyword and continue on failure
#        ...    Get UL throughput on gnb L2Lo all cell
#        Run keyword unless    '${direction}'=='DL'    Set to dictionary    ${dict_tput_info}    ul_tput_gnb=${ul_tput_gnb}
#
#        ${dl_tput_iperf}    Run keyword unless    '${direction}'=='UL'    Run keyword and continue on failure
#        ...    Cobham get DL throughput    ue_index=${ue_index}
#        Run keyword unless    '${direction}'=='UL'    Set to dictionary    ${dict_tput_info}    dl_tput_iperf=${dl_tput_iperf}
#
#        Append to list    ${list_tput_info_all}    ${dict_tput_info}
#        Sleep    ${interval}sec
#        ${now_time_stamp}    DateTime.get current date    result_format=epoch    exclude_millis=True
#        Exit for loop if    ${now_time_stamp}>${end_time}
#    END
#    [Return]    ${list_tput_info_all}
#
#Cobham check peak throughput
#    [Documentation]  Author: Wang Yixiang
#    ...              Description: Check peak throughput
#    [Arguments]      ${expected_dl_tput}    ${expected_ul_tput}
#    @{list_tput_info}    Cobham get UL and DL throughput for some time    ue_index=${0}
#    ...    capture_time=${50}    interval=${10}    ul_port=${UL_PORT}     dl_port=${DL_PORT}
#
#    run keyword and continue on failure
#    ...    Check throughput pass once    list_tput_info=${list_tput_info}    expected_tput=${expected_dl_tput}    direction=DL
#    run keyword and continue on failure
#    ...    Check throughput pass once    list_tput_info=${list_tput_info}    expected_tput=${expected_ul_tput}    direction=UL
#
#Cobham Common Test Teardown
#    [Timeout]    20 min
#    Iperf stop traffic from appserver and ue side    port=${IPERF_DL_PORT}
#    Cobham UE detach
#    Collect tma logs to test pc
#    5GC001726_keywords.Collect logs in teardown
#    Teardown all connections
#
#Cobham Common Test Teardown multi-UE
#    [Timeout]    20 min
#    run keyword and continue on failure    Iperf stop traffic from appserver and ue side    port=${IPERF_UL_PORT_LIST_TO_KILL}
#    run keyword and continue on failure    Cobham multiple UEs detach    number_of_ue=${NUMBER_OF_UE}
#    Cobham UE detach
#    Collect tma logs to test pc
#    5GC001726_keywords.Collect logs in teardown
#    Teardown all connections
