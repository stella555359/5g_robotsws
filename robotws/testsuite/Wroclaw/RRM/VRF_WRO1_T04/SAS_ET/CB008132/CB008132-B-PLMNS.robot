*** Settings ***
Documentation
...   mantainer: Michal Maczek
...   contact: michal.maczek@nokia.com
...   description: Krakow Verification Engineering team testcases for CB008132 feature

Library     resources/suite_kws.py                        WITH NAME   suite__
Library     resources/utilities.py                        WITH NAME   util__

Library    testsuite/Wroclaw/RRM/sim_resources/Krk_regression/MN_RAN_L2/resources/Python/common_wts.py             WITH NAME   wts__
Library    testsuite/Wroclaw/RRM/sim_resources/Krk_regression/MN_RAN_L2/resources/Python/common_gnb.py             WITH NAME   gnb__
Library    testsuite/Wroclaw/RRM/sim_resources/Krk_regression/MN_RAN_L2/resources/Python/mcshark_management.py     WITH NAME   mcshark__
Library    testsuite/Wroclaw/RRM/sim_resources/Krk_regression/MN_RAN_L2/resources/Python/traffic_management.py     WITH NAME   traffic__
Library    testsuite/Wroclaw/RRM/sim_resources/Krk_regression/MN_RAN_L2/resources/Python/utilities.py              WITH NAME   utilities__
Library    testsuite/Wroclaw/RRM/sim_resources/Krk_regression/MN_RAN_L2/resources/Python/counters.py               WITH NAME  counters__
Library    testsuite/Wroclaw/RRM/sim_resources/Krk_regression/MN_RAN_L2/resources/Python/slice_scheduling/validate_target_share.py  WITH NAME  ts_v

Resource    resources/common.robot
Resource    resources/recom.robot
Resource    resources/tti_trace.robot
Resource    ../resources/common_configuration.robot

Variables  resources/variables.py

Suite Setup     Run Keywords    wts__.Ensure Eth3 Bh Is Ok      ${BH_ETH3_IP_ADDR}
...                      AND    wts__.Ensure Eth4 Bh Is Ok      ${BH_ETH4_IP_ADDR}
...                      AND    suite__.Set Variables Based On Deployment And Release

Test Teardown    Run Keywords    Send Configuration ID To Scout
    ...    AND    common.Teardown Wts And Collect Logs CA

*** Test Cases ***
[1]CB008132_B_013_IWK2_slice_aware_scheduler_2CC_TDD_FDD_using_3plmns
    [Setup]     Run Keywords    suite__.Set Variables Based On Tc
    ...                  AND    common.Prepare Environment For Tests without rebooting          tc=B_CA_3PLMN
    ...                  AND    recom.Configure CA 3PLMN Delta And Do Recomissioning        quotas=${QUOTAS_EXPECTED_B_CA_3PLMN}
                                ...                                                         sd=${SD_VALUES}
                                ...                                                         output_dir=${OUTPUT_DIR_TC}
    ...                  AND    gnb__.Reset Units And Wait For Radio Head Online

    counters__.create_counter_list                                  ${COUNTERS_PRB_DL}

    wts__.Start Wts And Wait For Ready State     wts_config_filename=${WTS_CFG_CA_3PLMN}
    ...                                          wts_dir_path=${IPHY_DIR_PATH_DEFAULT}
    ...                                          edaemon_port=${EDAEMON_PORT}
    ...                                          egate_port=${EGATE_PORT}
    ...                                          sib_reception_dict=${SIB_RECEPTION_DICT_SA_SANSA}
    suite__.wait_wts_ready_state_before_x2_link     seconds=200
    BuiltIn.Sleep   20
    util__.set_internal_pdu_session     ue_id=1
    ...                                 pdu_id=1
    common.Register 1st UE to 1st slice
    BuiltIn.Sleep   20
    util__.run_full_internal_traffic    ue_id=${UE_ID_1}
    ...                                 mbps=${MAX_TPUT_BOTH_SUBCELLS_TEMP}

    BuiltIn.Sleep   20
    util__.set_internal_pdu_session     ue_id=2
    ...                                 pdu_id=1
    common.Register 2nd UE to 2nd slice
    BuiltIn.Sleep   20
    util__.run_full_internal_traffic    ue_id=${UE_ID_2}
    ...                                 mbps=${MAX_TPUT_BOTH_SUBCELLS_TEMP}

    BuiltIn.Sleep   20
    util__.set_internal_pdu_session     ue_id=3
    ...                                 pdu_id=1
    common.Register 3rd UE to 3rd slice
    BuiltIn.Sleep   20
    util__.run_full_internal_traffic    ue_id=${UE_ID_3}
    ...                                 mbps=${MAX_TPUT_BOTH_SUBCELLS_TEMP}

    suite__.Wait For Tput End State     seconds=600

    counters__.collect_counters_values
    ${COUNTERS_PATH}    get_latest_file_with_counters

    ts_v.target_share_validation
    ...    quotas=${DYN_SUBSTITUE_CA_3PLMN_3_SLICE}
    ...    tputs=${TPUTS_3RG}
    ...    path_to_json=${COUNTERS_PATH}/ALL_COUNTERS.json
    ...    prb_used=${DL_PRB_USED_COUNTERS_3RG_FDD_CA}
    ...    prb_avail=${DL_PRB_AVAIL_COUNTERS_3RG_FDD_CA}
    ...    prb_util_max=${DL_PRB_MAX_UTIL_COUNTERS_3RG_FDD_CA}
    ...    margin=${UTILIZATION_MARGIN}

    ts_v.target_share_validation
    ...    quotas=${DYN_SUBSTITUE_CA_3PLMN_3_SLICE}
    ...    tputs=${TPUTS_3RG}
    ...    path_to_json=${COUNTERS_PATH}/ALL_COUNTERS.json
    ...    prb_used=${DL_PRB_USED_COUNTERS_3RG_FDD}
    ...    prb_avail=${DL_PRB_AVAIL_COUNTERS_3RG_FDD}
    ...    prb_util_max=${DL_PRB_MAX_UTIL_COUNTERS_3RG_FDD}
    ...    margin=${UTILIZATION_MARGIN}

    suite__.Set Tc Status To Passed         tc=B_CA_3PLMN
