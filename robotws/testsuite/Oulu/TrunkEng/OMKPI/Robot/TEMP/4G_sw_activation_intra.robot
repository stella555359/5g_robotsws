*** Settings ***
Documentation
...   Author:   Heikki Autio
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Library     Collections
Library     taf.sw.reporting_portal
Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource    testsuite/Oulu/TrunkEng/OMKPI/Robot/Resources/OMKPI_common.robot
Resource    testsuite/Oulu/TrunkEng/OMKPI/Robot/TestKeywords/omkpi_sw_activation_intra.robot
Variables   testsuite/Oulu/TrunkEng/OMKPI/Robot/Targets/omkpi_targets_example.py

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown     Common Test Teardown

*** Variables ***
${WAIT_FOR_CELLS_UP}    500
${REPORT}               ${False}
# to list below you can add prints that will be monitored from syslog, if print is found, it is written to eventlog
@{SYSLOG_LIST}        Detected most recent reset type was   failed to execute   FirmwareActivationColdReset   BW.bin updated
...                   status = 70426 UPDATED
# to list below you can add prints that will fail the test if they are found from syslog
@{UNALLOWED_SYSLOGS}  4 (ERPresetTypeSpuriousReset)    14 (ERPresetTypeSpuriousResetBts)
# Release
${RELEASE}            SBTS00
# Path to allowed alarms file
${ALLOWED_ALARMS_FILE}  /home/ute/MN/UTE/robotws/testsuite/Oulu/TrunkEng/OMKPI/allowed_alarms.txt
# seconds, 0 if no waiting nor printing before post conditions check
${WAIT_CHECKS}          0
# If True saves SW build to pc before uploading it to BTS. If False uses link to SW build for uploading
# NOTE saves 10min if build is not saved on PC
${SAVE_BUILD_TO_PC}     ${True}
# Collect logs variable. Possible values are: On failure/Never/Always
${COLLECT_LOGS}         Always
${TEST_LOOPS}           1
${REFERENCE_TESTLINE}   ${EMPTY}

*** Test Cases ***
OMKPI Sw Activation Intra
    [Documentation]  Get T1, T2 and normal build from artifactory and download those to BTS one by one, check that everything ok.
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${SAVE_BUILD_TO_PC}  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${RELEASE}
        ...    name=OMKPI Sw activation intra
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Omkpi Sw Activation Intra
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
        ...    omkpi_case=${True}