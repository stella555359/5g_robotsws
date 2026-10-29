*** Settings ***
Documentation
...    author: Shi Ming
...    contact: ming.shi@nokia-sbell.com
...    squal group: SG03
...    feature: QoS Explore

Suite Setup    Common Suite Setup For Explore
Suite Teardown    Common Suite Teardown For Explore

Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/None_Feature_SG3/Qos_related_explore_testing/Recources/QoS_explore_common_keywords.robot

*** Test Cases ***
CB008236_PUSCH_slot_aggregation_FDD_NPI_FOT
    [Timeout]    2 hours
    [Setup]    Common Case Setup For Explore
    paras change on BTS
    ...    paras=${PARAMETERS_CB008236_PUSCH_slot_aggregation_FDD_NPI_FOT}
    ...    delta_file_name=${epc_log_path}${PARAMETERS_CB008236_JSON_FILE}
    get and check operationalState of required cells
    ...    cells=${cells_CB008236_PUSCH_slot_aggregation}
    ...    states=${cells_CB008236_PUSCH_slot_aggregation_states_enabled}
    PA set required cell to needed value and set other cells to max value
    ...    index=${0}    values=${PARAMETERS_CB008236_PA_INITIAL_VALUE}
    Power_ue.Prepare UE    ue_type=${UES_TYPE}[0]    ue_index=${0}
    set apn to default dxdata2
    FOR    ${ue_index}    IN    @{CB008236_PUSCH_slot_aggregation_ue_index}
        Check UE device status with adb recover    ue_index=${ue_index}
        UE attach with wireshark captured
        ...    filename=${UE_ATTACH_WIRESHARK}[${ue_index}]
        ...    ue_type=${UES_TYPE}[${ue_index}]
        ...    ue_index=${ue_index}
        ...    is_new_prepare_ue=${is_new_Qcom_ue_type}[${ue_index}]
    END
    Start only DL traffic and check tput common ue
    ...    ue_index=${0}    ue_type=${UES_TYPE}[0]    dl_throughput=${Send_Tput_DL}    cellid=${1}    gnb_index=${0}
    ...    direction=DL    tput_dl_cell=${expected_tput_dl}    dl_port=${TRAFFIC_DL_PORT}    duration=${7200}
    Start only UL traffic and check tput common ue
    ...    ue_index=${0}    cellid=${1}    ue_type=${UES_TYPE}[0]    gnb_index=${0}
    ...    tput_ul_cell=${expected_tput_ul}    ul_throughput=${Send_Tput_UL}    duration=${7200}
    ...    ul_port=${TRAFFIC_UL_PORT}
    Make a VoNR call(+6688) on SDX80    ue_index=${2}
    Sleep    20s
    check voice call status    ue_index=${2}    status=${2}
    Prepare with PM counter time to caculate    period=start
    CB008236_adjust_pa_to_trigger    filename=${CB008236_adjust_pa_to_trigger_pcap}
    Prepare with PM counter time to caculate    period=end
    Comment    get counters and compare with last time
    Sleep    1m
    ${release_info}=    Get completed release
    ${time}=    Get Time    year month day hour min sec
    ${time_string}=    Evaluate    "_".join(${time})
    ${build_time}=    Catenate    ${release_info}_${time_string}
    get and write kpis to excel file    KPI_file=CB008236_counters.yml    para_index=${1}    target_sheet=CB008236
    ...    build_and_time=${build_time}    excel_file=${EXCEL_KPI_FILE_NAME}
    compare kpi result with last time    target_sheet=CB008236
    [Teardown]    Run Keywords
    ...    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    get gnb snapshot
    ...    AND    Power_ue.Prepare UE    ue_type=${UES_TYPE}[0]    ue_index=${0}
    ...    AND    Stop DL or UL traffic common ue    ue_index=${0}    ue_type=${UES_TYPE}[0]    direction=DL
    ...    AND    Stop DL or UL traffic common ue    ue_index=${0}    ue_type=${UES_TYPE}[0]    direction=UL
    ...    AND    UE.UE Detach     ue_type=${UES_TYPE}[0]     ue_index=${0}
    ...    AND    hang up VoNR call    ue_index=${2}
    ...    AND    check voice call status    ue_index=${2}    status=${0}
    ...    AND    Run Keyword And Ignore Error    Power_ue.Prepare UE    ue_type=${UES_TYPE}[2]    ue_index=${2}
    ...    AND    UE.UE Detach    ue_type=${UES_TYPE}[2]    ue_index=${2}
    ...    AND    paras change on BTS
    ...    paras=${PARAMETERS_RECOVER_CB008236_PUSCH_slot_aggregation_FDD_NPI_FOT}
    ...    delta_file_name=${epc_log_path}${PARAMETERS_RECOVER_CB008236_JSON_FILE}
    ...    AND    get and check operationalState of required cells
    ...    cells=${cells_CB008236_PUSCH_slot_aggregation}
    ...    states=${cells_CB008236_PUSCH_slot_aggregation_states_enabled}
    ...    AND    Set the attenuation value of ports simultaneously
    ...    att_ports=${RU_PA_info}[0][ports]
    ...    values=${RECOVER_PA_MAX_VALUE}
    ...    att_ipaddr=${RU_PA_info}[0][att_ipaddr]
    ...    AND    Common Case Teardown For Explore


