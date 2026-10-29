*** Settings ***
Documentation    Keywords for CB008533.

*** Variables ***
${SCELL_TO_ADD_MOD_LIST}=                         nr-rrc.sCellToAddModList == 3 && nr-rrc.physCellId == 51 &&
                                             ...  nr-rrc.physCellId == 52 && nr-rrc.physCellId == 55 && nr-rrc.c1 == 0
${RRC_SCELL_TO_ADD_MOD_LIST}=                     nr-rrc.sCellToAddModList == 3 && nr-rrc.physCellId == 51 &&
                                             ...  nr-rrc.physCellId == 54 && nr-rrc.physCellId == 55 && nr-rrc.c1 == 0
${RRC_CSI_REPORTING_CONFIG_FOR_SCELLS}=           nr-rrc.reportConfigId == 13 && nr-rrc.carrier == 1 &&
                                             ...  nr-rrc.pucch_Resource == 19 && nr-rrc.reportConfigId == 14 &&
                                             ...  nr-rrc.carrier == 2 && nr-rrc.pucch_Resource == 21 &&
                                             ...  nr-rrc.reportConfigId == 15 && nr-rrc.carrier == 3 &&
                                             ...  nr-rrc.pucch_Resource == 23 && nr-rrc.c1 == 0
${CSI_RS_BEAM_REFINEMENT}=                        nr-rrc.reportConfigId == 23 && nr-rrc.reportQuantity == 5 &&
                                             ...  nr-rrc.uplinkBandwidthPartId == 1 && nr-rrc.pucch_Resource == 24 &&
                                             ...  nr-rrc.carrier == 3 && nr-rrc.reportConfigId == 22 &&
                                             ...  nr-rrc.reportQuantity == 5 && nr-rrc.uplinkBandwidthPartId == 1 &&
                                             ...  nr-rrc.pucch_Resource == 22 && nr-rrc.carrier == 2 && nr-rrc.c1 == 0
${RRC_CSI_RS_BEAM_REFINEMENT}=                    nr-rrc.reportConfigId == 23 && nr-rrc.reportQuantity == 5 &&
                                             ...  nr-rrc.uplinkBandwidthPartId == 1 && nr-rrc.pucch_Resource == 24 &&
                                             ...  nr-rrc.carrier == 3 && nr-rrc.c1 == 0
${PUCCH_CONFIG}=                                  (nr-rrc.pucch_ResourceSetId == 2) && (nr-rrc.PUCCH_ResourceId == 9) &&
                                             ...  (nr-rrc.pucch_ResourceSetId == 1) && nr-rrc.c1 == 0 &&
                                             ...  (nr-rrc.PUCCH_ResourceId == 10) && (nr-rrc.format == 3) &&
                                             ...  (nr-rrc.PUCCH_ResourceId == 11) && (nr-rrc.format == 3)
${RRC_PUCCH_CONFIG}=                              (nr-rrc.pucch_ResourceSetId == 2) && (nr-rrc.PUCCH_ResourceId == 9) &&
                                             ...  (nr-rrc.pucch_ResourceSetId == 1) && nr-rrc.c1 == 0 &&
                                             ...  (nr-rrc.PUCCH_ResourceId == 10) && (nr-rrc.format == 3) &&
                                             ...  (nr-rrc.PUCCH_ResourceId == 11) && (nr-rrc.format == 3) &&
                                             ...  (nr-rrc.startingPRB == 103) && (nr-rrc.startingPRB == 2) &&
                                             ...  (nr-rrc.startingPRB == 3) && (nr-rrc.startingPRB == 101)
${BWP_UPLINKDEDICATED}=                           (nr-rrc.pucch_Config == 1) && (nr-rrc.pucch_ResourceSetId == 1) &&
                                             ...  (nr-rrc.PUCCH_ResourceId == 10) && (nr-rrc.PUCCH_ResourceId == 11) &&
                                             ...  (nr-rrc.pucch_ResourceSetId == 2) && (nr-rrc.PUCCH_ResourceId == 9) &&
                                             ...  (nr-rrc.PUCCH_ResourceId == 19) && (nr-rrc.pucch_ResourceId == 21) &&
                                             ...  (nr-rrc.pucch_ResourceId == 22) && (nr-rrc.pucch_ResourceId == 23) &&
                                             ...  (nr-rrc.pucch_ResourceId == 24) &&
                                             ...  (nr-rrc.resourceToAddModList == 17) &&
                                             ...  (nr-rrc.format3 == 1) && (nr-rrc.maxCodeRate == 0)
