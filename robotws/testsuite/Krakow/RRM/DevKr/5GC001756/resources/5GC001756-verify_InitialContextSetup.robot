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
Verify that AMF${amf_id:\d+} InitialContextSetupRequest contains UERadioCapability
    ${flow}=      Get Flow Name
    ...     procedure=initialContextSetup
    ...     device=AMF${amf_id}

    Verify That Message Fulfills Query
    ...     (UERadioCapability is present)
    ...     message_alias=InitialContextSetupRequest
    ...     flow_alias=${flow}

Verify during initialContextSetup that AMF${amf_id:\d+} ${session_type:(initial|second|third)} PDU session with one QoS flow was added successfully
    ${flow_alias_ngap}=     Get Flow Name
    ...     procedure=initialContextSetup
    ...     device=AMF${amf_id}

    Verify That Message Fulfills Query
    ...     ((length(PDUSessionResourceSetupListCxtReq) eq 1)
    ...     and
    ...     (length(QosFlowSetupRequestList) eq 1))
    ...     message_alias=InitialContextSetupRequest
    ...     flow_alias=${flow_alias_ngap}

    Verify That Message Fulfills Query
    ...     ((length(PDUSessionResourceSetupListCxtRes) eq 1)
    ...     and
    ...     (length(associatedQosFlowList) eq 1))
    ...     message_alias=InitialContextSetupResponse
    ...     flow_alias=${flow_alias_ngap}

Verify during ${procedure} AMF${amf_id:\d+} NGAP ICS contains Emergency Fallback Indicator IE
    ${flow}=      Get Flow Name
    ...     procedure=${procedure}
    ...     device=AMF${amf_id}

    Verify That Message Fulfills Query
    ...     (emergencyFallbackRequestIndicator eq "emergency-fallback-requested")
    ...     message_alias=InitialContextSetupRequest
    ...     flow_alias=${flow}

Verify that for AMF${amf_id:\d+} in InitialContextSetupResponse 1 QoS flow for first PDU session and 2 QoS flows for second PDU session were created
    ${flow}=      Get Flow Name
    ...     procedure=initialContextSetup
    ...     device=AMF${amf_id}
    Verify That Message Fulfills Query
    ...     ((length(PDUSessionResourceSetupListCxtRes) eq 2)
    ...     and
    ...     (PDUSessionResourceSetupListCxtRes contains
    ...     ((associatedQosFlowList contains ((qosFlowIdentifier eq 1), (qosFlowIdentifier eq 2))),
    ...     (associatedQosFlowList contains (qosFlowIdentifier eq 1)))))
    ...     message_alias=InitialContextSetupResponse
    ...     flow_alias=${flow}

Verify that AMF${amf_id:\d+} InitialContextSetupFailure is sent with Radio Network Layer cause: Unspecified
    ${flow}=      Get Flow Name
    ...     procedure=initialContextSetupFailure
    ...     device=AMF${amf_id}
    Verify That Message Fulfills Query
    ...     (PDUSessionResourceFailedToSetupListCxtFail contains (radioNetwork eq "unspecified"))
    ...     message_alias=InitialContextSetupFailure
    ...     flow_alias=${flow}

Verify that AMF${amf_id:\d+} NGAP InitialContextSetupFailure contains cause: radioNetwork failure-in-radio-interface-procedure
    ${flow}=      Get Flow Name
    ...     procedure=initialContextSetupFailure
    ...     device=AMF${amf_id}
    Verify That Message Fulfills Query
    ...     (PDUSessionResourceFailedToSetupListCxtFail contains (radioNetwork eq "failure-in-radio-interface-procedure"))
    ...     message_alias=InitialContextSetupFailure
    ...     flow_alias=${flow}

Verify during ICS that AMF${amf_id:\d+} ${session_type:(initial|second|third)} PDU session with one QoS flow was added successfully
    ${flow_alias_ngap}=     Get Flow Name
    ...     procedure=initialContextSetup
    ...     device=AMF${amf_id}

    Verify That Message Fulfills Query
    ...     ((length(PDUSessionResourceSetupListCxtReq) eq 1)
    ...     and
    ...     (length(QosFlowSetupRequestList) eq 1))
    ...     message_alias=InitialContextSetupRequest
    ...     flow_alias=${flow_alias_ngap}

    Verify That Message Fulfills Query
    ...     ((length(PDUSessionResourceSetupListCxtRes) eq 1)
    ...     and
    ...     (length(associatedQosFlowList) eq 1))
    ...     message_alias=InitialContextSetupResponse
    ...     flow_alias=${flow_alias_ngap}
