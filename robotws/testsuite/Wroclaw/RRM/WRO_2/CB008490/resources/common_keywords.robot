*** Settings ***
Documentation
...   author: Piotr Brzezicki
...   contact: Dawid Rusek
...   maintainer: dawid.rusek@nokia.com

Library    DateTime                                                     WITH NAME    dt
Library    taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations    WITH NAME    cells

*** Keywords ***
Log Action To Console
    [Arguments]   ${msg}       ${new_line_before}=${True}    ${new_line_after}=${False}
    [Documentation]    Logs message to console
    ...                :param msg:     message logged
    ...                :new_line_before:    determines if include new line before log
    ...                :new_line_after:    determines if include new line after log

    Run keyword if    '${new_line_before}'=='${True}'   Log To Console    \n    no_newline=${True}
    ${date}=       dt.Get Current Date    exclude_millis=yes
    Log To Console    [${date}] ${msg}    no_newline=${True}
    Run keyword if    '${new_line_after}'=='${True}'   Log To Console    \n    no_newline=${True}

Wait For All Cells To Be OnAir
    [Arguments]   ${bts_id}=0
    [Documentation]     KW waits until All BTS cells achieve onAir state
    ...                 :param bts_id: ID of BTS from testline configuration __init__ file, default 0

    Log Action To Console    Wait For All Cells To Be OnAir
    cells.Wait For All Cells Statuses    bts_id=${bts_id}
    ...                                  availability_status=online
    ...                                  operational_state=enabled
    ...                                  administrative_state=Unlocked
    ...                                  blocking_state=Unblocked
    ...                                  procedural_status=configured
    ...                                  usage_state=Active
    ...                                  barring_status=unbarred
    ...                                  timeout=600
