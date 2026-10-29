*** Settings ***
Resource    ../test_resources/WebEM__RET_CW_view.robot

*** Test Cases ***
WebEM__RET_CW_view
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__WebEM__RET_CW_view
