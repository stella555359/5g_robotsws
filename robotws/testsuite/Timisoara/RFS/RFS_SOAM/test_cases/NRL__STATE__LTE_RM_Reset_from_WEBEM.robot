*** Settings ***
Documentation    Test Suite
Resource  ../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem.robot

*** Test Cases ***
[1]NRL__STATE__LTE_RM_Reset_from_WEBEM
    [Tags]    robot:skip
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem
