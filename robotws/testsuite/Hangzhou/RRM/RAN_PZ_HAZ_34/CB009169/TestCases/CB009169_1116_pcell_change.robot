*** Settings ***
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB009169/Resources/CB009169_keywords.robot
Force Tags        5G_RRM   PY36    RF50

Suite Setup        9169 pcell change suite preparation
Suite Teardown     run keyword and ignore error    CA Suite teardown


*** Test Cases ***
CB009169-SR_AB_B5_007_SCell_selection_for_activation_and_deactivation_with_2TDD_2FDD_iniNumSCellsToActivate_1
    [Documentation]    Author:Liu Zheng
    ...    Precondition in suite setup which set the corresponding NIDDs for A2 based and A1 based PSCell change\n
    ...      MRBTS/NRBTS/actMeasBasedSCellAddition is set to true\n
    ...    Related parameters for A2 based PSCell change, for T+F switch to F+T\n
    ...      MRBTS/NRBTS/actInterFreqHoSA is set to true\n
    ...      MRBTS/NRBTS/NRCELL(TDD)/NRREL/sCellAdditionMethod is set to covBasedA1\n
    ...      NRBTS/NRCELL/cellDepType(both pcell and scells) is set to 10 (SA+NSA)\n
    ...      NRBTS/NRCELL(TDD)/NRHOIF/a2BasedPCellSwitchEnabled for the frequency corresponding to FDD Cell (F2)\n
    ...      NRBTS/NRCELL(TDD)/a2MeasPCellSwitchEnabled for FR1-TDD PSCell\n
    ...      NRBTS/NRCELL(TDD)/a2MeasPCellSwitchSsbRsrp and/or NRBTS/NRCELL/a2MeasPCellSwitchSsbRsrq (for FR1-TDD PSCell)\n
    ...    Related parameters for A1 based PSCell change, for F+T switch to T+F\n
    ...      MRBTS/NRBTS/NRCELL(FDD)/NRREL/sCellAdditionMethod is set to covBasedA1\n
    ...      NRBTS/NRBTS/NRCELL(FDD)/NRHOIF/a1BasedPCellSwitchEnabled is set to true\n
    ...      NRBTS/NRBTS/NRCELL(TDD)/a1MeasPCellSwitchEnabled is set to rsrp\n
    ...      NRBTS/NRBTS/NRCELL(TDD)/a1MeasPCellSwitchSsbRsrp is configured.\n
    ...    Step1: attach to TDD cell and TDD(pcell) signal is good enough to do A1 scell addition, and in the same RRC reconfiguration message,
    ...         there is A2 pcell change configured.\n
    ...    Step2: start start UL(200M) and DL(2600M) traffic, throughput on TDD1(pcell) and FDD1(scell) and TDD3(scell) and FDD2(scell) can peak.\n
    ...    Step3: adjust TDD(pcell) signal to bad(PA from 0 to 40), trigger a2 measurement report \n
    ...    Step4: check pcell change from T+F+F+T CA to F+T+F+T CA \n
    ...    step5: adjust TDD(pcell) signal better(PA=15) but not reach to the A1based pcell change threshold,
    ...         check F+T CA UL DL traffic, due to scell signal is bad, throughput can't peak. \n
    ...    Step6: djust TDD(scell) signal to good(PA from 15 to 0), trigger a1 pcell change measurement report\n
    ...    Step7: check pcell change from F+T CA to T+F CA \n
    ...    Step8: check T+F CA UL DL traffic, throughput can peak \n
    ...    ***This case use cell1,2,5,3 for CA testing.
    [Setup]    9169 Case setup    dict_params_to_modify=${SCF_CASE_AB_B5_007}
    log to console    ***do A2 based PSCell change from 9169 to 6137***
    9169 Pcell id and scell id and expected throughput redefined in order to match with different pcell     ca_group_type=T+F_9169_4CC
    Connect to gnb coam via ssl

    run keyword and continue on failure    L3call with UL and DL CA and verify A2 configured on PCell
    Change status for parameter cellBarred on GNB    exp_status=notBarred    list_cell_ids=${SCELL_ID_UL_ADD}
    ...    timeout=${TIMER_FOR_MODIFY_VIA_API}

    ${starting_log_timestamp_A2}    Prepare for counter log    reporting_interval=5
    log to console    adjust PA to trigger A2 based PSCell change, from 9169 to 6137
    Adjust PA and verify Pcell change successful    pcell_change_type=A2

    9169 Pcell id and scell id and expected throughput redefined in order to match with different pcell     ca_group_type=F+T_6137_4CC
    Set attenuator ports of specified RUs to same value    exp_pa_value=${PA_TDD_100M_signal_better_after_SWTICH}    ru_idx_list=0
    run keyword and continue on failure    Verify throughput as expect    cell_index=${CELL_INDEX_LIST}
    ...    exp_ul_indiv=${EXP_UL}     exp_dl_indiv=${EXP_DL}      check_tput_ignore_time=40s    is_analysis_log_captured=${True}
    ...    bip_log_name=tput_validation_failed_after_pcell_change_to_6137
    run keyword and continue on failure    Check PM counter for A2 based pcell change M55145C03001 M55145C03002
    ...    starting_log_timestamp=${starting_log_timestamp_A2['log_generator_timestamp']}

    ${starting_log_timestamp_A1}    Prepare for counter log   reporting_interval=5
    log to console    adjust PA to bad then to good to trigger A1 based PSCell change, from 6137 to 9169
    Set attenuator ports of specified RUs to same value    exp_pa_value=${PA_TDD_100M_signal_bad_before_SWITCH}    ru_idx_list=0
    Change status for parameter cellBarred on GNB    exp_status=notBarred    list_cell_ids=${SCELL_ID_UL_ADD}
    ...    timeout=${TIMER_FOR_MODIFY_VIA_API}
    Adjust PA and verify Pcell change successful    pcell_change_type=A1
    9169 Pcell id and scell id and expected throughput redefined in order to match with different pcell     ca_group_type=T+F_9169_4CC
    run keyword and continue on failure    Verify throughput as expect    cell_index=${CELL_INDEX_LIST}
    ...    exp_ul_indiv=${EXP_UL}     exp_dl_indiv=${EXP_DL}      check_tput_ignore_time=40s    is_analysis_log_captured=${True}
    ...    bip_log_name=tput_validation_failed_after_pcell_change_to_9169
    run keyword and continue on failure    Check PM counter for A1 based pcell change M55145C02001 M55145C02002
    ...    starting_log_timestamp=${starting_log_timestamp_A1['log_generator_timestamp']}
    [Teardown]    run keyword and ignore error    Common case teardown    detach_ue=${True}


