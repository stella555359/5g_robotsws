*** Settings ***
Documentation  This suite contains WebEM__Disable_suppression_of_minor_warning_alarms TC

Resource  ../test_resources/WebEM__Disable_suppression_of_minor_warning_alarms.robot


*** Test Cases ***
WebEM__Disable_suppression_of_minor_warning_alarms
    [Setup]  TC Setup
    TC__WebEM__Disable_suppression_of_minor_warning_alarms
    [Teardown]  TC Teardown
