*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__Cell_Lock_Unlock_via_PLAN.robot

*** Test Cases ***
[1]SBTS_SBTS__STATE__Cell_Lock_Unlock_via_PLAN
    [Tags]    robot:skip
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__SBTS_SBTS_SBTS_SBTS__STATE__Cell_Lock_Unlock_via_PLAN