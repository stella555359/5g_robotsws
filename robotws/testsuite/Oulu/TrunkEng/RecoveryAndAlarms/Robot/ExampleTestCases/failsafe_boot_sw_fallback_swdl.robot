*** Settings ***
Documentation
...  Author:   Terhi Talvitie
...  Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Library      taf.fdsw.rc  WITH NAME  RC

Resource     testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource    testsuite/Oulu/TrunkEng/RecoveryAndAlarms/Robot/TestKeywords/failsafe_boot_ute.robot

Library      testsuite.Oulu.TrunkEng.RecoveryAndAlarms.Python.Interfaces.FDSW  WITH NAME  FDSW
Library      testsuite.Oulu.TrunkEng.RecoveryAndAlarms.Python.Interfaces.RescueConsole

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown     Common Test Teardown

*** Variables ***
# time to wait for RC connection, FDSW22B1 -> logs are collected on SSD befor rese -> wait time increased from 3min -> 10min
${WAIT_RC_CONNECTION}       10 min
${WAIT}                     300
&{EXPECTED_ALARM}           fault_id=${4082}  text=SW fallback due to max number of recovery resets   number=${7651}
&{ALLOWED_RC_ALARM}         fault_id=${61648}  text=LMP connectivity detected   number=${7665}
${ALLOWED_ALARMS_FILE}      /home/ute/MN/UTE/robotws/testsuite/Oulu/TrunkEng/RecoveryAndAlarms/allowed_alarms.txt
# Syslog prints that will be printed to eventlog when found from the syslog, will not fail the test if found/not found
@{SYSLOG_LIST}              ResetCounter  Detected most recent reset type  Failed to execute executable  RecoveryConstraints
                            ...    Executing recovery action  RecoveryActionController
# Collect logs variable. POssible values are: On failure/Never/Always
${COLLECT_LOGS}             On failure
# How many times test will be run, needs to be more than 0
${TEST_LOOPS}               1
${RELEASE_PASSIVE_BANK}     SBTS23R4

*** Test Cases ***
Sw Fallback With Extra SWDL
    [Documentation]   Corrupt software from fs1 and fs2 and reboot, check that correct alarm 4082 'SW fallback due to
    ...    max number of recovery resets' is reported, collect logs from Rescue Console, upload and activate new SW and
    ...    perform commissioning with scf file.
    [Tags]    "Sw Fallback" -test loops: ${TEST_LOOPS}
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT}   ${EXPECTED_ALARM}   ${SYSLOG_LIST}    ${WAIT_RC_CONNECTION}    ${ALLOWED_RC_ALARM}
        ...    ${RELEASE_PASSIVE_BANK}
        ...    name=Sw Fallback With Swdl
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
		...    keywords=Sw Fallback With Swdl
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
