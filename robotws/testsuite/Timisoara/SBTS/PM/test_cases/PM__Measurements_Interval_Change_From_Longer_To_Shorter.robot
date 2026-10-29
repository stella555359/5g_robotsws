*** Settings ***
Documentation  This suite contains PM__Measurements_Interval_Change_From_Longer_To_Shorter TC

Resource  ../test_resources/PM__Measurements_Interval_Change_From_Longer_To_Shorter.robot


*** Test Cases ***
PM__Measurements_Interval_Change_From_Longer_To_Shorter
    [Setup]  TC Setup
    TC__PM__Measurements_Interval_Change_From_Longer_To_Shorter
    [Teardown]  TC Teardown