*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/SBTS_SBTS_SBTS__STATE__SharedRM_LockUnlock_Cell_BlockUnblock_from_WEBEM.robot

*** Test Cases ***
[1]SBTS_SBTS_SBTS__STATE__SharedRM_LockUnlock_Cell_BlockUnblock_from_WEBEM
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__SBTS_SBTS_SBTS__STATE__SharedRM_LockUnlock_Cell_BlockUnblock_from_WEBEM