*** Settings ***
Documentation
...    author: Shi Ming
...    contact: ming.shi@nokia-sbell.com
...    squal group: SG03
...    feature: CB012149-DB

Force Tags  CA_5G_RRM
...    PY36
Suite Setup    Run Keywords
...                            robot_common_operations.Common Suite Setup
...                            AND    Common Suite Setup for COAM
...                            AND    Get sagnb version for selenium
...                            AND    Set Suite Variable    ${tl_gnb1_scf_${sw_version}}    ${sw_version}_gNB1_Golden_SCF.xml
...                            AND    modify and commission scf file
...                            AND    Get gnb release info

Suite Teardown     Common Suite Teardown for COAM    gnb_list=${gnb_list}

Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB012149_BB_BC_DA_DB/Resources/CB0012149_common_keywords.robot

*** Variables ***
${log_name_DB_01_1}    log_name_DB_01_1.pcap
${log_name_DB_01_2}    log_name_DB_01_2.pcap
${log_name_DB_01_3}    log_name_DB_01_3.pcap
${expected_tput_dl}    1
${Send_Tput_DL}        2000M
${expected_tput_ul}    1
${Send_Tput_UL}        600M
@{expected_value_D001_gnb1}    ${1}    ${1}    ${7}    ${1}    ${7}
@{Counter_D001}    ${0}
${kpis_templates_id}    1040
${tool_path}    /opt/workspace/Tool
${X70_wap2apn_location}    959 1370
${X70_mdrb2apn_location}    959 1576
${X70_mdrb1apn_location}    959 1802

@{enb_id}    34821    38321    358
@{cell_id}    0    1    2    3    4    5
@{cell_id_348}    0    1    2    3    4    5    6
@{multi_gnb_PA}    ${0}     ${127}
@{multi_gnb_PA_358}    ${0}
@{multi_gnb_PA_348}    ${0}    ${83}
@{multi_gnb_PA_383}    ${0}    ${65}    #${70}

${DL_PORT_K01}    ${tl.ues[0].iperf_details.port}
${UL_PORT_K01}    ${tl.ues[0].iperf_details.ssh_connection_details.port}
@{gnb_list}    ${0}
${tl_scf_dir_path}    /opt/workspace/CRT/Master/SCF_file/
${tl_scf_file_name1}    gNB1_Golden_SCF.xml
${tl_scf_file_name2}    gNB2_Golden_SCF.xml
${TS_LOG_PATH_BASE}         /opt/workspace/CRT/Master/Case_Logs/

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

@{5Gcell5_ANT}    ${5Gcell5_ANT1}    ${5Gcell5_ANT2}    ${5Gcell5_ANT3}    ${5Gcell5_ANT4}
@{5Gcell5_ANT_values}    ${multi_gnb_PA_348}[1]    ${multi_gnb_PA_348}[1]    ${multi_gnb_PA_348}[1]    ${multi_gnb_PA_348}[1]
@{5Gcell_ANT_initial_values}    ${multi_gnb_PA_348}[0]    ${multi_gnb_PA_348}[0]    ${multi_gnb_PA_348}[0]    ${multi_gnb_PA_348}[0]

@{5Gcell5_VALUES_DB_01}    ${0}    ${10}    ${0}    ${0}
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

${dxdata2_apn}    95 943
${dxdata2_apn_348}    158 943
${mdrb1_apn}    95 1329
${mdrb1_apn_348}    158 1368

${dxdata2}    ${tl.ues[0].pdn[0]}
${mdrb_apn_name}    ${tl.ues[0].pdn[1]}
${mdrb1_apn_name}    ${tl.ues[0].pdn[2]}

${X75_dxdata2_location}    959 940
${X75_mdrb_location}    959 1152
${X75_mdrb1_location}    959 1350

${ue1_type}                  ${tl.ues[1].capabilities[1]}

@{GNB_INDEX_list_snapshot}    ${0}

