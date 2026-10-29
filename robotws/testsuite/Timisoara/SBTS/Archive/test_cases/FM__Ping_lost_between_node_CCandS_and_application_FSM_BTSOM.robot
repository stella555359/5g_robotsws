*** Settings ***
Documentation  This suite contains FM__Ping_lost_between_node_CCandS_and_application_FSM_BTSOM TC

Resource  ../test_resources/FM__Ping_lost_between_node_CCandS_and_application_FSM_BTSOM.robot


*** Test Cases ***
FM__Ping_lost_between_node_CCandS_and_application_FSM_BTSOM
    [Setup]  TC Setup
    TC__FM__Ping_lost_between_node_CCandS_and_application_FSM_BTSOM
    [Teardown]  TC Teardown
