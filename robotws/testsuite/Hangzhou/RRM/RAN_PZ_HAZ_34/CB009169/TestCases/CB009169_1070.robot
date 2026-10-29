*** Settings ***
Documentation    T+F CA
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB009169/Resources/CB009169_keywords.robot

Force Tags        5G_RRM   PY36    RF50

Suite Setup        Suite preparation    frame_structure=1070
Suite Teardown     run keyword and ignore error    CA Suite teardown


*** Test Cases ***
CB009169-SR_AB_B1_011_FR1_DL_UL_data_scheduling_A1_SCell_addition_buffer_based_SCell_activation_deactivation_1070_actShortBsrLimitAdaptation_enabled
    [Tags]    CRT_TRUNK
    [Documentation]    This case is to verify if peak throughput can be reached on both UL and DL.
    ...    The execution order will be:
    ...      1) attach and start UL traffic, due to CB008311 enabled in suite setup, when check throughput,
    ...         no UL CA, and pcell UL 2 layers.
    ...      2) Stop UL traffic.
    ...      3) Start DL traffic and verify DL throughput.
    ...      4) Start UL traffic and verify bi-direction throughput.
    ...      5) Stop data transmission and detach UE.
    ...     additonal step: this step is for branch 24R2 and later.
    ...     online enable CB008830, and attach, start bi-direction throughput,
    ...     and check bi-direction throughput, TDD cells DL throughput will be increased due to DMRS Type2 enabled. /n
    ...     revert to DMRS type1 in case teardown.
    ...    ***This case use cell1,2,5,3 for CA testing.
    [Setup]    9169 Case setup
    # lock cell4 because cell4 and cell4 nrarfcn is same, maybe inflence cell5 throughput
    run keyword and ignore error    Perform cell lock via rest api    cell_idx=4
    ${starting_log_timestamp}    Prepare for counter log    reporting_interval=5
    run keyword and continue on failure    ULCA_peak_tput_verification_with_8311_enabled    cell_index=${CELL_INDEX_LIST}
    ...    exp_ul_indiv=${EXP_UL_INDIV_1070}    exp_dl_indiv=${EXP_DL_INDIV_1070}    target_avg_percent=0.98
    ...    exp_ul=${UL_TOTAL}    exp_dl=${DL_TOTAL}

    run keyword and continue on failure    Check PM counter 5GC001349 counters
    ...    starting_log_timestamp=${starting_log_timestamp['log_generator_timestamp']}

    log to console    additonal step: this step is for branch 24R3 and later.
    ...    online enable CB008830, and attach, start bi-direction throughput,
    ...    and check bi-direction throughput, TDD cells DL throughput will be increased due to DMRS Type2 enabled. /n
    run keyword if     '${program}' != '23R3' and '${program}' != '23R4' and '${program}' != '24R1'
    ...    COAM Update several parameters via rest api    parameters_to_update_via_api=${SCF_ENABLE_CB008830_API}
    run keyword if     '${program}' != '23R3' and '${program}' != '23R4' and '${program}' != '24R1'
    ...    Run keyword and continue on failure    L3 call with UL or DL CA exist    cell_index=${CELL_INDEX_LIST}
    ...    exp_ul_indiv=${EXP_UL_INDIV_1070}    exp_dl_indiv=${EXP_DL_INDIV_1070_ENABLE_8830}    tput_duration=300s
    ...    iperf_duration=3000S   is_need_to_stop_traffic=${True}    target_avg_percent=0.98    actBufferBasedScellAddition=oneShot_Dl_Fr1
    ...    exp_ul=${UL_TOTAL}    exp_dl=${DL_TOTAL_8830}    customized_log_name=Bi_diretion_tput_enable_8830

    [Teardown]    run keywords    run keyword and ignore error    COAM Update several parameters via rest api
    ...    parameters_to_update_via_api=${SCF_DISABLE_CB008830_API}    AND
    ...    run keyword and ignore error    Perform cell unlock via rest api   cell_idx=4    AND
    ...    run keyword and ignore error    Common case teardown    detach_ue=${True}

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
    ${EXP_DL_INDIV_1070}    Create List    ${EXP_DL_T100M_4x4_256QAM_1070_${MRBTS_ID}}    ${EXP_DL_F20M_2x2_256QAM_${MRBTS_ID}}
    ...    ${EXP_DL_T60M_4x4_256QAM_1070_${MRBTS_ID}}    ${EXP_DL_F10M_2x2_256QAM_${MRBTS_ID}}

    ${EXP_UL_T100M_2x2_64QAM_1070}    run keyword if     '${program}' == '24R2' and '${MRBTS_ID}' == '1170'
    ...    Evaluate    ${EXP_UL_T100M_2x2_64QAM_1070_${MRBTS_ID}}+${3}
    ...    ELSE    Set variable     ${EXP_UL_T100M_2x2_64QAM_1070_${MRBTS_ID}}
    ${EXP_UL_F20M_2x2_64QAM_1070}    run keyword if     '${program}' == '24R2' and '${MRBTS_ID}' == '1170'
    ...    Evaluate    ${EXP_UL_F20M_2x2_64QAM_1070_${MRBTS_ID}}+${3}
    ...    ELSE    Set variable     ${EXP_UL_F20M_2x2_64QAM_1070_${MRBTS_ID}}
    ${EXP_UL_INDIV_1070}    Create List    ${EXP_UL_T100M_2x2_64QAM_1070}    ${EXP_UL_F20M_2x2_64QAM_1070}  -1    -1

    ${EXP_UL_INDIV_1070_ENABLE_8311}    Create List      ${EXP_UL_T100M_2x2_64QAM_1070_ENABLE_8311_${MRBTS_ID}}    -1  -1    -1

    ${EXP_DL_INDIV_1070_ENABLE_8830}    Create List    ${EXP_DL_T100M_4x4_256QAM_1070_ENABLE_8830_${MRBTS_ID}}
    ...   ${EXP_DL_F20M_2x2_256QAM_${MRBTS_ID}}    ${EXP_DL_T60M_4x4_256QAM_1070_ENABLE_8830_${MRBTS_ID}}    ${EXP_DL_F10M_2x2_256QAM_${MRBTS_ID}}

    ${dl_total_temp}    catenate    ${EXP_DL_T100M_4x4_256QAM_1070_${MRBTS_ID}}+${EXP_DL_F20M_2x2_256QAM_${MRBTS_ID}}+
    ...    ${EXP_DL_T60M_4x4_256QAM_1070_${MRBTS_ID}}+${EXP_DL_F10M_2x2_256QAM_${MRBTS_ID}}

    ${dl_total_temp_8830}    catenate    ${EXP_DL_T100M_4x4_256QAM_1070_ENABLE_8830_${MRBTS_ID}}+${EXP_DL_F20M_2x2_256QAM_${MRBTS_ID}}+
    ...    ${EXP_DL_T60M_4x4_256QAM_1070_ENABLE_8830_${MRBTS_ID}}+${EXP_DL_F10M_2x2_256QAM_${MRBTS_ID}}

    ${dl_total}    evaluate    ${dl_total_temp}
    ${dl_total_8830}    evaluate    ${dl_total_temp_8830}
    ${ul_total}    evaluate    ${EXP_UL_T100M_2x2_64QAM_1070}+${EXP_UL_F20M_2x2_64QAM_1070}
    Set suite variable    ${EXP_DL_INDIV_1070}
    Set suite variable    ${EXP_UL_INDIV_1070}
    Set suite variable    ${EXP_UL_INDIV_1070_ENABLE_8311}
    Set suite variable    ${EXP_DL_INDIV_1070_ENABLE_8830}
    Set suite variable    ${DL_TOTAL}    ${dl_total}
    Set suite variable    ${UL_TOTAL}    ${ul_total}
    Set suite variable    ${DL_TOTAL_8830}    ${dl_total_8830}

