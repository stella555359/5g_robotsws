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

resourceSet1_template = """
    length(resourceList) ge {set_length}
    and resourceList contains {Resource_List}
    and maxPayloadSize eq {maxPayloadSize}
    """

resourceSet1_4CC_FFFF = resourceSet1_template.format(
    set_length=2,
    Resource_List=(10, 11),
    maxPayloadSize=8)

resourceSet1_3CC_FTT = resourceSet1_template.format(
    set_length=2,
    Resource_List=(10, 11),
    maxPayloadSize=8)

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

A1_measurement_for_TDD_SCell_Addition = \
    A1_measurement_report_template.format(
        phys_cell_id=51,
        rsrp_threshold=75)

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

meas_config_for_A1_FDD_removal_in_RRC_Reconfiguration = \
    meas_config_for_A1_removal_in_RRC_Reconfiguration_template.format(
        meas_id=4)
