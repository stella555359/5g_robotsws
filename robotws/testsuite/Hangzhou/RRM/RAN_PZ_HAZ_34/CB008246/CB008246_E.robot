*** Settings ***
Documentation
...    author: Shi Ming
...    contact: ming.shi@nokia-sbell.com
...    squal group: SG03
...    feature: CB008246-E

Force Tags  CA_5G_RRM
...    PY36
Suite Setup    Run Keywords
...             robot_common_operations.Common Suite Setup
...             AND    Common Suite Setup for COAM
...             AND    Get gnb release info
...             AND    Common Case TestLine Setup    is_commission=True    scf_path=${scf_path}    golden_scf_name=${tl_scf_${release_info}}
#...             AND    Setup for Env cell on-air for 2 gnb    is_commission_for_second_gnb=False
...             AND    Common UE parameter setup

Suite Teardown     Common Suite Teardown for COAM    gnb_list=${gnb_list}

Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008246/Resources/CB008246_common_keywords.robot

*** Variables ***
${log_name_E_006_1}    log_name_E_006_1.pcap
${log_name_E_008_1}    log_name_E_008_1.pcap
${expected_tput_dl}    300
${Send_Tput_DL}        600M
${expected_tput_ul}    90
${Send_Tput_UL}        200M
@{expected_value_D001_gnb1}    ${1}    ${1}    ${7}    ${1}    ${7}
@{Counter_D001}    ${0}
${kpis_templates_id}    1040    # CB008246-E_Counter&KPI

*** Test Cases ***
[1]CB008246-E_006_HRDRB_BRDRB_UL_initial_and_retransmission_counters_for_LowSE_MCS_table_PUSCH_Profile2_CPRI
    [Documentation]    CB008246-E
    [Tags]    CB008246-E    CRT_TRUNK
    [Timeout]    2 hour
    [Setup]
    E006 Prerequisite
    E006 Step 1 UE2 attach
    E006 Step 2 UE2 make traffic
    E006 Step 3 check HR KPI
    E006 Step 4 trigger HR to BR and check KPI
    E006 Step 5 trigger BR to HR and check KPI
    [Teardown]    E006 Teardown


[1]CB008246-E_008_New_PM_counters_for_PUSCH_tx_success_failure_with_LowSE_MCS_Table
    [Documentation]    CB008246-E
    [Tags]    CB008246-E    CRT_TRUNK
    [Timeout]    2 hour
    [Setup]
    E008 Prerequisite
    E008 Step 1 UE2 attach
    E008 Step 2 UE2 make traffic
    E008 Step 3 check HR KPI
    E008 Step 4 trigger HR to BR and check KPI
    E008 Step 5 trigger BR to HR and check KPI
    [Teardown]   E008 Teardown

*** Keywords ***
E006 Prerequisite
    robot_common_operations.Common Case Setup
    Online modify parmeters     parameters_to_update=${PARAM_8246_gnb1_E_006}    skip_parameter_relation_errors=False
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    Power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${2}
    Switch QCOM APN to muti DRB    ue_index=${2}    ue_type=${ue_type}    apn_name=${wap2_apn_name}

E006 Step 1 UE2 attach
    Comment    UE3 attach on gnb1 cell2
    Start capture gNB log on master    filename=${log_name_E_006_1}
    Attach and check power UE    ue_type=${ue_type}    ue_index=${2}    gnb_index=${0}
    [Teardown]    run keywords
    ...    Stop and download Logs on gNB on master    filename=${log_name_E_006_1}
    ...    AND    Check wireshark log for 8246_E006_1

E006 Step 2 UE2 make traffic
    Start only UL traffic and check tput    ue_index=${2}    cellid=${2}    ue_type=${ue_type}    gnb_index=${0}
    ...                                tput_ul_cell=${expected_tput_ul}    ul_throughput=${Send_Tput_UL}    duration=${7200}

E006 Step 3 check HR KPI
    Prepare with PM counter time to caculate    period=start
    sleep    6min    reason=check KPIs after make traffic during 5mins and xml report generated 1min
    check HR traffic check dict KPI from pm file    KPI_file=CB008246_E_006_HR_KPI.txt    para_index=${2}

