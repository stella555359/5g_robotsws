*** Settings ***
Documentation
...   Author:   Terhi Talvitie
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
${CASE_NAME}            Kill UEC Application in loop
# Max time to wait for cells to be up and running, currently mandatory to be given as integer, later also string will be suitable
${WAIT_FOR_CELLS_UP}    ${600}
# Wait after test and site reset, value can be given as string.
${WAIT_FOR_RECO_COUNTER_CLEAR}    360
# Time for wait alarm
${WAIT_FOR_ALARM}   90
# Suite Variable that's value is changed in Test Cases
${APPLICATION}
${SW_NODE}
${UNIT}  BBMOD1
${FAULT_NAME_END}    Virtual node not responding
${FAULT_NBR_END}     ${4383}
# Syslog prints that will be printed to eventlog when found from the syslog, will not fail the test if found/not found
@{SYSLOG_LIST}          ResetCounter  Detected most recent reset type Failed to execute executable  RecoveryConstraints
                        ...    Executing recovery action  RecoveryActionController  Set alarm  Reset count
                        ...    Please contact the owner of  FAULT_SIGNATURE  AlarmFaultSignature
@{UNALLOWED_SYSLOGS}        4 (ERPresetTypeSpuriousReset)    14 (ERPresetTypeSpuriousResetBts)
# Path to allowed alarms file
${ALLOWED_ALARMS_FILE}  /home/ute/MN/UTE/robotws/testsuite/Oulu/TrunkEng/RecoveryAndAlarms/allowed_alarms.txt
# Collect logs variable. Possible values are: On failure/Never/Always
${COLLECT_LOGS}         On failure
# How many times test will be run, needs to be more than 0
${TEST_LOOPS}     1


*** Test Cases ***
kill_UEC_from_BBMOD_SW_NODE_no_site_reset
    Sleep  1s
    [Timeout]    24h
    [Documentation]  Kill UEC application. Expect internal autonomous resets, RAT autonomous reset and alarms to be activated.
    [Tags]    "Kill UEC Application" -test loops: ${TEST_LOOPS}
    Set Suite Variable   ${APPLICATION}   UEC
    Set Suite Variable   ${UNIT}
    ${S_N}=  Get Virtual Sw Node  DistributedCPlane  ${UNIT}
    Set Suite Variable   ${SW_NODE}   ${S_N}
    ${fault_name_changed}=   Get Branch And Check If Same Or Newer Than Given  SBTS26R2
    IF  ${fault_name_changed}
        Set Suite Variable   ${FAULT_NAME_END}  Internal service not responding
    END
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...  ${WAIT_FOR_CELLS_UP}  ${APPLICATION}  ${SW_NODE}  ${UNIT}  ${WAIT_FOR_ALARM}  ${SYSLOG_LIST}
        ...  ${UNALLOWED_SYSLOGS}  ${FAULT_NAME_END}  ${FAULT_NBR_END}    ${WAIT_FOR_RECO_COUNTER_CLEAR}
        ...  name=${CASE_NAME}
        ...  test_case=1
        ...  loops=${TEST_LOOPS}
        ...  keywords=Kill application from BBMOD DistributedCPlane internal resets RAT resets and alarm active
        ...  expected_pass_rate=1
        ...  collect_test_logs=${COLLECT_LOGS}
