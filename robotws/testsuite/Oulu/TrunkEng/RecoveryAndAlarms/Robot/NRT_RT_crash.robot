*** Settings ***
Documentation
...   Author:   Mirka Kyllonen
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource    testsuite/Oulu/TrunkEng/RecoveryAndAlarms/Robot/TestKeywords/kill_applications_reset.robot
Resource    testsuite/Oulu/TrunkEng/RecoveryAndAlarms/Robot/TestKeywords/bbmod_soc_test_kws.robot

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
${CASE_NAME}            Crash of RT/NRT application
# Max time to wait for cells to be up and running, currently mandatory to be given as integer, later also string will be suitable
${WAIT_FOR_CELLS_UP}    ${600}
# Wait after test and site reset, value can be given as string.
${WAIT_FOR_RECO_COUNTER_CLEAR}    360
# Time for wait alarm
${WAIT_FOR_ALARM}   300
# to list below you can add prints that will fail the test if they are found from syslog
@{UNALLOWED_SYSLOGS}    14 (ERPresetTypeSpuriousResetBts)  19 (ERPresetTypeCold)
# Prints that are monitored from syslog to eventlog
@{SYSLOG_LIST}          Detected most recent reset type    Failed to execute executable
                        ...    Executing recovery action  Set alarm  Reset count
                        ...    Please contact the owner of  FAULT_SIGNATURE  AlarmFaultSignature
# Suite Variable that's value is changed in Test Cases
${UNIT}
${SOC}
${APPLICATION}
# Path to allowed alarms file
${ALLOWED_ALARMS_FILE}  /home/ute/MN/UTE/robotws/testsuite/Oulu/TrunkEng/RecoveryAndAlarms/allowed_alarms.txt
# Collect logs variable. Possible values are: On failure/Never/Always
${COLLECT_LOGS}         Always
# How many times test will be run, needs to be more than 0
${TEST_LOOPS}           1


*** Test Cases ***
ABIP1_Thor_RT
    [Documentation]  Crash RT application
    [Tags]  "Crash RT application" -test loops: ${TEST_LOOPS}
    Set Suite Variable   ${UNIT}           ABIP1
    Set Suite Variable   ${SOC}            Thor
    Set Suite Variable   ${APPLICATION}    l1_application_rt
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_ALARM}  ${APPLICATION}  ${UNIT}  ${SOC}  ${SYSLOG_LIST}
        ...    ${WAIT_FOR_RECO_COUNTER_CLEAR}
        ...    name=${CASE_NAME} ${UNIT} ${SOC}
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Kill application from secondary SoC and expect only SoC reset
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

ABIP1_Thor_NRT
    [Documentation]  Crash RT application
    [Tags]  "Crash RT application" -test loops: ${TEST_LOOPS}
    Set Suite Variable   ${UNIT}           ABIP1
    Set Suite Variable   ${SOC}            Thor
    Set Suite Variable   ${APPLICATION}    l1_application_nrt
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_ALARM}  ${APPLICATION}  ${UNIT}  ${SOC}  ${SYSLOG_LIST}
        ...    ${WAIT_FOR_RECO_COUNTER_CLEAR}
        ...    name=${CASE_NAME} ${UNIT} ${SOC}
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Kill application from secondary SoC and expect only SoC reset
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

ABIN1_Loki_RT
    [Documentation]  Crash RT application
    [Tags]  "Crash RT application" -test loops: ${TEST_LOOPS}
    Set Suite Variable   ${UNIT}           ABIN1
    Set Suite Variable   ${SOC}            LOKI#A
    Set Suite Variable   ${APPLICATION}    l1_application_rt
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_ALARM}  ${APPLICATION}  ${UNIT}  ${SOC}  ${SYSLOG_LIST}
        ...    ${WAIT_FOR_RECO_COUNTER_CLEAR}
        ...    name=${CASE_NAME} ${UNIT} ${SOC}
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Kill application from secondary SoC and expect only SoC reset
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

ABIN1_Loki_NRT
    [Documentation]  Crash RT application
    [Tags]  "Crash RT application" -test loops: ${TEST_LOOPS}
    Set Suite Variable   ${UNIT}           ABIN1
    Set Suite Variable   ${SOC}            LOKI#A
    Set Suite Variable   ${APPLICATION}    l1_application_nrt
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_ALARM}  ${APPLICATION}  ${UNIT}  ${SOC}  ${SYSLOG_LIST}
        ...    ${WAIT_FOR_RECO_COUNTER_CLEAR}
        ...    name=${CASE_NAME} ${UNIT} ${SOC}
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Kill application from secondary SoC and expect only SoC reset
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

ABIO1_Loki_RT
    [Documentation]  Crash RT application
    [Tags]  "Crash RT application" -test loops: ${TEST_LOOPS}
    Set Suite Variable   ${UNIT}           ABIO1
    Set Suite Variable   ${SOC}            LOKI#A
    Set Suite Variable   ${APPLICATION}    l1_application_rt
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_ALARM}  ${APPLICATION}  ${UNIT}  ${SOC}  ${SYSLOG_LIST}
        ...    ${WAIT_FOR_RECO_COUNTER_CLEAR}
        ...    name=${CASE_NAME} ${UNIT} ${SOC}
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Kill application from secondary SoC and expect only SoC reset
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

ABIO1_Loki_NRT
    [Documentation]  Crash RT application
    [Tags]  "Crash RT application" -test loops: ${TEST_LOOPS}
    Set Suite Variable   ${UNIT}           ABIO1
    Set Suite Variable   ${SOC}            LOKI#A
    Set Suite Variable   ${APPLICATION}    l1_application_nrt
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_ALARM}  ${APPLICATION}  ${UNIT}  ${SOC}  ${SYSLOG_LIST}
        ...    ${WAIT_FOR_RECO_COUNTER_CLEAR}
        ...    name=${CASE_NAME} ${UNIT} ${SOC}
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Kill application from secondary SoC and expect only SoC reset
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
