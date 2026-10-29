ICS_REQ_FIVEQI9 = "ngap.InitialContextSetupRequest_element && ngap.pDUSessionID == 1 && \
ngap.QosFlowSetupRequestList == 1 && ngap.fiveQI == 9"
ICS_REQ_FIVEQI5_PDU1 = "ngap.PDUSessionResourceModifyRequest_element && ngap.pDUSessionID == 1 && \
ngap.QosFlowAddOrModifyRequestList == 1 && ngap.fiveQI == 5"
ICS_REQ_FIVEQI98 = "ngap.InitialContextSetupRequest_element && ngap.pDUSessionID == 1 && \
ngap.QosFlowSetupRequestList == 2 && ngap.fiveQI == 9 && ngap.fiveQI == 8"
ICS_RESP = "ngap.PDUSessionResourceModifyResponse_element && ngap.pDUSessionID == 1 && ngap.qosFlowIdentifier == 2"
PDU_SETUP_REQ_FIVEQI5 = "ngap.PDUSessionResourceSetupRequest_element && ngap.pDUSessionID == 2 && \
ngap.QosFlowSetupRequestList == 1 && ngap.fiveQI == 5"
PDU_SETUP_REQ_FIVEQI15 = "ngap.PDUSessionResourceSetupRequest_element && ngap.pDUSessionID == 2 && \
ngap.QosFlowSetupRequestList == 2 && ngap.fiveQI == 5 && ngap.fiveQI == 1"
PDU_SETUP_REQ_FIVEQI125 = "ngap.PDUSessionResourceSetupRequest_element && ngap.pDUSessionID == 2 && \
ngap.QosFlowSetupRequestList == 3 && ngap.fiveQI == 5 && ngap.fiveQI == 1 && ngap.fiveQI == 2"
PDU_SETUP_RESP_1 = "ngap.PDUSessionResourceSetupResponse_element && ngap.pDUSessionID == 2 && \
ngap.qosFlowIdentifier == 1"
PDU_SETUP_RESP_QOS_1_2 = "ngap.PDUSessionResourceSetupResponse_element && ngap.pDUSessionID == 2 && \
ngap.qosFlowIdentifier == 1 && ngap.qosFlowIdentifier ==2"
PDU_SETUP_RESP_QOS_1_2_3 = "ngap.PDUSessionResourceSetupResponse_element && ngap.pDUSessionID == 2 && \
ngap.qosFlowIdentifier == 1 && ngap.qosFlowIdentifier ==2 && ngap.qosFlowIdentifier ==3"
RRC_RECONF_CGI_GAP_REL = "nr-rrc.rrcReconfiguration_element && nr-rrc.measObjectToRemoveList == 1 && \
nr-rrc.MeasObjectId == 2 && nr-rrc.reportConfigToRemoveList == 2 && nr-rrc.gapFR1 == 0 && nr-rrc.cellGroupId == 0"
RRC_RECONF_CGI_GAP_REL_1_MEAS = "nr-rrc.rrcReconfiguration_element && nr-rrc.measObjectToRemoveList == 1 && \
nr-rrc.MeasObjectId == 2 && nr-rrc.reportConfigToRemoveList == 1 && nr-rrc.gapUE == 0 && nr-rrc.cellGroupId == 0"
RRC_MEAS_ROLLBACK = "nr-rrc.rrcReconfiguration_element && nr-rrc.reportConfigToRemoveList == 2 && \
nr-rrc.ReportConfigId == 4 && nr-rrc.ReportConfigId == 6 && nr-rrc.reportConfigId == 7 && \
nr-rrc.measIdToRemoveList == 1 && nr-rrc.MeasId == 4"
PDU_MOD_REQ_FIVEQI8 = "ngap.PDUSessionResourceModifyRequest_element && ngap.pDUSessionID == 1 && \
ngap.QosFlowAddOrModifyRequestList == 1 && ngap.fiveQI == 8"
PDU_MOD_REQ_FIVEQI1 = "ngap.PDUSessionResourceModifyRequest_element && ngap.pDUSessionID == 2 && \
ngap.QosFlowAddOrModifyRequestList == 1 && ngap.fiveQI == 1"
PDU_MOD_REQ_QOS_FLOW_REMOVE = "ngap.PDUSessionResourceModifyRequest_element && ngap.id == 137 && \
ngap.qosFlowIdentifier == 2"
RRC_RECONF_CGI_DRX_SETUP = "nr-rrc.rrcReconfiguration_element && nr-rrc.cellForWhichToReportCGI == 52 && \
nr-rrc.drx_Config == 1"
RRC_RECONF_CGI_ANR_DRX_SETUP = "nr-rrc.rrcReconfiguration_element && nr-rrc.cellForWhichToReportCGI == 50 && \
nr-rrc.drx_Config == 1 && nr-rrc.drx_LongCycleStartOffset == 11"
RRC_RECONF_MEAS_REMOVE = "nr-rrc.rrcReconfiguration_element && nr-rrc.reportConfigToRemoveList == 2 && \
nr-rrc.ReportConfigId == 4 && nr-rrc.ReportConfigId == 7 && nr-rrc.eventId == 1"
PDU_MOD_RESP_FAIL = "ngap.PDUSessionResourceModifyResponse_element && ngap.pDUSessionID == 1 && \
ngap.radioNetwork == 22"
PDU_MOD_RESP_FALLBACK = "ngap.PDUSessionResourceModifyResponse_element && ngap.pDUSessionID == 2 && \
ngap.radioNetwork == 36"
RRC_RECONF_DRX_REMOVE = "nr-rrc.rrcReconfiguration_element && nr-rrc.drx_Config == 0"
PDU_MOD_RESP = "ngap.PDUSessionResourceModifyResponse_element && ngap.pDUSessionID == 1 && \
ngap.pDUSessionResourceModifyResponseTransfer == 00"
RRC_RECONF_DRX_SETUP = "nr-rrc.rrcReconfiguration_element && nr-rrc.drx_Config == 1 && \
nr-rrc.drx_LongCycleStartOffset == 9"
RRC_RECONF_DRX_SETUP2 = "nr-rrc.rrcReconfiguration_element && nr-rrc.drx_Config == 1 && \
nr-rrc.drx_LongCycleStartOffset == 3"
RRC_RECONFIGURATION_NRCGI_MEAS_REPORT_PCI_52 = "nr-rrc.rrcReconfiguration_element && nr-rrc.reportType == reportCGI \
&& nr-rrc.cellForWhichToReportCGI == 52 && nr-rrc.drx_Config == 1 && nr-rrc.drx_LongCycleStartOffset == 13 && \
nr-rrc.milliSeconds == 8 && nr-rrc.drx_InactivityTimer == 14"
RRC_RECONFIGURATION_NRCGI_MEAS_REPORT_PCI_51 = "nr-rrc.rrcReconfiguration_element && nr-rrc.reportType == reportCGI \
&& nr-rrc.cellForWhichToReportCGI == 51 && nr-rrc.drx_Config == 1 && nr-rrc.drx_LongCycleStartOffset == 11 && \
nr-rrc.milliSeconds == 8 && nr-rrc.drx_InactivityTimer == 14"
PDU_SESSION_2_RESOURCE_MODIFY_REQUEST_5QI_1_2 = "ngap.PDUSessionResourceModifyRequest_element && \
ngap.pDUSessionID == 2 && ngap.qosFlowIdentifier == 3 && ngap.fiveQI == 1 && ngap.qosFlowIdentifier == 2 && \
ngap.fiveQI == 2"
PDU_SESSION_2_RESOURCE_MODIFY_RESPONSE_5QI_1_2 = "ngap.PDUSessionResourceModifyResponse_element && \
ngap.pDUSessionID == 2 && ngap.radioNetwork == ims-voice-eps-fallback-or-rat-fallback-triggered"
RRC_RECONFIGURATION_EVENT_A2 = "nr-rrc.rrcReconfiguration_element && nr-rrc.measObjectToRemoveList == 1 && \
nr-rrc.eventId == eventA2 && nr-rrc.reportConfigToAddModList == 1"
RRC_RELEASE_TO_EUTRA = "nr-rrc.rrcRelease_element && nr-rrc.eutraFrequency == 4200 && \
nr-rrc.redirectedCarrierInfo == eutra"
MEAS_REP_UNKNOW_CELL = "nr-rrc.measurementReport_element && nr-rrc.measId == 3 && nr-rrc.physCellId == 50 && \
nr-rrc.measQuantityResults.rsrq == 17 && nr-rrc.physCellId == 150 && nr-rrc.measQuantityResults.rsrq == 125"
RRC_RECONF_CGI_UNKNOWN_CELL_DRX_SETUP = "nr-rrc.rrcReconfiguration_element && nr-rrc.reportType == reportCGI && \
nr-rrc.cellForWhichToReportCGI == 150 && nr-rrc.drx_Config == 1 && nr-rrc.drx_LongCycleStartOffset == 13"
RRC_RECONF_UNKNOWN_CELL_DRX_SETUP = "nr-rrc.rrcReconfiguration_element && nr-rrc.cellForWhichToReportCGI == 150 && \
nr-rrc.drx_Config == 1 && nr-rrc.drx_LongCycleStartOffset == 13"
RRC_RECONF_CGI_UNKNOWN_CELL_DRX_SETUP_11 = "nr-rrc.rrcReconfiguration_element && nr-rrc.reportType == reportCGI && \
nr-rrc.cellForWhichToReportCGI == 150 && nr-rrc.drx_Config == 1 && nr-rrc.drx_LongCycleStartOffset == 11"
MEAS_REP_UNKNOW_CELL2 = "nr-rrc.measurementReport_element && nr-rrc.measId == 4 && nr-rrc.physCellId == 50 && \
nr-rrc.physCellId == 150 && nr-rrc.plmn_IdentityInfoList == 1"
RRC_RELEASE_WITH_REDIRECT = "nr-rrc.rrcRelease_element && nr-rrc.eutraFrequency == 1350"
UE_CONTEXT_MOD_REQ_AMBR = "ngap.UEContextModificationRequest_element && \
ngap.uEAggregateMaximumBitRateDL == 5242880 && ngap.uEAggregateMaximumBitRateUL == 5242880"
RRC_EVENT_A2 = "nr-rrc.rrcReconfiguration_element && nr-rrc.reportConfigToRemoveList == 2 && nr-rrc.eventId == 1"
RRC_EVENT_A3 = "nr-rrc.rrcReconfiguration_element && nr-rrc.eventId == 2 && nr-rrc.gapUE == 1"
XNAP_HANDOVER_REQUEST = "xnap.HandoverRequest_element"
XNAP_HANDOVER_REQUEST_FIVEQI_59 = "xnap.HandoverRequest_element && xnap.fiveQI == 9 && xnap.fiveQI == 5"
XN_SETUP_REQUEST = "xnap.XnSetupRequest_element"
XN_SETUP_RESPONSE = "xnap.XnSetupResponse_element"
RRC_ANR_REMOVE_EDA = 'nr-rrc.rrcReconfiguration_element && nr-rrc.measIdToAddModList == 1 && nr-rrc.measId == 12 && \
nr-rrc.measObjectId == 4 && nr-rrc.reportConfigId == 8'
A_B1_TCP = [[RRC_RECONF_DRX_REMOVE, 2], RRC_RECONFIGURATION_NRCGI_MEAS_REPORT_PCI_52, RRC_RECONFIGURATION_EVENT_A2]
A_B1_NGAP = [ICS_REQ_FIVEQI9, PDU_SETUP_REQ_FIVEQI15, PDU_SETUP_RESP_QOS_1_2]
A_B3_TCP = [[RRC_RECONF_DRX_REMOVE, 3], RRC_RECONFIGURATION_NRCGI_MEAS_REPORT_PCI_51]
A_B3_NGAP = [ICS_REQ_FIVEQI9, PDU_SETUP_REQ_FIVEQI125, PDU_SETUP_RESP_QOS_1_2_3]
A_B11_5_TCP = [RRC_RECONF_CGI_GAP_REL, RRC_RECONF_CGI_DRX_SETUP, RRC_RECONF_MEAS_REMOVE]
A_B11_5_NGAP = [ICS_REQ_FIVEQI9, PDU_SETUP_REQ_FIVEQI5, PDU_SETUP_RESP_1, PDU_MOD_REQ_FIVEQI8, PDU_MOD_RESP_FAIL]
A_B11_6_TCP = [RRC_RECONF_CGI_GAP_REL, RRC_RECONF_CGI_DRX_SETUP, [RRC_RECONF_DRX_REMOVE, 2], [RRC_RECONF_DRX_SETUP, 2]]
A_B11_6_NGAP = [ICS_REQ_FIVEQI98, PDU_SETUP_REQ_FIVEQI5, PDU_SETUP_RESP_1, PDU_MOD_REQ_QOS_FLOW_REMOVE, PDU_MOD_RESP]
A_B4_TCP = [RRC_RECONFIGURATION_NRCGI_MEAS_REPORT_PCI_52, RRC_RELEASE_TO_EUTRA]
A_B4_NGAP = [ICS_REQ_FIVEQI9, PDU_SETUP_REQ_FIVEQI5, PDU_SESSION_2_RESOURCE_MODIFY_REQUEST_5QI_1_2,
             PDU_SESSION_2_RESOURCE_MODIFY_RESPONSE_5QI_1_2]
