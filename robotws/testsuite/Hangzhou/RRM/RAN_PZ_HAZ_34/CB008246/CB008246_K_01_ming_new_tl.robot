*** Settings ***
Documentation
...    author: Shi Ming
...    contact: ming.shi@nokia-sbell.com
...    squal group: SG03
...    feature: CB008246-K

Force Tags  CA_5G_RRM
...    PY36
Suite Setup    Run Keywords
...                            robot_common_operations.Common Suite Setup
...                            AND    Common Suite Setup for COAM
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
${log_name_K_001_1}    log_name_K_001_1.pcap
${log_name_K_001_2}    log_name_K_001_2.pcap
${log_name_K_001_3}    log_name_K_001_3.pcap
${expected_tput_dl}    1
${Send_Tput_DL}        400M
${expected_tput_ul}    1
${Send_Tput_UL}        100M
@{expected_value_D001_gnb1}    ${1}    ${1}    ${7}    ${1}    ${7}
@{Counter_D001}    ${0}
${kpis_templates_id}    1040    # CB008246-K_Counter&KPI
${tool_path}    /opt/workspace/Tool
${X70_wap2apn_location}    959 1370
${X70_mdrb2apn_location}    959 1576
${X70_mdrb1apn_location}    959 1802

@{enb_id}    34821    38321    358
@{cell_id}    0    1    2    3    4    5
@{cell_id_348}    0    1    2    3    4    5    6
@{multi_gnb_PA}    ${0}     ${127}
@{multi_gnb_PA_358}    ${0}
@{multi_gnb_PA_348}    ${0}
@{multi_gnb_PA_383}    ${0}
#${ue_type_K01}    samsung
${DL_PORT_K01}    ${tl.ues[0].iperf_details.port}
${UL_PORT_K01}    ${tl.ues[0].iperf_details.ssh_connection_details.port}
@{gnb_list}    ${0}
${tl_scf_dir_path}    /opt/workspace/CRT/Master/SCF_file/
${tl_scf_file_name1}    gNB1_Golden_SCF.xml
${tl_scf_file_name2}    gNB2_Golden_SCF.xml
${tl_scf_file_name1_358_24R1_tmp}    gNB1_Golden_SCF_24R1_8246.xml

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

${dxdata2_apn}    95 943
#${dxdata2_apn_348}    158 943
${dxdata2_apn_348}    95 1030
${click_access_point}    380 1060
${mdrb1_apn}    95 1329
#${mdrb1_apn_348}    158 1368
${mdrb1_apn_348}    95 1458

${dxdata2}    ${tl.ues[0].pdn[0]}
${mdrb_apn_name}    ${tl.ues[0].pdn[1]}
${mdrb1_apn_name}    ${tl.ues[0].pdn[2]}

${X75_dxdata2_location}    959 940
${X75_mdrb_location}    959 1152
${X75_mdrb1_location}    959 1350

${ue_type_K01}                  ${tl.ues[0].capabilities[0]}

${l2stream3_ttitrace_K001_1}    l2stream3_ttitrace_K001_1
${l2stream3_ttitrace_K001_2}    l2stream3_ttitrace_K001_2

*** Test Cases ***
[1]CB008246-K_001_Scell_addition_after_HRnonGBR _setup_SA_UE_not_support_lowSE_intra_gnb_DL_CA_T+T+F
    [Documentation]    CB008246-K
    [Tags]    CB008246-K    CRT_TRUNK
    [Timeout]    2 hour
    [Setup]
    K001 Prerequisite
    K001 Step 1 UE0 change APN and attach on scell
    K001 Step 2 trigger UE reestablish from scell to pscell
    K001 Step 3 check logs on wireshark
    K001 Step 4 UE0 make traffic
    K001 Step 5 check legacy Bler
    K001 Step 6 release 5QI8
    K001 Step 7 check logs on wireshark and TTI
    [Teardown]    K001 Teardown


