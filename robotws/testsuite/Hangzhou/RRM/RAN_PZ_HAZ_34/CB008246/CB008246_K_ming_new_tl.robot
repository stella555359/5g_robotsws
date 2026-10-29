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
...                            AND    Get gnb release info
...                            AND    Get sagnb version for selenium
...                            AND    Set Suite Variable    ${tl_gnb1_scf_${sw_version}}    ${sw_version}_gNB1_Golden_SCF.xml
...                            AND    Setup for Env cell on-air for 2 gnb    is_commission_for_second_gnb=False
...                                   tl_scf_file_name=${tl_gnb1_scf_${sw_version}}
...                            AND    Common UE parameter setup
...                            AND    Set multi DRB traffic DL UL port

Suite Teardown     Common Suite Teardown for COAM    gnb_list=${gnb_list}

Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008246/Resources/CB008246_common_keywords.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/outsides/common_8196/taf_log.robot

*** Variables ***
${log_name_K_001_1}    log_name_K_001_1.pcap
${log_name_K_001_2}    log_name_K_001_2.pcap
${log_name_K_004_1}    log_name_K_004_1.pcap
${log_name_K_004_2}    log_name_K_004_2.pcap
${log_name_K_004_3}    log_name_K_004_3.pcap
${log_name_04444966_1}    log_name_04444966_1.pcap
${log_name_04444966_2}    log_name_04444966_2.pcap
${log_name_04444966_3}    log_name_04444966_3.pcap
${log_name_K_006_1}    log_name_K_006_1.pcap
${log_name_K_006_2}    log_name_K_006_2.pcap
${log_name_K_006_3}    log_name_K_006_3.pcap
${log_name_K_06_1}    log_name_K_06_1.pcap
${log_name_K_06_2}    log_name_K_06_2.pcap
${log_name_K_06_3}    log_name_K_06_3.pcap
${log_name_K_011_1}    log_name_K_011_1.pcap
${log_name_K_011_2}    log_name_K_011_2.pcap
${log_name_K_011_3}    log_name_K_011_3.pcap
${log_name_K_012_1}    log_name_K_012_1.pcap
${log_name_K_012_2}    log_name_K_012_2.pcap
${log_name_K_16_1}    log_name_K_16_1.pcap
${log_name_K_16_2}    log_name_K_16_2.pcap
${log_name_K_16_3}    log_name_K_16_3.pcap
${log_name_K_018_1}    log_name_K_018_1.pcap
${log_name_K_018_2}    log_name_K_018_2.pcap
${log_name_K_018_3}    log_name_K_018_3.pcap
${log_name_K_019_1}    log_name_K_019_1.pcap
${log_name_K_019_2}    log_name_K_019_2.pcap
${log_name_K_019_3}    log_name_K_019_3.pcap
${expected_tput_dl}    1
${Send_Tput_DL}        500M
${expected_tput_ul}    1
${Send_Tput_UL}        400M
@{expected_value_D001_gnb1}    ${1}    ${1}    ${7}    ${1}    ${7}
@{Counter_D001}    ${0}
${kpis_templates_id}    1040    # CB008246-K_Counter&KPI
${tool_path}    /opt/workspace/Tool
${X70_wap2apn_location}    959 1370
${X70_mdrb2apn_location}    959 1576
${X70_mdrb1apn_location}    959 1802

@{scell_cell_index}    ${1}
@{scell_gnb_index}    ${1}

@{release_name}    SBTS24R1_ENB_0000

${l2stream3_ttitrace_K006_1}    l2stream3_ttitrace_K006_1
${l2stream3_ttitrace_K011_1}    l2stream3_ttitrace_K011_1
${l2stream3_ttitrace_K16_1}    l2stream3_ttitrace_K16_1
${l2stream3_ttitrace_K018_1}    l2stream3_ttitrace_K018_1

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
@{multi_gnb_PA}    ${0}     ${127}
@{multi_gnb_PA_358}    ${0}
@{multi_gnb_PA_348}    ${0}    ${60}
@{multi_gnb_PA_383}    ${0}    ${83}

${ue_type_qcom}    ${tl.ues[1].capabilities[0]}
${ue_type_qcom_2}    ${tl.ues[2].capabilities[0]}

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

*** Test Cases ***
[1]CB008246-K_006_interworking_between_DL_CA_VoNR_SA_UE_support_lowSE_intra_gnb_CA_T+T+T
    [Documentation]    CB008246-K
    [Tags]    CB008246-K    CRT_TRUNK
    [Timeout]    2 hour
    [Setup]
    K006 Prerequisite
    K006 Step 1 UE2 attach
    K006 Step 2 check logs on wireshark
    K006 Step 3 UE2 make traffic
    K006 Step 4 check HR KPI and TTI
    K006 Step 5 UE2 make VoNR
    K006 Step 6 check logs on wireshark
    K006 Step 7 UE2 keep VoNR 5min
    K006 Step 8 check Pcell an Scell HR BR KPI
    K006 Step 9 UE2 hang up VoNR
    K006 Step 10 check logs on wireshark and HR KPI on Pcell and Scell
    [Teardown]    K006 Teardown


[1]CB008246-K_011_HRDRB _setup_after_Scell_addition_NSA_UE_support_lowSE_table_FAF_deactivated_in_Scell_intra_gnb_DL_CA
    [Documentation]    CB008246-K
    [Tags]    CB008246-K    CRT_TRUNK
    [Timeout]    2 hour
    [Setup]
    K011 Prerequisite
    K011 Step 1 UE2 change APN and attach
    K011 Step 2 check logs on wireshark
    K011 Step 3 UE2 make traffic
    K011 Step 4 UE2 setup QCI8
    K011 Step 5 check logs on wireshark
    K011 Step 6 check release KPI on Scell and HR KPI on Pcell
    K011 Step 7 UE2 release QCI8
    K011 Step 8 check logs on wireshark
    [Teardown]    K011 Teardown


[1]CB008246-K_018_ Interworking_with_CA_in_UL_and_DFT-s-OFDM_for_the_Scell
    [Documentation]    CB008246-K
    [Tags]    CB008246-K    CRT_TRUNK
    [Timeout]    2 hour
    [Setup]
    K018 Prerequisite
    K018 Step 1 UE2 attach
    K018 Step 2 check logs on wireshark
    K018 Step 3 UE2 make traffic and check HR KPI
    K018 Step 4 SINR decrease on scell
    K018 Step 5 check logs on wireshark
    K018 Step 6 check HR BR and legacy BR on scell
    K018 Step 7 SINR increase on scell
    K018 Step 8 check logs on wireshark
    K018 Step 9 check HR KPI on scell
    [Teardown]    K018 Teardown


*** Keywords ***
K006 Prerequisite
    robot_common_operations.Common Case Setup    allowed_faults_ids=4291
    AlarmWatchdog.add_allow_alarms    fault_id=4291
    ${release_year}=    check_release_year    release_info=${release_info}
    IF    ${release_year} > ${24}
        execute 04444966 steps
    END
    comment    Prerequisite: config 5QI5 as BR, 5QI7 as HR, dllaMcsMax64qamLowSERANK1HR set 20, CA enabled
    IF    ${enb_instance} == ${enb_id}[0]     #TL348
        Online modify parmeters     parameters_to_update=${PARAM_8246_gnb1_K_006_348}    skip_parameter_relation_errors=False
        paras change on BTS
        ...    paras=${CB008246_ciphering_algorithms}
        ...    delta_file_name=${epc_log_path}${CB008246_ciphering_algorithms_json_file}
        COAM Wait for gnb ready and cell setup
        PA one cell 0 on and set other cell value 4 port for T348    cellid=${cell_id_348}[1]    set_value=${multi_gnb_PA}[0]
    ELSE IF    ${enb_instance} == ${enb_id}[1]     #TL383
        Online modify parmeters     parameters_to_update=${PARAM_8246_gnb1_K_006_348}    skip_parameter_relation_errors=False
        paras change on BTS
        ...    paras=${CB008246_ciphering_algorithms}
        ...    delta_file_name=${epc_log_path}${CB008246_ciphering_algorithms_json_file}
        COAM Wait for gnb ready and cell setup
        PA one cell 0 on and set other cell value 4 port for T348    cellid=${cell_id_348}[1]    set_value=${multi_gnb_PA}[0]
    END
##    Power_ue.Prepare UE    ue_type=${ue_type_qcom}    ue_index=${1}
##    Switch QCOM APN to muti DRB    ue_index=${1}    ue_type=${ue_type_qcom}    apn_name=${dxdata2_apn_name}
#    choice required APN on QCOM SDX80 UE    usedapn=${X80_dxdata2apn_location}    ue_index=${1}

K006 Step 1 UE2 attach
    comment    step1: UE2 attach on gnb1 cell1
    Power_ue.Prepare UE    ue_type=${ue_type_qcom}    ue_index=${1}
#    put btslog_ini file to ute
#    ...    server_ip=${appserver_addr}    server_username=${appserver_username}    server_password=${appserver_password}
#    Start capture syslog via btslog on ute
    Start capture gNB log on master    filename=${log_name_K_006_1}
    Attach and check power UE    ue_type=${ue_type_qcom}    ue_index=${1}    gnb_index=${0}
    [Teardown]    Stop and download Logs on gNB on master    filename=${log_name_K_006_1}
#    ...    AND    Stop capture syslog via btslog on ute

