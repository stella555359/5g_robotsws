*** Settings ***
Documentation  This suite contains FM__SC_reset_actForceAutoReset_false_enabled_cells TC

Resource  ../test_resources/FM__SC_reset_actForceAutoReset_false_enabled_cells.robot


*** Test Cases ***
FM__SC_reset_actForceAutoReset_false_enabled_cells
    [Setup]  TC Setup
    TC__FM__SC_reset_actForceAutoReset_false_enabled_cells
    [Teardown]  TC Teardown