CB009189_Service-aware_Scheduling_Request_and_H-ARQ_retransmissions
    [Documentation]
    ...    NIDD:actServiceAwareConfig=true
    ...    MRBTS-3481100000/NRBTS-34811/NRDRB_MAC-2 (New Radio DRB MAC Profile)
    ...    - maxDlHarqTxDrb=4
    ...    - maxUlHarqTxDrb=4
    ...    MRBTS-3481100000/NRBTS-34811/NRDRB_PDCP-2
    ...    - outOfOrderDeliveryDl=true
    ...    - outOfOrderDeliveryUl=true
    [Timeout]    2 hours
    [Setup]    Common Case Setup For Explore
    paras change on BTS
    ...    paras=${PARAMETERS_CB009189_Service_aware_Scheduling_Request_and_H_ARQ_retransmissions}
    ...    delta_file_name=${epc_log_path}${PARAMETERS_CB009189_JSON_FILE}
    get and check operationalState of required cells
    ...    cells=${cells_CB009189_Service_aware_Scheduling_Request_and_H_ARQ_retransmissions}
    ...    states=${cells_CB009189_Service_aware_Scheduling_Request_and_H_ARQ_retransmissions_states_enabled}
    PA set required cell to needed value and set other cells to max value
    ...    index=${4}    values=${PARAMETERS_CB009189_PA_INITIAL_VALUE}
    FOR    ${ue_index}    IN    @{CB009189_ue_index}
        Check UE device status with adb recover    ue_index=${ue_index}
        UE attach with wireshark captured
        ...    filename=${UE_ATTACH_WIRESHARK}[${ue_index}]
        ...    ue_type=${UES_TYPE}[${ue_index}]
        ...    ue_index=${ue_index}
        ...    is_new_prepare_ue=${is_new_Qcom_ue_type}[${ue_index}]
    END
    Start only DL traffic and check tput common ue
    ...    ue_index=${2}    ue_type=${UES_TYPE}[2]    dl_throughput=${Send_Tput_DL_9189}    cellid=${4}    gnb_index=${0}
    ...    direction=DL    tput_dl_cell=${expected_tput_dl_9189}    dl_port=${TRAFFIC_DL_PORT}    duration=${7200}
    Start only UL traffic and check tput common ue
    ...    ue_index=${2}    cellid=${4}    ue_type=${UES_TYPE}[2]    gnb_index=${0}
    ...    tput_ul_cell=${expected_tput_ul_9189}    ul_throughput=${Send_Tput_UL_9189}    duration=${7200}
    ...    ul_port=${TRAFFIC_UL_PORT}
    Prepare with PM counter time to caculate    period=start
    ${end_value}=    Evaluate    list(set(${PARAMETERS_CB009189_PA_TARGET_VALUE}))[0]
    ${initial_value}=    Evaluate    list(set(${PARAMETERS_CB009189_PA_INITIAL_VALUE}))[0]
    FOR    ${i}    IN RANGE    ${initial_value}    ${end_value} + ${PARAMETERS_CB009189_PA_STEP}    ${PARAMETERS_CB009189_PA_STEP}
        ${set_values}=    Evaluate    [${i}] * len(${PARAMETERS_CB009189_PA_INITIAL_VALUE})
        Set the attenuation value of ports simultaneously
        ...    att_ports=${RU_PA_info}[4][ports]
        ...    values=${set_values}
        ...    att_ipaddr=${RU_PA_info}[4][att_ipaddr]
        Sleep    1s
    END
    FOR    ${j}    IN RANGE    ${end_value}    ${initial_value} - ${PARAMETERS_CB009189_PA_STEP}    -${PARAMETERS_CB009189_PA_STEP}
        ${recover_set_values}=    Evaluate    [${j}] * len(${PARAMETERS_CB009189_PA_TARGET_VALUE})
        Set the attenuation value of ports simultaneously
        ...    att_ports=${RU_PA_info}[4][ports]
        ...    values=${recover_set_values}
        ...    att_ipaddr=${RU_PA_info}[4][att_ipaddr]
        Sleep    1s
    END
    Prepare with PM counter time to caculate    period=end
    Comment    get counters and compare with last time
    Sleep    1m
    ${release_info}=    Get completed release
    ${time}=    Get Time    year month day hour min sec
    ${time_string}=    Evaluate    "_".join(${time})
    ${build_time}=    Catenate    ${release_info}_${time_string}
    get and write kpis to excel file    KPI_file=CB009189_kpis.yml    para_index=${3}    target_sheet=CB009189
    ...    build_and_time=${build_time}    excel_file=${EXCEL_KPI_FILE_NAME}
    compare kpi result with last time    target_sheet=CB009189
    [Teardown]    Run Keywords
    ...    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    get gnb snapshot
    ...    AND    Run Keyword And Ignore Error    Power_ue.Prepare UE    ue_type=${UES_TYPE}[2]    ue_index=${2}
    ...    AND    Stop DL or UL traffic common ue    ue_index=${2}    ue_type=${UES_TYPE}[2]    direction=DL
    ...    AND    Stop DL or UL traffic common ue    ue_index=${2}    ue_type=${UES_TYPE}[2]    direction=UL
    ...    AND    UE.UE Detach    ue_type=${UES_TYPE}[2]    ue_index=${2}
    ...    AND    paras change on BTS
    ...    paras=${PARAMETERS_RECOVER_CB009189_Service_aware_Scheduling_Request_and_H_ARQ_retransmissions}
    ...    delta_file_name=${epc_log_path}${PARAMETERS_RECOVER_CB009189_JSON_FILE}
    ...    AND    get and check operationalState of required cells
    ...    cells=${cells_CB009189_Service_aware_Scheduling_Request_and_H_ARQ_retransmissions}
    ...    states=${cells_CB009189_Service_aware_Scheduling_Request_and_H_ARQ_retransmissions_states_enabled}
    ...    AND    Set the attenuation value of ports simultaneously
    ...    att_ports=${RU_PA_info}[4][ports]
    ...    values=${RECOVER_PA_MAX_VALUE}
    ...    att_ipaddr=${RU_PA_info}[4][att_ipaddr]
    ...    AND    Common Case Teardown For Explore


