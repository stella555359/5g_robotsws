*** Settings ***
Documentation  This suite contains FM__5G_cell_graceful_shutdown_when_SC_escalates_to_site_reset TC

Resource  ../test_resources/FM__5G_cell_graceful_shutdown_when_SC_escalates_to_site_reset.robot


*** Test Cases ***
FM__FM__5G_cell_graceful_shutdown_when_SC_escalates_to_site_reset
    [Setup]  TC Setup
    TC__FM__5G_cell_graceful_shutdown_when_SC_escalates_to_site_reset
    [Teardown]  TC Teardown