@{nr_rrc_k2_list_24R3}    2    3    2    3    2    2    2    2
@{nr_rrc_k2_list_25R1}    2    2    2    2    2    2    2    2
@{nr_rrc_k2_list}    2    2    2    2    2    2    2    2
@{nr_rrc_mappingType_list_24R3}    0    0    0    0    0    0    1    1
@{nr_rrc_mappingType_list_25R1}    0    0    0    0    0    1    1    1
#@{nr_rrc_mappingType_list}    0    0    0    0    1    1    1    0
@{nr_rrc_mappingType_list}    0    0    0    0    0    1    1    1
@{nr_rrc_startSymbolAndLength_list_24R3}    27    27    41    41    55    69    53    67
@{nr_rrc_startSymbolAndLength_list_25R1}    27    41    55    69    83    53    67    81
#@{nr_rrc_startSymbolAndLength_list}    27    41    69    83    53    67    81    55
@{nr_rrc_startSymbolAndLength_list}    27    41    55    69    83    53    67    81

${l2stream3_ttitrace_DB_01_1}    l2stream3_ttitrace_DB_01_1
${l2stream3_ttitrace_DB_01_2}    l2stream3_ttitrace_DB_01_2

${ue_type_qcom}    ${tl.ues[1].capabilities[0]}

*** Test Cases ***
[1]USCB012149-DB#IWK1_R16 UL Tx Switching UE interworking with CB006086 and 5GC002396-Alternate-2
    [Documentation]
    ...    1. UE attach to FDD cell as pcell
	...    2. UL switchedUl scell addition successful via A1 (UE capability pusch-TransCoherence value is non-coherent
    ...    UE doesn’t support full power capability)
    ...    3. Start UL traffic on Pcell and Scell, and check TTI logs
    ...    4. check related counters
    ...    5. check peak throughout
    ...    6. UE moves to position with poor radio link quality on TDD SCell and PUSCH is transmitted with rank1 (in
    ...    case radio link quality become bad and PUSCH is transmitted with rank1, reconfiguration for SRS port
    ...    switching “2 to 1” on TDD SCell is not triggered.)
    ...    7. UE moves back to position with good radio link quality on TDD SCell and PUSCH is transmitted with rank2
    [Tags]    CB012149_DB    CRT_TRUNK
    DB_01 Prerequisite
    DB_01 Step 1 UE1 attach to FDD cell as pcell
    DB_01 Step 2 check logs for UL switchedUl scell addition successful on wireshark
    DB_01 Step 3 UE1 Start UL traffic on Pcell and Scell
    DB_01 Step 4 check counters
    DB_01 Step 5 check peak throughput
    DB_01 Step 6 UE moves to position with poor radio link quality on TDD SCell
    DB_01 Step 7 check wireshark logs and TTI
    DB_01 Step 8 UE moves back to position with good radio link quality on TDD SCell
    DB_01 Step 9 check wireshark logs and TTI
    [Teardown]    DB_01 Teardown

*** Keywords ***
DB_01 Prerequisite
    robot_common_operations.Common Case Setup    allowed_faults_ids=4291,4546
    AlarmWatchdog.add_allow_alarms    fault_id=4291
    AlarmWatchdog.add_allow_alarms    fault_id=4546
#    Check UE device status with adb recover    ue_index=${0}
    Check UE device status with adb recover    ue_index=${1}
    comment    Prerequisite
    IF    ${enb_instance} == ${enb_id}[0]     #TL348
        paras change on BTS
        ...    paras=${CB012149_ciphering_algorithms}
        ...    delta_file_name=${epc_log_path}${CB012149_ciphering_algorithms_json_file}
        Online modify parmeters     parameters_to_update=${PARAM_12149_gnb1_DB_01_348}    skip_parameter_relation_errors=False
        COAM Wait for gnb ready and cell setup
        ###set gnb1 cell2 PA to 0
        PA one cell 0 on and set other cell value 4 port for T348    cellid=${cell_id}[1]    set_value=${multi_gnb_PA}[0]
    ELSE IF    ${enb_instance} == ${enb_id}[1]     #TL383
        paras change on BTS
        ...    paras=${CB012149_ciphering_algorithms}
        ...    delta_file_name=${epc_log_path}${CB012149_ciphering_algorithms_json_file}
        Online modify parmeters     parameters_to_update=${PARAM_12149_gnb1_DB_01_348}    skip_parameter_relation_errors=False
        COAM Wait for gnb ready and cell setup
        ###set gnb1 cell2 PA to 0
        PA one cell 0 on and set other cell value 4 port for T348    cellid=${cell_id}[1]    set_value=${multi_gnb_PA}[0]
    END

