*** Settings ***
Documentation
...    author: Ming Shi
...    contact: ming.shi@nokia-sbell.com
...    squal group: SG03
...    feature: CB012149-DA

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

*** Variables ***
${log_name_DA_IWK_1}    log_name_DA_IWK_1.pcap
${log_name_DA_IWK_2}    log_name_DA_IWK_2.pcap
${log_name_DA_IWK_3}    log_name_DA_IWK_3.pcap

${log_name_DA_IWK16_1}    log_name_DA_IWK16_1.pcap
${log_name_DA_IWK16_2}    log_name_DA_IWK16_2.pcap
${log_name_DA_IWK16_3}    log_name_DA_IWK16_3.pcap
${log_name_DA_IWK16_4}    log_name_DA_IWK16_4.pcap
${log_name_DA_IWK16_5}    log_name_DA_IWK16_5.pcap
${log_name_DA_IWK16_6}    log_name_DA_IWK16_6.pcap
${log_name_DA_IWK16_7}    log_name_DA_IWK16_7.pcap

${log_name_DA_IWK6_1}    log_name_DA_IWK6_1.pcap
${log_name_DA_IWK6_2}    log_name_DA_IWK6_2.pcap
${log_name_DA_IWK6_3}    log_name_DA_IWK6_3.pcap

${log_name_DA_IWK19_1}    log_name_DA_IWK19_1.pcap
${log_name_DA_IWK19_2}    log_name_DA_IWK19_2.pcap
${log_name_DA_IWK19_3}    log_name_DA_IWK19_3.pcap

${log_name_DA_IWK8_1}    log_name_DA_IWK8_1.pcap
${log_name_DA_IWK8_2}    log_name_DA_IWK8_2.pcap
${log_name_DA_IWK8_3}    log_name_DA_IWK8_3.pcap
${log_name_DA_IWK8_4}    log_name_DA_IWK8_4.pcap

${log_name_EDA_05437018_01}    log_name_EDA_05437018_01.pcap
${log_name_EDA_05437018_02}    log_name_EDA_05437018_02.pcap
${log_name_EDA_05437018_03}    log_name_EDA_05437018_03.pcap

${expected_tput_dl}    1
${Send_Tput_DL}        2000M
${expected_tput_ul}    1
${Send_Tput_UL}        600M
${Send_Tput_DL_small}        5M
${Send_Tput_UL_small}        10M
@{expected_value_D001_gnb1}    ${1}    ${1}    ${7}    ${1}    ${7}
@{Counter_D001}    ${0}
${kpis_templates_id}    1040
${tool_path}    /opt/workspace/Tool
${X70_wap2apn_location}    959 1370
${X70_mdrb2apn_location}    959 1576
${X70_mdrb1apn_location}    959 1802

@{enb_id}    34821    38321    358
@{cell_id}    0    1    2    3    4    5    6
@{cell_id_348}    0    1    2    3    4    5    6
@{multi_gnb_PA}    ${0}     ${127}     ${35}     ${50}
@{multi_gnb_PA_358}    ${0}
@{multi_gnb_PA_348}    ${0}    ${50}    ${70}    ${10}
@{multi_gnb_PA_383}    ${0}    ${50}    ${70}    ${10}

${DL_PORT_K01}    ${tl.ues[1].iperf_details.port}
${UL_PORT_K01}    ${tl.ues[1].iperf_details.ssh_connection_details.port}
@{gnb_list}    ${0}
${scf_dir_path}    /opt/workspace/CRT/Master/SCF_file/
${tl_scf_file_name1}    gNB1_Golden_SCF.xml
${tl_scf_file_name2}    gNB2_Golden_SCF.xml
${golden_scf_name}    gNB1_Golden_SCF_trunk.xml

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
#@{5Gcell5_VALUES_DA_IWK19}    ${10}    ${20}    ${10}    ${10}
@{5Gcell5_VALUES_DA_IWK19}    ${10}    ${10}    ${10}    ${10}
@{5Gcell5_VALUES_DA_IWK8}    ${10}    ${20}    ${10}    ${10}

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
@{nr_rrc_mappingType_list}    0    0    0    0    0    1    1    1
@{nr_rrc_mappingType_list_typeB}    1    1    1    1    1    1    1    1
@{nr_rrc_startSymbolAndLength_list_24R3}    27    27    41    41    55    69    53    67
@{nr_rrc_startSymbolAndLength_list_25R1}    27    41    55    69    83    53    67    81
@{nr_rrc_startSymbolAndLength_list}    27    41    55    69    83    53    67    81
@{nr_rrc_startSymbolAndLength_list_typeB}    27    41    55    69    83    53    67    81

${l2stream3_ttitrace_BB_02_1}    l2stream3_ttitrace_BB_02_1
${l2stream3_ttitrace_EDA_04474899_1}    l2stream3_ttitrace_EDA_04474899_1
${l2stream3_ttitrace_BB_04_1}    l2stream3_ttitrace_BB_04_1
${l2stream3_ttitrace_BB_04_2}    l2stream3_ttitrace_BB_04_2
${l2stream3_ttitrace_BB_10_1}    l2stream3_ttitrace_BB_10_1
${l2stream3_ttitrace_BB_10_2}    l2stream3_ttitrace_BB_10_2
${l2stream3_ttitrace_DA_IWK8_1}    l2stream3_ttitrace_DA_IWK8_1

${l2stream3_bip_DA_IWK8_1}    l2stream3_bip_DA_IWK8_1

${ue_type_qcom}    ${tl.ues[1].capabilities[0]}
${ue_type_qcom_2}    ${tl.ues[2].capabilities[0]}
${specify_port}    53368

*** Test Cases ***
#[1]USCB012149-DA#IWK6_R16_UL_Tx_Switching_UE_interworking_with_A6_measurement_based_TDD_SCell_swap
#    [Documentation]    USCB012149-DA_IWK6 (need to 2 TDD intra freq cell)
#    ...    This case validate the successful operation of the FDD + TDD FR1 UL TX switching (Option 1) feature activation.
#    ...    IWK with CB008290-AactSCellSwapFr1    M    Enumerated {0:disabled, 1:a6BasedSa}    MRBTS/NRBTS/actSCellSwapFr1
#    ...    1. Prerequisite: modify parameters, Disable CB012149
#    ...    2. Attach UE to FDD Pcell,UE have no R16 UL Tx switching band combination report
#    ...    3. change FDD PA value to trigger the A1 measurement, TDD Scell addition successful
#    ...    4. Enable CB012149 change parameter ulTxSwitchingSupportList with element contains ca_F_Fr1T_Sa_switchedUl
#    ...    5. check the UE log or wireshark log From log, the bandcombination have no update
#    ...    6. Then detach this UE,repeat step1-2,UE attach successfully and TDD activated as scell successfully.
#    ...    check the UE log or wireshark log
#    ...    UE report R16 UL Tx switching band combination
#    ...    RRC message contains CellGroupConfig.uplinkTxSwitchingOption-r16 = switchedUL
#    ...    7.Trigger A6_measurement_based_TDD_SCell_swap  from TDD scell1 to TDD scell2.
#    ...    8. Trigger UE UDP DL/UL Peak Tput. check DL/UL Peak Tput, keep the same.
#    ...    9. check the wireshark log and BTS log
#    ...    10. check Counter
#    ...    11. detach ue
#    ...    12. teardown
#    [Tags]    USCB012149-DA_IWK6    CRT_TRUNK
#    [Setup]    Common Case TestLine Setup    ModifySCF_Beforecommission=True
#            ...    ParamterToModify=${PARAM_12149_gnb1_DA_IWK6_new}    ListToAdd=${ListToAdd_12149_gnb1_D_IWK6}
#            ...    ListParamterToModify=${ListToModify_12149_gnb1_BC_01}    ParameterToDelete=${ParameterToDelete_12149_gnb1_BC_01}
#            ...    scf_path=${tl_scf_dir_path}    golden_scf_name=${tl_gnb1_scf_${sw_version}}    is_pdl_checking_needed=${True}
#    Run Keyword And Continue On Failure    DA#IWK6 Prerequisite
#    Run Keyword And Continue On Failure    DA#IWK6 Step 1 UE attach on pcell
#    Run Keyword And Continue On Failure    DA#IWK6 Step 2 check logs for UL switchedUl scell addition successful on wireshark
#    Run Keyword And Continue On Failure    DA#IWK6 Step 3 UE make traffic
#    Run Keyword And Continue On Failure    DA#IWK6 Step 4 Trigger A6_measurement_based_TDD_SCell_swap from TDD scell1 to TDD scell2
#    Run Keyword And Continue On Failure    DA#IWK6 Step 5 check Counter and IWK6_A6_Swap on wireshark log
#    Run Keyword And Continue On Failure    DA#IWK6 Step 6 check DL UL Peak Tput
#    Run Keyword And Continue On Failure    DA#IWK6 Step 7 check IWK6 swap counters
#    [Teardown]    DA#IWK6 Teardown