B_B3_TCP = [MEAS_REP_UNKNOW_CELL, [RRC_RECONF_DRX_REMOVE, 2], RRC_RECONF_CGI_UNKNOWN_CELL_DRX_SETUP,
            MEAS_REP_UNKNOW_CELL2, [RRC_RECONF_DRX_SETUP, 2], RRC_RELEASE_WITH_REDIRECT]
B_B3_NGAP = [ICS_REQ_FIVEQI9, PDU_SETUP_REQ_FIVEQI5, PDU_SETUP_RESP_1, PDU_MOD_REQ_FIVEQI1, XNAP_HANDOVER_REQUEST,
             PDU_MOD_RESP_FALLBACK]
A_B11_2_TCP = [RRC_RECONF_DRX_SETUP, RRC_RECONF_CGI_GAP_REL, RRC_RECONF_CGI_ANR_DRX_SETUP,
               RRC_RELEASE_TO_EUTRA]
A_B11_2_NGAP = [ICS_REQ_FIVEQI9, PDU_SETUP_REQ_FIVEQI5, PDU_SETUP_RESP_1, PDU_MOD_REQ_FIVEQI1, PDU_MOD_RESP_FALLBACK]
A_B10_TCP = [RRC_RECONF_CGI_GAP_REL_1_MEAS, RRC_RECONF_CGI_UNKNOWN_CELL_DRX_SETUP, RRC_MEAS_ROLLBACK,
             RRC_RECONF_DRX_SETUP2]
