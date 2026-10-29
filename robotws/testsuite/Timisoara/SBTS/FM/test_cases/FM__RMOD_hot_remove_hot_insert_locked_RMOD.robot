*** Settings ***
Documentation  This suite contains FM__RMOD_hot_remove_hot_insert_locked_RMOD TC

Resource  ../test_resources/FM__RMOD_hot_remove_hot_insert_locked_RMOD.robot


*** Test Cases ***
FM__RMOD_hot_remove_hot_insert_locked_RMOD
    [Setup]  TC Setup
    TC__FM__RMOD_hot_remove_hot_insert_locked_RMOD
    [Teardown]  TC Teardown
