*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/SBTS_SBTS__LOGS__RF_Scan.robot

*** Test Cases ***
[1]NRL__LOGS__RF_Scan
    [Tags]    robot:skip
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__SBTS_SBTS__LOGS__RF_Scan

