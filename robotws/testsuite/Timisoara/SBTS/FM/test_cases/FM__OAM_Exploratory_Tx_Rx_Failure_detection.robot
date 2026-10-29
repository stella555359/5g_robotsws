*** Settings ***
Documentation  This suite contains FM__OAM_Exploratory_Tx_Rx_Failure_detection TC

Resource  ../test_resources/FM__OAM_Exploratory_Tx_Rx_Failure_detection.robot


*** Test Cases ***
FM__OAM_Exploratory_Tx_Rx_Failure_detection
    [Setup]  TC Setup
    TC__FM__OAM_Exploratory_Tx_Rx_Failure_detection
    [Teardown]  TC Teardown

