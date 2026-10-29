*** Settings ***
Documentation
...   author: Kamil Bucki, Adrianna Pienkowska, Konrad Kucharzyk
...   contact: kamil.bucki@nokia.com, adrianna.pienkowska@nokia.com, konrad.kucharzyk@nokia.com
...   description: Krakow Verification Engineering team testcases for CB009084 feature

Library     resources/suite_kw.py                           WITH NAME   suite__
Library     resources/attach.py                             WITH NAME   attach__
Library     resources/validation_counters.py                WITH NAME   val_counters__
Library     resources/validation_bip.py                     WITH NAME   val_bip__
Library     resources/variables_preparation.py              WITH NAME   variable_prep__

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
...                      AND    mcshark__.download_mcshark_if_not_present

Test Teardown    Run Keywords    Send Configuration ID To Scout
    ...    AND    common.Teardown Wts And Collect Logs

*** Test Cases ***

[1]CB009084_F_001_B1_slice_aware_scheduler_with_basic_mu_mimo
    [Setup]     Run Keywords    suite__.Set Variables Based On Tc
    ...                  AND    common.Prepare Environment For Tests without rebooting      tc=F_B1_basic_mu_mimo
    ...                  AND    recom.Configure Dynamically Delta And Do Recomissioning     output_dir=${OUTPUT_DIR}
    ...                                                                                     delta_file=${DELTA_F_MU_MIMO}
    ...                                                                                     delta_setup=${DELTA_DYN_KEYS_SUBS_MAPPING_F_MU_MIMO}
    ...                  AND    gnb__.Reset Units And Wait For Radio Head Online

    counters__.Create Counter List      ${COUNTERS_PRB_DL}     ${COUNTERS_F_MU_MIMO}
    variable_prep__.prepare_resource_group_parameters_variable          delta_dictionary=${DELTA_DYN_KEYS_SUBS_MAPPING_F_MU_MIMO}


    wts__.start_wts_and_wait_for_ready_state                        wts_config_filename=${WTS_CFG_F_MU_MIMO}
    ...                                                             wts_dir_path=${IPHY_DIR_PATH_DEFAULT}
    ...                                                             edaemon_port=${EDAEMON_PORT}
    ...                                                             egate_port=${EGATE_PORT}
    ...                                                             sib_reception_dict=${SIB_RECEPTION_DICT_SA_SANSA}

    suite__.wait_before_ue_attach                                   seconds=30

    attach__.attach_many_sa_ues_to_slice_and_run_traffic            ues_id=${SA_3UE_IDS}
    ...                                                             cell=${CELL_WITH_ACTIVATED_FEATURE_EGATE}
    ...                                                             tput=${MAX_TPUT_F_MU_MIMO}
    ...                                                             ues_ip=${3UE_IP}
    ...                                                             beams_info=${BEAMFORMING_INFO_F_MU_MIMO}
    ...                                                             wait_time=10
    ...                                                             duration_tput=3600

    common.LOG SYSLOG BIP Start
    suite__.wait_for_logs_proper_format     seconds=10
    common.LOG SYSLOG BIP Stop

    suite__.wait_for_tput_end_state       seconds=600

    counters__.collect_counters_values
    ${COUNTERS_PATH}    get_latest_file_with_counters

    ts_v.target_share_validation
    ...    quotas=${DELTA_DYN_KEYS_SUBS_MAPPING_F_MU_MIMO}
    ...    tputs=${TPUTS_3RG}
    ...    path_to_json=${COUNTERS_PATH}/ALL_COUNTERS.json
    ...    prb_used=${DL_PRB_USED_COUNTERS_3RG_TDD}
    ...    prb_avail=${DL_PRB_AVAIL_COUNTERS_3RG_TDD}
    ...    prb_util_max=${DL_PRB_MAX_UTIL_COUNTERS_3RG_TDD}
    ...    margin=${UTILIZATION_MARGIN}

    val_bip__.save_filtered_pcap_to_txt_file            output_dir=${OUTPUT_DIR_TC}
    ...                                                 prefix=${BIP_F_MU_MIMO_PREFIX}
    ...                                                 using_mcshark=${BIP_USING_MCSHARK_F_MU_MIMO}
    ...                                                 filter=${FILTER_PDSCH_PDCCH_SEND_REQ_F}
    val_bip__.ensure_pdsch_pdcch_send_req_f_mu_mimo_bip_contain_correct_values

    suite__.set_tc_status_to_passed     tc=FB1
