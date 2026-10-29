*** Settings ***
Documentation  This suite contains PM__Check_Temperature_Counters TC

Resource  ../test_resources/PM__Check_Temperature_Counters.robot

*** Test Cases ***
PM__Check_Temperature_Counters
    [Setup]  TC Setup
    TC__PM__Check_Temperature_Counters
    [Teardown]  TC Teardown