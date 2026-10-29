*** Settings ***
Documentation      Author: jia-rebecca.liu@nokia-sbell.com
...                squad group: VRFT03
...                feature : CB007103


Suite Setup         Run keyword    7103 Suite Setup
...                                                    ModifySCF_Beforecommission=True
...                                                    ParamterToModify=${MODIFY_PARA_PucchF3_alwaysoff}
...                                                    ListParamterToModify=${MODIFY_LIST_PucchF3_alwaysoff}

Suite Teardown      Run keyword    7103 Suite TearDown

Resource          ../Resources/CB007103_common_keywords.robot






*** Variables ***
####-----log name-----####
${B34_001_wireshark_01}     B34_001_wireshark_attach_01
${B34_001_wireshark_02}     B34_001_wireshark_attach_02
${B34_001_wireshark_03}     B34_001_wireshark_attach_03
${C56_001_wireshark_01}     C56_001_wireshark_attach_01
${C56_001_wireshark_02}     C56_001_wireshark_attach_02
${C56_001_wireshark_03}     C56_001_wireshark_attach_03
${D1_001_wireshark_01}      D1_001_wireshark_attach_01
${D1_001_wireshark_02}      D1_001_wireshark_attach_02
${D4_001_wireshark_01}      D4_001_wireshark_attach_01
${D4_001_wireshark_02}      D4_001_wireshark_attach_02
${D4_001_wireshark_03}      D4_001_wireshark_attach_03
${D4_001_wireshark_04}      D4_001_wireshark_attach_04

*** Test Cases ***
[1]CB007103-B#3&4_001_DMRS_switch_due_to_radio_condition_change_when_pucchF3ModulationScheme_qpsk_4psk
    [Documentation]
    ...   This case test the Rel15 and Rel16 DMRS switch with pucchF3ModulationScheme = qpsk_4psk and pucchF3Rel16Pi2BpskAlwaysOn = FALSE settings
    ...   due to radio conditions change.
    [Tags]    B34001
    [Setup]
    7103 Case SetUp     ModifySCF_Aftercommission=True
    ...                 Modify_Para_Online=${Online_MODIFY_B34001}
    B34_001_Step1_attach_and_capture_wireshark    wiresharklog=${B34_001_wireshark_01}
    ${wireshark_logpath_B34001_02}    B34001_start_dl_traffic_change_PA_to_worse    wiresharklog=${B34_001_wireshark_02}
    BuiltIn.Set Test Variable    ${wireshark_logpath_B34001_02}
    B34001_Step3_get_counter_and_check
    ${wireshark_logpath_B34001_03}    B34001_Step4_change_PA_to_better     wiresharklog=${B34_001_wireshark_03}
    BuiltIn.Set Test Variable    ${wireshark_logpath_B34001_03}
    B34001_Step5_get_counter_and_check
    B34001_Step6_check_all_logs
    [Teardown]    7103 Case TearDown

