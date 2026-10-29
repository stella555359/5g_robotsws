selected_SCells_for_4CC_CA_in_UE_CON_MOD_REQ_template = """
        CUtoDURRCInformation contains
        (
            allowedBC-ListMRDC contains
            (
                (bandCombinationIndex eq {bandCombinationIndex})
                and (allowedFeatureSetsList contains (1))
            )
        )
        and
        SCell-ToBeSetupMod-List is present and length(SCell-ToBeSetupMod-List) eq 3
        and
        SCell-ToBeSetupMod-List contains
        (
            (sCellIndex eq 1) and (nRCellIdentity eq "{nRCellIdentity_1}")
        )
        and
        SCell-ToBeSetupMod-List contains
        (
            (sCellIndex eq 2) and (nRCellIdentity eq "{nRCellIdentity_2}")
        )
        and
        SCell-ToBeSetupMod-List contains
        (
            (sCellIndex eq 3) and (nRCellIdentity eq "{nRCellIdentity_3}")
        )
        """

selected_SCells_for_4CC_FFFF_UE_CA_in_UE_CON_MOD_REQ = selected_SCells_for_4CC_CA_in_UE_CON_MOD_REQ_template.format(
    bandCombinationIndex=1,
    nRCellIdentity_1="0b000000000000000000000100000000000010",
    nRCellIdentity_2="0b000000000000000000000100000000000011",
    nRCellIdentity_3="0b000000000000000000000100000000000100")

selected_SCells_for_4CC_FFFF_UE_CA_in_UE_CON_MOD_REQ_B8 = selected_SCells_for_4CC_CA_in_UE_CON_MOD_REQ_template.format(
    bandCombinationIndex=1,
    nRCellIdentity_1="0b000000000000000000000100000000000010",
    nRCellIdentity_2="0b000000000000000000000100000000000100",
    nRCellIdentity_3="0b000000000000000000000100000000000110")


selected_SCells_for_4CC_CA_in_UE_CON_MOD_RESP_template = """
    sCellToAddModList is present and length(sCellToAddModList) eq 3
    and sCellToAddModList contains
    (
        sCellIndex eq 1
        and sCellConfigCommon contains (physCellId eq {scell_physcellid_1})
    )
    and sCellToAddModList contains
    (
        sCellIndex eq 2
        and sCellConfigCommon contains (physCellId eq {scell_physcellid_2})
    )
    and sCellToAddModList contains
    (
        sCellIndex eq 3
        and sCellConfigCommon contains (physCellId eq {scell_physcellid_3})
    )
    and SelectedBandCombinationIndex eq "{SelectedBandCombinationIndex}"
    and (SelectedFeatureSetEntryIndex contains ("'00'H"))
    """

selected_SCells_for_4CC_FFFF_UE_CA_in_UE_CON_MOD_RESP = \
    selected_SCells_for_4CC_CA_in_UE_CON_MOD_RESP_template.format(
        scell_physcellid_1=52,
        scell_physcellid_2=53,
        scell_physcellid_3=54,
        SelectedBandCombinationIndex="0x0000")

selected_SCells_for_4CC_FFFF_UE_CA_in_UE_CON_MOD_RESP_B8 = \
    selected_SCells_for_4CC_CA_in_UE_CON_MOD_RESP_template.format(
        scell_physcellid_1=52,
        scell_physcellid_2=54,
        scell_physcellid_3=56,
        SelectedBandCombinationIndex="0x0000")

PUCCH_config_in_UE_CON_MOD_RESP_template = """
    pucch-Config contains
    (
        resourceSetToAddModList is present
        and length(resourceSetToAddModList) eq 2
        and resourceSetToAddModList contains
        (
            pucch-ResourceSetId eq 1
            and
            {resourceSet1_content}
        )
        and resourceSetToAddModList contains
        (
            pucch-ResourceSetId eq 2
            and
            length(resourceList) ge 2
            and
            resourceList contains (9, 19)
        )
        and resourceToAddModList is present
        {resourceToAddModList_content}
        {resourceToAddModList_length}
    )
    """


