*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/SBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode.robot

*** Test Cases ***
[1]SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__SBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode
