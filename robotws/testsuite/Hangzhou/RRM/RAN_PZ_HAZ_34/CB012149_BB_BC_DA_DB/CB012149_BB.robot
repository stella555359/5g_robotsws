*** Settings ***
Documentation
...    author: Shi Ming
...    contact: ming.shi@nokia-sbell.com
...    squal group: SG03
...    feature: CB012149-BB

Force Tags  CA_5G_RRM
...    PY36
Suite Setup    Run Keywords
...                            robot_common_operations.Common Suite Setup
...                            AND    Common Suite Setup for COAM
...                            AND    Get sagnb version for selenium
...                            AND    Set Suite Variable    ${tl_gnb1_scf_${sw_version}}    ${sw_version}_gNB1_Golden_SCF.xml
...                            AND    Setup for Env cell on-air for 2 gnb    is_commission_for_second_gnb=False
...                                   tl_scf_file_name=${tl_gnb1_scf_${sw_version}}
...                            AND    Get gnb release info

Suite Teardown     Common Suite Teardown for COAM    gnb_list=${gnb_list}

Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB012149_BB_BC_DA_DB/Resources/CB0012149_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/check_android_ue_l3_call_process.robot

*** Variables ***
${log_name_BB_02_1}    log_name_BB_02_1.pcap
${log_name_BB_02_2}    log_name_BB_02_2.pcap
${log_name_BB_04_1}    log_name_BB_04_1.pcap
${log_name_BB_10_1}    log_name_BB_10_1.pcap
${log_name_BB_10_2}    log_name_BB_10_2.pcap
${log_name_EDA_04474899_1}    log_name_EDA_04474899_1.pcap
${expected_tput_dl}    1
${Send_Tput_DL}        400M
${expected_tput_ul}    1
${Send_Tput_UL}        400M
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
@{multi_gnb_PA_348}    ${0}    ${50}    ${10}
@{multi_gnb_PA_383}    ${0}    ${50}    ${10}

${DL_PORT}    ${tl.ues[0].iperf_details.port}
${UL_PORT}    ${tl.ues[0].iperf_details.ssh_connection_details.port}
@{gnb_list}    ${0}
${tl_scf_dir_path}    /opt/workspace/CRT/Master/SCF_file/
${tl_scf_file_name1}    gNB1_Golden_SCF.xml
${tl_scf_file_name2}    gNB2_Golden_SCF.xml

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

@{5Gcell5_ANTS}    ${5Gcell5_ANT1}    ${5Gcell5_ANT2}    ${5Gcell5_ANT3}    ${5Gcell5_ANT4}
@{5Gcell5_VALUES_BB_10}    ${10}    ${20}    ${10}    ${10}

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
#${dxdata2_apn_348}    150 943
${dxdata2_apn_348}    95 1030
${click_access_point}    380 1060

${dxdata2}    ${tl.ues[0].pdn[0]}
${mdrb_apn_name}    ${tl.ues[0].pdn[1]}
${mdrb1_apn_name}    ${tl.ues[0].pdn[2]}

${X75_dxdata2_location}    959 940
${X75_mdrb_location}    959 1152
${X75_mdrb1_location}    959 1350

${ue0_type}                  ${tl.ues[0].capabilities[0]}
${ue1_type}                  ${tl.ues[1].capabilities[1]}

@{GNB_INDEX_list_snapshot}    ${0}

@{nr_rrc_k2_list_24R3}    2    3    2    3    2    2    2    2
@{nr_rrc_k2_list_25R1}    2    2    2    2    2    2    2    2
@{nr_rrc_k2_list}    2    2    2    2    2    2    2    2
@{nr_rrc_k2_list_typeB}    2    2    2    2    2    2    2    2
@{nr_rrc_mappingType_list_24R3}    0    0    0    0    0    0    1    1
@{nr_rrc_mappingType_list_25R1}    0    0    0    0    0    1    1    1
@{nr_rrc_mappingType_list}    0    0    0    0    1    1    1    0
@{nr_rrc_mappingType_list_typeB}    1    1    1    1    1    1    1    1
@{nr_rrc_startSymbolAndLength_list_24R3}    27    27    41    41    55    69    53    67
@{nr_rrc_startSymbolAndLength_list_25R1}    27    41    55    69    83    53    67    81
@{nr_rrc_startSymbolAndLength_list}    27    41    69    83    53    67    81    55
@{nr_rrc_startSymbolAndLength_list_typeB}    27    41    55    69    83    53    67    81

${l2stream3_ttitrace_BB_02_1}    l2stream3_ttitrace_BB_02_1
${l2stream3_ttitrace_EDA_04474899_1}    l2stream3_ttitrace_EDA_04474899_1
${l2stream3_ttitrace_BB_04_1}    l2stream3_ttitrace_BB_04_1
${l2stream3_ttitrace_BB_04_2}    l2stream3_ttitrace_BB_04_2
${l2stream3_ttitrace_BB_10_1}    l2stream3_ttitrace_BB_10_1
${l2stream3_ttitrace_BB_10_2}    l2stream3_ttitrace_BB_10_2

${ue_type_qcom}    ${tl.ues[1].capabilities[0]}

*** Test Cases ***
#[1]CB012149_BB_02_UL data scheduling with R16 UL Tx Switching for SCell activation_deactivation on Thor
#    [Documentation]    CB012149_BB_02
#    ...    1. UE attach to FDD cell as pcell
#	...    2. UL switchedUl scell addition successful via A1
#    ...    3. Start UL traffic on Pcell and Scell, and check TTI logs
#    ...    4. check related counters
#    ...    5. check peak throughout
#    [Tags]    CB012149_BB_02    CRT_TRUNK
#    [Timeout]    3 hours
#    [Setup]
#    BB_02 Prerequisite
#    BB_02 Step 1 UE1 attach to FDD cell as pcell
#    BB_02 Step 2 check logs for UL switchedUl scell addition successful on wireshark
#    BB_02 Step 3 UE1 Start UL traffic on Pcell and Scell
#    BB_02 Step 4 check counters
#    Run Keyword And Continue On Failure    BB_02 Step 5 check logs on TTI
#    BB_02 Step 6 check peak throughput
#    [Teardown]    BB_02 Teardown

#[1]CB012149_BB_04_DLUL data scheduling with R16 UL Tx Switching for SCell activation_deactivation Alt3 on Thor
#    [Documentation]
#    ...    1. UE attach to FDD cell as pcell
#	...    2. UL switchedUl scell addition successful via blind
#	...    3. start DL traffic on Pcell and Scell, and check TTI logs
#    ...    4. Start UL traffic on Pcell and Scell, and check TTI logs
#    ...    5. check related counters
#    ...    6. check peak throughout
#    [Tags]    CB012149_BB_04    CRT_TRUNK
#    [Setup]
#    BB_04 Prerequisite
#    BB_04 Step 1 UE1 attach to FDD cell as pcell
#    BB_04 Step 2 check logs for UL switchedUl scell addition successful on wireshark
#    BB_04 Step 3 UE1 Start DL traffic on Pcell and Scell
#    BB_04 Step 4 check logs on TTI
#    BB_04 Step 5 UE1 Start UL traffic on Pcell and Scell
#    BB_04 Step 6 check counters
#    Run Keyword And Continue On Failure    BB_04 Step 7 check logs on TTI
#    BB_04 Step 8 check peak throughput
#    [Teardown]    BB_04 Teardown

