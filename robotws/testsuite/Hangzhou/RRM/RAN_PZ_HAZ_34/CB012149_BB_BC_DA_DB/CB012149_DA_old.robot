*** Settings ***
Documentation
...    author: Jack Zeng
...    contact: jack.zeng@nokia-sbell.com
...    squal group: SG03
...    feature: CB012149-DA

Force Tags  CA_5G_RRM
...    PY36
Suite Setup    Run Keywords
...                            robot_common_operations.Common Suite Setup
...                            AND    Common Suite Setup for COAM
...                            AND    Get sagnb version for selenium
...                            AND    Set Suite Variable    ${tl_gnb1_scf_${sw_version}}    ${sw_version}_gNB1_Golden_SCF.xml

Suite Teardown     Run Keywords    Run Keyword And Ignore Error    CB0012149_common_KW.Prepare UE For MTK80    ue_index=${1}    cap_index=${0}
...                            AND    CB0012149_common_KW.Do UE Detach    ue_index=${1}
...                            AND    Common Suite Teardown for COAM    gnb_list=${gnb_list}


Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB012149_BB_BC_DA_DB/Resources/CB0012149_common_KW.robot

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

${log_name_DA_IWK6_3}    log_name_DA_IWK6_3.pcap
${log_name_DA_IWK8_4}    log_name_DA_IWK8_4.pcap

${expected_tput_dl}    1
${Send_Tput_DL}        280M
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

@{enb_id}    241    383    358
@{cell_id}    0    1    2    3    4    5    6
@{multi_gnb_PA}    ${30}     ${127}     ${35}     ${50}
@{multi_gnb_PA_358}    ${0}
#@{multi_gnb_PA_348}    ${15}     ${25}     ${35}     ${55}     ${75}    ${127}    ${65}    ${71}
@{multi_gnb_PA_348}    ${15}     ${25}     ${35}     ${55}     ${77}    ${127}    ${65}    ${71}
@{multi_gnb_PA_383}    ${30}     ${127}     ${35}     ${50}

${DL_PORT_K01}    ${tl.ues[1].iperf_details.port}
${UL_PORT_K01}    ${tl.ues[1].iperf_details.ssh_connection_details.port}
@{gnb_list}    ${0}
${scf_dir_path}    /opt/workspace/CRT/Master/SCF_file/
${tl_scf_file_name1}    gNB1_Golden_SCF.xml
${tl_scf_file_name2}    gNB2_Golden_SCF.xml
${golden_scf_name}    gNB1_Golden_SCF_trunk.xml

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

${ue2_type}                  ${tl.ues[1].capabilities[1]}
${ue1_type}           ${tl.ues[0].capabilities[0]}
${GNB_INDEX}    ${0}
${nrcellid_cell1}    556977
${nrcellid_pcell}    556978
${nrcellid_scell}    556979
${nrcellid_scell2}    556980
${nrcellid_cell}     ${nrcellid_pcell}     ${nrcellid_scell}
${ue_index}     1
@{nr_rrc_k2_list}    2    3    2    3    2    2    2    2
@{nr_rrc_k2_list_typeB}    2    3    2    2    2    2    2    2
@{nr_rrc_k2_list_IWK8}    3    3    4    5    6    9    10    11
@{nr_rrc_mappingType_list}    0    0    0    0    0    0    1    1
@{nr_rrc_mappingType_list_typeB}    1    1    1    1    1    1    1    1
@{nr_rrc_mappingType_list_IWK8}    0    0    0    0    0    0    0    0
@{nr_rrc_startSymbolAndLength_list}    27    27    41    41    55    69    53    67
@{nr_rrc_startSymbolAndLength_list_typeB}    27    27    55    69    83    53    67    81
@{nr_rrc_startSymbolAndLength_list_IWK8}    27    41    27    27    27    27    27    27
@{GNB_INDEX_list_snapshot}    ${0}
*** Test Cases ***
[1]USCB012149-DA#IWK6_R16_UL_Tx_Switching_UE_interworking_with_A6_measurement_based_TDD_SCell_swap
    [Documentation]    USCB012149-DA_IWK6 (需要TDD两个同频CC) 连线完成！
    ...    This case validate the successful operation of the FDD + TDD FR1 UL TX switching (Option 1) feature activation.
    ...    IWK with CB008290-AactSCellSwapFr1    M    Enumerated {0:disabled, 1:a6BasedSa}    MRBTS/NRBTS/actSCellSwapFr1
    ...    1. Prerequisite: modify parameters, Disable CB012149
    ...    2. Attach UE to FDD Pcell,UE have no R16 UL Tx switching band combination report
    ...    3. change FDD PA value to trigger the A1 measurement, TDD Scell addition successful
    ...    4. Enable CB012149 change parameter ulTxSwitchingSupportList with element contains ca_F_Fr1T_Sa_switchedUl
    ...    5. check the UE log or wireshark log From log, the bandcombination have no update
    ...    6. Then detach this UE,repeat step1-2,UE attach successfully and TDD activated as scell successfully.
    ...    check the UE log or wireshark log
    ...    UE report R16 UL Tx switching band combination
    ...    RRC message contains CellGroupConfig.uplinkTxSwitchingOption-r16 = switchedUL
    ...    7.Trigger A6_measurement_based_TDD_SCell_swap  from TDD scell1 to TDD scell2.
    ...    8. Trigger UE UDP DL/UL Peak Tput. check DL/UL Peak Tput, keep the same.
    ...    9. check the wireshark log and BTS log
    ...    10. check Counter
    ...    11. detach ue
    ...    12. teardown
    [Tags]    USCB012149-DA_IWK6    CRT_TRUNK
    [Setup]    Common Case TestLine Setup    ModifySCF_Beforecommission=True
            ...    ParamterToModify=${PARAM_12149_gnb1_DA_IWK6}    ListToAdd=${ListToAdd_12149_gnb1_D_IWK6}
            ...    ListParamterToModify=${ListToModify_12149_gnb1_BC_01}    ParameterToDelete=${ParameterToDelete_12149_gnb1_BC_01}
            ...    scf_path=${scf_dir_path}    golden_scf_name=${golden_scf_name}    is_pdl_checking_needed=${false}
