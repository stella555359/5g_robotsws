*** Settings ***
Documentation    Common UE management operations
...              This resource consolidates UE management functionality used across multiple test files.

Library     ute_wtssim
Library     random
Resource    ../../resources/Common/wts_ue.robot

*** Keywords ***
Get Random UE From List
    [Documentation]    Select a random UE from a list of UE IDs
    [Arguments]    ${ue_list}

    IF    ${ue_list}
        ${ue_id}    Evaluate    random.choice($ue_list)    random
        RETURN    ${ue_id}
    END
    RETURN    ${None}

Get UE State Information
    [Documentation]    Get state and cell information for a UE
    [Arguments]    ${ue_id}

    ${ue_state}    Get UE State    ue_id=${ue_id}
    ${current_cell}    Get Current Cell Of UE    ue_id=${ue_id}

    RETURN    ${ue_state}    ${current_cell}

Categorize UEs By State
    [Documentation]    Categorize UEs into registered and unregistered lists
    [Arguments]    ${ue_data}

    ${registered_ues}     Create List
    ${unregistered_ues}   Create List

    FOR   ${ue}   IN   @{ue_data}
        IF   '${ue}[State]' in ['ACTIVE', 'IDLE']
            Append To List    ${registered_ues}       ${ue}[UE Id]
        ELSE
            Append To List    ${unregistered_ues}     ${ue}[UE Id]
        END
    END

    RETURN   ${registered_ues}    ${unregistered_ues}

Execute Random UE Registration
    [Documentation]    Register a random unregistered UE from available cells
    [Arguments]    ${cell_ids}    ${relevant_enb_id}

    ${shuffled_cell_ids}   Set Variable   ${cell_ids}
    Evaluate   random.shuffle($shuffled_cell_ids)

    FOR   ${cell_id}   IN   @{shuffled_cell_ids}
        ${ue_data}   Get Available UE Data   enb_id=${relevant_enb_id}  cell_id=${cell_id}
        ${registered_ues}   ${unregistered_ues}   Categorize UEs By State   ue_data=${ue_data}

        IF    ${unregistered_ues}
            ${ue_id}    Get Random UE From List    ${unregistered_ues}
            Run Keyword And Warn On Failure    wts_ue.UE Register   ue_id=${ue_id}
            RETURN    ${ue_id}
        END
    END
    RETURN    ${None}

Execute Random UE Deregistration
    [Documentation]    Deregister a random registered UE from available cells
    [Arguments]    ${cell_ids}    ${relevant_enb_id}

    ${shuffled_cell_ids}   Set Variable   ${cell_ids}
    Evaluate   random.shuffle($shuffled_cell_ids)

    FOR   ${cell_id}   IN   @{shuffled_cell_ids}
        ${ue_data}    Get Available UE Data   enb_id=${relevant_enb_id}  cell_id=${cell_id}
        ${registered_ues}   ${unregistered_ues}   Categorize UEs By State   ue_data=${ue_data}

        IF    ${registered_ues}
            ${ue_id}    Get Random UE From List    ${registered_ues}
            wts_ue.UE Deregister   ue_id=${ue_id}
            RETURN    ${ue_id}
        END
    END
    RETURN    ${None}


Get UE State
    [Arguments]   ${ue_id}=1

    ${ue_info}=    Send Egate Command and verify output    cmd=ue_disp id=${ue_id} type=general_info   pass_regexp=state

    ${ue_state}   Get Regexp Matches   ${ue_info}   state +[A-Z]+

    ${splitted_ue_state}    Split String   ${ue_state}[0]
    ${state}          Set Variable   ${splitted_ue_state}[1]

    Log To Console   UE State is: ${state}

    RETURN   ${state}


Get Current Cell Of UE
    [Documentation]     This keyword checks for the current global cell id of a UE
    [Arguments]   ${ue_id}=1

    ${meas_info}=    Send Egate Command and verify output    cmd=ue_disp id=${ue_id} type=cell   pass_regexp=state

    ${cell}   Get Regexp Matches   ${meas_info}   cell +\\d+
    ${enb}    Get Regexp Matches   ${meas_info}    enb +\\d+

    ${splitted_cell}   Split String   ${cell}[0]
    ${cell_id}         Set Variable   ${splitted_cell}[1]

    ${splitted_enb}    Split String   ${enb}[0]
    ${enb_id}          Set Variable   ${splitted_enb}[1]

    Log To Console    UE ${ue_id} is on enb ${enb_id} cell ${cell_id}

    RETURN   ${cell_id}
