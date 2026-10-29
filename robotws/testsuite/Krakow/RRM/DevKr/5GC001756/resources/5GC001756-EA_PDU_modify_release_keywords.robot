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
Modify QoS Flow for UE${ue_id}
    Execute egate command   cmd=qosflow_modify qos_flow=1 mfbr_dl=100 mfbr_ul=100

Modify existed QoS Flow for UE${ue_id} PDU1 session
    Execute egate command   cmd=qosflow_modify qos_flow=1 mfbr_dl=300 mfbr_ul=300
    Sleep  3
    Execute egate command   cmd=ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_modify=1 by=amf

Prepare test environment EA1
    ${pcmd}    Get variable value      ${pcmd}    "True"
    Run Keyword if  ${pcmd} != "False"
    ...         Start PCMD message collection
    ${ue_capa_c2}=    Set Variable   01A883321A000000109800800C4DAA2FFCBFF0110389A00000010010135378000000000000115000000000000015000001002004088A00
    Execute egate command
    ...     cmd=ics_amf_ue_param id=1-2 include_ue_capabilities=yes ue_capabilities=${ue_capa_c2}
    Execute egate command   cmd=ue_nr_rrc_reconf_param id=1 if_contains=any nth=2 action=drop

Cleanup after test EA1
    ${pcmd}    Get variable value      ${pcmd}    "True"
    Run Keyword if  ${pcmd} != "False"
    ...         Stop PCMD message collection
    Run keyword and ignore error    Detach UE1
    Run keyword and ignore error    Detach idle UE1
    Run keyword and ignore error    Detach UE2
    Run keyword and ignore error    Detach idle UE2
    Execute egate command   cmd=ics_amf_ue_param id=1-2 include_ue_capabilities=no
    Reset PCMD database
    Execute egate command   cmd=ue_nr_rrc_reconf_param id=1 if_contains=any nth=2 action=none

Prepare test environment EA2
    Modify QoS Flow for UE1

    ${pcmd}    Get variable value      ${pcmd}    "True"
    Run Keyword if  ${pcmd} != "False"
    ...         Start PCMD message collection
    ${ue_capa_c2}=    Set Variable   01A883321A000000109800800C4DAA2FFCBFF0110389A00000010010135378000000000000115000000000000015000001002004088A00
    Execute egate command
    ...     cmd=ics_amf_ue_param id=1-2 include_ue_capabilities=yes ue_capabilities=${ue_capa_c2}

Cleanup after test EA2
    ${pcmd}    Get variable value      ${pcmd}    "True"
    Run Keyword if  ${pcmd} != "False"
    ...         Stop PCMD message collection
    Run keyword and ignore error    Detach UE1
    Run keyword and ignore error    Detach idle UE1
    Execute egate command   cmd=ics_amf_ue_param id=1-2 include_ue_capabilities=no
    Reset PCMD database
    Execute egate command   cmd=ue_nr_rrc_reconf_param id=1 if_contains=any nth=1 action=none

Prepare test environment EA3
    ${pcmd}    Get variable value      ${pcmd}    "True"
    Run Keyword if  ${pcmd} != "False"
    ...         Start PCMD message collection
    ${ue_capa_c2}=    Set Variable   01A883321A000000109800800C4DAA2FFCBFF0110389A00000010010135378000000000000115000000000000015000001002004088A00
    Execute egate command
    ...     cmd=ics_amf_ue_param id=1-2 include_ue_capabilities=yes ue_capabilities=${ue_capa_c2}

Cleanup after test EA3
    ${pcmd}    Get variable value      ${pcmd}    "True"
    Run Keyword if  ${pcmd} != "False"
    ...         Stop PCMD message collection
    Run keyword and ignore error    Detach UE1
    Run keyword and ignore error    Detach idle UE1
    Execute egate command   cmd=ics_amf_ue_param id=1-2 include_ue_capabilities=no
    Execute egate command   cmd=ue_nr_rrc_reconf_param id=1 if_contains=any nth=1 action=none
    Reset PCMD database

