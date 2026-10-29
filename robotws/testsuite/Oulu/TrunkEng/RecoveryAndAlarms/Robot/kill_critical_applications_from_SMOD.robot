*** Settings ***
Documentation
...   Author:   Mirka Kyllonen
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource    testsuite/Oulu/TrunkEng/RecoveryAndAlarms/Robot/TestKeywords/kill_critical_applications.robot
Resource    testsuite/Oulu/TrunkEng/Common/Robot/TestKeywords/flag_manipulation.robot

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
${CASE_NAME}            Crash of critical application
# Max time to wait for cells to be up and running, currently mandatory to be given as integer, later also string will be suitable
${WAIT_FOR_CELLS_UP}    ${600}
# Wait after test and site reset, value can be given as string. Note time for reset cleaner to be cleaned has been 360s.
${WAIT_FOR_RECO_COUNTER_CLEAR}    360
# Time to wait before doing post conditions checks, seconds. Default 300
${WAIT}    300
# Not suitable way for real testing because of reporting. Usable just when trying functionality.
@{APPLICATIONS}         bm  BTSOMexe  DCS  DEM  FRI  HAS  LTS  MCI  MCtrl  SWM  SysAdapter  TAS  BStat
# Suite Variable that's value is changed in Test Cases
${APPLICATION}          SysAdapter
# Syslog prints that will be printed to eventlog when found from the syslog, will not fail the test if found/not found
@{SYSLOG_LIST}          ResetCounter  Detected most recent reset type Failed to execute executable  RecoveryConstraints
                        ...    Executing recovery action  RecoveryActionController  Set alarm  Reset count
                        ...    Please contact the owner of  FAULT_SIGNATURE  AlarmFaultSignature
# Expected syslog print that will fail the test if not found during test run
${SYSLOG_PRINT}         ERPresetTypeSpuriousReset
# Path to allowed alarms file
${ALLOWED_ALARMS_FILE}  /home/ute/MN/UTE/robotws/testsuite/Oulu/TrunkEng/RecoveryAndAlarms/allowed_alarms.txt
# Collect logs variable. Possible values are: On failure/Never/Always
${COLLECT_LOGS}         On failure
# How many times test will be run, needs to be more than 0
${TEST_LOOPS}           1
${WAIT_CHECKS}          0    # seconds, 0 if no waiting nor printing before post conditions check
&{FLAG_VALUE}           0x2004c=5
${ADD_FLAG}             ${True}
${TEXT_TO_STEP}         Add flag
# Variable for RFS testing. If RFS is set True, there is takan logs from both sides (4G/5G) and done also other checks to other side also.
${RFS}     ${False}
${MASTER}  This  # This/Other
${WAIT_BEFORE_KILL}     0
${MARVIN_VERDICT}       ${True}

*** Test Cases ***
Crash BM Critical Application from RealNode in SMOD
    Sleep  1s
    [Timeout]    24h
    [Documentation]  Kill bm application from real node. Spurious reset is expected.
    [Tags]    "Kill BM Application" -test loops: ${TEST_LOOPS}
    Set Suite Variable   ${APPLICATION}   bm
#Checks if wrong application has crashed
    Set Suite Variable  ${Unexpected_Syslog}  Please contact owner of '(?!bm).*
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${FLAG_VALUE}  ${ADD_FLAG}  ${TEXT_TO_STEP}
        ...    name=Add flag to swconfig
        ...    test_case=Pre
        ...    loops=1
        ...    keywords=Change flag to swconfig
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_RECO_COUNTER_CLEAR}  ${APPLICATION}  ${SYSLOG_LIST}
        ...    ${SYSLOG_PRINT}   ${WAIT}
        ...    name=${CASE_NAME} ${APPLICATION}
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Application kill
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

Crash BTSOMexe Critical Application from RealNode in SMOD
    Sleep  1s
    [Timeout]    24h
    [Documentation]  Kill BTSOMexe application from real node. Spurious reset is expected.
    [Tags]    "Kill BTSOMexe Application" -test loops: ${TEST_LOOPS}
    Set Suite Variable  ${APPLICATION}  BTSOMexe
