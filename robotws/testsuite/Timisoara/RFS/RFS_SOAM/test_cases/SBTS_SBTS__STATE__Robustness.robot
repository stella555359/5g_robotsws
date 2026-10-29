*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/SBTS_SBTS__STATE__Robustness.robot

*** Test Cases ***
[1]SBTS_SBTS__STATE__Robustness
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__SBTS_SBTS__STATE__Robustness

