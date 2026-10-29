*** Settings ***
Force Tags      CLOUD_5G_CLASSICAL_ASIL_2xABIO_3xAHCA_3xAEQK_3xAHFIB_RFS

Documentation
...   Author:   Heikki Autio
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Library     Collections
Library     taf.sw.reporting_portal
Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource    testsuite/Oulu/TrunkEng/OMKPI/Robot/Resources/OMKPI_common.robot
Resource    testsuite/Oulu/TrunkEng/OMKPI/Robot/TestKeywords/omkpi_sw_dl.robot
Variables   testsuite/Oulu/TrunkEng/OMKPI/Robot/Targets/CNF_RFS_2_omkpi_targets.py

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown     Common Test Teardown

*** Variables ***
${WAIT_FOR_CELLS_UP}    1600
${REPORT}               ${True}
# to list below you can add prints that will be monitored from syslog, if print is found, it is written to eventlog
@{SYSLOG_LIST}
# to list below you can add prints that will fail the test if they are found from syslog
@{UNALLOWED_SYSLOGS}  4 (ERPresetTypeSpuriousReset)    14 (ERPresetTypeSpuriousResetBts)
# Promotion tag that is used to get the promoted build
${PROMOTION_TAG}      REGRESSION
# Release is a branch that is used in inter tests for an older build to which it is always rolled back before new build is uploaded to bts
# If you want to run Intra test, select same release that is active in BTS
${RELEASE}            SBTS00
# If set to ${True} makes SWDL by usin LMP connection, if set to ${False} uses S1 ip for SWDL
${LMP_SWDL}           ${True}
# Path to allowed alarms file
${ALLOWED_ALARMS_FILE}  /home/ute/MN/UTE/robotws/testsuite/Oulu/TrunkEng/OMKPI/allowed_alarms.txt
# seconds, 0 if no waiting nor printing before post conditions check
${WAIT_CHECKS}          180
# If True saves SW build to pc before uploading it to BTS. If False uses link to SW build for uploading
# NOTE saves 10min if build is not saved on PC
${SAVE_BUILD_TO_PC}     ${True}
${COLLECT_LOGS}         Always
${TEST_LOOPS}           3
${REFERENCE_TESTLINE}   CNF_RFS_2
@{ALLOWED_ALARMS}       1898  6327
${RFS}                  ${True}
${MASTER}               Other
${ZIP_LOGS}             ${True}
${FAULT_CAUSE_DEGRADED_CELLS}  1898
${NO_MARVIN}          True

*** Test Cases ***
Automated_OAMKPI_SW_Complete_Upgrade
    [Timeout]  16h
    [Documentation]  Get T1, T2 and normal build from artifactory and download those to BTS one by one, check that everything ok.
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${SAVE_BUILD_TO_PC}  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}
        ...    ${RELEASE}  ${PROMOTION_TAG}  ${LMP_SWDL}  ${OAM_KPI_TARGETS}  Complete upgrade
        ...    name=OMKPI Complete upgrade intra
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=OMKPI SW DL
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
        ...    omkpi_case=${True}
