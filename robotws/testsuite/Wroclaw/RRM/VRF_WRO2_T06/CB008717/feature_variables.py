NGAP_SETUP_REQUEST = "(ngap.procedureCode==21)&&(ngap.NGAP_PDU==0)"
NGAP_SETUP_RESPONSE = "(ngap.procedureCode==21)&&(ngap.NGAP_PDU==1)"


F1AP_NRDCSN_CELL_IDENTITY = "(f1ap.nRCellIdentity==00:00:08:00:20)"
F1AP_SA_CELL_IDENTITY = "(f1ap.nRCellIdentity==00:00:08:00:10)"

F1AP_F1SETUP_REQUEST = "(f1ap.F1AP_PDU==0)&&(f1ap.procedureCode==1)&&(f1ap.GNB_DU_Served_Cells_List==1)"
F1AP_F1SETUP_RESPONSE = "(f1ap.procedureCode==1)&&(f1ap.F1AP_PDU==1)"
F1AP_GNB_CU_CONFIGURATION_UPDATE_FOR_CELL_ACTIVATION = "(f1ap.procedureCode==4)&&(f1ap.F1AP_PDU==0)&&" \
                                                        "(f1ap.Cells_to_be_Activated_List==1)"
F1AP_GNB_CU_CONFIGURATION_UPDATE_ACKNOWLEDGE = "(f1ap.procedureCode==4)&&(f1ap.F1AP_PDU==1)"
F1AP_GNB_DU_CONFIGURATION_UPDATE_FOR_CELL_ACTIVATION = "(f1ap.procedureCode==3)&&(f1ap.F1AP_PDU==0)&&" \
                                                        "(f1ap.Cells_Status_List==1)&&(f1ap.service_state==0)"
F1AP_GNB_DU_CONFIGURATION_UPDATE_ACKNOWLEDGE = "(f1ap.procedureCode==3)&&(f1ap.F1AP_PDU==1)"
F1AP_GNB_DU_CONFIGURATION_UPDATE_WITH_CELL_TO_ADD = "(f1ap.procedureCode==3)&&(f1ap.F1AP_PDU==0)&&" \
                                                    "(f1ap.Served_Cells_To_Add_List==1)"

# B1 Messages
F1AP_F1SETUP_REQUEST_WITH_SA_CELL = "(per.optional_field_bit==1)&&(f1ap.mIB_message)&&" \
                                    + F1AP_F1SETUP_REQUEST + "&&" + F1AP_SA_CELL_IDENTITY

F1AP_GNB_CU_CONFIGURATION_UPDATE_FOR_SA_CELL_ACTIVATION_FOR_B1 = F1AP_SA_CELL_IDENTITY + "&&" \
                                     + F1AP_GNB_CU_CONFIGURATION_UPDATE_FOR_CELL_ACTIVATION + "&&" \
                                     "(f1ap.sibtypetobeupdatedlist==4)&&(f1ap.TransactionID==0)"
F1AP_GNB_CU_CONFIGURATION_UPDATE_ACKNOWLEDGE_FOR_SA_CELL_ACTIVATION_FOR_B1 = "(f1ap.TransactionID==0)&&" \
                                     + F1AP_GNB_CU_CONFIGURATION_UPDATE_ACKNOWLEDGE
F1AP_GNB_DU_CONFIGURATION_UPDATE_FOR_SA_CELL_ACTIVATION_FOR_B1 = "(f1ap.TransactionID==0)&&" + F1AP_SA_CELL_IDENTITY \
                                     + "&&" + F1AP_GNB_DU_CONFIGURATION_UPDATE_FOR_CELL_ACTIVATION
F1AP_GNB_DU_CONFIGURATION_UPDATE_ACKNOWLEDGE_FOR_SA_CELL_ACTIVATION_FOR_B1 = "(f1ap.TransactionID==0)&&" \
                                     + F1AP_GNB_DU_CONFIGURATION_UPDATE_ACKNOWLEDGE

F1AP_GNB_DU_CONFIGURATION_UPDATE_WITH_NRDCSN_CELL_TO_ADD = F1AP_GNB_DU_CONFIGURATION_UPDATE_WITH_CELL_TO_ADD \
                                     + "&&" + F1AP_NRDCSN_CELL_IDENTITY + "&&" \
                                     "(per.optional_field_bit==0)&&(f1ap.TransactionID==1)"
