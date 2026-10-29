*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/SBTS_SBTS_SBTS_SBTS__SWM__SW_Rollback.robot

*** Test Cases ***
[1]NR_SBTS__SWM__SBTS_Rollback
    [Tags]    robot:skip
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__SBTS_SBTS_SBTS_SBTS__SWM__SW_Rollback

