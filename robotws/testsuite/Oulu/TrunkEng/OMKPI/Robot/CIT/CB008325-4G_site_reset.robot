*** Settings ***
Force Tags          CLOUD_FR4L_x_PP_[11][1]_[AHEGB_AHEGB][AHEGB]_UE

Documentation
...   Author:   Lauri Lehtoaho
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Library          taf.sw.reporting_portal
Resource         testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource         testsuite/Oulu/TrunkEng/OMKPI/Robot/Resources/OMKPI_common.robot
Resource         testsuite/Oulu/TrunkEng/OMKPI/Robot/TestKeywords/omkpi_site_reset.robot
Variables        testsuite/Oulu/TrunkEng/OMKPI/Robot/Targets/CB008325-4G_omkpi_targets.py
Library          testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Marvin  WITH NAME  Marvin

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown     Common Test Teardown

*** Variables ***
${WAIT_FOR_CELLS_UP}        600
# Collect logs variable. Possible values are: On failure/Never/Always
${COLLECT_LOGS}             On failure
# How many times test will be run, needs to be more than 0
${TEST_LOOPS}               10
${REFERENCE_TESTLINE}       ${EMPTY}
${ALLOWED_ALARMS_FILE}      testsuite/Oulu/TrunkEng/OMKPI/allowed_alarms.txt
${REPORT}                   ${False}
@{SYSLOG_LIST}
@{UNALLOWED_SYSLOGS}        4 (ERPresetTypeSpuriousReset)    14 (ERPresetTypeSpuriousResetBts)  Please contact owner of
${WAIT_CHECKS}              30    # seconds, 0 if no waiting nor printing before post conditions check
${MARVIN_REF_RUN_ID}        9cd3353a-e20f-4d1b-b958-fd9c991785f8
${MARVIN_REF_CASE_ID}       1c55f790-af2e-4f78-8029-4144ad833afd
${UE_IN_USE}                ${True}
${gnb_trace_profile}        dcap-lite-full

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
