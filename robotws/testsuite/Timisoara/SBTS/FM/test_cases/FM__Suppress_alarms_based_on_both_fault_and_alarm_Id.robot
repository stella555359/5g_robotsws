*** Settings ***
Documentation  This suite contains FM__Suppress_alarms_based_on_both_fault_and_alarm_Id TC

Resource  ../test_resources/FM__Suppress_alarms_based_on_both_fault_and_alarm_Id.robot


*** Test Cases ***
FM__Suppress_alarms_based_on_both_fault_and_alarm_Id
    [Setup]  TC Setup
    TC_FM__Suppress_alarms_based_on_both_fault_and_alarm_Id
    [Teardown]  TC Teardown