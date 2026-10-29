*** Settings ***
Documentation    This is the regression cases robot for supercell function parity in cloud feature CB010413.

Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB010413/Resources/CB010413_CB08985_keywords.robot
Force Tags        5G_RRM    PY310    RF50

Suite Setup    Suite preparation
Suite Teardown    run keyword and ignore error    Aic Suite teardown

*** Test Cases ***
CB010413_CR_FC_01_CB008985_feature_NSA_L3Call_6xSubCell_configuration_activate_then_deactive_1116_3ms
    [Documentation]    Author: Lingxue Cui
    ...    This case verify the setup of supercell with 6 subcells, and L3call on supercell.
    ...    Then change supercell to normal cell, and verify L3call.
    [Setup]    Case setup    NSA_SA=NSA

    run keyword and continue on failure  L3call with DL or UL tput    is_need_to_stop_traffic=${True}    is_need_to_detach_ue=${True}
    ...    exp_ul=${EXP_UL_TPUT_NSA}    customized_log_name=L3call_with_supercell_6subcells    NSA_SA=NSA
    run keyword and continue on failure  Verify the subcell number and numberOfTransmittedSsBlocks


    Add list of allowed alarms    allowed_faults_ids=7504,7505,4405,4681
    Switch supercell to normal cell
    Aic Check CU and DUs Onair    NSA_SA=NSA
    Remove list of allowed alarms    allowed_faults_ids=7504,7505,4405,4681

    L3call with DL or UL tput    is_need_to_stop_traffic=${True}    is_need_to_detach_ue=${True}
    ...    exp_dl=${EXP_DL_TPUT_NORMAL_CELL}    exp_ul=${EXP_UL_TPUT_NSA}
    ...    customized_log_name=L3call_with_normal_cell    NSA_SA=NSA
    [Teardown]    run keyword and ignore error  Aic Common case teardown    pa_values_mapping=${INIT_PA}

CB010413_CR_FC_03_CB008985_feature_SA_configure_subcell_num_from_2x_to_3x_to_6x
    [Documentation]    Author: Lingxue Cui
    ...    In this case will verify the change of subcells number in supercell.
    ...    Initially the subcell number is 6, then reduce to 3 subcells, then 2 subcells.
    [Setup]    Case setup
    run keyword and continue on failure  L3call with DL or UL tput    is_need_to_stop_traffic=${True}    is_need_to_detach_ue=${True}
    ...    customized_log_name=L3call_with_supercell_6subcells

    log to console    \n Change subcell number to 3.
    Add list of allowed alarms    allowed_faults_ids=7504,7505,4405,4681
    Reduce subcell number in Supercell    target_subcell_number=${3}
    Aic Check CU and DUs Onair
    Remove list of allowed alarms    allowed_faults_ids=7504,7505,4405,4681
    run keyword and continue on failure  L3call with DL or UL tput    is_need_to_stop_traffic=${True}    is_need_to_detach_ue=${True}
    ...    customized_log_name=L3call_with_supercell_3subcells

    log to console    \n Change subcell number to 2.
    Add list of allowed alarms    allowed_faults_ids=7504,7505,4405
    Reduce subcell number in Supercell    target_subcell_number=${2}
    Aic Check CU and DUs Onair
    Remove list of allowed alarms    allowed_faults_ids=7504,7505,4405
    L3call with DL or UL tput    is_need_to_stop_traffic=${True}    is_need_to_detach_ue=${True}
    ...    customized_log_name=L3call_with_supercell_2subcells
    [Teardown]    run keyword and ignore error  Aic Common case teardown    pa_values_mapping=${INIT_PA}

CB010413_CR_FC_10_CB008985_SISO_Super_with_max_subcells_cell_Setup_and_subcell_switch
    [Documentation]    Author: Lingxue Cui
    ...    This case verify the setup of supercell with 6 subcells, switch between different subcells and verify the tput is not interrupted.
    [Setup]    Subcell switch case setup
    ${counter_list}    Generate counter list for subcell switch    candidate_subcell_list=${CANDIDATE_SUBCELLS}    expect_value=${1}
    run keyword and continue on failure  L3call with DL or UL tput
    ...    customized_log_name=L3call_with_supercell_6subcells

    ${counter_pre_timestamp}    Waiting time for new counter update period For Cloud   bts_type=du
    Adjust PA to trigger subcell switch  source_subcell_id=${CANDIDATE_SUBCELLS[${0}]}  target_subcell_id=${CANDIDATE_SUBCELLS[${1}]}
    run keyword and continue on failure  Verify Thput reach expectation
    ...    customized_log_name=Tput_after_subcell_switch_from_${CANDIDATE_SUBCELLS[${0}]}_to_${CANDIDATE_SUBCELLS[${1}]}

    Adjust PA to trigger subcell switch  source_subcell_id=${CANDIDATE_SUBCELLS[${1}]}  target_subcell_id=${CANDIDATE_SUBCELLS[${2}]}
    run keyword and continue on failure  Verify Thput reach expectation
    ...    customized_log_name=Tput_after_subcell_switch_from_${CANDIDATE_SUBCELLS[${1}]}_to_${CANDIDATE_SUBCELLS[${2}]}
    ${counter_post_timestamp}    Waiting time for new counter update period For Cloud   bts_type=du
    Check Counter Value match expectations    counter_list=${counter_list}    bts_type=du
    ...    start_time_lower_limit=${counter_pre_timestamp['log_generator_timestamp']}
    ...    start_time_upper_limit=${counter_post_timestamp['log_generator_timestamp']}
    [Teardown]    run keyword and ignore error  Aic Common case teardown    pa_values_mapping=${INIT_PA}

*** Keywords ***
Subcell switch case setup
    [Documentation]    Author: Lingxue Cui
    [Arguments]    ${attenuator_out_ports}=${PA_OUT_PORTS}    ${attenuator_rows}=${PA_ROWS}    ${attenuator_max_column_num}=${PA_MAX_COLUMN_NUM}
    Case setup    pa_values_mapping=${None}    NSA_SA=SA
    Block whole attenuator ports for testline    attenuator_out_ports=${attenuator_out_ports}
    ...     attenuator_rows=${attenuator_rows}    attenuator_max_column_num=${attenuator_max_column_num}
    ${candidate_subcell_list}    Generate random subcell numbers    total_subcell_number=${6}
    set test variable    ${CANDIDATE_SUBCELLS}    ${candidate_subcell_list}
    Initialize RU ports of PA for specific subcell    subcell_id=${candidate_subcell_list[${0}]}     exp_pa_value=${10}
