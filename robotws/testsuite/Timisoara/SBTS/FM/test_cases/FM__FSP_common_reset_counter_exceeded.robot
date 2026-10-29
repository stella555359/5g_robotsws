*** Settings ***
Documentation  This suite contains FM__FSP_common_reset_counter_exceeded TC

Resource  ../test_resources/FM__FSP_common_reset_counter_exceeded.robot


*** Test Cases ***
FM__FSP_common_reset_counter_exceeded
    [Setup]  TC Setup
    TC__FM__FSP_common_reset_counter_exceeded
    [Teardown]  TC Teardown
