*** Settings ***
Documentation  This suite contains FM__link_break_IuB_startup TC

Resource  ../test_resources/FM__link_break_IuB_startup.robot


*** Test Cases ***
FM__link_break_IuB_startup
    [Setup]  TC Setup
    TC__FM__link_break_IuB_startup
    [Teardown]  TC Teardown
