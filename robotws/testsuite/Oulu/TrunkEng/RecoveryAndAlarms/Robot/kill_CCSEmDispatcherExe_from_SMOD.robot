*** Settings ***
Force Tags  RF50

Documentation
...   Author:   Mirka Kyllönen
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Resource         testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource         testsuite/Oulu/TrunkEng/RecoveryAndAlarms/Robot/TestKeywords/SMOD_SoC_crash.robot
Resource         testsuite/Oulu/TrunkEng/Common/Robot/TestKeywords/change_commissioning_parameters.robot

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown     Common Test Teardown

*** Variables ***
# Commissioning change for CCSEmDispatcherExe -test
&{COMMISSIONING_PARAMETERS}   actForceAutoReset=false
                        ...   actForceUnitAutoReset=false
# seconds, 0 if no waiting nor printing before post conditions check, used only after commission change
${WAIT_CHECKS}          480
# to list below you can add prints that will be monitored from syslog, if print is found, it is written to eventlog
@{SYSLOG_LIST}          Detected most recent reset type was  failed to execute  FirmwareActivationColdReset
...                     BW.bin updated  status = 70426 UPDATED
# to list below you can add prints that will fail the test if they are found from syslog
@{UNALLOWED_SYSLOGS}    14 (ERPresetTypeSpuriousResetBts)
# Path to allowed alarms file
${ALLOWED_ALARMS_FILE}  testsuite/Oulu/TrunkEng/RecoveryAndAlarms/allowed_alarms.txt
# Waits (in seconds) after fault is generated
${WAIT_FOR_DISCONNECT}  300
${WAIT_FOR_RECONNECT}   120
${WAIT_FOR_CELLS_UP}    360
${WAIT_FOR_ALARM}       600
# Collect logs variable. Possible values are: On failure/Never/Always
${COLLECT_LOGS}         On failure
# How many times test will be run, needs to be more than 0
${TEST_LOOPS}           1
# SMOD name, can be ASOE, ASOH, ASOG. SMOD1 chooses the first (or only) found SMOD.
${SMOD}                 SMOD1
# Starting step
${STEP}                 1

*** Test Cases ***
SMOD Thor CCSEmDispatcherExe Interface SOC Crash
    [Documentation]  Crash the interface SoC from SMOD (ASOE, ASOH, ASOG) by killing CCSEmDispatcherExe.
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${COMMISSIONING_PARAMETERS}
        ...    name=Create delta file re-commissioning
        ...    test_case=Pre
        ...    loops=1
        ...    keywords=Do commissioning with delta file
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${STEP}  ${SMOD}  CCSEmDispatcherExe  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_ALARM}  ${False}  ${False}
        ...    name=Crash interface SoC from SMOD by killing CCSEmDispatcherExe
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Crash interface SoC from SMOD
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

SMOD Thor CCSEmDispatcherExe Interface SOC Crash All Containers
    [Documentation]  Crash the interface SoC from SMOD (ASOE, ASOH, ASOG) by killing CCSEmDispatcherExe.
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${COMMISSIONING_PARAMETERS}
        ...    name=Create delta file re-commissioning
        ...    test_case=Pre
        ...    loops=1
        ...    keywords=Do commissioning with delta file
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${STEP}  ${SMOD}  CCSEmDispatcherExe  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_ALARM}  ${True}  ${False}
        ...    name=Crash interface SoC from SMOD by killing CCSEmDispatcherExe All Containers
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Crash interface SoC from SMOD
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

SMOD Thor CCSEmDispatcherExe Interface SOC Crash All Containers Looped
    [Documentation]  Crash the interface SoC from SMOD (ASOE, ASOH, ASOG) by killing CCSEmDispatcherExe.
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${COMMISSIONING_PARAMETERS}
        ...    name=Create delta file re-commissioning
        ...    test_case=Pre
        ...    loops=1
        ...    keywords=Do commissioning with delta file
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${SMOD}  CCSEmDispatcherExe  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_ALARM}  ${True}  ${True}
        ...    name=Crash interface SoC from SMOD by killing CCSEmDispatcherExe All Containers
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Crash interface SOC from SMOD looped
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

Simple SMOD Thor CCSEmDispatcherExe Interface SOC Crash All Containers Looped
     [Documentation]  Crash the interface SoC from SMOD (ASOE, ASOH, ASOG) by killing CCSEmDispatcherExe.
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${COMMISSIONING_PARAMETERS}
        ...    name=Create delta file re-commissioning
        ...    test_case=Pre
        ...    loops=1
        ...    keywords=Do commissioning with delta file
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${STEP}  ${SMOD}  CCSEmDispatcherExe
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_ALARM}  ${True}  ${True}
        ...    name=Crash interface SoC from SMOD by killing CCSEmDispatcherExe All Containers
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Simple Crash interface SOC from SMOD looped
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
