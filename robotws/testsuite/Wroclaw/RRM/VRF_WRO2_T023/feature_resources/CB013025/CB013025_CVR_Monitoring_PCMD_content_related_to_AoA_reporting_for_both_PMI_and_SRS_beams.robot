*** Settings ***
Documentation    Keywords for the CB013025_CVR test case

Library      ute_wtssim
Library      ta5g_tshark
Library      ta5g_throughput
Library      ta5g_egate
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T023/resources/airphone/L3_call.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T023/feature_resources/CB013025/resources/CB013025_keywords.robot


*** Variables ***
${CELL_ID}           # ID of tested NR cell in mMIMO RU (AQQJ) with configured beamforming
${UE_ID}             # ID of tested UE from EGATE configuration file connected to NR cell with cell tracing
${RANK_INDICATOR}    # Rank indicator for the  number of transmission layers configured on UE during test

*** Keywords ***
TC__CB013025_CVR_Monitoring_PCMD_content_related_to_AoA_reporting_for_both_PMI_and_SRS_beams
    Step 1: Configure Number Of Transmission Layers For UE

    Step 2: Attach Ue And Wait For PMI Beam Type And Start Traffic
    Step 3: Validate New Trace Recording Session Start Msg
    Step 4: Validate AoA Msg For PMI Beam
    Step 5: Validate SRS Beam Type
    Step 6: Validate AoA Msgs For SRS Beam Are Occurring Periodically
    Step 7: Validate Rank Indicator In Utilized Beams
    Step 8: Release PDU Session With Traffic And Validate New Trace Recording Session Stop Msg

    [Teardown]    Deregister Ue Without Confirmation    ue_id=${UE_ID}


Step 1: Configure Number Of Transmission Layers For UE
    Log  \n==== Step 1: Configure Number Of Transmission Layers For UE ====  console=True
    Execute Egate Cmd    cmd=csi_override_testmode_nr profile_id=1 ri=${RANK_INDICATOR}
    Execute Egate Cmd    cmd=ue_testmode_set_nr id=${UE_ID} testmode=csi_override action=activate profile_id=1


Step 2: Attach Ue And Wait For PMI Beam Type And Start Traffic
    Log  \n==== Step 2: Attach Ue And Wait For PMI Beam Type And Start Traffic ====  console=True
    Perform Action And Wait For Given Tshark Message Number    alias=${TCE_ALIAS}
    ...    packet_filter=nsetapx.beamType == 2
    ...    packet_number=1    waiting_timeout=180    action=Attach Ue And Setup PDU Session

    Exit Idle Mode And Start Data Traffic    ue_id=${UE_ID}


Attach Ue And Setup PDU Session
    [Arguments]    ${pdu_id}=1
    ${ue_idle_timeout}=    Get srbInactivityTimerSA value
    ${half_ue_idle_timeout}=    Evaluate    int(${ue_idle_timeout})//int(2)

    Attach UE    ue_id=${UE_ID}    cell=${CELL_ID}    enb=2
    ...    pass_regexp=Received REGISTRATION COMPLETE from UE
    Set UE Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=${pdu_id}

    Sleep    ${half_ue_idle_timeout}s    reason=Expand the time window for PMI Beam to appear

    Establish PDU Session    ue_id=${UE_ID}    pdu_id=${pdu_id}    gw_id=1    nwslice=1
    ...    timeout=15
    ...    pass_regexp=UE${UE_ID}: Established PDU session ID=${pdu_id} using PDU Gateway ID=


Step 3: Validate New Trace Recording Session Start Msg
    Log  \n==== Step 3: Validate New Trace Recording Session Start Msg ====  console=True
    Validate Trace Recording Session Elements MBA
    ...    filter=nsetapx.startRecordingSession_element
    ...    number_of_messages=1


Step 4: Validate AoA Msg For PMI Beam
    Log  \n==== Step 4: Validate AoA Msg For PMI Beam ====  console=True
    Validate Trace Recording Session Elements MBA
    ...    filter=nsetapx.beamType == 2 && nsetapx.angleOfArrivalRecord && nsetapx.beamUsageTime && nsetapx.azimuthAngle && nsetapx.zenithAngle


Step 5: Validate SRS Beam Type
    Log  \n==== Step 5: Validate SRS Beam Type ====  console=True
    Validate Beam Type    alias=${TCE_ALIAS}    beam_type=1


Step 6: Validate AoA Msgs For SRS Beam Are Occurring Periodically
    Log  \n==== Step 6: Validate AoA Msgs For SRS Beam Are Occurring Periodically ====  console=True
    Validate Trace Recording Session Elements MBA
    ...    filter=nsetapx.beamType == 1 && nsetapx.angleOfArrivalRecord && nsetapx.beamUsageTime && nsetapx.azimuthAngle && nsetapx.zenithAngle
    ...    number_of_messages=2


Step 7: Validate Rank Indicator In Utilized Beams
    Log  \n==== Step 7: Validate Rank Indicator In Utilized Beams ====  console=True
    Validate Trace Recording Session Elements MBA
    ...    filter=nsetapx.rankIndicator == ${RANK_INDICATOR}


Release PDU Session With Traffic
    Stop Data Traffic    ues=${UE_ID}
    Release UE PDU Session    ue_id=${UE_ID}


Step 8: Release PDU Session With Traffic And Validate New Trace Recording Session Stop Msg
    Log  \n==== Step 8: Release PDU Session With Traffic And Validate New Trace Recording Session Stop Msg ====  console=True
    Perform Action And Wait For Given Tshark Message Number    alias=${TCE_ALIAS}
    ...    packet_filter=nsetapx.stopRecordingSession_element
    ...    packet_number=1    waiting_timeout=180    action=Release PDU Session With Traffic

