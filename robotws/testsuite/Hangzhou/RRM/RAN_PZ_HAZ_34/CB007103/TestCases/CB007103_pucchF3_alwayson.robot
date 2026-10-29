*** Settings ***
Documentation      Author: jia-rebecca.liu@nokia-sbell.com
...                squad group: VRFT03
...                feature : CB007103


Suite Setup         Run keyword    7103 Suite Setup
...                                                    ModifySCF_Beforecommission=True
...                                                    ParamterToModify=${MODIFY_PARA_PucchF3_alwayson}
...                                                    ListParamterToModify=${MODIFY_LIST_PucchF3_alwayson}

Suite Teardown      Run keyword    7103 Suite TearDown

Resource          ../Resources/CB007103_common_keywords.robot


*** Variables ***
####-----log name-----####
${B1_001_wireshark_01}     B1_001_wireshark_attach_01
${B1_001_wireshark_02}     B1_001_wireshark_attach_02
${B1_001_wireshark_03}     B1_001_wireshark_attach_03
${B1_001_wireshark_04}     B1_001_wireshark_attach_04
${debug_bad_point}         B1_001_debug_bad_point_01
${C1_001_wireshark_01}     C1_001_wireshark_01
${C1_001_wireshark_02}     C1_001_wireshark_02
${C1_001_wireshark_03}     C1_001_wireshark_03
${C1_001_wireshark_04}     C1_001_wireshark_04
${C2_001_wireshark_01}     C2_001_wireshark_01
${C2_001_wireshark_02}     C2_001_wireshark_02
${C2_001_wireshark_03}     C2_001_wireshark_03
${C2_001_wireshark_04}     C2_001_wireshark_04

*** Test Cases ***
#[1]CB007103-B#1_001_Performance_comparison_between_Rel16_and_Rel15_DMRS_for_PUCCHF3_when_pucchF3ModulationScheme_qpsk_4psk
#    [Documentation]
#    ...    This user scenario describes DMRS configuration for PUCCH F3 in the case when:
#    ...    • QPSK is configured in NIDD (NIDD NRCELL.pucchF3ModulationScheme = qpsk_4psk) for PUCCH F3
#    ...    • pi/2-BPSK and Rel16 DMRS is always switched on for PUCCH F3 by NIDD parameter NRCELL.pucchF3Rel16Pi2BpskAlwaysOn is TRUE.
#    ...    • UE is using Rel15 DMRS for PUCCH F3
#    ...    In this case:
#    ...    • regardless of whether TP is on or off for PUSCH: pi/2 BPSK, TP (DFT-S-OFDM) is used for PUCCH F3 together with maxCR1 (see Note 1) and
#    ...      with the fixed number of PRBs, Rel16 DMRS and pi/2-BPSK Power Boosting
#    ...    • there is no PUCCH F3 reconfiguration in the case of switch between no-TP and TP for PUSCH (no transient phase handling)
#    [Tags]    B1001
#    [Setup]
#    7103 Case SetUp    ModifySCF_Aftercommission=True
#    ...                Modify_Para_Online=${Online_Modify_B1001_casesetup}
#    B1001_Step1_attach_and_capture_wireshark_log    wiresharklog=${B1_001_wireshark_01}
#    B1001_Step2_start_traffic_change_to_bad
#    B1001_Step3_online_enable_dmrspucchF3r16
#    B1001_Step4_attach_and_capture_wireshark_log    wiresharklog=${B1_001_wireshark_02}
#    B1001_Step5_start_traffic_change_to_bad
#    B1001_Step6_check_logs
#    [Teardown]    7103 Case TearDown
#
#
#
#[1]CB007103-C#1_001_Performance_comparison_between_Rel16_and_Rel15_DMRS_for_PUSCH_PUCCHF3_when_pucchF3ModulationScheme_qpsk_4psk
#    [Documentation]
#    ...    This case test the Rel15 and Rel16 DMRS switch with pucchF3ModulationScheme = qpsk_4psk and pucchF3Rel16Pi2BpskAlwaysOn = FALSE settings
#    ...    due to radio conditions change.
#    ...    Check ul tput with 1M. cover B1001
#    [Tags]    C1001
#    [Setup]
#    7103 Case SetUp
#    ...                ModifySCF_Aftercommission=True
#    ...                Modify_Para_Online=${ONLINE_MODIFY_C1001_1}
#    C1001_Step1_attach_and_capture_wiresharklog
#    ${wireshark_logpath_C1001_02}    C1001_Step2_start_uldl_traffic_and change_to_bad_piont_when_Rel16Dmrs_disable
#    BuiltIn.Set Test Variable    ${wireshark_logpath_C1001_02}
#    C1001_Step3_enable_Rel16Dmrs_online
#    C1001_Step4_attach_and_capture_wiresharklog
#    ${wireshark_logpath_C1001_04}    C1001_Step5_start_uldl_traffic_and change_to_bad_piont_when_Rel16Dmrs_enable
#    BuiltIn.Set Test Variable    ${wireshark_logpath_C1001_04}
#    C1001_Checkpoint
#    [Teardown]    7103 Case TearDown


