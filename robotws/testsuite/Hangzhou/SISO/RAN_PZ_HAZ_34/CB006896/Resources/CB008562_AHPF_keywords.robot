*** Settings ***
Documentation    This is for CB008562 keywords
...              Author: Gao melinda
...              Contact: melinda.gao@nokia-sbell.com
...              squad: 5G_PZ_HZ_8_SG


Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/btslog.robot
Library    taf.ul.oam.selenium_coam    WITH NAME    selenium_coam
Library    taf.selenium.sbts    WITH NAME    selenium_sbts
Library    ../TestData/variables_AHPF_8562.py
Library    ../TestData/variables_AHPF_8562_for_24R1.py
Library    DateTime
Library    taf.transport.ssh    WITH NAME    csn
Variables    ../TestData/variables_AHPF_8562.py

*** Variables ***
${cell_id1}    ${1}
*** Keywords ***
General_SiSo_Auto_Antenna_Online_Monitoring_using_WebEM_with_call_AHPF
    log to console    prepare detach UE before monitoring...
    Run Keyword And Ignore Error    prepare UE detach
#    Start Btslog With Path Check
    ${UE_attach_time}    ${UE_detach_time}    data_transfer_8562    tput_info=${tput_define}    cell_id=${cell_id1}
    ...    target_avg_percent=${0.5}    min_percent=${0.5}    duration=${10}    tput_from=self_define
    [Teardown]    Selenium Logout And Close Browser

General_SiSo_Auto_Antenna_Online_Monitoring_using_WebEM_with_call_AHPF for 24R1
    log to console    prepare detach UE before monitoring...
    Run Keyword And Ignore Error    prepare UE detach
#    Start Btslog With Path Check
    ${UE_attach_time}    ${UE_detach_time}    data_transfer_8562 for 24R1    tput_info=${tput_define}    cell_id=${cell_id1}
    ...    target_avg_percent=${0.5}    min_percent=${0.5}    duration=${10}    tput_from=self_define
    [Teardown]    Selenium Logout And Close Browser

