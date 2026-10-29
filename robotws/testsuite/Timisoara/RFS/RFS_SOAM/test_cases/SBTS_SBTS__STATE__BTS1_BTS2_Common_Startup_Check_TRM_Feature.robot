*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__Secondary_Controller_check_Temporary_Primary_Controller_role_feature.robot

*** Test Cases ***
[1]SBTS_SBTS__STATE__BTS1_BTS2_Common_Startup_Check_TRM_Feature
    [Tags]    robot:skip
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__SBTS_SBTS_SBTS_SBTS__STATE__Secondary_Controller_check_Temporary_Primary_Controller_role_feature

