*** Settings ***
Documentation  This suite contains FM__Site_reset_recovery_counter_cleared_-_manual_site_reset TC

Resource  ../test_resources/FM__Site_reset_recovery_counter_cleared_-_manual_site_reset.robot


*** Test Cases ***
FM__Site_reset_recovery_counter_cleared_-_manual_site_reset
    [Setup]  TC Setup
    TC__FM__Site_reset_recovery_counter_cleared_-_manual_site_reset
    [Teardown]  TC Teardown