F1AP_GNB_DU_CONFIGURATION_UPDATE_ACKNOWLEDGE_WITH_NRDCSN_CELL_TO_ADD = "(f1ap.TransactionID==1)&&" \
                                     + F1AP_GNB_DU_CONFIGURATION_UPDATE_ACKNOWLEDGE

F1AP_GNB_CU_CONFIGURATION_UPDATE_FOR_NRDCSN_CELL_ACTIVATION_FOR_B1 = F1AP_NRDCSN_CELL_IDENTITY + "&&" \
                                     + F1AP_GNB_CU_CONFIGURATION_UPDATE_FOR_CELL_ACTIVATION + "&&" \
                                     "(f1ap.iE_Extensions==1)&&(f1ap.TransactionID==1)"
F1AP_GNB_CU_CONFIGURATION_UPDATE_ACKNOWLEDGE_FOR_NRDCSN_CELL_ACTIVATION_FOR_B1 = "(f1ap.TransactionID==1)&&" \
                                     + F1AP_GNB_CU_CONFIGURATION_UPDATE_ACKNOWLEDGE
F1AP_GNB_DU_CONFIGURATION_UPDATE_FOR_NRDCSN_CELL_ACTIVATION_FOR_B1 = "(f1ap.TransactionID==2)&&" \
                                     + F1AP_NRDCSN_CELL_IDENTITY + "&&" \
                                     + F1AP_GNB_DU_CONFIGURATION_UPDATE_FOR_CELL_ACTIVATION
F1AP_GNB_DU_CONFIGURATION_UPDATE_ACKNOWLEDGE_FOR_NRDCSN_CELL_ACTIVATION_FOR_B1 = "(f1ap.TransactionID==2)&&" \
                                     + F1AP_GNB_DU_CONFIGURATION_UPDATE_ACKNOWLEDGE

# ALT1 Messages
F1AP_F1SETUP_REQUEST_WITH_NRDCSN_CELL = F1AP_F1SETUP_REQUEST + "&&" + F1AP_NRDCSN_CELL_IDENTITY

F1AP_GNB_DU_CONFIGURATION_UPDATE_WITH_SA_CELL_TO_ADD = F1AP_GNB_DU_CONFIGURATION_UPDATE_WITH_CELL_TO_ADD \
                                     + "&&" + F1AP_SA_CELL_IDENTITY + "&&" \
                                     "(per.optional_field_bit==1)&&(f1ap.TransactionID==0)&&(f1ap.mIB_message)"
F1AP_GNB_DU_CONFIGURATION_UPDATE_ACKNOWLEDGE_WITH_SA_CELL_TO_ADD = "(f1ap.TransactionID==0)&&" \
                                     + F1AP_GNB_DU_CONFIGURATION_UPDATE_ACKNOWLEDGE

F1AP_GNB_CU_CONFIGURATION_UPDATE_FOR_SA_CELL_ACTIVATION_FOR_ALT1 = F1AP_SA_CELL_IDENTITY + "&&" \
                                     + F1AP_GNB_CU_CONFIGURATION_UPDATE_FOR_CELL_ACTIVATION + "&&" \
                                     "(f1ap.sibtypetobeupdatedlist==4)&&(f1ap.TransactionID==0)"
F1AP_GNB_CU_CONFIGURATION_UPDATE_ACKNOWLEDGE_FOR_SA_CELL_ACTIVATION_FOR_ALT1 = "(f1ap.TransactionID==0)&&" \
                                     + F1AP_GNB_CU_CONFIGURATION_UPDATE_ACKNOWLEDGE
F1AP_GNB_DU_CONFIGURATION_UPDATE_FOR_SA_CELL_ACTIVATION_FOR_ALT1 = "(f1ap.TransactionID==1)&&" \
                                     + F1AP_SA_CELL_IDENTITY + "&&" \
                                     + F1AP_GNB_DU_CONFIGURATION_UPDATE_FOR_CELL_ACTIVATION
F1AP_GNB_DU_CONFIGURATION_UPDATE_ACKNOWLEDGE_FOR_SA_CELL_ACTIVATION_FOR_ALT1 = "(f1ap.TransactionID==1)&&" \
                                     + F1AP_GNB_DU_CONFIGURATION_UPDATE_ACKNOWLEDGE

F1AP_GNB_CU_CONFIGURATION_UPDATE_FOR_NRDCSN_CELL_ACTIVATION_FOR_ALT1 = F1AP_NRDCSN_CELL_IDENTITY + "&&" \
                                     + F1AP_GNB_CU_CONFIGURATION_UPDATE_FOR_CELL_ACTIVATION + "&&" \
                                     "(f1ap.iE_Extensions==1)&&(f1ap.TransactionID==1)"
F1AP_GNB_CU_CONFIGURATION_UPDATE_ACKNOWLEDGE_FOR_NRDCSN_CELL_ACTIVATION_FOR_ALT1 = "(f1ap.TransactionID==1)&&" \
                                     + F1AP_GNB_CU_CONFIGURATION_UPDATE_ACKNOWLEDGE
F1AP_GNB_DU_CONFIGURATION_UPDATE_FOR_NRDCSN_CELL_ACTIVATION_FOR_ALT1 = "(f1ap.TransactionID==2)&&" \
                                     + F1AP_NRDCSN_CELL_IDENTITY + "&&" \
                                     + F1AP_GNB_DU_CONFIGURATION_UPDATE_FOR_CELL_ACTIVATION
F1AP_GNB_DU_CONFIGURATION_UPDATE_ACKNOWLEDGE_FOR_NRDCSN_CELL_ACTIVATION_FOR_ALT1 = "(f1ap.TransactionID==2)&&" \
                                     + F1AP_GNB_DU_CONFIGURATION_UPDATE_ACKNOWLEDGE
# -GA Messages
F1AP_SERVED_CELLS_TO_ADD_LIST_IN_GNBDUCONFIGURATIONUPDATE = "f1ap.procedureCode == 3 && f1ap.id == 58"
F1AP_GNB_CONFIGURATION_UPDATE_ACKNOWLEDGE = "f1ap.procedureCode==3 && f1ap.F1AP_PDU==1"
F1AP_GNBDUCONFIGURTIONUPDATE_WITH_SERVICE_STATE_IN_SERVICE = "f1ap.service_state == 0 && f1ap.procedureCode == 3"
F1AP_CELLS_TO_BE_ACTIVATED_LIST_FOR_8_CELLS = "f1ap.id == 3 && f1ap.Cells_to_be_Activated_List == 8"
UU_SIBS_NOT_PRESENT_ON_FR2_CELLS = "iphy.protocol.type && nr-rrc.c1 == 1 && (iphy.cell_id == 2 || iphy.cell_id == 3 " \
                                   "|| iphy.cell_id == 4 || iphy.cell_id == 5 || iphy.cell_id == 6 || " \
                                   "iphy.cell_id == 7 || iphy.cell_id == 8 || iphy.cell_id == 9)"
F1AP_GNBDUCONFIGURTIONUPDATE_WITH_PCELL_ACTIVATION = "nr-rrc.freqBandIndicatorNR == 78 && f1ap.procedureCode == 4" \
                                          " && f1ap.Cells_to_be_Activated_List == 1"
# H_B1e Messages
F1AP_UE_CONTEXT_MODIFICATION_REQUEST_FOR_H_B1e = "(f1ap.UEContextModificationRequest_element)&&" \
                                        "!(nr-rrc.measGapConfig_element)&&(nr-rrc.measObjectToAddModList==4)&&" \
                                        "(nr-rrc.reportConfigToAddModList==2)&&(nr-rrc.measIdToAddModList==3)&&" \
                                        "(nr-rrc.ssbFrequency==2072539)&&(nr-rrc.ssbFrequency==2074267)&&" \
                                        "(nr-rrc.ssbFrequency==2075995)&&(nr-rrc.a4_Threshold==rsrp)&&" \
                                        "(nr-rrc.a4_Threshold==rsrp)&&(nr-rrc.hysteresis==0)&&" \
                                        "(nr-rrc.timeToTrigger==ms100)&&(nr-rrc.reportAmount==r4)&&" \
                                        "(nr-rrc.reportInterval==ms1024)"

