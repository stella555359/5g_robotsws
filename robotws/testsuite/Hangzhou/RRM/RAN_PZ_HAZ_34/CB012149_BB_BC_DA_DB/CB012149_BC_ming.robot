*** Settings ***
Documentation
...    author: Shi Ming
...    contact: ming.shi@nokia-sbell.com
...    squal group: SG03
...    feature: CB012149-BC

Force Tags  CA_5G_RRM
...    PY36
Suite Setup    Run Keywords
...            robot_common_operations.Common Suite Setup
...            AND    Common Suite Setup for COAM
...            AND    Get gnb release info
...            AND    Get sagnb version for selenium
...            AND    Set Suite Variable    ${tl_gnb1_scf_${sw_version}}    ${sw_version}_gNB1_Golden_SCF.xml
...            AND    commission scf to BTS

Suite Teardown     Run Keywords
...            recover parameters
...            AND    Common Suite Teardown for COAM    gnb_list=${gnb_list}

Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB012149_BB_BC_DA_DB/Resources/CB0012149_common_keywords.robot

*** Variables ***
${log_name_BC_01_1}    log_name_BC_01_1.pcap
${log_name_BC_01_2}    log_name_BC_01_2.pcap
${log_name_BC_01_3}    log_name_BC_01_3.pcap
${log_name_BC_02_1}    log_name_BC_02_1.pcap
${log_name_BC_02_2}    log_name_BC_02_2.pcap

${expected_tput_dl}    1
${Send_Tput_DL}        1600M
${expected_tput_ul}    1
${Send_Tput_UL}        500M
@{expected_value_D001_gnb1}    ${1}    ${1}    ${7}    ${1}    ${7}
@{Counter_D001}    ${0}
${kpis_templates_id}    1040
${tool_path}    /opt/workspace/Tool
${X70_wap2apn_location}    959 1370
${X70_mdrb2apn_location}    959 1576
${X70_mdrb1apn_location}    959 1802

@{enb_id}    241    38321    358
@{cell_id}    0    1    2    3    4    5    6
@{multi_gnb_PA}    ${0}     ${127}
@{multi_gnb_PA_358}    ${0}
@{multi_gnb_PA_348}    ${15}     ${25}     ${35}     ${55}     ${85}     ${127}    ${0}
@{multi_gnb_PA_383}    ${0}    ${50}

${DL_PORT_K00}    ${tl.ues[0].iperf_details.port}
${UL_PORT_K00}    ${tl.ues[0].iperf_details.ssh_connection_details.port}
${DL_PORT_K01}    ${tl.ues[1].iperf_details.port}
${UL_PORT_K01}    ${tl.ues[1].iperf_details.ssh_connection_details.port}
@{gnb_list}    ${0}

${tl_scf_file_name1}    gNB1_Golden_SCF.xml
${tl_scf_file_name2}    gNB2_Golden_SCF.xml


#gnb1 cell1 p9p10
${5Gcell1_ANT1}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${5Gcell1_ANT2}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}

#${5Gcell1_ANT3}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[2].port_no}
#${5Gcell1_ANT4}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[3].port_no}

${5Gcell2_ANT1}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[0].port_no}
${5Gcell2_ANT2}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[1].port_no}
${5Gcell3_ANT1}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[0].port_no}
${5Gcell3_ANT2}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[1].port_no}
${5Gcell3_ANT3}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[2].port_no}
${5Gcell3_ANT4}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[3].port_no}
${5Gcell4_ANT1}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[0].port_no}    #gnb2 cell1
${5Gcell4_ANT2}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[1].port_no}    #gnb2 cell1
${5Gcell5_ANT1}    ${tl.gnbs[0].dus[0].rus[3].attenuation_ports[0].port_no}    #gnb1 cell4
${5Gcell5_ANT2}    ${tl.gnbs[0].dus[0].rus[3].attenuation_ports[1].port_no}    #gnb1 cell4
${4Gcell1_ANT1}    ${tl.gnbs[1].dus[0].rus[1].attenuation_ports[0].port_no}
${4Gcell1_ANT2}    ${tl.gnbs[1].dus[0].rus[1].attenuation_ports[1].port_no}

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

${ue0_type}                  ${tl.ues[0].capabilities[0]}
${ue1_type}                  ${tl.ues[1].capabilities[1]}
${GNB_INDEX}    ${0}
${nrcellid_pcell}    556978
${nrcellid_scell}    556979
${nrcellid_cell}     ${nrcellid_pcell}     ${nrcellid_scell}
${ue_index}     1
@{nr_rrc_k2_list_24R3}    2    3    2    3    2    2    2    2
@{nr_rrc_k2_list_25R1}    2    2    2    2    2    2    2    2
@{nr_rrc_k2_list}    2    2    2    2    2    2    2    2
@{nr_rrc_k2_list_typeB}    2    3    2    2    2    2    2    2
@{nr_rrc_mappingType_list_24R3}    0    0    0    0    0    0    1    1
@{nr_rrc_mappingType_list_25R1}    0    0    0    0    0    1    1    1
@{nr_rrc_mappingType_list}    0    0    0    0    1    1    1    0
@{nr_rrc_mappingType_list_typeB}    1    1    1    1    1    1    1    1
@{nr_rrc_startSymbolAndLength_list_24R3}    27    27    41    41    55    69    53    67
@{nr_rrc_startSymbolAndLength_list_25R1}    27    41    55    69    83    53    67    81
@{nr_rrc_startSymbolAndLength_list}    27    41    69    83    53    67    81    55
@{nr_rrc_startSymbolAndLength_list_typeB}    27    27    55    69    83    53    67    81
@{GNB_INDEX_list_snapshot}    ${0}

${ue_type_qcom}    ${tl.ues[1].capabilities[0]}

*** Test Cases ***
[1]CB012149-BC_1_001_Voice_over_NR_call_On_FDD_Pcell_with_UL_Tx_Switching_configured_With_Voice_Only
    [Documentation]    CB012149_BC_1_001
    ...    This user scenario validate the successful voice over NR call setup with FDD-TDD FR1 UL carrier aggregation for the single UE,
    ...    and UL Tx Switching is configured. PCell is FDD carrier and single SCell is TDD FR1 carrier
    ...    1. Prerequisite: modify parameters
    ...    2. Attach UE to FDD Pcell,UE have R16 UL Tx switching band combination report
    ...    3. Change FDD PA value to trigger the A1 measurement, TDD Scell addition successful
    ...    4. trigger UDP DL/UL Peak Tput.
    ...    5. Setup Voice call 6688 from UE side
    ...    6. check and compare the DL/UL Peak Tput, End call.
    ...    7. check the wireshark log and BTS log
    ...    8. check Counter
    ...    9. detach ue
    ...    10. teardown
    [Tags]    CB012149_BC_1_001    CRT_TRUNK
    [Setup]
    Run Keyword And Continue On Failure    BC_1_001 Prerequisite
    Run Keyword And Continue On Failure    BC_1_001 Step 1 UE attach on pcell
    Run Keyword And Continue On Failure    BC_1_001 Step 2 UE make traffic
    Run Keyword And Continue On Failure    BC_1_001 Step 3 UE make 6688 voice call
    Run Keyword And Continue On Failure    BC_1_001 Step 4 check DL UL Peak Tput during voice call
    Run Keyword And Continue On Failure    BC_1_001 Step 5 check counters
    Run Keyword And Continue On Failure    BC_1_001 Step 6 UE end voice call
    Run Keyword And Continue On Failure    BC_1_001 Step 7 check DL UL Peak Tput during without voice call
    [Teardown]     BC_1_001 Teardown

