*** Settings ***
Documentation    T+F CA
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB009169/Resources/CB009169_keywords.robot
Force Tags        5G_RRM   PY36    RF50

Suite Setup        Suite preparation    frame_structure=1116
Suite Teardown     run keyword and ignore error    CA Suite teardown


*** Test Cases ***
CB009169-SR_BE_B8_015_ABIO_TDD_100Mhz_FDD_20Mhz_Reset_L2_RT_A1_ScellAddition_A2_ScellReleased_BF_Enable
    [Documentation]    Author:Liu Zheng
    ...    ***This user scenario describes 5G L2 RT SW reset for UEs configured for Carrier Aggregation.
    ...    ***After L2RT SW reset, for the L2RT related loki and cell, throughput on this cell will be 0. Throughput on other cells no impact.
    ...    ***There will be fault 4383 and fault 6450 report in this case.
    ...    ***And snapshot will be collected in case teardowm to cancel the fault 6450.
    ...    ***This case use cell1,2,5,3 for CA testing.
    [Setup]    9169 Case setup    dict_params_to_modify=${ENABLE_A1_SCELL_ADDITION_A2_SCELL_RELEASE_API}
    log to console    \n##step1. L3 call and check throughput\n
    Run keyword and continue on failure    L3 call with UL or DL CA exist    cell_index=${CELL_INDEX_LIST}
    ...    exp_ul_indiv=${EXP_UL_INDIV_1116}    exp_dl_indiv=${EXP_DL_INDIV_1116}    tput_duration=60s
    ...    iperf_duration=6000S   is_need_to_stop_traffic=${False}    is_analysis_log_captured=${True}
    ...    bip_log_name=tput_validation_failed_Step1_L3_call_with_CA

    log to console    \n##step2. Trigger L2RT SW reset. the fault_4383 report and cells related restarted container disabled, wait cell on air\n
    AlarmWatchdog.add_allow_alarms    fault_id=4383
    AlarmWatchdog.add_allow_alarms    fault_id=6450
    Recover L2RT
    AlarmWatchdog.remove_allow_alarms    fault_id=4383
    log to console    \n##step3. after L2RT SW reset, for the L2RT related loki and cell, throughput on this cell will be 0.\n
    ${EXP_DL_INDIV_CELL3_lokib}    Create List    ${EXP_DL_T100M_4x4_256QAM_1116}  ${EXP_DL_F20M_2x2_256QAM}
    ...    ${EXP_DL_T60M_4x4_256QAM_1116}    0
    set test variable    ${EXP_DL_INDIV_CELL3_lokib}
    run keyword and continue on failure    Verify throughput as expect    cell_index=${CELL_INDEX_LIST}
    ...    exp_ul_indiv=${EXP_UL_INDIV_1116}    exp_dl_indiv=${EXP_DL_INDIV_CELL3_lokib}     check_tput_ignore_time=40s
    ...    is_analysis_log_captured=${True}    bip_log_name=tput_validation_failed_Step3_after_L2RT_SW_Reset
    Run keyword and continue on failure    Stop data transfer based on direction   data_transfer_direction=both
    Run keyword and ignore error    power_ue.UE Detach    ue_type=${UE_TYPE}    ue_index=${0}

    log to console    \n##step5. A1 configured after attach with Pcell signal bad\n
    ${Pcell_RU_Index}   set variable    ${NR_CELL_ID_MAPPING[${PCELL_ID}]['ruIndex_in_init']}
    ${A1_configured_log_path}    Adjust Pcell Signal Bad to do UE attach and A1 event configured for scell addition
    ...       pcell_exp_pa_value=${PCELL_BAD}      NSA_SA=${NSA_SA}
    ...       pcell_ru_index= ${Pcell_RU_Index}
    ${a1ReportId}        Run keyword and continue on failure    Get reportConfigId for special measEvent in F1AP log
    ...     log_path_pcap=${A1_configured_log_path}        measEvent=eventA1

    log to console    \n##step6. A1 report and scell addition\n
    ${A2_configured_log_path}  Run keyword and continue on failure  Adjust Pcell Signal as Good To Trigger A1 Report on Pcell and Do Scell Addition
    ...        pcell_exp_pa_value=${PCELL_GOOD}   pcell_ru_index=${Pcell_RU_Index}
    ...        a1_rsrp_thres=${A1_THRESHOLD_SCELL_ADD_SSB_RSRP}      a1_meas_id=${a1ReportId}
    ...        a2_meas_for_scell_released=${True}
    ...        scell_index_ul=${SCELL_ID_UL_ADD}     scell_index_dl=${SCELL_ID_DL_ADD}
    ${a2ReportId}  Run keyword and continue on failure  Get reportConfigId for special measEvent in F1AP log   log_path_pcap=${A2_configured_log_path}
    ...        measEvent=eventA2

    log to console    \n##ste7. start bi-direction data transfer and check the throughput can peak\n
    run keyword and continue on failure    Start data transfer based on direction  dl_tput=${DL_TPUT_IPERF}   ul_tput=${UL_TPUT_IPERF}  protocol=udp
    ...    duration=3000s    data_transfer_direction=both

    run keyword and continue on failure    Verify throughput as expect    cell_index=${CELL_INDEX_LIST}
    ...    exp_ul_indiv=${EXP_UL_INDIV_1116}    exp_dl_indiv=${EXP_DL_INDIV_1116}     check_tput_ignore_time=40s    is_analysis_log_captured=${True}
    ...    bip_log_name=tput_validation_failed_Step7

    log to console    \n##step8. make scell quality goes bellow the A2 threshold, scell-ToBeRemoved-List IE in F1AP, this scell no throughput\n

    run keyword and continue on failure    Adjust Scells And Pcell Signal as Bad To Trigger A2 Report and Scells Released
    ...            pcell_exp_pa_value=${PCELL_BAD}         scell_exp_pa_value=${SCELL_A2_RELEASED_PA}
    ...            pcell_id=${PCELL_ID}    scell_id_list=${SCELL_ID_UL_ADD}

    Set attenuator ports of specified RUs to same value    exp_pa_value=${PCELL_GOOD}    ru_idx_list=0
    Set attenuator ports of specified RUs to same value    exp_pa_value=${SCELL_GOOD}    ru_idx_list=1

    ${EXP_DL_INDIV_SCELL_REL}    Create List    ${EXP_DL_T100M_4x4_256QAM_1116}  0
    ...    ${EXP_DL_T60M_4x4_256QAM_1116}    90
    set test variable    ${EXP_DL_INDIV_SCELL_REL}
    ${EXP_UL_INDIV_SCELL_REL}    Create List    ${EXP_UL_T100M_2x2_64QAM_1116}  0    -1    -1
    set test variable    ${EXP_UL_INDIV_SCELL_REL}
    run keyword and continue on failure    Verify throughput as expect    cell_index=${CELL_INDEX_LIST}
    ...    exp_ul_indiv=${EXP_UL_INDIV_SCELL_REL}     exp_dl_indiv=${EXP_DL_INDIV_SCELL_REL}      check_tput_ignore_time=40s
    ...    is_analysis_log_captured=${True}    bip_log_name=tput_validation_failed_Step8_scell_released

    [Teardown]    run keyword and ignore error    BE_B8_015 collect snapshot and case teardown


