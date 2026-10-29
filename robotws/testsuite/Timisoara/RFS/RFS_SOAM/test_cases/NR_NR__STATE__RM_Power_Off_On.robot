*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__RM_Power_Off_On.robot

*** Test Cases ***
[1]NR_NR__STATE__RM_Power_Off_On
    [Tags]    robot:skip
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__SBTS_SBTS_SBTS_SBTS__STATE__RM_Power_Off_On

