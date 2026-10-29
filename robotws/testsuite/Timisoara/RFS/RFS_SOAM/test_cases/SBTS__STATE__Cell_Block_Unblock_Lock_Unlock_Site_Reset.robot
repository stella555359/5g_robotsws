*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_Lock_Unlock_Site_Reset.robot

*** Test Cases ***
[1]SBTS__STATE__Cell_Block_Unblock_Lock_Unlock_Site_Reset
    [Tags]    robot:skip
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_Lock_Unlock_Site_Reset