#[1]CB007103-C#5&6_001_DMRS_switch_due_to_radio_condition_change_when_pucchF3ModulationScheme_Pi2-BPSK
#    [Documentation]
#    ...    This case test the Rel15 and Rel16 DMRS switch with pucchF3ModulationScheme = Pi/2-BPSK and pucchF3Rel16Pi2BpskAlwaysOn = false settings
#    ...    due to radio conditions change . when:
#    ...    Pi/2-BPSK is configured in NIDD (NIDD NRCELL.pucchF3ModulationScheme = Pi/2-BPSK) for PUCCH F3
#    ...    pi/2-BPSK and Rel16 DMRS is not always switched on for PUCCH F3 by NIDD parameter NRCELL.pucchF3Rel16Pi2BpskAlwaysOn is false
#    ...    cover CB007103-A#2_001;
#    ...    cover F#9_001 set numberOfRxBeamforming=8RX
#    ...    cover F#8_001
#    ...    Cover F#6_001 Enable CB008662: actAdaptiveReTxResMcs=true
#    [Tags]    C56001
#    [Setup]
#    7103 Case SetUp
#    ...                ModifySCF_Aftercommission=True
#    ...                Modify_Para_Online=${Online_MODIFY_C56001}
#    C56001_Step1_attach_and_capture_wireshark    wiresharklog=${C56_001_wireshark_01}
#    ${wireshark_logpath_C56001_02}    C56001_Step2_start_uldl_traffic_at_bad
#    BuiltIn.Set Test Variable    ${wireshark_logpath_C56001_02}
#    C56001_Step3_get_counter_and_check
#    ${wireshark_logpath_C56001_03}    C56001_Step4_change_to_good
#    BuiltIn.Set Test Variable    ${wireshark_logpath_C56001_03}
#    C56001_Step5_get_counter_and_check
#    C56001_check_logs
#    [Teardown]    7103 Case TearDown
#
#[1]CB007103-D#1_001_Switching_from_DMRS_Rel15_to_DMRS_Rel16_for_PUSCH_and_PUCCHF3_IWK_with_CB009855
#    [Documentation]
#    ...    This user scenario validates Switching from DMRS Rel15 to Rel16 DMRS used for PUSCH and PUCCH F3 on TDD Pcell with 3DL and 2UL
#    ...    CA configuration which design for partial cover for 5CC USR CB007103-D #1 Interaction with CB009855 buffer based SCell addition / data
#    ...    inactivity based SCell release senario.
#    [Tags]    D1001
#    [Setup]
#    7103 Case SetUp    gnb_cell2_value=${30}    ATT_HB=${35}
#    ...                ModifySCF_Aftercommission=True
#    ...                Modify_Para_Online=${Online_MODIFY_D1001}
#    D1001_Step1_attach_and_capture_wireshark     wiresharklog=${D1_001_wireshark_01}
#    ${wireshark_logpath_D1001_02}    D1001_Step2_start_uldl_traffic_at_bad
#    BuiltIn.Set Test Variable    ${wireshark_logpath_D1001_02}
#    D1001_Step3_get_counter_and_check
#    [Teardown]    Run Keywords
#    ...    Common Case TestLine Setup     ModifySCF_Aftercommission=True     Modify_Para_Online=${Online_MODIFY_unbarred}     AND
#    ...    7103 Case TearDown
#
#[1]CB007103-D#4_001_Switching_from_DMRS_Rel15_to_DMRS_Rel16_for_PUSCH_and_PUCCHF3_due_to_change_in_MCS_with_TDD+FDD_UL_CA
#    [Documentation]
#    ...    This user scenario validates switching from DMRS Rel15 to DMRS Rel16 for PUSCH and PUCCH F3 due to change in MCS on the TDD Pcell when
#    ...    TDD+FDD+TDD 3CC CA configure and TDD cell as Pcell, Ul only at PCELL.
#    ...    for FDD+TDD ULCA, sCellBadChannelQualityThUL should be 0. cover D1001
#    [Tags]    D4001
#    [Setup]
#    7103 Case SetUp    gnb_cell2_value=${30}    gnb_cell3_value=${30}    ATT_HB=${35}
#    ...                ModifySCF_Aftercommission=True
#    ...                Modify_Para_Online=${Online_MODIFY_D4001}
#    D4001_Step1_attach_and_capture_wireshark_TFT     wiresharklog=${D4_001_wireshark_01}
#    ${wireshark_logpath_D4001_02}    D4001_Step2_start_uldl_traffic_at_bad
#    BuiltIn.Set Test Variable    ${wireshark_logpath_D4001_02}
#    D4001_Step3_get_counter_and_check
#    ${wireshark_logpath_D4001_04}      D4001_Step4_change_to_FDD_TDD_2CC
#    BuiltIn.Set Test Variable     ${wireshark_logpath_D4001_04}
#    D4001_check_logs
#    [Teardown]    7103 Case TearDown



*** Keywords ***
#----------------------CB007103-B#3&4_001----------------------#
B34_001_Step1_attach_and_capture_wireshark
    [Arguments]    ${wiresharklog}
    ${wireshark_logpath_B34001_01}    Attach UE and Capture wireshark for MTK80    wiresharklog=${wiresharklog}
    BuiltIn.Set Test Variable    ${wireshark_logpath_B34001_01}