K006 Step 2 check logs on wireshark
    comment    step2: check mcs_table and beatoffset on spcell and scell of 5QI5 and 5QI7
    check mcs_table and beatoffset    logname=${log_name_K_006_1}    legacy_mcs=False    lowSE_mcs=True
    ${SA_UE_RNTI_ID}    Get RNTI ID message    logname=${log_name_K_006_1}
    set test variable    ${SA_UE_RNTI_ID}

K006 Step 3 UE2 make traffic
    comment    step3: make DL traffic on 5QI7
    IF    ${enb_instance} == ${enb_id}[0]     #TL348
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[5]    value=${multi_gnb_PA_348}[0]    ip_addr=${att_ipaddr_1}
        Start only DL traffic and check tput    ue_index=${1}    cellid=${1}    ue_type=${ue_type_qcom}    gnb_index=${0}
        ...                                tput_dl_cell=${expected_tput_dl}    dl_throughput=${Send_Tput_DL}    duration=${7200}
        ...                                dl_port=${traffic_dl_port}
        Capture Ttitrace tti from WEBUI    names=${l2stream3_ttitrace_K006_1}    nr_phy_cell_ids=400    capture_time=2s
    ELSE IF    ${enb_instance} == ${enb_id}[1]     #TL383
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[5]    value=${multi_gnb_PA_348}[0]    ip_addr=${att_ipaddr_1}
        Start only DL traffic and check tput    ue_index=${1}    cellid=${1}    ue_type=${ue_type_qcom}    gnb_index=${0}
        ...                                tput_dl_cell=${expected_tput_dl}    dl_throughput=${Send_Tput_DL}    duration=${7200}
        ...                                dl_port=${traffic_dl_port}
        Capture Ttitrace tti from WEBUI    names=${l2stream3_ttitrace_K006_1}    nr_phy_cell_ids=400    capture_time=2s
    END

K006 Step 4 check HR KPI and TTI
    comment    step4: check lowSE HR counters and dllaMcsMax64qamLowSERANK1HR set lower or euqal than 20 on TTI(rrmDlProposedMcs)
    Prepare with PM counter time to caculate    period=start
    sleep    6min    reason=check KPIs after make traffic during 5mins and xml report generated 1min
    IF    ${enb_instance} == ${enb_id}[0]     #TL348
        Check DL HR traffic check dict KPI from pm file 348 383    KPI_file=CB008246_D_006_HR_KPI.txt    para_index=${1}
        Check DL HR traffic check dict KPI from pm file 348 383    KPI_file=CB008246_D_006_HR_KPI.txt    para_index=${3}
    ELSE IF    ${enb_instance} == ${enb_id}[1]     #TL383
        Check DL HR traffic check dict KPI from pm file 348 383    KPI_file=CB008246_D_006_HR_KPI.txt    para_index=${1}
        Check DL HR traffic check dict KPI from pm file 348 383    KPI_file=CB008246_D_006_HR_KPI.txt    para_index=${3}
    END
#    check value on TTI file K006_1    file_path=${epc_log_path}/${folder_name}/${file_name}    queried_filed=rrmDlProposedMcs
    check value on TTI file K006_1    file_path=${epc_log_path}/${l2stream3_ttitrace_K006_1}_dl.csv    queried_filed=dlFdSchedData.rrmDlProposedMcs

K006 Step 5 UE2 make VoNR
    comment    step5: make VoNR during middle of counter timing cycle
    Prepare with PM counter time to caculate    period=start
    sleep    1min    reason=make VoNR during middle of counter timing cycle
    Start capture gNB log on master    filename=${log_name_K_006_2}
    Step2: UE setup VoNR call on SDX80    ue_index=${1}
    sleep    20s
    check voice call status    ue_index=${1}    status=${2}
    [Teardown]    Stop and download Logs on gNB on master    filename=${log_name_K_006_2}

K006 Step 6 check logs on wireshark
    comment    step6: check lowSE HR and lowSE BR counters, and check msc_table(qam256) and beatoffset on wireshark
    check mcs_table and beatoffset    logname=${log_name_K_006_2}    lowSE_mcs=False

K006 Step 7 UE2 keep VoNR 5min
    comment    step7: keep VoNR 5min
    Prepare with PM counter time to caculate    period=end
    sleep    5min    reason=keep VoNR 5min

K006 Step 8 check Pcell an Scell HR BR KPI
    comment    step8: pscell check BR mcs counters have counter, but HR lowSE, mcs and BR lowSE can not count
    ...    scell check HR lowSE counters have counter, but BR lowSE, HR mcs and BR mcs can not count
    sleep    1min    reason=xml report generated 1min
    IF    ${enb_instance} == ${enb_id}[0]     #TL348
        check legacy DL traffic check dict KPI from pm file    KPI_file=CB008246_K_legacy_KPI.txt    para_index=${1}
        Check DL HR traffic check dict KPI from pm file 348 383    KPI_file=CB008246_D_006_HR_KPI.txt    para_index=${3}
    ELSE IF    ${enb_instance} == ${enb_id}[1]     #TL383
        check legacy DL traffic check dict KPI from pm file    KPI_file=CB008246_K_legacy_KPI.txt    para_index=${1}
        Check DL HR traffic check dict KPI from pm file 348 383    KPI_file=CB008246_D_006_HR_KPI.txt    para_index=${3}
    END

K006 Step 9 UE2 hang up VoNR
    comment    step9: hang up VoNR
    Start capture gNB log on master    filename=${log_name_K_006_3}
    Step3: UE hang up VoNR call    ue_index=${1}
    sleep    20s
    check voice call status    ue_index=${1}    status=${0}
    [Teardown]    Stop and download Logs on gNB on master    filename=${log_name_K_006_3}

K006 Step 10 check logs on wireshark and HR KPI on Pcell and Scell
    comment    step10: check msc_table and beatoffset on wireshark, check HR lowSE counters on 2 cells
    check mcs_table and beatoffset    logname=${log_name_K_006_3}    legacy_mcs=False    related_cell_num=1
    Prepare with PM counter time to caculate    period=start
    sleep    6min    reason=check KPIs after make traffic during 5mins and xml report generated 1min
    IF    ${enb_instance} == ${enb_id}[0]     #TL348
        Check DL HR traffic check dict KPI from pm file 348 383    KPI_file=CB008246_D_006_HR_KPI.txt    para_index=${1}
        Check DL HR traffic check dict KPI from pm file 348 383    KPI_file=CB008246_D_006_HR_KPI.txt    para_index=${3}
    ELSE IF    ${enb_instance} == ${enb_id}[1]     #TL383
        Check DL HR traffic check dict KPI from pm file 348 383    KPI_file=CB008246_D_006_HR_KPI.txt    para_index=${1}
        Check DL HR traffic check dict KPI from pm file 348 383    KPI_file=CB008246_D_006_HR_KPI.txt    para_index=${3}
    END

K006 Teardown
    robot_common_operations.Common Case Teardown
    AlarmWatchdog.remove_allow_alarms    fault_id=4291
    Stop DL or UL traffic    ue_index=${1}    ue_type=${ue_type_qcom}    direction=DL
    Step3: UE hang up VoNR call    ue_index=${1}
    QCM UE Recover Detach    ue_index=${1}    status=${0}    ue_type=${ue_type_qcom}
    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
    IF    ${enb_instance} == ${enb_id}[0]
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[1]    value=${multi_gnb_PA}[1]
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[5]    value=${multi_gnb_PA}[1]    ip_addr=${att_ipaddr_1}
        Online delete parmeters    parameters_to_update=${PARAM_8246_recover_delete_gnb1_K_006_348}    timeout=${300}
        Online modify parmeters    parameters_to_update=${PARAM_8246_recover_gnb1_K_006_348}    skip_parameter_relation_errors=False
        paras change on BTS
        ...    paras=${CB008246_recover_ciphering_algorithms}
        ...    delta_file_name=${epc_log_path}${CB008246_recover_ciphering_algorithms_json_file}
        COAM Wait for gnb ready and cell setup
    ELSE IF    ${enb_instance} == ${enb_id}[1]
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[1]    value=${multi_gnb_PA}[1]
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[5]    value=${multi_gnb_PA}[1]    ip_addr=${att_ipaddr_1}
        Online delete parmeters    parameters_to_update=${PARAM_8246_recover_delete_gnb1_K_006_348}    timeout=${300}
        Online modify parmeters    parameters_to_update=${PARAM_8246_recover_gnb1_K_006_348}    skip_parameter_relation_errors=False
        paras change on BTS
        ...    paras=${CB008246_recover_ciphering_algorithms}
        ...    delta_file_name=${epc_log_path}${CB008246_recover_ciphering_algorithms_json_file}
        COAM Wait for gnb ready and cell setup
    END
    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
#    get and analysis syslog







K011 Prerequisite
    robot_common_operations.Common Case Setup    allowed_faults_ids=4291,7523,7107
    AlarmWatchdog.add_allow_alarms    fault_id=7523
    AlarmWatchdog.add_allow_alarms    fault_id=7107
    AlarmWatchdog.add_allow_alarms    fault_id=4291
#    Start capture syslog via btslog on ute
    comment    step1: NSA QCI5 and QCI7 BR, QCI8 HR, scell not support 8246
    IF    ${enb_instance} == ${enb_id}[0]    #Tl348
#        Online modify parmeters     parameters_to_update=${PARAM_8246_gnb1_72a_to_72e}
#        Online delete objects    parameters_to_update=${OBJECT_DELETE_8246_gnb1_72a_to_72e}    timeout=${300}
        convert_to_json_file    data=${CB008246_72a_to_72e}    json_path=${case_logs_path}${CB008246_72a_to_72e_json_file_name}
        recommission for 72a to 72e    json_file=${case_logs_path}${CB008246_72a_to_72e_json_file_name}    skip_parameter_relation_errors=False
        COAM Wait for gnb ready and cell setup
        Online modify parmeters     parameters_to_update=${PARAM_8246_gnb1_K_011_348}    skip_parameter_relation_errors=False
        paras change on BTS
        ...    paras=${CB008246_ciphering_algorithms}
        ...    delta_file_name=${epc_log_path}${CB008246_ciphering_algorithms_json_file}
        PA one cell 0 on and set other cell value 4 port for T348    cellid=${cell_id_348}[3]    set_value=${multi_gnb_PA}[0]
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[3]    value=${multi_gnb_PA}[0]
        Change Attenuation value 4 port for multi PAs    cell=4Gcell${cell_id_348}[2]    value=${multi_gnb_PA}[0]
    ELSE IF    ${enb_instance} == ${enb_id}[1]    #TL383
#        Online modify parmeters     parameters_to_update=${PARAM_8246_gnb1_72a_to_72e}
#        Online delete objects    parameters_to_update=${OBJECT_DELETE_8246_gnb1_72a_to_72e}    timeout=${300}
        convert_to_json_file    data=${CB008246_72a_to_72e}    json_path=${case_logs_path}${CB008246_72a_to_72e_json_file_name}
        recommission for 72a to 72e    json_file=${case_logs_path}${CB008246_72a_to_72e_json_file_name}    skip_parameter_relation_errors=False
        COAM Wait for gnb ready and cell setup
        Online modify parmeters     parameters_to_update=${PARAM_8246_gnb1_K_011_348}    skip_parameter_relation_errors=False
        paras change on BTS
        ...    paras=${CB008246_ciphering_algorithms}
        ...    delta_file_name=${epc_log_path}${CB008246_ciphering_algorithms_json_file}
        PA one cell 0 on and set other cell value 4 port for T348    cellid=${cell_id_348}[3]    set_value=${multi_gnb_PA}[0]
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[3]    value=${multi_gnb_PA}[0]
        Change Attenuation value 4 port for multi PAs    cell=4Gcell${cell_id_348}[2]    value=${multi_gnb_PA}[0]
    END
    COAM Wait for gnb ready and cell setup
#    [Teardown]    Stop capture syslog via btslog on ute

K011 Step 1 UE2 change APN and attach
    comment    step1: UE change APN to mdrb1.nokia.com and attach on gnb1 cell1 NSA
#    choice required APN on QCOM SDX80 UE    usedapn=${X80_mdrb1apn_location}    ue_index=${1}
#    Start capture syslog via btslog on ute
    power_ue.Prepare UE    ue_type=${ue_type_qcom}    ue_index=${1}
#    Switch QCOM APN to muti DRB    ue_index=${1}    ue_type=${ue_type_qcom}    apn_name=${mdrb1_apn_name}
    Start capture gNB log on master    filename=${log_name_K_011_1}
    Attach and check power UE    ue_type=${ue_type_qcom}    ue_index=${1}    gnb_index=${0}    4G_check=True
    [Teardown]    Stop and download Logs on gNB on master    filename=${log_name_K_011_1}

K011 Step 2 check logs on wireshark
    comment    step2: check scell addition success, and wiresahrk mcs_table is 256qam if config 256qam
    check mcs_table and beatoffset NSA    logname=${log_name_K_011_1}    lowSE_mcs_nsa=False

K011 Step 3 UE2 make traffic
    comment    step3: make DL traffic on QCI7
    IF    ${enb_instance} == ${enb_id}[0]     #TL348
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[5]    value=${multi_gnb_PA_348}[0]    ip_addr=${att_ipaddr_1}
        Start only DL traffic and check tput    ue_index=${1}    cellid=${12}    ue_type=${ue_type_qcom}    gnb_index=${0}
        ...                                tput_dl_cell=${expected_tput_dl}    dl_throughput=${Send_Tput_DL}    duration=${7200}
        ...                                dl_port=${traffic_dl_port}
    ELSE IF    ${enb_instance} == ${enb_id}[1]     #TL383
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[5]    value=${multi_gnb_PA_348}[0]    ip_addr=${att_ipaddr_1}
        Start only DL traffic and check tput    ue_index=${1}    cellid=${12}    ue_type=${ue_type_qcom}    gnb_index=${0}
        ...                                tput_dl_cell=${expected_tput_dl}    dl_throughput=${Send_Tput_DL}    duration=${7200}
        ...                                dl_port=${traffic_dl_port}
    END

K011 Step 4 UE2 setup QCI8
    comment    step4: setup QCI8 via dynamic rule tool
    Prepare with PM counter time to caculate    period=start
    Sleep    1min    reason=wait for 1m to execute action for trigger counters
    Start capture gNB log on master    filename=${log_name_K_011_2}
    add or delete 5QI via npc dynamic rule    imsi=${tl.ues[1].imsi}    rule=ADD5QI8-PZ4-MXD
    sleep    20s    reason=wait for QCI08 added
    [Teardown]    Stop and download Logs on gNB on master    filename=${log_name_K_011_2}

K011 Step 5 check logs on wireshark
    comment    step5: check mcs_table lowSE and beatoffset on RRC Reconfig message, check scell release on UEcontextModifyrequest message
    check HR QCI added and scell released NSA    logname=${log_name_K_011_2}

K011 Step 6 check release KPI on Scell and HR KPI on Pcell
    comment    step6: check scell release counter on Scell, and after next couunter cycle(5min) check HR lowSE counters on Pcell
    Prepare with PM counter time to caculate    period=end
    sleep    1min    reason=xml report generated 1min
    Check scell release KPI from pm file    KPI_file=CB008246_K_011_HR_release_KPI.txt    para_index=${6}
    sleep    5min    reason=check KPIs after make traffic during 5mins and xml report generated 1min
    Capture Ttitrace tti from WEBUI    names=${l2stream3_ttitrace_K011_1}    nr_phy_cell_ids=544    capture_time=5s
    Check DL HR traffic check dict KPI from pm file for K11    KPI_file=CB008246_D_006_HR_KPI.txt    para_index=${2}

K011 Step 7 UE2 release QCI8
    comment    step7: release QCI8 via dynamic rule tool
    Start capture gNB log on master    filename=${log_name_K_011_3}
    add or delete 5QI via npc dynamic rule    imsi=${tl.ues[1].imsi}    rule=DEL5QI8-PZ4-MXD
    sleep    20s    reason=wait for QCI8 release
    [Teardown]    Stop and download Logs on gNB on master    filename=${log_name_K_011_3}

K011 Step 8 check logs on wireshark
    comment    step8: check scell is not added via wiresahrk
    check qci release and scell not added back NSA    logname=${log_name_K_011_3}
    should be equal    ${erab_1}    ${erab_2}

K011 Teardown
    robot_common_operations.Common Case Teardown
    AlarmWatchdog.remove_allow_alarms    fault_id=7523
    AlarmWatchdog.remove_allow_alarms    fault_id=7107
    AlarmWatchdog.remove_allow_alarms    fault_id=4291
#    Stop capture syslog via btslog on ute
    add or delete 5QI via npc dynamic rule    imsi=${tl.ues[1].imsi}    rule=DEL5QI8-PZ4-MXD
    Stop DL or UL traffic    ue_index=${1}    ue_type=${ue_type_qcom}    direction=DL
    QCM UE Recover Detach    ue_index=${1}    status=${0}    ue_type=${ue_type_qcom}
#    choice required APN on QCOM SDX80 UE    usedapn=${X80_dxdata2apn_location}    ue_index=${1}
#    Switch QCOM APN to muti DRB    ue_index=${1}    ue_type=${ue_type_qcom}    apn_name=${dxdata2_apn_name}
#    Switch QCOM APN to muti DRB    ue_index=${1}    ue_type=${ue_type_qcom}    apn_name=${dxdata2_apn_name}
    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
    IF    ${enb_instance} == ${enb_id}[0]    #Tl348
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[3]    value=${multi_gnb_PA}[1]
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[5]    value=${multi_gnb_PA}[1]    ip_addr=${att_ipaddr_1}
        Change Attenuation value 4 port for multi PAs    cell=4Gcell${cell_id_348}[2]    value=${multi_gnb_PA}[1]
#        Online delete parmeters    parameters_to_update=${PARAM_8246_recover_delete_gnb1_K_011_348}    timeout=${300}
#        Online modify parmeters    parameters_to_update=${PARAM_8246_recover_gnb1_K_011_348}    skip_parameter_relation_errors=False
#        COAM Wait for gnb ready and cell setup
        Setup for Env cell on-air for 2 gnb    is_commission_for_second_gnb=False    tl_scf_file_name=${tl_gnb1_scf_${sw_version}}
    ELSE IF    ${enb_instance} == ${enb_id}[1]    #Tl383
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[3]    value=${multi_gnb_PA}[1]
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[5]    value=${multi_gnb_PA}[1]    ip_addr=${att_ipaddr_1}
        Change Attenuation value 4 port for multi PAs    cell=4Gcell${cell_id_348}[2]    value=${multi_gnb_PA}[1]
