*** Settings ***
Documentation  This suite contains PM__vCU__Sum_NR_Counters_Suppression TC

Resource  ../test_resources/PM__vCU__Sum_NR_Counters_Suppression.robot


*** Test Cases ***
PM__vCU__Sum_NR_Counters_Suppression
    [Setup]  TC Setup
    TC__PM__vCU__Sum_NR_Counters_Suppression
    [Teardown]  TC Teardown
