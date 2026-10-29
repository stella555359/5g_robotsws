*** Settings ***
Force Tags    PY36
Documentation
...    Author:Deng xueqin
...    Contact:xueqin.deng@nokia-sbell.com
...    Group: VRF_HAZ3_T02
...    Feature: CB013288

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG08_keywords_cloud.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_Common.robot

Suite Setup         run keywords    Setup Suite For Cloud
Test Setup          Setup Test For Cloud
Test Teardown       Teardown Test For Cloud
Suite Teardown      Teardown Suite For Cloud

*** Variables ***
${scf_path_cu}    ${commissionings_path}/HGZ/${testline_name}/CB013288/cu
${scf_path_du}    ${commissionings_path}/HGZ/${testline_name}/CB013288/du
${TS_CASE_LOG_PATH}    /home/ute

*** Test Cases ***
[1]CB013288-E_1_cells onair on new full mode deployment on RINLINE2
    log to console    cell setup with full mode deployment checked in suite setup.

[1]CB013288-E_2_call setup based on new full mode deployment on RINLINE2
    Run Keyword And Ignore Error     UE call setup check
    ...    pci=56    ue_index=1    dl_tp=1500M    dl_exp=1300    ul_tp=1M    ul_exp=180

*** Keywords ***
UE call setup check
    [Arguments]    ${pci}    ${ue_index}    ${dl_tp}    ${dl_exp}    ${ul_tp}    ${ul_exp}
    CPE prepare    ue_index=${ue_index}
    CPE attach and verify    pci=${pci}    ue_index=${ue_index}
    CPE start dl ul traffic    ue_index=${ue_index}    dl_tp=${dl_tp}    ul_tp=${ul_tp}
    CPE collect tput
    CPE stop dl ul traffic    ue_index=${ue_index}
    CPE verify throughput    ue_index=${ue_index}    dl_exp=${dl_exp}    ul_exp=${ul_exp}
    [Teardown]    Call Teardown    ue_index=${ue_index}

CPE prepare
    [Arguments]  ${ue_index}
    log to console    \nPrepare UE
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Set Test Variable    ${ue_type}
    power_ue.Prepare UE    ue_index=${ue_index}    ue_type=${ue_type}

CPE attach and verify
    [Arguments]  ${ue_index}    ${pci}
    log to console    \nAttach UE
    ${5Grach_ed_0}    power_ue.UE Attach
    ...    ue_index=${ue_index}    ue_type=${ue_type}    log_type=Iperf    pci=${pci}
    sleep    6s

CPE detach
    [Arguments]  ${ue_index}
    log to console    \nDetach UE
    Power_ue.UE Detach    ue_index=${ue_index}    ue_type=${ue_type}

CPE start dl ul traffic
    [Arguments]  ${ue_index}    ${dl_tp}=20    ${ul_tp}=10    ${duration}=${3600}    ${protocol}=udp
    log to console    \nUe Start DL UL Traffic
    ${ul_process_num}    set variable    200
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_tp}
    ...    protocol=${protocol}    duration=${duration}    ue_index=${ue_index}
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_tp}
    ...    protocol=${protocol}    duration=${duration}    ue_index=${ue_index}    process_num=${ul_process_num}

CPE stop dl ul traffic
    [Arguments]    ${ue_index}    ${protocol}=udp
    log to console    \nUe Stop DL UL Traffic
    run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${ue_index}
    ...    protocol=${protocol}
    run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${ue_index}
    ...    protocol=${protocol}

CPE collect tput
    [Arguments]    ${duration}=30    ${ignore_time}=10    ${check_source}=Iperf
    log to console    \nCollect Tput
    ${log_path}    power_ue.Collect Tput    ue_type=${ue_type}    check_source=${check_source}    duration=${duration}
    ...    ignore_time=${ignore_time}
    [Return]  ${log_path}

CPE verify throughput
    [Arguments]  ${ue_index}    ${dl_exp}=1    ${ul_exp}=1    ${target_avg_percent}=0.80    ${min_percent}=0.60
    ...    ${log}=${TS_CASE_LOG_PATH}    ${check_source}=Iperf
    log to console    \nUE Verify Peak Throughput
    run keyword and continue on failure    power_ue.Check Tput    ue_type=${ue_type}    ue_index=${ue_index}
    ...    direction=dl    target_throughput=${dl_exp}
    ...    log=${log}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    ...    check_source=${check_source}
    run keyword and continue on failure    power_ue.Check Tput    ue_type=${ue_type}    ue_index=${ue_index}
    ...    direction=ul    target_throughput=${ul_exp}
    ...    log=${log}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    ...    check_source=${check_source}

Call Teardown
    [Arguments]    ${ue_index}
    Run Keyword And Ignore Error    CPE stop dl ul traffic    ue_index=${ue_index}
    Run Keyword And Ignore Error    CPE detach    ue_index=${ue_index}