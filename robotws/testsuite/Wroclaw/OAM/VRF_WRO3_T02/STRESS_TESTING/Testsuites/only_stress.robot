*** Settings ***
Documentation
...    Author: tomasz.marchewka@nokia.com
...    Description: Suite prepared for STRESS TESTING tests execution
...    Group in charge: I_MN_RAN_PZ_3_WRO_1_GMS <I_MN_RAN_PZ_3_WRO_1@internal.nsn.com>
...    Sample execution:
...    robot -v CONFIGURATION:Wroclaw.10_16_UTESRANxxxx -C on -T -d /home/ute/test_results -L TRACE -b debug.log
...    -V /home/ute/testline_configuration/10_16_UTESRANxxxx testsuite/Wroclaw/OAM/VRF_WRO3_T02/STRESS_TESTING/Testsuites/only_stress.robot


Resource        ../Testcases/MEM.01_Neighbouring_Objects_Delta_Commissioning_via_Admin/test.robot
Resource        ../Testcases/MEM.02_Neighbouring_NR_Objects_Delta_Commissioning_via_Admin/test.robot
Resource        ../Testcases/SM.01_Site_Reset/test.robot
Resource        ../Testcases/SM.02_Site_Block_Unblock/test.robot
Resource        ../Testcases/SM.04_Cell_Block_Unblock/test.robot
Resource        ../Testcases/SM.05_RMOD_Lock_Unlock/test.robot
Resource        ../Testcases/SM.08_BBMOD_Warm_Reset/test.robot
Resource        ../Testcases/SM.09_RAT_Reset/test.robot
Resource        ../Testcases/SM.10_Power_Reset/test.robot
Resource        ../Testcases/SM.11_RMOD_Reset/test.robot
Resource        ../Testcases/SM.12_CellGroup_Lock_Unlock/test.robot
Resource        ../Testcases/SM.13_BBMOD_Lock_Unlock/test.robot
Resource        ../Testcases/SM.14_GNSSE_Reset/test.robot
Resource        ../Testcases/SM.15_BBPOOL_Warm_Reset_NA/test.robot
Resource        ../Testcases/SM.47_BBMOD_Power_Reset_via_WebEM/test.robot
Resource        ../Testcases/SM.48_RU_Power_Reset/test.robot
Resource        ../Testcases/SM.100_SW_download_without_activation/test.robot
Resource        ../Testcases/PS.101_Preconfigure_PSGRP_NRGRP_For_MEM/test.robot   #PS4ALL


Force Tags
...           SBTS00  CRT  # Branch indicator; Test Phase indicator; Scope indicator
...           QCP_RAN_VRF  QCD_MN_RAN  ## QC project; QC domain for reporting
...           PY310  ## force python3 UTE package
...           RF50

Suite Setup       Run Keywords    common.Common Suite Setup    AND    Check If Concurrent
Suite Teardown    common.Common Suite Teardown
#Test Setup        common.Common Test Setup - MEMORY
#Test Teardown     common.Common Test Teardown - MEMORY
Test Timeout      73h


*** Variables ***
${ITERATIONS}                100
${SW_DOWNLOAD_ITERATIONS}    3
${TEST_SUITE_DURATION}       72    #test suite duration in hours
${MAX_FAIL_IN_ROW}           5     #maximum number of failed tests in a row
${SMODS_EXCLUDED_REGEX}      FSMF(\\+FSMF)?|ASO[EFGH]
@{TEST_SUITE_CONTENT}
${CONCURRENT}                False

*** Test Cases ***
### STRESS START ###
[1][2.0] SFE - Cell Block-Unblock - stress test
    [Tags]
    [Setup]    common.Common Test Setup - MEMORY
    Run Looping Test SM.04_Cell_Block_Unblock
    [Teardown]  SM.04_Cell_Block_Unblock.Test Case Teardown

