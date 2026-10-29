*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Lock_Unlock_from_WebEm.robot

*** Test Cases ***
[1]SBTS__STATE__BBMOD_LockUnlock_from_WEBEM
    [Tags]    robot:skip
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Lock_Unlock_from_WebEm

