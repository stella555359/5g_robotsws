*** Settings ***
Documentation
...    author: Shi Ming
...    contact: ming.shi@nokia-sbell.com
...    squal group: SG03
...    feature: QoS Explore

Suite Setup    Common Suite Setup For Explore
Suite Teardown    Common Suite Teardown For Explore

Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/None_Feature_SG3/Qos_related_explore_testing/Recources/QoS_explore_common_keywords.robot
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/throughput/nrdim_throughput/interface.py    WITH NAME    nrdim_get_tput
Variables    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CNI158433/Resources/CNI158433_CB014330_variables.py

*** Variables ***
@{enb_id}    34821    38321
${enb_instance}     ${tl.enbs[0].instance_id}


*** Test Cases ***
[1]CNI158433_22_Traffic_Impact_and_Boundary_Conditions_for_parameter_modification_eg_pagingTargetRate_IWK_with_CB014330
    [Timeout]    2 hours
    [Setup]    Common Case Setup For Explore
    Online modify parmeters
    ...    parameters_to_update=${PARAM_CNI158433_CB014330_gnb1_pagingDciAggregation}
    ...    skip_parameter_relation_errors=False
    get and check operationalState of required cells
    ...    cells=${cells_CNI158433_CB014330}
    ...    states=${cells_CNI158433_CB014330_status}
    PA set required cell to needed value and set other cells to max value
    ...    index=${4}    values=${PARAMETERS_CNI158433_CB014330_PA_INITIAL_VALUE}
    Power_ue.Prepare UE    ue_type=${UES_TYPE}[0]    ue_index=${0}
    set apn to default dxdata2
    FOR    ${ue_index}    IN    @{CNI158433_CB014330_ue_index}
        Check UE device status with adb recover    ue_index=${ue_index}
        UE attach with wireshark captured
        ...    filename=${UE_ATTACH_WIRESHARK}[${ue_index}]
        ...    ue_type=${UES_TYPE}[${ue_index}]
        ...    ue_index=${ue_index}
        ...    is_new_prepare_ue=${is_new_Qcom_ue_type}[${ue_index}]
    END
    Start only DL traffic and check tput common ue
    ...    ue_index=${0}    ue_type=${UES_TYPE}[0]    dl_throughput=${CNI158433_CB014330_Send_Tput_DL_01}    cellid=${4}    gnb_index=${0}
    ...    direction=DL    tput_dl_cell=${expected_tput_dl}    dl_port=${TRAFFIC_DL_PORT_01}    duration=${7200}
    Start only UL traffic and check tput common ue
    ...    ue_index=${0}    cellid=${4}    ue_type=${UES_TYPE}[0]    gnb_index=${0}
    ...    tput_ul_cell=${expected_tput_ul}    ul_throughput=${CNI158433_CB014330_Send_Tput_UL_01}    duration=${7200}
    ...    ul_port=${TRAFFIC_UL_PORT_01}
    Start only DL traffic and check tput common ue
    ...    ue_index=${1}    ue_type=${UES_TYPE}[1]    dl_throughput=${CNI158433_CB014330_Send_Tput_DL_02}    cellid=${4}    gnb_index=${0}
    ...    direction=DL    tput_dl_cell=${expected_tput_dl}    dl_port=${TRAFFIC_DL_PORT_02}    duration=${7200}
    Start only UL traffic and check tput common ue
    ...    ue_index=${1}    cellid=${4}    ue_type=${UES_TYPE}[1]    gnb_index=${0}
    ...    tput_ul_cell=${expected_tput_ul}    ul_throughput=${CNI158433_CB014330_Send_Tput_UL_02}    duration=${7200}
    ...    ul_port=${TRAFFIC_UL_PORT_02}
    save scf to ute path    local_dir_path=${epc_log_path}    file_name=${TEST NAME}.xml
    IF    ${enb_instance} == ${enb_id}[0]
        ${dl_expected_throughput_cell}    ${ul_expected_throughput_cell}=    get_expect_throughput
        ...    tl_scf_dir_path=${epc_log_path}    tl_scf_file_name=${TEST NAME}.xml    cell_id=${700}
        ${dl_expected_throughput_cell_finally}    Evaluate    ${dl_expected_throughput_cell} * ${0.85}
    ELSE IF    ${enb_instance} == ${enb_id}[1]
        ${dl_expected_throughput_cell}    ${ul_expected_throughput_cell}=    get_expect_throughput
        ...    tl_scf_dir_path=${epc_log_path}    tl_scf_file_name=${TEST NAME}.xml    cell_id=${700}
        ${dl_expected_throughput_cell_finally}    Evaluate    ${dl_expected_throughput_cell} * ${0.45}
    END
    Set Test Variable    ${dl_expected_throughput_cell_modify}    ${dl_expected_throughput_cell_finally}
    Set Test Variable    ${ul_expected_throughput_cell_got}    ${ul_expected_throughput_cell}
    check TDD cell throughput    pcellid=${4}
    ...    tput_dl_pcell=${dl_expected_throughput_cell_modify}
    ...    tput_ul_pcell=${ul_expected_throughput_cell_got}
    ...    time=60s    ue_type=${UES_TYPE}[0]    ue_index=${0}
    check TDD cell throughput    pcellid=${4}
    ...    tput_dl_pcell=${dl_expected_throughput_cell_modify}
    ...    tput_ul_pcell=${ul_expected_throughput_cell_got}
    ...    time=60s    ue_type=${UES_TYPE}[1]    ue_index=${1}
    Power_ue.Prepare UE    ue_type=${UES_TYPE}[0]    ue_index=${0}
    Stop DL or UL traffic common ue    ue_index=${0}    ue_type=${UES_TYPE}[0]    direction=DL
    Stop DL or UL traffic common ue    ue_index=${0}    ue_type=${UES_TYPE}[0]    direction=UL
    UE.UE Detach     ue_type=${UES_TYPE}[0]     ue_index=${0}
    Online modify parmeters
    ...    parameters_to_update=${PARAM_CNI158433_CB014330_gnb1_idle}
    ...    skip_parameter_relation_errors=False
    # loop
    Online modify parmeters
    ...    parameters_to_update=${PARAM_CNI158433_CB014330_gnb1_MCS0_SF2}
    ...    skip_parameter_relation_errors=False
    Power_ue.Prepare UE    ue_type=${UES_TYPE}[0]    ue_index=${0}
    UE attach with wireshark captured
    ...    filename=${UE_ATTACH_WIRESHARK}[${0}]
    ...    ue_type=${UES_TYPE}[${0}]
    ...    ue_index=${0}
    ...    is_new_prepare_ue=${is_new_Qcom_ue_type}[${0}]
    Sleep    10s
    Start only DL traffic and check tput common ue
    ...    ue_index=${0}    ue_type=${UES_TYPE}[0]    dl_throughput=${CNI158433_CB014330_Send_Tput_DL_01}    cellid=${4}    gnb_index=${0}
    ...    direction=DL    tput_dl_cell=${expected_tput_dl}    dl_port=${TRAFFIC_DL_PORT_01}    duration=${7200}
    Start only UL traffic and check tput common ue
    ...    ue_index=${0}    cellid=${4}    ue_type=${UES_TYPE}[0]    gnb_index=${0}
    ...    tput_ul_cell=${expected_tput_ul}    ul_throughput=${CNI158433_CB014330_Send_Tput_UL_01}    duration=${7200}
    ...    ul_port=${TRAFFIC_UL_PORT_01}
    check TDD cell throughput    pcellid=${4}
    ...    tput_dl_pcell=${dl_expected_throughput_cell_modify}
    ...    tput_ul_pcell=${ul_expected_throughput_cell_got}
    ...    time=60s    ue_type=${UES_TYPE}[0]    ue_index=${0}
    check TDD cell throughput    pcellid=${4}
    ...    tput_dl_pcell=${dl_expected_throughput_cell_modify}
    ...    tput_ul_pcell=${ul_expected_throughput_cell_got}
    ...    time=60s    ue_type=${UES_TYPE}[1]    ue_index=${1}
    Stop DL or UL traffic common ue    ue_index=${0}    ue_type=${UES_TYPE}[0]    direction=DL
    Stop DL or UL traffic common ue    ue_index=${0}    ue_type=${UES_TYPE}[0]    direction=UL
    UE.UE Detach     ue_type=${UES_TYPE}[0]     ue_index=${0}
    # loop
    [Teardown]    Run Keywords
    ...    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    get gnb snapshot
    ...    AND    Power_ue.Prepare UE    ue_type=${UES_TYPE}[0]    ue_index=${0}
    ...    AND    Stop DL or UL traffic common ue    ue_index=${0}    ue_type=${UES_TYPE}[0]    direction=DL
    ...    AND    Stop DL or UL traffic common ue    ue_index=${0}    ue_type=${UES_TYPE}[0]    direction=UL
    ...    AND    UE.UE Detach     ue_type=${UES_TYPE}[0]     ue_index=${0}
    ...    AND    Run Keyword And Ignore Error    Power_ue.Prepare UE    ue_type=${UES_TYPE}[1]    ue_index=${1}
    ...    AND    Stop DL or UL traffic common ue    ue_index=${1}    ue_type=${UES_TYPE}[1]    direction=DL
    ...    AND    Stop DL or UL traffic common ue    ue_index=${1}    ue_type=${UES_TYPE}[1]    direction=UL
    ...    AND    UE.UE Detach    ue_type=${UES_TYPE}[1]    ue_index=${1}
    ...    AND    Online modify parmeters
    ...    parameters_to_update=${PARAM_CNI158433_CB014330_gnb1_RECOVER_pagingDciAggregation}
    ...    skip_parameter_relation_errors=False
    ...    AND    Set the attenuation value of ports simultaneously
    ...    att_ports=${RU_PA_info}[0][ports]
    ...    values=${RECOVER_PA_MAX_VALUE}
    ...    att_ipaddr=${RU_PA_info}[0][att_ipaddr]
    ...    AND    Common Case Teardown For Explore

