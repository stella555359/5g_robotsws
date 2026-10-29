*** Settings ***
Documentation    F+T CA cases
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB006137/Resources/CB006137_keywords.robot
Resource    ../Resources/CB006137_C_B27_01_keywords.robot
Resource    ../Resources/scellSwap_iwk_RRE.resource
Force Tags        5G_RRM
...   PY36    RF50

Suite Setup        Suite preparation
Suite Teardown     run keyword and ignore error    CA Suite teardown


*** Test Cases ***
CB006137-AB_01_US01_FDD_20Mhz_TDD_100Mhz_UL_DL_Traffic_BF_Disabled_Blind_ScellActivated
    [Tags]    CRT_TRUNK
    [Documentation]    This case is to verify if peak throughput can be reached on both UL and DL.
    ...    The execution order will be:
    ...      1) UE attach and verify no scell addition since CB008311 is enabled
    ...      2) Start UL traffic and verify UL throughput: No UL CA
    ...      3) Stop UL traffic
    ...      4) Start DL traffic and verify DL throughput: DL CA exist
    ...      5) Start UL traffic and verify bi-direction throughput
    ...      6) Stop data transmission and detach UE.
    [Setup]    6137 Case setup    dict_params_to_modify=${RESTAPI_ACT_CB008311_DICT}
    ULCA_peak_tput_verification    cell_index=${CELL_INDEX_LIST}
    ...    exp_ul_indiv=${EXP_UL_INDIV}    exp_dl_indiv=${EXP_DL_INDIV}
    [Teardown]    run keyword and ignore error    Common case teardown    detach_ue=${True}        is_btslog_required=${False}
    ...    restapi_restore_nidd=${RESTAPI_DISABLE_CB008311_BTS_LEVEL}

CB006137-AA_11_2ABIO_ULCA_FDD_20Mhz_TDD_100Mhz_ULCA_deactivated_When_delete_sCellAdditionMethod_and_NRREL object
    [Tags]    CRT_TRUNK
    [Documentation]  Author: Ding Binmei
    ...    1. Check UL DL L3 call before doing any oprations
    ...    2. Remove ca_Fdd_Fr1Tdd_Sa_WithUl from carrierAggregationSupportList and verify related PDL error reported:
    ...    3.  Remove UL CA related config and verify Only DL CA exist
    ...        3.1 Remove ca_Fdd_Fr1Tdd_Sa_WithUl from carrierAggregationSupportList
    ...        3.2 Set NRREL.sCellOperationalMode as dlOnly for all nrrel under pcell
    ...        3.3 Update dlToUlContributionRatio to 101 since ca_Fdd_Fr1Tdd_Sa_WithUl has removed, otherwise PDL error will be displayed
    ...        3.4 Active update and verify DL CA works normal
    ...    4. Remove ca_Fdd_Fr1Tdd_Sa from carrierAggregationSupportList and verify PDL error:
    ...       PDL error reported"If current NRCELL supports FDD, and there is a NRREL with sCellAdditionMethod defined and NRCELL corresponding to
    ...       this NRREL supports TDD, then NRBTS/NRDU.carrierAggregationSupportList must support ca_Fdd_Fr1Tdd_Sa or ca_Fdd_Fr1Tdd_Nsa"
    ...    5. Remove sCellAdditionMethod and sCellOperationalMode and verify no CA
    ...    6. Add back sCellAdditionMethod(blind) sCellOperationalMode(dlOnly) and verify DL CA is OK
    ...    7. Add back ca_Fdd_Fr1Tdd_Sa to carrierAggregationSupportList and verify only DL CA exist
    ...    8. Update sCellOperationalMode to dlAndUl and restore dlToUlContributionRatio and verify UL DL CA is OK
    ...    9. Remove NRREL and verify no CA exists
    ...      Capture F1AP while doing remove NRREL MO:
    ...       a). Verify Pcell lock unlock happened
    ...       b). Verify scell is not added during ue attach via F1AP
    ...       c). Verify no dl tput for scell
    ...    10. Add back NRREL with sCellOperationalMode set to dlAndUl and verify UL DL CA is OK
    [Setup]    6137 Case setup
    Run keyword if    '${testline_name}' == '7_5_UTE5G402T254'    nidd_modify.online_modify_nidd_parameters_via_restapi
    ...    params_modify_dict=${RESTAPI_ACT_CB012269}    timeout=${TIMER_FOR_MODIFY_VIA_API}
    Run keyword and continue on failure    L3 call with UL or DL CA exist    cell_index=${CELL_INDEX_LIST}
    ...    target_avg_percent=${TPUT_AVG_PERCENT_COMMON}    min_percent=${TPUT_MIN_PERCENT_COMMON}
    ...    tcpdump_log_name=S1_L3_call_ca_inital    is_need_to_stop_traffic=${True}
    ...    customized_log_name=S1_L3_call_UL_DL
    Run keyword and continue on failure    AA_11_S2 Remove ca_Fdd_Fr1Tdd_Sa_WithUl from carrierAggregationSupportList and verify PDL error
    Run keyword and continue on failure    AA_11_S3 Remove UL CA related config and verify Only DL CA exist
    Run keyword and continue on failure    AA_11_S4 Remove ca_Fdd_Fr1Tdd_Sa from carrierAggregationSupportList and verify PDL error
    Run keyword and continue on failure    AA_11_S5 Remove sCellAdditionMethod and verify no CA
    Run keyword and continue on failure    AA_11_S6 Add back sCellAdditionMethod and verify DL CA is OK
    Run keyword and continue on failure
    ...    AA_11_S7 Add UL DL to carrierAggregationSupportList and verify only DL CA exist
    Run keyword and continue on failure
    ...    AA_11_S8 Update sCellOperationalMode to dlAndUl and restore dlToUlContributionRatio and verify UL DL CA is OK
    Run keyword and continue on failure    AA_11_S9 Remove NRREL and verify no CA exists
    Run keyword and continue on failure    AA_11_S10 Add back NRREL with sCellOperationalMode set to dlAndUl and verify UL DL CA is OK
    [Teardown]  run keyword and ignore error    Common case teardown    detach_ue=${True}    is_scf_restore=${True}
    ...    scf_file_path_for_restore=${scf_file_path_for_restore}      is_onair_check=${True}    onair_timeout=${TIMER_FOR_CELL_ON_AIR}
    ...    is_log_required=${IS_LOG_CAPTURED_CASE_LEVEL}    is_btslog_required=${False}

