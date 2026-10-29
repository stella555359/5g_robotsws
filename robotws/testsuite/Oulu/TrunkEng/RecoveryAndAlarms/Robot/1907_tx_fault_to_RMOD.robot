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
# Fault to be caused to tx can be f.ex. 1904, 1907...
${FAULT}                1907
# Fault name can be legacy or category alarms name. If FAULT_NAME is legacy type, it is checked from commissioning if
# name needs to be changed to category alarms style.
${FAULT_NAME}           RF Module failure
# Max time to wait for cells to be up and running, currently mandatory to be given as integer, later also string will be suitable
${WAIT_FOR_CELLS_UP}    ${600}
# Can have values: RX1-RX8, TX1-TX8, LTX, All_TX or All_RX
${RESOURCE}
${RMOD}                 BBMOD1-RMOD1
${RMOD1111}             1.1.1.1
# Rmod in chain
${RMOD1112}             1.1.1.2
# Syslog prints that will be printed to eventlog when found from the syslog, will not fail the test if found/not found
@{SYSLOG_LIST}          ResetCounter  Detected most recent reset type  Failed to execute executable  RecoveryConstraints
                        ...    Executing recovery action  RecoveryActionController   HW resource started up
                        ...    FAULT_SIGNATURE  AlarmFaultSignature
# Time to wait before doing any checks, seconds. Default 300
${WAIT}                 300
# List of unallowed syslog prints that will fail the test if seen during test
@{UNALLOWED_SYSLOGS}    4 (ERPresetTypeSpuriousReset)    14 (ERPresetTypeSpuriousResetBts)
# Path to allowed alarms file
${ALLOWED_ALARMS_FILE}  /home/ute/MN/UTE/robotws/testsuite/Oulu/TrunkEng/RecoveryAndAlarms/allowed_alarms.txt
${WAIT_CHECKS}          30    # seconds, 0 if no waiting nor printing before post conditions check
# Collect logs variable. POssible values are: On failure/Never/Always
${COLLECT_LOGS}         On failure
# How many times test will be run, needs to be more than 0
${TEST_LOOPS}           1

&{COMMISSIONING_PARAMETERS}     txPathFailureMode=keepCellInService
                   ...          dlMimoMode=Dynamic Open Loop MIMO
                   ...          syncSigTxMode=TxDiv


*** Test Cases ***
Alarms__RMOD_failure_1907_Gc_MIMO
    [Tags]    "TX Fault 1907 to RMOD" -test loops: ${TEST_LOOPS}

    Run Keyword And Continue On Failure  Check If Enforcedrecovtimewindow Enabled And Disable It
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${COMMISSIONING_PARAMETERS}
        ...    name=Create delta file re-commissioning
        ...    test_case=Pre
        ...    loops=1
        ...    keywords=Do commissioning with delta file
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

# All TXs of first RMOD in chain
    Set Suite Variable   ${RESOURCE}   All_TX
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${FAULT}  ${RMOD1111}  ${RESOURCE}
        ...    ${WAIT}  ${FAULT_NAME}
        ...    name=TX Fault 1907 to First RMOD in chain
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Rmod fault To All Tx or Rx of Radio
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

# All TXs of second RMOD in chain
    Set Suite Variable   ${RESOURCE}   All_TX
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${FAULT}  ${RMOD1112}  ${RESOURCE}
        ...    ${WAIT}  ${FAULT_NAME}
        ...    name=TX Fault 1907 to Second RMOD in chain
        ...    test_case=2
        ...    loops=${TEST_LOOPS}
        ...    keywords=Rmod fault To All Tx or Rx of Radio
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

# One TX of first RMOD in chain
    Set Suite Variable   ${RESOURCE}   TX1
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${FAULT}  ${RMOD1111}  ${RESOURCE}
        ...    ${WAIT}  ${FAULT_NAME}
        ...    name=TX Fault 1907 to First RMOD in chain
        ...    test_case=3
        ...    loops=${TEST_LOOPS}
        ...    keywords=Rmod fault To Tx Or Rx
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

# One TX of second RMOD in chain
    Set Suite Variable   ${RESOURCE}   TX1
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${FAULT}  ${RMOD1112}  ${RESOURCE}
        ...    ${WAIT}  ${FAULT_NAME}
        ...    name=TX Fault 1907 to Second RMOD in chain
        ...    test_case=4
        ...    loops=${TEST_LOOPS}
        ...    keywords=Rmod fault To Tx Or Rx
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

Rmod Fault 1907 to All Tx
    [Documentation]  Cause fault 1907 to all TXs of the radio.
    [Tags]    "Fault 1907 to RMOD" -test loops: ${TEST_LOOPS}
    Set Suite Variable   ${RESOURCE}     All_TX
    Run Keyword And Continue On Failure  Check If Enforcedrecovtimewindow Enabled And Disable It
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${FAULT}  ${RMOD}  ${RESOURCE}
        ...    ${WAIT}  ${FAULT_NAME}
        ...    name=Rmod Fault 1907 To All Tx of radios
        ...    test_case=1
        ...    loops=1
        ...    keywords=Rmod fault To All Tx or Rx of Radio
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