E006 Step 4 trigger HR to BR and check KPI
    Comment     gnb1 cell2 PA to 53db to trigger HR to BR
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${55}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${47}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${55}
    Prepare with PM counter time to caculate    period=start
    sleep    6min    reason=wait HR switch to BR completely and xml report generated
    check if HR swtich to BR success
    check BR traffic check dict KPI from pm file    KPI_file=CB008246_E_006_BR_KPI.txt    para_index=${2}

E006 Step 5 trigger BR to HR and check KPI
    Comment     gnb1 cell2 PA to 0db to trigger BR to HR
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    Prepare with PM counter time to caculate    period=start
    sleep    6min    reason=wait BR switch to HR completely and xml report generated
    check if BR swtich to HR success
    check HR traffic check dict KPI from pm file    KPI_file=CB008246_E_006_HR_KPI.txt    para_index=${2}

E006 Teardown
    robot_common_operations.Common Case Teardown
    Stop DL or UL traffic    ue_index=${2}    ue_type=${ue_type}    direction=UL
    QCM UE Recover Detach    ue_index=${2}    status=${0}    ue_type=${ue_type}
    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
    Adjust HBTE gNB_eNB_RU Attenuation
    Online modify parmeters    parameters_to_update=${PARAM_8246_recover_gnb1_E_006}    skip_parameter_relation_errors=False
    Run Keyword And Ignore Error    CI_interface.Common Case Teardown





E008 Prerequisite
    robot_common_operations.Common Case Setup
    Online modify parmeters     parameters_to_update=${PARAM_8246_gnb1_E_008}    skip_parameter_relation_errors=False
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
    Power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${2}
    Switch QCOM APN to muti DRB    ue_index=${2}    ue_type=${ue_type}    apn_name=${wap2_apn_name}

E008 Step 1 UE2 attach
    Comment    UE3 attach on gnb1 cell1
    Start capture gNB log on master    filename=${log_name_E_008_1}
    Attach and check power UE    ue_type=${ue_type}    ue_index=${2}    gnb_index=${0}
    [Teardown]    run keywords
    ...    Stop and download Logs on gNB on master    filename=${log_name_E_008_1}
    ...    AND    Check wireshark log for 8246_E008_1

E008 Step 2 UE2 make traffic
    Start only UL traffic and check tput    ue_index=${2}    cellid=${1}    ue_type=${ue_type}    gnb_index=${0}
    ...                                tput_ul_cell=${expected_tput_ul}    ul_throughput=${Send_Tput_UL}    duration=${7200}

E008 Step 3 check HR KPI
    Prepare with PM counter time to caculate    period=start
    sleep    6min    reason=check KPIs after make traffic during 5mins and xml report generated 1min
    check HR traffic check dict KPI from pm file    KPI_file=CB008246_E_006_HR_KPI.txt    para_index=${1}

E008 Step 4 trigger HR to BR and check KPI
    Comment     gnb1 cell2 PA to 35db to trigger HR to BR
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${55}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${30}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${55}
    Prepare with PM counter time to caculate    period=start
    sleep    6min    reason=wait BR switch to HR completely and xml report generated
    check if HR swtich to BR success    para_index=${1}
    check BR traffic check dict KPI from pm file    KPI_file=CB008246_E_006_BR_KPI.txt    para_index=${1}

E008 Step 5 trigger BR to HR and check KPI
    Comment     gnb1 cell2 PA to 0db to trigger BR to HR
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
    Prepare with PM counter time to caculate    period=start
    sleep    6min    reason=wait BR switch to HR completely and xml report generated
    check if BR swtich to HR success    para_index=${1}
    check HR traffic check dict KPI from pm file    KPI_file=CB008246_E_006_HR_KPI.txt    para_index=${1}

E008 Teardown
    robot_common_operations.Common Case Teardown
    Stop DL or UL traffic    ue_index=${2}    ue_type=${ue_type}    direction=UL
    QCM UE Recover Detach    ue_index=${2}    status=${0}    ue_type=${ue_type}
    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
    Adjust HBTE gNB_eNB_RU Attenuation
    Online modify parmeters    parameters_to_update=${PARAM_8246_recover_gnb1_E_008}    skip_parameter_relation_errors=False
    Run Keyword And Ignore Error    CI_interface.Common Case Teardown







