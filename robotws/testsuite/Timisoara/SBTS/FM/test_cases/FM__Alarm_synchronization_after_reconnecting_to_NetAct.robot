*** Settings ***
Documentation  This suite contains FM__Alarm_synchronization_after_reconnecting_to_NetAct TC

Resource  ../test_resources/FM__Alarm_synchronization_after_reconnecting_to_NetAct.robot


*** Test Cases ***
FM__Alarm_synchronization_after_reconnecting_to_NetAct
    [Setup]  TC Setup
    TC__FM__Alarm_synchronization_after_reconnecting_to_NetAct
    [Teardown]  TC Teardown
