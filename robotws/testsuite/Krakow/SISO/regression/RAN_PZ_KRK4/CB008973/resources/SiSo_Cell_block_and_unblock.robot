*** Settings ***

Resource    taf/rfrl/bts/robot/gnb.robot


*** Keywords ***
General SiSo Cell block and unblock
    Block Unblock All Cells For Each Group
    Block All Cells And Then Unblock One By One
    Verify All Cells Are Unblocked
    Wait Until Keyword Succeeds    2 minute    10 seconds    gnbcell.verify_all_cells_are_onair
    sleep    180s   Wait 3 minutes to werify if cells are still in online state
