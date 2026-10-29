*** Settings ***
Documentation
...    author: Shi Ming
...    contact: ming.shi@nokia-sbell.com
...    squal group: SG03
...    feature: CB008246-O

Force Tags  CA_5G_RRM
...    PY36
Suite Setup    Run Keywords
...                            robot_common_operations.Common Suite Setup
...                            AND    Common Suite Setup for COAM
...                            AND    Get gnb release info
...                            AND    Get sagnb version for selenium
...                            AND    Set Suite Variable    ${tl_gnb1_scf_${sw_version}}    ${sw_version}_gNB1_Golden_SCF.xml
...                            AND    Common Case TestLine Setup    is_commission=True    scf_path=${scf_path}
...                            golden_scf_name=${tl_gnb1_scf_${sw_version}}
...                            AND    Common UE parameter setup

Suite Teardown     Common Suite Teardown for COAM    gnb_list=${gnb_list}

Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008246/Resources/CB008246_common_keywords.robot

*** Variables ***
${log_name_O_004_1}    log_name_O_004_1.pcap
${log_name_O_004_2}    log_name_O_004_2.pcap
${log_name_O_001_1}    log_name_O_001_1.pcap
${log_name_O_001_2}    log_name_O_001_2.pcap
${log_name_O_001_3}    log_name_O_001_3.pcap
${expected_tput_dl}    300
${Send_Tput_DL}        600M
${expected_tput_ul}    90
${Send_Tput_UL}        200M
${R007_expected_tput_dl}    100
${R007_Send_Tput_DL}     600M
${expected_tput_dl_O004}    0
${Send_Tput_DL_O004}        1K
${expected_tput_ul_O004}    0
${Send_Tput_UL_O004}        1K
${Send_Tput_DL_O001}        1M
${expected_tput_dl_O001}    0.8
@{expected_value_D001_gnb1}    ${1}    ${1}    ${7}    ${1}    ${7}
@{Counter_D001}    ${0}
${kpis_templates_id}    1040    # CB008246-O_Counter&KPI
${tool_path}    /opt/workspace/Tool
@{allow_fault_list}    2923    2922

*** Test Cases ***
[1]CB008246_O_04_DLUL_MCS_downgrade_for_insufficient_buffer_separated_OLLA_for_ACK_enhancement_ulMcsDowngradeForHr_1
    [Documentation]    CB008246-O
    ...    1. Prerequisite: modify parameters
    ...    2. ue attach
    ...    3. make 1kb DL+UL traffic
    ...    4. keep 5mins
    ...    5. check MCS counters, calcualate avg value of MCS countes
    ...    6. detach ue
    ...    7. disable parameters dl/ulMcsDowngradeForHr
    ...    8. repeat step2 to step 5
    ...    9. compare avg value between dl/ulMcsDowngradeForHr enable and disable(enable larger than disable)
    ...    10. teardown
    [Tags]    CB008246-O    CRT_TRUNK    CRT_24R2
    [Timeout]    2 hour
    [Setup]
    O004 Prerequisite
    O004 Step 1 UE2 attach
    O004 Step 2 UE2 make traffic
    O004 Step 3 check HR MCS AVG KPI
    O004 Step 4 stop traffic and detach ue
    O004 Step 5 modify dlMcsDowngradeForHr and ulMcsDowngradeForHr to disabled
    O004 Step 6 repeat step 1 to step 2
    O004 Step 7 check HR MCS AVG KPI
    O004 Step 8 compare MCS AVG between parameter enabled and disabled
    [Teardown]    O004 Teardown


[1]CB008246_O_01_DL_MCS_downgrade_for_insufficient_buffer_separated_OLLA_for_ACK_enhancement
    [Documentation]    CB008246-O
    ...    compare KPI value for dlMcsDowngradeForHr(disabled>enhanced>enabled )
    [Tags]    CB008246-O    CRT_TRUNK    CRT_24R2
    [Timeout]    2 hour
    [Setup]
    O001 Prerequisite
    O001 Step 1 UE2 attach
    O001 Step 2 UE2 make traffic
    O001 Step 3 check HR MCS AVG KPI
    O001 Step 4 stop traffic and detach ue
    O001 Step 5 modify dlMcsDowngradeForHr to enabled
    O001 Step 6 repeat step 1 to step 2
    O001 Step 7 check HR MCS AVG KPI
    O001 Step 8 stop traffic and detach ue
    O001 Step 9 modify dlMcsDowngradeForHr to enhanced
    O001 Step 10 repeat step 1 to step 2
    O001 Step 11 check HR MCS AVG KPI
    O001 Step 12 compare MCS AVG between parameter disabled and enabled and enhanced
    [Teardown]    O001 Teardown

