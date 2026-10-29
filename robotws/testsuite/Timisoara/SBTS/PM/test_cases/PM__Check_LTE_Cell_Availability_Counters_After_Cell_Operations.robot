*** Settings ***
Documentation  This suite contains PM__Check_Counters_After_LTE_Cell_Operations TC

Resource  ../test_resources/PM__Check_LTE_Cell_Availability_Counters_After_Cell_Operations.robot


*** Test Cases ***
PM__Check_LTE_Cell_Availability_Counters_After_Cell_Operations
    [Setup]  TC Setup
    TC__PM__Check_LTE_Cell_Availability_Counters_After_Cell_Operations
    [Teardown]  TC Teardown
