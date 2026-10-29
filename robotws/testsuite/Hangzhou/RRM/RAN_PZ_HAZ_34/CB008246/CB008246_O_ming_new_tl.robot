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
...                            AND    Setup for Env cell on-air for 2 gnb    is_commission_for_second_gnb=False
...                                   tl_scf_file_name=${tl_gnb1_scf_${sw_version}}
...                            AND    Common UE parameter setup
...                            AND    paras change on BTS
...                                   paras=${CB008246_ciphering_algorithms}
...                                   delta_file_name=${epc_log_path}${CB008246_ciphering_algorithms_json_file}

Suite Teardown     Run Keywords
...                           paras change on BTS
...                           paras=${CB008246_recover_ciphering_algorithms}
...                           delta_file_name=${epc_log_path}${CB008246_recover_ciphering_algorithms_json_file}
...                           AND    Common Suite Teardown for COAM    gnb_list=${gnb_list}

Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008246/Resources/CB008246_common_keywords.robot

*** Variables ***
${log_name_PR856608_1}    log_name_PR856608_1.pcap
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
${expected_tput_dl_PR856608}    1
${Send_Tput_DL_O004}        1K
${Send_Tput_DL_PR856608}        2000M
${expected_tput_ul_O004}    0
${Send_Tput_UL_O004}        1K
${Send_Tput_DL_O001}        1M
${expected_tput_dl_O001}    0.8
@{expected_value_D001_gnb1}    ${1}    ${1}    ${7}    ${1}    ${7}
@{Counter_D001}    ${0}
${kpis_templates_id}    1040    # CB008246-O_Counter&KPI
${tool_path}    /opt/workspace/Tool

# TL348
${5Gcell1_ANT1}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${5Gcell1_ANT2}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
${5Gcell1_ANT3}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[2].port_no}
${5Gcell1_ANT4}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[3].port_no}
${5Gcell2_ANT1}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[0].port_no}
${5Gcell2_ANT2}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[1].port_no}
${5Gcell2_ANT3}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[2].port_no}
${5Gcell2_ANT4}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[3].port_no}
${5Gcell3_ANT1}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[0].port_no}
${5Gcell3_ANT2}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[1].port_no}
${5Gcell3_ANT3}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[2].port_no}
${5Gcell3_ANT4}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[3].port_no}
${5Gcell4_ANT1}    ${tl.gnbs[0].dus[0].rus[3].attenuation_ports[0].port_no}
${5Gcell4_ANT2}    ${tl.gnbs[0].dus[0].rus[3].attenuation_ports[1].port_no}
${5Gcell4_ANT3}    ${tl.gnbs[0].dus[0].rus[3].attenuation_ports[2].port_no}
${5Gcell4_ANT4}    ${tl.gnbs[0].dus[0].rus[3].attenuation_ports[3].port_no}
${5Gcell5_ANT1}    ${tl.gnbs[0].dus[0].rus[4].attenuation_ports[0].port_no}
${5Gcell5_ANT2}    ${tl.gnbs[0].dus[0].rus[4].attenuation_ports[1].port_no}
${5Gcell5_ANT3}    ${tl.gnbs[0].dus[0].rus[4].attenuation_ports[2].port_no}
${5Gcell5_ANT4}    ${tl.gnbs[0].dus[0].rus[4].attenuation_ports[3].port_no}
${5Gcell6_ANT1}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[0].port_no}
${5Gcell6_ANT2}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[1].port_no}
${5Gcell6_ANT3}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[2].port_no}
${5Gcell6_ANT4}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[3].port_no}

