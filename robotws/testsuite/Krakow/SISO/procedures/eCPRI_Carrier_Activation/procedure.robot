*** Settings ***

Resource    taf/rfrl/bts/robot/gnb.robot

*** Keywords ***
eCPRI Carrier Activation
    [Arguments]    ${rx_tx_parameters}    ${parameters}
    Verify Configuration Parameter in gNB Soap Logs   rx_tx_parameters=${rx_tx_parameters}   parameters=${parameters}
