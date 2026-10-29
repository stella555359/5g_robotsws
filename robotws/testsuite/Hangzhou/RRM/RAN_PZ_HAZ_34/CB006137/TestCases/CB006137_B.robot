*** Settings ***
Documentation    6137-B cases
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB006137/Resources/CB006137_keywords.robot
Force Tags        5G_RRM    PY36    RF50
Suite Setup        Suite preparation
Suite Teardown     run keyword and ignore error    CA Suite teardown

*** Test Cases ***
# use static power split, this dynamic power split case is disabled
#[1]CB006137_BA_02_03_FDD_20Mhz_TDD_100Mhz_SingleUE_with_dynamic_UL_powerSharing_BF_enabled_RefineBeamDisabled
#    [Tags]    CRT_TRUNK
#    [Documentation]    author: Wang Yixiang \n
#    ...    This case is to verify dynamic UL power sharing
#    ...    Manual Guide:https://confluence.ext.net.nokia.com/display/5GRANHZ/power+split+-+pc3
#    ...    The execution order will be:
#    ...      1) UE attach and verify scell addition
#    ...      2) Start UL and DL traffic and verify UL and DL throughput
#    ...      3) Stop DL throughput
#    ...      4) set weightRatioOfUePwrScellVsPcell=WeightRatio 100
#    ...      5) Adjust Pcell and Scell signal bad to simulate UE move to cell edge(weightRatioOfUePwrScellVsPcell=WeightRatio 100)，
#    ...         and reach pscell suspend
#    ...      6) Adjust Pcell and Scell signal back to good and check pscell resume and UL throughput becomes good
#    ...      7) set weightRatioOfUePwrScellVsPcell=WeightRatio 0.01
#    ...      8) Adjust Pcell and Scell signal bad to simulate UE move to cell edge, and reach Scell suspend
#    ...      9) Restore Pcell and Scell signal good to simulate UE move from cell edge to cell center
#    ...      10) set weightRatioOfUePwrScellVsPcell=WeightRatio 1 and check UL throughput becomes good
#    ...      11) Stop data transmission and detach UE.
#    [Setup]    6137 Case setup    is_log_required=${False}   ca_group_mapping_3cc=${F1_F2_T1_3CC_CA_GROUP}
#    ...    ca_group_mapping_4cc=${F1_F2_T1_T2_4CC_CA_GROUP}
#    Run keyword and continue on failure    Modify NIDD by rest api and wait onair   parameters=${MODIFY_SCF_POWERSPLIT_PC3_API}
#    Run keyword and continue on failure    L3 call with UL or DL CA exist    cell_index=${CELL_INDEX_LIST}
#    ...    exp_ul_indiv=${EXP_UL_INDIV}    exp_dl_indiv=${EXP_DL_INDIV}    tput_duration=60s   is_need_to_stop_traffic=${False}
#    Run keyword and continue on failure    Stop data transfer based on direction   data_transfer_direction=dl
#    Run keyword and continue on failure    Set weightRatioOfUePwrScellVsPcell via restapi    value=WeightRatio 100
#    Run keyword and continue on failure    Adjust Pcell Scell signal and check powerState   powerStateInfo=pcellsuspend
#    ...   pa_value_list=${PCELL_SUPEND}    cell_idx_list=2,1
#    Run keyword and continue on failure    Adjust Pcell Scell signal and check powerState   powerStateInfo=pcellresume
#    ...   exp_pa_value=0    cell_idx_list=2,1    adjust_pa_slowly=${True}
#    Run keyword and continue on failure    Verify throughput as expect    cell_index=${CELL_INDEX_LIST}
#    ...    exp_ul_indiv=${EXP_UL_INDIV}    exp_dl_indiv=${None}   exp_dl=-1   exp_ul=1   data_transfer_direction=ul
#    Run keyword and continue on failure    Connect to gnb coam via ssl
#    Run keyword and continue on failure    Set weightRatioOfUePwrScellVsPcell via restapi    value=WeightRatio 0.01
#    Run keyword and continue on failure    Adjust Pcell Scell signal and check powerState   powerStateInfo=scellsuspend
#    ...   pa_value_list=${SCELL_SUPEND}    cell_idx_list=1,2
#    # not check scell resume as scell suspend and resume ping-pong and stay at resume state, and check UL throughput is normal
#    Run keyword and continue on failure    Adjust Pcell Scell signal and check powerState   powerStateInfo=scellresume
#    ...   exp_pa_value=0    cell_idx_list=1,2   check_flag=${False}
#    Run keyword and continue on failure    Verify throughput as expect    cell_index=${CELL_INDEX_LIST}
#    ...    exp_ul_indiv=${EXP_UL_INDIV}    exp_dl_indiv=${None}   exp_dl=-1   exp_ul=1   data_transfer_direction=ul
#    [Teardown]    run keyword and ignore error    Run keywords    Set weightRatioOfUePwrScellVsPcell via restapi    value=WeightRatio 1    AND
#    ...    Common case teardown    detach_ue=${True}

