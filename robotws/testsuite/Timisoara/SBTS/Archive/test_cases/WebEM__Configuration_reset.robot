*** Settings ***
Resource    ../test_resources/WebEM__Configuration_reset.robot

*** Test Cases ***
WebEM__Configuration_reset
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__WebEM__Configuration_reset
