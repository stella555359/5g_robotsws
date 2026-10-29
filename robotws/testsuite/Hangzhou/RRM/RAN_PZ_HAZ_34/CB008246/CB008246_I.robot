*** Settings ***
Documentation
...    author: Shi Ming
...    contact: ming.shi@nokia-sbell.com
...    squal group: SG03
...    feature: CB008246-I

Force Tags  CA_5G_RRM
...    PY36
Suite Setup    Run Keywords
...             robot_common_operations.Common Suite Setup
...             AND    Common Suite Setup for COAM
...             AND    Get gnb release info
...             AND    Common UE parameter setup

Suite Teardown     Common Suite Teardown for COAM    gnb_list=${gnb_list}

Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008246/Resources/CB008246_common_keywords.robot

*** Variables ***
${log_name_I_007_1}    log_name_I_007_1.pcap
${log_name_I_007_2}    log_name_I_007_2.pcap
${log_name_I_007_3}    log_name_I_007_3.pcap
${log_name_I_006_1}    log_name_I_006_1.pcap
${expected_tput_dl}    300
${Send_Tput_DL}        600M
${expected_tput_ul_HW_I006}    1
${Send_Tput_UL}        200M
${expected_tput_ul}    1
${Send_Tput_UL_I006}        200M
@{expected_value_D001_gnb1}    ${1}    ${1}    ${7}    ${1}    ${7}
@{Counter_D001}    ${0}
${kpis_templates_id}    1040    # CB008246-E_Counter&KPI
${mdrb2_apn}    164 1670
${wap2_apn}    164 882

${specious_scf}    Configuration_scf_GNB1_CB008246_Q.xml
${tl_scf_SBTS25R1_ENB_9999_specious}    25R1_Configuration_scf_GNB1_CB008246_specious.xml

*** Test Cases ***
[1]CB008246-I_007_PM_Counters_with_multiple_non-GBR_High_Reliability_DRBs_in_UL_TDD_CPRI_static_PDCCH_without_ul-64QAM-MCS-TableAlt
    [Documentation]    CB008246-I
    [Tags]    CB008246-I    CRT_TRUNK
    [Timeout]    2 hour
    [Setup]
    I007 Prerequisite
    I007 Step 1 UE0 change APN and attach
    I007 Step 2 check HR and BR with GBR 5QI-7
    I007 Step 3 check HR and BR with GBR 5QI-3
    [Teardown]    I007 Teardown

[1]CB008246_I_06_FR1_SA_TDD_Scheduling_5G_UE_with_multiple_nonGBR_HR_DRBs_in_UL_via_PDU_Online_Change_dllaMcsMax64qam_param
    [Documentation]    CB008246-I
    [Tags]    CB008246-I    CRT_TRUNK    CRT_24R1
    [Timeout]    2 hour
    [Setup]
    I006 Prerequisite
    I006 Step 1 UE1 attach
    I006 Step 2 UE1 start traffic UL
    I006 Step 3 check HR and DL MCS online
    I006 Step 4 check HR and UL MCS online
    [Teardown]    I006 Teardown

*** Keywords ***
Analysis tti for I006_1
    [Arguments]    ${names}
    log to console    analysis tti file for I006_1 from Case_Logs file...
    ${ulFdSchedData_laMode}    get_ulFdSchedData_laMode_value    csv_file=${epc_log_path}/${names}_ul.csv
    ...    filter_name1=rnti     filter_name2=ulFdSchedData.laMode    filter_name3=${SA_UE_RNTI_ID}
    FOR  ${i}    IN    @{ulFdSchedData_laMode}
        should be equal      ${i}    HIGHRELIABILITY
    END
    ${ulFdSchedData_rrmUlProposedMcs}    get_ulFdSchedData_rrmUlProposedMcs_value    csv_file=${epc_log_path}/${names}_ul.csv
    ...    filter_name1=rnti     filter_name2=ulFdSchedData.rrmUlProposedMcs   filter_name3=${SA_UE_RNTI_ID}
    FOR  ${i}    IN    @{ulFdSchedData_rrmUlProposedMcs}
        should be true      ${i}<=${${15.0}}
    END