*** Keywords ***
9169 pcell change suite preparation
    [Documentation]  Author: Liu Zheng
    ...    exp_cc_num_in_use: refers to 3CC/4CC/${None}, if set as 3CC or 4CC will return the input value directly,
    ...        otherwise will judge based on ue type. sdx65: 3CC, sdx70: 4CC, other ue type will default to 3CC
    ...    Added new parameter for ${ca_group_mapping_3cc} and ${ca_group_mapping_4cc}, parameter need to be added based on exp_cc_num_in_use
    ...    ${ca_group_mapping_3cc} equals to ${ca_group_mapping} by default,
    ...    ToDo: ${ca_group_mapping} can be removed when all cases has removed this param
    [Arguments]    ${enb_default_scf_file}=${None}    ${cell_chbw_config}=4CC_T100M_F20M_F10M_T60M
    ...    ${swconfig_modify}=${None}    ${scf_modify_parameters}=${PARAMS_TO_MODIFY_SCF}
    ...    ${pa_values_mapping}=${INIT_PA_T1_F1_T3_F2}    ${ca_group_mapping_3cc}=${T1_F1_F2_3CC_CA_GROUP_COMMON}
    ...    ${ca_group_mapping_4cc}=${T1_F1_T3_F2_4CC_CA_GROUP_COMMON}    ${exp_cc_num_in_use}=${None}
    set suite variable    ${INIT_PA}    ${INIT_PA_T1_F1_T3_F2}
    Decode CA group mapping and set global variable    is_called_in_suite_level=${True}
    ...    ca_group_mapping_3cc=${ca_group_mapping_3cc}    ca_group_mapping_4cc=${ca_group_mapping_4cc}    exp_cc_num_in_use=${exp_cc_num_in_use}
    Import NIDD variables for 9169
    run keyword if    '${cell_chbw_config}'!='${None}'    import variables    ${CURDIR}/../TestData/NIDD_modify_scf_${cell_chbw_config}.py
    import variables    ${CURDIR}/../TestData/NIDD_Modify_pcell_change_9169.py

    Set suite variable    ${PARAMS_TO_DELETE}     ${DELETE_SCF_BEFORE_PCELL_SWITCH}
    Set suite variable    ${PARAMS_TO_ADD}       ${ADD_SCF_PSCELL_SWITCH}
    Set suite variable    ${PARAMS_TO_MODIFY}    ${MODIFY_SCF_PCELL_SWITCH_COMMISSION}

    CA Suite preparation    prepare_ue=${True}    NSA_SA=${NSA_SA}    enb_default_scf_file=${enb_default_scf_file}
    ...    swconfig_modify=${swconfig_modify}
    ...    prepare_ue=${True}
    ...    scf_modify_parameters=${scf_modify_parameters}
    ...    pa_values_mapping=${pa_values_mapping}

    Prepare NRREL under specific cell    ca_group_mapping=${CA_GROUP_MAPPING}    prepare_nrrel=T_F_4CC
    Prepare NRREL under specific cell    ca_group_mapping=${F1_F2_T1_T2_4CC_CA_GROUP_6137}    prepare_nrrel=F+T_4CC
    Set tput expectation for suite level


