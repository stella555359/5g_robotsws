*** Settings ***

Resource    taf/rfrl/bts/robot/gnb.robot


*** Keywords ***
eCPRI RP1 Supervision fauilure
    Provoke RU Supervision Failure
    Wait Until Keyword Succeeds    3 minutes    10 seconds    Verify All Radio Module Status    bts_state=unavailable
    Restore RU Supervision
    Wait Until Keyword Succeeds    3 minutes    10 seconds    Verify Restart Occured On All RU    time=300
    Wait Until Keyword Succeeds    255 seconds    10 seconds    Verify Setup Of All Cells
