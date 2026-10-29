*** Settings ***
Documentation
...   Author:   Mirka Kyllonen
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource    testsuite/Oulu/TrunkEng/RecoveryAndAlarms/Robot/TestKeywords/kill_applications_reset.robot
Resource    testsuite/Oulu/TrunkEng/RecoveryAndAlarms/Robot/TestKeywords/bbmod_soc_test_kws.robot

Library     testsuite.Oulu.TrunkEng.Common.Python.Interfaces.pass_rate
Library     testsuite.Oulu.TrunkEng.Common.Python.Interfaces.FspIP  WITH NAME  FSP
Library     testsuite.Oulu.TrunkEng.Common.Python.Interfaces.SSHConnection  WITH NAME  SSH
Library     testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Applications

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown     Common Test Teardown


*** Variables ***
# Max time to wait for cells to be up and running, currently mandatory to be given as integer, later also string will be suitable
${WAIT_FOR_CELLS_UP}    ${600}
# Wait after test and site reset, value can be given as string.
${WAIT_FOR_RECO_COUNTER_CLEAR}    360
# Time for wait alarm when alarm activated, needs to be log so 10 alarm have time to be raised
${WAIT_FOR_ALARM}   720
# time to wait after fault activated, before unit state checks
${WAIT_CHECKS}    180
# Suite Variable that's value is changed in Test Cases
${UNIT}
# This is PrimarySOC TODO! Use generic primarySOC value when available
${SOC}  K2A
# Application which is killed from K2x
${APPLICATION}  FaultServiceExe
# Prints that are monitored from syslog to eventlog
@{SYSLOG_LIST}          ResetCounter  Detected most recent reset type  Failed to execute executable
                        ...    Executing recovery action  RecoveryActionController  Set alarm  Reset count
                        ...    Please contact the owner of   RESET, DDAL_HOTPLUG_EVT_RIO_REMOVE received device_id
                        ...    FAULT_SIGNATURE  AlarmFaultSignature
# Path to allowed alarms file
${ALLOWED_ALARMS_FILE}  /home/ute/MN/UTE/robotws/testsuite/Oulu/TrunkEng/RecoveryAndAlarms/allowed_alarms.txt
# Collect logs variable. Possible values are: On failure/Never/Always
${COLLECT_LOGS}         Always
# How many times test will be run, needs to be more than 0
${TEST_LOOPS}           1


*** Test Cases ***
BBMOD-1 max recoveries and shutdown
    Sleep  1s
    [Timeout]    24h
    [Documentation]  Tester is generating failure to BBMOD PrimarySOC x3 to cause BBMOD autonomous reset.
    ...              Tester is generating failure to BBMOD PrimarySOC x1 to cause BBMOD autonomous power reset due to PR804929.
    ...              Tester is generating failure to BBMOD PrimarySOC x1 to cause permanent failure.
    ...              At the end Site reset cleaner is performed.
    ...              NOTE case is NOT suitable for one BBMOD configuration.
    [Tags]  "BBMOD-1 max recoveries and shutdown" -test loops: ${TEST_LOOPS}
    Set Suite Variable   ${UNIT}   BBMOD-1
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_ALARM}  ${APPLICATION}  ${UNIT}  ${SOC}  ${SYSLOG_LIST}
        ...    ${WAIT_FOR_RECO_COUNTER_CLEAR}    ${WAIT_CHECKS}
        ...    name=${UNIT} recovery and shutdown
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Kill application from primary SoC until alarm is active
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

BBMOD-2 max recoveries and shutdown
    Sleep  1s
    [Timeout]    24h
    [Documentation]  Tester is generating failure to BBMOD PrimarySOC x3 to cause BBMOD autonomous reset.
    ...              Tester is generating failure to BBMOD PrimarySOC x1 to cause BBMOD autonomous power reset due to PR804929.
    ...              Tester is generating failure to BBMOD PrimarySOC x1 to cause permanent failure.
    ...              At the end Site reset cleaner is performed.
    [Tags]  "BBMOD-2 max recoveries and shutdown" -test loops: ${TEST_LOOPS}
    Set Suite Variable   ${UNIT}   BBMOD-2
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_ALARM}  ${APPLICATION}  ${UNIT}  ${SOC}  ${SYSLOG_LIST}
        ...    ${WAIT_FOR_RECO_COUNTER_CLEAR}    ${WAIT_CHECKS}
        ...    name=${UNIT} recovery and shutdown
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Kill application from primary SoC until alarm is active
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

BBMOD-3 max recoveries and shutdown
    Sleep  1s
    [Timeout]    24h
    [Documentation]  Tester is generating failure to BBMOD PrimarySOC x3 to cause BBMOD autonomous reset.
    ...              Tester is generating failure to BBMOD PrimarySOC x1 to cause BBMOD autonomous power reset due to PR804929.
    ...              Tester is generating failure to BBMOD PrimarySOC x1 to cause permanent failure.
    ...              At the end Site reset cleaner is performed.
    [Tags]  "BBMOD-3 max recoveries and shutdown" -test loops: ${TEST_LOOPS}
    Set Suite Variable   ${UNIT}   BBMOD-3
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_ALARM}  ${APPLICATION}  ${UNIT}  ${SOC}  ${SYSLOG_LIST}
        ...    ${WAIT_FOR_RECO_COUNTER_CLEAR}    ${WAIT_CHECKS}
        ...    name=${UNIT} recovery and shutdown
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Kill application from primary SoC until alarm is active
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

