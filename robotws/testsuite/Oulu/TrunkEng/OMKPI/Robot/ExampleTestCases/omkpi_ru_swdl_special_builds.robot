*** Settings ***

Documentation
...   Author:   Terhi Talvitie
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Library     Collections
Library     taf.sw.reporting_portal
Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource    testsuite/Oulu/TrunkEng/OMKPI/Robot/Resources/OMKPI_common.robot
Resource    testsuite/Oulu/TrunkEng/OMKPI/Robot/TestKeywords/omkpi_rf_sw_update.robot
Variables   testsuite/Oulu/TrunkEng/OMKPI/Robot/Targets/omkpi_targets_example.py

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown     Common Test Teardown

*** Variables ***
${WAIT_FOR_CELLS_UP}     900
${REPORT}                ${False}
# to list below you can add prints that will be monitored from syslog, if print is found, it is written to eventlog
@{SYSLOG_LIST}
# to list below you can add prints that will fail the test if they are found from syslog
@{UNALLOWED_SYSLOGS}     4 (ERPresetTypeSpuriousReset)    14 (ERPresetTypeSpuriousResetBts)
# If set to ${True} makes SWDL by usin LMP connection, if set to ${False} uses S1 ip for SWDL
${LMP_SWDL}              ${True}
# Path to allowed alarms file
${ALLOWED_ALARMS_FILE}   /home/ute/MN/UTE/robotws/testsuite/Oulu/TrunkEng/OMKPI/allowed_alarms.txt
# seconds, 0 if no waiting nor printing before post conditions check
${WAIT_CHECKS}           90
# Collect logs variable. Possible values are: On failure/Never/Always
${COLLECT_LOGS}          On failure
${TEST_LOOPS}            1
${REFERENCE_TESTLINE}    ${EMPTY}

# User has manually downloaded builds to PC and wants to use them for SWDL tests
${BUILD_T1}              /home/ute/Downloads/SBTS00_ENB_9999_251008_000008_release_BTSSM_downloadable_testpackage_T1_A54.zip
${BUILD_T2}              /home/ute/Downloads/SBTS00_ENB_9999_251008_000008_release_BTSSM_downloadable_testpackage_T2_A54.zip
${ADD_KPI55E}            ${True}
${RADIO_NAME}            AEHC


*** Test Cases ***
OMKPI RU SWDL Special Builds
    [Documentation]  Builds given by user are download to BTS one by one, check that everything ok and calculate KPI.
    ...              NOTE there is no sanity checks or order checks between builds, user is responsible that correct builds are given.
    ...              SWDL order is T1, T2 and then normal build.
    ...              NOTE builds can be what ever you want to use.
    ...              NOTE you can give only one build, two builds or all three builds.
    ...              If only one build is given, only that build is downloaded to BTS and KPI calculated based on that.
    ...              If two builds are given, those two builds are downloaded to BTS and KPI calculated based on those.
    ...              If all three builds are given, all three builds are downloaded to BTS and KPI calculated based on those.
    ...              NOTE SWDL of build given in BUILD_N is in logs named to SWDL_normal,
    ...              logs of SWDL of build given in BUILD_T1 are found from logs in SWDL_T1,
    ...              logs of SWDL of build given in BUILD_T2 are found from logs in SWDL_T2.
    [Timeout]    12h
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}
        ...    name=OMKPI RU SWDL Special Builds
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Special Builds RU SWDL
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
        ...    omkpi_case=${True}