[1][1.1] [SFE]_LTE4471_Capacity_Module_Warm_reset - stress test
    [Tags]
    [Setup]    common.Common Test Setup - MEMORY
    ${SMOD_excluded}  Run Keyword And Return Status  Should Match Regexp  ${SMOD_COMPOSITION}  ${SMODS_EXCLUDED_REGEX}
    Run Keyword If  not ${SMOD_excluded}  Run Looping Test SM.08_BBMOD_Warm_Reset
    ...  ELSE  Log To Console  Execution skipped - ${SMOD_COMPOSITION}
    [Teardown]    Run Keyword If  not ${SMOD_excluded}  SM.08_BBMOD_Warm_Reset.Test Case Teardown

[1][1.0] RM_Lock_Unlock_-_stress_test
    [Tags]
    [Setup]    common.Common Test Setup - MEMORY
    Run keyword except for FSMF     common.Ensure NORMAL value on all RMODs
    Run Looping Test SM.05_RMOD_Lock_Unlock
    [Teardown]    Run Keywords      SM.05_RMOD_Lock_Unlock.Test Case Teardown
    ...      AND      Run keyword except for FSMF     common.Restore parameters value on all RMODs

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

[1][2.0] SFE - Site Block-Unblock - stress test
    [Tags]
    [Setup]    common.Common Test Setup - MEMORY
    Run Looping Test SM.02_Site_Block_Unblock
    [Teardown]    SM.02_Site_Block_Unblock.Test Case Teardown

[1][1.0] Automated__SM__Power_reset_-_stress_test
    [Tags]
    [Setup]    common.Common Test Setup - MEMORY
    Run keyword except for FSMF     common.Ensure NORMAL value on all RMODs
    Set Suite Variable    ${CB007040_available}    True
    Set Suite Variable    ${POWER_RESET_METHOD}    RANDOM
    Run Looping Test SM.10_Power_Reset
    [Teardown]    Run Keywords      SM.10_Power_Reset.Test Case Teardown
    ...      AND      Run keyword except for FSMF     common.Restore parameters value on all RMODs

#[1][3.0] Automated__SM__GNSS_Reset
#    [Tags]
#    [Setup]    common.Common Test Setup - MEMORY
#    Run Looping Test SM.14_GNSSE_Reset
#    [Teardown]    SM.14_GNSSE_Reset.Test Case Teardown

[1][3.0] Automated__SM__BBPOOL_Warm_Reset_via_NA
    [Tags]
    [Setup]    Run Keywords    common.Common Test Setup - MEMORY
    ...    AND    Setup TAF Netact
    ...    AND    Switch LTE Administration Feature    parameter=actLBBbPowerSaving  value=false
    Run Looping Test SM.15_BBPOOL_Warm_Reset_NA
    [Teardown]    Run Keywords    SM.15_BBPOOL_Warm_Reset_NA.Test Case Teardown
    ...    AND    Teardown TAF Netact
    ...    AND    Switch LTE Administration Feature    parameter=actLBBbPowerSaving  value=true

[1][1.1] Automated__SM__BBMOD_Power_Reset_via_WebEM_-_stress_test
    [Tags]
    [Setup]    common.Common Test Setup - MEMORY
    ${SMOD_excluded}  Run Keyword And Return Status  Should Match Regexp  ${SMOD_COMPOSITION}  ${SMODS_EXCLUDED_REGEX}
    Run Keyword If  not ${SMOD_excluded}  Run Looping Test SM.47_BBMOD_Power_Reset_via_WebEM
    ...  ELSE  Log To Console  Execution skipped - ${SMOD_COMPOSITION}
    [Teardown]    SM.47_BBMOD_Power_Reset_via_WebEM.Test Case Teardown

[1][1.0] Automated__SM__RMOD_Power_Reset
    [Tags]
    [Setup]    common.Common Test Setup - MEMORY
    Run keyword except for FSMF     common.Ensure NORMAL value on all RMODs
    Run Looping Test SM.48_RMOD_Power_Reset
    [Teardown]    Run Keywords      SM.48_RMOD_power_reset.Test Case Teardown
    ...      AND      Run keyword except for FSMF     common.Restore parameters value on all RMODs