#        Online delete parmeters    parameters_to_update=${PARAM_8246_recover_delete_gnb1_K_011_348}    timeout=${300}
#        Online modify parmeters    parameters_to_update=${PARAM_8246_recover_gnb1_K_011_348}    skip_parameter_relation_errors=False
#        COAM Wait for gnb ready and cell setup
        Setup for Env cell on-air for 2 gnb    is_commission_for_second_gnb=False    tl_scf_file_name=${tl_gnb1_scf_${sw_version}}
    END
#    get and analysis syslog







K018 Prerequisite
    robot_common_operations.Common Case Setup    allowed_faults_ids=4291,4546
    AlarmWatchdog.add_allow_alarms    fault_id=4291
    AlarmWatchdog.add_allow_alarms    fault_id=4546
    comment    Prerequisite: 5QI7 HR, pcell cell2 actUlDftSOfdm false, scell cell1 actUlDftSOfdm true
    IF    ${enb_instance} == ${enb_id}[0]     #TL348
#        Online modify parmeters     parameters_to_update=${PARAM_8246_gnb1_72a_to_72e}
#        Online delete objects    parameters_to_update=${OBJECT_DELETE_8246_gnb1_72a_to_72e}    timeout=${300}
#        COAM Wait for gnb ready and cell setup
        Online modify parmeters     parameters_to_update=${PARAM_8246_gnb1_K_018_348}    skip_parameter_relation_errors=False
        paras change on BTS
        ...    paras=${CB008246_ciphering_algorithms}
        ...    delta_file_name=${epc_log_path}${CB008246_ciphering_algorithms_json_file}
        COAM Wait for gnb ready and cell setup
        PA one cell 0 on and set other cell value 4 port for T348    cellid=${cell_id_348}[1]    set_value=${multi_gnb_PA}[0]
    ELSE IF    ${enb_instance} == ${enb_id}[1]     #TL383
#        Online modify parmeters     parameters_to_update=${PARAM_8246_gnb1_72a_to_72e}
#        Online delete objects    parameters_to_update=${OBJECT_DELETE_8246_gnb1_72a_to_72e}    timeout=${300}
#        COAM Wait for gnb ready and cell setup
        Online modify parmeters     parameters_to_update=${PARAM_8246_gnb1_K_018_348}    skip_parameter_relation_errors=False
        paras change on BTS
        ...    paras=${CB008246_ciphering_algorithms}
        ...    delta_file_name=${epc_log_path}${CB008246_ciphering_algorithms_json_file}
        COAM Wait for gnb ready and cell setup
        PA one cell 0 on and set other cell value 4 port for T348    cellid=${cell_id_348}[1]    set_value=${multi_gnb_PA}[0]
    END
##    Power_ue.Prepare UE    ue_type=${ue_type_qcom}    ue_index=${1}
##    Switch QCOM APN to muti DRB    ue_index=${1}    ue_type=${ue_type_qcom}    apn_name=${dxdata2_apn_name}
#    choice required APN on QCOM SDX80 UE    usedapn=${X80_dxdata2apn_location}    ue_index=${1}

K018 Step 1 UE2 attach
    comment    step1: UE2 attach on gnb1 cell2
    Power_ue.Prepare UE    ue_type=${tl.ues[2].capabilities[2]}    ue_index=${2}
    Start capture gNB log on master    filename=${log_name_K_018_1}
    Attach and check power UE    ue_type=${ue_type_qcom_2}    ue_index=${2}    gnb_index=${0}
    [Teardown]    Stop and download Logs on gNB on master    filename=${log_name_K_018_1}

K018 Step 2 check logs on wireshark
    comment    step2: check mcs_table lowSE and beatoffset on RRC reconfiguration message via wireshark
    check mcs_table and beatoffset    logname=${log_name_K_018_1}    index1=11    related_cell_num=4

K018 Step 3 UE2 make traffic and check HR KPI
    comment    step3: make UL traffic, check HR lowSE counters
#    put btslog_ini file to ute
#    ...    server_ip=${appserver_addr}    server_username=${appserver_username}    server_password=${appserver_password}
#    Start capture syslog via btslog on ute
    IF    ${enb_instance} == ${enb_id}[0]     #TL348
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[5]    value=${multi_gnb_PA_348}[0]    ip_addr=${att_ipaddr_1}
        Start only UL traffic and check tput    ue_index=${2}    cellid=${1}    ue_type=${ue_type_qcom_2}    gnb_index=${0}
        ...                                tput_ul_cell=${expected_tput_ul}    ul_throughput=${Send_Tput_UL}    duration=${7200}
        ...                                ul_port=${traffic_ul_port}
        Prepare with PM counter time to caculate    period=start
        sleep    6min    reason=check KPIs after make traffic during 5mins and xml report generated 1min
        # HR lowSE counters will be checked when RSRP good
        check HR traffic check dict KPI from pm file    KPI_file=CB008246_E_006_HR_KPI.txt    para_index=${1}
        check HR traffic check dict KPI from pm file    KPI_file=CB008246_E_006_HR_KPI.txt    para_index=${3}
    ELSE IF    ${enb_instance} == ${enb_id}[1]     #TL383
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[5]    value=${multi_gnb_PA_348}[0]    ip_addr=${att_ipaddr_1}
        Start only UL traffic and check tput    ue_index=${1}    cellid=${1}    ue_type=${ue_type_qcom}    gnb_index=${0}
        ...                                tput_ul_cell=${expected_tput_ul}    ul_throughput=${Send_Tput_UL}    duration=${7200}
        ...                                ul_port=${traffic_ul_port}
        Prepare with PM counter time to caculate    period=start
        sleep    6min    reason=check KPIs after make traffic during 5mins and xml report generated 1min
        # HR lowSE counters will be checked when RSRP good
        check HR traffic check dict KPI from pm file    KPI_file=CB008246_E_006_HR_KPI.txt    para_index=${1}
        check HR traffic check dict KPI from pm file    KPI_file=CB008246_E_006_HR_KPI.txt    para_index=${3}
    END
#    [Teardown]    Stop capture syslog via btslog on ute

K018 Step 4 SINR decrease on scell
    comment    step4: decrease RSRP of scell, gnb1 cell1 PA to 83db to trigger SINR decrease to below value of ulTransPrecodeOnSinrThresh(1.5)
    Start capture gNB log on master    filename=${log_name_K_018_2}
    IF    ${enb_instance} == ${enb_id}[0]     #TL348
        Set the attenuation value of ports simultaneously by step
        ...    att_ports=${5Gcell5_ANT}    values=${5Gcell5_ANT_values}    att_ipaddr=${att_ipaddr_1}
    ELSE IF    ${enb_instance} == ${enb_id}[1]     #TL383
        Set the attenuation value of ports simultaneously by step
        ...    att_ports=${5Gcell5_ANT}    values=${5Gcell5_ANT_values}    att_ipaddr=${att_ipaddr_1}
    END
    sleep    20s
    [Teardown]    Stop and download Logs on gNB on master    filename=${log_name_K_018_2}

K018 Step 5 check logs on wireshark
    comment    step5: check mcs_table 256Qam on RRC Reconfig via wireshark
    check mcs_table and beatoffset    logname=${log_name_K_018_2}    lowSE_mcs=False    index1=11    index2=8

K018 Step 6 check HR BR and legacy BR on scell
    comment    step6: wait 5min, check lowSE HR and BR counters not counting on scell,
    ...    and check 64Qam counters on scell(due to DFT)  ulTransPrecodeOffSinrThresh
    Prepare with PM counter time to caculate    period=start
    sleep    6min    reason=check KPIs after make traffic during 5mins and xml report generated 1min
#    Capture Ttitrace tti from WEBUI    names=${l2stream3_ttitrace_K018_1}    nr_phy_cell_ids=700    capture_time=5s
    # pcell: cell400
    # scell: cell700
    # when SINR < ulTransPrecodeOnSinrThresh scell check legacy DFT counters
    IF    ${enb_instance} == ${enb_id}[0]     #TL348
        Run Keyword And Continue On Failure
        ...    check UL DFT_S_OFDM traffic check dict KPI from pm file    KPI_file=CB008246_K_018_DFTSOFDM_KPI.txt    para_index=${3}
        check HR traffic check dict KPI from pm file    KPI_file=CB008246_E_006_HR_KPI.txt    para_index=${1}
    ELSE IF    ${enb_instance} == ${enb_id}[1]     #TL383
        Run Keyword And Continue On Failure
        ...    check UL DFT_S_OFDM traffic check dict KPI from pm file    KPI_file=CB008246_K_018_DFTSOFDM_KPI.txt    para_index=${3}
        check HR traffic check dict KPI from pm file    KPI_file=CB008246_E_006_HR_KPI.txt    para_index=${1}
    END

K018 Step 7 SINR increase on scell
    comment    step7: increase RSRP of scell, gnb1 cell1 PA to 0db to trigger SINR increase to above value of ulTransPrecodeOffSinrThresh(3.5)
    Start capture gNB log on master    filename=${log_name_K_018_3}
    IF    ${enb_instance} == ${enb_id}[0]     #TL348
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[5]    value=${multi_gnb_PA_348}[0]    ip_addr=${att_ipaddr_1}
    ELSE IF    ${enb_instance} == ${enb_id}[1]     #TL383
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[5]    value=${multi_gnb_PA_348}[0]    ip_addr=${att_ipaddr_1}
    END
    sleep    30s
    [Teardown]    Stop and download Logs on gNB on master    filename=${log_name_K_018_3}

