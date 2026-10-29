*** Settings ***
Documentation
...           CSV4ALL Test Suite VRF_WRO2_T04

Library         taf/rfrl/csv4all/CSV4AllTestCases.py
Resource        ../regression/regression_keywords.robot
Resource        ./resources/keywords.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ute_report.robot
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/common.py
Library         ute_syslog
Library         ./resources/delta.py
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/testline_preparation.py
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/uuf_utils.py
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/tracing.py
Library         OperatingSystem
Variables       testsuite/Wroclaw/RRM/VRF_WRO2_T04/regression/global_variables.py

Force Tags      CA_VRF_WRO2

Suite Setup     Run Keywords
...    Prepare Testline to onAir if Needed    ${CUSTOM_SW_CONFIG_FLAGS}    AND
...    Run Keyword And Ignore Error   Set Airplane Mode for All UEs

Test Teardown    Add Scout Data Info To Testcase

Test Timeout     100h

*** Variables ***
${CALCULATE_KPI}     ${True}
${CRITICAL_FAULTS}   ${VARIABLE['critical_faults']}
${custom_alarms}     ${VARIABLE['custom_alarms']}
@{customers}=         TMO US
${delta_file}        testsuite/Wroclaw/RRM/VRF_WRO2_T04/UUF/resources/delta.json
${L3_call_keyword}   ${None}
${SERIAL_CONSOLE}=   ${False}
${STOP_TEST_AFTER_FAIL}               ${False}
${USE_DCAP}    ${False}
${RESTORE_TARGET_SW}    ${True}
${USE_BUILDS_STORAGE}    ${False}
${DOWNLOAD_PATH}               ${None}

${RP_CA}   VRF_RRM
${RP_LOCATION}    VRF_WRO2
${RP_ORGANIZATION}    VRF_WRO2_T04
${QC_DOMAIN}                   ${None}
${LABEL}                       VRF_WRO2_4_CSV4ALL
${TEST_QC_ID}                  ${None}
${QC_PROJECT}                  ${None}
${report_comment}    VRF_WRO2_T04

${SHOULD_BE_REPORTED}=          ${True}
${MUMIN_CONFIG_FILE}=           ${None}

${SOURCE_SW}               ${EMPTY}
${TARGET_SW}               ${EMPTY}

${UPGRADE_ITERATIONS}           ${VARIABLE['UPGRADE_ITERATIONS']}
${SITE_RESET_ITERATIONS}        ${VARIABLE['SITE_RESET_ITERATIONS']}
${RU_RESET_ITERATIONS}           ${VARIABLE['RU_RESET_ITERATIONS']}
${BBMOD_RESET_ITERATIONS}        ${VARIABLE['BBMOD_RESET_ITERATIONS']}
${LOCK_UNLOCK_ITERATIONS}       ${VARIABLE['LOCK_UNLOCK_ITERATIONS']}
${DELTA_ITERATIONS}             ${VARIABLE['DELTA_ITERATIONS']}
@{IGNORED_PRINTS}     is not defined in SysinfoQuota.xml. Please contact the owner

&{NODE1}                    testline_object=${tl.gnbs[0]}
...                         node_vm=${tl.test_pc.default_ssh_connection_details.addr}
...                         node_alias=NR
...                         source_sw=${SOURCE_SW}
...                         target_sw=${TARGET_SW}
...                         custom_allowed_alarms=${custom_alarms}
...                         critical_alarms=${CRITICAL_FAULTS}
...                         syslog_ignored_prints=${IGNORED_PRINTS}
@{NODES}                    ${NODE1}


*** Test Cases ***
E2E_TL_SW_upgrade_rollback_with_OAM_KPI
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=${UPGRADE_ITERATIONS}
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=${TEST_QC_ID}
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${customers}
    ...  report_comment=${report_comment}
    ...  topology=${LABEL}
    ...  use_external_storage=${USE_BUILDS_STORAGE}
    ...  download_path=${DOWNLOAD_PATH}
    ...  restore_to_target_sw=${RESTORE_TARGET_SW}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...  l3_call_method=${None}

E2E_TL_Activation_Reset_with_OAM_KPI
    [Setup]   Set L3 Call To Execution
    Run Keyword And Continue On Failure    Start Continuous Tcpdump
    E2E TL ACTIVATION RESET TEST
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=${SITE_RESET_ITERATIONS}
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=${TEST_QC_ID}
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${customers}
    ...  report_comment=${report_comment}
    ...  topology=${LABEL}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...  l3_call_method=${L3_call_keyword}
    [Teardown]    Stop Continuous Tcpdump

E2E_TL_Site_Reset_with_OAM_KPI
    [Setup]   Set L3 Call To Execution
    Run Keyword And Continue On Failure    Start Continuous Tcpdump
    E2E TL SITE RESET WITH OAM KPI
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=${SITE_RESET_ITERATIONS}
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=${TEST_QC_ID}
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${customers}
    ...  report_comment=${report_comment}
    ...  topology=${LABEL}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...  l3_call_method=${L3_call_keyword}
    [Teardown]    Stop Continuous Tcpdump