CB008126_QoS_Flow_Modification_CB008234_UE_AMBR_SA
    [Documentation]
    ...    UE Attach
    ...    make traffic with DL and UL
    ...    modify AMBR via Core
    ...    check Wireshark log AMBR changed
    ...    repeat 10 times modify AMBR
    ...    compare and check KPI
    [Timeout]    2 hours
    [Setup]    Common Case Setup For Explore
    paras change on BTS
    ...    paras=${PARAMETERS_CB008126_CB008234_QoS_Flow_Modification_CB008234_UE_AMBR_SA}
    ...    delta_file_name=${epc_log_path}${PARAMETERS_CB008126_CB008234_JSON_FILE}
    get and check operationalState of required cells
    ...    cells=${cells_QoS_Flow_Modification_CB008234_UE_AMBR_SA}
    ...    states=${cells_QoS_Flow_Modification_CB008234_UE_AMBR_SA_states_enabled}
    PA set required cell to needed value and set other cells to max value
    ...    index=${4}    values=${PARAMETERS_CB008126_8234_PA_INITIAL_VALUE}
    FOR    ${ue_index}    IN    @{CB008126_8234_ue_index}
        Check UE device status with adb recover    ue_index=${ue_index}
        UE attach with wireshark captured
        ...    filename=${UE_ATTACH_WIRESHARK}[${ue_index}]
        ...    ue_type=${UES_TYPE}[${ue_index}]
        ...    ue_index=${ue_index}
        ...    is_new_prepare_ue=${is_new_Qcom_ue_type}[${ue_index}]
    END
    Start only DL traffic and check tput common ue
    ...    ue_index=${2}    ue_type=${UES_TYPE}[2]    dl_throughput=${Send_Tput_DL_8126_8234}    cellid=${4}    gnb_index=${0}
    ...    direction=DL    tput_dl_cell=${expected_tput_dl_8126_8234}    dl_port=${TRAFFIC_DL_PORT}    duration=${7200}
    Start only UL traffic and check tput common ue
    ...    ue_index=${2}    cellid=${4}    ue_type=${UES_TYPE}[2]    gnb_index=${0}
    ...    tput_ul_cell=${expected_tput_ul_8126_8234}    ul_throughput=${Send_Tput_UL_8126_8234}    duration=${7200}
    ...    ul_port=${TRAFFIC_UL_PORT}
    Prepare with PM counter time to caculate    period=start
    modify sessionAmbr value via SRN soap command
    ...    filename_modified=${MODIFY_SESSION_AMBR_VALUE_WIRESHARK}
    ...    filename_initial=${MODIFY_SESSION_AMBR_INITIAL_VALUE_WIRESHARK}
    Prepare with PM counter time to caculate    period=end
    Comment    get counters and compare with last time
    Sleep    1m
    ${release_info}=    Get completed release
    ${time}=    Get Time    year month day hour min sec
    ${time_string}=    Evaluate    "_".join(${time})
    ${build_time}=    Catenate    ${release_info}_${time_string}
    get and write kpis to excel file    KPI_file=CB008126_CB008234_kpis.yml    para_index=${3}    target_sheet=CB008126
    ...    build_and_time=${build_time}    excel_file=${EXCEL_KPI_FILE_NAME}
    compare kpi result with last time    target_sheet=CB008126
    [Teardown]    Run Keywords
    ...    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    get gnb snapshot
    ...    AND    Run Keyword And Ignore Error    Power_ue.Prepare UE    ue_type=${tl.ues[2].capabilities[2]}    ue_index=${2}
    ...    AND    Stop DL or UL traffic common ue    ue_index=${2}    ue_type=${UES_TYPE}[2]    direction=DL
    ...    AND    Stop DL or UL traffic common ue    ue_index=${2}    ue_type=${UES_TYPE}[2]    direction=UL
    ...    AND    UE.UE Detach    ue_type=${UES_TYPE}[2]    ue_index=${2}
    ...    AND    paras change on BTS
    ...    paras=${PARAMETERS_RECOVER_CB008126_CB008234_QoS_Flow_Modification_CB008234_UE_AMBR_SA}
    ...    delta_file_name=${epc_log_path}${PARAMETERS_RECOVER_CB008126_CB008234_JSON_FILE}
    ...    AND    get and check operationalState of required cells
    ...    cells=${cells_QoS_Flow_Modification_CB008234_UE_AMBR_SA}
    ...    states=${cells_QoS_Flow_Modification_CB008234_UE_AMBR_SA_states_enabled}
    ...    AND    Set the attenuation value of ports simultaneously
    ...    att_ports=${RU_PA_info}[4][ports]
    ...    values=${RECOVER_PA_MAX_VALUE}
    ...    att_ipaddr=${RU_PA_info}[4][att_ipaddr]
    ...    AND    Common Case Teardown For Explore