CB006137-AB_10_US07_FDD_20Mhz_TDD_100Mhz_Scell_BufferBased_DLOrULTraffic_ActivateScell_BF_Enabled_A1_ScellAddition_A2_ScellReleased
    [Tags]  CIT_TRUNK
    [Documentation]    author: dandan.fang@nokia-sbell.com
    ...   Precondition:  covBasedA1 configured for Pcell, A2 Meas release for Scell
    ...   Step1:A1 configured after attach with Pcell signal bad
    ...   Step2:A1 report and scell addition , inactivate when Pcell signal change to good
    ...   Step3:Scell activate when UL traffic increase from small to big for bufferbased
    ...   Step4:Scell activate when DL traffic increase from small to big for bufferbased
    ...   Step5:Scell deactivate when DL traffic stop with Bufferbased
    ...   Step6:A2 report and scell released when scell signal and pcell in bad
    ...   Ste76:Scell addition again when Pcell signal change to Good
    [Setup]    Buffer Case setup

    #6137 case choose scell which suppot UL to configure A2 event
    Online modify A1 ScellAddition A2 ScellRelease parameters
    ...        pcell_index=${PCELL_ID}    a1ThresholdSCellAddSsbRsrp_TDD=${A1_THRESHOLD_SCELL_ADD_SSB_RSRP}
    ...        a1ThresholdSCellAddSsbRsrp_FDD=${A1_THRESHOLD_SCELL_ADD_SSB_RSRP}
    ...        scell_index=${SCELL_ID_DL_ADD}      a2ThresholdSCellRelSsbRsrp=${A2_THRESHOLD_SCELL_REL_SSB_RSRP}

    #Step1:A1 configured after attach with Pcell signal bad
    ${Pcell_RU_Index}   set variable    ${NR_CELL_ID_MAPPING[${PCELL_ID}]['ruIndex_in_init']}
    ${A1_configured_log_path}    Adjust Pcell Signal Bad to do UE attach and A1 event configured for scell addition
    ...       pcell_exp_pa_value=${PCELL_BAD}      NSA_SA=${NSA_SA}
    ...       pcell_ru_index= ${Pcell_RU_Index}

    ${a1ReportId}        Get reportConfigId for special measEvent in F1AP log     log_path_pcap=${A1_configured_log_path}
    ...        measEvent=eventA1

    #Step2:A1 report and scell addition , inactivate when Pcell signal change to good
    ${A2_configured_log_path}       Adjust Pcell Signal as Good To Trigger A1 Report on Pcell and Do Scell Addition
    ...        pcell_exp_pa_value=${PCELL_GOOD}   pcell_ru_index=${Pcell_RU_Index}
    ...        a1_rsrp_thres=${A1_THRESHOLD_SCELL_ADD_SSB_RSRP}      a1_meas_id=${a1ReportId}
    ...        a2_meas_for_scell_released=${True}
    ...        scell_index_ul=${SCELL_ID_UL_ADD}     scell_index_dl=${SCELL_ID_DL_ADD}

    ${a2ReportId}        Get reportConfigId for special measEvent in F1AP log     log_path_pcap=${A2_configured_log_path}
    ...        measEvent=eventA2

    ${case_start_time_info}    Prepare for counter log

    run keyword and continue on failure    UL Only traffic increase from Small to Big to trigger Scell Activated For Bufferbased
    ...               cell_index=${CELL_INDEX_LIST}
    ...               ulTraffic_small_iperf=${BufferBase_UL_TRAFFIC_SMALL}     ulTraffic_big_iperf=${BufferBase_UL_TRAFFIC_Big}

    run keyword and continue on failure    Stop DL or UL traffic stop to check Scell deactivated for Bufferbased
    ...            data_transfer_direction=ul    expect_scell_deactivated=${True}
    ...            scell_id=${SCELL_ID_UL_ADD}      scell_operator_mode=dlAndUl

    run keyword and continue on failure    DL Only traffic increase from Small to Big to trigger Scell Activated For Bufferbased
    ...               cell_index=${CELL_INDEX_LIST}
    ...               dlTraffic_small_iperf=${BufferBase_DL_TRAFFIC_SMALL}     dlTraffic_big_iperf=${BufferBase_DL_TRAFFIC_Big}

    ${list_dl_scell_operational_mode}      Get scell OperatorMode info base on Scell DL List     dl_scell_list=${SCELL_ID_DL_ADD}
    ...       ca_group_mapping=${CA_GROUP_MAPPING}

    run keyword and continue on failure    Stop DL or UL traffic stop to check Scell deactivated for Bufferbased
    ...            data_transfer_direction=dl    expect_scell_deactivated=${True}
    ...            scell_id=${SCELL_ID_DL_ADD}      scell_operator_mode=${list_dl_scell_operational_mode}

    run keyword and continue on failure       check Scell activations M55316C09000 Scell Deactivation due to Buffer M55316C09001
    ...      starting_log_timestamp=${case_start_time_info['log_generator_timestamp']}   scell_id=${SCELL_ID_UL_ADD}[0]
    ...      counter_expected_number=${2}

    #Scell ID special defined, if 2CC, it is better to choose scell which support UL.
    Adjust Scells And Pcell Signal as Bad To Trigger A2 Report and Scells Released
    ...            pcell_exp_pa_value=${PCELL_BAD}         scell_exp_pa_value=${SCELL_A2_RELEASED_PA}
    ...            pcell_id=${PCELL_ID}    scell_id_list=${SCELL_ID_DL_ADD}

    Adjust Pcell Scell Signal Back To Good To Trigger A1 Scell Addition Again
    ...            pcell_exp_pa_value=${INIT_PA}
    ...            scell_index_ul=${SCELL_ID_UL_ADD}     scell_index_dl=${SCELL_ID_DL_ADD}

    [Teardown]     run keyword and ignore error      run keywords    Common case teardown    detach_ue=${True}
    ...        is_btslog_required=${False}
    ...    AND    Initialize attenuator values for testline  pa_values_mapping=${INIT_PA}

[1]CB006137-C_US-IWK12_01_A6BasedScellSwap_Scell_BF_enabled_ConfigurationIndependent_F_F_T_Scell_DlUL_Swap
    [Tags]    CRT_TRUNK
    [Documentation]    author: journey.jin@nokia-sbell.com
    ...  Step1: configured A1 scell addition,enable A6 scell swap parameters
    ...  Step2: configure 3cc and decode ca mapping
    ...  Step3: check CA setup and UL DL trafic
    ...  Step4: adjust source scell signal is bad,target scell is good,trigger a6 measurement report
    ...  Step5: check scell swap successful
    ...  Step6: check UL DL traffic after scell swap
    ...  Step7: check PM counter M55118C10501 M55118C10502
    ...  Step8: repeat step 3-7 for ul only to verify PR681986
    ...    Ding Binmei 2025-2-10: Add regression for 04307958_Customer_pronto_regression_ScellSwap_iwk_RRE_Main_steps
    [Setup]    Case setup for scell swap    ca_group_mapping=${F1_T1_T2_3CC_CA_SCELL_SWAP}    exp_cc_num=3CC

    ${traffic_direction_list}    Run keyword if    '${PROGRAM}'=='master'    Create List    ul
    ...    ELSE    Create List    both    ul

    FOR    ${traffic_direction}    IN    @{traffic_direction_list}

        ${exp_dl_indiv_before_scell_swap}    set variable if    '${traffic_direction}' == 'both'    ${EXP_DL_INDIV}    ${None}
        ${exp_dl_indiv_after_scell_swap}    set variable if    '${traffic_direction}' == 'both'    ${EXP_DL_INDIV_AFTER_SWAP}    ${None}

        Run keyword and continue on failure    L3 call with UL or DL CA exist    cell_index=${CELL_INDEX_LIST}
        ...    target_avg_percent=${TPUT_AVG_PERCENT_COMMON}    min_percent=${TPUT_MIN_PERCENT_COMMON}    is_need_to_stop_traffic=${False}
        ...    data_transfer_direction=${traffic_direction}    exp_dl_indiv=${exp_dl_indiv_before_scell_swap}
        ...    exp_ul_indiv=${EXP_UL_INDIV}

        #trigger A6 scell swap
        ${starting_log_timestamp}    Prepare for counter log
        ${Source_Scell_RU_Index}   set variable    ${NR_CELL_ID_MAPPING[${SCELL_ID_UL_ADD[0]}]['ruIndex_in_init']}
        ${Target_Scell_RU_Index}   set variable    ${NR_CELL_ID_MAPPING[${TARGET_SCELL_ID}]['ruIndex_in_init']}
        Adjust PA and verify scell swap successful   source_scell_ru_index=${Source_Scell_RU_Index}   target_scell_ru_index=${Target_Scell_RU_Index}

        #init PA to check Tput
        Initialize attenuator values for testline    pa_values_mapping=${INIT_PA_F1_T1_F2_T3}
        ${tput_log_path}    power_ue.Collect Tput     ue_type=${UE_TYPE}    duration=60s    ignore_time=30s
        ...     filter=L2Lo

        Run keyword and continue on failure    Check tput via power UE optimized     cell_index=${CELL_INDEX_LIST_AFTER_SCELL_SWAP}
        ...    tput_log_path=${tput_log_path}    direction=${traffic_direction}
        ...    exp_ul=1    exp_dl=1    target_avg_percent=${TPUT_AVG_PERCENT_COMMON}    min_percent=${TPUT_MIN_PERCENT_COMMON}
        ...    exp_ul_indiv=${EXP_UL_INDIV}    exp_dl_indiv=${exp_dl_indiv_after_scell_swap}    connection=GNB_OAM
        ...    customized_log_name=Tput_after_scell_swap    is_need_to_fail_keyword=${True}
        ...    is_analysis_log_captured=${False}

        run keyword and continue on failure    Check PM counter M55118C10501 M55118C10502
        ...    starting_log_timestamp=${starting_log_timestamp['log_generator_timestamp']}

        Run keyword and continue on failure    Stop data transfer and detach UE    data_transfer_direction=${traffic_direction}
        Run keyword and continue on failure    Initialize attenuator values for testline    pa_values_mapping=${INIT_PA_BEFORE_SCELL_SWAP}
    END
    Run keyword if    '${PROGRAM}'=='master'    04307958_Customer_pronto_regression_ScellSwap_iwk_RRE_Main_steps
    [Teardown]     run keyword and ignore error      run keywords
    ...    Common case teardown    detach_ue=${True}    is_scf_restore=${True}    scf_file_path_for_restore=${scf_file_path_for_restore}
    ...        is_btslog_required=${False}    is_onair_check=${True}    onair_timeout=${TIMER_FOR_CELL_ON_AIR}
    ...    AND    Initialize attenuator values for testline  pa_values_mapping=${INIT_PA}