F1AP_DLRRC_MESSAGE_TRANSFER_RRC_RECONFIGURATION_FOR_H_B1e = "(f1ap.DLRRCMessageTransfer_element)&&" \
                                        "!(nr-rrc.measGapConfig_element)&&(nr-rrc.measObjectToAddModList==3)&&" \
                                        "(nr-rrc.reportConfigToAddModList==2)&&(nr-rrc.measIdToAddModList==3)&&" \
                                        "(nr-rrc.ssbFrequency==2072539)&&(nr-rrc.ssbFrequency==2074267)&&" \
                                        "(nr-rrc.ssbFrequency==2075995)&&(nr-rrc.a4_Threshold==rsrp)&&" \
                                        "(nr-rrc.a4_Threshold==rsrp)&&(nr-rrc.hysteresis==0)&&" \
                                        "(nr-rrc.timeToTrigger==ms100)&&(nr-rrc.reportAmount==r4)&&" \
                                        "(nr-rrc.reportInterval==ms1024)&&(f1ap.RRCContainer)"

# H_B1F Messages
F1AP_UE_CONTEXT_MODIFICATION_REQUEST_FOR_H_B1F = "(f1ap.UEContextModificationRequest_element)&&" \
                                        "!(nr-rrc.measGapConfig_element)&&(nr-rrc.measObjectToAddModList==3)&&" \
                                        "(nr-rrc.reportConfigToAddModList==2)&&(nr-rrc.measIdToAddModList==2)&&" \
                                        "(nr-rrc.ssbFrequency==2072539)&&(nr-rrc.ssbFrequency==2074267)&&" \
                                        "(nr-rrc.ssbFrequency!=2075995)&&(nr-rrc.a4_Threshold==rsrp)&&" \
                                        "(nr-rrc.a4_Threshold==rsrq)&&(nr-rrc.hysteresis==0)&&" \
                                        "(nr-rrc.timeToTrigger==ms100)&&(nr-rrc.reportAmount==r4)&&" \
                                        "(nr-rrc.reportInterval==ms1024)"

F1AP_DLRRC_MESSAGE_TRANSFER_RRC_RECONFIGURATION_FOR_H_B1F = "(f1ap.DLRRCMessageTransfer_element)&&" \
                                        "!(nr-rrc.measGapConfig_element)&&(nr-rrc.measObjectToAddModList==2)&&" \
                                        "(nr-rrc.reportConfigToAddModList==2)&&(nr-rrc.measIdToAddModList==2)&&" \
                                        "(nr-rrc.ssbFrequency==2072539)&&(nr-rrc.ssbFrequency==2074267)&&" \
                                        "(nr-rrc.ssbFrequency!=2075995)&&(nr-rrc.a4_Threshold==rsrp)&&" \
                                        "(nr-rrc.a4_Threshold==rsrq)&&(nr-rrc.hysteresis==0)&&" \
                                        "(nr-rrc.timeToTrigger==ms100)&&(nr-rrc.reportAmount==r4)&&" \
                                        "(nr-rrc.reportInterval==ms1024)&&(f1ap.RRCContainer)"
# H_B1D Messages
F1AP_UE_CONTEXT_MODIFICATION_REQUEST_FOR_H_B1D = "(f1ap.UEContextModificationRequest_element)&&" \
                                        "(f1ap.procedureCode == 7)&&(nr-rrc.measObjectToAddModList == 3)&&" \
                                        "(nr-rrc.ssbFrequency == 2072539)&&(nr-rrc.ssbFrequency == 2074267)&&" \
                                        "(nr-rrc.a4_Threshold == 0)&&(nr-rrc.hysteresis == 0)&&" \
                                        "(nr-rrc.timeToTrigger == 4)&&(nr-rrc.reportAmount == 2)&&" \
                                        "(nr-rrc.reportInterval == 4)&&(nr-rrc.measIdToAddModList == 2)"

