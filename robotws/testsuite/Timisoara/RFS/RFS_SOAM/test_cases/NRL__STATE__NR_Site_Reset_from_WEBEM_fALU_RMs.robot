*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/NRL__STATE__NR_Site_Reset_from_WEBEM_fALU_RMs.robot

*** Test Cases ***
[1]NRL__STATE__NR_Site_Reset_from_WEBEM_fALU_RMs
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__NRL__STATE__NR_Site_Reset_from_WEBEM_fALU_RMs