#[1]USCB012149-DA#IWK16_R16_UL_Tx_Switching_UE_interworking_with_CB008124
#    [Documentation]    USCB012149-DA_IWK16
#    ...    This case validates the R16 UL Tx Switching single UE peak throughput when FDD cell is configured
#    ...    with PUSCH mapping type B
#    ...    IWK with CB008124: UL Resource Reservation and Scheduling by Configured Grants Type 2
#    ...    for interact with configured grant type 2.
#    ...    1. Prerequisite: modify parameters, enable CB012149 and configure CB008124
#    ...    2. Attach UE to FDD Pcell,UE have R16 UL Tx switching band combination report
#    ...    3. change FDD PA value to trigger the A1 measurement, TDD Scell addition successful
#    ...    4. check the UE log or wireshark log
#    ...    UE report R16 UL Tx switching band combination
#    ...    RRC message contains CellGroupConfig.uplinkTxSwitchingOption-r16 = switchedUL
#    ...    5. Trigger DL only traffic, UE DL peak throughput is reached
#    ...    6. start both UL and DL full buffer data transfer
#    ...    Both uplink single UE peak throughput and downlink single UE peak throughput are reached
#    ...    7. check the wireshark log and TTI log
#    ...    8. check Counter
#    ...    9. detach ue
#    ...    10. teardown
#    [Tags]    USCB012149-DA_IWK16    CRT_TRUNK
#    [Setup]    Common Case TestLine Setup    ModifySCF_Beforecommission=True
#            ...    ParamterToModify=${PARAM_12149_gnb1_DA_IWK16_new}    ListToAdd=${ListToAdd_12149_gnb1_BC_01}
#            ...    ListParamterToModify=${ListToModify_12149_gnb1_DA_IWK16}    ParameterToDelete=${ParameterToDelete_12149_gnb1_BC_01}
#            ...    MOsToAdd=${gnb1_12149_DA_IWK16_MOsToAdd}    is_pdl_checking_needed=${True}
#            ...    scf_path=${tl_scf_dir_path}    golden_scf_name=${tl_gnb1_scf_${sw_version}}
#    Run Keyword And Continue On Failure    DA#IWK16 Prerequisite
#    Run Keyword And Continue On Failure    DA#IWK16 Step 1 UE attach on pcell
#    Run Keyword And Continue On Failure    DA#IWK16 Step 2 check logs for UL switchedUl scell addition successful on wireshark
#    Run Keyword And Continue On Failure    DA#IWK16 Step 3 UE make traffic
#    Run Keyword And Continue On Failure    DA#IWK16 Step 4 check DL UL Peak Tput
#    Run Keyword And Continue On Failure    DA#IWK16 Step 5 Setup new DRB associated with CG profile
#    Run Keyword And Continue On Failure    DA#IWK16 Step 6 check counters and IWK16_CG_setup on wireshark log
#    Run Keyword And Continue On Failure    DA#IWK16 Step 7 make DL and UL small traffic
#    Run Keyword And Continue On Failure    DA#IWK16 Step 8 check DL UL Peak Tput
#    Run Keyword And Continue On Failure    DA#IWK16 Step 9 make DL and UL small traffic
#    Run Keyword And Continue On Failure    DA#IWK16 Step 10 check DL UL Peak Tput
#    Run Keyword And Continue On Failure    DA#IWK16 Step 11 TA cannot trigger this check points
#    Run Keyword And Continue On Failure    DA#IWK16 Step 12 delete new DRB
#    [Teardown]    DA#IWK16 Teardown

[1]USCB012149-DA#IWK19_R16_UL_Tx_Switching_UE_interworking_with_5GC001817
    [Documentation]    USCB012149-DA_IWK19
    ...    This case validates the R16 UL Tx Switching single UE peak throughput when FDD cell is configured
    ...    IWK with 5GC001817
    ...    actAperCsiCell    Boolean    M    Activation flag for aperiodic CSI.     5GC001817-A
    ...    enableDynamicBetaOffsets    Enumerated {disable, enableLimited, enableFull}    M
    ...    This value is used to indicate dynamic beta offsets enable status for aperiodic CSI report scheduling.
    ...    Detail refer to 5G_UP_ALG_3500 and 5G_UP_ALG_3561.    5GC001817-C
    ...    dynamicBetaOffsetsList    Structure defined in 5G_L2_IF_148    O
    ...    Present only when 'enableDynamicBetaOffsets' configured to not disable. Detail refer to 5G_UP_ALG_3561.5GC001817-C
    ...    1. Prerequisite: modify parameters, enable CB012149 and configure 5GC001817
    ...    2. Attach UE to FDD Pcell,UE have R16 UL Tx switching band combination report
    ...    3. change FDD PA value to trigger the A1 measurement, TDD Scell addition successful
    ...    4. check the UE log or wireshark log
    ...    UE report R16 UL Tx switching band combination
    ...    RRC message contains CellGroupConfig.uplinkTxSwitchingOption-r16 = switchedUL
    ...    5. Trigger DL only traffic, UE DL peak throughput is reached
    ...    6. start both UL and DL full buffer data transfer
    ...    Both uplink single UE peak throughput and downlink single UE peak throughput are reached
    ...    7. check the wireshark log and TTI log
    ...    8. check Counter
    ...    9. detach ue
    ...    10. teardown
    [Tags]    USCB012149-DA_IWK19    CRT_TRUNK
    [Setup]
    DA#IWK19 Prerequisite
    DA#IWK19 Step 1 UE attach on pcell
    DA#IWK19 Step 2 check logs for UL switchedUl scell addition successful on wireshark
    DA#IWK19 Step 3 UE make traffic on DL
    DA#IWK19 Step 4 check peak throughput on DL
    DA#IWK19 Step 5 UE1 Start UL traffic on Pcell and Scell
    DA#IWK19 Step 6 check counters
    Run Keyword And Continue On Failure    DA#IWK19 Step 7 check logs on TTI
    DA#IWK19 Step 8 check peak throughput on DL and UL
    [Teardown]    DA#IWK19 Teardown

[1]USCB012149-DA#IWK8_R16_UL_Tx_Switching_UE_interworking_with_CB008236_PUSCH_slot_aggregation_with_different_sCellDeactInPoorRf
    [Documentation]    USCB012149-DA_IWK8
    ...    This case validates the UL slot aggregation.
    ...    Support is limited to FDD SA deployments, Type A repetitions and voice traffic (VoNR).
    ...    This functionality improves UE's PUSCH cell edge performance for VoNR.
    ...    1. Prerequisite: modify parameters, enable CB012149 and configure CB008236
    ...    2. Attach UE to FDD Pcell,UE have R16 UL Tx switching band combination report
    ...    3. change FDD PA value to trigger the A1 measurement, TDD Scell addition successful
    ...    4. check the UE log or wireshark log
    ...    UE report R16 UL Tx switching band combination
    ...    RRC message contains CellGroupConfig.uplinkTxSwitchingOption-r16 = switchedUL
    ...    5. Trigger UL only traffic, UE UL peak throughput is reached
    ...    6. Start VoNR, and modify attna to trigger UL slot aggregation, scell deactived.
    ...    7. check the wireshark log and TTI log
    ...    8. check Counter
    ...    9. detach ue
    ...    10. teardown
    [Tags]    USCB012149-DA_IWK8   CRT_TRUNK
    [Setup]
    DA#IWK8 Prerequisite
    DA#IWK8 Step 1 UE attach on pcell
    DA#IWK8 Step 2 check logs for UL switchedUl scell addition successful on wireshark
    DA#IWK8 Step 3 UE make traffic on UL
    DA#IWK8 Step 4 check counters
    DA#IWK8 Step 5 check UL Peak Tput
    DA#IWK8 Step 6 UE make 6688 voice call
    DA#IWK8 Step 7 check UL Peak Tput
    DA#IWK8 Step 8 trigger SCell deactivation due to PUSCH slot aggregation on scell
    DA#IWK8 Step 9 check counters and PUSCH_slot_aggregation on wireshark log
    EDA_05437018 all steps
    [Teardown]    DA#IWK8 Teardown

*** Keywords ***
DA#IWK6 Prerequisite
    DA Case Prerequisite

DA#IWK6 Step 1 UE attach on pcell
    DA Case Step UE attach on pcell    filename=${log_name_DA_IWK6_1}

DA#IWK6 Step 2 check logs for UL switchedUl scell addition successful on wireshark
    Run Keyword And Continue On Failure    Check wireshark log for 12149 DA Case    pcap_file=${log_name_DA_IWK6_1}

DA#IWK6 Step 3 UE make traffic
    DA Case Step UE make traffic    filename=${log_name_DA_IWK6_2}

DA#IWK6 Step 4 Trigger A6_measurement_based_TDD_SCell_swap from TDD scell1 to TDD scell2
    ###change TDD scell1 PA to make the RSRP of this cell below thresholdSCellSwapSourceRsrp to trigger A6 measurement
    Start capture gNB log on master    filename=${log_name_DA_IWK6_3}
    Change Attenuation value    cell=5Gcell${cell_id}[5]    value=${multi_gnb_PA_348}[0]
    Change Attenuation value    cell=5Gcell${cell_id}[3]    value=${multi_gnb_PA_348}[4]
    sleep     10s
    [Teardown]    Stop and download Logs on gNB on master    filename=${log_name_DA_IWK6_3}

DA#IWK6 Step 5 check Counter and IWK6_A6_Swap on wireshark log
    #check IWK6_A6 swap, check Tput
    Run Keyword And Continue On Failure    DA IWK6 swap check counters
    Run Keyword And Continue On Failure    Check wireshark log for 12149 DA IWK6_A6_Swap     pcap_file=${log_name_DA_IWK6_3}

DA#IWK6 Step 6 check DL UL Peak Tput
    [Arguments]    ${ue_index}=${1}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    ${nrcellid_cell}    Create list  ${nrcellid_pcell}    ${nrcellid_scell2}
    Run Keyword And Continue On Failure    Check single direction throughput     ue_index=${ue_index}    ue_type=${ue_type}
    ...    expect_throughput=${expected_tput_dl}    gnb_index=${gnb_index}    direction=DL   list_of_cell_ids=${nrcellid_cell}
    Run Keyword And Continue On Failure    Check single direction throughput     ue_index=${ue_index}    ue_type=${ue_type}
    ...    expect_throughput=${expected_tput_ul}    gnb_index=${gnb_index}    direction=UL   list_of_cell_ids=${nrcellid_cell}

DA#IWK6 Step 7 check IWK6 swap counters
    comment    step5: check counters
    Prepare with PM counter time to caculate    period=start
    sleep    6min    reason=check KPIs after make traffic during 5mins and xml report generated 1min
    Run Keyword And Continue On Failure    check counters for scell active success on pcell and scell    pcell=${2}    scell=${4}

DA#IWK6 Teardown
    DA Case Teardown




DA#IWK16 Prerequisite
    DA Case Prerequisite

DA#IWK16 Step 1 UE attach on pcell
    DA Case Step UE attach on pcell    filename=${log_name_DA_IWK16_1}

DA#IWK16 Step 2 check logs for UL switchedUl scell addition successful on wireshark
    Run Keyword And Continue On Failure    Check wireshark log for 12149 DA Case    pcap_file=${log_name_DA_IWK16_1}

DA#IWK16 Step 3 UE make traffic
    #puschMappingType=TypeB
    DA Case Step UE make traffic    filename=${log_name_DA_IWK16_2}