#            ...    scf_path=${scf_dir_path}    golden_scf_name=${tl_gnb1_scf_${sw_version}}    is_pdl_checking_needed=${True}
    robot_common_operations.Common Case Setup    allowed_faults_ids=2922,2923
    AlarmWatchdog.add_allow_alarms    fault_id=2922
    AlarmWatchdog.add_allow_alarms    fault_id=2923
    DA Case Prerequisite
    DA Case Step 1 UE0 attach on pcell
    DA Case Step 2 UE0 make traffic
    ###change TDD scell1 PA to make the RSRP of this cell below thresholdSCellSwapSourceRsrp to trigger A6 measurement
    Start capture gNB log on master    filename=${log_name_DA_IWK6_3}
    Change Attenuation value    cell=5Gcell${cell_id}[5]    value=${multi_gnb_PA_348}[0]
    Change Attenuation value    cell=5Gcell${cell_id}[3]    value=${multi_gnb_PA_348}[4]
    sleep     10s
    Stop and download Logs on gNB on master    filename=${log_name_DA_IWK6_3}
    #check IWK6_A6 swap, check Tput
    Run Keyword And Continue On Failure    DA IWK6 swap check counters
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    ${nrcellid_cell}    Create list  ${nrcellid_pcell}    ${nrcellid_scell2}
    Run Keyword And Continue On Failure    Check wireshark log for 12149 DA IWK6_A6_Swap     pcap_file=${log_name_DA_IWK6_3}
    Run Keyword And Continue On Failure    Check single direction throughput     ue_index=${ue_index}    ue_type=${ue2_type}
    ...    expect_throughput=${expected_tput_dl}    gnb_index=${gnb_index}    direction=DL   list_of_cell_ids=${nrcellid_cell}
    Run Keyword And Continue On Failure    Check single direction throughput     ue_index=${ue_index}    ue_type=${ue2_type}
    ...    expect_throughput=${expected_tput_ul}    gnb_index=${gnb_index}    direction=UL   list_of_cell_ids=${nrcellid_cell}
    Run Keyword And Continue On Failure    DA Case Step 4 check IWK6 swap counters
    ##Run Keyword And Continue On Failure    DA Case Step 5 check logs on TTI
    [Teardown]     Run Keyword And Continue On Failure    DA Case Teardown

[1]USCB012149-DA#IWK16_R16_UL_Tx_Switching_UE_interworking_with_CB008124
    [Documentation]    USCB012149-DA_IWK16
    ...    This case validates the R16 UL Tx Switching single UE peak throughput when FDD cell is configured
    ...    with PUSCH mapping type B
    ...    IWK with CB008124: UL Resource Reservation and Scheduling by Configured Grants Type 2
    ...    for interact with configured grant type 2.
    ...    1. Prerequisite: modify parameters, enable CB012149 and configure CB008124
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
    [Tags]    USCB012149-DA_IWK16    CRT_TRUNK
    [Setup]    Common Case TestLine Setup    ModifySCF_Beforecommission=True
            ...    ParamterToModify=${PARAM_12149_gnb1_DA_IWK16}    ListToAdd=${ListToAdd_12149_gnb1_BC_01}
            ...    ListParamterToModify=${ListToModify_12149_gnb1_DA_IWK16}    ParameterToDelete=${ParameterToDelete_12149_gnb1_BC_01}
            ...    MOsToAdd=${gnb1_12149_DA_IWK16_MOsToAdd}    is_pdl_checking_needed=${false}
            ...    scf_path=${scf_dir_path}    golden_scf_name=${golden_scf_name}
