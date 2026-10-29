*** Settings ***
Resource    ../test_resources/FM__Ping_lost_between_node_CCS_and_application_FSM_LOMexe.robot

*** Test Cases ***
FM__Ping_lost_between_node_CCS_and_application_FSM_LOMexe
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__FM__Ping_lost_between_node_CCS_and_application_FSM_LOMexe
