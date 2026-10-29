*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/SBTS_SBTS__SWM__RU_SW_Upgrade.robot

*** Test Cases ***
[1]SBTS_SBTS__SWM__RU_SW_Upgrade
    [Tags]    robot:skip
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__SBTS_SBTS__SWM__RU_SW_Upgrade