${4Gcell1_ANT1}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${4Gcell1_ANT2}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
${4Gcell1_ANT3}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[2].port_no}
${4Gcell1_ANT4}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[3].port_no}
${4Gcell2_ANT1}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[0].port_no}
${4Gcell2_ANT2}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[1].port_no}
${4Gcell2_ANT3}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[2].port_no}
${4Gcell2_ANT4}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[3].port_no}
${4Gcell3_ANT1}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[0].port_no}
${4Gcell3_ANT2}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[1].port_no}
${4Gcell3_ANT3}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[2].port_no}
${4Gcell3_ANT4}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[3].port_no}
${4Gcell4_ANT1}    ${tl.gnbs[0].dus[0].rus[3].attenuation_ports[0].port_no}
${4Gcell4_ANT2}    ${tl.gnbs[0].dus[0].rus[3].attenuation_ports[1].port_no}
${4Gcell4_ANT3}    ${tl.gnbs[0].dus[0].rus[3].attenuation_ports[2].port_no}
${4Gcell4_ANT4}    ${tl.gnbs[0].dus[0].rus[3].attenuation_ports[3].port_no}

# TL383
${5Gcells1_ANT1}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${5Gcells1_ANT2}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
${5Gcells1_ANT3}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[2].port_no}
${5Gcells1_ANT4}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[3].port_no}
${5Gcells2_ANT1}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[0].port_no}
${5Gcells2_ANT2}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[1].port_no}
${5Gcells2_ANT3}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[2].port_no}
${5Gcells2_ANT4}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[3].port_no}
${5Gcells3_ANT1}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[0].port_no}
${5Gcells3_ANT2}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[1].port_no}
${5Gcells3_ANT3}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[2].port_no}
${5Gcells3_ANT4}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[3].port_no}
${5Gcells4_ANT1}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[0].port_no}    #gnb2 cell1
${5Gcells4_ANT2}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[1].port_no}    #gnb2 cell1
${4Gcells1_ANT1}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[0].port_no}
${4Gcells1_ANT2}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[1].port_no}
${4Gcells1_ANT3}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[2].port_no}
${4Gcells1_ANT4}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[3].port_no}

@{enb_id}    34821    38321
@{cell_id}    0    1    2    3    4    5
@{cell_id_348}    0    1    2    3    4    5    6
@{multi_gnb_PA}    ${0}     ${127}    ${30}
@{multi_gnb_PA_358}    ${0}
@{multi_gnb_PA_348}    ${0}
@{multi_gnb_PA_383}    ${0}

${ue_type_qcom}    ${tl.ues[1].capabilities[0]}

${dxdata2_apn_name}    ${tl.ues[1].pdn[0]}
${mdrb_apn_name}    ${tl.ues[1].pdn[1]}
${mdrb1_apn_name}    ${tl.ues[1].pdn[2]}

${X80_dxdata2apn_location}    1279 1100
${X80_mdrbapn_location}    1279 1300
${X80_mdrb1apn_location}    1279 1550

${traffic_dl_port}    ${tl.ues[1].iperf_details.port}
${traffic_ul_port}    ${tl.ues[1].iperf_details.ssh_connection_details.port}

${tl_scf_dir_path}    /opt/workspace/CRT/Master/SCF_file/

${tl_scf_file_name1}    gNB1_Golden_SCF.xml
${tl_scf_file_name2}    gNB2_Golden_SCF.xml

${l2stream3_ttitrace_PR856608_1}    l2stream3_ttitrace_PR856608_1

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

*** Keywords ***
O004 Prerequisite
    comment    O004 Prerequisite
    robot_common_operations.Common Case Setup    allowed_faults_ids=4291
    AlarmWatchdog.add_allow_alarms    fault_id=4291
    trigger WB switch to SB for PR856608
    IF    ${enb_instance} == ${enb_id}[0]     #TL348
        Online modify parmeters     parameters_to_update=${PARAM_8246_gnb1_O_004_348}    skip_parameter_relation_errors=False
        PA one cell 0 on and set other cell value 4 port for T348    cellid=${cell_id_348}[1]    set_value=${multi_gnb_PA}[0]
    ELSE IF    ${enb_instance} == ${enb_id}[1]     #TL383
        Online modify parmeters     parameters_to_update=${PARAM_8246_gnb1_O_004_348}    skip_parameter_relation_errors=False
        PA one cell 0 on and set other cell value 4 port for T348    cellid=${cell_id_348}[1]    set_value=${multi_gnb_PA}[0]
    END