[1]CB006137_BB_IWK1_01_FDD_20Mhz_TDD_100Mhz_Radio link quality based SCell deactivation in UL CA_F_T_2F
    [Tags]             CRT_TRUNK
    [Documentation]    author: Wang Yixiang \n
    ...   This case to check UL rlq status for ULCA
    ...   *Manual Guide https://confluence.ext.net.nokia.com/display/5GRANHZ/Scell+radio+link+quality
    ...      1) UE attach and verify scell addition
    ...      2) Start UL/DL traffic and verify UL/DL throughput
    ...      3) Adjust attunation to bigger value to simulate UE move from cell center to cell edge,
    ...         move out of the UL coverage of joint DL/UL Scell
    ...      4) Check ul scell rlq turn to bad, check UL throughput scell suspend
    ...      5) Adjust attunation to smaller value to simulate UE move from cell edge to cell center,
    ...         move in of the UL coverage of joint DL/UL SCell again
    ...      6) Check ul scell rlq turn to good, check throughput of DL and UL is good
    ...      7-abandon) Stop UL data, only DL data is trasmission
    ...      8-abandon) Scell RLQ changed from good to bad, scell data suspened
    ...      9-abandon) Cell RLQ bad to good, data resume
    ...      10-abandon) Scell RLQ remain in bad, and bad RLQ count match, trigger scell deactive permanent
    ...      11-abandon) Scell RLQ back to good, no scell active triggered
    [Setup]    6137 Case setup    is_log_required=${False}   ca_group_mapping_3cc=${F1_F2_T1_3CC_CA_GROUP}
    ...    ca_group_mapping_4cc=${F1_F2_T1_T2_4CC_CA_GROUP}
    Run keyword and continue on failure    Modify NIDD by rest api and wait onair   parameters=${MODIFY_SCF_RLQ_API}
    Run keyword and continue on failure    L3 call with UL or DL CA exist    cell_index=${CELL_INDEX_LIST}    dl_tput_iperf=${DL_TPUT_IPERF_1070}
    ...    exp_ul_indiv=${EXP_UL_INDIV}    exp_dl_indiv=${EXP_DL_INDIV}    tput_duration=60s   is_need_to_stop_traffic=${False}

    ${rlq_exp_pa_value}    set variable if     '${MRBTS_ID}'=='10152' or '${MRBTS_ID}'=='1170'    30    25
    Run keyword and continue on failure    Adjust Pcell Scell signal and check RLQ state aasyslog
    ...    messageInfo=ul scell rlq turn to bad    pa_start=0    pa_end=${rlq_exp_pa_value}    aasyslog_name=aasyslog_bad.txt

    Run keyword and continue on failure    Verify throughput as expect    cell_index=${CELL_INDEX_LIST}
    ...    exp_ul_indiv=${EXP_UL_INDIV_SCELL_SUSPEND}    exp_dl_indiv=${EXP_DL_INDIV_NO_CHECK}

    Run keyword and continue on failure    Adjust Pcell Scell signal and check RLQ state aasyslog
    ...   messageInfo=ul scell rlq turn to good    pa_start=0    pa_end=0    aasyslog_name=aasyslog_good.txt

#    Comment TPUT check due to bellow CNN PR. It's due to UE behavior is abnormal.
#    QCOM SDX 75 / 80 all have this issue and QCOM ticket is raised for tracking.
#    PR806804: [CIT][CRT][AEHC][RLQ] UL TP on TDD scell not resumed after Radio Link Quality turn to good while DL TP can reach to peak
#    Run keyword and continue on failure    Verify throughput as expect    cell_index=${CELL_INDEX_LIST}
#    ...    exp_ul_indiv=${EXP_UL_INDIV}    exp_dl_indiv=${EXP_DL_INDIV}    check_tput_ignore_time=40s

#    abandon UL only RLQ steps due to invalid PRs/Effots
#    Log to console    Start DL RLQ testing ...
#    Modify radio link monitoring parameters work on scell    cell_index=${SCELL_ID_UL_ADD}[0]
#    ...    badrlqcount=${SCELL_BAD_RLQ_COUNT}      period=${SCELL_CHANNEL_ESTIMATION_PERIOD}
#    Run keyword and continue on failure    Stop data transfer based on direction   data_transfer_direction=ul
#
#    run keyword and continue on failure        Verify scell data suspened and not deactivated when scell rlq in bad 4cc
#    ...         pa_scell_rlq_bad=${SCELL_LOW_THAN_BAD_MCS}
#
#    run keyword and continue on failure      Verify scell data resumed when scell rlq back to good 4cc
#    ...             pa_scell_rlq_good=${SCELL_GOOD_RLQ}
#
#    ${SCELL_BAD_RLQ_COUNT}   set variable    3
#    Modify radio link monitoring parameters work on scell    cell_index=${SCELL_ID_UL_ADD}[0]
#    ...    badrlqcount=${SCELL_BAD_RLQ_COUNT}      period=${SCELL_CHANNEL_ESTIMATION_PERIOD}
#    ${scell_deactivate_time}  evaluate  ${SCELL_BAD_RLQ_COUNT}*(${SCELL_CHANNEL_ESTIMATION_PERIOD})/1000+40
#    ${ru_idx_list}    Get RU index list by cell ID    cell_idx_list=${SCELL_ID_UL_ADD}
#
#    run keyword and continue on failure      Verify scell permanent deactivated when scell rlq remain in bad
#    ...             pa_scell_rlq_bad=${SCELL_LOW_THAN_BAD_MCS}    scell_deactivate_time=${scell_deactivate_time}
#    ...             scell_id=${SCELL_ID_UL_ADD}[0]    scell_operator_mode=dl_only   scell_ru_index=${ru_idx_list}[0]
#
#    run keyword and continue on failure    Verify scell not activate when rlq bad into good after scell permanent deactivated
#    ...          scell_rlq_good=${SCELL_GOOD_RLQ}   scell_ru_index=${ru_idx_list}[0]
#
#    ${EXP_DL_INDIV_BAD}    Create List    ${EXP_DL_F20M_2x2_256QAM_POOL}    ${EXP_DL_F10M_2x2_256QAM_POOL}
#    ...    0    ${EXP_DL_T60M_2x2_256QAM_1070}
#    Run keyword and continue on failure    Verify throughput as expect    cell_index=${CELL_INDEX_LIST}
#    ...    exp_ul_indiv=${None}    exp_dl_indiv=${EXP_DL_INDIV_BAD}   exp_dl=1   exp_ul=-1   data_transfer_direction=dl
#    ...    min_percent=0.4    tput_duration=30s    check_tput_ignore_time=10s

    [Teardown]    run keyword and ignore error    Common case teardown    detach_ue=${True}