check if HR swtich to BR success
    [Arguments]    ${para_index}=${2}
    ${dict_HR_to_BR_check}=    get dict kpi from pm file   KPI_file=CB008246_E_006_KPI_HR_to_BR_check.txt    para_index=${para_index}
    # PUSCH_INITX_LOWSE_BRDRB>0 and PUSCH_INITX_LOWSE_HRD_PRFL1+PUSCH_INITX_LOWSE_HRD_PRFL2=0 check swtich to BR
    ${status_0}=    Evaluate    ${dict_HR_to_BR_check}[PUSCH_INITX_LOWSE_HRD_PRFL1] + ${dict_HR_to_BR_check}[PUSCH_INITX_LOWSE_HRD_PRFL2]
    Should Be Equal    ${status_0}    ${0}
    ${status_1}=    Evaluate    ${dict_HR_to_BR_check}[PUSCH_INITX_LOWSE_BRDRB]>0
    Should Be Equal    ${status_1}    ${True}

check if BR swtich to HR success
    [Arguments]    ${para_index}=${2}
    ${dict_HR_to_BR_check}=    get dict kpi from pm file   KPI_file=CB008246_E_006_KPI_BR_to_HR_check.txt    para_index=${para_index}
    # PUSCH_INITX_LOWSE_BRDRB=0 and PUSCH_INITX_LOWSE_HRD_PRFL1+PUSCH_INITX_LOWSE_HRD_PRFL2>0 check swtich to HR
    ${status_0}=    Evaluate    ${dict_HR_to_BR_check}[PUSCH_INITX_LOWSE_HRD_PRFL1] + ${dict_HR_to_BR_check}[PUSCH_INITX_LOWSE_HRD_PRFL2]
    Should Be True    ${status_0}>${0}
    ${status_1}=    Evaluate    ${dict_HR_to_BR_check}[PUSCH_INITX_LOWSE_BRDRB] == ${0}
    Should Be Equal    ${status_1}    ${True}

check KPI on pm file
    get kpi from per pm file

check HR traffic check dict KPI from pm file
    [Arguments]     ${KPI_file}    ${para_index}    ${index}=${0}
    ${dict_kpis_name_value}=    get dict kpi from pm file    KPI_file=${KPI_file}    para_index=${para_index}    index=${index}
    check required KPI via pm file    KPI_name_list=${CB008246_E_006_HR_traffic_check_kpi_names_value_zero}
    ...    check_field=equal_specified_value    dict_kpi_get=${dict_kpis_name_value}
    check required KPI via pm file    KPI_name_list=${CB008246_E_006_HR_traffic_check_kpi_names_larger_zero}
    ...    check_field=larger_specified_value    dict_kpi_get=${dict_kpis_name_value}
    check required KPI via pm file    KPI_name_list=${CB008246_E_006_HR_traffic_check_kpi_names_less_specified_value}
    ...    check_field=less_specified_value    dict_kpi_get=${dict_kpis_name_value}
    check required KPI via pm file    KPI_name_list=${CB008246_E_006_HR_traffic_check_kpi_names_less_specified_value2}
    ...    check_field=less_specified_value    dict_kpi_get=${dict_kpis_name_value}    less_specfied=${1000}
    ${result_0}=    Evaluate
    ...    abs(${dict_kpis_name_value}[${E_006_HR_value_1}]+${dict_kpis_name_value}[${E_006_HR_value_2}]-${dict_kpis_name_value}[${E_006_HR_value_0}])
    Should Be True    ${result_0}<=${2}
#    Should Be Equal    ${result_0}    ${dict_kpis_name_value}[${E_006_HR_value_0}]
    ${result_1}=    Evaluate
    ...    abs(${dict_kpis_name_value}[${E_006_HR_value_4}]+${dict_kpis_name_value}[${E_006_HR_value_5}]-${dict_kpis_name_value}[${E_006_HR_value_3}])
    Should Be True    ${result_1}<=${2}
