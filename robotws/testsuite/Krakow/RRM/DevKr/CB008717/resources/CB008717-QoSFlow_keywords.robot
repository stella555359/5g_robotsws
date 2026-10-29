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
&{USER_5QI_TO_EGATE_QOS_FLOW_ID}=  170=1  1=2  9=3  5=4  2=2  4=5  8=6  7=7

*** Keywords ***
Verify that gNB${gnb_id:\d+} forwards UECapabilities received from UE${ue_id:\d+} to AMF${amf_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=uERadioCapabilityInfoIndication
    ...     device=AMF${amf_id}

    Verify That Message Fulfills Query
    ...     UERadioCapability is present
    ...     message_alias=UERadioCapabilityInfoIndication
    ...     flow_alias=${flow_alias}

    ${flow_alias2}=     Get flow name
    ...     UECapabilityInformation
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    verify_if_UERadioCapability_from_two_messages_is_the_same
    ...    message_source=UECapabilityInformation
    ...    flow_source=${flow_alias2}
    ...    message_to_verify=UERadioCapabilityInfoIndication
    ...    flow_to_verify=${flow_alias}

Reset QoS Flow settings on SMF
    Execute egate command  cmd=smf_param id=1 reset

Prepare NrDc UE${ue_id:\d+} candidate with 1 PDU sessions with 1 GBR QoS Flow
    Attach UE${ue_id} without ICS to gNB2 cell2
    Add to UE${ue_id} initial PDU session with ICS and indexToRFSP equal 87
    Add to UE${ue_id} PDU1 session QoS flows with 5QI from list [4] and delete QoS flows with 5QI from list [170]

    Trigger UE${ue_id} to enter idle mode

    EXPECT FLOW[timeout=10]: AMF1 NGAP initialContextSetup
    Trigger UE${ue_id} idle mode exit
    PASS FLOW[timeout=10]: AMF1 NGAP initialContextSetup

    Verify that AMF1 NGAP InitialContextSetup contains 1 PDU sessions
    Trigger UE${ue_id} to enter idle mode

Prepare NrDc UE${ue_id:\d+} candidate with 1 PDU sessions with 1 non-GBR signalling QoS Flow
    Attach UE${ue_id} without ICS to gNB2 cell2
#    Add to UE${ue_id} initial PDU session with ICS
    Add to UE${ue_id} initial PDU session with ICS and indexToRFSP equal 87
    Add to UE${ue_id} PDU1 session QoS flows with 5QI from list [5] and delete QoS flows with 5QI from list [170]

    Execute egate command
    ...     cmd=amf_param id=1 empty_pdu_session_list=off send_ics_registration=off

    Execute egate command
    ...     cmd=smf_param id=1 reset

    Trigger UE${ue_id} to enter idle mode

    EXPECT FLOW[timeout=10]: AMF1 NGAP initialContextSetup
    Trigger UE${ue_id} idle mode exit
    PASS FLOW[timeout=10]: AMF1 NGAP initialContextSetup

    Verify that AMF1 NGAP InitialContextSetup contains 1 PDU sessions
    Trigger UE${ue_id} to enter idle mode

Modify PDU${pdu_id:\d+} session by adding 1 non-GBR QoS Flow for UE${ue_id:\d+}
    Add to UE${ue_id} PDU1 session QoS flows with 5QI from list [9] and delete QoS flows with 5QI from list []

Modify PDU${pdu_id:\d+} session by adding 1 non-GBR QoS Flow and deleting 1 non-GBR signalling QoS Flow for UE${ue_id:\d+}
    Add to UE${ue_id} PDU2 session QoS flows with 5QI from list [170] and delete QoS flows with 5QI from list [5]

Modify PDU${pdu_id:\d+} session by deleting 1 GBR QoS Flow for UE${ue_id:\d+}
    Add to UE${ue_id} PDU${pdu_id} session QoS flows with 5QI from list [] and delete QoS flows with 5QI from list [4]
    Sleep    2

Add second PDU2 session with 1 non-GBR signalling QoS Flow for UE${ue_id:\d+}
    Add to UE${ue_id} second PDU session after ICS
    Add to UE${ue_id} PDU2 session QoS flows with 5QI from list [5] and delete QoS flows with 5QI from list [170]

Prepare NrDc UE${ue_id:\d+} candidate with 1 PDU sessions with 1 non-GBR and 1 GBR QoS Flow
    Attach UE${ue_id} without ICS to gNB2 cell2
#    Add to UE${ue_id} initial PDU session with ICS
    Add to UE${ue_id} initial PDU session with ICS and indexToRFSP equal 87
    Add to UE${ue_id} PDU1 session QoS flows with 5QI from list [4] and delete QoS flows with 5QI from list []

    Execute egate command
    ...     cmd=amf_param id=1 empty_pdu_session_list=off send_ics_registration=off

    Execute egate command
    ...     cmd=smf_param id=1 reset

    Trigger UE${ue_id} to enter idle mode

    EXPECT FLOW[timeout=10]: AMF1 NGAP initialContextSetup
    Trigger UE${ue_id} idle mode exit
    PASS FLOW[timeout=10]: AMF1 NGAP initialContextSetup

    Verify that AMF1 NGAP InitialContextSetup contains 1 PDU sessions
    Trigger UE${ue_id} to enter idle mode

Prepare NrDc UE${ue_id:\d+} candidate with 1 PDU sessions with 1 non-GBR and 1 GBR QoS Flow on NRCELL-${cell_id:\d+}
    Attach UE${ue_id} without ICS to gNB2 cell${cell_id}
#    Add to UE${ue_id} initial PDU session with ICS
    Add to UE${ue_id} initial PDU session with ICS and indexToRFSP equal 87
    Add to UE${ue_id} PDU1 session QoS flows with 5QI from list [4] and delete QoS flows with 5QI from list []

    Execute egate command
    ...     cmd=amf_param id=1 empty_pdu_session_list=off send_ics_registration=off

    Execute egate command
    ...     cmd=smf_param id=1 reset

    Trigger UE${ue_id} to enter idle mode

    EXPECT FLOW[timeout=10]: AMF1 NGAP initialContextSetup
    Trigger UE${ue_id} idle mode exit
    PASS FLOW[timeout=10]: AMF1 NGAP initialContextSetup

    Verify that AMF1 NGAP InitialContextSetup contains 1 PDU sessions
    Trigger UE${ue_id} to enter idle mode

Trigger UE${ue_id:\d+} idle mode exit
    Execute egate command
    ...   cmd=ue_im_exit id=${ue_id}

Trigger UE${ue_id:\d+} to enter idle mode
    Execute egate command
    ...   cmd=ue_im_entry id=${ue_id} by=ue
    Sleep  3

Remove QoS flows with 5QI from list [${qos_del}] from NRDC splitted PDU${pdu_id} at UE${ue_id} and expect TakeBack occured
    @{qos_to_del_list}=   Split To List       ${qos_del}
    ${length_of_qos_to_del_list}=  Get length    ${qos_to_del_list}

    ${qos_ids_del}=    Set Variable

    ${mapping}=    get variable value           ${USER_5QI_TO_EGATE_QOS_FLOW_ID}

    FOR  ${5qi}  IN  @{qos_to_del_list}
        ${qos_flow_id}    Get From Dictionary    ${mapping}   ${5qi}
        ${qos_ids_del}=   Add To String    ${qos_ids_del}    ${qos_flow_id}
    END

    EXPECT FLOW[timeout=10]: AMF1 NGAP pDUSessionResourceModify
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete

    Execute egate command   cmd=ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_del=${qos_ids_del} by=amf

    PASS FLOW[timeout=10]: AMF1 NGAP pDUSessionResourceModify
    Verify in NGAP that QoS flows for 5QIs [${qos_del}] were successfully released from PDU${pdu_id} session

    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete

    ${flow_alias_rrc}=     Get flow name
    ...     2*RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     (mrdc-SecondaryCellGroupConfig contains (release is present))
    ...     message_alias=RRCReconfiguration_1
    ...     flow_alias=${flow_alias_rrc}

    Verify That Message Fulfills Query
    ...     (length(drb-ToReleaseList) eq ${length_of_qos_to_del_list})
    ...     message_alias=RRCReconfiguration_2
    ...     flow_alias=${flow_alias_rrc}

Remove QoS flows with 5QI from list [${qos_del}] from NRDC splitted PDU${pdu_id} at UE${ue_id} and expect TakeBack failure
    @{qos_to_del_list}=   Split To List       ${qos_del}
    ${length_of_qos_to_del_list}=  Get length    ${qos_to_del_list}

    ${qos_ids_del}=    Set Variable

    ${mapping}=    get variable value           ${USER_5QI_TO_EGATE_QOS_FLOW_ID}

    FOR  ${5qi}  IN  @{qos_to_del_list}
        ${qos_flow_id}    Get From Dictionary    ${mapping}   ${5qi}
        ${qos_ids_del}=   Add To String    ${qos_ids_del}    ${qos_flow_id}
    END

    EXPECT FLOW[timeout=10]: AMF1 NGAP pDUSessionResourceModify
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishmentRequest

    Execute egate command   cmd=ue_nr_rrc_reconf_param if_contains=any action=reestablish cause=reconfigurationFailure id=${ue_id}
    Execute egate command   cmd=ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_del=${qos_ids_del} by=amf

    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishmentRequest
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    PASS FLOW[timeout=10]: AMF1 NGAP pDUSessionResourceModify

    ${flow_alias_rrc}=     Get flow name
    ...     RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     (mrdc-SecondaryCellGroupConfig contains (release is present))
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias_rrc}

    ${flow}=    Get flow name
         ...     procedure=pDUSessionResourceModify
         ...     device=AMF1

    Verify That Message Fulfills Query
    ...     (PDUSessionResourceFailedToModifyListModRes is present)
    ...     message_alias=PDUSessionResourceModifyResponse
    ...     flow_alias=${flow}