[1]CB006137_BA_04_01_Online_modification_of_parameter_for_scell_selection
    [Tags]    CRT_TRUNK
    [Documentation]   author: Fang ludan
    ...    This case is to verify scell selection when change dlToUlContributionRatio
    ...    The execution order will be:
    ...      1) set dlToUlContributionRatio=101
    ...      2) UE attach and Start UL and DL traffic
    ...      3) change dlToUlContributionRatio=100
    ...      4) UE detach and reattach Start UL and DL traffic
    ...      5) change dlToUlContributionRatio=10
    ...      6) UE detach and reattach Start UL and DL traffic
    ...      7) check counter
    [Setup]    case setup for sl
    Log To Console   set dlToUlContributionRatio=101
    Set dlToUlContributionRatio via restapi   value=${101}
    run keyword and continue on failure     L3 call with UL or DL CA exist
    ...    cell_index=${CELL_LIST_100}
    ...    scell_index_ul=${SCELL_LIST_100_UL}
    ...    scell_index_dl=${SCELL_LIST_100}
    ...    exp_ul_indiv=${EXP_UL_INDIV_100}
    ...    exp_dl_indiv=${EXP_DL_INDIV_100}
    ...    dl_tput_iperf=${DL_TPUT_IPERF_1070}
#    add name
    Log To Console   set dlToUlContributionRatio=100
    Set dlToUlContributionRatio via restapi  value=${100}
    run keyword and continue on failure     L3 call with UL or DL CA exist
    ...    cell_index=${CELL_LIST_100}
    ...    scell_index_ul=${SCELL_LIST_100_UL}
    ...    scell_index_dl=${SCELL_LIST_100}
    ...    exp_ul_indiv=${EXP_UL_INDIV_100}
    ...    exp_dl_indiv=${EXP_DL_INDIV_100}

    ${case_start_time_info}    Prepare for counter log
    Log To Console   set dlToUlContributionRatio=10
    Set dlToUlContributionRatio via restapi  value=${10}
    run keyword and continue on failure     L3 call with UL or DL CA exist
    ...    cell_index=${CELL_LIST_10}
    ...    scell_index_ul=${SCELL_LIST_10_UL}
    ...    scell_index_dl=${SCELL_LIST_10}
    ...    exp_ul_indiv=${EXP_UL_INDIV_10}
    ...    exp_dl_indiv=${EXP_DL_INDIV_10}
    run keyword and ignore error       check counter M55118C10001 M55118C10002 M55118C10005 M55118C10006
    ...      starting_log_timestamp=${case_start_time_info['log_generator_timestamp']}
    ...      counter_expected_number=${1}


    [Teardown]     run keyword and ignore error   run keywords  Common case teardown    detach_ue=${True}
    ...    AND    Initialize attenuator values for testline  pa_values_mapping=${INIT_PA_F1_F2_T1_T2}

