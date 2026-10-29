*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__RAT_Block_Unblock_from_WEBEM.robot

*** Test Cases ***
[1]SBTS_SBTS_SBTS__STATE__RAT_Block_Unblock_from_WEBEM
    [Tags]    robot:skip
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__SBTS_SBTS_SBTS_SBTS__STATE__RAT_Block_Unblock_from_WEBEM