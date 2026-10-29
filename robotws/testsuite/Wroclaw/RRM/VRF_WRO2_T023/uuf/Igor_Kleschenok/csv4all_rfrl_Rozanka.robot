*** Settings ***
Documentation
...   contact: Igor Kleschenok

Library        taf.sw.reporting_portal
Library        taf.ul.alarms_watchdog
Library        taf.sw.scout  WITH NAME  scout
Resource       ../../resources/ca_IWK.robot
Library        taf/rfrl/csv4all/CSV4AllTestCases.py
Library        taf/rfrl/csv4all/resources/utilities/utilities.py

*** Variables ***
${ABSTRACT_LIB_CONFIG}=         /home/ute/testline_configuration/7_16_UTE5GCLOUDU001/ta_ue_config.yaml
${TA_ATTENUATOR_CONFIG}=        /home/ute/testline_configuration/7_16_UTE5GCLOUDU001/ta_ue_config.yaml
${SCOUT_TL_NAME}                7_16_UTE5GCLOUDU001_1
${USE_SCOUT_INTERNAL_ID}        True

${UPGRADE_TEST_ITERATION}=                  10
${TEST_ITERATION}=                          10
${SITE_RESET_TEST_ITERATION}=               15
${SITE_ACTIVATION_RESET_TEST_ITERATION}=    14
${LTE_RAT_RESET_TEST_ITERATION}=            3
${NR_RAT_RESET_TEST_ITERATION}=             3
${COMMISSIONING_ITERATION}=                 2
${CELL_ITERATION}=                          5

@{CUSTOM_ALARMS}=               1904  4298  61631  4527  8150  7307  62003  7509  7513  6351  4694  6150  1900  6134  7511  7114  4373  4385  8000
@{CRITICAL_FAULTS}=             @{EMPTY}
${ALARM_TIMEOUT}=               120
${HARDWARE_CHECK_TIMEOUT}=      480
${LABEL}=                       PZ2_WRO23_Igor_Kleschenok_gNB
${HOSTNAME}=                    7_16_UTE5GCLOUDU001_1
${SHOULD_BE_REPORTED}=          ${True}
@{CUSTOMERS_LIST}=              Generic
${SOURCE_SW}=                   ${None}
${TARGET_SW}=                   ${None}
${DOWNLOAD_PATH}=               ${None}
${ONLINE_PARAMETER_DELTA}=      testsuite/Wroclaw/RRM/VRF_WRO2_T023/uuf/Igor_Kleschenok/resources/json_files/delta_online_parameter.json
${SITE_RESET_DELTA}=            testsuite/Wroclaw/RRM/VRF_WRO2_T023/uuf/Igor_Kleschenok/resources/json_files/delta_site_reset.json
${NR_RAT_RESET_DELTA}=          testsuite/Wroclaw/RRM/VRF_WRO2_T023/uuf/Igor_Kleschenok/resources/json_files/delta_nr_rat_reset.json
${USE_BUILDS_STORAGE}=          ${False}
${RESTORE_TARGET_SW}=           ${True}
${DISABLE_SYSLOG_CHECK}=        ${False}
@{USER_SUSPICIOUS_PRINTS}=      @{EMPTY}
${REPORT_COMMENT}=              ${None}
${CALCULATE_KPI}=               ${True}
${EMAIL_RECIPIENTS}=            igor.kleschenok@nokia.com  # email or emails separate by comma eg. name@nokia.com,name@nokia.com
${QC_DOMAIN}=                   MN_RAN
${QC_PROJECT}=                  RAN_VRF
${USE_TEST_PACKAGES}=           ${False}
${SYNCHRONIZE_SOFTWARE}=        ${True}
${USE_DCAP}=                    ${False}
${STOP_TEST_AFTER_FAIL}=        ${False}
${RP_CA}=                       VRF_RRM
${RP_LOCATION}=                 VRF_WRO2
${RP_ORGANIZATION}=             VRF_WRO2_T03_01

&{NODE1}                        node_alias=5G
...                             testline_object=${tl.gnbs[0]}
...                             source_sw=${SOURCE_SW}
...                             target_sw=${TARGET_SW}
...                             custom_allowed_alarms=${CUSTOM_ALARMS}
...                             critical_alarms=${CRITICAL_FAULTS}
...                             alarm_timer=${ALARM_TIMEOUT}
...                             hw_to_onair_timeout=${HARDWARE_CHECK_TIMEOUT}
...                             verify_syslog=${DISABLE_SYSLOG_CHECK}

&{NODE2}                        node_alias=4G
...                             testline_object=${tl.enbs[0]}
...                             source_sw=${SOURCE_SW}
...                             target_sw=${TARGET_SW}
...                             custom_allowed_alarms=${CUSTOM_ALARMS}
...                             critical_alarms=${CRITICAL_FAULTS}
...                             alarm_timer=${ALARM_TIMEOUT}
...                             hw_to_onair_timeout=${HARDWARE_CHECK_TIMEOUT}
...                             verify_syslog=${DISABLE_SYSLOG_CHECK}
@{NODES}                        ${NODE1}    ${NODE2}



*** Keywords ***