def fill_PUCCH_config_in_UE_CON_MOD_RESP_template(template=PUCCH_config_in_UE_CON_MOD_RESP_template,
                                                  resourceSet1_content=None,
                                                  resourceToAddModList_content=None,
                                                  resourceToAddModList_length=None):
    """
    :param template: template to use
    :param resourceSet1_content: conditions to be checked in pucch-ResourceSet 1
    :param resourceToAddModList_content: conditions to be checked in resourceToAddModList
    :param resourceToAddModList_length: length of resourceToAddModList (if needs to be asserted)
    :return:
    """
    resourceToAddModList_content = "and {}\n".format(
        resourceToAddModList_content) if resourceToAddModList_content else ""
    resourceToAddModList_length = "and length(resourceToAddModList) eq {}\n".format(
        resourceToAddModList_length) if resourceToAddModList_length else ""
    return template.format(resourceSet1_content=resourceSet1_content,
                           resourceToAddModList_content=resourceToAddModList_content,
                           resourceToAddModList_length=resourceToAddModList_length)


resourceSet1_template = """
    length(resourceList) ge {set_length}
    and resourceList contains {Resource_List}
    and maxPayloadSize eq {maxPayloadSize}
    """

resourceSet1_4CC_FFFF = resourceSet1_template.format(
    set_length=2,
    Resource_List=(10, 11),
    maxPayloadSize=8)

resourceToAddModList_template = """
    resourceToAddModList contains {ResourceIdList}
"""

resourceToAddModList_4CC_FFFF = resourceToAddModList_template.format(
    ResourceIdList=(10, 11, 19, 21, 23))

PUCCH_config_for_4CC_FFFF_CA_in_UE_CON_MOD_RESP_B3 = fill_PUCCH_config_in_UE_CON_MOD_RESP_template(
    resourceSet1_content=resourceSet1_4CC_FFFF,
    resourceToAddModList_content=resourceToAddModList_4CC_FFFF,
    resourceToAddModList_length=5)

CSI_meas_config_for_4CC_FFFF_CA_in_UE_CON_MOD_RESP_B3 = """
    csi-MeasConfig contains
    (
        csi-ReportConfigToAddModList is present
        and length(csi-ReportConfigToAddModList) eq 3
        and csi-ReportConfigToAddModList contains
        (
            reportConfigId eq 13
            and carrier eq 1
            and reportQuantity contains (cri-RI-PMI-CQI is present)
        )
        and csi-ReportConfigToAddModList contains
        (
            reportConfigId eq 14
            and carrier eq 2
            and reportQuantity contains (cri-RI-PMI-CQI is present)
        )
        and csi-ReportConfigToAddModList contains
        (
            reportConfigId eq 15
            and carrier eq 3
            and reportQuantity contains (cri-RI-PMI-CQI is present)
        )
    )
    """

measurementReport_in_UL_DCCH_Message_template = """
    measurementReport contains
    (
        measResults contains
        (
            measId eq {measId}
            and measResultServingMOList contains
            (
                servCellId eq 0
                and measResultServingCell contains
                (
                    physCellId eq {PCellId}
                    and measResult contains
                    (
                        cellResults contains
                        (
                            resultsSSB-Cell contains
                            (
                                rsrp eq {rsrp_threshold_PCell}
                            )
                        )
                    )
                )
            )
            and measResultServingMOList contains
            (
                servCellId eq 1
                and measResultServingCell contains
                (
                    physCellId eq {SCellId}
                    and measResult contains
                    (
                        cellResults contains
                        (
                            resultsSSB-Cell contains
                            (
                                rsrp eq {rsrp_threshold_SCell}
                            )
                        )
                    )
                )
            )
        )
    )
"""

A2_measurementReport_in_UL_DCCH_Message_for_SCell = \
    measurementReport_in_UL_DCCH_Message_template.format(
        measId=2,
        PCellId=51,
        rsrp_threshold_PCell=90,
        SCellId=52,
        rsrp_threshold_SCell=5)

SCells_to_remove_in_UE_CON_MOD_REQ_template = """
    SCell-ToBeRemoved-List is present and length(SCell-ToBeRemoved-List) eq 1
    and SCell-ToBeRemoved-List contains
        (
            SCell-ToBeRemoved-Item contains
            (
                sCell-ID contains
                (
                    nRCellIdentity eq "{nRCellIdentity}"
                )
            )
        )
"""

SCells_to_remove_in_UE_CON_MOD_REQ = \
    SCells_to_remove_in_UE_CON_MOD_REQ_template.format(
        nRCellIdentity="0b000000000000000000000100000000000010")