[1]CB006137_BA_IWK14_01_ScellChange_targetScellHaveULCA_mixedCA_3cc_withrsrp_for_mixedCA
    [Tags]    CRT_TRUNK
    [Documentation]    author: Fang ludan
    ...    This case is to verify scell change when Pcell signal change from bad to good
    ...    The execution order will be:
    ...      1) adjust PA , a1ThresholdSCellAddSsbRsrpFDD<rsrp<a1ThresholdSCellAddSsbRsrpTDD
    ...      2) UE attachdui only FDD add
    ...      3) Start UL and DL traffic
    ...      4) adjust PA , rsrp>a1ThresholdSCellAddSsbRsrpTDD
    ...      5) check scell change status, FDD change to TDD
    ...      6) verify UL and DL throughput
    [Setup]    case setup for scell change
    ${CA_GROUP_TYPE}   Set variable  F+F+T
    Set test variable    ${CA_GROUP_TYPE}
    Online modify A1 ScellAddition A2 ScellRelease parameters
    ...        pcell_index=${PCELL_ID}
    ...        scell_index=${SCELL_ID_UL_ADD}
    Prepare NRREL under specific cell    ca_group_mapping=${F1_F2_T1_NOT2_NOT3_3CC_CA_GROUP_covbasedA1}
    ${Pcell_RU_Index}   set variable    ${NR_CELL_ID_MAPPING[${PCELL_ID}]['ruIndex_in_init']}
    ${A1_configured_log_path}    Adjust Pcell Signal Bad to do UE attach and A1 event configured for scell addition
    ...       pcell_exp_pa_value=${PCELL_BAD}      NSA_SA=${NSA_SA}
    ...       pcell_ru_index= ${Pcell_RU_Index}

    ${a1ReportId}        Get reportConfigId for special measEvent in F1AP log     log_path_pcap=${A1_configured_log_path}
    ...        measEvent=eventA1
    Log To Console   Adjust Pcell Signal as Good To Trigger FDD add

    ${A2_configured_log_path}       Adjust Pcell Signal as Good To Trigger A1 Report on Pcell and Do Scell Addition
    ...        pcell_exp_pa_value=${PCELL_GOOD_FOR_FDD_ADD}   pcell_ru_index=${Pcell_RU_Index}
    ...        a1_rsrp_thres=${A1_THRESHOLD_SCELL_ADD_SSB_RSRP_FDD}      a1_meas_id=${a1ReportId}
    ...        a2_meas_for_scell_released=${False}    scell_index_dl=${SCELL_ID_DL_ADD[0]}
    ...        tcpdump_log_name=CA_A1_Report_When_Pcell_Good_FDD
    Start data transfer based on direction
    ...    dl_tput=${DL_TPUT_IPERF_1070}     ul_tput=${UL_TPUT_IPERF}    duration=3000s

    Run keyword and continue on failure    Verify throughput as expect    cell_index=${CELL_LIST_F_F}
    ...    exp_ul_indiv=${EXP_2CC_F_F_UL_INDIV}    exp_dl_indiv=${EXP_2CC_F_F_DL_INDIV}

    Log To Console   Adjust Pcell Signal as Good To Trigger TDD add

    ${A2_configured_log_path}       Adjust Pcell Signal as Good To Trigger A1 Report on Pcell and Do Scell Addition noA1check
    ...        pcell_exp_pa_value=${PCELL_GOOD}   pcell_ru_index=${Pcell_RU_Index}
#    ...        a1_rsrp_thres=${A1_THRESHOLD_SCELL_ADD_SSB_RSRP}      a1_meas_id=${a1ReportId}
    ...        a2_meas_for_scell_released=${False}
    ...        scell_index_ul=${SCELL_ID_UL_ADD}     scell_index_dl=${SCELL_ID_DL_ADD[1]}
    ...        tcpdump_log_name=CA_A1_Report_When_Pcell_Good_TDD

    Run keyword and continue on failure    Verify throughput as expect    cell_index=${CELL_LIST_F_T}
    ...    exp_ul_indiv=${EXP_2CC_F_T_UL_INDIV}    exp_dl_indiv=${EXP_2CC_F_T_DL_INDIV}
    [Teardown]     run keyword and ignore error   run keywords   Common case teardown    detach_ue=${True}
    ...    AND    Initialize attenuator values for testline  pa_values_mapping=${INIT_PA_F1_F2_T1_T2}


[1]CB006137_BA_IWK15_01_Scell_stepwise_Release_based_A2_and_release_scell_configure_UL_CA_FDD+TDD+TDD_DL3CCUL2CC
    [Tags]    CRT_TRUNK
    [Documentation]    author: Fang ludan
    ...    This case is to verify scell setp release when scell signal become bad
    ...    The execution order will be:
    ...      1) set scell-1 has higher NRBTS/NRCELL/a2MeasSCellRelSsbRsrp than sCell-2
    ...      2) UE attach and verify scell addition
    ...      3) Start UL traffic and verify UL throughput
    ...      4) Adjust Pcell and Scell signal bad to simulate UE move to cell edge,
    ...         and reach scell2 A2 release ,check scell2 release
    ...      5) still Adjust Pcell and Scell signal bad to simulate UE move to cell edge,
    ...         and reach scell1 A2 release ,check scell1 release
    ...      6) Stop data transmission and detach UE.
    [Setup]    case setup for scell relese
    Online modify A1 ScellAddition A2 ScellRelease parameters
    ...        pcell_index=${PCELL_ID}
    ...        scell_index=${SCELL_ID_DL_ADD}
    Prepare NRREL under specific cell    ca_group_mapping=${F1_T1_T2_NOF2_NOT3_3CC_CA_GROUP_covbasedA1}
    run keyword and continue on failure     L3 call with UL or DL CA exist
    ...    cell_index=${CELL_INDEX_LIST}
    ...    scell_index_ul=${SCELL_ID_UL_ADD}
    ...    scell_index_dl=${SCELL_ID_DL_ADD}
    ...    exp_ul_indiv=${EXP_3CC_UL_INDIV}
    ...    exp_dl_indiv=${EXP_3CC_DL_INDIV}
    ...    is_need_to_stop_traffic=${False}
    ...    dl_tput_iperf=${DL_TPUT_IPERF_1070}

    ${case_start_time_info}    Prepare for counter log

    Log To Console   Adjust scell Signal to trigger release scell with ULandDL
    Adjust Scells And Pcell Signal as Bad To Trigger A2 Report and Scells Released
    ...            pcell_exp_pa_value=${PCELL_BAD}         scell_exp_pa_value=${SCELL_A2_RELEASED_PA}
    ...            pcell_id=${PCELL_ID}    scell_id_list=${DL_ONLY_SCELL}
    ...            scell_index_list_check=${scell_index_list_check_scecond_release}

    log To Console   Adjust scell Signal to trigger release scell with onlyDL
    Adjust Scells And Pcell Signal as Bad To Trigger A2 Report and Scells Released
    ...            pcell_exp_pa_value=${PCELL_BAD}         scell_exp_pa_value=${SCELL_A2_RELEASED_PA}
    ...            pcell_id=${PCELL_ID}    scell_id_list=${UL_DL_SCELL}

    run keyword and continue on failure       check counter M55118C10003 M55118C10004
    ...      starting_log_timestamp=${case_start_time_info['log_generator_timestamp']}   cell_id=${PCELL_ID}
    ...      counter_expected_number=${1}

    [Teardown]     run keyword and ignore error   run keywords    Common case teardown    detach_ue=${True}
    ...    AND    Initialize attenuator values for testline  pa_values_mapping=${INIT_PA_F1_F2_T1_T2}




