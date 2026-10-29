*** Settings ***
Documentation
...   Author:   Mirka Kyllönen
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com
...   Force Tags      RF50

Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource    testsuite/Oulu/TrunkEng/RecoveryAndAlarms/Robot/TestKeywords/ABIA_SilentCrash_KWs.robot
Resource    testsuite/Oulu/TrunkEng/RecoveryAndAlarms/Robot/TestKeywords/kill_applications_reset.robot
Resource    testsuite/Oulu/TrunkEng/Common/Robot/TestKeywords/flag_manipulation.robot

Library     testsuite.Oulu.TrunkEng.Common.Python.Interfaces.pass_rate

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown     Common Test Teardown


*** Variables ***
# Max time to wait for cells to be up and running, currently mandatory to be given as integer, later also string will be suitable
${WAIT_FOR_CELLS_UP}    ${600}
# Time for wait alarm when alarm activated, needs to be log so 10 alarm have time to be raised
${WAIT_FOR_ALARM}       540
${WAIT_AFTER_SITE_RESET}   30
# Prints that are monitored from syslog to eventlog
@{SYSLOG_LIST}          ResetCounter  Detected most recent reset type  Failed to execute executable
                        ...    Executing recovery action  RecoveryActionController  Set alarm  Reset count
                        ...    Please contact the owner of   RESET, DDAL_HOTPLUG_EVT_RIO_REMOVE received device_id
                        ...    FAULT_SIGNATURE  AlarmFaultSignature
# Path to allowed alarms file
${ALLOWED_ALARMS_FILE}  /home/ute/MN/UTE/robotws/testsuite/Oulu/TrunkEng/RecoveryAndAlarms/allowed_alarms.txt
# Collect logs variable. Possible values are: On failure/Never/Always
${COLLECT_LOGS}         On failure
# How many times test will be run, needs to be more than 0
${TEST_LOOPS}           1
@{ALLOWED_ALARMS}   10
${WAIT_CHECKS}          0    # seconds, 0 if no waiting nor printing before post conditions check
&{FLAG_VALUE}           0x2004c=5
${ADD_FLAG}             ${True}
${TEXT_TO_STEP}         Add flag


*** Test Cases ***
ABIA_SilentCrash_Primary_SOC
	Sleep  1s
	[Timeout]    24h
	[Documentation]  Tester generates silent crash to BBMOD for ABIA(s) for K2A
	[Tags]    "ABIA SilentCrash for Primary SOC" -test loops: ${TEST_LOOPS}
	Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${FLAG_VALUE}  ${ADD_FLAG}  ${TEXT_TO_STEP}
        ...    name=Add flag to swconfig
        ...    test_case=Pre
        ...    loops=1
        ...    keywords=Change flag to swconfig
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
	Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_ALARM}  ${SYSLOG_LIST}  ${WAIT_AFTER_SITE_RESET}
        ...    name=ABIA Silent Crash Primary SOCs
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=ABIA Silent Crash Primary SOC
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

ABIA_SilentCrash_Secondary_SOC
	Sleep  1s
	[Timeout]    24h
	[Documentation]  Tester generates silent crash to BBMOD for ABIA(s) for K2B/C/D
	[Tags]    "ABIA SilentCrash for Primary SOC" -test loops: ${TEST_LOOPS}
	    Set Suite Variable   ${SOC}        K2B
	Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${SYSLOG_LIST}  ${WAIT_AFTER_SITE_RESET}  ${SOC}
        ...    name=ABIA Silent Crash Secondary SOCs
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=ABIA Silent Crash Secondary SOC
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
        Set Suite Variable   ${SOC}        K2C
	Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${SYSLOG_LIST}  ${WAIT_AFTER_SITE_RESET}  ${SOC}
        ...    name=ABIA Silent Crash Secondary SOCs
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=ABIA Silent Crash Secondary SOC
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
        Set Suite Variable   ${SOC}        K2D
	Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${SYSLOG_LIST}  ${WAIT_AFTER_SITE_RESET}  ${SOC}
        ...    name=ABIA Silent Crash Secondary SOCs
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=ABIA Silent Crash Secondary SOC
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

ABIA_Simple_SilentCrash_Primary_SOC
	Sleep  1s
	[Timeout]    24h
	[Documentation]  Tester generates silent crash to BBMOD for ABIA(s) for K2A
	[Tags]    "ABIA SilentCrash for Primary SOC" -test loops: ${TEST_LOOPS}
	Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_ALARM}  ${SYSLOG_LIST}  ${WAIT_AFTER_SITE_RESET}
        ...    name=ABIA Simple Silent Crash Primary SOCs
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Simple SilentCrash Primary SoC
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