DA#IWK16 Step 4 check DL UL Peak Tput
    [Arguments]    ${ue_index}=${1}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    ${nrcellid_cell}    Create list  ${nrcellid_pcell}    ${nrcellid_scell2}
    Run Keyword And Continue On Failure    Check single direction throughput     ue_index=${ue_index}    ue_type=${ue_type}
    ...    expect_throughput=${expected_tput_dl}    gnb_index=${gnb_index}    direction=DL   list_of_cell_ids=${nrcellid_cell}
    Run Keyword And Continue On Failure    Check single direction throughput     ue_index=${ue_index}    ue_type=${ue_type}
    ...    expect_throughput=${expected_tput_ul}    gnb_index=${gnb_index}    direction=UL   list_of_cell_ids=${nrcellid_cell}

DA#IWK16 Step 5 Setup new DRB associated with CG profile
    ##Setup new DRB associated with CG profile (5QI-8)
    Prepare with PM counter time to caculate    period=start
    Start capture gNB log on master    filename=${log_name_DA_IWK16_3}
    Run Keyword And Continue On Failure    add or delete 5QI via npc dynamic rule    imsi=${tl.ues[1].imsi}    rule=ADD5QI8-PZ4-MXD
    sleep     60s
    [Teardown]    Stop and download Logs on gNB on master    filename=${log_name_DA_IWK16_3}

DA#IWK16 Step 6 check counters and IWK16_CG_setup on wireshark log
    Prepare with PM counter time to caculate    period=start
    #check be observed that CG is activated.
    #Check counter  #Initial UL configured grant type 2 activation attempts (M55308C00020)=1
    #Check counter  #Successful UL configured grant type 2 activation attempts (M55308C00021)=1
    Run Keyword And Continue On Failure    DA IWK16_Case Step 4 check counters
    Run Keyword And Continue On Failure    Check wireshark log for 12149 DA IWK16_CG_setup     pcap_file=${log_name_DA_IWK16_3}
    #check shall be observed that CG configuration is accepted, UE is configured with CG but CG is not activated.

DA#IWK16 Step 7 make DL and UL small traffic
    DA Case Step UE make traffic
    ...    filename=${log_name_DA_IWK16_4}
    ...    Send_Tput_DL=${Send_Tput_DL_small}
    ...    Send_Tput_UL=${Send_Tput_UL_small}

DA#IWK16 Step 8 check DL UL Peak Tput
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    ${nrcellid_cell}    Create list  ${nrcellid_pcell}
    Run Keyword And Continue On Failure    Check single direction throughput     ue_index=${ue_index}    ue_type=${ue_type}
    ...    expect_throughput=${expected_tput_dl}    gnb_index=${gnb_index}    direction=DL   list_of_cell_ids=${nrcellid_cell}
    Run Keyword And Continue On Failure    Check single direction throughput     ue_index=${ue_index}    ue_type=${ue_type}
    ...    expect_throughput=${expected_tput_ul}    gnb_index=${gnb_index}    direction=UL   list_of_cell_ids=${nrcellid_cell}

DA#IWK16 Step 9 make DL and UL small traffic
    DA Case Step UE make traffic
    ...    filename=${log_name_DA_IWK16_5}
    ...    Send_Tput_DL=${Send_Tput_DL}
    ...    Send_Tput_UL=${Send_Tput_UL_small}
    ...    DL_PORT_K01=${dl_port}
    ...    UL_PORT_K01=${ul_port}

DA#IWK16 Step 10 check DL UL Peak Tput
    ${nrcellid_cell}    Create list  ${nrcellid_pcell}    ${nrcellid_scell}
    Run Keyword And Continue On Failure    Check single direction throughput     ue_index=${ue_index}    ue_type=${ue_type}
    ...    expect_throughput=${expected_tput_dl}    gnb_index=${gnb_index}    direction=DL   list_of_cell_ids=${nrcellid_cell}
    ${nrcellid_cell}    Create list  ${nrcellid_pcell}
    Run Keyword And Continue On Failure    Check single direction throughput     ue_index=${ue_index}    ue_type=${ue_type}
    ...    expect_throughput=${expected_tput_ul}    gnb_index=${gnb_index}    direction=UL   list_of_cell_ids=${nrcellid_cell}

DA#IWK16 Step 11 TA cannot trigger this check points
    Comment    TA cannot trigger this check points
        ## TA cannot trigger this check points
    #     #  observed that CG is keept activated. Though, if, for any reason, SCell is scheduled in UL, it shall be observed
    #     #that CG is deactivated and maintained deactivated until the SCell is deactivated again.
    #    #Initial ULconfigured grant type 2 de-activation attempts (M55308C00022)
    #    #Successful UL configured grant type 2 de-activation attempts (M55308C00023)
    #    Prepare with PM counter time to caculate    period=start
    #    Start capture gNB log on master    filename=${log_name_DA_IWK16_6}
    #    mtk m80 make traffic    ue_ip=${UE_IP}    direction=UL    ue_index=${ue_index}
    #    ...    ul_throughput=${Send_Tput_UL}    duration=${7200}    ul_port=${ul_port}
    #    Stop and download Logs on gNB on master    filename=${log_name_DA_IWK16_6}
    #    Run Keyword And Continue On Failure    DA IWK16_Case Step 4 check counters
    #    Run Keyword And Continue On Failure    Check single direction throughput     ue_index=${ue_index}    ue_type=${ue2_type}
    #    ...    expect_throughput=${expected_tput_dl}    gnb_index=${gnb_index}    direction=DL   list_of_cell_ids=${nrcellid_cell}
    #    Run Keyword And Continue On Failure    Check single direction throughput     ue_index=${ue_index}    ue_type=${ue2_type}
    #    ...    expect_throughput=${expected_tput_ul}    gnb_index=${gnb_index}    direction=UL   list_of_cell_ids=${nrcellid_cell}

DA#IWK16 Step 12 delete new DRB
    Start capture gNB log on master    filename=${log_name_DA_IWK16_7}
    Run Keyword And Continue On Failure    add or delete 5QI via npc dynamic rule     imsi=${tl.ues[1].imsi}     rule=DEL5QI8-PZ4-MXD
    #    ##It shall be observed that CG is deactivated and maintained deactivated until the SCell is deactivated again.
    #    ##This is valid even if the UL data rate decreases to minimum or to zero.
    [Teardown]     Stop and download Logs on gNB on master    filename=${log_name_DA_IWK16_7}

DA#IWK16 Teardown
    DA Case Teardown





DA#IWK19 Prerequisite
    robot_common_operations.Common Case Setup    allowed_faults_ids=4291,6327,7311,4546
    AlarmWatchdog.add_allow_alarms    fault_id=4291
    AlarmWatchdog.add_allow_alarms    fault_id=6327
    AlarmWatchdog.add_allow_alarms    fault_id=7311
    AlarmWatchdog.add_allow_alarms    fault_id=4546
    Check UE device status with adb recover    ue_index=${1}
    comment    Prerequisite
    IF    ${enb_instance} == ${enb_id}[0]
        paras change on BTS
        ...    paras=${CB012149_ciphering_algorithms}
        ...    delta_file_name=${epc_log_path}${CB012149_ciphering_algorithms_json_file}
        Online modify parmeters     parameters_to_update=${PARAM_12149_gnb1_DA_IWK19_348}    skip_parameter_relation_errors=False
        COAM Wait for gnb ready and cell setup
        ###set gnb1 cell1 PA to 0
        PA one cell 0 on and set other cell value 4 port for T348    cellid=${cell_id_348}[1]    set_value=${multi_gnb_PA}[0]
    ELSE IF    ${enb_instance} == ${enb_id}[1]
        paras change on BTS
        ...    paras=${CB012149_ciphering_algorithms}
        ...    delta_file_name=${epc_log_path}${CB012149_ciphering_algorithms_json_file}
        Online modify parmeters     parameters_to_update=${PARAM_12149_gnb1_DA_IWK19_348}    skip_parameter_relation_errors=False
        COAM Wait for gnb ready and cell setup
        ###set gnb1 cell1 PA to 0
        PA one cell 0 on and set other cell value 4 port for T348    cellid=${cell_id_348}[1]    set_value=${multi_gnb_PA}[0]
    END

DA#IWK19 Step 1 UE attach on pcell
    comment    step1: ue attach to FDD cell as pcell
    power_ue.Prepare UE    ue_type=${tl.ues[2].capabilities[2]}    ue_index=${2}
    Start capture gNB log on master    filename=${log_name_DA_IWK19_1}
    IF    ${enb_instance} == ${enb_id}[0]     #TL348
        Step1: UE attach    ue_type=${ue_type_qcom_2}    ue_index=${2}
        Comment    trigger A1 to add scell
#        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[5]    value=${multi_gnb_PA_348}[3]    ip_addr=${att_ipaddr_1}
        Set the attenuation value of ports simultaneously
        ...    att_ports=${5Gcell5_ANTS}    values=${5Gcell5_VALUES_DA_IWK19}    att_ipaddr=${att_ipaddr_1}
    ELSE IF    ${enb_instance} == ${enb_id}[1]     #TL383
        Step1: UE attach    ue_type=${ue_type_qcom}    ue_index=${1}
        Comment    trigger A1 to add scell
#        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[5]    value=${multi_gnb_PA_348}[3]    ip_addr=${att_ipaddr_1}
        Set the attenuation value of ports simultaneously
        ...    att_ports=${5Gcell5_ANTS}    values=${5Gcell5_VALUES_DA_IWK19}    att_ipaddr=${att_ipaddr_1}
    END
    Sleep    5s    Reason=wait for Scell add success
    [Teardown]    Stop and download Logs on gNB on master    filename=${log_name_DA_IWK19_1}

DA#IWK19 Step 2 check logs for UL switchedUl scell addition successful on wireshark
    comment    step2: check ue UL switchedUl scell addition successful via wireshark
    Check wireshark log for 12149_DA    logname=${log_name_DA_IWK19_1}    puschMappingType=TypeB
    ${c_rnti}=    Get RNTI-ID message    logname=${log_name_DA_IWK19_1}
    Set Test Variable    ${c_rnti}
    Run Keyword And Continue On Failure    Check wireshark log for 12149 DA IWK19_actAperCsi     pcap_file=${log_name_DA_IWK19_1}

