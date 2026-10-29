*** Settings ***
Documentation  This suite contains WebEM__Filtering_active_historical_BTS_alarm_list TC

Resource  ../test_resources/WebEM__Filtering_active_historical_BTS_alarm_list.robot


*** Test Cases ***
WebEM__Filtering_active_historical_BTS_alarm_list
    [Setup]  TC Setup
    TC__WebEM__Filtering_active_historical_BTS_alarm_list
    [Teardown]  TC Teardown
