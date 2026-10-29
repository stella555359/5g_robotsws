selected_SCells_for_FFTT_4CC_CA_in_UE_CON_MOD_REQ = \
    """
    SCell-ToBeSetupMod-List is present and length(SCell-ToBeSetupMod-List) eq 3
    and
    SCell-ToBeSetupMod-List contains
    (
        (sCellIndex eq 1) and (nRCellIdentity eq "0b000000000000000000000100000000000010")
    )
    and
    SCell-ToBeSetupMod-List contains
    (
        (sCellIndex eq 2) and (nRCellIdentity eq "0b000000000000000000000100000000000011")
    )
    and
    SCell-ToBeSetupMod-List contains
    (
        (sCellIndex eq 3) and (nRCellIdentity eq "0b000000000000000000000100000000000110")
    )
    and
    allowedBC-ListMRDC contains
    (
            bandCombinationIndex eq 5
    )
    and
    allowedBC-ListMRDC contains
    (
            bandCombinationIndex eq 2
    )
    """

added_SCells_for_FFTT_4CC_CA_in_UE_CON_MOD_RESP = \
    """
    sCellToAddModList contains
    (
        sCellIndex eq 1
        and nzp-CSI-RS-ResourceToAddModList is present
        and nzp-CSI-RS-ResourceSetToAddModList is present
        and csi-IM-ResourceToAddModList is present
        and csi-IM-ResourceSetToAddModList is present
        and csi-ResourceConfigToAddModList is present
    )
    and sCellToAddModList contains
    (
        sCellIndex eq 2
        and nzp-CSI-RS-ResourceToAddModList is present
        and nzp-CSI-RS-ResourceSetToAddModList is present
        and csi-IM-ResourceToAddModList is present
        and csi-IM-ResourceSetToAddModList is present
        and csi-ResourceConfigToAddModList is present
    )
    and
    sCellToAddModList contains
    (
        sCellIndex eq 3
        and nzp-CSI-RS-ResourceToAddModList is present
        and nzp-CSI-RS-ResourceSetToAddModList is present
        and csi-IM-ResourceToAddModList is present
        and csi-IM-ResourceSetToAddModList is present
        and csi-ResourceConfigToAddModList is present
    )
    """

added_SCells_for_FFTT_4CC_CA_in_RRC_Reconfiguration = \
    """
    sCellToAddModList contains
    (
        sCellIndex eq 1
        and sCellConfigCommon contains (physCellId eq 51)
    )
    and sCellToAddModList contains
    (
        sCellIndex eq 2
        and sCellConfigCommon contains (physCellId eq 52)
    )
    and
    sCellToAddModList contains
    (
        sCellIndex eq 3
        and sCellConfigCommon contains (physCellId eq 55)
    )
    """


PUCCH_config_for_FFTT_4CC_CA_in_RRC_Reconfiguration = \
    """
    spCellConfig contains
    (
        pucch-Config contains
        (
            resourceSetToAddModList contains
            (
                pucch-ResourceSetId eq 1
                and
                length(resourceList) eq 2
                and
                resourceList contains (10, 11)
                and
                maxPayloadSize eq 8
            )
            and
            resourceSetToAddModList contains
            (
                pucch-ResourceSetId eq 2
                and
                length(resourceList) eq 2
                and
                resourceList  contains (9, 19)
            )
            and
            length(resourceToAddModList) eq 7
            and
            resourceToAddModList contains
            (
                pucch-ResourceId eq 10
                and
                startingPRB eq 2
            )
            and
            resourceToAddModList contains
            (
                pucch-ResourceId eq 11
                and
                startingPRB eq 103
            )
            and
            format3 contains
            (
                maxCodeRate eq "zeroDot15"
                and
                simultaneousHARQ-ACK-CSI eq "true"
            )
        )
    )
    """

measurements_config_for_FFTT_4CC_CA_in_RRC_Reconfiguration = \
    """
    measConfig contains
    (
        measIdToRemoveList is present
        and length(measIdToRemoveList) eq 2
        and measIdToRemoveList contains (3, 4)
        and reportConfigToAddModList contains
        (
            reportConfigId eq 5
            and
            eventId contains (eventA2 is present)
            and
            a2-Threshold contains (rsrq eq 49)
        )
        and
        measObjectToAddModList contains
        (
            measObjectId eq 2
            and
            freqBandIndicatorNR eq 66
        )
        and
        measObjectToAddModList contains
        (
            measObjectId eq 3
            and
            freqBandIndicatorNR eq 41
        )
        and
        measObjectToAddModList contains
        (
            measObjectId eq 4
            and
            freqBandIndicatorNR eq 41
        )
        and
        measIdToAddModList contains
        (
            measId eq 5
            and
            measObjectId eq 2
            and
            reportConfigId eq 5
        )
        and
        measIdToAddModList contains
        (
            measId eq 6
            and
            measObjectId eq 3
            and
            reportConfigId eq 5
        )
        and
        measIdToAddModList contains
        (
            measId eq 7
            and
            measObjectId eq 4
            and
            reportConfigId eq 5
        )
    )
    """

