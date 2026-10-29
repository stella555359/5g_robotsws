*** Settings ***
Resource    ../test_resources/FM__Site_reset_counter_cleared_timer_exceeded.robot

*** Test Cases ***
FM__Site_reset_counter_cleared_timer_exceeded
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__FM__Site_reset_counter_cleared_timer_exceeded
