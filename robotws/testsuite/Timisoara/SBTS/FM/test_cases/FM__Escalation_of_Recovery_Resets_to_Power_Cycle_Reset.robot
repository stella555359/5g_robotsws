*** Settings ***
Documentation  This suite contains FM__Escalation_of_Recovery_Resets_to_Power_Cycle_Reset TC

Resource  ../test_resources/FM__Escalation_of_Recovery_Resets_to_Power_Cycle_Reset.robot


*** Test Cases ***
FM__Escalation_of_Recovery_Resets_to_Power_Cycle_Reset
    [Setup]  TC Setup
    TC__FM__Escalation_of_Recovery_Resets_to_Power_Cycle_Reset
    [Teardown]  TC Teardown
