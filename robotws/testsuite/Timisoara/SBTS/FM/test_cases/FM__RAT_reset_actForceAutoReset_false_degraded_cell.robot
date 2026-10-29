*** Settings ***
Documentation  This suite contains FM__RAT_reset_actForceAutoReset_false_degraded_cell TC

Resource  ../test_resources/FM__RAT_reset_actForceAutoReset_false_degraded_cell.robot


*** Test Cases ***
FM__RAT_reset_actForceAutoReset_false_degraded_cell
    [Setup]  TC Setup
    TC__FM__RAT_reset_actForceAutoReset_false_degraded_cell
    [Teardown]  TC Teardown
