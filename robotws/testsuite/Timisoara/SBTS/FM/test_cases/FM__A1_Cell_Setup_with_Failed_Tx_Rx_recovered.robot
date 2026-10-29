*** Settings ***
Documentation  This suite contains FM__A1_Cell_Setup_with_Failed_Tx_Rx_recovered TC

Resource  ../test_resources/FM__A1_Cell_Setup_with_Failed_Tx_Rx_recovered.robot


*** Test Cases ***
FM__A1_Cell_Setup_with_Failed_Tx_Rx_recovered
    [Setup]  TC Setup
    TC__FM__A1_Cell_Setup_with_Failed_Tx_Rx_recovered
    [Teardown]  TC Teardown
