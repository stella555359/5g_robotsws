*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/SBTS_SBTS__STATE__SMOD_BBMOD_shared_RM_Secondary_link_is_lost.robot

*** Test Cases ***
[1]SBTS_SBTS__STATE__SMOD_BBMOD_shared_RM_Secondary_link_is_lost
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__SBTS_SBTS__STATE__SMOD_BBMOD_shared_RM_Secondary_link_is_lost