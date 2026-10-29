*** Settings ***
Documentation  This suite contains FM__Autonomous_Power_Cycle_Reset_for_MPlane_Loss TC

Resource  ../test_resources/FM__Autonomous_Power_Cycle_Reset_for_MPlane_Loss.robot


*** Test Cases ***
FM__Autonomous_Power_Cycle_Reset_for_MPlane_Loss
    [Setup]  TC Setup
    TC__FM__Autonomous_Power_Cycle_Reset_for_MPlane_Loss
    [Teardown]  TC Teardown
