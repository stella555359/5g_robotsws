*** Settings ***
Documentation    T+F CA
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB009169/Resources/CB009169_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/CA/Resources/vonr.robot
Force Tags        5G_RRM   PY36    RF50

Suite Setup        9169 vonr enhance suite preparation    pa_values_mapping=${INIT_PA_T1_F1_T2_F2}
Suite Teardown     run keyword and ignore error    CA Suite teardown


*** Test Cases ***
CB009169-SR_CB_IWK4_003_Interworking_with_CB009425_VoNR_Increased_Transmission_Reliability_with_enabling_DRX
    [Documentation]    Author: Liu Zheng
    ...    The DL rBLER set take effect only after re-attach and after VONR start.
    ...    Step1: L3 call and throughput can peak.\n
    ...    Step2: start VONR, UDP throughput no impact.\n
    ...    Step3: set the pcell signal to bad(about RSRP=-90dbm) to cause retransmissions to occur leading to considerable high DL rBLE. \n
    ...    Step4: online update the DL rBLER parameters and check the throughout no change, the bler on pcell is also high. \n
    ...    step5: hang up voice call, stop data transfer and detach. \n
    ...    Step6: redo l3call and no vonr, check the throughput is same as step4, the bler on pcell is high.\n
    ...    Step7: add vonr, check the throughput can increase, maybe about 20M, the bler on pcell is low. \n
    ...    Step8: hang up voice call, stop data transfer and detach. \n
    ...    ***This case use cell1,2,4,3 for CA testing.
    [Setup]    9169 Case setup    ca_group_mapping_4cc=${T1_F1_T2_F2_4CC_CA_GROUP_COMMON}
    Perform cell lock via rest api    cell_idx=${5}
    log to console    ***Step1: L3 call and check thorughput*** \n
    Run keyword and continue on failure    L3 call with UL or DL CA exist    cell_index=${CELL_INDEX_LIST}
    ...    exp_ul_indiv=${EXP_UL_INDIV_1116}    exp_dl_indiv=${EXP_DL_INDIV_1116}
    ...    tput_duration=60s   iperf_duration=6000s    is_need_to_stop_traffic=${False}
    ...    customized_log_name=step1_throughput_l3call_tp_can_peak

    log to console    ***Step2: add VONR and check thorughput no impact***
    Run keyword and continue on failure      Make a VoNR call    ue_index=${0}    try_voice_call_duration=50
    ...    vonr_num=9988    hung_up_voice_call=${False}
    run keyword and continue on failure    Verify throughput as expect    cell_index=${CELL_INDEX_LIST}
    ...    exp_ul_indiv=${EXP_UL_INDIV_1116_WITH_VONR}     exp_dl_indiv=${EXP_DL_INDIV_1116_WITH_VONR}      check_tput_ignore_time=40s
    ...    customized_log_name=step2_throughput_add_vonr

    log to console     ***step3:set pcell signal RSRP about -90dbm, to make DL high bler***\n
    Set attenuator ports of specified RUs to same value    exp_pa_value=${PA_PCELL_DL_BLER}    ru_idx_list=0

    ${tput_log_path_step3}    power_ue.Collect Tput     ue_type=${UE_TYPE}    duration=120s
    ...    ignore_time=40s    filter=L2Lo
    ${dict_cell_indiv_tput_step3}    run keyword and continue on failure    Check tput and return each cells throughput
    ...    tput_log_path=${tput_log_path_step3}    direction=both     exp_ul=1    exp_dl=1
    ...    exp_ul_indiv=${EXP_UL_INDIV_PCELL_HIGH_BLER_WITH_VONR}     exp_dl_indiv=${EXP_DL_INDIV_PCELL_HIGH_BLER_WITH_VONR}
    ...    customized_log_name=step3_throughput_DL_high_bler

    log to console     ***step4: online update DL rBLER parameters and check the throughout no change, the bler on pcell is also high***\n
    COAM add several parameters via rest api    parameters_to_add_via_api=${ADD_DL_RBLER_SET_API}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${MODIFY_SCF_DL_RBLER_SET_API}

    ${tput_log_path_step4}    power_ue.Collect Tput     ue_type=${UE_TYPE}    duration=120s
    ...    ignore_time=40s    filter=L2Lo
    ${dict_cell_indiv_tput_step4}    run keyword and continue on failure    Check tput and return each cells throughput
    ...    tput_log_path=${tput_log_path_step4}    direction=both     exp_ul=1    exp_dl=1
    ...    exp_ul_indiv=${EXP_UL_INDIV_PCELL_HIGH_BLER_WITH_VONR}     exp_dl_indiv=${EXP_DL_INDIV_PCELL_HIGH_BLER_WITH_VONR}
    ...    customized_log_name=step4_throughput_online_update_dl_rbler_parameters

    log to console     ***compare throughput of before online update DL rBLER para and after  online update DL rBLER para,
    ...    throughput should no change***\n
    run keyword and continue on failure     compare the throughputs of each cells throughput should no change
    ...    dict_cell_indiv_tput1=${dict_cell_indiv_tput_step3}    dict_cell_indiv_tput2=${dict_cell_indiv_tput_step4}

    log to console     ***step5: hang up voice call, stop data transfer and detach*** \n
    hang up voice call
    Stop data transfer and detach UE    data_transfer_direction=both    ue_index=${0}

    log to console     ***step6: redo l3call and no vonr, check the throughput is same as step4, the bler on pcell is high*** \n

    Run keyword and continue on failure    L3 call with UL or DL CA exist    cell_index=${CELL_INDEX_LIST}
    ...    exp_ul_indiv=${EXP_UL_INDIV_PCELL_HIGH_BLER_NO_VONR}    exp_dl_indiv=${EXP_DL_INDIV_PCELL_HIGH_BLER_NO_VONR}
    ...    tput_duration=60s   iperf_duration=6000s    is_need_to_stop_traffic=${False}
    ...    customized_log_name=step6_throughput_dl_high_bler_redo_l3call

    log to console     ***step7: add vonr, check the throughput can increase, maybe about 20M, the bler on pcell is low*** \n
    Run keyword and continue on failure      Make a VoNR call    ue_index=${0}    try_voice_call_duration=50
    ...        vonr_num=9988    hung_up_voice_call=${False}

    ${tput_log_path_step7}    power_ue.Collect Tput     ue_type=${UE_TYPE}    duration=120s
    ...    ignore_time=40s    filter=L2Lo
    ${dict_cell_indiv_tput_step7}    run keyword and continue on failure    Check tput and return each cells throughput
    ...    tput_log_path=${tput_log_path_step7}    direction=both     exp_ul=1    exp_dl=1
    ...    exp_ul_indiv=${EXP_UL_INDIV_PCELL_LOW_BLER_WITH_VONR}      exp_dl_indiv=${EXP_DL_INDIV_PCELL_LOW_BLER_WITH_VONR}
    ...    customized_log_name=step7_throughput_add_vonr_dl_low_bler_tp_increase

    log to console     ***compare throughput of step4:online update DL rBLER parameters and step7:re-attach+L3call+vonr, step7 pcell DL throughput
    ...    should increased***\n
    run keyword and continue on failure     throughput should be increased after due to EnhancedVoNR
    ...    dict_cell_indiv_tput1=${dict_cell_indiv_tput_step4}    dict_cell_indiv_tput2=${dict_cell_indiv_tput_step7}
    ...    pcell_dl_increace=${DL_PCELL_THROUGHPUT_INCREASE}

    log to console     ***step8: hang up voice call, stop data transfer and detach*** \n
    hang up voice call
    Stop data transfer and detach UE    data_transfer_direction=both    ue_index=${0}

    [Teardown]    run keywords    run keyword and ignore error   Perform cell unlock via rest api     cell_idx=${5}
    ...    AND    run keyword and ignore error    Common case teardown    detach_ue=${True}


