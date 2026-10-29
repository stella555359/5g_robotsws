*** Settings ***
Documentation
...   Author:   Jere Jacklin
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource    testsuite/Oulu/TrunkEng/RecoveryAndAlarms/Robot/TestKeywords/early_startup_failure_with_flag_manipulation.robot

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown     Common Test Teardown


*** Variables ***
${ALLOWED_ALARMS_FILE}    testsuite/Oulu/TrunkEng/RecoveryAndAlarms/allowed_alarms.txt
${ADD_FLAG}               ${True}
@{UNALLOWED_SYSLOGS}
${WAIT_FOR_CELLS_UP}      600
${WAIT_CHECKS}            300
${WAIT_AFTER_SWDL}        600
${TEXT_TO_STEP}           Add flag
${COLLECT_LOGS}           Always
${TEST_LOOPS}             1
${WAIT_AFTER_BOOTLOADER}  600
${FORCE_NORMAL_BUILD}   ${True}


*** Test Cases ***
UC5 SSBL Bootloader Early Startup Failure
    [Documentation]  Use case 5 of CNI-139728
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}
        ...    name=SSBL Bootloader Early Startup Failure
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=SSBL Bootloader early startup failure
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

UC4 FSBL Bootloader Early Startup Failure
    [Documentation]  Use case 4 of CNI-139728
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}
        ...    name=FSBL Bootloader Early Startup Failure
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=FSBL Bootloader early startup failure
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

UC6 Systemd early startup failure
    [Documentation]  Use case 6 of CNI-139728
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}
        ...    name=Systemd early startup failure
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Stop watchdog in SW activation
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
