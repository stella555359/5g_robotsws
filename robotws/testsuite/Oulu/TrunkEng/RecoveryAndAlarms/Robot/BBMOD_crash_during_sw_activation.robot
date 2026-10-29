*** Settings ***
Documentation
...   Author:   Sirpa Passoja
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource    testsuite/Oulu/TrunkEng/RecoveryAndAlarms/Robot/TestKeywords/SoC_crash_during_SW_activation.robot

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown     Common Test Teardown


*** Variables ***
${WAIT_FOR_CELLS_UP}      ${600}
# Time to wait in seconds after sw rollback has been made
${WAIT_DISABLED_CELLS}    ${120}
${GRACEFUL_REBOOT}
@{SYSLOG_LIST}            ResetCounter  Detected most recent reset type  Failed to execute executable  RecoveryConstraints
                ...       Executing recovery action  RecoveryActionController   HW resource started up
@{UNALLOWED_SYSLOGS}      14 (ERPresetTypeSpuriousResetBts)
# Path to allowed alarms file
${ALLOWED_ALARMS_FILE}    testsuite/Oulu/TrunkEng/RecoveryAndAlarms/allowed_alarms.txt
# seconds, 0 if no waiting nor printing before post conditions check
${WAIT_CHECKS}            0
# SoC - if empty, chooses first secondary SoC
${SOC}                    ${EMPTY}
# Collect logs variable. Possible values are: On failure/Never/Always
${COLLECT_LOGS}           On failure
# How many times test will be run, needs to be more than 0
${TEST_LOOPS}             1
# Starting step
${STEP}                   1


*** Test Cases ***
Graceful Reboot for all BBMODs During SW Activation
    Set Suite Variable   ${GRACEFUL_REBOOT}   ${True}
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${WAIT_DISABLED_CELLS}  ${GRACEFUL_REBOOT}
        ...    name=Graceful Reboot for all BBMODs During SW Activation
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Crash During SW Activation for all BBMODs
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

Crash Application in Primary SoCs from all BBMODs During SW Activation
    Set Suite Variable   ${GRACEFUL_REBOOT}   ${False}
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${WAIT_DISABLED_CELLS}  ${GRACEFUL_REBOOT}
        ...    name=Crash Primary SoCs from all BBMMODs During SW Activation
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Crash During SW Activation for all BBMODs
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

Crash Application in Secondary SoCs from all BBMODs During SW Activation
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${SOC}  ${WAIT_FOR_CELLS_UP}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${WAIT_DISABLED_CELLS}
        ...    name=Crash Secondary SoCs from all BBMODs During SW Activation
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Crash Secondary SoC for all BBMODs During SW Activation
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
