*** Settings ***
Documentation
...   Author:   Essi Passoja
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource    testsuite/Oulu/TrunkEng/RecoveryAndAlarms/Robot/TestKeywords/SoC_crash_during_SW_activation.robot

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown     Common Test Teardown

*** Variables ***
${WAIT_FOR_CELLS_UP}    300
# to list below you can add prints that will be monitored from syslog, if print is found, it is written to eventlog
@{SYSLOG_LIST}          Detected most recent reset type was  failed to execute  FirmwareActivationColdReset
...                     BW.bin updated  status = 70426 UPDATED
# to list below you can add prints that will fail the test if they are found from syslog
@{UNALLOWED_SYSLOGS}    4 (ERPresetTypeSpuriousReset)  14 (ERPresetTypeSpuriousResetBts)
# Path to allowed alarms file
${ALLOWED_ALARMS_FILE}  testsuite/Oulu/TrunkEng/RecoveryAndAlarms/allowed_alarms.txt
# seconds, 0 if no waiting nor printing before post conditions check
${WAIT_CHECKS}          0
# Collect logs variable. Possible values are: On failure/Never/Always
${COLLECT_LOGS}         On failure
# How many times test will be run, needs to be more than 0
${TEST_LOOPS}           1
# Unit, can be ABIA, ABIN, ABIO, ABIP, ABIQ
${UNIT}                 ABIN1
# SoC - if empty, chooses first secondary SoC
${SOC}                  ${EMPTY}
# Starting step
${STEP}                 1


*** Test Cases ***
Secondary SoC Crash During SW Intra Activation
    [Documentation]  Get the name of active SW or triggering SW and get T1, T2 and normal build of the tested SW
    ...              from artifactory and download those to BTS one by one. Crash application from secondary SoC
    ...              during SW activation, then check that everything is OK.
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${UNIT}  ${SOC}  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${STEP}
        ...    name=Secondary SoC Crash After SW Intra Activation
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Crash Secondary SoC During SW Activation
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