#            ...    MOsToAdd=${gnb1_12149_DA_IWK16_MOsToAdd}    is_pdl_checking_needed=${True}
#            ...    scf_path=${scf_dir_path}    golden_scf_name=${tl_gnb1_scf_${sw_version}}
    robot_common_operations.Common Case Setup    allowed_faults_ids=2922,2923
    AlarmWatchdog.add_allow_alarms    fault_id=2922
    AlarmWatchdog.add_allow_alarms    fault_id=2923
    DA Case Prerequisite
    DA Case Step 1 UE0 attach on pcell
    DA Case Step 2 UE0 make traffic    #puschMappingType=TypeB
    #DA Case Step 3 Check CA DL UL Peak Tput
    ##Setup new DRB associated with CG profile (5QI-8)
    Prepare with PM counter time to caculate    period=start
    Start capture gNB log on master    filename=${log_name_DA_IWK16_3}
    Run Keyword And Continue On Failure    add or delete 5QI via npc dynamic rule    imsi=${tl.ues[1].imsi}    rule=ADD5QI8-PZ4-MXD
    sleep     60s
    Stop and download Logs on gNB on master    filename=${log_name_DA_IWK16_3}
    Prepare with PM counter time to caculate    period=start
    #check be observed that CG is activated.
    #Check counter  #Initial UL configured grant type 2 activation attempts (M55308C00020)=1
    #Check counter  #Successful UL configured grant type 2 activation attempts (M55308C00021)=1
    Run Keyword And Continue On Failure    DA IWK16_Case Step 4 check counters
    Run Keyword And Continue On Failure    Check wireshark log for 12149 DA IWK16_CG_setup     pcap_file=${log_name_DA_IWK16_3}
    #check shall be observed that CG configuration is accepted, UE is configured with CG but CG is not activated.
    Start capture gNB log on master    filename=${log_name_DA_IWK16_4}
#    Start both DL UL traffic    ue_index=${1}   ue_type=${ue2_type}    dl_throughput=${Send_Tput_DL_small}    pcellid=${2}
#    ...    gnb_index=${0}    ul_throughput=${Send_Tput_UL_small}     tput_ul_cell=${expected_tput_ul}    ul_port=${UL_PORT_K01}
#    ...    tput_dl_cell=${expected_tput_dl}
#    ...      protocol=udp      dl_port=${DL_PORT_K01}          duration=${7200}     scellid=${3}
    Start both DL UL traffic    ue_index=${1}    dl_throughput=${Send_Tput_DL_small}
    ...    ul_throughput=${Send_Tput_UL_small}    ul_port=${UL_PORT_K01}
    ...    dl_port=${DL_PORT_K01}          duration=${7200}
    Stop and download Logs on gNB on master    filename=${log_name_DA_IWK16_4}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    ${nrcellid_cell}    Create list  ${nrcellid_pcell}
    Run Keyword And Continue On Failure    Check single direction throughput     ue_index=${ue_index}    ue_type=${ue2_type}
    ...    expect_throughput=${expected_tput_dl}    gnb_index=${gnb_index}    direction=DL   list_of_cell_ids=${nrcellid_cell}
    Run Keyword And Continue On Failure    Check single direction throughput     ue_index=${ue_index}    ue_type=${ue2_type}
    ...    expect_throughput=${expected_tput_ul}    gnb_index=${gnb_index}    direction=UL   list_of_cell_ids=${nrcellid_cell}
    Start capture gNB log on master    filename=${log_name_DA_IWK16_5}
    mtk m80 make traffic    ue_ip=${UE_IP}    direction=DL    ue_index=${ue_index}
    ...    dl_throughput=${Send_Tput_DL}    duration=${7200}    dl_port=${dl_port}
    mtk m80 make traffic    ue_ip=${UE_IP}    direction=UL    ue_index=${ue_index}
    ...    ul_throughput=${Send_Tput_UL_small}    duration=${7200}    ul_port=${ul_port}
    Stop and download Logs on gNB on master    filename=${log_name_DA_IWK16_5}
    ${nrcellid_cell}    Create list  ${nrcellid_pcell}    ${nrcellid_scell}
    Run Keyword And Continue On Failure    Check single direction throughput     ue_index=${ue_index}    ue_type=${ue2_type}
    ...    expect_throughput=${expected_tput_dl}    gnb_index=${gnb_index}    direction=DL   list_of_cell_ids=${nrcellid_cell}
    ${nrcellid_cell}    Create list  ${nrcellid_pcell}
    Run Keyword And Continue On Failure    Check single direction throughput     ue_index=${ue_index}    ue_type=${ue2_type}
    ...    expect_throughput=${expected_tput_ul}    gnb_index=${gnb_index}    direction=UL   list_of_cell_ids=${nrcellid_cell}
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
    Run Keyword And Continue On Failure    add or delete 5QI via npc dynamic rule     imsi=${tl.ues[1].imsi}     rule=DEL5QI8-PZ4-MXD
