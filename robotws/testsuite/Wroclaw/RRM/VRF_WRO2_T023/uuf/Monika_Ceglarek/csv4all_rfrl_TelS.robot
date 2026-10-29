*** Settings ***
Documentation
...   contact: Monika Ceglarek


Library        Collections
Library        taf/rfrl/csv4all/CSV4AllTestCases.py
Library        ../../feature_resources/UUF/resources/CSV4AllTestCasesPrivate.py


*** Variables ***
${UPGRADE_ITERATION}           10
${RESET_ITERATIONS}            10
${TEST_ITERATION}              10
@{CUSTOM_ALARMS}               61631  7509  6351  6134  4011  7513  8150  8000
@{CUSTOM_ALARMS_LTE_LOCK}      61631  7509  6351  6134  4011  7513  8150  7511  8000
@{CRITICAL_FAULTS}             4082
${LABEL}                       VRF_WRO23_Monika_Ceglarek_Arizona
${HOSTNAME}                    10_16_MRBTS-53083
${SHOULD_BE_REPORTED}          True
@{CUSTOMERS_LIST}              TEF Spain
${5G_SOURCE_SW}                ${None}
${5G_TARGET_SW}                ${None}
${USE_BUILDS_STORAGE}          ${True}
${RESTORE_TARGET_SW}           ${True}
${USE_TEST_PACKAGES}           ${False}
${DOWNLOAD_PATH}               ${None}
${REPORT_COMMENT}              ${None}
${ALARM_TIMEOUT}                  120
${RMOD_HARDWARE_CHECK_TIMEOUT}    240
${HARDWARE_CHECK_TIMEOUT}         450
${CALCULATE_KPI}               ${True}
${QC_DOMAIN}                   ${None}
${TEST_QC_ID}                  ${None}
${QC_PROJECT}                  ${None}
${ONLINE_PARAMETER_DELTA}    /home/ute/MN/UTE/robotws/testsuite/Wroclaw/RRM/VRF_WRO2_T023/uuf/Monika_Ceglarek/resources/online_delta_TelS.json
${SITE_RESET_DELTA}          /home/ute/MN/UTE/robotws/testsuite/Wroclaw/RRM/VRF_WRO2_T023/uuf/Monika_Ceglarek/resources/reset_delta_TelS.json
${DISABLE_SYSLOG_CHECK}        ${False}

&{PDU_SM1}              model=GUDE  host=10.44.205.141  port=@{8, }  version=8220-1
&{PDU_SM2}              model=GUDE  host=10.44.205.141  port=@{7, }  version=8220-1
&{PDU_RU1}              model=GUDE  host=10.44.205.141  port=@{2, }  version=8220-1
&{PDU_RU2}              model=GUDE  host=10.44.205.141  port=@{6, }  version=8220-1
&{PDU_RU3}              model=GUDE  host=10.44.205.141  port=@{1, }  version=8220-1
&{PDU_RU4}              model=GUDE  host=10.44.205.141  port=@{4, }  version=8220-1
&{PDU_RU5}              model=GUDE  host=10.44.177.17  port=@{8, }  version=8221-1
&{PDU_RU6}              model=GUDE  host=10.44.205.188  port=@{6, }  version=8221-1
&{PDU_RU7}              model=GUDE  host=10.44.177.86  port=@{9, }  version=8221-1
&{SM1}                  DH200762500=${PDU_SM1}
&{SM2}                  L1162802405=${PDU_SM2}
&{RU1}                  LR231913110=${PDU_RU1}
&{RU2}                  6Q205001523=${PDU_RU2}
&{RU3}                  AS212202689=${PDU_RU3}
&{RU4}                  F7165111382=${PDU_RU4}
&{RU5}                  1M213805762=${PDU_RU5}
&{RU6}                  DH223908263=${PDU_RU6}
&{RU7}                  1M221313326=${PDU_RU7}

@{RMOD_PDU_LIST}=            ${RU1}  ${RU2}  ${RU3}  ${RU4}  ${RU5}  ${RU6}  ${RU7}
@{SITE_PDU_LIST}=            ${SM1}  ${SM2}  ${RU1}  ${RU2}  ${RU3}  ${RU4}  ${RU5}  ${RU6}  ${RU7}


${SYNCHRONIZE_SOFTWARE_ON_PASSIVE}    ${True}
${USE_DCAP}                           ${False}
${STOP_TEST_AFTER_FAIL}               ${False}
${RP_CA}                              VRF_RRM
${RP_LOCATION}                        VRF_WRO2
${RP_ORGANIZATION}                    VRF_WRO2_T02

