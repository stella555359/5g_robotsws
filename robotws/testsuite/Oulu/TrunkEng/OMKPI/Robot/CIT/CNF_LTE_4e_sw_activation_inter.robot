*** Settings ***
Force Tags        CLOUD_FR4_L_3A_4xFXEB_4xFRGT_4xFXCA_4xFRHG
...                SCFC_ADJUSTMENTS=CNF_4d_adjustments.yml
...             CELL_CONFIG=[2A1A2A1A1A1A][2A1A1A1A][3A1A2A1A1A1A]

Documentation
...   Author:   Heikki Autio
...   Contact:  I_MN_RAN_TRUNK_SG_OUL1@internal.nsn.com

Library     Collections
Library     taf.sw.reporting_portal
Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource    testsuite/Oulu/TrunkEng/OMKPI/Robot/Resources/OMKPI_common.robot
Resource    testsuite/Oulu/TrunkEng/OMKPI/Robot/TestKeywords/omkpi_sw_dl.robot
Variables   testsuite/Oulu/TrunkEng/OMKPI/Robot/Targets/CNF_LTE_4e_omkpi_target.py

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown     Common Test Teardown

*** Variables ***
${WAIT_FOR_CELLS_UP}    700
${REPORT}               ${True}
# to list below you can add prints that will be monitored from syslog, if print is found, it is written to eventlog
@{SYSLOG_LIST}        Detected most recent reset type was   failed to execute
# to list below you can add prints that will fail the test if they are found from syslog
@{UNALLOWED_SYSLOGS}  4 (ERPresetTypeSpuriousReset)    14 (ERPresetTypeSpuriousResetBts)
# Promotion tag that is used to get the promoted build
${PROMOTION_TAG}      REGRESSION
# Release is a branch that is used as an older build to which it is always rolled back before new build is uploaded to bts
${RELEASE}            SBTS24R1
# If set to ${True} makes SWDL by usin LMP connection, if set to ${False} uses S1 ip for SWDL
${LMP_SWDL}           ${True}
# Path to allowed alarms file
${ALLOWED_ALARMS_FILE}  /home/ute/MN/UTE/robotws/testsuite/Oulu/TrunkEng/OMKPI/allowed_alarms_4d.txt
# seconds, 0 if no waiting nor printing before post conditions check
${WAIT_CHECKS}          90
# If True saves SW build to pc before uploading it to BTS. If False uses link to SW build for uploading
# NOTE saves 10min if build is not saved on PC
${SAVE_BUILD_TO_PC}     ${True}
# Collect logs variable. Possible values are: On failure/Never/Always
${COLLECT_LOGS}         On failure
${TEST_LOOPS}           1
${REFERENCE_TESTLINE}   CNF_LTE_4e
${ZIP_LOGS}             ${True}
@{ALLOWED_ALARMS}       4420  4298  6280

*** Test Cases ***
Automated_OAMKPI_SW_Activation_Inter-release
    [Documentation]  Get the name of an older promoted build from WFT and then get T1, T2 and normal build of the tested SW
    ...              from artifactory and download those to BTS one by one, check that everything ok and calculate KPI.
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${SAVE_BUILD_TO_PC}  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}
        ...    ${RELEASE}  ${PROMOTION_TAG}  ${LMP_SWDL}  ${OAM_KPI_TARGETS}  kpi 2a or 2b
        ...    name=OMKPI SW Activation Inter Release
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=OMKPI SW DL
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
        ...    omkpi_case=${True}