*** Keywords ***
Suite preparation
    [Arguments]     ${cell_chbw_config}=4CC_F20M_T100M_F10M_T60M
    6137 Suite preparation    swconfig_modify=${SWCONFIG_6137_SYSLOG_INFO}
    ...    pa_values_mapping=${INIT_PA_F1_F2_T1_T2}
    ...    cell_chbw_config=${cell_chbw_config}
    ...    ca_group_mapping_3cc=${F1_F2_T1_3CC_CA_GROUP}
    ...    ca_group_mapping_4cc=${F1_F2_T1_T2_4CC_CA_GROUP}
    Set tput expectation for suite level

Set tput expectation for suite level
    ${EXP_3CC_DL_INDIV}    Create List    ${EXP_DL_F20M_2x2_256QAM_POOL}    ${EXP_DL_F10M_2x2_256QAM_POOL}    ${EXP_DL_T100M_4x4_256QAM_1070}
    ${EXP_3CC_DL_INDIV_NO_CHECK}    Create List    -1   -1    -1
    ${EXP_3CC_UL_INDIV}    Create List    ${EXP_UL_F20M_2x2_64QAM}    -1    ${EXP_UL_T100M_2x2_64QAM_1070}
    ${EXP_3CC_UL_INDIV_SCELL_SUSPEND}    Create List    ${EXP_UL_F20M_2x2_64QAM_PA_BAD}    -1    0

    ${EXP_4CC_DL_INDIV}    Create List    ${EXP_DL_F20M_2x2_256QAM_POOL}    ${EXP_DL_F10M_2x2_256QAM_POOL}
    ...    ${EXP_DL_T100M_4x4_256QAM_1070}    ${EXP_DL_T60M_2x2_256QAM_1070}
    ${EXP_4CC_DL_INDIV_NO_CHECK}    Create List    -1   -1    -1   -1
    ${EXP_4CC_UL_INDIV}    Create List    ${EXP_UL_F20M_2x2_64QAM}    -1    ${EXP_UL_T100M_2x2_64QAM_1070}   -1
    ${EXP_4CC_UL_INDIV_SCELL_SUSPEND}    Create List    ${EXP_UL_F20M_2x2_64QAM_PA_BAD}    -1    0   -1

    run keyword if    '${CC_NUM}'=='3CC'    Run keywords
    ...    Set suite variable    ${EXP_DL_INDIV}    ${EXP_3CC_DL_INDIV}    AND
    ...    Set suite variable    ${EXP_UL_INDIV}    ${EXP_3CC_UL_INDIV}    AND
    ...    Set suite variable    ${EXP_DL_INDIV_NO_CHECK}    ${EXP_3CC_DL_INDIV_NO_CHECK}    AND
    ...    Set suite variable    ${EXP_UL_INDIV_SCELL_SUSPEND}    ${EXP_3CC_UL_INDIV_SCELL_SUSPEND}
    ...    ELSE    Run keywords
    ...    Set suite variable    ${EXP_DL_INDIV}    ${EXP_4CC_DL_INDIV}    AND
    ...    Set suite variable    ${EXP_UL_INDIV}    ${EXP_4CC_UL_INDIV}    AND
    ...    Set suite variable    ${EXP_DL_INDIV_NO_CHECK}    ${EXP_4CC_DL_INDIV_NO_CHECK}    AND
    ...    Set suite variable    ${EXP_UL_INDIV_SCELL_SUSPEND}   ${EXP_4CC_UL_INDIV_SCELL_SUSPEND}

Set dlToUlContributionRatio via restapi
    [Documentation]  Author: fang ludan
    ...      1) Set dlToUlContributionRatio:
    [Arguments]  ${connection}=GNB_OAM   ${value}=101
    ${nidd_dlToUlContributionRatio_value}    evaluate
    ...    [dict(dist_name='${DN_NRBTS}/NRDU-${1}', parameter='dlToUlContributionRatio', value='${value}')]

    coam_gnb_classical.COAM Update several parameters via rest api
    ...    parameters_to_update_via_api=${nidd_dlToUlContributionRatio_value}    timeout=${TIMER_FOR_MODIFY_VIA_API}
    ...    connection=${connection}


    Wait until cluster ready based on NSA_SA type        NSA_SA=${NSA_SA}

