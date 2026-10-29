*** Settings ***
Documentation  This suite contains FM__RAT_reset_counter_exceeded_multi_RAT TC

Resource  ../test_resources/FM__RAT_reset_counter_exceeded__multi_RAT.robot


*** Test Cases ***
FM__RAT_reset_counter_exceeded_multi_RAT
    [Setup]  TC Setup
    TC__FM__RAT_reset_counter_exceeded_multi_RAT
    [Teardown]  TC Teardown
