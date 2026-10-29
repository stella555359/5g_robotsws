*** Settings ***

Documentation    :copyright: Nokia

*** Variables ***

${FULL_COMMISSIONING}        ${TRUE}
${RESET_TL}                  ${FALSE}

${UE1_CELL2}    1
${UE1_CELL7}    1
${UE2_CELL7}    2
${UE3_CELL7}    3
${UE4_CELL7}    4
${UE5_CELL7}    5
${UE6_CELL7}    6

############# WIRESHARK ################
${UL_1_TXSWITCHING_ON_FDD_PCELL}
...    nr-rrc.uplinkTxSwitchingOption_r16 == 0
...    && f1ap.SelectedBandCombinationIndex == 00:01  && nr-rrc.maxRank == 1
...    && nr-rrc.nrofSRS_Ports == 1 && nr-rrc.uplinkTxSwitchingPeriodLocation_r16 == True
...    && nr-rrc.uplinkTxSwitchingCarrier_r16 == 0 && nr-rrc.physCellId == 53
${UL_2_TXSWITCHING_ON_FDD_PCELL}
...    nr-rrc.uplinkTxSwitchingOption_r16 == 0 && nr-rrc.uplinkTxSwitching_2T_Mode_r17 == 0
...    && f1ap.SelectedBandCombinationIndex == 00:02 && nr-rrc.maxRank == 2
...    && nr-rrc.nrofSRS_Ports == 1 && nr-rrc.uplinkTxSwitchingPeriodLocation_r16 == True
...    && nr-rrc.uplinkTxSwitchingCarrier_r16 == 0 && nr-rrc.physCellId == 53
${UL_1_TXSWITCHING_ON_TDD_SCELL}
...    nr-rrc.physCellId == 53 && nr-rrc.sCellIndex == 2
...    && f1ap.SelectedBandCombinationIndex == 00:01 && nr-rrc.nrofSRS_Ports == 1
...    && nr-rrc.maxRank == 1 && nr-rrc.uplinkTxSwitchingPeriodLocation_r16 == False
...    && nr-rrc.uplinkTxSwitchingCarrier_r16 == 1
${UL_2_TXSWITCHING_ON_TDD_SCELL}
...    nr-rrc.physCellId == 53 && nr-rrc.sCellIndex == 2
...    && f1ap.SelectedBandCombinationIndex == 00:02 && nr-rrc.nrofSRS_Ports == 1
...    && nr-rrc.maxRank == 2 && nr-rrc.uplinkTxSwitchingPeriodLocation_r16 == False
...    && nr-rrc.uplinkTxSwitchingCarrier_r16 == 1
${F1AP_SCELL_TO_BE_SETUP_MOD_LIST_FDD_PCell}
...    f1ap.SCell_ToBeSetupMod_List == 5
${F1AP_SCELL_TO_ADD_MOD_LIST_FDD_PCell}
...    nr-rrc.sCellToAddModList == 5 && nr-rrc.physCellId == 51 && nr-rrc.physCellId == 53
...    && nr-rrc.physCellId == 54 && nr-rrc.physCellId == 60 && nr-rrc.physCellId == 61
...    && f1ap.SelectedBandCombinationIndex