#    ##It shall be observed that CG is deactivated and maintained deactivated until the SCell is deactivated again.
#    ##This is valid even if the UL data rate decreases to minimum or to zero.
    [Teardown]     Run Keyword And Continue On Failure    DA Case Teardown

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
    [Setup]    Common Case TestLine Setup    ModifySCF_Beforecommission=True
     ...    ParamterToModify=${PARAM_12149_gnb1_DA_IWK19}    ListToAdd=${ListToAdd_12149_gnb1_BC_01}
     ...    ListParamterToModify=${ListToModify_12149_gnb1_BC_01}    ParameterToDelete=${ParameterToDelete_12149_gnb1_BC_01}
     ...    scf_path=${scf_dir_path}    golden_scf_name=${golden_scf_name}    is_pdl_checking_needed=${false}
#     ...    scf_path=${scf_dir_path}    golden_scf_name=${tl_gnb1_scf_${sw_version}}    is_pdl_checking_needed=${True}
    robot_common_operations.Common Case Setup    allowed_faults_ids=2922,2923
    AlarmWatchdog.add_allow_alarms    fault_id=2922
    AlarmWatchdog.add_allow_alarms    fault_id=2923
    DA Case Prerequisite
    DA Case Step 1 UE0 attach on pcell
    DA Case Step 2 UE0 make traffic
    #Check wireshark log for 12149 DA IWK19_actAperCsi
    Run Keyword And Continue On Failure    Check wireshark log for 12149 DA IWK19_actAperCsi     pcap_file=${log_name_DA_IWK_1}
    #check counter
    Run Keyword And Continue On Failure    DA Case Step 4 check counters
    [Teardown]     Run Keyword And Continue On Failure    DA Case Teardown

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
    [Setup]    Common Case TestLine Setup    ModifySCF_Beforecommission=True
            ...    ParamterToModify=${PARAM_12149_gnb1_DA_IWK8}    ListToAdd=${ListToAdd_12149_gnb1_BC_01}
            ...    ListParamterToModify=${ListToModify_12149_gnb1_DA_IWK8}    ParameterToDelete=${ParameterToDelete_12149_gnb1_BC_01}
            ...    scf_path=${scf_dir_path}    golden_scf_name=${golden_scf_name}    is_pdl_checking_needed=${false}
#            ...    scf_path=${scf_dir_path}    golden_scf_name=${tl_gnb1_scf_${sw_version}}    is_pdl_checking_needed=${True}
    robot_common_operations.Common Case Setup    allowed_faults_ids=2922,2923
    AlarmWatchdog.add_allow_alarms    fault_id=2922
    AlarmWatchdog.add_allow_alarms    fault_id=2923
    DA Case Prerequisite
    DA Case Step 1 UE0 attach on pcell
    DA IWK8 Case Step 2 UE0 make traffic
    Run Keyword And Continue On Failure    Check wireshark log for 12149 DA IWK8_SharedSpectrumChAccess     pcap_file=${log_name_DA_IWK_1}
    Run Keyword And Continue On Failure    DA Case Step 3 UE0 make 6688 voice call and compare the DL UL Peak Tput
    Run Keyword And Continue On Failure    DA Case Step 4 check counters
    Prepare with PM counter time to caculate    period=start
    Start capture gNB log on master    filename=${log_name_DA_IWK8_4}
    Change Attenuation value    cell=5Gcell${cell_id}[3]    value=${multi_gnb_PA_348}[1]
    Change Attenuation value    cell=5Gcell${cell_id}[2]    value=${multi_gnb_PA_348}[3]
    Change Attenuation value    cell=5Gcell${cell_id}[2]    value=${multi_gnb_PA_348}[6]
    Change Attenuation value    cell=5Gcell${cell_id}[2]    value=${multi_gnb_PA_348}[7]
    Change Attenuation value    cell=5Gcell${cell_id}[2]    value=${multi_gnb_PA_348}[4]
    sleep    15s
    Stop and download Logs on gNB on master    filename=${log_name_DA_IWK8_4}
    #check counters for SCell deactivation due to PUSCH slot aggregation on scell
    DA IWK8_Case Step 4 check counters
    Run Keyword And Continue On Failure    Check wireshark log for 12149 DA IWK8_PUSCH_slot_aggregation
    [Teardown]     Run Keyword And Continue On Failure    DA IWK8 Case Teardown