B34001_start_dl_traffic_change_PA_to_worse
    [Arguments]    ${wiresharklog}        ${gnb_cell3_value}=${85}
    Start DL traffic for MTK80    get_ip_from_cpif=${wireshark_logpath_B34001_01}    dl_data_transfer=1M
    Prepare to caculate PM counter    period=start
    Start Capture CP-IF logs from Container     tcpdump_collector_name=${wiresharklog}
    Adjust the HBTE attenuation value for MTK80        gnb_cell3_value=${gnb_cell3_value}    gnb_cell2_value=${55}
    sleep    5min
    [Teardown]    Run Keywords
    ...    Prepare to caculate PM counter    period=end    AND
    ...    Stop CP-IF log Collection    tcpdump_collector_name=${wiresharklog}    target_dir=${epc_log_path}
    [Return]      ${cpif_log_path}

B34001_Step3_get_counter_and_check
    [Arguments]    ${counter_id}=${counter_id_b34001}    ${dic_path}=${counter_dic_path_b34001}    ${timeout}=300
    sleep    1min
    ${counter_value_list}     Get the PM counter    counter_id=${counter_id}   dic_path=${dic_path}    timeout=${timeout}
    should be true      ${counter_value_list}[0] == ${300}        #M55165C00037
    should be true      ${counter_value_list}[1] == ${300}        #M55165C00038
    should be true      ${counter_value_list}[2] >= ${1000}       #M55370C00033
    should be true      ${counter_value_list}[3] >= ${0}          #M55370C00037
    [Return]    ${counter_value_list}

B34001_Step4_change_PA_to_better
    [Arguments]     ${wiresharklog}    ${gnb_cell3_value}=${25}
    Prepare to caculate PM counter    period=start
    Start Capture CP-IF logs from Container     tcpdump_collector_name=${wiresharklog}
    Adjust the HBTE attenuation value for MTK80        gnb_cell3_value=${gnb_cell3_value}
    sleep    5min
    [Teardown]    Run Keywords
    ...    Prepare to caculate PM counter    period=end    AND
    ...    Stop CP-IF log Collection    tcpdump_collector_name=${wiresharklog}    target_dir=${epc_log_path}    AND
    ...    Run Keyword And Ignore Error    Stop DL traffic only
    [Return]      ${cpif_log_path}

B34001_Step5_get_counter_and_check
    [Arguments]    ${counter_id}=${counter_id_b34001}    ${dic_path}=${counter_dic_path_b34001}    ${timeout}=300
    sleep    1min
    ${counter_value_list}
    ...    Get the PM counter    counter_id=${counter_id}   dic_path=${dic_path}    timeout=${timeout}
    should be true      ${counter_value_list}[0] == ${0}          #M55165C00037
    should be true      ${counter_value_list}[1] == ${300}        #M55165C00038
    should be true      ${counter_value_list}[2] == ${0}          #M55370C00033
    should be true      ${counter_value_list}[3] == ${0}          #M55370C00037
    [Return]    ${counter_value_list}

B34001_Step6_check_all_logs
    [Arguments]
    Log to console    \n*** check wireshark_logpath_B34001_01 ***\n
    ${maxCodeRate_1}          Get PucchF3_maxcoderate From rrc_setup    file_path=${wireshark_logpath_B34001_01}
    should be true     '${maxCodeRate_1}' == 'zeroDot15'
    ${transformPrecoder_1}    Get transformPrecoder From rrc_setup    file_path=${wireshark_logpath_B34001_01}
    should be true     '${transformPrecoder_1}' == '1'
    ${pi2BPSK_pucchF3_1}      run keyword and return status    Get pi2BPSK_pucchF3 From rrc_reg      file_path=${wireshark_logpath_B34001_01}
    should be true     '${pi2BPSK_pucchF3_1}' == 'False'
    ${dmrs_Pucch_r16_IE_1}    run keyword and return status    Get dmrs_Pucch_r16_IE From rrc_reg    file_path=${wireshark_logpath_B34001_01}
    should be true     '${dmrs_Pucch_r16_IE_1}' == 'False'
#    ${tp_pi2BPSK_pusch_1}     Get tp_pi2BPSK_pusch From rrc_reg    file_path=${wireshark_logpath_B34001_01}
#    should be true     '${tp_pi2BPSK_pusch_1}' == '0'   disabled due to PR853328
     #for PR853328 In general PUSCH-Config->tp-pi2BPSK should be enabled only for UEs with Transform Precoder
