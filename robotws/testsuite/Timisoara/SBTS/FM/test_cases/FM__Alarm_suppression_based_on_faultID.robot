*** Settings ***
Documentation  This suite contains FM__Alarm_suppression_based_on_faultID TC

Resource  ../test_resources/FM__Alarm_suppression_based_on_faultID.robot


*** Test Cases ***
FM__Alarm_suppression_based_on_faultID
    [Setup]  TC Setup
    TC__FM__Alarm_suppression_based_on_faultID
    [Teardown]  TC Teardown
