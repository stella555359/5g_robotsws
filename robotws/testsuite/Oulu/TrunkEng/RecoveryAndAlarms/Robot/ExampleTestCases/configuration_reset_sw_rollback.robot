*** Settings ***
Documentation
...  Author:   Terhi Talvitie
...  Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Library      taf.fdsw.rc  WITH NAME  RC

Resource     testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
# Resource     testsuite/Oulu/TrunkEng/RecoveryAndAlarms/Robot/TestKeywords/failsafe_boot_ute.robot
Resource     testsuite/Oulu/TrunkEng/RecoveryAndAlarms/Robot/TestKeywords/configuration_reset_sw_rollback.robot

# Library      testsuite.Oulu.TrunkEng.RecoveryAndAlarms.Python.Interfaces.FDSW  WITH NAME  FDSW
# Library      testsuite.Oulu.TrunkEng.RecoveryAndAlarms.Python.Interfaces.RescueConsole

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown     Common Test Teardown

*** Variables ***
@{UNALLOWED_SYSLOGS}    ERPresetTypeSpuriousReset
# time to wait for RC connection, FDSW22B1 -> logs are collected on SSD befor rese -> wait time increased from 3min -> 10min
${WAIT_RC_CONNECTION}    600
${WAIT}                  300
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
Configuration Reset SW Rollback
    [Documentation]   Do configuration reset, collect logs from RescueConsole (this can be enabled by adding
    ...               RESCUE_CONSOLE_LOGS variable to the test) and go back to previous SW.
    [Tags]    "Configuration Reset SW Rollback" -test loops: ${TEST_LOOPS}
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
     ...    ${WAIT}  ${SYSLOG_LIST}  ${WAIT_RC_CONNECTION}  ${ALLOWED_RC_ALARM}  ${UNALLOWED_SYSLOGS}
     ...    name=Configuration reset rollback
     ...    test_case=1
     ...    loops=${TEST_LOOPS}
     ...    keywords=Configuration Reset SW Rollback
     ...    expected_pass_rate=1
     ...    collect_test_logs=${COLLECT_LOGS}
