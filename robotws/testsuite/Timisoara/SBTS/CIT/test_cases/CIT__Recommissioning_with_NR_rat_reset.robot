*** Settings ***
Documentation  This suite contains CIT__Recommissioning_with_NR_rat_reset TC

Resource  ../test_resources/CIT__Recommissioning_with_NR_rat_reset.robot


*** Test Cases ***
CIT__Recommissioning_with_NR_rat_reset
    [Setup]  TC Setup
    TC__CIT__Recommissioning_with_NR_rat_reset
    [Teardown]  TC Teardown