DB_01 Step 1 UE1 attach to FDD cell as pcell
    comment    step1: ue attach to FDD cell as pcell
#    put btslog_ini file to ute
#    ...    server_ip=${appserver_addr}    server_username=${appserver_username}    server_password=${appserver_password}
#    Start capture syslog via btslog on ute
    IF    ${enb_instance} == ${enb_id}[0]     #TL348
        power_ue.Prepare UE    ue_type=${ue_type_qcom}    ue_index=${1}
        Start capture gNB log on master    filename=${log_name_DB_01_1}
        Step1: UE attach    ue_type=${ue_type_qcom}    ue_index=${1}
        Comment    trigger A1 to add scell
        ###set gnb1 cell3 PA to 0   #TL348
#        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id}[5]    value=${multi_gnb_PA_348}[0]    ip_addr=${att_ipaddr_1}
        Set the attenuation value of ports simultaneously
        ...    att_ports=${5Gcell5_ANT}    values=${5Gcell5_VALUES_DB_01}    att_ipaddr=${att_ipaddr_1}
    ELSE IF    ${enb_instance} == ${enb_id}[1]     #TL383
        power_ue.Prepare UE    ue_type=${ue_type_qcom}    ue_index=${1}
        Start capture gNB log on master    filename=${log_name_DB_01_1}
        Step1: UE attach    ue_type=${ue_type_qcom}    ue_index=${1}
        Comment    trigger A1 to add scell
        ###set gnb1 cell3 PA to 0   #TL348
#        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id}[5]    value=${multi_gnb_PA_348}[0]    ip_addr=${att_ipaddr_1}
        Set the attenuation value of ports simultaneously
        ...    att_ports=${5Gcell5_ANT}    values=${5Gcell5_VALUES_DB_01}    att_ipaddr=${att_ipaddr_1}
    END
    Sleep    5s    Reason=wait for Scell add success
    [Teardown]    Stop and download Logs on gNB on master    filename=${log_name_DB_01_1}

DB_01 Step 2 check logs for UL switchedUl scell addition successful on wireshark
    comment    step2: check ue UL switchedUl scell addition successful via wireshark
    Check wireshark log for 12149_DB_01    logname=${log_name_DB_01_1}
    ${c_rnti}=    Get RNTI-ID message    logname=${log_name_DB_01_1}
    Set Test Variable    ${c_rnti}

DB_01 Step 3 UE1 Start UL traffic on Pcell and Scell
    comment    step3: make UL traffic traffic on Pcell and Scell
    Prepare with PM counter time to caculate    period=start
    IF    ${enb_instance} == ${enb_id}[0]     #TL348
        Start only UL traffic and check tput common ue    ue_index=${1}    cellid=${1}    ue_type=${ue_type_qcom}    gnb_index=${0}
        ...                                tput_ul_cell=${expected_tput_ul}    ul_throughput=${Send_Tput_UL}    duration=${7200}
        ...                                ul_port=${UL_PORT}
    ELSE IF    ${enb_instance} == ${enb_id}[1]     #TL383
        Start only UL traffic and check tput common ue    ue_index=${1}    cellid=${1}    ue_type=${ue_type_qcom}    gnb_index=${0}
        ...                                tput_ul_cell=${expected_tput_ul}    ul_throughput=${Send_Tput_UL}    duration=${7200}
        ...                                ul_port=${UL_PORT}
    END

DB_01 Step 4 check counters
    comment    step4: check counters
    Prepare with PM counter time to caculate    period=end
    sleep    1min    reason=check KPIs xml report generated 1min
    Run Keyword And Continue On Failure    check counters for scell active success on pcell and scell

