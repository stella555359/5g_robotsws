*** Settings ***
Documentation
...   author: Jakub Matuszczyk
...   contact: jakub.matuszczyk@nokia.com
...   Test suite for basic UUF OAM Tests in loop:

Library      taf/rfrl/csv4all/CSV4AllTestCases.py
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource     taf/rfrl/uuf4all/uuf4all_keywords.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Common Preconditions
Test Teardown     Common Postconditions With Restore Configuration If Test Failed

*** Variables ***
${UPDATE_TEST_ITERATION}            10
${SITE_RESET_TEST_ITERATION}        5
${REPORT}                           ${True}
${QC_REPORT}                        ${True}
${STOP_TEST_AFTER_FAIL}             ${True}
${RESTORE_TO_TARGET_SW}             ${False}
@{CUSTOMERS}                        A1 Austria
@{CRITICAL_FAULTS}                  0010  0016  1806  1868  4341  4352  4383  4476
@{TEMP_ALLOWED_ALARMS}              4479  61648  7328  4476  62003  7331  7108  4589  4385  7313
${SOURCE_SW}                        ${EMPTY}
${TARGET_SW}                        ${EMPTY}
${QC_DOMAIN}                        MN_RAN
${QC_PROJECT}                       RAN_VRF
${RP_LOCATION}                      VRF_KRK
${RP_ORGANIZATION}                  VRF_KRK_T06
${RP_CA}                            VRF_RRM
${QC_ID_UPGRADE}                    217222
${QC_ID_RESET}                      217224

&{GNB_59}                                  node_alias=9SK059
...                                        testline_object=${tl.gnbs[0]}
...                                        source_sw=${SOURCE_SW}
...                                        target_sw=${TARGET_SW}
...                                        custom_allowed_alarms=${TEMP_ALLOWED_ALARMS}
&{GNB_60}                                  node_alias=9SK060
...                                        testline_object=${tl.gnbs[1]}
...                                        source_sw=${SOURCE_SW}
...                                        target_sw=${TARGET_SW}
...                                        custom_allowed_alarms=${TEMP_ALLOWED_ALARMS}
@{NODES}                                   ${GNB_59}    ${GNB_60}

*** Test Cases ***
E2E_TL_SW_upgrade_rollback_with_OAM_KPI
    [Timeout]    96h

    ${SOURCE_SW}=    Run Keyword If  '${SOURCE_SW}'=='${EMPTY}'  Get Source SW
    ...   ELSE  set variable  ${SOURCE_SW}
    ${TARGET_SW}=    Run Keyword If  '${TARGET_SW}'=='${EMPTY}'  Get Target SW
    ...   ELSE  set variable  ${TARGET_SW}
    Set to dictionary    ${GNB_59}    source_sw=${SOURCE_SW}    target_sw=${TARGET_SW}
    Set to dictionary    ${GNB_60}    source_sw=${SOURCE_SW}    target_sw=${TARGET_SW}

   e2e_tl_sw_upgrade_rollback_with_oam_kpi
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODES}
    ...    iterations_per_node=${UPDATE_TEST_ITERATION}
    ...    report=${REPORT}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${QC_ID_UPGRADE}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=${CUSTOMERS}
    ...    restore_to_target_sw=${RESTORE_TO_TARGET_SW}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}


E2E_TL_Activation_Reset_with_OAM_KPI
    [Timeout]    96h
    e2e_tl_activation_reset_test
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODES}
    ...    iterations_per_node=${SITE_RESET_TEST_ITERATION}
    ...    report=${REPORT}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${QC_ID_RESET}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=${CUSTOMERS}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
