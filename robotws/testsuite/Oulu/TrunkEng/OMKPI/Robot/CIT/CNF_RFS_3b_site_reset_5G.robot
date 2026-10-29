*** Settings ***

Documentation
...   Author:       Tarmo Eskuri
...   Contact:      I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Library          taf.sw.reporting_portal
Resource         testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource         testsuite/Oulu/TrunkEng/OMKPI/Robot/Resources/OMKPI_common.robot
Resource         testsuite/Oulu/TrunkEng/OMKPI/Robot/TestKeywords/omkpi_site_reset.robot
Variables        testsuite/Oulu/TrunkEng/OMKPI/Robot/Targets/CNF_RFS_3_omkpi_targets.py

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}   ${ALLOWED_ALARMS}
Test Teardown     Common Test Teardown

*** Variables ***
${WAIT_FOR_CELLS_UP}        900
# Collect logs variable.    Possible values are: On failure/Never/Always
${COLLECT_LOGS}             Always
# How many times test will be run, needs to be more than 0
${TEST_LOOPS}               10
${REFERENCE_TESTLINE}       CNF_RFS_3b
${ALLOWED_ALARMS_FILE}      testsuite/Oulu/TrunkEng/OMKPI/allowed_alarms.txt
@{ALLOWED_ALARMS}           4420  6327  4220  4773  1815  10  7107  1898
${REPORT}                   ${True}
@{SYSLOG_LIST}
@{UNALLOWED_SYSLOGS}        4 (ERPresetTypeSpuriousReset)    14 (ERPresetTypeSpuriousResetBts)
${WAIT_CHECKS}              90    # seconds, 0 if no waiting nor printing before post conditions check
${RFS}                      ${True}
${MASTER}                   This


*** Test Cases ***
Automated_OAMKPI_Site_Reset
    [Documentation]  Perform site reset and collect KPI results.
    [Tags]           "Site reset" -test loops: ${TEST_LOOPS}
     Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${WAIT_CHECKS}  ${WAIT_FOR_CELLS_UP}  ${OAM_KPI_TARGETS}
        ...    name=Site Reset
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Site reset
        ...    expected_pass_rate=1.0
        ...    collect_test_logs=${COLLECT_LOGS}
        ...    omkpi_case=${True}
