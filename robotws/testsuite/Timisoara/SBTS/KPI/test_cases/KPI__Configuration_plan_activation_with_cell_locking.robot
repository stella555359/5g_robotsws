*** Settings ***
Documentation  This suite contains KPI__Configuration_plan_activation_with_cell_locking TC

Resource  ../test_resources/KPI__Configuration_plan_activation_with_cell_locking.robot


*** Test Cases ***
KPI__Configuration_plan_activation_with_cell_locking
    [Setup]  TC Setup
    TC__KPI__Configuration_plan_activation_with_cell_locking
    [Teardown]  TC Teardown
