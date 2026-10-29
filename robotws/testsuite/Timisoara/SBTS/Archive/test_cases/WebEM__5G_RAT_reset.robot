*** Settings ***
Resource    ../test_resources/WebEM__5G_RAT_reset.robot

*** Test Cases ***
WebEM__5G_RAT_reset
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__WebEM__5G_RAT_reset