${F1AP_BWP_UPLINKDEDICATED}=                      (nr-rrc.pucch_Config == 1) && (nr-rrc.pucch_ResourceSetId == 1) &&
                                             ...  (nr-rrc.PUCCH_ResourceId == 10) && (nr-rrc.PUCCH_ResourceId == 11) &&
                                             ...  (nr-rrc.pucch_ResourceSetId == 2) && (nr-rrc.PUCCH_ResourceId == 9) &&
                                             ...  (nr-rrc.PUCCH_ResourceId == 19) && (nr-rrc.pucch_ResourceId == 21) &&
                                             ...  (nr-rrc.pucch_ResourceId == 23) && (nr-rrc.pucch_ResourceId == 24) &&
                                             ...  (nr-rrc.resourceToAddModList == 16) && (nr-rrc.format3 == 1) &&
                                             ...  (nr-rrc.maxCodeRate == 0)
${SERVING_CELL_CONFIG}=                           (nr-rrc.csi_ReportConfigToAddModList == 7) &&
                                             ...  (nr-rrc.reportConfigId == 0) && (nr-rrc.pucch_Resource == 9) &&
                                             ...  (nr-rrc.reportConfigId == 13) && (nr-rrc.pucch_Resource == 19) &&
                                             ...  (nr-rrc.reportConfigId == 14) && (nr-rrc.pucch_Resource == 21) &&
                                             ...  (nr-rrc.reportConfigId == 22) && (nr-rrc.pucch_Resource == 22) &&
                                             ...  (nr-rrc.reportConfigId == 15) && (nr-rrc.pucch_Resource == 23) &&
                                             ...  (nr-rrc.reportConfigId == 23) && (nr-rrc.pucch_Resource == 24)
${F1AP_SERVING_CELL_CONFIG}                       (nr-rrc.csi_ReportConfigToAddModList == 6) &&
                                             ...  (nr-rrc.reportConfigId == 0) && (nr-rrc.pucch_Resource == 9) &&
                                             ...  (nr-rrc.reportConfigId == 13) && (nr-rrc.pucch_Resource == 19) &&
                                             ...  (nr-rrc.reportConfigId == 14) && (nr-rrc.pucch_Resource == 21) &&
                                             ...  (nr-rrc.reportConfigId == 15) && (nr-rrc.pucch_Resource == 23) &&
                                             ...  (nr-rrc.reportConfigId == 23) && (nr-rrc.pucch_Resource == 24)
${F1AP_SCELL_CONFIG_DEDICATED}=                   nr-rrc.csi_MeasConfig == 1 &&
                                             ...  nr-rrc.nzp_CSI_RS_ResourceToAddModList &&
                                             ...  nr-rrc.nzp_CSI_RS_ResourceSetToAddModList &&
                                             ...  nr-rrc.csi_IM_ResourceToAddModList &&
                                             ...  nr-rrc.csi_IM_ResourceSetToAddModList &&
                                             ...  nr-rrc.csi_ResourceConfigToAddModList &&
                                             ...  f1ap.procedureCode == 7
${NRCELLIDENTITY_&_BAND_COMBINATION}=             (f1ap.nRCellIdentity == 00:00:04:00:20) &&
                                             ...  (f1ap.nRCellIdentity == 00:00:04:00:30) &&
                                             ...  (f1ap.nRCellIdentity == 00:00:04:00:60) &&
                                             ...  (f1ap.procedureCode == 7) && (f1ap.SCell_ToBeSetupMod_List == 3) &&
                                             ...  (nr-rrc.bandCombinationIndex == 5)
${F1AP_NRCELLIDENTITY_&_BAND_COMBINATION}=        (f1ap.nRCellIdentity == 00:00:04:00:60) &&
                                             ...  (f1ap.nRCellIdentity == 00:00:04:00:50) &&
                                             ...  (f1ap.nRCellIdentity == 00:00:04:00:20) &&
                                             ...  (f1ap.procedureCode == 7) && (f1ap.SCell_ToBeSetupMod_List == 3) &&
                                             ...  (nr-rrc.bandCombinationIndex == 1)
${F1AP_A1_REPORT_CONFIG_TO_REMOVE_LIST}=          (nr-rrc.measIdToRemoveList == 2) &&
                                             ...  (nr-rrc.MeasId == 3) && (nr-rrc.MeasId == 4)
${A2_REPORT_CONFIG_TO_ADD_LIST}=                  (nr-rrc.measObjectToAddModList == 3) &&
                                             ...  (nr-rrc.freqBandIndicatorNR == 66) &&
                                             ...  (nr-rrc.freqBandIndicatorNR == 41) &&
                                             ...  (nr-rrc.freqBandIndicatorNR == 41) &&
                                             ...  (nr-rrc.reportConfigToAddModList == 1) &&
                                             ...  (nr-rrc.reportConfigId == 5) && (nr-rrc.a2_Threshold == 0) &&
                                             ...  (nr-rrc.measTriggerQuantity.rsrp == 90) && (nr-rrc.measIdToAddModList == 3) &&
                                             ...  (nr-rrc.measObjectId == 2) && (nr-rrc.reportConfigId == 5) &&
                                             ...  (nr-rrc.measObjectId == 3) && (nr-rrc.reportConfigId == 5) &&
                                             ...  (nr-rrc.measObjectId == 4) && (nr-rrc.reportConfigId == 5)
