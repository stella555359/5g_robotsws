*** Settings ***
Resource    ../test_resources/FM__SMOD_recovery_insufficient_resources_threads.robot

*** Test Cases ***
FM__SMOD_recovery_insufficient_resources_threads
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__FM__SMOD_recovery_insufficient_resources_threads