CB006137_C_US_B27_01_FDD_20Mhz_TDD_100Mhz_Single_UE_call_setup_with_transform_precoder_activated
    [Documentation]  Author: Ding Binmei
    ...    Introduced by big effort PR698968
    ...    Precondition for this case is: UE with PC3 capbility.
    ...    ---If ue cap doesn't fullfil the precondition then will skip the case steps. https://jiradc.ext.net.nokia.com/browse/REX-21398
    ...    Set actUlDftSOfdm to true for Pcell && Scell(sCellOperationalMode=dlAndUl), Monitor pcell SINR.
    ...    If pcell signal change to bad, TP will be activated, and scell ul transmission will be suspended. no affect for scell Dl
    ...        pcell dl tput will decrease due to signal change to bad
    ...    When pcell signal recovered. TP will be disabled. And traffic for scell ul recovered.
    ...    It will validate peak tput in this case
    [Setup]  C_B27_01_Case_setup
    Pass Execution If    'sdx75' in @{tl.ues[0].capabilities}    message=UE does not support PC3 and skip the rest steps
    Run keyword and continue on failure    L3 call with UL or DL CA exist    cell_index=${CELL_INDEX_LIST}
    ...    target_avg_percent=${TPUT_AVG_PERCENT_PEAK}    min_percent=${TPUT_MIN_PERCENT_PEAK}
    ...    tcpdump_log_name=S1_L3_call_ca_inital    is_need_to_stop_traffic=${False}
    ...    customized_log_name=S1_L3_call_UL_DL
    Run keyword and continue on failure    C_B27_01_S1_Adjust pcell signal from good to bad and verify transform Precoder is enabled for pcell
    Run keyword and continue on failure    C_B27_01_S2_Verify Scell ul transmission suspend after transform Precoder enabled for pcell
    Run keyword and continue on failure    C_B27_01_S3_Adjust pcell signal from bad to good and verify traffic all back to normal
    Run keyword and continue on failure    C_B27_01_S4_Verify tput recovered after TP disabled when signal change back to good
    [Teardown]  run keyword and ignore error    run keywords
    ...    Stop data transfer and detach UE    data_transfer_direction=both    AND
    ...    Common case teardown    detach_ue=${True}    is_scf_restore=${False}    is_log_required=${IS_LOG_CAPTURED_CASE_LEVEL}
    ...        is_btslog_required=${False}    AND
    ...    Initialize attenuator values for testline  pa_values_mapping=${INIT_PA}

*** Keywords ***
Suite preparation
    set suite variable    ${INIT_PA}    ${INIT_PA_F1_T1_F2_T3}
    6137 Suite preparation    cell_chbw_config=4CC_F20M_F10M_100M_60M
    ...    pa_values_mapping=${INIT_PA}
    ...    ca_group_mapping_3cc=${F1_T1_T3_3CC_CA_GROUP_COMMON}
    ...    ca_group_mapping_4cc=${F1_T1_F2_T3_4CC_CA_GROUP_COMMON}
    Set tput expectation for suite level
    Connect to gnb coam via ssl
    ${scf_file_path_for_restore}    Download SCF file and return with file path    extended_name=for_restore
    ...    local_dir=${SUITE_LOG_PATH}
    Set suite Variable    ${scf_file_path_for_restore}

Set tput expectation for suite level
    ${EXP_DL_INDIV}    Create List    ${EXP_DL_F20M_2x2_256QAM}    ${EXP_DL_T100M_4x4_256QAM}    ${EXP_DL_T60M_4x4_256QAM}
    ${EXP_UL_INDIV}    Create List    ${EXP_UL_F20M_2x2_64QAM}    ${EXP_UL_T100M_2x2_64QAM}    -1
    ${EXP_DL_INDIV_NO_CA}    Create List    ${EXP_DL_F20M_2x2_256QAM}    0    0
    ${EXP_UL_INDIV_NO_CA}    Create List    ${EXP_UL_F20M_2x2_64QAM}    0    -1
    run keyword if    '${CC_NUM}'=='4CC'    run keywords
    ...           insert_into_list    list_=${EXP_DL_INDIV}    index=-1    value=${EXP_DL_F10M_2x2_256QAM}
    ...    AND    append_to_list    ${EXP_UL_INDIV}    -1
    ...    AND    append_to_list    ${EXP_DL_INDIV_NO_CA}    0
    ...    AND    append_to_list    ${EXP_UL_INDIV_NO_CA}    -1

    # Bellow total tput values are only used in peak test cases, whose result is uploaded to CI power BI
    ${EXP_DL_TOTAL}    _Get tput value for all cells based on individul input    indiv_tput=${EXP_DL_INDIV}
    ${EXP_UL_TOTAL}    _Get tput value for all cells based on individul input    indiv_tput=${EXP_UL_INDIV}
    ${EXP_DL_INDIV_NO_CA_TOTAL}    _Get tput value for all cells based on individul input    indiv_tput=${EXP_DL_INDIV_NO_CA}
    ${EXP_UL_INDIV_NO_CA_TOTAL}    _Get tput value for all cells based on individul input    indiv_tput=${EXP_UL_INDIV_NO_CA}

    Set suite variable    ${EXP_DL_INDIV}
    Set suite variable    ${EXP_UL_INDIV}
    Set suite variable    ${EXP_DL_INDIV_NO_CA}
    Set suite variable    ${EXP_UL_INDIV_NO_CA}
    Set suite variable    ${EXP_DL_TOTAL}
    Set suite variable    ${EXP_UL_TOTAL}
    Set suite variable    ${EXP_DL_INDIV_NO_CA_TOTAL}
    Set suite variable    ${EXP_UL_INDIV_NO_CA_TOTAL}