*** Keywords ***
get_expect_throughput
    [Arguments]    ${tl_scf_dir_path}    ${tl_scf_file_name}    ${cell_id}
    ${dl_expected_throughput}    ${ul_expected_throughput}=    nrdim_get_tput.Get Theoretical Throughput
    ...    scf_path=${tl_scf_dir_path}${tl_scf_file_name}    cell_id=${cell_id}
    [Return]    ${dl_expected_throughput}    ${ul_expected_throughput}

check TDD cell throughput
    [Arguments]    ${pcellid}=1
    ...    ${tput_dl_pcell}=NULL
    ...    ${tput_ul_pcell}=NULL
    ...    ${time}=30s    ${ue_type}=${ue_type}
    ...    ${ue_index}=${0}
    Check_throughput with TDD cell     tput_dl_pcell=${tput_dl_pcell}    tput_ul_pcell=${tput_ul_pcell}
    ...    pcellid=${pcellid}
    ...    duration=${time}
    ...    ue_type=${ue_type}    ue_index=${ue_index}

Check_throughput with TDD cell
    [Arguments]    ${tput_dl_pcell}=${expected_tput_dl_T}
    ...    ${tput_ul_pcell}=NULL    ${duration}=30s
    ...    ${pcellid}=1    ${ue_type}=${ue_type}
    ...    ${ue_index}=${0}
    ${nrcellid_pcell}    COAM Get nrcellid with lcrid    lcrid=${pcellid}    gnb_index=${0}
    ${nrcellid_pcell}    Create list  ${nrcellid_pcell}
