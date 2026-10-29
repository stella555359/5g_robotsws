XNAP_SETUP_REQUEST = "(xnap.procedureCode == 17)&&(xnap)&&(xnap.nrPCI == 50)"
XNAP_SETUP_RESPONSE = "(xnap.procedureCode == 17)&&(xnap)&&(xnap.nrPCI == 52)&&(xnap.nrPCI == 51)"

# GA201
XNAP_SETUP_RESPONSE_TO_SIM_MN = "(xnap.XnSetupResponse_element)&&(ip.dst==10.0.1.9)"
F1AP_F1SETUP_REQUEST_WITH_CELL_54 = "(f1ap.procedureCode == 1)&&(f1ap.nRPCI == 54)"
F1AP_WITH_SERVED_CELLS_TO_ADD_LIST = "(f1ap.procedureCode == 3)&&(f1ap.id == 58)"
X2AP_SETUP_RESPONSE_WITH_NSA_CELL_INFO = "(x2ap.procedureCode == 36)&&(x2ap.nrpCI == 54)"
F1AP_NSA_CELL_TO_BE_ACTIVATED = "(f1ap.id == 3 && f1ap.Cells_to_be_Activated_List)&&" \
                                "(f1ap.nRCellIdentity == 00:00:0c:00:10)"
XNAP_SETUP_REQUEST_SN_MN = "(xnap.procedureCode == 17)&&(xnap)&&(xnap.nrPCI == 50)"
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

# GB_101
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

# B102
F1AP_APPLIEDFREQBANDLISTFILTER_N257 = "(nr-rrc.appliedFreqBandListFilter == 1) && (ngap.procedureCode == 14) && " \
                                      "(nr-rrc.bandNR == 257)"
RRC_UE_CAPA_ENQ_n1_n257 = "(nr-rrc.frequencyBandListFilter == 3) && (nr-rrc.bandNR == 1) && (nr-rrc.bandNR == 257) " \
                           "&& (nr-rrc.c1 == 6)"
B102_INSUFFICIENT_UE_CAPA = '0410888820EE7A05000574F7E03560803C4A0002C10010180910600098385C00C4834000A040260300C45' \
                            '018053380A546C4DD608C21A08107483C00A2D954542439F40CFB027C639F30C7942C0E070F017FFFFF00' \
                            '1FFFFFC00283E006B04610D04083C41E00496CAA2A0A1CFA067C639F30C7942C0E070F027FFC00001FFF0' \
                            '0000283E20EB04610D04083C41E00496CAA2A0A1CFA067C639F30C7942C0E070F027F6000001FD800000A' \
                            '816826F1C610E00151E7E2878011FB660AA40078F0021C4106115028FDFC81B8DC6188000180E81680E06F' \
                            '1C610E00151E7E2878011FB660AA40078F0021C4106115028FDFC81B8FC7188000180A816806F1C610E00' \
                            '151E7E2878011FB660AA40078F0021C4106115028FDFC81BAFD71880001800318789A001D0030C001FFFFF' \
                            'FFFF107882001D0430C005FFFFFFFFF107800001D0030C003FFFFFFFFF001040065000760387030010181C' \
                            '0C93E2C3018181800E06204161C0C0040607031020A02A06890000890000810023D06E003E002800301014' \
                            '01C0C0250070006020211001042C0420010003278060080000092500E008020080200802008025C9280700' \
                            '401004010040100401300080000300F9415BA46E11831403040000259494101C0100401004010040100659' \
                            '494101C0100401004010040100A5949400000300F4A2AABB515CA8A0D54020808010020200801040402004' \
                            '0100600C2020100200802004050B900803280'

# GG_B101_B301
XNAP_SETUP_REQUEST_GG_B101 = '(xnap.XnSetupRequest_element)&&(xnap.plmn_id == 13:41:98)&&(e212.mcc == "311")&&' \
                             '(e212.mnc == "489")&&(xnap.TAISupport_List == 2)&&(xnap.tac == 1)&&' \
                             '(xnap.sst == 01)&&(xnap.sd == 00:00:01)&&(xnap.sst == 01)&&(xnap.sd == 00:00:02)&&' \
                             '(xnap.tac == 2)&&(xnap.sst == 01)&&(xnap.sd == 00:00:03)&&(xnap.sst == 01)&&' \
                             '(xnap.sd == 00:00:04)&&(xnap.nrPCI == 50)&&(xnap.nrPCI == 51)'