#    ${powerBoostPi2BPSK_1}    run keyword and return status    Get powerBoostPi2BPSK from rrc_reg    file_path=${wireshark_logpath_B34001_01}
#    should be true     '${powerBoostPi2BPSK_1}' == 'True'

    Log to console    \n*** check wireshark_logpath_B34001_02 ***\n
    ${maxCodeRate_2}          Get PucchF3_maxcoderate From rrc_reg   file_path=${wireshark_logpath_B34001_02}
    should be true     '${maxCodeRate_2}' == 'zeroDot25'
    ${pi2BPSK_pucchF3_2}      Get pi2BPSK_pucchF3 From rrc_reg       file_path=${wireshark_logpath_B34001_02}
    should be true     '${pi2BPSK_pucchF3_2}' == '0'
    ${dmrs_Pucch_r16_IE_2}    run keyword and return status    Get dmrs_Pucch_r16_IE From rrc_reg    file_path=${wireshark_logpath_B34001_02}
    should be true     '${dmrs_Pucch_r16_IE_2}' == 'True'
    ${tp_pi2BPSK_pusch_2}     Get tp_pi2BPSK_pusch From rrc_reg     file_path=${wireshark_logpath_B34001_02}
    should be true     '${tp_pi2BPSK_pusch_2}' == '0'
    ${transformPrecoder_2}    Get transformPrecoder From rrc_reg    file_path=${wireshark_logpath_B34001_02}
    should be true     '${transformPrecoder_2}' == '0'
#    ${powerBoostPi2BPSK_2}    Get powerBoostPi2BPSK from rrc_reg    file_path=${wireshark_logpath_B34001_02}
#    should be true     '${powerBoostPi2BPSK_2}' == '1'

    Log to console    \n*** check wireshark_logpath_B34001_03 ***\n
    ${maxCodeRate_3}          Get PucchF3_maxcoderate From rrc_reg    file_path=${wireshark_logpath_B34001_03}
    should be true     '${maxCodeRate_3}' == 'zeroDot15'
    ${transformPrecoder_3}    Get transformPrecoder From rrc_reg      file_path=${wireshark_logpath_B34001_03}
    should be true     '${transformPrecoder_3}' == '1'
#    ${tp_pi2BPSK_pusch_3}     Get tp_pi2BPSK_pusch From rrc_reg       file_path=${wireshark_logpath_B34001_03}
#    should be true     '${tp_pi2BPSK_pusch_3}' == '0'
#    ${powerBoostPi2BPSK_3}    Get powerBoostPi2BPSK from rrc_reg      file_path=${wireshark_logpath_B34001_03}
#    should be true     '${powerBoostPi2BPSK_3}' == '1'
    ${dmrs_Pucch_r16_IE_3}    run keyword and return status    Get dmrs_Pucch_r16_IE From rrc_reg    file_path=${wireshark_logpath_B34001_03}
    should be true     '${dmrs_Pucch_r16_IE_3}' == 'False'
    ${pi2BPSK_pucchF3_3}      run keyword and return status    Get pi2BPSK_pucchF3 From rrc_reg      file_path=${wireshark_logpath_B34001_03}
    should be true     '${pi2BPSK_pucchF3_3}' == 'False'

#----------------------CB007103-C5&6_001----------------------#
C56001_Step1_attach_and_capture_wireshark
    [Arguments]    ${wiresharklog}
    ${wireshark_logpath_C56001_01}    Attach UE and Capture wireshark for MTK80    wiresharklog=${wiresharklog}
    BuiltIn.Set Test Variable    ${wireshark_logpath_C56001_01}

C56001_Step2_start_uldl_traffic_at_bad
    [Arguments]
    ...            ${gnb_cell3_value}=${86}
    Start DL and UL traffic for MTK80    get_ip_from_cpif=${wireshark_logpath_C56001_01}     ul_throughput=100k
    Prepare to caculate PM counter       period=start
    Start Capture CP-IF logs from Container     tcpdump_collector_name=${C56_001_wireshark_02}
    Adjust the HBTE attenuation value for MTK80        gnb_cell3_value=${gnb_cell3_value}
    sleep    2min
    ${C56001_biplog_path}    Collect Biplog on WEBUI for MTK80     target_dir=${epc_log_path}
    ...                                                            target_file_name=C56001_biplog
    ...                                                            Capture_bip_time=10s
    BuiltIn.Set Test Variable     ${C56001_biplog_path}
    sleep    3min
    [Teardown]    Run Keywords
    ...    Prepare to caculate PM counter    period=end    AND
    ...    Stop CP-IF log Collection    tcpdump_collector_name=${C56_001_wireshark_02}    target_dir=${epc_log_path}
    [Return]    ${cpif_log_path}