*** Keywords ***
O001 Prerequisite
    comment    O001 Prerequisite
    robot_common_operations.Common Case Setup
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    put btslog_ini file to ute
    ...    server_ip=${appserver_addr}    server_username=${appserver_username}    server_password=${appserver_password}
    Start capture syslog via btslog on ute
    Online modify parmeters     parameters_to_update=${PARAM_8246_gnb1_O_001}    skip_parameter_relation_errors=False
    Comment    modify RSRP Between -85db and -95db
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${28}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${28}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${28}
    Power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${2}

O001 Step 1 UE2 attach
    comment    Step1: UE2 attach on gnb1 cell2
    ue attach for steps    logname=${log_name_O_001_1}

O001 Step 2 UE2 make traffic
    comment    Step2: UE2 make traffic with DL
    Start only DL traffic and check tput    ue_index=${2}    cellid=${2}    ue_type=${ue_type}    gnb_index=${0}
    ...                                tput_dl_cell=${expected_tput_dl_O001}    dl_throughput=${Send_Tput_DL_O001}    duration=${7200}

O001 Step 3 check HR MCS AVG KPI
    comment    Step3: check HR dlMcsDowngradeForHr_disabled KPI
    Prepare with PM counter time to caculate    period=start
    sleep    6min    reason=check KPIs after make traffic during 5mins and xml report generated 1min

    ${dict_kpis_name_value}=    get dict kpi from pm file    KPI_file=CB008246_O_001_HR_KPI.txt    para_index=${2}
#    check required KPI via pm file    KPI_name_list=${CB008246_D_008_HR_traffic_check_kpi_names_larger_zero}
#    ...    check_field=larger_specified_value    dict_kpi_get=${dict_kpis_name_value}
    set test variable    ${dlMcsDowngradeForHr_disabled}    ${dict_kpis_name_value['1_PDSCH_INITX_LOWSE_MCS']}

O001 Step 4 stop traffic and detach ue
    Comment     Step4: stop traffic and detach ue
    Stop DL or UL traffic    ue_index=${2}    ue_type=${ue_type}    direction=DL
    QCM UE Recover Detach    ue_index=${2}    status=${0}    ue_type=${ue_type}

O001 Step 5 modify dlMcsDowngradeForHr to enabled
    Comment     Step5: modify dlMcsDowngradeForHr enabled
    Online modify parmeters     parameters_to_update=${PARAM_8246_gnb1_O_001_2}    skip_parameter_relation_errors=False

O001 Step 6 repeat step 1 to step 2
    ue attach for steps    logname=${log_name_O_001_2}
    O001 Step 2 UE2 make traffic

O001 Step 7 check HR MCS AVG KPI
    comment    Step7: check HR dlMcsDowngradeForHr_enabled KPI
    Prepare with PM counter time to caculate    period=start
    sleep    6min    reason=check KPIs after make traffic during 5mins and xml report generated 1min
    ${dict_kpis_name_value}=    get dict kpi from pm file    KPI_file=CB008246_O_001_HR_KPI.txt    para_index=${2}
    set test variable    ${dlMcsDowngradeForHr_enabled}    ${dict_kpis_name_value['1_PDSCH_INITX_LOWSE_MCS']}

O001 Step 8 stop traffic and detach ue
    Comment     Step8: stop traffic and detach ue
    Stop DL or UL traffic    ue_index=${2}    ue_type=${ue_type}    direction=DL
    QCM UE Recover Detach    ue_index=${2}    status=${0}    ue_type=${ue_type}

O001 Step 9 modify dlMcsDowngradeForHr to enhanced
    Comment     Step9: modify dlMcsDowngradeForHr enhanced
    Online modify parmeters     parameters_to_update=${PARAM_8246_gnb1_O_001_3}    skip_parameter_relation_errors=False

O001 Step 10 repeat step 1 to step 2
    ue attach for steps    logname=${log_name_O_001_3}
    O001 Step 2 UE2 make traffic

