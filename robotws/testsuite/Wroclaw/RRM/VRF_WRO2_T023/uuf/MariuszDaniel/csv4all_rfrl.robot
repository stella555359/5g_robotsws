*** Settings ***
Documentation
...   contact: Mariusz Daniel


Library        Collections
Library        taf/rfrl/csv4all/CSV4AllTestCases.py


*** Variables ***
${UPGRADE_ITERATION}           10
${RESET_ITERATIONS}            120
${TEST_ITERATION}              2
@{CUSTOM_ALARMS}               4298  4694  6150  6134  6351  7509  7513  8150  61631  4527  7307  62003  6450  7115  1906  4681  8000  1904  4547
@{CUSTOM_ALARMS_LTE_LOCK}      61631  7509  6351  6134  4011  7513  8150  7511  8000
@{CRITICAL_FAULTS}             10  4352
${LABEL}                       PZ2_WRO23_Mariusz_Daniel_SBTS
${HOSTNAME}                    10_16_MRBTS-19677
${SHOULD_BE_REPORTED}          True
@{CUSTOMERS_LIST}              Generic
${5G_SOURCE_SW}                ${None}
${5G_TARGET_SW}                ${None}
${USE_BUILDS_STORAGE}          ${True}
${RESTORE_TARGET_SW}           ${True}
${USE_TEST_PACKAGES}           ${False}
${DOWNLOAD_PATH}               ${None}
${REPORT_COMMENT}              ${None}
${ALARM_TIMEOUT}               250
${HARDWARE_CHECK_TIMEOUT}      900
${CALCULATE_KPI}               ${True}
${QC_DOMAIN}                   ${None}
${TEST_QC_ID}                  ${None}
${QC_PROJECT}                  ${None}
@{SYSLOG_IGNORED_PRINTS}=       INF
${EMAIL_RECIPIENTS}=            mariusz.daniel@nokia.com
${DISABLE_SYSLOG_CHECK}        ${False}


${SYNCHRONIZE_SOFTWARE_ON_PASSIVE}    ${True}
${USE_DCAP}                           ${False}
${STOP_TEST_AFTER_FAIL}               ${False}
${RP_CA}                              VRF_RRM
${RP_LOCATION}                        VRF_WRO2
${RP_ORGANIZATION}                    VRF_WRO2_T02

&{NODE1}                    node_vm=10.42.53.14
...                         source_sw=${5G_SOURCE_SW}
...                         target_sw=${5G_TARGET_SW}
...                         custom_allowed_alarms=${CUSTOM_ALARMS}
...                         testline_scout_name=${HOSTNAME}
...                         critical_alarms=${CRITICAL_FAULTS}
...                         alarm_timer=${ALARM_TIMEOUT}
...                         hw_to_onair_timeout=${HARDWARE_CHECK_TIMEOUT}
...                         verify_syslog=${DISABLE_SYSLOG_CHECK}
@{NODES}                    ${NODE1}

*** Test Cases ***
E2E_TL_Activation_Reset_Test
    [Timeout]  100h
    E2E TL ACTIVATION RESET TEST
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=${RESET_ITERATIONS}
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=${TEST_QC_ID}
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${CUSTOMERS_LIST}
    ...  report_comment=${REPORT_COMMENT}
    ...  topology=${LABEL}
    ...  use_external_storage=${USE_BUILDS_STORAGE}
    ...  download_path=${DOWNLOAD_PATH}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...  l3_call_method=${None}


E2E_TL_RU_Reset_with_OAM_KPI_1
    [Timeout]  100h
    E2E TL RU RESET WITH OAM KPI
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=${TEST_ITERATION}
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=${TEST_QC_ID}
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${CUSTOMERS_LIST}
    ...  report_comment=${REPORT_COMMENT}
    ...  topology=${LABEL}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...  l3_call_method=${None}


E2E_TL_Capacity_Module_Reset_with_OAM_KPI_1
    [Timeout]  100h
    ${modifications_dict} =  Create Dictionary  custom_allowed_alarms=${CUSTOM_ALARMS_LTE_LOCK}
    ${node2}  ${nodes2} =  Temporarily Modify Node  ${NODE1}  ${modifications_dict}
    E2E TL CAPACITY MODULE RESET WITH OAM KPI
    ...  nodes_details=${nodes2}
    ...  test_nodes_details=${node2}
    ...  iterations_per_node=${TEST_ITERATION}
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=${TEST_QC_ID}
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${CUSTOMERS_LIST}
    ...  report_comment=${REPORT_COMMENT}
    ...  topology=${LABEL}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...  l3_call_method=${None}


E2E_TL_Cell_Lock_Unlock_LTE_with_OAM_KPI_1
    [Timeout]  100h
    ${modifications_dict} =  Create Dictionary  custom_allowed_alarms=${CUSTOM_ALARMS_LTE_LOCK}
    ${node2}  ${nodes2} =  Temporarily Modify Node  ${NODE1}  ${modifications_dict}
    E2E TL CELL LOCK UNLOCK LTE WITH OAM KPI
    ...  nodes_details=${nodes2}
    ...  test_nodes_details=${node2}
    ...  iterations_per_node=${TEST_ITERATION}
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=${TEST_QC_ID}
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${CUSTOMERS_LIST}
    ...  report_comment=${REPORT_COMMENT}
    ...  topology=${LABEL}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...  l3_call_method=${None}

