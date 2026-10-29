*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == AUTHORS C-PLANE ==
...      - Dawid Krawczuk <dawid.krawczuk@nokia.com>
...      - Tomasz Pyrek <tomasz.pyrek@nokia.com>
...      - Michał Szymakowski <michal.szymakowski@nokia.com>
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

Resource    ./5GC001756-common_keywords.robot

*** Keywords ***
Add to UE${ue_id:\d+} PDU session with default QoS flow
    Sleep  2
    Expect Message Flow
    ...     AMF1:NGAP_PDUSessionResourceSetupRequest as PDUSessionResourceSetupRequest
    ...     AMF1:NGAP_PDUSessionResourceSetupResponse as PDUSessionResourceSetupResponse
    ...     alias=UE${ue_id}_NGAP_PDU_Session_Add  overall_timeout=10

    Expect Message Flow
    ...     UE_${ue_id}:NR-RRC_RRCReconfiguration as RRCReconfiguration
    ...     UE_${ue_id}:NR-RRC_RRCReconfigurationComplete
    ...     alias=UE${ue_id}_RRC_DRB_Add  overall_timeout=15

    Execute egate command
    ...     cmd=ue_pdu_session_setup pdu=2 ue=${ue_id} gw=2 nwslice=1
    ...     pass_regexp=UE${ue_id}: UE${ue_id}: Established PDU session

Attach emergency UE${ue_id} with single PDU session in ICS
    EXPECT FLOW: UE_${ue_id} NR-RRC RRCSetupRequest
    EXPECT FLOW: AMF1 NGAP initialUEMessage with cause emergency
    EXPECT FLOW: AMF1 NGAP initialContextSetup optimized version with 1 PDU Sessions
    EXPECT FLOW[timeout=15]: AMF1 NGAP uERadioCapabilityInfoIndication in optimized ICS procedure
    EXPECT FLOW: UE_${ue_id} NR-RRC RRCReconfiguration
    Execute egate command   cmd=ue_nr_rrc_setup_param id=1 establishment_cause=emergency
    Execute egate command   cmd=ue_register id=${ue_id} registration_type=EmergencyRegistration
    Sleep  5
    Execute egate command
    ...     cmd=ue_pdu_session_setup pdu=1 ue=${ue_id} gw=${ue_id} nwslice=1 request_type=initial-emergency-request
    ...     pass_regexp=UE${ue_id}: UE${ue_id}: Established PDU session
    Sleep  2

    PASS FLOW: UE_${ue_id} NR-RRC RRCSetupRequest
    PASS FLOW: AMF1 NGAP initialUEMessage with cause emergency
    PASS FLOW: AMF1 NGAP initialContextSetup optimized version with 1 PDU Sessions
    FAIL FLOW[timeout=15]: AMF1 NGAP uERadioCapabilityInfoIndication in optimized ICS procedure
    PASS FLOW: UE_${ue_id} NR-RRC RRCReconfiguration

Verify that UE${ue_id:\d+} emergency attach with ${num:\d+} PDU session was completed successfully
    Verify number of elements on the list within NGAP message
    ...     amf_id=1
    ...     procedure_name=initialContextSetup
    ...     message=InitialContextSetupRequest
    ...     list_name=PDUSessionResourceSetupListCxtReq
    ...     element_num=${num}

    Verify number of elements on the list within NGAP message
    ...     amf_id=1
    ...     procedure_name=initialContextSetup
    ...     message=InitialContextSetupResponse
    ...     list_name=PDUSessionResourceSetupListCxtRes
    ...     element_num=${num}

    Verify number of elements on the list within NGAP message
    ...     amf_id=1
    ...     procedure_name=initialContextSetup
    ...     message=InitialContextSetupRequest
    ...     list_name=QosFlowSetupRequestList
    ...     element_num=${num}

    Verify number of elements on the list within NGAP message
    ...     amf_id=1
    ...     procedure_name=initialContextSetup
    ...     message=InitialContextSetupResponse
    ...     list_name=associatedQosFlowList
    ...     element_num=${num}

    Verify in RRCReconfiguration that UE${ue_id} ${num} DRBs were added

