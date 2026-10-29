*** Settings ***
Documentation  This suite contains FM__link_break_X2_long TC

Resource  ../test_resources/FM__link_break_X2_long.robot


*** Test Cases ***
FM__link_break_X2_long
    [Setup]  TC Setup
    TC__FM__link_break_X2_long
    [Teardown]  TC Teardown
