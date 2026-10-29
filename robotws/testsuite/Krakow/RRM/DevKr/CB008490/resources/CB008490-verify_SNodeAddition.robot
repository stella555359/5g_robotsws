*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == AUTHORS C-PLANE ==
...       - Konrad Krzyzak <konrad.krzyzak@nokia.com>
...       - Tomasz Pyrek <tomasz.pyrek@nokia.com>
...       - Michal Szymakowski 	<michal.szymakowski@nokia.com>
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

Library     CB008490.py

*** Keywords ***
##### SNodeAdditionRequest keywords #####
Verify in SNodeAdditionRequest that it has 8 required protocolIE items for SN gNB${gnb:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=sNGRANnodeAdditionPreparation
    ...     device=gNB${gnb}
    ...     protocol=XNAP

    Verify That Message Fulfills Query
    ...     (NG-RANnodeUEXnAPID is present) and (UESecurityCapabilities is present) and (S-NG-RANnode-SecurityKey is present) and
    ...     (UEAggregateMaximumBitRate is present) and (PLMN-Identity is present) and (PDUSessionToBeAddedAddReq is present) and
    ...     (DRB-List is present)
    ...     message_alias=SNodeAdditionRequest
    ...     flow_alias=${flow_alias}

Verify in SNodeAdditionRequest that pduSessionId is set to ${pdu_id} and mn-terminated is not present and sn-terminated is present for SN gNB${gnb}
    ${flow_alias}=     Get flow name
    ...     procedure=sNGRANnodeAdditionPreparation
    ...     device=gNB${gnb}
    ...     protocol=XNAP

    Verify That Message Fulfills Query
    ...     PDUSessionToBeAddedAddReq contains ((pduSessionId eq ${pdu_id}) and (mn-terminated is not present) and (sn-terminated is present))
    ...     message_alias=SNodeAdditionRequest
    ...     flow_alias=${flow_alias}

Verify in SNodeAdditionRequest that gTPTunnel is present and pduSessionType is set to ipv4 for SN gNB${gnb:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=sNGRANnodeAdditionPreparation
    ...     device=gNB${gnb}
    ...     protocol=XNAP

    Verify That Message Fulfills Query
    ...     PDUSessionToBeAddedAddReq contains (sn-terminated contains (uL-NG-U-TNLatUPF contains
    ...     (gtpTunnel contains ((gtp-teid is present) and (tnl-address is present))) and pduSessionType eq "ipv4"))
    ...     message_alias=SNodeAdditionRequest
    ...     flow_alias=${flow_alias}

Verify in SNodeAdditionRequest that qosFlowsToBeForwarded list is ${len:\d+} element for SN gNB${gnb:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=sNGRANnodeAdditionPreparation
    ...     device=gNB${gnb}
    ...     protocol=XNAP

    Verify That Message Fulfills Query
    ...     PDUSessionToBeAddedAddReq contains (sn-terminated contains
    ...     (dataforwardinginfofromSource contains (length(qosFlowsToBeForwarded) eq ${len})))
    ...     message_alias=SNodeAdditionRequest
    ...     flow_alias=${flow_alias}

Verify in SNodeAdditionRequest that dl-dataforwarding is set to forwarding-proposed for SN gNB${gnb:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=sNGRANnodeAdditionPreparation
    ...     device=gNB${gnb}
    ...     protocol=XNAP

    Verify That Message Fulfills Query
    ...     PDUSessionToBeAddedAddReq contains (sn-terminated contains (dataforwardinginfofromSource contains (qosFlowsToBeForwarded contains
    ...     (dl-dataforwarding eq "dl-forwarding-proposed"))))
    ...     message_alias=SNodeAdditionRequest
    ...     flow_alias=${flow_alias}

Verify in SNodeAdditionRequest that dl-dataforwarding - forwarding-proposed is set for ${flows:\d+} QoS flows for SN gNB${gnb:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=sNGRANnodeAdditionPreparation
    ...     device=gNB${gnb}
    ...     protocol=XNAP

    verify_dl_dataforwarding    ${flow_alias}    SNodeAdditionRequest    ${flows}

Verify in SNodeAdditionRequest that sourceDRBtoQoSFlowMapping includes DRB ID 4 and QOS flow has 1 element for SN gNB${gnb:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=sNGRANnodeAdditionPreparation
    ...     device=gNB${gnb}
    ...     protocol=XNAP

    Verify That Message Fulfills Query
    ...     sourceDRBtoQoSFlowMapping contains ((drb-ID eq 4) and (length(qosFlows-List) eq 1))
    ...     message_alias=SNodeAdditionRequest
    ...     flow_alias=${flow_alias}

Verify in SNodeAdditionRequest that sourceDRBtoQoSFlowMapping includes ${drbs:\d+} DRBs with single QoS flow for SN gNB${gnb:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=sNGRANnodeAdditionPreparation
    ...     device=gNB${gnb}
    ...     protocol=XNAP

    verify_sourceDRBtoQoSFlowMapping    ${flow_alias}    SNodeAdditionRequest    ${drbs}

Verify in SNodeAdditionRequest that DRB-List contains ${num_of_drbs:\d+} elements for SN gNB${gnb:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=sNGRANnodeAdditionPreparation
    ...     device=gNB${gnb}
    ...     protocol=XNAP

    Verify That Message Fulfills Query
    ...     length(DRB-List) eq ${num_of_drbs}
    ...     message_alias=SNodeAdditionRequest
    ...     flow_alias=${flow_alias}

Verify in SNodeAdditionRequest that candidateCellInfoListMN has 1 element, pci: ${pci:\d+} for SN gNB${gnb:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=sNGRANnodeAdditionPreparation
    ...     device=gNB${gnb}
    ...     protocol=XNAP

    ${mn_to_sn_container}    parse_mn_to_sn_container    ${flow_alias}    SNodeAdditionRequest

    Verify That Message Fulfills Query
    ...     length(candidateCellInfoListMN) eq 1 and physCellId eq ${pci}
    ...     message_object=${mn_to_sn_container}

Verify in SNodeAdditionRequest that integrityProtection is enabled in MN
    ${flow_alias}=     Get flow name
    ...     procedure=sNGRANnodeAdditionPreparation
    ...     device=gNB3
    ...     protocol=XNAP

    ${mn_to_sn_container}    parse_mn_to_sn_container    ${flow_alias}    SNodeAdditionRequest

    Verify That Message Fulfills Query
    ...     integrityProtection is present
    ...     message_object=${mn_to_sn_container}

Verify in SNodeAdditionRequest that integrityProtection is not enabled in MN
    ${flow_alias}=     Get flow name
    ...     procedure=sNGRANnodeAdditionPreparation
    ...     device=gNB3
    ...     protocol=XNAP

    verify_field_not_in_mn_to_sn_container    integrityProtection    ${flow_alias}    SNodeAdditionRequest

Verify in SNodeAdditionRequest and SNodeAdditionRequestAcknowledge sdap-Config for all DRBs
    [Arguments]    ${gnb}=3    ${rdDisableSDAPheaderSa}=${False}

    ${flow_alias}=     Get flow name
    ...     procedure=sNGRANnodeAdditionPreparation
    ...     device=gNB${gnb}
    ...     protocol=XNAP

    verify_sdap_config_in_snode_add_request_and_ack    ${flow_alias}    ${rdDisableSDAPheaderSa}

Verify in sNGRANnodeAdditionPreparation${Failure} supported nea: [${nea_str}] and nia: [${nia_str}] algorithms for SN gNB${gnb:\d+}
    [Documentation]    KW usage:
    ...                Verify in SNodeAdditionRequest supported nea: [nea1,nea2,nea3] and nia: [nia1] algorithms for SN gNB${gnb:\d+}

    @{nea_list}    Split To List    ${nea_str}
    ${nea_length}=     Get Length       ${nea_list}
    @{nia_list}    Split To List    ${nia_str}
    ${nia_length}=     Get Length       ${nia_list}

    ${nea_query}=    prepare_nxa_query    ${nea_list}
    ${nia_query}=    prepare_nxa_query    ${nia_list}

    ${flow_alias}=     Get flow name
    ...     procedure=sNGRANnodeAdditionPreparation${Failure}
    ...     device=gNB${gnb}
    ...     protocol=XNAP

    Verify That Message Fulfills Query
    ...     nr-EncyptionAlgorithms contains (${nea_query}) and (length(nr-EncyptionAlgorithms) eq ${nea_length})
    ...     and
    ...     nr-IntegrityProtectionAlgorithms contains (${nia_query}) and (length(nr-EncyptionAlgorithms) eq ${nia_length})
    ...     message_alias=SNodeAdditionRequest
    ...     flow_alias=${flow_alias}

Verify in SNodeAdditionRequest that integrityProtectionIndication is set to ${option:(required|preferred|not-needed)} for SN gNB${gnb:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=sNGRANnodeAdditionPreparation
    ...     device=gNB${gnb}
    ...     protocol=XNAP

    Verify That Message Fulfills Query
    ...     integrityProtectionIndication eq '${option}'
    ...     message_alias=SNodeAdditionRequest
    ...     flow_alias=${flow_alias}

Verify in SNodeAdditionRequest that PDUSessionToBeAddedAddReq contains s-NSSAI with SD equal 1 for SN gNB${gnb:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=sNGRANnodeAdditionPreparation
    ...     device=gNB${gnb}
    ...     protocol=XNAP

    Verify That Message Fulfills Query
    ...     PDUSessionToBeAddedAddReq contains (s-NSSAI contains (sd eq '0x000001'))
    ...     message_alias=SNodeAdditionRequest
    ...     flow_alias=${flow_alias}

##### SNodeAdditionRequestAcknowledge keywords #####
Verify in SNodeAdditionRequestAck that PDUSessionAdmittedAddedReqAck has 1 element for SN gNB${gnb:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=sNGRANnodeAdditionPreparation
    ...     device=gNB${gnb}
    ...     protocol=XNAP

    Verify That Message Fulfills Query
    ...     length(PDUSessionAdmittedAddedAddReqAck) eq 1
    ...     message_alias=SNodeAdditionRequestAcknowledge
    ...     flow_alias=${flow_alias}

Verify in SNodeAdditionRequestAck that mn-terminated is not present and sn-terminated is present for SN gNB${gnb:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=sNGRANnodeAdditionPreparation
    ...     device=gNB${gnb}
    ...     protocol=XNAP

    Verify That Message Fulfills Query
    ...     PDUSessionAdmittedAddedAddReqAck contains ((mn-terminated is not present) and (sn-terminated is present))
    ...     message_alias=SNodeAdditionRequestAcknowledge
    ...     flow_alias=${flow_alias}

Verify in SNodeAdditionRequestAck that dL-NG-U-TNLatNG-RAN is present and dRBsToBeSetup has 1 element for SN gNB${gnb:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=sNGRANnodeAdditionPreparation
    ...     device=gNB${gnb}
    ...     protocol=XNAP

    Verify That Message Fulfills Query
    ...     PDUSessionAdmittedAddedAddReqAck contains (sn-terminated contains (dL-NG-U-TNLatNG-RAN is present and length(dRBsToBeSetup) eq 1))
    ...     message_alias=SNodeAdditionRequestAcknowledge
    ...     flow_alias=${flow_alias}

Verify in SNodeAdditionRequestAck that dL-NG-U-TNLatNG-RAN is present for SN gNB${gnb:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=sNGRANnodeAdditionPreparation
    ...     device=gNB${gnb}
    ...     protocol=XNAP

    Verify That Message Fulfills Query
    ...     PDUSessionAdmittedAddedAddReqAck contains (sn-terminated contains (dL-NG-U-TNLatNG-RAN is present))
    ...     message_alias=SNodeAdditionRequestAcknowledge
    ...     flow_alias=${flow_alias}


Verify in SNodeAdditionRequestAck that in dRBsToBeSetup drb-ID is 4 and sN-UL-PDCP-UP-TNLInfo has 1 elements for SN gNB${gnb:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=sNGRANnodeAdditionPreparation
    ...     device=gNB${gnb}
    ...     protocol=XNAP

    Verify That Message Fulfills Query
    ...     PDUSessionAdmittedAddedAddReqAck contains (sn-terminated contains (dRBsToBeSetup contains
    ...     (drb-ID eq 4 and length(sN-UL-PDCP-UP-TNLInfo) eq 1)))
    ...     message_alias=SNodeAdditionRequestAcknowledge
    ...     flow_alias=${flow_alias}

Verify in SNodeAdditionRequestAck that in sn-terminated dataforwardinginfoTarget is present and DRB-List contains 4 for SN gNB${gnb:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=sNGRANnodeAdditionPreparation
    ...     device=gNB${gnb}
    ...     protocol=XNAP

    Verify That Message Fulfills Query
    ...     PDUSessionAdmittedAddedAddReqAck contains (sn-terminated contains
    ...     (dataforwardinginfoTarget is present and iE-Extensions contains (DRB-List contains (4))))
    ...     message_alias=SNodeAdditionRequestAcknowledge
    ...     flow_alias=${flow_alias}

Verify in SNodeAdditionRequestAck that length of dataForwardingResponseDRBItemList eq ${len:\d+} for SN gNB${gnb:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=sNGRANnodeAdditionPreparation
    ...     device=gNB${gnb}
    ...     protocol=XNAP

    Verify That Message Fulfills Query
    ...     PDUSessionAdmittedAddedAddReqAck contains (sn-terminated contains
    ...     (length(dataForwardingResponseDRBItemList) eq ${len}))
    ...     message_alias=SNodeAdditionRequestAcknowledge
    ...     flow_alias=${flow_alias}

Verify in SNodeAdditionRequestAck that secondaryCellGroup is configured for SN gNB${gnb:\d+}
    ${XN_flow_alias}=     Get flow name
    ...     procedure=sNGRANnodeAdditionPreparation
    ...     device=gNB${gnb}
    ...     protocol=XNAP

    ${F1_flow_alias}=     Get flow name
    ...     procedure=uEContextSetup
    ...     device=gNB${gnb}
    ...     protocol=F1AP

    compare_secondaryCellGroup_and_CellGroupConfig
    ...     ${XN_flow_alias}
    ...     SNodeAdditionRequestAcknowledge
    ...     ${F1_flow_alias}
    ...     UEContextSetupResponse

Verify in SNodeAdditionRequestAck that in dRBsToBeSetup drb-IDs eq [${drb_ids}] for SN gNB${gnb:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=sNGRANnodeAdditionPreparation
    ...     device=gNB${gnb}
    ...     protocol=XNAP

    verify_drbs_in_dRBsToBeSetup    ${flow_alias}    SNodeAdditionRequestAcknowledge    ${drb_ids}

Verify in SNodeAdditionRequestAck in DRB-List DRB-ID eq [${drb_ids}] for SN gNB${gnb:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=sNGRANnodeAdditionPreparation
    ...     device=gNB${gnb}
    ...     protocol=XNAP

    verify_drbs_in_DRB_LIST    ${flow_alias}    SNodeAdditionRequestAcknowledge    ${drb_ids}

Verify in SNodeAdditionRequestAck that integrityProtection is enabled in SN
    ${flow_alias}=     Get flow name
    ...     procedure=sNGRANnodeAdditionPreparation
    ...     device=gNB3
    ...     protocol=XNAP

    ${sn_to_mn_container}    parse_sn_to_mn_container    ${flow_alias}    SNodeAdditionRequestAcknowledge

    Verify That Message Fulfills Query
    ...     integrityProtection is present
    ...     message_object=${sn_to_mn_container}

Verify in SNodeAdditionRequestAck that integrityProtection is not enabled in SN
    ${flow_alias}=     Get flow name
    ...     procedure=sNGRANnodeAdditionPreparation
    ...     device=gNB3
    ...     protocol=XNAP

    verify_field_not_in_sn_to_mn_container    integrityProtection   ${flow_alias}    SNodeAdditionRequestAcknowledge

Verify in SNodeAdditionRequestAck SN-to-MN-Container that ${field} is not present for SN gNB${gnb:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=sNGRANnodeAdditionPreparation
    ...     device=gNB${gnb}
    ...     protocol=XNAP

    verify_field_not_in_sn_to_mn_container    ${field}    ${flow_alias}    SNodeAdditionRequestAcknowledge

Verify in SNodeAdditionRequestAck that ${field} is not present for SN gNB${gnb:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=sNGRANnodeAdditionPreparation
    ...     device=gNB${gnb}
    ...     protocol=XNAP

    Verify That Message Fulfills Query
    ...     ${field} is not present
    ...     message_alias=SNodeAdditionRequestAcknowledge
    ...     flow_alias=${flow_alias}

Verify in SNodeAdditionRequestAck that securityResult is present and integrityProtectionResult is ${opt:performed|not-performed} for SN gNB${gnb:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=sNGRANnodeAdditionPreparation
    ...     device=gNB${gnb}
    ...     protocol=XNAP

    Verify That Message Fulfills Query
    ...     securityResult contains (integrityProtectionResult eq '${opt}' and confidentialityProtectionResult eq 'performed')
    ...     message_alias=SNodeAdditionRequestAcknowledge
    ...     flow_alias=${flow_alias}

Verify in SNodeAdditionRequestAck that cipheringAlgorithm is set to ${ciphAlg} and integrityProtAlgorithm is set to ${intAlg} for SN gNB${gnb:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=sNGRANnodeAdditionPreparation
    ...     device=gNB${gnb}
    ...     protocol=XNAP

    ${sn_to_mn_container}    parse_sn_to_mn_container    ${flow_alias}    SNodeAdditionRequestAcknowledge

    Verify That Message Fulfills Query
    ...     securityAlgorithmConfig contains (cipheringAlgorithm eq '${ciphAlg}' and integrityProtAlgorithm eq '${intAlg}')
    ...     message_object=${sn_to_mn_container}



##### SNodeAdditionRequestReject keywords #####
Verify that SNodeAdditionRequestReject contains cause:${cause_group:\S+}:${cause:\S+} for SN gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=sNGRANnodeAdditionPreparationFailure
    ...     device=gNB${gnb_id}
    ...     protocol=XNAP

    Verify That Message Fulfills Query
    ...     Cause contains (${cause_group} eq '${cause}')
    ...     message_alias=SNodeAdditionRequestReject
    ...     flow_alias=${flow_alias}

Verify that SNodeAdditionRequest does not contain AvailableDrbIds for SN gNB${gnb_id}
    ${flow_alias}=     Get flow name
    ...     procedure=sNGRANnodeAdditionPreparationFailure
    ...     device=gNB${gnb_id}
    ...     protocol=XNAP

    Verify That Message Fulfills Query
    ...     id-availableDRBIDs is not present
    ...     message_alias=SNodeAdditionRequest
    ...     flow_alias=${flow_alias}
