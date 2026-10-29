EN_DC_RECONFIGURATION_WITH_CA_WITHOUT_A2 = ("x2ap.SgNBAdditionRequestAcknowledge_element && nr-rrc.physCellId == 52 "
                                            "&& nr-rrc.sCellToAddModList == 1 && nr-rrc.physCellId == 53 && "
                                            "nr-rrc.measObjectToAddModList == 2 && !nr-rrc.eventId == 1 && "
                                            "nr-rrc.FreqBandIndicatorNR == 25 && nr-rrc.FreqBandIndicatorNR == 26")
EN_DC_RECONFIGURATION_WITHOUT_CA = ("x2ap.SgNBAdditionRequestAcknowledge_element && nr-rrc.physCellId == 52 && "
                                    "!nr-rrc.sCellToAddModList")
EN_DC_RECONFIGURATION_TDD_CELL = "x2ap.SgNBAdditionRequestAcknowledge_element && nr-rrc.physCellId == 50"
SGNB_RECONFIGURATION_COMPLETE = "x2ap.SgNBReconfigurationComplete_element"
SGNB_RECONFIGURATION_BUFFER_BASED = ("x2ap.SgNBModificationRequired_element && nr-rrc.sCellToAddModList == 1 && "
                                     "nr-rrc.physCellId == 53 && nr-rrc.FreqBandIndicatorNR == 25  && "
                                     "nr-rrc.measIdToRemoveList == 1 && nr-rrc.MeasId == 3")
SGNB_MODIFICATION_CONFIRM = "x2ap.SgNBModificationConfirm_element"
CB014151_FLOW = [EN_DC_RECONFIGURATION_WITH_CA_WITHOUT_A2, EN_DC_RECONFIGURATION_TDD_CELL,
                 EN_DC_RECONFIGURATION_WITHOUT_CA, [SGNB_RECONFIGURATION_COMPLETE, 3]]
CB014151_BUFFER_BASED_FLOW = [EN_DC_RECONFIGURATION_WITHOUT_CA, SGNB_RECONFIGURATION_COMPLETE,
                              SGNB_RECONFIGURATION_BUFFER_BASED, [SGNB_MODIFICATION_CONFIRM, 2]]
SYSLOG_ALGORITHM_PSCELL = ["orderPsCellCandidateListByPriorities: ordered candidateCells ["
                           "{cellId: 16385, weightedDlResources: 250000000, weightedRsrpRsrq: 0} , "
                           "{cellId: 16387, weightedDlResources: 50000000, weightedRsrpRsrq: 0} ]",
                           "orderPsCellCandidateListByCaAware: the origin candidateCells [16385, 16387], "
                           "caPossibleCellList [16387], caImpossibleCellList [16385], reOrderCellList [16387, 16385]",
                           "Fr1 report cell caCheckInfo [(16385, false), (16387, true)]",
                           "Fr1 all cell caCheckInfo [(16385, false), (16387, true)]"]