Buffer Case setup
    [Documentation]  Author: DandanFang
    ...          DRX should be disabled or OnDurationTime longer then UL Proactive period.
    Connect to gnb coam via ssl
    Modify cDRX status on PCell by rest api   pcell_index=${PCELL_ID}      actCDrx_status=false
    6137 Case setup    ca_group_mapping_3cc=${F1_T1_T3_3CC_CA_GROUP_COMMON}    ca_group_mapping_4cc=${F1_T1_F2_T3_4CC_CA_GROUP_COMMON}

Case setup for scell swap
    [Documentation]    Author: Jin Journey
    ...    Enable A6 scell swap
    [Arguments]    ${ca_group_mapping}=${None}    ${exp_cc_num}=${None}
    ${EXP_DL_INDIV}    Create List    ${EXP_DL_F20M_2x2_256QAM}    ${EXP_DL_F10M_2x2_256QAM}    ${EXP_DL_T60M_2x2_256QAM}
    ${EXP_UL_INDIV}    Create List    ${EXP_UL_F20M_2x2_64QAM}    -1    ${EXP_UL_T60M_2x2_64QAM}
    ${EXP_DL_INDIV_AFTER_SWAP}    Create List    ${EXP_DL_F20M_2x2_256QAM}    ${EXP_DL_F10M_2x2_256QAM}    ${EXP_DL_T60M_4x4_256QAM}

    Set test variable    ${EXP_DL_INDIV}
    Set test variable    ${EXP_UL_INDIV}
    Set test variable    ${EXP_DL_INDIV_AFTER_SWAP}
    Set test variable    ${DL_TPUT_IPERF}    1300M

    ${pcell_list}    create list    ${ca_group_mapping['pcell_id']}
    ${CELL_INDEX_LIST_AFTER_SCELL_SWAP}    combine lists    ${pcell_list}    ${ca_group_mapping['scell_swap_dl']}
    Set test variable    ${CELL_INDEX_LIST_AFTER_SCELL_SWAP}
    Set test variable    ${TARGET_SCELL_ID}    ${ca_group_mapping['scell_swap_ul'][0]}
    Initialize attenuator values for testline    pa_values_mapping=${INIT_PA_BEFORE_SCELL_SWAP}
    Configure A1 meas and A6 scell swap parameters    ca_group_mapping=${ca_group_mapping}
    ${param_to_upd}    Generate RRE params for update if on trunk branch
    6137 Case setup    dict_params_to_modify=${param_to_upd}    exp_cc_num_in_use=${exp_cc_num}    ca_group_mapping_3cc=${ca_group_mapping}

AA_11_S2 Remove ca_Fdd_Fr1Tdd_Sa_WithUl from carrierAggregationSupportList and verify PDL error
    [Documentation]  Author: Ding Binmei
    [Arguments]  ${connection}=GNB_OAM
    ${param_update_result}    COAM Update several parameters via rest api    parameters_to_update_via_api=${MODIFY_DEACTIVE_F_T_NO_UL_CA_RESTAPI}
    ...    should_activate=${False}    connection=${connection}    timeout=${TIMER_FOR_MODIFY_VIA_API}
    ${pdl_validation}    Evaluate    str(${param_update_result['validationResult']['pdlValidationResult']['logs']['relationErrors']})

    ${msg_exp_pdl_error}    run keyword if    '${PROGRAM}'=='master'or'${PROGRAM}'>='24R2'
    ...    Catenate    For ca_Rel_Fdd_Fr1Tdd, if NRREL.sCellOperationalMode is equal to dlAndUl, then there shall be
    ...    an element equal to ca_Fdd_Fr1Tdd_Sa_WithUl in NRDU.carrierAggregationSupportList or an element equal to ca_F_Fr1T_Sa_switchedUl
    ...    in NRDU.ulTxSwitchingSupportList of the ca_pDU of this ca_Rel_Fdd_Fr1Tdd
    ...    ELSE    Catenate    For ca_Rel_Fdd_Fr1Tdd, if NRREL.sCellOperationalMode is equal to dlAndUl,
    ...    then there shall be an element equal to ca_Fdd_Fr1Tdd_Sa_WithUl in NRDU.carrierAggregationSupportList
    ...    of the ca_pDU of this ca_Rel_Fdd_Fr1Tdd
    Run keyword and continue on failure    Should contain    ${pdl_validation}    ${msg_exp_pdl_error}


AA_11_S3 Remove UL CA related config and verify Only DL CA exist
    [Documentation]  Author: Ding Binmei
    ...    3.  Remove UL CA related config and verify Only DL CA exist
    ...        3.1 Remove ca_Fdd_Fr1Tdd_Sa_WithUl from carrierAggregationSupportList
    ...        3.2 Modify NRREL.sCellOperationalMode to dlOnly for UL scell
    ...        3.3 Update dlToUlContributionRatio to 101 since ca_Fdd_Fr1Tdd_Sa_WithUl has removed, otherwise PDL error will be displayed
    ...        3.4 Active update and verify DL CA works normal
    [Arguments]  ${connection}=GNB_OAM
    &{dict_params_to_modify}    Create dictionary
    &{dict_modify_sCellOperationalMode}    Create dictionary    sCellOperationalMode=dlOnly
    ${list_params_modify}    create list

    FOR    ${scell_index}    IN    @{SCELL_ID_UL_ADD}
        ${dict_nrrel_update}    coam_gnb_classical.get_nrrel_params_for_online_update    source_cell_id=${PCELL_ID}
        ...    neighbor_cell_id=${scell_index}    dict_exp_config=${dict_modify_sCellOperationalMode}
        ...    connection_alias_source=${connection}    connection_alias_neighbor=${connection}
        ${list_params_modify}    combine lists    ${list_params_modify}    ${dict_nrrel_update['param_to_upd']}
    END
    ${list_params_modify}    combine lists    ${list_params_modify}    ${MODIFY_DEACTIVE_F_T_NO_UL_CA_RESTAPI}
    ${update_dlToUlContributionRatio}    Evaluate    dict(dist_name='${DN_NRDU1}', parameter='dlToUlContributionRatio', value='101')
    Append to list    ${list_params_modify}    ${update_dlToUlContributionRatio}
    Set to dictionary    ${dict_params_to_modify}    param_to_upd=${list_params_modify}

    nidd_modify.online_modify_nidd_parameters_via_restapi    params_modify_dict=${dict_params_to_modify}
    ...    timeout=${TIMER_FOR_MODIFY_VIA_API}
    Wait until cluster ready based on NSA_SA type        NSA_SA=${NSA_SA}
    L3 call with UL or DL CA exist    cell_index=${CELL_INDEX_LIST}
    ...    scell_index_ul=${None}
    ...    exp_ul_indiv=${EXP_UL_INDIV_NO_CA}    exp_dl_indiv=${EXP_DL_INDIV}
    ...    target_avg_percent=${TPUT_AVG_PERCENT_COMMON}    min_percent=${TPUT_MIN_PERCENT_COMMON}
    ...    tcpdump_log_name=S3_DL_CA_only_after_remove_ul    is_need_to_stop_traffic=${True}
    ...    customized_log_name=S3_L3_call_Only_DL_CA

