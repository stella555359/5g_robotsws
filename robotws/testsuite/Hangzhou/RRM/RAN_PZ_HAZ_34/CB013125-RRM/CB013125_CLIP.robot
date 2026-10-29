*** Settings ***
Documentation
...         author: Lixia.tang
...         contact: lixia.tang@nokia-sbell.com
...         squad group: 5G_PZ_MMW_HZ_3_SG
...         CB013125 CRT

Suite Setup    Run keywords    robot_common_operations.Common Suite Setup    AND    CI_interface.Common Suite Setup
Suite Teardown    robot_common_operations.Common Suite Teardown

Resource    ./Resources/CB013125_Common_Keywords.robot

Variables   ./Resources/TL2070_Configration.py

*** Variables ***
@{ul_traffic_list}    79   66   20   20   #20Mbps
@{port_list}         43567   43577   43587   43597
${traffic_duration}   600

*** Test Cases ***
[1]CB013125_A_02_LTE_AVHQA_TM8_Pre-defined_Sector_Beam_Pattern_Validation
    [Setup]    Test Case setup
    [Timeout]    30min
    Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
    Prepare MultiUE And Attach    multiue_config_direction=${TLCommonConfig1["MultiUECFG_LTE"]}
    MultiUE Start UDP Traffic    ul_port_list=${port_list}   ul_tp_list=${ul_traffic_list}    ul_duration=${traffic_duration}
    sleep   120s
    ${tput_status}   run keyword and return status   Check LTE TPut From Spark UE
    ${syslog_status}   Run Keyword And Ignore error   Stop Syslog and Check Err Wrn
    ${syslog_status[1]}    Run Keyword If    '${syslog_status[0]}' == 'PASS'    Set Variable    True
    ...    ELSE    Set Variable    False
    ${bts_status}    Check BTS Status And Return Result
    ${status}    Evaluate   ${tput_status} and ${bts_status} and ${syslog_status[1]}
    Should Be True    ${status}
    [Teardown]    Test teardown  status=${status}

[1]CB013125_C_48_NR_NSA_Intra_Site_2CC_Carrier_Aggregation
    [Setup]    Test Case setup
    [Timeout]    30min
    Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
    ${tput_status}   run keyword and return status   Make a L3 Call and Check Tput
    ...    multiue_config=${TLCommonConfig2["MultiUECFG_NSA"]}     log_time=120s   ul_cell_list=${nr_ca_cell_list}
    ...    actCarrierAggregation=${True}   dl_cell_list=${nr_ca_cell_list}    exp_ul_tp=66    exp_dl_tp=1024
    ...    avg_percent=0.6   min_percent=0
    ${syslog_status}   Run Keyword And Ignore error   Stop Syslog and Check Err Wrn
    ${syslog_status[1]}    Run Keyword If    '${syslog_status[0]}' == 'PASS'    Set Variable    True
    ...    ELSE    Set Variable    False
    ${bts_status}    Check BTS Status And Return Result
    ${status}    Evaluate   ${tput_status} and ${bts_status} and ${syslog_status[1]}
    Should Be True    ${status}
    [Teardown]    Test teardown  status=${status}

[1]CB013125_B_36_NR_SU_MIMO_Peak_Throughput_with_Max_Output_Tx_Power
    [Setup]    Test Case setup
    [Timeout]    30min
    Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
    ${tput_status}   run keyword and return status   Make a L3 Call and Check Tput
    ...    multiue_config=${TLCommonConfig3["MultiUECFG_SA"]}     log_time=120s   ul_cell_list=${nr_sa_cell_list}
    ...    actCarrierAggregation=${False}   dl_cell_list=${nr_sa_cell_list}    exp_ul_tp=50    exp_dl_tp=500
    ...    avg_percent=0.9   min_percent=0
    ${syslog_status}   Run Keyword And Ignore error   Stop Syslog and Check Err Wrn
    ${syslog_status[1]}    Run Keyword If    '${syslog_status[0]}' == 'PASS'    Set Variable    True
    ...    ELSE    Set Variable    False
    ${bts_status}    Check BTS Status And Return Result
    ${status}    Evaluate   ${tput_status} and ${bts_status} and ${syslog_status[1]}
    Should Be True    ${status}
    [Teardown]    Test teardown  status=${status}

[1]CB013125_B_35_NR_Frame_Configuration_Timing_Adjustment_Setting
    [Setup]    Test Case setup
    [Timeout]    50min
    ${call_status_before}   Make SA L3 Call and Return Status
    Run Keyword And Ignore Error    Stop Traffic And Detach UE
    Connect to gnb coam via ssl   connection=${connection}
    Perform Delta Plan Activation   delta_file=${CURDIR}/Resources/case35_delta_file1.json
    sleep   60s
    Modify Pmax and msg1FrequencyStart Parameter
    ${bts_status}   Check BTS Status And Return Result   connection=BTS
    ${call_status_after}   Make SA L3 Call and Return Status
    ${status}    Evaluate   ${call_status_after} and ${bts_status}
    Should Be True    ${status}
    [Teardown]    Test teardown  status=${status}

[1]CB013125_B_16_LTE_Power_Saving_Feature_Interaction
    [Setup]    Test Case setup
    [Timeout]    60min
    Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
    Connect to gnb coam via ssl   connection=${connection}
    ${LBPS_test_status}    run keyword and return status  Test LTE Load Based Power Saving Function
    ${DeepSleep_test_status}    run keyword and return status  Test Extreme Deep Sleep Support on Habrok Radio
    COAM Teardown gnb connections   connection=${connection}
    ${syslog_status}   Run Keyword And Ignore error   Stop Syslog and Check Err Wrn
    ${syslog_status[1]}    Run Keyword If    '${syslog_status[0]}' == 'PASS'    Set Variable    True
    ...    ELSE    Set Variable    False
    ${status}    Evaluate   ${LBPS_test_status} and ${DeepSleep_test_status} and ${syslog_status[1]}
    Should Be True    ${status}
    [Teardown]    Test teardown  status=${status}

*** Keywords ***
Stop Syslog and Check Err Wrn
    Run Keyword And Ignore error       Stop BTSlogs Collection And Download Logs To Log Server
    Run Keyword And Continue On Failure    Check ERR Or WRN From Syslog    sys_logs_path=${UTE_syslogs_path}    Fail_Case=False
    ${syslog_status}   Check Exception in Syslog    log_file=${syslog_file}    filter_string=${Exception_string}
    ${status}    Set Variable If    "${syslog_status}"=="pass"    True    False
    run keyword if   not ${status}   Save Checking Error Warning Syslog    log_file=${syslog_file}
    [return]   ${status}

Test teardown
    [Arguments]    ${status}
    robot_common_operations.Common Case Teardown
    Check Case Status and Stop UE Traffic    status=${status}
    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}
    CI_interface.Common Case Teardown
