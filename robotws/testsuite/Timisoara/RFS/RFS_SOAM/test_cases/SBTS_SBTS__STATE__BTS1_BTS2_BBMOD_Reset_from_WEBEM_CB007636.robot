*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WEBEM_CB007636.robot

*** Test Cases ***
[1]SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WEBEM_CB007636
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WEBEM_CB007636