O001 Step 11 check HR MCS AVG KPI
    comment    Step11: check HR dlMcsDowngradeForHr_enhanced KPI
    Prepare with PM counter time to caculate    period=start
    sleep    6min    reason=check KPIs after make traffic during 5mins and xml report generated 1min
    ${dict_kpis_name_value}=    get dict kpi from pm file    KPI_file=CB008246_O_001_HR_KPI.txt    para_index=${2}
    set test variable    ${dlMcsDowngradeForHr_enhanced}    ${dict_kpis_name_value['1_PDSCH_INITX_LOWSE_MCS']}

O001 Step 12 compare MCS AVG between parameter disabled and enabled and enhanced
    comment    Step 11: compare MCS AVG between parameter enabled and disabled
    Should Be True    ${dlMcsDowngradeForHr_disabled}>${dlMcsDowngradeForHr_enhanced}>${dlMcsDowngradeForHr_enabled}

O001 Teardown
    robot_common_operations.Common Case Teardown
    AlarmWatchdog.remove_allow_alarms    fault_id=${allow_fault_list}
    Stop DL or UL traffic    ue_index=${2}    ue_type=${ue_type}    direction=DL
    QCM UE Recover Detach    ue_index=${2}    status=${0}    ue_type=${ue_type}
    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
    Adjust HBTE gNB_eNB_RU Attenuation
    Online modify parmeters    parameters_to_update=${PARAM_8246_recover_gnb1_O_001}    skip_parameter_relation_errors=False
    Stop capture syslog via btslog on ute
    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
    get and analysis syslog

O004 Prerequisite
    comment    O004 Prerequisite
    robot_common_operations.Common Case Setup
    Online modify parmeters     parameters_to_update=${PARAM_8246_gnb1_O_004}    skip_parameter_relation_errors=False
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    Power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${2}
    Switch QCOM APN to muti DRB    ue_index=${2}    ue_type=${ue_type}    apn_name=${wap2_apn_name}

O004 Step 1 UE2 attach
    comment    Step1: UE2 attach on gnb1 cell2
    ue attach for steps    logname=${log_name_O_004_1}

O004 Step 2 UE2 make traffic
    comment    Step2: UE2 make traffic with DL and UL
    Start only DL traffic and check tput    ue_index=${2}    cellid=${2}    ue_type=${ue_type}    gnb_index=${0}
    ...                                tput_dl_cell=${expected_tput_dl_O004}    dl_throughput=${Send_Tput_DL_O004}    duration=${7200}
    Start only UL traffic and check tput    ue_index=${2}    cellid=${2}    ue_type=${ue_type}    gnb_index=${0}
    ...                                tput_ul_cell=${expected_tput_ul_O004}    ul_throughput=${Send_Tput_UL_O004}    duration=${7200}

O004 Step 3 check HR MCS AVG KPI
    comment    Step3: check HR KPI
    Prepare with PM counter time to caculate    period=start
    sleep    6min    reason=check KPIs after make traffic during 5mins and xml report generated 1min
    ${pdsch_rank1}    ${pusch_rank1}=    check HR traffic SUM RANK1 MCS RANK from pm file
    ...    KPI_file=CB008246_O_04_HR_MCS_RANK1.txt    para_index=${2}
    ${pdsch_rank2}    ${pusch_rank2}=    check HR traffic SUM RANK2 MCS RANK from pm file
    ...    KPI_file=CB008246_O_04_HR_MCS_RANK2.txt    para_index=${2}
    set test variable    ${pdsch_rank1}
    set test variable    ${pusch_rank1}
    set test variable    ${pdsch_rank2}
    set test variable    ${pusch_rank2}
    ${pdsch_rank1_mcs_avg_value_1}=    run keyword if    '${pdsch_rank1}' == 'False'
    ...    Get HR traffic MCS AVG value from pm file    KPI_file=CB008246_O_04_HR_PDSCH_RANK1_MCS_AVG.txt
    ...    para_index=${2}    counter_name=PDSCH_RANK1_LOWSE_MCS_AVG
    ...    ELSE    evaluate   0+0
    ${pdsch_rank2_mcs_avg_value_1}=    run keyword if    '${pdsch_rank2}' == 'False'
    ...    Get HR traffic MCS AVG value from pm file    KPI_file=CB008246_O_04_HR_PDSCH_RANK2_MCS_AVG.txt
    ...    para_index=${2}    counter_name=PDSCH_RANK2_LOWSE_MCS_AVG
    ...    ELSE    evaluate   0+0
    ${pusch_rank1_mcs_avg_value_1}=    run keyword if    '${pusch_rank1}' == 'False'
    ...    Get HR traffic MCS AVG value from pm file    KPI_file=CB008246_O_04_HR_PUSCH_RANK1_MCS_AVG.txt
    ...    para_index=${2}    counter_name=PUSCH_RANK1_LOWSE_MCS_AVG
    ...    ELSE    evaluate   0+0
    ${pusch_rank2_mcs_avg_value_1}=    run keyword if    '${pusch_rank2}' == 'False'
    ...    Get HR traffic MCS AVG value from pm file    KPI_file=CB008246_O_04_HR_PUSCH_RANK2_MCS_AVG.txt
    ...    para_index=${2}    counter_name=PUSCH_RANK2_LOWSE_MCS_AVG
    ...    ELSE    evaluate   0+0
    set test variable    ${pdsch_rank1_mcs_avg_value_1}
    set test variable    ${pdsch_rank2_mcs_avg_value_1}
    set test variable    ${pusch_rank1_mcs_avg_value_1}
    set test variable    ${pusch_rank2_mcs_avg_value_1}

