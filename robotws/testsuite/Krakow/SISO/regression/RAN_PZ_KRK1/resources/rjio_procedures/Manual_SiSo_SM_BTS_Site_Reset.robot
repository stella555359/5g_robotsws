*** Settings ***
Documentation
...   Test CB012524 - Manual_SiSo_SM_BTS_Site_Reset
...   author: Agnieszka Bylica
...   author/contact: agnieszka.bylica@nokia.com


*** Keywords ***
Manual_SiSo_SM_BTS_Site_Reset
    [Arguments]    ${iterations}=${1}
    Prepare Ue
    Run L3 call on all cells one by one and verify tput    sheetname_in_tput_table=Tput before Site Reset
    FOR  ${iter}    IN RANGE    1    ${iterations} + 1
        gnbbbu.reset_bts
        Wait Until Keyword Succeeds     900 sec     30 sec    gnbcell.Verify All Cells are onAir
        Run L3 call on all cells one by one and verify tput    sheetname_in_tput_table=Iteration ${iter}
    END
