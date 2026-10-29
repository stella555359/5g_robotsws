*** Settings ***
Documentation
...   Author:   Terhi Talvitie
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Library     Collections
Library     taf.sw.reporting_portal
Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource    testsuite/Oulu/TrunkEng/OMKPI/Robot/Resources/OMKPI_common.robot
Resource    testsuite/Oulu/TrunkEng/OMKPI/Robot/TestKeywords/omkpi_rf_sw_update.robot
Resource    testsuite/Oulu/TrunkEng/OMKPI/Robot/TestKeywords/omkpi_ru_sw_update_one_package.robot
Variables   testsuite/Oulu/TrunkEng/OMKPI/Robot/Targets/CNF_LTE_12_omkpi_targets.py

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown     Common Test Teardown

*** Variables ***
# This ONE_BUILD variable can have value T1, T2 or normal. The given package is downloaded to RUs.
${ONE_BUILD}            T1
${WAIT_FOR_CELLS_UP}    800
${REPORT}               ${True}
# to list below you can add prints that will be monitored from syslog, if print is found, it is written to eventlog
@{SYSLOG_LIST}          FirmwareActivationColdReset   BW.bin updated
...                     status = 70426 UPDATED
# to list below you can add prints that will fail the test if they are found from syslog
@{UNALLOWED_SYSLOGS}    4 (ERPresetTypeSpuriousReset)    14 (ERPresetTypeSpuriousResetBts)

# Path to allowed alarms file
${ALLOWED_ALARMS_FILE}  /home/ute/MN/UTE/robotws/testsuite/Oulu/TrunkEng/OMKPI/allowed_alarms.txt
# seconds, 0 if no waiting nor printing before post conditions check
${WAIT_CHECKS}          90

# Collect logs variable. Possible values are: On failure/Never/Always
${COLLECT_LOGS}         Always
${TEST_LOOPS}           1
${REFERENCE_TESTLINE}   ${EMPTY}

*** Test Cases ***
OMKPI RU Sw Update T1 Package
    [Documentation]  Get the RF SW to be downloaded from the SBTS SW builds. Do SWDL of given package to radios.
    ...              This test case is used to update SW to RF units and check KPIs.
    ...              Procedure introduced in 24R3-SR with CB010779.
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${ONE_BUILD}
        ...    name=OMKPI Rf Sw Update
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=OMKPI RU SW Update One Package
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
        ...    omkpi_case=${True}

OMKPI RU Sw Update T2 Package
    [Documentation]  Get the RF SW to be downloaded from the SBTS SW builds. Do SWDL of given package to radios.
    ...              This test case is used to update SW to RF units and check KPIs.
    ...              Procedure introduced in 24R3-SR with CB010779.
    Set Suite Variable    ${ONE_BUILD}    T2
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${ONE_BUILD}
        ...    name=OMKPI Rf Sw Update
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=OMKPI RU SW Update One Package
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
        ...    omkpi_case=${True}

OMKPI RU Sw Update Normal Package
    [Documentation]  Get the RF SW to be downloaded from the SBTS SW builds. Do SWDL of given package to radios.
    ...              This test case is used to update SW to RF units and check KPIs.
    ...              Procedure introduced in 24R3-SR with CB010779.
    Set Suite Variable    ${ONE_BUILD}    normal
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${ONE_BUILD}
        ...    name=OMKPI Rf Sw Update
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=OMKPI RU SW Update One Package
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
        ...    omkpi_case=${True}