K018 Step 8 check logs on wireshark
    comment    step8: check mcs_table lowSE and beatoffset on RRC Reconfiguration message via wireshark
    check mcs_table and beatoffset    logname=${log_name_K_018_3}    legacy_mcs=False

K018 Step 9 check HR KPI on scell
    comment    step9: check HR lowSE HR counters on scell
    Prepare with PM counter time to caculate    period=start
    sleep    6min    reason=check KPIs after make traffic during 5mins and xml report generated 1min
    # pcell: cell400
    # scell: cell700
    # when SINR > ulTransPrecodeOffSinrThresh scell check HR lowSE counters
    IF    ${enb_instance} == ${enb_id}[0]     #TL348
        check HR traffic check dict KPI from pm file    KPI_file=CB008246_E_006_HR_KPI.txt    para_index=${1}
        check HR traffic check dict KPI from pm file    KPI_file=CB008246_E_006_HR_KPI.txt    para_index=${3}
    ELSE IF    ${enb_instance} == ${enb_id}[1]     #TL383
        check HR traffic check dict KPI from pm file    KPI_file=CB008246_E_006_HR_KPI.txt    para_index=${1}
        check HR traffic check dict KPI from pm file    KPI_file=CB008246_E_006_HR_KPI.txt    para_index=${3}
    END

K018 Teardown
    robot_common_operations.Common Case Teardown
    AlarmWatchdog.remove_allow_alarms    fault_id=4291
    AlarmWatchdog.remove_allow_alarms    fault_id=4546
    Stop DL or UL traffic    ue_index=${2}    ue_type=${ue_type_qcom_2}    direction=UL
    QCM UE Recover Detach    ue_index=${2}    status=${0}    ue_type=${ue_type_qcom_2}
    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
    IF    ${enb_instance} == ${enb_id}[0]
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[1]    value=${multi_gnb_PA}[1]
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[5]    value=${multi_gnb_PA}[1]    ip_addr=${att_ipaddr_1}
        Online delete parmeters    parameters_to_update=${PARAM_8246_recover_delete_gnb1_K_018_348}    timeout=${300}
        Online modify parmeters    parameters_to_update=${PARAM_8246_recover_gnb1_K_018_348}    skip_parameter_relation_errors=False
        paras change on BTS
        ...    paras=${CB008246_recover_ciphering_algorithms}
        ...    delta_file_name=${epc_log_path}${CB008246_recover_ciphering_algorithms_json_file}
        COAM Wait for gnb ready and cell setup
#        Setup for Env cell on-air for 2 gnb    is_commission_for_second_gnb=False    tl_scf_file_name=${tl_gnb1_scf_${sw_version}}
    ELSE IF    ${enb_instance} == ${enb_id}[1]
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[1]    value=${multi_gnb_PA}[1]
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[5]    value=${multi_gnb_PA}[1]    ip_addr=${att_ipaddr_1}
        Online delete parmeters    parameters_to_update=${PARAM_8246_recover_delete_gnb1_K_018_348}    timeout=${300}
        Online modify parmeters    parameters_to_update=${PARAM_8246_recover_gnb1_K_018_348}    skip_parameter_relation_errors=False
        paras change on BTS
        ...    paras=${CB008246_recover_ciphering_algorithms}
        ...    delta_file_name=${epc_log_path}${CB008246_recover_ciphering_algorithms_json_file}
        COAM Wait for gnb ready and cell setup
#        Setup for Env cell on-air for 2 gnb    is_commission_for_second_gnb=False    tl_scf_file_name=${tl_gnb1_scf_${sw_version}}
    END
#    get and analysis syslog






execute 04444966 steps
    IF    ${enb_instance} == ${enb_id}[0]     #TL348
        online update list parameter model    parameters=${LIST_PARAM_MODIFY_gnb1_04444966_348}
        COAM Wait for gnb ready and cell setup
        Online modify parmeters     parameters_to_update=${PARAM_8246_gnb1_04444966_348}    skip_parameter_relation_errors=False
        paras change on BTS
        ...    paras=${CB008246_ciphering_algorithms}
        ...    delta_file_name=${epc_log_path}${CB008246_ciphering_algorithms_json_file}
        COAM Wait for gnb ready and cell setup
        PA one cell 0 on and set other cell value 4 port for T348    cellid=${cell_id_348}[5]    set_value=${multi_gnb_PA}[0]
    ELSE IF    ${enb_instance} == ${enb_id}[1]     #TL383
        online update list parameter model    parameters=${LIST_PARAM_MODIFY_gnb1_04444966_348}
        COAM Wait for gnb ready and cell setup
        Online modify parmeters     parameters_to_update=${PARAM_8246_gnb1_04444966_348}    skip_parameter_relation_errors=False
        paras change on BTS
        ...    paras=${CB008246_ciphering_algorithms}
        ...    delta_file_name=${epc_log_path}${CB008246_ciphering_algorithms_json_file}
        COAM Wait for gnb ready and cell setup
        PA one cell 0 on and set other cell value 4 port for T348    cellid=${cell_id_348}[5]    set_value=${multi_gnb_PA}[0]
    END
    pdu session setup 5qi5 first then 5qi7
    Check wireshark log for PDUSessionResourceModifyRequest ok    logname=${log_name_04444966_3}
    Check wireshark log for PDUSessionResourceModifyResponse ok    logname=${log_name_04444966_3}
    [Teardown]    Run Keywords
    ...    online update list parameter model    parameters=${LIST_PARAM_RECOVER_MODIFY_gnb1_04444966_348}
    ...    AND    COAM Wait for gnb ready and cell setup
    ...    AND    Online modify parmeters     parameters_to_update=${PARAM_8246_recover_gnb1_04444966_348}    skip_parameter_relation_errors=False
    ...    AND    paras change on BTS
    ...    paras=${CB008246_recover_ciphering_algorithms}
    ...    delta_file_name=${epc_log_path}${CB008246_recover_ciphering_algorithms_json_file}
    ...    AND    COAM Wait for gnb ready and cell setup

pdu session setup 5qi5 first then 5qi7
    Switch QCOM SDX80 airplane mode status on    ue_index=${1}    airplane_enable=${True}
    data disable
    Switch QCOM SDX80 airplane mode status on    ue_index=${1}    airplane_enable=${False}
    pdu session setup 5qi5 first
    pdu session setup 5qi7 then
    voice call make
    [Teardown]    Switch QCOM SDX80 airplane mode status on    ue_index=${1}    airplane_enable=${False}

data disable
    Connect to control pc via cygwin    ue_index=${1}
    operate data button on SDX70    ue_index=${1}    status=disable
    Sleep    2s
    [Teardown]    csn.disconnect    connection=cygwin

pdu session setup 5qi5 first
    Start capture gNB log on master    filename=${log_name_04444966_1}
    Switch QCOM SDX80 airplane mode status on    ue_index=${1}    airplane_enable=${True}
    Sleep    2s
    [Teardown]    Stop and download Logs on gNB on master    filename=${log_name_04444966_1}

pdu session setup 5qi7 then
    Start capture gNB log on master    filename=${log_name_04444966_2}
    Connect to control pc via cygwin    ue_index=${1}
    # data enable
    operate data button on SDX70    ue_index=${1}    status=enable
    [Teardown]    Run Keywords
    ...    csn.disconnect    connection=cygwin
    ...    AND    Stop and download Logs on gNB on master    filename=${log_name_04444966_2}

voice call make
    Start capture gNB log on master    filename=${log_name_04444966_3}
    # make voice
    Step2: UE setup VoNR call on SDX80    ue_index=${1}
    sleep    20s
    check voice call status    ue_index=${1}    status=${2}
    [Teardown]    Run Keywords    Stop and download Logs on gNB on master    filename=${log_name_04444966_3}
    ...    AND    Step3: UE hang up VoNR call    ue_index=${1}
    ...    AND    sleep    20s
    ...    AND    check voice call status    ue_index=${1}    status=${0}

Check wireshark log for PDUSessionResourceModifyRequest ok
    [Arguments]    ${logname}
    ${all_packets}=    load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    ...    command_template=${command_template_with_Y}    alias=test6
    ${Code26_0} =    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 26 and ngap.fiveQI==1
    Log To Console    check PDUSessionResourceModifyRequest
    ${filtered_packets}=    filter_packets_by_expression
    ...    filter_expression=${Code26_0}    pcap_parser=test6
    ${5qi}=    get_field_value_by_xpath    xpath=.//ngap.fiveQI    pcap_parser=test6
#    Should Be Equal    ${5qi[0]}    1
    Should Contain    ${5qi}    1

Check wireshark log for PDUSessionResourceModifyResponse ok
    [Arguments]    ${logname}
    ${all_packets}=    load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    ...    command_template=${command_template_with_Y}    alias=test6
    ${Code26_1} =    Catenate    ngap.NGAP_PDU == 1 and ngap.procedureCode == 26
    Log To Console    check PDUSessionResourceModifyResponse
    ${filtered_packets}=    filter_packets_by_expression    filter_expression=${Code26_1}    pcap_parser=test6
    ${criticality} =    get_field_value_by_xpath    xpath=.//ngap.criticality    pcap_parser=test6
