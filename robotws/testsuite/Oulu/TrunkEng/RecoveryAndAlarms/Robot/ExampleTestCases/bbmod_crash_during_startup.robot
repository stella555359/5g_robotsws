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
${GRACEFUL_REBOOT}        ${True}
@{SYSLOG_LIST}            ResetCounter  Detected most recent reset type  Failed to execute executable  RecoveryConstraints
                ...       Executing recovery action  RecoveryActionController   HW resource started up
@{UNALLOWED_SYSLOGS}      14 (ERPresetTypeSpuriousResetBts)
${ALLOWED_ALARMS_FILE}    testsuite/Oulu/TrunkEng/RecoveryAndAlarms/allowed_alarms.txt
${COLLECT_LOGS}           On failure


*** Test Cases ***
Crash All BBMODs
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${GRACEFUL_REBOOT}
        ...    name=Crash All BBMODs
        ...    test_case=1
        ...    loops=1
        ...    keywords=Crash During Startup For All Primary SOCs
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
