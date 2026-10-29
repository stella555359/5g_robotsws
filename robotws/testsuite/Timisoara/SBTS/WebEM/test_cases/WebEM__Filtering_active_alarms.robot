*** Settings ***
Documentation  This suite contains WebEM__Filtering_active_alarms TC

Resource  ../test_resources/WebEM__Filtering_active_alarms.robot


*** Test Cases ***
WebEM__Filtering_active_alarms
    [Setup]  TC Setup
    TC__WebEM__Filtering_active_alarms
    [Teardown]  TC Teardown
