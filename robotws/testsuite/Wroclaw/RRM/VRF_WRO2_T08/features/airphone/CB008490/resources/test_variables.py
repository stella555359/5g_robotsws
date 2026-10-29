XNAP_SETUP_RESPONSE_TO_SIM_MN = "(xnap.XnSetupResponse_element)&&(ip.dst==10.0.1.9)"
X2AP_SETUP_RESPONSE_WITH_NSA_CELL_INFO = "(x2ap.procedureCode == 36)&&(x2ap.nrpCI == 54)"
F1AP_NSA_CELL_TO_BE_ACTIVATED = "(f1ap.id == 3 && f1ap.Cells_to_be_Activated_List)&&" \
                                "(f1ap.nRCellIdentity == 00:00:0c:00:10)"
F1AP_WITH_SERVED_CELLS_TO_ADD_LIST = "(f1ap.procedureCode == 3)&&(f1ap.id == 58)"
XNAP_SETUP_REQUEST_SN_PEER = "(xnap.procedureCode == 17)&&(xnap)&&(xnap.nrPCI == 54)"
XNAP_SETUP_RESPONSE_FOR_BOTH = "(xnap.procedureCode == 17)&&(xnap)&&(xnap.nrPCI == 56)&&(xnap.nrPCI == 53)&&" \
                               "(xnap.nrPCI == 52)"
F1AP_NR_DC_SN_CELL_TO_BE_ACTIVATED_2 = "(f1ap.id == 3 && f1ap.Cells_to_be_Activated_List)&&" \
                                       "(f1ap.nRCellIdentity == 00:00:0c:00:20)"
F1AP_NR_DC_SN_CELL_TO_BE_ACTIVATED_3 = "(f1ap.id == 3 && f1ap.Cells_to_be_Activated_List)&&" \
                                       "(f1ap.nRCellIdentity == 00:00:0c:00:30)"
F1AP_NR_DC_SN_CELL_TO_BE_ACTIVATED_6 = "(f1ap.id == 3 && f1ap.Cells_to_be_Activated_List)&&" \
                                       "(f1ap.nRCellIdentity == 00:00:0c:00:60)"
F1AP_CELL_STATE_IN_SERVICE = "(f1ap.service_state == 0)&&(f1ap.procedureCode == 3)"
GA_MSGS = [X2AP_SETUP_RESPONSE_WITH_NSA_CELL_INFO, F1AP_NSA_CELL_TO_BE_ACTIVATED, XNAP_SETUP_RESPONSE_TO_SIM_MN,
           [F1AP_WITH_SERVED_CELLS_TO_ADD_LIST, 3], XNAP_SETUP_REQUEST_SN_PEER, [XNAP_SETUP_RESPONSE_FOR_BOTH, 2],
           F1AP_NR_DC_SN_CELL_TO_BE_ACTIVATED_2, F1AP_NR_DC_SN_CELL_TO_BE_ACTIVATED_3,
           F1AP_NR_DC_SN_CELL_TO_BE_ACTIVATED_6, [F1AP_CELL_STATE_IN_SERVICE, 4]]


XNAP_SETUP_REQUEST_MN_INITIATES_TO_SN = "(xnap.procedureCode == 17)&&(xnap)&&(xnap.nrPCI == 50)"
XNAP_SETUP_RESPONSE_SN_RECEIVES_FROM_MN = "(xnap.procedureCode == 17)&&(xnap)&&(xnap.nrPCI == 57)"
XNAP_SETUP_REQUEST_PEER_INITIATES_TO_SN = "(xnap.procedureCode == 17)&&(xnap.nrPCI == 51)&&(xnap.nrPCI == 52)"
F1AP_WITH_SERVED_CELLS_TO_ADD_LIST_UNLOCKED_CELL3 = "(f1ap.procedureCode == 3)&&(f1ap.id == 58)&&" \
                                                          "(f1ap.nRPCI == 53)"
