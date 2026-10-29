*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/CBTS_SBTS__LOGS__Stability.robot

*** Test Cases ***
[1]CBTS_SBTS__LOGS__Stability
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__CBTS_SBTS__LOGS__Stability