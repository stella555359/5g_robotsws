*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/CBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset.robot

*** Test Cases ***
[1]CBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__CBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset

