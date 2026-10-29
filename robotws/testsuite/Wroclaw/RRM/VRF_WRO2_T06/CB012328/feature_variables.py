SGNB_RECONFIGURATION_FILTER = "nr-rrc.mrdc_SecondaryCellGroup == 0 " \
                                            "&& nr-rrc.cellGroupId == 1 " \
                                            "&& nr-rrc.physCellId == 61 " \
                                            "&& nr-rrc.FreqBandIndicatorNR == 258"


PDU_SESSION_RESOURCE_MODIFY_FILTER = "ngap.PDUSessionResourceModifyListModInd == 1 " \
                                            "&& ngap.pDUSessionID == 1 " \
                                            "&& ngap.qosFlowIdentifier == 1"

PDU_SESSION_RESOURCE_MODIFY_LIST_FILTER = "ngap.PDUSessionResourceModifyListModCfm == 1"

XNAP_SNODE_ADDITION_REQUEST_FITLER = "xnap.SNodeAdditionRequest_element"

XNAP_SNODEADDITIONREQUEST_FILTER = "xnap.SNodeAdditionRequest_element " \
                                            "&& xnap.DRB_ID == 6 " \
                                            "&& nr-rrc.ssbFrequency == 2017819 " \
                                            "&& nr-rrc.physCellId == 61 " \
                                            "&& nr-rrc.bandCombinationIndex == 7"

XNAP_SNODE_ADDITION_REQUEST_ACKNOWLEDGE_FILTER = "xnap.SNodeAdditionRequestAcknowledge_element" \
                                            "&& xnap.DRB_ID == 6 "

XNAP_XNU_ADDRESS_INDICATION_FILTER = "xnap.XnUAddressIndication_element"

XNAP_SN_STATUS_TRANSFER_FILTER = "xnap.SNStatusTransfer_element"

XNAP_SNODE_RECONFIGURATION_COMPLETE_FILTER = "xnap.SNodeReconfigurationComplete_element"

# cause: normal-release
XNAP_SNODE_RELEASE_REQUEST_FITLER = "xnap.SNodeReleaseRequest_element " \
                                            "&& xnap.Cause == 0 " \
                                            "&& xnap.pduSessionId == 1 " \
                                            "&& xnap.radioNetwork == 65"

XNAP_SNODE_RELEASE_REQUEST_ACKNOWLEDGE_FILTER = "xnap.SNodeReleaseRequestAcknowledge_element " \
                                            "&& xnap.pduSessionId == 1 " \
                                            "&& xnap.qosFlowIdentifier == 1 " \
                                            "&& xnap.drb_ID == 6"

NGAP_PDU_SESSION_RESOURCE_MODIFY_INDICATOR_FILTER = "ngap.PDUSessionResourceModifyIndication_element"

NGAP_PDU_SESSION_RESOURCE_MODIFY_CONFIRM_FILTER = "ngap.PDUSessionResourceModifyConfirm_element " \
                                            "&& ngap.qosFlowIdentifier == 1"

# Filtr dla measId: 1 (Event A2, freqBandIndicatorNR: 66)
MEAS_EVENT_A2_FILTER = \
    "(nr-rrc.rrcReconfiguration_element " \
    "&& nr-rrc.measConfig_element " \
    "&& nr-rrc.freqBandIndicatorNR == 66 " \
    "&& nr-rrc.eventA2_element)"

# Filtr dla measId: 2 (Event A3, freqBandIndicatorNR: 66)
MEAS_EVENT_A3_FILTER = \
    "(nr-rrc.rrcReconfiguration_element " \
    "&& nr-rrc.measConfig_element " \
    "&& nr-rrc.freqBandIndicatorNR == 66 " \
    "&& nr-rrc.eventA3_element)"

# Filtr dla measId: 3 (Event A5, freqBandIndicatorNR: 66)
MEAS_EVENT_A5_FILTER = \
    "(nr-rrc.rrcReconfiguration_element " \
    "&& nr-rrc.measConfig_element " \
    "&& nr-rrc.freqBandIndicatorNR == 66 " \
    "&& nr-rrc.eventA5_element)"

# Filtr dla measId: 4 (Event A1, freqBandIndicatorNR: 66)
MEAS_EVENT_A1_FILTER = \
    "(nr-rrc.rrcReconfiguration_element " \
    "&& nr-rrc.measConfig_element " \
    "&& nr-rrc.freqBandIndicatorNR == 66 " \
    "&& nr-rrc.eventA1_element)"  #

NGAP_PDU_SESSION_RESOURCE_MODIFY_REQUEST_FILTER = "(ngap.PDUSessionResourceModifyRequest_element " \
                                                  "&& ngap.fiveQI == 1 " \
                                                  "&& ngap.QosFlowAddOrModifyRequestList == 1)"

NGAP_PDU_SESSION_RESOURCE_MODIFY_RESPONSE_FILTER = "ngap.PDUSessionResourceModifyResponse_element"

RRC_SGNB_RELEASE_FILTER = "nr-rrc.release_element " \
                          "&& nr-rrc.mrdc_SecondaryCellGroupConfig == 0"

XNAP_UE_CONTEXT_RELEASE_FILTER = "xnap.UEContextRelease_element"