CB009169-SR_BA_B11_025_FR1_ULCA_is_preferred_even_it_cannot_bring_bigger_DL+UL_datarate_with_dlToUlcontributionRatio_50_with_frame_structure
    [Documentation]    Author:Liu Zheng
    ...    this case mainly test the cell selection after the CNI81817 enabled.
    ...    1. enable CNI81817(actHighestEstNrTputBcSel),
    ...    2. set the fr1UlCaPreferred to default value(dataRatePreferred), there will be no UL CA,
    ...       and the pcell UL throughput is 2 layer which is about 151M
    ...    3. set the fr1UlCaPreferred to ulCaPrefered, there will be UL CA.
    ...    ***This case use cell1,2,5,3 for CA testing.
    [Setup]    9169 Case setup
    log to console    \n##step1. ENable CIN81817\n
    COAM Update several parameters via rest api    parameters_to_update_via_api=${SCF_ENABLE_CNI81817_API}

    log to console    \n##step2. set the fr1UlCaPreferred to default value(dataRatePreferred), and check the throughput,
     ...    there should no UL CA and the pcell UL is 2 layer, throughout is about 150M\n
    COAM Update several parameters via rest api    parameters_to_update_via_api=${SCF_UPDATE_FR1ULCAPREFERRED_DATARATEPREFERRED_API}

    Run keyword and continue on failure    L3 call with UL or DL CA exist    scell_index_ul=${None}    cell_index=${CELL_INDEX_LIST}
    ...    exp_ul_indiv=${EXP_UL_INDIV_1116_NO_UL_SCELL}     exp_dl_indiv=${EXP_DL_INDIV_1116}    tput_duration=60s
    ...    iperf_duration=6000S   is_need_to_stop_traffic=${True}


    log to console    \n##step3. set the fr1UlCaPreferred to ulCaPrefered, and check the throughput,
     ...    there is UL CA and the pcell UL is 1 layer, there is scell UL throught, each UL is one layer.\n
    COAM Update several parameters via rest api    parameters_to_update_via_api=${SCF_UPDATE_FR1ULCAPREFERRED_ULCAPREFERRED_API}

    Run keyword and continue on failure    L3 call with UL or DL CA exist    cell_index=${CELL_INDEX_LIST}
    ...    exp_ul_indiv=${EXP_UL_INDIV_1116}    exp_dl_indiv=${EXP_DL_INDIV_1116}    tput_duration=60s
    ...    iperf_duration=6000S   is_need_to_stop_traffic=${True}

    [Teardown]    run keyword and ignore error    Common case teardown    detach_ue=${True}

