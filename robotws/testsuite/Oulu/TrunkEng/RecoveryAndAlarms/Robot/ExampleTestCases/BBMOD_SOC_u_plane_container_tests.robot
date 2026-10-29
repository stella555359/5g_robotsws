*** Settings ***
Documentation
...   Author:   Terhi Talvitie/Sirpa Passoja
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource    testsuite/Oulu/TrunkEng/RecoveryAndAlarms/Robot/TestKeywords/bbmod_soc_test_kws.robot

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown     Common Test Teardown


*** Variables ***
# Max time to wait for cells to be up and running, currently mandatory to be given as integer, later also string will be suitable
${WAIT_FOR_CELLS_UP}    ${300}
# Wait before post conditions check
${WAIT}                 30
# Time for wait alarm when alarm activated, needs to be long so 10 alarm have time to be raised
${WAIT_FOR_ALARM}       300
# Suite Variable that's value is changed in Test Cases
${UNIT}                 BBMOD1
${SOC}
${COMMAND}              pkill -SIGABRT L2CounterClien
# U-plane container
${CONTAINER}            0x1730
# Prints that are monitored from syslog to eventlog
@{SYSLOG_LIST}          ResetCounter  Detected most recent reset type    Failed to execute executable
                        ...    Executing recovery action  RecoveryActionController  Set alarm  Reset count
                        ...    Please contact the owner of   RESET, DDAL_HOTPLUG_EVT_RIO_REMOVE received device_id
# Path to allowed alarms file
${ALLOWED_ALARMS_FILE}  /home/ute/MN/UTE/robotws/testsuite/Oulu/TrunkEng/RecoveryAndAlarms/allowed_alarms.txt
# Collect logs variable. Possible values are: On failure/Never/Always
${COLLECT_LOGS}         Always
# How many times test will be run, needs to be more than 0
${TEST_LOOPS}           1

*** Test Cases ***
BBMOD1 Application L2CounterClien from container crash
    [Documentation]  Give command ${COMMAND} to container ${CONTAINER} of primary soc of ${UNIT}
    [Tags]  "BBMOD1 ${CONTAINER} Application crash (l2CounterClient)" -test loops: ${TEST_LOOPS}
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_ALARM}  ${WAIT}  ${UNIT}  ${SOC}  ${CONTAINER}  ${COMMAND}  ${SYSLOG_LIST}
        ...    name=${UNIT} crash application from container ${CONTAINER}
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Command To Container Of Bbmod Soc
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

BBMOD1 Application Disp_0 from container crash
    Set Suite Variable  ${COMMAND}     pkill -SIGABRT Disp_0
    [Documentation]  Give command ${COMMAND} to container ${CONTAINER} of primary soc of ${UNIT}
    [Tags]  "BBMOD1 ${CONTAINER} Application crash (l2CounterClient)" -test loops: ${TEST_LOOPS}
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_ALARM}  ${WAIT}  ${UNIT}  ${SOC}  ${CONTAINER}  ${COMMAND}  ${SYSLOG_LIST}
        ...    name=${UNIT} crash application from container ${CONTAINER}
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Command To Container Of Bbmod Soc
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

BBMOD1 Application CCSRTDaemonExe from container crash
    Set Suite Variable  ${COMMAND}     pkill -SIGABRT CCSRTDaemonExe
    [Documentation]  Give command ${COMMAND} to container ${CONTAINER} of primary soc of ${UNIT}
    [Tags]  "BBMOD1 ${CONTAINER} Application crash (l2CounterClient)" -test loops: ${TEST_LOOPS}
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_ALARM}  ${WAIT}  ${UNIT}  ${SOC}  ${CONTAINER}  ${COMMAND}  ${SYSLOG_LIST}
        ...    name=${UNIT} crash application from container ${CONTAINER}
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Command To Container Of Bbmod Soc
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

BBMOD1 Application Disp_0 for thread mode
    Set Suite Variable  ${CONTAINER}   0x1731
    Set Suite Variable  ${COMMAND}     pkill -SIGABRT Disp_0
    [Documentation]  Give command '${COMMAND}' to container ${CONTAINER} of primary soc of ${UNIT}
    [Tags]  "BBMOD1 ${CONTAINER} main dispatcher crash" -test loops: ${TEST_LOOPS}
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_ALARM}  ${WAIT}  ${UNIT}  ${SOC}  ${CONTAINER}  ${COMMAND}  ${SYSLOG_LIST}
        ...    name=${UNIT} ${CONTAINER} main dispatcher crash
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Command To Container Of Bbmod Soc
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

BBMOD1 Application RTHWAPIDaemon for thread mode
    Set Suite Variable  ${CONTAINER}   0x1731
    Set Suite Variable  ${COMMAND}     pkill -SIGABRT RTHWAPIDaemon
    [Documentation]  Give command '${COMMAND}' to container ${CONTAINER} of primary soc of ${UNIT}
    [Tags]  "BBMOD1 ${CONTAINER} main dispatcher crash" -test loops: ${TEST_LOOPS}
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_ALARM}  ${WAIT}  ${UNIT}  ${SOC}  ${CONTAINER}  ${COMMAND}  ${SYSLOG_LIST}
        ...    name=${UNIT} ${CONTAINER} main dispatcher crash
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Command To Container Of Bbmod Soc
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

BBMOD1 Application CCSRTDaemonExe for thread mode
    Set Suite Variable  ${CONTAINER}   0x1731
    Set Suite Variable  ${COMMAND}     pkill -SIGABRT CCSRTDaemonExe
    [Documentation]  Give command '${COMMAND}' to container ${CONTAINER} of primary soc of ${UNIT}
    [Tags]  "BBMOD1 ${CONTAINER} main dispatcher crash" -test loops: ${TEST_LOOPS}
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_ALARM}  ${WAIT}  ${UNIT}  ${SOC}  ${CONTAINER}  ${COMMAND}  ${SYSLOG_LIST}
        ...    name=${UNIT} ${CONTAINER} main dispatcher crash
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Command To Container Of Bbmod Soc
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