[1]CB012149-BC#2_002_R16_UL_Tx_Swithching_single_UE_peak_Tput_interworking_with_P-SRS_in_TDD_Cell_Thor_TypeA
    [Documentation]    CB012149_BC_2_002
    ...    This case validates the R16 UL Tx Switching single UE peak throughput when FDD cell is configured with PUSCH mapping type B
    ...    UE1 with UL_Tx_Swithching CA, UE2 with Non UL CA to compare the Tput impact
    ...    1. Prerequisite: modify parameters
    ...    2. Attach UE1 to FDD Pcell,UE1 have R16 UL Tx switching band combination report
    ...    3. change FDD PA value to trigger the A1 measurement, TDD Scell addition successful
    ...    4. trigger UE1 UDP DL/UL Peak Tput. check DL/UL Peak Tput
    ...    5. Attach UE2 to FDD Pcell without UL Tx switching cabability
    ...    UE2 rank2 to rank1, check src report, RRC reconfiguration.
    ...    6. check and compare the UE1 DL/UL Peak Tput
    ...    7. check the wireshark log and BTS log
    ...    8. check Counter
    ...    9. detach UE1 and UE2
    ...    10. teardown
    [Tags]    CB012149_BC_2_002    CRT_TRUNK
    [Setup]
    Run Keyword And Continue On Failure    BC_2_002 Prerequisite
    Run Keyword And Continue On Failure    BC_2_002 Step 1 UE attach on pcell
    Run Keyword And Continue On Failure    BC_2_002 Step 2 UE make traffic
    Run Keyword And Continue On Failure    BC_2_002 Step 3 check DL UL Peak Tput without UE0
    Run Keyword And Continue On Failure    BC_2_002 Step 4 UE0 attach
    Run Keyword And Continue On Failure    BC_2_002 Step 5 UE0 make traffic
    Run Keyword And Continue On Failure    BC_2_002 Step 6 check DL UL Peak Tput with UE0
    Run Keyword And Continue On Failure    BC_2_002 Step 7 check counters
   [Teardown]     BC_2_002 Teardown

*** Keywords ***
BC_1_001 Prerequisite
    robot_common_operations.Common Case Setup    allowed_faults_ids=2922,2923
    AlarmWatchdog.add_allow_alarms    fault_id=2922
    AlarmWatchdog.add_allow_alarms    fault_id=2923
    Check UE device status with adb recover    ue_index=${1}
    IF    ${enb_instance} == ${enb_id}[0]    #TL348
    ###set gnb1 FDD cell2 PA to 0
        PA one cell 0 on and set other cell value    cellid=${cell_id}[2]    set_value=${multi_gnb_PA_348}[0]    total_cell=${5}
    ELSE IF    ${enb_instance} == ${enb_id}[1]    #TL383
        ###set gnb1 cell1 PA to 0
        PA one cell 0 on and set other cell value 4 port    cellid=${cell_id}[1]    set_value=${multi_gnb_PA}[0]
    END

BC_1_001 Step 1 UE attach on pcell
    comment    step1: UE attach on pcell
    IF    ${enb_instance} == ${enb_id}[0]    #TL348
        CB0012149_common_keywords.Prepare UE For MTK80    ue_index=${1}    cap_index=${0}
        Change Attenuation value    cell=5Gcell${cell_id}[3]    value=${multi_gnb_PA_348}[3]
    ELSE IF    ${enb_instance} == ${enb_id}[1]    #TL383
        power_ue.Prepare UE    ue_type=${ue_type_qcom}    ue_index=${1}
    END
    Start capture gNB log on master    filename=${log_name_BC_01_1}
    IF    ${enb_instance} == ${enb_id}[0]    #TL348
        mtk ue attach on 348    scf_name=${tl_gnb1_scf_${sw_version}}
        Comment    trigger A1 to add scell
        Change Attenuation value    cell=5Gcell${cell_id}[3]    value=${multi_gnb_PA_348}[0]
        Sleep    5s    Reason=wait for Scell add success
    ELSE IF    ${enb_instance} == ${enb_id}[1]    #TL383
        Step1: UE attach    ue_type=${ue_type_qcom}    ue_index=${1}
    END
    [Teardown]    Stop and download Logs on gNB on master    filename=${log_name_BC_01_1}

BC_1_001 Step 2 UE make traffic
    comment    step2: make CA DL/UL Peak Tput
    Run Keyword And Continue On Failure     Check wireshark log for 12149_BC    logname=${log_name_BC_01_1}
    IF    ${enb_instance} == ${enb_id}[0]    #TL348
        Start only DL traffic and check tput    ue_index=${1}    cellid=${2}    ue_type=${ue1_type}    gnb_index=${0}
        ...                                tput_dl_cell=${expected_tput_dl}    dl_throughput=${Send_Tput_DL}    duration=${7200}
        ...                                dl_port=${DL_PORT_K01}
        Start only UL traffic and check tput    ue_index=${1}    cellid=${2}    ue_type=${ue1_type}    gnb_index=${0}
        ...                                tput_ul_cell=${expected_tput_ul}    ul_throughput=${Send_Tput_UL}    duration=${7200}
        ...                                ul_port=${UL_PORT_K01}
    ELSE IF    ${enb_instance} == ${enb_id}[1]     #TL383
        Change Attenuation value 4 port    cell=5Gcells${cell_id}[2]    value=${multi_gnb_PA_383}[0]
        Sleep    5s    Reason=wait for PA change success
        Start only DL traffic and check tput common ue    ue_index=${1}    cellid=${1}    ue_type=${ue_type_qcom}    gnb_index=${0}
        ...                                tput_dl_cell=${expected_tput_dl}    dl_throughput=${Send_Tput_DL}    duration=${7200}
        ...                                dl_port=${DL_PORT}
        Start only UL traffic and check tput common ue    ue_index=${1}    cellid=${1}    ue_type=${ue_type_qcom}    gnb_index=${0}
        ...                                tput_ul_cell=${expected_tput_ul}    ul_throughput=${Send_Tput_UL}    duration=${7200}
        ...                                ul_port=${UL_PORT}
    END

BC_1_001 Step 3 UE make 6688 voice call
    comment    Step 3 UE0 make 6688 voice call
    Start capture gNB log on master    filename=${log_name_BC_01_2}
    IF    ${enb_instance} == ${enb_id}[0]    #TL348
        Make a VoNR call(+6688) on mtk80    ue_index=${1}
        sleep    20s
        check voice call status    status=${2}    ue_index=${1}
    ELSE IF    ${enb_instance} == ${enb_id}[1]     #TL383
        Make a VoNR call(+6688) on SDX70    ue_index=${1}
        sleep    20s
        check voice call status    status=${2}    ue_index=${1}
    END
    [Teardown]     Stop and download Logs on gNB on master    filename=${log_name_BC_01_2}

BC_1_001 Step 4 check DL UL Peak Tput during voice call
    IF    ${enb_instance} == ${enb_id}[0]    #TL348
        ${dl_expected_throughput_pcell}    ${ul_expected_throughput_pcell}=    get_expect_throughput
        ...    tl_scf_dir_path=${tl_scf_dir_path}    tl_scf_file_name=${tl_gnb1_scf_${sw_version}}    cell_id=${2}
        ${dl_expected_throughput_scell}    ${ul_expected_throughput_scell}=    get_expect_throughput
        ...    tl_scf_dir_path=${tl_scf_dir_path}    tl_scf_file_name=${tl_gnb1_scf_${sw_version}}    cell_id=${3}
        check intra gnb ca throughput    scellid=${3}    pcellid=${2}    gnb_prime=${0}    gnb_external=${0}
        ...    tput_dl_pcell=${dl_expected_throughput_pcell}    tput_dl_scell=${dl_expected_throughput_scell}
        ...    tput_ul_pcell=${ul_expected_throughput_pcell}    tput_ul_scell=${ul_expected_throughput_scell}
        ...    time=300s    ue_type=${ue1_type}    ue_index=${1}
    ELSE IF    ${enb_instance} == ${enb_id}[1]    #TL383
        ${dl_expected_throughput_pcell}    ${ul_expected_throughput_pcell}=    get_expect_throughput
        ...    tl_scf_dir_path=${tl_scf_dir_path}    tl_scf_file_name=${tl_gnb1_scf_${sw_version}}    cell_id=${1}
        ${dl_expected_throughput_scell}    ${ul_expected_throughput_scell}=    get_expect_throughput
        ...    tl_scf_dir_path=${tl_scf_dir_path}    tl_scf_file_name=${tl_gnb1_scf_${sw_version}}    cell_id=${2}
        check intra gnb ca throughput    scellid=${2}    pcellid=${1}    gnb_prime=${0}    gnb_external=${0}
        ...    tput_dl_pcell=${dl_expected_throughput_pcell}    tput_dl_scell=${dl_expected_throughput_scell}
        ...    tput_ul_pcell=${ul_expected_throughput_pcell}    tput_ul_scell=${ul_expected_throughput_scell}
        ...    time=300s    ue_type=${ue_type_qcom}    ue_index=${1}
    END

