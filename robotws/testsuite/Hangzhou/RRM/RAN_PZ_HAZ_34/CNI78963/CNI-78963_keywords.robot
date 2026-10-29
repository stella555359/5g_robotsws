# @Time    : 2022/2/14 14:10
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : CNI-78963_keywords.robot
# @Software: PyCharm
*** Settings ***
Documentation    This is common robot keywords template
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/BIP_trace/BIP_trace_collector.robot

*** Keywords ***
Capture BIP Log And Convert To CSV
    [Documentation]    jian.1.chen@nokia-sbell.com
    [Arguments]    ${filter}
    Get L1L2 ABIO Traffic To ASIL Cpu
    Connect To BTS Csn Via Lmp
    ${bip_files}    Download BIP Logs From ASIK To TestPC and rename it
    ${csv_file}    Replace String    ${bip_files}[0]    .pcap    .csv
    Set Suite Variable    ${CSV_FILE}    ${csv_file}
    @{csv_title_list}    Create List    3gpp.slot    DlData_DciInfoL1sw.dciSize
    ...    DlData_DciInfoL1sw.startCce
    Convert BIP To CSV By MCShark    bip_file=${bip_files}[0]
    ...    output_file=${csv_file}    filter=${filter}    csv_title_list=${csv_title_list}

Attach UE And Start UL DL Traffic
    [Documentation]    jian.1.chen@nokia-sbell.com
    [Arguments]    ${ul_tp}    ${ul_duration}    ${dl_tp}    ${dl_duration}    ${ue_index}=${0}
    ${ue_type}    translate power ue type from testline    ${ue_index}
    power_ue.Prepare UE    ue_type=${ue_type}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=0
    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    4G_check=False
    power_ue.Start traffic   ue_type=${ue_type}   direction=ul   throughput=${ul_tp}    duration=${ul_duration}
    ...    iperf_type=via_command
    UE Start DL Traffic    throughput=${dl_tp}    dl_time=${dl_duration}