case setup for sl
    6137 Case setup    ca_group_mapping_3cc=${F1_F2_T1_T2_4CC_CA_GROUP}
    ...  ca_group_mapping_4cc=${F1_F2_T1_T2_T3_5CC_CA_GROUP}   exp_cc_num_in_use=4CC
    run keyword if  '${CC_NUM}'=='3CC'  set SL list 3CC   ELSE   set SL list 4CC
    Set weightForSCellSelection via restapi
    ${PCELL_ID}   Create List  ${PCELL_ID}
    ${CELL_LIST_100}    combine lists  ${PCELL_ID}   ${SCELL_LIST_100}
    ${CELL_LIST_10}    combine lists  ${PCELL_ID}   ${SCELL_LIST_10}
    Set test variable   ${CELL_LIST_100}
    Set test variable   ${CELL_LIST_10}

case setup for scell relese
    6137 Case setup   ca_group_mapping_3cc=${F1_T1_T2_NOF2_NOT3_3CC_CA_GROUP}
    ...    ca_group_mapping_4cc=${F1_T1_T2_NOF2_NOT3_3CC_CA_GROUP}
    ${EXP_3CC_DL_INDIV}    Create List    ${EXP_DL_F20M_2x2_256QAM_POOL}    ${EXP_DL_T100M_4x4_256QAM_1070}    ${EXP_DL_F20M_2x2_256QAM_POOL}
    ${EXP_3CC_UL_INDIV}    Create List    ${EXP_UL_F20M_2x2_64QAM}    ${EXP_UL_T100M_2x2_64QAM}      -1
    ${UL_DL_SCELL}    Create List    ${SCELL_ID_DL_ADD[0]}
    ${DL_ONLY_SCELL}    Create List    ${SCELL_ID_DL_ADD[1]}
    ${scell_index_list_check_scecond_release}    Create List    2
    Set test variable   ${EXP_3CC_DL_INDIV}
    Set test variable   ${EXP_3CC_UL_INDIV}
    Set test variable   ${UL_DL_SCELL}
    Set test variable   ${DL_ONLY_SCELL}
    Set test variable   ${scell_index_list_check_scecond_release}

case setup for scell change
    6137 Case setup   ca_group_mapping_3cc=${F1_F2_T1_NOT2_NOT3_3CC_CA_GROUP}
    ...    ca_group_mapping_4cc=${F1_F2_T1_NOT2_NOT3_3CC_CA_GROUP}
    ${EXP_2CC_F_F_DL_INDIV}    Create List    ${EXP_DL_F20M_2x2_256QAM_POOL_PA_BAD}    ${EXP_DL_F10M_2x2_256QAM_POOL}
    ${EXP_2CC_F_F_UL_INDIV}    Create List    ${EXP_UL_F20M_2x2_64QAM}        -1
    ${EXP_2CC_F_T_DL_INDIV}    Create List    ${EXP_DL_F20M_2x2_256QAM_POOL}    ${EXP_DL_T60M_2x2_256QAM_1070}
    ${EXP_2CC_F_T_UL_INDIV}    Create List    ${EXP_UL_F20M_2x2_64QAM}       ${EXP_UL_T60M_2x2_64QAM}
    ${CELL_LIST_F_F}    Create List   ${PCELL_ID}   ${SCELL_ID_DL_ADD[0]}
    ${CELL_LIST_F_T}    Create List   ${PCELL_ID}   ${SCELL_ID_DL_ADD[1]}
    Set test variable   ${EXP_2CC_F_F_DL_INDIV}
    Set test variable   ${EXP_2CC_F_F_UL_INDIV}
    Set test variable   ${EXP_2CC_F_T_DL_INDIV}
    Set test variable   ${EXP_2CC_F_T_UL_INDIV}
    Set test variable   ${CELL_LIST_F_F}
    Set test variable   ${CELL_LIST_F_T}

set SL list 4CC
    ${SCELL_LIST_100}    Create List   ${SCELL_ID_DL_ADD[0]}    ${SCELL_ID_DL_ADD[2]}  ${SCELL_ID_DL_ADD[3]}
    ${SCELL_LIST_10}    Create List  ${SCELL_ID_DL_ADD[0]}    ${SCELL_ID_DL_ADD[1]}  ${SCELL_ID_DL_ADD[2]}
    ${SCELL_LIST_100_UL}  Set variable  ${None}
    ${SCELL_LIST_10_UL}   Create List     ${SCELL_ID_UL_ADD[0]}
    ${EXP_UL_INDIV_100}   Create List    ${EXP_UL_F20M_2x2_64QAM}   0    0    0
    ${EXP_UL_INDIV_10}    Create List    ${EXP_UL_F20M_2x2_64QAM}      0    ${EXP_UL_T100M_2x2_64QAM}    0
    ${EXP_DL_INDIV_100}   Create List    ${EXP_DL_F20M_2x2_256QAM_POOL}    ${EXP_DL_F10M_2x2_256QAM_POOL}
    ...                                  ${EXP_DL_F10M_2x2_256QAM_POOL}  ${EXP_DL_T20M_2x2_256QAM}
    ${EXP_DL_INDIV_10}    Create List    ${EXP_DL_F20M_2x2_256QAM_POOL}    ${EXP_DL_F10M_2x2_256QAM_POOL}
    ...                              ${EXP_DL_F10M_2x2_256QAM_POOL}  ${EXP_DL_F10M_2x2_256QAM_POOL}
    Set test variable   ${SCELL_LIST_100_UL}
    Set test variable   ${SCELL_LIST_10_UL}
    Set test variable   ${SCELL_LIST_100}
    Set test variable   ${SCELL_LIST_10}
    Set test variable    ${EXP_UL_INDIV_100}
    Set test variable    ${EXP_UL_INDIV_10}
    Set test variable    ${EXP_DL_INDIV_100}
    Set test variable    ${EXP_DL_INDIV_10}

