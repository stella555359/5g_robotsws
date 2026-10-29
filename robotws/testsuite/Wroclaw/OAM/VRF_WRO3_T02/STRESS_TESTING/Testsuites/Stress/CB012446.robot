*** Settings ***
Documentation
...    Author: jakub.hirny@nokia.com
...    Description: Suite prepared for STRESS TESTING tests execution
...    Group in charge: I_MN_RAN_PZ_3_WRO_1_GMS <I_MN_RAN_PZ_3_WRO_1@internal.nsn.com>
...    Sample execution:
...    robot -v CONFIGURATION:Wroclaw.10_16_UTESRAN2161 -C on -T -d /home/ute/test_results -L TRACE -b debug.log
...    -V /home/ute/testline_configuration/10_16_UTESRAN2161
...    testsuite/Wroclaw/OAM/VRF_WRO3_T02/STRESS_TESTING/Testsuites/Stress/CB012446.robot


Resource        ../../Testcases/SM.41_Site_Reset_without_RU_Reset_via_NA/test.robot
Resource        ../../Testcases/SM.42_Site_Reset_without_RU_Reset_via_WebEM/test.robot
Resource        ../../Testcases/SM.43_Parallel_Site_Reset_of_Primary_and_Secondary_Core/test.robot
Resource        ../../Testcases/SM.44_Sequential_Site_Reset_of_Primary_and_Secondary_Core/test.robot
Resource        ../../Testcases/SM.45_Parallel_Site_Reset_of_the_Primary_and_Secondary_Core_Triggered_by_Site_Block-Unblock/test.robot
Resource        ../../Testcases/SM.46_Sequential_Site_Reset_of_the_Primary_and_Secondary_Core_Triggered_by_Site_Block-Unblock/test.robot



Force Tags
...           SBTS00  CRT  # Branch indicator; Test Phase indicator
...           QCP_RAN_VRF  QCD_MN_RAN  ## QC project; QC domain for reporting
...           PY39  ## force python3 UTE package
...           RF50
#...           CLOUD_SRAN_*_UTECA
...           SKIP_INSTALL_TOOLS
#...           SKIP_SCF_VALIDATION

Suite Setup       Run Keywords    common.Common Suite Setup
Suite Teardown    common.Common Suite Teardown
Test Timeout      73h


*** Variables ***
${ITERATIONS}                100
${DUAL_CORE_ITERATIONS}      50
${TEST_SUITE_DURATION}       72    #test suite duration in hours
${MAX_FAIL_IN_ROW}           5     #maximum number of failed tests in a row
${SMODS_EXCLUDED_REGEX}      FSMF(\\+FSMF)?|ASO[EFGH]
@{TEST_SUITE_CONTENT}
${CONCURRENT}                False

*** Test Cases ***
# RGT_EFF_Nov_2025_removal
# [1][1.0] Automated__SM__Site_Reset_without_RU_Reset_via_ACTIONS
#     [Setup]  Run Keywords  common.Common Test Setup  AND  Setup TAF Netact
#     Ensure NORMAL value on all RMODs
#     SM.41_Site_Reset_without_RU_Reset_via_NA
#     [Teardown]  Run Keywords  common.Common Test Teardown  AND  Teardown TAF Netact
#     ...                  AND  Restore parameters value on all RMODs

[1][1.0] Automated__SM__Site_Reset_without_RU_Reset_via_WebEM
    [Setup]  common.Common Test Setup - MEMORY
    Ensure NORMAL value on all RMODs
    SM.42_Site_Reset_without_RU_Reset_via_WebEM.Test Specific Setup
    Run Looping Test SM.42_Site_Reset_without_RU_Reset_via_WebEM
    [Teardown]  Run Keywords  SM.42_Site_Reset_without_RU_Reset_via_WebEM.Test Case Teardown
    ...                  AND  Restore parameters value on all RMODs

#[1][1.0] Automated_SM_Parallel_site_reset_of_the primary_and_secondary_core
#    [Setup]  Run Keywords  common.Common Test Setup - MEMORY
#    ...               AND  Set Test Variable  ${ITERATIONS}  ${DUAL_CORE_ITERATIONS}
#    SM.43_Parallel_Site_Reset_of_Primary_and_Secondary_Core.Test Specific Setup
#    Run Looping Test SM.43_Parallel_Site_Reset_of_Primary_and_Secondary_Core
#    [Teardown]  SM.43_Parallel_Site_Reset_of_Primary_and_Secondary_Core.Test Case Teardown

#[1][1.0] Automated_SM_Sequential_site_reset_of_the_primary_and_secondary_core
#    [Setup]  Run Keywords  common.Common Test Setup - MEMORY
#    ...               AND  Set Test Variable  ${ITERATIONS}  ${DUAL_CORE_ITERATIONS}
#    SM.44_Sequential_Site_Reset_of_Primary_and_Secondary_Core.Test Specific Setup
#    Run Looping Test SM.44_Sequential_Site_Reset_of_Primary_and_Secondary_Core
#    [Teardown]  SM.44_Sequential_Site_Reset_of_Primary_and_Secondary_Core.Test Case Teardown

