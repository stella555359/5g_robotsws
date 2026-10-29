*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/SBTS_SBTS__STATE__BBMOD_RMOD_Primary_Link_Break.robot

*** Test Cases ***
[1]NR_NR__STATE__BBMOD_RMOD_Primary_Link_Break
    [Tags]    robot:skip
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__SBTS_SBTS__STATE__BBMOD_RMOD_Primary_Link_Break