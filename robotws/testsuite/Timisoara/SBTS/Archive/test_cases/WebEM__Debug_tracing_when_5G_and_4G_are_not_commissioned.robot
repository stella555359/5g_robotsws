*** Settings ***
Resource    ../test_resources/WebEM__Debug_tracing_when_5G_and_4G_are_not_commissioned.robot

*** Test Cases ***
WebEM__Debug_tracing_when_5G_and_4G_are_not_commissioned
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__WebEM__Debug_tracing_when_5G_and_4G_are_not_commissioned