F1AP_DLRRC_MESSAGE_TRANSFER_RRC_RECONFIGURATION_FOR_H_B1D = "(f1ap.DLRRCMessageTransfer_element)&&" \
                                        "!(nr-rrc.measGapConfig_element)&&(nr-rrc.measObjectToAddModList==2)&&" \
                                        "(nr-rrc.reportConfigToAddModList==2)&&(nr-rrc.measIdToAddModList==2)&&" \
                                        "(nr-rrc.ssbFrequency==2072539)&&(nr-rrc.ssbFrequency==2074267)&&" \
                                        "(nr-rrc.ssbFrequency!=2075995)&&(nr-rrc.a4_Threshold==rsrp)&&" \
                                        "(nr-rrc.a4_Threshold==rsrp)&&(nr-rrc.hysteresis==0)&&" \
                                        "(nr-rrc.timeToTrigger==ms100)&&(nr-rrc.reportAmount==r4)&&" \
                                        "(nr-rrc.reportInterval==ms1024)&&(f1ap.RRCContainer)"

# H_EC1 Messages
F1AP_UE_CONTEXT_MODIFICATION_REQUEST_FOR_H_EC1 = "(f1ap.UEContextModificationRequest_element)&&" \
                                        "!(nr-rrc.measGapConfig_element)&&(nr-rrc.measObjectToAddModList==2)&&" \
                                        "(nr-rrc.reportConfigToAddModList==1)&&(nr-rrc.measIdToAddModList==1)&&" \
                                        "(nr-rrc.ssbFrequency==2072539)&&(nr-rrc.ssbFrequency!=2084059)&&" \
                                        "(nr-rrc.ssbFrequency!=2075995)&&(nr-rrc.a4_Threshold==rsrp)&&" \
                                        "(nr-rrc.hysteresis==0)&&(nr-rrc.reportInterval==ms1024)&&" \
                                        "(nr-rrc.timeToTrigger==ms100)&&(nr-rrc.reportAmount==r4)"

F1AP_DLRRC_MESSAGE_TRANSFER_RRC_RECONFIGURATION_FOR_H_EC1 = "(f1ap.DLRRCMessageTransfer_element)&&" \
                                        "!(nr-rrc.measGapConfig_element)&&(nr-rrc.measObjectToAddModList==1)&&" \
                                        "(nr-rrc.reportConfigToAddModList==1)&&(nr-rrc.measIdToAddModList==1)&&" \
                                        "(nr-rrc.ssbFrequency==2072539)&&(nr-rrc.ssbFrequency!=2084059)&&" \
                                        "(nr-rrc.ssbFrequency!=2075995)&&(nr-rrc.a4_Threshold==rsrp)&&" \
                                        "(nr-rrc.reportInterval==ms1024)&&(nr-rrc.hysteresis==0)&&" \
                                        "(nr-rrc.timeToTrigger==ms100)&&(nr-rrc.reportAmount==r4)&&" \
                                        "(f1ap.RRCContainer)"

F1AP_RRC_RECONFIGURATION_WITH_S_MEASURE_CONFIG = "(f1ap.DLRRCMessageTransfer_element)&&" \
                                        "(nr-rrc.s_MeasureConfig==0)&&(nr-rrc.ssb_RSRP==127)&&" \
                                        "(f1ap.RRCContainer)"


# H_B5a
F1AP_UE_CONTEXT_MODIFICATION_RESPONSE_FOR_H_B5A = "(f1ap.procedureCode == 7)&&" \
                                                  "(nr-rrc.csi_MeasConfig == 1)&&(nr-rrc.gapUE == 1)"

F1AP_RRC_RECONFIGURATION_WITH_CSI_MEASCONFIG = "(f1ap.procedureCode == 12)&&(nr-rrc.csi_MeasConfig == 1)&&" \
                                               "(nr-rrc.nzp_CSI_RS_ResourceToAddModList == 5)&&" \
                                               "(nr-rrc.nzp_CSI_RS_ResourceSetToAddModList == 2)&&" \
                                               "(nr-rrc.csi_IM_ResourceToAddModList == 1)&&" \
                                               "(nr-rrc.csi_IM_ResourceSetToAddModList == 1)&&" \
                                               "(nr-rrc.csi_ResourceConfigToAddModList == 3)&&" \
                                               "(nr-rrc.csi_ReportConfigToAddModList == 1)"


# H_B5a
F1AP_UE_CONTEXT_MODIFICATION_RESPONSE_FOR_H_B5A = "(f1ap.procedureCode == 7)&&" \
                                                  "(nr-rrc.csi_MeasConfig == 1)&&(nr-rrc.gapUE == 1)"