*** Keywords ***
K001 Prerequisite
    robot_common_operations.Common Case Setup    allowed_faults_ids=4291
    AlarmWatchdog.add_allow_alarms    fault_id=4291
    Check UE device status with adb recover    ue_index=${0}
    comment    Prerequisite: open CA function, 5QI7 config HR, 5QI-7 HR setup first, then 5QI-5
    ###set scell(gnb1 cell3) PA to 0
    IF    ${enb_instance} == ${enb_id}[0]     #TL348
        Online modify parmeters     parameters_to_update=${PARAM_8246_gnb1_K_001_348}    skip_parameter_relation_errors=False
        Online delete parmeters    parameters_to_update=${PARAM_8246_delete_gnb1_K_001}    timeout=${300}
        PA one cell 0 on and set other cell value 4 port for T348    cellid=${cell_id_348}[5]    set_value=${multi_gnb_PA}[0]
    ELSE IF    ${enb_instance} == ${enb_id}[1]     #TL383
        Online modify parmeters     parameters_to_update=${PARAM_8246_gnb1_K_001_348}    skip_parameter_relation_errors=False
        Online delete parmeters    parameters_to_update=${PARAM_8246_delete_gnb1_K_001}    timeout=${300}
        PA one cell 0 on and set other cell value 4 port for T348    cellid=${cell_id_348}[5]    set_value=${multi_gnb_PA}[0]
    END

K001 Step 1 UE0 change APN and attach on scell
    comment    step1: ue0 attach on scell(gnb1 cell3), setup 5QI5 and 5QI7, then setup HR 5QI8 via dynamic rule tool
    Power_ue.Prepare UE    ue_type=${ue_type_K01}    ue_index=${0}
    Wait Until Keyword Succeeds    3x    10s
    ...    Run Keywords
    ...    set apn mdrb1
    ...    AND    make WA with Samsung S21
    UE.UE Detach     ue_type=${ue_type_K01}     ue_index=${0}
    Power_ue.Prepare UE    ue_type=${ue_type_K01}    ue_index=${0}
    Start capture gNB log on master    filename=${log_name_K_001_1}
    Attach and check power UE    ue_type=${ue_type_K01}    ue_index=${0}    gnb_index=${0}
    # setup HR 5QI8 via dynamic rule tool
    add or delete 5QI via npc dynamic rule    imsi=${tl.ues[0].imsi}    rule=ADD5QI8-PZ4-MXD
    sleep    20s    reason=wait for 5QI8 added
    [Teardown]    Stop and download Logs on gNB on master    filename=${log_name_K_001_1}

K001 Step 2 trigger UE reestablish from scell to pscell
    comment    step2: trigger UE reestablish from scell to pscell
#    put btslog_ini file to ute
#    ...    server_ip=${appserver_addr}    server_username=${appserver_username}    server_password=${appserver_password}
#    Start capture syslog via btslog on ute
    Start capture gNB log on master    filename=${log_name_K_001_2}
    IF    ${enb_instance} == ${enb_id}[0]     #TL348
        ###set pcell(gnb1 cell1) PA to 0
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[1]    value=${multi_gnb_PA}[0]
        sleep    10s    reason=wait for pcell can be attach
        ###set scell(gnb1 cell3) PA to max
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[5]    value=${multi_gnb_PA}[1]    ip_addr=${att_ipaddr_1}
        sleep    30s    reason=wait for UE reestablish completely
    ELSE IF    ${enb_instance} == ${enb_id}[1]     #TL383
        ###set pcell(gnb1 cell1) PA to 0
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[1]    value=${multi_gnb_PA}[0]
        sleep    10s    reason=wait for pcell can be attach
        ###set scell(gnb1 cell3) PA to max
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[5]    value=${multi_gnb_PA}[1]    ip_addr=${att_ipaddr_1}
        sleep    30s    reason=wait for UE reestablish completely
    END
    [Teardown]    Stop and download Logs on gNB on master    filename=${log_name_K_001_2}
#    ...    AND    Stop capture syslog via btslog on ute

K001 Step 3 check logs on wireshark
    comment    step3: check ue not support lowSE via wireshark, check Scell addition success via wireshark
    Check wireshark log for 8246_K001_2

K001 Step 4 UE0 make traffic
    comment    step4: make DL traffic on 5QI7
    ###set gnb1 cell3 PA to 0   #TL348
    IF    ${enb_instance} == ${enb_id}[0]     #TL348
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[5]    value=${multi_gnb_PA_348}[0]    ip_addr=${att_ipaddr_1}
    ###set gnb1 cell3 PA to 0   #TL383
    ELSE IF    ${enb_instance} == ${enb_id}[1]     #TL383
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[5]    value=${multi_gnb_PA_348}[0]    ip_addr=${att_ipaddr_1}
    ###set gnb1 cell3 PA to 0   #TL383
    END
    Start only DL traffic and check tput    ue_index=${0}    cellid=${1}    ue_type=${ue_type_K01}    gnb_index=${0}
    ...                                tput_dl_cell=${expected_tput_dl}    dl_throughput=${Send_Tput_DL}    duration=${7200}
    ...                                dl_port=${DL_PORT_K01}