C56001_Step3_get_counter_and_check
    [Arguments]    ${counter_id}=${counter_id_C56001}    ${dic_path}=${counter_dic_path_C56001}    ${timeout}=300
    sleep    1min
    ${counter_value_list}
    ...    Get the PM counter    counter_id=${counter_id}   dic_path=${dic_path}    timeout=${timeout}
    should be true      ${counter_value_list}[0] == ${300}        #M55165C00036
    should be true      ${counter_value_list}[1] == ${300}        #M55165C00037
    should be true      ${counter_value_list}[2] == ${300}        #M55165C00038
    should be true      ${counter_value_list}[3] >= ${7000}       #M55370C00032
    should be true      ${counter_value_list}[4] >= ${500}       #M55370C00033
    should be true      ${counter_value_list}[5] >= ${7000}       #M55370C00034
    should be true      ${counter_value_list}[6] >= ${7000}       #M55370C00035
    should be true      ${counter_value_list}[7] >= ${0}          #M55370C00036
    should be true      ${counter_value_list}[8] >= ${0}          #M55370C00037

C56001_Step4_change_to_good
    [Arguments]
    ...            ${gnb_cell3_value}=${25}
    Start Capture CP-IF logs from Container     tcpdump_collector_name=${C56_001_wireshark_03}
    Adjust the HBTE attenuation value for MTK80        gnb_cell3_value=${gnb_cell3_value}
    Prepare to caculate PM counter       period=start
    sleep    5min
    [Teardown]    Run Keywords
    ...    Prepare to caculate PM counter    period=end    AND
    ...    Stop CP-IF log Collection    tcpdump_collector_name=${C56_001_wireshark_03}    target_dir=${epc_log_path}   AND
    ...    Stop DL and UL traffic for MTK80    AND
    ...    Detach MTK80
    [Return]    ${cpif_log_path}

C56001_Step5_get_counter_and_check
    [Arguments]    ${counter_id}=${counter_id_C56001}    ${dic_path}=${counter_dic_path_C56001}    ${timeout}=300
    sleep    1min
    ${counter_value_list}
    ...    Get the PM counter    counter_id=${counter_id}   dic_path=${dic_path}    timeout=${timeout}
    should be true      ${counter_value_list}[0] == ${0}          #M55165C00036
    should be true      ${counter_value_list}[1] == ${0}          #M55165C00037
    should be true      ${counter_value_list}[2] == ${300}        #M55165C00038
    should be true      ${counter_value_list}[3] == ${0}          #M55370C00032
    should be true      ${counter_value_list}[4] == ${0}          #M55370C00033
    should be true      ${counter_value_list}[5] == ${0}          #M55370C00034
    should be true      ${counter_value_list}[6] == ${0}          #M55370C00035
    should be true      ${counter_value_list}[7] == ${0}          #M55370C00036
    should be true      ${counter_value_list}[8] == ${0}          #M55370C00037

C56001_check_logs
    ${transformPrecoder_1}    Get transformPrecoder From rrc_setup    file_path=${wireshark_logpath_C56001_01}
    should be true     '${transformPrecoder_1}' == '1'
    ${transformPrecoder_2}    Get transformPrecoder From rrc_reg    file_path=${wireshark_logpath_C56001_02}
    should be true     '${transformPrecoder_2}' == '0'
    ${transformPrecoder_3}    Get transformPrecoder From rrc_reg    file_path=${wireshark_logpath_C56001_03}
    should be true     '${transformPrecoder_3}' == '1'
    Get and check pusch_dmrsSequenceType num From BIP    file_path=${C56001_biplog_path}
    Get and check Pcmax_value From BIP      file_path=${C56001_biplog_path}

#----------------------CB007103-D1#001----------------------#
D1001_Step1_attach_and_capture_wireshark
    [Arguments]    ${wiresharklog}
    ${wireshark_logpath_D1001_01}    Attach UE and Capture wireshark for MTK80    wiresharklog=${wiresharklog}
    BuiltIn.Set Test Variable    ${wireshark_logpath_D1001_01}

