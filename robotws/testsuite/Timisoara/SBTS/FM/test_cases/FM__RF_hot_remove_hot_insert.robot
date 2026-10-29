*** Settings ***
Documentation  This suite contains FM__RF_hot_remove_hot_insert TC

Resource  ../test_resources/FM__RF_hot_remove_hot_insert.robot


*** Test Cases ***
FM__RF_hot_remove_hot_insert
    [Setup]  TC Setup
    TC__FM__RF_hot_remove_hot_insert
    [Teardown]  TC Teardown