[1]CB012149_BB_10_R16 UL Tx Switching 256QAM UE DLUL peak throughput - PUSCH mapping type B 1116 0ms on Thor Mixed with R15 UE
    [Documentation]
    ...    1. UE(12149) attach to FDD cell as pcell
	...    2. UL switchedUl scell addition successful via blind
	...    3. UE(no 12149) attach to FDD cell as pcell
	...    4. UL switchedUl scell addition successful via blind
    ...    5. UE(12149) Start UL traffic on Pcell and Scell, and check TTI logs
    ...    6. UE(no 12149) Start UL traffic on Pcell and Scell, and check TTI logs
    ...    7. UE(12149) check related counters
    ...    8. UE(12149) check peak throughout
    [Tags]    CB012149_BB_10    CRT_TRUNK
    [Setup]
    BB_10 Prerequisite
    BB_10 Step 1 UE1 attach to FDD cell as pcell
    BB_10 Step 2 check logs for UL switchedUl scell addition successful on wireshark
    BB_10 Step 3 UE0 attach to FDD cell as pcell
    BB_10 Step 4 UE0 Start UL traffic on Pcell and Scell
    BB_10 Step 5 check logs on TTI
    BB_10 Step 6 UE1 Start UL traffic on Pcell and Scell
    BB_10 Step 7 check counters
    BB_10 Step 8 check logs on TTI
    BB_10 Step 9 check peak throughput
    [Teardown]    BB_10 Teardown


*** Keywords ***
BB_02 Prerequisite
    robot_common_operations.Common Case Setup
    ${release_name}    get_new_download_link_release    release_url=${download_link}
    ${release}=    Split String    string=${release_info}    separator=_
    ${compare_result}=    Run Keyword And Return Status    Should Contain    ${release_name}    ${release}[0]
    Set Test Variable    ${compare_result}
    IF    ${compare_result} == False
        EDA_04474899_steps
    END
    put btslog_ini file to ute
    ...    server_ip=${appserver_addr}    server_username=${appserver_username}    server_password=${appserver_password}
    Start capture syslog via btslog on ute
    Check UE device status with adb recover    ue_index=${1}
    comment    Prerequisite
    IF    ${enb_instance} == ${enb_id}[0]     #TL348
#        Online delete parmeters    parameters_to_update=${PARAM_12149_delete_gnb1_BB_02_initial}    timeout=${300}
        Online modify parmeters     parameters_to_update=${PARAM_12149_gnb1_BB_02_348}    skip_parameter_relation_errors=False
        COAM Wait for gnb ready and cell setup
        PA one cell 0 on and set other cell value    cellid=${cell_id}[2]    set_value=${multi_gnb_PA}[0]
    ELSE IF    ${enb_instance} == ${enb_id}[1]     #TL383
        Online modify parmeters     parameters_to_update=${PARAM_12149_gnb1_BB_02_383}    skip_parameter_relation_errors=False
        COAM Wait for gnb ready and cell setup
        Online modify parmeters     parameters_to_update=${PARAM_12149_lte_common_383_WA}    skip_parameter_relation_errors=False
        ###set gnb1 cell1 PA to 0
        PA one cell 0 on and set other cell value 4 port    cellid=${cell_id}[1]    set_value=${multi_gnb_PA}[0]
    END
    [Teardown]    Stop capture syslog via btslog on ute

BB_02 Step 1 UE1 attach to FDD cell as pcell
    comment    step1: ue attach to FDD cell as pcell
    IF    ${enb_instance} == ${enb_id}[0]    #TL348
        CB0012149_common_keywords.Prepare UE For MTK80    ue_index=${1}    cap_index=${0}
    ELSE IF    ${enb_instance} == ${enb_id}[1]     #TL383
        IF    ${compare_result} != False
            power_ue.Prepare UE    ue_type=${ue_type_qcom}    ue_index=${1}
        END
    END
    Start capture gNB log on master    filename=${log_name_BB_02_1}
    IF    ${enb_instance} == ${enb_id}[0]     #TL348
        mtk ue attach on 348
        Comment    trigger A1 to add scell
        Change Attenuation value    cell=5Gcell${cell_id}[3]    value=${multi_gnb_PA_348}[0]
    ELSE IF    ${enb_instance} == ${enb_id}[1]     #TL383
        Step1: UE attach    ue_type=${ue_type_qcom}    ue_index=${1}
        Comment    trigger A1 to add scell
        Change Attenuation value 4 port    cell=5Gcells${cell_id}[2]    value=${multi_gnb_PA_383}[0]
    END
    Sleep    5s    Reason=wait for Scell add success
    [Teardown]    Stop and download Logs on gNB on master    filename=${log_name_BB_02_1}

BB_02 Step 2 check logs for UL switchedUl scell addition successful on wireshark
    comment    step2: check ue UL switchedUl scell addition successful via wireshark
    Check wireshark log for 12149_BB_04    logname=${log_name_BB_02_1}
    ${c_rnti}=    Get RNTI-ID message    logname=${log_name_BB_02_1}
    Set Test Variable    ${c_rnti}

BB_02 Step 3 UE1 Start UL traffic on Pcell and Scell
    comment    step3: make UL traffic traffic on Pcell and Scell
    Prepare with PM counter time to caculate    period=start
    IF    ${enb_instance} == ${enb_id}[0]     #TL348
        Start only UL traffic and check tput    ue_index=${1}    cellid=${2}    ue_type=${ue1_type}    gnb_index=${0}
        ...                                tput_ul_cell=${expected_tput_ul}    ul_throughput=${Send_Tput_UL}    duration=${7200}
    ELSE IF    ${enb_instance} == ${enb_id}[1]     #TL383
        Start only UL traffic and check tput common ue    ue_index=${1}    cellid=${1}    ue_type=${ue_type_qcom}    gnb_index=${0}
        ...                                tput_ul_cell=${expected_tput_ul}    ul_throughput=${Send_Tput_UL}    duration=${7200}
        ...                                ul_port=${UL_PORT}
    END

BB_02 Step 4 check counters
    comment    step4: check counters
    Prepare with PM counter time to caculate    period=end
    sleep    1min    reason=check KPIs xml report generated 1min
    check counters for scell active success on pcell and scell