DA#IWK19 Step 3 UE make traffic on DL
    comment    step3: make DL traffic traffic on Pcell and Scell
    Start capture gNB log on master    filename=${log_name_DA_IWK19_2}
    IF    ${enb_instance} == ${enb_id}[0]    #TL348
        Start only DL traffic and check tput common ue    ue_index=${2}    cellid=${1}    ue_type=${ue_type_qcom_2}    gnb_index=${0}
        ...                                tput_dl_cell=${expected_tput_dl}    dl_throughput=${Send_Tput_DL}    duration=${7200}
        ...                                dl_port=${DL_PORT}
    ELSE IF    ${enb_instance} == ${enb_id}[1]     #TL383
        Start only DL traffic and check tput common ue    ue_index=${1}    cellid=${1}    ue_type=${ue_type_qcom}    gnb_index=${0}
        ...                                tput_dl_cell=${expected_tput_dl}    dl_throughput=${Send_Tput_DL}    duration=${7200}
        ...                                dl_port=${DL_PORT}
    END
    [Teardown]     Stop and download Logs on gNB on master    filename=${log_name_DA_IWK19_2}

DA#IWK19 Step 4 check peak throughput on DL
    comment    step7: check peak throughput
    IF    ${enb_instance} == ${enb_id}[0]
        Sleep    5m
        ${dl_expected_throughput_pcell_origin}    ${ul_expected_throughput_pcell}=    get_expect_throughput
        ...    tl_scf_dir_path=${tl_scf_dir_path}    tl_scf_file_name=${tl_gnb1_scf_${sw_version}}    cell_id=${400}
        ${dl_expected_throughput_scell_origin}    ${ul_expected_throughput_scell}=    get_expect_throughput
        ...    tl_scf_dir_path=${tl_scf_dir_path}    tl_scf_file_name=${tl_gnb1_scf_${sw_version}}    cell_id=${700}
        ${dl_expected_throughput_pcell}    Evaluate    ${dl_expected_throughput_pcell_origin} * ${0.53}
#        ${dl_expected_throughput_pcell}    Evaluate    ${dl_expected_throughput_pcell_origin} * ${0.34}
        ${dl_expected_throughput_scell}    Evaluate    ${dl_expected_throughput_scell_origin} * ${0.85}
#        ${dl_expected_throughput_scell}    Evaluate    ${dl_expected_throughput_scell_origin} * ${0.47}
#        ${dl_expected_throughput_scell}    Evaluate    ${dl_expected_throughput_scell_origin} * ${0.90}
        check intra gnb ca throughput    scellid=${4}    pcellid=${1}    gnb_prime=${0}    gnb_external=${0}
        ...    tput_dl_pcell=${dl_expected_throughput_pcell}    tput_dl_scell=${dl_expected_throughput_scell}
        ...    time=300s    ue_type=${ue_type_qcom_2}    ue_index=${2}
    ELSE IF    ${enb_instance} == ${enb_id}[1]
        Sleep    5m
        ${dl_expected_throughput_pcell_origin}    ${ul_expected_throughput_pcell}=    get_expect_throughput
        ...    tl_scf_dir_path=${tl_scf_dir_path}    tl_scf_file_name=${tl_gnb1_scf_${sw_version}}    cell_id=${400}
        ${dl_expected_throughput_scell_origin}    ${ul_expected_throughput_scell}=    get_expect_throughput
        ...    tl_scf_dir_path=${tl_scf_dir_path}    tl_scf_file_name=${tl_gnb1_scf_${sw_version}}    cell_id=${700}
        ${dl_expected_throughput_pcell}    Evaluate    ${dl_expected_throughput_pcell_origin} * ${0.53}
        ${dl_expected_throughput_scell}    Evaluate    ${dl_expected_throughput_scell_origin} * ${0.59}
        check intra gnb ca throughput    scellid=${4}    pcellid=${1}    gnb_prime=${0}    gnb_external=${0}
        ...    tput_dl_pcell=${dl_expected_throughput_pcell}    tput_dl_scell=${dl_expected_throughput_scell}
        ...    time=300s    ue_type=${ue_type_qcom}    ue_index=${1}
    END

DA#IWK19 Step 5 UE1 Start UL traffic on Pcell and Scell
    comment    step5: make UL traffic traffic on Pcell and Scell
    Prepare with PM counter time to caculate    period=start
    Start capture gNB log on master    filename=${log_name_DA_IWK19_3}
    IF    ${enb_instance} == ${enb_id}[0]    #TL348
        Start only UL traffic and check tput common ue    ue_index=${2}    cellid=${1}    ue_type=${ue_type_qcom_2}    gnb_index=${0}
        ...                                tput_ul_cell=${expected_tput_ul}    ul_throughput=${Send_Tput_UL}    duration=${7200}
        ...                                ul_port=${UL_PORT}
    ELSE IF    ${enb_instance} == ${enb_id}[1]    #TL383
        Start only UL traffic and check tput common ue    ue_index=${1}    cellid=${1}    ue_type=${ue_type_qcom}    gnb_index=${0}
        ...                                tput_ul_cell=${expected_tput_ul}    ul_throughput=${Send_Tput_UL}    duration=${7200}
        ...                                ul_port=${UL_PORT}
    END
    [Teardown]     Stop and download Logs on gNB on master    filename=${log_name_DA_IWK19_3}

DA#IWK19 Step 6 check counters
    comment    step4: check counters
    Prepare with PM counter time to caculate    period=end
    sleep    1min    reason=check KPIs xml report generated 1min
    Run Keyword And Continue On Failure    check counters for scell active success on pcell and scell

DA#IWK19 Step 7 check logs on TTI
    comment    step6: check UL logs on TTI
    IF    ${enb_instance} == ${enb_id}[0]    #TL348
        Capture Ttitrace With Admin Mode and Convert format    names=${l2stream3_ttitrace_BB_04_2}    nr_phy_cell_ids=400,700
        ...    capture_time=2s
        ${slot_1_6}    ${slot_3_8}=    check_required_filed_data
        ...    filename=${epc_log_path}/${l2stream3_ttitrace_BB_04_2}_ul.csv    c_rnti=${c_rnti}    physCellId=400
    ELSE IF    ${enb_instance} == ${enb_id}[1]    #TL383
        Capture Ttitrace With Admin Mode and Convert format    names=${l2stream3_ttitrace_BB_04_2}    nr_phy_cell_ids=400,700
        ...    capture_time=2s
        ${slot_1_6}    ${slot_3_8}=    check_required_filed_data
        ...    filename=${epc_log_path}/${l2stream3_ttitrace_BB_04_2}_ul.csv    c_rnti=${c_rnti}    physCellId=400
    END
    ${result_slot_1_6}=    Run Keyword And Return Status    Should Be True    condition=${slot_1_6}>0    msg=no satisfied data in slot 1 or slot 6
    ${result_slot_3_8}=    Run Keyword And Return Status    Should Be True    condition=${slot_3_8}>0    msg=no satisfied data in slot 3 or slot 8
    Should Be True    ${result_slot_1_6} or ${result_slot_3_8}

DA#IWK19 Step 8 check peak throughput on DL and UL
    comment    step7: check peak throughput
    IF    ${enb_instance} == ${enb_id}[0]    #TL348
        Sleep    5m
        ${dl_expected_throughput_pcell_origin}    ${ul_expected_throughput_pcell}=    get_expect_throughput
        ...    tl_scf_dir_path=${tl_scf_dir_path}    tl_scf_file_name=${tl_gnb1_scf_${sw_version}}    cell_id=${400}
        ${dl_expected_throughput_scell_origin}    ${ul_expected_throughput_scell_origin}=    get_expect_throughput
        ...    tl_scf_dir_path=${tl_scf_dir_path}    tl_scf_file_name=${tl_gnb1_scf_${sw_version}}    cell_id=${700}
        ${dl_expected_throughput_pcell}    Evaluate    ${dl_expected_throughput_pcell_origin} * ${0.53}
#        ${dl_expected_throughput_pcell}    Evaluate    ${dl_expected_throughput_pcell_origin} * ${0.34}
        ${dl_expected_throughput_scell}    Evaluate    ${dl_expected_throughput_scell_origin} * ${0.85}
#        ${dl_expected_throughput_scell}    Evaluate    ${dl_expected_throughput_scell_origin} * ${0.90}
        # due to CB007491 Two Additional DMRS configured
        ${ul_expected_throughput_scell}    Evaluate    ${ul_expected_throughput_scell_origin} * ${0.85}
        check intra gnb ca throughput    scellid=${4}    pcellid=${1}    gnb_prime=${0}    gnb_external=${0}
        ...    tput_dl_pcell=${dl_expected_throughput_pcell}    tput_dl_scell=${dl_expected_throughput_scell}
        ...    tput_ul_pcell=${ul_expected_throughput_pcell}    tput_ul_scell=${ul_expected_throughput_scell}
        ...    time=300s    ue_type=${ue_type_qcom_2}    ue_index=${2}
    ELSE IF    ${enb_instance} == ${enb_id}[1]    #TL383
        Sleep    5m
        ${dl_expected_throughput_pcell_origin}    ${ul_expected_throughput_pcell}=    get_expect_throughput
        ...    tl_scf_dir_path=${tl_scf_dir_path}    tl_scf_file_name=${tl_gnb1_scf_${sw_version}}    cell_id=${400}
        ${dl_expected_throughput_scell_origin}    ${ul_expected_throughput_scell_origin}=    get_expect_throughput
        ...    tl_scf_dir_path=${tl_scf_dir_path}    tl_scf_file_name=${tl_gnb1_scf_${sw_version}}    cell_id=${700}
        ${dl_expected_throughput_pcell}    Evaluate    ${dl_expected_throughput_pcell_origin} * ${0.53}
        ${dl_expected_throughput_scell}    Evaluate    ${dl_expected_throughput_scell_origin} * ${0.59}
        # due to CB007491 Two Additional DMRS configured
        ${ul_expected_throughput_scell}    Evaluate    ${ul_expected_throughput_scell_origin} * ${0.82}
        check intra gnb ca throughput    scellid=${4}    pcellid=${1}    gnb_prime=${0}    gnb_external=${0}
        ...    tput_dl_pcell=${dl_expected_throughput_pcell}    tput_dl_scell=${dl_expected_throughput_scell}
        ...    tput_ul_pcell=${ul_expected_throughput_pcell}    tput_ul_scell=${ul_expected_throughput_scell}
        ...    time=300s    ue_type=${ue_type_qcom}    ue_index=${1}
    END

