*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/CBTS_SBTS__STATE__RM_Power_Off_On.robot

*** Test Cases ***
[1]CBTS_SBTS__STATE__RM_Power_Off_On
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__CBTS_SBTS__STATE__RM_Power_Off_On

