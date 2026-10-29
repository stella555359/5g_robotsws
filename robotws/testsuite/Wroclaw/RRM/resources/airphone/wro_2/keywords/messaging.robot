# WARNING! messaging.robot is not python2.7 compatible

*** Settings ***
Documentation    Keywords for features fET.

Library     ta_messaging
Library     ../resources/NSA_messaging_filters.py
Library     ../resources/messaging.py
Resource    ./L3_Call.robot
Library      Process

*** Keywords ***
# Keywords wrapping usage of ta_messaging library around typical actions
###    SA Keywords    ###
Create gNB Alias
    [Arguments]     ${gNB_id}=2    ${gNB_IP}=10.0.1.2
    Create GNB Device With Alias 'gNB${gNB_id}' Identified By ip=${gNB_IP}
    Enable Internal Mirroring For Alias    gNB${gNB_id}

Attach UE And Verify Establishing PDU Session
    [Arguments]    ${ue_id}    ${cell_id}    ${gnb_id}=2    ${pdu_id}=1    ${gw_id}=1
    Create SA Aliases    ue_id=${ue_id}    gNB_id=${gnb_id}
    Expect UE Attach Messages Flow     ue_id=${ue_id}    gNB_id=${gnb_id}
    Expect PDU Messages Flow     ue_id=${ue_id}    gNB_id=${gnb_id}
    Sleep    3    # waiting for messages capturing to be stabilized
    Attach UE And Establish PDU Session    ue_id=${ue_id}    cell_id=${cell_id}    enb_id=${gnb_id}    pdu_id=${pdu_id}    gw_id=${gw_id}
    Check If UE Attach Messages Flow Occurred     ue_id=${ue_id}
    Check If PDU Messages Flow Occurred     ue_id=${ue_id}

Create SA Aliases
    [Arguments]     ${ue_id}    ${gNB_id}=2    ${gNB_IP}=10.0.1.2
    Create GNB Device With Alias 'gNB${gNB_id}' Identified By ip=${gNB_IP}
    Create UE Alias    alias=UE${ue_id}    ue_id=${ue_id}    id_type=wts_5g
    Enable Internal Mirroring For Alias    gNB${gNB_id}

Expect UE Attach Messages Flow
    [Arguments]     ${ue_id}    ${gNB_id}=2
    ${T3410}=    Set Variable    15  # 3GPP TS 24.301
    ${margin}=    Set Variable    2  # if anything the fail should be in Attach UE And Establish PDU Session keyword,
                                     # not in message capturing/veryfing part
    ${timeout}=    Evaluate     ${T3410}*2+${margin}  # There are two T3410 timers in keyword Attach UE And Establish PDU Session
    Expect Message Flow
    ...    UE${ue_id}:NR-RRC_RRCSetupRequest as RRCSetupRequest
    ...    UE${ue_id}:NR-RRC_RRCSetup as RRCSetup
    ...    UE${ue_id}:NR-RRC_RRCSetupComplete as RRCSetupComplete
    ...    gNB${gNB_id}:NGAP_InitialUEMessage as InitialUEMessage
    ...    alias=Attach_UE${ue_id}   overall_timeout=${timeout}

Check If UE Attach Messages Flow Occurred
    [Arguments]     ${ue_id}
    Flow Occurred As Expected    alias=Attach_UE${ue_id}

