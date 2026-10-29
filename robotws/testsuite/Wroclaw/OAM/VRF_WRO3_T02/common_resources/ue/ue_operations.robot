*** Settings ***
Documentation    Keywords regarding ue setup and operations.
...              Author:     Tomasz Stawowczyk
...              Contact:    tomasz.stawowczyk@nokia.com

Library          ute_ue

*** Keywords ***
Attach Ue And Check The Connection
    [Arguments]    ${ue_alias}=lte_ue    ${capabilities}=REAL_UE    ${check_cell}=True    ${expected_cell}=${none}
    Require Ue    ue_alias=${ue_alias}    capabilities=${capabilities}
    Attach Ue    lte_ue
    ${current_ue_cell}  Get Ue Info  ${ue_alias}  cell_id
    Run Keyword If    ${check_cell}    Should Match    ${current_ue_cell}    ${expected_cell}
    ...    msg=UE attached to another cell than expected!
    ${ue_ip}  Wait Until Keyword Succeeds  3x  10s  Get UE Info  ${ue_alias}  ip
    Should Match Regexp    ${ue_ip}    \\d+\\.\\d+\\.\\d+\\.\\d+