#Checks if wrong application has crashed
    Set Suite Variable  ${Unexpected_Syslog}  Please contact owner of '(?!BTSOMexe).*
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${FLAG_VALUE}  ${ADD_FLAG}  ${TEXT_TO_STEP}
        ...    name=Add flag to swconfig
        ...    test_case=Pre
        ...    loops=1
        ...    keywords=Change flag to swconfig
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_RECO_COUNTER_CLEAR}  ${APPLICATION}  ${SYSLOG_LIST}
        ...    ${SYSLOG_PRINT}   ${WAIT}
        ...    name=${CASE_NAME} ${APPLICATION}
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Application kill
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

Crash DCS Critical Application from RealNode in SMOD
    Sleep  1s
    [Timeout]    24h
    [Documentation]  Kill DCS application from real node. Spurious reset is expected.
    [Tags]    "Kill DCS Application" -test loops: ${TEST_LOOPS}
    Set Suite Variable  ${APPLICATION}  DCS
#Checks if wrong application has crashed
    Set Suite Variable  ${Unexpected_Syslog}  Please contact owner of '(?!DCS).*
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${FLAG_VALUE}  ${ADD_FLAG}  ${TEXT_TO_STEP}
        ...    name=Add flag to swconfig
        ...    test_case=Pre
        ...    loops=1
        ...    keywords=Change flag to swconfig
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_RECO_COUNTER_CLEAR}  ${APPLICATION}  ${SYSLOG_LIST}
        ...    ${SYSLOG_PRINT}   ${WAIT}
        ...    name=${CASE_NAME} ${APPLICATION}
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Application kill
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

Crash DEM Critical Application from RealNode in SMOD
    Sleep  1s
    [Timeout]    24h
    [Documentation]  Kill DEM application from real node. Spurious reset is expected.
    [Tags]    "Kill DEM Application" -test loops: ${TEST_LOOPS}
    Set Suite Variable  ${APPLICATION}  DEM
#Checks if wrong application has crashed
    Set Suite Variable  ${Unexpected_Syslog}  Please contact owner of '(?!DEM).*
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${FLAG_VALUE}  ${ADD_FLAG}  ${TEXT_TO_STEP}
        ...    name=Add flag to swconfig
        ...    test_case=Pre
        ...    loops=1
        ...    keywords=Change flag to swconfig
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_RECO_COUNTER_CLEAR}  ${APPLICATION}  ${SYSLOG_LIST}
        ...    ${SYSLOG_PRINT}   ${WAIT}
        ...    name=${CASE_NAME} ${APPLICATION}
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Application kill
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

Crash FRI Critical Application from RealNode in SMOD
    Sleep  1s
    [Timeout]    24h
    [Documentation]  Kill FRI application from real node. Spurious reset is expected.
    [Tags]    "Kill FRI Application" -test loops: ${TEST_LOOPS}
    Set Suite Variable  ${APPLICATION}  FRI
#Checks if wrong application has crashed
    Set Suite Variable  ${Unexpected_Syslog}  Please contact owner of '(?!FRI).*
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${FLAG_VALUE}  ${ADD_FLAG}  ${TEXT_TO_STEP}
        ...    name=Add flag to swconfig
        ...    test_case=Pre
        ...    loops=1
        ...    keywords=Change flag to swconfig
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_RECO_COUNTER_CLEAR}  ${APPLICATION}  ${SYSLOG_LIST}
        ...    ${SYSLOG_PRINT}   ${WAIT}
        ...    name=${CASE_NAME} ${APPLICATION}
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Application kill
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

Crash HAS Critical Application from RealNode in SMOD
    Sleep  1s
    [Timeout]    24h
    [Documentation]  Kill HAS application from real node. Spurious reset is expected.
    [Tags]    "Kill HAS Application" -test loops: ${TEST_LOOPS}
    Set Suite Variable  ${APPLICATION}  HAS
#Checks if wrong application has crashed
    Set Suite Variable  ${Unexpected_Syslog}  Please contact owner of '(?!HAS).*
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${FLAG_VALUE}  ${ADD_FLAG}  ${TEXT_TO_STEP}
        ...    name=Add flag to swconfig
        ...    test_case=Pre
        ...    loops=1
        ...    keywords=Change flag to swconfig
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_RECO_COUNTER_CLEAR}  ${APPLICATION}  ${SYSLOG_LIST}
        ...    ${SYSLOG_PRINT}   ${WAIT}
        ...    name=${CASE_NAME} ${APPLICATION}
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Application kill
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