AA_11_S4 Remove ca_Fdd_Fr1Tdd_Sa from carrierAggregationSupportList and verify PDL error
    [Documentation]  Author: Ding Binmei
    ...    Remove ca_Fr1Tdd_Fdd_Sa from carrierAggregationSupportList and Verify PDL error displayed
    [Arguments]    ${connection}=GNB_OAM
    ${param_update_result}    COAM Update several parameters via rest api    parameters_to_update_via_api=${MODIFY_DEACTIVE_F_T_NO_UL_DL_CA_RESTAPI}
    ...    should_activate=${False}    connection=${connection}    timeout=${TIMER_FOR_MODIFY_VIA_API}
    ${msg_exp_pdl_error}    Catenate    If current NRCELL supports FDD, and there is a NRREL with sCellAdditionMethod defined and
    ...    NRCELL corresponding to this NRREL supports TDD, then NRBTS/NRDU.carrierAggregationSupportList must support
    ...    ca_Fdd_Fr1Tdd_Sa or ca_Fdd_Fr1Tdd_Nsa
    ${pdl_validation}    Evaluate    str(${param_update_result['validationResult']['pdlValidationResult']['logs']['relationErrors']})
    Should contain    ${pdl_validation}    ${msg_exp_pdl_error}

AA_11_S5 Remove sCellAdditionMethod and verify no CA
    [Documentation]  Author: Ding Binmei
    [Arguments]    ${connection}=GNB_OAM
    &{dict_params_to_modify}    Create dictionary
    &{dict_remove_sCellAdditionMethod}    Create dictionary    sCellAdditionMethod=${None}    sCellOperationalMode=${None}
    ${list_params_modify}    create list

    FOR    ${scell_index}    IN    @{SCELL_ID_DL_ADD}
        ${dict_nrrel_update}    coam_gnb_classical.get_nrrel_params_for_online_update    source_cell_id=${PCELL_ID}
        ...    neighbor_cell_id=${scell_index}    dict_exp_config=${dict_remove_sCellAdditionMethod}
        ...    connection_alias_source=${connection}    connection_alias_neighbor=${connection}
        ${list_params_modify}    combine lists    ${list_params_modify}    ${dict_nrrel_update['param_to_del']}
    END
    Set to dictionary    ${dict_params_to_modify}    param_to_del=${list_params_modify}

    nidd_modify.online_modify_nidd_parameters_via_restapi    params_modify_dict=${dict_params_to_modify}
    ...    timeout=${TIMER_FOR_MODIFY_VIA_API}
    Wait until cluster ready based on NSA_SA type        NSA_SA=${NSA_SA}
    L3 call with UL or DL CA exist    cell_index=${CELL_INDEX_LIST}
    ...    scell_index_ul=${None}    scell_index_dl=${None}
    ...    exp_ul_indiv=${EXP_UL_INDIV_NO_CA}    exp_dl_indiv=${EXP_DL_INDIV_NO_CA}
    ...    target_avg_percent=${TPUT_AVG_PERCENT_COMMON}    min_percent=${TPUT_MIN_PERCENT_COMMON}
    ...    tcpdump_log_name=S5_DL_UL_No_CA    is_need_to_stop_traffic=${True}
    ...    customized_log_name=S5_L3_call_No_CA

AA_11_S6 Add back sCellAdditionMethod and verify DL CA is OK
    [Documentation]  Author: Ding Binmei
    [Arguments]    ${connection}=GNB_OAM
    &{dict_params_to_modify}    Create dictionary
    &{dict_add_sCellAdditionMethod}    Create dictionary    sCellAdditionMethod=blind    sCellOperationalMode=dlOnly
    ${list_params_modify}    create list

    FOR    ${scell_index}    IN    @{SCELL_ID_DL_ADD}
        ${dict_nrrel_update}    coam_gnb_classical.get_nrrel_params_for_online_update    source_cell_id=${PCELL_ID}
        ...    neighbor_cell_id=${scell_index}    dict_exp_config=${dict_add_sCellAdditionMethod}
        ...    connection_alias_source=${connection}    connection_alias_neighbor=${connection}
        ${list_params_modify}    combine lists    ${list_params_modify}    ${dict_nrrel_update['param_to_add']}
    END
    Set to dictionary    ${dict_params_to_modify}    param_to_add=${list_params_modify}

    nidd_modify.online_modify_nidd_parameters_via_restapi    params_modify_dict=${dict_params_to_modify}
    ...    timeout=${TIMER_FOR_MODIFY_VIA_API}
    Wait until cluster ready based on NSA_SA type        NSA_SA=${NSA_SA}
    L3 call with UL or DL CA exist    cell_index=${CELL_INDEX_LIST}
    ...    scell_index_ul=${None}
    ...    exp_ul_indiv=${EXP_UL_INDIV_NO_CA}    exp_dl_indiv=${EXP_DL_INDIV}
    ...    target_avg_percent=${TPUT_AVG_PERCENT_COMMON}    min_percent=${TPUT_MIN_PERCENT_COMMON}
    ...    tcpdump_log_name=S6_DL_CA_only_after_add_back_dl    is_need_to_stop_traffic=${True}
    ...    customized_log_name=S6_L3_call_DL_CA_only

AA_11_S7 Add UL DL to carrierAggregationSupportList and verify only DL CA exist
    [Documentation]  Author: Ding Binmei
    &{dict_params_to_modify}    Create dictionary
    Set to dictionary    ${dict_params_to_modify}    param_to_upd=${MODIFY_ACTIVE_F_T_UL_DL_CA_RESTAPI}
    nidd_modify.online_modify_nidd_parameters_via_restapi    params_modify_dict=${dict_params_to_modify}
    ...    timeout=${TIMER_FOR_MODIFY_VIA_API}
    Wait until cluster ready based on NSA_SA type        NSA_SA=${NSA_SA}
    L3 call with UL or DL CA exist    cell_index=${CELL_INDEX_LIST}
    ...    scell_index_ul=${None}
    ...    exp_ul_indiv=${EXP_UL_INDIV_NO_CA}    exp_dl_indiv=${EXP_DL_INDIV}
    ...    target_avg_percent=${TPUT_AVG_PERCENT_COMMON}    min_percent=${TPUT_MIN_PERCENT_COMMON}
    ...    tcpdump_log_name=S7_DL_CA_only_when_sCellOperationalMode_is_dlOnly    is_need_to_stop_traffic=${True}
    ...    customized_log_name=S7_L3_call_DL_CA_only