O004 Step 4 stop traffic and detach ue
    Comment     Step4: stop traffic and detach ue
    put btslog_ini file to ute
    ...    server_ip=${appserver_addr}    server_username=${appserver_username}    server_password=${appserver_password}
    Start capture syslog via btslog on ute
    Stop DL or UL traffic    ue_index=${2}    ue_type=${ue_type}    direction=DL
    Stop DL or UL traffic    ue_index=${2}    ue_type=${ue_type}    direction=UL
    QCM UE Recover Detach    ue_index=${2}    status=${0}    ue_type=${ue_type}
    [Teardown]    Stop capture syslog via btslog on ute

O004 Step 5 modify dlMcsDowngradeForHr and ulMcsDowngradeForHr to disabled
    Comment     Step5: modify dlMcsDowngradeForHr and ulMcsDowngradeForHr to disabled
    Online modify parmeters     parameters_to_update=${PARAM_8246_gnb1_O_004_2}    skip_parameter_relation_errors=False

O004 Step 6 repeat step 1 to step 2
    ue attach for steps    logname=${log_name_O_004_2}
    O004 Step 2 UE2 make traffic

O004 Step 7 check HR MCS AVG KPI
    comment    Step3: check HR KPI
    Prepare with PM counter time to caculate    period=start
    sleep    6min    reason=check KPIs after make traffic during 5mins and xml report generated 1min
    ${pdsch_rank1_mcs_avg_value_2}=    run keyword if    '${pdsch_rank1}' == 'False'
    ...    Get HR traffic MCS AVG value from pm file    KPI_file=CB008246_O_04_HR_PDSCH_RANK1_MCS_AVG.txt
    ...    para_index=${2}    counter_name=PDSCH_RANK1_LOWSE_MCS_AVG
    ...    ELSE    evaluate   0+0
    ${pdsch_rank2_mcs_avg_value_2}=    run keyword if    '${pdsch_rank2}' == 'False'
    ...    Get HR traffic MCS AVG value from pm file    KPI_file=CB008246_O_04_HR_PDSCH_RANK2_MCS_AVG.txt
    ...    para_index=${2}    counter_name=PDSCH_RANK2_LOWSE_MCS_AVG
    ...    ELSE    evaluate   0+0
    ${pusch_rank1_mcs_avg_value_2}=    run keyword if    '${pusch_rank1}' == 'False'
    ...    Get HR traffic MCS AVG value from pm file    KPI_file=CB008246_O_04_HR_PUSCH_RANK1_MCS_AVG.txt
    ...    para_index=${2}    counter_name=PUSCH_RANK1_LOWSE_MCS_AVG
    ...    ELSE    evaluate   0+0
    ${pusch_rank2_mcs_avg_value_2}=    run keyword if    '${pusch_rank2}' == 'False'
    ...    Get HR traffic MCS AVG value from pm file    KPI_file=CB008246_O_04_HR_PUSCH_RANK2_MCS_AVG.txt
    ...    para_index=${2}    counter_name=PUSCH_RANK2_LOWSE_MCS_AVG
    ...    ELSE    evaluate   0+0
    set test variable    ${pdsch_rank1_mcs_avg_value_2}
    set test variable    ${pdsch_rank2_mcs_avg_value_2}
    set test variable    ${pusch_rank1_mcs_avg_value_2}
    set test variable    ${pusch_rank2_mcs_avg_value_2}

