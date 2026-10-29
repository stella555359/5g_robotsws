*** Settings ***
Documentation  This suite contains FM__VN_recovery_reset_counter_cleared_-_manual_site_reset TC

Resource  ../test_resources/FM__VN_recovery_reset_counter_cleared_-_manual_site_reset.robot


*** Test Cases ***
FM__VN_recovery_reset_counter_cleared_-_manual_site_reset.robot
    [Setup]  TC Setup
    TC__FM__VN_recovery_reset_counter_cleared_-_manual_site_reset
    [Teardown]  TC Teardown
