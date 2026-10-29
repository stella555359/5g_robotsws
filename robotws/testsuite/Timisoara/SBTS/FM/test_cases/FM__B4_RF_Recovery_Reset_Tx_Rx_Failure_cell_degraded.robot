*** Settings ***
Documentation  This suite contains FM__B4_RF_Recovery_Reset_Tx_Rx_Failure_cell_degraded TC

Resource  ../test_resources/FM__B4_RF_Recovery_Reset_Tx_Rx_Failure_cell_degraded.robot


*** Test Cases ***
FM__B4_RF_Recovery_Reset_Tx_Rx_Failure_cell_degraded
    [Setup]  TC Setup
    TC__FM__B4_RF_Recovery_Reset_Tx_Rx_Failure_cell_degraded
    [Teardown]  TC Teardown
