*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/SBTS_SBTS__STATE__RM_Power_Off_On_CNI-149450.robot

*** Test Cases ***
[1]SBTS_SBTS__STATE__RM_Power_Off_On_CNI-149450
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__SBTS_SBTS__STATE__RM_Power_Off_On_CNI-149450