*** Settings ***
Documentation  This suite contains FM__vDU__Escalation_of_Recovery_Resets_to_Power_Cycle_Reset.robot TC

Resource  ../test_resources/FM__vDU__Escalation_of_Recovery_Resets_to_Power_Cycle_Reset.robot


*** Test Cases ***
FM__vDU__Escalation_of_Recovery_Resets_to_Power_Cycle_Reset.robot
    [Setup]  TC Setup
    TC__FM__vDU__Escalation_of_Recovery_Resets_to_Power_Cycle_Reset
    [Teardown]  TC Teardown
