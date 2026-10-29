*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == AUTHORS C-PLANE ==
...      - Dawid Krawczuk <dawid.krawczuk@nokia.com>
...      - Tomasz Pyrek <tomasz.pyrek@nokia.com>
...      - Michal Szymakowski <michal.szymakowski@nokia.com>
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

Resource    ./5GC001756-common_keywords.robot
Library     amf_verifier.py

*** Keywords ***
Prepare test environment EA1
    ${pcmd}    Get variable value      ${pcmd}    "True"
    Run Keyword if  ${pcmd} != "False"
    ...     Start PCMD message collection
    Sleep  10
    ${ue_capa_c2}=    Set Variable   01A883321A000000109800800C4DAA2FFCBFF0110389A00000010010135378000000000000115000000000000015000001002004088A00
    Execute egate command
    ...     cmd=ics_amf_ue_param id=1-2 include_ue_capabilities=yes ue_capabilities=${ue_capa_c2}
    Sleep  2

    Attach UE2 to cell1 gNB2

Cleanup after test EA1
    ${pcmd}    Get variable value      ${pcmd}    "True"
    Run Keyword if  ${pcmd} != "False"
    ...         Stop PCMD message collection
    Run keyword and ignore error    Detach UE1
    Run keyword and ignore error    Detach idle UE1
    Run keyword and ignore error    Execute egate command   cmd=ue_change_location id=1 enb=2 cell=1
    Run keyword and ignore error    Detach UE2
    Run keyword and ignore error    Detach idle UE2
    Run keyword and ignore error    Execute egate command   cmd=ue_change_location id=2 enb=2 cell=1
    Execute egate command   cmd=ics_amf_ue_param id=1-2 include_ue_capabilities=no
    Reset PCMD database

    Configure   ${CURDIR}/../config/yaml_config/unlock_amf1_link.yaml
    Sleep  10

Prepare test environment EA2
    ${pcmd}    Get variable value      ${pcmd}    "True"
    Run Keyword if  ${pcmd} != "False"
    ...     Start PCMD message collection
    Sleep  10
    ${ue_capa_c2}=    Set Variable   01A883321A000000109800800C4DAA2FFCBFF0110389A00000010010135378000000000000115000000000000015000001002004088A00
    Execute egate command
    ...     cmd=ics_amf_ue_param id=1-2 include_ue_capabilities=yes ue_capabilities=${ue_capa_c2}

    Configure   ${CURDIR}/../config/yaml_config/lock_amf2_link.yaml
    Sleep  10

    Attach UE2 to cell1 gNB2

Cleanup after test EA2
    ${pcmd}    Get variable value      ${pcmd}    "True"
    Run Keyword if  ${pcmd} != "False"
    ...         Stop PCMD message collection
    Run keyword and ignore error    Detach UE1
    Run keyword and ignore error    Detach idle UE1
    Run keyword and ignore error    Execute egate command   cmd=ue_change_location id=1 enb=2 cell=1
    Run keyword and ignore error    Detach UE2
    Run keyword and ignore error    Detach idle UE2
    Run keyword and ignore error    Execute egate command   cmd=ue_change_location id=2 enb=2 cell=1
    Execute egate command   cmd=ics_amf_ue_param id=1-2 include_ue_capabilities=no
    Reset PCMD database

Verify that NGAP InitialContextSetupRequest contains GUAMI assosiated with AMF2 for UE${ue_id}
    Get amf guami
    ...     flow_alias=UE1_NGAP_ICS
    ...     message_alias=InitialContextSetupRequest

Lock NG-C link with AMF1
    Configure   ${CURDIR}/../config/yaml_config/lock_amf1_link.yaml
    Sleep  10

Set expected call flow for unsuccessful AMF reselection for UE${ue_id}
    Expect Message Flow
    ...     UE_${ue_id}:NR-RRC_ULInformationTransfer
    ...     alias=UE${ue_id}_RRC_UlInfoTransfer  overall_timeout=15

    Expect Message Will Not Occur
    ...     AMF2:NGAP_UEContextModificationRequest
    ...     alias=no_UEContextModificationRequest  overall_timeout=10

    Expect Message Will Not Occur
    ...     AMF2:NGAP_PDUSessionResourceModifyRequest
    ...     alias=no_PDUSessionResourceModifyRequest  overall_timeout=10

    Expect Message Will Not Occur
    ...     UE_${ue_id}:NR-RRC_RRCReconfiguration
    ...     alias=no_RRC_reconfiguration_amf_reselection  overall_timeout=10

