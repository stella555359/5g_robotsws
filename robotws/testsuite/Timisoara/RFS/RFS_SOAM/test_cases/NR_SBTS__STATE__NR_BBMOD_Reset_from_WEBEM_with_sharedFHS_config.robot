*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM.robot

*** Test Cases ***
[1]NR_SBTS__STATE__NR_BBMOD_Reset_from_WEBEM_with_sharedFHS_config
    [Tags]    robot:skip
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WEBEM