BB_02 Step 5 check logs on TTI
    comment    step5: check logs on TTI
    IF    ${enb_instance} == ${enb_id}[0]    #TL348
        Capture Ttitrace With Admin Mode and Convert format    names=${l2stream3_ttitrace_BB_02_1}    nr_phy_cell_ids=40,348
        ...    capture_time=2s
        ${slot_1_6}    ${slot_3_8}=    check_required_filed_data
        ...    filename=${epc_log_path}/${l2stream3_ttitrace_BB_02_1}_ul.csv    c_rnti=${c_rnti}    physCellId=40
    ELSE IF    ${enb_instance} == ${enb_id}[1]    #TL383
        Capture Ttitrace With Admin Mode and Convert format    names=${l2stream3_ttitrace_BB_02_1}    nr_phy_cell_ids=38,383
        ...    capture_time=2s
        ${slot_1_6}    ${slot_3_8}=    check_required_filed_data
        ...    filename=${epc_log_path}/${l2stream3_ttitrace_BB_02_1}_ul.csv    c_rnti=${c_rnti}    physCellId=38
    END
    Should Be True    condition=${slot_1_6}>0    msg=no satisfied data in slot 1 or slot 6
    Should Be True    condition=${slot_3_8}>0    msg=no satisfied data in slot 3 or slot 8

BB_02 Step 6 check peak throughput
    comment    step6: check peak throughput
    IF    ${enb_instance} == ${enb_id}[0]    #TL348
        ${dl_expected_throughput_pcell}    ${ul_expected_throughput_pcell}=    get_expect_throughput
        ...    tl_scf_dir_path=${tl_scf_dir_path}    tl_scf_file_name=${tl_gnb1_scf_${sw_version}}    cell_id=${2}
        ${dl_expected_throughput_scell}    ${ul_expected_throughput_scell}=    get_expect_throughput
        ...    tl_scf_dir_path=${tl_scf_dir_path}    tl_scf_file_name=${tl_gnb1_scf_${sw_version}}    cell_id=${3}
        check intra gnb ca throughput    scellid=${3}    pcellid=${2}    gnb_prime=${0}    gnb_external=${0}
        ...    tput_ul_pcell=${ul_expected_throughput_pcell}    tput_ul_scell=${ul_expected_throughput_scell}
        ...    time=300s    ue_type=${ue_type_qcom}    ue_index=${1}
    ELSE IF    ${enb_instance} == ${enb_id}[1]    #TL383
        ${dl_expected_throughput_pcell}    ${ul_expected_throughput_pcell}=    get_expect_throughput
        ...    tl_scf_dir_path=${tl_scf_dir_path}    tl_scf_file_name=${tl_gnb1_scf_${sw_version}}    cell_id=${1}
        ${dl_expected_throughput_scell}    ${ul_expected_throughput_scell}=    get_expect_throughput
        ...    tl_scf_dir_path=${tl_scf_dir_path}    tl_scf_file_name=${tl_gnb1_scf_${sw_version}}    cell_id=${2}
        check intra gnb ca throughput    scellid=${2}    pcellid=${1}    gnb_prime=${0}    gnb_external=${0}
        ...    tput_ul_pcell=${ul_expected_throughput_pcell}    tput_ul_scell=${ul_expected_throughput_scell}
        ...    time=300s    ue_type=${ue_type_qcom}    ue_index=${1}
    END

BB_02 Teardown
    robot_common_operations.Common Case Teardown
    IF    ${enb_instance} == ${enb_id}[0]    #TL348
        Stop DL or UL traffic    ue_index=${1}    ue_type=${ue1_type}    direction=UL
        CB0012149_common_keywords.Do UE Detach    ue_index=${1}
    ELSE IF    ${enb_instance} == ${enb_id}[1]    #TL383
        Stop DL or UL traffic common ue    ue_index=${1}    ue_type=${ue_type_qcom}    direction=UL
        Step4: Detach UE    ue_type=${ue_type_qcom}    ue_index=${1}
    END
    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
    IF    ${enb_instance} == ${enb_id}[0]    #TL348
        Change Attenuation value    cell=5Gcell${cell_id}[2]    value=${multi_gnb_PA}[1]
        Change Attenuation value    cell=5Gcell${cell_id}[3]    value=${multi_gnb_PA}[1]
        Online delete parmeters    parameters_to_update=${PARAM_12149_delete_gnb1_BB_02}    timeout=${300}
        Online modify parmeters    parameters_to_update=${PARAM_12149_recover_gnb1_BB_02_348}    skip_parameter_relation_errors=False
        COAM Wait for gnb ready and cell setup
    ELSE IF    ${enb_instance} == ${enb_id}[1]    #TL383
        Change Attenuation value 4 port    cell=5Gcells${cell_id}[1]    value=${multi_gnb_PA}[0]
        Change Attenuation value 4 port    cell=5Gcells${cell_id}[2]    value=${multi_gnb_PA}[0]
        Online delete parmeters    parameters_to_update=${PARAM_12149_delete_gnb1_BB_02_383}    timeout=${300}
        Online modify parmeters    parameters_to_update=${PARAM_12149_recover_gnb1_BB_02_383}    skip_parameter_relation_errors=False
        COAM Wait for gnb ready and cell setup
        Online modify parmeters    parameters_to_update=${PARAM_12149_recover_lte_common_383_WA}    skip_parameter_relation_errors=False
        COAM Wait for gnb ready and cell setup
    END
    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
    get and analysis syslog






BB_04 Prerequisite
    robot_common_operations.Common Case Setup
    Check UE device status with adb recover    ue_index=${1}
    comment    Prerequisite
    IF    ${enb_instance} == ${enb_id}[0]    #TL348
        Online modify parmeters     parameters_to_update=${PARAM_12149_gnb1_BB_04_348}    skip_parameter_relation_errors=False
        COAM Wait for gnb ready and cell setup
        ###set gnb1 cell2 PA to 0
        PA one cell 0 on and set other cell value    cellid=${cell_id}[2]    set_value=${multi_gnb_PA}[0]
    ELSE IF    ${enb_instance} == ${enb_id}[1]    #TL383
        Online modify parmeters     parameters_to_update=${PARAM_12149_gnb1_BB_04_383}    skip_parameter_relation_errors=False
        COAM Wait for gnb ready and cell setup
        Online modify parmeters     parameters_to_update=${PARAM_12149_lte_common_383_WA}    skip_parameter_relation_errors=False
        ###set gnb1 cell1 PA to 0
        PA one cell 0 on and set other cell value 4 port    cellid=${cell_id}[1]    set_value=${multi_gnb_PA}[0]
    END

BB_04 Step 1 UE1 attach to FDD cell as pcell
    comment    step1: ue attach to FDD cell as pcell
    IF    ${enb_instance} == ${enb_id}[0]    #TL348
        CB0012149_common_keywords.Prepare UE For MTK80    ue_index=${1}    cap_index=${0}
    ELSE IF    ${enb_instance} == ${enb_id}[1]    #TL383
        power_ue.Prepare UE    ue_type=${ue_type_qcom}    ue_index=${1}
    END
    Start capture gNB log on master    filename=${log_name_BB_04_1}
    IF    ${enb_instance} == ${enb_id}[0]    #TL348
        mtk ue attach on 348
    ELSE IF    ${enb_instance} == ${enb_id}[1]    #TL383
        Step1: UE attach    ue_type=${ue_type_qcom}    ue_index=${1}
    END
    [Teardown]    Stop and download Logs on gNB on master    filename=${log_name_BB_04_1}

