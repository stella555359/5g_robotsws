*** Settings ***
Documentation
...   mantainer: Michal Maczek
...   contact: michal.maczek@nokia.com
...   description: Krakow Verification Engineering team testcases for CB008132 feature

Library     resources/suite_kws.py                        WITH NAME   suite__
Library     resources/recommissioning.py                  WITH NAME   recom__
Library     resources/validation_counters.py              WITH NAME   val_counters__
Library     resources/validation_tti.py                   WITH NAME   tti__
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
    ...    AND    common.Teardown Wts And Collect Logs

*** Test Cases ***
[1]CB008132_B_015_IWK3_slice_aware_scheduler_with_VoNR_enabled_FDD
    [Setup]     Run Keywords    suite__.Set Variables Based On Tc
    ...                  AND    common.Prepare Environment For Tests without rebooting          tc=B_VONR
    ...                  AND    recom.Configure VONR Delta And Do Recomissioning         quotas=${QUOTAS_EXPECTED_B_VONR}
                                ...                                                      sd=${SD_VALUES}
                                ...                                                      output_dir=${OUTPUT_DIR_TC}
    ...                  AND    gnb__.Reset Units And Wait For Radio Head Online

    counters__.create_counter_list                                  ${COUNTERS_PRB_DL}

    wts__.Start Wts And Wait For Ready State     wts_config_filename=${WTS_CFG_VONR}
    ...                                          wts_dir_path=${IPHY_DIR_PATH_DEFAULT}
    ...                                          edaemon_port=${EDAEMON_PORT}
    ...                                          egate_port=${EGATE_PORT}
    ...                                          sib_reception_dict=${SIB_RECEPTION_DICT_SA_SANSA}
    suite__.wait_wts_ready_state_before_x2_link     seconds=20

    util__.set_internal_pdu_session     ue_id=1
    ...                                 pdu_id=1
    util__.set_internal_pdu_session     ue_id=2
    ...                                 pdu_id=2
    util__.set_internal_pdu_session     ue_id=3
    ...                                 pdu_id=3
    util__.set_internal_pdu_session     ue_id=1
    ...                                 pdu_id=4

    wts__.Register Ue                   ue_id=${UE_ID_1}
    ...                                 cell_id=${CELL_WITH_ACTIVATED_FEATURE_INCREASED}
    ...                                 enb_id=${GNB_ID}
    wts__.Establish Pdu Session         ue_id=${UE_ID_1}
    ...                                 pdu_id=${PDU_ID_1}
    ...                                 nwslice=${NWSLICE_ID_2}
    ...                                 gw_id=${GW_ID_1}

    Run Downlink Throughput SA Max
    ...     ue_id=1
    ...     pdu_id=1
    ...     qfi=1
    ...     mbps=175

    suite__.Wait For Tput End State     seconds=600

    counters__.collect_counters_values
    ${COUNTERS_PATH}    get_latest_file_with_counters

    ts_v.target_share_validation
    ...    quotas=${DYN_SUBSTITUTE_B_VONR_FDD_1_SLICE}
    ...    tputs=${TPUTS_1RG}
    ...    path_to_json=${COUNTERS_PATH}/ALL_COUNTERS.json
    ...    prb_used=${DL_PRB_USED_COUNTERS_1RG_FDD_VONR}
    ...    prb_avail=${DL_PRB_AVAIL_COUNTERS_1RG_FDD}
    ...    prb_util_max=${DL_PRB_MAX_UTIL_COUNTERS_1RG_FDD_VONR}
    ...    margin=${UTILIZATION_MARGIN_ONE_SLICE}

    wts__.Register Ue                   ue_id=${UE_ID_2}
    ...                                 cell_id=${CELL_WITH_ACTIVATED_FEATURE_INCREASED}
    ...                                 enb_id=${GNB_ID}
    wts__.Establish Pdu Session         ue_id=${UE_ID_2}
    ...                                 pdu_id=${PDU_ID_2}
    ...                                 nwslice=${NWSLICE_ID_3}
    ...                                 gw_id=${GW_ID_2}
    Run Downlink Throughput SA Max
    ...     ue_id=2
    ...     pdu_id=2
    ...     qfi=1
    ...     mbps=175

    suite__.Wait For Tput End State     seconds=600

    counters__.collect_counters_values
    ${COUNTERS_PATH}    get_latest_file_with_counters

    ts_v.target_share_validation
    ...    quotas=${DYN_SUBSTITUTE_B_VONR_FDD_2_SLICE}
    ...    tputs=${TPUTS_2RG}
    ...    path_to_json=${COUNTERS_PATH}/ALL_COUNTERS.json
    ...    prb_used=${DL_PRB_USED_COUNTERS_2RG_FDD_VONR}
    ...    prb_avail=${DL_PRB_AVAIL_COUNTERS_2RG_FDD}
    ...    prb_util_max=${DL_PRB_MAX_UTIL_COUNTERS_2RG_FDD_VONR}
    ...    margin=${UTILIZATION_MARGIN}

    wts__.Register Ue                   ue_id=${UE_ID_3}
    ...                                 cell_id=${CELL_WITH_ACTIVATED_FEATURE_INCREASED}
    ...                                 enb_id=${GNB_ID}
    wts__.Establish Pdu Session         ue_id=${UE_ID_3}
    ...                                 pdu_id=${PDU_ID_3}
    ...                                 nwslice=${NWSLICE_ID_4}
    ...                                 gw_id=${GW_ID_3}

    Run Downlink Throughput SA Max
    ...     ue_id=3
    ...     pdu_id=3
    ...     qfi=1
    ...     mbps=175

    suite__.Wait For Tput End State                seconds=600

    counters__.collect_counters_values
    ${COUNTERS_PATH}    get_latest_file_with_counters

    ts_v.target_share_validation
    ...    quotas=${DYN_SUBSTITUTE_B_VONR_FDD_3_SLICE}
    ...    tputs=${TPUTS_3RG}
    ...    path_to_json=${COUNTERS_PATH}/ALL_COUNTERS.json
    ...    prb_used=${DL_PRB_USED_COUNTERS_3RG_FDD_VONR}
    ...    prb_avail=${DL_PRB_AVAIL_COUNTERS_3RG_FDD}
    ...    prb_util_max=${DL_PRB_MAX_UTIL_COUNTERS_3RG_FDD_VONR}
    ...    margin=${UTILIZATION_MARGIN}

    wts__.Establish Pdu Session         ue_id=${UE_ID_1}
    ...                                 pdu_id=${PDU_ID_4}
    ...                                 nwslice=${NWSLICE_ID_1}
    ...                                 gw_id=${GW_ID_4}
    wts__.Modify Pdu Session            ue_id=${UE_ID_1}
    ...                                 pdu_id=${PDU_ID_4}
    ...                                 qos_to_add=${QOS_TO_ADD_VONR}

    Run Downlink Throughput SA Max
    ...     ue_id=1
    ...     pdu_id=4
    ...     qfi=2
    ...     mbps=60
    suite__.Wait For Tput End State     seconds=600

    counters__.collect_counters_values
    ${COUNTERS_PATH}    get_latest_file_with_counters

    ts_v.target_share_validation
    ...    quotas=${DYN_SUBSTITUTE_B_VONR_FDD_4_SLICE}
    ...    tputs=${TPUTS_4RG_VONR}
    ...    path_to_json=${COUNTERS_PATH}/ALL_COUNTERS.json
    ...    prb_used=${DL_PRB_USED_COUNTERS_4RG_FDD}
    ...    prb_avail=${DL_PRB_AVAIL_COUNTERS_4RG_FDD}
    ...    prb_util_max=${DL_PRB_MAX_UTIL_COUNTERS_4RG_FDD}
    ...    margin=12

    suite__.Set Tc Status To Passed         tc=B_VONR
