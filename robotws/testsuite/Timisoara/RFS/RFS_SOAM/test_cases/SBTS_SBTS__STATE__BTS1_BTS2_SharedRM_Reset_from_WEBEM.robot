*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/SBTS_SBTS__STATE__BTS1_BTS2_SharedRM_Reset_from_WEBEM.robot

*** Test Cases ***
[1]SBTS_SBTS__STATE__BTS1_BTS2_SharedRM_Reset_from_WEBEM
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__SBTS_SBTS__STATE__BTS1_BTS2_SharedRM_Reset_from_WEBEM

