*** Settings ***
Documentation
...   Author:   Mirka Kyllönen
...   Contact:  I_MN_RAN_TRUNK_SG_OUL1@internal.nsn.com

Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource    testsuite/Oulu/TrunkEng/RecoveryAndAlarms/Robot/TestKeywords/hot_remove_insert.robot

Library     testsuite.Oulu.TrunkEng.RecoveryAndAlarms.Python.Interfaces.FaultingRmod

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown     Common Test Teardown


*** Variables ***
# Time to wait before checking alarms when RMOD is hot removed
${WAIT_BEFORE_ALARM_CHECK}    ${480}
# Max time to wait for cells to be up and running
${WAIT_FOR_CELLS_UP}    ${600}
# seconds, 0 if no waiting nor printing before post conditions check
${WAIT_CHECKS}     480
# time to wait after bts reset in seconds
${WAIT_AFTER_BTS_RESET}    1000
# Test type that will be done to all radios.
# Can be for example: Hot Remove Insert, Hot Remove Insert With Reset, Hot Remove Insert With Lock, Hot Remove During Startup
${TEST_TYPE}        Hot Remove During Startup
# Syslog prints that will be printed to eventlog when found from the syslog, will not fail the test if found/not found
@{SYSLOG_LIST}          ResetCounter  Detected most recent reset type  Failed to execute executable  RecoveryConstraints
                        ...    Executing recovery action  RecoveryActionController  Failure in optical interface
                        ...    HW resource started up (SWState=Configured)
# List of unallowed syslog prints that will fail the test if seen during test
@{UNALLOWED_SYSLOGS}    ERPresetTypeSpuriousReset
# Path to allowed alarms file
${ALLOWED_ALARMS_FILE}  testsuite/Oulu/TrunkEng/RecoveryAndAlarms/allowed_alarms.txt
# Collect logs variable. POssible values are: On failure/Never/Always
${COLLECT_LOGS}         On failure
# How many times test will be run, needs to be more than 0
${TEST_LOOPS}           1

# Add this to keywords= later if test will be run to all radios Do Test To All Radios One By One
# And this to variables     ${TEST_TYPE}

*** Test Cases ***
Hot Remove During Start-up
    [Documentation]  Switch power of rmod off, check alarms and switch power on and check that everything is back ok.
    ...              Do this to all radios in the environment one by one.
    [Tags]    "Hot Remove During Start-up To All Radios" -test loops: ${TEST_LOOPS}
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_BEFORE_ALARM_CHECK}  ${WAIT_CHECKS}  ${WAIT_FOR_CELLS_UP}  ${SYSLOG_LIST}
        ...    ${UNALLOWED_SYSLOGS}    ${WAIT_AFTER_BTS_RESET}  ${TEST_TYPE}
        ...    name=Hot Remove During Startup
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Do Test To All Radios One By One
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
