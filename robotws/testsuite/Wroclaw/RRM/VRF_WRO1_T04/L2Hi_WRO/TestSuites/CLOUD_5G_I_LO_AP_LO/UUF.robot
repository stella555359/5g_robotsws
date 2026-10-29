*** Settings ***
Documentation
...    author: Marcin Kotula
...    maintainer: Marcin Kotula (marcin.kotula@nokia.com)
...    testline: CLOUD_5G_I_LO_AP_LO
...    release: 26R1

Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_variables.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_keywords.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_configuration.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/logs_collection.robot

Library     taf/rfrl/csv4all/CSV4AllTestCases.py
Library     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_keywords.py

Suite Setup    Run Keywords    Enable Syslog Info Level Prints
...            AND             Configure NSA VM interfaces
...            AND             Reach Onair    lua_cfg=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}
...            AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}

Test Teardown     Send Configuration ID To Scout

Suite Teardown    Run Keywords    Check For An Unexpected Alarm
...            AND                Stop Default Processes And Gather Logs And Compress Logs


*** Variables ***
@{CUSTOMERS}                      Generic
${INITIAL}                        ${None}
${CANDIDATE}                      ${None}
${ITERATION}                      25
${STOP_TEST_AFTER_FAIL}           ${False}
${TEST_ON_NODE}                   ${None}
${REPORT}                         ${False}
${QC_REPORT}                      ${False}
${REPORT_COMMENT}                 ${None}
${QC_DOMAIN}                      MN_RAN
${TEST_QC_ID}                     ${None}
${QC_PROJECT}                     ${None}
&{gnb1}                           node_alias=5G           testline_object=${tl.gnbs[0]}
@{NODES}                          ${gnb1}
@{TEST_NODES}                     ${gnb1}

*** Test Cases ***
[1][1.0] E2E_TL_Site_reset_with_OAM_KPI
    [Tags]      reset
    [Timeout]   24h
    e2e_tl_site_reset_with_oam_kpi
    ...    ${NODES}
    ...    ${TEST_NODES}
    ...    ${ITERATION}
    ...    report=${REPORT}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${TEST_QC_ID}
    ...    qc_project=${QC_PROJECT}
    ...    report_comment=${REPORT_COMMENT}
    ...    customers_list=${CUSTOMERS}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
