*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__Secondary_Controller_check_Temporary_Primary_Controller_role_feature.robot

*** Test Cases ***
[1]NRL__STATE__NR_LTE_Startup_Check_TRM_Feature
    [Tags]    robot:skip
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__SBTS_SBTS_SBTS_SBTS__STATE__Secondary_Controller_check_Temporary_Primary_Controller_role_feature