Set tput expectation for suite level
    ${EXP_DL_INDIV_1116}    Create List    ${EXP_DL_T100M_4x4_256QAM_1116}    ${EXP_DL_F20M_2x2_256QAM}
    ...    ${EXP_DL_T60M_4x4_256QAM_1116}    ${EXP_DL_F10M_2x2_256QAM}
    ${EXP_UL_INDIV_1116}    Create List    ${EXP_UL_T100M_2x2_64QAM_1116}    ${EXP_UL_F20M_2x2_64QAM_1116}    -1    -1
    Set suite variable    ${EXP_DL_INDIV_1116}
    Set suite variable    ${EXP_UL_INDIV_1116}


9169 Pcell id and scell id and expected throughput redefined in order to match with different pcell
    [Documentation]    Author: zheng.4.liu@nokia-sbell.com
    ...    Happened when A1 based or A2 based PSCell triggered.
    [Arguments]    ${ca_group_type}=T+F_9169_4CC
    ${EXP_DL_INDIV_1116_6137}  Create List    ${EXP_DL_T100M_4x4_256QAM_1116_6137}     ${EXP_DL_F20M_2x2_256QAM_6137}
    ...    ${EXP_DL_T60M_4x4_256QAM_6137}    ${EXP_DL_F10M_2x2_256QAM_6137}
    ${EXP_UL_INDIV_1116_6137}  Create List    ${EXP_UL_T100M_2x2_64QAM_1116_6137}  ${EXP_UL_F20M_2x2_64QAM_6137}    -1    -1

    run keyword if    '${ca_group_type}'=='T+F_9169_4CC'   Run Keywords
    ...       Set suite variable    ${CA_GROUP_MAPPING}    ${T1_F1_T3_F2_4CC_CA_GROUP_COMMON}
    ...       AND    set test variable   ${PCELL_ID}    ${CA_GROUP_MAPPING['pcell_id']}
    ...       AND    set test variable   ${PCELL_RU_INDEX}    ${NR_CELL_ID_MAPPING[${PCELL_ID}]['ruIndex_in_init']}
    ...       AND    set test variable   ${SCELL_ID_UL_ADD}    ${CA_GROUP_MAPPING['verify_scell_add_ul']}
    ...       AND    set test variable   ${SCELL_ID_DL_ADD}    ${CA_GROUP_MAPPING['verify_scell_add_dl']}
    ...       AND    set test variable   ${SCELL_UL_RU_INDEX}     ${NR_CELL_ID_MAPPING[${SCELL_ID_UL_ADD[0]}]['ruIndex_in_init']}
    ...       AND    set test variable   ${EXP_DL}    ${EXP_DL_INDIV_1116}
    ...       AND    set test variable   ${EXP_UL}    ${EXP_UL_INDIV_1116}
    ...       AND    set test variable   ${CA_GROUP_TYPE}    T+F_9169_4CC
    ...       ELSE    Run Keywords    Set suite variable    ${CA_GROUP_MAPPING}    ${F1_F2_T1_T2_4CC_CA_GROUP_6137}
    ...       AND    set test variable   ${PCELL_ID}    ${CA_GROUP_MAPPING['pcell_id']}
    ...       AND    set test variable   ${PCELL_RU_INDEX}    ${NR_CELL_ID_MAPPING[${PCELL_ID}]['ruIndex_in_init']}
    ...       AND    set test variable   ${SCELL_ID_UL_ADD}    ${CA_GROUP_MAPPING['verify_scell_add_ul']}
    ...       AND    set test variable   ${SCELL_ID_DL_ADD}    ${CA_GROUP_MAPPING['verify_scell_add_dl']}
    ...       AND    set test variable   ${SCELL_UL_RU_INDEX}    ${NR_CELL_ID_MAPPING[${SCELL_ID_UL_ADD[0]}]['ruIndex_in_init']}
    ...       AND    set test variable   ${EXP_DL}    ${EXP_DL_INDIV_1116_6137}
    ...       AND    set test variable   ${EXP_UL}    ${EXP_UL_INDIV_1116_6137}
    ...       AND    Set suite variable  ${CELL_INDEX_LIST}
    ...       AND    set test variable   ${CA_GROUP_TYPE}    F+T_6137_4CC

