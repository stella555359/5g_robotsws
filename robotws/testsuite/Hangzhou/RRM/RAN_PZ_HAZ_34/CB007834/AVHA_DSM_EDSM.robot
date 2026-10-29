*** Settings ***
Resource    ./resources/CB007834_5G_A_common_keyword.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008140/Resources/CB008140_common_keywords_multiUE.robot
Variables    ./resources/CB007834_5G_A_variables.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Library    DateTime
Library    ./resources/CB007834_5G_A_AVHA.py

Documentation
...   author: xiaodan.li
...   contact: xiaodan.li@nokia-sbell.com
...   squad group: SG_03

Suite Setup    Run keywords    Common Suite Setup for COAM    AND
...    Load SCF with different release

Suite Teardown    Run Keywords
...    Common Suite Teardown for COAM   AND
...    Adjust gNB_RU Attenuation TL357    AND
...    Run Keyword And Ignore Error    COAM Teardown gnb connections

*** Variables ***
${golden_scf_name_357}    Configuration_scf_GNB1_TL357
${epc_log_path}    /opt/workspace/CRT/Master/Case_Logs/
@{allow_fault_list}    62003    7311    7307    7107    8000     7331
@{ue_index_MTU_all}    ${1}    ${2}    ${3}    ${4}    ${5}    ${6}    ${7}    ${8}
@{ue_index_MTU_UE1}    ${1}
@{ue_index_MTU_powerall}    ${-1}
${APN}    wustatic
${dl_throughput_AVHA}    2500M
${dl_expect_tput_AVHA}    1000


*** Test Cases ***
[1]AVHA_enter_deep_sleep_and_exit
    [Documentation]    This user scenario to verify peak Tput for UL and DL besed on TMO configuration.
    [Tags]     classical    CRT_TRUNK    CRT_23R2    CRT_23R3
    [Timeout]    3 hour
    [Setup]    robot_common_operations.Common Case Setup
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    Online Modify Cell Status    Modify_Para_Online=${Modify_Para_Online_AVHA_DSM_Modified_1}
    Wait until keyword succeeds    3X    10s
    ...    Get many times RMOD Realtime Measurements
    ...    power_1_min=${270}    power_1_max=${300}
    ${current_time}=    Get Current Date    result_format=%H:%M:%S
    ${Modify_Para_Online_AVHA_DSM_Modified}    Auto_Modify_DSM_Value
    Online Modify Cell Status    Modify_Para_Online=${Modify_Para_Online_AVHA_DSM_Modified}
    Check Cell RU enter to DSM/EDSM    RU_status=SLEEP
    ${current_time_1}=    Get Current Date    result_format=%H:%M:%S
    ${secs}     Subtract Time From Time    ${current_time_1}    ${current_time}
    ${a}    Set Variable    ${2400-int(${secs})}
    sleep    ${a}s
    Check Cell RU exit to DSM/EDSM
    Adjust gNB_RU Attenuation TL357    cell301_value=${0}    cell11_value=${0}
    Multi MTU power and prepare ue     ue_index_MTU_all=${ue_index_MTU_UE1}
    ...    ue_index_MTU_poweron_all=${ue_index_MTU_UE1}
    ...    ue_index_MTU_poweroff_all=${ue_index_MTU_powerall}
    ...    MTU=Multi-UE Power Management.exe
    MultiUE.Detach    ue_index=${0}
    Wait until keyword succeeds    3X    10s
    ...    MutlUE attach and check tput    target_throughput=${dl_expect_tput_AVHA}    dl_throughput=${dl_throughput_AVHA}    ue_index=${0}
    [Teardown]    Run Keywords
    ...    robot_common_operations.Common Case Teardown    AND
    ...    Online Modify Cell Status    Modify_Para_Online=${Modify_Para_Online_AVHA_DSM_Recovey}    AND
    ...    Run Keyword And Ignore Error    Tear down the connections

#[1]AVHA_enter_DEEPSLEEP_EXTREME_SFP_and_exit_with_online_parameter_change
#    [Documentation]    This user scenario describes successful call setup with FDD – TDD FR1 DL CA for the single UE ,
#    ...     data split over PCell and SCells, with covBasedA1 SCells addition and covBasedA1 SCells activation.
#    [Tags]     classical    CRT_TRUNK    CRT_23R2    CRT_23R3
#    [Timeout]    3 hour
#    [Setup]    robot_common_operations.Common Case Setup

*** Keywords ***
Load SCF with different release
    ${release}=    Get sagnb release 7834
    Common Case TestLine Setup with singe BTS
    ...    is_commission=True    golden_scf_name=${golden_scf_name_${gnb_instance}}_${release}.xml
    Wait until keyword succeeds    20 min    20s    Check the cells status on air

Online Modify Cell Status
    [Arguments]    ${Modify_Para_Online}=${PARAMETERS_TO_ONLINE_MODIFY_3CC}
    Modify Parameters for Cases    Modify_Para_Online=${Modify_Para_Online}
    Wait until keyword succeeds    20 min    20s    Check the cells status on air

