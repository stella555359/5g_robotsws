*** Settings ***
Documentation
...         author: Hongye.fu
...         contact: Hongye.fu@nokia-sbell.com
...         squad group: NSB MN RAN RD VRF HAZ 4
...         CB014095 CRT

Library    OperatingSystem

Suite Setup    Run keywords    robot_common_operations.Common Suite Setup    AND    CI_interface.Common Suite Setup
Suite Teardown    robot_common_operations.Common Suite Teardown

Resource    ./Resources/CB014095_Common_Keywords.robot
Variables   ./Resources/TL2070_Configuration.py


*** Variables ***
@{ul_traffic_list}    79   66   20   20   #20Mbps
@{port_list}         43567   43577   43587   43597
${traffic_duration}   600
${ue_alias}          spark_UE
${commission_loop_count}    30

*** Test Cases ***
[1]CB014095-SR-A-B1_5_CB014095-SR-A-B1_5_B2_Removal_of_sCellAdditionMethod_parameter_No_UE_blind
    [Tags]    HAZ3_T03
    [Setup]    Test Case setup
    [Timeout]    720min

    log to console    "Step0: Perform SCF commissioning loop ${commission_loop_count} times"
    SCF Commissioning Loop    loop_count=${commission_loop_count}

    log to console    "Step1: Start continuous traffic on UE before parameter removal"
    Prepare MultiUE And Attach    multiue_config_direction=${TLCommonConfig2["MultiUECFG_NSA"]}
    MultiUE Start UDP Traffic    ul_port_list=${port_list}   ul_tp_list=${ul_traffic_list}    ul_duration=300
    sleep    10s

    log to console    "Step2: Check throughput with SCell (before parameter removal)"
    Check UE Tput From Aasyslog   log_time=30s   ul_list=${nr_sa_cell_list}   dl_list=${nr_sa_cell_list}
    ...   actCarrierAggregation=${False}   exp_ul_tp=50    exp_dl_tp=500
    ...   target_avg_percent=0.9   min_percent=0   if_ul=${False}

    log to console    "Step3: Start Spark UE log before parameter removal"
    sparkMultiUE_yiyuan.start_log    ue_alias=${ue_alias}
    sleep    2s

    log to console    "Step4: Remove sCellAdditionMethod and sCellOperationalMode parameters online"
    Connect to gnb coam via ssl    connection=${connection}
    ${delta_json}    Catenate    SEPARATOR=
    ...    [{"distName": "MRBTS-10580/NRBTS-10580/NRCELL-501/NRREL-1", "operation": "update",
    ...    "parameters": [{"parameterName": "sCellAdditionMethod", "operation": "delete"},
    ...    {"parameterName": "sCellOperationalMode", "operation": "delete"}]}]
    ${delta_file}    Set Variable    /tmp/delta_remove_scell_params.json
    OperatingSystem.Create File    ${delta_file}    ${delta_json}
    coam.perform_delta_recommissioning    delta_file=${delta_file}
    ...    skip_parameter_relation_errors=${True}    should_activate=${True}
    ...    timeout=300    connection=${connection}

    log to console    "Step5: Wait for SCell to be released (approximately 1 minute)"
    sleep    60s

    log to console    "Step6: Stop Spark log and verify SCell release in RRC Reconfiguration message"
    Check SCell Release In RRC Reconfiguration    ue_alias=${ue_alias}

    log to console    "Step7: Verify cells are still onair and no unexpected alarms"
    ${onair_status}    Check Cells Onair And No Unexpected Alarm    Check_timer=2min    connection=${connection}
    Run Keyword If    '${onair_status}'!='pass'    Fail    Cell status check failed after parameter removal
    COAM Teardown gnb connections    connection=${connection}

    log to console    "Step8: Check throughput after SCell release"
    Check UE Tput From Aasyslog   log_time=30s   ul_list=${nr_sa_cell_list}   dl_list=${nr_sa_cell_list}
    ...   actCarrierAggregation=${False}   exp_ul_tp=25    exp_dl_tp=250
    ...   target_avg_percent=0.8   min_percent=0   if_ul=${False}

    log to console    "Step9: Stop traffic and detach UE"
    Run Keyword And Ignore Error    Stop Traffic And Detach UE

    # log to console    "Step9: Stop traffic and detach UE"
    # Run Keyword And Ignore Error    Stop Traffic And Detach UE

    [Teardown]    Test teardown



*** Keywords ***
SCF Commissioning Loop
    [Arguments]    ${loop_count}=30
    ${pass_count}    Set Variable    ${0}
    ${fail_count}    Set Variable    ${0}
    Connect to gnb coam via ssl    connection=${connection}
    FOR    ${i}    IN RANGE    ${loop_count}
        ${loop_num}    Evaluate    ${i}+1
        log to console    \n========== SCF Commission loop ${loop_num}/${loop_count} ==========
        ${comm_status}    ${comm_msg}    Run Keyword And Ignore error    coam.perform_commissioning    scf_file=${SCF_Path}
        ...   skip_parameter_relation_errors=True   timeout=600   connection=${connection}
        Run Keyword If    '${comm_status}'=='FAIL'    log to console    \n WARNING: commissioning failed at loop ${loop_num}: ${comm_msg}
        sleep    60s
        ${onair_status}    Check Cells Onair And No Unexpected Alarm    Check_timer=10min    connection=${connection}
        Run Keyword If    '${onair_status}'=='pass'    log to console    \n PASS: Loop ${loop_num} - Cells are onair
        Run Keyword If    '${onair_status}'!='pass'    log to console
        ...    \n FAIL: Loop ${loop_num} - Cells NOT onair (HW issue reproduced)
        Run Keyword If    '${onair_status}'!='pass'    Run Keyword And Ignore Error
        ...    Collect snapshot logs    Active_FaultID=${Active_FaultID}    History_FaultID=${History_FaultID}    connection=${connection}
        ${pass_count}    Set Variable If    '${onair_status}'=='pass'    ${${pass_count}+1}    ${pass_count}
        ${fail_count}    Set Variable If    '${onair_status}'!='pass'    ${${fail_count}+1}    ${fail_count}
        log to console    \n Stats: ${pass_count} passed / ${fail_count} failed out of ${loop_num} loops
        Run Keyword If    '${onair_status}'!='pass'    Exit For Loop
        sleep    30s
    END
    log to console    \n========== SCF Commissioning Loop Summary ==========
    log to console    \n Total: ${loop_count} loops, ${pass_count} passed, ${fail_count} failed
    COAM Teardown gnb connections    connection=${connection}
    Run Keyword If    ${fail_count} > 0    Fail    SCF Commissioning failed at loop ${${pass_count}+1}, snapshot collected

Test teardown
    Run Keyword And Ignore Error    Stop Traffic And Detach UE
    robot_common_operations.Common Case Teardown
    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}
    CI_interface.Common Case Teardown
