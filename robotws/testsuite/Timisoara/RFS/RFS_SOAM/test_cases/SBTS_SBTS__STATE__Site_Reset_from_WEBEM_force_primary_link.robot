*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_from_WEBEM.robot

*** Test Cases ***
[1]SBTS_SBTS__STATE__Site_Reset_from_WEBEM_force_primary_link
    [Tags]    robot:skip
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_from_WEBEM