Adjust PA and verify Pcell change successful
    [Documentation]    author: zheng.4.liu@nokia-sbell.com
    ...   when test 8542 A1 and A2 PSCell change, both need to adjust the TDD cell signal.
    ...   New scell added after Pcell switch
    ...   Pcell ID should be changed to Scell ID and old Scell released
    [Arguments]    ${NSA_SA}=${NSA_SA}    ${enb_default_scf_file}=${None}     ${tcpdump_log_name}=pcell_switch_triggered
    ...   ${pcell_change_type}=A1    ${scell_number}=${3}
    Start capture F1AP log    tcpdump_collector_name=${tcpdump_log_name}_${pcell_change_type}    options=-i any sctp

    Set Test Variable    ${TDD_Cell_id}    ${T1_F1_T3_F2_4CC_CA_GROUP_COMMON['pcell_id']}
    Set Test Variable    ${TDD_RU_index}      ${NR_CELL_ID_MAPPING[${TDD_Cell_id}]['ruIndex_in_init']}
    Set Test Variable    ${FDD_RU_index_with_ul}    ${T1_F1_T3_F2_4CC_CA_GROUP_COMMON['verify_scell_add_ul'][0]}
    run keyword if    '${pcell_change_type}'=='A1'    Set attenuator ports of specified RUs to same value
    ...    exp_pa_value=${PA_A1_BASED_PCELL_SWTICH}    ru_idx_list=${TDD_RU_index}
    ...    ELSE    Set attenuator ports of specified RUs to same value
    ...    exp_pa_value=${PA_A2_BASED_PCELL_SWTICH}    ru_idx_list=${TDD_RU_index}

    sleep    15s
    ${PSCell_change_log}    Stop tcpdump log collection    tcpdump_collector_name=${tcpdump_log_name}_${pcell_change_type}

    run keyword if   '${pcell_change_type}'=='A1'    run keyword and continue on failure
    ...    Verify A1 report for scell to trigger pcell switch in cpif log
    ...    log_path_pcap=${PSCell_change_log}        a1_rsrp_thres=${A1_THRESHOLD_PCELL_SWITCH_SSB_RSRP}    cellId=${SCELL_ID_UL_ADD[0]}
    ...    ELSE    run keyword and continue on failure     Verify A2 report for pcell to trigger pcell swith in cpif log
    ...    log_path_pcap=${PSCell_change_log}     a2_rsrp_thres=${A2_THRESHOLD_PCELL_SWITCH_SSB_RSRP}

    ${expected_target_pcell}    set variable if    '${pcell_change_type}'=='A1'   ${TDD_Cell_id}     ${SCELL_ID_UL_ADD[0]}

    run keyword and continue on failure     Verify Pcell ID Changed after pcell switch through RRC reconfiguration
    ...         log_path_pcap=${PSCell_change_log}    expected_target_pcell=${expected_target_pcell}    scell_number=${scell_number}

    ${expected_SCELL_ID_UL_ADD}    set variable if    '${pcell_change_type}'=='A1'   ${T1_F1_T3_F2_4CC_CA_GROUP_COMMON['verify_scell_add_ul']}
    ...    ${F1_F2_T1_T2_4CC_CA_GROUP_6137['verify_scell_add_ul']}
    ${expected_SCELL_ID_DL_ADD}    set variable if    '${pcell_change_type}'=='A1'   ${T1_F1_T3_F2_4CC_CA_GROUP_COMMON['verify_scell_add_dl']}
    ...    ${F1_F2_T1_T2_4CC_CA_GROUP_6137['verify_scell_add_dl']}

    Verify scell addition from f1ap log    log_file_path=${PSCell_change_log}
    ...    display_filter=f1ap.procedureCode == 12 &&nr-rrc.sCellToAddModList == 3
    ...    scell_index_ul=${expected_SCELL_ID_UL_ADD}   scell_index_dl=${expected_SCELL_ID_DL_ADD}


