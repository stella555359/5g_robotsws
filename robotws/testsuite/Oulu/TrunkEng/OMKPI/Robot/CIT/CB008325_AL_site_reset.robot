*** Settings ***
Documentation
...                 Author:   Lauri Lehtoaho
...                 Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Library          Collections
Library          taf.sw.reporting_portal
Resource         testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource         testsuite/Oulu/TrunkEng/OMKPI/Robot/Resources/OMKPI_common.robot
Library          testsuite.Oulu.TrunkEng.OMKPI.Python.Interfaces.OmkpiStartupTimesInterface  WITH NAME  Startup
Resource         testsuite/Oulu/TrunkEng/OMKPI/Robot/TestKeywords/omkpi_site_reset.robot
Variables        testsuite/Oulu/TrunkEng/OMKPI/Robot/Targets/CB008325_AL_omkpi_targets.py
Library          testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Marvin  WITH NAME  Marvin

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown     Common Test Teardown

*** Variables ***
${WAIT_FOR_CELLS_UP}        300
# Collect logs variable. Possible values are: On failure/Never/Always
${COLLECT_LOGS}             On failure
# How many times test will be run, needs to be more than 0
${TEST_LOOPS}               10
${REFERENCE_TESTLINE}       CB008325_AL
${ALLOWED_ALARMS_FILE}      testsuite/Oulu/TrunkEng/OMKPI/allowed_alarms.txt
${REPORT}                   ${True}
@{SYSLOG_LIST}
@{UNALLOWED_SYSLOGS}        4 (ERPresetTypeSpuriousReset)    14 (ERPresetTypeSpuriousResetBts)  Please contact owner of
${WAIT_CHECKS}              60    # seconds, 0 if no waiting nor printing before post conditions check
${UE_IN_USE}                ${True}
${MARVIN_REF_CASE_ID}      695445dd-16e1-4b9b-80c9-9c9b3f277263
${MARVIN_REF_RUN_ID}       6316b56b-431e-4257-9ea5-77dd1568b09c
${E2E_CHECKPOINTS}         ${True}
${gnb_trace_profile}       dcap-lite-full

*** Test Cases ***
Automated_OAMKPI_Site_Reset
    [Tags]  "Site reset" -test loops: ${TEST_LOOPS}  QC_689306  QCD_MN_RAN  QCP_RAN_ST
    [Documentation]  Perform site reset and collect KPI results.

#    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
#        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${FLAG_VALUE}  ${ADD_FLAG}  ${TEXT_TO_STEP}
#        ...    name=Add flag to swconfig
#        ...    test_case=1
#        ...    loops=1
#        ...    keywords=Change flag to swconfig
#        ...    expected_pass_rate=1
#        ...    collect_test_logs=${COLLECT_LOGS}

     Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${WAIT_CHECKS}  ${WAIT_FOR_CELLS_UP}  ${OAM_KPI_TARGETS}
        ...    name=Site Reset
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Site reset
        ...    expected_pass_rate=1.0
        ...    collect_test_logs=${COLLECT_LOGS}
        ...    omkpi_case=${True}