BB_04 Step 2 check logs for UL switchedUl scell addition successful on wireshark
    comment    step2: check ue UL switchedUl scell addition successful via wireshark
    Check wireshark log for 12149_BB_04    logname=${log_name_BB_04_1}
    ${c_rnti}=    Get RNTI-ID message    logname=${log_name_BB_04_1}
    Set Test Variable    ${c_rnti}

BB_04 Step 3 UE1 Start DL traffic on Pcell and Scell
    comment    step3: make DL traffic traffic on Pcell and Scell
    put btslog_ini file to ute
    ...    server_ip=${appserver_addr}    server_username=${appserver_username}    server_password=${appserver_password}
    Start capture syslog via btslog on ute
    IF    ${enb_instance} == ${enb_id}[0]    #TL348
        ###set gnb1 cell3 PA to 0   #TL348
        Change Attenuation value    cell=5Gcell${cell_id}[3]    value=${multi_gnb_PA_348}[0]
        Sleep    5s    Reason=wait for PA change success
        Start only DL traffic and check tput    ue_index=${1}    cellid=${2}    ue_type=${ue1_type}    gnb_index=${0}
        ...                                tput_dl_cell=${expected_tput_dl}    dl_throughput=${Send_Tput_DL}    duration=${7200}
    ELSE IF    ${enb_instance} == ${enb_id}[1]     #TL383
        ###set gnb1 cell2 PA to 0   #TL383
        Change Attenuation value 4 port    cell=5Gcells${cell_id}[2]    value=${multi_gnb_PA_383}[0]
        Sleep    5s    Reason=wait for PA change success
        Start only DL traffic and check tput common ue    ue_index=${1}    cellid=${1}    ue_type=${ue_type_qcom}    gnb_index=${0}
        ...                                tput_dl_cell=${expected_tput_dl}    dl_throughput=${Send_Tput_DL}    duration=${7200}
        ...                                dl_port=${DL_PORT}
    END
    [Teardown]    Stop capture syslog via btslog on ute

BB_04 Step 4 check logs on TTI
    comment    step4: check DL logs on TTI
    IF    ${enb_instance} == ${enb_id}[0]
        Capture Ttitrace With Admin Mode and Convert format    names=${l2stream3_ttitrace_BB_04_1}    nr_phy_cell_ids=40,348
        ...    capture_time=2s
        ${slot_1_6}    ${slot_3_8}=    check_required_filed_data
        ...    filename=${epc_log_path}/${l2stream3_ttitrace_BB_04_1}_ul.csv    c_rnti=${c_rnti}    physCellId=40
    ELSE IF    ${enb_instance} == ${enb_id}[1]
        Capture Ttitrace With Admin Mode and Convert format    names=${l2stream3_ttitrace_BB_04_1}    nr_phy_cell_ids=38,383
        ...    capture_time=2s
        ${slot_1_6}    ${slot_3_8}=    check_required_filed_data
        ...    filename=${epc_log_path}/${l2stream3_ttitrace_BB_04_1}_ul.csv    c_rnti=${c_rnti}    physCellId=38
    END
    Should Be True    condition=${slot_1_6}>0    msg=no satisfied data in slot 1 or slot 6
    Should Be True    condition=${slot_3_8}>0    msg=no satisfied data in slot 3 or slot 8

BB_04 Step 5 UE1 Start UL traffic on Pcell and Scell
    comment    step5: make UL traffic traffic on Pcell and Scell
    IF    ${enb_instance} == ${enb_id}[0]    #TL348
        Start only UL traffic and check tput    ue_index=${1}    cellid=${2}    ue_type=${ue1_type}    gnb_index=${0}
        ...                                tput_ul_cell=${expected_tput_ul}    ul_throughput=${Send_Tput_UL}    duration=${7200}
        Prepare with PM counter time to caculate    period=start
        Change Attenuation value    cell=5Gcell${cell_id}[3]    value=${multi_gnb_PA_348}[1]
        Sleep    1m
        Change Attenuation value    cell=5Gcell${cell_id}[3]    value=${multi_gnb_PA_348}[0]
        Sleep    1m
    ELSE IF    ${enb_instance} == ${enb_id}[1]    #TL383
        Start only UL traffic and check tput common ue    ue_index=${1}    cellid=${1}    ue_type=${ue_type_qcom}    gnb_index=${0}
        ...                                tput_ul_cell=${expected_tput_ul}    ul_throughput=${Send_Tput_UL}    duration=${7200}
        ...                                ul_port=${UL_PORT}
        Prepare with PM counter time to caculate    period=start
        Change Attenuation value 4 port    cell=5Gcells${cell_id}[2]    value=${multi_gnb_PA_383}[1]
        Sleep    1m
        Change Attenuation value 4 port    cell=5Gcells${cell_id}[2]    value=${multi_gnb_PA_383}[0]
        Sleep    1m
    END

BB_04 Step 6 check counters
    comment    step6: check counters
    Prepare with PM counter time to caculate    period=end
    sleep    1min    reason=check KPIs xml report generated 1min
    check counters for scell active success on pcell and scell

BB_04 Step 7 check logs on TTI
    comment    step7: check UL logs on TTI
    IF    ${enb_instance} == ${enb_id}[0]
        Capture Ttitrace With Admin Mode and Convert format    names=${l2stream3_ttitrace_BB_04_2}    nr_phy_cell_ids=40,348
        ...    capture_time=2s
        ${slot_1_6}    ${slot_3_8}=    check_required_filed_data
        ...    filename=${epc_log_path}/${l2stream3_ttitrace_BB_04_2}_ul.csv    c_rnti=${c_rnti}    physCellId=40
    ELSE IF    ${enb_instance} == ${enb_id}[1]
        Capture Ttitrace With Admin Mode and Convert format    names=${l2stream3_ttitrace_BB_04_2}    nr_phy_cell_ids=38,383
        ...    capture_time=2s
        ${slot_1_6}    ${slot_3_8}=    check_required_filed_data
        ...    filename=${epc_log_path}/${l2stream3_ttitrace_BB_04_2}_ul.csv    c_rnti=${c_rnti}    physCellId=38
    END
    Should Be True    condition=${slot_1_6}>0    msg=no satisfied data in slot 1 or slot 6
    Should Be True    condition=${slot_3_8}>0    msg=no satisfied data in slot 3 or slot 8

