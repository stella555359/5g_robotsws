*** Settings ***
Documentation  This suite contains FM__link_break_IuB_short TC

Resource  ../test_resources/FM__link_break_IuB_short.robot


*** Test Cases ***
FM__link_break_IuB_short
    [Setup]  TC Setup
    TC__FM__link_break_IuB_short
    [Teardown]  TC Teardown