Check counter for 1354
    ${counter_value_list}    Get the all PM counter value    gnb_index=${0}    counter_id=${counter_id_1354}
    ...    dic_path=${counter_dic_path_1354}
    ${Threshold1_value_list}    Get the all PM counter value    gnb_index=${0}    counter_id=${counter_id_1354_Threshold1}
    ...    dic_path=${counter_dic_path_1354_Threshold1}
    ${Threshold2_value_list}    Get the all PM counter value    gnb_index=${0}    counter_id=${counter_id_1354_Threshold2}
    ...    dic_path=${counter_dic_path_1354_Threshold2}
    FOR    ${index}    IN    ${counter_value_list}
       Run keyword If    '${index}'=='0' or '${index}'=='1'        Should be True    ${counter_value_list${index}}==0
       ...    ELSE    Should be True    2000 > ${counter_value_list${index}} > 0
       sleep    1s
    END
    ${M55354C04007_DL_NUM_RETX_F1U_THR1}    Set Variable    ${counter_value_list}[2]
    ${M55355C06007_DL_NUM_RETX_X2U_THR1}    Set Variable    ${counter_value_list}[0]
    ${M55354C06007_DL_NUM_RETX_F1U_THR2}    Set Variable    ${counter_value_list}[6]
    ${M55355C08007_DL_NUM_RETX_X2U_THR2}    Set Variable    ${counter_value_list}[4]
    Evaluate    Sum(${Threshold1_value_list})<${M55354C04007_DL_NUM_RETX_F1U_THR1}+${M55355C06007_DL_NUM_RETX_X2U_THR1}
    Evaluate    Sum(${Threshold2_value_list})<${M55354C06007_DL_NUM_RETX_F1U_THR2}+${M55355C08007_DL_NUM_RETX_X2U_THR2}
    [Teardown]    COAM Teardown gnb connections

Locked ALL LTE cell
    Locked LTE cell    enb_index=${0}    LNRCELL_list=${LNRCELL_ENB0}
    Locked LTE cell    enb_index=${1}    LNRCELL_list=${LNRCELL_ENB1}

UnLocked ALL LTE cell
    UnLocked LTE cell    enb_index=${0}    LNRCELL_list=${LNRCELL_ENB0}
    UnLocked LTE cell    enb_index=${1}    LNRCELL_list=${LNRCELL_ENB1}

Attach and check 3CC tput
    Attach and check power UE    ue_type=${ue_type}
    Power UE Start DL traffic    dl_throughput=${dl_throughput_3CC}    dl_length=1400B    duration=2400    process_num=${3}
    Power UE Start UL traffic    ul_throughput=${ul_throughput}    duration=1800    duration=2400
    Prepare to caculate PM counter    period=start
    Get record time    label=start
    sleep    1200s
    Get record time    label=end
    Check 3CC DLUL tput    ue_type=${ue_type}
    Stop UL DL data transfer
    sleep    15m
    Get bts package version
    generate new report and get report id    file_path=${file_path}    report_name=${package_version}_${report_name}    tl_id=${tl_id}
    ...    package_version=${package_version}    start_time=${start_time}    end_time=${end_time}
    download_kpi_file    report_id=${report_id}    path=${excel_kpi_path}
    [Teardown]    Run keywords    Stop UL DL data transfer    AND
    ...    power_ue.UE Detach    ue_type=${ue_type}

Check 3CC DLUL tput
    [Arguments]    ${tput_dl_pcell}=${expected_tput_dl_T_pcell}    ${tput_dl_scell1}=${expected_tput_dl_T_scell1}
    ...    ${tput_dl_scell2}=${expected_tput_dl_T_scell2}
    ...    ${pcellid}=103    ${scellid1}=107    ${scellid2}=121
    ...    ${gnb_prime}=${0}    ${gnb_external}=${0}    ${ue_type}=${ue_type}
    ${nrcellid_pcell}    COAM Get nrcellid with lcrid    lcrid=${pcellid}    gnb_index=${gnb_prime}
    ${nrcellid_scell1}    COAM Get nrcellid with lcrid    lcrid=${scellid1}    gnb_index=${gnb_external}
    ${nrcellid_scell2}    COAM Get nrcellid with lcrid    lcrid=${scellid2}    gnb_index=${gnb_external}
    ${nrcellid_pcell}    Create list  ${nrcellid_pcell}
    ${nrcellid_scell1}    Create list  ${nrcellid_scell1}
    ${nrcellid_scell2}    Create list  ${nrcellid_scell2}
    ${tput_log_prime}    power_ue.Collect Tput    duration=60s    ignore_time=0s    ue_type=${ue_type}    gnb_index=${gnb_prime}
    ${tput_log_external}    power_ue.Collect Tput    duration=60s    ignore_time=0s    ue_type=${ue_type}    gnb_index=${gnb_external}
    power_ue.Check Tput    direction=DL    cells=${nrcellid_pcell}    log=${tput_log_prime}    ue_type=${ue_type}
    ...    target_throughput=${tput_dl_pcell}
    power_ue.Check Tput    direction=DL    cells=${nrcellid_scell1}    log=${tput_log_external}    ue_type=${ue_type}
    ...    target_throughput=${tput_dl_scell1}
    power_ue.Check Tput    direction=DL    cells=${nrcellid_scell2}    log=${tput_log_external}    ue_type=${ue_type}
    ...    target_throughput=${tput_dl_scell2}
    Power_ue.Check Tput    direction=UL    cells=${nrcellid_pcell}    log=${tput_log_prime}    ue_type=${ue_type}
    ...    target_throughput=${ul_expect_tput}

