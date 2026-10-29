*** Settings ***
Documentation  This suite contains FM__RAT_Reset_Of_Each_RAT TC

Resource  ../test_resources/FM__RAT_Reset_Of_Each_RAT.robot


*** Test Cases ***
FM__RAT_Reset_Of_Each_RAT
    [Setup]  TC Setup
    TC__FM__RAT_Reset_Of_Each_RAT
    [Teardown]  TC Teardown
