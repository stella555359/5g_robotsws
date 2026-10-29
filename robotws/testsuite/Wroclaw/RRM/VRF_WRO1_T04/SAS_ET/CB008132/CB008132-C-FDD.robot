*** Settings ***
Documentation
...   author: Kamil Bucki, Adrianna Pienkowska, Konrad Kucharzyk
...   contact: kamil.bucki@nokia.com, adrianna.pienkowska@nokia.com, konrad.kucharzyk@nokia.com
...   description: Krakow Verification Engineering team testcases for CB008132 feature

Library     resources/suite_kws.py                          WITH NAME   suite__
Library     resources/validation_counters.py                WITH NAME   val_counters__
Library    resources/utilities.py                WITH NAME   util__

Library    testsuite/Wroclaw/RRM/sim_resources/Krk_regression/MN_RAN_L2/resources/Python/common_wts.py               WITH NAME   wts__
Library    testsuite/Wroclaw/RRM/sim_resources/Krk_regression/MN_RAN_L2/resources/Python/common_gnb.py               WITH NAME   gnb__
Library    testsuite/Wroclaw/RRM/sim_resources/Krk_regression/MN_RAN_L2/resources/Python/mcshark_management.py       WITH NAME   mcshark__
Library    testsuite/Wroclaw/RRM/sim_resources/Krk_regression/MN_RAN_L2/resources/Python/traffic_management.py       WITH NAME   traffic__
Library    testsuite/Wroclaw/RRM/sim_resources/Krk_regression/MN_RAN_L2/resources/Python/utilities.py                WITH NAME   utilities__
Library    testsuite/Wroclaw/RRM/sim_resources/Krk_regression/MN_RAN_L2/resources/Python/counters.py                 WITH NAME   counters__
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

[1]CB008132_C_013_IWK4_slice_aware_scheduler_2CC_TDD_FDD_using_3plmns_with_NSA_SA
    [Setup]     Run Keywords    suite__.Set Variables Based On Tc
    ...                  AND    common.Prepare Environment For Tests without rebooting      tc=C_CA_3PLMN
    ...                  AND    recom.Configure NSA CA 3PLMN Delta And Do Recomissioning    quotas=${QUOTAS_EXPECTED_C_3PLMN}
    ...                                                                                     sd=${SD_VALUES}
    ...                                                                                     output_dir=${OUTPUT_DIR_TC}
    ...                                                                                     resourceGroup_dn_list=${RESOURCEGROUP_DN_LIST_C_3PLMN}
    ...                  AND    gnb__.Reset Units And Wait For Radio Head Online

    counters__.create_counter_list                                  ${COUNTERS_PRB_DL}      ${C_3PLMN_3UE_COUNTERS_LIST}

    common.SYSLOG Start
    wts__.Start Wts And Wait For Ready State     wts_config_filename=${WTS_CFG_C_3PLMN}
    ...                                          wts_dir_path=${IPHY_DIR_PATH_DEFAULT}
    ...                                          edaemon_port=${EDAEMON_PORT}
    ...                                          egate_port=${EGATE_PORT}
    ...                                          sib_reception_dict=${SIB_RECEPTION_DICT_SA_SANSA}

    suite__.Wait For Tput End State     seconds=30

    wts__.Setup X2 Link

    wts__.Attach Ue To Plmn And Perform Sgnb Addition           ue_id=${UE_ID_12}
    ...                                                         bearer=${BEARER_ID_3}
    ...                                                         cell_id=${CELL_WITH_ACTIVATED_FEATURE}
    ...                                                         enb_id=${GNB_ID}
    ...                                                         plmn_enb=${PLMN_ID_1}
    ...                                                         selected_plmn=${UE_PLMN_312_490}
    ...                                                         serving_plmn=${UE_PLMN_312_490}

    common.Run Downlink Throughput NSA 5 times To Achieve Max Tput For 1st UE                   ue_id=${UE_ID_12}
    ...                                                                                         mbps=175
    ...                                                                                         bearer_id=${BEARER_ID_3}

    util__.set_internal_pdu_session     ue_id=4
    ...                                 pdu_id=1
    wts__.Register Ue                   ue_id=${UE_ID_4}
    ...                                 cell_id=${CELL_WITH_ACTIVATED_FEATURE}
    ...                                 enb_id=${GNB_ID}

    wts__.Establish Pdu Session         ue_id=${UE_ID_4}
    ...                                 pdu_id=${PDU_ID_1}
    ...                                 nwslice=${NWSLICE_ID_1}
    ...                                 gw_id=${GW_ID_1}

    util__.run_full_internal_traffic    ue_id=${UE_ID_4}
    ...                                 mbps=${MAX_TPUT_BOTH_SUBCELLS_TEMP}

    wts__.Attach Ue To Plmn And Perform Sgnb Addition           ue_id=${UE_ID_13}
    ...                                                         bearer=${BEARER_ID_4}
    ...                                                         cell_id=${CELL_WITH_ACTIVATED_FEATURE}
    ...                                                         enb_id=${GNB_ID}
    ...                                                         plmn_enb=${PLMN_ID_1}
    ...                                                         selected_plmn=${UE_PLMN_313_491}
    ...                                                         serving_plmn=${UE_PLMN_313_491}

    common.Run Downlink Throughput NSA 5 times To Achieve Max Tput For 1st UE    ue_id=${UE_ID_13}
    ...                                                                          mbps=175
    ...                                                                          bearer_id=${BEARER_ID_4}

    suite__.Wait For Tput End State     seconds=600

    counters__.collect_counters_values
    ${COUNTERS_PATH}    get_latest_file_with_counters

    val_counters__.Ensure Successful Radio Admissions Are Correct By Dictionary
    ...         validation_dictionary=${C_13_3PLMN_3UE_SUCCES_ADMISSIONS_RADIO_VALIDATION_DICTIONARY}
    ...         validation_step=after_3rd_ue

    ts_v.target_share_validation
    ...    quotas=${DYN_SUBSTITUE_CA_3PLMN_3_SLICE}
    ...    tputs=${TPUTS_3RG}
    ...    path_to_json=${COUNTERS_PATH}/ALL_COUNTERS.json
    ...    prb_used=${DL_PRB_USED_COUNTERS_3RG_TDD_CA}
    ...    prb_avail=${DL_PRB_AVAIL_COUNTERS_3RG_TDD}
    ...    prb_util_max=${DL_PRB_MAX_UTIL_COUNTERS_3RG_TDD_CA}
    ...    margin=${UTILIZATION_MARGIN}

    ts_v.target_share_validation
    ...    quotas=${DYN_SUBSTITUE_CA_3PLMN_1_SLICE}
    ...    tputs=${TPUTS_1RG}
    ...    path_to_json=${COUNTERS_PATH}/ALL_COUNTERS.json
    ...    prb_used=${DL_PRB_USED_COUNTERS_1RG_FDD_VONR}
    ...    prb_avail=${DL_PRB_AVAIL_COUNTERS_1RG_FDD}
    ...    prb_util_max=${DL_PRB_MAX_UTIL_COUNTERS_1RG_FDD_VONR}
    ...    margin=${UTILIZATION_MARGIN_ONE_SLICE}

    common.SYSLOG Stop
    suite__.Set Tc Status To Passed         tc=C_CA_3PLMN
