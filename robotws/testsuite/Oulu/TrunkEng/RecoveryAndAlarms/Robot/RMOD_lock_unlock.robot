*** Settings ***
Documentation
...   Author:   Sirpa Passoja
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource    testsuite/Oulu/TrunkEng/RecoveryAndAlarms/Robot/TestKeywords/Lock_Unlock_module.robot
Resource    testsuite/Oulu/TrunkEng/Common/Robot/TestKeywords/change_commissioning_parameters.robot

Library     testsuite.Oulu.TrunkEng.Common.Python.Interfaces.pass_rate

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown     Common Test Teardown

*** Variables ***
# Max time to wait for cells to be up and running after RMOD unlock
${WAIT_FOR_CELLS_UP}    ${600}
# Wait after RMOD hot insert and RMOD unlock
${WAIT_CHECKS}     150
${TEST_TYPE}    Lock Unlock RMOD
# Syslog prints that will be printed to eventlog when found from the syslog, will not fail the test if found/not found
@{SYSLOG_LIST}          ResetCounter  Detected most recent reset type  Failed to execute executable  RecoveryConstraints
                        ...    Executing recovery action  RecoveryActionController  Failure in optical interface
                        ...    HW resource started up (SWState=Configured)  FAULT_SIGNATURE  AlarmFaultSignature
# List of unallowed syslog prints that will fail the test if seen during test
@{UNALLOWED_SYSLOGS}    ERPresetTypeApplication    ERPresetTypeSpuriousReset
# Path to allowed alarms file
${ALLOWED_ALARMS_FILE}  testsuite/Oulu/TrunkEng/RecoveryAndAlarms/allowed_alarms.txt
# Collect logs variable. POssible values are: On failure/Never/Always
${COLLECT_LOGS}         On failure
# How many times test will be run, needs to be more than 0
${TEST_LOOPS}           1

*** Test Cases ***
RMOD_lock_unlock
    Sleep  1s
	[Timeout]    24h
    [Documentation]  Lock radio, unlock radio and check that everything is back ok.
    [Tags]    "Lock Unlock RMOD" -test loops: ${TEST_LOOPS}
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_CHECKS}  ${WAIT_FOR_CELLS_UP}  ${SYSLOG_LIST}
        ...    ${UNALLOWED_SYSLOGS}  ${TEST_TYPE}
        ...    name=Lock Unlock RMODs And Checks
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Do Lock Test To All Radios One By One
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