Expect PDU Messages Flow
    [Arguments]     ${ue_id}    ${gNB_id}=2
    ${T3410}=    Set Variable    15  # 3GPP TS 24.301
    ${margin}=    Set Variable    2  # if anything the fail should be in Attach UE And Establish PDU Session keyword,
                                     # not in message capturing/veryfing part
    ${timeout}=    Evaluate     ${T3410}*2+${margin}  # There are two T3410 timers in keyword Attach UE And Establish PDU Session
    Expect Message Flow
    ...    gNB${gNB_id}:NGAP_InitialContextSetupRequest as InitialContextSetupRequest
    ...    gNB${gNB_id}:NGAP_UERadioCapabilityInfoIndication as UERadioCapabilityInfoIndication
    ...    gNB${gNB_id}:NGAP_InitialContextSetupResponse as InitialContextSetupResponse
    ...    alias=Established_PDU_NGAP_UE${ue_id}   overall_timeout=${timeout}
    Expect Message Flow
    ...    gNB${gNB_id}:F1AP_UEContextSetupRequest as UEContextSetupRequest
    ...    gNB${gNB_id}:F1AP_UEContextSetupResponse as UEContextSetupResponse
    ...    alias=Established_PDU_F1AP_UE${ue_id}   overall_timeout=${timeout}
    Expect Message Flow
    ...    UE${ue_id}:NR-RRC_UECapabilityEnquiry as UECapabilityEnquiry
    ...    UE${ue_id}:NR-RRC_UECapabilityInformation as UECapabilityInformation
    ...    UE${ue_id}:NR-RRC_RRCReconfiguration as RRCReconfiguration
    ...    UE${ue_id}:NR-RRC_RRCReconfigurationComplete as RRCReconfigurationComplete
    ...    alias=Established_PDU_NR_RRC_UE${ue_id}   overall_timeout=${timeout}

Check If PDU Messages Flow Occurred
    [Arguments]     ${ue_id}
    Flow Occurred As Expected    alias=Established_PDU_NGAP_UE${ue_id}
    Flow Occurred As Expected    alias=Established_PDU_F1AP_UE${ue_id}
    Flow Occurred As Expected    alias=Established_PDU_NR_RRC_UE${ue_id}

Expect SCell Addition Messages Flow
    [Arguments]     ${ue_id}    ${gNB_id}=2
    Expect Message Flow
    ...    gNB${gNB_id}:F1AP_UEContextModificationRequest (SCell-ToBeSetupMod-List is present) as UEContextModificationRequest
    ...    gNB${gNB_id}:F1AP_UEContextModificationResponse (sCellToAddModList is present) as UEContextModificationResponse
    ...    gNB${gNB_id}:F1AP_UEContextModificationRequest (GNB-DUConfigurationQuery is present) as UEContextModificationRequest_2nd
    ...    gNB${gNB_id}:F1AP_UEContextModificationResponse (sCellToAddModList is present) as UEContextModificationResponse_2nd
    ...    UE${UE_ID}:NR-RRC_RRCReconfiguration (sCellToAddModList is present) as RRCReconfiguration
    ...    UE${UE_ID}:NR-RRC_RRCReconfigurationComplete as RRCReconfigurationComplete
    ...    alias=SCellAddition_UE${ue_id}   overall_timeout=60

Check If SCell Addition Messages Flow Occured
    [Arguments]     ${ue_id}
    Flow Occurred As Expected    alias=SCellAddition_UE${ue_id}

Attach UE And Verify Establishing PDU Session With Blind SCell Addition
    [Documentation]    Requires setting the gNB alias separately (keyword Create gNB Alias), but can be used in multi-UE scenarios without any change
    ...                Verifies successful PDU Session Setup and the occurrence of Blind SCell Addition immediately afterwards
    [Arguments]    ${ue_id}    ${cell_id}    ${gnb_id}=2    ${pdu_id}=1    ${gw_id}=1
    Create UE Alias    alias=UE${ue_id}    ue_id=${ue_id}    id_type=wts_5g
    Expect UE Attach Messages Flow     ue_id=${ue_id}    gNB_id=${gnb_id}
    Expect PDU Messages Flow     ue_id=${ue_id}    gNB_id=${gnb_id}
    Expect SCell Addition Messages Flow    ue_id=${ue_id}
    Attach UE And Establish PDU Session    ue_id=${ue_id}    cell_id=${cell_id}    enb_id=${gnb_id}    pdu_id=${pdu_id}    gw_id=${gw_id}
    Check If UE Attach Messages Flow Occurred     ue_id=${ue_id}
    Check If PDU Messages Flow Occurred     ue_id=${ue_id}
    Check If SCell Addition Messages Flow Occured    ue_id=${ue_id}
    Verify That Message Fulfills Query    pdu-Session eq ${pdu_id}    message_alias=RRCReconfiguration
    ...    flow_alias=Established_PDU_NR_RRC_UE${ue_id}


