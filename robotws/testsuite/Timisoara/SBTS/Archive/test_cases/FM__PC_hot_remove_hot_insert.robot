*** Settings ***
Resource    ../test_resources/FM__PC_hot_remove_hot_insert.robot

*** Test Cases ***
FM__PC_hot_remove_hot_insert
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__FM__PC_hot_remove_hot_insert

