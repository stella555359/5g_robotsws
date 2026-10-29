*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/SBTS_SBTS__STATE__Uncontrolled_L1Soc_Reset_CB010846.robot

*** Test Cases ***
[1]SBTS_SBTS__STATE__Uncontrolled_L1Soc_Reset_CB010846
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__SBTS_SBTS__STATE__Uncontrolled_L1Soc_Reset_CB010846