F1AP_RRC_RECONFIGURATION_WITH_CSI_MEASCONFIG = "(f1ap.procedureCode == 12)&&(nr-rrc.csi_MeasConfig == 1)&&" \
                                               "(nr-rrc.nzp_CSI_RS_ResourceToAddModList == 5)&&" \
                                               "(nr-rrc.csi_IM_ResourceToAddModList == 1)"

EGATE_CMD = "ue_nr_rrc_reconf_param id=1 if_contains=mrdc_scg_setup delay=4000 " \
            "if_contains=mrdc_scg_setup action=donot_send_scgNrResponse nth=2 if_contains=any action=drop nth=3"

# G_B81ab
E1AP_SETUP_REQUEST_G_B81 = "(e1ap.procedureCode == 3)&&(e1ap.SupportedPLMNs_List == 3)&&" \
                            "(e1ap.sST == 01)&&(e1ap.sD == 00:00:01)&&(e1ap.pLMN_Identity == 42:f4:90)&&" \
                            "(e1ap.pLMN_Identity == 32:f3:30)&&(e1ap.sST == 01)&&(e1ap.sD == 00:00:02)&&" \
                            "(e1ap.pLMN_Identity == 52:f5:50)&&(e1ap.sST == 01)&&(e1ap.sD == 00:00:03)"

F1AP_F1SETUP_REQUEST_WITH_SA_CELL_G_B81 = "(f1ap.procedureCode == 1)&&(f1ap.nRPCI == 51)&&(f1ap.fiveGS_TAC == 2)"

F1AP_GNB_DU_CONFIGURATION_UPDATE_WITH_NRDC_CELL_TO_ADD_WITH_PLMN3_AND_PLMN4_G_B81a = "(f1ap.procedureCode == 3)&&" \
                                "(f1ap.Served_Cells_To_Add_List == 1)&&(f1ap.nRPCI == 54)&&" \
                                "(f1ap.fiveGS_TAC == 4)&&(f1ap.pLMN_Identity == 13:41:98)&&" \
                                "(f1ap.servedPLMNs == 2)&&(f1ap.sST == 01)&&(f1ap.sD == 00:00:02)&&" \
                                "(f1ap.pLMN_Identity == 52:f5:50)&&(f1ap.sST == 01)&&(f1ap.sD == 00:00:03)&&" \
                                "(f1ap.BPLMN_ID_Info_List == 2)&&(f1ap.pLMNIdentity == 52:f5:50)&&" \
                                "(f1ap.fiveGS_TAC == 4)&&(f1ap.pLMNIdentity == 32:f3:30)&&(f1ap.fiveGS_TAC == 3)&&" \
                                "(f1ap.nr_cell_ID == 00:00:04:00:40)"

F1AP_GNB_DU_CONFIGURATION_UPDATE_WITH_NRDC_CELL_TO_ADD_WITH_PLMN3_AND_PLMN4_G_B81b = "(f1ap.procedureCode == 3)&&" \
                                "(f1ap.Served_Cells_To_Add_List == 1)&&(f1ap.nRPCI == 53)&&" \
                                "(f1ap.fiveGS_TAC == 3)&&(f1ap.pLMN_Identity == 13:41:98)&&" \
                                "(f1ap.servedPLMNs == 2)&&(f1ap.sST == 01)&&(f1ap.sD == 00:00:02)&&" \
                                "(f1ap.pLMN_Identity == 52:f5:50)&&(f1ap.sST == 01)&&(f1ap.sD == 00:00:03)&&" \
                                "(f1ap.BPLMN_ID_Info_List == 1)&&(f1ap.pLMNIdentity == 52:f5:50)&&" \
                                "(f1ap.pLMNIdentity == 32:f3:30)&&(f1ap.fiveGS_TAC == 3)&&" \
                                "(f1ap.nr_cell_ID == 00:00:04:00:30)"


NGAP_SETUP_REQUEST_G_B81 = "(ngap.procedureCode == 21)&&(ngap.tAC == 2)&&(ngap.pLMNIdentity == 13:41:98)"

F1AP_GNB_CU_CONFIGURATION_UPDATE_FOR_NRDC_CELL_ACTIVATION_WITH_PLMN3_AND_PLMN4 = "(f1ap.procedureCode == 4)&&" \
                                                "(f1ap.pLMNIdentity == 32:f3:30)&&(f1ap.pLMNIdentity == 52:f5:50)"

