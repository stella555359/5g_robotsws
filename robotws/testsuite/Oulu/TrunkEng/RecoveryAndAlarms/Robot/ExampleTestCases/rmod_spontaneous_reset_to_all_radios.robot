*** Settings ***
Documentation
...   Author:   Terhi Talvitie
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource    testsuite/Oulu/TrunkEng/RecoveryAndAlarms/Robot/TestKeywords/radio_spontaneous_reset.robot

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown     Common Test Teardown


*** Variables ***
# Syslog prints that will be printed to eventlog when found from the syslog, will not fail the test if found/not found
@{SYSLOG_LIST}          ResetCounter  Detected most recent reset type  Failed to execute executable  RecoveryConstraints
                        ...    Executing recovery action  RecoveryActionController   HW resource started up
# Time to wait before doing any post condition checks, seconds. Default 300
${WAIT}                 300
# Time to wait for cells up and running, seconds. Default 300
${WAIT_FOR_CELLS_UP}    300
# List of unallowed syslog prints that will fail the test if seen during test
@{UNALLOWED_SYSLOGS}    4 (ERPresetTypeSpuriousReset)    14 (ERPresetTypeSpuriousResetBts)
# Path to allowed alarms file
${ALLOWED_ALARMS_FILE}  testsuite/Oulu/TrunkEng/RecoveryAndAlarms/allowed_alarms.txt
# Collect logs variable. POssible values are: On failure/Never/Always
${COLLECT_LOGS}         On failure
# How many times test will be run, needs to be more than 0
${TEST_LOOPS}           1


*** Test Cases ***
Spontaneous Reset Of All Radios
    [Documentation]  Reset radio. Reset command depends on radio type and command is given via telnet or via ssh connection.
        ...          Check that after reset units and cells are up and running and no unexpected alarms are seen.
    [Tags]    "Spontaneous Reset Of Radio" -test loops: ${TEST_LOOPS}
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT}   ${WAIT_FOR_CELLS_UP}    ${SYSLOG_LIST}    ${UNALLOWED_SYSLOGS}
        ...    name=Spontaneous Reset Of All Radios
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Do Spontaneous Reset To All Radios One By One
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