set SL list 3CC
    ${SCELL_LIST_100}    Create List   ${SCELL_ID_DL_ADD[0]}    ${SCELL_ID_DL_ADD[2]}
    ${SCELL_LIST_10}    Create List  ${SCELL_ID_DL_ADD[1]}    ${SCELL_ID_DL_ADD[2]}
    ${SCELL_LIST_100_UL}  Set variable  ${None}
    ${SCELL_LIST_10_UL}   Create List    ${SCELL_ID_UL_ADD[0]}
    ${EXP_UL_INDIV_100}   Create List    ${EXP_UL_F20M_2x2_64QAM}   0  0
    ${EXP_UL_INDIV_10}    Create List    ${EXP_UL_F20M_2x2_64QAM}    ${EXP_UL_T100M_2x2_64QAM}   0
    ${EXP_DL_INDIV_100}   Create List    ${EXP_DL_F20M_2x2_256QAM_POOL}    ${EXP_DL_F10M_2x2_256QAM_POOL}  ${EXP_DL_F10M_2x2_256QAM_POOL}
    ${EXP_DL_INDIV_10}    Create List    ${EXP_DL_F20M_2x2_256QAM_POOL}    ${EXP_DL_F10M_2x2_256QAM_POOL}  ${EXP_DL_F10M_2x2_256QAM_POOL}
    Set test variable   ${SCELL_LIST_100_UL}
    Set test variable   ${SCELL_LIST_10_UL}
    Set test variable    ${EXP_UL_INDIV_100}
    Set test variable    ${EXP_UL_INDIV_10}
    Set test variable    ${EXP_DL_INDIV_100}
    Set test variable    ${EXP_DL_INDIV_10}
    Set test variable   ${SCELL_LIST_100}
    Set test variable   ${SCELL_LIST_10}

Online modify A1 ScellAddition A2 ScellRelease parameters
    [Documentation]    author: ludan.fang@nokia-sbell.com
    ...   Currently just consider one Scell.
    [Arguments]       ${pcell_index}=${PCELL_ID}
    ...               ${scell_index}=${SCELL_ID_DL_ADD}
    ${a2ThresholdSCellRelSsbRsrp}    Create List    ${65}    ${50}
    Modify sCell addition method to covBasedA1   cell_index=${pcell_index}
    ...                                          a1ThresholdSCellAddSsbRsrp_TDD=${A1_THRESHOLD_SCELL_ADD_SSB_RSRP}
    ...                                          a1ThresholdSCellAddSsbRsrp_FDD=${70}

    FOR    ${index}   ${cell_index}  IN ENUMERATE  @{scell_index}
        ${cell_index}    Evaluate    int(${cell_index})
        Configure A2 Measurement For SCell Release Enabled     cell_index=${cell_index}
        ...                                          a2ThresholdSCellRelSsbRsrp=${a2ThresholdSCellRelSsbRsrp[${index}]}
    END

Set weightForSCellSelection via restapi
    [Documentation]  Author: fang ludan
    ...      1) Set weightForSCellSelection:
    [Arguments]  ${connection}=GNB_OAM    ${paras}=${MODIFY_weightForSCellSelection_3CC}
    ${paras}    Set variable if    '${CC_NUM}'=='3CC'    ${MODIFY_weightForSCellSelection_3CC}
    ...    '${CC_NUM}'=='4CC' and 'sdx75' in @{tl.ues[0].capabilities}    ${MODIFY_weightForSCellSelection_4CC_X75}
    ...     ${MODIFY_weightForSCellSelection_4CC}
    coam_gnb_classical.COAM Update several parameters via rest api
    ...    parameters_to_update_via_api=${paras}    timeout=${TIMER_FOR_MODIFY_VIA_API}
    ...    connection=${connection}

    Wait until cluster ready based on NSA_SA type        NSA_SA=${NSA_SA}

