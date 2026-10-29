*** Settings ***
Documentation    This Resource file contains ue specific scenarios
Library     ute_wtssim
Resource    ../../resources/Common/wts_ue.robot

*** Variables ***
${CELL_IDS}
${RELEVANT_ENB_ID}


*** Keywords ***
Preload Enb And Cell Information
    ${RELEVANT_ENB_ID}    Get Relevant ENB ID
    ${ue_data}            Get Available Ue Data
    ${CELL_IDS}           Get Possible Cell IDs     ue_data=${ue_data}    relevant_enb_id=${RELEVANT_ENB_ID}

    Set Suite Variable   ${RELEVANT_ENB_ID}
    Set Suite Variable   ${CELL_IDS}


Get Available Ue Data
    [Arguments]    ${enb_id}=${None}    ${cell_id}=${None}

    ${data}    ute_wtssim.Execute Egate Command    cmd=ue_disp
    ...                                            alias=ap_egate
    ...                                            return_output=True
    ...                                            pass_regexp=IsUEInCusMode

    ${lines}     Split To Lines    ${data}
    ${lines2}    Evaluate    [x for x in $lines if "INT" in x]
    ${heading}   Create List   UE Id  Type  State  IP addresses  NAT IP addresses  Location  MME  UEC  Group-ID  Group-name
    ${ue_data}   Create List

    FOR    ${line}   IN  @{lines2}
        ${line_data}      Split String   ${line}
        ${element}        Evaluate    {key: value for key, value in zip($heading, $line_data)}
        Append To List    ${ue_data}   ${element}
    END

    IF   $enb_id!=${None}
        ${location}   Set Variable   ${enb_id}.${cell_id}

        ${filtered_ues_list}    Create List
        FOR   ${ue}  IN  @{ue_data}
            IF    ${ue}[Location] == ${location}
                Append To List   ${filtered_ues_list}   ${ue}
            END
        END

        ${ue_data}   Set Variable   ${filtered_ues_list}

    END

    RETURN    ${ue_data}

Get Relevant ENB ID
    ${enb_data}    ute_wtssim.Execute Egate Command    cmd=enb_disp
    ...                                                alias=ap_egate
    ...                                                return_output=True
    ...                                                pass_regexp=Configured RAN UT

    ${lines}     Split To Lines    ${enb_data}
    ${enb_heading}   Create List    ID  RAN Type  RAN ID   Address     Type             Active UEs

    ${enb_lines}     Split To Lines    ${enb_data}
    ${filtered_enb_lines}    Evaluate    [x for x in $lines if "0x" in x]

    ${enbs}   Create List
    FOR    ${line}   IN  @{filtered_enb_lines}
        ${line_data}      Split String   ${line}
        ${element}        Evaluate    {key: value for key, value in zip($enb_heading, $line_data)}
        Append To List    ${enbs}   ${element}
    END

    ${external_enbs}    Evaluate   [enb for enb in $enbs if enb["Type"].lower() == "external"]

    Length Should Be    ${external_enbs}   1

    ${enb_id}    Set Variable   ${external_enbs}[0][ID]

    RETURN   ${enb_id}

Get Possible Cell IDs
    [Arguments]    ${ue_data}    ${relevant_enb_id}

    ${locations}      Evaluate    list(set([ue["Location"] for ue in $ue_data]))
    ${cells}          Create List

    FOR   ${location}   IN   @{locations}
        ${enb_id}   ${cell}    Split String   ${location}   separator=.
        IF   ${enb_id} == ${relevant_enb_id}   Append To List    ${cells}    ${cell}
    END

    RETURN   ${cells}

Get Registered And Unregistered UE Ids
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


Execute Random UE Register
    ${shuffled_cell_ids}   Set Variable   ${CELL_IDS}
    Evaluate   random.shuffle($shuffled_cell_ids)

    FOR   ${cell_id}   IN   @{shuffled_cell_ids}
        ${ue_data}   Get Available Ue Data   enb_id=${RELEVANT_ENB_ID}  cell_id=${cell_id}
        ${registered_ues}   ${unregistered_ues}   Get Registered And Unregistered UE Ids   ue_data=${ue_data}

        IF    ${unregistered_ues}
            ${ue_id}     Evaluate   random.choice($unregistered_ues)
            Run Keyword And Warn On Failure    wts_ue.UE Register   ue_id=${ue_id}
            BREAK
        END
    END


Execute Random UE Deregister
    ${shuffled_cell_ids}   Set Variable   ${CELL_IDS}
    Evaluate   random.shuffle($shuffled_cell_ids)

    FOR   ${cell_id}   IN   @{shuffled_cell_ids}
        ${ue_data}    Get Available Ue Data   enb_id=${RELEVANT_ENB_ID}  cell_id=${cell_id}
        ${registered_ues}   ${unregistered_ues}   Get Registered And Unregistered UE Ids   ue_data=${ue_data}

        IF    ${registered_ues}
            ${ue_id}     Evaluate   random.choice($registered_ues)
            wts_ue.UE Deregister   ue_id=${ue_id}
            BREAK
        END
    END


