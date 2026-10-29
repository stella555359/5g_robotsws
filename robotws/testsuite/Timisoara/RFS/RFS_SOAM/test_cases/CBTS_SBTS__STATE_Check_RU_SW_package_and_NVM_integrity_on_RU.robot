*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/CBTS_SBTS__STATE_Check_RU_SW_package_and_NVM_integrity_on_RU.robot

*** Test Cases ***
[1]CBTS_SBTS__STATE_Check_RU_SW_package_and_NVM_integrity_on_RU
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__CBTS_SBTS__STATE_Check_RU_SW_package_and_NVM_integrity_on_RU