A_B10_NGAP = [ICS_REQ_FIVEQI9, PDU_SETUP_REQ_FIVEQI5, PDU_SETUP_RESP_1, XNAP_HANDOVER_REQUEST_FIVEQI_59,
              PDU_MOD_REQ_FIVEQI1]
C_B_TCP = [RRC_RECONF_CGI_GAP_REL_1_MEAS, [RRC_RECONF_UNKNOWN_CELL_DRX_SETUP, 2], [RRC_EVENT_A2, 2], [RRC_EVENT_A3, 6]]
C_B_NGAP = [[ICS_REQ_FIVEQI9, 50], ICS_REQ_FIVEQI5_PDU1, ICS_RESP, UE_CONTEXT_MOD_REQ_AMBR, [XN_SETUP_REQUEST, 2],
            [XN_SETUP_RESPONSE, 2], XNAP_HANDOVER_REQUEST]
A_B10_TCP_EDA = [RRC_ANR_REMOVE_EDA]
A_B10_NGAP_EDA = [[XNAP_HANDOVER_REQUEST_FIVEQI_59, 5], "xnap.HandoverPreparationFailure_element"]
ANR_RECHECK_STATE = ["Update for fetched relation object. Status received from CP-UE: pciConfirmed, "
                     "current relation status: PciStatus::recheck."]
