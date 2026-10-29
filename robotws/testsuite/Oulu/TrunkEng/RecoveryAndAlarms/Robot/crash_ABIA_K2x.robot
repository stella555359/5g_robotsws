*** Settings ***
Documentation
...   Author:   Mirka Kyllonen
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource    testsuite/Oulu/TrunkEng/RecoveryAndAlarms/Robot/TestKeywords/kill_applications_reset.robot
Resource    testsuite/Oulu/TrunkEng/RecoveryAndAlarms/Robot/TestKeywords/bbmod_soc_test_kws.robot
Resource    testsuite/Oulu/TrunkEng/Common/Robot/TestKeywords/change_commissioning_parameters.robot

Library     testsuite.Oulu.TrunkEng.Common.Python.Interfaces.FspIP  WITH NAME  FSP
Library     testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Applications

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown     Common Test Teardown


*** Variables ***
# This will be seen before every application in test run f.ex. Crash of critical application bm
${CASE_NAME}            Crash in ABIA Keppler
# Max time to wait for cells to be up and running, also string is suitable. Max wait time increased from 600s to 1800s
${WAIT_FOR_CELLS_UP}    ${1800}
# Wait after test and site reset, value can be given as string.
${WAIT_FOR_RECO_COUNTER_CLEAR}    360
# Time for wait alarm
${WAIT_FOR_ALARM}   300
# Suite Variable that's value is changed in Test Cases
${UNIT}
${SOC}
# Application which is killed from K2x
${APPLICATION}  FaultServiceExe
# Prints that are monitored from syslog to eventlog
@{SYSLOG_LIST}          Detected most recent reset type    Failed to execute executable
                        ...    Executing recovery action  Set alarm  Reset count
                        ...    Please contact the owner of  FAULT_SIGNATURE  AlarmFaultSignature
# Path to allowed alarms file
${ALLOWED_ALARMS_FILE}  /home/ute/MN/UTE/robotws/testsuite/Oulu/TrunkEng/RecoveryAndAlarms/allowed_alarms.txt
# Collect logs variable. Possible values are: On failure/Never/Always
${COLLECT_LOGS}         On failure
# How many times test will be run, needs to be more than 0
${TEST_LOOPS}           3


*** Test Cases ***
Crash FaultServiceExe from ABIA1 K2A
    Sleep  1s
    [Timeout]    24h
    [Documentation]  Kill FaultServiceExe from ABIA1 K2A
    [Tags]  "ABIA1 K2A Faultcase" -test loops: ${TEST_LOOPS}
    Set Suite Variable   ${UNIT}   ABIA1
    Set Suite Variable   ${SOC}   K2A
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_ALARM}  ${APPLICATION}  ${UNIT}  ${SOC}  ${SYSLOG_LIST}
        ...    ${WAIT_FOR_RECO_COUNTER_CLEAR}
        ...    name=${CASE_NAME} ${UNIT} ${SOC}
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Kill application from primary SoC and expect BBMOD reset
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

Crash FaultServiceExe from ABIA2 K2A
    Sleep  1s
    [Timeout]    24h
    [Documentation]  Kill FaultServiceExe from ABIA2 K2A
    [Tags]  "ABIA2 K2A Faultcase" -test loops: ${TEST_LOOPS}
    Set Suite Variable   ${UNIT}   ABIA2
    Set Suite Variable   ${SOC}   K2A
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_ALARM}  ${APPLICATION}  ${UNIT}  ${SOC}  ${SYSLOG_LIST}
        ...    ${WAIT_FOR_RECO_COUNTER_CLEAR}
        ...    name=${CASE_NAME} ${UNIT} ${SOC}
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Kill application from primary SoC and expect BBMOD reset
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

Crash FaultServiceExe from ABIA3 K2A
    Sleep  1s
    [Timeout]    24h
    [Documentation]  Kill FaultServiceExe from ABIA3 K2A
    [Tags]  "ABIA3 K2A Faultcase" -test loops: ${TEST_LOOPS}
    Set Suite Variable   ${UNIT}   ABIA3
    Set Suite Variable   ${SOC}   K2A
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_ALARM}  ${APPLICATION}  ${UNIT}  ${SOC}  ${SYSLOG_LIST}
        ...    ${WAIT_FOR_RECO_COUNTER_CLEAR}
        ...    name=${CASE_NAME} ${UNIT} ${SOC}
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Kill application from primary SoC and expect BBMOD reset
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

Crash FaultServiceExe from ABIA1 K2B
    Sleep  1s
    [Timeout]    24h
    [Documentation]  Kill FaultServiceExe from ABIA1 K2B
    [Tags]  "ABIA1 K2B Faultcase" -test loops: ${TEST_LOOPS}
    Set Suite Variable   ${UNIT}   ABIA1
    Set Suite Variable   ${SOC}   K2B
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_ALARM}  ${APPLICATION}  ${UNIT}  ${SOC}  ${SYSLOG_LIST}
        ...    ${WAIT_FOR_RECO_COUNTER_CLEAR}
        ...    name=${CASE_NAME} ${UNIT} ${SOC}
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Kill application from secondary SoC and expect SoC reset
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

