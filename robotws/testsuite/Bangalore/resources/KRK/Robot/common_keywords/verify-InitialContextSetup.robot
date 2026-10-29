*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

*** Keywords ***
Verify that AMF${amf_id:\d+} NGAP InitialContextSetup does not contain any PDU session
    ${flow_alias}=  get flow name
    ...     procedure=initialContextSetup
    ...     device=AMF${amf_id}

    Verify That Message Fulfills Query
    ...     (PDUSessionResourceSetupListCxtReq is not present)
    ...     message_alias=InitialContextSetupRequest
    ...     flow_alias=${flow_alias}

    Verify That Message Fulfills Query
    ...     (PDUSessionResourceSetupListCxtRes is not present)
    ...     message_alias=InitialContextSetupResponse
    ...     flow_alias=${flow_alias}

Verify that AMF${amf_id:\d+} NGAP InitialContextSetup does not contain UERadioCapability
    ${flow_alias}=    Get flow name
    ...     procedure=initialContextSetup
    ...     device=AMF${amf_id}

    Verify That Message Fulfills Query
    ...     (UERadioCapability is not present)
    ...     message_alias=InitialContextSetupRequest
    ...     flow_alias=${flow_alias}

Verify that AMF${amf_id:\d+} NGAP InitialContextSetup contains UERadioCapability
    ${flow_alias}=    Get flow name
    ...     procedure=initialContextSetup
    ...     device=AMF${amf_id}

    Verify That Message Fulfills Query
    ...     (UERadioCapability is present)
    ...     message_alias=InitialContextSetupRequest
    ...     flow_alias=${flow_alias}

Verify that AMF${amf_id:\d+} UEContextReleaseRequest contains cause=${rnl_cause}
    ${flow}=      Get Flow Name
    ...     procedure=uEContextReleaseRequest,uEContextRelease
    ...     device=AMF${amf_id}

    Verify That Message Fulfills Query
    ...     (radioNetwork eq "${rnl_cause}")
    ...     message_alias=UEContextReleaseRequest
    ...     flow_alias=${flow}