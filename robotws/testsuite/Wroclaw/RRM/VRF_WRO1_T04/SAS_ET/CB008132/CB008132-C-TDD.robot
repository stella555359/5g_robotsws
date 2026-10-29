*** Settings ***
Documentation
...   author: Kamil Bucki, Adrianna Pienkowska, Konrad Kucharzyk
...   contact: kamil.bucki@nokia.com, adrianna.pienkowska@nokia.com, konrad.kucharzyk@nokia.com
...   description: Krakow Verification Engineering team testcases for CB008132 feature

Library     resources/suite_kws.py                          WITH NAME   suite__

Library     testsuite/Wroclaw/RRM/sim_resources/Krk_regression/MN_RAN_L2/resources/Python/common_wts.py               WITH NAME   wts__
Library     testsuite/Wroclaw/RRM/sim_resources/Krk_regression/MN_RAN_L2/resources/Python/common_gnb.py               WITH NAME   gnb__
Library     testsuite/Wroclaw/RRM/sim_resources/Krk_regression/MN_RAN_L2/resources/Python/mcshark_management.py       WITH NAME   mcshark__
Library     testsuite/Wroclaw/RRM/sim_resources/Krk_regression/MN_RAN_L2/resources/Python/traffic_management.py       WITH NAME   traffic__
Library     testsuite/Wroclaw/RRM/sim_resources/Krk_regression/MN_RAN_L2/resources/Python/utilities.py                WITH NAME   utilities__
Library     testsuite/Wroclaw/RRM/sim_resources/Krk_regression/MN_RAN_L2/resources/Python/counters.py                 WITH NAME   counters__
Library     testsuite/Wroclaw/RRM/sim_resources/Krk_regression/MN_RAN_L2/resources/Python/slice_scheduling/validate_target_share.py  WITH NAME  ts_v

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
[1]CB008132_C_006_B301_slice_aware_scheduler_cell_reconfiguration_with NSA_TDD
    [Setup]     Run Keywords    suite__.Set Variables Based On Tc
    ...                  AND    common.Prepare Environment For Tests without rebooting           tc=C301
    ...                  AND    recom.Configure 6 NSA Slice And Do Recomissioning                quotas=${QUOTAS_EXPECTED_C_B301}
    ...                                                                                          output_dir=${OUTPUT_DIR_TC}
    ...                  AND    gnb__.Reset Units And Wait For Radio Head Online

    counters__.create_counter_list                                  ${COUNTERS_PRB_DL}

    common.Start WTS And Check Proper Quotas                                  quotas=${QUOTAS_EXPECTED_C_B301}
    common.Attach 6 NSA UE Run Traffic And Collect Logs

    counters__.collect_counters_values
    ${COUNTERS_PATH}    get_latest_file_with_counters

    ts_v.target_share_validation
    ...    quotas=${DYN_SUBSTITUTE_C_B301_TDD_6_SLICE}
    ...    tputs=${TPUTS_3RG}
    ...    path_to_json=${COUNTERS_PATH}/ALL_COUNTERS.json
    ...    prb_used=${DL_PRB_USED_COUNTERS_6RG_TDD}
    ...    prb_avail=${DL_PRB_AVAIL_COUNTERS_6RG_TDD}
    ...    prb_util_max=${DL_PRB_MAX_UTIL_COUNTERS_6RG_TDD}
    ...    margin=${UTILIZATION_MARGIN_4}

    Reconfigure Quotas And Run Traffic

    counters__.collect_counters_values
    ${COUNTERS_PATH}    get_latest_file_with_counters

    ts_v.target_share_validation
    ...    quotas=${DYN_SUBSTITUTE_C_B301_RECONF_TDD_6_SLICE}
    ...    tputs=${TPUTS_3RG}
    ...    path_to_json=${COUNTERS_PATH}/ALL_COUNTERS.json
    ...    prb_used=${DL_PRB_USED_COUNTERS_6RG_TDD}
    ...    prb_avail=${DL_PRB_AVAIL_COUNTERS_6RG_TDD}
    ...    prb_util_max=${DL_PRB_MAX_UTIL_COUNTERS_6RG_TDD}
    ...    margin=${UTILIZATION_MARGIN_4}

    suite__.Set Tc Status To Passed         tc=C301
    suite__.Set Tc Status To Passed         tc=C011
