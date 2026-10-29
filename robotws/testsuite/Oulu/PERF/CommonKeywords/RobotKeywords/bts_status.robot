*** Settings ***
Resource            taf/rfrl/bts/robot/common/gnb_bbu.robot

*** Keywords ***
Check Bts Status
    [Documentation]    Verify Bts status
    Log To Console    [robot] Verify BTS status
    Verify Procedural And Blocking State    procedural_states=OnAir
    Verify DU Availability
