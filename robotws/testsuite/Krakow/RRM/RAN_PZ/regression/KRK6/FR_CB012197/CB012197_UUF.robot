*** Settings ***
Documentation
...    Test suite for CB012197 upgrade rollback tests
...    author: Mikolaj Borkowski
...    contact: mikolaj.borkowski@nokia.com
...    maintainer: mikolaj.borkowski@nokia.com

Library            DateTime                                        WITH NAME    dt
Library            taf/rfrl/csv4all/CSV4AllTestCases.py
Library            ./resources/variables.py

Resource           taf/rfrl/uuf4all/uuf4all_keywords.robot
Resource           taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot

Variables          taf/rfrl/procedures/resources/python/common_allowed_alarms.py


Test Timeout       100h

Suite Setup    Common Suite Setup With OnAir Test Line Preparation
...    increase_timeout_for_update_sw=1800
...    swconfig_from_path=commissionings/Krakow/7_7_UTE5GCLOUDT9SK153/swconfig.txt
Suite Teardown    Common Suite Teardown

*** Variables ***
${ITERATION_SITE_RESET}                    30
${ITERATION_SW_UPGRADE_ROLLBACK}           5

${source_software}                         ${EMPTY}
${target_software}                         ${EMPTY}

${SITE_RESET_TEST_QC_ID}                   None
${SW_UPGRADE_ROLLBACK_TEST_QC_ID}          None

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

@{ALLOWED_ALARMS_5G}           7513    62003    1898    7509  4589

&{NODE1}                    testline_object=${tl.gnbs[0]}
...                         source_sw=${source_software}
...                         target_sw=${target_software}
...                         custom_allowed_alarms=${ALLOWED_ALARMS_5G}

@{NODES}                    ${NODE1}


*** Test Cases ***
CB012197_31_E2E_TL_SW_upgrade_rollback_with_OAM_KPI
    [Setup]    Test_Setup_E2E_TL_SW_upgrade_rollback
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
    [Teardown]    Test Teardown

CB012197_30_E2E_TL_Activation_Reset_with_OAM_KPI
    [Setup]    Test_Setup_E2E_TL_Site_reset
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
    [Teardown]    Test Teardown


*** Keywords ***
Test_Setup_E2E_TL_Site_reset
    [Documentation]    Test Setup for E2E TL Site Reset. It logs source, target SW, current SW on gNB
    ...                and sets and logs QC ID for specific release for Site Reset test

    Log Action To Console    Test Setup Site Reset ===============================
    ${setup_sw_gnb}=    Get SW From BTS
    Log Action To Console    SW on gNB: ${setup_sw_gnb}
    Set to dictionary    ${NODE1}    source_sw=${setup_sw_gnb}    target_sw=${setup_sw_gnb}
    Set Suite Variable    ${source_software}    ${setup_sw_gnb}
    Set Suite Variable    ${target_software}    ${setup_sw_gnb}
    ${release}=    Get Release From SW    ${setup_sw_gnb}
    ${site_reset_test_qc_id}=    Get QC TAG From Release    test_name=E2E_TL_Activation_Reset_with_OAM_KPI
    ...                                                      release=${release}
    Set Suite Variable    ${SITE_RESET_TEST_QC_ID}    ${site_reset_test_qc_id}
    Log Action To Console    QC ID: ${SITE_RESET_TEST_QC_ID}
    Log Action To Console    Test Procedure ======================================

Test_Setup_E2E_TL_SW_upgrade_rollback
    [Documentation]    Test Setup for E2E TL SW Upgrade Rollback. It logs source, target SW, current SW on gNB
    ...                and sets and logs QC ID for specific release for SW Rollback Upgrade test

    Log Action To Console    Test Setup SW Upgrade Rollback ======================
    ${setup_source_software}=    Run Keyword If  '${source_software}'=='${EMPTY}'  Get Source SW
    ...   ELSE  set variable  ${source_software}
    ${setup_target_software}=    Run Keyword If  '${target_software}'=='${EMPTY}'  Get Target SW
    ...   ELSE  set variable  ${target_software}
    Set to dictionary    ${NODE1}    source_sw=${setup_source_software}    target_sw=${setup_target_software}
    Set Suite Variable    ${source_software}    ${setup_source_software}
    Set Suite Variable    ${target_software}    ${setup_target_software}
    Log Softwares For Test
    ${release}=    Get Release From SW    ${target_software}
    ${sw_upgrade_rollback_test_qc_id}=    Get QC TAG From Release    test_name=E2E_TL_SW_upgrade_rollback_with_OAM_KPI
    ...                                                              release=${release}
    Set Suite Variable    ${SW_UPGRADE_ROLLBACK_TEST_QC_ID}    ${sw_upgrade_rollback_test_qc_id}
    Log Action To Console    QC ID: ${SW_UPGRADE_ROLLBACK_TEST_QC_ID}
    Log Action To Console    Test Procedure ======================================

Test Teardown
    [Documentation]    Performs Common Postconditions
    Log Action To Console    End Test Procedure ==================================
    Log Action to Console    Perform Common Postconditions
    Common Postconditions

Log Softwares For Test
    [Documentation]    Gets SW versions from gNB via Rest API and logs it to console as well as source and target SW
    ...                from Suite Variables

    ${sw_gnb}=    Get SW From BTS
    Log Action To Console    SW on gNB: ${sw_gnb}
    Log Action To Console    Source SW: ${source_software}
    Log Action To Console    Target SW: ${target_software}

Log Action To Console
    [Arguments]   ${msg}    ${datatime}=${True}    ${new_line_before}=${True}    ${new_line_after}=${False}
    [Documentation]    Logs message to console
    ...                :param msg:     message logged
    ...                :datatime:    determines if include timestamp in log
    ...                :new_line_before:    determines if include new line before log
    ...                :new_line_after:    determines if include new line after log
    Run keyword if    '${new_line_before}'=='${True}'   Log To Console    \n    no_newline=${True}
    ${date}=    Run keyword if    '${datatime}'=='${True}'   Get Current Date
    Run keyword if    '${datatime}'=='${True}'   Log To Console    [*][${date}] ${msg}    no_newline=${True}
    Run keyword if    '${datatime}'=='${False}'   Log To Console    [*] ${msg}    no_newline=${True}
    Run keyword if    '${new_line_after}'=='${True}'   Log To Console    \n    no_newline=${True}