resources_for_FFTT_4CC_CA_in_UE_CON_MOD_RESP = \
    """
    uplinkBWP-ToAddModList contains
    (
        pucch-Config contains
        (
            resourceSetToAddModList contains
            (
                pucch-ResourceSetId eq 1
                and
                length(resourceList) eq 2
                and
                resourceList contains (10, 11)
                and
                maxPayloadSize eq 8
            )
            and
            resourceSetToAddModList contains
            (
                pucch-ResourceSetId eq 2
                and
                length(resourceList) eq 2
                and
                resourceList contains (9, 19)
            )
            and
            length(resourceToAddModList) eq 7
            and
            resourceToAddModList contains
            (
                pucch-ResourceId eq 10
                and
                startingPRB eq 2
            )
            and
            resourceToAddModList contains
            (
                pucch-ResourceId eq 11
                and
                startingPRB eq 103
            )
            and
            format3 contains
            (
                maxCodeRate eq "zeroDot15"
                and
                simultaneousHARQ-ACK-CSI eq "true"
            )
        )
    )
    """

csi_for_FFTT_4CC_CA_in_UE_CON_MOD_RESP = \
    """
    spCellConfig contains
    (
        csi-MeasConfig contains
        (
            length(csi-ReportConfigToAddModList) eq 5
            and
            csi-ReportConfigToAddModList contains
            (
                reportConfigId eq 13
                and
                carrier eq 1
                and
                reportConfigType contains
                (
                    periodic contains
                    (
                        reportSlotConfig contains (slots80 is present)
                        and
                        pucch-CSI-ResourceList contains (pucch-Resource eq 19)
                    )
                )
                and
                reportQuantity contains (cri-RI-PMI-CQI is present)
            )
            and
            csi-ReportConfigToAddModList contains
            (
                reportConfigId eq 14
                and
                carrier eq 2
                and
                reportConfigType contains
                (
                    periodic contains
                    (
                        reportSlotConfig contains (slots80 is present)
                        and
                        pucch-CSI-ResourceList contains (pucch-Resource eq 21)
                    )
                )
                and
                reportQuantity contains (cri-RI-LI-PMI-CQI is present)
            )
            and
            csi-ReportConfigToAddModList contains
            (
                reportConfigId eq 22
                and
                carrier eq 2
                and
                reportConfigType contains
                (
                    periodic contains
                    (
                        reportSlotConfig contains (slots80 is present)
                        and
                        pucch-CSI-ResourceList contains (pucch-Resource eq 22)
                    )
                )
                and
                reportQuantity contains (cri-RSRP is present)
            )
            and
            csi-ReportConfigToAddModList contains
            (
                reportConfigId eq 15
                and
                carrier eq 3
                and
                reportConfigType contains
                (
                    periodic contains
                    (
                        reportSlotConfig contains (slots80 is present)
                        and
                        pucch-CSI-ResourceList contains (pucch-Resource eq 23)
                    )
                )
                and
                reportQuantity contains (cri-RI-LI-PMI-CQI is present)
            )
            and
            csi-ReportConfigToAddModList contains
            (
                reportConfigId eq 23
                and
                carrier eq 3
                and
                reportConfigType contains
                (
                    periodic contains
                    (
                        reportSlotConfig contains (slots80 is present)
                        and
                        pucch-CSI-ResourceList contains (pucch-Resource eq 24)
                    )
                )
                and
                reportQuantity contains (cri-RSRP is present)
            )
        )
    )
    """

selected_SCell_for_FDD_SCell_Release_in_FFTT_4CC_CA_in_UE_CON_MOD_REQ = \
    """
    SCell-ToBeRemoved-List is present and length(SCell-ToBeRemoved-List) eq 1
    and SCell-ToBeRemoved-List contains
    (
        nRCellIdentity eq "0b000000000000000000000100000000000010"
    )
    """

pucch_for_FDD_SCell_Release_in_FFTT_4CC_CA_in_UE_CON_MOD_RESP = \
    """
    CellGroupConfig contains
    (
        sCellToReleaseList contains (1)
        and length(sCellToReleaseList) eq 1
    )
    and csi-MeasConfig contains
    (
        csi-ReportConfigToReleaseList contains (13)
        and length(csi-ReportConfigToReleaseList) eq 1
    )
    and uplinkBWP-ToAddModList contains
    (
        pucch-Config contains
        (
            resourceSetToAddModList contains
            (
                pucch-ResourceSetId eq 2
                and
                length(resourceList) eq 2
                and
                resourceList contains (9, 22)
            )
            and length(resourceToReleaseList) eq 1
            and resourceToReleaseList contains (19)
        )
    )
    """

