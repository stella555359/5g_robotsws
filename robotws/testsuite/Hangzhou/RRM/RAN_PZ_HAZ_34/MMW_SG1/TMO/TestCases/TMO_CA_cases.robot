*** Settings ***
Documentation    This is for TMO CA cases
Resource    ../Resources/TMO_CA.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/CA/Resources/vonr.robot

Force Tags        5G_RRM    PY36    RF50

Suite Setup        Suite preparation    scf_template_path=${SCF_DEFAULT_FILE_PATH}
Suite Teardown     run keyword and ignore error    CA Suite teardown    is_log_required=${False}


*** Test Cases ***
CB008830-SR-A1_001_DL_DMRS_type2_actitivation_deactivation_online_modification_SA
    [Documentation]    Author: Ding Binmei
    ...    Peak TMO cases.
    ...    On TL053, This is for F+T 5CC CA.
    ...    Pcell: 21; Scell: 1, 301, 41, 311
    ...    ${CA_GROUP_F_T_5CC} are defined in commissionings/HGZ/${testline_name}/__init__.py
    ...    Steps as bellow:
    ...    1. Adjust PA and cell bar all other cells except for the attached cell
    ...    2. Start DL traffic and check tput, Check CA groups via RRC message.
    ...       Compare tput with values defined in EXP_CELL_TPUT_INFO(defined in commissionings/HGZ/${testline_name}/__init__.py),
    ...       layer info are calculated via RRC message
    ...    3. Start UL traffic and check bi-direction tput.
    [Setup]    Case setup    ca_group_mapping=${CA_GROUP_F_T_5CC}
    Set test variable    ${DL_TPUT_IPERF}    3700M
    Set test variable    ${UL_TPUT_IPERF}    350M
    TMO_Peak_Case_steps    exp_cell_tput_info=${EXP_CELL_TPUT_INFO}
    [Teardown]    Case teardown

CB008830_SR_C3_004_Dynamic_switch_between_type_1_and_type_2_due_to_both_VONR_and_High_Reliability_DRB_SA
    [Documentation]    Author: Ding Binmei
    ...    8830 IWK VONR with TMO config: 5CC T+F CA IWK with VONR, steps as bellow:
    ...    1. Start T+F CA call and verify: 5CC CA normally; And dlDmrsType for pcell is Type2 since 8830 enabled by default
    ...    2. Start VONR call and verify:
    ...       2.1 No CA exists since in TMO config, NRBTS.NRDRB.cellAggrLevel is set as: FR1 CA incompatible
    ...       2.2 Only traffic on pcell remained with about 5% decrease complared with peak value
    ...       2.3 dlDmrsType for pcell changed from Type2 to Type1
    ...    3. Stop VONR call and verify:
    ...       3.1 5CC CA back to normal
    ...       3.2 dlDmrsType for pcell changed back to Type2
    [Setup]    Case setup    ca_group_mapping=${CA_GROUP_T_F_5CC}
    Set test variable    ${DL_TPUT_IPERF}    3700M
    Set test variable    ${UL_TPUT_IPERF}    350M
    ${data_transfer_direction}    Set variable    both
    ${iperf_duration}    Set variable     3000s
    ${tput_duration}   Set variable    60s
    ${check_tput_ignore_time}    Set variable    30s
    ${f1ap_log_path_verify_scell_addition}    ${tput_log_path}    L3 call without traffic checked    NSA_SA=${NSA_SA}
    ...    data_transfer_direction=${data_transfer_direction}    dl_tput_iperf=${DL_TPUT_IPERF}
    ...    iperf_duration=${iperf_duration}   tput_duration=${tput_duration}    check_tput_ignore_time=${check_tput_ignore_time}
    ...    is_need_to_stop_traffic=${False}    tcpdump_log_name=S1_CA_l3_call_exist
    ${ca_info_rrc_with_CA}    CB008830_SR_C3_004_S1_1.1_verify_dlDmrsType_type2_for_pcell_and_CA_normally_activated_from_rrc_msg
    ...   f1ap_log_path_verify_scell_addition=${f1ap_log_path_verify_scell_addition}
    Run Keyword And Continue On Failure    CB008830_SR_C3_004_S1_1.2_traffic_for_CA_works_as_expected
    ...    tput_log_path=${tput_log_path}    ca_info_rrc=${ca_info_rrc_with_CA}
    ...    data_transfer_direction=${data_transfer_direction}
    Run Keyword And Continue On Failure
    ...    CB008830_SR_C3_004_S2_Start_VoNR_call_and_verify_no_CA_and_dlDmrsType_change_from_type2_to_type1_for_pcell
    ...    ca_info_rrc=${ca_info_rrc_with_CA}    data_transfer_direction=${data_transfer_direction}
    CB008830_SR_C3_004_S3_Stop_VoNR_call_and_verify_CA_back_to_normal_and_dlDmrsType_change_back_to_type2_for_pcell
    ...    ca_info_rrc=${ca_info_rrc_with_CA}    data_transfer_direction=${data_transfer_direction}
    [Teardown]    Run Keyword And Ignore Error    Run keywords    hang up voice call    AND    Case teardown

*** Keywords ***
Suite preparation
    [Documentation]    Author: Ding Binmei
    ...    Only commission on suite setup phase
    [Arguments]    ${enb_default_scf_file}=${None}    ${scf_template_path}=${SCF_DEFAULT_FILE_PATH}
    ...    ${scf_modify_parameters}=${None}    ${NSA_SA}=${NSA_SA}
    ${is_tl_delta_file_exists}    Run keyword and return status    File should exist    ${commissionings_path}/HGZ/${testline_name}/TLDelta.py
    Run keyword if    ${is_tl_delta_file_exists}
    ...    Import variables  ${commissionings_path}/HGZ/${testline_name}/TLDelta.py
    CA Suite preparation    prepare_ue=${True}    NSA_SA=${NSA_SA}
    ...    scf_template_path=${scf_template_path}    enb_default_scf_file=${enb_default_scf_file}
    ...    swconfig_modify=${None}    prepare_ue=${True}
    ...    scf_modify_parameters=${scf_modify_parameters}
    ...    pa_values_mapping=${None}    attenuator_out_ports=${PA_OUT_PORTS}    attenuator_rows=${PA_ROWS}

Case setup
    [Documentation]    Author: Ding Binmei
    [Arguments]    ${ca_group_mapping}
    ...    ${dict_params_to_modify}=${None}    ${is_log_required}=${False}
    ...    ${NSA_SA}=${NSA_SA}    ${timeout_restapi}=${TIMER_FOR_MODIFY_VIA_API}    ${allowed_faults_ids}=${ALLOWED_FAULTS_IDS}
    Set test variable    ${PCELL_ID}    ${ca_group_mapping['pcell_id']}
    Set Test Variable    ${INIT_PA}    ${ca_group_mapping['init_pa_value']}
    Common case setup    is_log_required=${is_log_required}    NSA_SA=${NSA_SA}    is_scf_backup_needed=${False}    fail_with_alarms=${False}
    ...    allowed_faults_ids=${allowed_faults_ids}
    run keyword if    ${dict_params_to_modify}!=${None}
    ...    Run keywords    nidd_modify.online_modify_nidd_parameters_via_restapi    params_modify_dict=${dict_params_to_modify}
    ...        timeout=${timeout_restapi}    AND
    ...        Wait until cluster ready based on NSA_SA type   NSA_SA=${NSA_SA}    is_need_to_setup_gnb_connection=${False}
    # download SCF file to log path for mannual rerun or mannual debug issue
    run keyword and ignore error    Download SCF file to log path
    run keyword and ignore error
    ...    Switch NSA SA mode via cell bar/unbar nr cells    pa_values_mapping=${INIT_PA}    pcell_id=${PCELL_ID}    timeout=2min
    ...        prefer_5g_nr_mode=${NSA_SA}    is_prepare_ue_needed=${False}    if_change_ENB_PA=${False}
    Wait until cluster ready based on NSA_SA type        NSA_SA=${NSA_SA}    is_need_to_setup_gnb_connection=${False}
    Sleep    30s    reason=Wait for cell status stable for attach

Case teardown
    [Arguments]    ${is_log_required}=${${IS_LOG_REQUIRED}}
    Common case teardown    detach_ue=${True}    is_scf_restore=${False}
    ...    is_log_required=${is_log_required}    is_btslog_required=${False}
    Initialize attenuator values for testline  pa_values_mapping=${INIT_PA_5CC}

