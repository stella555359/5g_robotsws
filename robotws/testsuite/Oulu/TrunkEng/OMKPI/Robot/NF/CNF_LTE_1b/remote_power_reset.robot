*** Settings ***

Documentation
...   Author:   Heikki Autio
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com
...             KPI#11 - Manual remote power reset downtime

Library          taf.sw.reporting_portal
Resource         testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource         testsuite/Oulu/TrunkEng/OMKPI/Robot/Resources/OMKPI_common.robot
Resource         testsuite/Oulu/TrunkEng/OMKPI/Robot/TestKeywords/omkpi_remote_power_reset.robot
Variables        testsuite/Oulu/TrunkEng/OMKPI/Robot/Targets/CNF_LTE_1_omkpi_targets.py

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown     Common Test Teardown

*** Variables ***
${WAIT_FOR_CELLS_UP}        600
# Collect logs variable. Possible values are: On failure/Never/Always
${COLLECT_LOGS}             Always
# How many times test will be run, needs to be more than 0
${TEST_LOOPS}               10
${REFERENCE_TESTLINE}       CNF_LTE_1b
${REPORT}                   ${True}
@{SYSLOG_LIST}
@{UNALLOWED_SYSLOGS}        4 (ERPresetTypeSpuriousReset)    14 (ERPresetTypeSpuriousResetBts)
${WAIT_CHECKS}              90    # seconds, 0 if no waiting nor printing before post conditions check
${ALLOWED_ALARMS_FILE}      /home/ute/MN/UTE/robotws/testsuite/Oulu/TrunkEng/OMKPI/allowed_alarms.txt
# Can have value ${True} or ${False}. If set ${True} resets with snapshot
${RESET_WITH_SNAPSHOT}      ${False}
${ZIP_LOGS}                 ${True}

*** Test Cases ***
Automated_OAMKPI_Remote_Power_Reset
    [Documentation]  Perform remote power reset and collect KPI results.
    [Tags]           "Remote power reset" -test loops: ${TEST_LOOPS}
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${WAIT_CHECKS}  ${RESET_WITH_SNAPSHOT}  ${WAIT_FOR_CELLS_UP}  ${OAM_KPI_TARGETS}
        ...    name=Remote Power Reset
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Remote power reset
        ...    expected_pass_rate=1.0
        ...    collect_test_logs=${COLLECT_LOGS}
        ...    omkpi_case=${True}
