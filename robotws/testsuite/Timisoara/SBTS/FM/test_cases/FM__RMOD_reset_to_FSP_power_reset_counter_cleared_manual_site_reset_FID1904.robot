*** Settings ***
Documentation  This suite contains FM__RMOD_reset_to_FSP_power_reset_counter_cleared_manual_site_reset_FID1904 TC

Resource  ../test_resources/FM__RMOD_reset_to_FSP_power_reset_counter_cleared_manual_site_reset_FID1904.robot


*** Test Cases ***
FM__RMOD_reset_to_FSP_power_reset_counter_cleared_manual_site_reset_FID1904
    [Setup]  TC Setup
    TC__FM__RMOD_reset_to_FSP_power_reset_counter_cleared_manual_site_reset_FID1904
    [Teardown]  TC Teardown
