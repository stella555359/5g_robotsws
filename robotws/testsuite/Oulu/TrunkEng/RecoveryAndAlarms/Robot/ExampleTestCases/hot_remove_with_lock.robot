*** Settings ***
Documentation
...   Author:   Terhi Talvitie
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource    testsuite/Oulu/TrunkEng/RecoveryAndAlarms/Robot/TestKeywords/hot_remove_insert.robot


Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown     Common Test Teardown


*** Variables ***
# User can give values for example:
#  eventlog style RMOD name:
#    1.1.1.1, 2.1.1.1, 1.3.1.1, FXEB(1.3.2.2), FRHA(1.4.2.1), (1.4.2.1)...,
#  short style (r + last part of commissioned RMOD name):
#    r1, r2, r3, r4...
#  last part of commissioned RMOD name
#    RMOD-1, RMOD-2, RMOD-3, RMOD-4...,
#  hw_path:
#    /SMOD_R-1(Left)/BBMOD_R-3(Left_Top)/rf1/RMOD_R-3 or without side info using x
#    /SMOD_R-y(x)/BBMOD_R-z(x_Bottom)/rf2/RMOD_R-v (NOTE numbers y, z and v are ignored)
# closest in this test
${RMOD_TO_TEST}    1.1.1.1
# Time to wait before checking alarms when RMOD is hot removed and when RMOD is locked
${WAIT_BEFORE_ALARM_CHECK}    ${200}
# Max time to wait for cells to be up and running after RMOD unlock
${WAIT_FOR_CELLS_UP}    ${300}
# Wait after RMOD hot insert and RMOD unlock
${WAIT_CHECKS}     150
# Syslog prints that will be printed to eventlog when found from the syslog, will not fail the test if found/not found
@{SYSLOG_LIST}          ResetCounter  Detected most recent reset type  Failed to execute executable  RecoveryConstraints
                        ...    Executing recovery action  RecoveryActionController  Failure in optical interface
                        ...    HW resource started up (SWState=Configured)
# List of unallowed syslog prints that will fail the test if seen during test
@{UNALLOWED_SYSLOGS}    (ERPresetTypeApplication    ERPresetTypeSpuriousReset
# Path to allowed alarms file
${ALLOWED_ALARMS_FILE}  testsuite/Oulu/TrunkEng/RecoveryAndAlarms/allowed_alarms.txt
# Collect logs variable. POssible values are: On failure/Never/Always
${COLLECT_LOGS}         On failure
# How many times test will be run, needs to be more than 0
${TEST_LOOPS}           1


*** Test Cases ***
Hot Remove Insert With Lock
    [Documentation]  Lock radio, switch power of rmod off, check alarms and switch power on and check that everything is back ok.
    [Tags]    "Hot Remove RMOD-1 with lock" -test loops: ${TEST_LOOPS}
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${RMOD_TO_TEST}  ${WAIT_BEFORE_ALARM_CHECK}  ${WAIT_CHECKS}    ${WAIT_FOR_CELLS_UP}  ${SYSLOG_LIST}
        ...    ${UNALLOWED_SYSLOGS}
        ...    name=Hot remove insert RMOD-1 with lock
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Hot Remove Insert With Lock
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
