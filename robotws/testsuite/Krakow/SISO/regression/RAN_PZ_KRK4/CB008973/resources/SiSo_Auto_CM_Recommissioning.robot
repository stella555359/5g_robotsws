*** Settings ***

Resource    taf/rfrl/bts/robot/gnb.robot
Resource    taf/rfrl/bts/robot/common/gnb_alarm.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Library     taf/rfrl/bts/devices/du/commissioning.py


*** Keywords ***
Parameter modification with autonomus BTS restart
    [Arguments]    ${dist_name}    ${parameter}    ${value}
    gnb_alarm.Allow Alarm  alarm=BTS Reset Cause
    Verify if Parameter Changed to Correct Value via GUI    dist_name=${dist_name}    parameter=${parameter}
    ...    value=${value}
    Wait Until Keyword Succeeds     900 sec     15 sec   Verify gNB is onAir
    Verify Default Allowed Alarms on gNB
    verify_validation_error_not_active

Parameter online modification
    [Arguments]    ${dist_name}    ${incorrect_value}    ${correct_value}    ${parameter}
    Verify if Parameter Changed to Correct Value via GUI    dist_name=${dist_name}    parameter=${parameter}
    ...    value=${correct_value}
    Verify gNB is onAir
    Verify Default Allowed Alarms on gNB
    verify_validation_error_not_active
    Verify if Parameter Changed to Incorrect Value via GUI    dist_name=${dist_name}   parameter=${parameter}
    ...    value=${incorrect_value}