BB_04 Step 8 check peak throughput
    comment    step8: check peak throughput
    IF    ${enb_instance} == ${enb_id}[0]
        ${dl_expected_throughput_pcell}    ${ul_expected_throughput_pcell}=    get_expect_throughput
        ...    tl_scf_dir_path=${tl_scf_dir_path}    tl_scf_file_name=${tl_gnb1_scf_${sw_version}}    cell_id=${2}
        ${dl_expected_throughput_scell}    ${ul_expected_throughput_scell}=    get_expect_throughput
        ...    tl_scf_dir_path=${tl_scf_dir_path}    tl_scf_file_name=${tl_gnb1_scf_${sw_version}}    cell_id=${3}
        check intra gnb ca throughput    scellid=${3}    pcellid=${2}    gnb_prime=${0}    gnb_external=${0}
        ...    tput_ul_pcell=${ul_expected_throughput_pcell}    tput_ul_scell=${ul_expected_throughput_scell}
        ...    time=300s    ue_type=${ue1_type}    ue_index=${1}
    ELSE IF    ${enb_instance} == ${enb_id}[1]
        ${dl_expected_throughput_pcell}    ${ul_expected_throughput_pcell}=    get_expect_throughput
        ...    tl_scf_dir_path=${tl_scf_dir_path}    tl_scf_file_name=${tl_gnb1_scf_${sw_version}}    cell_id=${1}
        ${dl_expected_throughput_scell}    ${ul_expected_throughput_scell}=    get_expect_throughput
        ...    tl_scf_dir_path=${tl_scf_dir_path}    tl_scf_file_name=${tl_gnb1_scf_${sw_version}}    cell_id=${2}
        check intra gnb ca throughput    scellid=${2}    pcellid=${1}    gnb_prime=${0}    gnb_external=${0}
        ...    tput_ul_pcell=${ul_expected_throughput_pcell}    tput_ul_scell=${ul_expected_throughput_scell}
        ...    time=300s    ue_type=${ue_type_qcom}    ue_index=${1}
    END

BB_04 Teardown
    robot_common_operations.Common Case Teardown
    AlarmWatchdog.remove_allow_alarms    fault_id=1932
    IF    ${enb_instance} == ${enb_id}[0]
        Stop DL or UL traffic    ue_index=${1}    ue_type=${ue1_type}    direction=DL
        Stop DL or UL traffic    ue_index=${1}    ue_type=${ue1_type}    direction=UL
        CB0012149_common_keywords.Do UE Detach    ue_index=${1}
    ELSE IF    ${enb_instance} == ${enb_id}[1]
        Stop DL or UL traffic common ue    ue_index=${1}    ue_type=${ue_type_qcom}    direction=DL
        Stop DL or UL traffic common ue    ue_index=${1}    ue_type=${ue_type_qcom}    direction=UL
        Step4: Detach UE    ue_type=${ue_type_qcom}    ue_index=${1}
    END
    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
    IF    ${enb_instance} == ${enb_id}[0]
        Change Attenuation value    cell=5Gcell${cell_id}[2]    value=${multi_gnb_PA}[1]
        Change Attenuation value    cell=5Gcell${cell_id}[3]    value=${multi_gnb_PA}[1]
        Online delete parmeters    parameters_to_update=${PARAM_12149_delete_gnb1_BB_04_348}    timeout=${300}
        Online modify parmeters    parameters_to_update=${PARAM_12149_recover_gnb1_BB_04_348}    skip_parameter_relation_errors=False
        COAM Wait for gnb ready and cell setup
    ELSE IF    ${enb_instance} == ${enb_id}[1]
        Change Attenuation value 4 port    cell=5Gcells${cell_id}[1]    value=${multi_gnb_PA}[1]
        Change Attenuation value 4 port    cell=5Gcells${cell_id}[2]    value=${multi_gnb_PA}[1]
        Online delete parmeters    parameters_to_update=${PARAM_12149_delete_gnb1_BB_04_383}    timeout=${300}
        Online modify parmeters    parameters_to_update=${PARAM_12149_recover_gnb1_BB_04_383}    skip_parameter_relation_errors=False
        COAM Wait for gnb ready and cell setup
        Online modify parmeters    parameters_to_update=${PARAM_12149_recover_lte_common_383_WA}    skip_parameter_relation_errors=False
        COAM Wait for gnb ready and cell setup
    END
    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
    get and analysis syslog






BB_10 Prerequisite
    robot_common_operations.Common Case Setup    allowed_faults_ids=4291,4546
    AlarmWatchdog.add_allow_alarms    fault_id=4291
    AlarmWatchdog.add_allow_alarms    fault_id=4546
    Check UE device status with adb recover    ue_index=${0}
    Check UE device status with adb recover    ue_index=${1}
#    ${release_name}    get_new_download_link_release    release_url=${download_link}
#    ${release}=    Split String    string=${release_info}    separator=_
#    ${compare_result}=    Run Keyword And Return Status    Should Contain    ${release_name}    ${release}[0]
#    Set Test Variable    ${compare_result}
#    IF    ${compare_result} == False
#        EDA_04474899_steps
#    END
    comment    Prerequisite
    IF    ${enb_instance} == ${enb_id}[0]
#        Online modify parmeters     parameters_to_update=${PARAM_12149_gnb1_72a_to_72e}
#        Online delete objects    parameters_to_update=${OBJECT_DELETE_12149_gnb1_72a_to_72e}    timeout=${300}
        convert_to_json_file    data=${CB012149_72a_to_72e}    json_path=${case_logs_path}${CB012149_72a_to_72e_json_file_name}
        recommission for 72a to 72e    json_file=${case_logs_path}${CB012149_72a_to_72e_json_file_name}    skip_parameter_relation_errors=False
        COAM Wait for gnb ready and cell setup
        Online modify parmeters     parameters_to_update=${PARAM_12149_gnb1_BB_10_348}    skip_parameter_relation_errors=False
        COAM Wait for gnb ready and cell setup
        ###set gnb1 cell1 PA to 0
        PA one cell 0 on and set other cell value 4 port for T348    cellid=${cell_id_348}[1]    set_value=${multi_gnb_PA}[0]
    ELSE IF    ${enb_instance} == ${enb_id}[1]
#        Online modify parmeters     parameters_to_update=${PARAM_12149_gnb1_72a_to_72e}
#        Online delete objects    parameters_to_update=${OBJECT_DELETE_12149_gnb1_72a_to_72e}    timeout=${300}
        convert_to_json_file    data=${CB012149_72a_to_72e}    json_path=${case_logs_path}${CB012149_72a_to_72e_json_file_name}
        recommission for 72a to 72e    json_file=${case_logs_path}${CB012149_72a_to_72e_json_file_name}    skip_parameter_relation_errors=False
        COAM Wait for gnb ready and cell setup
        Online modify parmeters     parameters_to_update=${PARAM_12149_gnb1_BB_10_348}    skip_parameter_relation_errors=False
        COAM Wait for gnb ready and cell setup
        ###set gnb1 cell1 PA to 0
        PA one cell 0 on and set other cell value 4 port for T348    cellid=${cell_id_348}[1]    set_value=${multi_gnb_PA}[0]
    END

