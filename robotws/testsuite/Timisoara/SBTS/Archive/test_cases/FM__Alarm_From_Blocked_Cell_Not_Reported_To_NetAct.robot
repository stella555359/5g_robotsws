*** Settings ***
Resource    ../test_resources/FM__Alarm_From_Blocked_Cell_Not_Reported_To_NetAct.robot

*** Test Cases ***
FM__Alarm_From_Blocked_Cell_Not_Reported_To_NetAct
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__FM__Alarm_From_Blocked_Cell_Not_Reported_To_NetAct
