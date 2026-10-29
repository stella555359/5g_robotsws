*** Settings ***
Documentation  This suite contains FM__Ping_lost_between_node_CCandS_and_application_FSM_RROM TC

Resource  ../test_resources/FM__Ping_lost_between_node_CCandS_and_application_FSM_RROM.robot


*** Test Cases ***
FM__Ping_lost_between_node_CCandS_and_application_FSM_RROM
    [Setup]  TC Setup
    TC__FM__Ping_lost_between_node_CCandS_and_application_FSM_RROM
    [Teardown]  TC Teardown
