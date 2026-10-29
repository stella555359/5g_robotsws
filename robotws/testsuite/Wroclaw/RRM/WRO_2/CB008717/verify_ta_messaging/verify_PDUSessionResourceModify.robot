*** Settings ***
Documentation    :copyright: Nokia
...             :authors: I_MN_RAN_RD_VRF_WRO2_6
...             :contact: I_MN_RAN_RD_VRF_WRO2_6

*** Keywords ***

Verify that AMF${a:\d+} PDUSessionResModReq_${n:\d+} out of ${all:\d+} was sent with pDUSessionID=${pdu:\d+} with fiveQI=${qi:\d+}
    Verify in AMF${a} PDUSessionResourceModifyRequest_${n} out of ${all} that pDUSessionID eq ${pdu} is present
    Verify in AMF${a} PDUSessionResModReq_${n} out of ${all} that qosFlowIdentifier is set to 2 and fiveQI eq ${qi}

Verify that AMF${a:\d+} PDUSessionResModResp_${n:\d+} out of ${all:\d+} was sent with pDUSessionID=${pdu:\d+}
    Verify in AMF${a} PDUSessionResourceModifyResponse_${n} out of ${all} that pDUSessionID eq ${pdu} is present

Verify that AMF${a:\d+} PDUSessionResModReq_${n:\d+} out of ${all:\d+} was send with pDUSessionID=${pdu:\d+} with fiveQI=${qi:\d+}
    Verify in AMF${a} PDUSessionResModReq_${n} out of ${all} that pDUSessionID eq ${pdu} is present in parallel flow
    Verify in AMF${a} PDUSessionResModReq_${n} out of ${all} QosFlowAddOrModifyRequestList is present and fiveQI eq ${qi}

Verify that AMF${a:\d+} PDUSessionResModReq_${n:\d+} out of ${all:\d+} was send with pDUSessionID=${pdu:\d+} and fiveQI=${qi:\d+}
    Verify in AMF${a} PDUSessionResModReq_${n} out of ${all} that pDUSessionID eq ${pdu} is present with 2 QoS
    Verify in AMF${a} PDUSessionResModReq_${n} out of ${all} QosFlowAddOrModifyRequestList is present with fiveQI eq ${qi}

Verify that AMF${a:\d+} PDUSessionResModReq_${n:\d+} out of ${all:\d+} was send with pDUSessionID=${pdu:\d+} and cause:${cause:\S+}
    Verify in AMF${a} PDUSessionResModReq_${n} out of ${all} that pDUSessionID eq ${pdu} is present in parallel flow
    Verify in AMF${a} PDUSessionResModReq_${n} out of ${all} PDUSessionResourceModifyRequestTransfer contains cause:${cause}

Verify in AMF${a:\d+} ${msg_name:\S+}_${msg_num:\d+} out of ${all:\d+} that pDUSessionID eq ${pdu:\d+} is present
    ${container_name}=    Set variable if    '${msg_name}'=='PDUSessionResourceModifyRequest'
    ...    PDUSessionResourceModifyRequest    PDUSessionResourceModifyResponse

    ${flow_alias}=     Get flow name
    ...     procedure=pDUSessionResourceModify
    ...     device=AMF${a}
    ...     protocol=NGAP

    Verify That Message Fulfills Query
    ...     ${container_name} contains (pDUSessionID eq ${pdu})
    ...     message_alias=${msg_name}
    ...     flow_alias=${flow_alias}

