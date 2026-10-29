*** Settings ***
Documentation
...   Author:   Terhi Talvitie
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource    testsuite/Oulu/TrunkEng/RecoveryAndAlarms/Robot/TestKeywords/kill_critical_applications.robot

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
${WAIT_FOR_CELLS_UP}    ${300}
# Wait after test and site reset, value can be given as string.
${WAIT_FOR_RECO_COUNTER_CLEAR}    360
# Not suitable way for real testing because of reporting. Usable just when trying functionality.
@{APPLICATIONS}         DEM  DCS  FRI  bm  BTSOMexe  HAS  LTS  MCI  MCtrl  SWM  SysAdapter  TAS  BStat
# Suite Variable that's value is changed in Test Cases
${APPLICATION}
# Syslog prints that will be printed to eventlog when found from the syslog, will not fail the test if found/not found
@{SYSLOG_LIST}          ResetCounter  Detected most recent reset type  Failed to execute executable  RecoveryConstraints
                        ...    Executing recovery action  RecoveryActionController
# Expected syslog print that will fail the test if not found during test run
${SYSLOG_PRINT}         ERPresetTypeSpuriousReset
# List of unallowed syslog prints that will fail the test if seen during test
#@{UNALLOWED_SYSLOGS}    (ERPresetTypeApplication
# Path to allowed alarms file
${ALLOWED_ALARMS_FILE}  testsuite/Oulu/TrunkEng/RecoveryAndAlarms/allowed_alarms.txt
# Collect logs variable. POssible values are: On failure/Never/Always
${COLLECT_LOGS}         On failure
# How many times test will be run, needs to be more than 0
${TEST_LOOPS}           1
# Time to wait before doing post conditions checks, seconds. Default 300
${WAIT}


*** Test Cases ***
#Kill All applications
#    [Documentation]  Kill application from real node. Application is given by user.
#    ${TESTCASE_NMBR}=  Set Variable    ${0}
#    FOR  ${APP}    IN    @{APPLICATIONS}
#        Set Suite Variable  ${APPLICATION}  ${APP}
#        ${TESTCASE_NMBR}=    Evaluate    ${TESTCASE_NMBR} + 1
#        Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
#            ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_RECO_COUNTER_CLEAR}  ${APPLICATION}  ${SYSLOG_LIST}
#            ...    ${SYSLOG_PRINT}  ${UNALLOWED_SYSLOGS}    ${WAIT}
#            ...    name=${CASE_NAME} ${APPLICATION}
#            ...    test_case=${TESTCASE_NMBR}
#            ...    loops=1
#            ...    keywords=Application Kill
#            ...    expected_pass_rate=1
#            ...    always_collect_logs=False
#    END
Kill FaultServiceExe Application
    [Documentation]  Kill FaultServiceExe application from real node. Spurious reset is expected.
    [Tags]    "Kill FaultServiceExe Application" -test loops: ${TEST_LOOPS}
    Set Suite Variable   ${APPLICATION}   FaultServiceExe
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_RECO_COUNTER_CLEAR}  ${APPLICATION}  ${SYSLOG_LIST}
        ...    ${SYSLOG_PRINT}    ${WAIT}
        ...    name=${CASE_NAME} ${APPLICATION}
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Application kill
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
    Run Keyword And Continue On Failure  Get Snapshot And Delete It

Kill BM Application
    [Documentation]  Kill bm application from real node. Spurious reset is expected.
    [Tags]    "Kill BM Application" -test loops: ${TEST_LOOPS}
    Set Suite Variable   ${APPLICATION}   bm
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_RECO_COUNTER_CLEAR}  ${APPLICATION}  ${SYSLOG_LIST}
        ...    ${SYSLOG_PRINT}    ${WAIT}
        ...    name=${CASE_NAME} ${APPLICATION}
        ...    test_case=2
        ...    loops=${TEST_LOOPS}
        ...    keywords=Application kill
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
    Run Keyword And Continue On Failure  Get Snapshot And Delete It

Kill BTSOMexe Application
    [Documentation]  Kill BTSOMexe application from real node. Spurious reset is expected.
    [Tags]    "Kill BTSOMexe Application" -test loops: ${TEST_LOOPS}
    Set Suite Variable  ${APPLICATION}  BTSOMexe
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_RECO_COUNTER_CLEAR}  ${APPLICATION}  ${SYSLOG_LIST}
        ...    ${SYSLOG_PRINT}    ${WAIT}
        ...    name=${CASE_NAME} ${APPLICATION}
        ...    test_case=3
        ...    loops=${TEST_LOOPS}
        ...    keywords=Application kill
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
    Run Keyword And Continue On Failure  Get Snapshot And Delete It

Kill LTS Application
    [Documentation]  Kill LTS application from real node. Spurious reset is expected.
    [Tags]    "Kill LTS Application" -test loops: ${TEST_LOOPS}
    Set Suite Variable  ${APPLICATION}  LTS
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_RECO_COUNTER_CLEAR}  ${APPLICATION}  ${SYSLOG_LIST}
        ...    ${SYSLOG_PRINT}    ${WAIT}
        ...    name=${CASE_NAME} ${APPLICATION}
        ...    test_case=4
        ...    loops=${TEST_LOOPS}
        ...    keywords=Application kill
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
    Run Keyword And Continue On Failure  Get Snapshot And Delete It
