*** Settings ***
Documentation
...   Author:   Sirpa Passoja
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource    testsuite/Oulu/TrunkEng/RecoveryAndAlarms/Robot/TestKeywords/kill_applications_reset.robot
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
${CASE_NAME}            Kill TRS Application in loop
# Max time to wait for cells to be up and running, currently mandatory to be given as integer, later also string will be suitable
${WAIT_FOR_CELLS_UP}    ${600}
# Wait after test and site reset, value can be given as string.
${WAIT_FOR_RECO_COUNTER_CLEAR}    360
# Time for wait alarm
${WAIT_FOR_ALARM}   5
# Suite Variable that's value is changed in Test Cases
${APPLICATION}
# Syslog prints that will be printed to eventlog when found from the syslog, will not fail the test if found/not found
@{SYSLOG_LIST}          ResetCounter  Detected most recent reset type Failed to execute executable  RecoveryConstraints
                        ...    Executing recovery action  RecoveryActionController  Set alarm  Reset count
                        ...    Please contact the owner of  FAULT_SIGNATURE  AlarmFaultSignature
# Expected syslog print that will fail the test if not found during test run site autonomous reset
${SYSLOG_PRINT}         ERPresetTypeApplication
@{UNALLOWED_SYSLOGS}        4 (ERPresetTypeSpuriousReset)    14 (ERPresetTypeSpuriousResetBts)
# Expected alarms:
${FAULT_NAME_SITE_RESET}    BTS site autonomous reset as recovery action
${ALARM_NBR_SITE_RESET}     ${7101}
${FAULT_NBR_SITE_RESET}     ${6918}
${FAULT_NAME_END}           Non critical SW Component failure
${ALARM_NBR_END}            ${7116}
${FAULT_NBR_END}            ${6918}
# Path to allowed alarms file
${ALLOWED_ALARMS_FILE}  /home/ute/MN/UTE/robotws/testsuite/Oulu/TrunkEng/RecoveryAndAlarms/allowed_alarms.txt
${WAIT_CHECKS}          30    # seconds, 0 if no waiting nor printing before post conditions check
# Collect logs variable. Possible values are: On failure/Never/Always
${COLLECT_LOGS}         Always
# How many times test will be run, needs to be more than 0
${TEST_LOOPS}      1
# Variable for RFS testing. If RFS is set True, there is takan logs from both sides (4G/5G) and done also other checks to other side also.
${RFS}     ${False}
${MASTER}  This  # This/Other

*** Test Cases ***
Crash TRS application in SMOD
    Sleep  1s
    [Timeout]    24h
    [Documentation]  Kill TRS application. Autonomous reset with faultID/alarm are expected.
    [Tags]    "Kill TRS Application" -test loops: ${TEST_LOOPS}
    Set Suite Variable   ${APPLICATION}   tmgr
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${APPLICATION}  ${SYSLOG_PRINT}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}
        ...    ${WAIT_FOR_ALARM}  ${FAULT_NAME_SITE_RESET}  ${ALARM_NBR_SITE_RESET}  ${FAULT_NBR_SITE_RESET}
        ...    ${FAULT_NAME_END}  ${ALARM_NBR_END}  ${FAULT_NBR_END}  ${WAIT_FOR_RECO_COUNTER_CLEAR}
        ...    name=${CASE_NAME}
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Kill trs application site reset x3 and alarm active
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