[1][1.0] Automated_SM_Parallel_Site_Reset_of_the_Primary_and_Secondary_Core_Triggered_by_Site_Block-Unblock
    [Setup]  Run Keywords  common.Common Test Setup - MEMORY
    ...               AND  Set Test Variable  ${ITERATIONS}  ${DUAL_CORE_ITERATIONS}
    SM.45_Parallel_Site_Reset_of_the_Primary_and_Secondary_Core_Triggered_by_Site_Block-Unblock.Test Specific Setup
    Run Looping Test SM.45_Parallel_Site_Reset_of_the_Primary_and_Secondary_Core_Triggered_by_Site_Block-Unblock
    [Teardown]  SM.45_Parallel_Site_Reset_of_the_Primary_and_Secondary_Core_Triggered_by_Site_Block-Unblock.Test Case Teardown

[1][1.0] Automated_SM_Sequential_site_reset_of_the_primary_and_secondary_core_triggered_by_site_block-unblock
    [Setup]  Run Keywords  common.Common Test Setup - MEMORY
    ...               AND  Set Test Variable  ${ITERATIONS}  ${DUAL_CORE_ITERATIONS}
    SM.46_Sequential_Site_Reset_of_the_Primary_and_Secondary_Core_Triggered_by_Site_Block-Unblock.Test Specific Setup
    Run Looping Test SM.46_Sequential_Site_Reset_of_the_Primary_and_Secondary_Core_Triggered_by_Site_Block-Unblock
    [Teardown]  SM.46_Sequential_Site_Reset_of_the_Primary_and_Secondary_Core_Triggered_by_Site_Block-Unblock.Test Case Teardown

*** Keywords ***
Run Looping Test ${test_name}
    ${passed_iterations}  Set Variable    ${0}
    ${failed_in_row}      Set Variable    ${0}
    ${KEYWORD_INDEX}      Set Variable    ${8}
    Append To List    ${TEST_SUITE_CONTENT}  ${TEST_NAME}
    ${TEST_INDEX}  Get Index From List    ${TEST_SUITE_CONTENT}  ${TEST_NAME}
    ${ITERATIONS}    Convert To Integer    ${ITERATIONS}
    ${data}    Create List
    FOR    ${iteration}    IN RANGE    1  ${ITERATIONS}+1
        Set Test Variable  ${ITERATION_INDEX}  ${iteration}
        Log In Frame    ${iteration} of ${ITERATIONS} - ${test_name}
        ${RESULTS_i}    Create Log Directory For Looping    ${iteration}
        ${port_open}    Run Keyword And Return Status    Check Admin Readiness
        Run Keyword If  ${port_open}   Run Keywords  Setup Syslog  ${RESULTS_i}/syslog    AND    Setup Admin
        alarms.Start Watchdog  ${skip_fault}
        ${iteration_start_time}    Get Current Time
        ${passed}    Run Keyword And Return Status    ${test_name}
        ${iteration_end_time}     Get Current Time
        Collect Syslog Files  ${RESULTS_i}/syslog/syslog.tar.gz
        ${no_unexpected_fid}  Run Keyword And Return Status  Stop Watchdog And Check Alarms
        ${time_diff}  Subtract Date From Date  ${iteration_end_time}  ${iteration_start_time}
        ${raw_data}  Create List  ${iteration}  ${iteration_start_time}  ${iteration_end_time}  ${time_diff}  ${passed}  ${no_unexpected_fid}
        Append To List    ${data}    ${raw_data}
        ${failed_in_row}  Set Variable If  ${passed} is True and ${no_unexpected_fid} is True  ${0}  ${failed_in_row+1}
        Run Keyword If  not ${passed} or not ${no_unexpected_fid}  Run Keyword If    0 < ${failed_in_row} <= ${MAX_FAIL_IN_ROW}
        ...    Run Keyword And Ignore Error    Recovery Snapshot For Looping    ${iteration}
        ${status}  ${passed_iterations}    Run Keyword And Ignore Error
        ...    Set Variable If  ${passed} and ${no_unexpected_fid}    ${passed_iterations+1}    ${passed_iterations}
        ${time_limit_reached}    Verify Suite Duration    ${TEST_SUITE_DURATION}
        Exit For Loop If    ${time_limit_reached}
    END
    ${headers}    Create List    iteration    iteration_start_time    iteration_end_time    time_difference    test verdict    watchdog verdict
    Generate Table    ${headers}    ${data}
    Run Keywords  Log To Console  Snapshot collecting
    ...  AND  Collect Snapshot  target_file_name=${RESULTS}/snapshot/snapshot_mrbts-${MRBTS_ID}.zip  timeout=1500
    Log  ${TEST_NAME}: ${passed_iterations}/${ITERATIONS} iterations passed    WARN
    Should Be Equal   ${passed_iterations}    ${ITERATIONS}

Recovery Snapshot For Looping
    [Arguments]    ${iteration}
    ${timestamp}    DateTime.Get Current Date  result_format=%d%m%Y%H%M%S  exclude_millis=True
    Log To Console    Iteration ${iteration} failed. Collecting logs.
    ${target_file_name}    Set Variable    ${RESULTS}/snapshot/${iteration}/${timestamp}_snapshot_mrbts-${MRBTS_ID}.zip
    Wait Until Keyword Succeeds  3x  10s  Collect Snapshot  target_file_name=${target_file_name}  timeout=1500

Create Log Directory For Looping
    [Arguments]    ${iteration}
    ${iteration}    Convert To String    ${iteration}
    ${RESULTS_i}    Join Path    ${RESULTS}    ${iteration}
    Create Directory    ${RESULTS_i}
    [Return]    ${RESULTS_i}