###    NSA / SA+NSA Keywords    ###

Attach UE In NSA Mode And Verify Success
    [Arguments]    ${ue_id}    ${cell_id}    ${gNB_id}=2
    Create SANSA Aliases    ue_id=${ue_id}
    Expect LTE RRC Flow For UE    ue_id=${ue_id}
    Attach UE To Enb    ue_id=${ue_id}    optional_parameters=profile=1
    Check If LTE RRC Messages Flow Occured    ue_id=${ue_id}
    Expect ENDC Flow For UE    ue_id=${ue_id}    gNB_id=${gNB_id}
    Start Gnb Addition Procedure    ue=${ue_id}    target_gnb=${gNB_id}    target_cells=${cell_id}    bearer=2    dc_type=split_scg
    ...                             pass_regexp=Proxy \\(eNB ${gNB_id} cell ${cell_id}\\) reported successful RA
    Check If ENDC Messages Flow Occured    ue_id=${ue_id}

Create SANSA Aliases
    [Arguments]     ${ue_id}    ${gNB_id}=2    ${gNB_IP}=10.0.1.2    ${eNB_id}=""    ${eNB_IP}=10.0.1.137
    Enable UE Capture On Simulated Enb    enable=${True}
    Create SA Aliases    ue_id=${ue_id}    gNB_id=${gNB_id}    gNB_IP=${gNB_IP}
    Create ENB device with alias 'eNB${eNB_id}' identified by ip=${eNB_IP}

Expect LTE RRC Flow For UE
    [Arguments]    ${ue_id}
    ${T3410}=    Set Variable    15  # 3GPP TS 24.301
    ${margin}=    Set Variable    2  # if anything the fail should be in Attach UE To Enb keyword, not in message capturing/veryfing part
    ${timeout}=    Evaluate     ${T3410}+${margin}
    Expect Message Flow
    ...     UE${ue_id}:RRC_RRCConnectionRequest
    ...     UE${ue_id}:RRC_RRCConnectionSetup
    ...     UE${ue_id}:RRC_RRCConnectionSetupComplete
    ...     UE${ue_id}:RRC_UECapabilityEnquiry
    ...     UE${ue_id}:RRC_UECapabilityInformation
    ...     UE${ue_id}:RRC_RRCConnectionReconfiguration
    ...     UE${ue_id}:RRC_RRCConnectionReconfigurationComplete
    ...     alias=LTE-RRC_UE${ue_id}
    ...     overall_timeout=${timeout}

Check If LTE RRC Messages Flow Occured
    [Arguments]    ${ue_id}
    Flow Occurred As Expected   alias=LTE-RRC_UE${ue_id}

Expect ENDC Flow For UE
    [Arguments]    ${ue_id}    ${gNB_id}=2
    ${tDCOverall}=    Set Variable    5  # MRBTS.NRBTS.tDCoverall default value of 5000ms
    ${margin}=    Set Variable    2  # if anything the fail should be in Start Gnb Addition Procedure keyword, not in message capturing/veryfing part
    ${timeout}=    Evaluate     ${tDCOverall}+${margin}
    Expect message flow
    ...    gNB${gNB_id}:X2AP_SgNBAdditionRequest (MeNBtoSgNBContainer is present) as SgnbAddReq
    ...    gNB${gNB_id}:X2AP_SgNBAdditionRequestAcknowledge (SgNBtoMeNBContainer is present) as SgnbAddReqAck
    ...    gNB${gNB_id}:X2AP_SgNBReconfigurationComplete (success-SgNBReconfComp is present) as SgnbReconfCmp
    ...    gNB${gNB_id}:X2AP_SNStatusTransfer
    ...    alias=EN-DC_X2AP_UE${ue_id}
    ...    overall_timeout=${timeout}
    Expect message flow
    ...    gNB${gNB_id}:F1AP_UEContextSetupRequest as ContextSetupReq
    ...    gNB${gNB_id}:F1AP_UEContextSetupResponse as ContextSetupResp
    ...    alias=EN-DC_F1AP_UE${ue_id}
    ...    overall_timeout=${timeout}

