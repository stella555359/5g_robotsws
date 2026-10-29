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

[1]CB009084_C_006_B301_slice_aware_scheduler_changing_configuration_online_with_NSA_SA_26_slices_TDD
    [Setup]     Run Keywords    suite__.Set Variables Based On Tc
    ...                  AND    common.Prepare Environment For Tests without rebooting          tc=CB
    ...                  AND    recom.Configure Dynamically Delta And Do Recomissioning         output_dir=${OUTPUT_DIR}
    ...                                                                                         delta_file=${DELTA_6NSA_20SA}
    ...                                                                                         delta_setup=${DELTA_DYN_KEYS_SUBSTITUTES_MAPPING_C}
    ...                  AND    gnb__.Reset Units And Wait For Radio Head Online

    counters__.create_counter_list                                  ${COUNTERS_PRB_DL}

    variable_prep__.Prepare Resource Group Parameters Variable          delta_dictionary=${DELTA_DYN_KEYS_SUBSTITUTES_MAPPING_C}

    wts__.Start Wts And Wait For Ready State                        wts_config_filename=${WTS_CFG_6UE}
    ...                                                             wts_dir_path=${IPHY_DIR_PATH_DEFAULT}
    ...                                                             edaemon_port=${EDAEMON_PORT}
    ...                                                             egate_port=${EGATE_PORT}
    ...                                                             sib_reception_dict=${SIB_RECEPTION_DICT_SA_SANSA}

    Sleep    30
    attach__.attach_many_sa_ue_each_to_multiple_slices              ues_id=${SA_3UE_IDS}
    ...                                                             slices_lists=${SA_20_SLICES}
    attach__.attach_many_nsa_ues                                    ues_id=${NSA_6UE_IDS }
    ...                                                             plmn=${NSA_PLMNS}
    ...                                                             cell_id=${CELL_WITH_ACTIVATED_FEATURE_WEBEM}
    attach__.start_dl_traffic_for_many_ues                          ue_ips=${20SA_6NSA_UE_IP}
    ...                                                             window=50M
    ...                                                             duration=3600

    suite__.wait_for_tput_end_state                                 seconds=600

    counters__.collect_counters_values
    ${COUNTERS_PATH}    get_latest_file_with_counters

    ts_v.target_share_validation
    ...    quotas=${DELTA_DYN_KEYS_SUBSTITUTES_MAPPING_C}
    ...    tputs=${TPUTS_26RG}
    ...    path_to_json=${COUNTERS_PATH}/ALL_COUNTERS.json
    ...    prb_used=${DL_PRB_USED_COUNTERS_26RG_TDD}
    ...    prb_avail=${DL_PRB_AVAIL_COUNTERS_26RG_TDD}
    ...    prb_util_max=${DL_PRB_MAX_UTIL_COUNTERS_26RG_TDD}
    ...    margin=${UTILIZATION_MARGIN_C}

    variable_prep__.Prepare Resource Group Parameters Variable          delta_dictionary=${DELTA_DYN_KEYS_SUBSTITUTES_MAPPING_C_RECONFIG}

    Configure Dynamically Delta And Do Recomissioning              delta_setup=${DELTA_DYN_KEYS_SUBSTITUTES_MAPPING_C_RECONFIG}
    ...                                                            delta_file=${DELTA_RECONFIG}
    ...                                                            output_dir=${OUTPUT_DIR}

    suite__.wait_for_tput_end_state                                 seconds=600

    counters__.collect_counters_values
    ${COUNTERS_PATH}    get_latest_file_with_counters

    ts_v.target_share_validation
    ...    quotas=${DELTA_DYN_KEYS_SUBSTITUTES_MAPPING_C_RECONFIG}
    ...    tputs=${TPUTS_26RG}
    ...    path_to_json=${COUNTERS_PATH}/ALL_COUNTERS.json
    ...    prb_used=${DL_PRB_USED_COUNTERS_26RG_TDD}
    ...    prb_avail=${DL_PRB_AVAIL_COUNTERS_26RG_TDD}
    ...    prb_util_max=${DL_PRB_MAX_UTIL_COUNTERS_26RG_TDD}
    ...    margin=${UTILIZATION_MARGIN_C}

    attach__.stop_iperf

    suite__.set_tc_status_to_passed         tc=B101
    suite__.set_tc_status_to_passed         tc=B102
    suite__.set_tc_status_to_passed         tc=B301
