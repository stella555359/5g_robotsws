*** Settings ***
Documentation  This suite contains FM__link_break_IuB_long TC

Resource  ../test_resources/FM__link_break_IuB_long.robot


*** Test Cases ***
FM__link_break_IuB_long
    [Setup]  TC Setup
    TC__FM__link_break_IuB_long
    [Teardown]  TC Teardown
