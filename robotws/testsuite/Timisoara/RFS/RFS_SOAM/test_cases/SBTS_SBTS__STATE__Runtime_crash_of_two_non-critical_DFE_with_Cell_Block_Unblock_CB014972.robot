*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/SBTS_SBTS__STATE__Runtime_crash_of_two_non-critical_DFE_with_Cell_Block_Unblock_CB014972.robot

*** Test Cases ***
[1]SBTS_SBTS__STATE__Runtime_crash_of_two_non-critical_DFE_with_Cell_Block_Unblock_CB014972
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__SBTS_SBTS__STATE__Runtime_crash_of_two_non-critical_DFE_with_Cell_Block_Unblock_CB014972