[1]new_USCB012149-DA#IWK8_R16_UL_Tx_Switching_UE_interworking_with_CB008236_PUSCH_slot_aggregation_with_different_sCellDeactInPoorRf_348
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
    [Setup]    Common Case TestLine Setup    ModifySCF_Beforecommission=True
            ...    ParamterToModify=${PARAM_12149_gnb1_DA_IWK8_new}    ListToAdd=${ListToAdd_12149_gnb1_BC_01}
            ...    ListParamterToModify=${ListToModify_12149_gnb1_DA_IWK8}    ParameterToDelete=${ParameterToDelete_12149_gnb1_DA_IWK8}
            ...    scf_path=${scf_dir_path}    golden_scf_name=${tl_scf_file_name1}    is_pdl_checking_needed=${True}
    Run Keyword And Continue On Failure    DA#IWK8 Prerequisite
    Run Keyword And Continue On Failure    DA Case Step 1 UE0 attach on pcell
    Run Keyword And Continue On Failure    DA IWK8 Case Step 2 UE0 make traffic
    Run Keyword And Continue On Failure    Check wireshark log for 12149 DA IWK8_SharedSpectrumChAccess     pcap_file=${log_name_DA_IWK_1}
    Run Keyword And Continue On Failure    DA Case Step 3 UE0 make 6688 voice call and compare the DL UL Peak Tput
    Run Keyword And Continue On Failure    DA Case Step 4 check counters
    Prepare with PM counter time to caculate    period=start
    Start capture gNB log on master    filename=${log_name_DA_IWK8_4}
    Change Attenuation value    cell=5Gcell${cell_id}[3]    value=${multi_gnb_PA_348}[1]
    Change Attenuation value    cell=5Gcell${cell_id}[2]    value=${multi_gnb_PA_348}[3]
    Change Attenuation value    cell=5Gcell${cell_id}[2]    value=${multi_gnb_PA_348}[6]
    Change Attenuation value    cell=5Gcell${cell_id}[2]    value=${multi_gnb_PA_348}[7]
    Change Attenuation value    cell=5Gcell${cell_id}[2]    value=${multi_gnb_PA_348}[4]
    sleep    15s
    Stop and download Logs on gNB on master    filename=${log_name_DA_IWK8_4}
    #check counters for SCell deactivation due to PUSCH slot aggregation on scell
    DA IWK8_Case Step 4 check counters
    Run Keyword And Continue On Failure    Check wireshark log for 12149 DA IWK8_PUSCH_slot_aggregation
    [Teardown]     DA#IWK8 Teardown

*** Keywords ***
DA#IWK8 Prerequisite
    robot_common_operations.Common Case Setup    allowed_faults_ids=2922,2923
    AlarmWatchdog.add_allow_alarms    fault_id=2922
    AlarmWatchdog.add_allow_alarms    fault_id=2923
    DA Case Prerequisite

DA#IWK8 Teardown
    robot_common_operations.Common Case Teardown
    AlarmWatchdog.remove_allow_alarms    fault_id=2922
    AlarmWatchdog.remove_allow_alarms    fault_id=2923
    Run Keyword And Continue On Failure     hang up VoNR call    ue_index=${1}
#    Stop DL or UL traffic    ue_index=${1}    ue_type=${ue2_type}    direction=DL
    Stop DL or UL traffic    ue_index=${1}    direction=DL
#    Stop DL or UL traffic    ue_index=${1}    ue_type=${ue2_type}    direction=UL
    Stop DL or UL traffic    ue_index=${1}    direction=UL
    ###Run Keyword And Continue On Failure    CB0012149_common_KW.Do UE Detach    ue_index=${1}
    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
    Run Keyword And Continue On Failure     Tear down the all connections
    #hang up VoNR call    ue_index=${1}
    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run Keyword And Continue On Failure    get gnb snapshot
#    Change Attenuation value    cell=5Gcell@{cell_id}[2]    value=@{multi_gnb_PA}[1]
#    Change Attenuation value    cell=5Gcell@{cell_id}[3]    value=@{multi_gnb_PA}[1]
#    Run Keyword And Continue On Failure    CI_interface.Common Case Teardown

DA Case Prerequisite
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


