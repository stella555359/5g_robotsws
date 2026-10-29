A1_DECONFIGURATION = {
    "A1_REPORT_CONFIG_TO_REMOVE_LIST": (
        "nr-rrc.measIdToRemoveList == 2"
        " && nr-rrc.MeasId == 3"
        " && nr-rrc.MeasId == 4"
    ),
}
A2_CONFIGURATION = {
    "A2_REPORT_CONFIG_TO_ADD_LIST": (
        "nr-rrc.reportConfigToAddModList == 1"
        " && nr-rrc.reportConfigId == 5"
        " && nr-rrc.eventId == 1"
        " && nr-rrc.measTriggerQuantity.rsrp == 90"
    ),
}
BEAM_REFINEMENT_RRC = {
    "RRC_CSI_REPORTING_CONFIG_FOR_SCELLS": (
        "nr-rrc.reportConfigId == 13"
        " && nr-rrc.carrier == 1"
        " && nr-rrc.pucch_Resource == 19"
        " && nr-rrc.reportConfigId == 14"
        " && nr-rrc.carrier == 2"
        " && nr-rrc.pucch_Resource == 21"
        " && nr-rrc.reportConfigId == 15"
        " && nr-rrc.carrier == 3"
        " && nr-rrc.pucch_Resource == 23"
        " && nr-rrc.c1 == 0"
    ),
    "CSI_RS_BEAM_REFINEMENT": (
        "nr-rrc.reportConfigId == 23"
        " && nr-rrc.reportQuantity == 5"
        " && nr-rrc.uplinkBandwidthPartId == 1"
        " && nr-rrc.pucch_Resource == 24"
        " && nr-rrc.carrier == 3"
        " && nr-rrc.reportConfigId == 22"
        " && nr-rrc.reportQuantity == 5"
        " && nr-rrc.uplinkBandwidthPartId == 1"
        " && nr-rrc.pucch_Resource == 22"
        " && nr-rrc.carrier == 2"
        " && nr-rrc.c1 == 0"
    ),
    "PUCCH_CONFIG": (
        "nr-rrc.pucch_ResourceSetId == 2"
        " && nr-rrc.PUCCH_ResourceId == 9"
        " && nr-rrc.pucch_ResourceSetId == 1"
        " && nr-rrc.c1 == 0"
        " && nr-rrc.PUCCH_ResourceId == 10"
        " && nr-rrc.format == 3"
        " && nr-rrc.PUCCH_ResourceId == 11"
        " && nr-rrc.format == 3"
    ),
}
BEAM_REFINEMENT_F1AP = {
    "BWP_UPLINK_DEDICATED": (
        "nr-rrc.pucch_Config == 1"
        " && nr-rrc.pucch_ResourceSetId == 1"
        " && nr-rrc.pucch_ResourceId == 10"
        " && nr-rrc.pucch_ResourceId == 11"
        " && nr-rrc.pucch_ResourceSetId == 2"
        " && nr-rrc.PUCCH_ResourceId == 9"
        " && nr-rrc.pucch_ResourceId == 19"
        " && nr-rrc.pucch_ResourceId == 21"
        " && nr-rrc.pucch_ResourceId == 22"
        " && nr-rrc.pucch_ResourceId == 23"
        " && nr-rrc.pucch_ResourceId == 24"
        " && nr-rrc.resourceToAddModList == 17"
        " && nr-rrc.format3 == 1"
        " && nr-rrc.maxCodeRate == 0"
    ),
    "SERVING_CELL_CONFIG": (
        "nr-rrc.csi_ReportConfigToAddModList == 7"
        " && nr-rrc.reportConfigId == 0"
        " && nr-rrc.pucch_Resource == 9"
        " && nr-rrc.reportConfigId == 13"
        " && nr-rrc.pucch_Resource == 19"
        " && nr-rrc.reportConfigId == 14"
        " && nr-rrc.pucch_Resource == 21"
        " && nr-rrc.reportConfigId == 22"
        " && nr-rrc.pucch_Resource == 22"
        " && nr-rrc.reportConfigId == 15"
        " && nr-rrc.pucch_Resource == 23"
        " && nr-rrc.reportConfigId == 23"
        " && nr-rrc.pucch_Resource == 24"
    ),
    "F1AP_SCELL_CONFIG_DEDICATED": (
        "nr-rrc.csi_MeasConfig == 1"
        " && nr-rrc.nzp_CSI_RS_ResourceToAddModList"
        " && nr-rrc.nzp_CSI_RS_ResourceSetToAddModList"
        " && nr-rrc.csi_IM_ResourceToAddModList"
        " && nr-rrc.csi_IM_ResourceSetToAddModList"
        " && nr-rrc.csi_ResourceConfigToAddModList"
        " && f1ap.procedureCode == 7"
    ),
}
