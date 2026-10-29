*** Settings ***
Documentation
...   Author:   Mirka Kyllonen
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource    testsuite/Oulu/TrunkEng/RecoveryAndAlarms/Robot/TestKeywords/hot_remove_insert.robot
Resource    testsuite/Oulu/TrunkEng/Common/Robot/TestKeywords/change_commissioning_parameters.robot


Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown     Common Test Teardown


*** Variables ***
# User can give values for example:
#            eventlog style RMOD name:
#                1.1.1.1, 2.1.1.1, 1.3.1.1, FXEB(2.3.1.1), FRHA(1.3.2.1), (1.1.3.1)...,
# RMOD_x.y.z.g:
#      x is pointing to SMOD (Note! if both sides of rack is used to same eNodeB, ONLY then there can be also RMOD_2.x.x.x)
#      y is pointing to BBMOD (starting from BBMOD in bottom of rack to upwards)
#      z is pointing to port nbr of BBMOD and
#      g is pointing to port nber of RMOD (chained config)#            short style (r + last part of commissioned RMOD name):
#                r1, r2, r3, r4...
#            last part of commissioned RMOD name
#                RMOD-1, RMOD-2, RMOD-3, RMOD-4...,
#            hw_path:
#                /SMOD_R-1(Left)/BBMOD_R-3(Left_Top)/rf1/RMOD_R-3 or without side info using x
#                /SMOD_R-y(x)/BBMOD_R-z(x_Bottom)/rf2/RMOD_R-v (NOTE numbers y, z and v are ignored)
#
${RMOD}            RMOD-1
# Time to wait before checking alarms when RMOD is hot removed
${WAIT_BEFORE_ALARM_CHECK}    ${300}
# Max time to wait for cells to be up and running, currently mandatory to be given as integer, later also string will be suitable
${WAIT_FOR_CELLS_UP}    ${600}
# Time to wait after site reset when RMOD is hot removed
${WAIT_AFTER_BTS_RESET}    ${300}
# seconds, 0 if no waiting nor printing before post conditions check
${WAIT_CHECKS}     480
# Syslog prints that will be printed to eventlog when found from the syslog, will not fail the test if found/not found
@{SYSLOG_LIST}          ResetCounter  Detected most recent reset type  Failed to execute executable  RecoveryConstraints
                        ...    Executing recovery action  RecoveryActionController  Failure in optical interface
                        ...    HW resource started up (SWState=Configured)  FAULT_SIGNATURE  AlarmFaultSignature
# List of unallowed syslog prints that will fail the test if seen during test
@{UNALLOWED_SYSLOGS}    ERPresetTypeApplication    ERPresetTypeSpuriousReset
# Path to allowed alarms file
${ALLOWED_ALARMS_FILE}  testsuite/Oulu/TrunkEng/RecoveryAndAlarms/allowed_alarms.txt
# Collect logs variable. Possible values are: On failure/Never/Always
${COLLECT_LOGS}         On failure
# How many times test will be run, needs to be more than 0
${TEST_LOOPS}           1
${TEST_TYPE}            Hot Remove Insert
${OBJECT_TO_CHANGE}      LNBTS

*** Test Cases ***
All-RMODs-hot-remove-hot-insert
    [Documentation]  Switch power of rmod off, check alarms and switch power on and check that everything is back ok.
    [Tags]    "Hot Remove all RMODs" -test loops: ${TEST_LOOPS}
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_BEFORE_ALARM_CHECK}  ${WAIT_CHECKS}  ${WAIT_FOR_CELLS_UP}  ${SYSLOG_LIST}
        ...    ${UNALLOWED_SYSLOGS}  ${WAIT_AFTER_BTS_RESET}  ${TEST_TYPE}
        ...    name=All RMODs Hot Remove Insert
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Do Test To All Radios One By One
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

RMOD-hot-remove-insert
    [Documentation]  Switch power of rmod off, check alarms and switch power on and check that everything is back ok.
    [Tags]    "Hot Remove Insert selected RMOD" -test loops: ${TEST_LOOPS}
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${RMOD}  ${WAIT_BEFORE_ALARM_CHECK}  ${WAIT_CHECKS}    ${WAIT_FOR_CELLS_UP}  ${SYSLOG_LIST}
        ...    ${UNALLOWED_SYSLOGS}
        ...    name=Selected RMOD Hot remove insert
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Hot Remove Insert
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
