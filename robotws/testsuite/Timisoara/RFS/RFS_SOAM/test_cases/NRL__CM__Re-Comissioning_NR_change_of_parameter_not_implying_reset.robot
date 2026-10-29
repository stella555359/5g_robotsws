*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/NRL__CM__Re-Comissioning_NR_change_of_parameter_not_implying_reset.robot

*** Test Cases ***
[1]NRL__CM__Re-Comissioning_NR_change_of_parameter_not_implying_reset
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__NRL__CM__Re-Comissioning_NR_change_of_parameter_not_implying_reset

