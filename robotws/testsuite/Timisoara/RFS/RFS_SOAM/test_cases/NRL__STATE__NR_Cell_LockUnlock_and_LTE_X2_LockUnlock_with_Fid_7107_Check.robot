*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/NRL__STATE__NR_Cell_LockUnlock_and_LTE_X2_LockUnlock_with_Fid_7107_Check.robot

*** Test Cases ***
[1]NRL__STATE__NR_Cell_LockUnlock_and_LTE_X2_LockUnlock_with_Fid_7107_Check
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__NRL__STATE__NR_Cell_LockUnlock_and_LTE_X2_LockUnlock_with_Fid_7107_Check

