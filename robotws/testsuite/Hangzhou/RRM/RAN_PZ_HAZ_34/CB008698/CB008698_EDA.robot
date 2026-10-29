*** Settings ***
Documentation
...    author: Shi Ming
...    contact: ming.shi@nokia-sbell.com
...    squal group: SG03
...    feature: CB008698 EDA

Suite Setup    Common Suite Setup For CB008698 EDA
Suite Teardown    Common Suite Teardown For CB008698 EDA

Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008698/Resources/CB008698_EDA_common_keywords.robot

*** Test Cases ***
[1]CB008698_ICS_failed_due_to_preemption_EDA_05272546
    [Documentation]
    ...    https://jiradc.ext.net.nokia.com/browse/RDI-33607
    ...    case1
    ...    1. Cell activation
    ...    2. UE1 setup successfully with one PDU session(contains two Qos Flows).
    ...    3. UE2 setup failed with one PDU session(contains one Qos Flow) and update EPmCounterId_5G_SGNB_SA_DU_RAC_REJ_DUE_RRC(M55139C00013)
    ...    case2
    ...    1. start gnb
    ...    2. SA UE1 ICS
    ...    3. SA UE2 ICS
    ...    4. UE1 is preempted.
    ...    5. SA UE3 ICS failed due to no preemption candidate
    ...    6. UE3 will be failed and update EPmCounterId_5G_SGNB_SA_DU_RAC_REJ_DUE_PUCCH(M55139C00010)
    [Tags]    EDA_05272546
    [Setup]    Common Case Setup For CB008698 EDA
    Case_1
    Case_2
    [Teardown]    Common Case Teardown For CB008698 EDA


*** Keywords ***
Case_1
    paras change on BTS
    ...    paras=${PARAMETERS_EDA_05272546}
    ...    delta_file_name=${epc_log_path}${PARAMETERS_EDA_05272546_JSON_FILE}
    Wait until keyword succeeds    2m    10s
    ...    get and check operationalState of required cells
    ...    cells=${cells_EDA_05272546}
    ...    states=${cells_EDA_05272546_states_enabled}
    PA set required cell to needed value and set other cells to max value
    ...    index=${0}    values=${PARAMETERS_EDA_05272546_PA_INITIAL_VALUE}
    Power_ue.Prepare UE    ue_type=${UES_TYPE}[0]    ue_index=${0}
    set apn to default dxdata2
    Prepare with PM counter time to caculate    period=start
    FOR    ${ue_index}    IN    @{EDA_05272546_ue_index_CASE_1}
        Check UE device status with adb recover    ue_index=${ue_index}
        UE attach with wireshark captured
        ...    filename=${UE_ATTACH_WIRESHARK}[${ue_index}]
        ...    ue_type=${UES_TYPE}[${ue_index}]
        ...    ue_index=${ue_index}
        ...    is_new_prepare_ue=${is_new_Qcom_ue_type}[${ue_index}]
    END
    Prepare with PM counter time to caculate    period=end
    Sleep    1m
    Check required counters as expected_values
    ...    counter_ids=${EDA_05272546_counter_ids_CASE_1}
    ...    dic_paths=${EDA_05272546_dic_paths}
    ...    expected_values=${EDA_05272546_expected_values}
    [Teardown]    Run Keywords
    ...    Run keyword if    '${KEYWORD STATUS}' == 'FAIL'    Run keyword and continue on failure    get gnb snapshot
    ...    AND    UEs detach case_1
    ...    AND    paras change on BTS
    ...    paras=${PARAMETERS_RECOVER_EDA_05272546}
    ...    delta_file_name=${epc_log_path}${PARAMETERS_RECOVER_EDA_05272546_JSON_FILE}
    ...    AND    Wait until keyword succeeds    2m    10s
    ...    get and check operationalState of required cells
    ...    cells=${cells_EDA_05272546}
    ...    states=${cells_EDA_05272546_states_enabled}
    ...    AND    Set the attenuation value of ports simultaneously
    ...    att_ports=${RU_PA_info}[0][ports]
    ...    values=${RECOVER_PA_MAX_VALUE}
    ...    att_ipaddr=${RU_PA_info}[0][att_ipaddr]

Case_2
    paras change on BTS
    ...    paras=${PARAMETERS_EDA_05272546_CASE_2}
    ...    delta_file_name=${epc_log_path}${PARAMETERS_EDA_05272546_CASE_2_JSON_FILE}
    Wait until keyword succeeds    2m    10s
    ...    get and check operationalState of required cells
    ...    cells=${cells_EDA_05272546}
    ...    states=${cells_EDA_05272546_states_enabled}
    PA set required cell to needed value and set other cells to max value
    ...    index=${0}    values=${PARAMETERS_EDA_05272546_PA_INITIAL_VALUE}
    Power_ue.Prepare UE    ue_type=${UES_TYPE}[0]    ue_index=${0}
    set apn to default dxdata2
    Prepare with PM counter time to caculate    period=start
    FOR    ${ue_index}    IN    @{EDA_05272546_ue_index_CASE_2}
        Check UE device status with adb recover    ue_index=${ue_index}
        UE attach with wireshark captured
        ...    filename=${UE_ATTACH_WIRESHARK}[${ue_index}]
        ...    ue_type=${UES_TYPE}[${ue_index}]
        ...    ue_index=${ue_index}
        ...    is_new_prepare_ue=${is_new_Qcom_ue_type}[${ue_index}]
    END
    Prepare with PM counter time to caculate    period=end
    Sleep    1m
    Check required counters as expected_values
    ...    counter_ids=${EDA_05272546_counter_ids_CASE_2}
    ...    dic_paths=${EDA_05272546_dic_paths}
    ...    expected_values=${EDA_05272546_expected_values}
    [Teardown]    Run Keywords
    ...    Run keyword if    '${KEYWORD STATUS}' == 'FAIL'    Run keyword and continue on failure    get gnb snapshot
    ...    AND    UEs detach case_2
    ...    AND    paras change on BTS
    ...    paras=${PARAMETERS_RECOVER_EDA_05272546_CASE_2}
    ...    delta_file_name=${epc_log_path}${PARAMETERS_RECOVER_EDA_05272546_CASE_2_JSON_FILE}
    ...    AND    Wait until keyword succeeds    2m    10s
    ...    get and check operationalState of required cells
    ...    cells=${cells_EDA_05272546}
    ...    states=${cells_EDA_05272546_states_enabled}
    ...    AND    Set the attenuation value of ports simultaneously
    ...    att_ports=${RU_PA_info}[0][ports]
    ...    values=${RECOVER_PA_MAX_VALUE}
    ...    att_ipaddr=${RU_PA_info}[0][att_ipaddr]