Attach UE${ue_id} with two PDU sessions to simulated gNB${gnb_id}
    Execute egate command   cmd=ue_change_location id=${ue_id} enb=2 cell=1
    Set up HO for UE${ue_id}
    Execute egate command   cmd=ue_register id=${ue_id}
    Sleep  2
    Execute egate command
    ...     cmd=ue_pdu_session_setup pdu=1 ue=${ue_id} gw=1 nwslice=1
    ...     pass_regexp=UE${ue_id}: UE${ue_id}: Established PDU session
    Sleep  2
    Execute egate command
    ...     cmd=ue_pdu_session_setup pdu=2 ue=${ue_id} gw=2 nwslice=1
    ...     pass_regexp=UE${ue_id}: UE${ue_id}: Established PDU session
    Sleep  2
    Execute egate command   cmd=meas_cfg_ue_disp id=${ue_id}
    Execute egate command
    ...     cmd=ue_measurement_send_nr id=${ue_id} meas_id=2 event=A5 srsrp_nr=19 srsrq_nr=10 phycell_id=52 nrsrp_nr=85 nrsrq_nr=31
    ...     pass_regexp=UE${ue_id}: Inter-eNB handover from EXT_ENB-2.1 to ENB-${gnb_id}.1 performed
    Sleep  20

Cleanup after test EA
    ${pcmd}    Get variable value      ${pcmd}    "True"
    Run Keyword if  ${pcmd} != "False"
    ...     Stop PCMD message collection
    Run keyword and ignore error    Detach UE1
    Run keyword and ignore error    Detach idle UE1
    Execute egate command   cmd=ue_nr_rrc_reconf_param id=1 if_contains=any nth=1 action=none
    Reset PCMD database

Prepare test environment interHO
    ${pcmd}    Get variable value      ${pcmd}    "True"
    Run Keyword if  ${pcmd} != "False"
    ...     Start PCMD message collection

Prepare test environment intraHO EA1
    ${pcmd}    Get variable value      ${pcmd}    "True"
    Run Keyword if  ${pcmd} != "False"
    ...         Start PCMD message collection
    ${ue_capa_c2}=    Set Variable   01A883321A000000109800800C4DAA2FFCBFF0110389A00000010010135378000000000000115000000000000015000001002004088A00
    Execute egate command
    ...     cmd=ics_amf_ue_param id=1-2 include_ue_capabilities=yes ue_capabilities=${ue_capa_c2}

Cleanup after test intraHO EA1
    ${pcmd}    Get variable value      ${pcmd}    "True"
    Run Keyword if  ${pcmd} != "False"
    ...         Stop PCMD message collection
    Run keyword and ignore error    Detach UE1
    Run keyword and ignore error    Detach idle UE1
    Run keyword and ignore error    Execute egate command   cmd=ue_change_location id=1 enb=2 cell=1
    Execute egate command   cmd=ics_amf_ue_param id=1-2 include_ue_capabilities=no
    Reset PCMD database

Prepare test environment intraHO EA3
    Execute egate command   cmd=qosflow_modify qos_flow=1 priority=5
    Execute egate command   cmd=qosflow_modify qos_flow=5 priority=5

    ${pcmd}    Get variable value      ${pcmd}    "True"
    Run Keyword if  ${pcmd} != "False"
    ...     Start PCMD message collection
    ${ue_capa_c2}=    Set Variable   01A883321A000000109800800C4DAA2FFCBFF0110389A00000010010135378000000000000115000000000000015000001002004088A00
    Execute egate command
    ...     cmd=ics_amf_ue_param id=1-2 include_ue_capabilities=yes ue_capabilities=${ue_capa_c2}
    Execute egate command   cmd=ue_change_location id=1 enb=2 cell=1
    Set up HO for UE1

