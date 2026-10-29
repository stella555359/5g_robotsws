*** Settings ***
Documentation
...   Author:   Mirka Kyllonen
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource    testsuite/Oulu/TrunkEng/RecoveryAndAlarms/Robot/TestKeywords/SMOD_SoC_crash.robot

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
# Max time to wait for cells to be up and running, currently mandatory to be given as integer, later also string will be suitable
${WAIT_FOR_CELLS_UP}    ${600}
# Time for wait alarm
${WAIT_FOR_ALARM}   600
# Waits (in seconds) after fault is generated
${WAIT_FOR_DISCONNECT}  300
${WAIT_FOR_RECONNECT}   120
# to list below you can add prints that will fail the test if they are found from syslog
@{UNALLOWED_SYSLOGS}    14 (ERPresetTypeSpuriousResetBts)
# Prints that are monitored from syslog to eventlog
@{SYSLOG_LIST}          Detected most recent reset type    Failed to execute executable
                        ...    Executing recovery action  Set alarm  Reset count
                        ...    Please contact the owner of  FAULT_SIGNATURE  AlarmFaultSignature
# Suite Variable that's value is changed in Test Cases
${APPLICATION}
${SMOD}                 SMOD1
# Path to allowed alarms file
${ALLOWED_ALARMS_FILE}  /home/ute/MN/UTE/robotws/testsuite/Oulu/TrunkEng/RecoveryAndAlarms/allowed_alarms.txt
# Collect logs variable. Possible values are: On failure/Never/Always
${COLLECT_LOGS}         Always
# How many times test will be run, needs to be more than 0
${TEST_LOOPS}           1
${STEP}                 1


*** Test Cases ***
SMOD Thor Interface SOC NRT Application Crash
    [Documentation]  Crash the interface SoC from SMOD (ASOE, ASOH, ASOG).
    Set Suite Variable   ${APPLICATION}    l1_application_nrt
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${STEP}  ${SMOD}  l1_application_nrt  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_ALARM}  ${False}  ${False}
        ...    name=Crash interface SoC from SMOD by killing l1_application_nrt
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Crash interface SoC from SMOD
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

SMOD Thor Interface SOC RT Application Crash
    [Documentation]  Crash the interface SoC from SMOD (ASOE, ASOH, ASOG).
    Set Suite Variable   ${APPLICATION}    l1_application_rt
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${STEP}  ${SMOD}  l1_application_rt  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_ALARM}  ${False}  ${False}
        ...    name=Crash interface SoC from SMOD by killing l1_application_rt
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Crash interface SoC from SMOD
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

