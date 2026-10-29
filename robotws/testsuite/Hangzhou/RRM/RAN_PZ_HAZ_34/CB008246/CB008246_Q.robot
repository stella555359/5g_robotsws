*** Settings ***
Documentation
...    author: Shi Ming
...    contact: ming.shi@nokia-sbell.com
...    squal group: SG03
...    feature: CB008246-Q

Force Tags  CA_5G_RRM
...    PY36
Suite Setup    Run Keywords
...             robot_common_operations.Common Suite Setup
...             AND    Common Suite Setup for COAM
...             AND    Get gnb release info
...             AND    Run Keyword If    '${release_info}' == 'SBTS24R3_ENB_0000'
...                    Common Case TestLine Setup    is_commission=True    scf_path=${scf_path}    golden_scf_name=${specious_scf}
...                    ELSE    Common Case TestLine Setup
...                            is_commission=True    scf_path=${scf_path}    golden_scf_name=${tl_scf_${release_info}_specious}
...             AND    Common UE parameter setup

Suite Teardown     Common Suite Teardown for COAM    gnb_list=${gnb_list}

Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008246/Resources/CB008246_common_keywords.robot

*** Variables ***
${log_name_Q_002_1}    log_name_Q_002_1.pcap
${log_name_Q_002_2}    log_name_Q_002_2.pcap
${log_name_Q_002_3}    log_name_Q_002_3.pcap
${expected_tput_dl}    300
${Send_Tput_DL}        600M
${expected_tput_ul}    90
${Send_Tput_UL}        200M
@{expected_value_D001_gnb1}    ${1}    ${1}    ${7}    ${1}    ${7}
@{Counter_D001}    ${0}
${kpis_templates_id}    1040    # CB008246-Q_Counter&KPI
${tool_path}    /opt/workspace/Tool
${specious_scf}    Configuration_scf_GNB1_CB008246_Q.xml
${tl_scf_SBTS25R2_ENB_9999_specious}    25R1_Configuration_scf_GNB1_CB008246_specious.xml
${tl_scf_SBTS25R1_ENB_0000_specious}    25R1_Configuration_scf_GNB1_CB008246_specious.xml

${l2stream3_ttitrace_Q002_1}    l2stream3_ttitrace_Q002_1

*** Test Cases ***
[1]CB008246-Q_002_Link_adaptation_for_High_reliability_DRB_feature_interworking_with_RRC_INACTIVE_state_transition
    [Documentation]    CB008246-Q
    [Tags]    CB008246-Q    CRT_TRUNK
    [Timeout]    2 hour
    [Setup]
    Q002 Prerequisite
    Q002 Step 1 UE2 attach and trigger ue inactive
    Q002 Step 2 UE2 make DL traffic
    Q002 Step 3 UE2 make UL traffic
    Q002 Step 4 check TTI and HR KPI
    [Teardown]    Q002 Teardown

*** Keywords ***
Q002 Prerequisite
    comment    Q002 Prerequisite: 5QI7 HR, srbInactivityTimerSA and drbInactivityTimerSA set 10s
    robot_common_operations.Common Case Setup
#    Online modify parmeters     parameters_to_update=${PARAM_8246_gnb1_Q_002}    skip_parameter_relation_errors=False
    Online modify parmeters     parameters_to_update=${PARAM_8246_gnb1_Q_002}    skip_parameter_relation_errors=True
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    Power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${2}
    Switch QCOM APN to muti DRB    ue_index=${2}    ue_type=${ue_type}    apn_name=${wap2_apn_name}

Q002 Step 1 UE2 attach and trigger ue inactive
    comment    Step1: UE2 attach on gnb1 cell2
    Prepare with PM counter time to caculate    period=start
    Start capture gNB log on master    filename=${log_name_Q_002_1}
    Attach and check power UE    ue_type=${ue_type}    ue_index=${2}    gnb_index=${0}
    [Teardown]    run keywords
    ...    sleep    1m    reason=wait for ue into inactive status
    ...    AND    Stop and download Logs on gNB on master    filename=${log_name_Q_002_1}
    ...    AND    Prepare with PM counter time to caculate    period=end
    ...    AND    sleep    1m    reason=wait xml report generated
    ...    AND    Check wireshark log for 8246_Q002_1
    ...    AND    check into idle status on wireshark    logname=${log_name_Q_002_1}
    ...    AND    check counters of related inactive status from pm file    KPI_file=CB008246_Q_inactive_related_KPI.txt    para_index=${2}

