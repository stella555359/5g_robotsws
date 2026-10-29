*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/CBTS_SBTS__STATE__CBTS_vDU_Reset_SBTS_Site_Reset.robot

*** Test Cases ***
[1]CBTS_SBTS__STATE__CBTS_vDU_Reset_SBTS_Site_Reset
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__CBTS_SBTS__STATE__CBTS_vDU_Reset_SBTS_Site_Reset

