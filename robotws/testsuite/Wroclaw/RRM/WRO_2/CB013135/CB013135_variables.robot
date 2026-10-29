*** Settings ***
Documentation    :copyright: Nokia
...              :authors: Damian Rzeczkowski
...              :contact: rzeczkowski.damian@gmail.com

*** Variables ***
${LOGGING_POLICY}=    NO_TRAFFIC_LOGS_POLICY
@{mplane_cells}=    5    6    9    12
${UE1_ID}=            1
${UE2_ID}=            2
${PCELL1_ID}=         1
${PCELL7_ID}=         7
${PDU_PCELL_1}=       1
${PDU_PCELL_7}=       2
${GW1_ID}=            1
${GW7_ID}=            2
${UE1_A1_MEAS_ID}=    4
${UE2_A1_MEAS_ID}=    4

${egate_console_log_filename}    /opt/iphy/latest/egate_console.log
&{PATTERNS}    supportedBandCombinationList-v1780=${pattern1}
...            supportedBandCombinationList-UplinkTxSwitch-v1780=${pattern2}

${pattern1}    supportedBandCombinationList-v1780\\s*\{
    ...         \\s*\{\\s*ca-ParametersNR-v1780\\s*\{
    ...             \\s*supportedAggBW-FR1-r17\\s*\{
    ...                 \\s*scalingFactorSCS-r17\\s*true,\\s*
    ...                 \\s*supportedAggBW-FDD-DL-r17\\s*fr1-r17\\s*:\\s*mhz160,\\s*
    ...                 \\s*supportedAggBW-FDD-UL-r17\\s*fr1-r17\\s*:\\s*mhz160,\\s*
    ...                 \\s*supportedAggBW-TDD-DL-r17\\s*fr1-r17\\s*:\\s*mhz200,\\s*
    ...                 \\s*supportedAggBW-TDD-UL-r17\\s*fr1-r17\\s*:\\s*mhz200,\\s*
    ...                 \\s*supportedAggBW-TotalDL-r17\\s*fr1-r17\\s*:\\s*mhz350,\\s*
    ...                 \\s*supportedAggBW-TotalUL-r17\\s*fr1-r17\\s*:\\s*mhz350\\s*
    ...             \\}\\s*
    ...         \\}\\s*

${pattern2}    supportedBandCombinationList-UplinkTxSwitch-v1780\\s*\\{\\s*
...             \\s*\\{\\s*bandCombination-v1780\\s*\\{\\s*
...                 \\s*ca-ParametersNR-v1780\\s*\\{\\s*
...                     \\s*supportedAggBW-FR1-r17\\s*\\{\\s*
...                         \\s*scalingFactorSCS-r17\\s*true,\\s*
...                         \\s*supportedAggBW-FDD-DL-r17\\s*fr1-r17\\s*:\\s*mhz160,\\s*
...                         \\s*supportedAggBW-FDD-UL-r17\\s*fr1-r17\\s*:\\s*mhz160,\\s*
...                         \\s*supportedAggBW-TDD-DL-r17\\s*fr1-r17\\s*:\\s*mhz200,\\s*
...                         \\s*supportedAggBW-TDD-UL-r17\\s*fr1-r17\\s*:\\s*mhz200,\\s*
...                         \\s*supportedAggBW-TotalDL-r17\\s*fr1-r17\\s*:\\s*mhz350,\\s*
...                         \\s*supportedAggBW-TotalUL-r17\\s*fr1-r17\\s*:\\s*mhz350\\s*
...                     \\}\\s*
...                 \\}\\s*
...             \\}\\s*
...           \\}\\s*

${F1AP_SCELL_TO_BE_SETUP_MOD_LIST_TDD_PCell}=     f1ap.SCell_ToBeSetupMod_List == 5
${F1AP_SCELL_TO_ADD_MOD_LIST_TDD_PCell}=          ((((((nr-rrc.sCellToAddModList == 5) && (nr-rrc.physCellId == 54))
    ...                                           && (nr-rrc.physCellId == 57))
    ...                                           && (nr-rrc.physCellId == 58)) && (nr-rrc.physCellId == 60)) && (nr-rrc.physCellId == 61))
    ...                                           && (f1ap.SelectedBandCombinationIndex == 00:03)
${ultxswithing_on_TDD_PCell}=                     ((((nr-rrc.uplinkTxSwitchingOption_r16 == 0)
    ...                                           && (nr-rrc.uplinkTxSwitchingPeriodLocation_r16 == False))
    ...                                           && (nr-rrc.uplinkTxSwitchingCarrier_r16 == 1)) && (f1ap.SelectedBandCombinationIndex == 00:03))
    ...                                           && (nr-rrc.physCellId == 57)
${ultxswitching_on_FDD_SCell}=                    ((((((nr-rrc.physCellId == 57) && (f1ap.SelectedBandCombinationIndex == 00:03))
    ...                                           && (nr-rrc.sCellIndex == 2)) && (nr-rrc.uplinkTxSwitchingPeriodLocation_r16 == True))
    ...                                           && (nr-rrc.uplinkTxSwitchingCarrier_r16 == 0)) && (nr-rrc.nrofSRS_Ports == 0))
    ...                                           && (nr-rrc.maxRank == 1)
${F1AP_SCELL_TO_BE_SETUP_MOD_LIST_FDD_PCell}=     f1ap.SCell_ToBeSetupMod_List == 5
${F1AP_SCELL_TO_ADD_MOD_LIST_FDD_PCell}=          ((((((nr-rrc.sCellToAddModList == 5) && (nr-rrc.physCellId == 51)) && (nr-rrc.physCellId == 54))
    ...                                           && (nr-rrc.physCellId == 58))
    ...                                           && (nr-rrc.physCellId == 60)) && (nr-rrc.physCellId == 61))
    ...                                           && (f1ap.SelectedBandCombinationIndex == 00:03)
${ultxswithing_on_FDD_PCell}=                     ((((nr-rrc.uplinkTxSwitchingOption_r16 == 0)
    ...                                           && (nr-rrc.uplinkTxSwitchingPeriodLocation_r16 == True))
    ...                                           && (nr-rrc.uplinkTxSwitchingCarrier_r16 == 1)) && (f1ap.SelectedBandCombinationIndex == 00:03))
    ...                                           && (nr-rrc.physCellId == 51)
${ultxswitching_on_TDD_SCell}=                    ((((((nr-rrc.physCellId == 51) && (f1ap.SelectedBandCombinationIndex == 00:03))
    ...                                           && (nr-rrc.sCellIndex == 1)) && (nr-rrc.uplinkTxSwitchingPeriodLocation_r16 == False))
    ...                                           && (nr-rrc.uplinkTxSwitchingCarrier_r16 == 0)) && (nr-rrc.nrofSRS_Ports == 1))
    ...                                           && (nr-rrc.maxRank == 2)