Check If ENDC Messages Flow Occured
    [Arguments]    ${ue_id}
    Flow Occurred As Expected   alias=EN-DC_X2AP_UE${ue_id}
    Flow Occurred As Expected   alias=EN-DC_F1AP_UE${ue_id}

Verify SgNBAddition Messages Flow Content For UE
    [Arguments]    ${ue_id}    ${physcell_id}
    ${filters}=    Get SgNBAddition Message Flow Filters    physcellid=${physcell_id}
    Verify That Message Fulfills Query
    ...    ${filters}[PSCellID_in_SgNBAdditionRequest]    message_alias=SgnbAddReq    flow_alias=EN-DC_X2AP_UE${ue_id}
    Verify That Message Fulfills Query
    ...    ${filters}[UECapa_and_PSCellID_in_UEContextSetupRequest]    message_alias=ContextSetupReq    flow_alias=EN-DC_F1AP_UE${ue_id}
    Verify That Message Fulfills Query
    ...    ${filters}[PSCellID_in_UEContextSetupResponse]    message_alias=ContextSetupResp    flow_alias=EN-DC_F1AP_UE${ue_id}
    Verify That Message Fulfills Query
    ...    ${filters}[PSCellID_in_SgNBAdditionRequestAck]    message_alias=SgnbAddReqAck    flow_alias=EN-DC_X2AP_UE${ue_id}
    Verify That Message Fulfills Query
    ...    ${filters}[RRCReconfCmp_in_SgNBReconfCmp]    message_alias=SgnbReconfCmp    flow_alias=EN-DC_X2AP_UE${ue_id}


Expect SCell Change messages flow
    [Arguments]     ${ue_id}    ${gNB_id}=2    ${overall_timeout}=60
    Expect message flow
    ...    gNB${gNB_id}:F1AP_UEContextModificationRequest (SCell-ToBeSetupMod-List is present) as UEContextModificationRequest
    ...    gNB${gNB_id}:F1AP_UEContextModificationResponse (sCellToAddModList is present) as UEContextModificationResponse
    ...    UE${UE_ID}:NR-RRC_RRCReconfiguration (sCellToAddModList is present) as RRCReconfiguration
    ...    UE${UE_ID}:NR-RRC_RRCReconfigurationComplete as RRCReconfigurationComplete
    ...    gNB${gNB_id}:F1AP_UEContextModificationRequest (RRCReconfigurationCompleteIndicator is present) as UEContextModificationRequest_2nd
    ...    gNB${gNB_id}:F1AP_UEContextModificationResponse as UEContextModificationResponse_2nd
    ...    gNB${gNB_id}:F1AP_UEContextModificationRequest (GNB-DUConfigurationQuery is present) as UEContextModificationRequest_3nd
    ...    gNB${gNB_id}:F1AP_UEContextModificationResponse (sCellToAddModList is present) as UEContextModificationResponse_3nd
    ...    alias=SCellChange_UE${ue_id}
    ...    overall_timeout=${overall_timeout}

Check if SCell Change messages flow occured
    [Arguments]     ${ue_id}
    Flow occurred as expected  alias=SCellChange_UE${ue_id}

Expect SCell Release messages flow
    [Arguments]    ${ue_id}    ${gNB_id}=2    ${overall_timeout}=60
    Expect message flow
    ...    gNB${gNB_id}:F1AP_UEContextModificationRequest (SCell-ToBeRemoved-List is present) as UEContextModificationRequest
    ...    gNB${gNB_id}:F1AP_UEContextModificationResponse (sCellToReleaseList is present) as UEContextModificationResponse
    ...    UE${UE_ID}:NR-RRC_RRCReconfiguration (sCellToReleaseList is present) as RRCReconfiguration
    ...    UE${UE_ID}:NR-RRC_RRCReconfigurationComplete as RRCReconfigurationComplete
    ...    gNB${gNB_id}:F1AP_UEContextModificationRequest (RRCReconfigurationCompleteIndicator is present) as UEContextModificationRequest_2nd
    ...    gNB${gNB_id}:F1AP_UEContextModificationResponse as UEContextModificationResponse_2nd
    ...    gNB${gNB_id}:F1AP_UEContextModificationRequest (GNB-DUConfigurationQuery is present) as UEContextModificationRequest_3nd
    ...    gNB${gNB_id}:F1AP_UEContextModificationResponse (resourceToAddModList is present) as UEContextModificationResponse_3nd
    ...    alias=SCellRelease_UE${ue_id}
    ...    overall_timeout=${overall_timeout}