PUCCH_config_for_3CC_FFF_CA_in_UE_CON_MOD_RESP_template = """
    spCellConfig contains
    (
        pucch-Config contains
        (
            resourceSetToAddModList is present
            and resourceSetToAddModList contains
            (
                pucch-ResourceSetId eq 1
                and
                length(resourceList) eq {set_length}
                and
                maxPayloadSize eq {maxPayloadSize}
            )
            and resourceToReleaseList is present
            and length(resourceToReleaseList) eq {length_to_release_list}
        )
    )
"""

PUCCH_config_for_3CC_FFF_CA_in_UE_CON_MOD_RESP = \
    PUCCH_config_for_3CC_FFF_CA_in_UE_CON_MOD_RESP_template.format(
        set_length=2,
        maxPayloadSize=4,
        length_to_release_list=1)

SCells_to_remove_in_UE_CON_MOD_RESP = """
    sCellToReleaseList is present
    and length(sCellToReleaseList) eq 1
    and sCellToReleaseList contains (1)
"""

meas_config_for_A2_removal_in_RRC_Reconfiguration_template = """
    measConfig contains
    (
        measObjectToRemoveList is present
        and measObjectToRemoveList contains
        (
            {meas_obj_id}
        )
        and measIdToRemoveList is present
        and measIdToRemoveList contains
        (
            {meas_id}
        )
    )
"""

meas_config_for_A2_removal_in_RRC_Reconfiguration = \
    meas_config_for_A2_removal_in_RRC_Reconfiguration_template.format(
        meas_obj_id=2,
        meas_id=2)

rrc_reconfiguration_complete_indicator_in_UE_CON_MOD_REQ = """
    protocolIEs contains
    (
        RRCReconfigurationCompleteIndicator eq "true"
    )
"""

gnb_configuration_query_in_UE_CON_MOD_REQ = """
    protocolIEs contains
    (
        GNB-DUConfigurationQuery eq "true"
    )
"""

A1_measurements_configuration_in_RRCReconfiguration_B8 = """
    measConfig contains
    (
        measObjectToAddModList contains
        (
            measObjectId eq 1
            and
            freqBandIndicatorNR eq 25
        )
        and reportConfigToAddModList contains
        (
            reportConfigId eq 1
            and
            eventId contains (eventA1 is present)
            and
            a1-Threshold contains (rsrp eq 70)
        )
        and measIdToAddModList contains
        (
            measId eq 1
            and measObjectId eq 1
            and reportConfigId eq 1
        )
    )
    """


meas_config_in_RRCReconfiguration_B8 = """
    measConfig contains
    (
        measObjectToAddModList contains
        (
            measObjectId eq 2
            and
            freqBandIndicatorNR eq 25
        )
        and measObjectToAddModList contains
        (
            measObjectId eq 3
            and
            freqBandIndicatorNR eq 66
        )
        and measObjectToAddModList contains
        (
            measObjectId eq 4
            and
            freqBandIndicatorNR eq 71
        )
        and reportConfigToAddModList contains
        (
            reportConfigId eq 2
            and
            eventId contains (eventA6 is present)
            and
            a6-Offset contains (rsrp eq 0)
        )
        and measIdToAddModList contains
        (
            measId eq 2
            and
            measObjectId eq 2
            and
            reportConfigId eq 2
        )
        and measIdToAddModList contains
        (
            measId eq 3
            and
            measObjectId eq 3
            and
            reportConfigId eq 2
        )
        and measIdToAddModList contains
        (
            measId eq 4
            and
            measObjectId eq 4
            and
            reportConfigId eq 2
        )
        and measIdToRemoveList is present
        and length(measIdToRemoveList) eq 1
        and measIdToRemoveList contains (1)
        and reportConfigToRemoveList is present
        and length(reportConfigToRemoveList) eq 1
        and reportConfigToRemoveList contains (1)
    )
    """

# After SCell Swap Filters

selected_SCells_for_4CC_CA_in_UE_CON_MOD_REQ_swap_template = """
        SCell-ToBeSetupMod-List is present and length(SCell-ToBeSetupMod-List) eq 1
        and
        SCell-ToBeSetupMod-List contains
        (
            (sCellIndex eq 4) and (nRCellIdentity eq "{nRCellIdentity_4}")
        )
        and
        SCell-ToBeRemoved-List is present and length(SCell-ToBeSetupMod-List) eq 1
        and
        SCell-ToBeRemoved-List contains
        (
            nRCellIdentity eq "{nRCellIdentity_1}"
        )
        """

