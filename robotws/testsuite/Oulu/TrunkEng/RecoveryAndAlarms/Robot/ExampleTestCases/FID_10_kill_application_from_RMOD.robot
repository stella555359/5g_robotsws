*** Settings ***
Documentation
...   Author:   Terhi Talvitie
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource    testsuite/Oulu/TrunkEng/RecoveryAndAlarms/Robot/TestKeywords/radio_faults.robot

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown     Common Test Teardown


*** Variables ***
${RMOD}                 SMOD1-BBMOD1-RMOD1
# application that is killed to cause fault, needs to be given as full path of the application, f.ex. /opt/UCCS/uCcsSysComControlDaemon
${RMOD_APPLICATION}     /opt/UCCS/uCcsSysComControlDaemon
${FAULT}                10
${FAULT_NAME}           No connection to unit
# Max time to wait for cells to be up and running, currently mandatory to be given as integer, later also string will be suitable
${WAIT_FOR_CELLS_UP}    ${600}
# Syslog prints that will be printed to eventlog when found from the syslog, will not fail the test if found/not found
@{SYSLOG_LIST}          ResetCounter  Detected most recent reset type  Failed to execute executable  RecoveryConstraints
                        ...    Executing recovery action  RecoveryActionController   HW resource started up
                        ...    FAULT_SIGNATURE  AlarmFaultSignature
# Time to wait before doing any checks, seconds. Default 300
${WAIT}                 300
# List of unallowed syslog prints that will fail the test if seen during test
@{UNALLOWED_SYSLOGS}    4 (ERPresetTypeSpuriousReset)    14 (ERPresetTypeSpuriousResetBts)
# Path to allowed alarms file
${ALLOWED_ALARMS_FILE}  testsuite/Oulu/TrunkEng/RecoveryAndAlarms/allowed_alarms.txt
# Collect logs variable. POssible values are: On failure/Never/Always
${COLLECT_LOGS}         On failure
# How many times test will be run, needs to be more than 0
${TEST_LOOPS}           1


*** Test Cases ***
Kill Application from RMOD FID 10 and Recovery
    [Documentation]  Cause fault 10 to selected radio by killing given application with kommand kill -9 and expect recovery actions.
    ...              Do site reset and check that units and cells are up and running and no unexpected alarms.
    [Tags]    "Kill Application from RMOD FID 10 and Recovery" -test loops: ${TEST_LOOPS}
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${RMOD}  ${RMOD_APPLICATION}  ${FAULT}  ${FAULT_NAME}  ${WAIT_FOR_CELLS_UP}  ${SYSLOG_LIST}
        ...    ${WAIT}  ${UNALLOWED_SYSLOGS}
        ...    name=Kill application from RMOD fault 10 and recovery
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Kill Application From RMOD And Check Recovery
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}


