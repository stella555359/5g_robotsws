*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/NRL__STATE__NR_FHS_Reset_from_WEBEM.robot

*** Test Cases ***
[1]NRL__STATE__NR_FHS_Reset_from_WEBEM
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__NRL__STATE__NR_FHS_Reset_from_WEBEM

