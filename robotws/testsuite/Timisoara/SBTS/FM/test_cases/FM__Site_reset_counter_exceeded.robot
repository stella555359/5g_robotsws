*** Settings ***
Documentation  This suite contains FM__Site_reset_counter_exceeded TC

Resource  ../test_resources/FM__Site_reset_counter_exceeded.robot


*** Test Cases ***
FM__Site_reset_counter_exceeded
    [Setup]  TC Setup
    TC__FM__Site_reset_counter_exceeded
    [Teardown]  TC Teardown