#Q002 Step 2 trigger UE2 to inactive status
#    comment    Step2: set UE2 data to inactive status
#    Prepare with PM counter time to caculate    period=start
#    Start capture gNB log on master    filename=${log_name_Q_002_2}
#    sleep    1m    reason=trigger ue inactive, and wait for ue into inactive status
##    Setup data status on UE    ue_index=${2}    status=disable
##    sleep    10s    reason=wait for ue into inactive status
#    [Teardown]    run keywords
#    ...    Stop and download Logs on gNB on master    filename=${log_name_Q_002_2}
#    ...    AND    Prepare with PM counter time to caculate    period=end
#    ...    AND    sleep    1m    reason=wait xml report generated
#    ...    AND    check into idle status on wireshark    logname=${log_name_Q_002_2}
#    ...    AND    check counters of related inactive status from pm file    KPI_file=CB008246_Q_inactive_related_KPI.txt    para_index=${2}

Q002 Step 2 UE2 make DL traffic
    comment    step3: make DL traffic 5QI7
    Prepare with PM counter time to caculate    period=start
    Start capture gNB log on master    filename=${log_name_Q_002_2}
    Start only DL traffic and check tput    ue_index=${2}    cellid=${2}    ue_type=${ue_type}    gnb_index=${0}
    ...                                tput_dl_cell=${expected_tput_dl}    dl_throughput=${Send_Tput_DL}    duration=${7200}
    [Teardown]    run keywords
    ...    Stop and download Logs on gNB on master    filename=${log_name_Q_002_2}
    ...    AND    Prepare with PM counter time to caculate    period=end
    ...    AND    sleep    1m    reason=wait xml report generated
    ...    AND    check rrc resume on wireshark    logname=${log_name_Q_002_2}
    ...    AND    check counters of related rrc resume of cell from pm file    KPI_file=CB008246_Q_resume_related_KPI.txt    para_index=${2}
    ...    AND    check counters of related rrc resume of bts from pm file    KPI_file=CB008246_Q_resume_related_KPI2.txt    para_index=${1}

Q002 Step 3 UE2 make UL traffic
    comment    step4: make ul traffic 5QI7
    Start only UL traffic and check tput    ue_index=${2}    cellid=${2}    ue_type=${ue_type}    gnb_index=${0}
    ...                                tput_ul_cell=${expected_tput_ul}    ul_throughput=${Send_Tput_UL}    duration=${7200}

Q002 Step 4 check TTI and HR KPI
    comment    step5: check TTI and DL UL HR KPI
    Prepare with PM counter time to caculate    period=start
    sleep    6min    reason=check KPIs after make traffic during 5mins and xml report generated 1min
    check HR traffic check dict KPI from pm file    KPI_file=CB008246_E_006_HR_KPI.txt    para_index=${2}
    Check D006 HR traffic check dict KPI from pm file    KPI_file=CB008246_D_006_HR_KPI.txt    para_index=${2}
##    upgrade gnb logs tool on VM    tool_download_path=${tool_path}
##    to capture logs via gnb_logs tool    option=-t    tool_download_path=${tool_path}    duration=5
#    to capture logs via gnb_logs tool    option=-C2 -T    tool_download_path=${tool_path}    duration=5
#    ${log_files}    ${folder_name}    get logs from gnb_logs folder    tool_download_path=${tool_path}
#    ${file_name}    get_required_tti_file_name    files_list=${log_files}
#    Run Keyword And Ignore Error    check value on TTI file Q002_1
#    ...    file_path=${epc_log_path}/${folder_name}/${file_name}    queried_filed=laMode    compare_data=HIGHRELIABILITY
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'
    ...    Capture Ttitrace tti from WEBUI    names=${l2stream3_ttitrace_Q002_1}    nr_phy_cell_ids=56
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[1]'
    ...    Capture Ttitrace tti from WEBUI    names=${l2stream3_ttitrace_Q002_1}    nr_phy_cell_ids=53
    Run Keyword And Ignore Error    check value on TTI file Q002_1
    ...    file_path=${epc_log_path}/${l2stream3_ttitrace_Q002_1}_ul.csv    queried_filed=ulFdSchedData.laMode    compare_data=HIGHRELIABILITY

Q002 Teardown
    robot_common_operations.Common Case Teardown
    put btslog_ini file to ute
    ...    server_ip=${appserver_addr}    server_username=${appserver_username}    server_password=${appserver_password}
    Start capture syslog via btslog on ute
    Stop DL or UL traffic    ue_index=${2}    ue_type=${ue_type}    direction=DL
    Stop DL or UL traffic    ue_index=${2}    ue_type=${ue_type}    direction=UL
    Stop capture syslog via btslog on ute
