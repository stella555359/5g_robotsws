*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/NR_SBTS__STATE__NR_BBMOD_LockUnlock_via_recommissioning.robot

*** Test Cases ***
[1]NR_SBTS__STATE__NR_BBMOD_LockUnlock_via_recommissioning
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__NR_SBTS__STATE__NR_BBMOD_LockUnlock_via_recommissioning
