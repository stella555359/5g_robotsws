*** Settings ***
Documentation
...   Author:   Mirka Kyllonen
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource    testsuite/Oulu/TrunkEng/RecoveryAndAlarms/Robot/TestKeywords/radio_faults.robot

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown     Common Test Teardown


*** Variables ***
# Fault to be caused to ltx can be f.ex. 1900, 1910, 1912...
${FAULT}         1912
# Fault name can be legacy or category alarms name. If FAULT_NAME is legacy type, it is checked from commissioning if
# name needs to be changed to category alarms style.
${FAULT_NAME}    RF Module out of order
# Max time to wait for cells to be up and running, currently mandatory to be given as integer, later also string will be suitable
${WAIT_FOR_CELLS_UP}    ${600}
# Can have values: RX, TX or LTX
${RESOURCE}    LTX
${RMOD1111}        1.1.1.1
# Rmod in chain
${RMOD1112}        1.1.1.2
# Syslog prints that will be printed to eventlog when found from the syslog, will not fail the test if found/not found
@{SYSLOG_LIST}          ResetCounter  Detected most recent reset type  Failed to execute executable  RecoveryConstraints
                        ...    Executing recovery action  RecoveryActionController   HW resource started up
                        ...    FAULT_SIGNATURE  AlarmFaultSignature
# Time to wait before doing any checks, seconds. Default 300
${WAIT}    300
# List of unallowed syslog prints that will fail the test if seen during test
@{UNALLOWED_SYSLOGS}    4 (ERPresetTypeSpuriousReset)    14 (ERPresetTypeSpuriousResetBts)
# Path to allowed alarms file
${ALLOWED_ALARMS_FILE}  /home/ute/MN/UTE/robotws/testsuite/Oulu/TrunkEng/RecoveryAndAlarms/allowed_alarms.txt
# Collect logs variable. POssible values are: On failure/Never/Always
${COLLECT_LOGS}         On failure
# How many times test will be run, needs to be more than 0
${TEST_LOOPS}           1

*** Test Cases ***
Alarms__RMOD_LTX_failure_1912_Gc_MIMO
    [Tags]    "LTX Fault 1912 to RMOD" -test loops: ${TEST_LOOPS}
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${FAULT}  ${RMOD1111}  ${RESOURCE}
        ...    ${WAIT}  ${FAULT_NAME}
        ...    name=LTX Fault 1912 to First RMOD in chain
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Rmod Fault To Ltx
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${FAULT}  ${RMOD1112}  ${RESOURCE}
        ...    ${WAIT}  ${FAULT_NAME}
        ...    name=LTX Fault 1912 to Second RMOD in chain
        ...    test_case=2
        ...    loops=${TEST_LOOPS}
        ...    keywords=Rmod Fault To Ltx
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