Prepare test environment EA4
    ${pcmd}    Get variable value      ${pcmd}    "True"
    Run Keyword if  ${pcmd} != "False"
    ...     Start PCMD message collection
    ${ue_capa_c2}=    Set Variable   01A883321A000000109800800C4DAA2FFCBFF0110389A00000010010135378000000000000115000000000000015000001002004088A00
    Execute egate command
    ...     cmd=ics_amf_ue_param id=1-2 include_ue_capabilities=yes ue_capabilities=${ue_capa_c2}

Cleanup after test EA4
    ${pcmd}    Get variable value      ${pcmd}    "True"
    Run Keyword if  ${pcmd} != "False"
    ...         Stop PCMD message collection
    Run keyword and ignore error    Detach UE1
    Run keyword and ignore error    Detach idle UE1
    Execute egate command   cmd=ics_amf_ue_param id=1-2 include_ue_capabilities=no
    Reset PCMD database

Prepare test environment EA5
    ${pcmd}    Get variable value      ${pcmd}    "True"
    Run Keyword if  ${pcmd} != "False"
    ...     Start PCMD message collection
    ${ue_capa_c2}=    Set Variable   01A883321A000000109800800C4DAA2FFCBFF0110389A00000010010135378000000000000115000000000000015000001002004088A00
    Execute egate command
    ...     cmd=ics_amf_ue_param id=1-2 include_ue_capabilities=yes ue_capabilities=${ue_capa_c2}
    Modify QoS Flow for UE1
    Configure   [{'MOC': 'NRBTS', 'ID': '1', 'rrcReestabTypeSA': 'sameGNB'}]
    Configure
    ...         config=${CURDIR}/../config/yaml_config/admission_control_parameters.yaml
    ...         name=admission_control
    Enable internal mirroring for alias     gNB2

Cleanup after test EA5
    ${pcmd}    Get variable value      ${pcmd}    "True"
    Run Keyword if  ${pcmd} != "False"
    ...         Stop PCMD message collection
    Run keyword and ignore error    Detach UE1
    Run keyword and ignore error    Detach idle UE1
    Run keyword and ignore error    Kill UE1
    Execute egate command   cmd=ics_amf_ue_param id=1-2 include_ue_capabilities=no
    Execute egate command   cmd=ue_nr_rrc_reconf_param id=1 if_contains=any action=none
    Reset PCMD database
    Deconfigure     name=admission_control
#    Configure   [{'MOC': 'NRBTS', 'ID': '1', 'rrcReestabTypeSA': 'deactivated'}]

Cleanup after test EA
    ${pcmd}    Get variable value      ${pcmd}    "True"
    Run Keyword if  ${pcmd} != "False"
    ...         Stop PCMD message collection
    Run keyword and ignore error    Detach UE1
    Run keyword and ignore error    Detach idle UE1
    Reset PCMD database

Verify that PDU session was not successfully modify for UE${ue_id} due to reestablishment
    ${pdu_modify}=  Get Flow Name
    ...         procedure=pDUSessionResourceModify
    ...         device=AMF1

    ${rrc_reconfig}=  Get Flow Name
    ...         RRCReconfiguration
    ...         device=UE_${ue_id}
    ...         protocol=NR-RRC

    ${rrc_reestab}=  Get Flow Name
    ...         RRCReestablishmentRequest
    ...         device=UE_${ue_id}
    ...         protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     ((PDUSessionResourceModifyListModReq contains (pDUSessionID eq 1))
    ...     and
    ...     (length(QosFlowListWithCause) eq 1))
    ...     message_alias=PDUSessionResourceModifyRequest
    ...     flow_alias=${pdu_modify}

    Verify That Message Fulfills Query
    ...     (length(drb-ToReleaseList) eq 1)
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${rrc_reconfig}

    Verify That Message Fulfills Query
    ...     (reestablishmentCause eq "reconfigurationFailure")
    ...     message_alias=RRCReestablishmentRequest
    ...     flow_alias=${rrc_reestab}

    Verify That Message Fulfills Query
    ...     ((length(PDUSessionResourceFailedToModifyListModRes) eq 1)
    ...     and
    ...     (PDUSessionResourceFailedToModifyListModRes contains (pDUSessionID eq 1))
    ...     and
    ...     (pDUSessionResourceModifyUnsuccessfulTransfer contains (radioNetwork eq "radio-connection-with-ue-lost")))
    ...     message_alias=PDUSessionResourceModifyResponse
    ...     flow_alias=${pdu_modify}

