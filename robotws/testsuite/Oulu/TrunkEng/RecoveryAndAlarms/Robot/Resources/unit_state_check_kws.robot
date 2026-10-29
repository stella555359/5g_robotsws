*** Settings ***
Documentation
...   Author:   Terhi Talvitie
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Library     Collections

*** Variables ***
# for cells
&{cell_enabled}    operationalState=enabled
&{cell_disabled}   operationalState=disabled
# for radios:
&{rmod_enabled}    administrativeState=Unlocked  operationalState=enabled
&{rmod_disabled}   administrativeState=Unlocked  operationalState=disabled
# for bbmods
&{bbmod_disabled}  availabilityStatus=failed   operationalState=disabled
&{bbmod_enabled}   operationalState=enabled

*** Keywords ***
Check if affected cells disabled
    [Documentation]  This KW checks that affected cells are disabled and other cells enabled.
    ...              Give list of cells that are expected to be disabled as argument.
    [Arguments]    ${FAULTY_CELL_LIST}
    Print Text To Eventlog   Check cell states
    &{cell_state_dict}    Create Dictionary
    FOR    ${faulty}    IN    @{FAULTY_CELL_LIST}
        Set To Dictionary  ${cell_state_dict}  ${faulty}  ${cell_disabled}
    END
    Print Text To Eventlog   ${cell_state_dict}
    Run Keyword And Continue On Failure    Check Cell States  ${cell_state_dict}  states_of_other_cells=${cell_enabled}
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}

Check if affected radios disabled
    [Documentation]  This KW checks that affected radios are disabled and other radios enabled.
    ...              Give list of radios that are expected to be disabled as argument.
    [Arguments]    ${radios}
    Print Text To Eventlog   Check radio states
    &{state_dict}    Create Dictionary
    FOR    ${faulty_r}    IN    @{radios}
        Set To Dictionary    ${state_dict}    ${faulty_r}    ${rmod_disabled}
    END
    Print Text To Eventlog   ${state_dict}
    Run Keyword And Continue On Failure    Check Radio States  ${state_dict}  states_of_other_rmods=${rmod_enabled}
    ...                                    print_ok_states=${True}
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}

Check if affected bbmods disabled
    [Documentation]  This KW checks that affected BBMODs are failed and disabled and other BBMODs enabled.
    ...              Give list of BBMODs that are expected to be failed and disabled as argument.
    [Arguments]    ${bbmods}
    Print Text To Eventlog   Check bbmod states
    ${bbmod_state}=  Check Build And Change Bbmod State  ${bbmod_disabled}
    &{state_dict}    Create Dictionary
    FOR    ${faulty_b}    IN    @{bbmods}
        Set To Dictionary    ${state_dict}    ${faulty_b}    ${bbmod_state}
    END
    Print Text To Eventlog   ${state_dict}
    Run Keyword And Continue On Failure    Check Bbmod States  ${state_dict}  states_of_other_bbmods=${bbmod_enabled}
    ...                                    print_ok_states=${True}
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}
