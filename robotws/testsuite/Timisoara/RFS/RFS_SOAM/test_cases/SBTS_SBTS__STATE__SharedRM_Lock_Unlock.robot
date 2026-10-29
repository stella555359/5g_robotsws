*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__RM_LockUnlock.robot

*** Test Cases ***
[1]SBTS_SBTS__STATE__SharedRM_Lock_Unlock
    [Tags]    robot:skip
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__SBTS_SBTS_SBTS_SBTS__STATE__RM_LockUnlock

