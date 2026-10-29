*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == AUTHORS C-PLANE ==
...      - Konrad Krzyzak <konrad.krzyzak@nokia.com>
...      - Karolina Sroczyk <karolina.sroczyk@nokia.com>
...      - Adrianna Zenczak <adrianna.zenczak@nokia.com>
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

*** Variables ***


*** Keywords ***
Add to UE${ue_id:\d+} initial PDU session with ICS and indexToRFSP equal ${indexToRSFP}
    EXPECT FLOW[timeout=3]: AMF1 NGAP pDUSessionResourceSetup
    Expect message flow
    ...    AMF1:NGAP_InitialContextSetupRequest as ICSRequest
    ...    alias=ICS
    ...    overall_timeout=10
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

    Execute egate command  cmd=amf_ue_ics_param id=1 ue=${ue_id} indexToRFSP=${indexToRSFP}

    Execute egate command  cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Run keyword and continue on failure
    ...     Execute egate command
    ...     cmd=ue_pdu_session_setup pdu=1 ue=${ue_id} gw=${current_gw_id} nwslice=1
    ...     pass_regexp=UE${ue_id}: UE${ue_id}: Established PDU session ID=1 using PDU Gateway ID
    ${current_gw_id}     Evaluate  ${current_gw_id} + 1
    Set Test Variable    ${current_gw_id}

    FAIL FLOW[timeout=3]: AMF1 NGAP pDUSessionResourceSetup
    Flow occurred as expected       alias=ICS
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

    Verify that AMF1 NGAP InitialContextSetup contains indexToRSFP equal ${indexToRSFP}

Verify that AMF${amf_id:\d+} NGAP InitialContextSetup contains indexToRSFP equal ${indexToRSFP}
    Verify That Message Fulfills Query
    ...     (IndexToRFSP is present)
    ...     message_alias=ICSRequest
    ...     flow_alias=ICS

    Verify That Message Fulfills Query
    ...     (IndexToRFSP eq ${indexToRSFP})
    ...     message_alias=ICSRequest
    ...     flow_alias=ICS

Set indexToRFSP to ${indexToRSFP:\d+} for UE${ue_id:\d+}
        Execute egate command  cmd=amf_ue_ics_param id=1 ue=${ue_id} indexToRFSP=${indexToRSFP}

Verify that UE${ue_id:\d+} performed ICS optimized
    Verify That Message Fulfills Query
    ...     ((UERadioCapability is present) and (PDUSessionResourceSetupListCxtReq is present))
    ...     message_alias=ICSRequest
    ...     flow_alias=ICS

Verify that UE${ue_id:\d+} performed ICS non optimized without UECap container
    Verify That Message Fulfills Query
    ...     ((UERadioCapability is not present) and (PDUSessionResourceSetupListCxtReq is present))
    ...     message_alias=ICSRequest
    ...     flow_alias=ICS

Attach UE${ue_id:\d+} with ICS to simulated gNB${gnb_id:\d+} with ICS and indexToRFSP equal ${indexToRSFP}
    EXPECT FLOW[timeout=10]: AMF1 NGAP pDUSessionResourceSetup
    Expect message flow
    ...    AMF1:NGAP_InitialContextSetupRequest as ICSRequest
    ...    alias=ICS
    ...    overall_timeout=10
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

    Execute egate command
    ...    cmd=amf_ue_ics_param id=1 ue=${ue_id} indexToRFSP=${indexToRSFP}
    Execute egate command  cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute egate command
    ...    cmd=change_ue_location id=${ue_id} cell=1 enb=${gnb_id}
    Sleep  1
    Execute egate command
    ...    cmd=ue_register id=${ue_id}
    Sleep  1
    Execute egate command
    ...    cmd=ue_pdu_session_setup ue=${ue_id} pdu=1 gw=${ue_id} nwslice=1
    Sleep  1

    PASS FLOW[timeout=10]: AMF1 NGAP pDUSessionResourceSetup
    Flow occurred as expected       alias=ICS
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

    Verify that AMF1 NGAP InitialContextSetup contains indexToRSFP equal ${indexToRSFP}

Set indexToRFSP for UE${ue_id:\d+} to ${indexToRSFP:\d+} using DL NAS Transport message
    EXPECT FLOW[timeout=10]: AMF1 NGAP downlinkNASTransport
    Execute egate command  cmd=amf_dl_nas_transport_param id=1 ue=${ue_id} indexToRFSP=${indexToRSFP}
    Execute egate command  cmd=ue_send_dl_nas_transport id=${ue_id}
    PASS FLOW[timeout=10]: AMF1 NGAP downlinkNASTransport

Verify that indexToRFSP-${indexToRfsp:\d+} is present in HandoverRequest message for UE${ue_id:\d+}
    ${flow_alias_handoverResourceAllocation}=     Get flow name
    ...     procedure=handoverResourceAllocation
    ...     device=AMF1

    ${source_to_target_hex_container}=  Set Variable  SourceToTarget-TransparentContainer

    verify_indexToRfsp_presence_in_handoverRequest
    ...     flow_alias=${flow_alias_handoverResourceAllocation}
    ...     message_alias=HandoverRequest
    ...     container=SourceToTarget-TransparentContainer
    ...     value=${indexToRfsp}

Verify that indexToRFSP-${indexToRfsp:\d+} is present in HandoverRequest message for inter-gNB XN based HO for UE${ue_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=handoverPreparation
    ...     device=gNB2
    ...     protocol=XNAP

    Verify That Message Fulfills Query
    ...     indexToRatFrequencySelectionPriority eq ${indexToRfsp}
    ...     message_alias=HandoverRequest
    ...     flow_alias=${flow_alias}

Attach UE${ue_id:\d+} to gNB${gnb_id:\d+} cell${cell_id:\d+} with ICS and indexToRFSP equal ${indexToRSFP}
    Expect message flow
    ...    AMF1:NGAP_InitialContextSetupRequest as ICSRequest
    ...    alias=ICS
    ...    overall_timeout=10
    Execute egate command   cmd=amf_ue_ics_param id=1 ue=${ue_id} indexToRFSP=${indexToRSFP}
    Execute egate command   cmd=amf_param id=1 empty_pdu_session_list=on send_ics_registration=on
    Execute egate command   cmd=ue_change_location id=${ue_id} enb=${gnb_id} cell=${cell_id}
    Execute egate command
    ...  cmd=ue_register id=${ue_id}
    ...  pass_regexp=Received REGISTRATION COMPLETE
    Execute egate command  cmd=amf_param id=1 empty_pdu_session_list=off send_ics_registration=off
    Flow occurred as expected       alias=ICS

    Verify that AMF1 NGAP InitialContextSetup contains indexToRSFP equal ${indexToRSFP}
