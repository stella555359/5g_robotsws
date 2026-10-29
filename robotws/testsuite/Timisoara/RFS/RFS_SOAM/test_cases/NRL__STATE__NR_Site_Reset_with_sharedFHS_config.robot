*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_from_WEBEM.robot

*** Test Cases ***
[1]NRL__STATE__NR_Site_Reset_with_sharedFHS_config
    [Tags]    robot:skip
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_from_WEBEM