BC_1_001 Step 5 check counters
    comment    step5: check counters
    Prepare with PM counter time to caculate    period=end
    sleep    1min    reason=check KPIs xml report generated 1min
    Run Keyword And Continue On Failure     check counters for scell active success on pcell and scell

BC_1_001 Step 6 UE end voice call
    hang up VoNR call    ue_index=${1}
    sleep  20s
    check voice call status    status=${0}    ue_index=${1}

BC_1_001 Step 7 check DL UL Peak Tput during without voice call
    IF    ${enb_instance} == ${enb_id}[0]    #TL348
        ${dl_expected_throughput_pcell}    ${ul_expected_throughput_pcell}=    get_expect_throughput
        ...    tl_scf_dir_path=${tl_scf_dir_path}    tl_scf_file_name=${tl_gnb1_scf_${sw_version}}    cell_id=${2}
        ${dl_expected_throughput_scell}    ${ul_expected_throughput_scell}=    get_expect_throughput
        ...    tl_scf_dir_path=${tl_scf_dir_path}    tl_scf_file_name=${tl_gnb1_scf_${sw_version}}    cell_id=${3}
        check intra gnb ca throughput    scellid=${3}    pcellid=${2}    gnb_prime=${0}    gnb_external=${0}
        ...    tput_dl_pcell=${dl_expected_throughput_pcell}    tput_dl_scell=${dl_expected_throughput_scell}
        ...    tput_ul_pcell=${ul_expected_throughput_pcell}    tput_ul_scell=${ul_expected_throughput_scell}
        ...    time=300s    ue_type=${ue1_type}    ue_index=${1}
    ELSE IF    ${enb_instance} == ${enb_id}[1]    #TL383
        ${dl_expected_throughput_pcell}    ${ul_expected_throughput_pcell}=    get_expect_throughput
        ...    tl_scf_dir_path=${tl_scf_dir_path}    tl_scf_file_name=${tl_gnb1_scf_${sw_version}}    cell_id=${1}
        ${dl_expected_throughput_scell}    ${ul_expected_throughput_scell}=    get_expect_throughput
        ...    tl_scf_dir_path=${tl_scf_dir_path}    tl_scf_file_name=${tl_gnb1_scf_${sw_version}}    cell_id=${2}
        check intra gnb ca throughput    scellid=${2}    pcellid=${1}    gnb_prime=${0}    gnb_external=${0}
        ...    tput_dl_pcell=${dl_expected_throughput_pcell}    tput_dl_scell=${dl_expected_throughput_scell}
        ...    tput_ul_pcell=${ul_expected_throughput_pcell}    tput_ul_scell=${ul_expected_throughput_scell}
        ...    time=300s    ue_type=${ue_type_qcom}    ue_index=${1}
    END

BC_1_001 Teardown
    robot_common_operations.Common Case Teardown
    AlarmWatchdog.remove_allow_alarms    fault_id=2922
    AlarmWatchdog.remove_allow_alarms    fault_id=2923
    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run Keyword And Continue On Failure     get gnb snapshot
    hang up VoNR call    ue_index=${1}
    sleep  20s
    check voice call status    status=${0}    ue_index=${1}
    IF    ${enb_instance} == ${enb_id}[0]    #TL348
        Stop DL or UL traffic    ue_index=${1}    ue_type=${ue1_type}    direction=DL
        Stop DL or UL traffic    ue_index=${1}    ue_type=${ue1_type}    direction=UL
        CB0012149_common_keywords.Do UE Detach    ue_index=${1}
        Change Attenuation value    cell=5Gcell${cell_id}[2]    value=${multi_gnb_PA}[1]
        Change Attenuation value    cell=5Gcell${cell_id}[3]    value=${multi_gnb_PA}[1]
    ELSE IF    ${enb_instance} == ${enb_id}[1]    #TL383
        Stop DL or UL traffic common ue    ue_index=${1}    ue_type=${ue_type_qcom}    direction=DL
        Stop DL or UL traffic common ue    ue_index=${1}    ue_type=${ue_type_qcom}    direction=UL
        Step4: Detach UE    ue_type=${ue_type_qcom}    ue_index=${1}
        Change Attenuation value 4 port    cell=5Gcells${cell_id}[1]    value=${multi_gnb_PA}[1]
        Change Attenuation value 4 port    cell=5Gcells${cell_id}[2]    value=${multi_gnb_PA}[1]
    END
    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
    Run Keyword And Continue On Failure     Tear down the all connections





BC_2_002 Prerequisite
    BC_1_001 Prerequisite

BC_2_002 Step 1 UE attach on pcell
    BC_1_001 Step 1 UE attach on pcell

BC_2_002 Step 2 UE make traffic
    BC_1_001 Step 2 UE make traffic

BC_2_002 Step 3 check DL UL Peak Tput without UE0
    [Arguments]    ${ue_index}=${1}
    IF    ${enb_instance} == ${enb_id}[0]     #TL348
        ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
        ${nrcellid_cell}    Create list  ${nrcellid_pcell}    ${nrcellid_scell}
        Check single direction throughput     ue_index=${ue_index}    ue_type=${ue_type}    direction=DL   list_of_cell_ids=${nrcellid_cell}
        ...    expect_throughput=${expected_tput_dl}    gnb_index=${gnb_index}
        Check single direction throughput     ue_index=${ue_index}    ue_type=${ue_type}    direction=UL   list_of_cell_ids=${nrcellid_cell}
        ...    expect_throughput=${expected_tput_ul}    gnb_index=${gnb_index}
    ELSE IF    ${enb_instance} == ${enb_id}[1]     #TL383
        ${dl_expected_throughput_pcell}    ${ul_expected_throughput_pcell}=    get_expect_throughput
        ...    tl_scf_dir_path=${tl_scf_dir_path}    tl_scf_file_name=${tl_gnb1_scf_${sw_version}}    cell_id=${1}
        ${dl_expected_throughput_scell}    ${ul_expected_throughput_scell}=    get_expect_throughput
        ...    tl_scf_dir_path=${tl_scf_dir_path}    tl_scf_file_name=${tl_gnb1_scf_${sw_version}}    cell_id=${2}
        check intra gnb ca throughput    scellid=${2}    pcellid=${1}    gnb_prime=${0}    gnb_external=${0}
        ...    tput_dl_pcell=${dl_expected_throughput_pcell}    tput_dl_scell=${dl_expected_throughput_scell}
        ...    tput_ul_pcell=${ul_expected_throughput_pcell}    tput_ul_scell=${ul_expected_throughput_scell}
        ...    time=300s    ue_type=${ue_type_qcom}    ue_index=${1}
    END

BC_2_002 Step 4 UE0 attach
    power_ue.Prepare UE    ue_type=${ue0_type}    ue_index=${0}
    IF    ${enb_instance} == ${enb_id}[0]     #TL348
        Set Suite Variable     ${iperf_button}     911 372
        Change Attenuation value    cell=5Gcell${cell_id}[2]    value=${multi_gnb_PA_348}[6]
    ELSE IF    ${enb_instance} == ${enb_id}[1]     #TL383
        Set Suite Variable    ${iperf_button}    690 365
    END
    Wait Until Keyword Succeeds    3x    10s    Run Keywords
    ...    set apn dxdata2
    ...    AND    make WA with Samsung S21
    Start capture gNB log on master    filename=${log_name_BC_02_1}
    Attach and check power UE    ue_type=${ue0_type}    ue_index=${0}    gnb_index=${0}
    [Teardown]    Stop and download Logs on gNB on master    filename=${log_name_BC_02_1}