F1AP_GNB_CU_CONFIGURATION_UPDATE_FOR_NRDC_CELL_ACTIVATION_WITH_PLMN3_AND_PLMN4_G_B81b = "(f1ap.procedureCode == 4)&&" \
                                                "(f1ap.pLMNIdentity == 32:f3:30)&&(f1ap.pLMNIdentity == 52:f5:50)&&" \
                                                "(f1ap.nRCellIdentity == 00:00:04:00:30)"

F1AP_GNB_CU_CONFIGURATION_UPDATE_FOR_2ND_SA_CELL_ACTIVATION_WITH_PLMN3_AND_PLMN4 = "(f1ap.procedureCode == 4)&&" \
                                                "(f1ap.pLMNIdentity == 32:f3:30)&&(f1ap.pLMNIdentity == 52:f5:50)&&" \
                                                "(f1ap.nRCellIdentity == 00:00:04:00:20)"

NGAP_NGRAN_CONFIGURATION_UPDATE_FOR_SA_CELL_WITH_TAC3_ONLY_PLMN3 = "(ngap.procedureCode == 35)&&(ngap.tAC == 2)&&" \
                                                        "(ngap.tAC == 3)&&(ngap.pLMNIdentity == 32:f3:30)"

NGAP_NGRAN_CONFIGURATION_UPDATE_FOR_SA_CELL_WITH_TAC3_PLMN3_PLMN4 = "(ngap.procedureCode == 35)&&(ngap.tAC == 2)&&" \
                                                        "(ngap.tAC == 3)&&(ngap.pLMNIdentity == 32:f3:30)&&" \
                                                        "(ngap.pLMNIdentity == 52:f5:50)"

F1AP_GNB_DU_CONFIGURATION_UPDATE_WITH_CELL4_TO_ADD_WITH_PLMN = "(f1ap.procedureCode == 3)&&" \
                                "(f1ap.Served_Cells_To_Add_List == 1)&&(f1ap.nRPCI == 54)&&" \
                                "(f1ap.fiveGS_TAC == 3)&&(f1ap.servedPLMNs == 1)&&(f1ap.pLMN_Identity == 32:f3:30)&&" \
                                "(f1ap.iE_Extensions == 1)&&(f1ap.SliceSupportList == 1)&&(f1ap.sST == 01)&&" \
                                "(f1ap.sD == 00:00:02)&&(f1ap.BPLMN_ID_Info_List == 1)&&" \
                                "(f1ap.pLMN_Identity_List == 1)&&(f1ap.pLMNIdentity == 32:f3:30)&&" \
                                "(f1ap.fiveGS_TAC == 3)&&(f1ap.nr_cell_ID == 00:00:04:00:40)"

F1AP_GNB_DU_CONFIGURATION_UPDATE_WITH_CELL5_TO_ADD_WITH_PLMN = "(f1ap.procedureCode == 3)&&" \
                                "(f1ap.Served_Cells_To_Add_List == 1)&&(f1ap.nRPCI == 55)&&" \
                                "(f1ap.fiveGS_TAC == 4)&&(f1ap.servedPLMNs == 1)&&(f1ap.pLMN_Identity == 52:f5:50)&&" \
                                "(f1ap.iE_Extensions == 1)&&(f1ap.SliceSupportList == 1)&&(f1ap.sST == 01)&&" \
                                "(f1ap.sD == 00:00:03)&&(f1ap.BPLMN_ID_Info_List == 1)&&" \
                                "(f1ap.pLMN_Identity_List == 1)&&(f1ap.pLMNIdentity == 52:f5:50)&&" \
                                "(f1ap.fiveGS_TAC == 4)&&(f1ap.nr_cell_ID == 00:00:04:00:50)"


F1AP_GNB_CU_CONFIGURATION_UPDATE_FOR_CELL4_ACTIVATION_WITH_PLMN = "(f1ap.procedureCode == 4)&&" \
                                                "(f1ap.pLMN_Identity == 13:41:98)&&(f1ap.pLMNIdentity == 32:f3:30)&&" \
                                                "(f1ap.nRCellIdentity == 00:00:04:00:40)"

