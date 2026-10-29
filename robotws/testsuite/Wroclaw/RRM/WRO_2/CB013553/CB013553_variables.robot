*** Settings ***
Documentation    :copyright: Nokia
...              :authors: Damian Rzeczkowski
...              :contact: rzeczkowski.damian@gmail.com

*** Variables ***
${LOGGING_POLICY}=    NO_TRAFFIC_LOGS_POLICY
@{mplane_cells}=    5    6    9    12
@{UE_IDs}=    1    2
@{PDU_IDs}=   1    2
${UE1_ID}=            1
${UE2_ID}=            2
${PCELL1_ID}=         3
${PCELL7_ID}=         7
${PDU_PCELL_1}=       1
${PDU_PCELL_7}=       2
${GW1_ID}=            1
${GW7_ID}=            2
${UE1_A1_MEAS_ID}=    4
${UE2_A1_MEAS_ID}=    4

${F1AP_SCELL_TO_BE_SETUP_MOD_LIST_TDD_PCell}=     f1ap.SCell_ToBeSetupMod_List == 5
${F1AP_SCELL_TO_ADD_MOD_LIST_TDD_PCell}=          ((((((nr-rrc.sCellToAddModList == 5) && (nr-rrc.physCellId == 51))
    ...                                           && (nr-rrc.physCellId == 54))
    ...                                           && (nr-rrc.physCellId == 57)) && (nr-rrc.physCellId == 60)) && (nr-rrc.physCellId == 61))
    ...                                           && (f1ap.SelectedBandCombinationIndex == 00:02)
${ultxswithing_on_TDD_PCell}=                     (((((((nr-rrc.uplinkTxSwitchingOption_r16 == 0) && (nr-rrc.uplinkTxSwitching_2T_Mode_r17 == 0))
    ...                                           && (f1ap.SelectedBandCombinationIndex == 00:02)) && (nr-rrc.maxRank == 2))
    ...                                           && (nr-rrc.nrofSRS_Ports == 1)) && (nr-rrc.uplinkTxSwitchingPeriodLocation_r16 == False))
    ...                                           && (nr-rrc.uplinkTxSwitchingCarrier_r16 == 1)) && (nr-rrc.physCellId == 57)
${ultxswitching_on_FDD_SCell}=                    ((((((nr-rrc.physCellId == 57) && (nr-rrc.sCellIndex == 3))
    ...                                           && (f1ap.SelectedBandCombinationIndex == 00:02)) && (nr-rrc.nrofSRS_Ports == 1))
    ...                                           && (nr-rrc.maxRank == 2)) && (nr-rrc.uplinkTxSwitchingPeriodLocation_r16 == True))
    ...                                           && (nr-rrc.uplinkTxSwitchingCarrier_r16 == 0)
${F1AP_SCELL_TO_BE_SETUP_MOD_LIST_FDD_PCell}=     f1ap.SCell_ToBeSetupMod_List == 5
${F1AP_SCELL_TO_ADD_MOD_LIST_FDD_PCell}=          ((((((nr-rrc.sCellToAddModList == 5) && (nr-rrc.physCellId == 51)) && (nr-rrc.physCellId == 53))
    ...                                           && (nr-rrc.physCellId == 54))
    ...                                           && (nr-rrc.physCellId == 60)) && (nr-rrc.physCellId == 61))
    ...                                           && (f1ap.SelectedBandCombinationIndex == 00:02)
${ultxswithing_on_FDD_PCell}=                     (((((((nr-rrc.uplinkTxSwitchingOption_r16 == 0) && (nr-rrc.uplinkTxSwitching_2T_Mode_r17 == 0))
    ...                                           && (f1ap.SelectedBandCombinationIndex == 00:02)) && (nr-rrc.maxRank == 2))
    ...                                           && (nr-rrc.nrofSRS_Ports == 1)) && (nr-rrc.uplinkTxSwitchingPeriodLocation_r16 == True))
    ...                                           && (nr-rrc.uplinkTxSwitchingCarrier_r16 == 0)) && (nr-rrc.physCellId == 53)
${ultxswitching_on_TDD_SCell}=                    ((((((nr-rrc.physCellId == 53) && (nr-rrc.sCellIndex == 2))
    ...                                           && (f1ap.SelectedBandCombinationIndex == 00:02)) && (nr-rrc.nrofSRS_Ports == 1))
    ...                                           && (nr-rrc.maxRank == 2)) && (nr-rrc.uplinkTxSwitchingPeriodLocation_r16 == False))
    ...                                           && (nr-rrc.uplinkTxSwitchingCarrier_r16 == 1)