test scell activate according to ADR
    [Documentation]  Author: Liu Zheng
    run keyword and continue on failure    UE attach start traffic and check scells activate according to ADR
    ...    file_name_scell_act_one_by_one=ul_no_decisionSCellMask
    ...    iniNumSCellsToActivate=${ININUMSCELLSTOACTIVATE}
    ...    scell_index_ul=${SCELL_ID_UL_ADD}    scell_index_dl=${SCELL_ID_DL_ADD}    pcell_id=${PCELL_ID}
    ...    tcpdump_log_name=basic_l3_call_ul    scell_addition_method=covBasedA1
    ...    ul_tput_iperf=${UL_TPUT_IPERF}    iperf_duration=3000s
    ...    data_transfer_direction=ul     need_attach_step=${True}    is_need_to_stop_traffic=${False}

    run keyword and continue on failure    UE attach start traffic and check scells activate according to ADR
    ...    file_name_scell_act_one_by_one=ul_no_decisionSCellMask
    ...    iniNumSCellsToActivate=${ININUMSCELLSTOACTIVATE}
    ...    scell_index_ul=${SCELL_ID_UL_ADD}    scell_index_dl=${SCELL_ID_DL_ADD}    pcell_id=${PCELL_ID}
    ...    tcpdump_log_name=basic_l3_call_dl    scell_addition_method=covBasedA1
    ...    dl_tput_iperf=${DL_TPUT_IPERF}    iperf_duration=3000s
    ...    data_transfer_direction=dl    need_attach_step=${False}    is_need_to_stop_traffic=${True}
    ...    traffic_need_to_stop=both

