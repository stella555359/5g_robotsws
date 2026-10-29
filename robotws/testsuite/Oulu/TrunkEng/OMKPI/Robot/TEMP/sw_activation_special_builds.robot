*** Settings ***

Documentation
...   Author:   Heikki Autio
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Library     Collections
Library     taf.sw.reporting_portal
Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource    testsuite/Oulu/TrunkEng/OMKPI/Robot/Resources/OMKPI_common.robot
Resource    testsuite/Oulu/TrunkEng/OMKPI/Robot/TestKeywords/omkpi_sw_dl.robot
Variables   testsuite/Oulu/TrunkEng/OMKPI/Robot/Targets/Adhoc_omkpi_targets.py

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown     Common Test Teardown

*** Variables ***
${WAIT_FOR_CELLS_UP}     600
${REPORT}                ${True}
# to list below you can add prints that will be monitored from syslog, if print is found, it is written to eventlog
@{SYSLOG_LIST}           FirmwareActivationColdReset   BW.bin updated
...                      status = 70426 UPDATED
# to list below you can add prints that will fail the test if they are found from syslog
@{UNALLOWED_SYSLOGS}     4 (ERPresetTypeSpuriousReset)    14 (ERPresetTypeSpuriousResetBts)
# Promotion tag that is used to get the promoted build
${PROMOTION_TAG}         REGRESSION
# Release is a branch that is used as an older build to which it is always rolled back before new build is uploaded to bts
# If ${RELEASE} is same that is active on BTS makes intra sw activation, otherwise inter activation
${RELEASE}               SBTS00
# If set to ${True} makes SWDL by usin LMP connection, if set to ${False} uses S1 ip for SWDL
${LMP_SWDL}              ${False}
# Path to allowed alarms file
${ALLOWED_ALARMS_FILE}   /home/ute/MN/UTE/robotws/testsuite/Oulu/TrunkEng/OMKPI/allowed_alarms.txt
# seconds, 0 if no waiting nor printing before post conditions check
${WAIT_CHECKS}           90
# If True saves SW build to pc before uploading it to BTS. If False uses link to SW build for uploading
# NOTE saves 10min if build is not saved on PC
${SAVE_BUILD_TO_PC}      ${True}
# Collect logs variable. Possible values are: On failure/Never/Always
${COLLECT_LOGS}          On failure
${TEST_LOOPS}            1
${REFERENCE_TESTLINE}    ${EMPTY}
# User has manually downloaded builds to PC and wants to use them for SWDL tests
${NO_BUILD_PATH_UPDATE}  ${True}
${BUILD_N}               /home/ute/Downloads/SBTS00_ENB_9999_240826_1261132_release_BTSSM_downloadable_A54.zip
${BUILD_T1}              /home/ute/Downloads/SBTS00_ENB_9999_240826_1261132_release_BTSSM_downloadable_testpackage_T1_A54.zip
${BUILD_T2}              /home/ute/Downloads/SBTS00_ENB_9999_240826_1261132_release_BTSSM_downloadable_testpackage_T2_A54.zip
# This KPI_TO_BE_TESTED variable can be used to calculate desired SWDL KPI values. Value can be for example:
# 2c or 2d
# 2a or 2b
# Sw inter activation without firmware update
# Sw intra activation without firmware update
# Sw inter activation with firmware update
# Sw intra activation with firmware update
# Inter-release SW activation downtime without firmware update
# Inter-release SW activation downtime with firmware updates
# Complete upgrade
${KPI_TO_BE_TESTED}      Complete upgrade

*** Test Cases ***
OMKPI Sw Activation Intra Special Builds
    [Documentation]  Builds given by user are download to BTS one by one, check that everything ok and calculate KPI.
    ...              NOTE SWDL of build given in BUILD_N is in logs named to SWDL_normal,
    ...              logs of SWDL of build given in BUILD_T1 are found from logs in SWDL_T1,
    ...              logs of SWDL of build given in BUILD_T2 are found from logs in SWDL_T2.
    ...              NOTE builds can be what ever you want to use. NOTE if SW active on BTS is different than given builds,
    ...              Rollbacks between SWDLs are made.
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${SAVE_BUILD_TO_PC}  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}
        ...    ${RELEASE}  ${PROMOTION_TAG}  ${LMP_SWDL}  ${OAM_KPI_TARGETS}  ${KPI_TO_BE_TESTED}
        ...    name=OMKPI Sw Activation Special Builds
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=OMKPI SW DL
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
        ...    omkpi_case=${True}
