*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/SBTS_SBTS__STATE__Primary_Controller_BBMOD_Reset_one_by_one.robot

*** Test Cases ***
[1]SBTS_SBTS__STATE__Primary_Controller_BBMOD_Reset_one_by_one
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__SBTS_SBTS__STATE__Primary_Controller_BBMOD_Reset_one_by_one

