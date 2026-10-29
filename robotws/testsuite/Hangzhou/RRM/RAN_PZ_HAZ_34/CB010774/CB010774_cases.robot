*** Settings ***
Documentation    Author: jun.8.chen@nokia-sbell.com
Suite Setup    10774_Suite_SetUp
Suite Teardown    10774_Suite_Teardown
Test Teardown    10774_Case_Teardown
Force Tags    PY36
Resource     Resources/CB010774_case_steps.robot
Variables    Resources/TestCaseVariables.py


*** Test Cases ***
[1]CB010774_B_B7_paging_broadcast_for_Idle_state_Ues_for_cell_with_5GC001116_0ms
    [Setup]    10774_Case_SetUp    framestructure=11160ms
    CB010774_B_B7_paging_broadcast_for_Idle_state_Ues_for_cell_with_5GC001116_0ms

[1]CB010774_B_B6_paging_broadcast_for_Idle_state_Ues_for_cell_with_CB012269_CB008406
    [Setup]    10774_Case_SetUp_8406
    CB010774_B_B6_paging_broadcast_for_Idle_state_Ues_for_cell_with_CB012269_CB008406

[1]CB010774_B_B5_paging_broadcast_for_Idle_state_Ues_for_cell_with_CB012269_5GC001070_BBPooling_Enabled
    [Setup]    10774_Case_SetUp_1070
    CB010774_B_B5_paging_broadcast_for_Idle_state_Ues_for_cell_with_CB012269_5GC001070_BBPooling_Enabled

[1]CB010774_B_B4_paging_broadcast_for_Idle_state_Ues_for_cell_with_CB012269_5GC001208
    [Setup]    10774_Case_SetUp_1208
    CB010774_B_B4_paging_broadcast_for_Idle_state_Ues_for_cell_with_CB012269_5GC001208