### STRESS END ###


*** Keywords ***
Run Looping Test ${test_name}
    ${passed_iterations}  Set Variable    ${0}
    ${failed_in_row}      Set Variable    ${0}
    ${KEYWORD_INDEX}      Set Variable    ${8}
    ${critical_in_row}    Set Variable    ${0}
    Append To List    ${TEST_SUITE_CONTENT}  ${TEST_NAME}
    ${TEST_INDEX}  Get Index From List    ${TEST_SUITE_CONTENT}  ${TEST_NAME}
    ${ITERATIONS}    Convert To Integer    ${ITERATIONS}
    ${data}    Create List
    FOR    ${iteration}    IN RANGE    1  ${ITERATIONS}+1
        Set Test Variable  ${ITERATION_INDEX}  ${iteration}
        Log In Frame    ${iteration} of ${ITERATIONS} - ${test_name}
        ${RESULTS_i}    Create Log Directory For Looping    ${iteration}
        Setup Syslog  ${RESULTS_i}/syslog
        ${port_open}    Run Keyword And Return Status    Check Admin Readiness
        Run Keyword If  ${port_open}    Setup Admin
        Run Keyword If  ${CONCURRENT}  Setup Admin - Concurrent
        alarms.Start Watchdog  ${skip_fault}
        ${iteration_start_time}    Get Current Time
        ${passed}    Run Keyword And Return Status    ${test_name}
        ${iteration_end_time}     Get Current Time
        Collect Syslog Files  ${RESULTS_i}/syslog/syslog.tar.gz
        ${no_unexpected_fid}  Run Keyword And Return Status  Stop Watchdog And Check Alarms
        ${critical_in_row}    Set Variable If    ${verdict} is True  ${0}  ${critical_in_row+1}
        Run Keyword If    ${critical_in_row} > 5  Fail    Test case failed due to 5 consecutive Critical alarms
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

Switch LTE Administration Feature
    [Arguments]    ${parameter}    ${value}
    ${new_value}       Set Variable     new_value
    ${admin_log_path}  Set Variable     /home/ute/test_results/admin_api_switch_feature/
    Wait Until Keyword Succeeds  6x  5s  admin.setup admin  admin_api_log_dir=${admin_log_path}  update_interval=500  alias=${new_value}
    ${feature_list}  admin.get managed objects  FEATLADM_A  connection=${new_value}
    FOR  ${ITEM}  IN  @{feature_list}
        ${feature_status}=  Set Variable If  '${ITEM['parameters']['${parameter}']}'=='${True}'  true
    END
    ${FEATLADM_DN}    Set Variable  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1/FEATLADM-1
    Run Keyword If  '${value}'=='true' and '${feature_status}'=='true'
    ...  Log To Console  Parameter ${parameter} is set on: ${feature_status}
    ...  ELSE IF  '${value}'=='true' and '${feature_status}'!='true'  Run Keywords
    ...  Log To Console  Parameter ${parameter} is set on: false. Expected value: true. => Featrue activation.
    ...  AND  admin.perform parameter recommissioning  dist_name=${FEATLADM_DN}
    ...                                                parameter=${parameter}
    ...                                                operation=update
    ...                                                value=${value}
    ...                                                skip_parameter_relation_errors=${SKIP_PARAMETER_RELATION_ERRORS}
    ...                                                connection=${new_value}
    ...  ELSE IF  '${value}'=='false' and '${feature_status}'=='true'  Run Keywords
    ...  Log To Console  Parameter ${parameter} is set on: true. Expected value: false. => Feature deactivation.
    ...  AND  admin.perform parameter recommissioning  dist_name=${FEATLADM_DN}
    ...                                                parameter=${parameter}
    ...                                                operation=update
    ...                                                value=${value}
    ...                                                skip_parameter_relation_errors=${SKIP_PARAMETER_RELATION_ERRORS}
    ...                                                connection=${new_value}
    ...  ELSE  Log To Console  Parameter ${parameter} is set on: false
    admin.teardown admin    alias=${new_value}
