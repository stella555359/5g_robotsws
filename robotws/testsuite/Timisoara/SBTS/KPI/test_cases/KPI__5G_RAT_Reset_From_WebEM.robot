*** Settings ***
Documentation  This suite contains KPI__5G_RAT_Reset_From_WebEM TC

Resource  ../test_resources/KPI__5G_RAT_Reset_From_WebEM.robot


*** Test Cases ***
KPI__5G_RAT_Reset_From_WebEM
    [Setup]  TC Setup
    TC__KPI__5G_RAT_Reset_From_WebEM
    [Teardown]  TC Teardown
