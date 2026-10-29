*** Settings ***

Documentation
...                 Author:   Lauri Lehtoaho
...                 Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Library           Collections
Library           taf.sw.reporting_portal
Resource          testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Library           testsuite.Oulu.TrunkEng.OMKPI.Python.Interfaces.OmkpiStartupTimesInterface  WITH NAME  Startup
Resource          testsuite/Oulu/TrunkEng/OMKPI/Robot/Resources/OMKPI_common.robot
Resource          testsuite/Oulu/TrunkEng/OMKPI/Robot/TestKeywords/omkpi_bbmod_reset.robot
Variables         testsuite/Oulu/TrunkEng/OMKPI/Robot/Targets/CB008325_AL_omkpi_targets.py
Library          testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Marvin  WITH NAME  Marvin

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown     Common Test Teardown

*** Variables ***
${WAIT_FOR_CELLS_UP}    300
${REPORT}               ${True}
${BBMOD_TO_RESET}       BBMOD-1
${RESET_TYPE}           PowerReset       # Warm/PowerReset
## Expected syslog print that will fail the test if not found during test run
#${SYSLOG_PRINT}         Detected most recent reset type was 1 (ERPresetTypeApplication)
# to list below you can add prints that will be monitored from syslog, if print is found, it is written to eventlog
@{SYSLOG_LIST}
# to list below you can add prints that will fail the test if they are found from syslog
@{UNALLOWED_SYSLOGS}    13 (ERPresetTypeApplicationBts)  4 (ERPresetTypeSpuriousReset)  Please contact owner of
# Path to allowed alarms file
${ALLOWED_ALARMS_FILE}  testsuite/Oulu/TrunkEng/OMKPI/allowed_alarms.txt
${WAIT_CHECKS}          60    # seconds, 0 if no waiting nor printing before post conditions check
# Collect logs variable. Possible values are: On failure/Never/Always
${COLLECT_LOGS}         On failure
# How many times test will be run, needs to be more than 0
${TEST_LOOPS}           10
${REFERENCE_TESTLINE}   CB008325_AL
${UE_IN_USE}            ${True}
#${MARVIN_REF_CASE_ID}      cfc9f669-e08b-46bb-8f20-78428edfb2ba
#${MARVIN_REF_RUN_ID}       df0c296b-cc49-4b9e-84b4-fd2019fb9ad

*** Test Cases ***
Automated_OAMKPI_Capacity_Module_Power_Reset
    [Documentation]  Reset user given BBMOD and checks alarms and cell states.
    [Tags]    "BBMOD reset" -test loops: ${TEST_LOOPS}
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${BBMOD_TO_RESET}  ${RESET_TYPE}  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}
        ...    ${UNALLOWED_SYSLOGS}  ${OAM_KPI_TARGETS}
        ...    name=Reset BBMOD
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Reset BBMOD
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
        ...    omkpi_case=${True}
