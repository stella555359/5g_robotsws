*** Settings ***
Documentation  This suite contains FM__Site_reset_actForceAutoReset_true_enabled_cell TC

Resource  ../test_resources/FM__Site_reset_actForceAutoReset_true_enabled_cell.robot


*** Test Cases ***
FM__Site_reset_actForceAutoReset_true_enabled_cell
    [Setup]  TC Setup
    TC__FM__Site_reset_actForceAutoReset_true_enabled_cell
    [Teardown]  TC Teardown
