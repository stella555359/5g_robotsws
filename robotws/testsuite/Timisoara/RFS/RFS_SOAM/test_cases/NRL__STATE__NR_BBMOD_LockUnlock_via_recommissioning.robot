*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/NRL__STATE__NR_BBMOD_LockUnlock_via_recommissioning.robot

*** Test Cases ***
[1]NRL__STATE__NR_BBMOD_LockUnlock_via_recommissioning
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__NRL__STATE__NR_BBMOD_LockUnlock_via_recommissioning