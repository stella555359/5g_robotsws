*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/RRM__RFS__2UEs_Simultaneous_Data_Voice_Call_Taf_Ue.robot

*** Test Cases ***
[1]RRM__RFS__2UEs_Simultaneous_Data_Voice_Call_Taf_Ue
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__RRM__RFS__2UEs_Simultaneous_Data_Voice_Call_Taf_Ue

