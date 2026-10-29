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


*** Variables ***
${WAIT_FOR_CELLS_UP}    300
${REPORT}               ${True}
${BBMOD_TO_RESET}       BBMOD-1    # you can also give BCI (BBMOD Configuration Identifier) ->  ABIA1/ABIA2...
${RESET_TYPE}           Warm       # Warm/PowerReset
## Expected syslog print that will fail the test if not found during test run
#${SYSLOG_PRINT}         Detected most recent reset type was 1 (ERPresetTypeApplication)
# to list below you can add prints that will be monitored from syslog, if print is found, it is written to eventlog
@{SYSLOG_LIST}          BbmodReset  ResetCounter  Detected most recent reset type was
# to list below you can add prints that will fail the test if they are found from syslog
@{UNALLOWED_SYSLOGS}    13 (ERPresetTypeApplicationBts)  4 (ERPresetTypeSpuriousReset)
# Path to allowed alarms file
${ALLOWED_ALARMS_FILE}  testsuite/Oulu/TrunkEng/OMKPI/allowed_alarms.txt
${WAIT_CHECKS}          0    # seconds, 0 if no waiting nor printing before post conditions check
# Collect logs variable. Possible values are: On failure/Never/Always
${COLLECT_LOGS}         On failure
# How many times test will be run, needs to be more than 0
${TEST_LOOPS}           3
${REFERENCE_TESTLINE}   ${EMPTY}

*** Test Cases ***
Automated_OAMKPI_Capacity_Module_Reset
    [Documentation]  Reset user given BBMOD and checks alarms and cell states.
    [Tags]    "BBMOD reset" -test loops: ${TEST_LOOPS} # QC_320863  QCD_MN_RAN  QCP_RAN_ST
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