O004 Step 8 compare MCS AVG between parameter enabled and disabled
    comment    Step 8: compare MCS AVG between parameter enabled and disabled
    ${pdsch_rank1_mcs_avg_value_2}=    run keyword if    '${pdsch_rank1}' == 'False'
    ...    should be true    ${pdsch_rank1_mcs_avg_value_1} < ${pdsch_rank1_mcs_avg_value_2}
    ${pdsch_rank2_mcs_avg_value_2}=    run keyword if    '${pdsch_rank2}' == 'False'
    ...    should be true    ${pdsch_rank2_mcs_avg_value_1} < ${pdsch_rank2_mcs_avg_value_2}
    ${pusch_rank1_mcs_avg_value_2}=    run keyword if    '${pusch_rank1}' == 'False'
    ...    should be true    ${pusch_rank1_mcs_avg_value_1} < ${pusch_rank1_mcs_avg_value_2}
    ${pusch_rank2_mcs_avg_value_2}=    run keyword if    '${pusch_rank2}' == 'False'
    ...    should be true    ${pusch_rank2_mcs_avg_value_1} < ${pusch_rank2_mcs_avg_value_2}

O004 Teardown
    robot_common_operations.Common Case Teardown
    Stop DL or UL traffic    ue_index=${2}    ue_type=${ue_type}    direction=DL
    Stop DL or UL traffic    ue_index=${2}    ue_type=${ue_type}    direction=UL
    QCM UE Recover Detach    ue_index=${2}    status=${0}    ue_type=${ue_type}
    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
    Adjust HBTE gNB_eNB_RU Attenuation
    Online modify parmeters    parameters_to_update=${PARAM_8246_recover_gnb1_O_004}    skip_parameter_relation_errors=False
    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
    get and analysis syslog





ue attach for steps
    [Arguments]    ${logname}
    Start capture gNB log on master    filename=${logname}
    Attach and check power UE    ue_type=${ue_type}    ue_index=${2}    gnb_index=${0}
    Sleep    30s
    [Teardown]    run keywords
    ...    Stop and download Logs on gNB on master    filename=${logname}
    ...    AND    Check wireshark log for 8246_O004    logname=${logname}

check HR traffic SUM RANK1 MCS RANK from pm file
    [Arguments]     ${KPI_file}    ${para_index}    ${index}=${0}
    ${dict_kpis_name_value}=    get dict kpi from pm file    KPI_file=${KPI_file}    para_index=${para_index}    index=${index}
    ${result1}=    run keyword and return status    should be equal    ${dict_kpis_name_value['PDSCH_RANK1_LOWSE_MCS']}    ${0}
    ${result2}=    run keyword and return status    should be equal    ${dict_kpis_name_value['PUSCH_CP_RANK1_LOWSE_MCS']}    ${0}
    [Return]    ${result1}    ${result2}

check HR traffic SUM RANK2 MCS RANK from pm file
    [Arguments]     ${KPI_file}    ${para_index}    ${index}=${0}
    ${dict_kpis_name_value}=    get dict kpi from pm file    KPI_file=${KPI_file}    para_index=${para_index}    index=${index}
    ${result1}=    run keyword and return status    should be equal    ${dict_kpis_name_value['PDSCH_RANK2_LOWSE_MCS']}    ${0}
    ${result2}=    run keyword and return status    should be equal    ${dict_kpis_name_value['PUSCH_CP_RANK2_LOWSE_MCS']}    ${0}
    [Return]    ${result1}    ${result2}

Get HR traffic MCS AVG value from pm file
    [Arguments]     ${KPI_file}    ${para_index}    ${counter_name}    ${index}=${0}
    ${dict_kpis_name_value}=    get dict kpi from pm file    KPI_file=${KPI_file}    para_index=${para_index}    index=${index}
    [Return]    ${dict_kpis_name_value}[${counter_name}]

Check wireshark log for 8246_O004
    [Arguments]    ${logname}
    Check UL_UE_MCS_table_Capbility    logname=${logname}

Check UL_UE_MCS_table_Capbility
    [Arguments]    ${logname}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    alias=test6
    ${filter_expression}=     Catenate    f1ap.procedureCode == 12 and nr-rrc.uplinkBWP_ToAddModList == 1 and nr-rrc.mcs_Table == 1
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_mcs_Table}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.mcs_Table    pcap_parser=test6
    Should Be Equal    ${nr_rrc_mcs_Table[1]}    1

COAM Save snapshot
    get gnb snapshot    gnb_index=${0}
#    get gnb snapshot    gnb_index=${1}

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