DB_01 Step 5 check peak throughput
    comment    step5: check peak throughput
    IF    ${enb_instance} == ${enb_id}[0]
        ${dl_expected_throughput_pcell}    ${ul_expected_throughput_pcell}=    get_expect_throughput
        ...    tl_scf_dir_path=${tl_scf_dir_path}    tl_scf_file_name=${tl_gnb1_scf_${sw_version}}    cell_id=${400}
        ${dl_expected_throughput_scell}    ${ul_expected_throughput_scell_origin}=    get_expect_throughput
        ...    tl_scf_dir_path=${tl_scf_dir_path}    tl_scf_file_name=${tl_gnb1_scf_${sw_version}}    cell_id=${700}
        # due to CB007491 Two Additional DMRS configured
        ${ul_expected_throughput_scell}    Evaluate    ${ul_expected_throughput_scell_origin} * ${0.85} * ${1.8}
        check intra gnb ca throughput    scellid=${4}    pcellid=${1}    gnb_prime=${0}    gnb_external=${0}
        ...    tput_ul_pcell=${ul_expected_throughput_pcell}    tput_ul_scell=${ul_expected_throughput_scell}
        ...    time=300s    ue_type=${ue_type_qcom}    ue_index=${1}
    ELSE IF    ${enb_instance} == ${enb_id}[1]
        ${dl_expected_throughput_pcell}    ${ul_expected_throughput_pcell}=    get_expect_throughput
        ...    tl_scf_dir_path=${tl_scf_dir_path}    tl_scf_file_name=${tl_gnb1_scf_${sw_version}}    cell_id=${400}
        ${dl_expected_throughput_scell}    ${ul_expected_throughput_scell_origin}=    get_expect_throughput
        ...    tl_scf_dir_path=${tl_scf_dir_path}    tl_scf_file_name=${tl_gnb1_scf_${sw_version}}    cell_id=${700}
        # due to CB007491 Two Additional DMRS configured
        ${ul_expected_throughput_scell}    Evaluate    ${ul_expected_throughput_scell_origin} * ${0.82} * ${1.8}
        check intra gnb ca throughput    scellid=${4}    pcellid=${1}    gnb_prime=${0}    gnb_external=${0}
        ...    tput_ul_pcell=${ul_expected_throughput_pcell}    tput_ul_scell=${ul_expected_throughput_scell}
        ...    time=300s    ue_type=${ue_type_qcom}    ue_index=${1}
    END

DB_01 Step 6 UE moves to position with poor radio link quality on TDD SCell
    comment    step6: UE moves to position with poor radio link quality on TDD SCell
    Start capture gNB log on master    filename=${log_name_DB_01_2}
    IF    ${enb_instance} == ${enb_id}[0]     #TL348
#        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id}[5]    value=${multi_gnb_PA_348}[1]    ip_addr=${att_ipaddr_1}
        Set the attenuation value of ports simultaneously by step
        ...    att_ports=${5Gcell5_ANT}    values=${5Gcell5_ANT_values}    att_ipaddr=${att_ipaddr_1}
    ELSE IF    ${enb_instance} == ${enb_id}[1]     #TL383
#        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id}[5]    value=${multi_gnb_PA_348}[1]    ip_addr=${att_ipaddr_1}
        Set the attenuation value of ports simultaneously by step
        ...    att_ports=${5Gcell5_ANT}    values=${5Gcell5_ANT_values}    att_ipaddr=${att_ipaddr_1}
    END
    Sleep    5s    Reason=wait for attenuation value to take effect
    [Teardown]    Stop and download Logs on gNB on master    filename=${log_name_DB_01_2}

