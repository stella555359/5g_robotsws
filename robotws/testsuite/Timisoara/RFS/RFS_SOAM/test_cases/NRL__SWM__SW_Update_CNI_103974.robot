*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/SBTS_SBTS_SBTS_SBTS__SWM__SW_Update_CNI_103974.robot

*** Test Cases ***
[1]NRL__SWM__SW_Update_CNI_103974
    [Tags]    robot:skip
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__SBTS_SBTS_SBTS_SBTS__SWM__SW_Update_CNI_103974

