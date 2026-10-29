*** Settings ***
Documentation  This suite contains FM__A2_Cell_Setup_with_Failed_Tx_Rx_in_Degraded_State TC

Resource  ../test_resources/FM__A2_Cell_Setup_with_Failed_Tx_Rx_in_Degraded_State.robot


*** Test Cases ***
FM__A2_Cell_Setup_with_Failed_Tx_Rx_in_Degraded_State
    [Setup]  TC Setup
    TC__FM__A2_Cell_Setup_with_Failed_Tx_Rx_in_Degraded_State
    [Teardown]  TC Teardown