DA#IWK19 Teardown
    robot_common_operations.Common Case Teardown
    AlarmWatchdog.remove_allow_alarms    fault_id=4291
    AlarmWatchdog.remove_allow_alarms    fault_id=6327
    AlarmWatchdog.remove_allow_alarms    fault_id=7311
    AlarmWatchdog.remove_allow_alarms    fault_id=4546
    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
    Stop DL or UL traffic common ue    ue_index=${2}    ue_type=${ue_type_qcom_2}    direction=DL
    Stop DL or UL traffic common ue    ue_index=${2}    ue_type=${ue_type_qcom_2}    direction=UL
    Step4: Detach UE    ue_type=${ue_type_qcom_2}    ue_index=${2}
    IF    ${enb_instance} == ${enb_id}[0]
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[1]    value=${multi_gnb_PA}[1]
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[5]    value=${multi_gnb_PA}[1]    ip_addr=${att_ipaddr_1}
        paras change on BTS
        ...    paras=${CB012149_recover_ciphering_algorithms}
        ...    delta_file_name=${epc_log_path}${CB012149_recover_ciphering_algorithms_json_file}
        Online delete parmeters    parameters_to_update=${PARAM_12149_delete_gnb1_DA_IWK19_348}    timeout=${300}
        Online modify parmeters    parameters_to_update=${PARAM_12149_recover_gnb1_DA_IWK19_348}    skip_parameter_relation_errors=False
        COAM Wait for gnb ready and cell setup
    ELSE IF    ${enb_instance} == ${enb_id}[1]
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[1]    value=${multi_gnb_PA}[1]
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[5]    value=${multi_gnb_PA}[1]    ip_addr=${att_ipaddr_1}
        paras change on BTS
        ...    paras=${CB012149_recover_ciphering_algorithms}
        ...    delta_file_name=${epc_log_path}${CB012149_recover_ciphering_algorithms_json_file}
        Online delete parmeters    parameters_to_update=${PARAM_12149_delete_gnb1_DA_IWK19_348}    timeout=${300}
        Online modify parmeters    parameters_to_update=${PARAM_12149_recover_gnb1_DA_IWK19_348}    skip_parameter_relation_errors=False
        COAM Wait for gnb ready and cell setup
    END
    Run Keyword And Ignore Error    CI_interface.Common Case Teardown





DA#IWK8 Prerequisite
    robot_common_operations.Common Case Setup    allowed_faults_ids=4291,6327,7311,4546
    AlarmWatchdog.add_allow_alarms    fault_id=4291
    AlarmWatchdog.add_allow_alarms    fault_id=6327
    AlarmWatchdog.add_allow_alarms    fault_id=7311
    AlarmWatchdog.add_allow_alarms    fault_id=4546
    Check UE device status with adb recover    ue_index=${1}
    comment    Prerequisite
    IF    ${enb_instance} == ${enb_id}[0]
#        Online modify parmeters     parameters_to_update=${PARAM_12149_gnb1_72a_to_72e}
#        Online delete objects    parameters_to_update=${OBJECT_DELETE_12149_gnb1_72a_to_72e}    timeout=${300}
        convert_to_json_file    data=${CB012149_72a_to_72e}    json_path=${case_logs_path}${CB012149_72a_to_72e_json_file_name}
        recommission for 72a to 72e    json_file=${case_logs_path}${CB012149_72a_to_72e_json_file_name}    skip_parameter_relation_errors=False
        COAM Wait for gnb ready and cell setup
        Online modify parmeters     parameters_to_update=${PARAM_12149_gnb1_DA_IWK8_348}    skip_parameter_relation_errors=False
        COAM Wait for gnb ready and cell setup
        ###set gnb1 cell1 PA to 0
        PA one cell 0 on and set other cell value 4 port for T348    cellid=${cell_id_348}[1]    set_value=${multi_gnb_PA}[0]
    ELSE IF    ${enb_instance} == ${enb_id}[1]
#        Online modify parmeters     parameters_to_update=${PARAM_12149_gnb1_72a_to_72e}
#        Online delete objects    parameters_to_update=${OBJECT_DELETE_12149_gnb1_72a_to_72e}    timeout=${300}
        convert_to_json_file    data=${CB012149_72a_to_72e}    json_path=${case_logs_path}${CB012149_72a_to_72e_json_file_name}
        recommission for 72a to 72e    json_file=${case_logs_path}${CB012149_72a_to_72e_json_file_name}    skip_parameter_relation_errors=False
        COAM Wait for gnb ready and cell setup
        Online modify parmeters     parameters_to_update=${PARAM_12149_gnb1_DA_IWK8_348}    skip_parameter_relation_errors=False
        COAM Wait for gnb ready and cell setup
        ###set gnb1 cell1 PA to 0
        PA one cell 0 on and set other cell value 4 port for T348    cellid=${cell_id_348}[1]    set_value=${multi_gnb_PA}[0]
    END

DA#IWK8 Step 1 UE attach on pcell
    comment    step1: ue attach to FDD cell as pcell
    put btslog_ini file to ute
    ...    server_ip=${appserver_addr}    server_username=${appserver_username}    server_password=${appserver_password}
    Start capture syslog via btslog on ute
    power_ue.Prepare UE    ue_type=${ue_type_qcom}    ue_index=${1}
    Start capture gNB log on master    filename=${log_name_DA_IWK8_1}
    IF    ${enb_instance} == ${enb_id}[0]     #TL348
        Step1: UE attach    ue_type=${ue_type_qcom}    ue_index=${1}
        Comment    trigger A1 to add scell
        Set the attenuation value of ports simultaneously
        ...    att_ports=${5Gcell5_ANTS}    values=${5Gcell5_VALUES_DA_IWK8}    att_ipaddr=${att_ipaddr_1}
#        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[5]    value=${multi_gnb_PA_348}[3]    ip_addr=${att_ipaddr_1}
    ELSE IF    ${enb_instance} == ${enb_id}[1]     #TL383
        Step1: UE attach    ue_type=${ue_type_qcom}    ue_index=${1}
        Comment    trigger A1 to add scell
        Set the attenuation value of ports simultaneously
        ...    att_ports=${5Gcell5_ANTS}    values=${5Gcell5_VALUES_DA_IWK8}    att_ipaddr=${att_ipaddr_1}
#        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[5]    value=${multi_gnb_PA_348}[3]    ip_addr=${att_ipaddr_1}
    END
    Sleep    5s    Reason=wait for Scell add success
    [Teardown]    Stop and download Logs on gNB on master    filename=${log_name_DA_IWK8_1}

DA#IWK8 Step 2 check logs for UL switchedUl scell addition successful on wireshark
    comment    step2: check ue UL switchedUl scell addition successful via wireshark
    Check wireshark log for 12149_DA    logname=${log_name_DA_IWK8_1}    puschMappingType=TypeA
    ${c_rnti}=    Get RNTI-ID message    logname=${log_name_DA_IWK8_1}
    Set Test Variable    ${c_rnti}
    # due to current UE is not support, so ignore error so far, update on 2025.05.14
    Run Keyword And Ignore Error    Check wireshark log for 12149 DA IWK8_SharedSpectrumChAccess     pcap_file=${log_name_DA_IWK8_1}

DA#IWK8 Step 3 UE make traffic on UL
    comment    step3: make UL traffic traffic on Pcell and Scell
    Prepare with PM counter time to caculate    period=start
    Start capture gNB log on master    filename=${log_name_DA_IWK8_2}
    IF    ${enb_instance} == ${enb_id}[0]    #TL348
        Start only UL traffic and check tput common ue    ue_index=${1}    cellid=${1}    ue_type=${ue_type_qcom}    gnb_index=${0}
        ...                                tput_ul_cell=${expected_tput_ul}    ul_throughput=${Send_Tput_UL}    duration=${7200}
        ...                                ul_port=${UL_PORT}
    ELSE IF    ${enb_instance} == ${enb_id}[1]    #TL383
        Start only UL traffic and check tput common ue    ue_index=${1}    cellid=${1}    ue_type=${ue_type_qcom}    gnb_index=${0}
        ...                                tput_ul_cell=${expected_tput_ul}    ul_throughput=${Send_Tput_UL}    duration=${7200}
        ...                                ul_port=${UL_PORT}
    END
    [Teardown]     Stop and download Logs on gNB on master    filename=${log_name_DA_IWK8_2}

DA#IWK8 Step 4 check counters
    comment    step4: check counters
    Prepare with PM counter time to caculate    period=end
    sleep    1min    reason=check KPIs after xml report generated 1min
    Run Keyword And Continue On Failure    check counters for scell active success on pcell and scell

DA#IWK8 Step 5 check UL Peak Tput
    comment    step5: check peak throughput
    IF    ${enb_instance} == ${enb_id}[0]    #TL348
        ${dl_expected_throughput_pcell}    ${ul_expected_throughput_pcell}=    get_expect_throughput
        ...    tl_scf_dir_path=${tl_scf_dir_path}    tl_scf_file_name=${tl_gnb1_scf_${sw_version}}    cell_id=${400}
        ${dl_expected_throughput_scell}    ${ul_expected_throughput_scell_origin}=    get_expect_throughput
        ...    tl_scf_dir_path=${tl_scf_dir_path}    tl_scf_file_name=${tl_gnb1_scf_${sw_version}}    cell_id=${700}
        # due to CB007491 Two Additional DMRS configured
        ${ul_expected_throughput_scell}    Evaluate    ${ul_expected_throughput_scell_origin} * ${0.82}
        check intra gnb ca throughput    scellid=${4}    pcellid=${1}    gnb_prime=${0}    gnb_external=${0}
        ...    tput_ul_pcell=${ul_expected_throughput_pcell}    tput_ul_scell=${ul_expected_throughput_scell}
        ...    time=300s    ue_type=${ue_type_qcom}    ue_index=${1}
    ELSE IF    ${enb_instance} == ${enb_id}[1]    #TL383
        ${dl_expected_throughput_pcell}    ${ul_expected_throughput_pcell}=    get_expect_throughput
        ...    tl_scf_dir_path=${tl_scf_dir_path}    tl_scf_file_name=${tl_gnb1_scf_${sw_version}}    cell_id=${400}
        ${dl_expected_throughput_scell}    ${ul_expected_throughput_scell_origin}=    get_expect_throughput
        ...    tl_scf_dir_path=${tl_scf_dir_path}    tl_scf_file_name=${tl_gnb1_scf_${sw_version}}    cell_id=${700}
        # due to CB007491 Two Additional DMRS configured
        ${ul_expected_throughput_scell}    Evaluate    ${ul_expected_throughput_scell_origin} * ${0.82}
        check intra gnb ca throughput    scellid=${4}    pcellid=${1}    gnb_prime=${0}    gnb_external=${0}
        ...    tput_ul_pcell=${ul_expected_throughput_pcell}    tput_ul_scell=${ul_expected_throughput_scell}
        ...    time=300s    ue_type=${ue_type_qcom}    ue_index=${1}
    END