data_transfer_8562
    [Arguments]    ${tput_info}    ${cell_id}=${None}    ${target_avg_percent}=${None}    ${min_percent}=${None}
    ...    ${protocol}=udp    ${duration}=${600}    ${gnb_index}=0    ${du_index}=0    ${tput_from}=tool
    ...    ${connection}=GNB_OAM    ${duration_call}=${1800}   ${ue_index}=${0}
    ${tput_info}    get_self_define_tput_by_release    tput_info=${tput_info}
    ${avg_expect_rate}    Run Keyword If    ${target_avg_percent}==${None}    get_avg_expect_rate    ELSE
    ...    set variable    ${target_avg_percent}
    ${min_expect_rate}    Run keyword If    ${min_percent}==${None}    get_min_expect_rate    ELSE
    ...    set variable    ${min_percent}
    ${tput_info_total}    create dictionary
    log to console    use ue${ue_index} to make call on cell${cell_id}
    ${tput_cell}    run keyword if    '${tput_from}'=='tool'    get_tput_info_by_tool
    ...    cell_id=${cell_id}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    ...    duration=${duration}    connection=${connection}    ELSE    set variable    ${tput_info[${cell_id}]}
    log to console    tput info for cell ${cell_id} is: ${tput_cell}
    set to dictionary    ${tput_info_total}    ${cell_id}    ${tput_cell}
    ${tput_info}   set variable    ${tput_cell}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    run keyword and ignore error    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    run keyword if    '${ue_type}'=='huawei_sigspark'   prepare_aasyslog_process    gnb_index=${gnb_index}    du_index=${du_index}
    ${UE_attach_time}    DateTime.Get Current Date    result_format=timestamp
    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    attach_mode=5G_${gNb_CuType}
    ${iperf_type}  set variable if  '${ue_type}'=='huawei'    via_app    via_command
    ${dl_tp}    set variable    ${tput_info['dl_tp']}
    ${ul_tp}    set variable    ${tput_info['ul_tp']}
    ${tput_spark}    run keyword if    '${ue_type}'=='huawei_sigspark'    generate_tput_for_spark_ue    dl_tp=${dl_tp}    ul_tp=${ul_tp}
    ${dl_tp}    run keyword if    '${ue_type}'=='huawei_sigspark'    set variable     ${tput_spark[0]}   ELSE    set variable   ${dl_tp}
    ${ul_tp}    run keyword if    '${ue_type}'=='huawei_sigspark'    set variable    ${tput_spark[1]}    ELSE    set variable   ${ul_tp}
    ${process_num}    set variable if      '${protocol}'=='udp'    ${1}    ${16}
    log to console    start dl traffic...
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_tp}
    ...    protocol=${protocol}    duration=${duration_call}    ue_index=${ue_index}    process_num=${process_num}    ue_mode=${gNb_CuType}
    log to console    start ul traffic...
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_tp}
    ...    protocol=${protocol}    duration=${duration_call}    ue_index=${ue_index}    iperf_type=${iperf_type}
    ...    data_amount=2M    ue_mode=${gNb_CuType}
    sleep    60s
    ${CSV_path}    set variable    /home/ute/MonitoringFile
    create directory    ${CSV_path}
    Selenium Login And Disable Screen Lock    download_dir=${CSV_path}
    selenium_sbts.select_antenna_lines_for_monitoring
    selenium_sbts.start_antenna_line_monitoring
    ${monitor_start_time}    DateTime.Get Current Date    result_format=timestamp
    sleep    120s
    selenium_sbts.stop_antenna_line_monitoring
    ${monitor_stop_time}    DateTime.Get Current Date    result_format=timestamp
    ${testing_duration_time}    DateTime.Subtract Date From Date    ${monitor_stop_time}    ${monitor_start_time}
    set test variable    ${testing_duration_time}
    ${antenna_lines_CSV_file}    selenium_sbts.export_monitored_value_to_csv
    ${tmp}    evaluate    ${testing_duration_time}/10
    ${end_RTWP}    get_integer    number=${tmp}
    ${VSWR_value}    ${VSWR_value_dict}    ${RTWP_value}    ${RTWP_value_dict}    ${RSSI_value}    ${RSSI_value_dict}
    ...    ${ETP_value}    ${ETP_value_dict}    ${lenth_integer_RSSI}    ${lenth_integer_VSWR}    ${lenth_integer_RTWP}
    ...    ${integer_VSWR}    ${integer_RTWP}    ${integer_RSSI}    ${character_RTWP}    ${character_RSSI}
    ...    ${ETP_list_length}
    ...    get_AHPF_CSV_content    file=${antenna_lines_CSV_file}
    ${call_RTWP_length}    Get Length    ${RTWP_value}
    log    ${call_RTWP_length}
    ${RTWP_number}    evaluate    ${call_RTWP_length}/4
    log to console    check VSWR's value...
    log    ${VSWR_value_dict}
    ${judge_value_VSWR}    judge value    list=${VSWR_value}
    should be equal    ${judge_value_VSWR}    True
    log to console    check RTWP's value...
    ${delta}    evaluate    ${end_RTWP} - ${RTWP_number}
    should be true    ${3} >= ${delta}
    ${judge_call_value_RTWP}    judge value    list=${RTWP_value}
    should be equal    ${judge_call_value_RTWP}    True
    log to console    check RSSI's value during call and no_call...
    log    ${RSSI_value_dict}
    ${judge_call_value_RSSI}    judge value    list=${RSSI_value}
    should be equal    ${judge_call_value_RSSI}    True
    log to console    check ETP's value...
    log    ${ETP_value_dict}
    ${judge_ETP_value}    judge value    list=${ETP_value}
    should be equal    ${judge_ETP_value}    True
    Should Be True    ${5} == ${ETP_list_length}
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
    check_tput_for_each_cell    tput_info=${tput_info_total}    cell_id=${cell_id}    ue_index=${ue_index}    tput_log=${tput_log}
    ...     target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    duration=${duration}    connection=${connection}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    ${iperf_type}  set variable if  '${ue_type}'=='huawei'    via_app    via_command
    run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${ue_index}
    ...    protocol=${protocol}
    run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${ue_index}
    ...    iperf_type=${iperf_type}    protocol=${protocol}
#    ${UE_detach_time}    DateTime.Get Current Date    result_format=timestamp
    power_ue.UE Detach  ue_type=${ue_type}    ue_index=${ue_index}
    ${UE_detach_time}    DateTime.Get Current Date    result_format=timestamp
    [Return]    ${UE_attach_time}    ${UE_detach_time}

prepare UE detach
    [Arguments]    ${ue_index}=${0}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    run keyword and ignore error    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    run keyword and ignore error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}

