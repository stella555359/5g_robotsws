*** Settings ***
Documentation  This suite contains FM__vDU__B5_Tx_Rx_Failure_detection_after_RF_recovery_reset TC

Resource  ../test_resources/FM__vDU__B5_Tx_Rx_Failure_detection_after_RF_recovery_reset.robot

*** Test Cases ***
FM__vDU__B5_Tx_Rx_Failure_detection_after_RF_recovery_reset
    [Setup]  TC Setup
    TC__FM__vDU__B5_Tx_Rx_Failure_detection_after_RF_recovery_reset
    [Teardown]  TC Teardown