#    Power_ue.Prepare UE    ue_type=${ue_type_qcom}    ue_index=${1}
#    Switch QCOM APN to muti DRB    ue_index=${1}    ue_type=${ue_type_qcom}    apn_name=${dxdata2_apn_name}
#    choice required APN on QCOM SDX80 UE    usedapn=${X80_dxdata2apn_location}    ue_index=${1}

O004 Step 1 UE2 attach
    comment    Step1: UE2 attach on gnb1 cell2
#    Power_ue.Prepare UE    ue_type=${ue_type_qcom}    ue_index=${1}
    ue attach for steps    logname=${log_name_O_004_1}

O004 Step 2 UE2 make traffic
    comment    Step2: UE2 make traffic with DL and UL
    Start only DL traffic and check tput    ue_index=${1}    cellid=${1}    ue_type=${ue_type_qcom}    gnb_index=${0}
    ...                                tput_dl_cell=${expected_tput_dl_O004}    dl_throughput=${Send_Tput_DL_O004}    duration=${7200}
    ...                                dl_port=${traffic_dl_port}
    Start only UL traffic and check tput    ue_index=${1}    cellid=${1}    ue_type=${ue_type_qcom}    gnb_index=${0}
    ...                                tput_ul_cell=${expected_tput_ul_O004}    ul_throughput=${Send_Tput_UL_O004}    duration=${7200}
    ...                                ul_port=${traffic_ul_port}

O004 Step 3 check HR MCS AVG KPI
    comment    Step3: check HR KPI
    Prepare with PM counter time to caculate    period=start
    sleep    6min    reason=check KPIs after make traffic during 5mins and xml report generated 1min
    ${pdsch_rank1}    ${pusch_rank1}=    check HR traffic SUM RANK1 MCS RANK from pm file
    ...    KPI_file=CB008246_O_04_HR_MCS_RANK1.txt    para_index=${1}
    ${pdsch_rank2}    ${pusch_rank2}=    check HR traffic SUM RANK2 MCS RANK from pm file
    ...    KPI_file=CB008246_O_04_HR_MCS_RANK2.txt    para_index=${1}
    set test variable    ${pdsch_rank1}
    set test variable    ${pusch_rank1}
    set test variable    ${pdsch_rank2}
    set test variable    ${pusch_rank2}
    ${pdsch_rank1_mcs_avg_value_1}=    run keyword if    '${pdsch_rank1}' == 'False'
    ...    Get HR traffic MCS AVG value from pm file    KPI_file=CB008246_O_04_HR_PDSCH_RANK1_MCS_AVG.txt
    ...    para_index=${1}    counter_name=PDSCH_RANK1_LOWSE_MCS_AVG
    ...    ELSE    evaluate   0+0
    ${pdsch_rank2_mcs_avg_value_1}=    run keyword if    '${pdsch_rank2}' == 'False'
    ...    Get HR traffic MCS AVG value from pm file    KPI_file=CB008246_O_04_HR_PDSCH_RANK2_MCS_AVG.txt
    ...    para_index=${1}    counter_name=PDSCH_RANK2_LOWSE_MCS_AVG
    ...    ELSE    evaluate   0+0
    ${pusch_rank1_mcs_avg_value_1}=    run keyword if    '${pusch_rank1}' == 'False'
    ...    Get HR traffic MCS AVG value from pm file    KPI_file=CB008246_O_04_HR_PUSCH_RANK1_MCS_AVG.txt
    ...    para_index=${1}    counter_name=PUSCH_RANK1_LOWSE_MCS_AVG
    ...    ELSE    evaluate   0+0
    ${pusch_rank2_mcs_avg_value_1}=    run keyword if    '${pusch_rank2}' == 'False'
    ...    Get HR traffic MCS AVG value from pm file    KPI_file=CB008246_O_04_HR_PUSCH_RANK2_MCS_AVG.txt
    ...    para_index=${1}    counter_name=PUSCH_RANK2_LOWSE_MCS_AVG
    ...    ELSE    evaluate   0+0
    set test variable    ${pdsch_rank1_mcs_avg_value_1}
    set test variable    ${pdsch_rank2_mcs_avg_value_1}
    set test variable    ${pusch_rank1_mcs_avg_value_1}
    set test variable    ${pusch_rank2_mcs_avg_value_1}

