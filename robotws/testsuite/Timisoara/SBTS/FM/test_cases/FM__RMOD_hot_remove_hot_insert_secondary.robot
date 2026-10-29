*** Settings ***
Documentation  This suite contains FM__RMOD_hot_remove_hot_insert_secondary TC

Resource  ../test_resources/FM__RMOD_hot_remove_hot_insert_secondary.robot


*** Test Cases ***
FM__RMOD_hot_remove_hot_insert_secondary
    [Setup]  TC Setup
    TC__FM__RMOD_hot_remove_hot_insert_secondary
    [Teardown]  TC Teardown
