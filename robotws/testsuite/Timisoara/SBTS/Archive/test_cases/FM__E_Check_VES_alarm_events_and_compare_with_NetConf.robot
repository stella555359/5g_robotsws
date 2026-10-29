*** Settings ***
Resource    ../test_resources/FM__E_Check_VES_alarm_events_and_compare_with_NetConf.robot

*** Test Cases ***
FM__E_Check_VES_alarm_events_and_compare_with_NetConf
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__FM__E_Check_VES_alarm_events_and_compare_with_NetConf