*** Keywords ***
9169 vonr enhance suite preparation
    [Documentation]  Author: Liu Zheng
    ...    exp_cc_num_in_use: refers to 3CC/4CC/${None}, if set as 3CC or 4CC will return the input value directly,
    ...        otherwise will judge based on ue type. sdx65: 3CC, sdx70: 4CC, other ue type will default to 3CC
    ...    Added new parameter for ${ca_group_mapping_3cc} and ${ca_group_mapping_4cc}, parameter need to be added based on exp_cc_num_in_use
    ...    ${ca_group_mapping_3cc} equals to ${ca_group_mapping} by default,
    ...    ToDo: ${ca_group_mapping} can be removed when all cases has removed this param
    [Arguments]    ${enb_default_scf_file}=${None}    ${cell_chbw_config}=4CC_T100M_F20M_F10M_T60M
    ...    ${swconfig_modify}=${None}    ${scf_modify_parameters}=${PARAMS_TO_MODIFY_SCF}
    ...    ${pa_values_mapping}=${INIT_PA_T1_F1_T2_F2}    ${ca_group_mapping_3cc}=${T1_F1_F2_3CC_CA_GROUP_COMMON}
    ...    ${ca_group_mapping_4cc}=${T1_F1_T2_F2_4CC_CA_GROUP_COMMON}    ${exp_cc_num_in_use}=${None}

    set suite variable    ${INIT_PA}    ${INIT_PA_T1_F1_T2_F2}
    Decode CA group mapping and set global variable    is_called_in_suite_level=${True}
    ...    ca_group_mapping_3cc=${ca_group_mapping_3cc}    ca_group_mapping_4cc=${ca_group_mapping_4cc}    exp_cc_num_in_use=${exp_cc_num_in_use}
    Import NIDD variables for 9169
    run keyword if    '${cell_chbw_config}'!='${None}'    import variables    ${CURDIR}/../TestData/NIDD_modify_scf_${cell_chbw_config}.py
    import variables    ${CURDIR}/../TestData/NIDD_modify_vonr_enhance.py

    Set suite variable    ${PARAMS_TO_DELETE}     ${DELETE_SCF_DEFAULT}
    Set suite variable    ${PARAMS_TO_ADD}       ${PARAMS_TO_ADD_FOR_VONR_AND_CDRX}
    Set suite variable    ${PARAMS_TO_MODIFY}    ${MODIFY_SCF_VONR_ENHANCE}

    CA Suite preparation    prepare_ue=${True}    NSA_SA=${NSA_SA}    enb_default_scf_file=${enb_default_scf_file}
    ...    swconfig_modify=${swconfig_modify}
    ...    prepare_ue=${True}
    ...    scf_modify_parameters=${scf_modify_parameters}
    ...    pa_values_mapping=${pa_values_mapping}

    Prepare NRREL under specific cell    ca_group_mapping=${CA_GROUP_MAPPING}    prepare_nrrel=T_F_4CC
    Set tput expectation for suite level


