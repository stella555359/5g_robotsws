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

*** Keywords ***
Verify in NGAP that QoS flows for 5QIs [${5qis}] were successfully added to new PDU session
    @{5qis_to_add_list}=    Split To List    ${5qis}
    ${5qis_to_add_tuple}=   Split To Integers Tuple    ${5qis}
    ${length_of_5qis_to_add_list}=  Get length    ${5qis_to_add_list}

    ${flow}=    Get flow name
    ...     procedure=pDUSessionResourceSetup
    ...     device=AMF1

    Run Keyword If    ${length_of_5qis_to_add_list} > 0
    ...     Verify That Message Fulfills Query
    ...     ( (length(QosFlowSetupRequestList) eq ${length_of_5qis_to_add_list})
    ...       and
    ...       (fiveQI contains ${5qis_to_add_tuple}) )
    ...     message_alias=PDUSessionResourceSetupRequest
    ...     flow_alias=${flow}

    Run Keyword If    ${length_of_5qis_to_add_list} == 0
    ...     Verify That Message Fulfills Query
    ...     (QosFlowSetupRequestList is not present)
    ...     message_alias=PDUSessionResourceSetupRequest
    ...     flow_alias=${flow}

    Verify That Message Fulfills Query
    ...     (PDUSessionResourceFailedToModifyListModRes is not present)
    ...     message_alias=PDUSessionResourceSetupResponse
    ...     flow_alias=${flow}

    Run Keyword If    ${length_of_5qis_to_add_list} > 0
    ...     Verify That Message Fulfills Query
    ...     (length(associatedQosFlowList) eq ${length_of_5qis_to_add_list})
    ...     message_alias=PDUSessionResourceSetupResponse
    ...     flow_alias=${flow}

    Run Keyword If    ${length_of_5qis_to_add_list} == 0
    ...     Verify That Message Fulfills Query
    ...     (associatedQosFlowList is not present)
    ...     message_alias=PDUSessionResourceSetupResponse
    ...     flow_alias=${flow}

Verify that AMF${amf_id:\d+} NGAP PDUSessionResourceSetup contains ${qosflow_count} QoS Flows
    ${flow_alias}=  get flow name
    ...     procedure=pDUSessionResourceSetup
    ...     device=AMF${amf_id}

    Verify That Message Fulfills Query
    ...     (length(QosFlowSetupRequestList) eq ${qosflow_count})
    ...     message_alias=PDUSessionResourceSetupRequest
    ...     flow_alias=${flow_alias}

    Verify That Message Fulfills Query
    ...     (length(associatedQosFlowList) eq ${qosflow_count})
    ...     message_alias=PDUSessionResourceSetupResponse
    ...     flow_alias=${flow_alias}

Verify that gNB failed to add QoS flows for 5QIs with cause=${cause}
    ${flow_alias}=  get flow name
    ...     procedure=pDUSessionResourceModify
    ...     device=AMF1

    Verify That Message Fulfills Query
    ...     PDUSessionResourceFailedToModifyListModRes contains (cause contains (radioNetwork eq "${cause}"))
    ...     message_alias=PDUSessionResourceModifyResponse
    ...     flow_alias=${flow_alias}

Verify that gNB failed to add QoS flows for 5QIs in PDU Session Setup with cause=${cause}
    ${flow_alias}=  get flow name
    ...     procedure=pDUSessionResourceSetup
    ...     device=AMF1

    Verify That Message Fulfills Query
    ...     PDUSessionResourceFailedToSetupListSURes contains (cause contains (radioNetwork eq "${cause}"))
    ...     message_alias=PDUSessionResourceSetupResponse
    ...     flow_alias=${flow_alias}

Verify that gNB sends InitialContextSetupFailure with cause=${cause}
    ${flow_alias}=  get flow name
    ...     procedure=initialContextSetupFailure
    ...     device=AMF1

    Verify That Message Fulfills Query
    ...     Cause contains (radioNetwork eq "${cause}")
    ...     message_alias=InitialContextSetupFailure
    ...     flow_alias=${flow_alias}

Verify in NGAP that 5QI${5qi} QoS flow GFBR was successfully modified to ${kbitrate}kbps
    ${bitrate}=    Evaluate    ${kbitrate}*1000
    ${flow}=    Get Flow Name
    ...     procedure=pDUSessionResourceModify
    ...     device=AMF1

    Verify That Message Fulfills Query
    ...     ((QosFlowAddOrModifyRequestList contains (fiveQI eq ${5qi}))
    ...     and
    ...     (QosFlowAddOrModifyRequestList contains (guaranteedFlowBitRateDL eq ${bitrate}))
    ...     and
    ...     (QosFlowAddOrModifyRequestList contains (guaranteedFlowBitRateDL eq ${bitrate})))
    ...     message_alias=PDUSessionResourceModifyRequest
    ...     flow_alias=${flow}

    Verify That Message Fulfills Query
    ...     (length(qosFlowAddOrModifyResponseList) eq 1)
    ...     message_alias=PDUSessionResourceModifyResponse
    ...     flow_alias=${flow}

Verify that gNB failed to setup PDU Session for 5QIs with cause=${cause}
    ${flow_alias}=  get flow name
    ...     procedure=pDUSessionResourceSetup
    ...     device=AMF1

    Verify That Message Fulfills Query
    ...     PDUSessionResourceFailedToSetupListSURes contains (cause contains (radioNetwork eq "${cause}"))
    ...     message_alias=PDUSessionResourceSetupResponse
    ...     flow_alias=${flow_alias}
