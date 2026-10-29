*** Settings ***
Force Tags

Documentation
...   Author:   Heikki Autio
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com
...             KPI#51a - Manual RU reset downtime
...             KPI#51b - Manual RU reset downtime

Library           taf.sw.reporting_portal
Library           Collections
Resource          testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource          testsuite/Oulu/TrunkEng/OMKPI/Robot/Resources/OMKPI_common.robot
Resource          testsuite/Oulu/TrunkEng/OMKPI/Robot/TestKeywords/omkpi_radio_reset.robot
Resource          testsuite/Oulu/TrunkEng/Common/Robot/TestKeywords/change_commissioning_parameters.robot
Variables         testsuite/Oulu/TrunkEng/OMKPI/Robot/Targets/CNF_LTE_17_omkpi_targets.py

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown     Common Test Teardown

*** Variables ***
&{COMMISSIONING_LTE441-A_PARAMETERS}

${WAIT_FOR_CELLS_UP}    600
${REPORT}               ${True}
# Now given as in commissioning (last part of rmod name). You can also give RCI (Radio Configuration Identifier):
# (1.1.1.1), (1.2.1.1)... or as seen in hw_path or in short style r1, r2 more
# in https://jiradc.ext.net.nokia.com/browse/FCA_TATSCRIPTS-181738
${RMOD_TO_RESET}           RMOD-1
${KPI}                  A/B       # A/B or C
# to list below you can add prints that will be monitored from syslog, if print is found, it is written to eventlog
# NOTE also regex can be used
@{SYSLOG_LIST}
# to list below you can add prints that will fail the test if they are found from syslog
@{UNALLOWED_SYSLOGS}    13 (ERPresetTypeApplicationBts)  4 (ERPresetTypeSpuriousReset)
                   ...  14 (ERPresetTypeSpuriousResetBts)  0 (ERPresetTypePowerOn)
# Path to allowed alarms file
${ALLOWED_ALARMS_FILE}  testsuite/Oulu/TrunkEng/OMKPI/allowed_alarms.txt
${WAIT_CHECKS}          90    # seconds, 0 if no waiting nor printing before post conditions check
# Collect logs variable. Possible values are: On failure/Never/Always
${COLLECT_LOGS}         Always
# How many times test will be run, needs to be more than 0
${TEST_LOOPS}           10
${REFERENCE_TESTLINE}   CNF_LTE_17

${ZIP_LOGS}             ${True}

*** Test Cases ***
Automated_OAMKPI_RU_Reset
    [Documentation]  Reset user given radio and checks alarms and cell states.
    [Tags]           "Radio reset" -test loops: ${TEST_LOOPS}  # QC_320863  QCD_MN_RAN  QCP_RAN_ST
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
