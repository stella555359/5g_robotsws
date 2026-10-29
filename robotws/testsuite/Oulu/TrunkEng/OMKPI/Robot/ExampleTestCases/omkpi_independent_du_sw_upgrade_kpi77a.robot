*** Settings ***
Documentation
...   Author:   Terhi Talvitie
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Library     Collections
Library     taf.sw.reporting_portal
Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource    testsuite/Oulu/TrunkEng/OMKPI/Robot/Resources/OMKPI_common.robot
Resource    testsuite/Oulu/TrunkEng/OMKPI/Robot/TestKeywords/omkpi_rf_sw_update.robot
Resource    testsuite/Oulu/TrunkEng/OMKPI/Robot/TestKeywords/omkpi_independent_du_sw_upgrade.robot
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
# Promotion tag that is used to get the promoted build
${PROMOTION_TAG}      REGRESSION
# Release is a branch that is used in inter tests for an older build to which it is always rolled back before new build is uploaded to bts
# If you want to run Intra test, select same release that is active in BTS
${RELEASE}            SBTS00
# If set to ${True} makes SWDL by usin LMP connection, if set to ${False} uses S1 ip for SWDL
${LMP_SWDL}           ${False}
# Path to allowed alarms file
${ALLOWED_ALARMS_FILE}  /home/ute/MN/UTE/robotws/testsuite/Oulu/TrunkEng/OMKPI/allowed_alarms.txt
# seconds, 0 if no waiting nor printing before post conditions check
${WAIT_CHECKS}          0
# If True saves SW build to pc before uploading it to BTS. If False uses link to SW build for uploading
# NOTE saves 10min if build is not saved on PC
${SAVE_BUILD_TO_PC}     ${True}
# Collect logs variable. Possible values are: On failure/Never/Always
${COLLECT_LOGS}         On failure
${TEST_LOOPS}           1
${REFERENCE_TESTLINE}   ${EMPTY}
${RU_SWDL}              ${True}
# This variable can have value:
# "Independent Manual DU SW Activation" then selected KPI is parsed in test (inter/intra, is firmware updated/not updated).
# User can also give hard coded KPI, some of these:
#   "Manual DU Inter-release SW activation downtime without firmware update downtime"
#   "Manual DU Inter-release SW activation downtime with firmware update downtime"
#   "Manual DU Intra-release SW activation downtime without firmware update downtime"
#   "Manual DU Intra-release SW activation downtime with firmware update downtime"
${TESTED_KPI}           UE perceived outage during upgrade for CPRI radio module
@{ALLOWED_ALARMS}       1898  4773  6327
${RFS}                  ${True}
${MASTER}               This

*** Test Cases ***
OMKPI Independent Du Sw Upgrade KPI77a
    [Documentation]  This KPI measures service outages on cells served by the radio module during the switching of synchronization
    ...              sources - from an upgraded BTS (following a reset) to a non-upgraded BTS. OM_GEN_SFS_OM_PERF_CAP.
    ...              11421824BTS OAM Radio Management. NOTE This test requires RFS environment.
    ...              Get T1, T2 and normal build from artifactory. First do RU upgrade then DU upgrade. Do this to T1,
    ...              T2 and normal builds one by one, check that everything ok. NOTE This test case requires that
    ...              the test environment is RFS.
    IF  '${RFS}' != '${True}'
        Fatal Error  This test case requires RFS environment. RFS variable is set to '${RFS}'.
    END
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${SAVE_BUILD_TO_PC}  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}
        ...    ${RELEASE}  ${PROMOTION_TAG}  ${LMP_SWDL}  ${OAM_KPI_TARGETS}  ${TESTED_KPI}
        ...    name=OMKPI Independent Du Sw Upgrade KPI77a
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=OMKPI Independent DU SW Upgrade
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
        ...    omkpi_case=${True}
