*** Settings ***
Resource    ../test_resources/FM__link_break_S1_long.robot

*** Test Cases ***
FM__link_break_s1_long
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__FM__link_break_s1_long