F1AP_WITH_SERVED_CELLS_TO_ADD_LIST_UNLOCKED_CELL4 = "(f1ap.procedureCode == 3)&&(f1ap.id == 58)&&" \
                                                          "(f1ap.nRPCI == 54)"
F1AP_WITH_SERVED_CELLS_TO_ADD_LIST_ADDED_CELL5 = "(f1ap.procedureCode == 3)&&(f1ap.id == 58)&&(f1ap.nRPCI == 55)"
F1AP_WITH_SERVED_CELLS_TO_ADD_LIST_ADDED_CELL6 = "(f1ap.procedureCode == 3)&&(f1ap.id == 58)&&(f1ap.nRPCI == 56)"
XNAP_NGRANCONFIGURATION_WITH_SERVED_CELLS_TO_UPDATE_UNLOCKED_CELL3 = "(xnap.id == 68)&&(xnap.nrPCI == 53)"
XNAP_NGRANCONFIGURATION_WITH_SERVED_CELLS_TO_UPDATE_UNLOCKED_CELL4 = "(xnap.id == 68)&&(xnap.nrPCI == 54)"
XNAP_NGRANCONFIGURATION_WITH_SERVED_CELLS_TO_UPDATE_ADDED_CELL5_CELL6 = "(xnap.id == 68)&&(xnap.nrPCI == 55)&&" \
                                                                  "(xnap.nrPCI == 56)"
F1AP_CELL_TO_BE_ACTIVATED_UNLOCKED_CELL3 = "(f1ap.id == 3)&&(f1ap.nRCellIdentity == 00:00:0c:00:40)"
F1AP_CELL_TO_BE_ACTIVATED_UNLOCKED_CELL4 = "(f1ap.id == 3)&&(f1ap.nRCellIdentity == 00:00:0c:00:50)"
F1AP_CELL_TO_BE_ACTIVATED_ADDED_CELL5 = "(f1ap.id == 3)&&(f1ap.nRCellIdentity == 00:00:0c:00:60)"
F1AP_CELL_TO_BE_ACTIVATED_ADDED_CELL6 = "(f1ap.id == 3)&&(f1ap.nRCellIdentity == 00:00:0c:00:70)"
F1AP_CELL_STATE_IN_SERVICE = "(f1ap.service_state == 0)&&(f1ap.procedureCode == 3)"

GB_MSGS = [XNAP_SETUP_REQUEST_MN_INITIATES_TO_SN, XNAP_SETUP_RESPONSE_SN_RECEIVES_FROM_MN,
           [XNAP_SETUP_REQUEST_PEER_INITIATES_TO_SN, 2], F1AP_WITH_SERVED_CELLS_TO_ADD_LIST_UNLOCKED_CELL3,
           F1AP_WITH_SERVED_CELLS_TO_ADD_LIST_UNLOCKED_CELL4, F1AP_WITH_SERVED_CELLS_TO_ADD_LIST_ADDED_CELL5,
           F1AP_WITH_SERVED_CELLS_TO_ADD_LIST_ADDED_CELL6,
           [XNAP_NGRANCONFIGURATION_WITH_SERVED_CELLS_TO_UPDATE_UNLOCKED_CELL3, 2],
           [XNAP_NGRANCONFIGURATION_WITH_SERVED_CELLS_TO_UPDATE_UNLOCKED_CELL4, 2],
           [XNAP_NGRANCONFIGURATION_WITH_SERVED_CELLS_TO_UPDATE_ADDED_CELL5_CELL6, 2],
           F1AP_CELL_TO_BE_ACTIVATED_UNLOCKED_CELL3, F1AP_CELL_TO_BE_ACTIVATED_UNLOCKED_CELL4,
           F1AP_CELL_TO_BE_ACTIVATED_ADDED_CELL5, F1AP_CELL_TO_BE_ACTIVATED_ADDED_CELL6,
           [F1AP_CELL_STATE_IN_SERVICE, 6]]