Check Cell RU enter to DSM/EDSM
    [Arguments]    ${RU_status}=SLEEP_EXTREME
    Wait until keyword succeeds    5 min    20s    Get Cell EnergySavingState    cell_index=311
    Wait until keyword succeeds    5 min    20s    Get Cell EnergySavingState    cell_index=312
    Wait until keyword succeeds    5 min    20s    Get Cell EnergySavingState    cell_index=313
    Wait until keyword succeeds    5 min    20s    Get Cell EnergySavingState    cell_index=301
    Wait until keyword succeeds    5 min    20s    Get Cell EnergySavingState    cell_index=302
    Wait until keyword succeeds    5 min    20s    Get Cell EnergySavingState    cell_index=303
    Wait until keyword succeeds    10 min    20s    Get Cell EnergySavingState    status=energySaving    cell_index=311
    Wait until keyword succeeds    10 min    20s    Get Cell EnergySavingState    status=energySaving    cell_index=312
    Wait until keyword succeeds    10 min    20s    Get Cell EnergySavingState    status=energySaving    cell_index=313
    Wait until keyword succeeds    10 min    20s    Get Cell EnergySavingState    status=energySaving    cell_index=301
    Wait until keyword succeeds    10 min    20s    Get Cell EnergySavingState    status=energySaving    cell_index=302
    Wait until keyword succeeds    10 min    20s    Get Cell EnergySavingState    status=energySaving    cell_index=303
    Wait until keyword succeeds    10 min    20s    Get require Cell status    status=off line    cell_index=311
    Wait until keyword succeeds    10 min    20s    Get require Cell status    status=off line    cell_index=312
    Wait until keyword succeeds    10 min    20s    Get require Cell status    status=off line    cell_index=313
    Wait until keyword succeeds    10 min    20s    Get require Cell status    status=off line    cell_index=301
    Wait until keyword succeeds    10 min    20s    Get require Cell status    status=off line    cell_index=302
    Wait until keyword succeeds    10 min    20s    Get require Cell status    status=off line    cell_index=303
    Wait until keyword succeeds    20 min    20s    Get RU DSM/EDSM    RU_index=1    status=${RU_status}
    Wait until keyword succeeds    20 min    20s    Get RU DSM/EDSM    RU_index=2    status=${RU_status}
    Wait until keyword succeeds    20 min    20s    Get RU DSM/EDSM    RU_index=3    status=${RU_status}
    sleep    60s
    Wait until keyword succeeds    3X    5s
    ...    Get many times RMOD Realtime Measurements
    ...    power_1_min=${130}    power_1_max=${150}
#    Wait until keyword succeeds    10 min    20s    Get require Cell status    status=failed    cell_index=311
#    Wait until keyword succeeds    10 min    20s    Get require Cell status    status=failed    cell_index=312
#    Wait until keyword succeeds    10 min    20s    Get require Cell status    status=failed    cell_index=301
#    Wait until keyword succeeds    10 min    20s    Get require Cell status    status=failed    cell_index=302

Check Cell RU exit to DSM/EDSM
    Wait until keyword succeeds    20 min    20s    Get RU DSM/EDSM    RU_index=1    status=AWAKE
    Wait until keyword succeeds    20 min    20s    Get RU DSM/EDSM    RU_index=2    status=AWAKE
    Wait until keyword succeeds    20 min    20s    Get RU DSM/EDSM    RU_index=3    status=AWAKE
    Wait until keyword succeeds    20 min    20s    Check the cells status on air
    sleep    60
    Wait until keyword succeeds    3X    5s
    ...    Get many times RMOD Realtime Measurements
    ...    power_1_min=${270}    power_1_max=${300}

MutlUE attach and check tput
    [Arguments]    ${target_throughput}=${dl_expect_tput}    ${dl_throughput}=${dl_throughput_FDD}    ${APN}=${APN}
    ...    ${ue_index}=${3}
    Attach and check IP OK    ue_index=${ue_index}    APN=${APN}
    MultiUE.Start DL Traffic    throughput_for_DL=${dl_throughput}    ue_index=${ue_index}    duration=2400    APN=${APN}
    sleep    60s
    Repeat keyword    10 times    Check tput via spark    target_throughput=${target_throughput}    ue_index=${ue_index}
    [Teardown]    Run Keywords
    ...    Run Keyword And Ignore Error    MultiUE.Stop DL Traffic    ue_index=${ue_index}    APN=${APN}
    ...    AND    Run Keyword And Ignore Error    MultiUE.Detach    ue_index=${ue_index}