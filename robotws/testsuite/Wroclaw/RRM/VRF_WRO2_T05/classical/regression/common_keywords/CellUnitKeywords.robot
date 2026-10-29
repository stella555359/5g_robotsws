*** Settings ***
Documentation    Suite description
...    Author: Przemyslaw Dabrowski
...    Contact: przemyslaw.dabrowski@nokia.com
...    Keywords used for actions on Cell

Library     taf.sbts.oam.coam.admin    WITH NAME    admin_cli
Library     taf.transport.ssh    WITH NAME    ssh
Resource    admin/BasicKeywords.robot

*** Keywords ***
Cell Lock
    [Arguments]    ${cell_nr}
    ${num}    Set correct SMOD position in Subrack
    ${object}    Catenate    SEPARATOR=     /MRBTS-1/RAT-1/RUNTIME_VIEW-${num}/MRBTS_R-${num}/
    ...    NRBTS_R-${tl.gnbs[0].global_bts_id}/NRCELL_R-${cell_nr}
    admin_cli.lock_cell    dist_name=${object}    timeout=60

Cell Unlock
    [Arguments]    ${cell_nr}
    ${num}    Set correct SMOD position in Subrack
    ${object}    Catenate    SEPARATOR=     /MRBTS-1/RAT-1/RUNTIME_VIEW-${num}/MRBTS_R-${num}/
    ...    NRBTS_R-${tl.gnbs[0].global_bts_id}/NRCELL_R-${cell_nr}
    admin_cli.unlock_cell    dist_name=${object}    timeout=60

Set correct SMOD position in Subrack
    ${leftdict}=    set variable    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1
    ${rightdict}=    set variable    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/APEQM_R-1/CABINET_R-1/SMOD_R-1
    ${status}    ${smodparamsdict}    run keyword and ignore error    admin_cli.get_parameters    dist_name=${leftdict}
    ${smodparamsdict}     run keyword if    '${status}'=='FAIL'    admin_cli.get_parameters    dist_name=${rightdict}
    ...     ELSE    admin_cli.get_parameters    dist_name=${leftdict}
    ${positionInSubrackparam}=    Get from Dictionary    ${smodparamsdict}    horizontalPosition
    ${positionInSubrack}=    set variable if
    ...    '1' == '${positionInSubrackparam}'    1
    ...    '2' == '${positionInSubrackparam}'    4
    [Return]    ${positionInSubrack}
