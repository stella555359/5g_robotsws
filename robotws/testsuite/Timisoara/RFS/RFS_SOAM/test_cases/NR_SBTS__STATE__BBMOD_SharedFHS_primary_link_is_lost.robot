*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/NR_SBTS__STATE__BBMOD_SharedFHS_primary_link_is_lost.robot

*** Test Cases ***
[1]NR_SBTS__STATE__BBMOD_SharedFHS_primary_link_is_lost
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__NR_SBTS__STATE__BBMOD_SharedFHS_primary_link_is_lost