K001 Step 5 check legacy Bler
    comment    step5: check Bler via counter
    Prepare with PM counter time to caculate    period=start
    sleep    6min    reason=check KPIs after make traffic during 5mins and xml report generated 1min
    Run Keyword And Continue On Failure
    ...    check legacy DL traffic check dict KPI from pm file    KPI_file=CB008246_K001_legacy_KPI.txt    para_index=${1}
    IF    ${enb_instance} == ${enb_id}[0]     #TL348
        Run Keyword And Continue On Failure
        ...    check legacy DL traffic check dict KPI from pm file    KPI_file=CB008246_K001_legacy_KPI.txt    para_index=${3}
    ELSE IF    ${enb_instance} == ${enb_id}[1]     #TL383
        Run Keyword And Continue On Failure
        ...    check legacy DL traffic check dict KPI from pm file    KPI_file=CB008246_K001_legacy_KPI.txt    para_index=${3}
    END
    IF    ${enb_instance} == ${enb_id}[0]
        Capture Ttitrace tti from WEBUI    names=${l2stream3_ttitrace_K001_1}    nr_phy_cell_ids=400    capture_time=2s
        check value on TTI file K001    file_path=${epc_log_path}/${l2stream3_ttitrace_K001_1}_dl.csv    queried_filed=dlFdSchedData.laMode
        ...    check_point=HIGHRELIABILITY
    ELSE IF    ${enb_instance} == ${enb_id}[1]
        Capture Ttitrace tti from WEBUI    names=${l2stream3_ttitrace_K001_1}    nr_phy_cell_ids=400    capture_time=2s
        check value on TTI file K001    file_path=${epc_log_path}/${l2stream3_ttitrace_K001_1}_dl.csv    queried_filed=dlFdSchedData.laMode
        ...    check_point=HIGHRELIABILITY
    END

K001 Step 6 release 5QI8
    comment    step6: release 5QI8 via dynamic rule tool
    Start capture gNB log on master    filename=${log_name_K_001_3}
    add or delete 5QI via npc dynamic rule    imsi=${tl.ues[0].imsi}    rule=DEL5QI8-PZ4-MXD
    sleep    20s    reason=wait for 5QI8 released
    [Teardown]    Stop and download Logs on gNB on master    filename=${log_name_K_001_3}

K001 Step 7 check logs on wireshark and TTI
    comment    step7: check ue not support lowSE via wireshark, check TTI(laMode) all BR
    Run Keyword And Continue On Failure    Check wireshark log for 8246_K001_3
    tmp_use_keyword

tmp_use_keyword
     IF    ${enb_instance} == ${enb_id}[0]
        Capture Ttitrace tti from WEBUI    names=${l2stream3_ttitrace_K001_2}    nr_phy_cell_ids=400
        check value on TTI file K001    file_path=${epc_log_path}/${l2stream3_ttitrace_K001_2}_dl.csv    queried_filed=dlFdSchedData.laMode
        ...    check_point=BASICRELIABILITY
    ELSE IF    ${enb_instance} == ${enb_id}[1]
        Capture Ttitrace tti from WEBUI    names=${l2stream3_ttitrace_K001_2}    nr_phy_cell_ids=400
        check value on TTI file K001    file_path=${epc_log_path}/${l2stream3_ttitrace_K001_2}_dl.csv    queried_filed=dlFdSchedData.laMode
        ...    check_point=BASICRELIABILITY
    END