E2E_TL_Site_Reset_without_HWF_with_OAM_KPI_2
    [Timeout]  100h
    E2E TL SITE RESET WITHOUT HWF WITH OAM KPI
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=${RESET_ITERATIONS}
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=${TEST_QC_ID}
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${CUSTOMERS_LIST}
    ...  report_comment=${REPORT_COMMENT}
    ...  topology=${LABEL}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...  l3_call_method=${None}


E2E_TL_RU_Reset_with_OAM_KPI_2
    [Timeout]  100h
    E2E TL RU RESET WITH OAM KPI
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=${TEST_ITERATION}
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=${TEST_QC_ID}
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${CUSTOMERS_LIST}
    ...  report_comment=${REPORT_COMMENT}
    ...  topology=${LABEL}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...  l3_call_method=${None}


E2E_TL_Capacity_Module_Reset_with_OAM_KPI_2
    [Timeout]  100h
    ${modifications_dict} =  Create Dictionary  custom_allowed_alarms=${CUSTOM_ALARMS_LTE_LOCK}
    ${node2}  ${nodes2} =  Temporarily Modify Node  ${NODE1}  ${modifications_dict}
    E2E TL CAPACITY MODULE RESET WITH OAM KPI
    ...  nodes_details=${nodes2}
    ...  test_nodes_details=${node2}
    ...  iterations_per_node=${TEST_ITERATION}
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=${TEST_QC_ID}
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${CUSTOMERS_LIST}
    ...  report_comment=${REPORT_COMMENT}
    ...  topology=${LABEL}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...  l3_call_method=${None}


E2E_TL_Cell_Lock_Unlock_LTE_with_OAM_KPI_2
    [Timeout]  100h
    ${modifications_dict} =  Create Dictionary  custom_allowed_alarms=${CUSTOM_ALARMS_LTE_LOCK}
    ${node2}  ${nodes2} =  Temporarily Modify Node  ${NODE1}  ${modifications_dict}
    E2E TL CELL LOCK UNLOCK LTE WITH OAM KPI
    ...  nodes_details=${nodes2}
    ...  test_nodes_details=${node2}
    ...  iterations_per_node=${TEST_ITERATION}
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=${TEST_QC_ID}
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${CUSTOMERS_LIST}
    ...  report_comment=${REPORT_COMMENT}
    ...  topology=${LABEL}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...  l3_call_method=${None}

E2E_TL_Site_Reset_without_HWF_with_OAM_KPI_3
    [Timeout]  100h
    E2E TL SITE RESET WITHOUT HWF WITH OAM KPI
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=${RESET_ITERATIONS}
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=${TEST_QC_ID}
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${CUSTOMERS_LIST}
    ...  report_comment=${REPORT_COMMENT}
    ...  topology=${LABEL}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...  l3_call_method=${None}


E2E_TL_RU_Reset_with_OAM_KPI_3
    [Timeout]  100h
    E2E TL RU RESET WITH OAM KPI
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=${TEST_ITERATION}
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=${TEST_QC_ID}
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${CUSTOMERS_LIST}
    ...  report_comment=${REPORT_COMMENT}
    ...  topology=${LABEL}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...  l3_call_method=${None}


E2E_TL_Capacity_Module_Reset_with_OAM_KPI_3
    [Timeout]  100h
    ${modifications_dict} =  Create Dictionary  custom_allowed_alarms=${CUSTOM_ALARMS_LTE_LOCK}
    ${node2}  ${nodes2} =  Temporarily Modify Node  ${NODE1}  ${modifications_dict}
    E2E TL CAPACITY MODULE RESET WITH OAM KPI
    ...  nodes_details=${nodes2}
    ...  test_nodes_details=${node2}
    ...  iterations_per_node=${TEST_ITERATION}
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=${TEST_QC_ID}
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${CUSTOMERS_LIST}
    ...  report_comment=${REPORT_COMMENT}
    ...  topology=${LABEL}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...  l3_call_method=${None}


E2E_TL_Cell_Lock_Unlock_LTE_with_OAM_KPI_3
    [Timeout]  100h
    ${modifications_dict} =  Create Dictionary  custom_allowed_alarms=${CUSTOM_ALARMS_LTE_LOCK}
    ${node2}  ${nodes2} =  Temporarily Modify Node  ${NODE1}  ${modifications_dict}
    E2E TL CELL LOCK UNLOCK LTE WITH OAM KPI
    ...  nodes_details=${nodes2}
    ...  test_nodes_details=${node2}
    ...  iterations_per_node=${TEST_ITERATION}
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=${TEST_QC_ID}
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${CUSTOMERS_LIST}
    ...  report_comment=${REPORT_COMMENT}
    ...  topology=${LABEL}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...  l3_call_method=${None}