DA Case Step 1 UE0 attach on pcell
    comment    step1: UE0 attach on pcell
    CB0012149_common_KW.Prepare UE For MTK80    ue_index=${1}    cap_index=${0}
    Change Attenuation value    cell=5Gcell${cell_id}[3]    value=${multi_gnb_PA_348}[3]
    Start capture gNB log on master    filename=${log_name_DA_IWK_1}
    CB0012149_common_KW.Do UE Attach    ue_index=${1}
    CB0012149_common_KW.Verify UE Attach Success
    sleep    30s
    Change Attenuation value    cell=5Gcell${cell_id}[3]    value=${multi_gnb_PA_348}[0]
    [Teardown]    Stop and download Logs on gNB on master    filename=${log_name_DA_IWK_1}

DA Case Step 2 UE0 make traffic
#    [Arguments]    ${puschMappingType}=TypeA
#    comment    step2: make CA DL/UL Peak Tput
    Run Keyword And Continue On Failure    Check wireshark log for 12149 DA Case    pcap_file=${log_name_DA_IWK_1}
    ##Run Keyword And Continue On Failure     check UL switchedUl scell additon successful on wireshark
##    ...     puschMappingType=${puschMappingType}
    ##Run Keyword And Continue On Failure     Tear down the all connections
    Start capture gNB log on master    filename=${log_name_DA_IWK_2}
#    Start both DL UL traffic and check tput    ue_index=${1}   ue_type=${ue2_type}    dl_throughput=${Send_Tput_DL}    pcellid=${2}
#    ...    gnb_index=${0}    ul_throughput=${Send_Tput_UL}     tput_ul_cell=${expected_tput_ul}    ul_port=${UL_PORT_K01}
#    ...    tput_dl_cell=${expected_tput_dl}
#    ...      protocol=udp      dl_port=${DL_PORT_K01}          duration=${7200}     scellid=${3}
    Start both DL UL traffic and check tput    ue_index=${1}   ue_type=${ue2_type}    dl_throughput=${Send_Tput_DL}
    ...    gnb_index=${0}    ul_throughput=${Send_Tput_UL}     tput_ul_cell=${expected_tput_ul}    ul_port=${UL_PORT_K01}
    ...    tput_dl_cell=${expected_tput_dl}
    ...      dl_port=${DL_PORT_K01}          duration=${7200}
    [Teardown]     Stop and download Logs on gNB on master    filename=${log_name_DA_IWK_2}

DA IWK8 Case Step 2 UE0 make traffic
#    [Arguments]    ${puschMappingType}=TypeA
#    comment    step2: make CA DL/UL Peak Tput
    Run Keyword And Continue On Failure    Check wireshark log for 12149 DA Case    pcap_file=${log_name_DA_IWK_1}
    ##Run Keyword And Continue On Failure     check UL switchedUl scell additon successful on wireshark for IWK8
##    ...     puschMappingType=${puschMappingType}
    ##Run Keyword And Continue On Failure     Tear down the all connections
    Start capture gNB log on master    filename=${log_name_DA_IWK_2}
    Connect to control pc via cygwin    ue_index=${ue_index}
    Get Commercial UE IP with first UE    ue_index=${ue_index}
    mtk m80 make traffic    direction=UL    ue_index=${ue_index}
    ...    ul_throughput=${Send_Tput_UL}    duration=${7200}    ul_port=${ul_port}
    sleep    80s
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    ${nrcellid_cell}    Create list  ${nrcellid_pcell}    ${nrcellid_scell}
    Check single direction throughput     ue_index=${ue_index}    ue_type=${ue_type}    direction=UL   list_of_cell_ids=${nrcellid_cell}
    ...    expect_throughput=${expected_tput_ul}    gnb_index=${gnb_index}
    [Teardown]     Stop and download Logs on gNB on master    filename=${log_name_DA_IWK_2}

DA Case Step 3 UE0 make 6688 voice call and compare the DL UL Peak Tput
#    comment    Step 3 UE0 make 6688 voice call
    Start capture gNB log on master    filename=${log_name_DA_IWK_3}
    Make a VoNR call(+6688)    ue_index=${ue_index}
#    ${dl_expected_throughput_pcell}    ${ul_expected_throughput_pcell}=    get_expect_throughput
#    ...    tl_scf_dir_path=${tl_scf_dir_path}    tl_scf_file_name=${golden_scf_name}    cell_id=${2}
#    ${dl_expected_throughput_scell}    ${ul_expected_throughput_scell}=    get_expect_throughput
#    ...    tl_scf_dir_path=${tl_scf_dir_path}    tl_scf_file_name=${golden_scf_name}    cell_id=${3}
#    check intra gnb ca throughput    scellid=${3}    pcellid=${2}    gnb_prime=${0}    gnb_external=${0}
#    ...    tput_ul_pcell=${ul_expected_throughput_pcell}    tput_ul_scell=${ul_expected_throughput_scell}
#    ...    time=300s
    [Teardown]     Stop and download Logs on gNB on master    filename=${log_name_DA_IWK_3}

