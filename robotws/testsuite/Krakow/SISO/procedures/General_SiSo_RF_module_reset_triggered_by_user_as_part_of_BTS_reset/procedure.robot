*** Settings ***

Resource    taf/rfrl/bts/robot/gnb.robot
Resource    taf/rfrl/procedures/resources/robot/utilities.robot

*** Keywords ***
General SiSo Module Reset Triggered By User
    [Arguments]    ${gnb_ip}    ${timeout}
    Reset gNB    wait_for_reconnection=False
    Verify gNB Does Not Respond   bts_ip=${gnb_ip}
    Verify gNB Responds    bts_ip=${gnb_ip}   timeout=${timeout}
    Wait Until Keyword Succeeds     8 min     30 sec   Verify gNB is onAir
    Get and Save DHCP Configuration
    Verify Connection to All Radio Units   ${dhcp_dict}
