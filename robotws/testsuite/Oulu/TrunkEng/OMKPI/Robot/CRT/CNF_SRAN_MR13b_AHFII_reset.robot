*** Settings ***
Force Tags

Documentation
...                 Author:   Topi Pasanen
...                 Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Library          taf.sw.reporting_portal
Resource         testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource         testsuite/Oulu/TrunkEng/OMKPI/Robot/Resources/OMKPI_common.robot
Resource         testsuite/Oulu/TrunkEng/OMKPI/Robot/TestKeywords/omkpi_radio_reset.robot
Resource         testsuite/Oulu/TrunkEng/Common/Robot/TestKeywords/change_commissioning_parameters.robot
Variables        testsuite/Oulu/TrunkEng/OMKPI/Robot/Targets/TMO_MR13_AHFII_AHLOB_omkpi_targets.py

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown     Common Test Teardown

*** Variables ***
${WAIT_FOR_CELLS_UP}    300
${REPORT}               ${True}
${RMOD_TO_RESET}        RMOD-7
${KPI}                  A/B       # A/B or C
@{SYSLOG_LIST}          Detected most recent reset type was    failed to execute
...  .*processRmodUpdate: stateInfo:.*operationalState: (Disabled . availabilityStatus: NotInstalled|Enabled . availabilityStatus: Online)
@{UNALLOWED_SYSLOGS}    13 (ERPresetTypeApplicationBts)  4 (ERPresetTypeSpuriousReset)
                   ...  14 (ERPresetTypeSpuriousResetBts)  0 (ERPresetTypePowerOn)
${ALLOWED_ALARMS_FILE}  testsuite/Oulu/TrunkEng/OMKPI/allowed_alarms.txt
${WAIT_CHECKS}          30    # seconds, 0 if no waiting nor printing before post conditions check
# Collect logs variable. POssible values are: On failure/Never/Always
${COLLECT_LOGS}         Always
# How many times test will be run, needs to be more than 0
${TEST_LOOPS}           10
${REFERENCE_TESTLINE}   CNF_SRAN_MR13b


*** Test Cases ***
Automated_OAMKPI_RU_Reset
    [Documentation]  Reset user given radio and checks alarms and cell states.
    [Tags]           "Radio reset" -test loops: ${TEST_LOOPS}  # QC_553275  QCD_MN_RAN  QCP_RAN_ST
    Run Keyword If      '${KPI}' == 'C'
        ...    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${COMMISSIONING_LTE441-A_PARAMETERS}
        ...    name=Create delta file re-commissioning
        ...    test_case=Pre
        ...    loops=1
        ...    keywords=Do commissioning with delta file
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${RMOD_TO_RESET}  ${KPI}  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}
        ...    name=Reset radio
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Reset Radio
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
        ...    omkpi_case=${True}