D1001_Step2_start_uldl_traffic_at_bad
    [Arguments]
    ...            ${gnb_cell3_value}=${84}
    ...            ${gnb_cell2_value}=${30}
    Start DL and UL traffic for MTK80    get_ip_from_cpif=${wireshark_logpath_D1001_01}    dl_data_transfer=900M    ul_throughput=100K
    Prepare to caculate PM counter       period=start
    Start Capture CP-IF logs from Container     tcpdump_collector_name=${D1_001_wireshark_02}
    Adjust the HBTE attenuation value for MTK80        gnb_cell3_value=${gnb_cell3_value}     gnb_cell2_value=${gnb_cell2_value}
    sleep    2min
    Check 3CC tput for MTK80 with CA mode
    sleep    3min
    [Teardown]    Run Keywords
    ...    Prepare to caculate PM counter    period=end    AND
    ...    Stop CP-IF log Collection    tcpdump_collector_name=${D1_001_wireshark_02}    target_dir=${epc_log_path}
    [Return]    ${cpif_log_path}

D1001_Step3_get_counter_and_check
    [Arguments]    ${counter_id}=${counter_id_C56001}    ${dic_path}=${counter_dic_path_C56001}    ${timeout}=300
    sleep    1min
    ${counter_value_list}
    ...    Get the PM counter    counter_id=${counter_id}   dic_path=${dic_path}    timeout=${timeout}
    should be true      ${counter_value_list}[0] == ${300}        #M55165C00036
    should be true      ${counter_value_list}[1] == ${300}        #M55165C00037
    should be true      ${counter_value_list}[2] == ${300}        #M55165C00038
    should be true      ${counter_value_list}[3] >= ${7000}       #M55370C00032
    should be true      ${counter_value_list}[4] >= ${1000}       #M55370C00033
    should be true      ${counter_value_list}[5] >= ${7000}       #M55370C00034
    should be true      ${counter_value_list}[6] >= ${7000}       #M55370C00035
    should be true      ${counter_value_list}[7] >= ${0}          #M55370C00036
    should be true      ${counter_value_list}[8] >= ${0}          #M55370C00037

#----------------------CB007103-D#4_001----------------------#
D4001_Step1_attach_and_capture_wireshark_TFT
    [Arguments]    ${wiresharklog}
    ${wireshark_logpath_D4001_01}    Attach UE and Capture wireshark for MTK80    wiresharklog=${wiresharklog}
    BuiltIn.Set Test Variable    ${wireshark_logpath_D4001_01}

D4001_Step2_start_uldl_traffic_at_bad
    [Documentation]    N78+N1+N40 3CC, N78 had ul traffic only
    [Arguments]
    Start DL and UL traffic for MTK80    get_ip_from_cpif=${wireshark_logpath_D4001_01}    dl_data_transfer=200M    ul_throughput=100M
    Prepare to caculate PM counter       period=start
    Start Capture CP-IF logs from Container     tcpdump_collector_name=${D4_001_wireshark_02}
    MCS SET ATT for MTK80     att_value=${84}
    sleep    2min
    Check 3CC tput for MTK80 with CA mode
    ${D4001_biplog_01}    Collect Biplog on WEBUI for MTK80     target_dir=${epc_log_path}
    ...                                                         target_file_name=D4001_biplog_3CC
    ...                                                         Capture_bip_time=10s
    BuiltIn.Set Test Variable      ${D4001_biplog_01}
    sleep    1min
    [Teardown]    Run Keywords
    ...    Prepare to caculate PM counter    period=end    AND
    ...    Stop CP-IF log Collection    tcpdump_collector_name=${D4_001_wireshark_02}    target_dir=${epc_log_path}     AND
    ...    Stop DL and UL traffic for MTK80     AND
    ...    Detach MTK80     AND
    ...    MCS SET ATT for MTK80    att_value=${25}    AND
    ...    Run Keyword And Ignore Error    mcs_common.Teardown MCS    mcs_type=${mcs_type}
    [Return]    ${cpif_log_path}