Analysis tti for I006_2
    [Arguments]    ${names}
    log to console    analysis tti file for I006_2 from Case_Logs file...
    ${ulFdSchedData_laMode}    get_ulFdSchedData_laMode_value    csv_file=${epc_log_path}/${names}_ul.csv
    ...    filter_name1=rnti     filter_name2=ulFdSchedData.laMode    filter_name3=${SA_UE_RNTI_ID}
    FOR  ${i}    IN    @{ulFdSchedData_laMode}
        should be equal      ${i}    HIGHRELIABILITY
    END
    ${ulFdSchedData_rrmUlProposedMcs}    get_ulFdSchedData_rrmUlProposedMcs_value    csv_file=${epc_log_path}/${names}_ul.csv
    ...    filter_name1=rnti     filter_name2=ulFdSchedData.rrmUlProposedMcs   filter_name3=${SA_UE_RNTI_ID}
    ${ulFdSchedData_rrmUlProposedMcs_greater_than_15}    Create list
    FOR  ${i}    IN    @{ulFdSchedData_rrmUlProposedMcs}
        run keyword if     ${i}>${${15.0}}
        ...    append to list     ${ulFdSchedData_rrmUlProposedMcs_greater_than_15}    ${i}
    END
    Should Not Be Empty    ${ulFdSchedData_rrmUlProposedMcs_greater_than_15}


I006 Step 3 check HR and DL MCS online
    Modify Parameters for Cases     gnb_index=${0}    Modify_Para_Online=${PARAM_8246_gnb1_I_006_2}
    ...    skip_parameter_relation_errors=False
    sleep    15s
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_1    nr_phy_cell_ids=56
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[1]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_1    nr_phy_cell_ids=53
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[2]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_1    nr_phy_cell_ids=60
#    Capture Ttitrace With Admin Mode and Convert format    names=l2stream3_ttitrace_1    nr_phy_cell_ids=53
    sleep    2s
    Analysis tti for I006_1    names=l2stream3_ttitrace_1


I006 Step 4 check HR and UL MCS online
    Modify Parameters for Cases     gnb_index=${0}    Modify_Para_Online=${PARAM_8246_gnb1_I_006_3}
    ...    skip_parameter_relation_errors=False
    sleep    15s
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_2    nr_phy_cell_ids=56
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[1]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_2    nr_phy_cell_ids=53
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[2]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_2    nr_phy_cell_ids=60
#    Capture Ttitrace With Admin Mode and Convert format    names=l2stream3_ttitrace_2    nr_phy_cell_ids=53
    sleep    2s
    Analysis tti for I006_2    names=l2stream3_ttitrace_2

I006 Step 2 UE1 start traffic UL
    Start only UL traffic and check tput    ue_index=${0}    cellid=${2}    ue_type=${tl.ues[0].capabilities[2]}    gnb_index=${0}
    ...                                tput_ul_cell=${expected_tput_ul}    ul_throughput=${Send_Tput_UL}    duration=${7200}
    ...                                ul_port=${tl.ues[0].iperf_details.port}    iperf_type=via_app

I006 Step 1 UE1 attach
    Comment    UE1 attach on gnb1 cell2
    Start capture gNB log on master    filename=${log_name_I_006_1}
    Power_ue.Prepare UE    ue_type=${tl.ues[0].capabilities[2]}    ue_index=${0}
    Attach and check power UE    ue_type=${tl.ues[0].capabilities[2]}    ue_index=${0}    gnb_index=${0}
    Sleep    30s
    [Teardown]    run keywords
    ...    Stop and download Logs on gNB on master    filename=${log_name_I_006_1}
    ...    AND    Check wireshark log for 8246_I006_1    logname=${log_name_I_006_1}

Check wireshark log for 8246_I006_1
    [Arguments]    ${logname}
    Check wireshark log for 8246_I_UE_RNTI_ID    logname=${logname}

Check wireshark log for 8246_I_UE_RNTI_ID
    [Arguments]    ${logname}
    ${UE_RNTI_ID}=    Get RNTI-ID message    logname=${logname}
    Set Suite Variable    ${SA_UE_RNTI_ID}    ${UE_RNTI_ID}

Get RNTI-ID message
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    ####InitialULRRCMessageTransfer, RRC Setup Request
    ${RRC_Setup_request}=     Catenate    (f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 11 and f1ap.C_RNTI)
    ${RRC_Setup_request_packets}=    cap.filter_packets_by_expression    filter_expression=${RRC_Setup_request}
    ${UE_RNTI_ID}=     cap.get_field_value_by_xpath    pdml_list=${RRC_Setup_request_packets}
    ...                                                xpath=.//f1ap.C_RNTI
    [Return]    ${UE_RNTI_ID}[0]