DA#IWK8 Step 6 UE make 6688 voice call
    comment    Step 6 UE1 make 6688 voice call
    Start capture gNB log on master    filename=${log_name_DA_IWK8_3}
    IF    ${enb_instance} == ${enb_id}[0]    #TL348
        Make a VoNR call(+6688) on SDX80    ue_index=${1}
        sleep    20s
        check voice call status    status=${2}    ue_index=${1}
    ELSE IF    ${enb_instance} == ${enb_id}[1]     #TL383
        Make a VoNR call(+6688) on SDX80    ue_index=${1}
        sleep    20s
        check voice call status    status=${2}    ue_index=${1}
    END
    [Teardown]     Stop and download Logs on gNB on master    filename=${log_name_DA_IWK8_3}

DA#IWK8 Step 7 check UL Peak Tput
    comment    step7: check peak throughput
    IF    ${enb_instance} == ${enb_id}[0]
        ${dl_expected_throughput_pcell}    ${ul_expected_throughput_pcell}=    get_expect_throughput
        ...    tl_scf_dir_path=${tl_scf_dir_path}    tl_scf_file_name=${tl_gnb1_scf_${sw_version}}    cell_id=${400}
        ${dl_expected_throughput_scell}    ${ul_expected_throughput_scell_origin}=    get_expect_throughput
        ...    tl_scf_dir_path=${tl_scf_dir_path}    tl_scf_file_name=${tl_gnb1_scf_${sw_version}}    cell_id=${700}
        # due to CB007491 Two Additional DMRS configured
        ${ul_expected_throughput_scell}    Evaluate    ${ul_expected_throughput_scell_origin} * ${0.82}
        check intra gnb ca throughput    scellid=${4}    pcellid=${1}    gnb_prime=${0}    gnb_external=${0}
        ...    tput_ul_pcell=${ul_expected_throughput_pcell}    tput_ul_scell=${ul_expected_throughput_scell}
        ...    time=300s    ue_type=${ue_type_qcom}    ue_index=${1}
    ELSE IF    ${enb_instance} == ${enb_id}[1]
        ${dl_expected_throughput_pcell}    ${ul_expected_throughput_pcell}=    get_expect_throughput
        ...    tl_scf_dir_path=${tl_scf_dir_path}    tl_scf_file_name=${tl_gnb1_scf_${sw_version}}    cell_id=${400}
        ${dl_expected_throughput_scell}    ${ul_expected_throughput_scell_origin}=    get_expect_throughput
        ...    tl_scf_dir_path=${tl_scf_dir_path}    tl_scf_file_name=${tl_gnb1_scf_${sw_version}}    cell_id=${700}
        # due to CB007491 Two Additional DMRS configured
        ${ul_expected_throughput_scell}    Evaluate    ${ul_expected_throughput_scell_origin} * ${0.82}
        check intra gnb ca throughput    scellid=${4}    pcellid=${1}    gnb_prime=${0}    gnb_external=${0}
        ...    tput_ul_pcell=${ul_expected_throughput_pcell}    tput_ul_scell=${ul_expected_throughput_scell}
        ...    time=300s    ue_type=${ue_type_qcom}    ue_index=${1}
    END

DA#IWK8 Step 8 trigger SCell deactivation due to PUSCH slot aggregation on scell
    Prepare with PM counter time to caculate    period=start
    Start capture gNB log on master    filename=${log_name_DA_IWK8_4}
    IF    ${enb_instance} == ${enb_id}[0]     #TL348
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id}[1]    value=${multi_gnb_PA_348}[2]
    ELSE IF    ${enb_instance} == ${enb_id}[1]     #TL383
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id}[1]    value=${multi_gnb_PA_348}[2]
    END
    Sleep    15s    Reason=wait for PA change success
    [Teardown]    Stop and download Logs on gNB on master    filename=${log_name_DA_IWK8_4}

DA#IWK8 Step 9 check counters and PUSCH_slot_aggregation on wireshark log
    # due to current UE is not support, so ignore error so far, update on 2025.05.14
    Run Keyword And Ignore Error    DA IWK8_Case check counters with SCell deactivation due to PUSCH slot aggregation on scell
    Run Keyword And Ignore Error    Check wireshark log for 12149 DA IWK8_PUSCH_slot_aggregation

EDA_05437018 all steps
    Run Keyword And Continue On Failure     hang up VoNR call    ue_index=${1}
    Stop DL or UL traffic common ue    ue_index=${1}    ue_type=${ue_type_qcom}    direction=DL
    Stop DL or UL traffic common ue    ue_index=${1}    ue_type=${ue_type_qcom}    direction=UL
    Step4: Detach UE    ue_type=${ue_type_qcom}    ue_index=${1}
    Online modify parmeters     parameters_to_update=${PARAM_gnb1_EDA_05437018_348}    skip_parameter_relation_errors=False
    COAM Wait for gnb ready and cell setup
    ###set gnb1 cell1 PA to 0
    PA one cell 0 on and set other cell value 4 port for T348    cellid=${cell_id_348}[1]    set_value=${multi_gnb_PA}[0]
    EDA_05437018 attach and trigger CA setup via A1    filename=${log_name_EDA_05437018_01}
    EDA_05437018 make UL traffic    filename=${log_name_EDA_05437018_02}
    Prepare with PM counter time to caculate    period=start
    EDA_05437018 add 5QI8    filename=${log_name_EDA_05437018_03}
#    EDA_05437018 make vonr    filename=${log_name_EDA_05437018_03}
    Prepare with PM counter time to caculate    period=end
    EDA_05437018 Check wireshark log for Sr_Periodicity of msg userModifiyReq    filename=${log_name_EDA_05437018_03}
    Sleep    6m
    get and check kpis    KPI_file=EDA_05437018.yml    para_index=${1}

DA#IWK8 Teardown
    robot_common_operations.Common Case Teardown
    AlarmWatchdog.remove_allow_alarms    fault_id=4291
    AlarmWatchdog.remove_allow_alarms    fault_id=6327
    AlarmWatchdog.remove_allow_alarms    fault_id=7311
    AlarmWatchdog.remove_allow_alarms    fault_id=4546
    Stop capture syslog via btslog on ute
    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
    Run Keyword And Continue On Failure     hang up VoNR call    ue_index=${1}
    Stop DL or UL traffic common ue    ue_index=${1}    ue_type=${ue_type_qcom}    direction=DL
    Stop DL or UL traffic common ue    ue_index=${1}    ue_type=${ue_type_qcom}    direction=UL
    Step4: Detach UE    ue_type=${ue_type_qcom}    ue_index=${1}
    IF    ${enb_instance} == ${enb_id}[0]
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[1]    value=${multi_gnb_PA}[1]
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[5]    value=${multi_gnb_PA}[1]    ip_addr=${att_ipaddr_1}
        Setup for Env cell on-air for 2 gnb    is_commission_for_second_gnb=False    tl_scf_file_name=${tl_gnb1_scf_${sw_version}}
#        Online delete parmeters    parameters_to_update=${PARAM_12149_delete_gnb1_DA_IWK8_348}    timeout=${300}
#        Online modify parmeters    parameters_to_update=${PARAM_12149_recover_gnb1_DA_IWK8_348}    skip_parameter_relation_errors=False
#        COAM Wait for gnb ready and cell setup
    ELSE IF    ${enb_instance} == ${enb_id}[1]
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[1]    value=${multi_gnb_PA}[1]
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[5]    value=${multi_gnb_PA}[1]    ip_addr=${att_ipaddr_1}
        Setup for Env cell on-air for 2 gnb    is_commission_for_second_gnb=False    tl_scf_file_name=${tl_gnb1_scf_${sw_version}}
#        Online delete parmeters    parameters_to_update=${PARAM_12149_delete_gnb1_DA_IWK8_348}    timeout=${300}
#        Online modify parmeters    parameters_to_update=${PARAM_12149_recover_gnb1_DA_IWK8_348}    skip_parameter_relation_errors=False
#        COAM Wait for gnb ready and cell setup
    END
    Run Keyword And Ignore Error    CI_interface.Common Case Teardown





DA Case Prerequisite
    robot_common_operations.Common Case Setup    allowed_faults_ids=2922,2923
    AlarmWatchdog.add_allow_alarms    fault_id=2922
    AlarmWatchdog.add_allow_alarms    fault_id=2923
    ###set gnb1 FDD cell2 PA to 0
    RUN KEYWORD IF    ${enb_instance} == ${enb_id}[2]     #TL358
    ###set gnb1 cell3 PA to 0   #TL358
    ...    PA one cell 0 on and set other cell value    cellid=${cell_id}[2]    set_value=${multi_gnb_PA_358}[0]
    ###set gnb1 cell3 PA to 0   #TL348
    ...    ELSE IF    ${enb_instance} == ${enb_id}[0]     #TL348
    ...    PA one cell 0 on and set other cell value    cellid=${cell_id}[2]    set_value=${multi_gnb_PA_348}[0]    total_cell=${5}
    ###set gnb1 cell3 PA to 0   #TL383
    ...    ELSE IF    ${enb_instance} == ${enb_id}[1]     #TL383
    ...    PA one cell 0 on and set other cell value    cellid=${cell_id}[2]    set_value=${multi_gnb_PA_383}[0]


DA Case Step UE attach on pcell
    [Arguments]    ${filename}
    comment    step1: UE0 attach on pcell
    CB0012149_common_keywords.Prepare UE For MTK80    ue_index=${1}    cap_index=${0}
    Change Attenuation value    cell=5Gcell${cell_id}[3]    value=${multi_gnb_PA_348}[3]
    Start capture gNB log on master    filename=${filename}
    mtk ue attach on 348    scf_name=${tl_gnb1_scf_${sw_version}}
#    sleep    30s
    Comment    trigger A1 to add scell
    Change Attenuation value    cell=5Gcell${cell_id}[3]    value=${multi_gnb_PA_348}[0]
    Sleep    5s    Reason=wait for Scell add success
    [Teardown]    Stop and download Logs on gNB on master    filename=${filename}