*** Keywords ***
Suite preparation
    [Arguments]    ${frame_structure}
    set suite variable    ${INIT_PA}    ${INIT_PA_T1_F1_T3_F2}
    9169 Suite preparation    cell_chbw_config=4CC_T100M_F20M_F10M_T60M
    ...    pa_values_mapping=${INIT_PA}
    ...    ca_group_mapping_3cc=${T1_F1_F2_3CC_CA_GROUP_COMMON}
    ...    ca_group_mapping_4cc=${T1_F1_T3_F2_4CC_CA_GROUP_COMMON}
    ...    frame_structure=${frame_structure}
    Set tput expectation for suite level

Set tput expectation for suite level
    ${EXP_DL_INDIV_1116}    Create List    ${EXP_DL_T100M_4x4_256QAM_1116}    ${EXP_DL_F20M_2x2_256QAM}
    ...    ${EXP_DL_T60M_4x4_256QAM_1116}    ${EXP_DL_F10M_2x2_256QAM}
    ${EXP_UL_INDIV_1116}    Create List    ${EXP_UL_T100M_2x2_64QAM_1116}    ${EXP_UL_F20M_2x2_64QAM_1116}  -1    -1
    ${EXP_UL_INDIV_1116_NO_UL_SCELL}    Create List   ${EXP_UL_T100M_2x2_64QAM_1116_NO_ULCA}    -1    -1    -1

    Set suite variable    ${EXP_DL_INDIV_1116}
    Set suite variable    ${EXP_UL_INDIV_1116}
    Set suite variable    ${EXP_UL_INDIV_1116_NO_UL_SCELL}


9169 Pcell id and scell id and expected throughput redefined in order to match with different pcell
    [Documentation]    Author: zheng.4.liu@nokia-sbell.com
    ...    Happened when A1 based or A2 based PSCell triggered.
    [Arguments]    ${ca_group_type}=T+F_9169_4CC
    ${EXP_DL_INDIV_1116_6137}  Create List  ${EXP_DL_F20M_2x2_256QAM}    ${EXP_DL_F10M_2x2_256QAM}
    ...    ${EXP_DL_T100M_4x4_256QAM_1116}   ${EXP_DL_F10M_2x2_256QAM}
    ${EXP_UL_INDIV_1116_6137}  Create List  ${EXP_UL_F20M_2x2_64QAM_1116}    ${EXP_UL_T100M_2x2_64QAM_1116}    -1    -1

    run keyword if    '${ca_group_type}'=='T+F_9169_4CC'   Run Keywords
    ...       Set suite variable    ${CA_GROUP_MAPPING}    ${T1_F1_T3_F2_4CC_CA_GROUP_COMMON}
    ...       AND    set test variable   ${PCELL_ID}    ${CA_GROUP_MAPPING['pcell_id']}
