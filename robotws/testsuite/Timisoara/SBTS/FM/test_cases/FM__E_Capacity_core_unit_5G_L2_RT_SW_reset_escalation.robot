*** Settings ***
Documentation  This suite contains FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation TC

Resource  ../test_resources/FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation.robot


*** Test Cases ***
FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation
    [Setup]  TC Setup
    TC__FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation
    [Teardown]  TC Teardown
