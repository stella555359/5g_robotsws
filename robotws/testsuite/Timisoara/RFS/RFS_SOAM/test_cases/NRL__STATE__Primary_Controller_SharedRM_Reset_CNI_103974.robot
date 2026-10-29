*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem.robot

*** Test Cases ***
[1]NRL__STATE__Primary_Controller_SharedRM_Reset_CNI_103974
    [Tags]    robot:skip
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem

