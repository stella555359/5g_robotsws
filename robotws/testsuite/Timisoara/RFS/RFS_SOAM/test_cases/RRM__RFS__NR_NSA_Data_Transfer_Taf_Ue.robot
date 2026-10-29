*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/RRM__RFS__NR_NSA_Data_Transfer_Taf_Ue.robot

*** Test Cases ***
[1]RRM__RFS__NR_NSA_Data_Transfer_Taf_Ue
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__RRM__RFS__NR_NSA_Data_Transfer_Taf_Ue