Remove QoS flows with 5QI from list [${qos_del}] from NRDC splitted PDU${pdu_id} at UE${ue_id} and expect PDUModification failure
    @{qos_to_del_list}=   Split To List       ${qos_del}
    ${length_of_qos_to_del_list}=  Get length    ${qos_to_del_list}

    ${qos_ids_del}=    Set Variable

    ${mapping}=    get variable value           ${USER_5QI_TO_EGATE_QOS_FLOW_ID}

    FOR  ${5qi}  IN  @{qos_to_del_list}
        ${qos_flow_id}    Get From Dictionary    ${mapping}   ${5qi}
        ${qos_ids_del}=   Add To String    ${qos_ids_del}    ${qos_flow_id}
    END

    EXPECT FLOW[timeout=10]: AMF1 NGAP pDUSessionResourceModify
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete

    Execute egate command   cmd=ue_nr_rrc_reconf_param if_contains=any action=drop nth=2 id=${ue_id}
    Execute egate command   cmd=ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_del=${qos_ids_del} by=amf

    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    FAIL FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete
    PASS FLOW[timeout=10]: AMF1 NGAP pDUSessionResourceModify

    ${flow_alias_rrc}=     Get flow name
    ...     2*RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     (mrdc-SecondaryCellGroupConfig contains (release is present))
    ...     message_alias=RRCReconfiguration_1
    ...     flow_alias=${flow_alias_rrc}

    Verify That Message Fulfills Query
    ...     (length(drb-ToReleaseList) eq ${length_of_qos_to_del_list})
    ...     message_alias=RRCReconfiguration_2
    ...     flow_alias=${flow_alias_rrc}

    ${flow}=    Get flow name
         ...     procedure=pDUSessionResourceModify
         ...     device=AMF1

#    Verify That Message Fulfills Query      TODO check legacy spec why this is not present!
#    ...     (PDUSessionResourceFailedToModifyListModRes is present)
#    ...     message_alias=PDUSessionResourceModifyResponse
#    ...     flow_alias=${flow}

Verify that QosFlowToRelaseList recieved with cause:radioNetwork:unspecified
    ${flow}=    Get flow name
         ...     procedure=pDUSessionResourceModify
         ...     device=AMF1

    Verify That Message Fulfills Query
    ...     (QosFlowListWithCause contains (radioNetwork eq 'unspecified'))
    ...     message_alias=PDUSessionResourceModifyRequest
    ...     flow_alias=${flow}
