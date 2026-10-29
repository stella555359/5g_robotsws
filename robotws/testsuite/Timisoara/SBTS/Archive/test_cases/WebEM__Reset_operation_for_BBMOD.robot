*** Settings ***
Resource    ../test_resources/WebEM__Reset_operation_for_BBMOD.robot

*** Test Cases ***
WebEM__Reset_operation_for_BBMOD
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__WebEM__Reset_operation_for_BBMOD
