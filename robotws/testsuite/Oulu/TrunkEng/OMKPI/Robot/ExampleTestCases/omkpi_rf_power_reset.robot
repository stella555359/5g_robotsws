*** Settings ***
Documentation
...   Author:   Terhi Talvitie
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Library         taf.sw.reporting_portal
Resource        testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource        testsuite/Oulu/TrunkEng/OMKPI/Robot/Resources/OMKPI_common.robot
Resource        testsuite/Oulu/TrunkEng/OMKPI/Robot/TestKeywords/omkpi_rf_power_reset.robot
Variables       testsuite/Oulu/TrunkEng/OMKPI/Robot/Targets/omkpi_targets_example.py

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown     Common Test Teardown

*** Variables ***
# This variable has the kind of name that is in power breaker, currently r1, r2, r3....
${RMOD_TO_TEST}             r1
${WAIT_AFTER_POWER_CUT}     60
${WAIT_FOR_CELLS_UP}        300
# Collect logs variable. Possible values are: On failure/Never/Always
${COLLECT_LOGS}             On failure
# How many times test will be run, needs to be more than 0
${TEST_LOOPS}               1
${REFERENCE_TESTLINE}       ${EMPTY}
${ALLOWED_ALARMS_FILE}      testsuite/Oulu/TrunkEng/OMKPI/allowed_alarms.txt
${REPORT}                   ${True}
@{SYSLOG_LIST}              Detected most recent reset type was  Failed to execute executable  RecoveryConstraints
                   ...      RecoveryActionController    Executing recovery action
@{UNALLOWED_SYSLOGS}        4 (ERPresetTypeSpuriousReset)    14 (ERPresetTypeSpuriousResetBts)
${WAIT_CHECKS}              180    # seconds, 0 if no waiting nor printing before post conditions check

*** Test Cases ***
Radio Power Reset
    [Documentation]  Switch power of radio off and back on, check alarms and collect KPI results.
    [Tags]           "Rf power reset" -test loops: ${TEST_LOOPS}
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${RMOD_TO_TEST}  ${WAIT_AFTER_POWER_CUT}  ${WAIT_CHECKS}  ${WAIT_FOR_CELLS_UP}
        ...    ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${OAM_KPI_TARGETS}
        ...    name=RF Power Reset
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=RF power reset
        ...    expected_pass_rate=1.0
        ...    collect_test_logs=${COLLECT_LOGS}
        ...    omkpi_case=${True}
