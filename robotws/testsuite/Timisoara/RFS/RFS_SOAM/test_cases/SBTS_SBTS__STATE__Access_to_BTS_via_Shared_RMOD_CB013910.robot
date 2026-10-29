*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/SBTS_SBTS__STATE__Access_to_BTS_via_Shared_RMOD_CB013910.robot

*** Test Cases ***
[1]SBTS_SBTS__STATE__Access_to_BTS_via_Shared_RMOD_CB013910
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__SBTS_SBTS__STATE__Access_to_BTS_via_Shared_RMOD_CB013910
