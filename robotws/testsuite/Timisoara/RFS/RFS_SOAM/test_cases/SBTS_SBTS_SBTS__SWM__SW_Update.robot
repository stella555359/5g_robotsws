*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/SBTS_SBTS_SBTS_SBTS__SWM__SW_Update.robot

*** Test Cases ***
[1]SBTS_SBTS_SBTS__SWM__SW_Update
    [Tags]    robot:skip
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__SBTS_SBTS_SBTS_SBTS__SWM__SW_Update

