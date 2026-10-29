*** Settings ***
Resource    ../test_resources/FM__Change_dnPrefix_ASIL.robot

*** Test Cases ***
TC__FM__Change_dnPrefix_ASIL
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    FM__Change_dnPrefix_ASIL
