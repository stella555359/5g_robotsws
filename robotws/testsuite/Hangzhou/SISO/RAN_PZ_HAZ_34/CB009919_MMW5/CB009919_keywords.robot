# @Time    : 2023/2/13 10:11
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : CB009919_keywords.robot
# @Software: PyCharm
*** Settings ***
Documentation
...    author: Chen Jian
...    contact: jian.1.chen@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_3_SG05
...    Feature CB009919-SR-A _AEHC common keywords
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot

*** Keywords ***
UE Attach On Different tddSpecSubfConf
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${set_1}    ${set_2}    ${cell_list}
    Wait Until Keyword Succeeds    10min    15s    Verify BTS 4G Cells Status Is Normal State
    UE Attach 4G And Check Throughput Normal    ${cell_list}
    coam.perform_delta_recommissioning    delta_file=${set_1}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=${600}    connection=GNB_OAM
    Wait Until Keyword Succeeds    10min    15s    Verify BTS 4G Cells Status Is Normal State
    UE Attach 4G And Check Throughput Normal    ${cell_list}
    coam.perform_delta_recommissioning    delta_file=${set_2}
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
    Sleep    100s
    Check 4G Thourghput Update Normal    ${cell_list}
    [Teardown]    power_ue.UE Detach    ue_type=${ue_type}   ue_index=${ue_index}

Check 4G Thourghput Update Normal
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${cell_list}    ${ul_tp_threshold}=0    ${dl_tp_threshold}=0
    ...    ${ul}=M8012C23        ${dl}=M8012C26
    ${dl_counters}    coam.get_pm_counters    counter_ids=${dl}    timeout=300    connection=GNB_OAM
    ${all_cells_dl}    Set Variable    0
    FOR    ${cell}    IN    @{cell_list}
        ${dl_tp}    Set Variable If    '${Active_SW_version}'>='SBTS24R2'
        ...    ${dl_counters['BTS']['MRBTS-2006']['LNBTS-10786']['${cell}']['MCC-262']['MNC-03']['LTE_Cell_Throughput']['${dl}']}
        ...    ${dl_counters['BTS']['CELLS']['${cell}']['MCC-262_MNC-03']['LTE_Cell_Throughput']['${dl}']}
        ${time_list}    Get Dictionary Keys    ${dl_tp}
        ${all_cells_dl}    Evaluate    ${all_cells_dl}+${dl_tp['${time_list[-1]}']}
    END
    ${ul_counters}    coam.get_pm_counters    counter_ids=${ul}    timeout=300    connection=GNB_OAM
    ${all_cells_ul}    Set Variable    0
    FOR    ${cell}    IN    @{cell_list}
        ${ul_tp}    Set Variable If    '${Active_SW_version}'>='SBTS24R2'
        ...    ${ul_counters['BTS']['MRBTS-2006']['LNBTS-10786']['${cell}']['MCC-262']['MNC-03']['LTE_Cell_Throughput']['${ul}']}
        ...    ${ul_counters['BTS']['CELLS']['${cell}']['MCC-262_MNC-03']['LTE_Cell_Throughput']['${ul}']}
        ${time_list}    Get Dictionary Keys    ${ul_tp}
        ${all_cells_ul}    Evaluate    ${all_cells_ul}+${ul_tp['${time_list[-1]}']}
    END
    Should Be True    ${all_cells_dl}>${dl_tp_threshold}
    Should Be True    ${all_cells_ul}>${ul_tp_threshold}
