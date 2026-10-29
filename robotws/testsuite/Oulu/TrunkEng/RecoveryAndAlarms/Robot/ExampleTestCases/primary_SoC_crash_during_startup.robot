*** Settings ***
Documentation
...   Author:   Essi Passoja
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource    testsuite/Oulu/TrunkEng/RecoveryAndAlarms/Robot/TestKeywords/bbmod_crash_during_startup.robot

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown     Common Test Teardown


*** Variables ***
${WAIT_FOR_CELLS_UP}      ${600}
${GRACEFUL_REBOOT}        ${False}
@{SYSLOG_LIST}            ResetCounter  Detected most recent reset type  Failed to execute executable  RecoveryConstraints
                ...       Executing recovery action  RecoveryActionController   HW resource started up
@{UNALLOWED_SYSLOGS}      14 (ERPresetTypeSpuriousResetBts)
# Path to allowed alarms file
${ALLOWED_ALARMS_FILE}    testsuite/Oulu/TrunkEng/RecoveryAndAlarms/allowed_alarms.txt
# Collect logs variable. Possible values are: On failure/Never/Always
${COLLECT_LOGS}           On failure
# How many times test will be run, needs to be more than 0
${TEST_LOOPS}             1
# Unit, can be ABIA, ABIN, ABIO, ABIP, ABIQ
${UNIT}                   ABIN1
# Starting step
${STEP}                   1


*** Test Cases ***
Crash Primary SoC During Startup
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${UNIT}  ${GRACEFUL_REBOOT}  ${STEP}
        ...    name=Crash Primary SoC During Startup
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Crash Primary SoC During Startup
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
