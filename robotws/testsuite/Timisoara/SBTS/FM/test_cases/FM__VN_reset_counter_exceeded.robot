*** Settings ***
Documentation  This suite contains FM__VN_reset_counter_exceeded TC

Resource  ../test_resources/FM__VN_reset_counter_exceeded.robot


*** Test Cases ***
FM__VN_reset_counter_exceeded
    [Setup]  TC Setup
    TC__FM__VN_reset_counter_exceeded
    [Teardown]  TC Teardown
