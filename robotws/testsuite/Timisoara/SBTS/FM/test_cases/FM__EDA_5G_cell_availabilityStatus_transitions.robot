*** Settings ***
Documentation  This suite contains FM__EDA_5G_cell_availabilityStatus_transitions TC

Resource  ../test_resources/FM__EDA_5G_cell_availabilityStatus_transitions.robot


*** Test Cases ***
FM__EDA_5G_cell_availabilityStatus_transitions
    [Setup]  TC Setup
    TC__FM__EDA_5G_cell_availabilityStatus_transitions
    [Teardown]  TC Teardown
