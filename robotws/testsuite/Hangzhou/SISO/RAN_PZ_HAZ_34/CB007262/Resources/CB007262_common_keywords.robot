*** Settings ***
Documentation
...    author: Shufei Chen
...    contact: shufei.chen@nokia-sbell.com
...    squad group: SG_08
...    feature : CB007262

Resource    ../../AZQR_SG08/Resources/CB006487_keyword.robot



*** Variables ***


*** Keywords ***
CB007262-5G-B-A1_004_General_SiSo_BB_sub-unit_lock_and_unlock_with_L3_call
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of this test case is to verify correctness of BB sub-unit (ABIL) lock/unlock
    ...    procedure, triggered by an operator in WebEM. Verification with L3 call
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 19.8.2021 - - Created
    ...    *******************
    ...    Owner_shufei.chen@nokia-sbell.com
    [Arguments]  ${connection}=GNB_OAM    ${with_peak}=${False}
    Selenium Login And Disable Screen Lock
    log to console    *****lock the BBMod*****
    selenium_coam.lock_abil
    log to console    *****Check BBMod Locked Status*****
    Wait Until Keyword Succeeds    2min    2s    Check BBMod Locked Status
    ${ru_index_list}    Get Rus Of Abil
    FOR  ${ru_index}  IN  @{ru_index_list}
        Wait Until Keyword Succeeds    2min    2s    RU Should Be Unlocked    ru_index=${ru_index}
    END
    ${cell_list_all}    Get Cells Of Abil
    FOR  ${cell_id}  IN  @{cell_list_all}
        ${cell_info}    coam.get_subcells_status   timeout=20    connection=${connection}
        ${cell_group_idx}    get_group_id    cell_info=${cell_info}    idx=${cell_id}
        Wait Until Keyword Succeeds    5 min    3 sec    Cell Should Be Disabled  cell_idx=${cell_id}
        ...    cell_group_idx=${cell_group_idx}
    END
    log to console    *****unlock the BBMod*****
    selenium_coam.unlock_abil
    log to console    *****Check BBMod unLocked Status*****
    Wait Until Keyword Succeeds    2min    2s    Check BBMod Unlocked Status
    FOR  ${ru_index}  IN  @{ru_index_list}
        Wait Until Keyword Succeeds    2min    2s    RU Should Be Unlocked    ru_index=${ru_index}
    END
    FOR  ${cell_id}  IN  @{cell_list_all}
        ${cell_info}    coam.get_subcells_status   timeout=20    connection=${connection}
        ${cell_group_idx}    get_group_id    cell_info=${cell_info}    idx=${cell_id}
        Wait Until Keyword Succeeds    5 min    3 sec    Cell Should Be Unlocked  cell_idx=${cell_id}
        ...    cell_group_idx=${cell_group_idx}
    END
    ${cell_list}    create list    ${1}
    Get UE From Init File and Make call    cell_list=${cell_list}  with_peak=${with_peak}  ue_num_each_call=1


Check BBMod Locked Status
    [Arguments]  ${connection}=GNB_OAM
    ${abio_locked_info}    selenium_coam.get_abil_info
    ${abio_locked_info}    set variable    ${abio_locked_info}[Status]
    ${result}    get release flag    connection=${connection}
    ${Locked}    Set Variable If    ${result}    Locked    Locked
    ${enabled}    Set Variable If    ${result}    Enabled    enabled
    ${configured}    Set Variable If    ${result}    configured    configured
    should be equal    ${abio_locked_info}[Operational state]    ${enabled}
    should be equal    ${abio_locked_info}[Procedural status]    ${configured}
    should be equal    ${abio_locked_info}[Administrative state]    ${Locked}
    run keyword if  ${result}    Run keyword and continue on failure    Should be equal as strings
                                      ...  ${abio_locked_info}[Availability status]    Online
                                      ...  msg=Current ABIO availabilityStatus is not in Online status

Check BBMod Unlocked Status
    [Arguments]  ${connection}=GNB_OAM
    ${abio_locked_info}    selenium_coam.get_abil_info
    ${abio_locked_info}    set variable    ${abio_locked_info}[Status]
    ${result}    get release flag    connection=${connection}
    ${unlocked}    Set Variable If    ${result}    Unlocked    Unlocked
    ${enabled}    Set Variable If    ${result}    Enabled    enabled
    ${configured}    Set Variable If    ${result}    configured    configured
    should be equal    ${abio_locked_info}[Operational state]    ${enabled}
    should be equal    ${abio_locked_info}[Procedural status]    ${configured}
    should be equal    ${abio_locked_info}[Administrative state]    ${unlocked}
    run keyword if  ${result}    Run keyword and continue on failure    Should be equal as strings
                                      ...  ${abio_locked_info}[Availability status]    Online
                                      ...  msg=Current ABIO availabilityStatus is not in Online status

