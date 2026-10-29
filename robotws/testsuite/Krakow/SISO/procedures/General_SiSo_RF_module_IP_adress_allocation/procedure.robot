*** Settings ***

Resource    taf/rfrl/bts/robot/gnb.robot

*** Keywords ***
General SiSo RF module IP adress allocation
    ${dhcp_dict} =      Get DHCP Config For All Radio Units
    Verify Connection to All Radio Units   dhcp_dict=${dhcp_dict}