&{SECONDARY_DICT}                     host=10.42.53.113
...                                   password=${tl.test_pcs[1].default_ssh_connection_details.password}
...                                   user=${tl.test_pcs[1].default_ssh_connection_details.username}
...                                   bts_host_ip=192.168.255.119
@{RMOD_LIST}
...             MRBTS-53083/EQM-1/APEQM-1/RMOD-1
...             MRBTS-53083/EQM-1/APEQM-1/RMOD-2
...             MRBTS-53083/EQM-1/APEQM-1/RMOD-3
...             MRBTS-53083/EQM-1/APEQM-1/RMOD-4
...             MRBTS-53083/EQM-1/APEQM-1/RMOD-5
...             MRBTS-53083/EQM-1/APEQM-1/RMOD-6
...             MRBTS-53083/EQM-1/APEQM-1/RMOD-7
@{BBMOD_LIST}
...              MRBTS-53083/EQM-1/APEQM-1/CABINET-1/BBMOD-1
...              MRBTS-53083/EQM-1/APEQM-1/CABINET-1/BBMOD-2
...              MRBTS-53083/EQM-1/APEQM-1/CABINET-1/BBMOD-4
...              MRBTS-53083/EQM-1/APEQM-1/CABINET-1/BBMOD-5
&{NODE1}                    node_vm=10.42.53.112
...                         secondary_vm=${SECONDARY_DICT}
...                         source_sw=${5G_SOURCE_SW}
...                         target_sw=${5G_TARGET_SW}
...                         custom_allowed_alarms=${CUSTOM_ALARMS}
...                         testline_scout_name=${HOSTNAME}
...                         critical_alarms=${CRITICAL_FAULTS}
...                         alarm_timer=${ALARM_TIMEOUT}
...                         hw_to_onair_timeout=${HARDWARE_CHECK_TIMEOUT}
...                         verify_syslog=${DISABLE_SYSLOG_CHECK}
...                         modules_for_test=${RMOD_LIST}

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


E2E_TL_RU_Reset_with_OAM_KPI
    [Timeout]  100h
    ${modifications_dict} =  Create Dictionary  hw_to_onair_timeout=${RMOD_HARDWARE_CHECK_TIMEOUT}
    ${node2}  ${nodes2} =  Temporarily Modify Node  ${NODE1}  ${modifications_dict}
    E2E TL RU RESET WITH OAM KPI
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


E2E_TL_Capacity_Module_Reset_with_OAM_KPI
    [Timeout]  100h
    ${modifications_dict} =  Create Dictionary  custom_allowed_alarms=${CUSTOM_ALARMS_LTE_LOCK}  modules_for_test=${BBMOD_LIST}
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


E2E_TL_Cell_Block_Unblock_GSM_with_OAM_KPI
    [Timeout]   100h
    E2E TL CELL BLOCK UNBLOCK GSM WITH OAM KPI
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


E2E_TL_Cell_Block_Unblock_WCDMA_with_OAM_KPI
    [Timeout]   100h
    E2E TL CELL BLOCK UNBLOCK WCDMA WITH OAM KPI
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
    ${modifications_dict} =  Create Dictionary  hw_to_onair_timeout=${RMOD_HARDWARE_CHECK_TIMEOUT}
    ${node2}  ${nodes2} =  Temporarily Modify Node  ${NODE1}  ${modifications_dict}
    E2E TL RU LOCK UNLOCK
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


E2E_TL_RU_Power_Reset
    [Timeout]  100h
    ${modifications_dict} =  Create Dictionary  hw_to_onair_timeout=${RMOD_HARDWARE_CHECK_TIMEOUT}
    ${node2}  ${nodes2} =  Temporarily Modify Node  ${NODE1}  ${modifications_dict}
    E2E TL RU POWER RESET
    ...  nodes_details=${nodes2}
    ...  test_nodes_details=${node2}
    ...  iterations_per_node=${TEST_ITERATION}
    ...  rmods_with_pdu_ports=${RMOD_PDU_LIST}
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
    ${modifications_dict} =  Create Dictionary  modules_for_test=${BBMOD_LIST}
    ${node2}  ${nodes2} =  Temporarily Modify Node  ${NODE1}  ${modifications_dict}
    E2E TL CAPACITY MODULE LOCK UNLOCK
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


E2E_TL_Site_Reset_with_OAM_KPI
    [Timeout]  100h
    E2E TL SITE RESET WITH OAM KPI
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


E2E_TL_Power_Reset
    [Timeout]  100h
    E2E TL POWER RESET
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=${RESET_ITERATIONS}
    ...  modules_with_pdu_ports=${SITE_PDU_LIST}
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


E2E_TL_Power_Site_Reset_With_OAM_KPI
    [Timeout]  100h
    E2E TL POWER SITE RESET WITH OAM KPI
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


*** Keywords ***
Temporarily Modify Node
    [Arguments]  ${node}  ${modifications_dict}  ${print_to_console}=False
    ${node2} =  Create Dictionary  &{node}
    Set To Dictionary  ${node2}  &{modifications_dict}
    ${nodes2} =  Create List  ${node2}
    Log  Nodes are modified for ${TEST_NAME} test case.\n\nNode2: ${node2}\n\nNodes2: ${nodes2}  console=${print_to_console}
    [Return]  ${node2}  ${nodes2}