XNAP_SETUP_RESPONSE_GG_B101 = "(xnap.XnSetupResponse_element)&&(xnap.nrPCI == 52)&&(xnap.nrPCI == 53)"
F1AP_GNBDU_CONF_UPD_FOR_CELL1_GG_B101 = "(f1ap.Cells_Status_List == 1)&&(f1ap.service_state == 0)&&(f1ap.nRPCI == 50)"
F1AP_GNBDU_CONF_UPD_FOR_CELL2_GG_B101 = "(f1ap.Cells_Status_List == 1)&&(f1ap.service_state == 0)&&(f1ap.nRPCI == 51)"
XNAP_NG_RAN_CONF_UPD_GG_B301 = "(xnap.NGRANNodeConfigurationUpdate_element)&&(xnap.broadcastPLMNs == 1)&&" \
                               "(xnap.plmn_id == 13:41:98)&&(xnap.TAISupport_List == 2)&&(xnap.tac == 1)&&" \
                               "(xnap.sd == 00:00:01)&&(xnap.sd == 00:00:02)&&(xnap.broadcastPLMNs == 1)&&" \
                               "(xnap.plmn_id == 13:41:98)&&(xnap.tac == 2)&&(xnap.sd == 00:00:03)&&" \
                               "(xnap.sd == 00:00:04)&&(xnap.nrPCI == 54)"
XNAP_NG_RAN_CONF_UPD_ACK_GG_B301 = "(xnap.NGRANNodeConfigurationUpdateAcknowledge_element)"
F1AP_GNBDU_CONF_UPD_FOR_CELL1_2_GG_B301 = "(f1ap.GNBDUConfigurationUpdate_element)&&" \
                                          "(f1ap.Cells_Status_Item_element)&&(f1ap.service_status_element)&&" \
                                          "(f1ap.service_state == 0)"

# GG_401
F1AP_GNB_DU_CONFIGURATION_UPDATE_WITH_SERVED_CELL_INF_WITH_PLMN = "(f1ap.procedureCode == 3)&&"\
                                            "(f1ap.Served_Cells_To_Add_List == 1)&&(f1ap.nRPCI == 55)&&"\
                                            "(f1ap.fiveGS_TAC == 150)&&(f1ap.servedPLMNs == 2)&&"\
                                            "(f1ap.pLMN_Identity == 42:f4:90)&&(f1ap.SliceSupportList == 2)&&"\
                                            "(f1ap.sST == 01)&&(f1ap.sD == 00:00:02)&&(f1ap.sST == 01)&&"\
                                            "(f1ap.sD == 00:00:16)&&(f1ap.pLMN_Identity == 32:f3:30)&&"\
                                            "(f1ap.SliceSupportList == 2)&&(f1ap.sST == 01)&&"\
                                            "(f1ap.sD == 00:00:0d)&&(f1ap.sST == 01)&&(f1ap.sD == 00:00:85)"
F1AP_GNB_DU_CONFIGURATION_UPDATE_WITH_BROADCAST_PLMN_LIST = "(f1ap.procedureCode == 3)&&"\
                                            "(f1ap.Served_Cells_To_Add_List == 1)&&(f1ap.nRPCI == 55)&&" \
                                            "(f1ap.fiveGS_TAC == 150)&&(f1ap.BPLMN_ID_Info_List == 2)&&"\
                                            "(f1ap.pLMNIdentity == 42:f4:90)&& (f1ap.fiveGS_TAC == 150)&&" \
                                            "(f1ap.nr_cell_ID == 00:00:08:00:30)&&"\
                                            "(f1ap.pLMNIdentity == 32:f3:30)&&(f1ap.fiveGS_TAC == 250)&&"\
                                            "(f1ap.nr_cell_ID == 00:00:08:00:30)"
XNAP_NGRAN_NODE_CONFIGURATION_UPDATE_WITH_TAI_SUPPORT_LIST = "(xnap.procedureCode == 18)&&"\
                                            "(xnap.TAISupport_List == 4)&&(xnap.tac == 100)&&" \
                                            "(xnap.plmn_id == 13:41:98)&&(xnap.sst == 01)&&(xnap.sd == 00:00:01)&&" \
                                            "(xnap.sst == 01)&&(xnap.sd == 00:00:0b)&&(xnap.tac == 150)&&" \
                                            "(xnap.plmn_id == 42:f4:90)&&(xnap.sst == 01)&&(xnap.sd == 00:00:02)&&" \
                                            "(xnap.sst == 01)&&(xnap.sd == 00:00:16)&&(xnap.tac == 200)&&" \
                                            "(xnap.plmn_id == 32:f3:30)&&(xnap.sst == 01)&&(xnap.sd == 00:00:03)&&" \
                                            "(xnap.sst == 01)&&(xnap.sd == 00:00:21)&&(xnap.tac == 250)&&" \
                                            "(xnap.plmn_id == 32:f3:30)&&(xnap.sst == 01)&&(xnap.sd == 00:00:0d)&&" \
                                            "(xnap.sst == 01)&&(xnap.sd == 00:00:85)"
XNAP_NGRAN_NODE_CONFIGURATION_UPDATE_WITH_SERVED_CELL_INF = "(xnap.procedureCode == 18)&&"\
                                            "(xnap.id == 68)&&(xnap.served_Cells_ToAdd_NR == 1)&&(xnap.nrPCI == 55)&&"\
                                            "(xnap.tac == 150)&&(xnap.PLMN_Identity == 32:f3:30)&&"\
                                            "(xnap.BPLMN_ID_Info_NR == 2)&&(xnap.PLMN_Identity == 42:f4:90)&&"\
                                            "(xnap.tac == 150)&&(xnap.NR_Cell_Identity == 0x000008003)&&"\
                                            "(xnap.PLMN_Identity == 32:f3:30)&&(xnap.tac == 250)&&"\
                                            "(xnap.NR_Cell_Identity == 0x000008003)"
F1AP_NEW_CELL_STATE_IN_SERVICE = "(f1ap.service_state == 0)&&(f1ap.procedureCode == 3)&&" \
                                 "(f1ap.nRCellIdentity == 00:00:08:00:30)"

# GD_B101_B301
F1AP_GNBDU_CONF_UPD_FOR_CELL5_GD_B101_B301 = "f1ap.GNBDUConfigurationUpdate_element&&" \
                                    "f1ap.Served_Cells_To_Delete_Item_element&&f1ap.oldNRCGI_element&&" \
                                    "f1ap.nRCellIdentity == 00000c0050"
F1AP_GNBDU_CONF_UPD_FOR_CELL6_GD_B101_B301 = "f1ap.GNBDUConfigurationUpdate_element&&" \
                                    "f1ap.Served_Cells_To_Delete_Item_element&&f1ap.oldNRCGI_element&&" \
                                    "f1ap.nRCellIdentity == 00000c0060"
F1AP_GNBDU_CONF_UPD_FOR_CELL7_GD_B101_B301 = "f1ap.GNBDUConfigurationUpdate_element&&" \
                                    "f1ap.Served_Cells_To_Delete_Item_element&&f1ap.oldNRCGI_element&&" \
                                    "f1ap.nRCellIdentity == 00000c0070"
F1AP_GNBDU_CONF_UPD_FOR_CELL8_GD_B101_B301 = "f1ap.GNBDUConfigurationUpdate_element&&" \
                                    "f1ap.Served_Cells_To_Delete_Item_element&&f1ap.oldNRCGI_element&&" \
                                    "f1ap.nRCellIdentity == 00000c0070"
XNAP_NGRANNODE_CONF_UPD_FOR_CELL5_GD_B101_B301 = "xnap.NGRANNodeConfigurationUpdate_element&&" \
                                    "xnap.ServedCellsToUpdate_NR_element&&xnap.served_Cells_ToDelete_NR&&" \
                                    "xnap.NR_CGI_element&&xnap.NR_Cell_Identity == 0x000000000000c005"
XNAP_NGRANNODE_CONF_UPD_FOR_CELL6_GD_B101_B301 = "xnap.NGRANNodeConfigurationUpdate_element&&" \
                                    "xnap.ServedCellsToUpdate_NR_element&&xnap.served_Cells_ToDelete_NR&&" \
                                    "xnap.NR_CGI_element&&xnap.NR_Cell_Identity == 0x000000000000c006"
XNAP_NGRANNODE_CONF_UPD_FOR_CELL7_GD_B101_B301 = "xnap.NGRANNodeConfigurationUpdate_element&&" \
                                    "xnap.ServedCellsToUpdate_NR_element&&xnap.served_Cells_ToDelete_NR&&" \
                                    "xnap.NR_CGI_element&&xnap.NR_Cell_Identity == 0x000000000000c007"
XNAP_NGRANNODE_CONF_UPD_FOR_CELL8_GD_B101_B301 = "xnap.NGRANNodeConfigurationUpdate_element&&" \
                                    "xnap.ServedCellsToUpdate_NR_element&&xnap.served_Cells_ToDelete_NR&&" \
                                    "xnap.NR_CGI_element&&xnap.NR_Cell_Identity == 0x000000000000c008"
XNAP_NGRANNODE_CONF_UPD_FOR_CELL5_AND_CELL6_REMOVAL_GD_B101_B301 = \
    ("xnap.NGRANNodeConfigurationUpdate_element && xnap.TAISupport_List == 2 && xnap.tac == 100 && "
     "xnap.tAISliceSupport_List == 2 && xnap.plmn_id == 13:41:98 && xnap.sst == 01: && xnap.sd == 00:00:01 && "
     "xnap.sst == 01: && xnap.sd == 00:00:0b  && xnap.tac == 150 && xnap.tAISliceSupport_List == 2 && "
     "xnap.plmn_id == 42:f4:90 && xnap.sst == 01: && xnap.sd == 00:00:02 && xnap.sst == 01: && xnap.sd == 00:00:16")
XNAP_SETUP_RESPONSE_TO_SN_B101_B301 = "(xnap.XnSetupResponse_element)&&(ip.dst==10.0.1.2)"
F1AP_GNBDU_CONF_UPD_FOR_LAST_ACTIVE_CELL_REMOVAL_GD_B101_B301 = "f1ap.Served_Cells_To_Delete_Item_element&&" \
                                    "f1ap.oldNRCGI_element&&f1ap.nRCellIdentity==00000c0010"
XNAP_SNODE_RELEASE_REQUIRED = "(xnap.SNodeReleaseRequired_element)&&(xnap.radioNetwork == 22)"
