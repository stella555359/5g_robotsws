*** Settings ***
Documentation  This suite contains FM__link_break_Abis_long TC

Resource  ../test_resources/FM__link_break_Abis_long.robot


*** Test Cases ***
FM__link_break_Abis_long
    [Setup]  TC Setup
    TC__FM__link_break_Abis_long
    [Teardown]  TC Teardown
