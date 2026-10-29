*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue.robot

*** Test Cases ***
[1]RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue
