*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__Secondary_Controller_SharedRM_LockUnlock_via_PLAN.robot

*** Test Cases ***
[1]SBTS_SBTS_SBTS_SBTS__STATE__Secondary_Controller_SharedRM_LockUnlock_via_PLAN
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__SBTS_SBTS_SBTS_SBTS__STATE__Secondary_Controller_SharedRM_LockUnlock_via_PLAN