Crash FaultServiceExe from ABIA2 K2B
    Sleep  1s
    [Timeout]    24h
    [Documentation]  Kill FaultServiceExe from ABIA2 K2B
    [Tags]  "ABIA2 K2B Faultcase" -test loops: ${TEST_LOOPS}
    Set Suite Variable   ${UNIT}   ABIA2
    Set Suite Variable   ${SOC}   K2B
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_ALARM}  ${APPLICATION}  ${UNIT}  ${SOC}  ${SYSLOG_LIST}
        ...    ${WAIT_FOR_RECO_COUNTER_CLEAR}
        ...    name=${CASE_NAME} ${UNIT} ${SOC}
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Kill application from secondary SoC and expect SoC reset
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

Crash FaultServiceExe from ABIA3 K2B
    Sleep  1s
    [Timeout]    24h
    [Documentation]  Kill FaultServiceExe from ABIA3 K2B
    [Tags]  "ABIA3 K2B Faultcase" -test loops: ${TEST_LOOPS}
    Set Suite Variable   ${UNIT}   ABIA3
    Set Suite Variable   ${SOC}   K2B
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_ALARM}  ${APPLICATION}  ${UNIT}  ${SOC}  ${SYSLOG_LIST}
        ...    ${WAIT_FOR_RECO_COUNTER_CLEAR}
        ...    name=${CASE_NAME} ${UNIT} ${SOC}
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Kill application from secondary SoC and expect SoC reset
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

Crash FaultServiceExe from ABIA1 K2C
    Sleep  1s
    [Timeout]    24h
    [Documentation]  Kill FaultServiceExe from ABIA1 K2C
    [Tags]  "ABIA1 K2C Faultcase" -test loops: ${TEST_LOOPS}
    Set Suite Variable   ${UNIT}   ABIA1
    Set Suite Variable   ${SOC}   K2C
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_ALARM}  ${APPLICATION}  ${UNIT}  ${SOC}  ${SYSLOG_LIST}
        ...    ${WAIT_FOR_RECO_COUNTER_CLEAR}
        ...    name=${CASE_NAME} ${UNIT} ${SOC}
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Kill application from secondary SoC and expect SoC reset
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

Crash FaultServiceExe from ABIA2 K2C
    Sleep  1s
    [Timeout]    24h
    [Documentation]  Kill FaultServiceExe from ABIA2 K2C
    [Tags]  "ABIA2 K2C Faultcase" -test loops: ${TEST_LOOPS}
    Set Suite Variable   ${UNIT}   ABIA2
    Set Suite Variable   ${SOC}   K2C
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_ALARM}  ${APPLICATION}  ${UNIT}  ${SOC}  ${SYSLOG_LIST}
        ...    ${WAIT_FOR_RECO_COUNTER_CLEAR}
        ...    name=${CASE_NAME} ${UNIT} ${SOC}
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Kill application from secondary SoC and expect SoC reset
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

Crash FaultServiceExe from ABIA3 K2C
    Sleep  1s
    [Timeout]    24h
    [Documentation]  Kill FaultServiceExe from ABIA3 K2C
    [Tags]  "ABIA3 K2C Faultcase" -test loops: ${TEST_LOOPS}
    Set Suite Variable   ${UNIT}   ABIA3
    Set Suite Variable   ${SOC}   K2C
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_ALARM}  ${APPLICATION}  ${UNIT}  ${SOC}  ${SYSLOG_LIST}
        ...    ${WAIT_FOR_RECO_COUNTER_CLEAR}
        ...    name=${CASE_NAME} ${UNIT} ${SOC}
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Kill application from secondary SoC and expect SoC reset
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

Crash FaultServiceExe from ABIA1 K2D
    Sleep  1s
    [Timeout]    24h
    [Documentation]  Kill FaultServiceExe from ABIA1 K2D
    [Tags]  "ABIA1 K2D Faultcase" -test loops: ${TEST_LOOPS}
    Set Suite Variable   ${UNIT}   ABIA1
    Set Suite Variable   ${SOC}   K2D
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_ALARM}  ${APPLICATION}  ${UNIT}  ${SOC}  ${SYSLOG_LIST}
        ...    ${WAIT_FOR_RECO_COUNTER_CLEAR}
        ...    name=${CASE_NAME} ${UNIT} ${SOC}
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Kill application from secondary SoC and expect SoC reset
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

Crash FaultServiceExe from ABIA2 K2D
    Sleep  1s
    [Timeout]    24h
    [Documentation]  Kill FaultServiceExe from ABIA2 K2D
    [Tags]  "ABIA2 K2D Faultcase" -test loops: ${TEST_LOOPS}
    Set Suite Variable   ${UNIT}   ABIA2
    Set Suite Variable   ${SOC}   K2D
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_ALARM}  ${APPLICATION}  ${UNIT}  ${SOC}  ${SYSLOG_LIST}
        ...    ${WAIT_FOR_RECO_COUNTER_CLEAR}
        ...    name=${CASE_NAME} ${UNIT} ${SOC}
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Kill application from secondary SoC and expect SoC reset
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

Crash FaultServiceExe from ABIA3 K2D
    Sleep  1s
    [Timeout]    24h
    [Documentation]  Kill FaultServiceExe from ABIA3 K2D
    [Tags]  "ABIA3 K2D Faultcase" -test loops: ${TEST_LOOPS}
    Set Suite Variable   ${UNIT}   ABIA3
    Set Suite Variable   ${SOC}   K2D
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_ALARM}  ${APPLICATION}  ${UNIT}  ${SOC}  ${SYSLOG_LIST}
        ...    ${WAIT_FOR_RECO_COUNTER_CLEAR}
        ...    name=${CASE_NAME} ${UNIT} ${SOC}
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Kill application from secondary SoC and expect SoC reset
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
