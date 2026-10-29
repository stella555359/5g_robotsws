*** Settings ***
Documentation
...    Author: Yang Di
...    Contact: di.yang@nokia-sbell.com
...    Group: VRF_HAZ3_T05
...    Feature: CB012097

Resource    testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Cloud/CB012097/keywords_cloud.robot
Variables   ./CasePara_12097.py

Suite Setup         Cloud Suite Setup
Test Setup          run keywords    Modify actRadioFanFailureEarlyNotif   value=true    AND
                    ...    Modify optionalFansInstalled   value=false
Suite Teardown      robot_common_operations.Common Suite Teardown

*** Variables ***
${if_commissioning}                 False

*** Test Cases ***
CB012097_SR_022_BD#B2_Optional_fan_ detection_failure_with_ feature_enabled_ALT1
    log to console    B2_Optional_fan_ detection_failure_with_ feature_enabled_ALT1
    Modify Nrpm_fail
    Wait Until Keyword Succeeds   5min   20s   vdu_fm.Checking No unexpected Active Alarms Raised
    ...    user_unexpected_alarms=1933
    Modify optionalFansInstalled   value=true
    BTS Report Fault on FAN
    Verify All RU Status Should Be Normal on vDU
    Check Fans State

