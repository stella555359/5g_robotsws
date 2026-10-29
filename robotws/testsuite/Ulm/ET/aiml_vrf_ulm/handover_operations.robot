*** Settings ***
Documentation      This robot resource keeps all keywords related to performing Handovers.
...                Currently only intra-gnb handovers are supported.

Resource    ../../resources/Common/wts_ue.robot
Resource    common_ue_operations.robot

*** Keywords ***
Perform Random UE Handovers
    [Arguments]   ${amount}
    FOR   ${_}   IN RANGE    ${amount}
        ${current_ue}   Evaluate    random.choice($AVAILABLE_UE_IDS)    random

        ${ue_state}    Get UE State   ue_id=${current_ue}

        IF   '${ue_state}' != 'ACTIVE'
            Log To Console     UE ${current_ue} is in state ${ue_state} - Registering

            wts_ue.UE Register            ue_id=${current_ue}
            wts_ue.UE PDU Session Setup   ue_id=${current_ue}   gw=${current_ue}
        END

        TRY
            ${new_cell}   Perform Handover For UE   ${current_ue}
            Log To Console     UE ${current_ue} is now at cell ${new_cell}
        EXCEPT
            Log To Console    Unable to perform handover for UE ${current_ue}
        END

        ${delay}   Evaluate   random.randint(10, 50) / 10    random
        Log To Console    Sleep ${delay}s
        Sleep    ${delay}s
    END

Check If A3 And A5 Measurements Are Present
    [Documentation]    This keyword checks if measurements for A3 and A5 events can be sent.
    ...                A3 events are triggered when neighbor becomes offset better than PCell/PSCell.
    ...                A5 events are triggered when PCell/PSCell becomes worse than threshold1 and
    ...                neighbor becomes better than threshold2.
    [Arguments]     ${ue_id}=1

    ${meas_info}=   Send Egate Command and verify output    cmd=ue_meas_cfg_disp id=${ue_id}  pass_regexp=NR MEASUREMENT IDENTITIES:
    ${a3_present}=  Run Keyword and Return Status  Should Match Regexp  ${meas_info}  EventA3
    ${a5_present}=  Run Keyword and Return Status  Should Match Regexp  ${meas_info}  EventA5

    Log To Console   UE ${ue_id} has A3 present: ${a3_present} and A5 present: ${a5_present}

    RETURN   ${a3_present} and ${a5_present}


Send Measurement For Handover
    [Arguments]    ${ue_id}=1    ${phycell_id}=50

    TRY
        Log To Console    Send Measurement: Trying meas_id=1
        Send Egate Command and verify output    cmd=ue_disp id=${ue_id} type=cell   pass_regexp=Configured UEs
        ...   cmd=ue_measurement_send_nr id=${ue_id} meas_id=1 event=A3 srsrp_nr=19 phycell_id=${phycell_id} nrsrp_nr=100
        ...   pass_regexp=criticalExtensions rrcReconfigurationComplete
    EXCEPT
        Log To Console    Send Measurement: Trying meas_id=2
        Send Egate Command and verify output    cmd=ue_disp id=${ue_id} type=cell   pass_regexp=Configured UEs
        ...   cmd=ue_measurement_send_nr id=${ue_id} meas_id=2 event=A3 srsrp_nr=19 phycell_id=${phycell_id} nrsrp_nr=100
        ...   pass_regexp=criticalExtensions rrcReconfigurationComplete
    END


Perform Handover For UE
    [Documentation]   Perform a handover procedure for a specific UE
    ...
    ...    Example Egate flow:
    ...
    ...    ue_register id=1 nwslice=1
    ...    ue_pdu_session_setup pdu=1 ue=1 nwslice=1 gw=1
    ...    ue_meas_cfg_disp id=1 #--> es sollte ein A3 Measurement konfiguriert sein
    ...    ue_measurement_send_nr id=1 meas_id=1 event=A3 srsrp_nr=19 phycell_id=51 nrsrp_nr=100
    ...
    [Arguments]   ${ue_id}=1

    ${handover_possible}    Check If A3 And A5 Measurements Are Present    ue_id=${ue_id}

    IF    not ${handover_possible}
        Log    No Handover possible for ue ${ue_id} - missing measurements!
        RETURN
    END
    ${current_cell}         common_ue_operations.Get Current Cell Of UE   ue_id=${ue_id}
    ${source_cell}          Set Variable    ${current_cell}

    ${handover_cell_candidates}   Get Cell Candidates   cell_id=${current_cell}

    # pick a random of the handover cell candidates
    ${target_cell}   Evaluate    random.choice($handover_cell_candidates)    random

    Send Measurement For Handover   ue_id=${ue_id}   phycell_id=${GCID_TO_PCID}[${target_cell}]
    ${current_cell}         Get Current Cell Of UE   ue_id=${ue_id}
    Should Be Equal As Integers    ${current_cell}   ${target_cell}     msg=Handover was not succesful!

    Log To Console    Succesful Handover for ue ${ue_id} from cell ${source_cell} to ${current_cell}

    RETURN    ${target_cell}


Get Cell Candidates
    [Documentation]    This keyword returns a list of candidate cells for handover, matching the technology of the source cell.
    ...                It filters cells by technology and excludes the current cell. Used for intra-gnb handover scenarios.
    [Arguments]   ${cell_id}

    ${cell_id}             Convert To Integer     ${cell_id}
    ${cell_technology}     Get From Dictionary    ${TECHNOLOGY}   ${cell_id}
    ${cell_candidates}     Create List

    FOR   ${other_cell}   ${other_cell_technology}   IN   &{TECHNOLOGY}
        IF   $other_cell != $cell_id and $other_cell_technology == $cell_technology
            Append To List     ${cell_candidates}   ${other_cell}
        END
    END

    RETURN   ${cell_candidates}