Crash LTS Critical Application from RealNode in SMOD
    Sleep  1s
    [Timeout]    24h
    [Documentation]  Kill LTS application from real node. Spurious reset is expected.
    [Tags]    "Kill LTS Application" -test loops: ${TEST_LOOPS}
    Set Suite Variable  ${APPLICATION}  LTS
#Checks if wrong application has crashed
    Set Suite Variable  ${Unexpected_Syslog}  Please contact owner of '(?!LTS).*
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${FLAG_VALUE}  ${ADD_FLAG}  ${TEXT_TO_STEP}
        ...    name=Add flag to swconfig
        ...    test_case=Pre
        ...    loops=1
        ...    keywords=Change flag to swconfig
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_RECO_COUNTER_CLEAR}  ${APPLICATION}  ${SYSLOG_LIST}
        ...    ${SYSLOG_PRINT}  ${WAIT}
        ...    name=${CASE_NAME} ${APPLICATION}
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Application kill
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

Crash MCI Critical Application from RealNode in SMOD
    Sleep  1s
    [Timeout]    24h
    [Documentation]  Kill MCI application from real node. Spurious reset is expected.
    [Tags]    "Kill MCI Application" -test loops: ${TEST_LOOPS}
    Set Suite Variable  ${APPLICATION}  MCI
#Checks if wrong application has crashed
    Set Suite Variable  ${Unexpected_Syslog}  Please contact owner of '(?!MCI).*
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${FLAG_VALUE}  ${ADD_FLAG}  ${TEXT_TO_STEP}
        ...    name=Add flag to swconfig
        ...    test_case=Pre
        ...    loops=1
        ...    keywords=Change flag to swconfig
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_RECO_COUNTER_CLEAR}  ${APPLICATION}  ${SYSLOG_LIST}
        ...    ${SYSLOG_PRINT}  ${WAIT}
        ...    name=${CASE_NAME} ${APPLICATION}
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Application kill
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

Crash MCtrl Critical Application from RealNode in SMOD
    Sleep  1s
    [Timeout]    24h
    [Documentation]  Kill MCtrl application from real node. Spurious reset is expected.
    [Tags]    "Kill MCtrl Application" -test loops: ${TEST_LOOPS}
    Set Suite Variable  ${APPLICATION}  MCtrl
#Checks if wrong application has crashed
    Set Suite Variable  ${Unexpected_Syslog}  Please contact owner of '(?!MCtrl).*
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${FLAG_VALUE}  ${ADD_FLAG}  ${TEXT_TO_STEP}
        ...    name=Add flag to swconfig
        ...    test_case=Pre
        ...    loops=1
        ...    keywords=Change flag to swconfig
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_RECO_COUNTER_CLEAR}  ${APPLICATION}  ${SYSLOG_LIST}
        ...    ${SYSLOG_PRINT}   ${WAIT}
        ...    name=${CASE_NAME} ${APPLICATION}
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Application kill
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

Crash SWM Critical Application from RealNode in SMOD
    Sleep  1s
    [Timeout]    24h
    [Documentation]  Kill SWM application from real node. Spurious reset is expected.
    [Tags]    "Kill SWM Application" -test loops: ${TEST_LOOPS}
    Set Suite Variable  ${APPLICATION}  SWM
#Checks if wrong application has crashed
    Set Suite Variable  ${Unexpected_Syslog}  Please contact owner of '(?!SWM).*
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${FLAG_VALUE}  ${ADD_FLAG}  ${TEXT_TO_STEP}
        ...    name=Add flag to swconfig
        ...    test_case=Pre
        ...    loops=1
        ...    keywords=Change flag to swconfig
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_RECO_COUNTER_CLEAR}  ${APPLICATION}  ${SYSLOG_LIST}
        ...    ${SYSLOG_PRINT}    ${WAIT}
        ...    name=${CASE_NAME} ${APPLICATION}
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Application kill
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

Crash SysAdapter Critical Application from RealNode in SMOD
    Sleep  1s
    [Timeout]    24h
    [Documentation]  Kill SysAdapter application from real node. Spurious reset is expected.
    [Tags]    "Kill SysAdapter Application" -test loops: ${TEST_LOOPS}
    Set Suite Variable  ${APPLICATION}  SysAdapter