Verify that QoS flow was successfully added to multiple PDU sessions for UE${ue_id}
    ${ngap_flow}=   Get Flow Name
    ...     procedure=pDUSessionResourceModify
    ...     device=AMF1

    ${rrc_flow}=   Get Flow Name
    ...     RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     ((PDUSessionResourceModifyListModReq contains (pDUSessionID eq 1))
    ...     and
    ...     (QosFlowAddOrModifyRequestList contains (fiveQI eq 1))
    ...     and
    ...     (PDUSessionResourceModifyListModReq contains (pDUSessionID eq 2))
    ...     and
    ...     (QosFlowAddOrModifyRequestList contains (fiveQI eq 9)))
    ...     message_alias=PDUSessionResourceModifyRequest
    ...     flow_alias=${ngap_flow}

    Verify That Message Fulfills Query
    ...     ((length(drb-ToAddModList) eq 2)
    ...     and
    ...     (drb-ToAddModList contains (pdu-Session eq 1))
    ...     and
    ...     (drb-ToAddModList contains (pdu-Session eq 2)))
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${rrc_flow}

    Verify That Message Fulfills Query
    ...     (length(PDUSessionResourceModifyListModRes) eq 2)
    ...     message_alias=PDUSessionResourceModifyResponse
    ...     flow_alias=${ngap_flow}

Verify that QoS flow was successfully added and deleted to multiple PDU sessions for UE${ue_id}
     ${ngap_flow}=   Get Flow Name
    ...     procedure=pDUSessionResourceModify
    ...     device=AMF1

    ${rrc_flow}=   Get Flow Name
    ...     RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     ((PDUSessionResourceModifyListModReq contains (pDUSessionID eq 1))
    ...     and
    ...     (QosFlowAddOrModifyRequestList contains (fiveQI eq 9))
    ...     and
    ...     (PDUSessionResourceModifyListModReq contains (pDUSessionID eq 2))
    ...     and
    ...     (length(QosFlowListWithCause) eq 1))
    ...     message_alias=PDUSessionResourceModifyRequest
    ...     flow_alias=${ngap_flow}

    Verify That Message Fulfills Query
    ...     ((length(drb-ToAddModList) eq 1)
    ...     and
    ...     (drb-ToAddModList contains (pdu-Session eq 1))
    ...     and
    ...     (length(drb-ToReleaseList) eq 1))
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${rrc_flow}

    Verify That Message Fulfills Query
    ...     (length(PDUSessionResourceModifyListModRes) eq 2)
    ...     message_alias=PDUSessionResourceModifyResponse
    ...     flow_alias=${ngap_flow}

Verify in NGAP that GBR QoS flow was unsuccessfully added to existed PDU session for UE${ue_id} due to lack of RRC: Reconfiguration Complete
    ${flow}=    Get Flow Name
    ...     procedure=pDUSessionResourceModify
    ...     device=AMF1

    Verify That Message Fulfills Query
    ...     (QosFlowAddOrModifyRequestList contains (fiveQI eq 2))
    ...     message_alias=PDUSessionResourceModifyRequest
    ...     flow_alias=${flow}

     Verify That Message Fulfills Query
    ...     (radioNetwork eq "radio-connection-with-ue-lost")
    ...     message_alias=PDUSessionResourceModifyResponse
    ...     flow_alias=${flow}

Verify that modification of PDU session was rejected with cause radioNetwork: radio-resources-not-available for UE${ue_id}
    Verify That Message Fulfills Query
    ...     (radioNetwork contains (radio-resources-not-available))
    ...     message_alias=PDUSessionResourceModifyResponse
    ...     flow_alias=UE${ue_id}_NGAP_qos_flow_add_failure

Verify in NGAP that ${num:\d+} QoS flows were successfully added to existed PDU session for UE${ue_id}
    ${flow}=    Get Flow Name
    ...     procedure=pDUSessionResourceModify
    ...     device=AMF1

    Verify That Message Fulfills Query
    ...     ((QosFlowAddOrModifyRequestList contains (fiveQI eq 8))
    ...     and
    ...     (QosFlowAddOrModifyRequestList contains (fiveQI eq 9)))
    ...     message_alias=PDUSessionResourceModifyRequest
    ...     flow_alias=${flow}

    Verify That Message Fulfills Query
    ...     (length(qosFlowAddOrModifyResponseList) eq 2)
    ...     message_alias=PDUSessionResourceModifyResponse
    ...     flow_alias=${flow}

