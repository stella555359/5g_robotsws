*** Settings ***
Documentation
...   author: Kamil Bucki, Adrianna Pienkowska, Konrad Kucharzyk
...   contact: kamil.bucki@nokia.com, adrianna.pienkowska@nokia.com, konrad.kucharzyk@nokia.com
...   description: Krakow Verification Engineering team testcases for CB009084 feature

Library     resources/suite_kw.py                          WITH NAME   suite__
Library     resources/attach.py                            WITH NAME   attach__
Library     resources/variables_preparation.py             WITH NAME   variable_prep__
Library     resources/validation_bip.py                    WITH NAME   val_bip__
Library     resources/validation_counters.py               WITH NAME   val_counters__

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
...                      AND    common.Custom Config Setup DSS
...                      AND    suite__.Set Variables Based On Deployment And Release

Test Teardown    Run Keywords    Send Configuration ID To Scout
    ...    AND    common.Teardown Wts And Collect Logs

*** Test Cases ***

[1]CB009084_E_002_B101_slice_aware_scheduler_with_DSS_enabled
    [Setup]     Prepare Environment For DSS Test
    variable_prep__.Prepare Resource Group Parameters Variable          delta_dictionary=${DELTA_DYN_KEYS_SUBSTITUTES_MAPPING_E_DSS}
    counters__.create_counter_list                                  ${COUNTERS_PRB_DL}
    ...                                                             ${COUNTERS_DSS}
    Setup For One Cell DSS Partnership                              wts_cfg=${WTS_CFG_DSS}

    suite__.wait_before_ue_attach         seconds=120
    attach__.attach_multi_ue     ues_id=${SA_3UE_IDS}
    ...                          pdus_id=${SA_3UE_IDS}
    ...                          nwslices=${SA_3UE_IDS}
    ...                          cell_id=3

    attach__.run_internal_traffic_multi_ue     ues_id=${SA_3UE_IDS}
    ...                                        pdus_id=${SA_3UE_IDS}
    ...                                        tput=${MAX_TPUT}
    ...                                        wait_time=600

    counters__.collect_counters_values
    ${COUNTERS_PATH}    get_latest_file_with_counters

    BIP Start
    suite__.wait_for_logs_proper_format         seconds=10
    BIP Stop

    val_counters__.ensure_e_dss_enabled_counters_contain_correct_values
    ...         cell=3
    ...         expected_part=70
    ...         percentage_margin=3

    ts_v.target_share_validation
    ...    quotas=${DELTA_DYN_KEYS_SUBSTITUTES_MAPPING_E_DSS}
    ...    tputs=${TPUTS_3RG}
    ...    path_to_json=${COUNTERS_PATH}/ALL_COUNTERS.json
    ...    prb_used=${DL_PRB_USED_COUNTERS_3RG_FDD_DSS}
    ...    prb_avail=${DL_PRB_AVAIL_COUNTERS_3RG_FDD_DSS}
    ...    prb_util_max=${DL_PRB_MAX_UTIL_COUNTERS_3RG_FDD_DSS}
    ...    margin=${UTILIZATION_MARGIN}


    val_bip__.save_filtered_pcap_to_txt_file            output_dir=${OUTPUT_DIR_TC}
    ...                                                 prefix=${BIP_E_DSS_ENABLED_PREFIX}
    ...                                                 using_mcshark=${BIP_USING_MCSHARK_E_DSS_ENABLED}
    ...                                                 filter=${FILTER_PDSCH_PDCCH_SEND_REQ_E_DSS_ENABLED}
    val_bip__.ensure_pdsch_send_req_e_dss_enabled_bip_contain_correct_values
    suite__.set_tc_status_to_passed     tc=EB101_DSS