${F1AP_A2_REPORT_CONFIG_TO_ADD_LIST}=             (nr-rrc.measObjectToAddModList == 3) &&
                                             ...  (nr-rrc.freqBandIndicatorNR == 66) &&
                                             ...  (nr-rrc.freqBandIndicatorNR == 25) &&
                                             ...  (nr-rrc.freqBandIndicatorNR == 41) &&
                                             ...  (nr-rrc.reportConfigToAddModList == 1) &&
                                             ...  (nr-rrc.reportConfigId == 5) && (nr-rrc.a2_Threshold == 0) &&
                                             ...  (nr-rrc.measTriggerQuantity.rsrp == 90) && (nr-rrc.measIdToAddModList == 3) &&
                                             ...  (nr-rrc.measObjectId == 2) && (nr-rrc.reportConfigId == 5) &&
                                             ...  (nr-rrc.measObjectId == 3) && (nr-rrc.reportConfigId == 5) &&
                                             ...  (nr-rrc.measObjectId == 4) && (nr-rrc.reportConfigId == 5)

*** Keywords ***
Verify Successful 4CC FFTT On F1AP Messages
    Verify Tcpdump Log      packet_filter=${NRCELLIDENTITY_&_BAND_COMBINATION}           continue_on_failure=False
    Verify Tcpdump Log      packet_filter=${SCELL_TO_ADD_MOD_LIST}                       continue_on_failure=False

Verify Successful 4CC FFFT On F1AP Messages
    Verify Tcpdump Log      packet_filter=${F1AP_NRCELLIDENTITY_&_BAND_COMBINATION}      continue_on_failure=False
    Verify Tcpdump Log      packet_filter=${RRC_SCELL_TO_ADD_MOD_LIST}                   continue_on_failure=False

Verify Deconfiguration Of A1 Measurement
    Verify Tcpdump Log      packet_filter=${F1AP_A1_REPORT_CONFIG_TO_REMOVE_LIST}        continue_on_failure=False

Verify Configuration Of A2 Measurement
    [Arguments]    ${filter}
    Verify Tcpdump Log      packet_filter=${filter}                                      continue_on_failure=False

Verify Beam Refinement For Two TDD SCells On RRC Reconfiguration Message
    Verify Tcpdump Log      packet_filter=${RRC_CSI_REPORTING_CONFIG_FOR_SCELLS}         continue_on_failure=False
    Verify Tcpdump Log      packet_filter=${CSI_RS_BEAM_REFINEMENT}                      continue_on_failure=False
    Verify Tcpdump Log      packet_filter=${PUCCH_CONFIG}                                continue_on_failure=False

Verify Beam Refinement For One TDD SCell On RRC Reconfiguration Message
    Verify Tcpdump Log      packet_filter=${RRC_CSI_REPORTING_CONFIG_FOR_SCELLS}         continue_on_failure=False
    Verify Tcpdump Log      packet_filter=${RRC_CSI_RS_BEAM_REFINEMENT}                  continue_on_failure=False
    Verify Tcpdump Log      packet_filter=${RRC_PUCCH_CONFIG}                            continue_on_failure=False

Verify Beam Refinement For Two TDD SCells On F1AP UE Context Modification Response
    Verify Tcpdump Log      packet_filter=${BWP_UPLINKDEDICATED}                         continue_on_failure=False
    Verify Tcpdump Log      packet_filter=${SERVING_CELL_CONFIG}                         continue_on_failure=False
    Verify Tcpdump Log      packet_filter=${F1AP_SCELL_CONFIG_DEDICATED}                 continue_on_failure=False
                                                                                    ...  relation_symbol= >=
Verify Beam Refinement For One TDD SCell On F1AP UE Context Modification Response
    Verify Tcpdump Log      packet_filter=${F1AP_BWP_UPLINKDEDICATED}                    continue_on_failure=False
    Verify Tcpdump Log      packet_filter=${F1AP_SERVING_CELL_CONFIG}                    continue_on_failure=False
    Verify Tcpdump Log      packet_filter=${F1AP_SCELL_CONFIG_DEDICATED}                 continue_on_failure=False
                                                                                    ...  relation_symbol= >=
Reset Egate
    Execute Egate Command    cmd=sim_reset
