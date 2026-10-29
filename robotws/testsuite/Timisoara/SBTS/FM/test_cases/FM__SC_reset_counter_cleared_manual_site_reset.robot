*** Settings ***
Documentation  This suite contains FM__SC_reset_counter_cleared_manual_site_reset TC

Resource  ../test_resources/FM__SC_reset_counter_cleared_manual_site_reset.robot


*** Test Cases ***
FM__SC_reset_counter_cleared_manual_site_reset
    [Setup]  TC Setup
    TC__FM__SC_reset_counter_cleared_manual_site_reset
    [Teardown]  TC Teardown
