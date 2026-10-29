*** Settings ***
Documentation  This suite contains FM__B3_Tx_Rx_Failure_after_RF_recovery_reset TC

Resource  ../test_resources/FM__B3_Tx_Rx_Failure_after_RF_recovery_reset.robot


*** Test Cases ***
FM__B3_Tx_Rx_Failure_after_RF_recovery_reset
    [Setup]  TC Setup
    TC__FM__B3_Tx_Rx_Failure_after_RF_recovery_reset
    [Teardown]  TC Teardown
