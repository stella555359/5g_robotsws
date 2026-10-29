*** Settings ***
Documentation      Author: jia-rebecca.liu@nokia-sbell.com
...                squad group: SG_03
...                feature : CB009384

Resource         testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB012544_FDD/Resources/CB012544_SG3_case_step_cloud_vm.robot
Resource         testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/BIP_trace/BIP_trace_collector.robot


Suite Setup    Run Keyword    CB012544_FDD_suite_setup_CLOUD_VM

Suite Teardown    Run Keyword    CB012544_FDD_suite_teardown_CLOUD_VM


*** Variables ***
${M60_wireshark_attach_01}           M60_12bit_check.pcap
${M60_wireshark_check_IE}            M60_IE_check.pcap
${M60_wireshark_attach_02}           M60_ul_grant.pcap
${M60_wireshark_failure}             M60_attach_failed.pcap
${attach_WA_log}                     M60_attach_WA_log.pcap
${enter_idle_WA}                     M60_enter_idle_WA_log.pcap
${second_retry_after_failed}         M60_second_retry_after_failed.pcap
${dl_traffic_MTK60}                  120M
${expected_tput_MTK60}               117
${expected_tput_MTK60_ulgrant}       27
${expected_tput_samsung}             85
${ue_type_samsung}                   ${tl.ues[1].capabilities[1]}
${DL_port}                           ${tl.ues[4].iperf_details.port}
@{gnb_list}                          ${0}
${ue_type_MTK60_VM}                  ${tl.ues[4].capabilities[1]}
@{12544_allow_fault_list_VM}         7107    4681    7319    7300

*** Test Cases ***
[1]CB009384-A_B2_RedCap_UE_identification_during_call_setup_and_data_transfer_12_bit_length_check_counter
   [Documentation]
    ...    This case checks RedCap UE 12 bit identification during call setup and data transfer
    [Tags]    9384-A_B2
    [Setup]
    SG3_12544_case_setup_cloud_vm    online_ModifySCF=True
    ...                              Modify_Para_Online=${Online_Modify_9384_12bit}
    MTK60 prepare UE for VM    ue_index=${4}    ue_type=${ue_type_MTK60_VM}
    ###check SN 12bit and fiveG-TMSI/redcap IE exsit ###
    ${wireshark_attach_12bit}     _UE_attach_and_enter_idle_VM    tcpdump_collector_name=${M60_wireshark_attach_01}
    _check_user_inactivity_in_wireshark     file_path=${wireshark_attach_12bit}
    Prepare to caculate PM counter     period=start
    Start capture wireshark log on master     filename=${M60_wireshark_check_IE}    gNB_index=${0}
    Start DL traffic for MTK60      get_ip_from_cpif=${wireshark_attach_12bit}    dl_data_transfer=${dl_traffic_MTK60}    ue_index=${4}
    sleep    10s    reason=wait for a while after start traffic.
    Check tput for MTK60     ue_index=${4}     target_throughput=${expected_tput_MTK60}    cellid=${nrcellid3}    gnb_index=${0}
    ...                      duration=${60}
    Close the iperf process on APPserver    port=${DL_PORT}
    MTK60 UE Detach     ue_index=${4}
    Prepare to caculate PM counter       period=end
    ${wireshark_IE_check}    Stop and download the wiresharklog from master for VM    filename=${M60_wireshark_check_IE}    gNB_index=${0}
    check counters for 12bit
    check wireshark log for IE and 12bit    wireshark_IE_check=${wireshark_IE_check}    wireshark_attach_12bit=${wireshark_attach_12bit}
    ###---- check normal UE can attach and do traffic normally after redcap UE attach ----###
    Adjust the HBTE attenuation value for cloud vm    gnb_cell3_value=${10}
    power_ue.Prepare UE    ue_index=${1}    ue_type=${ue_type_samsung}    ui_version=S24UI5.1
    Attach and check power UE    ue_type=${ue_type_samsung}    ue_index=${1}
    Power UE Start DL traffic    dl_throughput=${dl_traffic_MTK60}    duration=9999
    ...    dl_length=1024B    dl_port=${DL_PORT}    ue_index=${1}    process_num=${1}    ue_type=${ue_type_samsung}
    DL Tput collect and check with nrcellid     cellid=${nrcellid3}    dlexpect_tp=${expected_tput_samsung}    ue_type=${ue_type_samsung}
    ...                                         duration=1m    gnb_index=${0}    min_percent=0.85
    power_ue.Stop traffic    ue_type=${ue_type_samsung}   direction=dl    ue_index=${1}    iperf_port=${DL_PORT}
    power_ue.UE Detach    ue_type=${ue_type_samsung}    ue_index=${1}
    ###---- change dl_length =100B,check throughput ----###
    Adjust the HBTE attenuation value for cloud vm    gnb_cell3_value_MTK60=${30}
    Common Case TestLine Setup     ModifySCF_Aftercommission=True
    ...                            Modify_Para_Online=${Online_Modify_9384_ulgrant}
    ${wireshark_attach_ulgrant}     _UE_attach_and_enter_idle_VM    tcpdump_collector_name=${M60_wireshark_attach_02}    sleep_time=1s
    Start DL traffic for MTK60      get_ip_from_cpif=${wireshark_attach_ulgrant}    dl_data_transfer=${dl_traffic_MTK60}    ue_index=${4}
    ...                             buffer_size=100B
    Check tput for MTK60     ue_index=${4}     target_throughput=${expected_tput_MTK60_ulgrant}    cellid=${nrcellid3}    gnb_index=${0}
    ...                      duration=${10}
    Close the iperf process on APPserver    port=${DL_PORT}
    MTK60 UE Detach     ue_index=${4}
    ###---- abnormal scenario ----###
    Common Case TestLine Setup     ModifySCF_Aftercommission=True
    ...                            Modify_Para_Online=${Online_Modify_9384_failure}
    Prepare to caculate PM counter     period=start
    Start capture wireshark log on master     filename=${M60_wireshark_failure}    gNB_index=${0}
    ${MTK60_attach_status}    run keyword and return status    MTK60 UE Attach    ue_index=${4}    gnb_index=${0}
    ...                                                        tcpdump_collector_name=${M60_wireshark_failure}
    ${wireshark_failure_scenario}    Stop and download the wiresharklog from master for VM    filename=${M60_wireshark_failure}    gNB_index=${0}
    MTK60 UE Detach     ue_index=${4}
    Prepare to caculate PM counter       period=end
    check counter for failure scenario
    [Teardown]    Case Teardown for 9384

*** Keywords ***
Case Teardown for 9384
    robot_common_operations.Common Case Teardown
    run keyword and ignore error    COAM Save snapshot via api    log_path=${TS_CASE_LOG_PATH}
    run keyword and ignore error    MTK60 UE Detach     ue_index=${4}
    run keyword and ignore error    Close the iperf process on APPserver    port=${UE_DL_port}
    run keyword and ignore error    Adjust the HBTE attenuation value for cloud vm
    Run keyword and ignore error    Teardown the all connections
    Run keyword and ignore error    CI_interface.Common Case Teardown