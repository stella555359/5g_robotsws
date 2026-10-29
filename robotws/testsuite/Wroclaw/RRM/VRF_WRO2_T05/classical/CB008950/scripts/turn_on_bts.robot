*** Settings ***
Documentation   Test scrip that can be used to turn on BTS with 2 DUs


Resource      taf/rfrl/bts/robot/gnb.robot


*** Test Cases ***
Turn on BTS
    Log to console    ${tl}
    Power Reset gNB    gnb_id=0    du_id=0
    Power Reset gNB    gnb_id=1    du_id=0
    All Radio Units Power On on gNB    gnb_id=0    du_id=0
    All Radio Units Power On on gNB    gnb_id=1    du_id=0