[1]CB007103-C#2_001_Performance_comparison_between_Rel16_and_Rel15_DMRS_for_PUSCH_PUCCHF3_when_pucchF3ModulationScheme_pi2-BPSK
    [Documentation]
    ...    This user scenario describes DMRS configuration for PUSCH and PUCCH F3 in the case when:
    ...    pi/2-BPSK is configured in NIDD (NIDD NRCELL.pucchF3ModulationScheme = pi2bpsk) for PUCCH F3
    ...    pi/0. NRCELL.pucchF3Rel16Pi2BpskAlwaysOn is TRUE
    ...    UE is using Rel15 DMRS for PUSCH and PUCCH F3
    ...    In this case:
    ...    regardless of whether TP is on or off for PUSCH: pi/2 BPSK, TP (DFT-S-OFDM) is used for PUCCH F3 together with maxCR1 (see Note 1) and
    ...    with the fixed number of PRBs, Rel16 DMRS and pi/2-BPSK Power Boosting
    ...    there is no PUCCH F3 reconfiguration in the case of switch between no-TP and TP for PUSCH (no transient phase handling)
    ...    UL traffic 100k, check bler/ibler counter
    [Tags]    C2001
    [Setup]
    7103 Case SetUp    ModifySCF_Aftercommission=True
    ...                Modify_Para_Online=${Online_MODIFY_C2001}
    C2001_Step1_attach_and_capture_wiresharklog
    ${wireshark_logpath_C2001_02}    C2001_Step2_start_uldl_traffic_and change_to_bad_piont_when_Rel16Dmrs_disable
    BuiltIn.Set Test Variable    ${wireshark_logpath_C2001_02}
    C2001_Step3_enable_Rel16Dmrs_online
    C2001_Step4_attach_and_capture_wiresharklog
    ${wireshark_logpath_C2001_04}    C2001_Step5_start_uldl_traffic_and change_to_bad_piont_when_Rel16Dmrs_enable
    BuiltIn.Set Test Variable    ${wireshark_logpath_C2001_04}
    C2001_Checkpoint
    [Teardown]    7103 Case TearDown



*** Keywords ***
#----------------------b1001------------------------#
B1001_Step1_attach_and_capture_wireshark_log
    [Arguments]    ${wiresharklog}
    ${wireshark_logpath_B1001_01}    Attach UE and Capture wireshark for MTK80    wiresharklog=${wiresharklog}
    BuiltIn.Set Test Variable    ${wireshark_logpath_B1001_01}

B1001_Step2_start_traffic_change_to_bad
    [Arguments]    ${att_value_bad}=${80}
    Start DL traffic for MTK80    get_ip_from_cpif=${wireshark_logpath_B1001_01}
    Adjust the HBTE attenuation value for MTK80        gnb_cell3_value=${att_value_bad}
    Start Capture CP-IF logs from Container     tcpdump_collector_name=${B1_001_wireshark_03}
    Prepare counter time caculate    period=start
    sleep    5min
    [Teardown]    Run Keywords
    ...    Stop CP-IF log Collection    tcpdump_collector_name=${B1_001_wireshark_03}    target_dir=${epc_log_path}   AND
    ...    Prepare to caculate PM counter    period=end    AND
    ...    Stop DL traffic only    AND
    ...    Detach MTK80    AND
    ...    Adjust the HBTE attenuation value for MTK80        gnb_cell3_value=${25}

B1001_Step3_online_enable_dmrspucchF3r16
    change_parameter_online     Modify_Para_Online=${Online_Modify_B1001}