*** Keywords ***
CB008236_adjust_pa_to_trigger
    [Arguments]    ${filename}
    Start capture gNB log on master    filename=${filename}
    ${end_value}=    Evaluate    list(set(${PARAMETERS_CB008236_PA_TARGET_VALUE}))[0]
    ${initial_value}=    Evaluate    list(set(${PARAMETERS_CB008236_PA_INITIAL_VALUE}))[0]
    FOR    ${i}    IN RANGE    ${initial_value}    ${end_value} + ${PARAMETERS_CB008236_PA_STEP}    ${PARAMETERS_CB008236_PA_STEP}
        ${set_values}=    Evaluate    [${i}] * len(${PARAMETERS_CB008236_PA_INITIAL_VALUE})
        Set the attenuation value of ports simultaneously
        ...    att_ports=${RU_PA_info}[0][ports]
        ...    values=${set_values}
        ...    att_ipaddr=${RU_PA_info}[0][att_ipaddr]
        Sleep    1s
    END
    FOR    ${j}    IN RANGE    ${end_value}    ${initial_value} - ${PARAMETERS_CB008236_PA_STEP}    -${PARAMETERS_CB008236_PA_STEP}
        ${recover_set_values}=    Evaluate    [${j}] * len(${PARAMETERS_CB008236_PA_TARGET_VALUE})
        Set the attenuation value of ports simultaneously
        ...    att_ports=${RU_PA_info}[0][ports]
        ...    values=${recover_set_values}
        ...    att_ipaddr=${RU_PA_info}[0][att_ipaddr]
        Sleep    1s
    END
    [Teardown]    Stop and download Logs on gNB on master    filename=${filename}
