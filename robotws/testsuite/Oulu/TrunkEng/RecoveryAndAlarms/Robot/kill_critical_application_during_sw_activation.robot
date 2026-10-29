*** Settings ***
Documentation
...   Author:   Sirpa Passoja
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource    testsuite/Oulu/TrunkEng/RecoveryAndAlarms/Robot/TestKeywords/kill_critical_applications_during_sw_activation.robot
Resource    testsuite/Oulu/TrunkEng/Common/Robot/TestKeywords/flag_manipulation.robot

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown     Common Test Teardown


*** Variables ***
# This will be seen before every application in test run f.ex. Crash of critical application bm
${CASE_NAME}            Crash of critical application during SW activation
# Max time to wait for cells to be up and running, currently mandatory to be given as integer, later also string will be suitable
${WAIT_FOR_CELLS_UP}    ${600}
# Time to wait in seconds after sw rollback has been made
${WAIT_DISABLED_CELLS}    ${120}
# Wait after test and site reset, value can be given as string. Note time for reset cleaner to be cleaned has been 360s.
${WAIT_FOR_RECO_COUNTER_CLEAR}    360
# Time to wait before doing post conditions checks, seconds. Default 300
${WAIT_CHECKS}          ${300}
# Not suitable way for real testing because of reporting. Usable just when trying functionality.
@{APPLICATIONS}         bm  BTSOMexe  DCS  DEM  FRI  HAS  LTS  MCI  MCtrl  SWM  SysAdapter  TAS  BStat
# Suite Variable that's value is changed in Test Cases
${APPLICATION}
# Syslog prints that will be printed to eventlog when found from the syslog, will not fail the test if found/not found
@{SYSLOG_LIST}          ResetCounter  Detected most recent reset type Failed to execute executable  RecoveryConstraints
                        ...    Executing recovery action  RecoveryActionController  Set alarm  Reset count
                        ...    Please contact the owner of
# Expected syslog print that will fail the test if not found during test run
${SYSLOG_PRINT}         ERPresetTypeSpuriousReset
# Path to allowed alarms file
${ALLOWED_ALARMS_FILE}  /home/ute/MN/UTE/robotws/testsuite/Oulu/TrunkEng/RecoveryAndAlarms/allowed_alarms.txt
# Collect logs variable. Possible values are: On failure/Never/Always
${COLLECT_LOGS}         On failure
# How many times test will be run, needs to be more than 0
${TEST_LOOPS}           1
&{FLAG_VALUE}           0x2004c=5
${ADD_FLAG}             ${True}
${TEXT_TO_STEP}         Add flag
# Variable for RFS testing. If RFS is set True, there is takan logs from both sides (4G/5G) and done also other checks to other side also.
${RFS}     ${False}
${MASTER}  This  # This/Other

*** Test Cases ***
Crash SWM Critical Application from RealNode in SMOD
    Sleep  1s
    [Timeout]    24h
    [Documentation]  Kill SWM application from real node during SW activation. Spurious reset is allowed.
    Set Suite Variable  ${APPLICATION}  SWM
#Checks if wrong application has crashed
    Set Suite Variable  ${Unexpected_Syslog}  Please contact owner of '(?!SWM).*
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${FLAG_VALUE}  ${ADD_FLAG}  ${TEXT_TO_STEP}
        ...    name=Add flag to swconfig
        ...    test_case=Pre
        ...    loops=1
        ...    keywords=Change flag to swconfig
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_RECO_COUNTER_CLEAR}  ${APPLICATION}  ${WAIT_CHECKS}
        ...    ${SYSLOG_LIST}  ${SYSLOG_PRINT}  ${WAIT_DISABLED_CELLS}
        ...    name=${CASE_NAME} ${APPLICATION}
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Critical application kill during SW activation
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
