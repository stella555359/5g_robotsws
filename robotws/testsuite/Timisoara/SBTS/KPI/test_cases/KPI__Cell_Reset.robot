*** Settings ***
Documentation  This suite contains KPI__Cell_Reset TC

Resource  ../test_resources/KPI__Cell_Reset.robot


*** Test Cases ***
KPI__Cell_Reset
    [Setup]  TC Setup
    TC__KPI__Cell_Reset
    [Teardown]  TC Teardown