PCI_RESOLUTION_REMOVE_MEASUREMENTS_AND_MEAS_GAPS = ("nr-rrc.measObjectToRemoveList==2&&"
                                                    "nr-rrc.reportConfigToRemoveList==3&&"
                                                    "nr-rrc.measIdToRemoveList==3&&nr-rrc.gapFR1==0&&"
                                                    "nr-rrc.cellGroupId==0")
PCI_RESOLUTION_CGI_REPORT = ("nr-rrc.measObjectToAddModList==1&&nr-rrc.reportConfigToAddModList==1&&"
                             "nr-rrc.reportType==2&&nr-rrc.measIdToAddModList==1&&nr-rrc.drx_Config==1")
PCI_RESOLUTION_REPORT_CGI_51 = PCI_RESOLUTION_CGI_REPORT + ("&&nr-rrc.cellForWhichToReportCGI==51&&"
                                                            "nr-rrc.drx_LongCycleStartOffset==11")
PCI_RESOLUTION_REPORT_CGI_11 = PCI_RESOLUTION_CGI_REPORT + ("&&nr-rrc.cellForWhichToReportCGI==11&&"
                                                            "nr-rrc.drx_LongCycleStartOffset==9")
PCI_RESOLUTION_REPORT_CGI_52 = PCI_RESOLUTION_CGI_REPORT + ("&&nr-rrc.cellForWhichToReportCGI==52&&"
                                                            "nr-rrc.drx_LongCycleStartOffset==13")
