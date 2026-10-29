*** Settings ***
Resource    ../test_resources/FM__RMOD_hot_remove_hot_insert_long_fibers.robot

*** Test Cases ***
FM__RMOD_hot_remove_hot_insert_long_fibers.robot
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__FM__RMOD_hot_remove_hot_insert_long_fibers

