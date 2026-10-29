*** Settings ***
Documentation  This suite contains CM_Cable_Speed_Change TC

Resource  ../test_resources/CM_CABLE_SPEED_CHANGE.robot


*** Test Cases ***
CM_Cable_Speed_Change
    [Setup]  TC Setup
    TC__CM_Cable_Speed_Change
    [Teardown]  TC Teardown
