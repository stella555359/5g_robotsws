*** Settings ***
Documentation
...   11283 Toothless
...   contact: Adam Szczerba

...   6134 - "EN DSS De-activated on partner side"
...   6351 - "System information broadcast parameters overflow"
...   7509 - "EN DSS Setup Failure - Max EN DSS Counter Value reached - No answer from CRM"
...   7511 - "EN DSS Keep Alive Procedure Time out"
...   7513 - "EN DSS De-activated on partner side"
...   8000 - "Failure in connection between BTS and 3rd party tool"
...   8150 - "NRRELNotConfiguredA3A5"
...   61631 - "ToP master service $IP unusable"

...   git pull origin master
...   pip install -r requirements.cfg
...   pip install -r dependencies.py39-rf50.lock      // in case of Python3.9
...   pip install -r dependencies.py310-rf50.lock      // in case of Python3.10
...   pip install -U taf.rfrl.csv4all

Library        Collections
Library        taf/rfrl/csv4all/CSV4AllTestCases.py
Variables      resources/mumin.py

*** Variables ***
${UPGRADE_ITERATION}           1
${RESET_ITERATIONS}            1
${TEST_ITERATION}              500k
${ACTIVATION_ITERATIONS}       500
@{CUSTOM_ALARMS}               61631  7509  6351  6134  7513  7511
@{CUSTOM_ALARMS_LTE_LOCK}      61631  7509  6351  6134  7513  7511
@{CRITICAL_FAULTS}             1905
${LABEL}                       PZ2_WRO23_Adam_Szczerba
${HOSTNAME}                    10_16_MRBTS-11283
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
${ONLINE_PARAMETER_DELTA}    /home/ute/MN/UTE/robotws/testsuite/Wroclaw/RRM/WRO2_3/uuf/Piotr_Smolak/resources/online_delta.json
${SITE_RESET_DELTA}          /home/ute/MN/UTE/robotws/testsuite/Wroclaw/RRM/WRO2_3/uuf/Piotr_Smolak/resources/reset_delta.json
${DISABLE_SYSLOG_CHECK}        ${False}
${EMAIL_RECIPIENTS}            adam.szczerba@nokia.com


${SYNCHRONIZE_SOFTWARE_ON_PASSIVE}    ${True}
${USE_DCAP}                           ${False}
${STOP_TEST_AFTER_FAIL}               ${False}
${RP_CA}                              VRF_RRM
${RP_LOCATION}                        VRF_WRO2
${RP_ORGANIZATION}                    VRF_WRO2_T03

&{NODE1}                    node_vm=10.44.156.107
...                         source_sw=${5G_SOURCE_SW}
...                         target_sw=${5G_TARGET_SW}
...                         custom_allowed_alarms=${CUSTOM_ALARMS}
...                         testline_scout_name=${HOSTNAME}
...                         critical_alarms=${CRITICAL_FAULTS}
...                         alarm_timer=${ALARM_TIMEOUT}
...                         hw_to_onair_timeout=${HARDWARE_CHECK_TIMEOUT}
...                         verify_syslog=${DISABLE_SYSLOG_CHECK}
...                         mumin_config=${gnb1_lmi_mumin}
@{NODES}                    ${NODE1}

*** Test Cases ***
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


*** Keywords ***
Temporarily Modify Node
    [Arguments]  ${node}  ${modifications_dict}  ${print_to_console}=False
    ${node2} =  Create Dictionary  &{node}
    Set To Dictionary  ${node2}  &{modifications_dict}
    ${nodes2} =  Create List  ${node2}
    Log  Nodes are modified for ${TEST_NAME} test case.\n\nNode2: ${node2}\n\nNodes2: ${nodes2}  console=${print_to_console}
    [Return]  ${node2}  ${nodes2}