#    Should Be Equal    ${result_1}    ${dict_kpis_name_value}[${E_006_HR_value_3}]
    ${result_2_1}=    Evaluate    ${dict_kpis_name_value}[${E_006_HR_value_6}]-${dict_kpis_name_value}[${E_006_HR_value_7}]
    ${result_2_2}=    Evaluate    ${result_2_1}-${dict_kpis_name_value}[${E_006_HR_value_8}]
    Should Be True    ${-50}<${result_2_2}<${50}
    ${result_3}=    Evaluate    ${dict_kpis_name_value}[${E_006_HR_value_9}]+${dict_kpis_name_value}[${E_006_HR_value_10}]
    Should Be True    ${result_3}>${0}
    ${result_4}=    Evaluate    ${dict_kpis_name_value}[${E_006_HR_value_11}]+${dict_kpis_name_value}[${E_006_HR_value_12}]
    Should Be True    ${result_4}>${0}
    ${result_5}=    Evaluate    ${dict_kpis_name_value}[${E_006_HR_value_13}]+${dict_kpis_name_value}[${E_006_HR_value_14}]
    Should Be True    ${result_5}>${0}

check BR traffic check dict KPI from pm file
    [Arguments]     ${KPI_file}    ${para_index}    ${index}=${0}
    ${dict_kpis_name_value}=    get dict kpi from pm file    KPI_file=${KPI_file}    para_index=${para_index}    index=${index}
    check required KPI via pm file    KPI_name_list=${CB008246_E_006_BR_traffic_check_kpi_names_value_zero}
    ...    check_field=equal_specified_value    dict_kpi_get=${dict_kpis_name_value}
    check required KPI via pm file    KPI_name_list=${CB008246_E_006_BR_traffic_check_kpi_names_larger_zero}
    ...    check_field=larger_specified_value    dict_kpi_get=${dict_kpis_name_value}
    check required KPI via pm file    KPI_name_list=${CB008246_E_006_BR_traffic_check_kpi_names_less_specified_value}
    ...    check_field=less_specified_value    dict_kpi_get=${dict_kpis_name_value}    less_specfied=${0.11}
    check required KPI via pm file    KPI_name_list=${CB008246_E_006_BR_traffic_check_kpi_names_less_specified_value2}
    ...    check_field=less_specified_value    dict_kpi_get=${dict_kpis_name_value}    less_specfied=${1000}
    ${result_0}=    Evaluate
    ...    abs(${dict_kpis_name_value}[${E_006_BR_value_1}]+${dict_kpis_name_value}[${E_006_BR_value_2}]-${dict_kpis_name_value}[${E_006_BR_value_0}])
#    Should Be Equal    ${result_0}    ${dict_kpis_name_value}[${E_006_BR_value_0}]
    Should Be True    ${result_0}<=${2}
    ${result_1}=    Evaluate
    ...    abs(${dict_kpis_name_value}[${E_006_BR_value_5}]+${dict_kpis_name_value}[${E_006_BR_value_3}]-${dict_kpis_name_value}[${E_006_BR_value_4}])
    Should Be True    ${result_1}<=${2}
#    Should Be Equal    ${result_1}    ${dict_kpis_name_value}[${E_006_BR_value_5}]
    ${result_2}=    Evaluate    ${dict_kpis_name_value}[${E_006_HR_value_6}]+${dict_kpis_name_value}[${E_006_HR_value_7}]
    Should Be True    ${result_2}>${0}
    ${result_3}=    Evaluate    ${dict_kpis_name_value}[${E_006_HR_value_8}]+${dict_kpis_name_value}[${E_006_HR_value_9}]
    Should Be True    ${result_3}>${0}
    ${result_4}=    Evaluate    ${dict_kpis_name_value}[${E_006_HR_value_10}]+${dict_kpis_name_value}[${E_006_HR_value_11}]
    Should Be True    ${result_4}>${0}

check KPI
    check KPI with required name    KPI_name_list=${CB008246_E_006_kpi_names_in_range}    check_field=in_range
    check KPI with required name    KPI_name_list=${CB008246_E_006_kpi_names_value_zero}    check_field=zero
    check KPI with required name    KPI_name_list=${CB008246_E_006_kpi_names_larger_zero}    check_field=larger_zero
    check if one of the counters has a value    KPI_name_list=${CB008246_E_006_kpi_names_one_value_1}
    check if one of the counters has a value    KPI_name_list=${CB008246_E_006_kpi_names_one_value_2}
    check if one of the counters has a value    KPI_name_list=${CB008246_E_006_kpi_names_one_value_3}
    check if one of the counters has a value    KPI_name_list=${CB008246_E_006_kpi_names_one_value_4}

