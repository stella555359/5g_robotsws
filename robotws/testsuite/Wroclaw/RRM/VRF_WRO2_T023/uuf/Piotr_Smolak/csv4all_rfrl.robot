*** Settings ***
Documentation
...   contact: Piotr Smolak

...   6134 - "EN DSS De-activated on partner side"
...   6351 - "System information broadcast parameters overflow"
...   7509 - "EN DSS Setup Failure - Max EN DSS Counter Value reached - No answer from CRM"
...   7511 - "EN DSS Keep Alive Procedure Time out"
...   7513 - "EN DSS De-activated on partner side"
...   8000 - "Failure in connection between BTS and 3rd party tool"
...   8150 - "NRRELNotConfiguredA3A5"
...   61631 - "ToP master service $IP unusable"


Library        Collections
Library        taf/rfrl/csv4all/CSV4AllTestCases.py
Variables      resources/mumin.py


*** Variables ***
${UPGRADE_ITERATION}           1
${ACTIVATION_ITERATIONS}       300
${TEST_ITERATION}              100
@{CUSTOM_ALARMS}               61631  7509  6351  6134  7513  8150  7511  8000
@{CUSTOM_ALARMS_LTE_LOCK}      61631  7509  6351  6134  7513  8150  7511  8000
@{CRITICAL_FAULTS}             30
${LABEL}                       PZ2_WRO23_Piotr_Smolak_SBTS
${HOSTNAME}                    10_16_MRBTS-55015
${SHOULD_BE_REPORTED}          True
@{CUSTOMERS_LIST}              Generic
${5G_SOURCE_SW}                SBTS00_ENB_9999_250918_000007
${5G_TARGET_SW}                SBTS00_ENB_9999_250918_000019
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
${ONLINE_PARAMETER_DELTA}    /home/ute/MN/UTE/robotws/testsuite/Wroclaw/RRM/WRO2_3/uuf/Piotr_Smolak/resources/online_delta.json
${SITE_RESET_DELTA}          /home/ute/MN/UTE/robotws/testsuite/Wroclaw/RRM/WRO2_3/uuf/Piotr_Smolak/resources/reset_delta.json
${DISABLE_SYSLOG_CHECK}        ${False}
${EMAIL_RECIPIENTS}            piotr.smolak@nokia.com
${RDC_CONFIG}                /home/ute/MN/UTE/robotws/testsuite/Wroclaw/RRM/WRO2_3/uuf/Piotr_Smolak/resources/rf_modules_configuraton.yaml

&{PDU_RU1}              model=GUDE  host=10.44.177.85  port=@{3, }  version=8221-1
&{PDU_RU2}              model=GUDE  host=10.44.205.184  port=@{10, }  version=8221-1
&{PDU_RU3}              model=GUDE  host=10.44.177.87  port=@{2, }  version=8221-1
&{PDU_RU4}              model=GUDE  host=10.44.177.87  port=@{7, }  version=8221-1
&{PDU_RU5}              model=GUDE  host=10.44.177.87  port=@{8, }  version=8221-1
&{PDU_RU6}              model=GUDE  host=10.44.177.87  port=@{9, }  version=8221-1
&{PDU_RU7}              model=GUDE  host=10.44.177.87  port=@{10, }  version=8221-1
&{PDU_RU8}              model=GUDE  host=10.44.177.87  port=@{11, }  version=8221-1
&{RU1}                  L1215106564=${PDU_RU1}
&{RU2}                  AH231800539=${PDU_RU2}
&{RU3}                  EA215050418=${PDU_RU3}
&{RU4}                  AH192201204=${PDU_RU4}
&{RU5}                  F7144943055=${PDU_RU5}
&{RU6}                  L1194707348=${PDU_RU6}
&{RU7}                  L1160409654=${PDU_RU7}
&{RU8}                  1M222706961=${PDU_RU8}

@{PDU_LIST}=            ${RU1}  ${RU2}  ${RU3}  ${RU4}  ${RU5}  ${RU6}  ${RU7}  ${RU8}

${SYNCHRONIZE_SOFTWARE_ON_PASSIVE}    ${True}
${USE_DCAP}                           ${False}
${STOP_TEST_AFTER_FAIL}               ${False}
${RP_CA}                              VRF_RRM
${RP_LOCATION}                        VRF_WRO2
${RP_ORGANIZATION}                    VRF_WRO2_T03

&{NODE1}                    node_vm=10.42.53.59
...                         secondary_vm=10.42.53.55
...                         source_sw=${5G_SOURCE_SW}
...                         target_sw=${5G_TARGET_SW}
...                         custom_allowed_alarms=${CUSTOM_ALARMS}
...                         testline_scout_name=${HOSTNAME}
...                         critical_alarms=${CRITICAL_FAULTS}
...                         alarm_timer=${ALARM_TIMEOUT}
...                         hw_to_onair_timeout=${HARDWARE_CHECK_TIMEOUT}
...                         verify_syslog=${DISABLE_SYSLOG_CHECK}
...                         mumin_config=${mumin_rmods[0]}
@{NODES}                    ${NODE1}


*** Test Cases ***
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


E2E_TL_Activation_Reset_Test
    [Timeout]  100h
    E2E TL ACTIVATION RESET TEST
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=${ACTIVATION_ITERATIONS}
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


E2E_TL_Site_Reset_without_HWF_with_OAM_KPI
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


E2E_TL_RU_Reset_with_OAM_KPI
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


E2E_TL_Capacity_Module_Reset_with_OAM_KPI
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


E2E_TL_Cell_Lock_Unlock_LTE_with_OAM_KPI
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
