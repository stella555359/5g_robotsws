# @Time    : 2023/11/16 15:34
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : CB009855_common_keywords.robot
# @Software: PyCharm
*** Settings ***
Documentation    This is common robot keywords template
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/logs.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/throughput/nrdim_throughput/interface.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot

*** Keywords ***
UE Attach On Different tddSpecSubfConf
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${set_1}    ${set_2}    ${cell_list}
    UE Attach 4G And Check Throughput Normal    ${cell_list}
    coam.perform_delta_recommissioning    delta_file=${set_1}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=${600}    connection=GNB_OAM
    Wait Until Keyword Succeeds    10min    15s    Verify BTS 4G Cells Status Is Normal State
    UE Attach 4G And Check Throughput Normal    ${cell_list}
    coam.perform_delta_recommissioning    delta_file=${set_2}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=${600}    connection=GNB_OAM
    Wait Until Keyword Succeeds    10min    15s    Verify BTS 4G Cells Status Is Normal State
    UE Attach 4G And Check Throughput Normal    ${cell_list}

UE Attach On Different prachConfIndex
    [Documentation]    Author: felix.zhu@nokia-sbell.com
    [Arguments]    ${set_1}    ${cell_list}
    UE Attach 4G And Check Throughput Normal    ${cell_list}
    coam.perform_delta_recommissioning    delta_file=${set_1}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=${600}    connection=GNB_OAM
    Wait Until Keyword Succeeds    10min    15s    Verify BTS 4G Cells Status Is Normal State
    UE Attach 4G And Check Throughput Normal    ${cell_list}

UE Attach 4G And Check Throughput Normal
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${cell_list}    ${ue_index}=0
    ...    ${ul_tp}=50M    ${ul_duration}=600
    ...    ${dl_tp}=50M    ${dl_duration}=600
    ${ue_type}    translate power ue type from testline    ${ue_index}
    Run Keyword And Ignore Error    power_ue.Prepare UE    ue_type=${ue_type}
    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
    Wait Until Keyword Succeeds    1min    10s    Verify 4G Attach by ADB Command    ${ue_index}
    UE Start UL Traffic    throughput=${ul_tp}    ul_time=${ul_duration}
    UE Start DL Traffic    throughput=${dl_tp}    dl_time=${dl_duration}
    Sleep    300s
    Check 4G Thourghput Update Normal    ${cell_list}
    [Teardown]    power_ue.UE Detach    ue_type=${ue_type}   ue_index=${ue_index}

Check 4G Thourghput Update Normal
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${cell_list}    ${ul_tp_threshold}=0    ${dl_tp_threshold}=0
    ...    ${ul}=M8012C23        ${dl}=M8012C26
    ${dl_counters}    coam.get_pm_counters    counter_ids=${dl}    timeout=300    connection=GNB_OAM
    ${all_cells_dl}    Set Variable    0
    FOR    ${cell}    IN    @{cell_list}
        ${dl_tp}    Set Variable
        ...    ${dl_counters['BTS']['MRBTS-2028']['LNBTS-11087']['${cell}']['MCC-262']['MNC-03']['LTE_Cell_Throughput']['${dl}']}
        ${time_list}    Get Dictionary Keys    ${dl_tp}
        ${all_cells_dl}    Evaluate    ${all_cells_dl}+${dl_tp['${time_list[-1]}']}
    END
    ${ul_counters}    coam.get_pm_counters    counter_ids=${ul}    timeout=300    connection=GNB_OAM
    ${all_cells_ul}    Set Variable    0
    FOR    ${cell}    IN    @{cell_list}
        ${ul_tp}    Set Variable
        ...    ${ul_counters['BTS']['MRBTS-2028']['LNBTS-11087']['${cell}']['MCC-262']['MNC-03']['LTE_Cell_Throughput']['${ul}']}
        ${time_list}    Get Dictionary Keys    ${ul_tp}
        ${all_cells_ul}    Evaluate    ${all_cells_ul}+${ul_tp['${time_list[-1]}']}
    END
    Should Be True    ${all_cells_dl}>${dl_tp_threshold}
    Should Be True    ${all_cells_ul}>${ul_tp_threshold}

