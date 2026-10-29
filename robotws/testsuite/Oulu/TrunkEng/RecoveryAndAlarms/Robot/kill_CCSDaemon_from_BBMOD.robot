*** Settings ***
Documentation
...   Author:   Mirka Kyllonen
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource    testsuite/Oulu/TrunkEng/RecoveryAndAlarms/Robot/TestKeywords/bbmod_soc_test_kws.robot
Resource    testsuite/Oulu/TrunkEng/Common/Robot/TestKeywords/change_commissioning_parameters.robot

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
# This will be seen before every application in test run f.ex. Crash of critical application bm
${CASE_NAME}            Crash of CCSDaemon from BBMOD
# Max time to wait for cells to be up and running, currently mandatory to be given as integer, later also string will be suitable
${WAIT_FOR_CELLS_UP}    ${600}
# Wait after test and site reset, value can be given as string.
${WAIT_FOR_RECO_COUNTER_CLEAR}    360
# Time for wait alarm
${WAIT_FOR_ALARM}   360
# Prints that are monitored from syslog to eventlog
@{SYSLOG_LIST}          Detected most recent reset type    Failed to execute executable
                        ...    Executing recovery action  Set alarm  Reset count
                        ...    Please contact the owner of  FAULT_SIGNATURE  AlarmFaultSignature
# Suite Variable that's value is changed in Test Cases
${UNIT}
${SOC}
${APPLICATION}
# Path to allowed alarms file
${ALLOWED_ALARMS_FILE}  /home/ute/MN/UTE/robotws/testsuite/Oulu/TrunkEng/RecoveryAndAlarms/allowed_alarms.txt
# Collect logs variable. Possible values are: On failure/Never/Always
${COLLECT_LOGS}         Always
# How many times test will be run, needs to be more than 0
${TEST_LOOPS}           1


*** Test Cases ***
ABIP1_Marlin_CCSDaemon
    Sleep  1s
    [Timeout]    12h
    [Documentation]  Crash CCSDaemon application
    [Tags]  "Crash CCSDaemon application" -test loops: ${TEST_LOOPS}
    Set Suite Variable   ${UNIT}           ABIP1
    Set Suite Variable   ${SOC}            Marlin
    Set Suite Variable   ${APPLICATION}    CCSDaemonExe
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_ALARM}  ${APPLICATION}  ${UNIT}  ${SOC}  ${TEST_LOOPS}
        ...    name=${CASE_NAME} ${UNIT} ${SOC}
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Kill CCSDaemon from BBMOD then make SoC and BBMOD reset
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

ABIN1_Snowfish_CCSDaemon
    Sleep  1s
    [Timeout]    12h
    [Documentation]  Crash CCSDaemon application
    [Tags]  "Crash CCSDaemon application" -test loops: ${TEST_LOOPS}
    Set Suite Variable   ${UNIT}           ABIN1
    Set Suite Variable   ${SOC}            SNF
    Set Suite Variable   ${APPLICATION}    CCSDaemonExe
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_ALARM}  ${APPLICATION}  ${UNIT}  ${SOC}  ${TEST_LOOPS}
        ...    name=${CASE_NAME} ${UNIT} ${SOC}
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Kill CCSDaemon from BBMOD then make SoC and BBMOD reset
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

ABIO1_Snowfish_CCSDaemon
    Sleep  1s
    [Timeout]    12h
    [Documentation]  Crash CCSDaemon application
    [Tags]  "Crash CCSDaemon application" -test loops: ${TEST_LOOPS}
    Set Suite Variable   ${UNIT}           ABIO1
    Set Suite Variable   ${SOC}            SNF
    Set Suite Variable   ${APPLICATION}    CCSDaemonExe
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_ALARM}  ${APPLICATION}  ${UNIT}  ${SOC}  ${TEST_LOOPS}
        ...    name=${CASE_NAME} ${UNIT} ${SOC}
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Kill CCSDaemon from BBMOD then make SoC and BBMOD reset
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
