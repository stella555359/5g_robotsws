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
Verify in NGAP that QoS flows for 5QIs [${5qis}] were successfully added to existing PDU session
    @{5qis_to_add_list}=    Split To List    ${5qis}
    ${5qis_to_add_tuple}=   Split To Integers Tuple    ${5qis}
    ${length_of_5qis_to_add_list}=  Get length    ${5qis_to_add_list}

    ${flow}=    Get flow name
    ...     procedure=pDUSessionResourceModify
    ...     device=AMF1

    Run Keyword If    ${length_of_5qis_to_add_list} > 0
    ...     Verify That Message Fulfills Query
    ...     ( (length(QosFlowAddOrModifyRequestList) eq ${length_of_5qis_to_add_list})
    ...       and
    ...       (fiveQI contains ${5qis_to_add_tuple}) )
    ...     message_alias=PDUSessionResourceModifyRequest
    ...     flow_alias=${flow}

    Run Keyword If    ${length_of_5qis_to_add_list} == 0
    ...     Verify That Message Fulfills Query
    ...     (QosFlowAddOrModifyRequestList is not present)
    ...     message_alias=PDUSessionResourceModifyRequest
    ...     flow_alias=${flow}

    Verify That Message Fulfills Query
    ...     (PDUSessionResourceFailedToModifyListModRes is not present)
    ...     message_alias=PDUSessionResourceModifyResponse
    ...     flow_alias=${flow}

    Run Keyword If    ${length_of_5qis_to_add_list} > 0
    ...     Verify That Message Fulfills Query
    ...     (length(qosFlowAddOrModifyResponseList) eq ${length_of_5qis_to_add_list})
    ...     message_alias=PDUSessionResourceModifyResponse
    ...     flow_alias=${flow}

    Run Keyword If    ${length_of_5qis_to_add_list} == 0
    ...     Verify That Message Fulfills Query
    ...     (qosFlowAddOrModifyResponseList is not present)
    ...     message_alias=PDUSessionResourceModifyResponse
    ...     flow_alias=${flow}

Verify in NGAP that QoS flows for 5QIs [${5qis}] were successfully released from existing PDU session
    @{5qis_to_release_list}=   Split To List    ${5qis}
    ${length_of_5qis_to_release_list}=  Get length    ${5qis_to_release_list}

    ${flow}=    Get flow name
    ...     procedure=pDUSessionResourceModify
    ...     device=AMF1

    Run Keyword If    ${length_of_5qis_to_release_list} > 0
    ...     Verify That Message Fulfills Query
    ...     (length(QosFlowListWithCause) eq ${length_of_5qis_to_release_list})
    ...     message_alias=PDUSessionResourceModifyRequest
    ...     flow_alias=${flow}

    Run Keyword If    ${length_of_5qis_to_release_list} == 0
    ...     Verify That Message Fulfills Query
    ...     (QosFlowListWithCause is not present)
    ...     message_alias=PDUSessionResourceModifyRequest
    ...     flow_alias=${flow}

    Verify That Message Fulfills Query
    ...     (PDUSessionResourceFailedToModifyListModRes is not present)
    ...     message_alias=PDUSessionResourceModifyResponse
    ...     flow_alias=${flow}
