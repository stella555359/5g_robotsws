*** Settings ***
Documentation
...  Author:   Essi Passoja
...  Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource    testsuite/Oulu/TrunkEng/RecoveryAndAlarms/Robot/TestKeywords/dsp_crash.robot
Library     testsuite.Oulu.TrunkEng.Common.Python.Interfaces.FspIP  WITH NAME  FSP
Library     testsuite.Oulu.TrunkEng.RecoveryAndAlarms.Python.Interfaces.FaultingBBMOD


Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown     Common Test Teardown

*** Variables ***
${UNIT}                 BBMOD1
${SOC}                  K2A
${WAIT_FOR_ALARM}       300
${WAIT_FOR_CELLS_UP}    300
${TEST_LOOPS}           1
${COLLECT_LOGS}         On failure
${ALLOWED_ALARMS_FILE}  /home/ute/MN/UTE/robotws/testsuite/Oulu/TrunkEng/RecoveryAndAlarms/allowed_alarms.txt

*** Test Cases ***
Crash DSP From ABIA1
    [Documentation]  Crash DSP From ABIA1, expect alarm 6706.
    [Tags]           "Crash DSP From ABIA" -test loops: ${TEST_LOOPS}
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_ALARM}  ${UNIT}  ${SOC}
        ...    name=Crash DSP From ABIA1
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Crash DSP From ABIA
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