K001 Teardown
    robot_common_operations.Common Case Teardown
    AlarmWatchdog.remove_allow_alarms    fault_id=4291
    add or delete 5QI via npc dynamic rule    imsi=${tl.ues[0].imsi}    rule=DEL5QI8-PZ4-MXD
    Stop DL or UL traffic    ue_index=${0}    ue_type=${ue_type_K01}    direction=DL
    Run Keyword If    '${ue_type_K01}' == 'qct_dx50'    QCM UE Recover Detach    ue_index=${0}    status=${0}    ue_type=${ue_type_K01}
    Run Keyword If    '${ue_type_K01}' == 'samsung' or '${ue_type_K01}' == 'Huawei'    set apn dxdata2
    ...    ELSE IF    '${ue_type_K01}' == 'qct_dx50'
    ...    choice required APN on QCOM UE    usedapn=${X75_dxdata2_location}   ue_index=${0}
#    ...    Switch QCOM APN to muti DRB    ue_index=${0}    ue_type=${ue_type_K01}    apn_name=${dxdata2}
    Run Keyword If    '${ue_type_K01}' != 'qct_dx50'    QCM UE Recover Detach    ue_index=${0}    status=${0}    ue_type=${ue_type_K01}
    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
    IF    ${enb_instance} == ${enb_id}[0]     #TL348
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[1]    value=${multi_gnb_PA}[1]
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[5]    value=${multi_gnb_PA}[1]    ip_addr=${att_ipaddr_1}
        Online delete parmeters    parameters_to_update=${PARAM_8246_recover_delete_gnb1_K_001}    timeout=${300}
        Online modify parmeters    parameters_to_update=${PARAM_8246_recover_gnb1_K_001_348}    skip_parameter_relation_errors=False
    ELSE IF    ${enb_instance} == ${enb_id}[1]     #TL383
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[1]    value=${multi_gnb_PA}[1]
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[5]    value=${multi_gnb_PA}[1]    ip_addr=${att_ipaddr_1}
        Online delete parmeters    parameters_to_update=${PARAM_8246_recover_delete_gnb1_K_001}    timeout=${300}
        Online modify parmeters    parameters_to_update=${PARAM_8246_recover_gnb1_K_001_348}    skip_parameter_relation_errors=False
    END
    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
#    get and analysis syslog






set apn dxdata2
    RUN KEYWORD IF    ${enb_instance} != ${enb_id}[2]
    ...    run keywords    Set Suite Variable    ${close_task}    538 1874
    ...    AND    set apn with special method    usedapn=${dxdata2_apn_348}    location_apn=${click_access_point}
    ...    ELSE    set apn to wap2    usedapn=${dxdata2_apn}

set apn mdrb
    RUN KEYWORD IF    ${enb_instance} != ${enb_id}[2]
    ...    run keywords    Set Suite Variable    ${close_task}    538 1874
    ...    AND    set apn with special method    usedapn=${muiltdrb_348}    location_apn=${click_access_point}
    ...    ELSE    set apn to wap2    usedapn=${muiltdrb}

set apn mdrb1
    RUN KEYWORD IF    ${enb_instance} != ${enb_id}[2]
    ...    run keywords    Set Suite Variable    ${close_task}    538 1874
    ...    AND    set apn with special method    usedapn=${mdrb1_apn_348}    location_apn=${click_access_point}
    ...    ELSE    set apn to wap2    usedapn=${mdrb1_apn}

check legacy DL traffic check dict KPI from pm file
    [Arguments]     ${KPI_file}    ${para_index}    ${index}=${0}
    ${dict_kpis_name_value}=    get dict kpi from pm file    KPI_file=${KPI_file}    para_index=${para_index}    index=${index}
    check required KPI via pm file    KPI_name_list=${CB008246_K_legacy_DL_traffic_check_kpi_names_value_zero}
    ...    check_field=equal_specified_value    dict_kpi_get=${dict_kpis_name_value}
    check required KPI via pm file    KPI_name_list=${CB008246_K_legacy_DL_traffic_check_kpi_names_larger_zero}
    ...    check_field=larger_specified_value    dict_kpi_get=${dict_kpis_name_value}
    check required KPI via pm file    KPI_name_list=${CB008246_K_legacy_DL_traffic_check_kpi_names_less_specified_value}
    ...    check_field=less_specified_value    dict_kpi_get=${dict_kpis_name_value}    less_specfied=${0.011}
    ${result_1}    evaluate
    ...    ${dict_kpis_name_value}[${K_legacy_00}]+${dict_kpis_name_value}[${K_legacy_01}]
    IF    ${enb_instance} == ${enb_id}[0]     #TL348
        ${result_1_348}    Evaluate    ${dict_kpis_name_value}[${K_legacy_02}]+${dict_kpis_name_value}[${K_legacy_03}]
        ${result_1_all}    Evaluate    ${result_1}+${result_1_348}
        should be true    ${result_1_all}>${0}
    ELSE IF    ${enb_instance} == ${enb_id}[1]     #TL383
        ${result_1_383}    Evaluate    ${dict_kpis_name_value}[${K_legacy_02}]+${dict_kpis_name_value}[${K_legacy_03}]
        ${result_1_all}    Evaluate    ${result_1}+${result_1_383}
        Should Be True    ${result_1_all}>${0}
    END
