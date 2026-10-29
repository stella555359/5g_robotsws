*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/SBTS_SBTS__STATE__SMOD_BBMOD_shared_RM_Primary_link_is_lost.robot

*** Test Cases ***
[1]NRL__STATE__SMOD_BBMOD_shared_RM_Primary_link_is_lost
    [Tags]    robot:skip
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__SBTS_SBTS__STATE__SMOD_BBMOD_shared_RM_Primary_link_is_lost