*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/NR_SBTS__STATE__NR_SBTS_SM_Power_Off_On.robot

*** Test Cases ***
[1]NR_SBTS__STATE__NR_SBTS_SM_Power_Off_On
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__NR_SBTS__STATE__NR_SBTS_SM_Power_Off_On