UE attach start traffic and check scells activate according to ADR
    [Documentation]  Author: Liu Zheng
    ...    1. If the request come from DL branch, gNB selects SCells to activate according to ADR, no matter DL only SCell or joint DL/UL SCell.\n
    ...    2. If the request come from UL branch, gNB selects the only 1 joint DL/UL SCell to activate.\n
    ...    3. If the request come from both UL and DL branch, gNB selects the only 1 joint DL/UL SCell to activate firstly, \n
    ...    then if more SCell activation is need according to NIDD:iniNumSCellsToActivate, gNB selects DL only SCells according to ADR.\n
    ...    check scell activate according to ADR by bellow msg in aasyslog\n
    ...    INF//L2-PS/src/dl/sch/ca/RemoteDlSCellActivationManagerLog.hpp[69] ue rnti:58449 decisionSCellMask:1\n
    [Arguments]    ${file_name_scell_act_one_by_one}    ${iniNumSCellsToActivate}=${ININUMSCELLSTOACTIVATE}    ${connection}=ASIK Master
    ...    ${scell_index_ul}=${SCELL_ID_UL_ADD}    ${scell_index_dl}=${SCELL_ID_DL_ADD}    ${pcell_id}=${PCELL_ID}
    ...    ${tcpdump_log_name}=basic_l3_call    ${scell_addition_method}=covBasedA1   ${ue_index}=${0}   ${NSA_SA}=${NSA_SA}
    ...    ${dl_tput_iperf}=${DL_TPUT_IPERF}    ${ul_tput_iperf}=${UL_TPUT_IPERF}    ${protocol}=udp    ${iperf_duration}=3000s
    ...    ${data_transfer_direction}=both    ${connection_gnb_oam}=GNB_OAM    ${need_attach_step}=${True}    ${is_need_to_stop_traffic}=${False}
    ...    ${traffic_need_to_stop}=${None}
    ${pcell_RU_Index}   set variable    ${NR_CELL_ID_MAPPING[${pcell_id}]['ruIndex_in_init']}

    run keyword if    ${need_attach_step}==${True}
    ...    Set attenuator ports of specified RUs to same value    exp_pa_value=${PCELL_BAD}    ru_idx_list=${pcell_RU_Index}
    run keyword if    ${need_attach_step}==${True}
    ...    UE attach and verify Scell addition in tcpdump log    scell_index_ul=${scell_index_ul}    scell_index_dl=${scell_index_dl}
    ...    pcell_id=${pcell_id}    tcpdump_log_name=${tcpdump_log_name}    scell_addition_method=${scell_addition_method}    ue_index=${ue_index}
    ...    NSA_SA=${NSA_SA}    connection=${connection_gnb_oam}
    Set attenuator ports of specified RUs to same value    exp_pa_value=${PCELL_GOOD}    ru_idx_list=${pcell_RU_Index}

    Log to console    check scells activate according to ADR\n
    Teardown the Aasyslog save progress
    Aasyslog precondition
    ${aasyslog_gnb_log_path}    Start the Aasyslog save progress    filter=L2\\|cp    log_name=${file_name_scell_act_one_by_one}.txt
    ...    is_ssh_con_released=${False}

    run keyword and continue on failure    Start data transfer based on direction  dl_tput=${dl_tput_iperf}   ul_tput=${ul_tput_iperf}
    ...    protocol=${protocol}    duration=${iperf_duration}    data_transfer_direction=${data_transfer_direction}

    ${info_scell_act}    Get decisionSCellMask filter info from aasyslog    aasyslog_log_path=${aasyslog_gnb_log_path}
        ...    filter=decisionSCellMask    connection=${connection}

    run keyword if    '${data_transfer_direction}'=='ul'    verify decisionSCellMask when traffic is UL    info_scell_act=${info_scell_act}
    ...    ELSE    verify decisionSCellMask when traffic is DL or both    info_scell_act=${info_scell_act}

    run keyword if    '${data_transfer_direction}'=='ul'    run keyword and continue on failure    Verify throughput as expect
    ...    cell_index=${CELL_INDEX_LIST}    exp_ul_indiv=${EXP_UL_INDIV_1116}    exp_dl_indiv=${None}     check_tput_ignore_time=40s
    ...    data_transfer_direction=${data_transfer_direction}
    ...    ELSE IF    '${data_transfer_direction}'=='dl'       run keyword and continue on failure    Verify throughput as expect
    ...    cell_index=${CELL_INDEX_LIST}    exp_ul_indiv=${None}    exp_dl_indiv=${EXP_DL_INDIV_1116}     check_tput_ignore_time=40s
    ...    data_transfer_direction=${data_transfer_direction}
    ...    ELSE    run keyword and continue on failure    Verify throughput as expect
    ...    cell_index=${CELL_INDEX_LIST}    exp_ul_indiv=${EXP_UL_INDIV_1116}    exp_dl_indiv=${EXP_DL_INDIV_1116}     check_tput_ignore_time=40s
    ...    data_transfer_direction=${data_transfer_direction}


    run keyword if    '${data_transfer_direction}'=='ul'    Run keyword and continue on failure    Stop data transfer based on direction
    ...    data_transfer_direction=ul
    ...    ELSE IF    '${data_transfer_direction}'=='dl'     Run keyword and continue on failure    Stop data transfer based on direction
    ...    data_transfer_direction=dl
    ...    ELSE    run keyword and continue on failure   Stop data transfer based on direction   data_transfer_direction=both

    ${list_dl_scell_operational_mode}      Get scell OperatorMode info base on Scell DL List     dl_scell_list=${SCELL_ID_DL_ADD}
    ...       ca_group_mapping=${CA_GROUP_MAPPING}

    ${traffic_need_to_stop}    set variable if    ${traffic_need_to_stop}!=${None}    ${traffic_need_to_stop}    ${data_transfer_direction}

    run keyword if    ${is_need_to_stop_traffic}=${True}    stop traffic based on direction   data_transfer_direction=${traffic_need_to_stop}
    [Teardown]    Run keyword and ignore error    Teardown aasyslog with log downloaded to ute    gnb_log_path=${aasyslog_gnb_log_path}
    ...        ute_log_folder=${TS_CASE_LOG_PATH}

stop traffic based on direction
    [Arguments]    ${data_transfer_direction}
    run keyword if    '${data_transfer_direction}'=='ul'    run keyword and continue on failure
    ...    Stop DL or UL traffic stop to check Scell deactivated for Bufferbased
    ...            data_transfer_direction=ul    expect_scell_deactivated=${True}
    ...            scell_id=${SCELL_ID_UL_ADD}      scell_operator_mode=dlAndUl
    ...    ELSE IF   '${data_transfer_direction}'=='dl'    run keyword and continue on failure
    ...    Stop DL or UL traffic stop to check Scell deactivated for Bufferbased
    ...            data_transfer_direction=dl    expect_scell_deactivated=${True}
    ...            scell_id=${SCELL_ID_DL_ADD}      scell_operator_mode=${list_dl_scell_operational_mode}
    ...    ELSE    run keyword and continue on failure    Stop DL or UL traffic stop to check Scell deactivated for Bufferbased
    ...            data_transfer_direction=both   expect_scell_deactivated=${True}
    ...            scell_id=${SCELL_ID_UL_ADD}      scell_operator_mode=${list_dl_scell_operational_mode}


verify decisionSCellMask when traffic is UL
    [Arguments]    ${info_scell_act}
    run keyword and continue on failure
    ...    Should be true    ${info_scell_act['records_num']} == ${0}

verify decisionSCellMask when traffic is DL or both
    [Arguments]    ${info_scell_act}    ${iniNumSCellsToActivate}=1
    run keyword and continue on failure
    ...    Should be true    ${info_scell_act['records_num']} == ${2}
    run keyword and continue on failure
    ...    should be equal  ${info_scell_act['decisionSCellMask_for_all'][0]}    ${iniNumSCellsToActivate}
    run keyword and continue on failure
    ...    should be equal  ${info_scell_act['decisionSCellMask_for_all'][1]}    ${iniNumSCellsToActivate}


Get decisionSCellMask filter info from aasyslog
    [Documentation]  Author: Liu Zheng
    ...    ${filter}: grep criteria in aasyslog. e.g: cp\\|l2
    ...    ${connection}: if local: then support to execute on ute
    ...    Example output: dict with bellow format:
    ...    {records_num:1, timestamp_for_all:[time1, time2], decisionSCellMask_for_all=[1,1], timestamp_latest=time2}
    [Arguments]  ${aasyslog_log_path}    ${filter}    ${connection}=ASIK Master
    ${cmd_check_decisionSCellMask}    Set variable   cat ${aasyslog_log_path}|grep -ai "${filter}"|grep -av grep
    ${output}    Run keyword if    '${connection}'=='local'    Run    command=${cmd_check_decisionSCellMask}
    ...    ELSE    csn.execute    command=${cmd_check_decisionSCellMask}    connection=${connection}
    @{list_records}    split string    ${output}    \n
    Remove Values From List    ${list_records}   ${empty}
    ${len}    Get Length    ${list_records}
    &{dict_filter_info}    create dictionary    records_num=${len}
    @{list_time}    create list
    @{list_decisionSCellMask}    create list
    FOR    ${line}    IN    @{list_records}
        ${time}    Get Regexp Matches    ${line}    \\d{2}\\:\\d{2}\\:\\d{2}\\.[\\d|\\w]*
        ${decisionSCellMask}    Get Regexp Matches    ${line}    decisionSCellMask:(.*)    1
        ${decisionSCellMask_num}    set variable    ${decisionSCellMask[0]}
        append to list    ${list_time}    ${time}
        append to list    ${list_decisionSCellMask}    ${decisionSCellMask_num}
    END
    Set to dictionary    ${dict_filter_info}    timestamp_for_all=${list_time}    decisionSCellMask_for_all=${list_decisionSCellMask}
    Run keyword if    '${len}'=='0'    Set to dictionary    ${dict_filter_info}    timestamp_latest=${EMPTY}
    ...    ELSE    Set to dictionary    ${dict_filter_info}    timestamp_latest=${list_time[-1]}
    [Return]  ${dict_filter_info}