#    Setup data status on UE    ue_index=${2}    status=enable
    QCM UE Recover Detach    ue_index=${2}    status=${0}    ue_type=${ue_type}
    Adjust HBTE gNB_eNB_RU Attenuation
#    Online modify parmeters    parameters_to_update=${PARAM_8246_recover_gnb1_Q_002}    skip_parameter_relation_errors=False
    Online modify parmeters    parameters_to_update=${PARAM_8246_recover_gnb1_Q_002}    skip_parameter_relation_errors=True
    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
    Common Case TestLine Setup    is_commission=True    scf_path=${scf_path}    golden_scf_name=${tl_scf_${release_info}}
    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
    get and analysis syslog






check counters of related inactive status from pm file
    [Arguments]     ${KPI_file}    ${para_index}    ${index}=${0}
    ${dict_kpis_name_value}=    get dict kpi from pm file    KPI_file=${KPI_file}    para_index=${para_index}    index=${index}
    should be true    ${dict_kpis_name_value}[NG_FLOW_SUSP_RRC_CONN_INACTIVE]>=${1}

check counters of related rrc resume of cell from pm file
    [Arguments]     ${KPI_file}    ${para_index}    ${index}=${0}
    ${dict_kpis_name_value}=    get dict kpi from pm file    KPI_file=${KPI_file}    para_index=${para_index}    index=${index}
    check required KPI via pm file    KPI_name_list=${CB008246_Q_legacy_DL_traffic_check_kpi_names_larger_zero_cell}
    ...    check_field=larger_specified_value    dict_kpi_get=${dict_kpis_name_value}

check counters of related rrc resume of bts from pm file
    [Arguments]     ${KPI_file}    ${para_index}    ${index}=${0}
    ${dict_kpis_name_value}=    get dict kpi from pm file    KPI_file=${KPI_file}    para_index=${para_index}    index=${index}
    check required KPI via pm file    KPI_name_list=${CB008246_Q_legacy_DL_traffic_check_kpi_names_larger_zero_bts}
    ...    check_field=larger_specified_value    dict_kpi_get=${dict_kpis_name_value}

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

Check D006 HR traffic check dict KPI from pm file
    [Arguments]     ${KPI_file}    ${para_index}    ${index}=${0}
    ${dict_kpis_name_value}=    get dict kpi from pm file    KPI_file=${KPI_file}    para_index=${para_index}    index=${index}
    check required KPI via pm file    KPI_name_list=${CB008246_D_006_HR_traffic_check_kpi_names_value_zero}
    ...    check_field=equal_specified_value    dict_kpi_get=${dict_kpis_name_value}
    check required KPI via pm file    KPI_name_list=${CB008246_D_006_HR_traffic_check_kpi_names_larger_zero}
    ...    check_field=larger_specified_value    dict_kpi_get=${dict_kpis_name_value}
    check required KPI via pm file    KPI_name_list=${CB008246_D_006_HR_traffic_check_kpi_names_less_specified_value}
    ...    check_field=less_specified_value    dict_kpi_get=${dict_kpis_name_value}    less_specfied=${0.011}
    check required KPI via pm file    KPI_name_list=${CB008246_D_006_HR_traffic_check_kpi_names_greater_than_or_equal_specfied}
    ...    check_field=greater_than_or_equal_specified_value    dict_kpi_get=${dict_kpis_name_value}    greater_than_or_equal_specfied=${0}

Check wireshark log for 8246_Q002_1
    Check UL_UE_MCS_table_Capbility    logname=${log_name_Q_002_1}

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

Setup data status on UE
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${status}=enable
    Connect to control pc via cygwin    ue_index=${ue_index}    alias=cygwin${ue_index}
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell svc data ${status}    connection=cygwin${ue_index}
    sleep   2s
    [Teardown]    csn.disconnect      connection=cygwin${ue_index}

check into idle status on wireshark
    [Arguments]    ${logname}
    ${all_packets}=    load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}    alias=test6
