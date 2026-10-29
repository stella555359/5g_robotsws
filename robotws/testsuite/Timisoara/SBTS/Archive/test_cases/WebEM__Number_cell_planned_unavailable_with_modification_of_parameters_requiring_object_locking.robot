*** Settings ***
Resource    ../test_resources/WebEM__Number_cell_planned_unavailable_with_modification_of_parameters_requiring_object_locking.robot

*** Test Cases ***
WebEM__Number_cell_planned_unavailable_with_modification_of_parameters_requiring_object_locking
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__WebEM__Number_cell_planned_unavailable_with_modification_of_parameters_requiring_object_locking