DA Case Step UE make traffic
    [Arguments]    ${filename}    ${Send_Tput_DL}=${Send_Tput_DL}    ${DL_PORT_K01}=${DL_PORT_K01}
    ...    ${Send_Tput_UL}=${Send_Tput_UL}    ${UL_PORT_K01}=${UL_PORT_K01}
    comment    make CA DL/UL Peak Tput
    Start capture gNB log on master    filename=${filename}
    Start only DL traffic and check tput    ue_index=${1}    cellid=${2}    ue_type=${ue1_type}    gnb_index=${0}
    ...                                tput_dl_cell=${expected_tput_dl}    dl_throughput=${Send_Tput_DL}    duration=${7200}
    ...                                dl_port=${DL_PORT_K01}
    Start only UL traffic and check tput    ue_index=${1}    cellid=${2}    ue_type=${ue1_type}    gnb_index=${0}
    ...                                tput_ul_cell=${expected_tput_ul}    ul_throughput=${Send_Tput_UL}    duration=${7200}
    ...                                ul_port=${UL_PORT_K01}
    [Teardown]     Stop and download Logs on gNB on master    filename=${filename}

DA Case Teardown
    robot_common_operations.Common Case Teardown
    AlarmWatchdog.remove_allow_alarms    fault_id=2922
    AlarmWatchdog.remove_allow_alarms    fault_id=2923
    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    get gnb snapshot
    Stop DL or UL traffic    ue_index=${1}    ue_type=${ue1_type}    direction=DL
    Stop DL or UL traffic    ue_index=${1}    ue_type=${ue1_type}    direction=UL
    CB0012149_common_keywords.Do UE Detach    ue_index=${1}
    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
    Run Keyword And Continue On Failure     Tear down the all connections

Check wireshark log for 12149 DA IWK6_A6_Swap
    [Arguments]     ${pcap_file}
    Comment    Check wireshark log for 12149 DA IWK6_A6_Swap
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${pcap_file}
    ${IWK6_A6_Swap_filter}    Catenate    (f1ap.procedureCode == 13) && (nr-rrc.measResultServingMOList == 2)
    ${IWK6_A6_Swap_packets}    cap.filter_packets_by_expression
    ...    filter_expression=${IWK6_A6_Swap_filter}
    ${measId}=    cap.Get Field Value By Xpath    pdml_list=${IWK6_A6_Swap_packets}     xpath=.//nr-rrc.measResultServingMOList
    Should Contain    ${measId}    2

Check wireshark log for 12149 DA IWK16_CG_setup
    [Arguments]     ${pcap_file}
    Comment    Check wireshark log for 12149 DA IWK16_CG_setup
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${pcap_file}
    ${IWK16_CG_setup_filter}    Catenate    (f1ap.procedureCode == 12) && (nr-rrc.configuredGrantConfig == 1)
    ${IWK16_CG_setup_packets}    cap.filter_packets_by_expression
    ...    filter_expression=${IWK16_CG_setup_filter}
    ${configuredGrantConfig}=    cap.Get Field Value By Xpath    pdml_list=${IWK16_CG_setup_packets}
    ...    xpath=.//nr-rrc.configuredGrantConfig
    Should Contain    ${configuredGrantConfig}    1

Check wireshark log for 12149 DA IWK8_SharedSpectrumChAccess
    [Arguments]     ${pcap_file}
    Comment    Check wireshark log for 12149 DA IWK8_SharedSpectrumChAccess
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${pcap_file}
    ${SharedSpectrumChAccessfilter}    Catenate    (f1ap.procedureCode == 13) && (nr-rrc.non_SharedSpectrumChAccess_r16 == 0)
    ${SharedSpectrumChAccess_packets}    cap.filter_packets_by_expression
    ...    filter_expression=${SharedSpectrumChAccessfilter}
    ${SharedSpectrumChAccess}=    cap.Get Field Value By Xpath    pdml_list=${SharedSpectrumChAccess_packets}
    ...    xpath=.//nr-rrc.non_SharedSpectrumChAccess_r16
    Should Contain    ${SharedSpectrumChAccess}    0

Check wireshark log for 12149 DA IWK19_actAperCsi
    [Arguments]     ${pcap_file}
    Comment    Check wireshark log for 12149 DA IWK19_actAperCsi
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${pcap_file}
    ${IWK19_actAperCsi_filter}    Catenate    (f1ap.procedureCode == 12) && (nr-rrc.reportConfigType == 3)
    ${IWK19_actAperCsi_packets}    cap.filter_packets_by_expression
    ...    filter_expression=${IWK19_actAperCsi_filter}
    ${actAperCsi}=    cap.Get Field Value By Xpath    pdml_list=${IWK19_actAperCsi_packets}
    ...    xpath=.//nr-rrc.reportConfigType
    Should Contain    ${actAperCsi}    3

Check wireshark log for 12149 DA IWK8_PUSCH_slot_aggregation
    ${drx_onDurationTimer1}=    Check wireshark log for 12149 DA IWK8_drx_onDurationTimer     pcap_file=${log_name_DA_IWK8_1}
    ${drx_onDurationTimer2}=    Check wireshark log for 12149 DA IWK8_drx_onDurationTimer     pcap_file=${log_name_DA_IWK8_3}
    ${drx_onDurationTimer3}=    Check wireshark log for 12149 DA IWK8_drx_onDurationTimer     pcap_file=${log_name_DA_IWK8_4}
    Should Contain    ${drx_onDurationTimer1}    7
    ##Should Contain    ${drx_onDurationTimer2}    7
    Should Contain    ${drx_onDurationTimer3}    10

Check wireshark log for 12149 DA IWK8_drx_onDurationTimer
    [Arguments]     ${pcap_file}
    Comment    Check wireshark log for 12149 DA IWK8_drx_onDurationTimer
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${pcap_file}
    ${IWK8_drx_onDurationTimer_filter}    Catenate    (f1ap.procedureCode == 12) && (nr-rrc.drx_onDurationTimer == 1)
    ${IWK8_drx_onDurationTimer_packets}    cap.filter_packets_by_expression
    ...    filter_expression=${IWK8_drx_onDurationTimer_filter}
    ${drx_onDurationTimer}=    cap.Get Field Value By Xpath    pdml_list=${IWK8_drx_onDurationTimer_packets}
    ...    xpath=.//nr-rrc.milliSeconds
    [Return]    ${drx_onDurationTimer}

check UL switchedUl scell additon successful on wireshark for IWK8
    [Arguments]    ${puschMappingType}=TypeA
    ${physCellId}=    get required value of parameter    Abbreviation=physCellId    gnb_index=${0}    distname_id=${3}
    # RRC Reconfiguration
    ${RRC_Reconfiguration_filter}    Catenate
    ...    (((f1ap.F1AP_PDU == 0) && (f1ap.procedureCode == 12)) && (nr-rrc.startSymbolAndLength)) && (nr-rrc.physCellId == ${physCellId})
    ${RRC_Reconfiguration_packets}    cap.filter_packets_by_expression    filter_expression=${RRC_Reconfiguration_filter}
    ${nr_rrc_k2}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.pusch_TimeDomainAllocationList//nr-rrc.PUSCH_TimeDomainResourceAllocation_element//nr-rrc.k2
    Run Keyword If    '${puschMappingType}' == 'TypeA'
    ...    Should Be Equal    ${nr_rrc_k2_list_IWK8}    ${nr_rrc_k2}[0:8]
    ...    ELSE IF    '${puschMappingType}' == 'TypeB'
    ...    Should Be Equal    ${nr_rrc_k2_list_typeB}    ${nr_rrc_k2}[0:8]
    ${nr_rrc_mappingType}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.pusch_TimeDomainAllocationList//nr-rrc.PUSCH_TimeDomainResourceAllocation_element//nr-rrc.mappingType
    Run Keyword If    '${puschMappingType}' == 'TypeA'
    ...    Should Be Equal    ${nr_rrc_mappingType_list_IWK8}    ${nr_rrc_mappingType}[0:8]
    ...    ELSE IF    '${puschMappingType}' == 'TypeB'
    ...    Should Be Equal    ${nr_rrc_mappingType_list_typeB}    ${nr_rrc_mappingType}[0:8]
    ${nr_rrc_startSymbolAndLength}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.pusch_TimeDomainAllocationList//nr-rrc.PUSCH_TimeDomainResourceAllocation_element//nr-rrc.startSymbolAndLength
    Run Keyword If    '${puschMappingType}' == 'TypeA'
    ...    Should Be Equal    ${nr_rrc_startSymbolAndLength_list_IWK8}    ${nr_rrc_startSymbolAndLength}[0:8]
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
    IF    ${enb_instance} == ${enb_id}[0]     #TL348
        check counters for scell active success on pcell    KPI_file=CB012149_BB_04_scell_active_success_KPI.txt    para_index=${1}
        check counters for scell active success on scell    KPI_file=CB012149_BB_04_scell_active_success_KPI.txt    para_index=${3}
#        IF    (${sw_version}[-4:-2] == 25 and ${sw_version}[-1] ==3) or (${sw_version}[-4:-2] > 25)
#            check counters for scell active success on pcell after_25r3_cni_141831
#            ...    KPI_file=CB012149_BB_04_scell_active_success_KPI.txt    para_index=${1}
#            check counters for scell active success on scell    KPI_file=CB012149_BB_04_scell_active_success_KPI.txt    para_index=${3}
#        ELSE
#            check counters for scell active success on pcell    KPI_file=CB012149_BB_04_scell_active_success_KPI.txt    para_index=${1}
#            check counters for scell active success on scell    KPI_file=CB012149_BB_04_scell_active_success_KPI.txt    para_index=${3}
#        END
    ELSE IF    ${enb_instance} == ${enb_id}[1]     #TL383
        check counters for scell active success on pcell    KPI_file=CB012149_BB_04_scell_active_success_KPI.txt    para_index=${1}
        check counters for scell active success on scell    KPI_file=CB012149_BB_04_scell_active_success_KPI.txt    para_index=${3}
#        IF    (${sw_version}[-4:-2] == 25 and ${sw_version}[-1] ==3) or (${sw_version}[-4:-2] > 25)
##            check counters for scell active success on pcell after_25r3_cni_141831
##            ...    KPI_file=CB012149_BB_04_scell_active_success_KPI.txt    para_index=${1}
#            check counters for scell active success on pcell    KPI_file=CB012149_BB_04_scell_active_success_KPI.txt    para_index=${1}
#            check counters for scell active success on scell    KPI_file=CB012149_BB_04_scell_active_success_KPI.txt    para_index=${2}
#        ELSE
#            check counters for scell active success on pcell    KPI_file=CB012149_BB_04_scell_active_success_KPI.txt    para_index=${1}
#            check counters for scell active success on scell    KPI_file=CB012149_BB_04_scell_active_success_KPI.txt    para_index=${2}
#        END
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

