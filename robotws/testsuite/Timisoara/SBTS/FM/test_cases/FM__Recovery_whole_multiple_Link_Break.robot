*** Settings ***
Documentation  This suite contains FM__Recovery_whole_multiple_Link_Break TC

Resource  ../test_resources/FM__Recovery_whole_multiple_Link_Break.robot


*** Test Cases ***
FM__Recovery_whole_multiple_Link_Break
    [Setup]  TC Setup
    TC__FM__Recovery_whole_multiple_Link_Break
    [Teardown]  TC Teardown
