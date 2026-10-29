*** Settings ***
Documentation  This suite contains FM__Blackbox_Alarm_Suppression TC

Resource  ../test_resources/FM__Blackbox_Alarm_Suppression.robot


*** Test Cases ***
FM__Blackbox_Alarm_Suppression
    [Setup]  TC Setup
    TC__FM__Blackbox_Alarm_Suppression
    [Teardown]  TC Teardown