BC_2_002 Step 5 UE0 make traffic
    ${ue0_dl_port}=    Evaluate    ${DL_PORT}+100
    ${ue0_ul_port}=    Evaluate    ${UL_PORT}+100
    IF    ${enb_instance} == ${enb_id}[0]     #TL348
        Start only DL traffic and check tput common ue    ue_index=${0}    cellid=${2}    ue_type=${ue0_type}    gnb_index=${0}
        ...                                tput_dl_cell=${expected_tput_dl}    dl_throughput=${Send_Tput_DL}    duration=${7200}
        ...                                dl_port=${ue0_dl_port}
        Start only UL traffic and check tput common ue    ue_index=${0}    cellid=${2}    ue_type=${ue0_type}    gnb_index=${0}
        ...                                tput_ul_cell=${expected_tput_ul}    ul_throughput=${Send_Tput_UL}    duration=${7200}
        ...                                ul_port=${ue0_ul_port}
    ELSE IF    ${enb_instance} == ${enb_id}[1]     #TL383
        Start only DL traffic and check tput common ue    ue_index=${0}    cellid=${1}    ue_type=${ue0_type}    gnb_index=${0}
        ...                                tput_dl_cell=${expected_tput_dl}    dl_throughput=${Send_Tput_DL}    duration=${7200}
        ...                                dl_port=${ue0_dl_port}
        Start only UL traffic and check tput common ue    ue_index=${0}    cellid=${1}    ue_type=${ue0_type}    gnb_index=${0}
        ...                                tput_ul_cell=${expected_tput_ul}    ul_throughput=${Send_Tput_UL}    duration=${7200}
        ...                                ul_port=${ue0_ul_port}
    END

BC_2_002 Step 6 check DL UL Peak Tput with UE0
    IF    ${enb_instance} == ${enb_id}[0]    #TL348
        Change Attenuation value    cell=5Gcell${cell_id}[2]    value=${multi_gnb_PA_348}[0]
        ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
        ${nrcellid_cell}    Create list  ${nrcellid_pcell}    ${nrcellid_scell}
        Check single direction throughput     ue_index=${ue_index}    ue_type=${ue_type}    direction=DL   list_of_cell_ids=${nrcellid_cell}
        ...    expect_throughput=${expected_tput_dl}    gnb_index=${gnb_index}
        Check single direction throughput     ue_index=${ue_index}    ue_type=${ue_type}    direction=UL   list_of_cell_ids=${nrcellid_cell}
        ...    expect_throughput=${expected_tput_ul}    gnb_index=${gnb_index}
    ELSE IF    ${enb_instance} == ${enb_id}[1]    #TL383
        ${dl_expected_throughput_pcell}    ${ul_expected_throughput_pcell}=    get_expect_throughput
        ...    tl_scf_dir_path=${tl_scf_dir_path}    tl_scf_file_name=${tl_gnb1_scf_${sw_version}}    cell_id=${1}
        ${dl_expected_throughput_scell}    ${ul_expected_throughput_scell}=    get_expect_throughput
        ...    tl_scf_dir_path=${tl_scf_dir_path}    tl_scf_file_name=${tl_gnb1_scf_${sw_version}}    cell_id=${2}
        check intra gnb ca throughput    scellid=${2}    pcellid=${1}    gnb_prime=${0}    gnb_external=${0}
        ...    tput_dl_pcell=${dl_expected_throughput_pcell}    tput_dl_scell=${dl_expected_throughput_scell}
        ...    tput_ul_pcell=${ul_expected_throughput_pcell}    tput_ul_scell=${ul_expected_throughput_scell}
        ...    time=300s    ue_type=${ue_type_qcom}    ue_index=${1}
    END

BC_2_002 Step 7 check counters
    comment    step5: check counters
    Prepare with PM counter time to caculate    period=end
    sleep    1min    reason=check KPIs xml report generated 1min
    Run Keyword And Continue On Failure     check counters for scell active success on pcell and scell

BC_2_002 Teardown
    robot_common_operations.Common Case Teardown
    AlarmWatchdog.remove_allow_alarms    fault_id=2922
    AlarmWatchdog.remove_allow_alarms    fault_id=2923
    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run Keyword And Continue On Failure     get gnb snapshot
    Stop DL or UL traffic    ue_index=${1}    ue_type=${ue1_type}    direction=DL
    Stop DL or UL traffic    ue_index=${1}    ue_type=${ue1_type}    direction=UL
    CB0012149_common_keywords.Do UE Detach    ue_index=${1}
    Stop DL or UL traffic common ue    ue_index=${0}    ue_type=${ue0_type}    direction=DL
    Stop DL or UL traffic common ue    ue_index=${0}    ue_type=${ue0_type}    direction=UL
    make WA with Samsung S21
    QCM UE Recover Detach    ue_index=${0}    ue_type=${ue0_type}
    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
    Run Keyword And Continue On Failure     Tear down the all connections




commission scf to BTS
    IF    ${enb_instance} == ${enb_id}[0]    #TL348
        Common Case TestLine Setup    ModifySCF_Beforecommission=True
        ...    ParamterToModify=${PARAM_12149_gnb1_BC_1_001_new}    ListToAdd=${ListToAdd_12149_gnb1_BC_01}
        ...    ListParamterToModify=${ListToModify_12149_gnb1_BC_01}    ParameterToDelete=${ParameterToDelete_12149_gnb1_BC_01}
        ...    scf_path=${tl_scf_dir_path}    golden_scf_name=${tl_gnb1_scf_${sw_version}}    is_pdl_checking_needed=${True}
    ELSE IF    ${enb_instance} == ${enb_id}[1]     #TL383
        Setup for Env cell on-air for 2 gnb    is_commission_for_second_gnb=False
        ...                                   tl_scf_file_name=${tl_gnb1_scf_${sw_version}}
        Online modify parmeters     parameters_to_update=${PARAM_12149_gnb1_BC_1_001_383}    skip_parameter_relation_errors=False
        COAM Wait for gnb ready and cell setup
        Online modify parmeters     parameters_to_update=${PARAM_12149_lte_common_383_WA}    skip_parameter_relation_errors=False
    END

recover parameters
    IF    ${enb_instance} == ${enb_id}[0]    #TL348
        Setup for Env cell on-air for 2 gnb    is_commission_for_second_gnb=False
        ...                                   tl_scf_file_name=${tl_gnb1_scf_${sw_version}}
    ELSE IF    ${enb_instance} == ${enb_id}[1]     #TL383
        Online delete parmeters    parameters_to_update=${PARAM_12149_delete_gnb1_BC_1_001_383}    timeout=${300}
        Online modify parmeters    parameters_to_update=${PARAM_12149_recover_gnb1_BC_1_001_383}    skip_parameter_relation_errors=False
        COAM Wait for gnb ready and cell setup
        Online modify parmeters    parameters_to_update=${PARAM_12149_recover_lte_common_383_WA}    skip_parameter_relation_errors=False
        COAM Wait for gnb ready and cell setup
    END

Check wireshark log for 12149_BC
    [Arguments]     ${logname}    ${puschMappingType}=TypeA
    Comment    check wireshark log for 12149_BC
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}
    IF    ${enb_instance} == ${enb_id}[0]    #TL348
        Run Keyword And Continue On Failure     check CB012149 UERadioCapabilityInfoIndication on wireshark
        ##Run Keyword And Continue On Failure     check UL switchedUl scell additon successful on wireshark
    ELSE IF    ${enb_instance} == ${enb_id}[1]     #TL383
        check CB012149 UERadioCapabilityInfoIndication on wireshark
        IF    '${release_info}' == 'SBTS24R3_ENB_0000'
            check UL switchedUl scell additon successful on wireshark on 24R3    puschMappingType=${puschMappingType}
        ELSE IF    '${release_info}' == 'SBTS25R1_ENB_0000'
            check UL switchedUl scell additon successful on wireshark on 25R1    puschMappingType=${puschMappingType}
        ELSE
            check UL switchedUl scell additon successful on wireshark    puschMappingType=${puschMappingType}
        END
    END
    ${c_rnti}=    Get RNTI-ID message    logname=${logname}
    Set Test Variable    ${c_rnti}

