*** Settings ***
Documentation  This suite contains FM__link_break_Abis_startup TC

Resource  ../test_resources/FM__link_break_Abis_startup.robot


*** Test Cases ***
FM__link_break_Abis_startup
    [Setup]  TC Setup
    TC__FM__link_break_Abis_startup
    [Teardown]  TC Teardown