B1001_Step4_attach_and_capture_wireshark_log
    [Arguments]    ${wiresharklog}
    ${wireshark_logpath_B1001_02}    Attach UE and Capture wireshark for MTK80    wiresharklog=${wiresharklog}
    BuiltIn.Set Test Variable    ${wireshark_logpath_B1001_02}

B1001_Step5_start_traffic_change_to_bad
    [Arguments]    ${att_value_bad}=${80}
    Start DL traffic for MTK80    get_ip_from_cpif=${wireshark_logpath_B1001_02}
    Start Capture CP-IF logs from Container     tcpdump_collector_name=${B1_001_wireshark_04}
    Adjust the HBTE attenuation value for MTK80        gnb_cell3_value=${att_value_bad}
    Prepare counter time caculate    period=start
    sleep    5min
    [Teardown]    Run Keywords
    ...    Stop CP-IF log Collection    tcpdump_collector_name=${B1_001_wireshark_04}    target_dir=${epc_log_path}   AND
    ...    Prepare to caculate PM counter    period=end    AND
    ...    Stop DL traffic only    AND
    ...    Detach MTK80

B1001_Step6_check_logs

    Log to console    /n*** check wiresharklog_01 ***/n
    ${maxCodeRate_1}    Get PucchF3_maxcoderate From rrc_setup   file_path=${wireshark_logpath_B1001_01}
    should be true     '${maxCodeRate_1}' == 'zeroDot15'
    ${dmrs_Pucch_r16_IE_1}    run keyword and return status    Get dmrs_Pucch_r16_IE From rrc_reg    file_path=${wireshark_logpath_B1001_01}
    should be true     '${dmrs_Pucch_r16_IE_1}' == 'False'

    Log to console    /n*** check wiresharklog_02 ***/n
    ${dmrs_Pucch_r16_IE_2}    Get dmrs_Pucch_r16_IE From rrc_reg   file_path=${wireshark_logpath_B1001_02}
    should be true     '${dmrs_Pucch_r16_IE_2}' == '${0}'
    ${pi2BPSK_pucchF3}    Get pi2BPSK_pucchF3 From rrc_reg    file_path=${wireshark_logpath_B1001_02}
    should be true     '${pi2BPSK_pucchF3}' == '${0}'


#----------------------c1001------------------------#
C1001_Step1_attach_and_capture_wiresharklog
    ${wireshark_logpath_C1001_01}    Attach UE and Capture wireshark for MTK80    wiresharklog=${C1_001_wireshark_01}
    BuiltIn.Set Test Variable     ${wireshark_logpath_C1001_01}

C1001_Step2_start_uldl_traffic_and change_to_bad_piont_when_Rel16Dmrs_disable
    [Arguments]
    ...            ${att_value_bad}=${84}
    Start DL and UL traffic for MTK80    get_ip_from_cpif=${wireshark_logpath_C1001_01}
    Prepare to caculate PM counter       period=start
    Start Capture CP-IF logs from Container     tcpdump_collector_name=${C1_001_wireshark_02}
    Adjust the HBTE attenuation value for MTK80        gnb_cell3_value=${att_value_bad}
    sleep    120
    ${C1001_tput_avg_ul_1}     Check tput for MTK80
    ${C1001_tput_avg_dl_1}     Check tput for MTK80    direction=DL
    ${C1001_biplog_path_disable}    Collect Biplog on WEBUI for MTK80     target_dir=${epc_log_path}      target_file_name=C1001_biplog_disable
    BuiltIn.Set Test Variable     ${C1001_tput_avg_ul_1}
    BuiltIn.Set Test Variable     ${C1001_tput_avg_dl_1}
    [Teardown]    Run Keywords
    ...    Prepare to caculate PM counter    period=end    AND
    ...    Stop CP-IF log Collection    tcpdump_collector_name=${C1_001_wireshark_02}    target_dir=${epc_log_path}   AND
    ...    Stop DL and UL traffic for MTK80    AND
    ...    Detach MTK80    AND
    ...    Adjust the HBTE attenuation value for MTK80        gnb_cell3_value=${25}
    [Return]    ${cpif_log_path}

C1001_Step3_enable_Rel16Dmrs_online
    change_parameter_online     Modify_Para_Online=${ONLINE_MODIFY_C1001_2}

C1001_Step4_attach_and_capture_wiresharklog
    ${wireshark_logpath_C1001_03}    Attach UE and Capture wireshark for MTK80    wiresharklog=${C1_001_wireshark_03}
    BuiltIn.Set Test Variable     ${wireshark_logpath_C1001_03}

