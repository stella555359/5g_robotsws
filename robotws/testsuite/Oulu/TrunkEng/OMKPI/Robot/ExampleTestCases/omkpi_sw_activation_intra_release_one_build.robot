*** Settings ***
Documentation
...   Author:   Terhi Talvitie
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com
...   In this suite there are three test cases:
...   1. Test Case is 'OMKPI Swdl Intra Release T1' updates T1 SW to BTS and check KPIs.
...   2. Test Case is 'OMKPI Swdl Intra Release T2' updates T2 SW to BTS and check KPIs.
...   3. Test Case is 'OMKPI Swdl Intra Release Normal' updates normal SW to BTS and check KPIs.
...   As a default, if this suite is run, all packages (T1, T2 and normal) will be downloaded, all as own tests.
...   For singlerun, you can select one or more Test Cases from the drop down menu.
...   For local test, use these if you want test a single package:
...   -t "OMKPI Swdl Intra Release T1"
...   -t "OMKPI Swdl Intra Release T2"
...   -t "OMKPI Swdl Intra Release Normal"

Library     Collections
Library     taf.sw.reporting_portal
Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource    testsuite/Oulu/TrunkEng/OMKPI/Robot/Resources/OMKPI_common.robot
Resource    testsuite/Oulu/TrunkEng/OMKPI/Robot/TestKeywords/omkpi_sw_dl.robot
Variables   testsuite/Oulu/TrunkEng/OMKPI/Robot/Targets/omkpi_targets_example.py

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown     Common Test Teardown

*** Variables ***
${WAIT_FOR_CELLS_UP}    300
${REPORT}               ${True}
# to list below you can add prints that will be monitored from syslog, if print is found, it is written to eventlog
@{SYSLOG_LIST}        Detected most recent reset type was   failed to execute   FirmwareActivationColdReset   BW.bin updated
...                   status = 70426 UPDATED
# to list below you can add prints that will fail the test if they are found from syslog
@{UNALLOWED_SYSLOGS}  4 (ERPresetTypeSpuriousReset)    14 (ERPresetTypeSpuriousResetBts)
# If set to ${True} makes SWDL by usin LMP connection, if set to ${False} uses S1 ip for SWDL
${LMP_SWDL}           ${False}
# Path to allowed alarms file
${ALLOWED_ALARMS_FILE}  /home/ute/MN/UTE/robotws/testsuite/Oulu/TrunkEng/OMKPI/allowed_alarms.txt
# seconds, 0 if no waiting nor printing before post conditions check
${WAIT_CHECKS}          0
# Collect logs variable. Possible values are: On failure/Never/Always
${COLLECT_LOGS}         On failure
${TEST_LOOPS}           1
${REFERENCE_TESTLINE}   ${EMPTY}

*** Test Cases ***
OMKPI Swdl Intra Release T1
    [Documentation]  Get the name of active SW and get T1 build of the tested SW from artifactory and download the
    ...               package to BTS, check that everything ok and calculate KPI.
    Set Suite Variable  ${ONE_BUILD}  T1
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}   ${LMP_SWDL}    ${OAM_KPI_TARGETS}
        ...    kpi 2c or 2d   ${ONE_BUILD}
        ...    name=OMKPI Swdl Intra Release one build
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=OMKPI SW DL One Package
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
        ...    omkpi_case=${True}

OMKPI Swdl Intra Release T2
    [Documentation]  Get the name of active SW and get T2 build of the tested SW from artifactory and download the
    ...               package to BTS, check that everything ok and calculate KPI.
    Set Suite Variable  ${ONE_BUILD}  T2
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}   ${LMP_SWDL}    ${OAM_KPI_TARGETS}
        ...    kpi 2c or 2d   ${ONE_BUILD}
        ...    name=OMKPI Swdl Intra Release one build
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=OMKPI SW DL One Package
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
        ...    omkpi_case=${True}

OMKPI Swdl Intra Release Normal
    [Documentation]  Get the name of active SW and get normal build of the tested SW from artifactory and download the
    ...               package to BTS, check that everything ok and calculate KPI.
    Set Suite Variable  ${ONE_BUILD}  normal
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}   ${LMP_SWDL}    ${OAM_KPI_TARGETS}
        ...    kpi 2c or 2d   ${ONE_BUILD}
        ...    name=OMKPI Swdl Intra Release one build
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=OMKPI SW DL One Package
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
        ...    omkpi_case=${True}
