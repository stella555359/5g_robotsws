*** Settings ***
Resource    ../test_resources/FM__RMOD_hot_remove_hot_insert_primary.robot


*** Test Cases ***
FM__RMOD_hot_remove_hot_insert_primary
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__FM__RMOD_hot_remove_hot_insert_primary
