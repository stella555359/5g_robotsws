*** Settings ***
Documentation  This suite contains FM__B_5G_RAT_reset_counter_exceeded TC

Resource  ../test_resources/FM__B_5G_RAT_reset_counter_exceeded.robot


*** Test Cases ***
FM__B_5G_RAT_reset_counter_exceeded
    [Setup]  TC Setup
    TC__FM__B_5G_RAT_reset_counter_exceeded
    [Teardown]  TC Teardown