F1AP_GNB_CU_CONFIGURATION_UPDATE_FOR_CELL5_ACTIVATION_WITH_PLMN = "(f1ap.procedureCode == 4)&&" \
                                                "(f1ap.pLMN_Identity == 13:41:98)&&(f1ap.pLMNIdentity == 52:f5:50)"


# G_b9a

F1AP_F1SETUP_REQUEST_WITH_PCELL = "(f1ap.procedureCode == 1)&&(f1ap.nRPCI == 51)"

F1AP_GNB_CU_CONFIGURATION_UPDATE_FOR_NSA_PART_CELL_ACTIVATION = "(f1ap.procedureCode == 4)&&" \
                                                                "(f1ap.TransactionID == 0)&&" \
                                                                "(f1ap.Cells_to_be_Activated_List == 1)&&" \
                                                                "(f1ap.nRCellIdentity == 00:00:04:00:10)"

F1AP_GNB_CU_CONFIGURATION_UPDATE_FOR_SA_CELL_ACTIVATION = "(f1ap.procedureCode == 4)&&" \
                                                          "(f1ap.Cells_to_be_Activated_List == 1)&&" \
                                                          "(f1ap.nRCellIdentity == 00:00:04:00:10)&&" \
                                                          "(f1ap.sibtypetobeupdatedlist == 4)"

# JC_B12a
E1AP_BEARER_CONTEXT_INACTIVITY_NOTIFICATION = "(e1ap.procedureCode == 13)&&(e1ap.uE_Activity == 1)"
NGAP_UE_CONTEXT_RELEASE_REQUEST_FOR_JC_B12a = "(ngap.procedureCode == 42)&&(ngap.radioNetwork == 20)"


# JC_B19
F1AP_UE_CONTEXT_MODIFICATION_REQUEST_FOR_JC_B19 = "(f1ap.UEContextModificationRequest_element)&&" \
                                        "!(nr-rrc.measGapConfig_element)&&(nr-rrc.measObjectToAddModList==2)&&" \
                                        "(nr-rrc.reportConfigToAddModList==1)&&(nr-rrc.measIdToAddModList==1)&&" \
                                        "(nr-rrc.ssbFrequency==2071387)&&(nr-rrc.freqBandIndicatorNR==257)&&" \
                                        "(nr-rrc.a4_Threshold==rsrp)&& (nr-rrc.hysteresis==0)&&" \
                                        "(nr-rrc.timeToTrigger==ms5120)&&(nr-rrc.reportAmount==r4)&&" \
                                        "(nr-rrc.reportInterval==ms1024)"


F1AP_DLRRC_MESSAGE_TRANSFER_RRC_RECONFIGURATION_FOR_JC_B19 = "(f1ap.DLRRCMessageTransfer_element)&&" \
                                        "(nr-rrc.measGapConfig_element)&&(nr-rrc.measObjectToAddModList==1)&&" \
                                        "(nr-rrc.reportConfigToAddModList==1)&&(nr-rrc.measIdToAddModList==1)&&" \
                                        "(nr-rrc.ssbFrequency==2071387)&&(nr-rrc.freqBandIndicatorNR==257)&&" \
                                        "(nr-rrc.a4_Threshold==rsrp)&& (nr-rrc.hysteresis==0)&&" \
                                        "(nr-rrc.timeToTrigger==ms5120)&&(nr-rrc.reportAmount==r4)&&" \
                                        "(nr-rrc.reportInterval==ms1024)"

F1AP_UE_CONTEXT_RELEASE_COMMAND_FOR_JC_B19 = \
    "(f1ap.UEContextReleaseCommand_element) && (f1ap.RRCContainer) &&" \
    "(nr-rrc.cellReselectionPriorities_element) && (nr-rrc.freqPriorityListNR == 4) &&" \
    "(nr-rrc.carrierFreq == 295000) && (nr-rrc.cellReselectionPriority == 7) &&" \
    "(nr-rrc.carrierFreq == 286000) && (nr-rrc.cellReselectionPriority == 3) &&" \
    "(nr-rrc.carrierFreq == 158200) && (nr-rrc.cellReselectionPriority == 2) &&" \
    "(nr-rrc.carrierFreq == 633312) && (nr-rrc.cellReselectionPriority == 0)"
