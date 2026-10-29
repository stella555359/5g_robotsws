*** Settings ***
Documentation  This suite contains FM__Alarm_suppression_by_mocDN_all_severity TC

Resource  ../test_resources/FM__Alarm_suppression_by_mocDN_all_severity.robot


*** Test Cases ***
FM__Alarm_suppression_by_mocDN_all_severity
    [Setup]  TC Setup
    TC__FM__Alarm_suppression_by_mocDN_all_severity
    [Teardown]  TC Teardown