I006 Teardown
    robot_common_operations.Common Case Teardown
    QCM UE Recover Detach    ue_index=${0}    status=${0}    ue_type=${tl.ues[0].capabilities[2]}
    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
    Adjust HBTE gNB_eNB_RU Attenuation
    Modify Parameters for Cases    gnb_index=${0}    Modify_Para_Online=${PARAM_8246_recover_gnb1_I_006}
    Common Case TestLine Setup    is_commission=True    scf_path=${scf_path}    golden_scf_name=${tl_scf_${release_info}}
    Run Keyword And Ignore Error    CI_interface.Common Case Teardown







I006 Prerequisite
    robot_common_operations.Common Case Setup
    Run Keyword If    '${release_info}' == 'SBTS25R1_ENB_9999'
    ...    Common Case TestLine Setup    is_commission=True    scf_path=${scf_path}    golden_scf_name=${tl_scf_${release_info}_specious}
    ...    ELSE    Common Case TestLine Setup    is_commission=True    scf_path=${scf_path}    golden_scf_name=${specious_scf}
    Modify Parameters for Cases     gnb_index=${0}    Modify_Para_Online=${PARAM_8246_gnb1_I_006_1}
    ...    skip_parameter_relation_errors=False
    sleep    5s
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}

I007 Prerequisite
    Common Case TestLine Setup    is_commission=True    scf_path=${scf_path}    golden_scf_name=${tl_scf_${release_info}}
    robot_common_operations.Common Case Setup
    Online modify parmeters     parameters_to_update=${PARAM_8246_gnb1_I_007}    skip_parameter_relation_errors=False
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}

I007 Step 1 UE0 change APN and attach
    Comment    UE3 attach on gnb1 cell2
    Start capture gNB log on master    filename=${log_name_I_007_1}
    Power_ue.Prepare UE    ue_type=${tl.ues[0].capabilities[2]}    ue_index=${0}
    Comment    change APN to mdrb2.nokia.com
    set apn to change    usedapn=${mdrb2_apn}    ue_index=${0}
    Attach and check power UE    ue_type=${tl.ues[0].capabilities[2]}    ue_index=${0}    gnb_index=${0}
    [Teardown]    run keywords
    ...    Stop and download Logs on gNB on master    filename=${log_name_I_007_1}
    ...    AND    Check wireshark log for 8246_I007_1

I007 Step 2 check HR and BR with GBR 5QI-7
    check HR and BR with GBR 5QI-7

I007 Step 3 check HR and BR with GBR 5QI-3
    check HR and BR with GBR 5QI-3

I007 Teardown
    robot_common_operations.Common Case Teardown
    set apn to change    usedapn=${wap2_apn}    ue_index=${0}
    QCM UE Recover Detach    ue_index=${0}    status=${0}    ue_type=${tl.ues[0].capabilities[2]}
    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
    Adjust HBTE gNB_eNB_RU Attenuation
    Online delete parmeters    parameters_to_update=${PARAM_8246_recover_delete_gnb1_I_007}
    Online modify parmeters    parameters_to_update=${PARAM_8246_recover_gnb1_I_007}    skip_parameter_relation_errors=False
    Run Keyword And Ignore Error    CI_interface.Common Case Teardown







check if HR swtich to BR success
    [Arguments]    ${para_index}=${2}
    ${dict_HR_to_BR_check}=    get dict kpi from pm file   KPI_file=CB008246_I_007_KPI_switch_between_HR_and_BR_check.txt    para_index=${para_index}
    # PUSCH_INITX_LOWSE_BRDRB>0 and PUSCH_INITX_LOWSE_HRD_PRFL1+PUSCH_INITX_LOWSE_HRD_PRFL2=0 check swtich to BR
    ${status_0}=    Evaluate    ${dict_HR_to_BR_check}[PUSCH_INITX_64TBL_HRD_PRFL1] + ${dict_HR_to_BR_check}[PUSCH_INITX_64TBL_HRD_PRFL2]
    Should Be Equal    ${status_0}    ${0}
    ${status_1}=    Evaluate    ${dict_HR_to_BR_check}[PUSCH_INITX_64TBL_BR]>0
    Should Be Equal    ${status_1}    ${True}

check if BR swtich to HR success
    [Arguments]    ${para_index}=${2}
    ${dict_HR_to_BR_check}=    get dict kpi from pm file   KPI_file=CB008246_I_007_KPI_switch_between_HR_and_BR_check.txt    para_index=${para_index}
    # PUSCH_INITX_LOWSE_BRDRB=0 and PUSCH_INITX_LOWSE_HRD_PRFL1+PUSCH_INITX_LOWSE_HRD_PRFL2>0 check swtich to HR
    ${status_0}=    Evaluate    ${dict_HR_to_BR_check}[PUSCH_INITX_64TBL_HRD_PRFL1] + ${dict_HR_to_BR_check}[PUSCH_INITX_64TBL_HRD_PRFL2]
    Should Be True    ${status_0}>${0}
    ${status_1}=    Evaluate    ${dict_HR_to_BR_check}[PUSCH_INITX_64TBL_BR] == ${0}
    Should Be Equal    ${status_1}    ${True}

