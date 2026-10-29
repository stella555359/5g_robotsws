*** Settings ***
Documentation    CB010630

Library     OperatingSystem
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/SISO_common_operation.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/UE_start_traffic.robot
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/throughput/nrdim_throughput/interface.py    WITH NAME
...         throughput_computation
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB010630_CB012119/Resources/CB010630_common_keywords.robot


*** Variables ***
@{ul_power_port_list}         43500   43600
${TL_NRBTS_ID}                ${tl.gnbs[0].instance_id}
@{T928_all_cell_list}         1   2   5
@{T928_all_nr_cell_list}      167247873    167247874    167247877
@{ul_traffic_list}            10    30
@{allowed_list1}              ${4655}    ${61524}    ${61652}    ${61649}    ${4654}    ${4592}
@{allowed_list2}              ${4655}    ${61524}    ${61652}    ${61649}    ${4654}    ${4592}    ${49}
@{CA_2CC_nr_list}             167247873    167247875
@{CA_4CC_nr_list}             167247873    167247874    167247876     167247877


*** Keywords ***
########### setup KW #################
CB010630 Suit Setup
    CI_interface.Common Suite Setup
    robot_common_operations.Common Suite Setup

CB010630.Case Setup
    robot_common_operations.Common Case Setup
    AlarmWatchdog.add_allow_alarms    fault_id=49
    Check GNB on air    bts_host=${gNB_ip}
    Check Alarm List on BTS    bts_host=${gNB_ip}    allowed_list=${allowed_list1}
    Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
    ...      Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
    ...      Test_PC_password=${Test_PC_password}
    ...      btslog_path=/tmp/btslog2      btslog_launcher=/opt/btslog/btslog_launcher
    ...      btslog_launcher_path=/opt/btslog/btslog

CB010630.Case Teardown
    Run Keyword And Ignore error       Stop BTSlogs Collection And Download Logs To Log Server
    Run Keyword And Ignore error     Check ERR Or WRN From Syslog
    ...      sys_logs_path=${UTE_syslogs_path}      UTE_logs_path=${UTE_logs_path}
    ...      base_file=${Base_ERR_WRN_csv_path}
    ...      Expected_ERR_WRN_deviation=0.3      Delete_old_ERR_WRN=1
    ...       Fail_Case=False       Clear_log=True
    ...      FilesSystem=/dev/vda2      Max_used_space_ratio=0.85
    Run Keyword If    "${TEST_STATUS}"=="FAIL"    Save Snapshot    bts_host=${gNB_ip}
    robot_common_operations.Common case Teardown
    CI_interface.Common Case Teardown


############# Logic Code ###############

Start Traffic And Check Tp
    [Arguments]    ${ul_tp_list}    ${process}    ${log_time}    ${ul_list}    ${dl_list}    ${exp_ul_tp}    ${exp_dl_tp}
    ...    ${multiue_config_direction}=${TLCommonConfig["MultiUECFG"]}    ${ul_port_list}=${ul_power_port_list}    ${target_avg_percent}=1
    ...    ${min_percent}=0    ${if_ul}=${True}    ${if_dl}=${True}    ${duration}=6000    ${get_spark_license}=${True}
    Start Traffic By Spark    ul_tp_list=${ul_tp_list}    if_ul=${if_ul}    if_dl=${if_dl}    duration=${duration}    process=${process}
    ...    multiue_config_direction=${multiue_config_direction}    ul_port_list=${ul_port_list}    get_spark_license=${get_spark_license}
    Check TP From Aasyslog    log_time=${log_time}    ul_list=${ul_list}    dl_list=${dl_list}    exp_ul_tp=${exp_ul_tp}
    ...    exp_dl_tp=${exp_dl_tp}   target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    if_ul=${if_ul}    if_dl=${if_dl}
    [Teardown]    Stop Traffic And Detach UE    if_ul=${if_ul}    if_dl=${if_dl}


Test_scenario1_5QI7_no_CA
    [Arguments]    ${ul_tp_list}    ${process}    ${log_time}    ${ul_list}    ${dl_list}    ${exp_ul_tp}    ${exp_dl_tp}
    ...    ${multiue_config_direction}=${TLCommonConfig["MultiUECFG"]}    ${ul_port_list}=${ul_power_port_list}    ${target_avg_percent}=1
    ...    ${min_percent}=0    ${if_ul}=${True}    ${if_dl}=${True}    ${duration}=6000    ${get_spark_license}=${True}
    run keyword and continue on failure
    ...      Start Traffic By Spark    ul_tp_list=${ul_tp_list}    if_ul=${if_ul}    if_dl=${if_dl}    duration=${duration}    process=${process}
    ...    multiue_config_direction=${multiue_config_direction}    ul_port_list=${ul_port_list}    get_spark_license=${get_spark_license}
     Run Keyword And Ignore error          Check TP From Aasyslog
     ...      log_time=${log_time}    ul_list=${ul_list}    dl_list=${dl_list}    exp_ul_tp=${exp_ul_tp}
     ...    exp_dl_tp=${exp_dl_tp}   target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    if_ul=${if_ul}    if_dl=${if_dl}
    run keyword and continue on failure       Wait for one counter period     interval_time=5min
    #run keyword and continue on failure       Stop Traffic And Detach UE    if_ul=${if_ul}    if_dl=${if_dl}
	Log To Console    \n ### 5QI_ID 7 big traffic counters ###
	#${counter_dict}       Get counter value based on the list      host=${gNB_ip}
    #...     counter_list=${All_COUNTER_LIST}
    Get all DL counter value for the Corresponding 5QI via admin_cli    5QI_ID=7
    ...      MR_NR_CELL_NAME=${MRBTS_ID}/${NRBTS_ID}/NRCELL-2
	Set DL KPI Calculation formula
	check DL kpi for 5QI-7 big traffic condition
	run keyword and continue on failure    Get PART-C UL counter value for the Corresponding 5QI via admin_cli   5QI_ID=7
    ...      MR_NR_CELL_NAME=${MRBTS_ID}/${NRBTS_ID}/NRCELL-2
	run keyword and continue on failure    Set Part-C UL KPI Calculation formula
	run keyword and continue on failure    check PART-C UL kpi for 5QI-7
	[Teardown]    Stop Traffic And Detach UE    if_ul=${if_ul}    if_dl=${if_dl}