selected_SCells_for_4CC_FFFF_UE_CA_in_UE_CON_MOD_REQ_B8_swap = \
    selected_SCells_for_4CC_CA_in_UE_CON_MOD_REQ_swap_template.format(
        bandCombinationIndex=1,
        nRCellIdentity_1="0b000000000000000000000100000000000010",
        nRCellIdentity_4="0b000000000000000000000100000000000011")

selected_SCells_for_4CC_CA_in_UE_CON_MOD_RESP_swap_template = """
    sCellToAddModList is present and length(sCellToAddModList) eq 1
    and sCellToAddModList contains
    (
        sCellIndex eq 4
        and sCellConfigCommon contains (physCellId eq {scell_physcellid_1})
    )
    and sCellToReleaseList is present and length(sCellToReleaseList) eq 1
    and sCellToReleaseList contains (1)
    """

selected_SCells_for_4CC_FFFF_UE_CA_in_UE_CON_MOD_RESP_B8_swap = \
    selected_SCells_for_4CC_CA_in_UE_CON_MOD_RESP_swap_template.format(
        scell_physcellid_1=53,
        SelectedBandCombinationIndex="0x0000")


CSI_meas_config_for_4CC_FFFF_CA_in_UE_CON_MOD_RESP_B8_swap = """
    csi-MeasConfig contains
    (
        csi-ReportConfigToAddModList is present
        and length(csi-ReportConfigToAddModList) eq 1
        and csi-ReportConfigToAddModList contains
        (
            reportConfigId eq 13
            and carrier eq 4
            and reportQuantity contains (cri-RI-PMI-CQI is present)
        )
    )
    """

PUCCH_config_for_4CC_FFFF_CA_in_UE_CON_MOD_RESP_B8_swap = """
    pucch-Config contains
    (
        resourceSetToAddModList is present
        and length(resourceSetToAddModList) eq 1
        and resourceSetToAddModList contains
        (
            pucch-ResourceSetId eq 2
            and
            length(resourceList) ge 2
            and
            resourceList contains (9, 23)
        )
        and resourceToAddModList is present
        and length(resourceToAddModList) eq 1
        and resourceToAddModList contains
        (
            pucch-ResourceId eq 19
        )
    )
    """

meas_config_in_RRCReconfiguration_B8_swap = """
    measConfig contains
    (
        measObjectToAddModList contains
        (
            measObjectId eq 1
            and
            freqBandIndicatorNR eq 25
        )
        and measIdToAddModList contains
        (
            measId eq 2
            and
            measObjectId eq 2
            and
            reportConfigId eq 2
        )
        and measIdToRemoveList is not present
        and reportConfigToRemoveList is not present
    )
    """

# PCell Change filters

meas_config_in_RRCReconfiguration_B7 = """
    measConfig contains
    (
        measObjectToAddModList contains
        (
            measObjectId eq 2
            and freqBandIndicatorNR eq 66
        )
        and measObjectToAddModList contains
        (
            measObjectId eq 3
            and freqBandIndicatorNR eq 25
        )
        and measObjectToAddModList contains
        (
            measObjectId eq 4
            and freqBandIndicatorNR eq 71
        )
        and reportConfigToAddModList contains
        (
            reportConfigId eq 2
            and eventId contains (eventA2 is present)
        )
        and measIdToAddModList contains
        (
            measId eq 2
            and measObjectId eq 1
            and reportConfigId eq 2
        )
        and measIdToRemoveList is present
        and length(measIdToRemoveList) eq 1
        and measIdToRemoveList contains (1)
        and reportConfigToRemoveList is present
        and length(reportConfigToRemoveList) eq 1
        and reportConfigToRemoveList contains (1)
    )
    """

