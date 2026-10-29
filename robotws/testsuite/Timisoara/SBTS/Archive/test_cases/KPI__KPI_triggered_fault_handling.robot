*** Settings ***
Documentation  This suite contains KPI__KPI_triggered_fault_handling TC

Resource  ../test_resources/KPI__KPI_triggered_fault_handling.robot


*** Test Cases ***
KPI__KPI_triggered_fault_handling
    [Setup]  TC Setup
    TC__KPI__KPI_triggered_fault_handling
    [Teardown]  TC Teardown
