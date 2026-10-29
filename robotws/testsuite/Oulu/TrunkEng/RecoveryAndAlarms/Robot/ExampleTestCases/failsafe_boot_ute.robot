*** Settings ***
Documentation
...  Author:   Terhi Talvitie
...  Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Library      taf.fdsw.rc  WITH NAME  RC

Resource     testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource     testsuite/Oulu/TrunkEng/RecoveryAndAlarms/Robot/TestKeywords/failsafe_boot_ute.robot

Library      testsuite.Oulu.TrunkEng.RecoveryAndAlarms.Python.Interfaces.FDSW  WITH NAME  FDSW
Library      testsuite.Oulu.TrunkEng.RecoveryAndAlarms.Python.Interfaces.RescueConsole

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown     Common Test Teardown

*** Variables ***
${UNALLOWED_SYSLOGS}
# time to wait for RC connection, FDSW22B1 -> logs are collected on SSD befor rese -> wait time increased from 3min -> 10min
${WAIT_RC_CONNECTION}    600
${WAIT}                  300
&{EXPECTED_ALARM}        fault_id=${4082}  text=SW fallback   number=${7651}
&{ALLOWED_RC_ALARM}      fault_id=${61648}  text=LMP connectivity detected   number=${7665}
...                      fault_id2=${61675}  number2=${7665}
...                      text2=WiFi Configuration Issue: Wifi disabled due to Wifi factory default configuration retrieving failed
${ALLOWED_ALARMS_FILE}   /home/ute/MN/UTE/robotws/testsuite/Oulu/TrunkEng/RecoveryAndAlarms/allowed_alarms.txt
# Syslog prints that will be printed to eventlog when found from the syslog, will not fail the test if found/not found
@{SYSLOG_LIST}           ResetCounter  Detected most recent reset type  Failed to execute executable  RecoveryConstraints
...                      Executing recovery action  RecoveryActionController
# Collect logs variable. POssible values are: On failure/Never/Always
${COLLECT_LOGS}          On failure
# How many times test will be run, needs to be more than 0
${TEST_LOOPS}            1


*** Test Cases ***
Long Press
    [Documentation]   Make long service button press, collect logs from RescueConsole (this can be enabled by adding
    ...    RESCUE_CONSOLE_LOGS variable to the test) and go back to previous SW.
    [Tags]    "Long Press" -test loops: ${TEST_LOOPS}
    ${UNIT}=    Get Master SMOD ProductName
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
     ...    ${WAIT}  ${SYSLOG_LIST}  ${WAIT_RC_CONNECTION}    ${ALLOWED_RC_ALARM}    ${UNIT}
     ...    name=Long Press
     ...    test_case=1
     ...    loops=${TEST_LOOPS}
     ...    keywords=Long Press
     ...    expected_pass_rate=1
     ...    collect_test_logs=${COLLECT_LOGS}

Short Press
    [Documentation]   Make short service button press, collect logs from RescueConsole (this can be enabled by adding
    ...    RESCUE_CONSOLE_LOGS variable to the test) and go back to previous SW.
    [Tags]    "Short Press" -test loops: ${TEST_LOOPS}
    ${UNIT}=    Get Master SMOD ProductName
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
     ...    ${WAIT}  ${SYSLOG_LIST}    ${WAIT_RC_CONNECTION}    ${ALLOWED_RC_ALARM}    ${UNIT}
     ...    name=Short Press
     ...    test_case=1
     ...    loops=${TEST_LOOPS}
     ...    keywords=Short Press
     ...    expected_pass_rate=1
     ...    collect_test_logs=${COLLECT_LOGS}

Short Press And New SW
    [Documentation]   Make short service button press, collect logs from RescueConsole (this can be enabled by adding
    ...    RESCUE_CONSOLE_LOGS variable to the test), upload and activate new SW and perform commissioning with scf file.
    [Tags]    "Short Press And New SW" -test loops: ${TEST_LOOPS}
    ${UNIT}=    Get Master SMOD ProductName
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
     ...    ${WAIT}  ${SYSLOG_LIST}    ${WAIT_RC_CONNECTION}    ${ALLOWED_RC_ALARM}    ${UNIT}
     ...    name=Short Press And New SW
     ...    test_case=1
     ...    loops=${TEST_LOOPS}
     ...    keywords=Short Press And New SW
     ...    expected_pass_rate=1
     ...    collect_test_logs=${COLLECT_LOGS}

Sw Fallback
    [Documentation]   Corrupt software from fs1 and fs2 and reboot, check that correct alarm 4082 'SW fallback due to
    ...    max number of recovery resets' is reported, collect logs from RescueConsole (this can be disabled by setting
    ...    RESCUE_CONSOLE_LOGS suite variable to False), upload and activate new SW and perform commissioning with scf file.
    [Tags]    "Sw Fallback" -test loops: ${TEST_LOOPS}
# Check if RESCUE_CONSOLE_LOGS variable is set from commandline or by environment reservation TAG before setting it to True
    Run Keyword And Continue On Failure  Check If Rescue Console Logs Variable Is Set  set_the_variable_to_true=${True}
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT}   ${EXPECTED_ALARM}   ${SYSLOG_LIST}    ${WAIT_RC_CONNECTION}    ${ALLOWED_RC_ALARM}
        ...    name=Sw Fallback
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
		...    keywords=Sw Fallback
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
