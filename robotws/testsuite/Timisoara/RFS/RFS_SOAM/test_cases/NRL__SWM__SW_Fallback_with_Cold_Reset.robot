*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/SBTS_SBTS__SWM__SW_Fallback_with_Cold_Reset.robot

*** Test Cases ***
[1]NRL__SWM__SW_Fallback_with_Cold_Reset
    [Tags]    robot:skip
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__SBTS_SBTS__SWM__SW_Fallback_with_Cold_Reset

