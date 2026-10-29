*** Settings ***
Documentation  This suite contains FM__B_5G_RAT_reset_counter_cleared__manual_site_reset TC

Resource  ../test_resources/FM__B_5G_RAT_reset_counter_cleared__manual_site_reset.robot


*** Test Cases ***
FM__B_5G_RAT_reset_counter_cleared__manual_site_reset
    [Setup]  TC Setup
    TC__FM__B_5G_RAT_reset_counter_cleared__manual_site_reset
    [Teardown]  TC Teardown
