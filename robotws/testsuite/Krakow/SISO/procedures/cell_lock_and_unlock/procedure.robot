*** Settings ***

Resource    ./keywords.robot


*** Keywords ***
Cell lock and unlock
    Modify timeout for X2 link drop    new_value=0
    Lock Unlock All Cells For Each Group
    Lock All Cells And Then Unlock For Each Group
    Lock All Cell Groups And Then Unlock
    Verify All Cells Are Unlocked
    Wait Until Keyword Succeeds    8 minute    10 seconds    Verify Setup Of All Cells
    Wait For Site To Be Onair
    sleep    180s   Wait 3 minutes to werify if cells are still in online state
    Modify timeout for X2 link drop    new_value=30
