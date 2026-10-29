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
# To sendFault command:
# Fault to be caused to LTX can be f.ex. 1900, 1901, 1902, 1903, 1904, 1905, 1906, 1912, 1923, 1926, 1928, 1930...
# Fault to be caused to TX can be f.ex. 1904, 1905, 1906, 1907, 1908, 1910, 1918, 1920, 1924...
# Fault to be caused to RX can be f.ex. 1903, 1904, 1905, 1911, 1924...
${FAULT}         1907
# Fault name can be legacy or category alarms name. If FAULT_NAME is legacy type, it is checked from commissioning if
# name needs to be changed to category alarms style.
${FAULT_NAME}    RF Module failure
# Max time to wait for cells to be up and running
${WAIT_FOR_CELLS_UP}    ${60}
# Can have value LTX, TX1-TX8, RX1-RX8, All_TX or All_RX. The antenna to which fault is caused is selected by position. RX1 is for example
# the first active RX that is found from the given radio in the used configuration, RX2 is the second active antenna found from
# the selected radio etc.
${RESOURCE}    TX1
${RMOD}        BBMOD1-RMOD1
# Syslog prints that will be printed to eventlog when found from the syslog, will not fail the test if found/not found
@{SYSLOG_LIST}          ResetCounter  Detected most recent reset type  Failed to execute executable  RecoveryConstraints
                        ...    Executing recovery action  RecoveryActionController   HW resource started up
# Time to wait before doing any checks, seconds. Default 300
${WAIT}    300
# List of unallowed syslog prints that will fail the test if seen during test
@{UNALLOWED_SYSLOGS}    4 (ERPresetTypeSpuriousReset)    14 (ERPresetTypeSpuriousResetBts)
# Path to allowed alarms file
${ALLOWED_ALARMS_FILE}  testsuite/Oulu/TrunkEng/RecoveryAndAlarms/allowed_alarms.txt
# Collect logs variable. POssible values are: On failure/Never/Always
${COLLECT_LOGS}         On failure
# How many times test will be run, needs to be more than 0
${TEST_LOOPS}           1


*** Test Cases ***
Rmod Fault 1907 to TX1 of RMOD1
    [Documentation]  Cause fault 1907 to TX of radio (closest if chain configuration) once.
    ...    Expect active alarm. Do site reset and check that units and cells are up and running and no unexpected alarms.
    [Tags]    "Fault 1907 to RMOD" -test loops: ${TEST_LOOPS}
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${FAULT}  ${RMOD}  ${RESOURCE}
        ...    ${WAIT}  ${FAULT_NAME}
        ...    name=Rmod Fault 1907 to RX1 of RMOD1
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Rmod fault To Tx Or Rx
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