#    Should Be Equal    ${criticality[0]}    0
    Should Contain    ${criticality}    0

#    Check EIAP log name    logname=${logname}
    ${all_packets}=    load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    ${ULRRCMessageTransfer} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 13
    Log To Console    check RRCreconfigurecomplete
    ${filtered_packets}=    filter_packets_by_expression    filter_expression=${ULRRCMessageTransfer}
    ${criticality} =    get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//f1ap.criticality
#    Should Be Equal    ${criticality[0]}    1
    Should Contain    ${criticality}    1

Set multi DRB traffic DL UL port
    ${port_common}=    Convert To Integer    ${tl.ues[1].iperf_details.port}
    ${DL_UL_port_mdrb2_5QI7}=    Evaluate    ${port_common}+${200}
    ${DL_UL_port_mdrb2_5QI3}=    Evaluate    ${port_common}+${300}
    ${DL_UL_port_mdrb2_5QI4}=    Evaluate    ${port_common}+${400}
    Set Suite Variable    ${DL_UL_port_mdrb2_5QI7}
    Set Suite Variable    ${DL_UL_port_mdrb2_5QI3}
    Set Suite Variable    ${DL_UL_port_mdrb2_5QI4}

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
    should be true    ${result_1}>${0}
    ${result_2}    evaluate    abs(${dict_kpis_name_value}[${K_legacy_04}])
    should be true    ${0}<=${result_2}<${50}

Check scell release KPI from pm file
    [Arguments]     ${KPI_file}    ${para_index}    ${index}=${0}
    comment    in this case, 1 scell is released
    ${dict_kpis_name_value}=    get dict kpi from pm file    KPI_file=${KPI_file}    para_index=${para_index}    index=${index}
    check required KPI via pm file    KPI_name_list=${CB008246_K_011_scell_release_check_kpi_names_value}
    ...    check_field=equal_specified_value    dict_kpi_get=${dict_kpis_name_value}    equal_specfied=${1}

Check DL HR traffic check dict KPI from pm file for K06
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

Check DL HR traffic check dict KPI from pm file for K11
    [Arguments]     ${KPI_file}    ${para_index}    ${index}=${0}
    ${dict_kpis_name_value}=    get dict kpi from pm file    KPI_file=${KPI_file}    para_index=${para_index}    index=${index}
    check required KPI via pm file    KPI_name_list=${CB008246_K_011_HR_traffic_check_kpi_names_value_zero}
    ...    check_field=equal_specified_value    dict_kpi_get=${dict_kpis_name_value}
    check required KPI via pm file    KPI_name_list=${CB008246_K_011_HR_traffic_check_kpi_names_larger_zero}
    ...    check_field=larger_specified_value    dict_kpi_get=${dict_kpis_name_value}
    check required KPI via pm file    KPI_name_list=${CB008246_K_011_HR_traffic_check_kpi_names_less_specified_value}
    ...    check_field=less_specified_value    dict_kpi_get=${dict_kpis_name_value}    less_specfied=${0.011}
    check required KPI via pm file    KPI_name_list=${CB008246_K_011_HR_traffic_check_kpi_names_greater_than_or_equal_specfied}
    ...    check_field=greater_than_or_equal_specified_value    dict_kpi_get=${dict_kpis_name_value}    greater_than_or_equal_specfied=${0}

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

check UL legacy traffic check dict KPI from pm file
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

check UL CG traffic check dict KPI from pm file
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
    Should Be True    ${result_0}<=${50}
    ${result_1}=    Evaluate
    ...    abs(${dict_kpis_name_value}[${I_007_HR_value_4}]+${dict_kpis_name_value}[${I_007_HR_value_5}]-${dict_kpis_name_value}[${I_007_HR_value_3}])
    Should Be True    ${result_1}<=${2}
    ${result_2_1}=    Evaluate    ${dict_kpis_name_value}[${I_007_HR_value_7}]-${dict_kpis_name_value}[${I_007_HR_value_8}]
    ${result_2_2}=    Evaluate    ${result_2_1}-${dict_kpis_name_value}[${I_007_HR_value_6}]
    Should Be True    ${-50}<${result_2_2}<${50}
    ${result_3}=    Evaluate    ${dict_kpis_name_value}[${I_007_HR_value_9}]+${dict_kpis_name_value}[${I_007_HR_value_10}]
    Should Be True    ${result_3}>${0}

check UL DFT_S_OFDM traffic check dict KPI from pm file
    [Arguments]     ${KPI_file}    ${para_index}    ${index}=${0}
    ${dict_kpis_name_value}=    get dict kpi from pm file    KPI_file=${KPI_file}    para_index=${para_index}    index=${index}
    check required KPI via pm file    KPI_name_list=${CB008246_K_018_HR_traffic_check_kpi_names_value_zero}
    ...    check_field=equal_specified_value    dict_kpi_get=${dict_kpis_name_value}
    check required KPI via pm file    KPI_name_list=${CB008246_K_018_HR_traffic_check_kpi_names_larger_zero}
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

check UL legacy BR traffic check dict KPI from pm file
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

Check UL_UE_MCS_table_Capbility 256Qam
    [Arguments]    ${logname}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    command_template=${command_template_with_Y}    alias=test6
    ${filter_expression}=     Catenate    f1ap.procedureCode == 12 and nr-rrc.uplinkBWP_ToAddModList == 1 and nr-rrc.mcs_Table == 1
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_mcs_Table}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.mcs_Table    pcap_parser=test6
    Should Be Equal    ${nr_rrc_mcs_Table[1]}    1

Check UL_UE_MCS_table_Capbility
    [Arguments]    ${logname}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    command_template=${command_template_with_Y}    alias=test6
    ${filter_expression}=     Catenate    f1ap.procedureCode == 12 and nr-rrc.uplinkBWP_ToAddModList == 1 and nr-rrc.mcs_Table == 1
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_mcs_Table}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.mcs_Table    pcap_parser=test6
    Should Be Equal    ${nr_rrc_mcs_Table[1]}    1

check mcs_table and beatoffset
    [Arguments]    ${logname}    ${legacy_mcs}=True    ${lowSE_mcs}=True    ${related_cell_num}=2    ${index1}=10    ${index2}=11
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}
    run keyword if    '${legacy_mcs}' == 'True'    check legacy mcs_table and beatoffset on wireshark    index1=${index1}    index2=${index2}
    run keyword if    '${lowSE_mcs}' == 'True'    check lowSE table and beatoffset on wireshark    related_cell_num=${related_cell_num}

check legacy mcs_table and beatoffset on wireshark
    [Arguments]    ${index1}=10    ${index2}=11
    # DLRRCMessageTransfer, RRC Reconfiguration, DL NAS transport, PDU session establishment accept
