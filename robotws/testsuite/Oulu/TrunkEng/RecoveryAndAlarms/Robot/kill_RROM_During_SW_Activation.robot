*** Settings ***
Documentation
...   Author:   Sirpa Passoja
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource    testsuite/Oulu/TrunkEng/RecoveryAndAlarms/Robot/TestKeywords/SMOD_Crash_During_SW_Activation.robot

Library     testsuite.Oulu.TrunkEng.Common.Python.Interfaces.pass_rate
Library     testsuite.Oulu.TrunkEng.Common.Python.Interfaces.FspIP  WITH NAME  FSP
Library     testsuite.Oulu.TrunkEng.Common.Python.Interfaces.SSHConnection  WITH NAME  SSH
Library     testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Applications

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown     Common Test Teardown


*** Variables ***
# Max time to wait for cells to be up and running, currently mandatory to be given as integer, later also string will be suitable
${WAIT_FOR_CELLS_UP}    ${600}
# Wait after test and site reset, value can be given as string.
${WAIT_FOR_RECO_COUNTER_CLEAR}    360
# Time for wait after SWDL
${WAIT_AFTER_SWDL}      300  #seconds
# Time to wait in seconds after sw rollback has been made
${WAIT_DISABLED_CELLS}    ${120}
# Not suitable way for real testing because of reporting. Usable just when trying functionality.
@{APPLICATIONS}         ENBC  FaultServiceExe  MCEC  RROM  TUPC
# Suite Variable that's value is changed in Test Cases
${APPLICATION}
# Syslog prints that will be printed to eventlog when found from the syslog, will not fail the test if found/not found
@{SYSLOG_LIST}          ResetCounter  Detected most recent reset type Failed to execute executable  RecoveryConstraints
                        ...    Executing recovery action  RecoveryActionController  Set alarm  Reset count
                        ...    Please contact the owner of
# Expected syslog print that will fail the test if not found during test run site autonomous reset
${SYSLOG_PRINT}             ERPresetTypeApplication
@{UNALLOWED_SYSLOGS}        4 (ERPresetTypeSpuriousReset)    14 (ERPresetTypeSpuriousResetBts)
# Expected alarms:
${FAULT_NAME_SITE_RESET}    BTS site autonomous reset as recovery action
${ALARM_NBR_SITE_RESET}     ${7101}
${FAULT_NBR_SITE_RESET}     ${4383}
# Path to allowed alarms file
${ALLOWED_ALARMS_FILE}  /home/ute/MN/UTE/robotws/testsuite/Oulu/TrunkEng/RecoveryAndAlarms/allowed_alarms.txt
# Collect logs variable. Possible values are: On failure/Never/Always
${COLLECT_LOGS}         On failure
# How many times test will be run, needs to be more than 0
${TEST_LOOPS}    1
# Variable for RFS testing. If RFS is set True, there is takan logs from both sides (4G/5G) and done also other checks to other side also.
${RFS}     ${False}
${MASTER}  This  # This/Other

*** Test Cases ***
Crash RROM from CentralCPlane in SMOD during SW activation
    Sleep  1s
    [Timeout]    24h
    [Documentation]  Kill RROM application during SW activation. Autonomous reset with faultID/alarm are expected.
    Set Suite Variable   ${APPLICATION}   RROM
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...  ${WAIT_FOR_CELLS_UP}  ${APPLICATION}  ${WAIT_AFTER_SWDL}  ${WAIT_DISABLED_CELLS}  ${SYSLOG_LIST}
        ...  ${SYSLOG_PRINT}  ${UNALLOWED_SYSLOGS}  ${FAULT_NAME_SITE_RESET}  ${ALARM_NBR_SITE_RESET}
        ...  ${FAULT_NBR_SITE_RESET}
        ...  name=Kill RROM Application During SW Activation
        ...  test_case=1
        ...  loops=${TEST_LOOPS}
        ...  keywords=Crash Application From SMOD During SW Activation
        ...  expected_pass_rate=1
        ...  collect_test_logs=${COLLECT_LOGS}