#    ...       AND    set test variable   ${PCELL_RU_INDEX}    ${NR_CELL_ID_MAPPING[${PCELL_ID}]['ruIndex_in_init']}
    ...       AND    set test variable   ${PCELL_RU_INDEX}    ${CA_GROUP_MAPPING['pcell_id']['ru_index_in_testline_file']}
    ...       AND    set test variable   ${SCELL_UL_RU_INDEX}     ${CA_GROUP_MAPPING['verify_scell_add_ul']['ru_index_in_testline_file']}
    ...       AND    set test variable   ${SCELL_ID_UL_ADD}    ${CA_GROUP_MAPPING['verify_scell_add_ul']}
    ...       AND    set test variable   ${SCELL_ID_DL_ADD}    ${CA_GROUP_MAPPING['verify_scell_add_dl']}
    ...       AND    set test variable   ${EXP_DL}    ${EXP_DL_INDIV_1116}
    ...       AND    set test variable   ${EXP_UL}    ${EXP_UL_INDIV_1116}
    ...       AND    set test variable   ${CA_GROUP_TYPE}    T+F_9169_4CC
    ...       ELSE    Run Keywords    Set suite variable    ${CA_GROUP_MAPPING}    ${F1_F2_T1_T2_4CC_CA_GROUP_6137}
    ...       set test variable   ${PCELL_ID}    ${CA_GROUP_MAPPING['pcell_id']}
    ...       AND    set test variable   ${PCELL_RU_INDEX}    ${CA_GROUP_MAPPING['pcell_id']['ru_index_in_testline_file']}
    ...       AND    set test variable   ${SCELL_UL_RU_INDEX}     ${CA_GROUP_MAPPING['verify_scell_add_ul']['ru_index_in_testline_file']}
    ...       AND    set test variable   ${SCELL_ID_UL_ADD}    ${CA_GROUP_MAPPING['verify_scell_add_ul']}
    ...       AND    set test variable   ${SCELL_ID_DL_ADD}    ${CA_GROUP_MAPPING['verify_scell_add_dl']}
    ...       AND    set test variable   ${EXP_DL}    ${EXP_DL_INDIV_1116_6137}
    ...       AND    set test variable   ${EXP_UL}    ${EXP_UL_INDIV_1116_6137}
    ...       AND    Set suite variable  ${CELL_INDEX_LIST}
    ...       AND    set test variable   ${CA_GROUP_TYPE}    F+T_6137_4CC

Adjust PA and verify Pcell change successful
    [Documentation]    author: zheng.4.liu@nokia-sbell.com
    ...   when test 8542 A1 and A2 PSCell change, both need to adjust the TDD cell signal.
    ...   New scell added after Pcell switch
    ...   Pcell ID should be changed to Scell ID and old Scell released
    [Arguments]    ${tcpdump_log_name}=pcell_switch_triggered
    ...   ${pcell_change_type}=A1
    Start capture F1AP log    tcpdump_collector_name=${tcpdump_log_name}_${pcell_change_type}    options=-i any sctp

    Set Test Variable    ${TDD_Cell_id}    ${PCELL_ID}    ${T1_F1_T3_F2_4CC_CA_GROUP_COMMON['pcell_id']}
    Set Test Variable    ${TDD_RU_index}      ${T1_F1_T3_F2_4CC_CA_GROUP_COMMON['pcell_id']['ru_index_in_testline_file']}
    run keyword if    '${pcell_change_type}'=='A1'    Set attenuator ports of specified RUs to same value
    ...    exp_pa_value=${PA_A1_BASED_PCELL_SWTICH}    ru_idx_list=${TDD_RU_index}
    ...    ELSE    Set attenuator ports of specified RUs to same value
    ...    exp_pa_value=${PA_A2_BASED_PCELL_SWTICH}    ru_idx_list=${TDD_RU_index}

    sleep    15s
    ${PSCell_change_log}    Stop tcpdump log collection    tcpdump_collector_name=${tcpdump_log_name}_${pcell_change_type}

    run keyword if   '${pcell_change_type}'=='A1'    run keyword and continue on failure
    ...    Verify A1 report for scell to trigger pcell switch in cpif log
    ...    log_path_pcap=${PSCell_change_log}        a1_rsrp_thres=${A1_THRESHOLD_PCELL_SWITCH_SSB_RSRP}
    ...    ELSE    run keyword and continue on failure     Verify A2 report for pcell to trigger pcell swith in cpif log
    ...    log_path_pcap=${PSCell_change_log}     a2_rsrp_thres=${A2_THRESHOLD_PCELL_SWITCH_SSB_RSRP}

    run keyword and continue on failure     Verify Pcell ID Changed after pcell switch through RRC reconfiguration
    ...         log_path_pcap=${PSCell_change_log}

    run keyword and continue on failure     Verify new scell add after pcell switch through RRC Info
    ...         log_path_pcap=${PSCell_change_log}


