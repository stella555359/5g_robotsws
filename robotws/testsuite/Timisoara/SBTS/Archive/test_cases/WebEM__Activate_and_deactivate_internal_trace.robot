*** Settings ***
Resource    ../test_resources/WebEM__Activate_and_deactivate_internal_trace.robot

*** Test Cases ***
WebEM__Activate_and_deactivate_internal_trace
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__WebEM__Activate_and_deactivate_internal_trace
