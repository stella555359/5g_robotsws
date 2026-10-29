*** Settings ***
Documentation
...   Author:   Mirka Kyllonen
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource    testsuite/Oulu/TrunkEng/RecoveryAndAlarms/Robot/TestKeywords/radio_faults.robot
Resource    testsuite/Oulu/TrunkEng/Common/Robot/TestKeywords/change_commissioning_parameters.robot

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
${FAULT}         1904
# Fault name can be legacy or category alarms name. If FAULT_NAME is legacy type, it is checked from commissioning if
# name needs to be changed to category alarms style.
${FAULT_NAME}    RF BB bus synchronization error
# Max time to wait for cells to be up and running, currently mandatory to be given as integer, later also string will be suitable
${WAIT_FOR_CELLS_UP}    ${600}
# Can have values: RX1-RX8, TX1-TX8, LTX, All_TX or All_RX
${RESOURCE}
${RMOD}
# Syslog prints that will be printed to eventlog when found from the syslog, will not fail the test if found/not found
@{SYSLOG_LIST}          ResetCounter  Detected most recent reset type  Failed to execute executable  RecoveryConstraints
                        ...    Executing recovery action  RecoveryActionController   HW resource started up
                        ...    FAULT_SIGNATURE  AlarmFaultSignature
# Time to wait before doing any checks, seconds. Default 300
${WAIT}    300
# Variable for delta commissioning
${WAIT_CHECKS}  300
# List of unallowed syslog prints that will fail the test if seen during test
@{UNALLOWED_SYSLOGS}    4 (ERPresetTypeSpuriousReset)    14 (ERPresetTypeSpuriousResetBts)
# Path to allowed alarms file
${ALLOWED_ALARMS_FILE}  testsuite/Oulu/TrunkEng/RecoveryAndAlarms/allowed_alarms.txt
# Collect logs variable. Possible values are: On failure/Never/Always
${COLLECT_LOGS}         On failure
# How many times test will be run, needs to be more than 0
${TEST_LOOPS}           1
&{COMMISSIONING_PARAMETERS}     enforcedRecovTimeWindow=Enforced recovery disabled

*** Test Cases ***
BBMOD1-RMOD1 Fault 1904
    [Documentation]  Cause fault 1904 to radio.
    [Tags]    "Fault 1904 to RMOD" -test loops: ${TEST_LOOPS}
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${COMMISSIONING_PARAMETERS}
        ...    name=Create delta file re-commissioning
        ...    test_case=Pre
        ...    loops=1
        ...    keywords=Do commissioning with delta file
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
    Set Suite Variable   ${RESOURCE}   All_TX
    Set Suite Variable   ${RMOD}        BBMOD1-RMOD1
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${FAULT}  ${RMOD}  ${RESOURCE}
        ...    ${WAIT}  ${FAULT_NAME}
        ...    name=Rmod Fault 1904 To All Tx
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Rmod fault To All Tx or Rx of Radio
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
    Set Suite Variable   ${RESOURCE}   All_RX
    Set Suite Variable   ${RMOD}        BBMOD1-RMOD1
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${FAULT}  ${RMOD}  ${RESOURCE}
        ...    ${WAIT}  ${FAULT_NAME}
        ...    name=Rmod Fault 1904 To All Rx
        ...    test_case=2
        ...    loops=${TEST_LOOPS}
        ...    keywords=Rmod fault To All Tx or Rx of Radio
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
    Set Suite Variable   ${RESOURCE}   RX1
    Set Suite Variable   ${RMOD}        BBMOD1-RMOD1
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${FAULT}  ${RMOD}  ${RESOURCE}
        ...    ${WAIT}  ${FAULT_NAME}
        ...    name=Rmod Fault 1904 To One Rx
        ...    test_case=3
        ...    loops=${TEST_LOOPS}
        ...    keywords=Rmod fault To Tx Or Rx
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

SMOD1-RMOD1 Fault 1904
    [Documentation]  Cause fault 1904 to radio
    ...    If radio uses telnet sendFault cause fault 3 times and expect recovery actions. After recovery and checks,
    ...    do site reset and check that units and cells are up and running and no unexpected alarms.
    [Tags]    "Fault 1904 to RMOD" -test loops: ${TEST_LOOPS}
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${COMMISSIONING_PARAMETERS}
        ...    name=Create delta file re-commissioning
        ...    test_case=Pre
        ...    loops=1
        ...    keywords=Do commissioning with delta file
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
    Set Suite Variable   ${RESOURCE}   All_TX
    Set Suite Variable   ${RMOD}        SMOD1-RMOD1
    Run Keyword And Continue On Failure     ALARMS.Add Allowed Alarm  fault_id=1904  fault_name=RF BB bus synchronization error
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${FAULT}  ${RMOD}  ${RESOURCE}
        ...    ${WAIT}  ${FAULT_NAME}
        ...    name=Rmod Fault 1904 To All Tx
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Rmod fault To All Tx or Rx of Radio
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
    #Set Suite Variable   ${RESOURCE}   All_RX
    #Set Suite Variable   ${RMOD}        SMOD1-RMOD1
    #Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
    #    ...    ${WAIT_FOR_CELLS_UP}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${FAULT}  ${RMOD}  ${RESOURCE}
    #    ...    ${WAIT}  ${FAULT_NAME}
    #    ...    name=Rmod Fault 1904 To All Rx
    #    ...    test_case=2
    #    ...    loops=${TEST_LOOPS}
    #    ...    keywords=Rmod fault To All Tx or Rx of Radio
    #    ...    expected_pass_rate=1
    #    ...    collect_test_logs=${COLLECT_LOGS}
    #Set Suite Variable   ${RESOURCE}   RX1
    #Set Suite Variable   ${RMOD}        SMOD1-RMOD1
    #Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
    #    ...    ${WAIT_FOR_CELLS_UP}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${FAULT}  ${RMOD}  ${RESOURCE}
    #    ...    ${WAIT}  ${FAULT_NAME}
    #    ...    name=Rmod Fault 1904 To One Rx
    #    ...    test_case=3
    #    ...    loops=${TEST_LOOPS}
    #    ...    keywords=Rmod fault To Tx Or Rx
    #    ...    expected_pass_rate=1
    #    ...    collect_test_logs=${COLLECT_LOGS}