Verify in AMF${a:\d+} PDUSessionResModReq_${n:\d+} out of ${all:\d+} that qosFlowIdentifier is set to 2 and fiveQI eq ${qi:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=pDUSessionResourceModify
    ...     device=AMF${a}
    ...     protocol=NGAP

    Verify That Message Fulfills Query
    ...     QosFlowAddOrModifyRequestList contains (qosFlowIdentifier eq 2 and fiveQI eq ${qi})
    ...     message_alias=PDUSessionResourceModifyRequest
    ...     flow_alias=${flow_alias}

Verify in AMF${a:\d+} PDUSessionResModReq_${n:\d+} out of ${all:\d+} that pDUSessionID eq ${pdu:\d+} is present in parallel flow
    Verify That Message Fulfills Query
    ...    pDUSessionID eq ${pdu}
    ...    message_alias=PDUSessionResourceModifyRequest
    ...    flow_alias=takeback_PDUSessionResourceModify

Verify in AMF${a:\d+} PDUSessionResModReq_${n:\d+} out of ${all:\d+} QosFlowAddOrModifyRequestList is present and fiveQI eq ${qi:\d+}
    Verify That Message Fulfills Query
    ...    QosFlowAddOrModifyRequestList is present and fiveQI eq ${qi}
    ...    message_alias=PDUSessionResourceModifyRequest
    ...    flow_alias=takeback_PDUSessionResourceModify

Verify that AMF${a:\d+} PDUSessionResModResp_${n:\d+} out of ${all:\d+} was send with pDUSessionID=${pdu:\d+}
    Verify That Message Fulfills Query
    ...    PDUSessionResourceModifyListModRes contains (pDUSessionID eq ${pdu})
    ...    message_alias=PDUSessionResourceModifyResponse
    ...    flow_alias=takeback_PDUSessionResourceModify

Verify in AMF${a:\d+} PDUSessionResModReq_${n:\d+} out of ${all:\d+} PDUSessionResourceModifyRequestTransfer contains cause:${cause:\S+}
    Verify That Message Fulfills Query
    ...    pDUSessionResourceModifyRequestTransfer contains (cause contains (radioNetwork eq '${cause}'))
    ...    message_alias=PDUSessionResourceModifyRequest
    ...    flow_alias=takeback_PDUSessionResourceModify

Verify that AMF${a:\d+} PDUSessionResoModResp_${n:\d+} out of ${all:\d+} was send with pDUSessionID=${pdu:\d+} and cause:${cause:\S+}
    Verify in AMF${a} PDUSessionResoModResp_${n} out of ${all} that pDUSessionID eq ${pdu} is present in parallel flow
    Verify in AMF${a} PDUSessionResoModResp_${n} out of ${all} PDUSessionResourceModifyResponse contains cause:${cause}

Verify in AMF${a:\d+} PDUSessionResoModResp_${n:\d+} out of ${all:\d+} that pDUSessionID eq ${pdu:\d+} is present in parallel flow
    Verify That Message Fulfills Query
    ...    PDUSessionResourceModifyResponse contains (pDUSessionID eq ${pdu})
    ...    message_alias=PDUSessionResourceModifyResponse
    ...    flow_alias=takeback_PDUSessionResourceModifyFailed

Verify in AMF${a:\d+} PDUSessionResoModResp_${n:\d+} out of ${all:\d+} PDUSessionResourceModifyResponse contains cause:${cause:\S+}
    Verify That Message Fulfills Query
    ...    pDUSessionResourceModifyUnsuccessfulTransfer contains (cause contains (radioNetwork eq '${cause}'))
    ...    message_alias=PDUSessionResourceModifyResponse
    ...    flow_alias=takeback_PDUSessionResourceModifyFailed

Verify in AMF${a} PDUSessionResModReq_${n} out of ${all} that pDUSessionID eq ${pdu} is present with 2 QoS
    Verify That Message Fulfills Query
        ...    PDUSessionResourceModifyResponse contains (pDUSessionID eq ${pdu})
        ...    message_alias=PDUSessionResourceModifyResponse
        ...    flow_alias=takeback_PDUSessionResourceModify
Verify in AMF${a} PDUSessionResModReq_${n} out of ${all} QosFlowAddOrModifyRequestList is present with fiveQI eq ${qi}
    Verify That Message Fulfills Query
    ...    QosFlowAddOrModifyRequestList contains (fiveQI eq 5)
    ...    message_alias=PDUSessionResourceModifyRequest
    ...    flow_alias=takeback_PDUSessionResourceModify