BB_10 Step 1 UE1 attach to FDD cell as pcell
    comment    step1: ue attach to FDD cell as pcell
    power_ue.Prepare UE    ue_type=${ue_type_qcom}    ue_index=${1}
    Start capture gNB log on master    filename=${log_name_BB_10_1}
    Step1: UE attach    ue_type=${ue_type_qcom}    ue_index=${1}
    [Teardown]    Stop and download Logs on gNB on master    filename=${log_name_BB_10_1}

BB_10 Step 2 check logs for UL switchedUl scell addition successful on wireshark
    comment    step2: check ue UL switchedUl scell addition successful via wireshark
    Check wireshark log for 12149_BB_04    logname=${log_name_BB_10_1}    puschMappingType=TypeB
    ${c_rnti}=    Get RNTI-ID message    logname=${log_name_BB_10_1}
    Set Test Variable    ${c_rnti}

BB_10 Step 3 UE0 attach to FDD cell as pcell
    comment    step3: ue attach to FDD cell as pcell
    Power_ue.Prepare UE    ue_type=${ue0_type}    ue_index=${0}
    Wait Until Keyword Succeeds    3x    10s    Run Keywords
    ...    set apn dxdata2
    ...    AND    make WA with Samsung S21
#    put btslog_ini file to ute
#    ...    server_ip=${appserver_addr}    server_username=${appserver_username}    server_password=${appserver_password}
#    Start capture syslog via btslog on ute
    Start capture gNB log on master    filename=${log_name_BB_10_2}
    Attach and check power UE    ue_type=${ue0_type}    ue_index=${0}    gnb_index=${0}
    [Teardown]    Stop and download Logs on gNB on master    filename=${log_name_BB_10_2}
#    ...    AND    Stop capture syslog via btslog on ute

BB_10 Step 4 UE0 Start UL traffic on Pcell and Scell
    comment    step4: make UL traffic traffic on Pcell and Scell
    IF    ${enb_instance} == ${enb_id}[0]     #TL348
        ###set gnb1 cell3 PA to 0
#        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id}[5]    value=${multi_gnb_PA_348}[2]    ip_addr=${att_ipaddr_1}
        Set the attenuation value of ports simultaneously
        ...    att_ports=${5Gcell5_ANTS}    values=${5Gcell5_VALUES_BB_10}    att_ipaddr=${att_ipaddr_1}
    ELSE IF    ${enb_instance} == ${enb_id}[1]     #TL383
        ###set gnb1 cell2 PA to 0
#        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id}[5]    value=${multi_gnb_PA_348}[2]    ip_addr=${att_ipaddr_1}
        Set the attenuation value of ports simultaneously
        ...    att_ports=${5Gcell5_ANTS}    values=${5Gcell5_VALUES_BB_10}    att_ipaddr=${att_ipaddr_1}
    END
    Sleep    5s    Reason=wait for PA change success
    Set Suite Variable    ${iperf_button}    690 365
    ${ue0_ul_port}=    Evaluate    ${UL_PORT}+100
    IF    ${enb_instance} == ${enb_id}[0]     #TL348
        Start only UL traffic and check tput common ue    ue_index=${0}    cellid=${1}    ue_type=${ue0_type}    gnb_index=${0}
        ...                                tput_ul_cell=${expected_tput_ul}    ul_throughput=${Send_Tput_UL}    duration=${7200}
        ...                                ul_port=${ue0_ul_port}
    ELSE IF    ${enb_instance} == ${enb_id}[1]     #TL383
        Start only UL traffic and check tput common ue    ue_index=${0}    cellid=${1}    ue_type=${ue0_type}    gnb_index=${0}
        ...                                tput_ul_cell=${expected_tput_ul}    ul_throughput=${Send_Tput_UL}    duration=${7200}
        ...                                ul_port=${ue0_ul_port}
    END

BB_10 Step 5 check logs on TTI
    comment    step5: check UL logs on TTI
    IF    ${enb_instance} == ${enb_id}[0]
        Capture Ttitrace With Admin Mode and Convert format    names=${l2stream3_ttitrace_BB_10_1}    nr_phy_cell_ids=400,700
        ...    capture_time=2s
        ${slot_1_6}    ${slot_3_8}=    check_required_filed_data
        ...    filename=${epc_log_path}/${l2stream3_ttitrace_BB_10_1}_ul.csv    c_rnti=${c_rnti}    physCellId=400
    ELSE IF    ${enb_instance} == ${enb_id}[1]
        Capture Ttitrace With Admin Mode and Convert format    names=${l2stream3_ttitrace_BB_10_1}    nr_phy_cell_ids=400,700
        ...    capture_time=2s
        ${slot_1_6}    ${slot_3_8}=    check_required_filed_data
        ...    filename=${epc_log_path}/${l2stream3_ttitrace_BB_10_1}_ul.csv    c_rnti=${c_rnti}    physCellId=400
    END

BB_10 Step 6 UE1 Start UL traffic on Pcell and Scell
    comment    step6: make UL traffic traffic on Pcell and Scell
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

BB_10 Step 7 check counters
    comment    step7: check counters
    Prepare with PM counter time to caculate    period=end
    sleep    1min    reason=check KPIs xml report generated 1min
    Run Keyword And Continue On Failure    check counters for scell active success on pcell and scell

BB_10 Step 8 check logs on TTI
    comment    step8: check UL logs on TTI
    IF    ${enb_instance} == ${enb_id}[0]
        Capture Ttitrace With Admin Mode and Convert format    names=${l2stream3_ttitrace_BB_10_2}    nr_phy_cell_ids=400,700
        ...    capture_time=2s
        ${slot_1_6}    ${slot_3_8}=    check_required_filed_data
        ...    filename=${epc_log_path}/${l2stream3_ttitrace_BB_10_2}_ul.csv    c_rnti=${c_rnti}    physCellId=400
    ELSE IF    ${enb_instance} == ${enb_id}[1]
        Capture Ttitrace With Admin Mode and Convert format    names=${l2stream3_ttitrace_BB_10_2}    nr_phy_cell_ids=400,700
        ...    capture_time=2s
        ${slot_1_6}    ${slot_3_8}=    check_required_filed_data
        ...    filename=${epc_log_path}/${l2stream3_ttitrace_BB_10_2}_ul.csv    c_rnti=${c_rnti}    physCellId=400
    END
    ${result_slot_1_6}=    Run Keyword And Return Status    Should Be True    condition=${slot_1_6}>0    msg=no satisfied data in slot 1 or slot 6
    ${result_slot_3_8}=    Run Keyword And Return Status    Should Be True    condition=${slot_3_8}>0    msg=no satisfied data in slot 3 or slot 8
#    Should Be True    ${result_slot_1_6} or ${result_slot_3_8}

