*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/NRL__STATE__LTE_SM_Power_Off_On_CBRS.robot

*** Test Cases ***
[1]NRL__STATE__LTE_SM_Power_Off_On_CBRS
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__NRL__STATE__LTE_SM_Power_Off_On_CBRS