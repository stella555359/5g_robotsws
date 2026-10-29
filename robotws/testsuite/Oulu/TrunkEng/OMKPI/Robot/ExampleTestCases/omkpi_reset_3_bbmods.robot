*** Settings ***
Documentation
...   Author:   Terhi Talvitie
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Library           Collections
Library           taf.sw.reporting_portal
Resource          testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource          testsuite/Oulu/TrunkEng/OMKPI/Robot/Resources/OMKPI_common.robot
Resource          testsuite/Oulu/TrunkEng/OMKPI/Robot/TestKeywords/omkpi_bbmod_reset.robot
Variables         testsuite/Oulu/TrunkEng/OMKPI/Robot/Targets/omkpi_targets_example.py


Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown     Common Test Teardown

# NOTE this test suitable only in environments that have three BBMOD units.
*** Variables ***
${WAIT_FOR_CELLS_UP}    300
${REPORT}               ${True}
${RESET_TYPE}           Warm       # Warm/PowerReset
# You can also give BBMOD as BBMOD-1/BBMOD-2/BBMOD-3 or BCI (BBMOD Configuration Identifier) ABIA1/ABIL2/ABIL2.1..
${BBMOD_TO_RESET}       /SMOD_R-y(x)/BBMOD_R-z(x_Bottom)
# to list below you can add prints that will be monitored from syslog, if print is found, it is written to eventlog
@{SYSLOG_LIST}          BbmodReset  ResetCounter
# to list below you can add prints that will fail the test if they are found from syslog
@{UNALLOWED_SYSLOGS}    13 (ERPresetTypeApplicationBts)  4 (ERPresetTypeSpuriousReset)
                   ...  14 (ERPresetTypeSpuriousResetBts)  0 (ERPresetTypePowerOn)
# Path to allowed alarms file
${ALLOWED_ALARMS_FILE}  testsuite/Oulu/TrunkEng/OMKPI/allowed_alarms.txt
${WAIT_CHECKS}          0    # seconds, 0 if no waiting nor printing before post conditions check
# Collect logs variable. POssible values are: On failure/Never/Always
${COLLECT_LOGS}         On failure
# How many times test will be run, needs to be more than 0
${TEST_LOOPS}           2
${REFERENCE_TESTLINE}   ${EMPTY}

*** Test Cases ***
Reset Bottom BBMOD
    [Documentation]  Reset bottom BBMOD (BBMOD-1) and checks alarms and cell states.
    [Tags]    "Reset bottom bbmod" -test loops: ${TEST_LOOPS}
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${BBMOD_TO_RESET}  ${RESET_TYPE}  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}
        ...    ${UNALLOWED_SYSLOGS}  ${OAM_KPI_TARGETS}
        ...    name=Reset bottom BBMOD
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Reset BBMOD
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
        ...    omkpi_case=${True}
Reset Middle BBMOD
    [Documentation]  Reset middle BBMOD (BBMOD-2) and checks alarms and cell states.
    [Tags]    "Reset middle bbmod" -test loops: ${TEST_LOOPS}
    Set Suite Variable  ${BBMOD_TO_RESET}  /SMOD_R-y(x)/BBMOD_R-z(x_Middle)
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${BBMOD_TO_RESET}  ${RESET_TYPE}  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}
        ...    ${UNALLOWED_SYSLOGS}  ${OAM_KPI_TARGETS}
        ...    name=Reset middle BBMOD
        ...    test_case=2
        ...    loops=${TEST_LOOPS}
        ...    keywords=Reset BBMOD
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
        ...    omkpi_case=${True}
Reset Top BBMOD
    [Documentation]  Reset top BBMOD (BBMOD-3) and checks alarms and cell states.
    [Tags]    "Reset top bbmod" -test loops: ${TEST_LOOPS}
    Set Suite Variable  ${BBMOD_TO_RESET}   /SMOD_R-y(x)/BBMOD_R-z(x_Top)
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${BBMOD_TO_RESET}  ${RESET_TYPE}  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}
        ...    ${UNALLOWED_SYSLOGS}  ${OAM_KPI_TARGETS}
        ...    name=Reset top BBMOD
        ...    test_case=3
        ...    loops=${TEST_LOOPS}
        ...    keywords=Reset BBMOD
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
        ...    omkpi_case=${True}