BB_10 Step 9 check peak throughput
    comment    step9: check peak throughput
    IF    ${enb_instance} == ${enb_id}[0]
        ${dl_expected_throughput_pcell}    ${ul_expected_throughput_pcell}=    get_expect_throughput
        ...    tl_scf_dir_path=${tl_scf_dir_path}    tl_scf_file_name=${tl_gnb1_scf_${sw_version}}    cell_id=${400}
        ${dl_expected_throughput_scell}    ${ul_expected_throughput_scell}=    get_expect_throughput
        ...    tl_scf_dir_path=${tl_scf_dir_path}    tl_scf_file_name=${tl_gnb1_scf_${sw_version}}    cell_id=${700}
        ${ul_expected_throughput_scell_finally}    Evaluate    ${ul_expected_throughput_scell} * ${0.85}
        check intra gnb ca throughput    scellid=${4}    pcellid=${1}    gnb_prime=${0}    gnb_external=${0}
        ...    tput_ul_pcell=${ul_expected_throughput_pcell}    tput_ul_scell=${ul_expected_throughput_scell_finally}
        ...    time=300s    ue_type=${ue1_type}    ue_index=${1}
    ELSE IF    ${enb_instance} == ${enb_id}[1]
        ${dl_expected_throughput_pcell}    ${ul_expected_throughput_pcell}=    get_expect_throughput
        ...    tl_scf_dir_path=${tl_scf_dir_path}    tl_scf_file_name=${tl_gnb1_scf_${sw_version}}    cell_id=${400}
        ${dl_expected_throughput_scell}    ${ul_expected_throughput_scell}=    get_expect_throughput
        ...    tl_scf_dir_path=${tl_scf_dir_path}    tl_scf_file_name=${tl_gnb1_scf_${sw_version}}    cell_id=${700}
        ${ul_expected_throughput_scell_finally}    Evaluate    ${ul_expected_throughput_scell} * ${0.82}
        check intra gnb ca throughput    scellid=${4}    pcellid=${1}    gnb_prime=${0}    gnb_external=${0}
        ...    tput_ul_pcell=${ul_expected_throughput_pcell}    tput_ul_scell=${ul_expected_throughput_scell_finally}
        ...    time=300s    ue_type=${ue1_type}    ue_index=${1}
    END

BB_10 Teardown
    robot_common_operations.Common Case Teardown
    AlarmWatchdog.remove_allow_alarms    fault_id=4291
    AlarmWatchdog.remove_allow_alarms    fault_id=4546
    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
    Stop DL or UL traffic common ue    ue_index=${0}    ue_type=${ue0_type}    direction=UL
    Stop DL or UL traffic common ue    ue_index=${1}    ue_type=${ue_type_qcom}    direction=UL
    Step4: Detach UE    ue_type=${ue_type_qcom}    ue_index=${1}
    QCM UE Recover Detach    ue_index=${0}    ue_type=${ue0_type}
    IF    ${enb_instance} == ${enb_id}[0]
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id}[1]    value=${multi_gnb_PA}[1]
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id}[5]    value=${multi_gnb_PA}[1]    ip_addr=${att_ipaddr_1}
        Setup for Env cell on-air for 2 gnb    is_commission_for_second_gnb=False    tl_scf_file_name=${tl_gnb1_scf_${sw_version}}
#        Online delete parmeters    parameters_to_update=${PARAM_12149_delete_gnb1_BB_10_348}    timeout=${300}
#        Online modify parmeters    parameters_to_update=${PARAM_12149_recover_gnb1_BB_10_348}    skip_parameter_relation_errors=False
#        COAM Wait for gnb ready and cell setup
    ELSE IF    ${enb_instance} == ${enb_id}[1]
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id}[1]    value=${multi_gnb_PA}[1]
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id}[5]    value=${multi_gnb_PA}[1]    ip_addr=${att_ipaddr_1}
        Setup for Env cell on-air for 2 gnb    is_commission_for_second_gnb=False    tl_scf_file_name=${tl_gnb1_scf_${sw_version}}
#        Online delete parmeters    parameters_to_update=${PARAM_12149_delete_gnb1_BB_10_348}    timeout=${300}
#        Online modify parmeters    parameters_to_update=${PARAM_12149_recover_gnb1_BB_10_348}    skip_parameter_relation_errors=False
#        COAM Wait for gnb ready and cell setup
    END
    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
#    get and analysis syslog






set apn dxdata2
    RUN KEYWORD IF    ${enb_instance} != ${enb_id}[2]
    ...    run keywords    Set Suite Variable    ${close_task}    538 1874
    ...    AND    set apn with special method    usedapn=${dxdata2_apn_348}    location_apn=${click_access_point}
    ...    ELSE    set apn to wap2    usedapn=${dxdata2_apn}

Check wireshark log for 12149_BB_04
    [Arguments]    ${logname}    ${puschMappingType}=TypeA
    Comment    check wireshark log for 12149_BB_04
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}
    check CB012149 UERadioCapabilityInfoIndication on wireshark
    Run Keyword If    '${release_info}' == 'SBTS24R3_ENB_0000'
    ...    check UL switchedUl scell additon successful on wireshark on 24R3    puschMappingType=${puschMappingType}
    ...    ELSE IF    '${release_info}' == 'SBTS25R1_ENB_0000'
    ...    check UL switchedUl scell additon successful on wireshark on 25R1    puschMappingType=${puschMappingType}
    ...    ELSE    check UL switchedUl scell additon successful on wireshark    puschMappingType=${puschMappingType}

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

check value on TTI file BB_04
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
    ...    ${time}=30s    ${ue_type}=${ue_type}
    ...    ${ue_index}=${0}
    Check_throughput with CA     tput_dl_pcell=${tput_dl_pcell}    tput_dl_scell=${tput_dl_scell}    tput_ul_pcell=${tput_ul_pcell}
    ...    tput_ul_scell=${tput_ul_scell}    scellid=${scellid}    pcellid=${pcellid}
    ...    gnb_prime=${gnb_prime}    gnb_external=${gnb_external}    duration=${time}
    ...    ue_type=${ue_type}    ue_index=${ue_index}

make WA with Samsung S21
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Connect to control pc via cygwin    ue_index=${ue_index}
    sleep   5s
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent ${Home_button}    connection=cygwin
    sleep   2s
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe ${swipe}    connection=cygwin
    sleep   4s
    #####Samsung S21 WA to click time cancel
    csn.send_command    command=adb -s ${serial_number} shell input tap 302 2108    connection=cygwin
    sleep    2s
    [Teardown]    csn.disconnect    connection=cygwin

EDA_04474899_steps
    online update list parameter bwp
    online update list parameter csiReportPeriodicity
    online update list parameter rbgLimit
    Online modify parmeters     parameters_to_update=${tmp_EDA_04474899_348}    skip_parameter_relation_errors=False
    PA one cell 0 on and set other cell value 4 port for T348    cellid=${cell_id_348}[5]    set_value=${multi_gnb_PA}[0]
    UE attach with tcpdump and TTI capture
    Check wireshark log for EDA_04474899    logname=${log_name_EDA_04474899_1}
    [Teardown]    EDA_04474899_recover

