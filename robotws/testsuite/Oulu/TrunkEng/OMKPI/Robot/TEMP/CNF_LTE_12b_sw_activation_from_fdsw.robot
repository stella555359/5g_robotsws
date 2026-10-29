*** Settings ***
Documentation
...  Author:   Heikki Auio
...  Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Resource     testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource     testsuite/Oulu/TrunkEng/OMKPI/Robot/TestKeywords/omkpi_sw_activation_from_fdsw.robot
Variables    testsuite/Oulu/TrunkEng/OMKPI/Robot/Targets/CNF_LTE_12_omkpi_targets.py

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown     Common Test Teardown

*** Variables ***
${UNALLOWED_SYSLOGS}
# time to wait for RC connection
${WAIT_RC_CONNECTION}    300
${WAIT_CHECKS}           300
${WAIT_FOR_CELLS_UP}     900
${ALLOWED_ALARMS_FILE}   /home/ute/MN/UTE/robotws/testsuite/Oulu/TrunkEng/OMKPI/allowed_alarms.txt
# Syslog prints that will be printed to eventlog when found from the syslog, will not fail the test if found/not found
@{SYSLOG_LIST}
# Collect logs variable. Possible values are: On failure/Never/Always
${COLLECT_LOGS}          Always
# How many times test will be run, needs to be more than 0
${TEST_LOOPS}            3


*** Test Cases ***
SW Activation from FDSW
    [Documentation]   Do configuration reset that activates FDSW. Install T1 (or T2 if T1 was in passive side) software
    ...               from RescueConsole. Do commissioning. Calculate KPIs. Do RU SWDL. Check post conditions. Then do
    ...               configuration reset that activates FDSW. Install T2 (or T1 if T2 was in passive side) software from RC.
    ...               Do commissioning. Calculate KPIs. Do RU SWDL. Check post conditions. Then do configuration reset that activates FDSW.
    ...               Install Normal software from RC. Do commissioning. Calculate KPIs. Do RU SWDL. Check post conditions.
    [Tags]    "SW Activation from FDSW" -test loops: ${TEST_LOOPS}
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
     ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${WAIT_RC_CONNECTION}   ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}
     ...    name=SW Activation From FDSW
     ...    test_case=1
     ...    loops=${TEST_LOOPS}
     ...    keywords=SW Activation From FDSW
     ...    expected_pass_rate=1
     ...    collect_test_logs=${COLLECT_LOGS}
     ...    omkpi_case=${True}
