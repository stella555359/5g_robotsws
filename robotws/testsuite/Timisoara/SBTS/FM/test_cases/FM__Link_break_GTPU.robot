*** Settings ***
Documentation  This suite contains FM__Link_break_GTPU TC

Resource  ../test_resources/FM__Link_break_GTPU.robot


*** Test Cases ***
FM__Link_break_GTPU
    [Setup]  TC Setup
    TC__FM__Link_break_GTPU
    [Teardown]  TC Teardown
