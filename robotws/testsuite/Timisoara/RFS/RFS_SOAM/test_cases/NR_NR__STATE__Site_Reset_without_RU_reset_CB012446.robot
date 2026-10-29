*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_without_RU_reset_CB012446.robot

*** Test Cases ***
[1]NR_NR__STATE__Site_Reset_without_RU_reset_CB012446
    [Tags]    robot:skip
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_without_RU_reset_CB012446
