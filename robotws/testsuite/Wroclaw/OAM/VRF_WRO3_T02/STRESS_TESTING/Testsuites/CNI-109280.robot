*** Settings ***
Documentation
...    Author: tomasz.marchewka@nokia.com
...    Description: Suite prepared for CNI-109280 execution
...    Group in charge: I_MN_RAN_PZ_3_WRO_1_GMS <I_MN_RAN_PZ_3_WRO_1@internal.nsn.com>
...    Sample execution:
...    robot -v CONFIGURATION:Wroclaw.10_16_UTESRANxxxx -C on -T -d /home/ute/test_results -L TRACE -b debug.log
...    -V /home/ute/testline_configuration/10_16_UTESRANxxxx testsuite/Wroclaw/OAM/VRF_WRO3_T02/STRESS_TESTING/Testsuites/CNI-109280.robot


Resource        ../Testcases/SM.01_Site_Reset/test.robot
Resource        ../Testcases/SM.04_Cell_Block_Unblock/test.robot
Resource        ../Testcases/SM.08_BBMOD_Warm_Reset/test.robot
Resource        ../Testcases/SM.09_RAT_Reset/test.robot
Resource        ../Testcases/SM.10_Power_Reset/test.robot
Resource        ../Testcases/SM.11_RMOD_Reset/test.robot
Resource        ../../resources_mem/selenium.robot


Force Tags
...           SBTS00  CRT  # Branch indicator; Test Phase indicator; Scope indicator
...           QCP_RAN_ST  QCD_MN_RAN  ## QC project; QC domain for reporting
...           PY310  ## force python3 UTE package
...           RF50

Suite Setup       Run Keywords    common.Common Suite Setup    AND    Check If Concurrent
Suite Teardown    common.Common Suite Teardown
#Test Setup        common.Common Test Setup - MEMORY
#Test Teardown     common.Common Test Teardown - MEMORY
Test Timeout      73h


*** Variables ***
${ITERATIONS}                100
${TEST_SUITE_DURATION}       72    #test suite duration in hours
${MAX_FAIL_IN_ROW}           5     #maximum number of failed tests in a row
${SMODS_EXCLUDED_REGEX}      FSMF(\\+FSMF)?|ASO[EF]
@{TEST_SUITE_CONTENT}
${CONCURRENT}                False

*** Test Cases ***
### STRESS START ###
[1][2.0] SFE - Cell Block-Unblock - stress test
    [Tags]
    [Setup]    common.Common Test Setup - MEMORY
    Run Looping Test SM.04_Cell_Block_Unblock
    [Teardown]  SM.04_Cell_Block_Unblock.Test Case Teardown

[1][3.0] Automated__SM__RMOD_Reset
    [Tags]
    [Setup]    common.Common Test Setup - MEMORY
    Run Looping Test SM.11_RMOD_Reset
    [Teardown]    SM.11_RMOD_Reset.Test Case Teardown

[1][1.1] [SFE]_LTE4471_Capacity_Module_Warm_reset - stress test
    [Tags]
    [Setup]    common.Common Test Setup - MEMORY
    ${SMOD_excluded}  Run Keyword And Return Status  Should Match Regexp  ${SMOD_COMPOSITION}  ${SMODS_EXCLUDED_REGEX}
    Run Keyword If  not ${SMOD_excluded}  Run Looping Test SM.08_BBMOD_Warm_Reset
    ...  ELSE  Log To Console  Execution skipped - ${SMOD_COMPOSITION}
    [Teardown]    Run Keyword If  not ${SMOD_excluded}  SM.08_BBMOD_Warm_Reset.Test Case Teardown

[1][3.0] Automated__SM__RAT Reset - stress test
    [Tags]
    [Setup]    common.Common Test Setup - MEMORY
    Run Looping Test SM.09_RAT_Reset
    [Teardown]    SM.09_RAT_Reset.Test Case Teardown

[1][2.0] SFE - Site reset stress test
    [Tags]
    [Setup]    common.Common Test Setup - MEMORY
    Run Keyword If  not ${skip_NA_integration}  Setup TAF Netact
    Run Looping Test SM.01_Site_Reset
    [Teardown]    Run Keyword If  not ${skip_NA_integration}  Run Keywords
    ...        SM.01_Site_Reset.Test Case Teardown    AND   Teardown TAF Netact
    ...  ELSE  SM.01_Site_Reset.Test Case Teardown

[1][1.0] Automated__SM__Power_reset_-_stress_test
    [Tags]
    [Setup]    common.Common Test Setup - MEMORY
    Check Reset Method Validity
    Set Suite Variable    ${POWER_RESET_METHOD}    RANDOM
    Run Looping Test SM.10_Power_Reset
    [Teardown]    SM.10_Power_Reset.Test Case Teardown


### STRESS END ###


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
        Run Keyword If  ${CONCURRENT}  Setup Admin - Concurrent
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
    Run Keyword If  ${CONCURRENT}  Run Keywords  Log To Console  Snapshot collecting - concurrent
    ...  AND  Collect Snapshot  target_file_name=${RESULTS}/snapshot/snapshot_mrbts-6041.zip  timeout=1500  alias=concurrent
    Log  ${TEST_NAME}: ${passed_iterations}/${ITERATIONS} iterations passed    WARN
    Should Be Equal   ${passed_iterations}    ${ITERATIONS}

Recovery Snapshot For Looping
    [Arguments]    ${iteration}
    ${timestamp}    DateTime.Get Current Date  result_format=%d%m%Y%H%M%S  exclude_millis=True
    Log To Console    Iteration ${iteration} failed. Collecting logs.
    ${target_file_name}    Set Variable    ${RESULTS}/snapshot/${iteration}/${timestamp}_snapshot_mrbts-${MRBTS_ID}.zip
    Wait Until Keyword Succeeds  3x  10s  Collect Snapshot  target_file_name=${target_file_name}  timeout=1500
    Run Keyword If  ${CONCURRENT}  Wait Until Keyword Succeeds  3x  10s  Collect Snapshot
    ...  target_file_name=${RESULTS}/snapshot/${iteration}/${timestamp}_snapshot_mrbts-6041.zip  timeout=1500  alias=concurrent

Create Log Directory For Looping
    [Arguments]    ${iteration}
    ${iteration}    Convert To String    ${iteration}
    ${RESULTS_i}    Join Path    ${RESULTS}    ${iteration}
    Create Directory    ${RESULTS_i}
    [Return]    ${RESULTS_i}

Check If Concurrent
    Run Keyword If  '${TOPOLOGY}'=='CLOUD_SRAN_NL_1ASIB_3ABIC_1ASIK_3ABIL_2AEHC_UTECA'
    ...        Set Suite Variable  ${CONCURRENT}  True
    ...  ELSE  Set Suite Variable  ${CONCURRENT}  False
