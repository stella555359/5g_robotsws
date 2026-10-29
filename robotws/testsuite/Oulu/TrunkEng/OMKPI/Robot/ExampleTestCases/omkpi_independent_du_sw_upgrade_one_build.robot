*** Settings ***
Documentation
...   Author:   Terhi Talvitie
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com
...   In this suite there are three test cases:
...   1. Test Case is 'OMKPI Independent Du Sw Upgrade T1' updates T1 SW to RU and then to DU and check KPIs.
...   2. Test Case is 'OMKPI Independent Du Sw Upgrade T2' updates T2 SW to RU and then to DU and check KPIs.
...   3. Test Case is 'OMKPI Swdl Intra Release Normal' updates normal SW to RU and then to DU and check KPIs.
...   As a default, if this suite is run, all packages (T1, T2 and normal) will be downloaded, all as own tests.
...   For singlerun, you can select one or more Test Cases from the drop down menu.
...   For local test, use these if you want test a single package:
...   -t "OMKPI Independent Du Sw Upgrade T1"
...   -t "OMKPI Independent Du Sw Upgrade T2"
...   -t "OMKPI Independent Du Sw Upgrade Normal"

Library     Collections
Library     taf.sw.reporting_portal
Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource    testsuite/Oulu/TrunkEng/OMKPI/Robot/Resources/OMKPI_common.robot
Resource    testsuite/Oulu/TrunkEng/OMKPI/Robot/TestKeywords/omkpi_rf_sw_update.robot
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
# RU_SWDL has to be True so RU SWDL will be done before DU SWDL
${RU_SWDL}              ${True}
# This variable can have value:
# "Independent Manual DU SW Activation" then selected KPI is parsed in test (inter/intra, is firmware updated/not updated).
# User can also give hard coded KPI, some of these:
#   "Manual DU Inter-release SW activation downtime without firmware update downtime"
#   "Manual DU Inter-release SW activation downtime with firmware update downtime"
#   "Manual DU Intra-release SW activation downtime without firmware update downtime"
#   "Manual DU Intra-release SW activation downtime with firmware update downtime"
${TESTED_KPI}            Independent Manual DU SW Activation

*** Test Cases ***
OMKPI Independent Du Sw Upgrade T1
    [Documentation]  Get T1 BTS build from artifactory. First do RU upgrade to T1 then DU upgrade to T1.
    ...              Check that everything ok and calculate KPI (${TESTED_KPI}).
    Set Suite Variable  ${ONE_BUILD}  T1
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}   ${LMP_SWDL}    ${OAM_KPI_TARGETS}
        ...    ${TESTED_KPI}   ${ONE_BUILD}
        ...    name=Independent Du Sw Upgrade one build T1
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=OMKPI SW DL One Package
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
        ...    omkpi_case=${True}

OMKPI Independent Du Sw Upgrade T2
    [Documentation]  Get T2 BTS build from artifactory. First do RU upgrade to T2 then DU upgrade to T2.
    ...              Check that everything ok and calculate KPI (${TESTED_KPI}).
    Set Suite Variable  ${ONE_BUILD}  T2
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}   ${LMP_SWDL}    ${OAM_KPI_TARGETS}
        ...    ${TESTED_KPI}   ${ONE_BUILD}
        ...    name=Independent Du Sw Upgrade one build T2
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=OMKPI SW DL One Package
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
        ...    omkpi_case=${True}

OMKPI Independent Du Sw Upgrade Normal
    [Documentation]  Get BTS build from artifactory. First do RU upgrade to the build then DU upgrade to the build.
    ...              Check that everything ok and calculate KPI (${TESTED_KPI}).
    Set Suite Variable  ${ONE_BUILD}  normal
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}   ${LMP_SWDL}    ${OAM_KPI_TARGETS}
        ...    ${TESTED_KPI}   ${ONE_BUILD}
        ...    name=Independent Du Sw Upgrade one build
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=OMKPI SW DL One Package
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
        ...    omkpi_case=${True}