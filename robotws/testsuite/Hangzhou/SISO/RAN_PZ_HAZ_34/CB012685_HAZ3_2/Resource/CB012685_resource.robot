*** Settings ***
Documentation
...    author: zhang lusha
...    contact: lusha.zhang@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_2_SG

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot.robot
Resource    ${BASIC_PATH_5G}/Cell/General_SiSo_Cell_block_and_unblock.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Commissioning_BTS_Template_Commissioning.robot
Resource    ${BASIC_PATH_5G}/Manual_SiSo_CM_Recommissioning.robot
Resource    ${BASIC_PATH_5G}/Manual_SiSo_SM_BTS_Site_Reset.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Auto_BTS_site_reset.robot
Resource    ${BASIC_PATH_5G}/Cell/General_SiSo_Online_Cell_addition_deletion.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_reset_from_GUI.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_power_reset.robot
Resource    ${BASIC_PATH_5G}/BTS/Manual_SiSo_SM_NR_RAT_reset.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC000496_C/Resources/L3Call.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/cell_addition_deletion_online.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB007501_CB007503/Resource/CB007501_CB007503_resource.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/basic/simple_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot

Library    BuiltIn
Library    Collections
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/throughput/nrdim_throughput/interface.py

*** Variables ***
${TS_CASE_LOG_PATH}    /home/ute
${ue_type}    ${tl.ues[0].capabilities[2]}
${BASIC_PATH_5G}    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G
# ${UTE_syslogs_path}   /home/ute

*** Keywords ***
# CB012685 Start Syslog
#     Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
#     ...      Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
#     ...      Test_PC_password=${Test_PC_password}
#     ...      btslog_path=/tmp/btslog2      btslog_launcher=/opt/btslog/btslog_launcher
#     ...      btslog_launcher_path=/opt/btslog/btslog
#     sleep     2s

# CB012685 Stop Syslog And Check ERR WRN
#     Stop BTSlogs Collection And Download Logs To Log Server
#     log to console      UTE_logs_path is : ${UTE_syslogs_path}
#     Run Keyword And Continue On Failure      Check ERR Or WRN From Syslog
#     ...      sys_logs_path=${UTE_syslogs_path}
#     ...      UTE_logs_path=${UTE_logs_path}
#     ...      base_file=${Base_ERR_WRN_csv_path}
#     ...      Expected_ERR_WRN_deviation=0.08      Delete_old_ERR_WRN=1
#     ...       Fail_Case=False       Clear_log=True
#     ...      FilesSystem=/dev/vda2      Max_used_space_ratio=0.7

CB012685 Throughput test
    ${list_of_cell_ids}    Create List    33210369
    Throughput test        cells=${list_of_cell_ids}    dl_tp=712
    ...    dl_exp=500   ul_tp=80   ul_exp=50    ul_iperf_process=2

Throughput test
    [Arguments]    ${pci}=201    ${ue_index}=${0}    ${dl_tp}=500    ${dl_exp}=0    ${ul_tp}=100    ${ul_exp}=0
    ...    ${cells}=${cells}    ${ul_iperf_process}=ul_iperf_process
    CPE prepare    ue_index=${ue_index}
    CPE attach and verify    pci=${pci}    ue_index=${ue_index}
    CPE start dl ul traffic    ue_index=${ue_index}    dl_tp=${dl_tp}    ul_tp=${ul_tp}    ul_iperf_process=${ul_iperf_process}
    ${log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=300s    ignore_time=10s    check_source=Aasyslog
    ${all_tp}    power_ue.Check Bi Tput    ue_index=${ue_index}    ue_type=${ue_type}    log=${log}    cells=${cells}
    ...    ultarget_throughput=${ul_exp}    dltarget_throughput=${dl_exp}    check_source=Aasyslog
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
    [Arguments]  ${ue_index}    ${dl_tp}=20    ${ul_tp}=10    ${duration}=${3600}    ${protocol}=udp    ${ul_iperf_process}=2
    log to console    \nUe Start DL UL Traffic
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_tp}
    ...    protocol=${protocol}    duration=${duration}    ue_index=${ue_index}
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_tp}
    ...    protocol=${protocol}    duration=${duration}    ue_index=${ue_index}    process_num=${ul_iperf_process}

CPE stop dl ul traffic
    [Arguments]    ${ue_index}    ${protocol}=udp
    log to console    \nUe Stop DL UL Traffic
    run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${ue_index}
    ...    protocol=${protocol}
    run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${ue_index}
    ...    protocol=${protocol}

CPE collect tput
    [Arguments]    ${duration}=300    ${ignore_time}=10    ${check_source}=Iperf
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
