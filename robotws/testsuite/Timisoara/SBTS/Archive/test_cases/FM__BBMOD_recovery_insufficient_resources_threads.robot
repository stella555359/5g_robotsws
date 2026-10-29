*** Settings ***
Resource    ../test_resources/FM__BBMOD_recovery_insufficient_resources_threads.robot

*** Test Cases ***
FM__BBMOD_recovery_insufficient_resources_threads
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__FM__BBMOD_recovery_insufficient_resources_threads
