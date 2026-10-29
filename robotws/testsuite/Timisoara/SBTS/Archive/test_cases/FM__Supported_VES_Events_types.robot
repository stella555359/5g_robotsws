*** Settings ***
Resource    ../test_resources/FM__Supported_VES_Events_types.robot

*** Test Cases ***
TC__FM__Supported_VES_Events_types
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    FM__Supported_VES_Events_types
