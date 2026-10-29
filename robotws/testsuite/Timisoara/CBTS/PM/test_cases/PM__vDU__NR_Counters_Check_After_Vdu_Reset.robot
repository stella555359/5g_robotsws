*** Settings ***
Documentation  This suite contains PM__vDU__NR_Counters_Check_After_Vdu_Reset TC

Resource  ../test_resources/PM__vDU__NR_Counters_Check_After_Vdu_Reset.robot


*** Test Cases ***
PM__vDU__NR_Counters_Check_After_Vdu_Reset
    [Setup]  TC Setup
    TC__PM__vDU__NR_Counters_Check_After_Vdu_Reset
    [Teardown]  TC Teardown
