*** Settings ***
Documentation  This suite contains FM__SoC_reset_actForceUnitAutoReset_true_same_fault_in_one_hour TC

Resource  ../test_resources/FM__SoC_reset_actForceUnitAutoReset_true_same_fault_in_one_hour.robot


*** Test Cases ***
FM__SoC_reset_actForceUnitAutoReset_true_same_fault_in_one_hour
    [Setup]  TC Setup
    TC__FM__SoC_reset_actForceUnitAutoReset_true_same_fault_in_one_hour
    [Teardown]  TC Teardown
