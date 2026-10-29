*** Settings ***

Resource    taf/rfrl/bts/robot/gnb.robot


*** Keywords ***
General SiSo BTS reset with RF power reset
    Reset gNB via GUI
    Power Reset All gNB Radio Units
    Wait Until Keyword Succeeds     600 sec     5 sec   Verify All Radio Module Status
    Wait Until Keyword Succeeds     600 sec     5 sec   Verify Setup Of All Cells
    Wait Until Keyword Succeeds     900 sec     5 sec   Verify gNB is onAir
