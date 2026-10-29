*** Settings ***
Suite Setup    Setup BTS env and set keyword prority
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs

Documentation    Suite description
...   author:      ying.5.chen@nokia-sbell.com
...   contact:     ying.5.chen@nokia-sbell.com
...   squad group: MMW_SG7

Force Tags    5G_RRM
...   PY39

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG7/resource/Common_Keywords.robot

*** Variables ***
${UE_TYPE}    huawei

${ul_throughput1}    73M
${dl_throughput1}    575M
${ul_peak_40M}    62   
${dl_peak_40M}    547
${duration}    1200
${list_of_cell_ids}    152940545

*** Test Cases ***
5GC00000_TestCase
    [Documentation]
    ...    1. The purpose of this test case is to setup L3 call and check traffic.
    ...      case step:
    ...         a. L3 call and check preak throughput
    [Tags]    A001
    Set test variable    ${TS_CASE_LOG_PATH}     ${TEST_LOG_DIR}
    L3 call and preak tput    dl_throughput=${dl_throughput1}    ul_throughput=${ul_throughput1}    dl_expect_throughput=${Dl_peak_40M}
    ...    ul_expect_throughput=${ul_peak_40M}    duration=${duration}

*** Keywords ***
L3 call and preak tput
    [Arguments]     ${dl_throughput}     ${ul_throughput}     ${dl_expect_throughput}     ${ul_expect_throughput}    ${duration}
    ...               ${ue_index}=${0}    ${iperf_type}=via_command    ${apn_address}=stdata1    ${ue_type}=${ue_type}    ${ue_index}=${0}
    ...    ${list_of_cell_ids}=152940545
    Log To Console    Single UE Attach
    power_ue.Prepare UE     ue_type=${ue_type}    ue_index=${ue_index}
    Log To Console    UE Attach
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    attach_mode=5G_SA    ue_index=${ue_index}
    Log To Console    Verify attach
    power_ue.Verify attach    ue_type=${ue_type}    ue_index=${ue_index}    5Grach_ed=${5Grach_ed}    4G_check=False
    Log To Console    UL/DL traffic
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_throughput}    duration=${duration}    iperf_type=${iperf_type}
    ...    iperf_port=47489    apn_address=${apn_address}
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_throughput}    duration=${duration}    iperf_type=${iperf_type}
    ...    iperf_port=47501    apn_address=${apn_address}
    sleep    5s
    Log To Console    check Tput
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    ue_index=${ue_index}    duration=100s    ignore_time=10s
    ${list_of_cell_ids}    Create list    ${list_of_cell_ids}
    power_ue.Check Tput    ue_type=${ue_type}    direction=ul    cells=${list_of_cell_ids}    log=${tput_log}
    ...                     target_throughput=${ul_expect_throughput}
    power_ue.Check Tput    ue_type=${ue_type}    direction=dl    cells=${list_of_cell_ids}    log=${tput_log}
    ...                     target_throughput=${dl_expect_throughput}
    Log To Console    stop UL/DL traffic
    power_ue.Stop traffic     ue_type=${ue_type}     direction=dl    iperf_type=via_command
    power_ue.Stop traffic     ue_type=${ue_type}     direction=ul    iperf_type=via_command
    sleep    10s
    PowerUE.UE Detach    ue_type=${ue_type}
