*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/SBTS__STATE__RM_Power_Off_On.robot

*** Test Cases ***
[1]SBTS__STATE__RM_Power_Off_On
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__SBTS__STATE__RM_Power_Off_On

