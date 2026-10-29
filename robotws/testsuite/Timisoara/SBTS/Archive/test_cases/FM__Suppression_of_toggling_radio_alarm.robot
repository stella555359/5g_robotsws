*** Settings ***
Resource    ../test_resources/FM__Suppression_of_toggling_radio_alarm.robot

*** Test Cases ***
FM__Suppression_of_toggling_radio_alarm
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__FM__Suppression_of_toggling_radio_alarm
