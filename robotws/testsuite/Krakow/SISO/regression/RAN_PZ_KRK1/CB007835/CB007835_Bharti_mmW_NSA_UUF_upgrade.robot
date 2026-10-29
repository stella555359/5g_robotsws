*** Settings ***
Documentation
...   Test suite for regression testing of feature CB007835
...   author: Aleksander Skworzec
...   contact: aleksander.skworzec@nokia.com

Library      String
Library      taf.rfrl.utilities.cloud_manager.artifacts
Library      testsuite/Krakow/resources/UUF/get_uuf_builds.py
Library      testsuite/Krakow/SISO/regression/RAN_PZ_KRK1/CB007835/resources/variables_Bharti.py
Library      taf.rfrl.csv4all.CSV4AllTestCases    WITH NAME    csv_tc
Library      testsuite.Krakow.SISO.regression.RAN_PZ_KRK1.CB007835.resources.BhartiCustomKeywords.BhartiCustomKeywords    WITH NAME    bck
Library      taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations    WITH NAME    cell_operations
Resource     testsuite/Krakow/SISO/regression/RAN_PZ_KRK1/CB007835/resources/keywords.robot
Resource     taf/rfrl/uuf4all/uuf4all_test_cases.robot
Resource     taf/rfrl/uuf4all/uuf4all_keywords.robot
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables    testsuite/Krakow/SISO/regression/RAN_PZ_KRK1/CB007835/resources/delta_Bharti.py

Force Tags    CA_VRF_KRK    RF50

Suite Setup       Run Keywords
...               Common Suite Setup With OnAir Test Line Preparation
...               increase_time_for_checking_cells=${1800}
...               increase_timeout_for_update_sw=${1800}
...               increase_time_for_checking_radios=${1800}
...               swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
...               prefix_tag=8CC_NSA
...               list_of_additional_allowed_alarms=@{ADDITIONAL_ALLOWED_ALARMS}
...               remove_note_60002_if_exists=${True}
...               AND
...               Get Bharti Variables
Suite Teardown    common_setups_and_teardowns.Common Suite Teardown

Test Setup        Custom Test Setup
Test Teardown     common_setups_and_teardowns.Common Postconditions With Restore Configuration If Test Failed   collect_syslog=${False}

*** Variables ***
${UPDATE_TEST_ITERATION}            5
${SITE_RESET_TEST_ITERATION}        30
${SHOULD_BE_REPORTED}=              True
@{CUSTOMERS_LIST}=                  Bharti
@{CRITICAL_FAULTS}=                 0010  0016  1806  1868  4341  4352  4383
${SOURCE_SW}=                       ${None}
${TARGET_SW}=                       ${None}
${UPDATE_TEST_FAILED}               ${False}
${QC_DOMAIN}=                       MN_RAN
${QC_PROJECT}=                      RAN_VRF
${RP_CA}                            VRF_OAM
${RP_ORGANIZATION}                  VRF_KRK_T01
${RP_LOCATION}                      VRF_KRK
${BTS_HOST_IP}                      192.168.255.129
${SCOUT_HOSTNAME}                   7_7_UTE5GCLOUDT1SK212
${SERIAL_CONSOLE}=                  ${False}
&{NODE1}                            testline_object=${tl.gnbs[0]}
@{NODES}                            ${NODE1}
@{CUSTOM_ALARMS}=                   8150    4420    1898
@{ADDITIONAL_ALLOWED_ALARMS}	    Create List
...                                 Wifi Enabled Alarm
...                                 NRRELNotConfiguredA3A5
...                                 GPS receiver alarm: firmware upgrade ongoing
...                                 PPS reference missing

#TPUT variables
${tput_duration}                    300s
${dl_tput}                          4000 Mbits/sec
${ul_tput}                          500 Mbits/sec
${tput_protocol}                    TCP
${ENABLE_RACH_OBSERVER}             ${False}

*** Test Cases ***
E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI
    [Timeout]    96h
    ${SOURCE_SW} =    IF    '${SOURCE_SW}'=='${None}'  Get CM Source Build    ELSE    Set Variable  ${SOURCE_SW}
    ${TARGET_SW} =    IF    '${TARGET_SW}'=='${None}'  Get Target Build   ELSE    Set Variable  ${TARGET_SW}
    Set To Dictionary    ${NODE1}    source_sw    ${SOURCE_SW}
    Set To Dictionary    ${NODE1}    target_sw    ${TARGET_SW}
    ${upgrade_result}=    Run Keyword And Return Status      csv_tc.E2E TL SW UPGRADE ROLLBACK WITH OAM KPI
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${UPDATE_TEST_ITERATION}
    ...                                     report=${True}
    ...                                     qc_domain=${QC_DOMAIN}
    ...                                     qc_project=${QC_PROJECT}
    ...                                     qc_id=${kpi_qc_ids['qc_upgrade']}
    ...                                     sw_build=${TARGET_SW}
    ...                                     customers_list=@{CUSTOMERS_LIST}
    ...                                     restore_to_target_sw=${True}
    Set Suite Variable   ${UPGRADE_TEST_PASSED}     ${upgrade_result}
    Run Keyword If      '${UPGRADE_TEST_PASSED}' == '${False}'      Fail    "UUF test failed - one of the iterations failed, please check the logs"
    [Teardown]    Custom Test Teardown