Set tput expectation for suite level
    [Documentation]    for 9169 cases throughput check, the ${cell_index} is set to [1, 2, 4, 3],
    ...    so the throughput should align the ${cell_index}
    ${EXP_DL_INDIV_1116}    Create List    ${EXP_DL_T100M_4x4_256QAM_1116}    ${EXP_DL_F20M_2x2_256QAM}    ${EXP_DL_T60M_2x2_256QAM_1116}
    ...    ${EXP_DL_F10M_2x2_256QAM}
    ${EXP_UL_INDIV_1116}    Create List    ${EXP_UL_T100M_2x2_64QAM_1116}    ${EXP_UL_F20M_2x2_64QAM_1116}  -1    -1

    ${EXP_DL_INDIV_1116_WITH_VONR}    Create List    ${EXP_DL_T100M_4x4_256QAM_1116}    ${EXP_DL_F20M_2x2_256QAM}    ${EXP_DL_T60M_2x2_256QAM_1116}
    ...    ${EXP_DL_F10M_2x2_256QAM}
    ${EXP_UL_INDIV_1116_WITH_VONR}    Create List    ${EXP_UL_T100M_2x2_64QAM_1116}    0    -1    -1

    ${DL_PCELL_THROUGHPUT_HIGH_BLER}    set variable if    '${MRBTS_ID}' == '255'    420    510
    set suite variable     ${DL_PCELL_THROUGHPUT_HIGH_BLER}
#    ${UL_PCELL_THROUGHPUT_RSRP_BAD}    set variable if    '${MRBTS_ID}' == '255'    12    16
    set suite variable     ${UL_PCELL_THROUGHPUT_RSRP_BAD}    10

    ${EXP_UL_INDIV_PCELL_HIGH_BLER_WITH_VONR}    Create List    ${UL_PCELL_THROUGHPUT_RSRP_BAD}    0    -1    -1
    ${EXP_DL_INDIV_PCELL_HIGH_BLER_WITH_VONR}    Create List    ${DL_PCELL_THROUGHPUT_HIGH_BLER}    ${EXP_DL_F20M_2x2_256QAM}
    ...    ${EXP_DL_T60M_2x2_256QAM_1116}    ${EXP_DL_F10M_2x2_256QAM}

    ${EXP_UL_INDIV_PCELL_HIGH_BLER_NO_VONR}    Create List    ${UL_PCELL_THROUGHPUT_RSRP_BAD}    ${EXP_UL_F20M_2x2_64QAM_1116}     -1    -1
    ${EXP_DL_INDIV_PCELL_HIGH_BLER_NO_VONR}    Create List    ${DL_PCELL_THROUGHPUT_HIGH_BLER}    ${EXP_DL_F20M_2x2_256QAM}
    ...    ${EXP_DL_T60M_2x2_256QAM_1116}  ${EXP_DL_F10M_2x2_256QAM}

    ${DL_PCELL_THROUGHPUT_INCREASE}    set variable    ${1}
    set suite variable     ${DL_PCELL_THROUGHPUT_INCREASE}

    ${DL_PCELL_THROUGHPUT_LOW_BLER}    evaluate    ${DL_PCELL_THROUGHPUT_HIGH_BLER} + ${DL_PCELL_THROUGHPUT_INCREASE}
    ${EXP_UL_INDIV_PCELL_LOW_BLER_WITH_VONR}    Create List    ${UL_PCELL_THROUGHPUT_RSRP_BAD}    0   -1    -1
    ${EXP_DL_INDIV_PCELL_LOW_BLER_WITH_VONR}    Create List    ${DL_PCELL_THROUGHPUT_LOW_BLER}    ${EXP_DL_F20M_2x2_256QAM}
    ...    ${EXP_DL_T60M_2x2_256QAM_1116}  ${EXP_DL_F10M_2x2_256QAM}

    Set suite variable    ${EXP_DL_INDIV_1116}
    Set suite variable    ${EXP_UL_INDIV_1116}
    Set suite variable    ${EXP_DL_INDIV_1116_WITH_VONR}
    Set suite variable    ${EXP_UL_INDIV_1116_WITH_VONR}
    Set suite variable    ${EXP_UL_INDIV_PCELL_HIGH_BLER_WITH_VONR}
    Set suite variable    ${EXP_DL_INDIV_PCELL_HIGH_BLER_WITH_VONR}
    Set suite variable    ${EXP_UL_INDIV_PCELL_HIGH_BLER_NO_VONR}
    Set suite variable    ${EXP_DL_INDIV_PCELL_HIGH_BLER_NO_VONR}
    Set suite variable    ${EXP_UL_INDIV_PCELL_LOW_BLER_WITH_VONR}
    Set suite variable    ${EXP_DL_INDIV_PCELL_LOW_BLER_WITH_VONR}
