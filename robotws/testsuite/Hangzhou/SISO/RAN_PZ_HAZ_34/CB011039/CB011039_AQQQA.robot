*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           Run keywords    SISO Coam Test Setup    AND    AlarmWatchdog.add_allow_alarms    fault_id=2934
Test Teardown        Run keywords    Deactivate Fail Safe Mode on RU     AND    AlarmWatchdog.remove_allow_alarms
...    fault_id=2934     AND     SISO Coam Test Teardown

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ./Resources/CB011039_AQQQA_keywords.robot

Documentation
...    Author: Yang Di
...    Contact: di.yang@nokia-sbell.com
...    squad group: VRF_HAZ3_5
...    Feature CB011039 Fail safe boot for RU

*** Variables ***

*** Test Cases ***
CB011039_5G_C_1_Radio_Module_fail_safe_mode_fault_activation
    [Tags]      C_1
    CB011039 Change Fail Safe Mode Value    enable
    Perform RU Lock
    RU Should Be Locked
    Perform RU Reset
    Wait Until Keyword Succeeds    15min    30s    RU Should Be Locked In Fail Safe Mode
    Cells Should Be Disabled In Fail Safe Mode
    Get Fail Safe Mode Value
    Wait For Expect Fault Present    faultId=2934    timeout=6min
#    Expect Fault Should Absent    faultId=1850
    wait until keyword succeeds    180    20    Check if fault is active on RU in History log
    ...    EFaultId_FailSafeMode

CB011039_5G_C_3_Radio_Module_snapshot_collection_during_fail_safe_mode
    [Tags]      C_3
    Activate Fail Safe Mode on RU
    Get Fail Safe Mode Value
    Wait For Expect Fault Present    faultId=2934    timeout=6min
    General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot    is_get_snapshot_via_selenium=${True}
    wait until keyword succeeds    180    20    Check if fault is active on RU in History log
    ...    EFaultId_FailSafeMode

CB011039_5G_C_4_Radio_Module_remote_reset_during_fail_safe_mode
    [Tags]      C_4
    Activate Fail Safe Mode on RU
    Get Fail Safe Mode Value
    Wait For Expect Fault Present    faultId=2934    timeout=6min
    wait until keyword succeeds    180    20    Check if fault is active on RU in History log
    ...    EFaultId_FailSafeMode
    CB011039 Change Fail Safe Mode Value    disable
    Perform RU Reset
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
    Wait For Expect Fault To Disappear    faultId=2934    timeout=4min

CB011039_5G_C_8_Entering_Radio_Module_fail_safe_mode_via_Testability_interface
    [Tags]      C_8
    [Teardown]   Run Keywords  run keyword if test failed    Restore The Suspending Service   AND
    ...  SISO Coam Test Teardown
    AlarmWatchdog.add_allow_alarms    fault_id=${FAULT_ID_SUSPEND_SERVICE}
    Suspend Selected RFSW Service Via Testability Interface
    Get Fail Safe Mode Value
    Lock Ru and check Status
    wait until keyword succeeds    180    20    Check if fault is active on RU in History log
    ...    EFaultId_FailSafeMode
    wait until keyword succeeds    2x   60s    Restore The Suspending Service

CB011039_5G_C_7_Radio_Module_Testability_interface_usage_during_fail_safe_mode
    [Tags]      C_7
    [Teardown]   Run Keywords  run keyword if test failed    Restore The Suspending Service   AND
    ...   SISO Coam Test Teardown
    AlarmWatchdog.add_allow_alarms    fault_id=${FAULT_ID_SUSPEND_SERVICE}
    Suspend Selected RFSW Service Via Testability Interface
    General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot    is_get_snapshot_via_selenium=${True}
    Get Fail Safe Mode Value
    wait until keyword succeeds    180    20    Check if fault is active on RU in History log
    ...    EFaultId_FailSafeMode
    wait until keyword succeeds    2x   60s    Restore The Suspending Service

CB011039_5G_H_1_Radio_Module_Online_Diagnostics_tests
    [Tags]      H_1
    [Teardown]   Run Keywords   Deactivate Fail Safe Mode on RU     AND    Run Keyword And Ignore Error
    ...    Selenium Logout And Close Browser     AND     SISO Coam Test Teardown
    Activate Fail Safe Mode on RU
    AlarmWatchdog.add_allow_alarms    fault_id=4681
    Get Fail Safe Mode Value
    Wait For Expect Fault Present    faultId=2934    timeout=6min
    wait until keyword succeeds    180    20    Check if fault is active on RU in History log
    ...    EFaultId_FailSafeMode
    Trigger AQQQA 4681 and Wait Check Points NOK
    Check Diagnostic Report in Snapshot
    Restore AQQQA 4681 Alarm
    selenium_sbts.start_diagnostic_check    scope=Full diagnostic check