ROLLBACK_AFTER_PCI_RESOLUTION = ("nr-rrc.measObjectToRemoveList==1&&nr-rrc.measObjectToAddModList==1&&"
                                 "nr-rrc.reportConfigToRemoveList==2&&nr-rrc.reportConfigToAddModList==1&&"
                                 "nr-rrc.eventId==1&&nr-rrc.measIdToRemoveList==1&&nr-rrc.measIdToAddModList==1&&"
                                 "nr-rrc.drx_Config==0")
DRX_RELEASE_INTRA_FREQ = "nr-rrc.rrcReconfiguration_element&&nr-rrc.drx_Config==0&&!nr-rrc.measObjectToAddModList"
DRX_SETUP_BASIC = ("nr-rrc.rrcReconfiguration_element&&nr-rrc.drx_Config==1&&"
                   "nr-rrc.drx_LongCycleStartOffset==9&&!nr-rrc.measObjectToAddModList")
TOTAL_MEASUREMENT_REPORTS = "nr-rrc.criticalExtensions==0&&nr-rrc.measResultNeighCells"
HO_CANCEL = "ngap.HandoverRequired_element||ngap.HandoverCancel_element||ngap.HandoverCancelAcknowledge_element"
UE_CONTEXT_FAILURE_AND_REFUSE_AND_REQUIRED = ("f1ap.UEContextModificationFailure_element&&"
                                              "f1ap.UEContextModificationRefuse_element||"
                                              "f1ap.UEContextModificationRequired_element")
CB0126048_TCP = [[PCI_RESOLUTION_REMOVE_MEASUREMENTS_AND_MEAS_GAPS, 4], PCI_RESOLUTION_REPORT_CGI_51,
                 [PCI_RESOLUTION_REPORT_CGI_11, 2], [PCI_RESOLUTION_REPORT_CGI_52, 2],
                 [ROLLBACK_AFTER_PCI_RESOLUTION, 4], [DRX_RELEASE_INTRA_FREQ, 1],
                 [DRX_SETUP_BASIC, 1], [TOTAL_MEASUREMENT_REPORTS, 8]]
CB0126048_NGAP = [[HO_CANCEL, 3], [UE_CONTEXT_FAILURE_AND_REFUSE_AND_REQUIRED, 0]]
