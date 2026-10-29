*** Settings ***
Documentation    Author:jun.8.chen@nokia-sbell.com
...              This is for MTK related common keywords with using taf.ul.power_ue.
...              Please do not modify the file without notification to author
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/check_android_ue_l3_call_process.robot


*** Keywords ***
Start L3 Call And ChecK Throughput
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]    ${cells}
    ...            ${ue_index}=${0}
    ...            ${mode}=SA
    ...            ${is_do_require_ue}=${True}
    ...            ${transfer_duration}=900
    ...            ${ul_throughput}=100
    ...            ${dl_throughput}=1400
    ...            ${duration}=5min
    ...            ${ignore_time}=1min
    ...            ${ultarget_throughput}=90
    ...            ${dltarget_throughput}=1300
    ...            ${target_avg_percent}=0.9
    ...            ${min_percent}=0.8
    ${attach_info}    Start UE Attach For MTK UE    ue_index=${ue_index}
    ...                                             is_do_require_ue=${is_do_require_ue}
    ...                                             mode=${mode}
    Start Traffic For MTK UE    ue_type=${ue_type}
    ...                         ue_index=${ue_index}
    ...                         duration=${transfer_duration}
    ...                         ul_throughput=${ul_throughput}
    ...                         dl_throughput=${dl_throughput}
    Start To Collect And Check Tupt    ue_type=${ue_type}
    ...                                cells=${cells}
    ...                                ultarget_throughput=${ultarget_throughput}
    ...                                dltarget_throughput=${dltarget_throughput}
    ...                                target_avg_percent=${target_avg_percent}
    ...                                min_percent=${min_percent}
    [Teardown]    Teardown For MTK UE    ue_type=${ue_type}    ue_index=${ue_index}

Start UE Attach For MTK UE
    [Documentation]    Author:jun.8.chen@nokia-sbell.com
    ...                this keyword perform MTK attach and verify 5g rach success.
    [Arguments]    ${wireshark_log_prefix}=cpif_log_attach
    ...            ${enb_wireshark_log_prefix}=enb_wireshark_log
    ...            ${connection}=ASIK Master
    ...            ${log_dir_ute}=${TS_CASE_LOG_PATH}
    ...            ${ue_index}=${0}
    ...            ${gnb_index}=${0}
    ...            ${du_index}=0
    ...            ${enb_index}=${0}
    ...            ${common_unit_index}=${0}
    ...            ${sleep_interval}=5 sec
    ...            ${coam_connection}=GNB_OAM
    ...            ${mode}=SA
    ...            ${is_do_require_ue}=${True}
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Set Test Variable    ${ue_type}
    ${wireshark_log_name}    Set Variable    ${wireshark_log_prefix}_${timestamp}
    ${enb_wireshark_log_name}    Set Variable    ${enb_wireshark_log_prefix}_${timestamp}
    Run Keyword If    ${is_do_require_ue}    New_MTK_keywords.Start Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    Run Keyword And Continue On Failure    Start Container Capture Wireshark Log    tcpdump_collector_name=${wireshark_log_name}
    ...                                                                             asik_connection_alias=${connection}
    ...                                                                             gnb_index=${gnb_index}
    ...                                                                             du_index=${du_index}
    Run Keyword If    '${mode}'=='NSA'
    ...    Run Keyword And Continue On Failure    Start tcpdump Log On Enb    tcpdump_collector_name=${enb_wireshark_log_name}
    ...                                                                       enb_index=${enb_index}
    ...                                                                       common_unit_index=${common_unit_index}
    Sleep    ${sleep_interval}
    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
    Sleep    ${sleep_interval}
    ${wireshark_log_path_on_testPC}    Run Keyword And Continue On Failure    Stop Container Wireshark Log Collection
    ...    tcpdump_collector_name=${wireshark_log_name}    target_dir=${log_dir_ute}
    ${enb_wireshark_log_path_on_testPC}    Run Keyword If   '${mode}'=='NSA'
    ...    Run Keyword And Continue On Failure    Stop tcpdump log collection    tcpdump_collector_name=${enb_wireshark_log_name}
    ...                                                                          target_dir=${log_dir_ute}
    power_ue.Verify attach    ue_type=${ue_type}    ue_index=${ue_index}
    ${attach_info}    Run Keyword If    '${mode}'=='NSA'    Create Dictionary    cpif_log_path=${wireshark_log_path_on_testPC}
    ...                                                                          enb_wireshark_log_path=${enb_wireshark_log_path_on_testPC}
    ...    ELSE    Create Dictionary    cpif_log_path=${wireshark_log_path_on_testPC}
    [Return]     ${attach_info}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    core.stop_collectors    names=${wireshark_log_name}    AND
    ...                           Run Keyword And Ignore Error    core.teardown_collectors    names=${wireshark_log_name}    AND
    ...                           Run Keyword And Ignore Error    core.stop_collectors    names=${enb_wireshark_log_name}    AND
    ...                           Run Keyword And Ignore Error    core.teardown_collectors    names=${enb_wireshark_log_name}

Start Prepare UE
    [Documentation]   jun.8.chen@nokia-sbell.com
    ...              Description: Precondtion for mtk ue
    [Arguments]    ${ue_type}    ${ue_index}=${0}
    Wait Until Keyword Succeeds    3 times    5 sec    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}

Start Traffic For MTK UE
    [Documentation]    Author:jun.8.chen@nokia-sbell.com
    [Arguments]    ${ue_type}    ${ue_index}=${0}    ${duration}=600    ${ul_throughput}=100    ${dl_throughput}=1400
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    ue_index=${ue_index}    duration=${duration}    throughput=${ul_throughput}
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    ue_index=${ue_index}    duration=${duration}    throughput=${dl_throughput}

Stop Traffic For MTK UE
    [Documentation]    Author:jun.8.chen@nokia-sbell.com
    [Arguments]    ${ue_type}    ${ue_index}=${0}
    power_ue.Stop traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=dl
    power_ue.Stop traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=ul

Start To Collect And Check Tupt
    [Documentation]    Author:jun.8.chen@nokia-sbell.com
    [Arguments]    ${ue_type}    ${cells}    ${ue_index}=${0}    ${duration}=5min
    ...            ${ignore_time}=1min    ${check_source}=Aasyslog
    ...            ${connection}=GNB_OAM     ${list_all_cell_ids}=${False}
    ...            ${ultarget_throughput}=90    ${dltarget_throughput}=1300
    ...            ${target_avg_percent}=0.9    ${min_percent}=0.8
    power_ue.Collect Tput    ue_type=${ue_type}
    ...                      ue_index=${ue_index}
    ...                      duration=${duration}
    ...                      ignore_time=${ignore_time}
    ...                      check_source=${check_source}
    ${list_nrcell_ids}    Get NRCELLID based on CELLID    cellid=${cells}    connection=${connection}    list_all_cell_ids=${list_all_cell_ids}
    power_ue.Check Bi Tput    ue_type=${ue_type}    ue_index=${ue_index}    cells=${list_nrcell_ids}
    ...                       ultarget_throughput=${ultarget_throughput}    dltarget_throughput=${dltarget_throughput}
    ...                       target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    ...                       check_source=${check_source}

Teardown For MTK UE
    [Documentation]    Author:jun.8.chen@nokia-sbell.com
    [Arguments]    ${ue_type}    ${ue_index}=${0}
    Run Keyword And Ignore Error    power_ue.Stop traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=dl
    Run Keyword And Ignore Error    power_ue.Stop traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=ul
    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}
    Run Keyword And Ignore Error    power_ue.Teardown UE    ue_type=${ue_type}    ue_index=${ue_index}

