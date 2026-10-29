*** Settings ***
Documentation  This suite contains FM__C_Capacity_core_unit_5G_L3_SW_reset_escalation TC

Resource  ../test_resources/FM__C_Capacity_core_unit_5G_L3_SW_reset_escalation.robot


*** Test Cases ***
FM__C_Capacity_core_unit_5G_L3_SW_reset_escalation
    [Setup]  TC Setup
    TC__FM__C_Capacity_core_unit_5G_L3_SW_reset_escalation
    [Teardown]  TC Teardown
