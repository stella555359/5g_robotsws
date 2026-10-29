*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/SBTS_SBTS_SBTS_SBTS__LOGS__Stability.robot

*** Test Cases ***
[1]NRL__LOGS__NR_LTE_Stability
    [Tags]    robot:skip
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__SBTS_SBTS_SBTS_SBTS__LOGS__Stability