Verify in NGAP that ${num:\d+} QoS flows were successfully deleted from existed PDU session for UE${ue_id}
    ${flow}=    Get Flow Name
    ...     procedure=pDUSessionResourceModify
    ...     device=AMF1

    Verify That Message Fulfills Query
    ...     (length(QosFlowListWithCause) eq 2)
    ...     message_alias=PDUSessionResourceModifyRequest
    ...     flow_alias=${flow}

    Verify That Message Fulfills Query
    ...     (length(PDUSessionResourceModifyListModRes) eq 1)
    ...     message_alias=PDUSessionResourceModifyResponse
    ...     flow_alias=${flow}

Verify in NGAP that ${n_add} QoS flows were added and ${n_del} deleted from existed PDU session for UE${ue_id}
    ${flow}=    Get Flow Name
    ...     procedure=pDUSessionResourceModify
    ...     device=AMF1

    Verify That Message Fulfills Query
    ...     ((QosFlowAddOrModifyRequestList contains (fiveQI eq 1))
    ...     and
    ...     (QosFlowAddOrModifyRequestList contains (fiveQI eq 2))
    ...     and
    ...     (length(QosFlowListWithCause) eq ${n_del}))
    ...     message_alias=PDUSessionResourceModifyRequest
    ...     flow_alias=${flow}

    Verify That Message Fulfills Query
    ...     ((length(PDUSessionResourceModifyListModRes) eq 1)
    ...     and
    ...     (length(qosFlowAddOrModifyResponseList) eq ${n_add}))
    ...     message_alias=PDUSessionResourceModifyResponse
    ...     flow_alias=${flow}

Verify in NGAP that GBR QoS flow was successfully added to existed PDU session for UE${ue_id}
    ${flow}=    Get Flow Name
    ...     procedure=pDUSessionResourceModify
    ...     device=AMF1

    Verify That Message Fulfills Query
    ...     ((QosFlowAddOrModifyRequestList contains (fiveQI eq 1))
    ...     and
    ...     (QosFlowAddOrModifyRequestList contains (maximumFlowBitRateDL eq 100000))
    ...     and
    ...     (QosFlowAddOrModifyRequestList contains (maximumFlowBitRateDL eq 100000)))
    ...     message_alias=PDUSessionResourceModifyRequest
    ...     flow_alias=${flow}

    Verify That Message Fulfills Query
    ...     (length(qosFlowAddOrModifyResponseList) eq 1)
    ...     message_alias=PDUSessionResourceModifyResponse
    ...     flow_alias=${flow}

Verify in NGAP that ${num:\d+} QoS flow was successfully added to existed PDU session for UE${ue_id}
    ${flow}=        Get Flow Name
    ...     procedure=pDUSessionResourceModify
    ...     device=AMF1

    Verify That Message Fulfills Query
    ...     (QosFlowAddOrModifyRequestList contains (fiveQI eq 8))
    ...     message_alias=PDUSessionResourceModifyRequest
    ...     flow_alias=${flow}

    Verify That Message Fulfills Query
    ...     (length(qosFlowAddOrModifyResponseList) eq 1)
    ...     message_alias=PDUSessionResourceModifyResponse
    ...     flow_alias=${flow}

Verify in NGAP that QoS flow was successfully modified for UE${ue_id}
    ${flow}=    Get Flow Name
    ...     procedure=pDUSessionResourceModify
    ...     device=AMF1

    Verify That Message Fulfills Query
    ...     ((QosFlowAddOrModifyRequestList contains (fiveQI eq 1))
    ...     and
    ...     (QosFlowAddOrModifyRequestList contains (maximumFlowBitRateDL eq 300000))
    ...     and
    ...     (QosFlowAddOrModifyRequestList contains (maximumFlowBitRateDL eq 300000)))
    ...     message_alias=PDUSessionResourceModifyRequest
    ...     flow_alias=${flow}

    Verify That Message Fulfills Query
    ...     (length(qosFlowAddOrModifyResponseList) eq 1)
    ...     message_alias=PDUSessionResourceModifyResponse
    ...     flow_alias=${flow}