NGRANNodeConfigurationUpdate = "xnap.procedureCode == 18 && xnap.nrPCI == 51 && xnap.tac == 2 && xnap.nrPCI == 52 &&\
xnap.id == 75 && ip.dst == 10.0.1.9"
NGRANNodeConfigurationUpdateFailure = "ip.src == 10.0.1.9  && xnap.procedureCode == 18 && xnap.Cause == 2 &&\
xnap.protocol == 6"
XnSetupReqAndResp = "xnap.procedureCode == 17"
XnSetupResponseWithUpdateInTac = "xnap.tac == 2 && xnap.procedureCode == 17 && xnap.sst == 01 && xnap.sd == 00:00:03 \
&& xnap.sd == 00:00:04 && ip.src == 10.0.1.3"
GC_MSGS = [[NGRANNodeConfigurationUpdate, 4], NGRANNodeConfigurationUpdateFailure, [XnSetupReqAndResp, 6],
           XnSetupResponseWithUpdateInTac]

NGRANNodeConfigurationUpdate_GF = "xnap.procedureCode == 18 && ip.dst == 10.0.1.9 && xnap.nrPCI == 53 && \
xnap.nrPCI == 54"
ErrorIndication = "xnap.procedureCode == 21 && xnap.procedureCode == 18 && xnap.triggeringMessage == 0"
GF_202_MSGS = [[XnSetupReqAndResp, 4], [NGRANNodeConfigurationUpdate_GF, 4], ErrorIndication]

NGRANNodeConfigurationUpdate_Cell_Delete = "ip.dst == 10.0.1.9 && xnap.procedureCode == 18 && \
xnap.served_Cells_ToDelete_NR == 1"
GF_302_MSGS = [[XnSetupReqAndResp, 4], [NGRANNodeConfigurationUpdate_Cell_Delete, 2]]
GF_SCTP_MSGS = ["sctp.chunk_type == 7", "sctp.chunk_type == 8", "sctp.chunk_type == 14"]

NGRANNodeConfigurationUpdate_Cells_Aggregation1 = "xnap.procedureCode == 18 && xnap.nrPCI == 53 && \
xnap.nrPCI == 55 && xnap.served_Cells_ToAdd_NR == 2"
NGRANNodeConfigurationUpdate_Cells_Aggregation2 = "xnap.procedureCode == 18 && xnap.nrPCI == 53 && \
xnap.nrPCI == 55 && xnap.served_Cells_ToAdd_NR == 2"
GH_MSGS = [[XnSetupReqAndResp, 4], [NGRANNodeConfigurationUpdate_Cells_Aggregation1, 2],
           [NGRANNodeConfigurationUpdate_Cells_Aggregation2, 2]]
ResetRequest = "xnap.ResetRequestTypeInfo == 1 && xnap.procedureCode == 20"
NgReset = "ngap.procedureCode == 20 && ngap.radioNetwork == 3"
NgRanConfigurationWithCorrectTa = "xnap.procedureCode == 18 && xnap.TAISupport_List == 2 && \
xnap.sd == 00:00:01 && xnap.sd == 00:00:0b && xnap.sd == 00:00:6f"
UeWith8CCConfirmation = "nr-rrc.sCellToAddModList == 7 && xnap.procedureCode == 7"
NgRanConfigurationWithCellsDeleted = "xnap.procedureCode == 18 && xnap.served_Cells_ToDelete_NR"
xn_link_sn_alarms = [("7107", "MRBTS-1/NRBTS-3/NRCELL-2"),
                     ("7107", "MRBTS-1/NRBTS-3/NRCELL-3"),
                     ("7107", "MRBTS-1/NRBTS-3/NRCELL-4")]
SYSLOG_MDT_LOG = ["Ue with cookie 0 on nrCellIdentity 32769 allocated with mdt, "
                  "current list size of UEs with MDT enabled is 1"]
CB0012328_X = [["nr-rrc.measurementReport_element", 2], "nr-rrc.mrdc_SecondaryCellGroupConfig==0",
               ["nr-rrc.RRCReconfiguration_element&&nr-rrc.mrdc_SecondaryCellGroupConfig==1", 2]]
