*** Settings ***
Documentation  This suite contains FM__5G_BBMOD_unit_recovery_reset_counter_exceeded TC

Resource  ../test_resources/FM__5G_BBMOD_unit_recovery_reset_counter_exceeded.robot


*** Test Cases ***
TC__5G_BBMOD_unit_recovery_reset_counter_exceeded
    [Setup]  TC Setup
    FM__5G_BBMOD_unit_recovery_reset_counter_exceeded
    [Teardown]  TC Teardown