C1001_Step5_start_uldl_traffic_and change_to_bad_piont_when_Rel16Dmrs_enable
    [Arguments]
    ...            ${att_value_bad}=${84}
    Start DL and UL traffic for MTK80    get_ip_from_cpif=${wireshark_logpath_C1001_03}
    Prepare to caculate PM counter       period=start
    Start Capture CP-IF logs from Container     tcpdump_collector_name=${C1_001_wireshark_04}
    Adjust the HBTE attenuation value for MTK80        gnb_cell3_value=${att_value_bad}
    sleep    120
    ${C1001_tput_avg_ul_2}     Check tput for MTK80
    ${C1001_tput_avg_dl_2}     Check tput for MTK80    direction=DL
    ${C1001_biplog_path}    Collect Biplog on WEBUI for MTK80     target_dir=${epc_log_path}     target_file_name=C1001_biplog_enable
    BuiltIn.Set Test Variable     ${C1001_biplog_path}
    BuiltIn.Set Test Variable     ${C1001_tput_avg_ul_2}
    BuiltIn.Set Test Variable     ${C1001_tput_avg_dl_2}
    [Teardown]    Run Keywords
    ...    Prepare to caculate PM counter    period=end    AND
    ...    Stop CP-IF log Collection    tcpdump_collector_name=${C1_001_wireshark_04}    target_dir=${epc_log_path}
    ...    AND     Stop DL and UL traffic for MTK80
    ...    AND     Detach MTK80
    ...    AND     Adjust the HBTE attenuation value for MTK80        gnb_cell3_value=${25}
    [Return]    ${cpif_log_path}

C1001_Checkpoint
    Log to console    /n*** compare tput_avg_1 and tput_avg_2 ***/n
    run keyword and continue on failure     should be true    ${C1001_tput_avg_ul_1} <= ${C1001_tput_avg_ul_2}
    run keyword and continue on failure     should be true    ${C1001_tput_avg_dl_1} <= ${C1001_tput_avg_dl_2}

    Log to console    /n*** check wiresharklog_01 ***/n
    ${maxCodeRate_C1001_01}          Get PucchF3_maxcoderate From rrc_setup    file_path=${wireshark_logpath_C1001_01}
    run keyword and continue on failure     should be true     '${maxCodeRate_C1001_01}' == 'zeroDot15'
    ${transformPrecoder_C1001_01}    Get transformPrecoder From rrc_setup      file_path=${wireshark_logpath_C1001_01}
    run keyword and continue on failure     should be true     '${transformPrecoder_C1001_01}' == '1'
    ${dmrs_Pucch_r16_IE_C1001_01}    run keyword and return status    Get dmrs_Pucch_r16_IE From rrc_reg    file_path=${wireshark_logpath_C1001_01}
    run keyword and continue on failure     should be true     '${dmrs_Pucch_r16_IE_C1001_01}' == 'False'

    Log to console    /n*** check wiresharklog_02 ***/n
    ${transformPrecoder_C1001_02}    Get transformPrecoder From rrc_reg      file_path=${wireshark_logpath_C1001_02}
    run keyword and continue on failure     should be true     '${transformPrecoder_C1001_02}' == '0'
    ${tp_pi2BPSK_pusch_C1001_02}     Get tp_pi2BPSK_pusch From rrc_reg     file_path=${wireshark_logpath_C1001_02}
    run keyword and continue on failure     should be true     '${tp_pi2BPSK_pusch_C1001_02}' == '0'

    Log to console    /n*** check wiresharklog_03 ***/n
    ${maxCodeRate_C1001_03}          Get PucchF3_maxcoderate From rrc_setup    file_path=${wireshark_logpath_C1001_03}
    run keyword and continue on failure     should be true     '${maxCodeRate_C1001_03}' == 'zeroDot15'
    ${transformPrecoder_C1001_03}    Get transformPrecoder From rrc_setup      file_path=${wireshark_logpath_C1001_03}
    run keyword and continue on failure     should be true     '${transformPrecoder_C1001_03}' == '1'
    ${pi2BPSK_pucchF3_C1001_03}      Get pi2BPSK_pucchF3 From rrc_reg       file_path=${wireshark_logpath_C1001_03}
    run keyword and continue on failure     should be true     '${pi2BPSK_pucchF3_C1001_03}' == '0'
    ${dmrs_Pucch_r16_IE_C1001_03}    run keyword and return status    Get dmrs_Pucch_r16_IE From rrc_reg    file_path=${wireshark_logpath_C1001_03}
    run keyword and continue on failure     should be true     '${dmrs_Pucch_r16_IE_C1001_03}' == 'True'
    ${tp_pi2BPSK_pusch_C1001_03}     Get tp_pi2BPSK_pusch From rrc_reg     file_path=${wireshark_logpath_C1001_03}
    run keyword and continue on failure     should be true     '${tp_pi2BPSK_pusch_C1001_03}' == '0'
    ${dmrs_Pusch_r16_IE_C1001_03}    Get dmrs_Pusch_r16_IE From rrc_reg    file_path=${wireshark_logpath_C1001_03}
    run keyword and continue on failure     should be true     '${dmrs_Pusch_r16_IE_C1001_03}' == '1'

    Log to console    /n*** check wiresharklog_04 ***/n
    ${transformPrecoder_C1001_04}    Get transformPrecoder From rrc_reg      file_path=${wireshark_logpath_C1001_04}
    run keyword and continue on failure     should be true     '${transformPrecoder_C1001_04}' == '0'
    ${tp_pi2BPSK_pusch_C1001_04}     Get tp_pi2BPSK_pusch From rrc_reg     file_path=${wireshark_logpath_C1001_04}
    run keyword and continue on failure     should be true     '${tp_pi2BPSK_pusch_C1001_04}' == '0'

    Log to console    /n*** check when MCS=0/1 DMRStype is TYPE_2 in biplog ***/n
    ${dmrsSequenceType_pusch_C1001}    Get dmrsSequenceType From BIP when mcs_low    file_path=${C1001_biplog_path}
    run keyword and continue on failure     should be true    '${dmrsSequenceType_pusch_C1001}' == '${1}'