O004 Step 4 stop traffic and detach ue
    Comment     Step4: stop traffic and detach ue
#    put btslog_ini file to ute
#    ...    server_ip=${appserver_addr}    server_username=${appserver_username}    server_password=${appserver_password}
#    Start capture syslog via btslog on ute
    Stop DL or UL traffic    ue_index=${1}    ue_type=${ue_type_qcom}    direction=DL
    Stop DL or UL traffic    ue_index=${1}    ue_type=${ue_type_qcom}    direction=UL
    QCM UE Recover Detach    ue_index=${1}    status=${0}    ue_type=${ue_type_qcom}
#    [Teardown]    Stop capture syslog via btslog on ute

O004 Step 5 modify dlMcsDowngradeForHr and ulMcsDowngradeForHr to disabled
    Comment     Step5: modify dlMcsDowngradeForHr and ulMcsDowngradeForHr to disabled
    IF    ${enb_instance} == ${enb_id}[0]     #TL348
        Online modify parmeters     parameters_to_update=${PARAM_8246_gnb1_O_004_2_348}    skip_parameter_relation_errors=False
    ELSE IF    ${enb_instance} == ${enb_id}[1]     #TL383
        Online modify parmeters     parameters_to_update=${PARAM_8246_gnb1_O_004_2_348}    skip_parameter_relation_errors=False
    END

O004 Step 6 repeat step 1 to step 2
    ue attach for steps    logname=${log_name_O_004_2}
    O004 Step 2 UE2 make traffic

O004 Step 7 check HR MCS AVG KPI
    comment    Step3: check HR KPI
    Prepare with PM counter time to caculate    period=start
    sleep    6min    reason=check KPIs after make traffic during 5mins and xml report generated 1min
    ${pdsch_rank1_mcs_avg_value_2}=    run keyword if    '${pdsch_rank1}' == 'False'
    ...    Get HR traffic MCS AVG value from pm file    KPI_file=CB008246_O_04_HR_PDSCH_RANK1_MCS_AVG.txt
    ...    para_index=${1}    counter_name=PDSCH_RANK1_LOWSE_MCS_AVG
    ...    ELSE    evaluate   0+0
    ${pdsch_rank2_mcs_avg_value_2}=    run keyword if    '${pdsch_rank2}' == 'False'
    ...    Get HR traffic MCS AVG value from pm file    KPI_file=CB008246_O_04_HR_PDSCH_RANK2_MCS_AVG.txt
    ...    para_index=${1}    counter_name=PDSCH_RANK2_LOWSE_MCS_AVG
    ...    ELSE    evaluate   0+0
    ${pusch_rank1_mcs_avg_value_2}=    run keyword if    '${pusch_rank1}' == 'False'
    ...    Get HR traffic MCS AVG value from pm file    KPI_file=CB008246_O_04_HR_PUSCH_RANK1_MCS_AVG.txt
    ...    para_index=${1}    counter_name=PUSCH_RANK1_LOWSE_MCS_AVG
    ...    ELSE    evaluate   0+0
    ${pusch_rank2_mcs_avg_value_2}=    run keyword if    '${pusch_rank2}' == 'False'
    ...    Get HR traffic MCS AVG value from pm file    KPI_file=CB008246_O_04_HR_PUSCH_RANK2_MCS_AVG.txt
    ...    para_index=${1}    counter_name=PUSCH_RANK2_LOWSE_MCS_AVG
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
    AlarmWatchdog.remove_allow_alarms    fault_id=4291
    Stop DL or UL traffic    ue_index=${1}    ue_type=${ue_type_qcom}    direction=DL
    Stop DL or UL traffic    ue_index=${1}    ue_type=${ue_type_qcom}    direction=UL
    QCM UE Recover Detach    ue_index=${1}    status=${0}    ue_type=${ue_type_qcom}
    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
    IF    ${enb_instance} == ${enb_id}[0]     #TL348
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[1]    value=${multi_gnb_PA}[1]
        Online modify parmeters    parameters_to_update=${PARAM_8246_recover_gnb1_O_004_348}    skip_parameter_relation_errors=False
    ELSE IF    ${enb_instance} == ${enb_id}[1]     #TL383
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[1]    value=${multi_gnb_PA}[1]
        Online modify parmeters    parameters_to_update=${PARAM_8246_recover_gnb1_O_004_348}    skip_parameter_relation_errors=False
    END
    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