Cleanup after test intraHO EA3
    ${pcmd}    Get variable value      ${pcmd}    "True"
    Run Keyword if  ${pcmd} != "False"
    ...         Stop PCMD message collection
    Run keyword and ignore error    Detach UE1
    Run keyword and ignore error    Detach idle UE1
    Run keyword and ignore error    Execute egate command   cmd=ue_change_location id=1 enb=2 cell=1
    Execute egate command   cmd=ics_amf_ue_param id=1-2 include_ue_capabilities=no
    Reset PCMD database

Prepare test environment intraHO EA2
    Execute egate command   cmd=qosflow_modify qos_flow=1 priority=15
    Execute egate command   cmd=qosflow_modify qos_flow=5 priority=15

    ${pcmd}    Get variable value      ${pcmd}    "True"
    Run Keyword if  ${pcmd} != "False"
    ...     Start PCMD message collection
    ${ue_capa_c2}=    Set Variable   01A883321A000000109800800C4DAA2FFCBFF0110389A00000010010135378000000000000115000000000000015000001002004088A00
    Execute egate command
    ...     cmd=ics_amf_ue_param id=1-2 include_ue_capabilities=yes ue_capabilities=${ue_capa_c2}
    Execute egate command   cmd=ue_change_location id=1 enb=2 cell=1

Cleanup after test intraHO EA2
    ${pcmd}    Get variable value      ${pcmd}    "True"
    Run Keyword if  ${pcmd} != "False"
    ...         Stop PCMD message collection

    Run keyword and ignore error    Detach UE1
    Run keyword and ignore error    Detach idle UE1
    Run keyword and ignore error    Execute egate command   cmd=ue_change_location id=1 enb=2 cell=1
    Execute egate command   cmd=ics_amf_ue_param id=1-2 include_ue_capabilities=no
    Execute egate command   cmd=qosflow_modify qos_flow=1 priority=5
    Execute egate command   cmd=qosflow_modify qos_flow=5 priority=5
    Execute egate command   cmd=ue_nr_rrc_reconf_param id=1 if_contains=any nth=1 action=none
    Reset PCMD database
    Sleep   5
    Run keyword and ignore error    Detach UE1
    Run keyword and ignore error    Execute egate command       cmd=ue_kill id=1
#    Run Keyword And Ignore Error           # needs ta_messaging stopping source implementation
#    ...   Run Keyword When Not In UTE      Restore AP by reset

Set expected call flow for gNB2 receives Measurement report for event A3 from UE${ue_id}
    Set Flow
    ...    NR-RRC_MeasurementReport
    ...    device=UE_${ue_id}

Set expected call flow for UE${ue_id} intra-gNB handover from cell1 to cell2
    Expect Message Flow
    ...     gNB2:F1AP_UEContextModificationRequest
    ...     alias=F1AP_modify_UE_${ue_id}  overall_timeout=15

    Expect Message Flow
    ...     UE_${ue_id}:NR-RRC_RRCReconfiguration as HORRCReconfiguration
    ...     alias=UE${ue_id}_NR-RRC_Reconf_ho  overall_timeout=15

    Expect Message Flow
    ...     UE_${ue_id}:NR-RRC_RRCReconfigurationComplete as HORRCReconfigurationComplete
    ...     alias=UE${ue_id}_NR-RRC_ReconfComplete_ho  overall_timeout=15

Set expected call flow for UE${ue_id} intra-gNB partial handover from cell1 to cell2
    Expect Message Flow
    ...     UE_${ue_id}:NR-RRC_RRCReconfiguration as HORRCReconfiguration
    ...     alias=UE${ue_id}_NR-RRC_Reconf_ho  overall_timeout=15

    Expect Message Flow
    ...     UE_${ue_id}:NR-RRC_RRCReconfigurationComplete as HORRCReconfigurationComplete
    ...     alias=UE${ue_id}_NR-RRC_ReconfComplete_ho  overall_timeout=15

    Expect Message Flow
    ...     AMF1:NGAP_PDUSessionResourceNotify as PDUNotify
    ...     alias=UE${ue_id}_NGAP_pdu_notify  overall_timeout=15