Check PM counter 5GC001349 counters
    [Documentation]    author: xin.qi@nokia-sbell.com
    ...    M55306C06001: RA msg3 receptions on NRCELL-1.
    ...    M55306C03001: RA setup completions for contention based group A preambbles on NRCELL-1.
    ...    M55306C00001: RA setup attempts for contention based group A preambles corresponding to SSB beam ID 0 on NRCELL-1.
    ...    M55306C00002: RA setup attempts for contention based group A preambles corresponding to SSB beam ID 1 on NRCELL-1.

    [Arguments]       ${starting_log_timestamp}
    ${pm_files_local_path}    Wait for PM file generated and download    starting_log_timestamp=${starting_log_timestamp}
    ${cell_check_list}    create list     ${PCELL_ID}
    ${list_measurement_ids}    create list    M55306C06001    M55306C03001    M55306C00001    M55306C00002
    ${dict_measurements_value}    counter.get_total_cell_counter_from_multiple_files    list_file_path=${pm_files_local_path}
    ...      list_cell=${cell_check_list}          list_measurement_ids=${list_measurement_ids}

    ${M55306C06001}    set variable    ${dict_measurements_value['${PCELL_ID}']['M55306C06001']}
    ${M55306C03001}    set variable    ${dict_measurements_value['${PCELL_ID}']['M55306C03001']}
    ${M55306C00001}    set variable    ${dict_measurements_value['${PCELL_ID}']['M55306C00001']}
    ${M55306C00002}    set variable    ${dict_measurements_value['${PCELL_ID}']['M55306C00002']}
    ${list_measurement_value}    evaluate    ${M55306C00001}+${M55306C00002}
    run keyword and continue on failure     should be true      ${list_measurement_value}>=1
    run keyword and continue on failure     should be true      ${M55306C06001}>=1
    run keyword and continue on failure     should be true      ${M55306C03001}>=1

