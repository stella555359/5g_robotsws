*** Settings ***
Force Tags          CLOUD_FR4_ASOH_[11]_[AHEH_AHEH]

Documentation
...   Author:   Heikki Autio
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com
...             KPI#12 - CM activation with site reset downtime

Library           Collections
Library           taf.sw.reporting_portal
Resource          testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource          testsuite/Oulu/TrunkEng/OMKPI/Robot/Resources/OMKPI_common.robot
Library           testsuite.Oulu.TrunkEng.OMKPI.Python.Interfaces.OmkpiCommissioningInterface  WITH NAME  OmkpiCommissioningInterface
Resource          testsuite/Oulu/TrunkEng/OMKPI/Robot/TestKeywords/omkpi_commissioning_reset.robot
Resource          testsuite/Oulu/TrunkEng/Common/Robot/TestKeywords/change_commissioning_parameters.robot
Variables         testsuite/Oulu/TrunkEng/OMKPI/Robot/Targets/CNF_LTE_16_omkpi_targets.py

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown     Common Test Teardown

*** Variables ***
${PARAMETER}            actTimeErrorManagement
${WAIT_FOR_CELLS_UP}    400
${REPORT}               ${True}
# to list below you can add prints that will be monitored from syslog, if print is found, it is written to eventlog
# NOTE also regex can be used
@{SYSLOG_LIST}
# to list below you can add prints that will fail the test if they are found from syslog
@{UNALLOWED_SYSLOGS}    13 (ERPresetTypeApplicationBts)  4 (ERPresetTypeSpuriousReset)
                   ...  14 (ERPresetTypeSpuriousResetBts)  0 (ERPresetTypePowerOn)
# Path to allowed alarms file
${ALLOWED_ALARMS_FILE}  testsuite/Oulu/TrunkEng/OMKPI/allowed_alarms.txt
# Collect logs variable. POssible values are: On failure/Never/Always
${COLLECT_LOGS}         Always
# How many times test will be run, needs to be more than 0
${TEST_LOOPS}           5
${REFERENCE_TESTLINE}   CNF_LTE_16
${ZIP_LOGS}             ${True}

*** Test Cases ***
Automated_OAMKPI_CM_Activation
    [Documentation]  Commissioning reset
    [Tags]           "Commissioning reset" -test loops: ${TEST_LOOPS}
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${PARAMETER}  ${WAIT_FOR_CELLS_UP}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}
        ...    name=Commissioning reset
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Commissioning reset
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
        ...    omkpi_case=${True}