DB_01 Step 7 check wireshark logs and TTI
    comment    step7: check wireshark logs and TTI
    IF    ${enb_instance} == ${enb_id}[0]
        Capture Ttitrace With Admin Mode and Convert format    names=${l2stream3_ttitrace_DB_01_1}    nr_phy_cell_ids=700
        ...    capture_time=2s
    ELSE IF    ${enb_instance} == ${enb_id}[1]
        Capture Ttitrace With Admin Mode and Convert format    names=${l2stream3_ttitrace_DB_01_1}    nr_phy_cell_ids=700
        ...    capture_time=2s
    END
    check_numOfLayers_field_contains_with_RANK    filename=${epc_log_path}/${l2stream3_ttitrace_DB_01_1}_ul.csv    check_data=RANK1

DB_01 Step 8 UE moves back to position with good radio link quality on TDD SCell
    comment    step8: UE moves back to position with good radio link quality on TDD SCell
    Start capture gNB log on master    filename=${log_name_DB_01_3}
    IF    ${enb_instance} == ${enb_id}[0]     #TL348
        ###set gnb1 cell3 PA to 0   #TL348
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id}[3]    value=${multi_gnb_PA_348}[0]    ip_addr=${att_ipaddr_1}
    ELSE IF    ${enb_instance} == ${enb_id}[1]     #TL383
        ###set gnb1 cell3 PA to 0   #TL383
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id}[3]    value=${multi_gnb_PA_348}[0]    ip_addr=${att_ipaddr_1}
    END
    Sleep    5s    Reason=wait for attenuation value to take effect
    [Teardown]    Stop and download Logs on gNB on master    filename=${log_name_DB_01_3}

DB_01 Step 9 check wireshark logs and TTI
    comment    step9: check wireshark logs and TTI
    IF    ${enb_instance} == ${enb_id}[0]
        Capture Ttitrace With Admin Mode and Convert format    names=${l2stream3_ttitrace_DB_01_2}    nr_phy_cell_ids=700
        ...    capture_time=2s
    ELSE IF    ${enb_instance} == ${enb_id}[1]
        Capture Ttitrace With Admin Mode and Convert format    names=${l2stream3_ttitrace_DB_01_2}    nr_phy_cell_ids=700
        ...    capture_time=2s
    END
    check_numOfLayers_field_contains_with_RANK    filename=${epc_log_path}/${l2stream3_ttitrace_DB_01_2}_ul.csv    check_data=RANK1

DB_01 Teardown
    robot_common_operations.Common Case Teardown
    AlarmWatchdog.remove_allow_alarms    fault_id=4291
    AlarmWatchdog.remove_allow_alarms    fault_id=4546
    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
    IF    ${enb_instance} == ${enb_id}[0]    #TL348
        Stop DL or UL traffic common ue    ue_index=${1}    ue_type=${ue_type_qcom}    direction=UL
        Step4: Detach UE    ue_type=${ue_type_qcom}    ue_index=${1}
    ELSE IF    ${enb_instance} == ${enb_id}[1]    #TL383
        Stop DL or UL traffic common ue    ue_index=${1}    ue_type=${ue_type_qcom}    direction=UL
        Step4: Detach UE    ue_type=${ue_type_qcom}    ue_index=${1}
    END
#    Stop capture syslog via btslog on ute
    IF    ${enb_instance} == ${enb_id}[0]    #TL348
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id}[1]    value=${multi_gnb_PA}[1]
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id}[5]    value=${multi_gnb_PA}[1]    ip_addr=${att_ipaddr_1}
        Setup for Env cell on-air for 2 gnb    is_commission_for_second_gnb=False    tl_scf_file_name=${tl_gnb1_scf_${sw_version}}
    ELSE IF    ${enb_instance} == ${enb_id}[1]    #TL383
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id}[1]    value=${multi_gnb_PA}[1]
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id}[5]    value=${multi_gnb_PA}[1]    ip_addr=${att_ipaddr_1}
        Setup for Env cell on-air for 2 gnb    is_commission_for_second_gnb=False    tl_scf_file_name=${tl_gnb1_scf_${sw_version}}
    END
    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
#    get and analysis syslog