Verify RIP M8056C0 Update Normal
    [Documentation]     Author: felix.zhu@nokia-sbell.com
    [Arguments]    ${timeout}=300    ${connection}=GNB_OAM
    ${counter_ids}=    Create List
    FOR    ${i}    IN RANGE    0    100
        ${counter_id}=    Set Variable    M8056C${i}
        Append To List    ${counter_ids}    ${counter_id}
    END
    ${counter_ids_str}=    Evaluate    ','.join(${counter_ids})
    ${rip_counters}=    coam.get_pm_counters    counter_ids=${counter_ids_str}    timeout=${timeout}    connection=${connection}
    FOR    ${counter_id}    IN    @{counter_ids}
        ${counter_dict}=    Get From Dictionary
        ...    ${rip_counters['BTS']['MRBTS-2028']['LNBTS-11087']['LNCEL-212']['MCC-262']['MNC-03']['LTE_Received_Interference_Power']}
        ...    ${counter_id}
        ${counter_list}=    Get Dictionary Values    ${counter_dict}
        FOR    ${value}    IN    @{counter_list}
            Should Be True    ${value} > -130 and ${value} < -113    Counter ${counter_id} value ${value} not in (-130, -113)
        END
    END

verify_LTE_peak_throughput
    [Documentation]    Author: felix.zhu@nokia-sbell.com
    [Arguments]     ${ue_index}=0
    ...    ${ul_tp}=11    ${ul_duration}=600
    ...    ${dl_tp}=128    ${dl_duration}=600
    ...    ${protocol}=udp    ${apn}=${None}
    ...    ${log}=${None}
    ...    ${target_avg_percent}=0.98    ${min_percent}=0.85
    ...    ${check_source}=Iperf
    ${ue_type}    translate power ue type from testline    ${ue_index}
    Run Keyword And Ignore Error    power_ue.Prepare UE    ue_type=${ue_type}
    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
    Wait Until Keyword Succeeds    1min    10s    Verify 4G Attach by ADB Command    ${ue_index}
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_tp}
    ...    protocol=${protocol}    duration=${dl_duration}    ue_index=${ue_index}    apn=${apn}
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_tp}
    ...    protocol=${protocol}    duration=${ul_duration}    ue_index=${ue_index}    apn=${apn}
    sleep    20s
    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${ue_index}
    ...    protocol=${protocol}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${ue_index}
    ...    protocol=${protocol}
    power_ue.Check Tput    ue_type=${ue_type}    ue_index=${ue_index}
    ...    direction=dl    target_throughput=${dl_tp}
    ...    log=${log}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    ...    check_source=${check_source}
    power_ue.Check Tput    ue_type=${ue_type}    ue_index=${ue_index}
    ...    direction=ul    target_throughput=${ul_tp}
    ...    log=${log}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    ...    check_source=${check_source}
    [Teardown]    power_ue.UE Detach    ue_type=${ue_type}   ue_index=${ue_index}

Reconfigure_LTE_different_bandwidth
    [Documentation]    Author: felix.zhu@nokia-sbell.com
    [Arguments]    ${set_1}
    coam.perform_delta_recommissioning    delta_file=${set_1}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=${600}    connection=GNB_OAM
    Wait Until Keyword Succeeds    10min    15s    Verify BTS 4G Cells Status Is Normal State

UE root
    [Documentation]    Author: felix.zhu@nokia-sbell.com
    [Arguments]  ${ue_index}=0    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Connect to control pc enhanced    ue_index=${ue_index}
    csn.send_command    command=adb -s ${serial_number} root  connection=cpc_${ue_index}
    csn.disconnect    connection=cpc_${ue_index}