AA_11_S8 Update sCellOperationalMode to dlAndUl and restore dlToUlContributionRatio and verify UL DL CA is OK
    [Documentation]  Author: Ding Binmei
    ...    Update sCellOperationalMode to dlAndUl, restore dlToUlContributionRatio to initial value and verify UL DL CA is OK
    [Arguments]    ${connection}=GNB_OAM
    &{dict_params_to_modify}    Create dictionary
    &{dict_update_sCellOperationalMode}    Create dictionary    sCellOperationalMode=dlAndUl
    ${list_params_modify}    create list

    FOR    ${scell_index}    IN    @{SCELL_ID_UL_ADD}
        ${dict_nrrel_update}    coam_gnb_classical.get_nrrel_params_for_online_update    source_cell_id=${PCELL_ID}
        ...    neighbor_cell_id=${scell_index}    dict_exp_config=${dict_update_sCellOperationalMode}
        ...    connection_alias_source=${connection}    connection_alias_neighbor=${connection}
        ${list_params_modify}    combine lists    ${list_params_modify}    ${dict_nrrel_update['param_to_upd']}
    END
    ${update_dlToUlContributionRatio}    Evaluate
    ...    dict(dist_name='${DN_NRDU1}', parameter='dlToUlContributionRatio', value='${DL_TO_UL_CONTRIBUTION_RATIO}')
    Append to list    ${list_params_modify}    ${update_dlToUlContributionRatio}
    Set to dictionary    ${dict_params_to_modify}    param_to_upd=${list_params_modify}

    nidd_modify.online_modify_nidd_parameters_via_restapi    params_modify_dict=${dict_params_to_modify}
    ...    timeout=${TIMER_FOR_MODIFY_VIA_API}
    Wait until cluster ready based on NSA_SA type        NSA_SA=${NSA_SA}
    L3 call with UL or DL CA exist    cell_index=${CELL_INDEX_LIST}
    ...     exp_ul_indiv=${EXP_UL_INDIV}    exp_dl_indiv=${EXP_DL_INDIV}
    ...    target_avg_percent=${TPUT_AVG_PERCENT_COMMON}    min_percent=${TPUT_MIN_PERCENT_COMMON}
    ...    tcpdump_log_name=S8_DL_UL_CA_when_sCellOperationalMode_is_dlAndUl    is_need_to_stop_traffic=${False}
    ...    customized_log_name=S8_L3_call_UL_DL_CA

AA_11_S9 Remove NRREL and verify no CA exists
    [Documentation]  Author: Ding Binmei
    ...    1. Change both pcell and scell status to notBarred: In case UE attach to other GNBs when pcell lock unlock after remove NRREL MO
    ...    2. Capture F1AP while doing remove NRREL MO:
    ...       a). Verify Pcell lock unlock happened
    ...       b). Verify scell is not added during ue attach via F1AP
    ...       c). Verify no dl tput for scell
    [Arguments]    ${connection}=GNB_OAM        ${log_index}=${0}
    ${file_name_f1ap_lock_unlock}    Set variable    S9_f1ap_check_lock_unlock_cell_happen_${log_index}
    run keyword and continue on failure    Remove NRREL and verify pcell lock unlock happened
    ...    file_name_f1ap_lock_unlock=${file_name_f1ap_lock_unlock}    connection=${connection}
    Change status for parameter cellBarred on GNB    exp_status=notBarred   list_cell_ids=${PCELL_ID}    connection=${connection}
    Run keyword and ignore error    Stop data transfer and detach UE
    Sleep    30s    reason=Wait for cell status stable for attach

    ${file_name_f1ap_check_ca}    Set variable    S9_DL_UL_No_CA_when_delete_nrrel_${log_index}
    run keyword and continue on failure  L3 call with UL or DL CA exist    cell_index=${CELL_INDEX_LIST}
    ...    scell_index_ul=${None}    scell_index_dl=${None}
    ...    exp_ul_indiv=${EXP_UL_INDIV_NO_CA}   exp_dl_indiv=${EXP_DL_INDIV_NO_CA}
    ...    target_avg_percent=${TPUT_AVG_PERCENT_COMMON}    min_percent=${TPUT_MIN_PERCENT_COMMON}
    ...    tcpdump_log_name=${file_name_f1ap_check_ca}    is_need_to_stop_traffic=${True}
    ...    customized_log_name=S9_L3_call_No_CA
    [Teardown]    run keyword and ignore error    Stop data transfer and detach UE

AA_11_S10 Add back NRREL with sCellOperationalMode set to dlAndUl and verify UL DL CA is OK
    [Documentation]  Author: Ding Binmei
    [Arguments]    ${connection}=GNB_OAM    ${log_index}=${0}
    ${ca_group_mapping}    set variable if    '${testline_name}' == '7_5_UTE5G402T254'    ${F1_T1_F2_T3_4CC_CA_GROUP_6137_AA_11_S10}
    ...    ${CA_GROUP_MAPPING}
    ${list_params_modify}    create list
    Prepare NRREL under specific cell    ca_group_mapping=${ca_group_mapping}    connection=${connection}

    ${file_name_f1ap_check_ca}    Set variable    S10_DL_UL_CA_when_NRREL_Added_back_${log_index}
    run keyword and continue on failure  L3 call with UL or DL CA exist    cell_index=${CELL_INDEX_LIST}
    ...     exp_ul_indiv=${EXP_UL_INDIV}    exp_dl_indiv=${EXP_DL_INDIV}
    ...    target_avg_percent=${TPUT_AVG_PERCENT_COMMON}    min_percent=${TPUT_MIN_PERCENT_COMMON}
    ...    tcpdump_log_name=${file_name_f1ap_check_ca}    is_need_to_stop_traffic=${True}
    ...    customized_log_name=S10_L3_call_UL_DL_CA

Online modify A1 ScellAddition A2 ScellRelease parameters
    [Documentation]    author: dandan.fang@nokia-sbell.com
    ...   Currently just consider one Scell.
    [Arguments]       ${pcell_index}=${PCELL_ID}
    ...               ${a1ThresholdSCellAddSsbRsrp_TDD}=75
    ...               ${a1ThresholdSCellAddSsbRsrp_FDD}=75
    ...               ${scell_index}=${SCELL_ID_DL_ADD}    ${a2ThresholdSCellRelSsbRsrp}=${A2_THRESHOLD_SCELL_REL_SSB_RSRP}
    Modify sCell addition method to covBasedA1   cell_index=${pcell_index}
    ...                                          a1ThresholdSCellAddSsbRsrp_TDD=${a1ThresholdSCellAddSsbRsrp_TDD}
    ...                                          a1ThresholdSCellAddSsbRsrp_FDD=${a1ThresholdSCellAddSsbRsrp_FDD}
    ...                                          is_to_skip_sCellAdditionMethod_none_rel=${True}

    FOR    ${cell_index}  IN    @{scell_index}
        ${cell_index}    Evaluate    int(${cell_index})
        Configure A2 Measurement For SCell Release Enabled     cell_index=${cell_index}
        ...                                          a2ThresholdSCellRelSsbRsrp=${a2ThresholdSCellRelSsbRsrp}
    END

UL Only traffic increase from Small to Big to trigger Scell Activated For Bufferbased
    [Documentation]    Author: Dandan Fang
    [Arguments]       ${cell_index}=${CELL_INDEX_LIST}
    ...               ${ulTraffic_small_iperf}=10     ${ulTraffic_big_iperf}=300
    ...               ${tput_duration}=60s    ${iperf_duration}=3000s   ${connection}=GNB_OAM

    ${EXP_UL_TPUT_INDIV_SMALL}    set variable if    '${CC_NUM}'=='3CC'    ${ulTraffic_small_iperf},0,-1    ${ulTraffic_small_iperf},0,-1,-1

    # Small UL traffic
    run keyword and continue on failure    Start UL or DL data transfer and verify Scell is activated or not For Bufferbased
    ...           data_transfer_direction=ul    ul_tput_iperf=${ulTraffic_small_iperf}M
    ...           expect_scell_activated=${False}       iperf_duration=${iperf_duration}
    ${tput_log}    power_ue.Collect Tput     ue_type=${UE_TYPE}    duration=${tput_duration}    ignore_time=1min    filter=L2Lo
    run keyword and continue on failure     Check tput via power UE optimized     direction=ul
    ...    tput_log_path=${tput_log}   connection=${connection}
    ...    exp_ul_indiv=${EXP_UL_TPUT_INDIV_SMALL}    exp_ul=1
    ...    target_avg_percent=${TPUT_AVG_PERCENT_COMMON}   min_percent=${TPUT_AVG_PERCENT_COMMON}
    ...    cell_index=${cell_index}     customized_log_name=tput_UL_small_traffic_only

    # Big UL traffic
    run keyword and continue on failure    Start UL or DL data transfer and verify Scell is activated or not For Bufferbased
    ...           data_transfer_direction=ul    ul_tput_iperf=${ulTraffic_big_iperf}M
    ...           expect_scell_activated=${True}       iperf_duration=${iperf_duration}
    ${tput_log}    power_ue.Collect Tput     ue_type=${UE_TYPE}    duration=${tput_duration}    ignore_time=1min    filter=L2Lo
    run keyword and continue on failure     Check tput via power UE optimized     direction=ul
    ...    tput_log_path=${tput_log}   connection=${connection}
    ...    exp_ul_indiv=${EXP_UL_INDIV}    exp_ul=1
    ...    target_avg_percent=${TPUT_AVG_PERCENT_COMMON}   min_percent=${TPUT_AVG_PERCENT_COMMON}
    ...    cell_index=${cell_index}     customized_log_name=tput_UL_big_traffic_only