Check wireshark log for 12149_DB_01
    [Arguments]    ${logname}
    Comment    check wireshark log for 12149_BB_04
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}
    check CB012149 UERadioCapabilityInfoIndication on wireshark
    Run Keyword If    '${release_info}' == 'SBTS24R3_ENB_0000'
    ...    check UL switchedUl scell additon successful on wireshark on 24R3
    ...    ELSE IF    '${release_info}' == 'SBTS25R1_ENB_0000'
    ...    check UL switchedUl scell additon successful on wireshark on 25R1
    ...    ELSE    check UL switchedUl scell additon successful on wireshark

check counters for scell active success on pcell and scell
    IF    ${enb_instance} == ${enb_id}[0]     #TL348
        IF    (${sw_version}[-4:-2] == 25 and ${sw_version}[-1] ==3) or (${sw_version}[-4:-2] > 25)
#            check counters for scell active success on pcell after_25r3_cni_141831
#            ...    KPI_file=CB012149_BB_04_scell_active_success_KPI.txt    para_index=${1}
            check counters for scell active success on pcell    KPI_file=CB012149_BB_04_scell_active_success_KPI.txt    para_index=${1}
            check counters for scell active success on scell    KPI_file=CB012149_BB_04_scell_active_success_KPI.txt    para_index=${3}
        ELSE
            check counters for scell active success on pcell    KPI_file=CB012149_BB_04_scell_active_success_KPI.txt    para_index=${1}
            check counters for scell active success on scell    KPI_file=CB012149_BB_04_scell_active_success_KPI.txt    para_index=${3}
        END
    ELSE IF    ${enb_instance} == ${enb_id}[1]     #TL383
        IF    (${sw_version}[-4:-2] == 25 and ${sw_version}[-1] ==3) or (${sw_version}[-4:-2] > 25)
#            check counters for scell active success on pcell after_25r3_cni_141831
#            ...    KPI_file=CB012149_BB_04_scell_active_success_KPI.txt    para_index=${1}
            check counters for scell active success on pcell    KPI_file=CB012149_BB_04_scell_active_success_KPI.txt    para_index=${1}
            check counters for scell active success on scell    KPI_file=CB012149_BB_04_scell_active_success_KPI.txt    para_index=${3}
        ELSE
            check counters for scell active success on pcell    KPI_file=CB012149_BB_04_scell_active_success_KPI.txt    para_index=${1}
            check counters for scell active success on scell    KPI_file=CB012149_BB_04_scell_active_success_KPI.txt    para_index=${3}
        END
    END

check counters for scell active success on pcell
    [Arguments]     ${KPI_file}    ${para_index}    ${index}=${0}
    ${dict_kpis_name_value}=    get kpi from pm file    KPI_file=${KPI_file}    para_index=${para_index}    index=${index}
    check required KPI value via pm file    KPI_name_list=${CB012149_BB_04_pcell_check_kpi_names_value_larger_zero}
    ...    check_field=larger_specified_value    dict_kpi_get=${dict_kpis_name_value}
    check required KPI value via pm file    KPI_name_list=${CB012149_BB_04_pcell_check_kpi_names_value_zero}
    ...    check_field=equal_specified_value    dict_kpi_get=${dict_kpis_name_value}

check counters for scell active success on pcell after_25r3_cni_141831
    [Arguments]     ${KPI_file}    ${para_index}    ${index}=${0}
    ${dict_kpis_name_value}=    get kpi from pm file    KPI_file=${KPI_file}    para_index=${para_index}    index=${index}
    check required KPI value via pm file    KPI_name_list=${CB012149_BB_04_after_25r3_cni_141831_pcell_check_kpi_names_value_larger_zero}
    ...    check_field=larger_specified_value    dict_kpi_get=${dict_kpis_name_value}
    check required KPI value via pm file    KPI_name_list=${CB012149_BB_04_after_25r3_cni_141831_pcell_check_kpi_names_value_zero}
    ...    check_field=equal_specified_value    dict_kpi_get=${dict_kpis_name_value}

