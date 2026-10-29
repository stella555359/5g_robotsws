*** Settings ***
Documentation  This suite contains FM__link_break_Abis_short TC

Resource  ../test_resources/FM__link_break_Abis_short.robot


*** Test Cases ***
FM__link_break_Abis_short
    [Setup]  TC Setup
    TC__FM__link_break_Abis_short
    [Teardown]  TC Teardown
