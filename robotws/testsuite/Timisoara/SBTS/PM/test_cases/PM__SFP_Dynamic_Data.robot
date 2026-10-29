*** Settings ***
Documentation  This suite contains PM__SFP_Dynamic_Data TC

Resource  ../test_resources/PM__SFP_Dynamic_Data.robot


*** Test Cases ***
PM__SFP_Dynamic_Data
    [Setup]  TC Setup
    TC__PM__SFP_Dynamic_Data
    [Teardown]  TC Teardown
