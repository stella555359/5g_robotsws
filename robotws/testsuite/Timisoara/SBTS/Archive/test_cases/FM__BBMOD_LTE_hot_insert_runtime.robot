*** Settings ***
Resource    ../test_resources/FM__BBMOD_LTE_hot_insert_runtime.robot

*** Test Cases ***
FM__BBMOD_LTE_hot_insert_runtime
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__FM__BBMOD_LTE_hot_insert_runtime

