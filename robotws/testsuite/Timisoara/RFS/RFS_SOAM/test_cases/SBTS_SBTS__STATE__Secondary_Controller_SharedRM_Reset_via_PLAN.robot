*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/SBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset_via_PLAN.robot

*** Test Cases ***
[1]SBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset_via_PLAN
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__SBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset_via_PLAN