TMO_Peak_Case_steps
    [Documentation]    Author: Ding Binmei
    ...    1. Adjust PA and cell bar all other cells except for the attached cell
    ...    2. Start DL traffic and check tput, compare tput expected result from RRC message
    ...    3. Start UL traffic and check bi-direction tput.
    [Arguments]    ${exp_cell_tput_info}=${EXP_CELL_TPUT_INFO}    ${NSA_SA}=${NSA_SA}    ${connection}=GNB_OAM    ${gnb_index}=0
    ...    ${iperf_duration}=3000s    ${tput_duration}=60s    ${check_tput_ignore_time}=30s
    ${f1ap_log_path_verify_scell_addition}    ${tput_log_path}    L3 call without traffic checked    NSA_SA=${NSA_SA}
    ...    connection=${connection}    gnb_index=${gnb_index}    data_transfer_direction=dl    dl_tput_iperf=${DL_TPUT_IPERF}
    ...    iperf_duration=${iperf_duration}   tput_duration=${tput_duration}    check_tput_ignore_time=${check_tput_ignore_time}
    ...    is_need_to_stop_traffic=${False}
    Run keyword and continue on failure   Verify ue is attached to the expected cell    log_path_f1ap_ute=${f1ap_log_path_verify_scell_addition}
    ...    cell_id_for_attach=${PCELL_ID}    connection_alias=${connection}
    ${ca_info_rrc}    Get CA info from rrc reconfiguration msg    log_file_path=${f1ap_log_path_verify_scell_addition}
    ${dl_scell_num}    Get Length    ${ca_info_rrc['scell_addition_info']['dl_ca_scell_pci']}
    Should be true    ${dl_scell_num} > 0    msg=CA does not exist, please check
    Run keyword and continue on failure   Verify tput based on RRC message    exp_cell_tput_mapping=${exp_cell_tput_info}
    ...    f1ap_log_file_path=${f1ap_log_path_verify_scell_addition}    tput_log_path=${tput_log_path}    ca_info_rrc=${ca_info_rrc}
    ...    customized_log_name=L3_call_with_CA_DL_only    data_transfer_direction=dl
    Start data transfer based on direction    data_transfer_direction=ul
    ...    ul_tput=${UL_TPUT_IPERF}    dl_tput=${DL_TPUT_IPERF}    duration=${iperf_duration}
    ${tput_log_path}    power_ue.Collect Tput     ue_type=${UE_TYPE}    duration=${tput_duration}    filter=L2Lo
    ...    ignore_time=${check_tput_ignore_time}
    Verify tput based on RRC message    exp_cell_tput_mapping=${exp_cell_tput_info}    f1ap_log_file_path=${f1ap_log_path_verify_scell_addition}
    ...    tput_log_path=${tput_log_path}    ca_info_rrc=${ca_info_rrc}    customized_log_name=L3_call_with_CA_both    data_transfer_direction=both
    ...    is_analysis_log_captured=${True}
    [Teardown]  Run keyword and ignore error    Stop data transfer and detach UE    data_transfer_direction=both

##################For case CB008830_SR_C3_004
CB008830_SR_C3_004_S1_1.1_verify_dlDmrsType_type2_for_pcell_and_CA_normally_activated_from_rrc_msg
    [Documentation]    Author: Ding Binmei
    ...    Start T+F CA call(Bi direction) and verify:
    ...      1.1 5CC CA activated normally;
    ...      1.2 dlDmrsType for pcell is Type2 since 8830 enabled by default
    [Arguments]    ${f1ap_log_path_verify_scell_addition}
    Run keyword and continue on failure   Verify ue is attached to the expected cell    log_path_f1ap_ute=${f1ap_log_path_verify_scell_addition}
    ...    cell_id_for_attach=${PCELL_ID}
    ${dlDmrsType_pcell}    Get dlDmrsType from rrc reconfiguration msg for pecll    log_file_path=${f1ap_log_path_verify_scell_addition}
    Run keyword and continue on failure   Should Be Equal As Strings    ${dlDmrsType_pcell}    type2
    ${ca_info_rrc}    Get CA info from rrc reconfiguration msg    log_file_path=${f1ap_log_path_verify_scell_addition}
    ${dl_scell_num}    Get Length    ${ca_info_rrc['scell_addition_info']['dl_ca_scell_pci']}
    Should be true    ${dl_scell_num} > 0    msg=CA does not exist, please check
    [Return]    ${ca_info_rrc}

CB008830_SR_C3_004_S1_1.2_traffic_for_CA_works_as_expected
    [Documentation]    Author: Ding Binmei
    ...    Verify tput for CA
    [Arguments]    ${tput_log_path}    ${ca_info_rrc}    ${exp_cell_tput_info}=${EXP_CELL_TPUT_INFO}
    ...    ${data_transfer_direction}=both
    Verify tput based on RRC message    exp_cell_tput_mapping=${exp_cell_tput_info}
    ...    tput_log_path=${tput_log_path}    ca_info_rrc=${ca_info_rrc}
    ...    customized_log_name=S1_L3_call_with_CA    data_transfer_direction=${data_transfer_direction}
    ...    is_analysis_log_captured=${True}    bip_log_name=S1_bip_log_check_tput_failed

