*** Settings ***
Documentation  This suite contains FM__RF_hot_remove_hot_insert_via_SWN_RU TC

Resource  ../test_resources/FM__RF_hot_remove_hot_insert_via_SWN_RU.robot


*** Test Cases ***
FM__RF_hot_remove_hot_insert_via_SWN_RU
    [Setup]  TC Setup
    TC__FM__RF_hot_remove_hot_insert_via_SWN_RU
    [Teardown]  TC Teardown