E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI_single_node_upgrade
    [Timeout]  100h
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=${UPGRADE_ITERATION}
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=${TEST_QC_ID}
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${CUSTOMERS_LIST}
    ...  report_comment=${REPORT_COMMENT}
    ...  topology=${LABEL}
    ...  use_external_storage=${USE_BUILDS_STORAGE}
    ...  download_path=${DOWNLOAD_PATH}
    ...  use_testpackage=${USE_TEST_PACKAGES}
    ...  restore_to_target_sw=${RESTORE_TARGET_SW}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...  l3_call_method=${None}
    ...  synchronize_software_on_passive=${SYNCHRONIZE_SOFTWARE_ON_PASSIVE}

E2E_TL_Cell_Block_Unblock_LTE_with_OAM_KPI
    [Timeout]  100h
    ${modifications_dict} =  Create Dictionary  custom_allowed_alarms=${CUSTOM_ALARMS_LTE_LOCK}
    ${node2}  ${nodes2} =  Temporarily Modify Node  ${NODE1}  ${modifications_dict}
    E2E TL CELL BLOCK UNBLOCK LTE WITH OAM KPI
    ...  nodes_details=${nodes2}
    ...  test_nodes_details=${node2}
    ...  iterations_per_node=${TEST_ITERATION}
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=${TEST_QC_ID}
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${CUSTOMERS_LIST}
    ...  report_comment=${REPORT_COMMENT}
    ...  topology=${LABEL}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...  l3_call_method=${None}


E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
    [Timeout]  100h
    E2E TL CELL LOCK UNLOCK NR WITH OAM KPI
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=${TEST_ITERATION}
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=${TEST_QC_ID}
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${CUSTOMERS_LIST}
    ...  report_comment=${REPORT_COMMENT}
    ...  topology=${LABEL}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...  l3_call_method=${None}


E2E_TL_Cell_Block_Unblock_NR_with_OAM_KPI
    [Timeout]  100h
    E2E TL CELL BLOCK UNBLOCK NR WITH OAM KPI
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=${TEST_ITERATION}
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=${TEST_QC_ID}
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${CUSTOMERS_LIST}
    ...  report_comment=${REPORT_COMMENT}
    ...  topology=${LABEL}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...  l3_call_method=${None}


E2E_TL_Delta_Commissioning_With_Online_Parameter_Modification
    [Timeout]  100h
    E2E TL DELTA COMMISSIONING WITH ONLINE PARAMETER MODIFICATION
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=${TEST_ITERATION}
    ...  delta=${ONLINE_PARAMETER_DELTA}
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=${TEST_QC_ID}
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${CUSTOMERS_LIST}
    ...  report_comment=${REPORT_COMMENT}
    ...  topology=${LABEL}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...  l3_call_method=${None}


E2E_TL_Delta_Commissioning_With_Site_Reset_Required
    [Timeout]  100h
    E2E TL DELTA COMMISSIONING WITH SITE RESET REQUIRED
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=${TEST_ITERATION}
    ...  delta=${SITE_RESET_DELTA}
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=${TEST_QC_ID}
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${CUSTOMERS_LIST}
    ...  report_comment=${REPORT_COMMENT}
    ...  topology=${LABEL}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...  l3_call_method=${None}


E2E_TL_BTS_Block_Unblock
    [Timeout]  100h
    E2E TL BTS BLOCK UNBLOCK
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=${TEST_ITERATION}
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=${TEST_QC_ID}
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${CUSTOMERS_LIST}
    ...  report_comment=${REPORT_COMMENT}
    ...  topology=${LABEL}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...  l3_call_method=${None}


E2E_TL_RU_Lock_Unlock
    [Timeout]  100h
    E2E TL RU LOCK UNLOCK
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=${TEST_ITERATION}
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=${TEST_QC_ID}
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${CUSTOMERS_LIST}
    ...  report_comment=${REPORT_COMMENT}
    ...  topology=${LABEL}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...  l3_call_method=${None}


E2E_TL_RU_Power_Reset
    [Timeout]  100h
    E2E TL RU POWER RESET
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=${TEST_ITERATION}
    ...  rmods_with_pdu_ports=${PDU_LIST}
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=${TEST_QC_ID}
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${CUSTOMERS_LIST}
    ...  report_comment=${REPORT_COMMENT}
    ...  topology=${LABEL}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...  l3_call_method=${None}


E2E_TL_Capacity_Module_Lock_Unlock
    [Timeout]  100h
    E2E TL CAPACITY MODULE LOCK UNLOCK
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=${TEST_ITERATION}
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=${TEST_QC_ID}
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${CUSTOMERS_LIST}
    ...  report_comment=${REPORT_COMMENT}
    ...  topology=${LABEL}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...  l3_call_method=${None}





*** Keywords ***
Temporarily Modify Node
    [Arguments]  ${node}  ${modifications_dict}  ${print_to_console}=False
    ${node2} =  Create Dictionary  &{node}
    Set To Dictionary  ${node2}  &{modifications_dict}
    ${nodes2} =  Create List  ${node2}
    Log  Nodes are modified for ${TEST_NAME} test case.\n\nNode2: ${node2}\n\nNodes2: ${nodes2}  console=${print_to_console}
    [Return]  ${node2}  ${nodes2}