DA Case Step 3 Check CA DL UL Peak Tput
    ${dl_expected_throughput_pcell}    ${ul_expected_throughput_pcell}=    get_expect_throughput
    ...    tl_scf_dir_path=${tl_scf_dir_path}    tl_scf_file_name=${golden_scf_name}    cell_id=${2}
    ${dl_expected_throughput_scell}    ${ul_expected_throughput_scell}=    get_expect_throughput
    ...    tl_scf_dir_path=${tl_scf_dir_path}    tl_scf_file_name=${golden_scf_name}    cell_id=${3}
    check intra gnb ca throughput    scellid=${3}    pcellid=${2}    gnb_prime=${0}    gnb_external=${0}
    ...    tput_ul_pcell=${ul_expected_throughput_pcell}    tput_ul_scell=${ul_expected_throughput_scell}
    ...    time=300s

DA Case Step 4 check logs on wireshark and TTI
#    comment    step4: logs on wireshark and TTI
    upgrade gnb logs tool on VM    tool_download_path=${tool_path}
    to capture logs via gnb_logs tool    option=-C 2,3 -t    tool_download_path=${tool_path}    duration=5
    sleep    20s

DA Case Teardown
    robot_common_operations.Common Case Teardown
    AlarmWatchdog.remove_allow_alarms    fault_id=2922
    AlarmWatchdog.remove_allow_alarms    fault_id=2923
#    Stop DL or UL traffic    ue_index=${1}    ue_type=${ue2_type}    direction=DL
    Stop DL or UL traffic    ue_index=${1}    direction=DL
#    Stop DL or UL traffic    ue_index=${1}    ue_type=${ue2_type}    direction=UL
    Stop DL or UL traffic    ue_index=${1}    direction=UL
    ###Run Keyword And Continue On Failure    CB0012149_common_KW.Do UE Detach    ue_index=${1}
    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
    Run Keyword And Continue On Failure     Tear down the all connections
    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    get gnb snapshot

DA IWK8 Case Teardown
    robot_common_operations.Common Case Teardown
    Run Keyword And Continue On Failure     hang up VoNR call    ue_index=${1}
#    Stop DL or UL traffic    ue_index=${1}    ue_type=${ue2_type}    direction=DL
    Stop DL or UL traffic    ue_index=${1}    direction=DL
#    Stop DL or UL traffic    ue_index=${1}    ue_type=${ue2_type}    direction=UL
    Stop DL or UL traffic    ue_index=${1}    direction=UL
    ###Run Keyword And Continue On Failure    CB0012149_common_KW.Do UE Detach    ue_index=${1}
    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
    Run Keyword And Continue On Failure     Tear down the all connections
    #hang up VoNR call    ue_index=${1}
    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run Keyword And Continue On Failure    get gnb snapshot
#    Change Attenuation value    cell=5Gcell@{cell_id}[2]    value=@{multi_gnb_PA}[1]
#    Change Attenuation value    cell=5Gcell@{cell_id}[3]    value=@{multi_gnb_PA}[1]
#    Run Keyword And Continue On Failure    CI_interface.Common Case Teardown

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
    ${drx_onDurationTimer1}=    Check wireshark log for 12149 DA IWK8_drx_onDurationTimer     pcap_file=${log_name_DA_IWK_1}
    ${drx_onDurationTimer2}=    Check wireshark log for 12149 DA IWK8_drx_onDurationTimer     pcap_file=${log_name_DA_IWK_3}
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

Check wireshark log for 12149 DA Case
    [Arguments]     ${pcap_file}
    Comment    check wireshark log for 12149 DA Case
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${pcap_file}
    Run Keyword And Continue On Failure     check CB012149 UERadioCapabilityInfoIndication on wireshark
    ${c_rnti}=    Get RNTI-ID message    logname=${pcap_file}
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
    Should Contain    ${supportedBandCombinationList_1}    1
    Should Contain    ${supportedBandCombinationList_1}    78
    ${length}=    Get Length    ${supportedBandCombinationList_1}
    Should Be Equal As Integers    ${length}    4
    Should Be Equal    ${supportedBandCombinationList_2}[0]    0
    Should Be Equal    ${supportedBandCombinationList_2}[1]    1
    Should Be Equal    ${supportedBandCombinationList_2}[2]    0
    Should Be Equal    ${supportedBandCombinationList_2}[3]    2
    ${length}=    Get Length    ${supportedBandCombinationList_2}
    Should Be Equal As Integers    ${length}    4
    Should Be Equal    ${supportedBandCombinationList_3}[0]    0
    Should Be Equal    ${supportedBandCombinationList_3}[1]    0
    Should Be Equal    ${supportedBandCombinationList_3}[2]    0
    Should Be Equal    ${supportedBandCombinationList_3}[3]    0
    ${length}=    Get Length    ${supportedBandCombinationList_3}
    Should Be Equal As Integers    ${length}    4
    ${uplinkTxSwitching_OptionSupport_r16}=    cap.Get Field Value By Xpath    pdml_list=${UERadioCapabilityInfoIndication_packets}
    ...    xpath=.//nr-rrc.uplinkTxSwitching_OptionSupport_r16
    Should Be Equal    ${uplinkTxSwitching_OptionSupport_r16}[0]    0

