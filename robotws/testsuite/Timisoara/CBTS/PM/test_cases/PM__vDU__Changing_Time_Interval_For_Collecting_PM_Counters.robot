*** Settings ***
Documentation  This suite contains PM__vDU__Changing_Time_Interval_For_Collecting_PM_Counters TC

Resource  ../test_resources/PM__vDU__Changing_Time_Interval_For_Collecting_PM_Counters.robot


*** Test Cases ***
PM__vDU__Changing_Time_Interval_For_Collecting_PM_Counters
    [Setup]  TC Setup
    TC__PM__vDU__Changing_Time_Interval_For_Collecting_PM_Counters
    [Teardown]  TC Teardown