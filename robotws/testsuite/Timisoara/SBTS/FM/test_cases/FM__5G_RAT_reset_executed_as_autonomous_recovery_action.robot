*** Settings ***
Documentation  This suite contains FM__5G_RAT_reset_executed_as_autonomous_recovery_action TC

Resource  ../test_resources/FM__5G_RAT_reset_executed_as_autonomous_recovery_action.robot


*** Test Cases ***
FM__5G_RAT_reset_executed_as_autonomous_recovery_action
    [Setup]  TC Setup
    TC__FM__5G_RAT_reset_executed_as_autonomous_recovery_action
    [Teardown]  TC Teardown