#Checks if wrong application has crashed
    Set Suite Variable  ${Unexpected_Syslog}  Please contact owner of '(?!SysAdapter).*
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${FLAG_VALUE}  ${ADD_FLAG}  ${TEXT_TO_STEP}
        ...    name=Add flag to swconfig
        ...    test_case=Pre
        ...    loops=1
        ...    keywords=Change flag to swconfig
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_RECO_COUNTER_CLEAR}  ${APPLICATION}  ${SYSLOG_LIST}
        ...    ${SYSLOG_PRINT}    ${WAIT}
        ...    name=${CASE_NAME} ${APPLICATION}
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Application kill
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

Crash TAS Critical Application from RealNode in SMOD
    Sleep  1s
    [Timeout]    24h
    [Documentation]  Kill TAS application from real node. Spurious reset is expected.
    [Tags]    "Kill TAS Application" -test loops: ${TEST_LOOPS}
    Set Suite Variable  ${APPLICATION}  TAS
#Checks if wrong application has crashed
    Set Suite Variable  ${Unexpected_Syslog}  Please contact owner of '(?!TAS).*
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${FLAG_VALUE}  ${ADD_FLAG}  ${TEXT_TO_STEP}
        ...    name=Add flag to swconfig
        ...    test_case=Pre
        ...    loops=1
        ...    keywords=Change flag to swconfig
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_RECO_COUNTER_CLEAR}  ${APPLICATION}  ${SYSLOG_LIST}
        ...    ${SYSLOG_PRINT}    ${WAIT}
        ...    name=${CASE_NAME} ${APPLICATION}
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Application kill
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

Crash PMStat Critical Application from RealNode in SMOD
    Sleep  1s
    [Timeout]    24h
    [Documentation]  Kill PMStat application from real node. Spurious reset is expected.
    [Tags]    "Kill PMStat Application" -test loops: ${TEST_LOOPS}
    Set Suite Variable  ${APPLICATION}  PMStat
#Checks if wrong application has crashed
    Set Suite Variable  ${Unexpected_Syslog}  Please contact owner of '(?!PMStat).*
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${FLAG_VALUE}  ${ADD_FLAG}  ${TEXT_TO_STEP}
        ...    name=Add flag to swconfig
        ...    test_case=Pre
        ...    loops=1
        ...    keywords=Change flag to swconfig
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_RECO_COUNTER_CLEAR}  ${APPLICATION}  ${SYSLOG_LIST}
        ...    ${SYSLOG_PRINT}  ${WAIT}
        ...    name=${CASE_NAME} ${APPLICATION}
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Application kill
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

Crash Critical Application from RealNode in SMOD in loop and finally expect SW fallback
    Sleep  1s
    [Timeout]    24h
    [Documentation]  Kill Critical application from real node. Spurious reset(s) is expected and also SW fallback.
    [Tags]    "Kill PMStat Application" -test loops: ${TEST_LOOPS}
    Set Suite Variable  ${APPLICATION}  PMStat
#Checks if wrong application has crashed
    Set Suite Variable  ${Unexpected_Syslog}  Please contact owner of '(?!PMStat).*

    Run Keyword And Continue On Failure    ALARMS.Add Allowed Alarm  fault_name=SW fallback
    Run Keyword And Continue On Failure    ALARMS.Add Expected Alarm To Allowed

    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_RECO_COUNTER_CLEAR}  ${APPLICATION}  ${SYSLOG_LIST}
        ...    ${SYSLOG_PRINT}  ${WAIT}
        ...    name=${CASE_NAME} ${APPLICATION}
        ...    test_case=1
        ...    loops=3
        ...    keywords=Application kill
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

Crash Critical Application During Runtime
    Sleep  1s
    [Timeout]    24h
    [Documentation]  Kill Critical Application.
    [Tags]    "Kill Critical Application" -test loops: ${TEST_LOOPS}
    Set Suite Variable  ${APPLICATION}
    IF  '${WAIT_BEFORE_KILL}' != '0'
        Set Suite Variable  ${WAIT_BEFORE_KILL}
    ELSE
        Set Suite Variable  ${WAIT_BEFORE_KILL}  480
    END
    Set Suite Variable  ${Unexpected_Syslog}  Please contact owner of '(?!${APPLICATION}).*
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_RECO_COUNTER_CLEAR}  ${APPLICATION}  ${SYSLOG_LIST}
        ...    ${SYSLOG_PRINT}  ${WAIT}
        ...    name=${CASE_NAME} ${APPLICATION}
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Application kill
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