#    ${Code42_0} =    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 42
#    Log To Console    check UEContextReleaseRequest
#    ${filtered_packets}=    filter_packets_by_expression
#    ...    filter_expression=${Code42_0}    pcap_parser=test6
#    ${ngap_radioNetwork}=    get_field_value_by_xpath    xpath=.//ngap.radioNetwork    pcap_parser=test6
#    Should Contain    ${ngap_radioNetwork}    20
#    ${Code41_0} =    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 41
#    Log To Console    check UEContextReleaseCommand
#    ${filtered_packets}=    filter_packets_by_expression
#    ...    filter_expression=${Code41_0}    pcap_parser=test6
#    ${ngap_radioNetwork}=    get_field_value_by_xpath    xpath=.//ngap.radioNetwork    pcap_parser=test6
#    Should Contain    ${ngap_radioNetwork}    20
#    ${count_user_inactivity}=    Get Count    ${ngap_radioNetwork}    20
#    Should Be True    ${count_user_inactivity} >= 1
    ${BCIN_filter}    catenate    (e1ap.E1AP_PDU == 0) && (e1ap.procedureCode == 13)
    ${BCIN_packets}=    filter_packets_by_expression    filter_expression=${BCIN_filter}    pcap_parser=test6
    ${uE_Activity}=    get_field_value_by_xpath    xpath=.//e1ap.uE_Activity    pcap_parser=test6
    should contain    ${uE_Activity}    1

check rrc resume on wireshark
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}
    # InitialULRRCMessageTransfer, RRC Resume Request 1
    ${reusme_request_1_filter}    catenate    ((f1ap.F1AP_PDU == 0)) && (nr-rrc.resumeIdentity)
    ${reusme_request_1_packets}    cap.filter_packets_by_expression    filter_expression=${reusme_request_1_filter}
    ${procedureCode}=    cap.Get Field Value By Xpath    pdml_list=${reusme_request_1_packets}
    ...                                                xpath=.//f1ap.procedureCode
#    Should Be Equal    ${procedureCode}[0]    11
    # DLRRCMessageTransfer, RRC Resume
    ${RRC_Resume_filter}    catenate    ((f1ap.F1AP_PDU == 0) && (f1ap.procedureCode == 12)) && (nr-rrc.mcs_Table == 1)
    ${RRC_Resume_packets}    cap.filter_packets_by_expression    filter_expression=${RRC_Resume_filter}
    ${mcs_Table}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Resume_packets}
    ...                                                xpath=.//nr-rrc.mcs_Table
    FOR    ${i}    IN    @{mcs_Table}
        should be equal    ${i}    1
    END
    ${betaOffsetACK_Index1}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Resume_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetACK_Index1
    ${betaOffsetACK_Index2}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Resume_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetACK_Index2
    ${betaOffsetACK_Index3}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Resume_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetACK_Index3
    ${betaOffsetCSI_Part1_Index1}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Resume_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetCSI_Part1_Index1
    ${betaOffsetCSI_Part1_Index2}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Resume_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetCSI_Part1_Index2
    Should Be Equal    ${betaOffsetACK_Index1}[0]    9
    Should Be Equal    ${betaOffsetACK_Index2}[0]    6
    Should Be Equal    ${betaOffsetACK_Index3}[0]    3
    Should Be Equal    ${betaOffsetCSI_Part1_Index1}[0]    11
    Should Be Equal    ${betaOffsetCSI_Part1_Index2}[0]    6


get_required_tti_file_name
    [Arguments]    ${files_list}    ${required_file_name}=dl__all.csv
    FOR    ${file}    IN    @{files_list}
        ${status}    run keyword and return status    should contain    ${file}    ${required_file_name}
        exit for loop if    '${status}' == 'True'
        set test variable    ${file}
    END
    [Return]    ${file}

check value on TTI file
    [Arguments]    ${file_name}
    ${col_br_BLER}    ${col_br_MCS}    get_BR_BLER_MCS_value    csv_file=${file_name}
    ...    filter_name1=laMode
    ...    filter_name2=targetBLER
    ...    filter_name3=isDefaultMcsProposed
    ...    filter_name4=${SA_UE_RNTI_ID}
    ...    filter_name5=rnti
#    FOR  ${i}    IN    @{col_br_BLER}
#        should contain       ${${i}}    ${${0.15}}
#    END
    should contain       ${col_br_BLER}    0.15
    FOR  ${i}    IN    @{col_br_MCS}
        should be equal      ${${i}}    ${${0.0}}
    END

check value on TTI file Q002_1
    [Arguments]    ${file_path}    ${queried_filed}    ${compare_data}=BASICRELIABILITY
    ${required_data_list}=    get_value_from_csv_file    file_path=${file_path}    queried_filed=${queried_filed}
    ${no_duplicates_required_data_list}    Remove Duplicates    ${required_data_list}
    ${length}    Get Length    ${no_duplicates_required_data_list}
    should be equal    ${no_duplicates_required_data_list}[0]    ${compare_data}
    Should Be Equal As Integers    ${length}    1
