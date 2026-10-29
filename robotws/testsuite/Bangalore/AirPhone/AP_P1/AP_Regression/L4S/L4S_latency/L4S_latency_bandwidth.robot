*** Settings ***
Documentation     author: Sudha V
...               contact: sudha.v@nokia.com
...               Description:

Resource        ./L4S_latency_bandwidth_keywords.robot
Resource        ../../../Resources/robot/gnb.robot

Suite Setup       Common Suite Setup    feature_folder=L4S

*** Variables ***
${ul_tput}                       0
${WTS_CFG_PATH}                  ${CURDIR}/Config_Files/wts
${delta_file}                    ${CURDIR}/Config_Files/sm/scfc.xml
${target_gnb}                    2
${target_cells}                  1
@{SA_UE_List}                    2
@{L4S_SA_UE_List}                1
${UE_IP}                         1.2.4.2
${THROUGHPUT}                    70M
${TRAFFIC_DURATION}              10000
@{ports}                         7263    7261    7265
${L4S_port}                      7267
${latency}                       80000
@{UE_List}                       1    2
@{dl_tput_list}                  175    175    175    175    100
@{Counter_List}                  M55352C03021    M55352C03022    M55352C03023    M55352C03024    M55352C03025
@{scell_index_list}              1    2    3    4
${configs}                       ${CURDIR}/Config_Files
${without_BLER_mode}             without_BLER
${with_BLER_mode}                with_BLER
${L4S_with_BLER_mode}            L4S_with_BLER

*** Test Cases ***
L4S_TC1 classic and L4S validation
    [Documentation]    Calculates latency and bandwidth of iperf traffic
    [Tags]    AP_REG    L4S_TC1
    [Setup]    Test Setup
    set Test Variable       ${log_iperf_files}    ${True}
    Comment    set Test Variable       ${bip_logs_started}    ${False}
    Register For L4S SA UEs    ${L4S_SA_UE_List}
    Register SA UE    ${SA_UE_List}
    Log To Console    classic and L4S traffic flow without BLER_testmode
    ${server_procs}    ${client_procs}    Start Classic Iperf Flows    ${without_BLER_mode}
    ${server_procs_iperf}    ${client_procs_iperf}    Start L4S Iperf Flow    ${without_BLER_mode}
    ${all_server_procs}    Combine Lists    ${server_procs}    ${server_procs_iperf}
    ${all_client_procs}    Combine Lists    ${client_procs}    ${client_procs_iperf}
    Sleep    60s
    Start parallel traffic for all SA UEs    ${SA_UE_List}    ${dl_tput_list}    ${ul_tput}
    Sleep    30s
    Run keyword And Continue On Failure
    ...    wait until keyword succeeds    10min    10s    Validate throughput from UE stats for all CA UEs for L4S
    ...    expected_dl_tput=430    expected_ue1_tput=200    expected_ue2_tput=200
    Log To Console    classic and L4S traffic flow with BLER_testmode
    FOR    ${server_proc}    ${client_proc}    IN ZIP    ${all_server_procs}    ${all_client_procs}
        Stop DL Data Transfer using Iperf    ${server_proc}    ${client_proc}
    END
    Activate BLER testmode
    ${server_procs}    ${client_procs}    Start Classic Iperf Flows    ${with_BLER_mode}
    ${server_procs_iperf}    ${client_procs_iperf}    Start L4S Iperf Flow    ${with_BLER_mode}
    ${all_server_procs}    Combine Lists    ${server_procs}    ${server_procs_iperf}
    ${all_client_procs}    Combine Lists    ${client_procs}    ${client_procs_iperf}
    Sleep    60s
    Run keyword And Continue On Failure
    ...    wait until keyword succeeds    10min    15s    Validate throughput from UE stats for all CA UEs for L4S
    ...    expected_dl_tput=280    expected_ue1_tput=120    expected_ue2_tput=180
    Run Keyword And Continue On Failure    Validate L4S iperf latency    ${with_BLER_mode}
    Run Keyword And Continue On Failure    Validate L4S bandwidth    ${with_BLER_mode}
    Log To Console    L4S traffic flow with BLER_testmode
    FOR    ${server_proc}    ${client_proc}    IN ZIP    ${all_server_procs}    ${all_client_procs}
        Stop DL Data Transfer using Iperf    ${server_proc}    ${client_proc}
    END
    ${server_procs_iperf}    ${client_procs_iperf}    Start L4S Iperf Flow    ${L4S_with_BLER_mode}
    Sleep    60s
    Run keyword And Continue On Failure
    ...    wait until keyword succeeds    10min    15s    Validate throughput from UE stats for all CA UEs for L4S
    ...    expected_dl_tput=355    expected_ue1_tput=70    expected_ue2_tput=300
    Run Keyword And Continue On Failure    Validate L4S iperf latency    ${L4S_with_BLER_mode}
    FOR    ${server_proc}    ${client_proc}    IN ZIP    ${server_procs_iperf}    ${client_procs_iperf}
        Stop DL Data Transfer using Iperf    ${server_proc}    ${client_proc}
    END
    Perform Stop Traffic and Detach SA UEs for Blind ScellAddition    ${SA_UE_List}
    Deactivate BLER testmode
    Log To Console    Sleeping for 5min before collecting PM Counters..
    Sleep    300s
    Run Keyword And Ignore Error    Collect Gnb PM Counters    target_dir=${testlog_path}    name=gnb_pm_counters
    Run Keyword And Ignore Error    Validate Gnb PM Counters    sa_ue_list=${SA_UE_List}    counters=${Counter_List}
    ...    counters_dir=${testlog_path}    name=gnb_pm_counters
    [Teardown]    Test Teardown