DL Only traffic increase from Small to Big to trigger Scell Activated For Bufferbased
    [Documentation]    Author: Dandan Fang
    [Arguments]       ${cell_index}=${CELL_INDEX_LIST}
    ...               ${dlTraffic_small_iperf}=10     ${dlTraffic_big_iperf}=2000
    ...               ${tput_duration}=60s    ${iperf_duration}=3000s    ${connection}=GNB_OAM
    ${EXP_DL_TPUT_INDIV_SMALL}    set variable if    '${CC_NUM}'=='3CC'    ${dlTraffic_small_iperf},0,0    ${dlTraffic_small_iperf},0,0,0

    # Small DL traffic
    run keyword and continue on failure    Start UL or DL data transfer and verify Scell is activated or not For Bufferbased
    ...           data_transfer_direction=dl    expect_scell_activated=${False}    dl_tput_iperf=${dlTraffic_small_iperf}M
    ...           iperf_duration=${iperf_duration}
    ${tput_log}    power_ue.Collect Tput     ue_type=${UE_TYPE}    duration=${tput_duration}    ignore_time=1min    filter=L2Lo
    run keyword and continue on failure     Check tput via power UE optimized     direction=dl
    ...    tput_log_path=${tput_log}   connection=${connection}
    ...    exp_dl_indiv=${EXP_DL_TPUT_INDIV_SMALL}    exp_dl=1
    ...    target_avg_percent=${TPUT_AVG_PERCENT_COMMON}   min_percent=${TPUT_AVG_PERCENT_COMMON}
    ...    cell_index=${cell_index}     customized_log_name=tput_DL_small_traffic_only

    run keyword and continue on failure    Start UL or DL data transfer and verify Scell is activated or not For Bufferbased
    ...           data_transfer_direction=dl     expect_scell_activated=${True}    dl_tput_iperf=${dlTraffic_big_iperf}M
    ...           iperf_duration=${iperf_duration}
    ${tput_log}    power_ue.Collect Tput     ue_type=${UE_TYPE}    duration=${tput_duration}    ignore_time=1min    filter=L2Lo
    run keyword and continue on failure     Check tput via power UE optimized     direction=dl
    ...    tput_log_path=${tput_log}   connection=${connection}
    ...    exp_dl_indiv=${EXP_DL_INDIV}    exp_dl=1
    ...    target_avg_percent=${TPUT_AVG_PERCENT_COMMON}   min_percent=${TPUT_AVG_PERCENT_COMMON}
    ...    cell_index=${cell_index}     customized_log_name=tput_DL_big_traffic_only

Adjust PA and verify scell swap successful
    [Documentation]    author: journey.jin@nokia-sbell.com
    ...   source scell signal bad, target scell good, trigger scell swap
    ...   A6 meas report should be happened on source scell
    ...   New scell added after scell swap and source scell is released
    [Arguments]    ${tcpdump_log_name}=scell_swap_triggered    ${source_scell_exp_pa_value}=${SOURCE_SCELL_BAD}
    ...    ${target_scell_exp_pa_value}=${TARGET_SCELL_GOOD}    ${source_scell_ru_index}=0    ${target_scell_ru_index}=1
    ...    ${source_scell}=${SCELL_ID_UL_ADD[0]}    ${target_scell}=${TARGET_SCELL_ID}
    Start capture F1AP log    tcpdump_collector_name=${tcpdump_log_name}    options=-i any sctp


    Set attenuator ports of specified RUs to same value    exp_pa_value=${target_scell_exp_pa_value}    ru_idx_list=${target_scell_ru_index}
    Set attenuator ports of specified RUs to same value    exp_pa_value=${source_scell_exp_pa_value}    ru_idx_list=${source_scell_ru_index}
    sleep    10s
    ${ue_scell_swap_log}    Stop tcpdump log collection    tcpdump_collector_name=${tcpdump_log_name}

    run keyword and continue on failure    Verify A6 report for scell to trigger scell swap in cpif log
    ...    log_path_pcap=${ue_scell_swap_log}    source_scell=${source_scell}

    run keyword and continue on failure     Verify new scell add after scell swap through RRC Info
    ...    log_path_pcap=${ue_scell_swap_log}    expected_target_scell=${target_scell}

    [Teardown]    run keyword and ignore error    Stop Tcpdump via collector    tcpdump_collector_name=${tcpdump_log_name}

Verify A6 report for scell to trigger scell swap in cpif log
    [Documentation]    author: Jin Journey
    [Arguments]    ${log_path_pcap}    ${source_scell}
    ${physicalCellId}   set variable    ${NR_CELL_ID_MAPPING[${source_scell}]['physicalCellId']}
    ${filter}    set variable
    ...    (f1ap.procedureCode == 13) && (nr-rrc.measResultServingMOList) && (nr-rrc.physCellId == ${physicalCellId})
    pcap.setup     infile=${log_path_pcap}    display_filter=${filter}
    ${xpath}  catenate    SEPARATOR=${EMPTY}     .//nr-rrc.measResultServingMOList//*//nr-rrc.physCellId[@show='${physicalCellId}']
    ...    /following-sibling::nr-rrc.measResult_element//*//nr-rrc.resultsSSB_Cell_element/nr-rrc.measQuantityResults.rsrp

    ${source_scell_rsrp}  pcap.get_field_value_by_xpath    xpath=${xpath}      attribute_name=show

    run keyword and continue on failure    should be true    ${source_scell_rsrp[-1]} <= 70


Verify new scell add after scell swap through RRC Info
    [Documentation]    author: Jin Journey
    ...      check new scell add after scell swap
    [Arguments]     ${log_path_pcap}    ${expected_target_scell}
    #new scell addition
    ${expected_scellPCI}   set variable    ${NR_CELL_ID_MAPPING[${expected_target_scell}]['physicalCellId']}
    ${filter}    set variable
    ...     ( f1ap.procedureCode == 12 ) && (nr-rrc.sCellToAddModList) && ( nr-rrc.physCellId == ${expected_scellPCI} )
    ${pkt_new_scell_addition}    Load pcap file with filter    log_path_pcap=${log_path_pcap}    filter=${filter}
    ${new_scell_pci}    pcap.get_field_value_by_xpath
    ...    pdml_list=${pkt_new_scell_addition}        attribute_name=show
    ...    xpath=.//nr-rrc.sCellConfigCommon_element/nr-rrc.physCellId

    ${release_scell_index}    pcap.get_field_value_by_xpath
    ...    xpath=.//nr-rrc.sCellToReleaseList       attribute_name=show

    run keyword and continue on failure   should be true    ${expected_scellPCI} == ${new_scell_pci[0]}
    run keyword and continue on failure   should be true    ${release_scell_index[0]} == ${1}