#    should be true    ${result_1}>${0}
    ${result_2}    evaluate    abs(${dict_kpis_name_value}[${K_legacy_04}])
    should be true    ${0}<=${result_2}<${100}

Check wireshark log for 8246_K001_2
    Check UL_UE_MCS_table_Capbility without_ul-64QAM-MCS-TableAlt    logname=${log_name_K_001_2}
    check beatoffset 5QI8 and scell addition success    logname=${log_name_K_001_2}

Check wireshark log for 8246_K001_3
    Check UL_UE_MCS_table_Capbility without_ul-64QAM-MCS-TableAlt    logname=${log_name_K_001_3}
    check beatoffset    logname=${log_name_K_001_3}

Check UL_UE_MCS_table_Capbility without_ul-64QAM-MCS-TableAlt
    [Arguments]    ${logname}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    alias=test6
    ${filter_expression}=     Catenate    f1ap.procedureCode == 12 and nr-rrc.uplinkBWP_ToAddModList == 1 and nr-rrc.mcs_Table == 1
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_mcs_Table}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.mcs_Table    pcap_parser=test6
#    Should Be Equal    ${nr_rrc_mcs_Table[1]}    1
    Should Not Contain    ${nr_rrc_mcs_Table}    1

check beatoffset 5QI8 and scell addition success
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}
    check beatoffset 5QI8 on wireshark
    check scell addition success

check beatoffset 5QI8 on wireshark
    # SACK (Ack=2, Arwnd=2097152) , RRC Reconfiguration
    ${RRC_Setup_filter}    Catenate    ((f1ap.F1AP_PDU == 0) && (f1ap.procedureCode == 12)) && (nr-rrc.betaOffsetACK_Index1 == 10)
    ${RRC_Setup_packets}    cap.filter_packets_by_expression    filter_expression=${RRC_Setup_filter}
    ${betaOffsetACK_Index1}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Setup_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetACK_Index1
    ${betaOffsetACK_Index2}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Setup_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetACK_Index2
    ${betaOffsetACK_Index3}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Setup_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetACK_Index3
    ${betaOffsetCSI_Part1_Index1}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Setup_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetCSI_Part1_Index1
    ${betaOffsetCSI_Part1_Index2}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Setup_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetCSI_Part1_Index2
    Should Be Equal    ${betaOffsetACK_Index1}[0]    10
    Should Be Equal    ${betaOffsetACK_Index2}[0]    11
    Should Be Equal    ${betaOffsetACK_Index3}[0]    6
    Should Be Equal    ${betaOffsetCSI_Part1_Index1}[0]    13
    Should Be Equal    ${betaOffsetCSI_Part1_Index2}[0]    13

check scell addition success
    IF    ${enb_instance} == ${enb_id}[0]     #TL348
        ${scell_physCellId}=    Get value of parameter from SCF file    golden_scf_name=${tl_gnb1_scf_${sw_version}}
        ...    dist_name=${NRCELL700name_GNB1}    p_name=physCellId    scf_path=${tl_scf_dir_path}
    ELSE IF    ${enb_instance} == ${enb_id}[1]     #TL383
        ${scell_physCellId}=    Get value of parameter from SCF file    golden_scf_name=${tl_gnb1_scf_${sw_version}}
        ...    dist_name=${NRCELL700name_GNB1}    p_name=physCellId    scf_path=${tl_scf_dir_path}
    END
    # SACK (Ack=11, Arwnd=2097152) , RRC Reconfiguration
    ${RRC_Reconfiguration_filter}    Catenate
    ...    ((f1ap.F1AP_PDU == 0) && (f1ap.procedureCode == 12)) && (nr-rrc.physCellId == ${scell_physCellId})
    ${RRC_Reconfiguration_packets}    cap.filter_packets_by_expression    filter_expression=${RRC_Reconfiguration_filter}
    ${nr-rrc_physCellId}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...                                                xpath=.//nr-rrc.physCellId
    Should Be Equal As Integers    ${nr-rrc_physCellId}[0]    ${scell_physCellId}

