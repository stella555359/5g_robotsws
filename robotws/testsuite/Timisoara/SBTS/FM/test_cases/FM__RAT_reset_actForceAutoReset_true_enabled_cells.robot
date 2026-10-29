*** Settings ***
Documentation  This suite contains FM__RAT_reset_actForceAutoReset_true_enabled_cells TC

Resource  ../test_resources/FM__RAT_reset_actForceAutoReset_true_enabled_cells.robot


*** Test Cases ***
FM__RAT_reset_actForceAutoReset_true_enabled_cells
    [Setup]  TC Setup
    TC__FM__RAT_reset_actForceAutoReset_true_enabled_cells
    [Teardown]  TC Teardown
