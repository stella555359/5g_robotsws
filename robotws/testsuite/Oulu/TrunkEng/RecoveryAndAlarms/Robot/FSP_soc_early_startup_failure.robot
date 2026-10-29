*** Settings ***
Documentation
...   Author:   Jere Jacklin
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource    testsuite/Oulu/TrunkEng/RecoveryAndAlarms/Robot/TestKeywords/early_startup_failure_with_flag_manipulation.robot
Resource    testsuite/Oulu/TrunkEng/Common/Robot/TestKeywords/flag_manipulation.robot

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown     Common Test Teardown


*** Variables ***
${ALLOWED_ALARMS_FILE}    testsuite/Oulu/TrunkEng/RecoveryAndAlarms/allowed_alarms.txt
&{SECONDARY_CORE_FLAGS}   0x2019d=2
&{PRIMARY_CORE_FLAGS}     0x2019d=3
@{SYSLOG_LIST}
${SYSLOG_PRINT}
${WAIT_FOR_CELLS_UP}      ${600}
${WAIT_CHECKS}            300
${WAIT_AFTER_SWDL}        480  # 300s is not enough time for cells to be up in UC3
${TEXT_TO_STEP}           Add flag
${COLLECT_LOGS}           Always
${TEST_LOOPS}             1


*** Test Cases ***
UC3 Primary Core Early Startup Failure
    [Documentation]  Use case 3 of CNI-139728. NOTE this test requires full rack environment.
    ${FULLRACK}=  Site is fullrack
    # This variable is used to kill given application during SWDL
    IF  ${FULLRACK}
        Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
            ...    ${WAIT_AFTER_SWDL}  ${PRIMARY_CORE_FLAGS}  HWRPostSExe
            ...    name=T1 SWDL with active flags
            ...    test_case=1
            ...    loops=${TEST_LOOPS}
            ...    keywords=Primary Core Early Startup Failure
            ...    expected_pass_rate=1
            ...    collect_test_logs=${COLLECT_LOGS}
    ELSE
        Print Text To Eventlog    Test is suitable only for full rack environments
        Fail    Wrong topology. Test is valid only for full rack environments
    END

UC2 Secondary Core Early Startup Failure
    [Documentation]  Use case 2 of CNI-139728. NOTE this test requires full rack environment.
    ${FULLRACK}=  Site is fullrack
    IF  ${FULLRACK}
        Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
            ...    ${SECONDARY_CORE_FLAGS}
            ...    name=T1 SWDL with active flags
            ...    test_case=1
            ...    loops=${TEST_LOOPS}
            ...    keywords=Secondary Core Early Startup Failure
            ...    expected_pass_rate=1
            ...    collect_test_logs=${COLLECT_LOGS}
    ELSE
        Print Text To Eventlog    Test is suitable only for full rack environments
        Fail    Wrong topology. Test is valid only for full rack environments
    END