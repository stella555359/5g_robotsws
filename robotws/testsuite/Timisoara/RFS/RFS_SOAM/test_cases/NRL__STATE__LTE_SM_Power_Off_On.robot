*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/SBTS_SBTS__STATE__BTS_Power_Off_On.robot

*** Test Cases ***
[1]NRL__STATE__LTE_SM_Power_Off_On
    [Tags]    robot:skip
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__SBTS_SBTS__STATE__BTS_Power_Off_On

