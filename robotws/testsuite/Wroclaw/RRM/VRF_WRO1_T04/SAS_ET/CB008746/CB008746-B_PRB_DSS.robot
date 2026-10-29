*** Settings ***
Documentation
...   author: Adrianna Pienkowska, Jacek Kozmic, Agata Sidlo
...   contact: adrianna.pienkowska@nokia.com, jacek.kozmic@nokia.com, agata.sidlo@nokia.com
...   description: Krakow Verification Engineering team testcases for CB008746 feature

Library     testsuite/Wroclaw/RRM/sim_resources/Krk_regression/MN_RAN_L2/resources/Python/file_management.py                  WITH NAME     file__
Library     testsuite/Wroclaw/RRM/sim_resources/Krk_regression/MN_RAN_L2/resources/Python/common_wts.py                       WITH NAME     wts__
Library     testsuite/Wroclaw/RRM/sim_resources/Krk_regression/MN_RAN_L2/resources/Python/common_gnb.py                       WITH NAME     gnb__
Library     testsuite/Wroclaw/RRM/sim_resources/Krk_regression/MN_RAN_L2/resources/Python/counters.py                         WITH NAME     counts__
Library     testsuite/Wroclaw/RRM/sim_resources/Krk_regression/MN_RAN_L2/resources/Python/slice_scheduling/suite.py           WITH NAME     suite__
Library     testsuite/Wroclaw/RRM/sim_resources/Krk_regression/MN_RAN_L2/resources/Python/slice_scheduling/attach.py          WITH NAME     attach__
Library     testsuite/Wroclaw/RRM/sim_resources/Krk_regression/MN_RAN_L2/resources/Python/slice_scheduling/validation_bip.py  WITH NAME     bip__
Library     testsuite/Wroclaw/RRM/sim_resources/Krk_regression/MN_RAN_L2/resources/Python/slice_scheduling/var_preparation.py        WITH NAME  c_p
Library     testsuite/Wroclaw/RRM/sim_resources/Krk_regression/MN_RAN_L2/resources/Python/slice_scheduling/validation_counters.py    WITH NAME  c_v

Resource    resources/common.robot
Resource    ../resources/common_configuration.robot

Variables   resources/variables.py
Variables   resources/delta_setups.py
Variables   resources/validation_dicts.py

Force Tags      STATE_CONFIGURED   RAN_5G
...             CLOUD_5G_I_LO_AP_LOOO    VARIANT_SANSA_FS_CPRI_CMWV_FDD__SBTS00

Suite Setup       Suite Setup 8746
Test Teardown     Run Keywords    Send Configuration ID To Scout
    ...    AND    Test Teardown 8746

*** Test Cases ***

CB008746-B_B103_SPID_based_slicing_with_PRB_pooling_and_DSS_enabled
    [Setup]     Run Keywords      Custom Config Setup PRB DSS
    ...         AND               Prepare Environment For PRB And DSS Test
    common.SYSLOG Start
    common__.Set Variables Based On Deployment And Release
    common__.set_variables_based_on_tc
    ...    EB101_DSS_PRB
    Prepare Environment For Tests without rebooting
    ...    EB101_DSS_PRB
    counts__.create_counter_list
    ...    ${DL_PRB_COUNTERS}
    ...    ${COUNTERS_DSS_PRB}
    ...    ${COUNTERS_DSS}
    c_p.prepare_resource_group_parameters_variable
    ...    ${PRB_DSS_VALIDATION}
    Setup DSS Partnership
    ...    wts_cfg=${WTS_CFG_PRB_DSS}
    common.Attach Multiple Ues To Plmns And Start Traffic
    ...    nr_ues=3
    ...    spid=${UE_SPID_VALUES_PRB_DSS}
    ...    plmn=${THREE_UES_PLMNS_PRB_DSS}
    ...    dl_mbps=${TPUT_PRB_DSS}
    ...    x2_setup=${False}
    ...    cell_id=${PRB_DSS_CELLS}
    common__.Wait For Counters To Update
    counts__.collect_counters_values
    BIP Start
    suite__.wait_for_logs_proper_format
    ...    seconds=3
    BIP Stop
    c_v.counter_e_prb_pooling_and_dss_validation
    ...    ts_margin=5
    ...    prb_margin=779100
    ...    counter_utilization_margin=15
    ...    dss_expected_part=70
    ...    dss_margin=3
    common.SYSLOG Stop
    bip__.save_filtered_pcap_to_txt_file
    ...    output_dir=${OUTPUT_DIR_TC}
    ...    prefix=${BIP_E_DSS_ENABLED_PREFIX}
    ...    using_mcshark=${BIP_USING_MCSHARK_E_DSS_ENABLED}
    ...    pcap_path=${OUTPUT_DIR_TC}/l1l2bip.pcap
    ...    filter=${FILTER_PDSCH_PDCCH_SEND_REQ_E_DSS_ENABLED}
    bip__.ensure_pdsch_send_req_e_dss_enabled_bip_contain_correct_values
    c_v.check_prb_activated
    suite__.set_tc_status_to_passed
    ...    tc=EB101_DSS_PRB