#    get and analysis syslog





ue attach for steps
    [Arguments]    ${logname}
    Start capture gNB log on master    filename=${logname}
    Attach and check power UE    ue_type=${ue_type_qcom}    ue_index=${1}    gnb_index=${0}
#    Sleep    30s
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

get gnb snapshot
    [Arguments]     ${gnb_index}=${0}
    Connect to gnb coam via ssl    gnb_index=${gnb_index}
    COAM Save snapshot via rest api    log_path=${epc_log_path}
    [Teardown]    COAM Teardown gnb connections

PA one cell 0 on and set other cell value 4 port for T348
    [Arguments]    ${cellid}    ${set_value}=${0}    ${total_cell}=${6}
    IF    '${cellid}' == '5' or '${cellid}' == '6'
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cellid}    value=${set_value}    ip_addr=${att_ipaddr_1}
    ELSE
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cellid}    value=${set_value}    ip_addr=${att_ipaddr}
    END
    FOR  ${index}  IN RANGE   ${total_cell}
        ${cellnum} =    evaluate    ${index}+1
        IF    ('${cellid}' != '${cellnum}') and ('${cellnum}' == '5' or '${cellnum}' == '6')
            Change Attenuation value 4 port for multi PAs    cell=5Gcell${cellnum}    value=${127}    ip_addr=${att_ipaddr_1}
        ELSE IF    ('${cellid}' != '${cellnum}') and ('${cellnum}' != '5' or '${cellnum}' != '6')
            Change Attenuation value 4 port for multi PAs    cell=5Gcell${cellnum}    value=${127}    ip_addr=${att_ipaddr}
        END
    END

Change Attenuation value 4 port for multi PAs
    [Arguments]    ${cell}    ${value}    ${ip_addr}=${att_ipaddr}
    Set Programmable Attenuation Value for multi PAs    ports=${${cell}_ANT1}    value=${value}    ip_addr=${ip_addr}
    Set Programmable Attenuation Value for multi PAs    ports=${${cell}_ANT2}    value=${value}    ip_addr=${ip_addr}
    Set Programmable Attenuation Value for multi PAs    ports=${${cell}_ANT3}    value=${value}    ip_addr=${ip_addr}
    Set Programmable Attenuation Value for multi PAs    ports=${${cell}_ANT4}    value=${value}    ip_addr=${ip_addr}

Set Programmable Attenuation Value for multi PAs
    [Arguments]    ${ports}    ${value}    ${ip_addr}=${att_ipaddr}
    atten.setup_attenuator    ip_addr=${ip_addr}    port=${att_api_port}
    ...    attenuation_port_numbers=${ports}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    ...    model=${model}
    atten.set_attenuation     port=${ports}    value=${value}

PA one cell 0 on and set other cell value 4 port
    [Arguments]    ${cellid}    ${set_value}=${0}    ${total_cell}=${4}
    IF    ${cellid} == 4
        Change Attenuation value    cell=5Gcells${cellid}    value=${set_value}
    ELSE
        Change Attenuation value 4 port    cell=5Gcells${cellid}    value=${set_value}
    END
    FOR  ${index}    IN RANGE    ${total_cell}
        ${cellnum} =    evaluate    ${index}+1
        IF    '${cellid}'!='${cellnum}'
            IF    ${cellnum} == 4
                Change Attenuation value    cell=5Gcells${cellnum}    value=${127}
            ELSE
                Change Attenuation value 4 port    cell=5Gcells${cellnum}    value=${127}
            END
        END
    END
    Change Attenuation value 4 port    cell=4Gcells1    value=${127}