Check PM counter for A2 based pcell change M55145C03001 M55145C03002
    [Documentation]    author: Liu Zheng
    ...    M55145C03001:Nbr of A2 based inter-frequency intra-DU HO attempts for SA per PLMN-ID
    ...    M55145C03002:Nbr of A2 based successful inter-frequency intra-DU HOs for SA per PLMN-ID
    [Arguments]       ${starting_log_timestamp}
    ${pm_files_local_path}    Wait for PM file generated and download    starting_log_timestamp=${starting_log_timestamp}
#    ${cell_check_list}    create list     ${SCELL_ID}
    ${list_measurement_ids}    create list    M55145C03001    M55145C03002
    ${dict_measurements_value}    counter.get_total_cell_counter_from_multiple_files    list_file_path=${pm_files_local_path}
    ...      list_cell=${SCELL_ID_UL_ADD}    list_measurement_ids=${list_measurement_ids}

    ${M55145C03001}    set variable    ${dict_measurements_value['${SCELL_ID_UL_ADD[0]}']['M55145C03001']}
    ${M55145C03002}    set variable    ${dict_measurements_value['${SCELL_ID_UL_ADD[0]}']['M55145C03002']}
    run keyword and continue on failure     should be equal as strings      ${M55145C03001}       1
    run keyword and continue on failure     should be equal as strings      ${M55145C03002}       1

Check PM counter for A1 based pcell change M55145C02001 M55145C02002
    [Documentation]    author: Liu Zheng
    ...    M55145C02001: Nbr of A1 based inter-frequency intra-DU HO attempts for SA per PLMN-ID
    ...    M55145C02002: Nbr of A1 based successful inter-frequency intra-DU HOs for SA per PLMN-ID
    [Arguments]       ${starting_log_timestamp}
    ${pm_files_local_path}    Wait for PM file generated and download    starting_log_timestamp=${starting_log_timestamp}
#    ${cell_check_list}    create list     ${SCELL_ID}
    ${list_measurement_ids}    create list    M55145C02001    M55145C02002
    ${dict_measurements_value}    counter.get_total_cell_counter_from_multiple_files    list_file_path=${pm_files_local_path}
    ...      list_cell=${SCELL_ID_UL_ADD}    list_measurement_ids=${list_measurement_ids}

    ${M55145C02001}    set variable    ${dict_measurements_value['${SCELL_ID_UL_ADD[0]}']['M55145C02001']}
    ${M55145C02002}    set variable    ${dict_measurements_value['${SCELL_ID_UL_ADD[0]}']['M55145C02002']}
    run keyword and continue on failure     should be equal as strings      ${M55145C02001}       1
    run keyword and continue on failure     should be equal as strings      ${M55145C02002}       1

L3call with UL and DL CA and verify A2 configured on PCell
    [Documentation]    author: Cui Linguxe
    ${ute_log_path_f1ap_attach}    UE attach and verify Scell addition in tcpdump log
    ...    scell_index_ul=${SCELL_ID_UL_ADD}    scell_index_dl=${SCELL_ID_DL_ADD}
    ...    pcell_id=${PCELL_ID}    tcpdump_log_name=basic_l3_call    scell_addition_method=blind    ue_index=${0}
    ...    NSA_SA=${NSA_SA}    connection=GNB_OAM
    ...    gnb_index=${0}    actBufferBasedScellAddition=disabled

    Start data transfer based on direction    dl_tput=${DL_TPUT_IPERF}     ul_tput=${UL_TPUT_IPERF}    protocol=udp
    ...    duration=6000s    data_transfer_direction=both

    ${tput_log_path}    power_ue.Collect Tput     ue_type=${UE_TYPE}    duration=60s
    ...                   ignore_time=30s    filter=L2Lo
    run keyword and ignore error    check iperf process on appserver
    run keyword and continue on failure    Check tput via power UE optimized     cell_index=${CELL_INDEX_LIST}     tput_log_path=${tput_log_path}
    ...    direction=both    exp_ul=1    exp_dl=1    target_avg_percent=0.95    min_percent=0.85
    ...    exp_ul_indiv=${EXP_UL}    exp_dl_indiv=${EXP_DL}
    ...    is_need_to_fail_keyword=${True}
    ...    is_analysis_log_captured=${True}    bip_log_name=tput_validation_failed_9169_L3call_with_CA

    Verify A2 Configured On Pcell When Pcell Switch Enabled In Cpif Log
    ...    log_path_pcap=${ute_log_path_f1ap_attach}