DA Case Step 4 check counters
    comment    step5: check counters
    Prepare with PM counter time to caculate    period=end
    sleep    1min    reason=check KPIs after xml report generated 1min
    Run Keyword And Continue On Failure    check counters for scell active success on pcell and scell

DA IWK6 swap check counters
    comment    DA IWK6 swap check counters
    Prepare with PM counter time to caculate    period=start
    sleep    60s
    Run Keyword And Continue On Failure    check counters for IWK6 swap counters on pcell
    ...    KPI_file=CB012149_DA_IWK6_R16_UL_Tx_Switching_UE_interworking_with_A6_measurement_based_TDD_SCell_swap.txt
    ...    para_index=${2}

check counters for IWK6 swap counters on pcell
    [Arguments]     ${KPI_file}    ${para_index}    ${index}=${0}
    ${dict_kpis_name_value}=    get kpi from pm file    KPI_file=${KPI_file}    para_index=${para_index}    index=${index}
    check required KPI value via pm file    KPI_name_list=${CB012149_IWK6_pcell_check_kpi_names_value_larger_zero}
    ...    check_field=larger_specified_value    dict_kpi_get=${dict_kpis_name_value}

check counters for Configured Grants Type 2 on pcell
    [Arguments]     ${KPI_file}    ${para_index}    ${index}=${0}
    ${dict_kpis_name_value}=    get kpi from pm file    KPI_file=${KPI_file}    para_index=${para_index}    index=${index}
    check required KPI value via pm file    KPI_name_list=${CB012149_IWK16_pcell_check_kpi_names_value_larger_zero}
    ...    check_field=larger_specified_value    dict_kpi_get=${dict_kpis_name_value}
    check required KPI value via pm file    KPI_name_list=${CB012149_IWK16_pcell_check_kpi_names_value_zero}
    ...    check_field=equal_specified_value    dict_kpi_get=${dict_kpis_name_value}

check counters for SCell deactivation due to PUSCH slot aggregation on scell
    [Arguments]     ${KPI_file}    ${para_index}    ${index}=${0}
    ${dict_kpis_name_value}=    get kpi from pm file    KPI_file=${KPI_file}    para_index=${para_index}    index=${index}
    check required KPI value via pm file    KPI_name_list=${CB012149_IWK8_scell_check_kpi_names_value_larger_zero}
    ...    check_field=larger_specified_value    dict_kpi_get=${dict_kpis_name_value}

DA IWK16_Case Step 4 check counters
    comment    DA IWK16_Case Step 4 check counters
    sleep     60s
    Run Keyword And Continue On Failure    check counters for Configured Grants Type 2 on pcell
    ...    KPI_file=CB012149_DA_IWK16_R16_UL_Tx_Switching_UE_interworking_with_CB008124_KPI.txt    para_index=${2}

DA IWK8_Case check counters with SCell deactivation due to PUSCH slot aggregation on scell
    comment    DA IWK8_Case check counters with SCell deactivation due to PUSCH slot aggregation on scell
    Prepare with PM counter time to caculate    period=end
    sleep     60s
    IF    ${enb_instance} == ${enb_id}[0]
        Run Keyword And Continue On Failure    check counters for SCell deactivation due to PUSCH slot aggregation on scell
        ...    KPI_file=CB012149_DA_IWK8_R16_UL_Tx_Switching_UE_interworking_with_CB008236.txt    para_index=${3}
    ELSE IF    ${enb_instance} == ${enb_id}[1]
        Run Keyword And Continue On Failure    check counters for SCell deactivation due to PUSCH slot aggregation on scell
        ...    KPI_file=CB012149_DA_IWK8_R16_UL_Tx_Switching_UE_interworking_with_CB008236.txt    para_index=${3}
    END

check value on TTI file DA
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






Check wireshark log for 12149_DA
    [Arguments]    ${logname}    ${puschMappingType}=TypeA
    Comment    check wireshark log for 12149_BB_04
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}
    check CB012149 UERadioCapabilityInfoIndication on wireshark
    Run Keyword If    '${release_info}' == 'SBTS24R3_ENB_0000'
    ...    check UL switchedUl scell additon successful on wireshark on 24R3    puschMappingType=${puschMappingType}
    ...    ELSE IF    '${release_info}' == 'SBTS25R1_ENB_0000'
    ...    check UL switchedUl scell additon successful on wireshark on 25R1    puschMappingType=${puschMappingType}
    ...    ELSE    check UL switchedUl scell additon successful on wireshark    puschMappingType=${puschMappingType}

modify and commission scf file
    ${new_log_scf_path}=    change scf file
    ...    scf_path=${tl_scf_dir_path}    scf_name=${tl_gnb1_scf_${sw_version}}    new_scf_path=${TS_LOG_PATH_BASE}
    ${file_name}=    Evaluate    '${new_log_scf_path}'.split('/')[-1]
    Common Case TestLine Setup    is_commission=${True}    is_commission_for_second_gnb=${False}
    ...    scf_path=${TS_LOG_PATH_BASE}    golden_scf_name=${file_name}
    ...    skip_parameter_relation_errors=${False}

EDA_05437018 attach and trigger CA setup via A1
    [Arguments]    ${filename}
    Start capture gNB log on master    filename=${filename}
    IF    ${enb_instance} == ${enb_id}[0]     #TL348
        Attach and check power UE    ue_type=${ue_type_qcom}    ue_index=${1}    4G_check=False
        Comment    trigger A1 to add scell
        Set the attenuation value of ports simultaneously
        ...    att_ports=${5Gcell5_ANTS}    values=${5Gcell5_VALUES_DA_IWK8}    att_ipaddr=${att_ipaddr_1}
    ELSE IF    ${enb_instance} == ${enb_id}[1]     #TL383
        Attach and check power UE    ue_type=${ue_type_qcom}    ue_index=${1}    4G_check=False
        Comment    trigger A1 to add scell
        Set the attenuation value of ports simultaneously
        ...    att_ports=${5Gcell5_ANTS}    values=${5Gcell5_VALUES_DA_IWK8}    att_ipaddr=${att_ipaddr_1}
    END
    Sleep    5s    Reason=wait for Scell add success
    [Teardown]    Stop and download Logs on gNB on master    filename=${filename}

EDA_05437018 make UL traffic
    [Arguments]    ${filename}
    Start capture gNB log on master    filename=${filename}
    IF    ${enb_instance} == ${enb_id}[0]    #TL348
        Start only UL traffic and check tput common ue    ue_index=${1}    cellid=${1}    ue_type=${ue_type_qcom}    gnb_index=${0}
        ...                                tput_ul_cell=${expected_tput_ul}    ul_throughput=${Send_Tput_UL}    duration=${7200}
        ...                                ul_port=${specify_port}
    ELSE IF    ${enb_instance} == ${enb_id}[1]    #TL383
        Start only UL traffic and check tput common ue    ue_index=${1}    cellid=${1}    ue_type=${ue_type_qcom}    gnb_index=${0}
        ...                                tput_ul_cell=${expected_tput_ul}    ul_throughput=${Send_Tput_UL}    duration=${7200}
        ...                                ul_port=${specify_port}
    END
    [Teardown]     Stop and download Logs on gNB on master    filename=${filename}

EDA_05437018 make vonr
    [Arguments]    ${filename}
    Start capture gNB log on master    filename=${filename}
    IF    ${enb_instance} == ${enb_id}[0]    #TL348
        Make a VoNR call(+6688) on SDX80    ue_index=${1}
        sleep    20s
        check voice call status    status=${2}    ue_index=${1}
    ELSE IF    ${enb_instance} == ${enb_id}[1]     #TL383
        Make a VoNR call(+6688) on SDX80    ue_index=${1}
        sleep    20s
        check voice call status    status=${2}    ue_index=${1}
    END
    [Teardown]     Stop and download Logs on gNB on master    filename=${filename}

EDA_05437018 add 5QI8
    [Arguments]    ${filename}
    Start capture gNB log on master    filename=${filename}
    IF    ${enb_instance} == ${enb_id}[0]    #TL348
        add or delete 5QI via npc dynamic rule    imsi=${tl.ues[1].imsi}    rule=ADD5QI8-PZ4-MXD
        sleep    20s    reason=wait for QCI08 added
    ELSE IF    ${enb_instance} == ${enb_id}[1]     #TL383
        add or delete 5QI via npc dynamic rule    imsi=${tl.ues[1].imsi}    rule=ADD5QI8-PZ4-MXD
        sleep    20s    reason=wait for QCI08 added
    END
    [Teardown]     Stop and download Logs on gNB on master    filename=${filename}

EDA_05437018 Check wireshark log for Sr_Periodicity of msg userModifiyReq
    [Arguments]     ${filename}
    Comment    EDA_05437018 Check wireshark log for Sr_Periodicity of msg userModifiyReq
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${filename}
    ${itf_l2_ps_user_usermodifyreq_filter}    Catenate    itf_l2_ps_user_usermodifyreq
    ${itf_l2_ps_user_usermodifyreq_packets}    cap.filter_packets_by_expression
    ...    filter_expression=${itf_l2_ps_user_usermodifyreq_filter}
    ${periodicity}=    cap.Get Field Value By Xpath    pdml_list=${itf_l2_ps_user_usermodifyreq_packets}
    ...    xpath=.//itf_l2_ps_sr_PerSrConfig.periodicity
    ${length_periodicity}=    Get Length    ${periodicity}
    Should Be Equal As Integers    ${length_periodicity}    ${2}
#    Should Be Equal As Integers    ${periodicity}[0]    ${20}
    Should Be Equal As Strings    ${periodicity}[0]    ${periodicity}[1]

get and check kpis
    [Arguments]
    ...    ${KPI_file}
    ...    ${para_index}
    ${counters}=    get required kpi values via pm file
    ...    KPI_file=${KPI_file}
    ...    para_index=${para_index}
    ${data}=    Evaluate    list(${counters}.values())
    Should Be Equal As Integers    ${data}[0]    ${0}
    Should Be Equal As Integers    ${data}[1]    ${0}
    Should Be True    ${data}[2] > ${0}
