*** Settings ***
Resource    ../test_resources/WebEM__Admin_CLI_Power_reset_with_additional_timeout.robot

*** Test Cases ***
WebEM__Admin_CLI_Power_reset_with_additional_timeout
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__WebEM__Admin_CLI_Power_reset_with_additional_timeout
