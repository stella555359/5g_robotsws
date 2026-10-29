*** Settings ***
Documentation  This suite contains PM__Check_Counters_Number_On_NetAct_Reports TC

Resource  ../test_resources/PM__Check_Counters_Number_On_NetAct_Reports.robot


*** Test Cases ***
PM__Check_Counters_Number_On_NetAct_Reports
    [Setup]  TC Setup
    TC__PM__Check_Counters_Number_On_NetAct_Reports
    [Teardown]  TC Teardown