data_transfer_8562 for 24R1
    [Arguments]    ${tput_info}    ${cell_id}=${None}    ${target_avg_percent}=${None}    ${min_percent}=${None}
    ...    ${protocol}=udp    ${duration}=${600}    ${gnb_index}=0    ${du_index}=0    ${tput_from}=tool
    ...    ${connection}=GNB_OAM    ${duration_call}=${1800}   ${ue_index}=${0}
    ${tput_info}    get_self_define_tput_by_release    tput_info=${tput_info}
    ${avg_expect_rate}    Run Keyword If    ${target_avg_percent}==${None}    get_avg_expect_rate    ELSE
    ...    set variable    ${target_avg_percent}
    ${min_expect_rate}    Run keyword If    ${min_percent}==${None}    get_min_expect_rate    ELSE
    ...    set variable    ${min_percent}
    ${tput_info_total}    create dictionary
    log to console    use ue${ue_index} to make call on cell${cell_id}
    ${tput_cell}    run keyword if    '${tput_from}'=='tool'    get_tput_info_by_tool
    ...    cell_id=${cell_id}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    ...    duration=${duration}    connection=${connection}    ELSE    set variable    ${tput_info[${cell_id}]}
    log to console    tput info for cell ${cell_id} is: ${tput_cell}
    set to dictionary    ${tput_info_total}    ${cell_id}    ${tput_cell}
    ${tput_info}   set variable    ${tput_cell}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    run keyword and ignore error    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    run keyword if    '${ue_type}'=='huawei_sigspark'   prepare_aasyslog_process    gnb_index=${gnb_index}    du_index=${du_index}
    ${UE_attach_time}    DateTime.Get Current Date    result_format=timestamp
    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    attach_mode=5G_${gNb_CuType}
    ${iperf_type}  set variable if  '${ue_type}'=='huawei'    via_app    via_command
    ${dl_tp}    set variable    ${tput_info['dl_tp']}
    ${ul_tp}    set variable    ${tput_info['ul_tp']}
    ${tput_spark}    run keyword if    '${ue_type}'=='huawei_sigspark'    generate_tput_for_spark_ue    dl_tp=${dl_tp}    ul_tp=${ul_tp}
    ${dl_tp}    run keyword if    '${ue_type}'=='huawei_sigspark'    set variable     ${tput_spark[0]}   ELSE    set variable   ${dl_tp}
    ${ul_tp}    run keyword if    '${ue_type}'=='huawei_sigspark'    set variable    ${tput_spark[1]}    ELSE    set variable   ${ul_tp}
    ${process_num}    set variable if      '${protocol}'=='udp'    ${1}    ${16}
    log to console    start dl traffic...
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_tp}
    ...    protocol=${protocol}    duration=${duration_call}    ue_index=${ue_index}    process_num=${process_num}    ue_mode=${gNb_CuType}
    log to console    start ul traffic...
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_tp}
    ...    protocol=${protocol}    duration=${duration_call}    ue_index=${ue_index}    iperf_type=${iperf_type}
    ...    data_amount=2M    ue_mode=${gNb_CuType}
    sleep    60s
    ${CSV_path}    set variable    /home/ute/MonitoringFile
    create directory    ${CSV_path}
    Selenium Login And Disable Screen Lock    download_dir=${CSV_path}
    selenium_sbts.select_antenna_lines_for_monitoring
    selenium_sbts.start_antenna_line_monitoring
    ${monitor_start_time}    DateTime.Get Current Date    result_format=timestamp
    sleep    120s
    selenium_sbts.stop_antenna_line_monitoring
    ${monitor_stop_time}    DateTime.Get Current Date    result_format=timestamp
    ${testing_duration_time}    DateTime.Subtract Date From Date    ${monitor_stop_time}    ${monitor_start_time}
    set test variable    ${testing_duration_time}
    ${antenna_lines_CSV_file}    selenium_sbts.export_monitored_value_to_csv
    ${tmp}    evaluate    ${testing_duration_time}/10
    ${end_RTWP}    get_integer_24R1    number=${tmp}
    ${VSWR_value}    ${VSWR_value_dict}    ${RTWP_value}    ${RTWP_value_dict}    ${RSSI_value}    ${RSSI_value_dict}
    ...    ${ETP_value}    ${ETP_value_dict}    ${lenth_integer_RSSI}    ${lenth_integer_VSWR}    ${lenth_integer_RTWP}
    ...    ${integer_VSWR}    ${integer_RTWP}    ${integer_RSSI}    ${character_RTWP}    ${character_RSSI}
    ...    get_AHPF_CSV_content_for_24R1    file=${antenna_lines_CSV_file}
    ${call_RTWP_length}    Get Length    ${RTWP_value}
    log    ${call_RTWP_length}
    ${RTWP_number}    evaluate    ${call_RTWP_length}/4
    log to console    check VSWR's value...
    log    ${VSWR_value_dict}
    ${judge_value_VSWR}    judge_value_for_24R1    list=${VSWR_value}
    should be equal    ${judge_value_VSWR}    True
    log to console    check RTWP's value...
    ${delta}    evaluate    ${end_RTWP} - ${RTWP_number}
    should be true    ${1} >= ${delta}
    ${judge_call_value_RTWP}    judge_value_for_24R1    list=${RTWP_value}
    should be equal    ${judge_call_value_RTWP}    True
    log to console    check RSSI's value during call and no_call...
    log    ${RSSI_value_dict}
    ${judge_call_value_RSSI}    judge_value_for_24R1    list=${RSSI_value}
    should be equal    ${judge_call_value_RSSI}    True
    log to console    check ETP's value...
    log    ${ETP_value_dict}
    ${judge_ETP_value}    judge_value_for_24R1    list=${ETP_value}
    should be equal    ${judge_ETP_value}    True
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
    check_tput_for_each_cell    tput_info=${tput_info_total}    cell_id=${cell_id}    ue_index=${ue_index}    tput_log=${tput_log}
    ...     target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    duration=${duration}    connection=${connection}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    ${iperf_type}  set variable if  '${ue_type}'=='huawei'    via_app    via_command
    run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${ue_index}
    ...    protocol=${protocol}
    run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${ue_index}
    ...    iperf_type=${iperf_type}    protocol=${protocol}
#    ${UE_detach_time}    DateTime.Get Current Date    result_format=timestamp
    power_ue.UE Detach  ue_type=${ue_type}    ue_index=${ue_index}
    ${UE_detach_time}    DateTime.Get Current Date    result_format=timestamp
    [Return]    ${UE_attach_time}    ${UE_detach_time}
