*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

Library     ../../resources/Python/utilities.py

*** Keywords ***
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

Verify single field in NGAP message
    [Arguments]     ${amf_id}  ${procedure_name}  ${message}  ${field}  ${value}
    ${new_value}=   map_message_value_to_ta_messaging_used_value    ${value}
    Log     ${new_value}
    ${flow}=      get flow name
    ...     procedure=${procedure_name}
    ...     device=AMF${amf_id}
    Verify That Message Fulfills Query
    ...     (${field} is present)
    ...     message_alias=${message}
    ...     flow_alias=${flow}

    Verify That Message Fulfills Query
    ...     (${field} eq ${new_value})
    ...     message_alias=${message}
    ...     flow_alias=${flow}

Verify that XNAP Inter-gNB Handover was completed successfully for UE${ue_id:\d+} with 1 nonGBR and 1 GBR 5QI${5qi_id:\d+} QoS flow
    PASS FLOW[timeout=10]: gNB3_XN XNAP handoverPreparation,sNStatusTransfer
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    PASS FLOW[timeout=10]: AMF1 NGAP pathSwitchRequest

    ${flow_alias}=  Get Flow Name
    ...     procedure=handoverPreparation,sNStatusTransfer
    ...     device=gNB3_XN

    Verify That Message Fulfills Query
    ...     ((length(pduSessionResourcesToBeSetup-List) eq 1)
    ...     and
    ...     (pduSessionResourcesToBeSetup-List contains ((pduSessionId eq 1) and (qosFlowsToBeSetup-List contains (fiveQI eq ${5qi_id})))))
    ...     message_alias=HandoverRequest
    ...     flow_alias=${flow_alias}

    Verify That Message Fulfills Query
    ...     (length(PDUSessionResourcesAdmitted-List) eq 1)
    ...     message_alias=HandoverRequestAcknowledge
    ...     flow_alias=${flow_alias}
