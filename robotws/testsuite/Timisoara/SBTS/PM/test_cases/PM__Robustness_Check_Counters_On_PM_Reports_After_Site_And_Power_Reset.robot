*** Settings ***
Documentation  This suite contains PM__Robustness_Check_Counters_On_PM_Reports_After_Site_And_Power_Reset TC

Resource  ../test_resources/PM__Robustness_Check_Counters_On_PM_Reports_After_Site_And_Power_Reset.robot


*** Test Cases ***
PM__Robustness_Check_Counters_On_PM_Reports_After_Site_And_Power_Reset
    [Setup]  TC Setup
    TC__PM__Robustness_Check_Counters_On_PM_Reports_After_Site_And_Power_Reset
    [Teardown]  TC Teardown