# X2AP MeNB -> SgNB
SGNB_ADDITION_REQUEST_FILTER = "x2ap.SgNBAdditionRequest_element " \
                                   "&& nr-rrc.ue_CapabilityInfo " \
                                   "&& nr-rrc.ssbFrequency == 636576 " \
                                   "&& nr-rrc.physCellId == 50"

# F1AP gNB-CU-CP -> gNB-DU
UE_CONTEXT_SETUP_REQUEST_FILTER = "f1ap.UEContextSetupRequest_element " \
                                  "&& nr-rrc.ue_CapabilityInfo " \
                                  "&& nr-rrc.ssbFrequency == 636576 " \
                                  "&& nr-rrc.physCellId == 50 " \
                                  "&& nr-rrc.UE_CapabilityRAT_ContainerList " \
                                  "&& nr-rrc.MeasConfig_element " \
                                  "&&  nr-rrc.measObject == measObjectNR " \
                                  "&& nr-rrc.ssbFrequency == 636576 " \
                                  "&& nr-rrc.freqBandIndicatorNR == 78 " \
                                  "&& nr-rrc.eventA1_element " \
                                  "&& nr-rrc.a1_Threshold == rsrp " \
                                  "&& nr-rrc.measTriggerQuantity.rsrp == 71 " \
                                  "&& nr-rrc.hysteresis == 0 " \
                                  "&& nr-rrc.timeToTrigger == ms480 " \
                                  "&& nr-rrc.measIdToAddModList == 2 " \
                                  "&& nr-rrc.measId == 2 " \
                                  "&& nr-rrc.measObjectId == 1 " \
                                  "&& nr-rrc.reportConfigId == 2"

# F1AP gNB-DU -> gNB-CU-CP
UE_CONTEXT_SETUP_RESPONSE_FILTER = "f1ap.UEContextSetupResponse_element " \
                                   "&& f1ap.DUtoCURRCInformation_element " \
                                   "&& nr-rrc.CellGroupConfig_element " \
                                   "&& nr-rrc.spCellConfig_element " \
                                   "&& nr-rrc.reconfigurationWithSync_element " \
                                   "&& nr-rrc.spCellConfigCommon_element " \
                                   "&& nr-rrc.physCellId == 50"

# X2AP SgNB -> MeNB
SGNB_ADDITION_REQUEST_ACKNOWLEDGE_FILTER = "x2ap.SgNBAdditionRequestAcknowledge_element " \
                                           "&& nr-rrc.CellGroupConfig_element " \
                                           "&& nr-rrc.spCellConfig_element " \
                                           "&& nr-rrc.reconfigurationWithSync_element " \
                                           "&& nr-rrc.spCellConfigCommon_element " \
                                           "&& nr-rrc.physCellId == 50  " \
                                           "&& nr-rrc.measConfig_element " \
                                           "&& nr-rrc.measObject == measObjectNR " \
                                           "&& nr-rrc.ssbFrequency == 636576 " \
                                           "&& nr-rrc.freqBandIndicatorNR == 78 " \
                                           "&& nr-rrc.eventA1_element " \
                                           "&& nr-rrc.a1_Threshold == rsrp " \
                                           "&& nr-rrc.measTriggerQuantity.rsrp == 71 " \
                                           "&& nr-rrc.hysteresis == 0 " \
                                           "&& nr-rrc.timeToTrigger == ms480 " \
                                           "&& nr-rrc.measIdToAddModList == 2 " \
                                           "&& nr-rrc.measId == 2 " \
                                           "&& nr-rrc.measObjectId == 1 " \
                                           "&& nr-rrc.reportConfigId == 2 " \
                                           "&& nr-rrc.nonCriticalExtension_element " \
                                           "&& nr-rrc.pSCellFrequency == 636576"

# X2AP MeNB -> SgNB
SGNB_RECONFIGURATION_COMPLETE_FILTER = "x2ap.SgNBReconfigurationComplete_element " \
                                       "&& x2ap.meNBtoSgNBContainer " \
                                       "&& nr-rrc.rrcReconfigurationComplete_element"

# X2AP MeNB -> SgNB
SN_STATUS_TRANSFER_FILTER = "x2ap.SNStatusTransfer_element"


# --------- FILTERS BELOW SHOULD NOT BE MATCHED ---------

# F1AP gNB-CU-CP -> gNB-DU
UE_CONTEXT_MODIFICATION_REQUEST__WITH_A4_FILTER = \
    "(f1ap.UEContextModificationRequest_element " \
    "&& f1ap.CUtoDURRCInformation_element " \
    "&& nr-rrc.MeasConfig_element " \
    "&& nr-rrc.measObjectNR_element) " \
    "&& (nr-rrc.freqBandIndicatorNR == 257 " \
    "|| nr-rrc.freqBandIndicatorNR == 258) " \
    "&& (nr-rrc.reportConfigNR_element " \
    "&& nr-rrc.eventA4_element)"

# F1AP gNB-DU -> gNB-CU-CP
UE_CONTEXT_MODIFICATION_RESPONSE__WITH_MEAS_GAP_CONFIG_FILTER = \
    "f1ap.UEContextModificationResponse_element " \
    "&& f1ap.DUtoCURRCInformation_element " \
    "&& nr-rrc.MeasGapConfig_element"

# X2AP SgNB -> MeNB
SGNB_MODIFICATION_REQUIRED__WITH_A4_AND_MEAS_GAP_CONFIG_FILTER = \
    "(x2ap.SgNBModificationRequired_element " \
    "&& x2ap.SgNBtoMeNBContainer " \
    "&& nr-rrc.rrcReconfiguration_element " \
    "&& nr-rrc.measObjectNR_element) " \
    "&& (nr-rrc.freqBandIndicatorNR == 257 || nr-rrc.freqBandIndicatorNR == 258) " \
    "&& (nr-rrc.reportConfigNR_element " \
    "&& nr-rrc.eventA4_element " \
    "&& nr-rrc.measGapConfig_element)"

# X2AP MeNB -> SgNB
SGNB_MODIFICATION_CONFIRM_FILTER = "x2ap.SgNBModificationConfirm_element " \
                                   "&& nr-rrc.rrcReconfigurationComplete_element"
