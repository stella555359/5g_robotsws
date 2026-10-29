*** Settings ***
Documentation  This suite contains FM__B5_Tx_Rx_Failure_detection_after_RF_recovery_reset_fault_appears_again_runtime TC

Resource  ../test_resources/FM__B5_Tx_Rx_Failure_detection_after_RF_recovery_reset_fault_appears_again_runtime.robot


*** Test Cases ***
FM__B5_Tx_Rx_Failure_detection_after_RF_recovery_reset_fault_appears_again_runtime
    [Setup]  TC Setup
    TC__FM__B5_Tx_Rx_Failure_detection_after_RF_recovery_reset_fault_appears_again_runtime
    [Teardown]  TC Teardown
