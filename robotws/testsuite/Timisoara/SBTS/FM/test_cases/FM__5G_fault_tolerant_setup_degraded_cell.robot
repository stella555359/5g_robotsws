*** Settings ***
Documentation  This suite contains FM__5G_fault_tolerant_setup_degraded_cell TC

Resource  ../test_resources/FM__5G_fault_tolerant_setup_degraded_cell.robot


*** Test Cases ***
TC__FM__5G_fault_tolerant_setup_degraded_cell
    [Setup]  TC Setup
    FM__5G_fault_tolerant_setup_degraded_cell
    [Teardown]  TC Teardown