#----------------------c2001------------------------#
C2001_Step1_attach_and_capture_wiresharklog
    ${wireshark_logpath_C2001_01}    Attach UE and Capture wireshark for MTK80    wiresharklog=${C2_001_wireshark_01}
    BuiltIn.Set Test Variable     ${wireshark_logpath_C2001_01}

C2001_Step2_start_uldl_traffic_and change_to_bad_piont_when_Rel16Dmrs_disable
    [Arguments]
    ...            ${att_value_bad}=${80}
    Start DL and UL traffic for MTK80    get_ip_from_cpif=${wireshark_logpath_C2001_01}    ul_throughput=100k
    ${C2001_time1_start}     Get current date    result_format=%Y%m%d%H%M%S    time_zone=UTC
    Prepare to caculate PM counter       period=start
    Start Capture CP-IF logs from Container     tcpdump_collector_name=${C2_001_wireshark_02}
    Adjust the HBTE attenuation value for MTK80        gnb_cell3_value=${att_value_bad}
    sleep     2min
    run keyword and continue on failure    Check tput for MTK80
    sleep     4min
    Prepare to caculate PM counter    period=end
    ${C2001_time1_end}    Get current date    result_format=%Y%m%d%H%M%S    time_zone=UTC
    [Teardown]    Run Keywords
    ...    Stop CP-IF log Collection    tcpdump_collector_name=${C2_001_wireshark_02}    target_dir=${epc_log_path}   AND
    ...    Stop DL and UL traffic for MTK80    AND
    ...    Detach MTK80
    ...    AND    C2001_counter_check    value_M55165C00037=${0}    value_M55165C00038=${300}    value_M55370C00033=${0}    value_M55370C00037=${0}
    ...    AND    C2001_KPI_value     test_start=${C2001_time1_start}     test_end=${C2001_time1_end}     folder_name=C2001_STEP2
    ...    AND     Adjust the HBTE attenuation value for MTK80        gnb_cell3_value=${25}
    [Return]    ${cpif_log_path}

C2001_Step3_enable_Rel16Dmrs_online
    change_parameter_online     Modify_Para_Online=${ONLINE_MODIFY_C2001_2}

C2001_Step4_attach_and_capture_wiresharklog
    Adjust the HBTE attenuation value for MTK80        gnb_cell3_value=${35}
    ${wireshark_logpath_C2001_03}    Attach UE and Capture wireshark for MTK80    wiresharklog=${C2_001_wireshark_03}
    BuiltIn.Set Test Variable     ${wireshark_logpath_C2001_03}