UE attach with tcpdump and TTI capture
    power_ue.Prepare UE    ue_type=${ue_type_qcom}    ue_index=${1}
    Start capture gNB log on master    filename=${log_name_EDA_04474899_1}
    Step1: UE attach    ue_type=${ue_type_qcom}    ue_index=${1}
    # due to the time is too long
#    Capture Ttitrace With Admin Mode and Convert format    names=${l2stream3_ttitrace_EDA_04474899_1}    nr_phy_cell_ids=383
    [Teardown]    Run Keywords    Stop and download Logs on gNB on master    filename=${log_name_EDA_04474899_1}
    ...    AND    Step4: Detach UE    ue_type=${ue_type_qcom}    ue_index=${1}

Check wireshark log for EDA_04474899
    [Arguments]    ${logname}
    Comment    Check wireshark log for EDA_04474899
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}
    ${ZP_CSI_RS_Resource_element_filter}    Catenate    ((f1ap.F1AP_PDU == 0) && (f1ap.procedureCode == 12)) && (nr-rrc.c1 == 1)
    ${ZP_CSI_RS_Resource_element_packets}    cap.filter_packets_by_expression
    ...    filter_expression=${ZP_CSI_RS_Resource_element_filter}
    ${periodicityAndOffset}=    cap.Get Field Value By Xpath    pdml_list=${ZP_CSI_RS_Resource_element_packets}
    ...    xpath=.//nr-rrc.zp_CSI_RS_ResourceToAddModList//nr-rrc.ZP_CSI_RS_Resource_element//nr-rrc.periodicityAndOffset
    Should Be Equal    ${periodicityAndOffset}[2]    7
    ${nr_rrc_slots40}=    cap.Get Field Value By Xpath    pdml_list=${ZP_CSI_RS_Resource_element_packets}
    ...    xpath=.//nr-rrc.zp_CSI_RS_ResourceToAddModList//nr-rrc.ZP_CSI_RS_Resource_element//nr-rrc.slots40
    Should Be Equal    ${nr_rrc_slots40}[0]    26

online update list parameter bwp
    [Arguments]    ${gnb_index}=${0}    ${skip_parameter_relation_errors}=True
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    online operate list parameters
    ...    parameters=${tmp_EDA_04474899_variable_7001}    operation=update    skip_parameter_relation_errors=${skip_parameter_relation_errors}
    online operate list parameters
    ...    parameters=${tmp_EDA_04474899_variable_7002}    operation=update    skip_parameter_relation_errors=${skip_parameter_relation_errors}
    online operate list parameters
    ...    parameters=${tmp_EDA_04474899_variable_7003}    operation=update    skip_parameter_relation_errors=${skip_parameter_relation_errors}
    online operate list parameters
    ...    parameters=${tmp_EDA_04474899_variable_7004}    operation=update    skip_parameter_relation_errors=False
    [Teardown]    COAM Teardown gnb connections

online update list parameter csiReportPeriodicity
    [Arguments]    ${gnb_index}=${0}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    online operate list parameters
    ...    parameters=${tmp_EDA_04474899_variable_csiReportPeriodicity_348}    operation=update    skip_parameter_relation_errors=False
    [Teardown]    COAM Teardown gnb connections

online update list parameter rbgLimit
    [Arguments]    ${gnb_index}=${0}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    online operate list parameters
    ...    parameters=${tmp_EDA_04474899_variable_rbgLimit_348}    operation=update    skip_parameter_relation_errors=False
    [Teardown]    COAM Teardown gnb connections

EDA_04474899_recover
    online update list parameter bwp recover
    online update list parameter csiReportPeriodicity recover
    online update list parameter rbgLimit recover
    Online delete parmeters    parameters_to_update=${tmp_EDA_04474899_recover_delete_348}    timeout=${300}
    Online modify parmeters     parameters_to_update=${tmp_EDA_04474899_348}    skip_parameter_relation_errors=False

online update list parameter bwp recover
    [Arguments]    ${gnb_index}=${0}    ${skip_parameter_relation_errors}=True
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    online operate list parameters
    ...    parameters=${tmp_EDA_04474899_variable_7001_recover}    operation=update
    ...    skip_parameter_relation_errors=${skip_parameter_relation_errors}
    online operate list parameters
    ...    parameters=${tmp_EDA_04474899_variable_7002_recover}    operation=update
    ...    skip_parameter_relation_errors=${skip_parameter_relation_errors}
    online operate list parameters
    ...    parameters=${tmp_EDA_04474899_variable_7003_recover}    operation=update
    ...    skip_parameter_relation_errors=${skip_parameter_relation_errors}
    online operate list parameters
    ...    parameters=${tmp_EDA_04474899_variable_7004_recover}    operation=update
    ...    skip_parameter_relation_errors=False
    [Teardown]    COAM Teardown gnb connections

online update list parameter csiReportPeriodicity recover
    [Arguments]    ${gnb_index}=${0}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    online operate list parameters
    ...    parameters=${tmp_EDA_04474899_variable_csiReportPeriodicity_recover_348}    operation=update    skip_parameter_relation_errors=False
    [Teardown]    COAM Teardown gnb connections

online update list parameter rbgLimit recover
    [Arguments]    ${gnb_index}=${0}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    online operate list parameters
    ...    parameters=${tmp_EDA_04474899_variable_rbgLimit_recover_348}    operation=update    skip_parameter_relation_errors=False
    [Teardown]    COAM Teardown gnb connections

online operate list parameters
    [Documentation]    This keyword is used to operate list parameter from the gNB
    ...    Author: ming.shi@nokia-sbell.com
    [Arguments]
    ...    ${parameters}
    ...    ${operation}=update
    ...    ${skip_parameter_relation_errors}=True
    ...    ${should_activate}=True
    ...    ${timeout}=${300}
    ...    ${connection}=GNB_OAM
    coam.perform_parameter_recommissioning
    ...    dist_name=${parameters}[dist_name]    parameter=${parameters}[parameter]    operation=${operation}
    ...    value=${parameters}[value]    skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...    should_activate=${should_activate}
    ...    timeout=${timeout}    connection=${connection}

Capture Ttitrace With Admin Mode and Convert format of ue attach
    [Arguments]
    ...            ${names}=l2stream3_ttitrace
    ...            ${SW_BRANCH}=NULL
    ...            ${nr_phy_cell_ids}=NULL
    ...            ${gNB_index}=${0}
    ...            ${target_dir}=${epc_log_path}
    Start Ttitrace With Admin Mode    names=${names}    SW_BRANCH=${SW_BRANCH}    nr_phy_cell_ids=${nr_phy_cell_ids}    gNB_index=${gNB_index}
    Step1: UE attach    ue_type=${ue_type_qcom}    ue_index=${1}
    [Teardown]    Run Keywords    Stop Ttitrace With Admin Mode    names=${names}      target_dir=${target_dir}
    ...    AND    Convert Ttitrace From Pcap To Excelcsv    names=${names}      target_dir=${target_dir}