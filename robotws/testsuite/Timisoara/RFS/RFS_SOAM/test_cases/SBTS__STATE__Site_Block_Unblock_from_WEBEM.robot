*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/SBTS__STATE__Site_Block_Unblock_from_WEBEM.robot

*** Test Cases ***
[1]SBTS__STATE__Site_Block_Unblock_from_WEBEM
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__SBTS__STATE__Site_Block_Unblock_from_WEBEM

