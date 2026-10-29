*** Settings ***
Force Tags

Documentation
...   Author:   Heikki Autio
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Library     Collections
Library     taf.sw.reporting_portal
Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource    testsuite/Oulu/TrunkEng/OMKPI/Robot/Resources/OMKPI_common.robot
Resource    testsuite/Oulu/TrunkEng/OMKPI/Robot/TestKeywords/omkpi_sw_dl.robot
Variables   testsuite/Oulu/TrunkEng/OMKPI/Robot/Targets/CNF_LTE_17_omkpi_targets.py

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown     Common Test Teardown

*** Variables ***
${WAIT_FOR_CELLS_UP}    800
${REPORT}               ${True}
# to list below you can add prints that will be monitored from syslog, if print is found, it is written to eventlog
@{SYSLOG_LIST}        FirmwareActivationColdReset   BW.bin updated
...                   status = 70426 UPDATED
# to list below you can add prints that will fail the test if they are found from syslog
@{UNALLOWED_SYSLOGS}  4 (ERPresetTypeSpuriousReset)    14 (ERPresetTypeSpuriousResetBts)
# Release
${RELEASE}
${PROMOTION_TAG}
# Path to allowed alarms file
${ALLOWED_ALARMS_FILE}  /home/ute/MN/UTE/robotws/testsuite/Oulu/TrunkEng/OMKPI/allowed_alarms.txt
# seconds, 0 if no waiting nor printing before post conditions check
${WAIT_CHECKS}          90
# If True saves SW build to pc before uploading it to BTS. If False uses link to SW build for uploading
# NOTE saves 10min if build is not saved on PC
${SAVE_BUILD_TO_PC}     ${True}
# Collect logs variable. Possible values are: On failure/Never/Always
${COLLECT_LOGS}         Always
${TEST_LOOPS}           3
${REFERENCE_TESTLINE}   CNF_LTE_17

${ZIP_LOGS}             ${True}
${LMP_SWDL}             ${True}

*** Test Cases ***
Automated_OAMKPI_SW_Activation_Intra-release
    [Documentation]  Get the name of active SW or triggering SW and get T1, T2 and normal build of the tested SW
    ...              from artifactory and download those to BTS one by one, check that everything ok and calculate KPI.
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${SAVE_BUILD_TO_PC}  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}
        ...    ${RELEASE}  ${PROMOTION_TAG}  ${LMP_SWDL}  ${OAM_KPI_TARGETS}  kpi 2c or 2d
        ...    name=OMKPI Sw Activation Intra Release
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=OMKPI SW DL
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
        ...    omkpi_case=${True}

