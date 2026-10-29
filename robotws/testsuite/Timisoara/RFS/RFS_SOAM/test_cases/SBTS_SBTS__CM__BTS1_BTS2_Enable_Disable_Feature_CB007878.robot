*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/SBTS_SBTS__CM__BTS1_BTS2_Enable_Disable_Feature_CB007878.robot

*** Test Cases ***
[1]SBTS_SBTS__CM__BTS1_BTS2_Enable_Disable_Feature_CB007878
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__SBTS_SBTS__CM__BTS1_BTS2_Enable_Disable_Feature_CB007878

