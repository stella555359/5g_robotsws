*** Settings ***
Documentation  This suite contains FM__RMOD_reset_to_FSP_power_reset_exceeded_FID1905 TC

Resource  ../test_resources/FM__RMOD_reset_to_FSP_power_reset_exceeded_FID1905.robot


*** Test Cases ***
FM__RMOD_reset_to_FSP_power_reset_exceeded_FID1905
    [Setup]  TC Setup
    TC__FM__RMOD_reset_to_FSP_power_reset_exceeded_FID1905
    [Teardown]  TC Teardown