measurements_config_for_FDD_SCell_Release_in_FFTT_4CC_CA_in_RRC_Reconfiguration = \
    """
    sCellToReleaseList contains (1)
    and length(sCellToReleaseList) eq 1
    and measConfig contains
    (
        measIdToRemoveList contains (5, 6)
        and length(measIdToRemoveList) eq 2
        and length(measIdToAddModList) eq 1
        and measIdToAddModList contains
        (
            measObjectId eq 1
            and measId eq 12
            and reportConfigId eq 8
        )
    )
    """

selected_SCells_for_SCell_Change_from_FTT_to_FFF_in_UE_Context_Modification_Request = \
    """
    SCell-ToBeSetupMod-List is present
    and length(SCell-ToBeSetupMod-List) eq 2
    and SCell-ToBeSetupMod-List contains
    (
        nRCellIdentity eq "0b000000000000000000000100000000000010"
    )
    and SCell-ToBeSetupMod-List contains
    (
        nRCellIdentity eq "0b000000000000000000000100000000000101"
    )
    and SCell-ToBeRemoved-List is present
    and length(SCell-ToBeRemoved-List) eq 2
    and SCell-ToBeRemoved-List contains
    (
        nRCellIdentity eq "0b000000000000000000000100000000000011"
    )
    and SCell-ToBeRemoved-List contains
    (
        nRCellIdentity eq "0b000000000000000000000100000000000110"
    )
    """

pucch_configuration_for_SCell_Change_from_FTT_to_FFF_3CC_CA_in_UE_Context_Modification_Response = \
    """
    csi-MeasConfig contains
    (
        csi-ReportConfigToReleaseList contains (15, 22, 23)
        and length(csi-ReportConfigToReleaseList) eq 3
        and csi-ReportConfigToAddModList contains
        (
            reportConfigId eq 13
        )
        and csi-ReportConfigToAddModList contains
        (
            reportConfigId eq 14
        )
        and length(csi-ReportConfigToAddModList) eq 2
    )
    and uplinkBWP-ToAddModList contains
    (
        pucch-Config contains
        (
            resourceSetToAddModList contains
            (
                pucch-ResourceSetId eq 1
                and
                length(resourceList) eq 2
                and
                resourceList contains (10, 11)
                and
                maxPayloadSize eq 4
            )
            and resourceSetToAddModList contains
            (
                pucch-ResourceSetId eq 2
                and
                length(resourceList) eq 2
                and
                resourceList contains (9, 19)
            )
            and resourceToAddModList contains
            (
                pucch-ResourceId eq 19
            )
            and length(resourceToAddModList) eq 1
            and resourceToReleaseList contains  (22, 23, 24)
            and length(resourceToReleaseList) eq 3
        )
    )
    """

selected_SCells_for_SCell_Change_from_FTT_to_FFF_in_RRC_Reconfiguration = \
    """
    sCellToAddModList is present
    and length(sCellToAddModList) eq 2
    and sCellToAddModList contains
    (
        physCellId eq 51
    )
    and sCellToAddModList contains
    (
        physCellId eq 54
    )
    and sCellToReleaseList is present
    and length(sCellToReleaseList) eq 2
    and sCellToReleaseList contains (2, 3)
    """

measurement_deconfiguration_A1_A2_and_configuration_A2_SCell_Change_from_FTT_to_FFF_in_RRC_Reconfiguration = \
    """
    measConfig contains
    (
        measIdToRemoveList is present
        and length(measIdToRemoveList) eq 5
        and measIdToRemoveList contains (12, 7, 8, 9, 10)
        and measIdToAddModList is present
        and length(measIdToAddModList) eq 4
        and measIdToAddModList contains
        (
            measObjectId eq 5
            and measId eq 13
            and reportConfigId eq 5
        )
        and measIdToAddModList contains
        (
            measObjectId eq 5
            and measId eq 14
            and reportConfigId eq 6
        )
        and measIdToAddModList contains
        (
            measObjectId eq 6
            and measId eq 15
            and reportConfigId eq 5
        )
        and measIdToAddModList contains
        (
            measObjectId eq 6
            and measId eq 16
            and reportConfigId eq 6
        )
    )
    """
Postcondition_SCell_Change_from_FTT_to_FFF_in_RRC_Reconfiguration = \
    """
    DUtoCURRCInformation contains
    (
        SelectedBandCombinationIndex is present
        and SelectedBandCombinationIndex eq "0x0000"
    )
    """
