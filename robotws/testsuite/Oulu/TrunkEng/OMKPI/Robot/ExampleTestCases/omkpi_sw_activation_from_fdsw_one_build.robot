*** Settings ***
Documentation
...  Author:   Terhi Talvitie
...  Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com
...   In this suite there are three test cases:
...   1. Test Case is 'SW Activation from FDSW to T1' updates T1 SW onto FDSW and check KPIs.
...   2. Test Case is 'SW Activation from FDSW to T2' updates T2 SW onto FDSW and check KPIs.
...   3. Test Case is 'SW Activation from FDSW to Normal' updates normal SW onto FDSW and check KPIs.
...   As a default, if this suite is run, all packages (T1, T2 and normal) will be downloaded, all as own tests.
...   For singlerun, you can select one or more Test Cases from the drop down menu.
...   For local test, use these if you want test a single package:
...   -t "SW Activation from FDSW to T1"
...   -t "SW Activation from FDSW to T2"
...   -t "SW Activation from FDSW to Normal"

Resource     testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource     testsuite/Oulu/TrunkEng/OMKPI/Robot/TestKeywords/omkpi_sw_activation_from_fdsw.robot
Variables    testsuite/Oulu/TrunkEng/OMKPI/Robot/Targets/omkpi_targets_example.py

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown     Common Test Teardown

*** Variables ***
# time to wait for RC connection
${WAIT_RC_CONNECTION}    300
${WAIT_CHECKS}           300
${WAIT_FOR_CELLS_UP}     600
${ALLOWED_ALARMS_FILE}   /home/ute/MN/UTE/robotws/testsuite/Oulu/TrunkEng/OMKPI/allowed_alarms.txt
# Syslog prints that will be printed to eventlog when found from the syslog, will not fail the test if found/not found
@{SYSLOG_LIST}           ResetCounter  Detected most recent reset type  Failed to execute executable  RecoveryConstraints
...                      Executing recovery action  RecoveryActionController
@{UNALLOWED_SYSLOGS}     4 (ERPresetTypeSpuriousReset)    14 (ERPresetTypeSpuriousResetBts)
# Collect logs variable. Possible values are: On failure/Never/Always
${COLLECT_LOGS}          On failure
# How many times test will be run, needs to be more than 0
${TEST_LOOPS}            1


*** Test Cases ***
SW Activation from FDSW to T1
    [Documentation]   Do configuration reset that activates FDSW. Install T1 software from RescueConsole. Calculate KPIs.
    [Tags]    "SW Activation from FDSW to T1" -test loops: ${TEST_LOOPS}
    Set Suite Variable  ${ONE_BUILD}  T1
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
     ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${WAIT_RC_CONNECTION}   ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}
     ...    name=SW Activation From FDSW One Build
     ...    test_case=1
     ...    loops=${TEST_LOOPS}
     ...    keywords=SW Activation From FDSW One Build
     ...    expected_pass_rate=1
     ...    collect_test_logs=${COLLECT_LOGS}
     ...    omkpi_case=${True}

SW Activation from FDSW to T2
    [Documentation]   Do configuration reset that activates FDSW. Install T2 software from RescueConsole. Calculate KPIs.
    [Tags]    "SW Activation from FDSW to T2" -test loops: ${TEST_LOOPS}
    Set Suite Variable  ${ONE_BUILD}  T2
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
     ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${WAIT_RC_CONNECTION}   ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}
     ...    name=SW Activation From FDSW One Build
     ...    test_case=1
     ...    loops=${TEST_LOOPS}
     ...    keywords=SW Activation From FDSW One Build
     ...    expected_pass_rate=1
     ...    collect_test_logs=${COLLECT_LOGS}
     ...    omkpi_case=${True}

SW Activation from FDSW to Normal
    [Documentation]   Do configuration reset that activates FDSW. Install Normal software from RescueConsole. Calculate KPIs.
    [Tags]    "SW Activation from FDSW to Normal" -test loops: ${TEST_LOOPS}
    Set Suite Variable  ${ONE_BUILD}  Normal
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
     ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${WAIT_RC_CONNECTION}   ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}
     ...    name=SW Activation From FDSW One Build
     ...    test_case=1
     ...    loops=${TEST_LOOPS}
     ...    keywords=SW Activation From FDSW One Build
     ...    expected_pass_rate=1
     ...    collect_test_logs=${COLLECT_LOGS}
     ...    omkpi_case=${True}
