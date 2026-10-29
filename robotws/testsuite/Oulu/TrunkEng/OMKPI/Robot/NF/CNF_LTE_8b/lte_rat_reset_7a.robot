*** Settings ***
Force Tags          CLOUD_FR4A_x_AA_[1][1]_[AHBCC][AHBCC]_ASIAA

Documentation
...                 Author:   Topi Pasanen
...                 Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com
...                           KPI#7 - Manual LTE RAT reset downtime

Library           Collections
Library           taf.sw.reporting_portal
Resource          testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource          testsuite/Oulu/TrunkEng/OMKPI/Robot/Resources/OMKPI_common.robot
Library           testsuite.Oulu.TrunkEng.OMKPI.Python.Interfaces.OmkpiCommonInterface
Library           testsuite.Oulu.TrunkEng.OMKPI.Python.Interfaces.OmkpiCommissioningInterface
Resource          testsuite/Oulu/TrunkEng/OMKPI/Robot/TestKeywords/omkpi_rat_reset.robot
Variables         testsuite/Oulu/TrunkEng/OMKPI/Robot/Targets/CNF_LTE_8b_omkpi_targets.py

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown     Common Test Teardown

*** Variables ***
${WAIT_FOR_CELLS_UP}    300
${REPORT}               ${True}
# RAT_TO_RESET can have values: NR, LTE, WCDMA, GSM
${RAT_TO_RESET}         LTE
# Reset type can have values: Soft, Hard
${RESET_TYPE}           Soft
# KPI can be one of the following: LTE: KPI#7, KPI#7a (Soft), KPI#7b. NR: KPI#10
${KPI}                  KPI#7a
# to list below you can add prints that will be monitored from syslog, if print is found, it is written to eventlog
@{SYSLOG_LIST}
# to list below you can add prints that will fail the test if they are found from syslog
@{UNALLOWED_SYSLOGS}    13 (ERPresetTypeApplicationBts)  4 (ERPresetTypeSpuriousReset)
                   ...  14 (ERPresetTypeSpuriousResetBts)  0 (ERPresetTypePowerOn)
# Path to allowed alarms file
${ALLOWED_ALARMS_FILE}  /home/ute/MN/UTE/robotws/testsuite/Oulu/TrunkEng/OMKPI/allowed_alarms.txt
${WAIT_CHECKS}          90    # seconds, 0 if no waiting nor printing before post conditions check
# Collect logs variable. POssible values are: On failure/Never/Always
${COLLECT_LOGS}         Always
# How many times test will be run, needs to be more than 0
${REFERENCE_TESTLINE}   CNF_LTE_8b
${TEST_LOOPS}           10

${ZIP_LOGS}             ${True}

*** Test Cases ***
Automated_OAMKPI_LTE_RAT_Reset
    [Documentation]  Reset user given RAT and checks alarms and cell states.
    [Tags]           "RAT reset" -test loops: ${TEST_LOOPS}
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${RAT_TO_RESET}  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${RESET_TYPE}  ${KPI}
        ...    name=Reset RAT
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=RAT Reset
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
        ...    omkpi_case=${True}