E2E_TL_Power_Site_Reset_with_OAM_KPI
    [Setup]   Set L3 Call To Execution
    Run Keyword And Continue On Failure    Start Continuous Tcpdump
    E2E TL POWER SITE RESET WITH OAM KPI
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=${SITE_RESET_ITERATIONS}
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=${TEST_QC_ID}
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${customers}
    ...  report_comment=${report_comment}
    ...  topology=${LABEL}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...  l3_call_method=${L3_call_keyword}
    [Teardown]    Stop Continuous Tcpdump

E2E_TL_RU_Reset_with_OAM_KPI
    [Setup]   Set L3 Call To Execution
    E2E TL RU RESET WITH OAM KPI
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=${RU_RESET_ITERATIONS}
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=${TEST_QC_ID}
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${customers}
    ...  report_comment=${report_comment}
    ...  topology=${LABEL}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}

E2E_TL_Capacity_Module_Reset_with_OAM_KPI
    [Setup]   Set L3 Call To Execution
    E2E TL CAPACITY MODULE RESET WITH OAM KPI
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=${BBMOD_RESET_ITERATIONS}
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=${TEST_QC_ID}
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${customers}
    ...  report_comment=${report_comment}
    ...  topology=${LABEL}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}

E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
    E2E TL CELL LOCK UNLOCK NR WITH OAM KPI
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=${LOCK_UNLOCK_ITERATIONS}
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=${TEST_QC_ID}
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${customers}
    ...  report_comment=${REPORT_COMMENT}
    ...  topology=${LABEL}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}

E2E_TL_Cell_Block_UnBlock_NR_with_OAM_KPI
    E2E TL CELL BLOCK UNBLOCK NR WITH OAM KPI
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=${LOCK_UNLOCK_ITERATIONS}
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=${TEST_QC_ID}
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${customers}
    ...  report_comment=${report_comment}
    ...  topology=${LABEL}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}

E2E_TL_Delta_Commissioning_With_Online_Parameter_Modification
    ${parameter_to_modification}   Prepare Delta
    ...     filename=${delta_file}
    ...     parameter_type=online

    E2E TL DELTA COMMISSIONING WITH ONLINE PARAMETER MODIFICATION
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=${DELTA_ITERATIONS}
    ...  delta=${delta_file}
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=${TEST_QC_ID}
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${customers}
    ...  report_comment=${report_comment}
    ...  topology=${LABEL}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...  l3_call_method=${None}

E2E_TL_Delta_Commissioning_With_Site_Reset_Required
    ${parameter_to_modification}   Prepare Delta
    ...     filename=${delta_file}
    ...     parameter_type=site_reset

    E2E TL DELTA COMMISSIONING WITH SITE RESET REQUIRED
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=${DELTA_ITERATIONS}
    ...  delta=${delta_file}
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=${TEST_QC_ID}
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${customers}
    ...  report_comment=${report_comment}
    ...  topology=${LABEL}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...  l3_call_method=${None}

E2E_TL_Bts_Block_UnBlock
    E2E TL BTS BLOCK UNBLOCK
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=${LOCK_UNLOCK_ITERATIONS}
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=${TEST_QC_ID}
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${customers}
    ...  report_comment=${report_comment}
    ...  topology=${LABEL}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...  l3_call_method=${None}

E2E_TL_RMOD_Lock_Unlock
    E2E TL RU LOCK UNLOCK
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=${LOCK_UNLOCK_ITERATIONS}
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=${TEST_QC_ID}
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${customers}
    ...  report_comment=${report_comment}
    ...  topology=${LABEL}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...  l3_call_method=${None}

E2E_TL_BBMOD_Lock_Unlock
    E2E TL CAPACITY MODULE LOCK UNLOCK
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=${LOCK_UNLOCK_ITERATIONS}
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=${TEST_QC_ID}
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${customers}
    ...  report_comment=${report_comment}
    ...  topology=${LABEL}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...  l3_call_method=${None}

E2E_TL_Cell_Lock_Unlock_LTE_with_OAM_KPI
    E2E TL CELL LOCK UNLOCK LTE WITH OAM KPI
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=${LOCK_UNLOCK_ITERATIONS}
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=${TEST_QC_ID}
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${customers}
    ...  report_comment=${report_comment}
    ...  topology=${LABEL}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}

E2E_TL_Cell_Block_Unblock_GSM_with_OAM_KPI
    E2E TL CELL BLOCK UNBLOCK GSM WITH OAM KPI
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=${LOCK_UNLOCK_ITERATIONS}
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=${TEST_QC_ID}
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${customers}
    ...  report_comment=${report_comment}
    ...  topology=${LABEL}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
