*** Settings ***
Documentation  This suite contains FM__Update_alarm_fault_ID_online_suppressed_allowed_list TC

Resource  ../test_resources/FM__Update_alarm_fault_ID_online_suppressed_allowed_list.robot


*** Test Cases ***
FM__Update_alarm_fault_ID_online_suppressed_allowed_list
    [Setup]  TC Setup
    TC__FM__Update_alarm_fault_ID_online_suppressed_allowed_list
    [Teardown]  TC Teardown