check counters for scell active success on scell
    [Arguments]     ${KPI_file}    ${para_index}    ${index}=${0}
    ${dict_kpis_name_value}=    get kpi from pm file    KPI_file=${KPI_file}    para_index=${para_index}    index=${index}
    check required KPI value via pm file    KPI_name_list=${CB012149_BB_04_scell_check_kpi_names_value_larger_zero}
    ...    check_field=larger_specified_value    dict_kpi_get=${dict_kpis_name_value}
    check required KPI value via pm file    KPI_name_list=${CB012149_BB_04_scell_check_kpi_names_value_zero}
    ...    check_field=equal_specified_value    dict_kpi_get=${dict_kpis_name_value}

check value on TTI file DB_01
    [Arguments]    ${file_path}    ${queried_filed}    ${check_point}=BASICRELIABILITY
    ${required_data_list}=    get_value_from_csv_file    file_path=${file_path}    queried_filed=${queried_filed}
    ${no_duplicates_required_data_list}    Remove Duplicates    ${required_data_list}
    ${length}    Get Length    ${no_duplicates_required_data_list}
    should be equal    ${no_duplicates_required_data_list}[0]    ${check_point}
    Should Be Equal As Integers    ${length}    1

check intra gnb ca throughput
    [Arguments]    ${scellid}=1    ${pcellid}=1    ${gnb_prime}=${0}    ${gnb_external}=${1}
    ...    ${tput_dl_pcell}=NULL    ${tput_dl_scell}=NULL
    ...    ${tput_ul_pcell}=NULL    ${tput_ul_scell}=NULL
    ...    ${time}=30s    ${ue_type}=${ue1_type}
    ...    ${ue_index}=${0}
    Check_throughput with CA     tput_dl_pcell=${tput_dl_pcell}    tput_dl_scell=${tput_dl_scell}    tput_ul_pcell=${tput_ul_pcell}
    ...    tput_ul_scell=${tput_ul_scell}    scellid=${scellid}    pcellid=${pcellid}
    ...    gnb_prime=${gnb_prime}    gnb_external=${gnb_external}    duration=${time}
    ...    ue_type=${ue_type}     ue_index=${ue_index}

Set the attenuation value of ports simultaneously by step
    [Arguments]    ${att_ports}    ${values}    ${att_connection_port}=${att_connection_port}    ${att_ipaddr}=${att_ipaddr}
    ...    ${max_attenuation_value}=${127}    ${model}=${model}    ${att_api_port}=${att_api_port}    ${vendor}=${vendor}
    [Documentation]    ming.shi@nokia-sbell.com
    ...    This keyword is to set the test environment PA values, HBTE and topyoung.
    ...    ${att_ports}:List all the attenuator ports as int list (list[int])
    ...    ${value}:List the value of attenuator ports  int list  (list[Union[str,int,float]])
    ...    ${att_connection_port}:if PA is HBTE, the port is any one port.
    ...                           if PA is topyoung, the port is a List all the attenuator ports as int list
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_connection_port}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    ...    model=${model}
    ${total_range}=    Evaluate    list(set(${values}))[0] + ${1}
    FOR    ${i}    IN RANGE    ${total_range}
        ${new_values}=    Evaluate    [j + ${i} for j in ${5Gcell_ANT_initial_values}]
        att.set_ports_attenuation    ports=${att_ports}    values=${new_values}
        Sleep    1s
    END
    ${ports_values}=    att.read_ports_attenuation    ports=${att_ports}
    Lists Should Be Equal    list1=${values}    list2=${ports_values}    msg=Inconsistencies before and after modification

modify and commission scf file
    ${new_log_scf_path}=    change scf file
    ...    scf_path=${tl_scf_dir_path}    scf_name=${tl_gnb1_scf_${sw_version}}    new_scf_path=${TS_LOG_PATH_BASE}
    ${file_name}=    Evaluate    '${new_log_scf_path}'.split('/')[-1]
    Common Case TestLine Setup    is_commission=${True}    is_commission_for_second_gnb=${False}
    ...    scf_path=${TS_LOG_PATH_BASE}    golden_scf_name=${file_name}
    ...    skip_parameter_relation_errors=${False}
#    ${rc}    ${output}=    run and return rc and output    cd /opt/workspace/Tool/;./modify_numpy_version.sh