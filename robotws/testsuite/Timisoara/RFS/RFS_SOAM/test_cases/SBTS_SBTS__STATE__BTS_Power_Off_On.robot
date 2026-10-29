*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/SBTS_SBTS__STATE__BTS_Power_Off_On.robot

*** Test Cases ***
[1]SBTS_SBTS__STATE__BTS_Power_Off_On
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__SBTS_SBTS__STATE__BTS_Power_Off_On