Change Attenuation value
    [Arguments]    ${cell}    ${value}
    Set the Attenuation Value    ports=${${cell}_ANT1}    value=${value}
    Set the Attenuation Value    ports=${${cell}_ANT2}    value=${value}
    Run Keyword If    '${cell}' == '5Gcell3'    Run Keywords
    ...    Set the Attenuation Value    ports=${${cell}_ANT3}    value=${value}
    ...    AND    Set the Attenuation Value    ports=${${cell}_ANT4}    value=${value}

Change Attenuation value 4 port
    [Arguments]    ${cell}    ${value}
    Set the Attenuation Value    ports=${${cell}_ANT1}    value=${value}
    Set the Attenuation Value    ports=${${cell}_ANT2}    value=${value}
    Set the Attenuation Value    ports=${${cell}_ANT3}    value=${value}
    Set the Attenuation Value    ports=${${cell}_ANT4}    value=${value}

Set the Attenuation Value
    [Arguments]    ${ports}    ${value}
    atten.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${ports}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    ...    model=${model}
    atten.set_attenuation     port=${ports}    value=${value}

trigger WB switch to SB for PR856608
    IF    ${enb_instance} == ${enb_id}[0]     #TL348
        Online modify parmeters     parameters_to_update=${PARAM_8246_gnb1_PR856608_348}    skip_parameter_relation_errors=False
        PA one cell 0 on and set other cell value 4 port for T348    cellid=${cell_id_348}[5]    set_value=${multi_gnb_PA}[2]
    ELSE IF    ${enb_instance} == ${enb_id}[1]     #TL383
        Online modify parmeters     parameters_to_update=${PARAM_8246_gnb1_PR856608_348}    skip_parameter_relation_errors=False
        PA one cell 0 on and set other cell value 4 port for T348    cellid=${cell_id_348}[5]    set_value=${multi_gnb_PA}[2]
    END
    Power_ue.Prepare UE    ue_type=${ue_type_qcom}    ue_index=${1}
    ue attach for PR856608    logname=${log_name_PR856608_1}
    Start only DL traffic and check tput    ue_index=${1}    cellid=${4}    ue_type=${ue_type_qcom}    gnb_index=${0}
    ...                                tput_dl_cell=${expected_tput_dl_PR856608}    dl_throughput=${Send_Tput_DL_PR856608}    duration=${7200}
    ...                                dl_port=${traffic_dl_port}
#    upgrade gnb logs tool on VM    tool_download_path=${tool_path}
    to capture logs via gnb_logs tool    option=-t 2 -C700    tool_download_path=${tool_path}
#    Capture Ttitrace tti from WEBUI    names=${l2stream3_ttitrace_PR856608_1}    nr_phy_cell_ids=700    capture_time=2s
    Prepare with PM counter time to caculate    period=start
    sleep    6min    reason=check KPIs after make traffic during 5mins and xml report generated 1min
    IF    ${enb_instance} == ${enb_id}[0]     #TL348
        Check DL HR traffic check dict KPI from pm file 348 383    KPI_file=CB008246_D_006_HR_KPI.txt    para_index=${3}
    ELSE IF    ${enb_instance} == ${enb_id}[1]     #TL383
        Check DL HR traffic check dict KPI from pm file 348 383    KPI_file=CB008246_D_006_HR_KPI.txt    para_index=${3}
    END
    ${log_files}    ${folder_name}    ${csv_path}=    get logs from gnb_logs folder from v2.67    tool_download_path=${tool_path}    lcrid=${4}
    ${file_name}    get_required_tti_file_name    files_list=${log_files}
    check value on TTI file for PR856608    file_path=${csv_path}/${file_name}    queried_filed=spectrumEfficiencyM100
#    check value on TTI file for PR856608
#    ...    file_path=${epc_log_path}/${l2stream3_ttitrace_PR856608_1}_dl.csv    queried_filed=spectrumEfficiencyM100
    [Teardown]    recover for PR856608

