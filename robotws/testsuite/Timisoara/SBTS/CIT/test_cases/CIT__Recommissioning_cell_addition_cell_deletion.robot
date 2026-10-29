*** Settings ***
Documentation  This suite contains CIT__Recommissioning_cell_addition_cell_deletion TC

Resource  ../test_resources/CIT__Recommissioning_cell_addition_cell_deletion.robot


*** Test Cases ***
CIT__Recommissioning_cell_addition_cell_deletion
    [Setup]  TC Setup
    TC__CIT__Recommissioning_cell_addition_cell_deletion
    [Teardown]  TC Teardown
