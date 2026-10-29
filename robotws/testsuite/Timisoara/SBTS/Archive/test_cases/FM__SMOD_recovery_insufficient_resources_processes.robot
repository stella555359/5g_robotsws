*** Settings ***
Resource    ../test_resources/FM__SMOD_recovery_insufficient_resources_processes.robot

*** Test Cases ***
FM__SMOD_recovery_insufficient_resources_processes
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__FM__SMOD_recovery_insufficient_resources_processes
