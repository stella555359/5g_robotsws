*** Settings ***

Documentation
...   Author:   Sirpa Passoja
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource    testsuite/Oulu/TrunkEng/OMKPI/Robot/Resources/OMKPI_common.robot
Resource    testsuite/Oulu/TrunkEng/RecoveryAndAlarms/Robot/TestKeywords/SOC_crash_during_rf_swdl.robot

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown     Common Test Teardown

*** Variables ***
${WAIT_FOR_CELLS_UP}    800
${WAIT_DISABLED_CELLS}    ${120}
# to list below you can add prints that will be monitored from syslog, if print is found, it is written to eventlog
@{SYSLOG_LIST}          Detected most recent reset type was   failed to execute   FirmwareActivationColdReset   BW.bin updated
...                     status = 70426 UPDATED
# to list below you can add prints that will fail the test if they are found from syslog
@{UNALLOWED_SYSLOGS}    14 (ERPresetTypeSpuriousResetBts)
# Path to allowed alarms file
${ALLOWED_ALARMS_FILE}  /home/ute/MN/UTE/robotws/testsuite/Oulu/TrunkEng/RecoveryAndAlarms/allowed_alarms.txt
# seconds, 0 if no waiting nor printing before post conditions check
${WAIT_CHECKS}          90
# SoC - if empty, chooses first secondary SoC
${SOC}                    ${EMPTY}
# Collect logs variable. Possible values are: On failure/Never/Always
${COLLECT_LOGS}         On failure
${TEST_LOOPS}           1
${RFS}                  ${False}
${MASTER}               This  #This/Other
${ZIP_LOGS}             ${True}
@{ALLOWED_ALARMS}       4420  6327  4220  4773  1815  4773  1898  7107  4452

*** Test Cases ***
Crash Application in Primary SoCs from all BBMODs During RF SWDL
    [Documentation]  Get the RF SW to be downloaded from the SBTS SW builds. Crash Primary SoC from BBMODs furing RF SWDL.
    ...              First do SWDL of T1 to radios, then do SWDL of T2 to radios and finally do SWDL of normal build to radios.
    ...              Procedure introduced in 24R3-SR with CB010779.
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}
        ...    name=Crash Primary SoC from all BBMODs During RF SWDL
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=BBMOD Crash During RF SWDL
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
