*** Settings ***
Documentation  This suite contains PM__vDU__Check_Performance_Management_Counters_GUI TC

Resource  ../test_resources/PM__vDU__Check_Performance_Management_Counters_GUI.robot


*** Test Cases ***
PM__vDU__Check_Performance_Management_Counters_GUI
    [Setup]  TC Setup
    TC__PM__vDU__Check_Performance_Management_Counters_GUI
    [Teardown]  TC Teardown