CB008830_SR_C3_004_S2_Start_VoNR_call_and_verify_no_CA_and_dlDmrsType_change_from_type2_to_type1_for_pcell
    [Documentation]    Author: Ding Binmei
    ...    Start VONR call and verify:
    ...    2.1 No CA exists since in TMO config, NRBTS.NRDRB.cellAggrLevel is set as: FR1 CA incompatible
    ...    2.2 Only traffic on pcell remained with about 5% decrease compared with peak value
    ...    2.3 dlDmrsType for pcell changed from Type2 to Type1
    ...    ${tput_discount_due_to_vonr}: refers to tput discount compared with original tput value
    [Arguments]    ${ca_info_rrc}    ${exp_cell_tput_info}=${EXP_CELL_TPUT_INFO}    ${tput_duration}=60s    ${check_tput_ignore_time}=30s
    ...    ${tput_discount_due_to_vonr}=${0.95}    ${data_transfer_direction}=both
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${tcpdump_log_name}    Set variable    S2_Start_voNR_call_${timestamp}
    Start capture F1AP log    tcpdump_collector_name=${tcpdump_log_name}
    Make a VoNR call    ue_index=${0}    try_voice_call_duration=5    vonr_num=6688    hung_up_voice_call=${False}
    ${tput_log_path}    power_ue.Collect Tput     ue_type=${UE_TYPE}    duration=${tput_duration}    ignore_time=${check_tput_ignore_time}
    ...    filter=L2Lo
    ${f1ap_log_with_vonr_call}    logs.Stop capture F1AP log    tcpdump_collector_name=${tcpdump_log_name}
    Run keyword and continue on failure   Verify VoNR call is started successfully    log_file_path=${f1ap_log_with_vonr_call}
    ${dlDmrsType_pcell}    Get dlDmrsType from rrc reconfiguration msg for pecll    log_file_path=${f1ap_log_with_vonr_call}
    Run keyword and continue on failure   Should Be Equal As Strings    ${dlDmrsType_pcell}    type1
    ...    msg=Check dlDmrsType failed. As pcell dlDmrsType is not changed to type1 after VONR call
    ${ca_info_no_ca}    Generate ca info for traffic verification with no CA exist    exp_cell_tput_mapping=${exp_cell_tput_info}
    ...    ca_info_from_rrc=${ca_info_rrc}
    ${target_avg_percent}    Evaluate    round(0.95*${tput_discount_due_to_vonr}, 2)
    ${min_percent}  Evaluate    round(0.85*${tput_discount_due_to_vonr}, 2)
    Run keyword and continue on failure   Verify tput based on RRC message    exp_cell_tput_mapping=${exp_cell_tput_info}
    ...    f1ap_log_file_path=${f1ap_log_with_vonr_call}    tput_log_path=${tput_log_path}    ca_info_rrc=${ca_info_no_ca}
    ...    customized_log_name=S2_L3_call_with_No_CA_after_voNR_call    data_transfer_direction=${data_transfer_direction}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    [Return]    ${f1ap_log_with_vonr_call}
    [Teardown]    Run keyword and ignore error    Stop Tcpdump via collector    tcpdump_collector_name=${tcpdump_log_name}

CB008830_SR_C3_004_S3_Stop_VoNR_call_and_verify_CA_back_to_normal_and_dlDmrsType_change_back_to_type2_for_pcell
    [Documentation]    Author: Ding Binmei
    ...    Stop VONR call and verify:
    ...    3.1 5CC CA back to normal
    ...    3.2 dlDmrsType for pcell changed back to Type2
    [Arguments]        ${ca_info_rrc}    ${exp_cell_tput_info}=${EXP_CELL_TPUT_INFO}    ${tput_duration}=60s
    ...    ${check_tput_ignore_time}=30s    ${data_transfer_direction}=both
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${tcpdump_log_name}    Set variable    S3_Stop_voNR_call_${timestamp}
    Start capture F1AP log    tcpdump_collector_name=${tcpdump_log_name}
    hang up voice call
    sleep    20s
    ${f1ap_log_with_vonr_call_released}    logs.Stop capture F1AP log    tcpdump_collector_name=${tcpdump_log_name}
    Run keyword and continue on failure   Verify VoNR call is released successfully    log_file_path=${f1ap_log_with_vonr_call_released}
    ${dlDmrsType_pcell}    Get dlDmrsType from rrc reconfiguration msg for pecll    log_file_path=${f1ap_log_with_vonr_call_released}
    Run keyword and continue on failure   Should Be Equal As Strings    ${dlDmrsType_pcell}    type2
    ${tput_log_path}    power_ue.Collect Tput     ue_type=${UE_TYPE}    duration=${tput_duration}    ignore_time=${check_tput_ignore_time}
    ...    filter=L2Lo
    Run keyword and continue on failure   Verify tput based on RRC message    exp_cell_tput_mapping=${exp_cell_tput_info}
    ...    tput_log_path=${tput_log_path}    ca_info_rrc=${ca_info_rrc}
    ...    customized_log_name=S3_L3_call_with_CA_back_to_normal    data_transfer_direction=${data_transfer_direction}
    [Teardown]    Run keyword and ignore error    Run keywords    Stop Tcpdump via collector    tcpdump_collector_name=${tcpdump_log_name}  AND
    ...    Stop data transfer and detach UE    data_transfer_direction=${data_transfer_direction}


