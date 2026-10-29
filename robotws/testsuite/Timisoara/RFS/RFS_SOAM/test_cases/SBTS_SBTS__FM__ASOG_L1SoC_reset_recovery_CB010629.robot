*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/SBTS_SBTS__FM__ASOG_L1SoC_reset_recovery_CB010629.robot

*** Test Cases ***
[1]SBTS_SBTS__FM__ASOG_L1SoC_reset_recovery_CB010629
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__SBTS_SBTS__FM__ASOG_L1SoC_reset_recovery_CB010629