#    ${legacy_beatoffset_filter}    catenate    ((f1ap.F1AP_PDU == 0) && (f1ap.procedureCode == 12)) && (nr-rrc.betaOffsetACK_Index2 == 8)
    ${legacy_beatoffset_filter}    catenate    ((f1ap.F1AP_PDU == 0) && (f1ap.procedureCode == 12)) && (nr-rrc.betaOffsetACK_Index2 == ${index2})
    ${legacy_beatoffset_packets}    cap.filter_packets_by_expression    filter_expression=${legacy_beatoffset_filter}
    ${betaOffsetACK_Index1}=    cap.Get Field Value By Xpath    pdml_list=${legacy_beatoffset_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetACK_Index1
    ${betaOffsetACK_Index2}=    cap.Get Field Value By Xpath    pdml_list=${legacy_beatoffset_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetACK_Index2
    ${betaOffsetACK_Index3}=    cap.Get Field Value By Xpath    pdml_list=${legacy_beatoffset_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetACK_Index3
    ${betaOffsetCSI_Part1_Index1}=    cap.Get Field Value By Xpath    pdml_list=${legacy_beatoffset_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetCSI_Part1_Index1
    ${betaOffsetCSI_Part1_Index2}=    cap.Get Field Value By Xpath    pdml_list=${legacy_beatoffset_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetCSI_Part1_Index2
#    Run Keyword If    '${release_info}' == 'SBTS24R2_ENB_0000'
#    ...    Should Be Equal    ${betaOffsetACK_Index1}[0]    11
#    ...    ELSE    Should Be Equal    ${betaOffsetACK_Index1}[0]    ${index1}
    Should Be Equal    ${betaOffsetACK_Index1}[0]    ${index1}
#    Should Be Equal    ${betaOffsetACK_Index2}[0]    8
    Should Be Equal    ${betaOffsetACK_Index2}[0]    ${index2}
    Should Be Equal    ${betaOffsetACK_Index3}[0]    6
    Should Be Equal    ${betaOffsetCSI_Part1_Index1}[0]    13
    Should Be Equal    ${betaOffsetCSI_Part1_Index2}[0]    13

check lowSE table and beatoffset on wireshark
    [Arguments]    ${related_cell_num}=2
    # DLRRCMessageTransfer, RRC Reconfiguration, DL NAS transport, PDU session establishment accept
    ${pdu_s_e_accept_filter}    catenate    ((f1ap.F1AP_PDU == 0) && (f1ap.procedureCode == 12)) && (nr-rrc.mcs_Table == 1)
    ${pdu_s_e_accept_packets}    cap.filter_packets_by_expression    filter_expression=${pdu_s_e_accept_filter}
    ${mcs_Table}=    cap.Get Field Value By Xpath    pdml_list=${pdu_s_e_accept_packets}
    ...                                                xpath=.//nr-rrc.mcs_Table
    ${no_duplicates_mcs_Table}=    Remove Duplicates    ${mcs_Table}
    Should Be Equal As Integers    ${no_duplicates_mcs_Table}[0]    1
#    FOR    ${i}    IN    @{mcs_Table}
#        should be equal    ${i}    1
#    END
#    ${num}    get length    ${mcs_Table}
#    # ca_cell_num = pcell + scell, +1 due to DL+UL for one Pcell
    ${total_num}    evaluate    ${related_cell_num}+1
#    should be equal as integers    ${num}    ${total_num}
    ${betaOffsetACK_Index1}=    cap.Get Field Value By Xpath    pdml_list=${pdu_s_e_accept_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetACK_Index1
    ${betaOffsetACK_Index2}=    cap.Get Field Value By Xpath    pdml_list=${pdu_s_e_accept_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetACK_Index2
    ${betaOffsetACK_Index3}=    cap.Get Field Value By Xpath    pdml_list=${pdu_s_e_accept_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetACK_Index3
    ${betaOffsetCSI_Part1_Index1}=    cap.Get Field Value By Xpath    pdml_list=${pdu_s_e_accept_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetCSI_Part1_Index1
    ${betaOffsetCSI_Part1_Index2}=    cap.Get Field Value By Xpath    pdml_list=${pdu_s_e_accept_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetCSI_Part1_Index2
    Should Be Equal    ${betaOffsetACK_Index1}[0]    9
    Should Be Equal    ${betaOffsetACK_Index2}[0]    6
    Should Be Equal    ${betaOffsetACK_Index3}[0]    3
    Should Be Equal    ${betaOffsetCSI_Part1_Index1}[0]    11
    Should Be Equal    ${betaOffsetCSI_Part1_Index2}[0]    6

check mcs_table and beatoffset NSA
    [Arguments]    ${logname}    ${legacy_mcs_nsa}=True    ${lowSE_mcs_nsa}=True    ${related_cell_num}=2
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}
    run keyword if    '${legacy_mcs_nsa}' == 'True'    check legacy mcs_table and beatoffset NSA on wireshark
    run keyword if    '${lowSE_mcs_nsa}' == 'True'    check lowSE table and beatoffset NSA on wireshark    related_cell_num=${related_cell_num}

check legacy mcs_table and beatoffset NSA on wireshark
    # SgNBAdditionRequestAcknowledge, RRC Reconfiguration
    ${UeAddition_req_filter}    Catenate    (x2ap.X2AP_PDU == 1) && (x2ap.procedureCode == 27)
    ${UeAddition_req_packets}    cap.filter_packets_by_expression    filter_expression=${UeAddition_req_filter}
    ${betaOffsetACK_Index1}=    cap.Get Field Value By Xpath    pdml_list=${UeAddition_req_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetACK_Index1
    ${betaOffsetACK_Index2}=    cap.Get Field Value By Xpath    pdml_list=${UeAddition_req_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetACK_Index2
    ${betaOffsetACK_Index3}=    cap.Get Field Value By Xpath    pdml_list=${UeAddition_req_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetACK_Index3
    ${betaOffsetCSI_Part1_Index1}=    cap.Get Field Value By Xpath    pdml_list=${UeAddition_req_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetCSI_Part1_Index1
    ${betaOffsetCSI_Part1_Index2}=    cap.Get Field Value By Xpath    pdml_list=${UeAddition_req_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetCSI_Part1_Index2
    Should Be Equal    ${betaOffsetACK_Index1}[0]    10
    Should Be Equal    ${betaOffsetACK_Index2}[0]    11
    Should Be Equal    ${betaOffsetACK_Index3}[0]    6
    Should Be Equal    ${betaOffsetCSI_Part1_Index1}[0]    13
    Should Be Equal    ${betaOffsetCSI_Part1_Index2}[0]    13

check lowSE table and beatoffset NSA on wireshark
    [Arguments]    ${related_cell_num}=2
    # DLRRCMessageTransfer, RRC Reconfiguration, DL NAS transport, PDU session establishment accept
    ${pdu_s_e_accept_filter}    catenate    ((f1ap.F1AP_PDU == 0) && (f1ap.procedureCode == 12)) && (nr-rrc.mcs_Table == 1)
    ${pdu_s_e_accept_packets}    cap.filter_packets_by_expression    filter_expression=${pdu_s_e_accept_filter}
    ${mcs_Table}=    cap.Get Field Value By Xpath    pdml_list=${pdu_s_e_accept_packets}
    ...                                                xpath=.//nr-rrc.mcs_Table
    ${no_duplicates_mcs_Table}=    Remove Duplicates    ${mcs_Table}
    Should Be Equal As Integers    ${no_duplicates_mcs_Table}[0]    1
#    FOR    ${i}    IN    @{mcs_Table}
#        should be equal    ${i}    1
#    END
#    ${num}    get length    ${mcs_Table}
#    # ca_cell_num = pcell + scell, +1 due to DL+UL for one Pcell
    ${total_num}    evaluate    ${related_cell_num}+1
#    should be equal as integers    ${num}    ${total_num}
    ${betaOffsetACK_Index1}=    cap.Get Field Value By Xpath    pdml_list=${pdu_s_e_accept_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetACK_Index1
    ${betaOffsetACK_Index2}=    cap.Get Field Value By Xpath    pdml_list=${pdu_s_e_accept_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetACK_Index2
    ${betaOffsetACK_Index3}=    cap.Get Field Value By Xpath    pdml_list=${pdu_s_e_accept_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetACK_Index3
    ${betaOffsetCSI_Part1_Index1}=    cap.Get Field Value By Xpath    pdml_list=${pdu_s_e_accept_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetCSI_Part1_Index1
    ${betaOffsetCSI_Part1_Index2}=    cap.Get Field Value By Xpath    pdml_list=${pdu_s_e_accept_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetCSI_Part1_Index2
    Should Be Equal    ${betaOffsetACK_Index1}[0]    9
    Should Be Equal    ${betaOffsetACK_Index2}[0]    6
    Should Be Equal    ${betaOffsetACK_Index3}[0]    3
    Should Be Equal    ${betaOffsetCSI_Part1_Index1}[0]    11
    Should Be Equal    ${betaOffsetCSI_Part1_Index2}[0]    6

check HR QCI added and scell released NSA
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}
    check HR QCI added NSA on wireshark
    check scell released NSA on wireshark
    ${erab_1}=    get erab value when qci added NSA on wireshark
    set test variable    ${erab_1}

check HR QCI added NSA on wireshark
    # SgNBModificationRequest
    ${SgNBModificationRequest_filter}    catenate    (x2ap.X2AP_PDU == 0) && (x2ap.procedureCode == 29)
    ${SgNBModificationRequest_packets}    cap.filter_packets_by_expression    filter_expression=${SgNBModificationRequest_filter}
    ${x2ap_qCI}=    cap.Get Field Value By Xpath    pdml_list=${SgNBModificationRequest_packets}
    ...                                                xpath=.//x2ap.qCI
    should be equal    ${x2ap_qCI}[0]    8
    # SgNBModificationRequestAcknowledge, RRC Reconfiguration
    ${SgNBModificationRequestAcknowledge_filter}    catenate    (x2ap.X2AP_PDU == 1) && (x2ap.procedureCode == 29)
    ${SgNBModificationRequestAcknowledge_packets}    cap.filter_packets_by_expression
    ...    filter_expression=${SgNBModificationRequestAcknowledge_filter}
    ${x2ap_qCI}=    cap.Get Field Value By Xpath    pdml_list=${SgNBModificationRequestAcknowledge_packets}
    ...                                                xpath=.//x2ap.qCI
    ${mcs_Table}=    cap.Get Field Value By Xpath    pdml_list=${SgNBModificationRequestAcknowledge_packets}
    ...                                                xpath=.//nr-rrc.mcs_Table
    should be equal    ${mcs_Table}[0]    1
    ${betaOffsetACK_Index1}=    cap.Get Field Value By Xpath    pdml_list=${SgNBModificationRequestAcknowledge_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetACK_Index1
    ${betaOffsetACK_Index2}=    cap.Get Field Value By Xpath    pdml_list=${SgNBModificationRequestAcknowledge_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetACK_Index2
    ${betaOffsetACK_Index3}=    cap.Get Field Value By Xpath    pdml_list=${SgNBModificationRequestAcknowledge_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetACK_Index3
    ${betaOffsetCSI_Part1_Index1}=    cap.Get Field Value By Xpath    pdml_list=${SgNBModificationRequestAcknowledge_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetCSI_Part1_Index1
    ${betaOffsetCSI_Part1_Index2}=    cap.Get Field Value By Xpath    pdml_list=${SgNBModificationRequestAcknowledge_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetCSI_Part1_Index2
    Should Be Equal    ${betaOffsetACK_Index1}[0]    9
    Should Be Equal    ${betaOffsetACK_Index2}[0]    6
    Should Be Equal    ${betaOffsetACK_Index3}[0]    3
    Should Be Equal    ${betaOffsetCSI_Part1_Index1}[0]    11
    Should Be Equal    ${betaOffsetCSI_Part1_Index2}[0]    6

check scell released NSA on wireshark
    # UEContextModificationRequest
    ${UEContextModificationRequest_filter}    catenate    ((f1ap.F1AP_PDU == 0) && (f1ap.procedureCode == 7)) && (f1ap.id == 51)
    ${UEContextModificationRequest_packets}    cap.filter_packets_by_expression    filter_expression=${UEContextModificationRequest_filter}
    ${f1ap_id}=    cap.Get Field Value By Xpath    pdml_list=${UEContextModificationRequest_packets}
    ...                                                xpath=.//f1ap.id
    should contain    ${f1ap_id}    51

get erab value when qci added NSA on wireshark
    # SgNBModificationRequestAcknowledge, RRC Reconfiguration
    ${SgNBModificationRequestAcknowledge_filter}    catenate    (x2ap.X2AP_PDU == 1) && (x2ap.procedureCode == 29)
    ${SgNBModificationRequestAcknowledge_packets}    cap.filter_packets_by_expression
    ...    filter_expression=${SgNBModificationRequestAcknowledge_filter}
    ${x2ap_e_RAB_ID}=    cap.Get Field Value By Xpath    pdml_list=${SgNBModificationRequestAcknowledge_packets}
    ...                                                xpath=.//x2ap.e_RAB_ID
    [Return]    ${x2ap_e_RAB_ID}[0]

check legacy mcs_table and beatoffset SgNBModificationRequestAcknowledge NSA on wireshark
    # SgNBModificationRequestAcknowledge, RRC Reconfiguration
    ${SgNBModificationRequestAcknowledge_filter}    Catenate    (x2ap.X2AP_PDU == 1) && (x2ap.procedureCode == 29)
    ${SgNBModificationRequestAcknowledge_packets}    cap.filter_packets_by_expression
    ...    filter_expression=${SgNBModificationRequestAcknowledge_filter}
    ${betaOffsetACK_Index1}=    cap.Get Field Value By Xpath    pdml_list=${SgNBModificationRequestAcknowledge_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetACK_Index1
    ${betaOffsetACK_Index2}=    cap.Get Field Value By Xpath    pdml_list=${SgNBModificationRequestAcknowledge_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetACK_Index2
    ${betaOffsetACK_Index3}=    cap.Get Field Value By Xpath    pdml_list=${SgNBModificationRequestAcknowledge_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetACK_Index3
    ${betaOffsetCSI_Part1_Index1}=    cap.Get Field Value By Xpath    pdml_list=${SgNBModificationRequestAcknowledge_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetCSI_Part1_Index1
    ${betaOffsetCSI_Part1_Index2}=    cap.Get Field Value By Xpath    pdml_list=${SgNBModificationRequestAcknowledge_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetCSI_Part1_Index2
#    Should Be Equal    ${betaOffsetACK_Index1}[0]    11
    Should Be Equal    ${betaOffsetACK_Index1}[0]    10
#    Should Be Equal    ${betaOffsetACK_Index2}[0]    8
    Should Be Equal    ${betaOffsetACK_Index2}[0]    11
    Should Be Equal    ${betaOffsetACK_Index3}[0]    6
    Should Be Equal    ${betaOffsetCSI_Part1_Index1}[0]    13
    Should Be Equal    ${betaOffsetCSI_Part1_Index2}[0]    13

check scell not added back NSA on wireshark
    ${cell1_physcellid}=    Get physCellId from SCF 8246    golden_scf_name=${tl_gnb1_scf_${sw_version}}    gnb_index=${0}
    ...    cell_index=${544}    scf_path=${tl_scf_dir_path}
    ${cell2_physcellid}=    Get physCellId from SCF 8246    golden_scf_name=${tl_gnb1_scf_${sw_version}}    gnb_index=${0}
    ...    cell_index=${700}    scf_path=${tl_scf_dir_path}
    # UEContextModificationResponse
    ${UEContextModificationResponse_filter}
    ...    Catenate    ((f1ap.F1AP_PDU == 1) && (f1ap.procedureCode == 7)) && (nr-rrc.physCellId == ${cell1_physcellid})
    ${UEContextModificationResponse_packets}    cap.filter_packets_by_expression    filter_expression=${UEContextModificationResponse_filter}
    ${physCellId}=    cap.Get Field Value By Xpath    pdml_list=${UEContextModificationResponse_packets}
    ...                                                xpath=.//nr-rrc.physCellId
    should contain    ${physCellId}    ${cell1_physcellid}
    should not contain    ${physCellId}    ${cell2_physcellid}

Get physCellId from SCF 8246
    [Arguments]       ${golden_scf_name}    ${gnb_index}=${0}    ${cell_index}=${1}    ${scf_path}=${tl_scf_dir_path}
    scf.Load scf    ${scf_path}/${golden_scf_name}
    ${physcellid}=    scf.get_value_from_scf
    ...    dist_name=MRBTS-${tl.gnbs[${gnb_index}].global_bts_id}/NRBTS-${tl.gnbs[${gnb_index}].instance_id}/NRCELL-${cell_index}
    ...    p_name=physCellId
    [Return]     ${physcellid}

check qci release and scell not added back NSA
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}
    check legacy mcs_table and beatoffset SgNBModificationRequestAcknowledge NSA on wireshark
    ${erab_2}=    get erab value when qci added NSA on wireshark
    set test variable    ${erab_2}
    check scell not added back NSA on wireshark

check sgnbaddition and mcs_table and beatoffset NSA
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}
    check sgnbaddition and mcs_table and beatoffset NSA on wireshark

check sgnbaddition and mcs_table and beatoffset NSA on wireshark
    ${cell1_physcellid}=    Get physCellId from SCF    golden_scf_name=${tl_gnb1_scf_${sw_version}}    gnb_index=${0}
    ...    cell_index=${1}    scf_path=${scf_path}
    ${cell2_physcellid}=    Get physCellId from SCF    golden_scf_name=${tl_gnb1_scf_${sw_version}}    gnb_index=${0}
    ...    cell_index=${2}    scf_path=${scf_path}
    # SgNBAdditionRequestAcknowledge, RRC Reconfiguration
    ${SgNBAdditionRequestAcknowledge_filter}    catenate
    ...    ((x2ap.X2AP_PDU == 1) && (x2ap.procedureCode == 27)) && (nr-rrc.physCellId == ${cell1_physcellid})
    ${SgNBAdditionRequestAcknowledge_packets}    cap.filter_packets_by_expression    filter_expression=${SgNBAdditionRequestAcknowledge_filter}
    ${mcs_Table}=    cap.Get Field Value By Xpath    pdml_list=${SgNBAdditionRequestAcknowledge_packets}
    ...                                                xpath=.//nr-rrc.mcs_Table
    should contain    ${mcs_Table}    1
    ${betaOffsetACK_Index1}=    cap.Get Field Value By Xpath    pdml_list=${SgNBAdditionRequestAcknowledge_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetACK_Index1
    ${betaOffsetACK_Index2}=    cap.Get Field Value By Xpath    pdml_list=${SgNBAdditionRequestAcknowledge_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetACK_Index2
    ${betaOffsetACK_Index3}=    cap.Get Field Value By Xpath    pdml_list=${SgNBAdditionRequestAcknowledge_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetACK_Index3
    ${betaOffsetCSI_Part1_Index1}=    cap.Get Field Value By Xpath    pdml_list=${SgNBAdditionRequestAcknowledge_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetCSI_Part1_Index1
    ${betaOffsetCSI_Part1_Index2}=    cap.Get Field Value By Xpath    pdml_list=${SgNBAdditionRequestAcknowledge_packets}
    ...                                                xpath=.//nr-rrc.betaOffsetCSI_Part1_Index2
    Should Be Equal    ${betaOffsetACK_Index1}[0]    9
    Should Be Equal    ${betaOffsetACK_Index2}[0]    6
    Should Be Equal    ${betaOffsetACK_Index3}[0]    3
    Should Be Equal    ${betaOffsetCSI_Part1_Index1}[0]    11
    Should Be Equal    ${betaOffsetCSI_Part1_Index2}[0]    6

COAM Save snapshot
    get gnb snapshot    gnb_index=${0}

get gnb snapshot
    [Arguments]     ${gnb_index}=${0}
    Connect to gnb coam via ssl    gnb_index=${gnb_index}
    COAM Save snapshot via rest api    log_path=${epc_log_path}
    [Teardown]    COAM Teardown gnb connections

Get RNTI ID message
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    ####InitialULRRCMessageTransfer, RRC Setup Request
    ${RRC_Setup_request}=     Catenate    (f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 11 and f1ap.C_RNTI)
    ${RRC_Setup_request_packets}=    cap.filter_packets_by_expression    filter_expression=${RRC_Setup_request}
    ${UE_RNTI_ID}=     cap.get_field_value_by_xpath    pdml_list=${RRC_Setup_request_packets}
    ...                                                xpath=.//f1ap.C_RNTI
    [Return]    ${UE_RNTI_ID}[0]

check value on TTI file K006_1
    [Arguments]    ${file_path}    ${queried_filed}
    ${required_data_list}=    get_value_from_csv_file_255_exclude    file_path=${file_path}    queried_filed=${queried_filed}
    ${no_duplicates_required_data_list}    Remove Duplicates    ${required_data_list}
    FOR    ${data}    IN    @{no_duplicates_required_data_list}
        should be true    ${data}<=20 or ${data}==32.0
    END

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