check CB012149 UERadioCapabilityInfoIndication on wireshark
    # check NGAP：UERadioCapabilityInfoIndication
    # supportedBandCombinationList-UplinkTxSwitch-r16: 1 item contain N1+N78
    # nr-rrc.supportedBandCombinationList_UplinkTxSwitch_r16
    ${UERadioCapabilityInfoIndication_filter}    Catenate    (ngap.NGAP_PDU == 0) && (ngap.procedureCode == 44)
    ${UERadioCapabilityInfoIndication_packets}    cap.filter_packets_by_expression
    ...    filter_expression=${UERadioCapabilityInfoIndication_filter}
    ${supportedBandCombinationList_1}=    cap.Get Field Value By Xpath    pdml_list=${UERadioCapabilityInfoIndication_packets}
    ...                                                xpath=.//nr-rrc.BandCombination_UplinkTxSwitch_r16_element//nr-rrc.bandNR
    ${supportedBandCombinationList_2}=    cap.Get Field Value By Xpath    pdml_list=${UERadioCapabilityInfoIndication_packets}
    ...                                                xpath=.//nr-rrc.BandCombination_UplinkTxSwitch_r16_element//nr-rrc.ca_BandwidthClassDL_NR
    ${supportedBandCombinationList_3}=    cap.Get Field Value By Xpath    pdml_list=${UERadioCapabilityInfoIndication_packets}
    ...                                                xpath=.//nr-rrc.BandCombination_UplinkTxSwitch_r16_element//nr-rrc.ca_BandwidthClassUL_NR
#    IF    ${enb_instance} == ${enb_id}[0]     #TL348
#        Should Contain    ${supportedBandCombinationList_1}    1
#        Should Contain    ${supportedBandCombinationList_1}    78
#        ${length}=    Get Length    ${supportedBandCombinationList_1}
#        Should Be Equal As Integers    ${length}    4
#        Should Be Equal    ${supportedBandCombinationList_2}[0]    0
#        Should Be Equal    ${supportedBandCombinationList_2}[1]    1
#        Should Be Equal    ${supportedBandCombinationList_2}[2]    0
#        Should Be Equal    ${supportedBandCombinationList_2}[3]    2
#        ${length}=    Get Length    ${supportedBandCombinationList_2}
#        Should Be Equal As Integers    ${length}    4
#        Should Be Equal    ${supportedBandCombinationList_3}[0]    0
#        Should Be Equal    ${supportedBandCombinationList_3}[1]    0
#        Should Be Equal    ${supportedBandCombinationList_3}[2]    0
#        Should Be Equal    ${supportedBandCombinationList_3}[3]    0
#        ${length}=    Get Length    ${supportedBandCombinationList_3}
#        Should Be Equal As Integers    ${length}    4
#    ELSE IF    ${enb_instance} == ${enb_id}[1]     #TL383
#        Should Contain    ${supportedBandCombinationList_1}    71
#        Should Contain    ${supportedBandCombinationList_1}    41
#        ${length}=    Get Length    ${supportedBandCombinationList_1}
#        Should Be Equal As Integers    ${length}    5
#        Should Be Equal    ${supportedBandCombinationList_2}[0]    2
#        Should Be Equal    ${supportedBandCombinationList_2}[1]    0
#        Should Be Equal    ${supportedBandCombinationList_2}[2]    0
#        Should Be Equal    ${supportedBandCombinationList_2}[3]    0
#        Should Be Equal    ${supportedBandCombinationList_2}[4]    0
#        ${length}=    Get Length    ${supportedBandCombinationList_2}
#        Should Be Equal As Integers    ${length}    5
#        Should Be Equal    ${supportedBandCombinationList_3}[0]    0
#        Should Be Equal    ${supportedBandCombinationList_3}[1]    0
#        Should Be Equal    ${supportedBandCombinationList_3}[2]    0
#        Should Be Equal    ${supportedBandCombinationList_3}[3]    0
#        ${length}=    Get Length    ${supportedBandCombinationList_3}
#        Should Be Equal As Integers    ${length}    4
#    END
    ${uplinkTxSwitching_OptionSupport_r16}=    cap.Get Field Value By Xpath    pdml_list=${UERadioCapabilityInfoIndication_packets}
    ...    xpath=.//nr-rrc.uplinkTxSwitching_OptionSupport_r16
    Should Be Equal    ${uplinkTxSwitching_OptionSupport_r16}[0]    0

check UL switchedUl scell additon successful on wireshark
    [Arguments]    ${puschMappingType}=TypeA
    IF    ${enb_instance} == ${enb_id}[0]     #TL348
        ${physCellId}=    get required value of parameter    Abbreviation=physCellId    gnb_index=${0}    distname_id=${3}
    ELSE IF    ${enb_instance} == ${enb_id}[1]     #TL383
        ${physCellId}=    get required value of parameter    Abbreviation=physCellId    gnb_index=${0}    distname_id=${2}
    END
    # RRC Reconfiguration
    ${RRC_Reconfiguration_filter}    Catenate
    ...    (((f1ap.F1AP_PDU == 0) && (f1ap.procedureCode == 12)) && (nr-rrc.startSymbolAndLength == 55)) && (nr-rrc.physCellId == ${physCellId})
    ${RRC_Reconfiguration_packets}    cap.filter_packets_by_expression    filter_expression=${RRC_Reconfiguration_filter}
    ${nr_rrc_k2}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.pusch_TimeDomainAllocationList//nr-rrc.PUSCH_TimeDomainResourceAllocation_element//nr-rrc.k2
    Run Keyword If    '${puschMappingType}' == 'TypeA'
    ...    Should Be Equal    ${nr_rrc_k2_list}    ${nr_rrc_k2}[0:8]
    ...    ELSE IF    '${puschMappingType}' == 'TypeB'
    ...    Should Be Equal    ${nr_rrc_k2_list_typeB}    ${nr_rrc_k2}[0:8]
    ${nr_rrc_mappingType}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.pusch_TimeDomainAllocationList//nr-rrc.PUSCH_TimeDomainResourceAllocation_element//nr-rrc.mappingType
    Run Keyword If    '${puschMappingType}' == 'TypeA'
    ...    Should Be Equal    ${nr_rrc_mappingType_list}    ${nr_rrc_mappingType}[0:8]
    ...    ELSE IF    '${puschMappingType}' == 'TypeB'
    ...    Should Be Equal    ${nr_rrc_mappingType_list_typeB}    ${nr_rrc_mappingType}[0:8]
    ${nr_rrc_startSymbolAndLength}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.pusch_TimeDomainAllocationList//nr-rrc.PUSCH_TimeDomainResourceAllocation_element//nr-rrc.startSymbolAndLength
    Run Keyword If    '${puschMappingType}' == 'TypeA'
    ...    Should Be Equal    ${nr_rrc_startSymbolAndLength_list}    ${nr_rrc_startSymbolAndLength}[0:8]
    ...    ELSE IF    '${puschMappingType}' == 'TypeB'
    ...    Should Be Equal    ${nr_rrc_startSymbolAndLength_list_typeB}    ${nr_rrc_startSymbolAndLength}[0:8]
    ${nr_rrc_uplinkTxSwitchingOption_r16}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.uplinkTxSwitchingOption_r16
    Should Be Equal    ${nr_rrc_uplinkTxSwitchingOption_r16}[0]    0
    ${nr_rrc_uplinkTxSwitchingPowerBoosting-r16}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.uplinkTxSwitchingPowerBoosting-r16
    Should Be Empty    ${nr_rrc_uplinkTxSwitchingPowerBoosting-r16}
    ###FOR TDD SCELL###
    ${nr_rrc_maxRank}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.sCellToAddModList//nr-rrc.maxRank
    Should Be Equal    ${nr_rrc_maxRank}[0]    2
    ${nr_rrc_srs_ResourceId}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.sCellToAddModList//nr-rrc.srs_ResourceId
    Should Be Equal    ${nr_rrc_srs_ResourceId}[0]    0
    ${nr_rrc_nrofSRS_Ports}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.sCellToAddModList//nr-rrc.nrofSRS_Ports
    Should Be Equal    ${nr_rrc_nrofSRS_Ports}[0]    1
    ${nr_rrc_uplinkTxSwitchingPeriodLocation_r16}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.sCellToAddModList//nr-rrc.uplinkTxSwitching_r16//nr-rrc.uplinkTxSwitchingPeriodLocation_r16