check counter M55118C10003 M55118C10004
    [Documentation]     author: ludan.fang@nokia-sbell.com
    ...      Following counter will be counted under Pcell
    ...      M55118C10003: This counter shows the number of initiated RRC Reconfiguration messages in SA mode releasing 1
    ...      S-Cell in UL based on A2 measurement on S-Cell.
    ...      M55118C10004: This counter shows the number of successful RRC Reconfiguration procedures in SA mode releasing
    ...      1 S-Cell in UL based on A2 measurement on S-Cell.
    [Arguments]       ${starting_log_timestamp}   ${cell_id}=1   ${counter_expected_number}=${1}
    ${pm_files_local_path}    Wait for PM file generated and download    starting_log_timestamp=${starting_log_timestamp}
    ${cell_check_list}    create list     ${cell_id}
    ${list_measurement_ids}    create list    M55118C10003    M55118C10004
    ${dict_measurements_value}    counter.get_total_cell_counter_from_multiple_files
    ...      list_file_path=${pm_files_local_path}      list_cell=${cell_check_list}
    ...      list_measurement_ids=${list_measurement_ids}

    ${scell_M55118C10003}    set variable    ${dict_measurements_value['${cell_id}']['M55118C10003']}
    ${scell_M55118C10004}    set variable    ${dict_measurements_value['${cell_id}']['M55118C10004']}
    run keyword and continue on failure   run keywords    Should be true      ${scell_M55118C10003}>=${counter_expected_number}
    ...                                        AND        Should be true      ${scell_M55118C10004}>=${counter_expected_number}

check counter M55118C10001 M55118C10002 M55118C10005 M55118C10006
    [Documentation]     author: ludan.fang@nokia-sbell.com
    ...      Following counter will be counted under Scell
    ...      scell_M55118C10001: This counter indicates the total number of RRC Reconfiguration attempts
    ...      for 1 S-Cell Addition in UL for SA mode.
    ...      scell_M55118C10002: This counter indicates the total number of successful RRC Reconfiguration attempts
    ...      for 1 S-Cell Addition in UL for SA mode.
    [Arguments]       ${starting_log_timestamp}   ${cell_id}=${CELL_INDEX_LIST}   ${counter_expected_number}=${1}
    ${pm_files_local_path}    Wait for PM file generated and download    starting_log_timestamp=${starting_log_timestamp}
    ${cell_check_list}    create list     ${cell_id}
    ${list_measurement_ids}    create list    M55118C10001    M55118C10002   M55118C10005  M55118C10006
    ${dict_measurements_value}    counter.get_total_cell_counter_from_multiple_files
    ...      list_file_path=${pm_files_local_path}      list_cell=${cell_check_list}
    ...      list_measurement_ids=${list_measurement_ids}

    ${scell_M55118C10001}    set variable    ${dict_measurements_value[${CELL_INDEX_LIST[0]}]['M55118C10001']}
    ${scell_M55118C10002}    set variable    ${dict_measurements_value[${CELL_INDEX_LIST[0]}]['M55118C10002']}
    ${scell_M55118C10005}    set variable    ${dict_measurements_value[${CELL_INDEX_LIST[0]}]['M55118C10005']}
    ${scell_M55118C10006}    set variable    ${dict_measurements_value[${CELL_INDEX_LIST[2]}]['M55118C10006']}
    run keyword and continue on failure   run keywords    Should be true      ${scell_M55118C10001}>=${counter_expected_number}
    ...                                        AND        Should be true      ${scell_M55118C10002}>=${counter_expected_number}
    ...                                        AND        Should be true      ${scell_M55118C10005}>=${counter_expected_number}
    ...                                        AND        Should be true      ${scell_M55118C10006}>=${counter_expected_number}

Adjust Pcell Signal as Good To Trigger A1 Report on Pcell and Do Scell Addition noA1check
    [Documentation]    Author: ludan Fang
    ...      Note: It is just called when scell addition method as covBasedA1
    ...      a2_meas_for_scell_released control whether need to check A2 configured for Scell release, False no check
    ...                                         true need to check
    [Arguments]    ${tcpdump_log_name}=CA_A1_Report_When_Pcell_Good
    ...            ${pcell_exp_pa_value}=${0}       ${pcell_ru_index}=${PCELL_RU_INDEX}
#    ...            ${a1_rsrp_thres}=${80}     ${a1_meas_id}=${1}
    ...            ${a2_meas_for_scell_released}=${False}
    ...            ${scell_index_ul}=${None}     ${scell_index_dl}=${SCELL_ID}
    Prepare and start aasyslog
    Start capture F1AP log    tcpdump_collector_name=${tcpdump_log_name}    options=-i any sctp
    log to console    Tune PA to trigger UE A1 measurement report
    Initialize attenuator for specified RU     exp_pa_value=${pcell_exp_pa_value}    ru_index=${pcell_ru_index}
    sleep    5s    msg=Wait for UE send A1 measurement report.

    ${ute_log_path}    Stop tcpdump log collection    tcpdump_collector_name=${tcpdump_log_name}

    # no need to check A2 configured on which cell.
    run keyword if      ${a2_meas_for_scell_released}         Verify A2 event configed in F1AP log
    ...     log_path_pcap=${ute_log_path}

    run keyword and continue on failure    Verify scell addition from f1ap log    log_file_path=${ute_log_path}
    ...     scell_index_ul=${scell_index_ul}    scell_index_dl=${scell_index_dl}

    ${is_scell_activated}    Run keyword and return status    Stop aasyslog to check scell activation
    should be true    ${is_scell_activated}
    [Return]    ${ute_log_path}
    [Teardown]    run keyword and ignore error    Run keywords    Stop Tcpdump via collector
    ...       tcpdump_collector_name=${tcpdump_log_name}    AND
    ...       Teardown the Aasyslog save progress
