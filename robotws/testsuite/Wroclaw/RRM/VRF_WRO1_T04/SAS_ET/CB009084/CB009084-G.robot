*** Settings ***
Documentation
...   author: Kamil Bucki, Adrianna Pienkowska
...   contact: kamil.bucki@nokia.com, adrianna.pienkowska@nokia.com
...   description: Krakow Verification Engineering team testcases for CB009084 feature

Library     resources/suite_kw.py                          WITH NAME   suite__
Library     resources/validation_egate.py                  WITH NAME   val_egate__
Library     resources/validation_counters.py               WITH NAME   val_counters__
Library     resources/validation_txt.py                    WITH NAME   val_txt__
Library     resources/variables_preparation.py             WITH NAME   variable_prep__

Library     testsuite/Wroclaw/RRM/sim_resources/Krk_regression/MN_RAN_L2/resources/Python/common_wts.py               WITH NAME   wts__
Library     testsuite/Wroclaw/RRM/sim_resources/Krk_regression/MN_RAN_L2/resources/Python/common_gnb.py               WITH NAME   gnb__
Library     testsuite/Wroclaw/RRM/sim_resources/Krk_regression/MN_RAN_L2/resources/Python/mcshark_management.py       WITH NAME   mcshark__
Library     testsuite/Wroclaw/RRM/sim_resources/Krk_regression/MN_RAN_L2/resources/Python/traffic_management.py       WITH NAME   traffic__
Library     testsuite/Wroclaw/RRM/sim_resources/Krk_regression/MN_RAN_L2/resources/Python/utilities.py                WITH NAME   utilities__
Library     testsuite/Wroclaw/RRM/sim_resources/Krk_regression/MN_RAN_L2/resources/Python/counters.py                 WITH NAME   counters__

Library     testsuite/Wroclaw/RRM/sim_resources/Krk_regression/MN_RAN_L2/resources/Python/slice_scheduling/validate_target_share.py  WITH NAME  ts_v

Resource    resources/common.robot
Resource    resources/recom.robot
Resource    ../resources/common_configuration.robot

Variables  resources/variables.py

Suite Setup     Run Keywords    wts__.Ensure Eth3 Bh Is Ok      ${BH_ETH3_IP_ADDR}
...                      AND    wts__.Ensure Eth4 Bh Is Ok      ${BH_ETH4_IP_ADDR}
...                      AND    suite__.Set Variables Based On Deployment And Release

Test Teardown    Run Keywords    Send Configuration ID To Scout
    ...    AND    Teardown Wts And Collect Logs

*** Test Cases ***

[1]CB009084_G_001_B1_slice_aware-scheduler_with_multiple_BWPs_TDD
    [Setup]     Run Keywords    suite__.Set Variables Based On Tc
    ...                  AND    common.Prepare Environment For Tests without rebooting      tc=G_B1_multiple_bwps
    ...                  AND    recom.Configure Dynamically Delta And Do Recomissioning     output_dir=${OUTPUT_DIR}
    ...                                                                                     delta_file=${DELTA_G_MULTIPLE_BWPS}
    ...                                                                                     delta_setup=${DELTA_DYN_KEYS_SUBS_MAPPING_G_MULTI_BWP}
    ...                  AND    gnb__.Reset Units And Wait For Radio Head Online

    counters__.Create Counter List      ${COUNTERS_PRB_DL}     ${COUNTERS_G_MULTIPLE_BWPS}
    variable_prep__.prepare_resource_group_parameters_variable          delta_dictionary=${DELTA_DYN_KEYS_SUBS_MAPPING_G_MULTI_BWP}

    wts__.Start Wts And Wait For Ready State     wts_config_filename=${WTS_CFG_G_MULTIPLE_BWPS}
    ...                                          wts_dir_path=${IPHY_DIR_PATH_DEFAULT}
    ...                                          edaemon_port=${EDAEMON_PORT}
    ...                                          egate_port=${EGATE_PORT}
    ...                                          sib_reception_dict=${SIB_RECEPTION_DICT_SA_SANSA}

    attach__.attach_multi_ue     ues_id=${UES_IDS_G_LARGE}
    ...                          pdus_id=${PDU_3UE_IDS_G_MULTIPLE_BWPS}
    ...                          nwslices=${SLICES_IDS_G}

    attach__.run_internal_traffic_multi_ue     ues_id=${UES_IDS_G_LARGE}
    ...                                        pdus_id=${PDU_3UE_IDS_G_MULTIPLE_BWPS}
    ...                                        tput=${MAX_TPUT_G_MULTIPLE_BWPS}
    ...                                        wait_time=600

    val_egate__.copy_egate_console_log_to_output_dir        output_dir=${OUTPUT_DIR_TC}
    val_egate__.validate_sib1_downlink_uplink_config_common_egate_console_log           bwp_type=${LARGE_BWP}

    counters__.collect_counters_values
    ${COUNTERS_PATH}    get_latest_file_with_counters

    ts_v.target_share_validation
    ...    quotas=${DELTA_DYN_KEYS_SUBS_MAPPING_G_MULTI_BWP}
    ...    tputs=${TPUTS_3RG}
    ...    path_to_json=${COUNTERS_PATH}/ALL_COUNTERS.json
    ...    prb_used=${DL_PRB_USED_COUNTERS_3RG_TDD}
    ...    prb_avail=${DL_PRB_AVAIL_COUNTERS_3RG_TDD}
    ...    prb_util_max=${DL_PRB_MAX_UTIL_COUNTERS_3RG_TDD}
    ...    margin=${UTILIZATION_MARGIN}

    counters__.get_list_of_values_for_counters      counters_list=${COUNTERS_G_MULTIPLE_BWPS}
    ...                                             set_variable=${SET_COUNTER_LIST_VARIABLES_G_MULTIPLE_BWPS}
    ...                                             cell_num=${CELL_WITH_ACTIVATED_FEATURE_WEBEM}
    ...                                             bts_num=1
    ...                                             mrbts_num=1

    val_counters__.check_if_counter_values_are_zero             counter_name=${M55139C02501}
    val_counters__.sum_up_all_counter_values_and_validate       counter_name=${M55139C02502}
    ...                                                         expected_sum=3

    suite__.set_tc_status_to_passed     tc=G_B1