#    Should Be Equal    ${nr_rrc_uplinkTxSwitchingPeriodLocation_r16}[0]    0
    Should Be Equal    ${nr_rrc_uplinkTxSwitchingPeriodLocation_r16}[0]    False
    ${nr_rrc_uplinkTxSwitchingCarrier_r16}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.sCellToAddModList//nr-rrc.uplinkTxSwitching_r16//nr-rrc.uplinkTxSwitchingCarrier_r16
    Should Be Equal    ${nr_rrc_uplinkTxSwitchingCarrier_r16}[0]    1
    ###FOR FDD PCELL###
    ${nr_rrc_maxRank}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.spCellConfig_element//nr-rrc.maxRank
    Should Be Equal    ${nr_rrc_maxRank}[0]    1
    ${nr_rrc_tp_pi2BPSK}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.spCellConfig_element//nr-rrc.tp_pi2BPSK
    Should Be Equal    ${nr_rrc_tp_pi2BPSK}[0]    0
    ${nr_rrc_uplinkTxSwitchingPeriodLocation_r16}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.spCellConfig_element//nr-rrc.uplinkTxSwitching_r16//nr-rrc.uplinkTxSwitchingPeriodLocation_r16
#    Should Be Equal    ${nr_rrc_uplinkTxSwitchingPeriodLocation_r16}[0]    1
    Should Be Equal    ${nr_rrc_uplinkTxSwitchingPeriodLocation_r16}[0]    True
    ${nr_rrc_uplinkTxSwitchingCarrier_r16}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.spCellConfig_element//nr-rrc.uplinkTxSwitching_r16//nr-rrc.uplinkTxSwitchingCarrier_r16
    Should Be Equal    ${nr_rrc_uplinkTxSwitchingCarrier_r16}[0]    0
    ${nr_rrc_pucch_ResourceId}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.spCellConfig_element//nr-rrc.bwp_Dedicated_element//nr-rrc.resourceToAddModList//nr-rrc.pucch_ResourceId
    ${nr_rrc_startingSymbolIndex}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.spCellConfig_element//nr-rrc.bwp_Dedicated_element//nr-rrc.resourceToAddModList//nr-rrc.startingSymbolIndex
    ${nr_rrc_nrofSymbols}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.spCellConfig_element//nr-rrc.bwp_Dedicated_element//nr-rrc.resourceToAddModList//nr-rrc.nrofSymbols
    ${nr_rrc_startingSymbolIndex_list}    Create List
    ${nr_rrc_nrofSymbols_list}    Create List
    FOR    ${index}    ${item}    IN ENUMERATE    @{nr_rrc_pucch_ResourceId}
        RUN KEYWORD IF    0<=${item}<=5    Run Keywords
        ...    Append To List    ${nr_rrc_startingSymbolIndex_list}    4
        ...    AND    Append To List    ${nr_rrc_nrofSymbols_list}    7
        ...    ELSE IF    6<=${item}<=7    Run Keywords
        ...    Append To List    ${nr_rrc_startingSymbolIndex_list}    0
        ...    AND    Append To List    ${nr_rrc_nrofSymbols_list}    14
        ...    ELSE IF    10<=${item}<=11    Run Keywords
        ...    Append To List    ${nr_rrc_startingSymbolIndex_list}    3
        ...    AND    Append To List    ${nr_rrc_nrofSymbols_list}    8
        ...    ELSE IF    ${item}==8    Run Keywords
        ...    Append To List    ${nr_rrc_startingSymbolIndex_list}    4
        ...    AND    Append To List    ${nr_rrc_nrofSymbols_list}    7
        ...    ELSE IF    (${item}==9 or 18<=${item}<=28) and ${nr_rrc_nrofSymbols}[${index}]==8    Run Keywords
        ...    Append To List    ${nr_rrc_startingSymbolIndex_list}    3
        ...    AND    Append To List    ${nr_rrc_nrofSymbols_list}    8
        ...    ELSE IF    (${item}==9 or 18<=${item}<=28) and ${nr_rrc_nrofSymbols}[${index}]==14    Run Keywords
        ...    Append To List    ${nr_rrc_startingSymbolIndex_list}    0
        ...    AND    Append To List    ${nr_rrc_nrofSymbols_list}    14
    END
    Should Be Equal    ${nr_rrc_startingSymbolIndex_list}    ${nr_rrc_startingSymbolIndex}
    Should Be Equal    ${nr_rrc_nrofSymbols_list}    ${nr_rrc_nrofSymbols}

check UL switchedUl scell additon successful on wireshark on 25R1
    [Arguments]    ${puschMappingType}=TypeA
    IF    ${enb_instance} == ${enb_id}[0]     #TL348
        ${physCellId}=    get required value of parameter    Abbreviation=physCellId    gnb_index=${0}    distname_id=${3}
    ELSE IF    ${enb_instance} == ${enb_id}[1]     #TL383
        ${physCellId}=    get required value of parameter    Abbreviation=physCellId    gnb_index=${0}    distname_id=${2}
    END
    # RRC Reconfiguration
    ${RRC_Reconfiguration_filter}    Catenate
    ...    (((f1ap.F1AP_PDU == 0) && (f1ap.procedureCode == 12)) && (nr-rrc.startSymbolAndLength == 55)) && (nr-rrc.physCellId == ${physCellId})
    ${RRC_Reconfiguration_packets}    cap.filter_packets_by_expression    filter_expression=${RRC_Reconfiguration_filter}
    ${nr_rrc_k2}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.pusch_TimeDomainAllocationList//nr-rrc.PUSCH_TimeDomainResourceAllocation_element//nr-rrc.k2
    Run Keyword If    '${puschMappingType}' == 'TypeA'
    ...    Should Be Equal    ${nr_rrc_k2_list_25R1}    ${nr_rrc_k2}[0:8]
    ...    ELSE IF    '${puschMappingType}' == 'TypeB'
    ...    Should Be Equal    ${nr_rrc_k2_list_typeB}    ${nr_rrc_k2}[0:8]
    ${nr_rrc_mappingType}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.pusch_TimeDomainAllocationList//nr-rrc.PUSCH_TimeDomainResourceAllocation_element//nr-rrc.mappingType
    Run Keyword If    '${puschMappingType}' == 'TypeA'
    ...    Should Be Equal    ${nr_rrc_mappingType_list_25R1}    ${nr_rrc_mappingType}[0:8]
    ...    ELSE IF    '${puschMappingType}' == 'TypeB'
    ...    Should Be Equal    ${nr_rrc_mappingType_list_typeB}    ${nr_rrc_mappingType}[0:8]
    ${nr_rrc_startSymbolAndLength}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.pusch_TimeDomainAllocationList//nr-rrc.PUSCH_TimeDomainResourceAllocation_element//nr-rrc.startSymbolAndLength
    Run Keyword If    '${puschMappingType}' == 'TypeA'
    ...    Should Be Equal    ${nr_rrc_startSymbolAndLength_list_25R1}    ${nr_rrc_startSymbolAndLength}[0:8]
    ...    ELSE IF    '${puschMappingType}' == 'TypeB'
    ...    Should Be Equal    ${nr_rrc_startSymbolAndLength_list_typeB}    ${nr_rrc_startSymbolAndLength}[0:8]
    ${nr_rrc_uplinkTxSwitchingOption_r16}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.uplinkTxSwitchingOption_r16
    Should Be Equal    ${nr_rrc_uplinkTxSwitchingOption_r16}[0]    0
    ${nr_rrc_uplinkTxSwitchingPowerBoosting-r16}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.uplinkTxSwitchingPowerBoosting-r16
    Should Be Empty    ${nr_rrc_uplinkTxSwitchingPowerBoosting-r16}
    ###FOR TDD SCELL###
    ${nr_rrc_maxRank}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.sCellToAddModList//nr-rrc.maxRank
    Should Be Equal    ${nr_rrc_maxRank}[0]    2
    ${nr_rrc_srs_ResourceId}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.sCellToAddModList//nr-rrc.srs_ResourceId
    Should Be Equal    ${nr_rrc_srs_ResourceId}[0]    0
    ${nr_rrc_nrofSRS_Ports}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.sCellToAddModList//nr-rrc.nrofSRS_Ports
    Should Be Equal    ${nr_rrc_nrofSRS_Ports}[0]    1
    ${nr_rrc_uplinkTxSwitchingPeriodLocation_r16}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.sCellToAddModList//nr-rrc.uplinkTxSwitching_r16//nr-rrc.uplinkTxSwitchingPeriodLocation_r16