Set expected call flow for successful AMF reselection for UE${ue_id}
    Expect Message Flow
    ...     UE_${ue_id}:NR-RRC_ULInformationTransfer
    ...     alias=UE${ue_id}_RRC_UlInfoTransfer  overall_timeout=15

    Expect Message Flow
    ...     AMF2:NGAP_UplinkNASTransport (save_pcmd_selected_value) as UlNASTransport
    ...     alias=UE${ue_id}_UL_NAS  overall_timeout=15

    Expect Message Flow
    ...     AMF2:NGAP_UEContextModificationRequest as UECtxModifyReq1
    ...     AMF2:NGAP_UEContextModificationResponse as UECtxModifyResp1
    ...     alias=UE${ue_id}_NGAP_UEContextModificationRequest1  overall_timeout=10

    Expect Message Flow
    ...     AMF2:NGAP_UEContextModificationRequest as UECtxModifyReq2
    ...     AMF2:NGAP_UEContextModificationResponse (save_pcmd_selected_value) as UECtxModifyResp2
    ...     alias=UE${ue_id}_NGAP_UEContextModificationRequest2  overall_timeout=10

    Expect Message Flow
    ...     AMF2:NGAP_PDUSessionResourceModifyRequest as PDUSessionResourceModifyRequest
    ...     AMF2:NGAP_PDUSessionResourceModifyResponse as PDUSessionResourceModifyResponse
    ...     alias=UE${ue_id}_NGAP_amf_reselection  overall_timeout=10

    Expect Message Flow
    ...     UE_${ue_id}:NR-RRC_RRCReconfiguration as RRCReconfigurationQosAdded
    ...     UE_${ue_id}:NR-RRC_RRCReconfigurationComplete
    ...     alias=UE${ue_id}_RRC_reconfiguration_amf_reselection  overall_timeout=10

Trigger UE${ue_id} to perform PDU1 session modification by adding QoS flow with 5QI-${5qi}
    5GC001756-common_keywords.Add to UE${ue_id} PDU1 session QoS flows with 5QI from list [${5qi}] and delete QoS flows with 5QI from list []

Verify that backup AMF2 is not reselected for UE${ue_id}
    Flow Occurred As Expected       alias=UE${ue_id}_RRC_UlInfoTransfer
    Flow Not Occurred For Message   alias=no_UEContextModificationRequest
    Flow Not Occurred For Message   alias=no_PDUSessionResourceModifyRequest
    Flow Not Occurred For Message   alias=no_RRC_reconfiguration_amf_reselection

Verify that backup AMF2 is reselected successfully for UE${ue_id}
    Flow Occurred As Expected   alias=UE${ue_id}_RRC_UlInfoTransfer
    Flow Occurred As Expected   alias=UE${ue_id}_UL_NAS
    Flow Occurred As Expected   alias=UE${ue_id}_NGAP_UEContextModificationRequest1
    Flow Occurred As Expected   alias=UE${ue_id}_NGAP_UEContextModificationRequest2

Verify that second NGAP UEContextModificationRequest message contains new GUAMI
    Verify difference of two amf guami
    ...     flow_alias_amf1=UE1_NGAP_ICS
    ...     flow_alias_amf2=UE1_NGAP_UEContextModificationRequest2
    ...     msg_alias_amf1=InitialContextSetupRequest
    ...     msg_alias_amf2=UECtxModifyReq2

Verify that QoS flow was successfully added for UE${ue_id} after AMF reselection
    Flow Occurred As Expected   alias=UE${ue_id}_RRC_reconfiguration_amf_reselection
    Flow Occurred As Expected   alias=UE${ue_id}_NGAP_amf_reselection

    Verify That Message Fulfills Query
    ...     ((PDUSessionResourceModifyListModReq contains (pDUSessionID eq 1))
    ...     and
    ...     (QosFlowAddOrModifyRequestList contains (fiveQI eq 9)))
    ...     message_alias=PDUSessionResourceModifyRequest
    ...     flow_alias=UE${ue_id}_NGAP_amf_reselection

    Verify That Message Fulfills Query
    ...     (length(PDUSessionResourceModifyListModRes) eq 1)
    ...     message_alias=PDUSessionResourceModifyResponse
    ...     flow_alias=UE${ue_id}_NGAP_amf_reselection

    Verify That Message Fulfills Query
    ...     ((length(drb-ToAddModList) eq 1)
    ...     and
    ...     (drb-ToAddModList contains (pdu-Session eq 1)))
    ...     message_alias=RRCReconfigurationQosAdded
    ...     flow_alias=UE${ue_id}_RRC_reconfiguration_amf_reselection
