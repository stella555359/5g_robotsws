*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/SBTS_SBTS__SWM__SW_Fallback.robot

*** Test Cases ***
[1]SBTS_SBTS__SWM__SW_Fallback
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__SBTS_SBTS__SWM__SW_Fallback