#    Should Be Equal    ${nr_rrc_uplinkTxSwitchingPeriodLocation_r16}[0]    0
    Should Be Equal    ${nr_rrc_uplinkTxSwitchingPeriodLocation_r16}[0]    False
    ${nr_rrc_uplinkTxSwitchingCarrier_r16}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.sCellToAddModList//nr-rrc.uplinkTxSwitching_r16//nr-rrc.uplinkTxSwitchingCarrier_r16
    Should Be Equal    ${nr_rrc_uplinkTxSwitchingCarrier_r16}[0]    1
    ###FOR FDD PCELL###
    ${nr_rrc_maxRank}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.spCellConfig_element//nr-rrc.maxRank
    Should Be Equal    ${nr_rrc_maxRank}[0]    1
    ${nr_rrc_tp_pi2BPSK}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.spCellConfig_element//nr-rrc.tp_pi2BPSK
    Should Be Equal    ${nr_rrc_tp_pi2BPSK}[0]    0
    ${nr_rrc_uplinkTxSwitchingPeriodLocation_r16}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.spCellConfig_element//nr-rrc.uplinkTxSwitching_r16//nr-rrc.uplinkTxSwitchingPeriodLocation_r16
#    Should Be Equal    ${nr_rrc_uplinkTxSwitchingPeriodLocation_r16}[0]    1
    Should Be Equal    ${nr_rrc_uplinkTxSwitchingPeriodLocation_r16}[0]    True
    ${nr_rrc_uplinkTxSwitchingCarrier_r16}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.spCellConfig_element//nr-rrc.uplinkTxSwitching_r16//nr-rrc.uplinkTxSwitchingCarrier_r16
    Should Be Equal    ${nr_rrc_uplinkTxSwitchingCarrier_r16}[0]    0
    ${nr_rrc_pucch_ResourceId}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.spCellConfig_element//nr-rrc.bwp_Dedicated_element//nr-rrc.resourceToAddModList//nr-rrc.pucch_ResourceId
    ${nr_rrc_startingSymbolIndex}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.spCellConfig_element//nr-rrc.bwp_Dedicated_element//nr-rrc.resourceToAddModList//nr-rrc.startingSymbolIndex
    ${nr_rrc_nrofSymbols}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.spCellConfig_element//nr-rrc.bwp_Dedicated_element//nr-rrc.resourceToAddModList//nr-rrc.nrofSymbols
    ${nr_rrc_startingSymbolIndex_list}    Create List
    ${nr_rrc_nrofSymbols_list}    Create List
    FOR    ${index}    ${item}    IN ENUMERATE    @{nr_rrc_pucch_ResourceId}
        RUN KEYWORD IF    0<=${item}<=5    Run Keywords
        ...    Append To List    ${nr_rrc_startingSymbolIndex_list}    4
        ...    AND    Append To List    ${nr_rrc_nrofSymbols_list}    7
        ...    ELSE IF    6<=${item}<=7    Run Keywords
        ...    Append To List    ${nr_rrc_startingSymbolIndex_list}    0
        ...    AND    Append To List    ${nr_rrc_nrofSymbols_list}    14
        ...    ELSE IF    10<=${item}<=11    Run Keywords
        ...    Append To List    ${nr_rrc_startingSymbolIndex_list}    3
        ...    AND    Append To List    ${nr_rrc_nrofSymbols_list}    8
        ...    ELSE IF    ${item}==8    Run Keywords
        ...    Append To List    ${nr_rrc_startingSymbolIndex_list}    4
        ...    AND    Append To List    ${nr_rrc_nrofSymbols_list}    7
        ...    ELSE IF    (${item}==9 or 18<=${item}<=28) and ${nr_rrc_nrofSymbols}[${index}]==8    Run Keywords
        ...    Append To List    ${nr_rrc_startingSymbolIndex_list}    3
        ...    AND    Append To List    ${nr_rrc_nrofSymbols_list}    8
        ...    ELSE IF    (${item}==9 or 18<=${item}<=28) and ${nr_rrc_nrofSymbols}[${index}]==14    Run Keywords
        ...    Append To List    ${nr_rrc_startingSymbolIndex_list}    0
        ...    AND    Append To List    ${nr_rrc_nrofSymbols_list}    14
    END
    Should Be Equal    ${nr_rrc_startingSymbolIndex_list}    ${nr_rrc_startingSymbolIndex}
    Should Be Equal    ${nr_rrc_nrofSymbols_list}    ${nr_rrc_nrofSymbols}

check UL switchedUl scell additon successful on wireshark on 24R3
    [Arguments]    ${puschMappingType}=TypeA
    IF    ${enb_instance} == ${enb_id}[0]     #TL348
        ${physCellId}=    get required value of parameter    Abbreviation=physCellId    gnb_index=${0}    distname_id=${3}
    ELSE IF    ${enb_instance} == ${enb_id}[1]     #TL383
        ${physCellId}=    get required value of parameter    Abbreviation=physCellId    gnb_index=${0}    distname_id=${2}
    END
    # RRC Reconfiguration
    ${RRC_Reconfiguration_filter}    Catenate
    ...    (((f1ap.F1AP_PDU == 0) && (f1ap.procedureCode == 12)) && (nr-rrc.startSymbolAndLength == 55)) && (nr-rrc.physCellId == ${physCellId})
    ${RRC_Reconfiguration_packets}    cap.filter_packets_by_expression    filter_expression=${RRC_Reconfiguration_filter}
    ${nr_rrc_k2}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.pusch_TimeDomainAllocationList//nr-rrc.PUSCH_TimeDomainResourceAllocation_element//nr-rrc.k2
    Run Keyword If    '${puschMappingType}' == 'TypeA'
    ...    Should Be Equal    ${nr_rrc_k2_list_24R3}    ${nr_rrc_k2}[0:8]
    ...    ELSE IF    '${puschMappingType}' == 'TypeB'
    ...    Should Be Equal    ${nr_rrc_k2_list_typeB}    ${nr_rrc_k2}[0:8]
    ${nr_rrc_mappingType}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.pusch_TimeDomainAllocationList//nr-rrc.PUSCH_TimeDomainResourceAllocation_element//nr-rrc.mappingType
    Run Keyword If    '${puschMappingType}' == 'TypeA'
    ...    Should Be Equal    ${nr_rrc_mappingType_list_24R3}    ${nr_rrc_mappingType}[0:8]
    ...    ELSE IF    '${puschMappingType}' == 'TypeB'
    ...    Should Be Equal    ${nr_rrc_mappingType_list_typeB}    ${nr_rrc_mappingType}[0:8]
    ${nr_rrc_startSymbolAndLength}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.pusch_TimeDomainAllocationList//nr-rrc.PUSCH_TimeDomainResourceAllocation_element//nr-rrc.startSymbolAndLength
    Run Keyword If    '${puschMappingType}' == 'TypeA'
    ...    Should Be Equal    ${nr_rrc_startSymbolAndLength_list_24R3}    ${nr_rrc_startSymbolAndLength}[0:8]
    ...    ELSE IF    '${puschMappingType}' == 'TypeB'
    ...    Should Be Equal    ${nr_rrc_startSymbolAndLength_list_typeB}    ${nr_rrc_startSymbolAndLength}[0:8]
    ${nr_rrc_uplinkTxSwitchingOption_r16}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.uplinkTxSwitchingOption_r16
    Should Be Equal    ${nr_rrc_uplinkTxSwitchingOption_r16}[0]    0
    ${nr_rrc_uplinkTxSwitchingPowerBoosting-r16}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.uplinkTxSwitchingPowerBoosting-r16
    Should Be Empty    ${nr_rrc_uplinkTxSwitchingPowerBoosting-r16}
    ###FOR TDD SCELL###
    ${nr_rrc_maxRank}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.sCellToAddModList//nr-rrc.maxRank
    Should Be Equal    ${nr_rrc_maxRank}[0]    2
    ${nr_rrc_srs_ResourceId}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.sCellToAddModList//nr-rrc.srs_ResourceId
    Should Be Equal    ${nr_rrc_srs_ResourceId}[0]    0
    ${nr_rrc_nrofSRS_Ports}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.sCellToAddModList//nr-rrc.nrofSRS_Ports
    Should Be Equal    ${nr_rrc_nrofSRS_Ports}[0]    1
    ${nr_rrc_uplinkTxSwitchingPeriodLocation_r16}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.sCellToAddModList//nr-rrc.uplinkTxSwitching_r16//nr-rrc.uplinkTxSwitchingPeriodLocation_r16
