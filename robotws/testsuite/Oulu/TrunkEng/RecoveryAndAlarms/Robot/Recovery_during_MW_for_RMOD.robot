*** Settings ***
Documentation
...   Author:   Mirka Kyllönen
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource    testsuite/Oulu/TrunkEng/RecoveryAndAlarms/Robot/TestKeywords/radio_faults.robot
Resource    testsuite/Oulu/TrunkEng/Common/Robot/TestKeywords/change_commissioning_parameters.robot

Library     testsuite.Oulu.TrunkEng.Common.Python.Interfaces.pass_rate
Library     testsuite.Oulu.TrunkEng.Common.Python.Interfaces.FspIP  WITH NAME  FSP
Library     testsuite.Oulu.TrunkEng.Common.Python.Interfaces.SSHConnection  WITH NAME  SSH
Library     testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Applications

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown     Common Test Teardown


*** Variables ***
# This will be seen before every application in test run f.ex. Crash of critical application bm
${CASE_NAME}            all tx stuff
# Fault to be caused to tx can be f.ex. 1904, 1907...
${FAULT}         1907
${FAULT_TWO}     1912
# Fault name can be legacy or category alarms name. If FAULT_NAME is legacy type, it is checked from commissioning if
# name needs to be changed to category alarms style.
${FAULT_NAME}    RF Module failure
# Max time to wait for cells to be up and running, currently mandatory to be given as integer, later also string will be suitable
${WAIT_FOR_CELLS_UP}    ${600}
# Can have values: RX1-RX8, TX1-TX8, LTX, All_TX or All_RX
${RESOURCE}        All_TX
${RESOURCE_TWO}    LTX
${RMOD}            RMOD-1
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
${WAIT_CHECKS}          30    # seconds, 0 if no waiting nor printing before post conditions check
# Collect logs variable. POssible values are: On failure/Never/Always
${COLLECT_LOGS}         On failure
# How many times test will be run, needs to be more than 0
${TEST_LOOPS}           1
${USER_GIVEN_TIME}       10min
# Time to wait after maintenance window has been activated for a recovery reset to occur
${WAIT_FOR_MW_ALARM}     300
${WAIT_FOR_RECO_COUNTER_CLEAR}    360
&{COMMISSIONING_PARAMETERS}   actForceAutoReset=false
                        ...   actForceUnitAutoReset=false
                        ...   enforcedRecovTimeWindow=Enforced recovery disabled

*** Test Cases ***
Recovery during MW for RMOD All TX
    Sleep  1s
    [Timeout]    24h
    [Documentation]  Recovery during MW for RMOD All TX
    [Tags]    "Recovery during MW for RMOD All TX" -test loops: ${TEST_LOOPS}
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...  ${WAIT_FOR_CELLS_UP}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${FAULT}  ${RMOD}  ${RESOURCE}
        ...  ${WAIT}    ${FAULT_NAME}  ${USER_GIVEN_TIME}  ${WAIT_FOR_RECO_COUNTER_CLEAR}
        ...  name=${CASE_NAME}
        ...  test_case=1
        ...  loops=${TEST_LOOPS}
        ...  keywords=Recovery During MW for RMOD All Tx
        ...  expected_pass_rate=1
        ...  collect_test_logs=${COLLECT_LOGS}

Recovery during MW for RMOD LTX
    Sleep  1s
    [Timeout]    24h
    [Documentation]  Recovery during MW for RMOD LTX
    [Tags]    "Recovery during MW for RMOD LTX" -test loops: ${TEST_LOOPS}
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...  ${WAIT_FOR_CELLS_UP}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${FAULT_TWO}  ${RMOD}  ${RESOURCE_TWO}
        ...  ${WAIT}  ${FAULT_NAME}  ${USER_GIVEN_TIME}
        ...  name=${CASE_NAME}
        ...  test_case=1
        ...  loops=${TEST_LOOPS}
        ...  keywords=Recovery during MW for RMOD LTX
        ...  expected_pass_rate=1
        ...  collect_test_logs=${COLLECT_LOGS}

# Additional fault tests
Recovery during MW for RMOD All TX With Additional Fault
    [Documentation]  Recovery during MW for RMOD All TX With Additional Fault
    [Timeout]    24h
    [Tags]    "Recovery during MW for RMOD All TX" -test loops: ${TEST_LOOPS}
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  480  ${SYSLOG_LIST}  ${COMMISSIONING_PARAMETERS}
        ...    name=Create delta file re-commissioning
        ...    test_case=Pre
        ...    loops=1
        ...    keywords=Do commissioning with delta file
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
    Sleep  1s
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...  ${WAIT_FOR_CELLS_UP}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${FAULT}  ${RMOD}  ${RESOURCE}
        ...  ${WAIT}    ${FAULT_NAME}  ${USER_GIVEN_TIME}  ${WAIT_FOR_RECO_COUNTER_CLEAR}
        ...  name=${CASE_NAME}
        ...  test_case=1
        ...  loops=${TEST_LOOPS}
        ...  keywords=Recovery During MW for RMOD All Tx With Additional Fault
        ...  expected_pass_rate=1
        ...  collect_test_logs=${COLLECT_LOGS}

Recovery during MW for RMOD LTX With Additional Fault
    [Timeout]    24h
    [Documentation]  Recovery During MW For RMOD LTX With Additional Fault
    [Tags]    "Recovery during MW for RMOD LTX" -test loops: ${TEST_LOOPS}
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  480  ${SYSLOG_LIST}  ${COMMISSIONING_PARAMETERS}
        ...    name=Create delta file re-commissioning
        ...    test_case=Pre
        ...    loops=1
        ...    keywords=Do commissioning with delta file
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
    Sleep  1s
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...  ${WAIT_FOR_CELLS_UP}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${FAULT_TWO}  ${RMOD}  ${RESOURCE_TWO}
        ...  ${WAIT}  ${FAULT_NAME}  ${USER_GIVEN_TIME}
        ...  name=${CASE_NAME}
        ...  test_case=1
        ...  loops=${TEST_LOOPS}
        ...  keywords=Recovery during MW for RMOD LTX With Additional Fault
        ...  expected_pass_rate=1
        ...  collect_test_logs=${COLLECT_LOGS}