check beatoffset
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}
    check beatoffset on wireshark

check beatoffset on wireshark
    # SACK (Ack=2, Arwnd=2097152) , UEContextModificationResponse
    ${RRC_Setup_filter}    Catenate    ((f1ap.F1AP_PDU == 1) && (f1ap.procedureCode == 7)) && (nr-rrc.betaOffsetACK_Index1 == 10)
    ${RRC_Setup_packets}    cap.filter_packets_by_expression    filter_expression=${RRC_Setup_filter}
    ${betaOffsetACK_Index1}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Setup_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetACK_Index1
    ${betaOffsetACK_Index2}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Setup_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetACK_Index2
    ${betaOffsetACK_Index3}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Setup_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetACK_Index3
    ${betaOffsetCSI_Part1_Index1}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Setup_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetCSI_Part1_Index1
    ${betaOffsetCSI_Part1_Index2}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Setup_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetCSI_Part1_Index2
    Should Be Equal    ${betaOffsetACK_Index1}[0]    10
    Should Be Equal    ${betaOffsetACK_Index2}[0]    11
    Should Be Equal    ${betaOffsetACK_Index3}[0]    6
    Should Be Equal    ${betaOffsetCSI_Part1_Index1}[0]    13
    Should Be Equal    ${betaOffsetCSI_Part1_Index2}[0]    13

check 5QI7 setup first
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}
    # InitialContextSetupRequest, DL NAS transport, PDU session establishment accept
    ${InitialContextSetupRequest_filter}    Catenate    (ngap.NGAP_PDU == 0) && (ngap.procedureCode == 14)
    ${InitialContextSetupRequest_packets}    cap.filter_packets_by_expression    filter_expression=${InitialContextSetupRequest_filter}
    ${ngap_fiveQI}=    cap.Get Field Value By Xpath    pdml_list=${InitialContextSetupRequest_packets}
    ...                                                xpath=.//ngap.fiveQI
    Should Be Equal    ${ngap_fiveQI}[0]    7
#    ${result}    run keyword and return status    Should Be Equal    ${ngap_fiveQI}[0]    7
#    run keyword if    ${result} == ${True}    log to console    5QI7 setup first


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



PA one cell 0 on and set other cell value
    [Arguments]    ${cellid}    ${set_value}=${0}    ${total_cell}=${4}
    Change Attenuation value    cell=5Gcell${cellid}    value=${set_value}
    FOR  ${index}  IN RANGE   ${total_cell}
        ${cellnum} =    evaluate    ${index}+1
        run keyword if    '${cellid}'!='${cellnum}'    Change Attenuation value    cell=5Gcell${cellnum}    value=${127}
    END
    Change Attenuation value    cell=4Gcell1    value=${127}

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



get_required_tti_file_name
    [Arguments]    ${files_list}    ${required_file_name}=dl__all.csv
    FOR    ${file}    IN    @{files_list}
        ${status}    run keyword and return status    should contain    ${file}    ${required_file_name}
        exit for loop if    '${status}' == 'True'
        set test variable    ${file}
    END
    [Return]    ${file}


Get RNTI ID message
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    ####InitialULRRCMessageTransfer, RRC Setup Request
    ${RRC_Setup_request}=     Catenate    (f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 11 and f1ap.C_RNTI)
    ${RRC_Setup_request_packets}=    cap.filter_packets_by_expression    filter_expression=${RRC_Setup_request}
    ${UE_RNTI_ID}=     cap.get_field_value_by_xpath    pdml_list=${RRC_Setup_request_packets}
    ...                                                xpath=.//f1ap.C_RNTI
    [Return]    ${UE_RNTI_ID}[0]

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

check value on TTI file K001
    [Arguments]    ${file_path}    ${queried_filed}    ${check_point}=BASICRELIABILITY
    ${required_data_list}=    get_value_from_csv_file    file_path=${file_path}    queried_filed=${queried_filed}
    ${no_duplicates_required_data_list}    Remove Duplicates    ${required_data_list}
    ${length}    Get Length    ${no_duplicates_required_data_list}
    should be equal    ${no_duplicates_required_data_list}[0]    ${check_point}
    Should Be Equal As Integers    ${length}    1