Set Source Software And Target Software
    ${SOURCE_SW}=    Run Keyword If  '${SOURCE_SW}'=='${None}'  Get Source SW
    ...   ELSE  set variable  ${SOURCE_SW}
    ${TARGET_SW}=    Run Keyword If  '${TARGET_SW}'=='${None}'  Get Target SW
    ...   ELSE  set variable  ${TARGET_SW}
    Set to dictionary         ${NODE1}
    ...                       source_sw=${SOURCE_SW}
    ...                       target_sw=${TARGET_SW}


*** Test Cases ***

E2E_TL_Parallel_SW_Upgrade_Rollback_with_OAM_KPI
    [Timeout]   100h
    Set Source Software And Target Software
    E2E PARALLEL SW UPGRADE ROLLBACK WITH OAM KPI
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODES}
    ...          iterations_per_node=${UPGRADE_TEST_ITERATION}
    ...          report=${SHOULD_BE_REPORTED}
    ...          use_dcap=${USE_DCAP}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${None}
    ...          qc_project=${QC_PROJECT}
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          report_comment=${REPORT_COMMENT}
    ...          topology=${LABEL}
    ...          use_external_storage=${USE_BUILDS_STORAGE}
    ...          download_path=${DOWNLOAD_PATH}
    ...          use_testpackage=${USE_TEST_PACKAGES}
    ...          restore_to_target_sw=${RESTORE_TARGET_SW}
    ...          stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...          l3_call_method=${None}
    ...          synchronize_software_on_passive=${SYNCHRONIZE_SOFTWARE}

E2E_TL_Activation_Reset_Test
    [Timeout]  100h
    E2E TL ACTIVATION RESET TEST
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=${SITE_ACTIVATION_RESET_TEST_ITERATION}
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${None}
    ...  qc_id=${None}
    ...  qc_project=${None}
    ...  customers_list=${CUSTOMERS_LIST}
    ...  report_comment=${REPORT_COMMENT}
    ...  topology=${LABEL}
    ...  use_external_storage=${USE_BUILDS_STORAGE}
    ...  download_path=${DOWNLOAD_PATH}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...  l3_call_method=${None}


E2E_TL_RU_Reset_with_OAM_KPI
    [Timeout]   100h
    E2E TL RU RESET WITH OAM KPI
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODE1}
    ...  iterations_per_node=${TEST_ITERATION}
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=${None}
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${CUSTOMERS_LIST}
    ...  report_comment=${REPORT_COMMENT}
    ...  topology=${LABEL}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...  l3_call_method=${None}

E2E_TL_Capacity_Module_Reset_with_OAM_KPI
    [Timeout]   100h
    E2E TL CAPACITY MODULE RESET WITH OAM KPI
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODE1}
    ...  iterations_per_node=${TEST_ITERATION}
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=${None}
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${CUSTOMERS_LIST}
    ...  report_comment=${REPORT_COMMENT}
    ...  topology=${LABEL}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...  l3_call_method=${None}

E2E_TL_Delta_Commissioning_With_Online_Parameter_Modification
    [Timeout]   100h
    E2E TL DELTA COMMISSIONING WITH ONLINE PARAMETER MODIFICATION
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODE2}
    ...  iterations_per_node=${COMMISSIONING_ITERATION}
    ...  delta=${ONLINE_PARAMETER_DELTA}
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=${None}
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${CUSTOMERS_LIST}
    ...  report_comment=${REPORT_COMMENT}
    ...  topology=${LABEL}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...  l3_call_method=${None}

E2E_TL_Delta_Commissioning_With_Site_Reset_Required
    [Timeout]   100h
    E2E TL DELTA COMMISSIONING WITH SITE RESET REQUIRED
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODE1}
    ...  iterations_per_node=${COMMISSIONING_ITERATION}
    ...  delta=${SITE_RESET_DELTA}
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=${None}
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${CUSTOMERS_LIST}
    ...  report_comment=${REPORT_COMMENT}
    ...  topology=${LABEL}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...  l3_call_method=${None}

E2E_TL_Delta_Commissioning_With_NR_Rat_Reset
    [Timeout]   100h
    E2E TL DELTA COMMISSIONING WITH NR RAT RESET
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODE1}
    ...  iterations_per_node=${COMMISSIONING_ITERATION}
    ...  delta=${NR_RAT_RESET_DELTA}
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=${None}
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${CUSTOMERS_LIST}
    ...  report_comment=${REPORT_COMMENT}
    ...  topology=${LABEL}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...  l3_call_method=${None}

E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
    [Timeout]   100h
    E2E TL CELL LOCK UNLOCK NR WITH OAM KPI
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODE1}
    ...  iterations_per_node=${CELL_ITERATION}
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=${None}
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${CUSTOMERS_LIST}
    ...  report_comment=${REPORT_COMMENT}
    ...  topology=${LABEL}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...  l3_call_method=${None}

E2E_TL_Cell_Lock_Unlock_LTE_with_OAM_KPI
    [Timeout]   100h
    E2E TL CELL LOCK UNLOCK LTE WITH OAM KPI
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODE2}
    ...  iterations_per_node=${CELL_ITERATION}
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=${None}
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${CUSTOMERS_LIST}
    ...  report_comment=${REPORT_COMMENT}
    ...  topology=${LABEL}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...  l3_call_method=${None}