[1.0] CB007835-5G-A_BiDir_TCP_SU_throughput-4CC-2DL-2UL-4CC-2DL-0UL
    ${l3call_result}=    Run Keyword And Return Status    BiDir TCP throughput verification
    ...                        tput_duration=${tput_duration}  dl_tput=${dl_tput}  ul_tput=${ul_tput}  tput_protocol=${tput_protocol}
    Set Suite Variable   ${L3_CALL_TEST_PASSED}     ${l3call_result}
    Run Keyword If      '${L3_CALL_TEST_PASSED}' == '${False}'      Fail    "L3 call test failed - please check the logs"
    [Teardown]    common_setups_and_teardowns.Common Postconditions With Restore Configuration If Test Failed
    ...           collect_syslog=${False}   restore_only_if_not_onair=${False}

[1][1.0] E2E_TL_SW_upgrade_rollback_with_OAM_KPI_and_L3_Call
    [Documentation]    This test case passes if both SW upgrade and BiDir TCP tput tests are passed.
    Run Keyword If      '${UPGRADE_TEST_PASSED}' == '${True}' and '${L3_CALL_TEST_PASSED}' == '${True}'
    ...                 Log    'Both upgrade and L3 call passed - passing SW upgrade with L3 call scenario.'
    ...                 ELSE    Fail   'Failing SW upgrade with L3 call as one part failed before. Please check the logs.'

E2E_TL_Activation_Reset_with_OAM_KPI
    [Timeout]    96h
    gnbbbu.Disconnect
    csv_tc.E2E TL ACTIVATION RESET TEST
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${SITE_RESET_TEST_ITERATION}
    ...                                     report=${True}
    ...                                     qc_domain=${QC_DOMAIN}
    ...                                     qc_project=${QC_PROJECT}
    ...                                     qc_id=${kpi_qc_ids['qc_activation_reset']}
    ...                                     sw_build=${TARGET_SW}
    ...                                     customers_list=@{CUSTOMERS_LIST}


[1][1.0] E2E_TL_RU_Reset_with_OAM_KPI
    uuf4all_test_cases.OAM_RMOD_RESET
    ...          test_iteration=10
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          should_be_reported=${SHOULD_BE_REPORTED}
    ...          critical_faults=@{CRITICAL_FAULTS}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${kpi_qc_ids['qc_ru_reset']}
    ...          qc_project=${QC_PROJECT}
    ...          custom_alarms=${CUSTOM_ALARMS}
    ...          use_remote_node=${False}

[1][1.0] E2E_TL_Cell_Block_Unblock_NR_with_OAM_KPI
    uuf4all_test_cases.OAM_NRCEL_BLOCK
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          should_be_reported=${SHOULD_BE_REPORTED}
    ...          critical_faults=@{CRITICAL_FAULTS}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${kpi_qc_ids['qc_cell_block']}
    ...          qc_project=${QC_PROJECT}
    ...          custom_alarms=${CUSTOM_ALARMS}
    ...          use_remote_node=${False}

[1][1.0] E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
    uuf4all_test_cases.OAM_NRCEL_LOCK
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          should_be_reported=${SHOULD_BE_REPORTED}
    ...          critical_faults=@{CRITICAL_FAULTS}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${kpi_qc_ids['qc_cell_lock']}
    ...          qc_project=${QC_PROJECT}
    ...          custom_alarms=${CUSTOM_ALARMS}
    ...          use_remote_node=${False}

[1][1.0] CB007834-5G-11_Commisioning_with_site_reset
    uuf4all_test_cases.DELTA_COMMISSIONING_WITH_SITE_RESET_REQUIRED
    ...          test_iteration=1
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${kpi_qc_ids['qc_site_reset_commissioning']}
    ...          qc_project=${QC_PROJECT}
    ...          should_be_reported=${SHOULD_BE_REPORTED}
    ...          critical_faults=@{CRITICAL_FAULTS}
    ...          custom_alarms=${CUSTOM_ALARMS}
    ...          use_remote_node=${False}

[1][1.0] CB007834-5G-12_Commisioning_online_change
    uuf4all_test_cases.DELTA_COMMISSIONING_WITH_ONLINE_PARAMETER_MODIFICATION
    ...          test_iteration=1
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${kpi_qc_ids['qc_online_commissioning']}
    ...          qc_project=${QC_PROJECT}
    ...          should_be_reported=${SHOULD_BE_REPORTED}
    ...          critical_faults=@{CRITICAL_FAULTS}
    ...          custom_alarms=${CUSTOM_ALARMS}
    ...          use_remote_node=${False}

[1][1.0] E2E_TL_Delta_Commissioning_With_NR_Rat_Reset
    [Timeout]   24h
    uuf4all_test_cases.DELTA_COMMISSIONING_WITH_NR_RAT_RESET
    ...          test_iteration=1
    ...          delta_file=testsuite/Krakow/SISO/regression/RAN_PZ_KRK1/CB007835/resources/delta_Bharti.json
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${kpi_qc_ids['qc_delta_commissioning']}
    ...          qc_project=${QC_PROJECT}
    ...          should_be_reported=${SHOULD_BE_REPORTED}
    ...          critical_faults=@{CRITICAL_FAULTS}
    ...          custom_alarms=${CUSTOM_ALARMS}
    ...          use_remote_node=${False}

*** Keywords ***
Custom Test Setup
    common_setups_and_teardowns.Common Preconditions        collect_syslog=${False}
    Run Keyword And Ignore Error    Remove Directory         path=/home/ute/.ute-ca/cache/bts/    recursive=${True}

Custom Test Teardown
    gnbbbu.connect    force=${True}
    common_setups_and_teardowns.Common Postconditions With Restore Configuration If Test Failed

Get Bharti Variables
    ${vars_bharti}    variables_Bharti.get_variables_Bharti
    set suite variable    ${kpi_qc_ids}    ${vars_bharti['kpi_qc_ids']}
