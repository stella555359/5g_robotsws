*** Settings ***
Resource    ../test_resources/FM__BBMOD_hot_remove_local_RMOD.robot

*** Test Cases ***
FM__BBMOD_hot_remove_local_RMOD_F
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__FM__BBMOD_hot_remove_local_RMOD_F

