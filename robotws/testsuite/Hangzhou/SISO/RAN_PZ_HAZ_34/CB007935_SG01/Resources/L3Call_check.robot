*** Settings ***
Documentation    L3 call check steps
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/coam_gnb_classical.py
Library    random
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/l3call.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/CA/Resources/CA_Common_New/L3_call_check_based_on_RRC.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/CA/Resources/CA_keywords.robot


*** Variables ***
${TPUT_AVG_PERCENT_COMMON}    0.8
${TPUT_MIN_PERCENT_COMMON}    0.5


*** Keywords ***
Get random cell index for attach based on provided rmod ids
    [Documentation]    Author: Ding Binmei
    [Arguments]    ${rmod_ids}=${RMOD_ID_WITH_7935_ENABLED}    ${connection_alias}=GNB_OAM
    ${gnb_relation_mapping}    coam_gnb_classical.get_relation_mapping_between_cell_index_and_other_ids
    ...    connection_alias=${connection_alias}
    ${list_cell_index}    Get Dictionary Keys    ${gnb_relation_mapping}
    ${cell_index_for_rmod_ids}    Create List
    FOR    ${cell_id}    IN    @{list_cell_index}
        ${rmod_id}    Set variable    ${gnb_relation_mapping[${cell_id}]["rmod_index"]}
        Run Keyword If    '${rmod_id}' in ${rmod_ids}    Append To List    ${cell_index_for_rmod_ids}    ${cell_id}
    END
    ${random_cell_index}    Evaluate    random.choice(${cell_index_for_rmod_ids})
    [Return]    ${random_cell_index}

Start L3 call and check tput is as expected
    [Documentation]    Author: Ding Binmei
    ...    EXP_CELL_TPUT_INFO: is a dictionary with cell index as key and a dictionary with ul_tput and dl_tput as value.
    ...        it's defined under commission folder for each testline
    [Arguments]    ${cell_id_for_attach}    ${tcpdump_log_name}    ${tput_curve_customized_log_name}
    ...    ${exp_tput_info_map}=${EXP_CELL_TPUT_INFO}    ${is_need_to_stop_traffic_and_detach}=${True}
    ...    ${is_need_to_prepare_ue}=${True}
    ${f1ap_log_path}    ${tput_log_path}    L3_call_check_based_on_RRC.L3 call without traffic checked
    ...    NSA_SA=${NSA_SA}    data_transfer_direction=both
    ...    dl_tput_iperf=${DL_TPUT_IPERF}    ul_tput_iperf=${UL_TPUT_IPERF}
    ...    protocol=udp    iperf_duration=7000s    tput_duration=60s    check_tput_ignore_time=30s    tcpdump_log_name=${tcpdump_log_name}
    ...    is_need_to_prepare_ue=${is_need_to_prepare_ue}    is_need_to_stop_traffic=${is_need_to_stop_traffic_and_detach}
    Run keyword and continue on failure   Verify ue is attached to the expected cell    log_path_f1ap_ute=${f1ap_log_path}
    ...    cell_id_for_attach=${cell_id_for_attach}
    Check tput via power UE optimized    cell_index=${cell_id_for_attach}     tput_log_path=${tput_log_path}
    ...    direction=both    exp_ul=${exp_tput_info_map[${cell_id_for_attach}]['ul_tput']}
    ...    exp_dl=${exp_tput_info_map[${cell_id_for_attach}]['dl_tput']}
    ...    target_avg_percent=${TPUT_AVG_PERCENT_COMMON}    min_percent=${TPUT_MIN_PERCENT_COMMON}    actCarrierAggregation=${False}
    ...    customized_log_name=${tput_curve_customized_log_name}    is_need_to_fail_keyword=${True}

Verify traffic is still available after disable PTP
    [Arguments]    ${cell_id_for_attach}    ${tput_curve_customized_log_name}    ${exp_tput_info_map}=${EXP_CELL_TPUT_INFO}
    ${tput_log_path}    power_ue.Collect Tput     ue_type=${UE_TYPE}    duration=60s    ignore_time=30s
    ...    filter=L2Lo
    Check tput via power UE optimized    cell_index=${cell_id_for_attach}     tput_log_path=${tput_log_path}
    ...    direction=both    exp_ul=${exp_tput_info_map[${cell_id_for_attach}]['ul_tput']}
    ...    exp_dl=${exp_tput_info_map[${cell_id_for_attach}]['dl_tput']}
    ...    target_avg_percent=${TPUT_AVG_PERCENT_COMMON}    min_percent=${TPUT_MIN_PERCENT_COMMON}    actCarrierAggregation=${False}
    ...    customized_log_name=${tput_curve_customized_log_name}    is_need_to_fail_keyword=${True}