check KPI on pm file
    get kpi from per pm file

check HR traffic check dict KPI from pm file
    [Arguments]     ${KPI_file}    ${para_index}    ${index}=${0}
    ${dict_kpis_name_value}=    get dict kpi from pm file    KPI_file=${KPI_file}    para_index=${para_index}    index=${index}
    check required KPI via pm file    KPI_name_list=${CB008246_I_007_HR_traffic_check_kpi_names_value_zero}
    ...    check_field=equal_specified_value    dict_kpi_get=${dict_kpis_name_value}
    check required KPI via pm file    KPI_name_list=${CB008246_I_007_HR_traffic_check_kpi_names_larger_zero}
    ...    check_field=larger_specified_value    dict_kpi_get=${dict_kpis_name_value}
    check required KPI via pm file    KPI_name_list=${CB008246_I_007_HR_traffic_check_kpi_names_less_specified_value}
    ...    check_field=less_specified_value    dict_kpi_get=${dict_kpis_name_value}
    ${result_0}=    Evaluate
    ...    abs(${dict_kpis_name_value}[${I_007_HR_value_1}]+${dict_kpis_name_value}[${I_007_HR_value_2}]-${dict_kpis_name_value}[${I_007_HR_value_0}])
    Should Be True    ${result_0}<=${2}
    ${result_1}=    Evaluate
    ...    abs(${dict_kpis_name_value}[${I_007_HR_value_4}]+${dict_kpis_name_value}[${I_007_HR_value_5}]-${dict_kpis_name_value}[${I_007_HR_value_3}])
    Should Be True    ${result_1}<=${2}
    ${result_2_1}=    Evaluate    ${dict_kpis_name_value}[${I_007_HR_value_7}]-${dict_kpis_name_value}[${I_007_HR_value_8}]
    ${result_2_2}=    Evaluate    ${result_2_1}-${dict_kpis_name_value}[${I_007_HR_value_6}]
    Should Be True    ${-50}<${result_2_2}<${50}
    ${result_3}=    Evaluate    ${dict_kpis_name_value}[${I_007_HR_value_9}]+${dict_kpis_name_value}[${I_007_HR_value_10}]
    Should Be True    ${result_3}>${0}

check BR traffic check dict KPI from pm file
    [Arguments]     ${KPI_file}    ${para_index}    ${index}=${0}
    ${dict_kpis_name_value}=    get dict kpi from pm file    KPI_file=${KPI_file}    para_index=${para_index}    index=${index}
    check required KPI via pm file    KPI_name_list=${CB008246_I_007_BR_traffic_check_kpi_names_value_zero}
    ...    check_field=equal_specified_value    dict_kpi_get=${dict_kpis_name_value}
    check required KPI via pm file    KPI_name_list=${CB008246_I_007_BR_traffic_check_kpi_names_larger_zero}
    ...    check_field=larger_specified_value    dict_kpi_get=${dict_kpis_name_value}
    check required KPI via pm file    KPI_name_list=${CB008246_I_007_BR_traffic_check_kpi_names_less_specified_value}
    ...    check_field=less_specified_value    dict_kpi_get=${dict_kpis_name_value}    less_specfied=${0.11}
    ${result_0}=    Evaluate
    ...    abs(${dict_kpis_name_value}[${I_007_BR_value_1}]+${dict_kpis_name_value}[${I_007_BR_value_2}]-${dict_kpis_name_value}[${I_007_BR_value_0}])
    Should Be True    ${result_0}<=${2}
    ${result_1}=    Evaluate
    ...    abs(${dict_kpis_name_value}[${I_007_BR_value_4}]-${dict_kpis_name_value}[${I_007_BR_value_5}]-${dict_kpis_name_value}[${I_007_BR_value_3}])
#    Should Be True    ${result_1}<=${2}
    ${result_2}=    Evaluate    ${dict_kpis_name_value}[${I_007_BR_value_6}]+${dict_kpis_name_value}[${I_007_BR_value_7}]
    Should Be True    ${result_2}>${0}

