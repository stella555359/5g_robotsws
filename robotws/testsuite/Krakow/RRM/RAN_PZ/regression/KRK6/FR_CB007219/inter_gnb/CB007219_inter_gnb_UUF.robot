*** Settings ***
Documentation
...   Test suite for regression testing of UUF
...   author: Jakub Bak
...   contact: jakub.1.bak@nokia.com
...   maintainer: jakub.1.bak@nokia.com


Library            taf/rfrl/csv4all/CSV4AllTestCases.py
Resource           taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource           taf/rfrl/uuf4all/uuf4all_keywords.robot
Variables          taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Suite Setup        Common Suite Setup
Suite Teardown     Common Suite Teardown

Test Setup         Common Preconditions
Test Teardown      Common Postconditions

Test Timeout       100h


*** Variables ***
${ITERATION_SITE_RESET}                    1
${ITERATION_SW_UPGRADE_ROLLBACK}           5

${SOURCE_SW}                               ${EMPTY}
${TARGET_SW}                               ${EMPTY}

${SITE_RESET_TEST_QC_ID}                   182953
${SW_UPGRADE_ROLLBACK_TEST_QC_ID}          183310

@{CRITICAL_ALARMS}                         0010  0016  1806  1868  4341  4352  4383
@{ALLOWED_ALARMS}                          62003 7331  4655  4654  61524  61652
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

&{GNB}                                     node_alias=4SK094
...                                        testline_object=${tl.gnbs[0]}
...                                        source_sw=${SOURCE_SW}
...                                        target_sw=${TARGET_SW}
...                                        critical_alarms=${CRITICAL_ALARMS}
@{NODES}                                   ${GNB}


*** Test Cases ***
E2E_TL_SW_upgrade_rollback_with_OAM_KPI
    [Timeout]    96h

    ${SOURCE_SW}=    Run Keyword If  '${SOURCE_SW}'=='${EMPTY}'  Get Source SW
    ...   ELSE  set variable  ${SOURCE_SW}
    ${TARGET_SW}=    Run Keyword If  '${TARGET_SW}'=='${EMPTY}'  Get Target SW
    ...   ELSE  set variable  ${TARGET_SW}
    Set to dictionary    ${BTS0}    source_sw=${SOURCE_SW}    target_sw=${TARGET_SW}

    e2e_tl_sw_upgrade_rollback_with_oam_kpi
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODES}
    ...    iterations_per_node=${ITERATION_SW_UPGRADE_ROLLBACK}
    ...    report=${REPORT}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${SW_UPGRADE_ROLLBACK_TEST_QC_ID}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=${CUSTOMERS}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}

E2E_TL_Activation_Reset_with_OAM_KPI
    [Timeout]    96h
    e2e_tl_activation_reset_test
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODES}
    ...    iterations_per_node=${ITERATION_SITE_RESET}
    ...    report=${REPORT}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${SITE_RESET_TEST_QC_ID}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=${CUSTOMERS}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
