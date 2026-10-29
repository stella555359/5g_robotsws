*** Settings ***
Documentation  This suite contains KPI__Max_Duration_of_GNSSE_Reset TC

Resource  ../test_resources/KPI__Max_Duration_of_GNSSE_Reset.robot


*** Test Cases ***
KPI__Max_Duration_of_GNSSE_Reset
    [Setup]  TC Setup
    TC__KPI__Max_Duration_of_GNSSE_Reset
    [Teardown]  TC Teardown
