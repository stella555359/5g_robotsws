*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/SBTS_SBTS__STATE__BBMOD_RMOD_Primary_Link_Break_Reset_Recovery.robot

*** Test Cases ***
[1]SBTS_SBTS__STATE__BBMOD_RMOD_Primary_Link_Break_Reset_Recovery
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__SBTS_SBTS__STATE__BBMOD_RMOD_Primary_Link_Break_Reset_Recovery