Check wireshark log for 8246_I007_1
    Check UL_UE_MCS_table_Capbility without_ul-64QAM-MCS-TableAlt    logname=${log_name_I_007_1}

Check UL_UE_MCS_table_Capbility without_ul-64QAM-MCS-TableAlt
    [Arguments]    ${logname}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    alias=test6
    ${filter_expression}=     Catenate    f1ap.procedureCode == 12 and nr-rrc.uplinkBWP_ToAddModList == 1 and nr-rrc.mcs_Table == 1
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_mcs_Table}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.mcs_Table    pcap_parser=test6
#    Should Be Equal    ${nr_rrc_mcs_Table[1]}    1
    Should Not Contain    ${nr_rrc_mcs_Table}    1

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

check HR and BR with GBR 5QI-3
    Start only UL traffic and check tput    ue_index=${0}    cellid=${2}    ue_type=${tl.ues[0].capabilities[2]}    gnb_index=${0}
    ...                                tput_ul_cell=${expected_tput_ul}    ul_throughput=${Send_Tput_UL}    duration=${7200}
    ...                                ul_port=${tl.ues[0].iperf_details.ssh_connection_details.port}    iperf_type=via_app

    Prepare with PM counter time to caculate    period=start
    sleep    6min    reason=check KPIs after make traffic during 5mins and xml report generated 1min
    check HR traffic check dict KPI from pm file    KPI_file=CB008246_I_007_HR_KPI.txt    para_index=${2}

    Comment     gnb1 cell2 PA to 52db to trigger HR to BR
    Start capture gNB log on master    filename=${log_name_I_007_3}
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${55}
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${52}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${50}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${55}
    Prepare with PM counter time to caculate    period=start
    sleep    6min    reason=wait HR switch to BR completely and xml report generated
    Stop and download Logs on gNB on master    filename=${log_name_I_007_3}
    check if HR swtich to BR success
    check BR traffic check dict KPI from pm file    KPI_file=CB008246_I_007_BR_KPI.txt    para_index=${2}

    Comment     gnb1 cell2 PA to 0db to trigger BR to HR
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    Prepare with PM counter time to caculate    period=start
    sleep    6min    reason=wait BR switch to HR completely and xml report generated
    check if BR swtich to HR success
    check HR traffic check dict KPI from pm file    KPI_file=CB008246_I_007_HR_KPI.txt    para_index=${2}
    [Teardown]    run keywords
    ...    Stop DL or UL traffic    ue_index=${0}    ue_type=${tl.ues[0].capabilities[2]}    direction=UL
    ...    iperf_port=${tl.ues[0].iperf_details.ssh_connection_details.port}
    ...    AND    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_I_007_3}

check HR and BR with GBR 5QI-7
    Start only UL traffic and check tput    ue_index=${0}    cellid=${2}    ue_type=${tl.ues[0].capabilities[2]}    gnb_index=${0}
    ...                                tput_ul_cell=${expected_tput_ul}    ul_throughput=${Send_Tput_UL}    duration=${7200}
    ...                                ul_port=${tl.ues[0].iperf_details.port}    iperf_type=via_app

    Prepare with PM counter time to caculate    period=start
    sleep    6min    reason=check KPIs after make traffic during 5mins and xml report generated 1min
    check HR traffic check dict KPI from pm file    KPI_file=CB008246_I_007_HR_KPI.txt    para_index=${2}

    Comment     gnb1 cell2 PA to 52db to trigger HR to BR
    Start capture gNB log on master    filename=${log_name_I_007_2}
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${55}
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${52}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${50}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${55}
    Prepare with PM counter time to caculate    period=start
    sleep    6min    reason=wait HR switch to BR completely and xml report generated
    Stop and download Logs on gNB on master    filename=${log_name_I_007_2}
    check if HR swtich to BR success
    check BR traffic check dict KPI from pm file    KPI_file=CB008246_I_007_BR_KPI.txt    para_index=${2}

    Comment     gnb1 cell2 PA to 0db to trigger BR to HR
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    Prepare with PM counter time to caculate    period=start
    sleep    6min    reason=wait BR switch to HR completely and xml report generated
    check if BR swtich to HR success
    check HR traffic check dict KPI from pm file    KPI_file=CB008246_I_007_HR_KPI.txt    para_index=${2}
    [Teardown]    run keywords
    ...    Stop DL or UL traffic    ue_index=${0}    ue_type=${tl.ues[0].capabilities[2]}    direction=UL
    ...    iperf_port=${tl.ues[0].iperf_details.port}
    ...    AND    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_I_007_2}