Set expected call flow for failure UE${ue_id} intra-gNB handover from cell1 to cell2
    Expect Message Flow
    ...     gNB2:F1AP_UEContextModificationRequest
    ...     alias=F1AP_modify_UE_${ue_id}  overall_timeout=15

    Expect Message Will Not Occur
    ...     UE_${ue_id}:NR-RRC_RRCReconfigurationComplete
    ...     alias=no_UE${ue_id}_NR-RRC_ReconfComplete  overall_timeout=10

Set expected call flow for successful UE${ue_id} PDU session modification by adding additional QoS flow
    Expect Message Flow
    ...     AMF1:NGAP_PDUSessionResourceModifyRequest as PDUSessionResourceModifyRequest
    ...     AMF1:NGAP_PDUSessionResourceModifyResponse as PDUSessionResourceModifyResponse
    ...     alias=UE${ue_id}_NGAP_qos_flow_add_succ  overall_timeout=10

    Expect Message Flow
    ...     UE_${ue_id}:NR-RRC_RRCReconfiguration as RRCReconfigurationAddedQosFlow
    ...     UE_${ue_id}:NR-RRC_RRCReconfigurationComplete
    ...     alias=UE${ue_id}_RRC_reconfiguration  overall_timeout=15

Set expected call flow for UE${ue_id} inter-gNB handover from gNB${src_gnb} to gNB${tgt_gnb}
    Log to console    UE${ue_id} from gNB${src_gnb} to gNB${tgt_gnb}
    EXPECT FLOW: gNB3_XN XNAP handoverPreparation,sNStatusTransfer
    EXPECT FLOW: UE_1 NR-RRC RRCReconfigurationComplete
    EXPECT FLOW: AMF1 NGAP pathSwitchRequest

Set expected call flow for UE${ue_id} inter gNB HO PDU Session Resource Release
    Log to console    UE${ue_id}
    EXPECT FLOW: UE_1 NR-RRC RRCReconfiguration
    EXPECT FLOW: UE_1 2 times NR-RRC RRCReconfigurationComplete

Set expected call flow for failure UE${ue_id} inter-gNB handover from gNB${tgt_src} to gNB${tgt_gnb}
    Log to console    UE${ue_id} from gNB${tgt_src} to gNB${tgt_gnb}
    EXPECT FLOW: gNB3_XN XNAP handoverPreparation,sNStatusTransfer
    EXPECT FLOW[timeout=15]: UE_1 NR-RRC RRCReconfigurationComplete
    EXPECT FLOW[timeout=15]: AMF1 NGAP pathSwitchRequest
    EXPECT FLOW[timeout=15]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease

Set expected call flow for inter-gNB handover for UE${ue_id}
    Log to console    UE${ue_id}
    EXPECT FLOW: gNB3_XN XNAP handoverPreparation,sNStatusTransfer

Set expected call flow for UE${ue_id} intra-cell handover
    Log to console    UE${ue_id}
    EXPECT FLOW: AMF1 NGAP pathSwitchRequest
    EXPECT FLOW: UE_1 NR-RRC RRCReconfiguration
    EXPECT FLOW: UE_1 2 times NR-RRC RRCReconfigurationComplete

Set up HO for UE${ue_id}
    ${list_id}=   Set variable   ${ue_id}
    Execute egate command
    ...     cmd=ue_history_information_list_add_ngran id=${list_id} gnb_id=3 cell_type=medium nrcgi=311:489|0x01 time_ue_stayed_in_cell=100
    Execute egate command
    ...     cmd=ue_history_information_list_add_ngran id=${list_id} gnb_id=2 cell_type=medium nrcgi=311:489|0x01 time_ue_stayed_in_cell=100
    Execute egate command   cmd=ue_history_information_list id=${list_id} action=commit
    Execute egate command   cmd=ue_enb_param id=${ue_id} ue_history_list=${list_id}

Trigger UE${ue_id} to send MeasurementReport with A3 value above offset defined for cell1 simulated gNB
    execute egate command   cmd=ue_measurement_send_nr id=${ue_id} meas_id=1 event=A3 srsrp_nr=18 phycell_id=52 nrsrp_nr=85

