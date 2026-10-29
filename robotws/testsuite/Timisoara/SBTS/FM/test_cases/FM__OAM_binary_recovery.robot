*** Settings ***
Documentation  This suite contains TC__OAM_binary_recovery TC

Resource  ../test_resources/FM__OAM_binary_recovery.robot


*** Test Cases ***
TC__OAM_binary_recovery
    [Setup]  TC Setup
    FM__OAM_binary_recovery
    [Teardown]  TC Teardown
