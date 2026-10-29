*** Settings ***
Documentation  This suite contains FM__link_break_SBTS_long TC

Resource  ../test_resources/FM__link_break_SBTS_long.robot


*** Test Cases ***
FM__link_break_SBTS_long
    [Setup]  TC Setup
    TC__FM__link_break_SBTS_long
    [Teardown]  TC Teardown
