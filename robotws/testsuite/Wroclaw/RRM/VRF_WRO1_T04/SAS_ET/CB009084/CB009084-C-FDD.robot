*** Settings ***
Documentation
...   author: Kamil Bucki, Adrianna Pienkowska, Konrad Kucharzyk
...   contact: kamil.bucki@nokia.com, adrianna.pienkowska@nokia.com, konrad.kucharzyk@nokia.com
...   description: Krakow Verification Engineering team testcases for CB009084 feature

Library     resources/validation_counters.py               WITH NAME   val_counters__
Library     resources/variables_preparation.py             WITH NAME   variable_prep__

Library     testsuite/Wroclaw/RRM/sim_resources/Krk_regression/MN_RAN_L2/resources/Python/counters.py                   WITH NAME   counters__
Library     testsuite/Wroclaw/RRM/sim_resources/Krk_regression/MN_RAN_L2/resources/Python/slice_scheduling/validate_target_share.py  WITH NAME  ts_v
Resource    resources/common.robot
Resource    resources/recom.robot
Resource    ../resources/common_configuration.robot

Variables  resources/variables.py

Suite Setup     Run Keywords    wts__.Ensure Eth3 Bh Is Ok      ${BH_ETH3_IP_ADDR}
...                      AND    wts__.Ensure Eth4 Bh Is Ok      ${BH_ETH4_IP_ADDR}
...                      AND    suite__.Set Variables Based On Deployment And Release

Test Teardown    Run Keywords    Send Configuration ID To Scout
    ...    AND    common.Teardown Wts And Collect Logs

*** Test Cases ***

[1]TC_01_2_UEs_2_slices_SA_QCI_6_quota_10_30_and_70_100_FDD
    [Setup]     Run Keywords    suite__.Set Variables Based On Tc
    ...                  AND    common.Prepare Environment For Tests without rebooting          tc=C_B501_HARQ_reTX_01
    ...                  AND    recom.Just Do Recomissioning                     output_dir=${OUTPUT_DIR_TC}
                                ...                                              delta_file=${DELTA_C_HARQ_RETX}
    ...                  AND    gnb__.Reset Units And Wait For Radio Head Online

    counters__.create_counter_list                                  ${COUNTERS_PRB_DL}      ${COUNTERS_C_B501_RETX}
    variable_prep__.prepare_resource_group_parameters_variable          delta_dictionary=${DELTA_DYN_KEYS_SUBSTITUTES_MAPPING_C_B501_RETX}

    wts__.Start Wts And Wait For Ready State                        wts_config_filename=${WTS_CFG_C_HARQ_RETX}
    ...                                                             wts_dir_path=${IPHY_DIR_PATH_DEFAULT}
    ...                                                             edaemon_port=${EDAEMON_PORT}
    ...                                                             egate_port=${EGATE_PORT}
    ...                                                             sib_reception_dict=${SIB_RECEPTION_DICT_SA_SANSA}

    attach__.attach_many_sa_ues_to_slice_setup_bler_and_run_traffic            ues_id=${SA_2UE_IDS}
    ...                                                                        cell=${CELL_WITH_ACTIVATED_FEATURE_WEBEM}
    ...                                                                        tput=${MAX_TPUT_C_HARQ_RETX}
    ...                                                                        ues_ip=${2UE_IP}
    ...                                                                        bler_info=${BLER_INFO_C_HARQ_RETX}
    ...                                                                        duration_tput=3600

    suite__.wait_for_tput_end_state            seconds=600

    counters__.collect_counters_values
    ${COUNTERS_PATH}    get_latest_file_with_counters

    ts_v.target_share_validation
    ...    quotas=${DELTA_DYN_KEYS_SUBSTITUTES_MAPPING_C_B501_RETX}
    ...    tputs=${TPUTS_2RG}
    ...    path_to_json=${COUNTERS_PATH}/ALL_COUNTERS.json
    ...    prb_used=${DL_PRB_USED_COUNTERS_2RG_FDD}
    ...    prb_avail=${DL_PRB_AVAIL_COUNTERS_2RG_FDD}
    ...    prb_util_max=${DL_PRB_MAX_UTIL_COUNTERS_2RG_FDD}
    ...    margin=${COUNTER_TARGET_SHARE_MARGIN_C_B501_RETX}

    Save All Counters To Variables And Calculate Needed Ratios
    Ensure QoS Groups Counters Are Close To Zero

    attach__.trigger_bler_cmd           bler_info=${TRIGGER_BLER_INFO_C_HARQ_RETX}
    suite__.wait_for_bler_in_counters_visibility            seconds=600

    counters__.collect_counters_values
    ${COUNTERS_PATH}    get_latest_file_with_counters

    ts_v.target_share_validation
    ...    quotas=${DELTA_DYN_KEYS_SUBSTITUTES_MAPPING_C_B501_RETX}
    ...    tputs=${TPUTS_2RG}
    ...    path_to_json=${COUNTERS_PATH}/ALL_COUNTERS.json
    ...    prb_used=${DL_PRB_USED_COUNTERS_2RG_FDD}
    ...    prb_avail=${DL_PRB_AVAIL_COUNTERS_2RG_FDD}
    ...    prb_util_max=${DL_PRB_MAX_UTIL_COUNTERS_2RG_FDD}
    ...    margin=${COUNTER_TARGET_SHARE_MARGIN_C_B501_RETX}

    Save All Counters To Variables And Calculate Needed Ratios
    Ensure QoS 06 Group Counter Is Non Zero And QoS 07 Group Counter Is Close To Zero

    attach__.trigger_bler_cmd           bler_info=${DEACTIVATE_BLER_INFO_C_HARQ_RETX}

    suite__.set_tc_status_to_passed         tc=reTX_01

*** Keywords ***

Save All Counters To Variables And Calculate Needed Ratios
    Log    Save All Counters To Variables And Calculate Needed Ratios
    counters__.get_list_of_values_for_counters      counters_list=${COUNTERS_C_B501_RETX}
    ...                                             set_variable=${SET_COUNTER_LIST_VARIABLES_C_B501_RETX}
    ...                                             bts_num=1
    ...                                             mrbts_num=1
    ...                                             du_num=1

Ensure QoS Groups Counters Are Close To Zero
    val_counters__.check_if_counter_values_are_zero             counter_name=${M55311C05006}
    val_counters__.check_if_counter_values_are_zero             counter_name=${M55311C05007}

Ensure QoS 06 Group Counter Is Non Zero And QoS 07 Group Counter Is Close To Zero
    val_counters__.check_if_counters_values_are_non_zero             counter_name=${M55311C05006}
    val_counters__.check_if_counter_values_are_zero                  counter_name=${M55311C05007}
