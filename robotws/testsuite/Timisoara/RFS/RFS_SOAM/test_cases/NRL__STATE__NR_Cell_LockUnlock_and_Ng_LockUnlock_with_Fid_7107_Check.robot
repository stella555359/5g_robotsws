*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/SBTS_SBTS__STATE__NR_Cell_LockUnlock_and_Ng_LockUnlock_with_Fid_7107_Check.robot

*** Test Cases ***
[1]NRL__STATE__NR_Cell_LockUnlock_and_Ng_LockUnlock_with_Fid_7107_Check
    [Tags]    robot:skip
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__SBTS_SBTS__STATE__NR_Cell_LockUnlock_and_Ng_LockUnlock_with_Fid_7107_Check

