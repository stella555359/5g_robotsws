*** Settings ***

Resource    taf/rfrl/ue/robot/REAL_UE.robot

*** Keywords ***
L3 Call
    Require Ue for L3 Call
    ue.Attach Ue     UE
    Wait Until Keyword Succeeds     20 sec     5 sec    ue.Validate Ue Info   UE   5G_STATE    5G_NSA
    ue.Detach UE     UE