Trigger UE${ue_id} to send MeasurementReport with value above offset defined for cell2
    execute egate command   cmd=ue_measurement_send_nr id=${ue_id} meas_id=1 event=A3 srsrp_nr=18 phycell_id=51 nrsrp_nr=85

UE${ue_id} triggers XNAP Inter-gNB Handover from simulated gNB${src_gnb} to real gNB${tgt_gnb}
    Log to console    Executing Inter-gNB Handover from simulated gNB${src_gnb} to real gNB${tgt_gnb}
    execute egate command   cmd=ue_measurement_send_nr id=${ue_id} meas_id=5 event=A5 srsrp_nr=18 phycell_id=50 nrsrp_nr=85

UE${ue_id} triggers XNAP Inter-gNB Handover from simulated gNB${src_gnb} to cell2 real gNB${tgt_gnb}
    Log to console    Executing Inter-gNB Handover from simulated gNB${src_gnb} to cell2 real gNB${tgt_gnb}
    execute egate command   cmd=ue_measurement_send_nr id=${ue_id} meas_id=5 event=A5 srsrp_nr=18 phycell_id=51 nrsrp_nr=85

Verify that A3 measurement was send from UE${ue_id}
    ${flow_name}=   Get Flow Name
    ...    MeasurementReport
    ...    device=UE_${ue_id}
    ...    protocol=NR-RRC
    Flow Occurred As Expected   alias=${flow}

Verify that AMF receives notification that the not admitted PDU session has been released
    Flow Occurred As Expected   alias=UE1_NGAP_pdu_notify

    Verify That Message Fulfills Query
    ...     (PDUSessionResourceNotifyReleasedTransfer contains (radioNetwork eq "slice-not-supported"))
    ...     message_alias=PDUNotify
    ...     flow_alias=UE1_NGAP_pdu_notify

Verify that AMF sends New Security Context Indicator in NGAP: Path Switch Request Acknowledge message for UE${ue_id}
    Log to console    Verifying that AMF sends New Security Context Indicator in NGAP: Path Switch Request Acknowledge message for UE${ue_id}
    PASS FLOW: AMF1 NGAP pathSwitchRequest

    ${flow_alias}=      Get Flow Name
    ...     procedure=pathSwitchRequest
    ...     device=AMF1

    Verify That Message Fulfills Query
    ...     (NewSecurityContextInd eq 'true')
    ...     message_alias=PathSwitchRequestAcknowledge
    ...     flow_alias=${flow_alias}

Verify that intra cell intra gNB HO is performed successfully for UE${ue_id}
    PASS FLOW: UE_1 NR-RRC RRCReconfiguration
    PASS FLOW: UE_1 2 times NR-RRC RRCReconfigurationComplete

    ${flow_alias}=  Get Flow Name
    ...     RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     ((radioBearerConfig contains (securityConfig is present)) and (drb-ToAddModList contains (reestablishPDCP eq 'true')))
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias}

Verify that all requested PDU sessions for UE${ue_id} are admitted
    ${flow_alias}=  Get Flow Name
    ...     RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     (length(drb-ToAddModList) eq 2)
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias}

Verify that inter-gNB Handover was completed successfully for UE${ue_id}
    Log to console    Verifying that inter-gNB Handover was completed successfully for UE${ue_id}
    PASS FLOW: gNB3_XN XNAP handoverPreparation,sNStatusTransfer

    ${flow_alias}=      Get Flow Name
    ...     procedure=handoverPreparation,sNStatusTransfer
    ...     device=gNB3_XN

    Verify That Message Fulfills Query
    ...     ((length(pduSessionResourcesToBeSetup-List) eq 2)
    ...     and
    ...     (pduSessionResourcesToBeSetup-List contains ((pduSessionId eq 1) and (fiveQI eq 5)))
    ...     and
    ...     (pduSessionResourcesToBeSetup-List contains ((pduSessionId eq 2) and (fiveQI eq 5))))
    ...     message_alias=HandoverRequest
    ...     flow_alias=${flow_alias}

    Verify That Message Fulfills Query
    ...     (length(PDUSessionResourcesAdmitted-List) eq 2)
    ...     message_alias=HandoverRequestAcknowledge
    ...     flow_alias=${flow_alias}

