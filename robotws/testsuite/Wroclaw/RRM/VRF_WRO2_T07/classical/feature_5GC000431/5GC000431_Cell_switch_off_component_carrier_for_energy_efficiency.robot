*** Settings ***
Documentation
...   author: Patryk Janas
...   contact: patryk.janas@nokia.com
...   maintainer:    patryk.janas@nokia.com
...   Description:   This feature describes and verify cell switch off (carrier component) for energy efficiency

#Force Tags    CA_5G_RRM   STATE_SW_UPLOADED   PY36
#...           RAN_5G    RAN_5G_FDD    RAN_5G_FDD_CD    RAN_5G_FDD_MP    RAN_5G_FDD_MP_CUSTOMER   RAN_5G_MP
#...           SBTS00__WITH__CLOUD_5G_CLASSICAL_SA_4xANDROID_ASIK_ABIL_3xAHLOA_ENB

Library     testsuite/Wroclaw/RRM/resources/TestCaseRequirement.py
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/logs/btslog.py
Library     testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.testline_preparation    WITH NAME    testline_preparation
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/feature_5GC000431/resources/keywords_431.robot


Suite Setup       Run keywords
...               prepare_testline                              AND
...               Add nrpgrp object

Test Setup        Run keywords
...               start_btslog_on_local_machine                 AND
...               AdminUtils.wait_for_all_cells_on_air_state

Test Teardown     stop_and_collect_btslog


*** Test Cases ***
[1]5GC000431_A_1_Feature_5GC000431_Activation
    [1]5GC000431_A_1_Feature_5GC000431_Activation


[1]5GC000431_A_3_Feature_5GC000431_Deactivation_with_cell_in_energySaving_state
    [1]5GC000431_A_3_Feature_5GC000431_Deactivation_with_cell_in_energySaving_state


[1]5GC000431_A_2_Feature_5GC000431_Deactivation
    [Setup]  Requires TC      [1]5GC000431_A_3_Feature_5GC000431_Deactivation_with_cell_in_energySaving_state
    Log      TC passed by 5GC000431_A_3_Feature_5GC000431_Deactivation_with_cell_in_energySaving_state


[1]5GC000431_A_4_Feature_5GC000431_Configure_Load-Based_Power_Saving_Controls
    [1]5GC000431_A_4_Feature_5GC000431_Configure_Load-Based_Power_Saving_Controls


[1]5GC000431_A_7_Determine_Cell_Power_Saving_Mode
    [Setup]  Setup A7
    [1]5GC000431_A_7_Determine_Cell_Power_Saving_Mode


[1]5GC000431_A_11_Handle_cell_outage_impact_on_capacity_cell_locking
    [Setup]  Setup A11
    [1]5GC000431_A_11_Handle_cell_outage_impact_on_capacity_cell_locking


[1]5GC000431_A_13_Suspend_Load-Based_Power_Saving
    [Setup]  Setup A7
    [1]5GC000431_A_13_Suspend_Load-Based_Power_Saving

[1]5GC000431_A_15_Un-suspend_Load-Based_Power_Saving
    [Setup]  Setup A7
    [1]5GC000431_A_15_Un-suspend_Load-Based_Power_Saving

[1]5GC000431_A_20_Cell_Switch-off_Order_last_cell_switch_off_enabled
    [Setup]  Setup A7
    [1]5GC000431_A_20_Cell_Switch-off_Order_last_cell_switch_off_enabled
