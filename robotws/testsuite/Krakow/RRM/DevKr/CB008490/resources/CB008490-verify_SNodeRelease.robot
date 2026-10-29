*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == AUTHORS C-PLANE ==
...       - Konrad Krzyzak <konrad.krzyzak@nokia.com>
...       - Tomasz Pyrek <tomasz.pyrek@nokia.com>
...       - Michal Szymakowski <michal.szymakowski@nokia.com>
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

Library     CB008490.py

*** Keywords ***
##### SNodeRelease keywords #####
Verify that XNAP SNodeReleaseRequest contains cause:${cause_group:\S+}:${cause:\S+}, gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=mNGRANnodeinitiatedSNGRANnodeRelease
    ...     device=gNB${gnb_id}

    Verify That Message Fulfills Query
    ...     Cause contains (${cause_group} eq '${cause}')
    ...     message_alias=SNodeReleaseRequest
    ...     flow_alias=${flow_alias}

Verify that XNAP SNodeReleaseRequired contains cause:${cause_group:\S+}:${cause:\S+}, gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=sNGRANnodeinitiatedSNGRANnodeRelease
    ...     device=gNB${gnb_id}

    Verify That Message Fulfills Query
    ...     Cause contains (${cause_group} eq '${cause}')
    ...     message_alias=SNodeReleaseRequired
    ...     flow_alias=${flow_alias}

Verify that XNAP SNodeReleaseRequestAcknowledge ${object:\S+} contains '${item:\S+}', gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=mNGRANnodeinitiatedSNGRANnodeRelease
    ...     device=gNB${gnb_id}

    Verify That Message Fulfills Query
    ...     ${object} contains ('${item}')
    ...     message_alias=SNodeReleaseRequestAcknowledge
    ...     flow_alias=${flow_alias}

Verify that XNAP SNodeReleaseRequestAcknowledge ${item:\S+} field is present, gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=mNGRANnodeinitiatedSNGRANnodeRelease
    ...     device=gNB${gnb_id}

    Verify That Message Fulfills Query
    ...     (${item} is present)
    ...     message_alias=SNodeReleaseRequestAcknowledge
    ...     flow_alias=${flow_alias}

Verify that XnAP:SNodeReleaseRequest contains ${item:\S+} same as in XnAP:SNodeAdditionRequestAck
    ${flow_alias_snodeRel}=     Get flow name
    ...     procedure=mNGRANnodeinitiatedSNGRANnodeRelease
    ...     device=gNB2
    ...     protocol=XNAP

    ${flow_alias_snodeAddAck}=     Get flow name
    ...     procedure=sNGRANnodeAdditionPreparation
    ...     device=gNB3
    ...     protocol=XNAP

    compare_field_between_two_messages
    ...    msg1=SNodeReleaseRequest
    ...    msg1_flow=${flow_alias_snodeRel}
    ...    msg2=SNodeAdditionRequestAcknowledge
    ...    msg2_flow=${flow_alias_snodeAddAck}
    ...    field=${item}

Verify that XNAP:SNodeReleaseRequestAcknowledge contains ${item:\S+} same as in XnAP:SNodeReleaseRequest
    ${flow_alias_snodeRel}=     Get flow name
    ...     procedure=mNGRANnodeinitiatedSNGRANnodeRelease
    ...     device=gNB2
    ...     protocol=XNAP

    compare_field_between_two_messages
    ...    msg1=SNodeReleaseRequest
    ...    msg1_flow=${flow_alias_snodeRel}
    ...    msg2=SNodeReleaseRequestAcknowledge
    ...    msg2_flow=${flow_alias_snodeRel}
    ...    field=${item}

Verify that XNAP:UeContextRelease contains ${item:\S+} same as in XnAP:SNodeReleaseRequest
    ${flow_alias_snodeRel}=     Get flow name
    ...     procedure=mNGRANnodeinitiatedSNGRANnodeRelease
    ...     device=gNB2
    ...     protocol=XNAP

    ${flow_alias_ueCtxRel}=     Get flow name
    ...     procedure=uEContextRelease
    ...     device=gNB2
    ...     protocol=XNAP

    compare_field_between_two_messages
    ...    msg1=SNodeReleaseRequest
    ...    msg1_flow=${flow_alias_snodeRel}
    ...    msg2=UEContextRelease
    ...    msg2_flow=${flow_alias_ueCtxRel}
    ...    field=${item}

Verify that XNAP SNodeReleaseRequest contains only id-M-NG-RANnodeUEXnAPID and id-Cause, gNB${gnb_id}
    ${flow_alias}=     Get flow name
    ...     procedure=mNGRANnodeinitiatedSNGRANnodeRelease
    ...     device=gNB${gnb_id}

    # id: id-M-NG-RANnodeUEXnAPID (23)
    # id: id-Cause (7)
    Verify That Message Fulfills Query
    ...     length(protocolIEs) eq 2 and protocolIEs contains (id eq 23) and protocolIEs contains (id eq 7)
    ...     message_alias=SNodeReleaseRequest
    ...     flow_alias=${flow_alias}
