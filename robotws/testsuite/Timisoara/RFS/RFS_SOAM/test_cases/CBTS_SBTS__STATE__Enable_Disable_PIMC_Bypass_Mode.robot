*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/CBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode.robot

*** Test Cases ***
[1]CBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__CBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode
