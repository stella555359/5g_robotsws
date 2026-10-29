CA_UE_ID1 = 1
CA_UE_ID2 = 2

F1_SCELLS_TO_BE_REMOVED = "f1ap.SCell_ToBeRemoved_List == 2"
F1_SCELLS_TO_RELEASE = "nr-rrc.sCellToReleaseList == 2"

XYZ = ' && '.join(
    [F1_SCELLS_TO_BE_REMOVED,
     F1_SCELLS_TO_RELEASE])

F1AP_RECONFIGURE_TO_3CC_SCELLS_B_C = "(f1ap.procedureCode == id-UEContextModification) && " \
                                     "f1ap.SCell_ToBeSetupMod_List == 2&&(f1ap.nRCellIdentity == 00:00:04:00:20) && " \
                                     "(f1ap.nRCellIdentity == 00:00:04:00:30) &&!f1ap.SCell_ToBeRemoved_List "
F1AP_RECONFIGURE_TO_3CC_SCELLS_A_C = "(f1ap.procedureCode == id-UEContextModification) &&  " \
                                     "f1ap.SCell_ToBeSetupMod_List == 2&&(f1ap.nRCellIdentity == 00:00:04:00:10) && " \
                                     "(f1ap.nRCellIdentity == 00:00:04:00:30) &&!f1ap.SCell_ToBeRemoved_List "
HO_WITH_2_SCELLS_B_C_ACTIVE_AND_TO_BE_RELEASED = "(f1ap.HandoverPreparationInformation) && (nr-rrc.sCellToAddModList" \
                                                 "== 2) && (nr-rrc.physCellId == 51) && (nr-rrc.physCellId == 52) &&" \
                                                 "(f1ap.SCell_ToBeRemoved_List == 2) && (f1ap.nRCellIdentity == " \
                                                 "00:00:04:00:20) && (f1ap.nRCellIdentity == 00:00:04:00:30) "
HO_WITH_1_SCELL_C_ACTIVE_AND_TO_BE_RELEASED = "(f1ap.HandoverPreparationInformation) && (nr-rrc.sCellToAddModList ==" \
                                              "1) && (nr-rrc.physCellId == 52) && (f1ap.SCell_ToBeRemoved_List == 1)" \
                                              "&& (f1ap.nRCellIdentity == 00:00:04:00:30) "
HO_WITHOUT_CA_ACTIVE = "(f1ap.HandoverPreparationInformation) && (!nr-rrc.sCellToAddModList)"
F1AP_RECONFIGURE_TO_3CC_SCELLS_A_B = "(f1ap.procedureCode == id-UEContextModification) &&  " \
                                   "f1ap.SCell_ToBeSetupMod_List == 2&&(f1ap.nRCellIdentity == 00:00:04:00:10) && " \
                                   "(f1ap.nRCellIdentity == 00:00:04:00:20) &&!f1ap.SCell_ToBeRemoved_List "

F1AP_SCELL_TO_BE_SETUP_MOD_LIST = "f1ap.SCell_ToBeSetupMod_List"
F1AP_SCELL_A_TO_ADD_MOD_LIST = "(nr-rrc.physCellId == 50 && nr-rrc.pdsch_HARQ_ACK_Codebook == 1)"
F1AP_SCELL_B_TO_ADD_MOD_LIST = "(nr-rrc.physCellId == 51 && nr-rrc.pdsch_HARQ_ACK_Codebook == 1)"
F1AP_SCELL_C_TO_ADD_MOD_LIST = "(nr-rrc.physCellId == 52 && nr-rrc.pdsch_HARQ_ACK_Codebook == 1)"
F1AP_SCELL_A_AND_B_TO_ADD_MOD_LIST = F1AP_SCELL_A_TO_ADD_MOD_LIST + F1AP_SCELL_B_TO_ADD_MOD_LIST
F1AP_SCELL_B_AND_C_TO_ADD_MOD_LIST = F1AP_SCELL_B_TO_ADD_MOD_LIST + F1AP_SCELL_C_TO_ADD_MOD_LIST
F1AP_SCELL_C_AND_A_TO_ADD_MOD_LIST = F1AP_SCELL_C_TO_ADD_MOD_LIST + F1AP_SCELL_A_TO_ADD_MOD_LIST
E1AP_UE_NOT_ACTIVE = "(e1ap.uE_Activity == 1)"

NGAP_SETUP_RESPONSE = "ngap.NGSetupResponse_element"
NGAP_SETUP_RESPONSE_TIMEOUT = 300

CPRT_DEBUG_ACTIVATION_COMMAND = "echo -e \"[control]\nLoggingSeverity=trace\" > /ffs/run/cp_runtime.ini && "
NON_DSS_CELL_SIB_RECEPTION_LIST = {1: [1]}
ALL_CELL_SIB_RECEPTION_LIST = {2: [1, 2, 3]}
SIB1_CELL1_PACKET_ON_RRC = 'iphy.cell_id==1&&nr-rrc.c1==1'
SIB1_CELL2_PACKET_ON_RRC = 'iphy.cell_id==2&&nr-rrc.c1==1'
SIB1_CELL3_PACKET_ON_RRC = 'iphy.cell_id==3&&nr-rrc.c1==1'

E1AP_FIVEQI1_SETUP = "(e1ap.qos_flow_Information_To_Be_Setup && e1ap.fiveQI == 1)"
F1AP_FIVEQI1_SETUP = "(f1ap.DRBs_ToBeSetupMod_List && f1ap.fiveQI == 1)"
E1AP_FIVEQI5_SETUP = "(e1ap.qos_flow_Information_To_Be_Setup && e1ap.fiveQI == 5)"
F1AP_FIVEQI5_SETUP = "(f1ap.DRBs_ToBeSetupMod_List && f1ap.fiveQI == 5)"
E1AP_FIVEQI1_RELEASE = "(e1ap.dRB_To_Remove_List_NG_RAN == 1 && e1ap.dRB_ID == 6)"
F1AP_FIVEQI1_RELEASE = "(f1ap.DRBs_ToBeReleased_List) && (f1ap.dRBID == 6)"
E1AP_FIVEQI5_RELEASE = "(e1ap.dRB_To_Remove_List_NG_RAN == 1 && e1ap.dRB_ID == 5)"
F1AP_FIVEQI5_RELEASE = "(f1ap.DRBs_ToBeReleased_List) && (f1ap.dRBID == 5)"
E1AP_FIVEQI1_AND_FIVEQI5_SETUP = "(e1ap.qos_flow_Information_To_Be_Setup) && (e1ap.fiveQI == 1) && (e1ap.fiveQI == 5)"
F1AP_FIVEQI1_AND_FIVEQI5_SETUP_ON_ICS = "(f1ap.DRBs_ToBeSetup_List) && (f1ap.fiveQI == 5) && (f1ap.fiveQI == 1)"

RRC_MESG_CAPTURING_TIMER = "5s"

CELLS_1_2_AND_3_DICTIONARY = {1: [1, 2, 3]}
