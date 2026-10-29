*** Settings ***
Documentation  This suite contains FM__SoC_reset_not_allowed_allowBbPoolRecoveryReset_false TC

Resource  ../test_resources/FM__SoC_reset_not_allowed_allowBbPoolRecoveryReset_false.robot


*** Test Cases ***
FM__SoC_reset_not_allowed_allowBbPoolRecoveryReset_false
    [Setup]  TC Setup
    TC__FM__SoC_reset_not_allowed_allowBbPoolRecoveryReset_false
    [Teardown]  TC Teardown
