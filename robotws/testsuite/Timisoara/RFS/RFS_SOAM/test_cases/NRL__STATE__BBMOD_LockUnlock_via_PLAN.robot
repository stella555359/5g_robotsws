*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/SBTS_SBTS__STATE__BBMOD_LockUnlock_via_PLAN.robot

*** Test Cases ***
[1]NRL__STATE__BBMOD_LockUnlock_via_PLAN
    [Tags]    robot:skip
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__SBTS_SBTS__STATE__BBMOD_LockUnlock_via_PLAN