D4001_Step3_get_counter_and_check
    [Arguments]    ${counter_id}=${counter_id_D4001}    ${dic_path}=${counter_dic_path_D4001}    ${timeout}=300
    sleep    1min
    ${counter_value_list}
    ...    Get the PM counter    counter_id=${counter_id}   dic_path=${dic_path}    timeout=${timeout}
    should be true      ${counter_value_list}[0] == ${300}           #M55165C00036,need trigger r16 transformPrecoding enable
    should be true      ${counter_value_list}[1] == ${300}           #M55165C00037
    should be true      ${counter_value_list}[2] >= ${100}           #M55370C00032
    should be true      ${counter_value_list}[3] >= ${3000}          #M55370C00034
    should be true      ${counter_value_list}[4] >= ${3000}          #M55370C00035
    should be true      ${counter_value_list}[5] >= ${0}             #M55370C00036
    should be true      ${counter_value_list}[6] >= ${0}             #M55370C00037
    should be true      ${counter_value_list}[7] >= ${10000}        #M55310C20000 FDD CELL2
    should be true      ${counter_value_list}[8] >= ${10000}        #M55310C20000 TDD CELL3

D4001_Step4_change_to_FDD_TDD_2CC
    [Documentation]    N1+N78 2CC
    [Arguments]
    change_parameter_online     ${ONLINE_MODIFY_D4001_FDD_TDD}
    Adjust the HBTE attenuation value for MTK80     gnb_cell2_value=${20}
    ...                                             gnb_cell3_value=${127}
    ...                                             enb_cell1_value=${127}
    ${wireshark_logpath_D4001_03}    Attach UE and Capture wireshark for MTK80    wiresharklog=${D4_001_wireshark_03}
#    Start UL traffic via iperf for MTK80     ul_throughput=100M
    Start DL and UL traffic for MTK80    get_ip_from_cpif=${wireshark_logpath_D4001_03}      dl_data_transfer=500M     ul_throughput=100M
    Prepare to caculate PM counter       period=start
    Start Capture CP-IF logs from Container     tcpdump_collector_name=${D4_001_wireshark_04}
    MCS SET ATT for MTK80     att_value=${60}
    Adjust the HBTE attenuation value for MTK80     gnb_cell2_value=${50}
    ...                                             gnb_cell3_value=${127}
    ...                                             enb_cell1_value=${127}
    MCS SET ATT for MTK80     att_value=${83}
    Adjust the HBTE attenuation value for MTK80     gnb_cell2_value=${75}
    ...                                             gnb_cell3_value=${127}
    ...                                             enb_cell1_value=${127}
    sleep    1min
    Check F+T_2CC tput for MTK80 with CA mode     direction=dl
    Check F+T_2CC tput for MTK80 with CA mode     direction=ul    target_throughput=0.4
    ${D4001_biplog_02}    Collect Biplog on WEBUI for MTK80     target_dir=${epc_log_path}
    ...                                                         target_file_name=D4001_biplog_2CC
    ...                                                         Capture_bip_time=10s
    BuiltIn.Set Test Variable      ${D4001_biplog_02}
    sleep    3min
    [Teardown]    Run Keywords
    ...    Prepare to caculate PM counter    period=end    AND
    ...    Stop CP-IF log Collection    tcpdump_collector_name=${D4_001_wireshark_04}    target_dir=${epc_log_path}     AND
    ...    Stop DL and UL traffic for MTK80     AND
    ...    Detach MTK80     AND
    ...    MCS SET ATT for MTK80    att_value=${25}    AND
    ...    Run Keyword And Ignore Error    mcs_common.Teardown MCS    mcs_type=${mcs_type}
    [Return]    ${cpif_log_path}

D4001_check_logs
    ${transformPrecoder_1}    Get transformPrecoder From rrc_setup    file_path=${wireshark_logpath_D4001_01}
    should be true     '${transformPrecoder_1}' == '1'
    ${transformPrecoder_2}    Get transformPrecoder From rrc_reg    file_path=${wireshark_logpath_D4001_02}    ie_index=-1
    should be true     '${transformPrecoder_2}' == '0'
    Get and check pusch_dmrsSequenceType num From BIP     file_path=${D4001_biplog_01}
    Get and check Pcmax_value From BIP      file_path=${D4001_biplog_01}
    #-------FDD+TDD ULCA checkpoint--------#
    ${transformPrecoder_2}    Get transformPrecoder From rrc_reg    file_path=${wireshark_logpath_D4001_04}
    should be true     '${transformPrecoder_2}' == '0'
    Get and check pusch_dmrsSequenceType From BIP for CA     file_path=${D4001_biplog_02}    cell_pci=374