recover for PR856608
    Stop DL or UL traffic    ue_index=${1}    ue_type=${ue_type_qcom}    direction=DL
    QCM UE Recover Detach    ue_index=${1}    status=${0}    ue_type=${ue_type_qcom}
    Run keyword if    '${KEYWORD STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
    IF    ${enb_instance} == ${enb_id}[0]     #TL348
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[5]    value=${multi_gnb_PA}[1]
        Online modify parmeters    parameters_to_update=${PARAM_8246_recover_gnb1_PR856608_348}    skip_parameter_relation_errors=False
    ELSE IF    ${enb_instance} == ${enb_id}[1]     #TL383
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[5]    value=${multi_gnb_PA}[1]
        Online modify parmeters    parameters_to_update=${PARAM_8246_recover_gnb1_PR856608_348}    skip_parameter_relation_errors=False
    END

ue attach for PR856608
    [Arguments]    ${logname}
    Start capture gNB log on master    filename=${logname}
    Attach and check power UE    ue_type=${ue_type_qcom}    ue_index=${1}    gnb_index=${0}
    [Teardown]    run keywords
    ...    Stop and download Logs on gNB on master    filename=${logname}
    ...    AND    check UL_UE_MCS_table_Capbility for PR856608    logname=${logname}

check UL_UE_MCS_table_Capbility for PR856608
    [Arguments]    ${logname}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    alias=test6
    ${filter_expression}=     Catenate    f1ap.procedureCode == 12 and nr-rrc.mcs_Table == 1
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_mcs_Table}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.mcs_Table    pcap_parser=test6
    Should Be Equal    ${nr_rrc_mcs_Table[1]}    1

Check DL HR traffic check dict KPI from pm file 348 383
    [Arguments]     ${KPI_file}    ${para_index}    ${index}=${0}
    ${dict_kpis_name_value}=    get dict kpi from pm file    KPI_file=${KPI_file}    para_index=${para_index}    index=${index}
    check required KPI via pm file    KPI_name_list=${CB008246_D_006_HR_traffic_check_kpi_names_value_zero_348_383}
    ...    check_field=equal_specified_value    dict_kpi_get=${dict_kpis_name_value}
    check required KPI via pm file    KPI_name_list=${CB008246_D_006_HR_traffic_check_kpi_names_larger_zero_348_383}
    ...    check_field=larger_specified_value    dict_kpi_get=${dict_kpis_name_value}
    check required KPI via pm file    KPI_name_list=${CB008246_D_006_HR_traffic_check_kpi_names_less_specified_value}
    ...    check_field=less_specified_value    dict_kpi_get=${dict_kpis_name_value}    less_specfied=${0.011}
    check required KPI via pm file    KPI_name_list=${CB008246_D_006_HR_traffic_check_kpi_names_greater_than_or_equal_specfied}
    ...    check_field=greater_than_or_equal_specified_value    dict_kpi_get=${dict_kpis_name_value}    greater_than_or_equal_specfied=${0}
    ${value1}=    Set Variable    ${dict_kpis_name_value}[${CB008246_K_ALL_HR_348_383_01}]
    ${value2}=    Set Variable    ${dict_kpis_name_value}[${CB008246_K_ALL_HR_348_383_02}]
    ${value3}=    Set Variable    ${dict_kpis_name_value}[${CB008246_K_ALL_HR_348_383_03}]
    ${result}=    Evaluate    ${value1} + ${value2} + ${value3}
    Should Be True    ${result} > ${0}

check value on TTI file for PR856608
    [Arguments]    ${file_path}    ${queried_filed}
    ${required_data_list}=    get_value_from_csv_file_255_exclude    file_path=${file_path}    queried_filed=${queried_filed}
    ${no_duplicates_required_data_list}    Remove Duplicates    ${required_data_list}
    ${se_value}=    Evaluate    int(4.5234 * 4)
    FOR    ${data}    IN    @{no_duplicates_required_data_list}
        ${check_data}=    Evaluate    int(${data} / 100)
        should be true    ${check_data}<=${se_value}
    END

get_required_tti_file_name
    [Arguments]    ${files_list}    ${required_file_name}=dl__all.csv
    FOR    ${file}    IN    @{files_list}
        ${status}    run keyword and return status    should contain    ${file}    ${required_file_name}
        exit for loop if    '${status}' == 'True'
        set test variable    ${file}
    END
    [Return]    ${file}