A2_measurementReport_in_UL_DCCH_Message_for_PCell_Change = """
    measurementReport contains
    (
        measResults contains
        (
            measId eq 2
            and measResultServingMOList contains
            (
                servCellId eq 0
                and measResultServingCell contains
                (
                    physCellId eq 51
                    and measResult contains
                    (
                        cellResults contains
                        (
                            resultsSSB-Cell contains
                            (
                                rsrp eq 20
                            )
                        )
                    )
                )
            )
            and measResultServingMOList contains
            (
                servCellId eq 1
                and measResultServingCell contains
                (
                    physCellId eq 52
                    and measResult contains
                    (
                        cellResults contains
                        (
                            resultsSSB-Cell contains
                            (
                                rsrp eq 70
                            )
                        )
                    )
                )
            )
            and measResultServingMOList contains
            (
                servCellId eq 2
                and measResultServingCell contains
                (
                    physCellId eq 53
                    and measResult contains
                    (
                        cellResults contains
                        (
                            resultsSSB-Cell contains
                            (
                                rsrp eq 10
                            )
                        )
                    )
                )
            )
            and measResultServingMOList contains
            (
                servCellId eq 3
                and measResultServingCell contains
                (
                    physCellId eq 54
                    and measResult contains
                    (
                        cellResults contains
                        (
                            resultsSSB-Cell contains
                            (
                                rsrp eq 50
                            )
                        )
                    )
                )
            )
        )
    )
"""

HO_PREP_in_UE_CON_MOD_REQ_B7 = """
    spCellConfig contains
    (reconfigurationWithSync contains
        (spCellConfigCommon contains
            (physCellId eq 51)
        )
    )
    """

SCell_ToBeRemoved_List_in_UE_CON_MOD_REQ_B7_template = """
        SCell-ToBeRemoved-List is present
        and length(SCell-ToBeRemoved-List) eq 3
        and SCell-ToBeRemoved-List contains
        (
            nRCellIdentity eq "{nRCellIdentity_1}"
        )
        and SCell-ToBeRemoved-List contains
        (
            nRCellIdentity eq "{nRCellIdentity_2}"
        )
        and SCell-ToBeRemoved-List contains
        (
            nRCellIdentity eq "{nRCellIdentity_3}"
        )
        """

SCell_ToBeRemoved_List_in_UE_CON_MOD_REQ_B7 = \
    SCell_ToBeRemoved_List_in_UE_CON_MOD_REQ_B7_template.format(
        nRCellIdentity_1="0b000000000000000000000100000000000010",
        nRCellIdentity_2="0b000000000000000000000100000000000011",
        nRCellIdentity_3="0b000000000000000000000100000000000100")

spCellConfig_in_UE_CON_MOD_RESP_B7 = """
    DUtoCURRCInformation contains
    (
        CellGroupConfig contains
        (
            spCellConfig contains
            (
                reconfigurationWithSync contains
                (
                    spCellConfigCommon contains
                    (
                        physCellId eq 54
                    )
                )
                and csi-MeasConfig contains
                (
                    csi-ReportConfigToReleaseList is present
                    and length(csi-ReportConfigToReleaseList) eq 4
                    and csi-ReportConfigToReleaseList contains (0, 13, 14, 15)
                )
            )
            and sCellToReleaseList is present
            and length(sCellToReleaseList) eq 3
            and sCellToReleaseList contains (1,2,3)
        )
    )
"""

meas_config_in_RRC_Reconf_FFFF_B7 = """
    measConfig contains
    (
        measObjectToRemoveList contains (1,2,3)
        and measObjectToAddModList contains
        (
            measObjectId eq 4
            and
            freqBandIndicatorNR eq 71
        )
        and reportConfigToAddModList contains
        (
            reportConfigId eq 3
            and
            eventId contains (eventA1 is present)
            and
            a1-Threshold contains (rsrp eq 70)
        )
        and reportConfigToRemoveList contains (2)
        and measIdToRemoveList contains (2)
        and measIdToAddModList contains
        (
            measId eq 3
            and
            measObjectId eq 4
            and
            reportConfigId eq 3
        )
    )
    """

nonCriticalExtension_in_RRC_Reconf_FFFF_B7 = """
    sCellToReleaseList is present
    and sCellToReleaseList contains (1,2,3)
"""

selected_SCells_for_4CC_CA_in_UE_CON_MOD_REQ_template = """
        SCell-ToBeSetupMod-List contains
        (
            sCellIndex eq 1
            and nRCellIdentity eq "{nRCellIdentity_1}"
        )
        and SCell-ToBeSetupMod-List contains
        (
            sCellIndex eq 2
            and nRCellIdentity eq "{nRCellIdentity_2}"
        )
        and SCell-ToBeSetupMod-List contains
        (
            sCellIndex eq 3
            and nRCellIdentity eq "{nRCellIdentity_3}"
        )
        """

selected_SCells_for_4CC_FFFF_CA_in_UE_CON_MOD_REQ_B7 = selected_SCells_for_4CC_CA_in_UE_CON_MOD_REQ_template.format(
    bandCombinationIndex=4,
    nRCellIdentity_1="0b000000000000000000000100000000000001",
    nRCellIdentity_2="0b000000000000000000000100000000000010",
    nRCellIdentity_3="0b000000000000000000000100000000000011")

selected_SCells_for_4CC_CA_in_UE_CON_MOD_RESP_template = """
    sCellToAddModList is present and length(sCellToAddModList) eq 3
    and sCellToAddModList contains
    (
        sCellIndex eq 1
        and sCellConfigCommon contains (physCellId eq {scell_physcellid_1})
    )
    and sCellToAddModList contains
    (
        sCellIndex eq 2
        and sCellConfigCommon contains (physCellId eq {scell_physcellid_2})
    )
    and sCellToAddModList contains
    (
        sCellIndex eq 3
        and sCellConfigCommon contains (physCellId eq {scell_physcellid_3})
    )
    and SelectedBandCombinationIndex eq "{SelectedBandCombinationIndex}"
    and (SelectedFeatureSetEntryIndex contains ("'00'H"))
    """

selected_SCells_for_4CC_FFFF_CA_in_UE_CON_MOD_RESP_B7 = \
    selected_SCells_for_4CC_CA_in_UE_CON_MOD_RESP_template.format(
        scell_physcellid_1=51,
        scell_physcellid_2=52,
        scell_physcellid_3=53,
        SelectedBandCombinationIndex="0x0000")

meas_config_in_RRCReconfiguration_After_A2_B7 = """
    measConfig contains
    (
        measObjectToAddModList contains
        (
            measObjectId eq 5
            and
            freqBandIndicatorNR eq 25
        )
        and measObjectToAddModList contains
        (
            measObjectId eq 6
            and
            freqBandIndicatorNR eq 66
        )
        and measObjectToAddModList contains
        (
            measObjectId eq 7
            and
            freqBandIndicatorNR eq 25
        )
        and measIdToRemoveList is present
        and length(measIdToRemoveList) eq 1
        and measIdToRemoveList contains (3)
        and reportConfigToRemoveList is present
        and length(reportConfigToRemoveList) eq 1
        and reportConfigToRemoveList contains (3)
    )
    """

A1_measurement_report_template = """
    measurementReport contains
    (
        measResults contains
        (
            measId eq 1
            and measResultServingMOList contains
            (
                servCellId eq 0
                and measResultServingCell contains
        (
        physCellId eq {phys_cell_id}
        and measResult contains
            (
            cellResults contains
                (
                resultsSSB-Cell contains
                    (
                    rsrp eq {rsrp_threshold}
                    )
                )
            )
        )
            )
        )
    )
"""

A1_measurement_for_SCell_Addition = \
    A1_measurement_report_template.format(
        phys_cell_id=51,
        rsrp_threshold=90)

meas_config_for_A1_removal_in_RRC_Reconfiguration_template = """
    measConfig contains
    (
        measIdToRemoveList is present
        and measIdToRemoveList contains
        (
            {meas_id}
        )
    )
"""

meas_config_for_A1_removal_in_RRC_Reconfiguration = \
    meas_config_for_A1_removal_in_RRC_Reconfiguration_template.format(
        meas_id=1)

A1_measurement_report_template_2 = """
    measurementReport contains
    (
        measResults contains
        (
            measId eq 4
            and measResultServingMOList contains
            (
                servCellId eq 0
                and measResultServingCell contains
        (
        physCellId eq {phys_cell_id}
        and measResult contains
            (
            cellResults contains
                (
                resultsSSB-Cell contains
                    (
                    rsrp eq {rsrp_threshold}
                    )
                )
            )
        )
            )
        )
    )
"""

A1_measurement_for_TDD_SCell_Addition = \
    A1_measurement_report_template.format(
        phys_cell_id=51,
        rsrp_threshold=75)

A1_measurement_for_FDD_SCell_Addition = \
    A1_measurement_report_template_2.format(
        phys_cell_id=51,
        rsrp_threshold=90)

selected_SCells_for_3CC_CA_in_UE_CON_MOD_REQ_template = """
        SCell-ToBeSetupMod-List contains
        (
            sCellIndex eq 1
            and nRCellIdentity eq "{nRCellIdentity_1}"
        )
        and SCell-ToBeSetupMod-List contains
        (
            sCellIndex eq 2
            and nRCellIdentity eq "{nRCellIdentity_2}"
        )
        """

