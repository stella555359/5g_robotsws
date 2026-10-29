*** Settings ***
Suite Setup       run keywords    SISO Coam Suite Setup    AND    Get BtsName
Suite Teardown    SISO Coam Suite Teardown
Test Setup        run keywords    SISO Coam Test Setup    AND    CB009275 Set   value=true
Test Teardown     run keywords    Cancel Fault via RF Command   AND    SISO Coam Test Teardown

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    Resources/CB012097_common_keyword.robot

Documentation
...    Author: Yang Di
...    contact: di.yang@nokia-sbell.com
...    squad group: MMW_05
...    Feature CB012097

*** Test Cases ***
CB012097_SR_001_CB009275_Feature_Enable_with_Fault_1932_actived_RU_support_CB012097
    [Tags]      001
    CB009275 Set   value=false
    Trigger fault 1932 on RMOD
    BTS Report Fault on RMOD
    Wait Until keyword Succeeds    5 min    20 sec   Check if fault is active on RU in History log
    ...    EFaultId_NoFansDetected
    RU Should Be Online   ru_index=2
    CB009275 Set   value=true
    Expect Fault Should Absent    faultId=1932
    Wait Until keyword Succeeds    5 min    20 sec   Check if fault is active on RU in History log
    ...    EFaultId_NoFansDetected
    RU Should Be Online   ru_index=2

CB012097_SR_002_CB009275_Feature_Enable_with_Fault_1933_actived_RU_support_CB012097
    [Tags]      002
    CB009275 Set   value=false
    Trigger fault with High Temperature
    BTS Report Fault on RMOD   faultId=1934
    Wait Until keyword Succeeds    5 min    20 sec   Check if fault is active on RU in History log
    ...    EfaultId_FanReducedSetSpeed
    RU Should Be Online   ru_index=2
    Check Fans State
    Trigger fault 1933 after High Temperature
    RU Should Be Online   ru_index=2
    Check Fans State
    CB009275 Set   value=true
    Expect Fault Should Absent    faultId=1933
    Wait Until keyword Succeeds    5 min    20 sec   Check if fault is active on RU in History log
    ...    EfaultId_FrFanBrokenEarlyNotifAl
    RU Should Be Online   ru_index=2
    Check Fans State

CB012097_SR_003_CB009275_Feature_Enable_with_Fault_1934_actived_RU_support_CB012097
    [Tags]      003
    CB009275 Set   value=false
    Trigger fault with High Temperature
    BTS Report Fault on RMOD   faultId=1934
    Wait Until keyword Succeeds    5 min    20 sec   Check if fault is active on RU in History log
    ...    EfaultId_FanReducedSetSpeed
    RU Should Be Online   ru_index=2
    Check Fans State
    CB009275 Set   value=true
    Expect Fault Should Absent    faultId=1934
    Wait Until keyword Succeeds    5 min    20 sec   Check if fault is active on RU in History log
    ...    EfaultId_FanReducedSetSpeed
    RU Should Be Online   ru_index=2
    Check Fans State

CB012097_SR_007_CB009275_Feature_Enable_with_Fault_1933_not_raised_due_temperature_RU_support_CB012097
    [Tags]      007
    CB009275 Set   value=false
    Trigger fault with Low Temperature    faultId=1933
    Wait Until keyword Succeeds    5 min    20 sec   Check if fault is active on RU in History log
    ...    EfaultId_FrFanBrokenEarlyNotifAl
    Expect Fault Should Absent    faultId=1933
    RU Should Be Online   ru_index=2
    Check Fans State
    CB009275 Set   value=true
    Expect Fault Should Absent    faultId=1933
    Wait Until keyword Succeeds    5 min    20 sec   Check if fault is active on RU in History log
    ...    EfaultId_FrFanBrokenEarlyNotifAl
    RU Should Be Online   ru_index=2
    Check Fans State

CB012097_SR_008_CB009275_Feature_Enable_with_Fault_1934_not_raised_due_temperature_RU_support_CB012097
    [Tags]      008
    CB009275 Set   value=false
    Trigger fault with Low Temperature    faultId=1934
    Wait Until keyword Succeeds    5 min    20 sec   Check if fault is active on RU in History log
    ...    EfaultId_FrFanReducedSetSpeedEarlyNotifAl
    Expect Fault Should Absent    faultId=1934
    RU Should Be Online   ru_index=2
    Check Fans State
    CB009275 Set   value=true
    Expect Fault Should Absent    faultId=1934
    Wait Until keyword Succeeds    5 min    20 sec   Check if fault is active on RU in History log
    ...    EfaultId_FrFanReducedSetSpeedEarlyNotifAl
    RU Should Be Online   ru_index=2
    Check Fans State