#    Should Be Equal    ${nr_rrc_uplinkTxSwitchingPeriodLocation_r16}[0]    0
    Should Be Equal    ${nr_rrc_uplinkTxSwitchingPeriodLocation_r16}[0]    False
    ${nr_rrc_uplinkTxSwitchingCarrier_r16}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.sCellToAddModList//nr-rrc.uplinkTxSwitching_r16//nr-rrc.uplinkTxSwitchingCarrier_r16
    Should Be Equal    ${nr_rrc_uplinkTxSwitchingCarrier_r16}[0]    1
    ###FOR FDD PCELL###
    ${nr_rrc_maxRank}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.spCellConfig_element//nr-rrc.maxRank
    Should Be Equal    ${nr_rrc_maxRank}[0]    1
    ${nr_rrc_tp_pi2BPSK}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.spCellConfig_element//nr-rrc.tp_pi2BPSK
    Should Be Equal    ${nr_rrc_tp_pi2BPSK}[0]    0
    ${nr_rrc_uplinkTxSwitchingPeriodLocation_r16}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.spCellConfig_element//nr-rrc.uplinkTxSwitching_r16//nr-rrc.uplinkTxSwitchingPeriodLocation_r16
#    Should Be Equal    ${nr_rrc_uplinkTxSwitchingPeriodLocation_r16}[0]    1
    Should Be Equal    ${nr_rrc_uplinkTxSwitchingPeriodLocation_r16}[0]    True
    ${nr_rrc_uplinkTxSwitchingCarrier_r16}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.spCellConfig_element//nr-rrc.uplinkTxSwitching_r16//nr-rrc.uplinkTxSwitchingCarrier_r16
    Should Be Equal    ${nr_rrc_uplinkTxSwitchingCarrier_r16}[0]    0
    ${nr_rrc_pucch_ResourceId}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.spCellConfig_element//nr-rrc.bwp_Dedicated_element//nr-rrc.resourceToAddModList//nr-rrc.pucch_ResourceId
    ${nr_rrc_startingSymbolIndex}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.spCellConfig_element//nr-rrc.bwp_Dedicated_element//nr-rrc.resourceToAddModList//nr-rrc.startingSymbolIndex
    ${nr_rrc_nrofSymbols}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.spCellConfig_element//nr-rrc.bwp_Dedicated_element//nr-rrc.resourceToAddModList//nr-rrc.nrofSymbols
    ${nr_rrc_startingSymbolIndex_list}    Create List
    ${nr_rrc_nrofSymbols_list}    Create List
    FOR    ${index}    ${item}    IN ENUMERATE    @{nr_rrc_pucch_ResourceId}
        RUN KEYWORD IF    0<=${item}<=5    Run Keywords
        ...    Append To List    ${nr_rrc_startingSymbolIndex_list}    4
        ...    AND    Append To List    ${nr_rrc_nrofSymbols_list}    7
        ...    ELSE IF    6<=${item}<=7    Run Keywords
        ...    Append To List    ${nr_rrc_startingSymbolIndex_list}    0
        ...    AND    Append To List    ${nr_rrc_nrofSymbols_list}    14
        ...    ELSE IF    10<=${item}<=11    Run Keywords
        ...    Append To List    ${nr_rrc_startingSymbolIndex_list}    3
        ...    AND    Append To List    ${nr_rrc_nrofSymbols_list}    8
        ...    ELSE IF    ${item}==8    Run Keywords
        ...    Append To List    ${nr_rrc_startingSymbolIndex_list}    4
        ...    AND    Append To List    ${nr_rrc_nrofSymbols_list}    7
        ...    ELSE IF    (${item}==9 or 18<=${item}<=28) and ${nr_rrc_nrofSymbols}[${index}]==8    Run Keywords
        ...    Append To List    ${nr_rrc_startingSymbolIndex_list}    3
        ...    AND    Append To List    ${nr_rrc_nrofSymbols_list}    8
        ...    ELSE IF    (${item}==9 or 18<=${item}<=28) and ${nr_rrc_nrofSymbols}[${index}]==14    Run Keywords
        ...    Append To List    ${nr_rrc_startingSymbolIndex_list}    0
        ...    AND    Append To List    ${nr_rrc_nrofSymbols_list}    14
    END
    Should Be Equal    ${nr_rrc_startingSymbolIndex_list}    ${nr_rrc_startingSymbolIndex}
    Should Be Equal    ${nr_rrc_nrofSymbols_list}    ${nr_rrc_nrofSymbols}

check counters for scell active success on pcell and scell
    IF    ${enb_instance} == ${enb_id}[0]    #TL348
        check counters for scell active success on pcell    KPI_file=CB012149_BC_scell_active_success_KPI.txt    para_index=${2}
        check counters for scell active success on scell    KPI_file=CB012149_BC_scell_active_success_KPI.txt    para_index=${3}
    ELSE IF    ${enb_instance} == ${enb_id}[1]    #TL383
        check counters for scell active success on pcell    KPI_file=CB012149_BC_scell_active_success_KPI.txt    para_index=${1}
        check counters for scell active success on scell    KPI_file=CB012149_BC_scell_active_success_KPI.txt    para_index=${2}
    END

check counters for scell active success on pcell
    [Arguments]     ${KPI_file}    ${para_index}    ${index}=${0}
    ${dict_kpis_name_value}=    get kpi from pm file    KPI_file=${KPI_file}    para_index=${para_index}    index=${index}
    check required KPI value via pm file    KPI_name_list=${CB012149_DA_pcell_check_kpi_names_value_larger_zero}
    ...    check_field=larger_specified_value    dict_kpi_get=${dict_kpis_name_value}
    check required KPI value via pm file    KPI_name_list=${CB012149_DA_pcell_check_kpi_names_value_zero}
    ...    check_field=equal_specified_value    dict_kpi_get=${dict_kpis_name_value}

check counters for scell active success on scell
    [Arguments]     ${KPI_file}    ${para_index}    ${index}=${0}
    ${dict_kpis_name_value}=    get kpi from pm file    KPI_file=${KPI_file}    para_index=${para_index}    index=${index}
    check required KPI value via pm file    KPI_name_list=${CB012149_DA_scell_check_kpi_names_value_larger_zero}
    ...    check_field=larger_specified_value    dict_kpi_get=${dict_kpis_name_value}
    check required KPI value via pm file    KPI_name_list=${CB012149_DA_scell_check_kpi_names_value_zero}
    ...    check_field=equal_specified_value    dict_kpi_get=${dict_kpis_name_value}

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

set apn dxdata2
    RUN KEYWORD IF    ${enb_instance} != ${enb_id}[2]
    ...    run keywords    Set Suite Variable    ${close_task}    538 1874
    ...    AND    set apn with special method    usedapn=${dxdata2_apn_348}    location_apn=${click_access_point}
    ...    ELSE    set apn to wap2    usedapn=${dxdata2_apn}

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
