*** Settings ***
Documentation
...   Author:   Terhi Talvitie
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource    testsuite/Oulu/TrunkEng/Common/Robot/TestKeywords/change_commissioning_parameters.robot
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
${FAULT}         1911
# Fault name can be legacy or category alarms name. If FAULT_NAME is legacy type, it is checked from commissioning if
# name needs to be changed to category alarms style.
${FAULT_NAME}    RF Module failure
# Max time to wait for cells to be up and running, currently mandatory to be given as integer, later also string will be suitable
${WAIT_FOR_CELLS_UP}    ${300}
# Can have values: RX1-RX8, TX1-TX8, LTX, All_TX or All_RX
${RESOURCE}    All_RX
# Default value for antenna is 0 that is LTX, 1-8 are TX and 9 -> RX
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

# For commissioning legacy/category alarms active
${PARAMETER}            actCategoryAlarms
# Can have values for example: true or false. If false then legacy alarms are activated.
${VALUE_OF_PARAMETER}   false


*** Test Cases ***
Rmod Fault 1911 to All Rx
    [Documentation]  First Changes value of actCategoryAlarms to user given value true or false. Then cause fault 1911 to
    ...    all RXs of the radio (closest if chain configuration). If radio uses telnet sendFault cause fault to all active antennas
    ...    and expect recovery actions.  Do site reset and check that units and cells are up and running and no unexpected alarms.
    ...    If radio is made radio cause fault to selected rmod once.
    [Tags]    "Fault 1911 to RMOD" -test loops: ${TEST_LOOPS}
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT}  ${SYSLOG_LIST}  ${PARAMETER}  ${VALUE_OF_PARAMETER}
        ...    name=Change actCategoryAlarms Parameter
        ...    test_case=pre
        ...    loops=1
		...    keywords=Change commissioning parameter
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${FAULT}  ${RMOD}  ${RESOURCE}
        ...    ${WAIT}  ${FAULT_NAME}
        ...    name=Rmod Fault 1911 To All Rx
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Rmod fault To All Tx or Rx of Radio
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
