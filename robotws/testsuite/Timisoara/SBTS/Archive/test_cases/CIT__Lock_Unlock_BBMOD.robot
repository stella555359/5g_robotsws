*** Settings ***
Resource    ../test_resources/CIT__Lock_Unlock_BBMOD.robot

*** Test Cases ***
CIT__Lock_Unlock_BBMOD
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__CIT__Lock_Unlock_BBMOD