Check PM counter M55118C10501 M55118C10502
    [Documentation]    author: journey.jin@nokia-sbell.com
    ...    M55118C10501:The total number of SCell swap attempts for 1 SCell in the PCell for SA mode.
    ...                 This counter is updated on the PCell for a single SCell which is swapped during SCell Swap procedure due to A6 measurements
    ...    M55118C10502:The total number of successful SCell swap attempts for 1 SCell in the PCell for SA mode.
    ...                 This counter is updated on the PCell for a single SCell which is successfully swapped
    ...                 during SCell Swap procedure due to A6 measurements
    [Arguments]       ${starting_log_timestamp}
    ${pm_files_local_path}    Wait for PM file generated and download    starting_log_timestamp=${starting_log_timestamp}
    ${cell_check_list}    create list     ${PCELL_ID}
    ${list_measurement_ids}    create list    M55118C10501    M55118C10502
    ${dict_measurements_value}    counter.get_total_cell_counter_from_multiple_files    list_file_path=${pm_files_local_path}
    ...      list_cell=${cell_check_list}          list_measurement_ids=${list_measurement_ids}

    ${M55118C10501}    set variable    ${dict_measurements_value['${pcell_id}']['M55118C10501']}
    ${M55118C10502}    set variable    ${dict_measurements_value['${pcell_id}']['M55118C10502']}
    run keyword and continue on failure     should be equal as strings      ${M55118C10501}       1
    run keyword and continue on failure     should be equal as strings      ${M55118C10502}       1

04307958_Customer_pronto_regression_ScellSwap_iwk_RRE_Main_steps
    [Documentation]    Author: Ding Binmei
    ...    Counter info:
    ...    M55118C10005: UE_PCELL_1_CONF_SCELL_UL_SA, Sum of CA UEs in the current cell configured as a PCell, which have 1 configured SCell in UL
    ...    M55124C00516: REESTAB_RRCRECONFIG_SUCC, the number of RRC reconfiguration succeed in RRC reestablishment procedure
    ...    M55118C10502: SCELL_SWAP_1_SUCC_SA. The total number of successful SCell swap attempts for 1 SCell in the PCell for SA mode.
    ...     This counter is updated on the PCell for a single SCell which is successfully swapped during SCell Swap procedure due to A6 measurements
    ...    Main steps:
    ...    1. Start L3 call
    ...    2. Start to trigger scell swap and RRE for multiple times
    ...    3. Check PM counter M55118C10005 after trigger scellswap and RRE for multiple times and Verify counter should be > 0;
    ...       also verify for counter M55124C00516 and M55118C10502 to make sure that RRE and scell swaps can be triggered
    ...    4. Check PM counter M55118C10005 value change to 0 after UE detach
    Log to console    Regression for customer pronto 04307958, check counter M55118C10005 after trigger scellswap and RRE for multiple times
    Log to console    1. Start L3 call
    Run Keyword And Continue On Failure    L3 call with UL or DL CA exist    cell_index=${CELL_INDEX_LIST}
        ...    target_avg_percent=${TPUT_AVG_PERCENT_COMMON}    min_percent=${TPUT_MIN_PERCENT_COMMON}    is_need_to_stop_traffic=${False}
        ...    data_transfer_direction=both    exp_dl_indiv=${EXP_DL_INDIV}    iperf_duration=30000s
        ...    exp_ul_indiv=${EXP_UL_INDIV}

    ${ru_index_pcell}    set variable    ${NR_CELL_ID_MAPPING[${PCELL_ID}]['ruIndex_in_init']}
    ${ru_index_scell_swap_source}   set variable    ${NR_CELL_ID_MAPPING[${SCELL_ID_UL_ADD[0]}]['ruIndex_in_init']}
    ${ru_index_scell_swap_target}   set variable    ${NR_CELL_ID_MAPPING[${TARGET_SCELL_ID}]['ruIndex_in_init']}

    Log to console    2. Start to trigger scell swap and RRE for multiple times
    ${start_log_timestamp_before_trigger_RRE_scell_swap}    Prepare for counter log
    Adjust PA to trigger scell swap and RRE together    ru_index_pcell=${ru_index_pcell}
    ...    ru_index_scell_swap_source=${ru_index_scell_swap_source}    ru_index_scell_swap_target=${ru_index_scell_swap_target}
    ...    pa_trigger_rre=60    pa_trigger_scell_swap=${SOURCE_SCELL_BAD}    max_retry_time=100

    Log to console    3. Check PM counter M55118C10005 after trigger scellswap and RRE for multiple times and Verify counter should be > 0
    ${counter_for_trigger_RRE_scell_swap_local_file_path}    Wait for PM file generated and download
    ...    starting_log_timestamp=${start_log_timestamp_before_trigger_RRE_scell_swap['log_generator_timestamp']}
    ${cell_check_list}    create list     ${PCELL_ID}
    ${list_measurement_ids}    create list    M55118C10005    M55124C00516    M55118C10502
    ${dict_measurements_value_beforee_ue_detach}    counter.get_total_cell_counter_from_multiple_files
    ...    list_file_path=${counter_for_trigger_RRE_scell_swap_local_file_path}
    ...    list_cell=${cell_check_list}          list_measurement_ids=${list_measurement_ids}
    Log to console    Counter values before UE detach: ${dict_measurements_value_beforee_ue_detach}
    Run Keyword And Continue On Failure    Should be true    ${dict_measurements_value_beforee_ue_detach['${PCELL_ID}']['M55118C10005']} > 0
    ...    msg=Counter M55118C10005 UE_PCELL_1_CONF_SCELL_UL_SA value before UE detach should be > 0, as UL CA exists
    Run Keyword And Continue On Failure    Should be true    ${dict_measurements_value_beforee_ue_detach['${PCELL_ID}']['M55124C00516']} > 0
    ...    msg=Counter M55124C00516 REESTAB_RRCRECONFIG_SUCC should be > 0, please check if RRE is triggered
    Run Keyword And Continue On Failure    Should be true    ${dict_measurements_value_beforee_ue_detach['${PCELL_ID}']['M55118C10502']} > 0
    ...    msg=Counter M55118C10502 SCELL_SWAP_1_SUCC_SA should be > 0, please check if SCell swap is triggered

    Log to console    4. Check PM counter M55118C10005 value change to 0 after UE detach
    Stop data transfer and detach UE    data_transfer_direction=both
    ${counter_for_next_period_starting_log_timestamp}    Prepare for counter log
    ${counter_for_next_period_local_file_path}    Wait for PM file generated and download
    ...    starting_log_timestamp=${counter_for_next_period_starting_log_timestamp['log_generator_timestamp']}
    ${dict_measurements_value_after_ue_detach}    counter.get_total_cell_counter_from_multiple_files
    ...    list_file_path=${counter_for_next_period_local_file_path}
    ...    list_cell=${cell_check_list}          list_measurement_ids=${list_measurement_ids}
    Should be true    ${dict_measurements_value_after_ue_detach['${PCELL_ID}']['M55118C10005']} == 0
    ...    msg=Counter M55118C10005 UE_PCELL_1_CONF_SCELL_UL_SA value should be 0 after UE detach