selected_SCells_for_3CC_FTT_UE_CA_in_UE_CON_MOD_REQ = selected_SCells_for_3CC_CA_in_UE_CON_MOD_REQ_template.format(
    bandCombinationIndex=1,
    nRCellIdentity_1="0b000000000000000000000100000000000101",
    nRCellIdentity_2="0b000000000000000000000100000000000110")

resourceSet1_3CC_FTT = resourceSet1_template.format(
    set_length=2,
    Resource_List=(10, 11),
    maxPayloadSize=8)

selected_SCells_for_3CC_CA_in_UE_CON_MOD_RESP_template = """
    sCellToAddModList is present and length(sCellToAddModList) eq 2
    and sCellToAddModList contains
    (
        sCellIndex eq 1
        and sCellConfigCommon contains (physCellId eq {scell_physcellid_1})
    )
    and sCellToAddModList contains
    (
        sCellIndex eq 2
        and sCellConfigCommon contains (physCellId eq {scell_physcellid_2})
    )
    and SelectedBandCombinationIndex eq "{SelectedBandCombinationIndex}"
    and (SelectedFeatureSetEntryIndex contains ("'00'H"))
    """

selected_SCells_for_3CC_FTT_UE_CA_in_UE_CON_MOD_RESP = \
    selected_SCells_for_3CC_CA_in_UE_CON_MOD_RESP_template.format(
        scell_physcellid_1=55,
        scell_physcellid_2=56,
        SelectedBandCombinationIndex="0x0001")

meas_config_for_A1_FDD_removal_in_RRC_Reconfiguration = \
    meas_config_for_A1_removal_in_RRC_Reconfiguration_template.format(
        meas_id=4)

selected_SCells_for_4CC_CA_in_UE_CON_MOD_REQ_template_2 = """
        CUtoDURRCInformation contains
        (
            allowedBC-ListMRDC contains
            (
                (bandCombinationIndex eq {bandCombinationIndex})
                and (allowedFeatureSetsList contains (1))
            )
        )
        and
        SCell-ToBeSetupMod-List is present and length(SCell-ToBeSetupMod-List) eq 3
        and
        SCell-ToBeSetupMod-List contains
        (
            (sCellIndex eq 3) and (nRCellIdentity eq "{nRCellIdentity_3}")
        )
        and
        SCell-ToBeSetupMod-List contains
        (
            (sCellIndex eq 4) and (nRCellIdentity eq "{nRCellIdentity_4}")
        )
        and
        SCell-ToBeSetupMod-List contains
        (
            (sCellIndex eq 5) and (nRCellIdentity eq "{nRCellIdentity_5}")
        )
        """

selected_SCells_for_4CC_FFFF_UE_CA_in_UE_CON_MOD_REQ_2 = selected_SCells_for_4CC_CA_in_UE_CON_MOD_REQ_template_2.format(
    bandCombinationIndex=1,
    nRCellIdentity_3="0b000000000000000000000100000000000010",
    nRCellIdentity_4="0b000000000000000000000100000000000011",
    nRCellIdentity_5="0b000000000000000000000100000000000100")

selected_SCells_for_4CC_CA_in_UE_CON_MOD_RESP_template_2 = """
    sCellToAddModList is present and length(sCellToAddModList) eq 3
    and sCellToAddModList contains
    (
        sCellIndex eq 3
        and sCellConfigCommon contains (physCellId eq {scell_physcellid_3})
    )
    and sCellToAddModList contains
    (
        sCellIndex eq 4
        and sCellConfigCommon contains (physCellId eq {scell_physcellid_4})
    )
    and sCellToAddModList contains
    (
        sCellIndex eq 5
        and sCellConfigCommon contains (physCellId eq {scell_physcellid_5})
    )
    and SelectedBandCombinationIndex eq "{SelectedBandCombinationIndex}"
    and (SelectedFeatureSetEntryIndex contains ("'00'H"))
    """

selected_SCells_for_4CC_FFFF_UE_CA_in_UE_CON_MOD_RESP_2 = \
    selected_SCells_for_4CC_CA_in_UE_CON_MOD_RESP_template_2.format(
        scell_physcellid_3=52,
        scell_physcellid_4=53,
        scell_physcellid_5=54,
        SelectedBandCombinationIndex="0x0000")