Check wireshark log for 8246_E006_1
    Check UL_UE_MCS_table_Capbility    logname=${log_name_E_006_1}

Check wireshark log for 8246_E008_1
    Check UL_UE_MCS_table_Capbility    logname=${log_name_E_008_1}

Check UL_UE_MCS_table_Capbility
    [Arguments]    ${logname}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    alias=test6
    ${filter_expression}=     Catenate    f1ap.procedureCode == 12 and nr-rrc.uplinkBWP_ToAddModList == 1 and nr-rrc.mcs_Table == 1
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_mcs_Table}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.mcs_Table    pcap_parser=test6
    Should Be Equal    ${nr_rrc_mcs_Table[1]}    1

COAM Save snapshot
    get gnb snapshot    gnb_index=${0}
    get gnb snapshot    gnb_index=${1}

get gnb snapshot
    [Arguments]     ${gnb_index}=${0}
    Connect to gnb coam via ssl    gnb_index=${gnb_index}
#    COAM Download scf from cluster    scf_dir_path=${epc_log_path}
    COAM Save snapshot via rest api    log_path=${epc_log_path}
    [Teardown]    COAM Teardown gnb connections

Adjust HBTE gNB_eNB_RU Attenuation
    [Arguments]    ${gnb1_cell1_value}=${127}    ${gnb1_cell2_value}=${127}    ${gnb2_cell1_value}=${127}    ${enb_cell1_value}=${127}
    Adjust the tl HBTE attenuation value    #tl=@{diffTL_enb_ID}[0]
    ...    gnb1_cell1_value=${gnb1_cell1_value}    gnb1_cell2_value=${gnb1_cell2_value}
    ...    gnb2_cell1_value=${gnb2_cell1_value}    enb_cell1_value=${enb_cell1_value}

Adjust the tl HBTE attenuation value
    [Arguments]     ${gnb1_cell1_value}=${127}    ${gnb1_cell2_value}=${127}    ${gnb2_cell1_value}=${127}
    ...    ${enb_cell1_value}=${127}
    ####create cell list#####
    @{att_ports_gnb1_cell1}    Create List    ${att_port_1_HBTE}     ${att_port_2_HBTE}
    @{att_ports_gnb1_cell2}    Create List    ${att_port_3_HBTE}     ${att_port_4_HBTE}
    @{att_ports_gnb2_cell1}    Create List    ${att_port_5_HBTE}     ${att_port_6_HBTE}
    @{att_ports_enb_cell1}     Create List    ${att_port_7_HBTE}     ${att_port_8_HBTE}

    ###create value list####
    @{values_gnb1_cell1}    Create List    ${gnb1_cell1_value}    ${gnb1_cell1_value}    ${gnb1_cell1_value}    ${gnb1_cell1_value}
    @{values_gnb1_cell2}    Create List    ${gnb1_cell2_value}    ${gnb1_cell2_value}    ${gnb1_cell2_value}    ${gnb1_cell2_value}
    @{values_gnb2_cell1}    Create List    ${gnb2_cell1_value}    ${gnb2_cell1_value}    ${gnb2_cell1_value}    ${gnb2_cell1_value}
    @{values_enb_cell1}     Create List    ${enb_cell1_value}     ${enb_cell1_value}     ${enb_cell1_value}     ${enb_cell1_value}

    ###Adjust the HBTE attenuation value###
    Set the attenuation value    att_ports=${att_ports_gnb1_cell1}    values=${values_gnb1_cell1}
    ...    att_connection_port=${att_port_1_HBTE}    att_ipaddr=${att_ipaddr_HBTE}
    Set the attenuation value    att_ports=${att_ports_gnb1_cell2}    values=${values_gnb1_cell2}
    ...    att_connection_port=${att_port_1_HBTE}    att_ipaddr=${att_ipaddr_HBTE}
    Set the attenuation value    att_ports=${att_ports_gnb2_cell1}    values=${values_gnb2_cell1}
    ...    att_connection_port=${att_port_1_HBTE}    att_ipaddr=${att_ipaddr_HBTE}
    Set the attenuation value    att_ports=${att_ports_enb_cell1}     values=${values_enb_cell1}
    ...    att_connection_port=${att_port_1_HBTE}    att_ipaddr=${att_ipaddr_HBTE}
