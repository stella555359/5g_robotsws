*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_same_time_from_WEBEM.robot

*** Test Cases ***
[1]NRL__STATE__NR_LTE_Site_Reset_same_time_from_WEBEM
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_same_time_from_WEBEM