#Get all X70 pointer variable
#    Set Suite Variable    ${home}    3
#    Set Suite Variable    ${airplane}    953 1385
#    Set Suite Variable    ${close_task}    523 272
#    Set Suite Variable    ${Home_button}    3
#    Set Suite Variable    ${swipe}    500 2050 500 800
#    Set Suite Variable    ${open_iperf_location}    480 860
#    Set Suite Variable    ${iperf_button}    720 312
#    Set Suite Variable    ${iperf_space}    800 550
#    Set Suite Variable    ${brand}    qti

choice required APN on QCOM UE
    [Arguments]    ${usedapn}    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Get all X70 pointer variable
    set Qcom apn to wap2    usedapn=${usedapn}    ue_index=${ue_index}
    make airplane mode to enable    ue_index=${ue_index}
    Connect to control pc via cygwin    ue_index=${ue_index}
    #### KEYCODE_APP_SWITCH,recent APP application
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 187    connection=cygwin
    #### clear all KEYCODE_APP_SWITCH,recent APP application
    FOR  ${i}    IN RANGE    ${9}
        csn.send_command    command=adb -s ${serial_number} shell input swipe 100 1300 900 1300    connection=cygwin
        sleep    1s
    END
    sleep    2s
    FOR  ${i}    IN RANGE    ${2}
        csn.send_command    command=adb -s ${serial_number} shell input tap 241 1076    connection=cygwin
        sleep   1s
    END
    [Teardown]    csn.disconnect    connection=cygwin

set Qcom apn to wap2
    [Arguments]    ${usedapn}=${wap2apn}    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Set Suite Variable    ${apnset1}    ${usedapn}
    Connect to control pc via cygwin    ue_index=${ue_index}
    ${passed} =    Check airplane mode status on    ue_index=${ue_index}
    run keyword if    '${passed}'=='${True}'
        ...    Run Keywords    Connect to control pc via cygwin    ue_index=${ue_index}
        ...    AND    Commercial UE click AIRPLANE once    Home_button=${home}    airplane=${airplane}    ue_index=${ue_index}
        ...    close_task=${close_task}
    Connect to control pc via cygwin    ue_index=${ue_index}    alias=cygwin
    sleep   5s
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent ${Home_button}    connection=cygwin
    sleep   2s
    #### KEYCODE_APP_SWITCH,recent APP application
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 187    connection=cygwin
    #### clear all KEYCODE_APP_SWITCH,recent APP application
    FOR  ${i}    IN RANGE    ${9}
        csn.send_command    command=adb -s ${serial_number} shell input swipe 100 1300 900 1300    connection=cygwin
        sleep    1s
    END
    sleep    2s
    FOR  ${i}    IN RANGE    ${2}
        csn.send_command    command=adb -s ${serial_number} shell input tap 241 1076    connection=cygwin
        sleep   1s
    END
    sleep   2s
    ####1.APN setting
    ####1.1 setting
    csn.send_command    command=adb -s ${serial_number} shell am start com.android.settings/com.android.settings.Settings$ApnSettingsActivity
    ...    connection=cygwin
    ####1.2 Network&internet
    sleep   2s
    csn.send_command    command=adb -s ${serial_number} shell input tap 447 938    connection=cygwin
    sleep   2s
    ####1.3 SIMs
    csn.send_command    command=adb -s ${serial_number} shell input tap 323 1205    connection=cygwin
    sleep   2s
    ####1.4 T-Mobile
    csn.send_command    command=adb -s ${serial_number} shell input tap 337 736    connection=cygwin
    sleep   2s
    ####1.5 swipe Access Point Names
    FOR  ${i}    IN RANGE    ${4}
        csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800    connection=cygwin
        sleep    1s
    END
    ####1.6 click Access Point Names
    csn.send_command    command=adb -s ${serial_number} shell input tap 486 1604    connection=cygwin
    sleep   2s
    ####1.6 switch Access Point Names
    csn.send_command    command=adb -s ${serial_number} shell input tap ${apnset1}    connection=cygwin
    sleep   2s
    [Teardown]    csn.disconnect    connection=cygwin

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
