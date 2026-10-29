*** Settings ***
Documentation  This suite contains FM__link_break_X2 TC

Resource  ../test_resources/FM__link_break_X2.robot


*** Test Cases ***
FM__link_break_X2
    [Setup]  TC Setup
    TC__FM__link_break_X2
    [Teardown]  TC Teardown