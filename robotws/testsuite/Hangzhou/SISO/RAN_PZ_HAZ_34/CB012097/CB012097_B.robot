*** Settings ***
Suite Setup       run keywords    SISO Coam Suite Setup    AND    Get BtsName    AND    Get SW version
                  ...    AND    AlarmWatchdog.add_allow_alarms    fault_id=1933
Suite Teardown    SISO Coam Suite Teardown
Test Setup        run keywords    SISO Coam Test Setup    AND    CB009275 Set   value=true    AND
                  ...    Modify optionalFansInstalled   value=true
Test Teardown     run keywords    Modify optionalFansInstalled   value=false    AND
                  ...    Wait For Expect Fault To Disappear    faultId=1933    timeout=5min    AND
                  ...    SISO Coam Test Teardown

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    Resources/CB012097_common_keyword.robot
Library     String

Documentation
...    Author: Yang Di
...    contact: di.yang@nokia-sbell.com
...    squad group: MMW_05
...    Feature CB012097

*** Test Cases ***
CB012097_SR_022_BD#B2_Optional_fan_ detection_failure_with_ feature_enabled_ALT1
    [Tags]      022
    Modify Nrpm_fail
    Modify optionalFansInstalled   value=false
    Wait For Expect Fault To Disappear    faultId=1933    timeout=5min
    Modify optionalFansInstalled   value=true
    Sleep   35s
    Run Keyword If    '${release}'=='SBTS25R3'    BTS Report Fault on FAN    faultId=1933
    ...  ELSE  Run Keywords    Expect Fault Should Absent    faultId=1933     AND
    ...  Wait Until keyword Succeeds    5 min    20 sec   Check if fault is active on RU in History log
    ...  EfaultId_FrFanBroken
    RU Should Be Online   ru_index=2
    Run Keyword If    '${release}'=='SBTS25R3'    Check Fans State
    ...  availabilityStatus=failed  operationalState=disabled
    ...  ELSE  Check Fans State  availabilityStatus=not installed  operationalState=disabled

CB012097_SR_023_BD#B2_Optional_fan_ detection_failure_with_ feature_enabled_ALT2
    [Tags]      023
    Modify Nrpm_fail
    Modify optionalFansInstalled   value=false
    CB009275 Set   value=false
    Wait For Expect Fault To Disappear    faultId=1933    timeout=5min
    Modify optionalFansInstalled   value=true
    BTS Report Fault on RMOD   faultId=1933
    RU Should Be Online   ru_index=2
    Run Keyword If    '${release}'=='SBTS25R3'    Check Fans State
    ...  availabilityStatus=failed  operationalState=disabled
    ...  ELSE  Check Fans State  availabilityStatus=not installed  operationalState=disabled

CB012097_SR_024_BD#B3_Optional_fan_ detection_failure_enabling_ Early_notification_of_radio_ fan_failures
    [Tags]      024
    CB009275 Set   value=false
    Modify Nrpm_fail
    BTS Report Fault on RMOD   faultId=1933
    CB009275 Set   value=true
    Run Keyword If    '${release}'=='SBTS25R3'    BTS Report Fault on FAN    faultId=1933
    ...  ELSE  Run Keywords    Expect Fault Should Absent    faultId=1933     AND
    ...  Wait Until keyword Succeeds    5 min    20 sec   Check if fault is active on RU in History log
    ...  EfaultId_FrFanBroken
    RU Should Be Online   ru_index=2
    Run Keyword If    '${release}'=='SBTS25R3'    Check Fans State
    ...  availabilityStatus=failed  operationalState=disabled
    ...  ELSE  Check Fans State  availabilityStatus=not installed  operationalState=disabled

CB012097_SR_025_BD#B4_Optional_fan_ detection_failure_disabling_ Early_notification_of_radio_ fan_failures
    [Tags]      025
    Modify Nrpm_fail
    BTS Report Fault on FAN   faultId=1933
    CB009275 Set   value=false
    BTS Report Fault on RMOD   faultId=1933
    RU Should Be Online   ru_index=2
    Run Keyword If    '${release}'=='SBTS25R3'    Check Fans State
    ...  availabilityStatus=failed  operationalState=disabled
    ...  ELSE  Check Fans State  availabilityStatus=not installed  operationalState=disabled

CB012097_SR_026_BD#B5_Optional_fan_ detection_failure_and_feature_disabling_ALT1
    [Tags]      026
    Modify Nrpm_fail
    BTS Report Fault on FAN   faultId=1933
    Modify optionalFansInstalled   value=false
    Wait For Expect Fault To Disappear    faultId=1933    timeout=5min
    RU Should Be Online   ru_index=2
    Check Fans State  availabilityStatus=not installed  operationalState=disabled
    Modify optionalFansInstalled   value=true
    Run Keyword If    '${release}'=='SBTS25R3'   BTS Report Fault on FAN    faultId=1933
    ...  ELSE  Run Keywords    Expect Fault Should Absent    faultId=1933     AND
    ...  Wait Until keyword Succeeds    5 min    20 sec   Check if fault is active on RU in History log
    ...  EfaultId_FrFanBroken