Verify that XNAP Inter-gNB Handover was completed with success for UE${ue_id}
    Log to console    Verifying that XNAP Inter-gNB Handover was completed with success for UE${ue_id}
    PASS FLOW: gNB3_XN XNAP handoverPreparation,sNStatusTransfer

    ${flow_alias}=      Get Flow Name
    ...     procedure=handoverPreparation,sNStatusTransfer
    ...     device=gNB3_XN

    Verify That Message Fulfills Query
    ...     ((length(pduSessionResourcesToBeSetup-List) eq 2)
    ...     and
    ...     (pduSessionResourcesToBeSetup-List contains ((pduSessionId eq 1) and (fiveQI eq 5)))
    ...     and
    ...     (pduSessionResourcesToBeSetup-List contains ((pduSessionId eq 2) and (fiveQI eq 5))))
    ...     message_alias=HandoverRequest
    ...     flow_alias=${flow_alias}

    Verify That Message Fulfills Query
    ...     (length(PDUSessionResourcesAdmitted-List) eq 2)
    ...     message_alias=HandoverRequestAcknowledge
    ...     flow_alias=${flow_alias}

Verify that Path Switch Request Acknowledge from AMF containing PDUSessionResourceReleasedListPSAck IE with one of established PDU session
    PASS FLOW: AMF1 NGAP pathSwitchRequest

    ${flow_alias}=      Get Flow Name
    ...     procedure=pathSwitchRequest
    ...     device=AMF1

    Verify That Message Fulfills Query
    ...     (length(PDUSessionResourceToBeSwitchedDLList) eq 2)
    ...     message_alias=PathSwitchRequest
    ...     flow_alias=${flow_alias}

    Verify That Message Fulfills Query
    ...     ((length(PDUSessionResourceReleasedListPSAck) eq 1)
    ...     and
    ...     (PDUSessionResourceReleasedListPSAck contains (pDUSessionID eq 2))
    ...     and
    ...     (length(PDUSessionResourceSwitchedList) eq 1))
    ...     message_alias=PathSwitchRequestAcknowledge
    ...     flow_alias=${flow_alias}

Verify that PDU session indicated in Path Switch Request Acknowledge is released
    ${flow_alias}=  Get Flow Name
    ...     RRCReconfiguration
    ...     device=UE_1
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     (length(drb-ToReleaseList) eq 1)
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias}

Verify that XNAP Inter-gNB Handover was completed successfully for UE${ue_id}
    Log to console    Verifying that XNAP Inter-gNB Handover was completed successfully for UE${ue_id}
    PASS FLOW: gNB3_XN XNAP handoverPreparation,sNStatusTransfer
    PASS FLOW: UE_1 NR-RRC RRCReconfigurationComplete
    PASS FLOW: AMF1 NGAP pathSwitchRequest

    ${flow_alias}=  Get Flow Name
    ...     procedure=handoverPreparation,sNStatusTransfer
    ...     device=gNB3_XN

    Verify That Message Fulfills Query
    ...     ((length(pduSessionResourcesToBeSetup-List) eq 2)
    ...     and
    ...     (pduSessionResourcesToBeSetup-List contains ((pduSessionId eq 1) and (fiveQI eq 5)))
    ...     and
    ...     (pduSessionResourcesToBeSetup-List contains ((pduSessionId eq 2) and (fiveQI eq 5))))
    ...     message_alias=HandoverRequest
    ...     flow_alias=${flow_alias}

    Verify That Message Fulfills Query
    ...     (length(PDUSessionResourcesAdmitted-List) eq 2)
    ...     message_alias=HandoverRequestAcknowledge
    ...     flow_alias=${flow_alias}

Verify that XNAP Inter-gNB Handover failed for UE${ue_id}
    PASS FLOW: gNB3_XN XNAP handoverPreparation,sNStatusTransfer
    FAIL FLOW[timeout=15]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    FAIL FLOW[timeout=15]: AMF1 NGAP pathSwitchRequest
    FAIL FLOW[timeout=15]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease

Verify that intra-gNB inter-cell handover execution for UE${ue_id} succeed
    Flow Occurred As Expected  alias=F1AP_modify_UE_${ue_id}
    Flow Occurred As Expected  alias=UE${ue_id}_NR-RRC_Reconf_ho
    Flow Occurred As Expected  alias=UE${ue_id}_NR-RRC_ReconfComplete_ho

    Verify That Message Fulfills Query
    ...     ((reconfigurationWithSync contains (physCellId eq 51))
    ...     and
    ...     (measConfig contains (reportConfigToAddModList contains (eventA3 is present))))
    ...     message_alias=HORRCReconfiguration
    ...     flow_alias=UE${ue_id}_NR-RRC_Reconf_ho

Verify that partial intra-gNB inter-cell handover execution for UE${ue_id} succeed
    Flow Occurred As Expected  alias=F1AP_modify_UE_${ue_id}
    Flow Occurred As Expected  alias=E1AP_bearer_context_modify_UE_${ue_id}
    Flow Occurred As Expected  alias=UE${ue_id}_NR-RRC_Reconf_ho
    Flow Occurred As Expected  alias=UE${ue_id}_NR-RRC_ReconfComplete_ho

    Verify That Message Fulfills Query
    ...     (((reconfigurationWithSync contains (physCellId eq 51))
    ...     and
    ...     (measConfig contains (reportConfigToAddModList contains (eventA3 is present))))
    ...     and
    ...     (length(drb-ToAddModList) eq 2)
    ...     and
    ...     (length(drb-ToReleaseList) eq 1))
    ...     message_alias=HORRCReconfiguration
    ...     flow_alias=UE${ue_id}_NR-RRC_Reconf_ho

Verify that intra-gNB inter-cell handover was not performed due to lack of RRCReconfigurationComple for UE${ue_id}
    Flow Not Occurred For Message    alias=no_UE${ue_id}_NR-RRC_ReconfComplete

Verify that QoS flows were successfully added to PDU1 session for UE${ue_id}
    Flow Occurred As Expected  alias=UE${ue_id}_NGAP_qos_flow_add_succ
    Flow Occurred As Expected  alias=UE${ue_id}_RRC_reconfiguration

    Verify That Message Fulfills Query
    ...     ((QosFlowAddOrModifyRequestList contains (fiveQI eq 1))
    ...     and
    ...     (QosFlowAddOrModifyRequestList contains (priorityLevelARP eq 5)))
    ...     message_alias=PDUSessionResourceModifyRequest
    ...     flow_alias=UE${ue_id}_NGAP_qos_flow_add_succ

    Verify That Message Fulfills Query
    ...     (length(drb-ToAddModList) eq 1)
    ...     message_alias=RRCReconfigurationAddedQosFlow
    ...     flow_alias=UE${ue_id}_RRC_reconfiguration

    Verify That Message Fulfills Query
    ...     (length(qosFlowAddOrModifyResponseList) eq 1)
    ...     message_alias=PDUSessionResourceModifyResponse
    ...     flow_alias=UE${ue_id}_NGAP_qos_flow_add_succ

Verify that NGAP InitialContextSetup contains priorityLevelARP set to emergency for UE${ue_id}
    Verify That Message Fulfills Query
    ...     (QosFlowSetupRequestList contains (priorityLevelARP eq 5))
    ...     message_alias=InitialContextSetupRequest${ue_id}
    ...     flow_alias=UE${ue_id}_NGAP_ICS

UE${ue_id} triggers XNAP Inter-gNB Handover from gNB2 to simulated gNB3
    Execute egate command   cmd=meas_cfg_ue_disp id=${ue_id}
    Execute egate command
    ...     cmd=ue_measurement_send_nr id=${ue_id} meas_id=2 event=A5 srsrp_nr=19 srsrq_nr=10 phycell_id=52 nrsrp_nr=85 nrsrq_nr=31
    ...     pass_regexp=UE${ue_id}: Inter-eNB handover from EXT_ENB-2.1 to ENB-3.1 performed
    Sleep  2
