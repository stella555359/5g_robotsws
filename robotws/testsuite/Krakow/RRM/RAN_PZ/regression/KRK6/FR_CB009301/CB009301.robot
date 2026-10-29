*** Settings ***
Documentation
...   Test Suite: CB009301 for 5G testing.
...   Test cases verify if the feature collects successfully initial and periodic eCPRI delay measurements during basic
...   operations performed on BTS.
...   In test scenarios below logs are used for verification:
...   1. eGEN logs - in collected pcap can be checked if count of MSG5 requests is matching MSG5 responses. It is done
...   by comparing amount of each action type: 0x00 & 0x02 for request & response for delay measurement in DL and
...   0x01, 0x05 & 0x04 for request & response for delay measurement in UL.
...   2. Snapshot - in L1 RMOD journal and L1 previous boots journal can be verified if unexpected actions occured
...   during test procedure e.g. timeout, no responses from RU.

...   author: Karolina Pacia, Mateusz Potoniec
...   contact: karolina.pacia@nokia.com, mateusz.potoniec@nokia.com
...   maintainer: karolina.pacia@nokia.com, mateusz.potoniec@nokia.com

Library    taf/rfrl/csv4all/CSV4AllTestCases.py
Library    taf/rfrl/procedures/resources/python/OAM_KPI/oam_kpi_runner.py

Resource    ./resources/suite_specific_keywords.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot


Suite Setup         Common Suite Setup With OnAir Test Line Preparation
...                 increase_timeout_for_update_sw=1800
...                 increase_time_for_checking_cells=1800
Suite Teardown      Common Suite Setup With OnAir Test Line Preparation Teardown


*** Variables ***
${ITERATION_SITE_RESET}                    30
${ITERATIONS}                              5

${SOURCE_SW}                               ${None}
${TARGET_SW}                               ${None}

${SITE_RESET_TEST_QC_ID}                   None
${SW_UPGRADE_ROLLBACK_TEST_QC_ID}          None

@{CRITICAL_ALARMS}                         0010  0016  1806  1868  4341  4352  4383

${SERIAL_CONSOLE}                          ${False}

${REPORT}                                  ${True}
${QC_REPORT}                               ${True}
${STOP_TEST_AFTER_FAIL}                    ${False}

@{CUSTOMERS}                               Generic
${QC_DOMAIN}                               MN_RAN
${QC_PROJECT}                              RAN_VRF
${RP_LOCATION}                             VRF_KRK
${RP_ORGANIZATION}                         VRF_KRK_T06
${RP_CA}                                   VRF_RRM

&{NODE1}                                   testline_object=${tl.gnbs[0]}
...                                        source_sw=${SOURCE_SW}
...                                        target_sw=${TARGET_SW}
...                                        critical_alarms=${CRITICAL_ALARMS}

@{NODES}                                   ${NODE1}
@{UPGRADE_NODES}                           ${NODE1}

${RESTORE_TO_TARGET_SW}                    ${False}


*** Test Cases ***
CB009301_X_03_Online_Enable_Or_Disable_Delay_Measurement
    [Setup]  Run keywords    Test Setup    AND    Require UE
    Attach UE
    Start UDP DL and UL data transmission and verify results
    Detach UE
    Start Egen Logs Collector    timeout=3600
    Change actEcpriDelayMeasurement     True
    Log Action To Console    Sleep 10s to wait for logs collection
    Sleep    10s
    Attach UE
    Start UDP DL and UL data transmission and verify results
    Detach UE
    Change actEcpriDelayMeasurement    False
    ${egen_logs_path}=    Stop Egen Logs Collector and Download Logs
    Log Action To Console    Check Egen eCPRI Logs
    Check Egen eCPRI Logs    ${egen_logs_path}
    Attach UE
    Start UDP DL and UL data transmission and verify results
    Detach UE
    [Teardown]    Test Teardown

CB009301_X_16_SW_Upgrade_Rollback_with_eCPRI_delay_measurement_enabled
    [Setup]  Test Setup UUF
    e2e_tl_sw_upgrade_rollback_with_oam_kpi         ${NODES}  ${NODE1}  ${ITERATIONS}
    ...    report=${REPORT}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=${CUSTOMERS}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...    restore_to_target_sw=${RESTORE_TO_TARGET_SW}
    [Teardown]    Test Teardown UUF

CB009301_X_17_Activation_Reset_with_OAM_KPI_with_eCPRI_delay_measurement_enabled
    [Setup]  Test Setup UUF
    E2E TL ACTIVATION RESET TEST
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    iterations_per_node=${ITERATION_SITE_RESET}
    ...    report=${REPORT}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${SITE_RESET_TEST_QC_ID}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=${CUSTOMERS}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    [Teardown]    Test Teardown UUF