#    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    ${tput_log}    power_ue.Collect Tput    duration=${duration}    ignore_time=0s    ue_type=${ue_type}    gnb_index=${0}
    run keyword If    '${tput_dl_pcell}'!='NULL'
    ...    power_ue.Check Tput    direction=DL    cells=${nrcellid_pcell}    log=${tput_log}    ue_type=${ue_type}
    ...    target_throughput=${tput_dl_pcell}
    run keyword If    '${tput_ul_pcell}'!='NULL'
    ...    Get average UL through and check    log=${tput_log}    list_of_cell_ids=${nrcellid_pcell}
    ...    tput_ul_pcell=${tput_ul_pcell}
#    Run Keyword And Continue On Failure    run keyword If    '${tput_ul_scell}'!='NULL'
#    ...    power_ue.Check Tput    direction=UL    cells=${nrcellid_scell}    log=${tput_log}[1]    ue_type=${ue_type}
#    ...    target_throughput=${tput_ul_scell}

Get average UL through and check
    [Arguments]    ${log}    ${list_of_cell_ids}    ${tput_ul_pcell}
    ${tput_result}    ${record}    aastp.get_aasyslog_throughput
    ...                            direction=ul    log=${log}    cells=${list_of_cell_ids}
    ${real_ul_tput}    set variable    ${tput_result[0]['average']}
    Run Keyword And Continue On Failure    Should Be True    ${real_ul_tput} > ${tput_ul_pcell}*0.3