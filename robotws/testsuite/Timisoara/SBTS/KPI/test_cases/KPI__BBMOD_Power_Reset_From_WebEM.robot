*** Settings ***
Documentation  This suite contains KPI__BBMOD_Power_Reset_From_WebEM TC

Resource  ../test_resources/KPI__BBMOD_Power_Reset_From_WebEM.robot


*** Test Cases ***
KPI__BBMOD_Power_Reset_From_WebEM
    [Setup]  TC Setup
    TC__KPI__BBMOD_Power_Reset_From_WebEM
    [Teardown]  TC Teardown