check UL switchedUl scell additon successful on wireshark
    [Arguments]    ${puschMappingType}=TypeA
    ${physCellId}=    get required value of parameter    Abbreviation=physCellId    gnb_index=${0}    distname_id=${3}
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
    [Arguments]     ${pcell}=${2}    ${scell}=${3}
    check counters for scell active success on pcell    KPI_file=CB012149_BC_scell_active_success_KPI.txt    para_index=${pcell}
    check counters for scell active success on scell    KPI_file=CB012149_BC_scell_active_success_KPI.txt    para_index=${scell}

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

check value on TTI file DA Case
    [Arguments]    ${file_path}    ${queried_filed}    ${check_point}=BASICRELIABILITY
    ${required_data_list}=    get_value_from_csv_file    file_path=${file_path}    queried_filed=${queried_filed}
    ${no_duplicates_required_data_list}    Remove Duplicates    ${required_data_list}
    ${length}    Get Length    ${no_duplicates_required_data_list}
    should be equal    ${no_duplicates_required_data_list}[0]    ${check_point}
    Should Be Equal As Integers    ${length}    1

DA Case Step 4 check counters
    comment    step5: check counters
    Prepare with PM counter time to caculate    period=start
    sleep    6min    reason=check KPIs after make traffic during 5mins and xml report generated 1min
    Run Keyword And Continue On Failure    check counters for scell active success on pcell and scell

DA Case Step 4 check IWK6 swap counters
    comment    step5: check counters
    Prepare with PM counter time to caculate    period=start
    sleep    6min    reason=check KPIs after make traffic during 5mins and xml report generated 1min
    Run Keyword And Continue On Failure    check counters for scell active success on pcell and scell    pcell=${2}    scell=${4}

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

DA IWK8_Case Step 4 check counters
    comment    DA IWK8_Case Step 4 check counters
    Prepare with PM counter time to caculate    period=start
    sleep     60s
    Run Keyword And Continue On Failure    check counters for SCell deactivation due to PUSCH slot aggregation on scell
    ...    KPI_file=CB012149_DA_IWK8_R16_UL_Tx_Switching_UE_interworking_with_CB008236.txt    para_index=${3}

DA Case Step 5 check logs on TTI
    comment    step5: check logs on TTI
#    upgrade gnb logs tool on VM    tool_download_path=${tool_path}
    to capture logs via gnb_logs tool    option=-C 2,3 -t    tool_download_path=${tool_path}    duration=5
    sleep    20s
    ${physCellId}=    get required value of parameter    Abbreviation=physCellId    gnb_index=${0}    distname_id=${2}
    RUN KEYWORD IF    ${enb_instance} == ${enb_id}[0]     #TL348
    ...      set test variable    ${nrcellid_pcell}     ${nrcellid_cell1}
    ${log_files}    ${folder_name}    get logs from gnb_logs folder from v2.67    tool_download_path=${tool_path}
    ...    nrCellIdentity=${nrcellid_pcell}
    ${file_name}    get_required_tti_file_name    files_list=${log_files}    required_file_name=ul__all.csv
    ${slot_1_6}    ${slot_3_8}=    check_required_filed_data
    ...    filename=${epc_log_path}/${folder_name}/${file_name}    c_rnti=${c_rnti}    physCellId=${physCellId}
    #Should Be True    condition=${slot_1_6}>0    msg=no satisfied data in slot 1 or slot 6
    #Should Be True    condition=${slot_3_8}>0    msg=no satisfied data in slot 3 or slot 8
    # need to modify below keyword
    check value on TTI file DA    file_path=${epc_log_path}/${folder_name}/${file_name}    queried_filed=laMode
    ...    check_point=BASICRELIABILITY

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
    ...    ${time}=30s
    Check_throughput with CA     tput_dl_pcell=${tput_dl_pcell}    tput_dl_scell=${tput_dl_scell}    tput_ul_pcell=${tput_ul_pcell}
    ...    tput_ul_scell=${tput_ul_scell}    scellid=${scellid}    pcellid=${pcellid}
    ...    gnb_prime=${gnb_prime}    gnb_external=${gnb_external}    duration=${time}