UE attach start traffic and check scells activate according to ADR
    [Documentation]  Author: Liu Zheng
    ...    1. If the request come from DL branch, gNB selects SCells to activate according to ADR, no matter DL only SCell or joint DL/UL SCell.\n
    ...    2. If the request come from UL branch, gNB selects the only 1 joint DL/UL SCell to activate.\n
    ...    3. If the request come from both UL and DL branch, gNB selects the only 1 joint DL/UL SCell to activate firstly, \n
    ...    then if more SCell activation is need according to NIDD:iniNumSCellsToActivate, gNB selects DL only SCells according to ADR.\n
    ...    check scell activate according to ADR by bellow msg in aasyslog\n
    ...    INF//L2-PS/src/dl/sch/ca/RemoteDlSCellActivationManagerLog.hpp[69] ue rnti:58449 decisionSCellMask:1\n
    [Arguments]    ${file_name_scell_act_one_by_one}    ${connection}=ASIK Master
    ...    ${scell_index_ul}=${SCELL_ID_UL_ADD}    ${scell_index_dl}=${SCELL_ID_DL_ADD}    ${pcell_id}=${PCELL_ID}
    ...    ${tcpdump_log_name}=basic_l3_call    ${scell_addition_method}=covBasedA1   ${ue_index}=${0}   ${NSA_SA}=${NSA_SA}
    ...    ${dl_tput_iperf}=${DL_TPUT_IPERF}    ${ul_tput_iperf}=${UL_TPUT_IPERF}    ${protocol}=udp    ${iperf_duration}=3000s
    ...    ${data_transfer_direction}=both    ${connection_gnb_oam}=GNB_OAM    ${need_attach_step}=${True}    ${is_need_to_stop_traffic}=${False}
    ...    ${traffic_need_to_stop}=${None}
    ${pcell_RU_Index}   set variable    ${NR_CELL_ID_MAPPING[${pcell_id}]['ruIndex_in_init']}

    run keyword if    ${need_attach_step}=${True}
    ...    Set attenuator ports of specified RUs to same value    exp_pa_value=${PCELL_BAD}    ru_idx_list=${pcell_RU_Index}
    run keyword if    ${need_attach_step}=${True}
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
    ...    ELSE IF    '${data_transfer_direction}'=='dl'       run keyword and continue on failure    Verify throughput as expect
    ...    cell_index=${CELL_INDEX_LIST}    exp_ul_indiv=${None}    exp_dl_indiv=${EXP_DL_INDIV_1116}     check_tput_ignore_time=40s
    ...    ELSE    run keyword and continue on failure    Verify throughput as expect
    ...    cell_index=${CELL_INDEX_LIST}    exp_ul_indiv=${EXP_UL_INDIV_1116}    exp_dl_indiv=${EXP_DL_INDIV_1116}     check_tput_ignore_time=40s


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

BE_B8_015 collect snapshot and case teardown
    [Documentation]  Author: Wang Yixiang
    ...    As in step2. Trigger L2RT SW reset will trigger FID:6450, madatory collect snapshot to eliminate FID:6450
    COAM Save snapshot via webUI    download_dir=${TS_CASE_LOG_PATH}   url=https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...    username=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...    password=${tl.gnbs[0].cu.oam_http_connection_details.password}
    AlarmWatchdog.remove_allow_alarms    fault_id=6450
    Common case teardown    detach_ue=${True}