Check if SCell Release messages flow occured
    [Arguments]     ${ue_id}
    Flow occurred as expected  alias=SCellRelease_UE${ue_id}

Attach Multiple UEs And Verify Establishing PDU Sessions
    [Arguments]    ${ue_ids}    ${pdu_ids}    ${gw_ids}    ${cell_id}    ${gnb_id}=2    ${gnb_ip}=10.0.1.2
    ${ues_number}=    Get Length    ${ue_ids}
    Create GNB Device With Alias 'gNB${gnb_id}' Identified By ip=${gnb_ip}
    Enable Internal Mirroring For Alias    gNB${gnb_id}
    FOR    ${ue_index}    IN RANGE    ${ues_number}
        Create UE Alias    alias=UE${ue_ids}[${ue_index}]    ue_id=${ue_ids}[${ue_index}]    id_type=wts_5g
        Expect UE Attach Messages Flow     ue_id=${ue_ids}[${ue_index}]    gNB_id=${gnb_id}
        Expect PDU Messages Flow     ue_id=${ue_ids}[${ue_index}]    gNB_id=${gnb_id}
        Sleep    3    # waiting for messages capturing to be stabilized
        Attach UE And Establish PDU Session    ue_id=${ue_ids}[${ue_index}]    cell_id=${cell_id}    enb_id=${gnb_id}
        ...                                    pdu_id=${pdu_ids}[${ue_index}]    gw_id=${gw_ids}[${ue_index}]
        Check If UE Attach Messages Flow Occurred     ue_id=${ue_ids}[${ue_index}]
        Check If PDU Messages Flow Occurred     ue_id=${ue_ids}[${ue_index}]
    END

Set Custom SCTP RTO Min Time
    [Arguments]    ${SCTP_RTO_MIN_VALUE}=500
    Log to console    Setting custom SCTP RTO Time to ${SCTP_RTO_MIN_VALUE}
    ${sctp_rto_min_command}=    Set Variable    net.sctp.rto_min=
    Run Process     sudo    sysctl    -w    ${sctp_rto_min_command}${SCTP_RTO_MIN_VALUE}

Release Multiple UEs Without Confirmation
    [Arguments]    ${number_of_ues}
    ${number_of_simulated_ues_increased_by_one} =    Evaluate    ${number_of_ues}+1
    FOR    ${ue_id}    IN RANGE    1    ${number_of_simulated_ues_increased_by_one}    1
        ${pdu_id_eval}=  Evaluate  (${ue_id} % 14)+1
        Execute Egate Command    cmd=ue_pdu_session_release ue=${ue_id} pdu=${pdu_id_eval} by=amf
        Sleep    1
        Execute Egate Command    cmd=ue_deregister id=${ue_id} by=ue ue_deregister_type=switch_off
    END

Set Max Rx Tx Queue Sizes For AP Simulated Traffic Performance
    [Arguments]    ${queue_size}=20971520
    Log to console    Setting maximum allowed Rx and Tx queue sizes in the system for WTS traffic performance
    ${wmem_max_command}=    Set Variable    net.core.wmem_max=
    ${wmem_default_command}=    Set Variable    net.core.wmem_default=
    ${rmem_max_command}=    Set Variable    net.core.rmem_max=
    ${rmem_default_command}=    Set Variable    net.core.rmem_default=
    Run Process     sudo    sysctl    -w    ${wmem_max_command}${queue_size}
    Run Process     sudo    sysctl    -w    ${wmem_default_command}${queue_size}
    Run Process     sudo    sysctl    -w    ${rmem_max_command}${queue_size}
    Run Process     sudo    sysctl    -w    ${rmem_default_command}${queue_size}
