*** Settings ***
Force Tags          CLOUD_FR4_L_A_[111111]_[FXCA(+FHDB)_FXCA(+FHDB)_FXCA(+FHDB)_AHFB_AHEB_AHCA]_FHS

Documentation
...   Author:   Lauri Lehtoaho
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Library           taf.sw.reporting_portal
Library           Collections
Resource          testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource          testsuite/Oulu/TrunkEng/OMKPI/Robot/Resources/OMKPI_common.robot
Resource          testsuite/Oulu/TrunkEng/OMKPI/Robot/TestKeywords/omkpi_fhs_reset.robot
Variables         testsuite/Oulu/TrunkEng/OMKPI/Robot/Targets/CNF_LTE_11b_omkpi_targets.py

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown     Common Test Teardown

*** Variables ***
${WAIT_FOR_CELLS_UP}    300
${REPORT}               ${True}
# Name of FHS to be reset
${FHS_TO_RESET}        FHS1
# to list below you can add prints that will be monitored from syslog, if print is found, it is written to eventlog
# NOTE also regex can be used
@{SYSLOG_LIST}          Detected most recent reset type was    failed to execute
# to list below you can add prints that will fail the test if they are found from syslog
@{UNALLOWED_SYSLOGS}    13 (ERPresetTypeApplicationBts)  4 (ERPresetTypeSpuriousReset)
                   ...  14 (ERPresetTypeSpuriousResetBts)
# Path to allowed alarms file
${ALLOWED_ALARMS_FILE}  testsuite/Oulu/TrunkEng/OMKPI/allowed_alarms.txt
${WAIT_CHECKS}          60    # seconds, 0 if no waiting nor printing before post conditions check
# Collect logs variable. POssible values are: On failure/Never/Always
${COLLECT_LOGS}         On failure
# How many times test will be run, needs to be more than 0
${TEST_LOOPS}           25
${REFERENCE_TESTLINE}   CNF_LTE_11b

*** Test Cases ***
Automated_OAMKPI_FHS_Reset
    [Documentation]  Reset user given FHS and checks alarms and cell states.
    [Tags]           "FHS reset" -test loops: ${TEST_LOOPS}  # QC_689297  QCD_MN_RAN  QCP_RAN_ST
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${FHS_TO_RESET}  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}
        ...    name=Reset FHS
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Reset FHS
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
        ...    omkpi_case=${True}
