*** Settings ***
Documentation    :copyright: Nokia
...             :authors: I_MN_RAN_RD_VRF_WRO2_6
...             :contact: I_MN_RAN_RD_VRF_WRO2_6

*** Keywords ***
Verify that AMF${amf_id:\d+} NGAP InitialContextSetup does not contain UERadioCapability
    ${flow_alias}=    Get flow name
    ...     procedure=initialContextSetup
    ...     device=AMF${amf_id}

    Verify That Message Fulfills Query
    ...     (UERadioCapability is not present)
    ...     message_alias=InitialContextSetupRequest
    ...     flow_alias=${flow_alias}

Verify that AMF${amf_id:\d+} NGAP InitialContextSetup contains ${PDU_count:\d+} PDU sessions with only non-GBR QoS Flows
    ${flow_alias}=  get flow name
    ...     procedure=initialContextSetup
    ...     device=AMF${amf_id}

    Verify number of elements on the list within NGAP message
    ...     amf_id=${amf_id}
    ...     procedure_name=initialContextSetup
    ...     message=InitialContextSetupRequest
    ...     list_name=PDUSessionResourceSetupListCxtReq
    ...     element_num=${PDU_count}

    Verify That Message Fulfills Query
    ...    (qosCharacteristics contains (fiveQI ne 1))
    ...    message_alias=InitialContextSetupRequest
    ...    flow_alias=${flow_alias}

Verify number of elements on the list within NGAP message
    [Arguments]     ${amf_id}  ${procedure_name}  ${message}  ${list_name}  ${element_num}
    ${flow}=      get flow name
    ...     procedure=${procedure_name}
    ...     device=AMF${amf_id}
    Verify That Message Fulfills Query
    ...     (${list_name} is present)
    ...     message_alias=${message}
    ...     flow_alias=${flow}
    Verify That Message Fulfills Query
    ...     (length(${list_name}) eq ${element_num})
    ...     message_alias=${message}
    ...     flow_alias=${flow}
