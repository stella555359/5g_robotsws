*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == AUTHORS C-PLANE ==
...      - Dawid Krawczuk <dawid.krawczuk@nokia.com>
...      - Cezary Dudek <cezary.dudek@nokia.com>
...      - Marek Kieltyka <marek.kieltyka@nokia.com>
...      - Tomasz Pyrek <michal.szymakowski@nokia.com>
...      - Karolina Sroczyk <karolina.sroczyk@nokia.com>
...      - Gabriela Stasiuk <gabriela.stasiuk@nokia.com>
...      - Michal Szymakowski <michal.szymakowski@nokia.com>
...      - Grzegorz Szymik <grzegorz.szymik@nokia.com>
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

Resource    CB008379-common_keywords.robot


*** Keywords ***
Verify that AMF${amf_id:\d+} NGAP InitialContextSetup contains ${pdu_count} PDU sessions
    ${flow_alias}=  get flow name
    ...     procedure=initialContextSetup
    ...     device=AMF${amf_id}

    Verify That Message Fulfills Query
    ...     (length(PDUSessionResourceSetupListCxtReq) eq ${pdu_count})
    ...     message_alias=InitialContextSetupRequest
    ...     flow_alias=${flow_alias}

    Verify That Message Fulfills Query
    ...     (length(PDUSessionResourceSetupListCxtRes) eq ${pdu_count})
    ...     message_alias=InitialContextSetupResponse
    ...     flow_alias=${flow_alias}


Verify that UE${ue_id:\d+} attach with ${num:\d+} PDU session 5QI${5qi_id:\d+} QoS flow was completed successfully
    ${flow}=    Get flow name
    ...     procedure=initialContextSetup
    ...     device=AMF1

    Verify That Message Fulfills Query
    ...     (QosFlowSetupRequestList contains (fiveQI eq ${5qi_id}))
#    ...     and
#    ...     (QosFlowSetupRequestList contains (maximumFlowBitRateDL eq 100000))
#    ...     and
#    ...     (QosFlowSetupRequestList contains (maximumFlowBitRateDL eq 100000)))
    ...     message_alias=InitialContextSetupRequest
    ...     flow_alias=${flow}

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

    Verify That Message Fulfills Query
    ...     length(associatedQosFlowList) eq 1
    ...     message_alias=InitialContextSetupResponse
    ...     flow_alias=${flow}

Verify that UE${ue_id:\d+} attach with setup default 1 nonGBR and 1 GBR 5QI${5qi_id:\d+} QoS flow was completed successfully
    ${flow}=    Get flow name
    ...     procedure=initialContextSetup
    ...     device=AMF1

    Verify That Message Fulfills Query
    ...     ((QosFlowSetupRequestList contains (fiveQI eq ${5qi_id}))
    ...     and
    ...     (QosFlowSetupRequestList contains (fiveQI eq 5)))
#    ...     (QosFlowSetupRequestList contains (maximumFlowBitRateDL eq 100000))
#    ...     and
#    ...     (QosFlowSetupRequestList contains (maximumFlowBitRateDL eq 100000)))
    ...     message_alias=InitialContextSetupRequest
    ...     flow_alias=${flow}

    Verify number of elements on the list within NGAP message
    ...     amf_id=1
    ...     procedure_name=initialContextSetup
    ...     message=InitialContextSetupRequest
    ...     list_name=PDUSessionResourceSetupListCxtReq
    ...     element_num=1

    Verify number of elements on the list within NGAP message
    ...     amf_id=1
    ...     procedure_name=initialContextSetup
    ...     message=InitialContextSetupResponse
    ...     list_name=PDUSessionResourceSetupListCxtRes
    ...     element_num=1

    Verify That Message Fulfills Query
    ...     length(associatedQosFlowList) eq 2
    ...     message_alias=InitialContextSetupResponse
    ...     flow_alias=${flow}

Verify that UE${ue_id:\d+} attach with setup default 1 nonGBR, 1 GBR VoNR and 1 GBR 5QI${5qi_id:\d+} QoS flow was completed successfully
    ${flow}=    Get flow name
    ...     procedure=initialContextSetup
    ...     device=AMF1

    Verify That Message Fulfills Query
    ...     ((QosFlowSetupRequestList contains (fiveQI eq 1))
    ...     and
    ...     (QosFlowSetupRequestList contains (fiveQI eq 5))
    ...     and
    ...     (QosFlowSetupRequestList contains (fiveQI eq ${5qi_id})))
#    ...     (QosFlowSetupRequestList contains (maximumFlowBitRateDL eq 100000))
#    ...     and
#    ...     (QosFlowSetupRequestList contains (maximumFlowBitRateDL eq 100000)))
    ...     message_alias=InitialContextSetupRequest
    ...     flow_alias=${flow}

    Verify number of elements on the list within NGAP message
    ...     amf_id=1
    ...     procedure_name=initialContextSetup
    ...     message=InitialContextSetupRequest
    ...     list_name=PDUSessionResourceSetupListCxtReq
    ...     element_num=1

    Verify number of elements on the list within NGAP message
    ...     amf_id=1
    ...     procedure_name=initialContextSetup
    ...     message=InitialContextSetupResponse
    ...     list_name=PDUSessionResourceSetupListCxtRes
    ...     element_num=1

    Verify That Message Fulfills Query
    ...     length(associatedQosFlowList) eq 3
    ...     message_alias=InitialContextSetupResponse
    ...     flow_alias=${flow}

Verify that AMF${amf_id:\d+} NGAP InitialContextSetup does contain 1 PDU session and 2 QoS flows
    ${flow_alias}=  get flow name
    ...     procedure=initialContextSetup
    ...     device=AMF${amf_id}

    Verify That Message Fulfills Query
    ...     ((length(PDUSessionResourceSetupListCxtReq) eq 1)
    ...     and
    ...     (length(QosFlowSetupRequestList) eq 2))
    ...     message_alias=InitialContextSetupRequest
    ...     flow_alias=${flow_alias}

    Verify That Message Fulfills Query
    ...     ((length(PDUSessionResourceSetupListCxtRes) eq 1)
    ...     and
    ...     (length(associatedQosFlowList) eq 2))
    ...     message_alias=InitialContextSetupResponse
    ...     flow_alias=${flow_alias}

Verify that AMF${amf_id:\d+} NGAP InitialContextSetup is rejected due to cause ${cause}
    ${flow_alias}=  get flow name
    ...     procedure=initialContextSetupFailure
    ...     device=AMF${amf_id}

    Verify That Message Fulfills Query
    ...     (Cause is present)
    ...     message_alias=InitialContextSetupFailure
    ...     flow_alias=${flow_alias}

    Verify That Message Fulfills Query
    ...     (Cause contains (radioNetwork eq ${cause}))
    ...     message_alias=InitialContextSetupFailure
    ...     flow_alias=${flow_alias}

Verify that Establishment Cause IE set to emergency for UE${ue_id:\d+}
    ${flow_alias}=      Get Flow Name
    ...     procedure=initialUEMessage
    ...     device=AMF1

    Verify That Message Fulfills Query
    ...     (RRCEstablishmentCause eq 'emergency')
    ...     message_alias=InitialUEMessage
    ...     flow_alias=${flow_alias}
