*** Settings ***
Force Tags        SCFC_ADJUSTMENTS=Adhoc.yml

Documentation
...   Author:   Heikki Autio
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Library     Collections
Library          taf.sw.reporting_portal
Resource         testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource         testsuite/Oulu/TrunkEng/OMKPI/Robot/Resources/OMKPI_common.robot
Library          testsuite.Oulu.TrunkEng.OMKPI.Python.Interfaces.OmkpiCommonInterface
Library          testsuite.Oulu.TrunkEng.OMKPI.Python.Interfaces.OmkpiCommissioningInterface
Resource         testsuite/Oulu/TrunkEng/OMKPI/Robot/TestKeywords/omkpi_rat_reset.robot
Variables        testsuite/Oulu/TrunkEng/OMKPI/Robot/Targets/Startup_omkpi_targets.py

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown     Common Test Teardown

*** Variables ***
${WAIT_FOR_CELLS_UP}    1000
${REPORT}               ${False}
# RAT_TO_RESET can have values: NR, LTE, WCDMA, GSM
${RAT_TO_RESET}         LTE
# Reset type can have values: Soft, Hard
${RESET_TYPE}           Soft
# KPI can be one of the following: LTE: KPI#7, KPI#7a (Soft), KPI#7b. NR: KPI#10
${KPI}                  KPI#7
@{SYSLOG_LIST}
@{UNALLOWED_SYSLOGS}    13 (ERPresetTypeApplicationBts)  4 (ERPresetTypeSpuriousReset)
                   ...  14 (ERPresetTypeSpuriousResetBts)  0 (ERPresetTypePowerOn)
# Path to allowed alarms file
${ALLOWED_ALARMS_FILE}  /home/ute/MN/UTE/robotws/testsuite/Oulu/TrunkEng/OMKPI/allowed_alarms.txt
${WAIT_CHECKS}          60
# Collect logs variable. POssible values are: On failure/Never/Always
${COLLECT_LOGS}         On failure
${TEST_LOOPS}           25
${REFERENCE_TESTLINE}   ${EMPTY}

*** Test Cases ***
Automated_Startup_LTE_RAT_Reset
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