*** Settings ***
Documentation  This suite contains FM__Suppression_of_toggling_external_alarm TC

Resource  ../test_resources/FM__Suppression_of_toggling_external_alarm.robot


*** Test Cases ***
FM__Suppression_of_toggling_external_alarm
    [Setup]  TC Setup
    TC__FM__Suppression_of_toggling_external_alarm
    [Teardown]  TC Teardown
