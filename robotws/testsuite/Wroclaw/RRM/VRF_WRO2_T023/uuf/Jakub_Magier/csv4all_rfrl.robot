*** Settings ***
Documentation
...   author: Jakub Magier
...   contact: jakub.magier@nokia.com
...   Test suite for basic UUF OAM Tests in loop.
...   Custom faults description:
...   4298 - "ToP reference missing"  4694 - "FIFO buffer over/underflow"  6150 - "GTP-U Path Failure"
...   6351 - "System information broadcast parameters overflow"
...   8150 - "NRRELNotConfiguredA3A5"
...   7509 - "EN DSS Setup Failure - Max EN DSS Counter Value reached - No answer from CRM"
...   7513 - "EN DSS De-activated on partner side"
...   61631 - "ToP master service $IP unusable"
...   62003 - "Transport layer connection lost in XP interface"

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ute_report.robot
Resource     UUF_keywords_and_variables.robot
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/tl_config.py
Library      Collections
Library      taf/rfrl/csv4all/CSV4AllTestCases.py
Library      ta5g_testline_management
Library      ta5g_iphy
Library      ta5g_cell_operations
Library      ta5g_tshark


*** Variables ***
${UPGRADE_ITERATION}           1
${RESET_ITERATIONS}            10
${TEST_ITERATION}              10
@{CUSTOM_ALARMS}               4298  4694  6150  6134  6351  7509  7513  8150  61631  4527  7307  62003  6450  1906  4681  8000  1898  9
@{CUSTOM_ALARMS_LTE_LOCK}      4298  4694  6150  6134  6351  7509  7513  8150  61631  4527  7307  62003  6450  1906  4681  8000  1898  9
@{CRITICAL_FAULTS}             4082
${LABEL}                       PZ2_WRO23_Jakub_Magier
${HOSTNAME}                    ${None}
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
${DISABLE_SYSLOG_CHECK}        ${False}
${SYNCHRONIZE_SOFTWARE_ON_PASSIVE}    ${True}
${USE_DCAP}                           ${False}
${STOP_TEST_AFTER_FAIL}               ${False}
${RP_CA}                              VRF_RRM
${RP_LOCATION}                        VRF_WRO2
${RP_ORGANIZATION}                    VRF_WRO2_T03
${TESTLINE_IP}                 ${tl.test_pc.default_ssh_connection_details.addr}
${WTS_CONFIG}                  ${None}
${BSR_PACKAGE_NAME}            ${None}
${EDAEMON_PORT}                ${None}
${VM_USER}                     ute
${VM_PASSWORD}                 ${None}
${AP_TIMEOUT}                  360
&{airphone_details}            hostname=${TESTLINE_IP}
...                            username=${VM_USER}
...                            password=${VM_PASSWORD}
...                            timeout=${AP_TIMEOUT}

&{NODE1}                    node_vm=${TESTLINE_IP}
...                         source_sw=${5G_SOURCE_SW}
...                         target_sw=${5G_TARGET_SW}
...                         custom_allowed_alarms=${CUSTOM_ALARMS}
...                         testline_scout_name=${HOSTNAME}
...                         critical_alarms=${CRITICAL_FAULTS}
...                         alarm_timer=${ALARM_TIMEOUT}
...                         hw_to_onair_timeout=${HARDWARE_CHECK_TIMEOUT}
...                         verify_syslog=${DISABLE_SYSLOG_CHECK}
...                         airphone_details=${airphone_details}
@{NODES}                    ${NODE1}


*** Test Cases ***
E2E_TL_Activation_Reset_test
    [Timeout]  100h
    [Setup]    Run Keywords    Configure ETH3 Interfaces    AND
    ...                        Install Bsr Package For UUF Test   bsr_package=${BSR_PACKAGE_NAME}   AND
    ...                        Wait For Testline Icmp Echo Replies And Ssh Services

    E2E_TL_ACTIVATION_RESET_TEST
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
    ...  configure_wts=${True}

E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
    [Timeout]  100h
    [Setup]    Run Keywords    Configure ETH3 Interfaces    AND
    ...                        Install Bsr Package For UUF Test    bsr_package=${BSR_PACKAGE_NAME}   AND
    ...                        Wait For Testline Icmp Echo Replies And Ssh Services    AND
    ...                        Configure Wts Environment    wts_config=${WTS_CONFIG}    edaemon_port=${EDAEMON_PORT}

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

    [Teardown]    Run Keywords    Teardown Egate

E2E_TL_Cell_Block_Unblock_NR_with_OAM_KPI
    [Timeout]  100h
    [Setup]    Run Keywords    Configure ETH3 Interfaces    AND
    ...                        Install Bsr Package For UUF Test   bsr_package=${BSR_PACKAGE_NAME}   AND
    ...                        Wait For Testline Icmp Echo Replies And Ssh Services    AND
    ...                        Configure Wts Environment    wts_config=${WTS_CONFIG}    edaemon_port=${EDAEMON_PORT}

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

    [Teardown]    Run Keywords    Teardown Egate
