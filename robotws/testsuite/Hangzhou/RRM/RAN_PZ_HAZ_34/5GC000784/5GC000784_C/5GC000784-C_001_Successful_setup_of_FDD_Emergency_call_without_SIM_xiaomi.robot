# #*** Settings ***
# #Force Tags    PY36
# #Documentation     author: qingqing zhang
# #...                 contact: qingqing.zhang@nokia-sbell.com
# #...                 squad group: SG_03
# #...                 feature : 5GC000784
# #
# #Resource       ./Resources/5GC000784_common_keyword_xiaomi.robot
# #Variables      ./Resources/5GC00784_C_variables.py
# #Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/UE.robot
# #
# #Suite Setup    run keywords
# #...    robot_common_operations.Common Suite Setup    AND
# #...    Common Suite Setup for COAM    AND
# #...    Prepare with COAM classical BTS2 cell onair    AND
# #...    Lock LTE
# #
# #Suite Teardown   Run Keywords
# #...            robot_common_operations.Common Suite Teardown    AND
# #...            Run Keyword And Ignore Error    COAM Teardown gnb connections
# #
# #*** Variables ***
# #${tl_scf_file_name}    7326_784_SCF.xml
# #${tl_scf_filename_enb}    784_enb.xml
# #${interface_gnb}    br0
# #${interface_enb}    any
# #${nglogname1}    784C01nosim.pcap
# #${nglogname2}    784C02nosim_again.pcap
# #${nglogname3}    784C03withSIM.pcap
# #${nglogname4}    784C03withSIM_again.pcap
# #${nglogname4}    784C03withSIM_again.pcap
# #${nglogname11_1}    784C11_err_onggong.pcap
# #${nglogname11_2}    784C11_err_setup_failed.pcap
# #${gnb_log_7}    784C07_gnb_nosim.pcap
# #${enb_log_7}    784C07_enb_nosim.pcap
# #${gnb_log_8}    784C08_gnb_withsim.pcap
# #${enb_log_8}    784C08_enb_withsim.pcap
# #${biplog_C_01}       biplog_C_01.pcap
# #${biplog_C_11_1}       biplog_C_011_err.pcap
# #${biplog_C_11_2}       biplog_C_011_noerr.pcap
# #@{att_value}    0    120    8
# #${ue_index}    0
# #${nomal_call_number}    6688
# #${EC_number}    911
# #${power_on}    at+CFUN=1
# #${power_off}    at+CFUN=0
# #####1881
# #${ue_ul_port}    ${tl.ues[0].iperf_details.port}
# #${ue_dl_port}    ${tl.ues[0].iperf_details.ssh_connection_details.port}
# #${ul_direction}    ul
# #${dl_direction}    dl
# #${duration}    600
# #${ul_throughput}    40M
# #${dl_throughput}    800M
# #${ul_expect_throughput}    34
# #${dl_expect_throughput}    552     ###552*0.95=525
# #
# #*** Test Cases ***
# #[1]5GC001881_B_20_General_SiSo_E2E_system_setup_with_data_transfer_conducted_4T2R_40M
# #    [Documentation]
# #    ...    This test scenario is used to verify the E2E data transfer functionality of RF in full-panel mode.
# #    [Tags]     CRT_22R2    CRT_22R3    CRT_22R4
# #    [Timeout]    1 hour
# #    [Setup]    robot_common_operations.Common Case Setup
# #    Lock 5G other cell
# #    Adjust gNB_RU Attenuation    value1=${127}    value2=${127}    value3=${0}
# #    ${cell1_id}=    COAM Get nrcellid with lcrid    lcrid=${3}
# #    ${list_of_cell_ids}    Create list    ${cell1_id}
# #    Precondition for Sansumg UE    ue_type=${ue_type}    ui_version=S21UI3.1
# #    Attach and check power UE    ue_type=${ue_type}
# #    Power UE Start UL traffic    ul_throughput=${ul_throughput}
# #    power_ue.Start traffic    ue_type=${ue_type}    direction=${dl_direction}    duration=${duration}
# #    ...    throughput=${dl_throughput}    iperf_port=${ue_dl_port}
# #    sleep    60s
# #    ${log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=5m
# #    Power_ue.Check Tput    ue_type=${ue_type}    direction=UL    log=${log}   cells=${list_of_cell_ids}
# #    ...    target_throughput=${ul_expect_throughput}
# #    Power_ue.Check Tput    ue_type=${ue_type}    direction=DL    log=${log}   cells=${list_of_cell_ids}
# #    ...    target_throughput=${dl_expect_throughput}
# #    power_ue.Stop traffic    ue_type=huawei    direction=ul
# #    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl
# #    sleep    300s
# #    Power UE Start UL traffic    ul_throughput=${ul_throughput}
# #    power_ue.Start traffic    ue_type=${ue_type}    direction=${dl_direction}    duration=${duration}
# #    ...    throughput=${dl_throughput}    iperf_port=${ue_dl_port}
# #    sleep    12s
# #    UE.Check Both ULDL throughput for 40s    ue_type=huawei     theory_ul_peak=${ul_expect_throughput}
# #    ...    theory_dl_peak=${dl_expect_throughput}    nr_cell_index=${3}
# #    [Teardown]    Run keywords
# #    ...    robot_common_operations.Common Case Teardown    AND
# #    ...    Run Keyword And Ignore Error    Common UE teardown    AND
# #    ...    Check hanging resource for gnb    gnb_ips=${gnb_ips}    AND
# #    ...    Run Keyword And Ignore Error    Unlock 5G other cell    AND
# #    ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
# #
# #*** Keywords ***
# #power off SIM and attach
# #    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
# #    Power UE Precondition
# #    unlock the screen and close all task
# #    power_ue.UE Attach    ue_type=xiaomi    ue_index=${0}    gnb_index=${0}
# #    Modify NIDD parameter on gnb    parameters_to_update=${PARAMETERS_TO_UPDATE_EMER_RESOURCE}
# #    power off or on SIM    command=${power_off}    ue_index=${ue_index}
# #
# #trun on and off flight mode
# #    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
# #    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
# #    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
# #    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
# #    #####Turn off all running tasks on the phone#####
# #    csn.send_command    command=adb -s ${serial_number} shell input keyevent 3    connection=cygwin${ue_index}
# #    sleep   2s
# #    csn.send_command    command=adb -s ${serial_number} shell input keyevent 187    connection=cygwin${ue_index}
# #    sleep   4s
# #    csn.send_command    command=adb -s ${serial_number} shell input tap ${close_task}    connection=cygwin${ue_index}
# #    #####attach#####
# #    csn.send_command    command=adb -s ${serial_number} shell am start -a android.settings.AIRPLANE_MODE_SETTINGS
# #    ...        connection=cygwin${ue_index}
# #    sleep    2s
# #    csn.send_command    command=adb -s ${serial_number} shell input tap ${airplane}    connection=cygwin${ue_index}
# #    sleep   4s
# #    csn.send_command    command=adb -s ${serial_number} shell input tap ${airplane}    connection=cygwin${ue_index}
# #    sleep   4s
# #    [Teardown]    csn.disconnect      connection=cygwin${ue_index}
# #
# #make an emergency without SIM
# #    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${gnb_index}=${0}
# #    trun on and off flight mode
# #    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
# #    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
# #    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
# #    Start a emergency call
# ##    power off or on SIM    command=${dial_911}    ue_index=${ue_index}
# #    Start Capture Wireshark Logs on gNB    nglogname=${gnb_log_7}    interface=${interface_gnb}    gnb_index=${gnb_index}
# #    sleep    300s
# #    Stop the emergency call
# #    sleep    10s
# #    Stop Capture Wireshark Logs on gNB    nglogname=${gnb_log_7}    gnb_index=${gnb_index}
# #    [Teardown]    csn.disconnect      connection=cygwin${ue_index}
# #
# #make another emergency call and check it success
# #    [Arguments]     ${nglogname}    ${interface}    ${gnb_index}    ${ue_index}
# #    Start Capture Wireshark Logs on gNB    nglogname=${nglogname}    interface=${interface}    gnb_index=${gnb_index}
# #    make an emergency without SIM
# #    Stop Capture Wireshark Logs on gNB    nglogname=${nglogname}    gnb_index=${gnb_index}
# #    Check wireshark log for successful EC procedure without sim   logname=${nglogname}
# #
# #make an emergency with EPSfallback
# #    [Arguments]    ${ue_index}=${0}    ${gnb_index}=${0}
# #	trun on and off flight mode
# ##    eNB start capture wireshark log    filename=${enb_log_8}    interface=${interface_enb}
# #    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
# #    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
# #    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
# #    Start a emergency call
# #    Start Capture Wireshark Logs on gNB    nglogname=${gnb_log_8}    interface=${interface_gnb}    gnb_index=${gnb_index}
# #    Adjust eNB_RU Attenuation    value=${0}    value1=${0}
# #    sleep    330s
# #    Stop the emergency call
# #    Stop Capture Wireshark Logs on gNB    nglogname=${gnb_log_8}    gnb_index=${gnb_index}
# ##    eNB stop and Save classical Logs   filename=${enb_log_8}
# #
# #make an emergency without SIM by EPSfallback
# #    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${gnb_index}=${0}
# #    trun on and off flight mode
# #    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
# #    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
# #    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
# #    Start a emergency call
# #    Start Capture Wireshark Logs on gNB    nglogname=${gnb_log_7}    interface=${interface_gnb}    gnb_index=${gnb_index}
# #    sleep    300s
# #    Stop the emergency call
# #    Stop Capture Wireshark Logs on gNB    nglogname=${gnb_log_7}    gnb_index=${gnb_index}
# #    [Teardown]    csn.disconnect      connection=cygwin${ue_index}
# #
# #make an emergency with modify NIDD and check log
# #    [Arguments]    ${ue_index}=${0}    ${gnb_index}=${0}
# #    Start Capture Wireshark Logs on gNB    nglogname=${nglogname11_1}    interface=${interface_gnb}    gnb_index=${gnb_index}
# #    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
# #    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
# #    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
# #    Start a emergency call
# #    sleep    90s
# #    Modify NIDD parameter on gnb    parameters_to_update=${PARAMETERS_TO_emergencyCallLimServ_false}
# #    sleep    20s
# #    Stop Capture Wireshark Logs on gNB    nglogname=${nglogname11_1}    gnb_index=${gnb_index}
# #    stop the emergency call
# #    Check wireshark log that emergency call still ongoing  logname=${nglogname11_1}
# #    bip capture and check SIB1 not contain emergency from BIP log   biplog=${biplog_c_11_2}    bip_time=${1}
# #    Start Capture Wireshark Logs on gNB    nglogname=${nglogname11_2}    interface=${interface_gnb}    gnb_index=${0}
# #    Start a emergency call
# #    sleep    90s
# #    Stop Capture Wireshark Logs on gNB    nglogname=${nglogname11_2}    gnb_index=${0}
# #    Check wireshark log that emergency call setup failed  logname=${nglogname11_2}
# #
# #Check wireshark log for fallback EC procedure failed on 5QI1
# #    [Arguments]    ${gnb_log}    ${enb_log}
# #    Check wireshark log for EC 5QI 1    logname=${gnb_log}
# #    Check wireshark log for EC 5QI 1 failed for redirection    logname=${gnb_log}
# #    Check wireshark log for EC UEContextreleasecommand    logname=${gnb_log}
# ##    Check wireshark log for EC UEContextreleasecomplete    logname=${gnb_log}
# ##    Check wireshark log for EC fallback on enb    logname=${enb_log}
# #
# #Check wireshark log for fallback EC procedure failed on 5QI5
# #    [Arguments]    ${gnb_log}
# ##    Check wireshark log for EC 5QI 5    logname=${gnb_log}
# #    Check wireshark log for EC 5QI 5 failed for redirection    logname=${gnb_log}
# #
# #Check wireshark log that emergency call still ongoing
# #    [Arguments]    ${logname}
# #    Check wireshark log for EC setup    logname=${logname}
# #    Check wireshark log for EC 5QI 5 by ICRS    logname=${logname}
# #    Check wireshark log for EC 5QI 1    logname=${logname}
# #    Check wireshark log for EC unrelease  logname=${logname}