C2001_Step5_start_uldl_traffic_and change_to_bad_piont_when_Rel16Dmrs_enable
    [Arguments]
    ...            ${att_value_bad}=${80}
    Start DL and UL traffic for MTK80    get_ip_from_cpif=${wireshark_logpath_C2001_03}    ul_throughput=100k
    ${C2001_time2_start}    Get current date    result_format=%Y%m%d%H%M%S    time_zone=UTC
    Prepare to caculate PM counter       period=start
    Start Capture CP-IF logs from Container     tcpdump_collector_name=${C2_001_wireshark_04}
    Adjust the HBTE attenuation value for MTK80        gnb_cell3_value=${att_value_bad}
    ${C2001_biplog_path}    Collect Biplog on WEBUI for MTK80     target_dir=${epc_log_path}     Capture_bip_time=120s
    ...                                                           target_file_name=C2001_biplog
    BuiltIn.Set Test Variable     ${C2001_biplog_path}
    run keyword and continue on failure    Check tput for MTK80
    sleep     4min
    Prepare to caculate PM counter    period=end
    ${C2001_time2_end}    Get current date    result_format=%Y%m%d%H%M%S    time_zone=UTC
    [Teardown]    Run Keywords
    ...    Stop CP-IF log Collection    tcpdump_collector_name=${C2_001_wireshark_04}    target_dir=${epc_log_path}
    ...    AND     Stop DL and UL traffic for MTK80
    ...    AND     Detach MTK80
    ...    AND     run keyword and continue on failure    C2001_counter_check    value_M55165C00037=${300}    value_M55165C00038=${300}
    ...                                   value_M55370C00033=${500}    value_M55370C00037=${0}
    ...    AND     C2001_KPI_value    test_start=${C2001_time2_start}    test_end=${C2001_time2_end}    folder_name=C2001_STEP5
    ...    AND     Adjust the HBTE attenuation value for MTK80        gnb_cell3_value=${25}
    [Return]    ${cpif_log_path}

C2001_Checkpoint

    Log to console    /n*** check when MCS=0/1 DMRStype is TYPE_2 in biplog ***/n
    ${dmrsSequenceType_pucch_C2001}    Get dmrsSequenceType From BIP when mcs_low for trunk    file_path=${C2001_biplog_path}
    ...                                                                                        bip_filter=uldata_pucchreceivereql1sw
    run keyword and continue on failure    should be true    '${dmrsSequenceType_pucch_C2001}' == '${1}'


C2001_counter_check
    [Arguments]    ${value_M55165C00037}    ${value_M55165C00038}    ${value_M55370C00033}    ${value_M55370C00037}
    ...     ${counter_id}=${counter_id_b34001}
    ...     ${dic_path}=${counter_dic_path_b34001}
    ${counter_value}    Get the PM counter    counter_id=${counter_id}   dic_path=${dic_path}    timeout=300
    run keyword and continue on failure    should be true    ${counter_value[0]} == ${value_M55165C00037}
    run keyword and continue on failure    should be true    ${counter_value[1]} == ${value_M55165C00038}
    run keyword and continue on failure    should be true    ${counter_value[2]} >= ${value_M55370C00033}
    run keyword and continue on failure    should be true    ${counter_value[3]} >= ${value_M55370C00037}

C2001_KPI_value
    [Arguments]    ${test_start}    ${test_end}    ${folder_name}
    ${kpi_value_dict}      Get_KPI_value_from_pm_file                test_start=${test_start}
    ...                                                              test_end=${test_end}
    ...                                                              folder_name=${folder_name}
    BuiltIn.Set Test Variable    ${NR_1237_value}    ${kpi_value_dict}[NR_1237]
    BuiltIn.Set Test Variable    ${NR_5056_value}    ${kpi_value_dict}[NR_5056]
    BuiltIn.Set Test Variable    ${NR_5057_value}    ${kpi_value_dict}[NR_5057]
    BuiltIn.Set Test Variable    ${DFTsOFDM_for_MCS0_and_MCS1_value}     ${kpi_value_dict}[DFTsOFDM_for_MCS0_and_MCS1]
    [Return]    ${NR_1237_value}    ${NR_5056_value}    ${NR_5057_value}    ${DFTsOFDM_for_MCS0_and_MCS1_value}
