*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__Secondary_Controller_SharedRM_LockUnlock.robot

*** Test Cases ***
[1]NRL__STATE__Secondary_Controller_SharedRM_LockUnlock
    [Tags]    robot:skip
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__SBTS_SBTS_SBTS_SBTS__STATE__Secondary_Controller_SharedRM_LockUnlock

