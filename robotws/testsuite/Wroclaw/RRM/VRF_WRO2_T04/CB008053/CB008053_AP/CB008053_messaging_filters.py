selected_SCells_for_3CC_CA_in_UE_CON_MOD_REQ_template = """
    SCell-ToBeSetupMod-List is present and length(SCell-ToBeSetupMod-List) eq 2
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
    """

selected_SCells_for_3CC_CA_in_UE_CON_MOD_REQ_DB2B_template = """
    CUtoDURRCInformation contains
    (
        allowedBC-ListMRDC contains
        (
            (bandCombinationIndex eq {bandCombinationIndex})
            and (allowedFeatureSetsList contains (1))
        )
    )
    and
    SCell-ToBeSetupMod-List is present and length(SCell-ToBeSetupMod-List) eq 2
    and
    SCell-ToBeSetupMod-List contains
    (
        (sCellIndex eq 1) and (nRCellIdentity eq "{nRCellIdentity}")
    )
    and
    SCell-ToBeSetupMod-List contains
    (
        (sCellIndex eq 2) and (nRCellIdentity eq "0b000000000000000000000100000000000110")
    )
    """

selected_SCells_for_3CC_TTT_CA_in_UE_CON_MOD_REQ = selected_SCells_for_3CC_CA_in_UE_CON_MOD_REQ_template.format(
    nRCellIdentity_1="0b000000000000000000000100000000000101",
    nRCellIdentity_2="0b000000000000000000000100000000000110")
selected_SCells_for_3CC_FTT_CA_in_UE_CON_MOD_REQ = selected_SCells_for_3CC_CA_in_UE_CON_MOD_REQ_template.format(
    nRCellIdentity_1="0b000000000000000000000100000000000100",
    nRCellIdentity_2="0b000000000000000000000100000000000110")
selected_SCells_for_3CC_FFF_CA_in_UE_CON_MOD_REQ = selected_SCells_for_3CC_CA_in_UE_CON_MOD_REQ_template.format(
    nRCellIdentity_1="0b000000000000000000000100000000000010",
    nRCellIdentity_2="0b000000000000000000000100000000000011")
selected_SCells_for_3CC_FFT_DB2b_UE2_CA_in_UE_CON_MOD_REQ = \
    selected_SCells_for_3CC_CA_in_UE_CON_MOD_REQ_DB2B_template.format(
        bandCombinationIndex=2,
        nRCellIdentity="0b000000000000000000000100000000000010")

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

selected_SCells_for_4CC_FTTT_CA_in_UE_CON_MOD_REQ = selected_SCells_for_4CC_CA_in_UE_CON_MOD_REQ_template.format(
    bandCombinationIndex=2,
    nRCellIdentity_1="0b000000000000000000000100000000000100",
    nRCellIdentity_2="0b000000000000000000000100000000000101",
    nRCellIdentity_3="0b000000000000000000000100000000000110")

selected_SCells_for_4CC_TTTF_UE1_CA_in_UE_CON_MOD_REQ = selected_SCells_for_4CC_CA_in_UE_CON_MOD_REQ_template.format(
    bandCombinationIndex=4,
    nRCellIdentity_1="0b000000000000000000000100000000000011",
    nRCellIdentity_2="0b000000000000000000000100000000000101",
    nRCellIdentity_3="0b000000000000000000000100000000000110")

selected_SCells_for_4CC_TTTF_UE1_CA_in_UE_CON_MOD_REQ_A_B1c = \
    selected_SCells_for_4CC_CA_in_UE_CON_MOD_REQ_template.format(
        bandCombinationIndex=2,
        nRCellIdentity_1="0b000000000000000000000100000000000001",
        nRCellIdentity_2="0b000000000000000000000100000000000101",
        nRCellIdentity_3="0b000000000000000000000100000000000110")

selected_SCells_for_4CC_TTTF_UE2_CA_in_UE_CON_MOD_REQ = selected_SCells_for_4CC_CA_in_UE_CON_MOD_REQ_template.format(
    bandCombinationIndex=3,
    nRCellIdentity_1="0b000000000000000000000100000000000010",
    nRCellIdentity_2="0b000000000000000000000100000000000101",
    nRCellIdentity_3="0b000000000000000000000100000000000110")

selected_SCells_for_4CC_FTTT_CA_in_UE_CON_MOD_REQ_B5 = selected_SCells_for_4CC_CA_in_UE_CON_MOD_REQ_template.format(
    bandCombinationIndex=4,
    nRCellIdentity_1="0b000000000000000000000100000000000100",
    nRCellIdentity_2="0b000000000000000000000100000000000101",
    nRCellIdentity_3="0b000000000000000000000100000000000110")

selected_SCells_for_TTTF_4CC_CA_in_UE_CON_MOD_REQ = selected_SCells_for_4CC_CA_in_UE_CON_MOD_REQ_template.format(
    bandCombinationIndex=4,
    nRCellIdentity_1="0b000000000000000000000100000000000011",
    nRCellIdentity_2="0b000000000000000000000100000000000101",
    nRCellIdentity_3="0b000000000000000000000100000000000110")

selected_SCells_for_TTTF_4CC_CA_in_UE_CON_MOD_REQ_AB8 = selected_SCells_for_4CC_CA_in_UE_CON_MOD_REQ_template.format(
    bandCombinationIndex=2,
    nRCellIdentity_1="0b000000000000000000000100000000000001",
    nRCellIdentity_2="0b000000000000000000000100000000000101",
    nRCellIdentity_3="0b000000000000000000000100000000000110")

selected_SCells_for_4CC_TTFF_DB1a_UE2_CA_in_UE_CON_MOD_REQ = \
    selected_SCells_for_4CC_CA_in_UE_CON_MOD_REQ_template.format(
        bandCombinationIndex=2,
        nRCellIdentity_1="0b000000000000000000000100000000000001",
        nRCellIdentity_2="0b000000000000000000000100000000000010",
        nRCellIdentity_3="0b000000000000000000000100000000000110")

selected_SCells_for_4CC_TTTF_DB1a_UE1_CA_in_UE_CON_MOD_REQ = \
    selected_SCells_for_4CC_CA_in_UE_CON_MOD_REQ_template.format(
        bandCombinationIndex=1,
        nRCellIdentity_1="0b000000000000000000000100000000000001",
        nRCellIdentity_2="0b000000000000000000000100000000000101",
        nRCellIdentity_3="0b000000000000000000000100000000000110")

selected_SCells_for_4CC_FTTT_DB2b_UE1_CA_in_UE_CON_MOD_REQ = \
    selected_SCells_for_4CC_CA_in_UE_CON_MOD_REQ_template.format(
        bandCombinationIndex=1,
        nRCellIdentity_1="0b000000000000000000000100000000000100",
        nRCellIdentity_2="0b000000000000000000000100000000000101",
        nRCellIdentity_3="0b000000000000000000000100000000000110")

# CB008053-B2_B
selected_and_removed_SCells_for_4CC_CA_in_UE_CON_MOD_REQ_template = """
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
        (sCellIndex eq 3) and (nRCellIdentity eq "0b000000000000000000000100000000000100")
    )
    and
    SCell-ToBeSetupMod-List contains
    (
        (sCellIndex eq 4) and (nRCellIdentity eq "0b000000000000000000000100000000000101")
    )
    and
    SCell-ToBeSetupMod-List contains
    (
        (sCellIndex eq 5) and (nRCellIdentity eq "0b000000000000000000000100000000000110")
    )
    and
    SCell-ToBeRemoved-List is present and length(SCell-ToBeRemoved-List) eq 2
    and
    SCell-ToBeRemoved-List contains
    (
        nRCellIdentity eq "0b000000000000000000000100000000000010"
    )
    and
    SCell-ToBeRemoved-List contains
    (
        nRCellIdentity eq "0b000000000000000000000100000000000011"
    )
    """

selected_and_removed_SCells_for_4CC_FTTT_CA_in_UE_CON_MOD_REQ = \
    selected_and_removed_SCells_for_4CC_CA_in_UE_CON_MOD_REQ_template.format(
        bandCombinationIndex=2)

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
    """

selected_SCells_for_3CC_CA_in_UE_CON_MOD_RESP_DB2B_template = """
    sCellToAddModList is present and length(sCellToAddModList) eq 2
    and sCellToAddModList contains
    (
        sCellIndex eq 1
        and sCellConfigCommon contains (physCellId eq {scell_physcellid})
    )
    and sCellToAddModList contains
    (
        sCellIndex eq 2
        and sCellConfigCommon contains (physCellId eq 56)
    )
    and SelectedBandCombinationIndex eq "{SelectedBandCombinationIndex}"
    and (SelectedFeatureSetEntryIndex contains ("'00'H"))
    """

selected_SCells_for_3CC_TTT_CA_in_UE_CON_MOD_RESP = selected_SCells_for_3CC_CA_in_UE_CON_MOD_RESP_template.format(
    scell_physcellid_1=55,
    scell_physcellid_2=56)
selected_SCells_for_3CC_FTT_CA_in_UE_CON_MOD_RESP = selected_SCells_for_3CC_CA_in_UE_CON_MOD_RESP_template.format(
    scell_physcellid_1=54,
    scell_physcellid_2=56)
selected_SCells_for_3CC_FFF_CA_in_UE_CON_MOD_RESP = selected_SCells_for_3CC_CA_in_UE_CON_MOD_RESP_template.format(
    scell_physcellid_1=52,
    scell_physcellid_2=53)
selected_SCells_for_3CC_FFT_DB2b_UE2_CA_in_UE_CON_MOD_RESP = \
    selected_SCells_for_3CC_CA_in_UE_CON_MOD_RESP_DB2B_template.format(
        scell_physcellid=52, SelectedBandCombinationIndex="0x0001")

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

selected_SCells_for_4CC_FTTT_CA_in_UE_CON_MOD_RESP = selected_SCells_for_4CC_CA_in_UE_CON_MOD_RESP_template.format(
    scell_physcellid_1=54, scell_physcellid_2=55, scell_physcellid_3=56, SelectedBandCombinationIndex="0x0001")
selected_SCells_for_4CC_TTTF_UE1_CA_in_UE_CON_MOD_RESP = selected_SCells_for_4CC_CA_in_UE_CON_MOD_RESP_template.format(
    scell_physcellid_1=53, scell_physcellid_2=55, scell_physcellid_3=56, SelectedBandCombinationIndex="0x0003")
selected_SCells_for_4CC_TTTF_UE1_CA_in_UE_CON_MOD_RESP_A_B1c = \
    selected_SCells_for_4CC_CA_in_UE_CON_MOD_RESP_template.format(
        scell_physcellid_1=51, scell_physcellid_2=55, scell_physcellid_3=56, SelectedBandCombinationIndex="0x0001")
selected_SCells_for_4CC_TTTF_UE2_CA_in_UE_CON_MOD_RESP = selected_SCells_for_4CC_CA_in_UE_CON_MOD_RESP_template.format(
    scell_physcellid_1=52, scell_physcellid_2=55, scell_physcellid_3=56, SelectedBandCombinationIndex="0x0002")
selected_SCells_for_TTTF_4CC_CA_in_UE_CON_MOD_RESP = selected_SCells_for_4CC_CA_in_UE_CON_MOD_RESP_template.format(
    scell_physcellid_1=53, scell_physcellid_2=55, scell_physcellid_3=56, SelectedBandCombinationIndex="0x0003")
selected_SCells_for_TTTF_4CC_CA_in_UE_CON_MOD_RESP_AB8 = selected_SCells_for_4CC_CA_in_UE_CON_MOD_RESP_template.format(
    scell_physcellid_1=51, scell_physcellid_2=55, scell_physcellid_3=56, SelectedBandCombinationIndex="0x0001")
selected_SCells_for_4CC_FTTT_CA_in_UE_CON_MOD_RESP_B5 = selected_SCells_for_4CC_CA_in_UE_CON_MOD_RESP_template.format(
    scell_physcellid_1=54, scell_physcellid_2=55, scell_physcellid_3=56, SelectedBandCombinationIndex="0x0003")
selected_SCells_for_4CC_TTTF_DB1a_UE1_CA_in_UE_CON_MOD_RESP = \
    selected_SCells_for_4CC_CA_in_UE_CON_MOD_RESP_template.format(
        scell_physcellid_1=51, scell_physcellid_2=55, scell_physcellid_3=56, SelectedBandCombinationIndex="0x0000")
selected_SCells_for_3CC_F_DB2b_UE1_CA_in_UE_CON_MOD_RESP = selected_SCells_for_4CC_TTTF_DB1a_UE1_CA_in_UE_CON_MOD_RESP
selected_SCells_for_4CC_TTFF_DB1a_UE2_CA_in_UE_CON_MOD_RESP = \
    selected_SCells_for_4CC_CA_in_UE_CON_MOD_RESP_template.format(
        scell_physcellid_1=51, scell_physcellid_2=52, scell_physcellid_3=56, SelectedBandCombinationIndex="0x0001")
selected_SCells_for_4CC_FTTT_DB2b_UE1_CA_in_UE_CON_MOD_RESP = \
    selected_SCells_for_4CC_CA_in_UE_CON_MOD_RESP_template.format(
        scell_physcellid_1=54, scell_physcellid_2=55, scell_physcellid_3=56, SelectedBandCombinationIndex="0x0000")

# CB008053-B_B2
selected_SCells_for_4CC_SCell_Change_CA_in_UE_CON_MOD_RESP_template = """
    sCellToAddModList is present and length(sCellToAddModList) eq 3
    and sCellToAddModList contains
    (
        sCellIndex eq 3
        and sCellConfigCommon contains (physCellId eq {scell_physcellid})
    )
    and sCellToAddModList contains
    (
        sCellIndex eq 4
        and sCellConfigCommon contains (physCellId eq 55)
    )
    and sCellToAddModList contains
    (
        sCellIndex eq 5
        and sCellConfigCommon contains (physCellId eq 56)
    )
    and
    sCellToReleaseList is present
    and length(sCellToReleaseList) eq 2
    and sCellToReleaseList contains (1, 2)
    and SelectedBandCombinationIndex eq "{SelectedBandCombinationIndex}"
    and (SelectedFeatureSetEntryIndex contains ("'00'H"))
    """

selected_SCells_for_4CC_FTTT_SCell_Change_CA_in_UE_CON_MOD_RESP = \
    selected_SCells_for_4CC_SCell_Change_CA_in_UE_CON_MOD_RESP_template.format(
        scell_physcellid=54, SelectedBandCombinationIndex="0x0001")

selected_SCell_for_Release_and_BandCombIndex_in_UE_CON_MOD_RESP_template = """
    sCellToReleaseList contains ({scell_scellindex})
    and length(sCellToReleaseList) eq 1
    and SelectedBandCombinationIndex eq "{SelectedBandCombinationIndex}"
    and (SelectedFeatureSetEntryIndex contains ("'00'H"))
"""

selected_3th_SCell_TDD_for_Release_in_TTTF_4CC_CA_in_UE_CON_MOD_RESP = \
    selected_SCell_for_Release_and_BandCombIndex_in_UE_CON_MOD_RESP_template.format(
        scell_scellindex=3, SelectedBandCombinationIndex="0x0001")

selected_2nd_SCell_TDD_for_Release_in_TTTF_4CC_CA_in_UE_CON_MOD_RESP = \
    selected_SCell_for_Release_and_BandCombIndex_in_UE_CON_MOD_RESP_template.format(
        scell_scellindex=2, SelectedBandCombinationIndex="0x0001")

selected_1st_SCell_FDD_for_Release_in_TTTF_4CC_CA_in_UE_CON_MOD_RESP = """
    sCellToReleaseList contains (1)
    and length(sCellToReleaseList) eq 1
"""

selected_SCell_for_SCell_Release_in_TTTF_4CC_CA_in_UE_CON_MOD_REQ_template = """
    SCell-ToBeRemoved-List is present and length(SCell-ToBeRemoved-List) eq 1
    and SCell-ToBeRemoved-List contains
    (
        nRCellIdentity eq "{nRCellIdentity}"
    )
    """
selected_1st_SCell_for_FDD_SCell_Release_in_TTTF_4CC_CA_in_UE_CON_MOD_REQ = \
    selected_SCell_for_SCell_Release_in_TTTF_4CC_CA_in_UE_CON_MOD_REQ_template.format(
        nRCellIdentity="0b000000000000000000000100000000000001")
selected_2nd_SCell_for_TDD_SCell_Release_in_TTTF_4CC_CA_in_UE_CON_MOD_REQ = \
    selected_SCell_for_SCell_Release_in_TTTF_4CC_CA_in_UE_CON_MOD_REQ_template.format(
        nRCellIdentity="0b000000000000000000000100000000000101")
selected_3th_SCell_for_TDD_SCell_Release_in_TTTF_4CC_CA_in_UE_CON_MOD_REQ = \
    selected_SCell_for_SCell_Release_in_TTTF_4CC_CA_in_UE_CON_MOD_REQ_template.format(
        nRCellIdentity="0b000000000000000000000100000000000110")

# D-B1a
selected_SCells_for_2CC_TT_CA_in_UE_CON_MOD_REQ_template = """
    CUtoDURRCInformation contains
    (
        allowedBC-ListMRDC contains
        (
            bandCombinationIndex eq {bandCombinationIndex}
            and allowedFeatureSetsList contains (1)
        )
    )
    and
    SCell-ToBeSetupMod-List is present and length(SCell-ToBeSetupMod-List) eq 1
    and
    SCell-ToBeSetupMod-List contains
    (
        (sCellIndex eq 1) and (nRCellIdentity eq "{nRCellIdentity}")
    )
    """

selected_SCells_for_2CC_TT_DB1a_UE3_CA_in_UE_CON_MOD_REQ = \
    selected_SCells_for_2CC_TT_CA_in_UE_CON_MOD_REQ_template.format(
        bandCombinationIndex=1,
        nRCellIdentity="0b000000000000000000000100000000000101")

selected_SCells_for_2CC_TT_CA_in_UE_CON_MOD_RESP_template = """
    sCellToAddModList is present and length(sCellToAddModList) eq 1
    and sCellToAddModList contains
    (
        sCellIndex eq 1
        and sCellConfigCommon contains (physCellId eq {scell_physcellid})
    )
        and SelectedBandCombinationIndex eq "{SelectedBandCombinationIndex}"
    """

selected_SCells_for_2CC_TT_DB1a_UE3_CA_in_UE_CON_MOD_RESP = \
    selected_SCells_for_2CC_TT_CA_in_UE_CON_MOD_RESP_template.format(
        scell_physcellid=55, SelectedBandCombinationIndex="0x0000")

PUCCH_config_in_UE_CON_MOD_RESP_template = """
    spCellConfig contains
    (
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
            )
            and resourceToAddModList is present
            {resourceToAddModList_content}
            {resourceToAddModList_length}
        )
    )
    """

PUCCH_config_for_4CC_TTTF_DB1a_CA_in_UE_CON_MOD_RESP = """
    spCellConfig contains
    (
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
                length(resourceList) le 7
            )
            and resourceToAddModList is present
            {resourceToAddModList_length}
        )
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

resourceSet1_FDD_PCell = resourceSet1_template.format(
    set_length=2,
    Resource_List=(10, 11),
    maxPayloadSize=8)

resourceSet1_4CC_TTTF = resourceSet1_template.format(
    set_length=8,
    Resource_List=(10, 11, 12, 13, 14, 15, 16, 17),
    maxPayloadSize=20)

resourceSet1_3CC_TTT = resourceSet1_template.format(
    set_length=8,
    Resource_List=(10, 11, 12, 13, 14, 15, 16, 17),
    maxPayloadSize=16)

resourceSet1_3CC_FFF = resourceSet1_template.format(
    set_length=2,
    Resource_List=(10, 11),
    maxPayloadSize=4)

resourceSet1_4CC_FTTT = resourceSet1_template.format(
    set_length=2,
    Resource_List=(10, 11),
    maxPayloadSize=8)

resourceSet1_4CC_TTFF_DB1a = resourceSet1_template.format(
    set_length=8,
    Resource_List=(10, 11, 12, 13, 14, 15, 16, 17),
    maxPayloadSize=16)

resourceSet1_2CC_TT_DB1a = resourceSet1_template.format(
    set_length=8,
    Resource_List=(10, 11, 12, 13, 14, 15, 16, 17),
    maxPayloadSize=12)

resourceSet1_3CC_FFT_DB2b = resourceSet1_template.format(
    set_length=2,
    Resource_List=(10, 11),
    maxPayloadSize=8)

resourceSet1_4CC_FTTT_DB2b = resourceSet1_4CC_FTTT

resourceToAddModList_template = """
    resourceToAddModList contains {ResourceIdList}
"""

resourceToAddModList_4CC_TFTT = resourceToAddModList_template.format(
    ResourceIdList=(19, 21, 23))

resourceToAddModList_4CC_TTTF = resourceToAddModList_template.format(
    ResourceIdList=(19, 21, 22, 23, 24))

resourceToAddModList_4CC_FTTT = resourceToAddModList_template.format(
    ResourceIdList=(10, 11, 19, 20, 21, 22, 23, 24))

resourceToAddModList_3CC_FTT = resourceToAddModList_template.format(
    ResourceIdList=(10, 11, 19, 20, 21, 22))

resourceToAddModList_3CC_FFF = resourceToAddModList_template.format(
    ResourceIdList=(10, 11, 19, 21))

PUCCH_config_for_3CC_FFF_in_UE_CON_MOD_RESP = fill_PUCCH_config_in_UE_CON_MOD_RESP_template(
    resourceSet1_content=resourceSet1_3CC_FFF,
    resourceToAddModList_content=resourceToAddModList_3CC_FFF,
    resourceToAddModList_length=4)

# CB008053-B-B2
PUCCH_config_for_4CC_FTTT_CA_in_UE_CON_MOD_RESP_SCell_Change = """
    spCellConfig contains
    (
        pucch-Config contains
        (
            resourceSetToAddModList is present
            and length(resourceSetToAddModList) eq 1
            and resourceSetToAddModList contains
            (
                pucch-ResourceSetId eq 1
                and length(resourceList) eq 2
                and resourceList contains (10, 11)
                and maxPayloadSize eq 8
            )
        )
    )
    """

# Used in CB008053-A-B1c
PUCCH_config_for_3CC_TTT_BF_BR_CA_in_UE_CON_MOD_RESP = """
    spCellConfig contains
    (
        pucch-Config contains
        (
            resourceSetToAddModList is present
            and length(resourceSetToAddModList) ge 1
            and resourceSetToAddModList contains
            (
                pucch-ResourceSetId eq 1
                and length(resourceList) eq 8
                and resourceList contains (10, 11, 12, 13, 14, 15, 16, 17)
                and maxPayloadSize eq 16
            )
            and
            (
                resourceToAddModList contains (pucch-ResourceId eq 19)
                and resourceToAddModList contains (pucch-ResourceId eq 20)
                and resourceToAddModList contains (pucch-ResourceId eq 21)
                and resourceToAddModList contains (pucch-ResourceId eq 22)
            )
            and length(resourceToAddModList) eq 4
        )
    )
    """
PUCCH_config_for_3CC_FTT_BF_BR_in_UE_CON_MOD_RESP = fill_PUCCH_config_in_UE_CON_MOD_RESP_template(
    resourceSet1_content=resourceSet1_FDD_PCell,
    resourceToAddModList_content=resourceToAddModList_3CC_FTT,
    resourceToAddModList_length=6)
PUCCH_config_for_4CC_TTTF_CA_BF_BR_in_UE_CON_MOD_RESP = fill_PUCCH_config_in_UE_CON_MOD_RESP_template(
    resourceSet1_content=resourceSet1_4CC_TTTF,
    resourceToAddModList_content=resourceToAddModList_4CC_TTTF,
    resourceToAddModList_length=5)
PUCCH_config_for_4CC_FTTT_CA_BF_BR_in_UE_CON_MOD_RESP = fill_PUCCH_config_in_UE_CON_MOD_RESP_template(
    resourceSet1_content=resourceSet1_FDD_PCell,
    resourceToAddModList_content=resourceToAddModList_4CC_FTTT,
    resourceToAddModList_length=8)
PUCCH_config_for_4CC_TFTT_CA_in_UE_CON_MOD_RESP = fill_PUCCH_config_in_UE_CON_MOD_RESP_template(
    resourceSet1_content=resourceSet1_4CC_TTTF,
    resourceToAddModList_content=resourceToAddModList_4CC_TFTT,
    resourceToAddModList_length=3)

PUCCH_config_for_4CC_TTFF_DB1a_CA_in_UE_CON_MOD_RESP = """
    spCellConfig contains
    (
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
                length(resourceList) le 6
            )
            and resourceToAddModList is present
            {resourceToAddModList_length}
        )
    )
    """

PUCCH_config_for_4CC_TTFF_DB1a_UE2_CA_in_UE_CON_MOD_RESP = fill_PUCCH_config_in_UE_CON_MOD_RESP_template(
    template=PUCCH_config_for_4CC_TTFF_DB1a_CA_in_UE_CON_MOD_RESP,
    resourceSet1_content=resourceSet1_4CC_TTFF_DB1a,
    resourceToAddModList_length=4)

PUCCH_config_for_2CC_TT_DB1a_CA_in_UE_CON_MOD_RESP = """
    spCellConfig contains
    (
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
                length(resourceList) le 4
            )
            and resourceToAddModList is present
            {resourceToAddModList_length}
        )
    )
    """

PUCCH_config_for_3th_SCell_TDD_for_Release_in_TTTF_4CC_CA_in_UE_CON_MOD_RESP = """
    spCellConfig contains
    (
        pucch-Config contains
        (
            resourceSetToAddModList is present
            and resourceSetToAddModList contains
            (
                pucch-ResourceSetId eq 1
                and
                length(resourceList) eq 8
                and
                maxPayloadSize eq 12
            )
            and resourceToReleaseList is present
            and length(resourceToReleaseList) eq 2
            and resourceToReleaseList contains (23, 24)
            and format3 is present
            and format3 contains (maxCodeRate is present and maxCodeRate eq "zeroDot08")
        )
    )
"""

PUCCH_config_for_2nd_SCell_TDD_for_Release_in_TTTF_4CC_CA_in_UE_CON_MOD_RESP = """
    spCellConfig contains
    (
        pucch-Config contains
        (
            resourceSetToAddModList is present
            and resourceSetToAddModList contains
            (
                pucch-ResourceSetId eq 1
                and
                length(resourceList) eq 8
                and
                maxPayloadSize eq 8
            )
            and resourceToReleaseList is present
            and length(resourceToReleaseList) eq 2
            and resourceToReleaseList contains (21, 22)
            and format3 is not present
        )
    )
"""

PUCCH_config_for_1st_SCell_FDD_for_Release_in_TTTF_4CC_CA_in_UE_CON_MOD_RESP = """
    spCellConfig contains
    (
        pucch-Config contains
        (
            resourceToReleaseList is present
            and length(resourceToReleaseList) eq 1
            and resourceToReleaseList contains (19)
            and format3 is not present
        )
    )
"""

PUCCH_config_for_4CC_FTTT_DB2b_CA_in_UE_CON_MOD_RESP = """
    spCellConfig contains
    (
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
                length(resourceList) le 7
            )
            and resourceToAddModList is present
            {resourceToAddModList_length}
        )
    )
    """

PUCCH_config_for_3CC_FFT_DB2b_CA_in_UE_CON_MOD_RESP = """
    spCellConfig contains
    (
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
                length(resourceList) le 4
            )
            and resourceToAddModList is present
            {resourceToAddModList_length}
        )
    )
    """

PUCCH_config_for_4CC_TTTF_DB1a_UE1_CA_in_UE_CON_MOD_RESP = fill_PUCCH_config_in_UE_CON_MOD_RESP_template(
    template=PUCCH_config_for_4CC_TTTF_DB1a_CA_in_UE_CON_MOD_RESP,
    resourceSet1_content=resourceSet1_4CC_TTTF,
    resourceToAddModList_length=5)

PUCCH_config_for_2CC_TT_DB1a_UE3_CA_in_UE_CON_MOD_RESP = fill_PUCCH_config_in_UE_CON_MOD_RESP_template(
    template=PUCCH_config_for_2CC_TT_DB1a_CA_in_UE_CON_MOD_RESP,
    resourceSet1_content=resourceSet1_2CC_TT_DB1a,
    resourceToAddModList_length=2)

PUCCH_config_for_4CC_FTTT_DB2b_UE1_CA_in_UE_CON_MOD_RESP = fill_PUCCH_config_in_UE_CON_MOD_RESP_template(
    template=PUCCH_config_for_4CC_FTTT_DB2b_CA_in_UE_CON_MOD_RESP,
    resourceSet1_content=resourceSet1_4CC_FTTT_DB2b,
    resourceToAddModList_length=8)

PUCCH_config_for_3CC_FFT_DB2b_UE2_CA_in_UE_CON_MOD_RESP = fill_PUCCH_config_in_UE_CON_MOD_RESP_template(
    template=PUCCH_config_for_3CC_FFT_DB2b_CA_in_UE_CON_MOD_RESP,
    resourceSet1_content=resourceSet1_3CC_FFT_DB2b,
    resourceToAddModList_length=5)


CSI_meas_config_in_3CC_FFF_UE_CON_MOD_RESP = """
    spCellConfig contains
    (
        csi-MeasConfig contains
        (
            csi-ReportConfigToAddModList is present and length(csi-ReportConfigToAddModList) eq 2
            and csi-ReportConfigToAddModList contains (reportConfigId eq 13 and carrier eq 1)
            and csi-ReportConfigToAddModList contains (reportConfigId eq 14 and carrier eq 2)
        )
    )
"""

CSI_meas_config_in_4CC_UE_CON_MOD_RESP_template = """
    spCellConfig contains
    (
        csi-MeasConfig contains
        (
            csi-ReportConfigToAddModList is present and length(csi-ReportConfigToAddModList) eq 3
            and csi-ReportConfigToAddModList contains (reportConfigId eq 13 and carrier eq {carrier_1})
            and csi-ReportConfigToAddModList contains (reportConfigId eq 14 and carrier eq {carrier_2})
            and csi-ReportConfigToAddModList contains (reportConfigId eq 15 and carrier eq {carrier_3})
        )
    )
"""

CSI_meas_config_in_4CC_FTTT_UE_CON_MOD_RESP_SCell_Change = CSI_meas_config_in_4CC_UE_CON_MOD_RESP_template.format(
    carrier_1=3,
    carrier_2=4,
    carrier_3=5)

CSI_meas_config_in_4CC_UE_CON_MOD_RESP_PCell_Change = CSI_meas_config_in_4CC_UE_CON_MOD_RESP_template.format(
    carrier_1=1,
    carrier_2=2,
    carrier_3=3)

CSI_meas_config_for_Release_CA_in_UE_CON_MOD_RESP_template = """
    spCellConfig contains
    (
        csi-MeasConfig contains
        (
            csi-ReportConfigToReleaseList is present
            and length(csi-ReportConfigToReleaseList) eq {ReportConfigToReleaseList_length}
            and csi-ReportConfigToReleaseList contains {ReportConfigToReleaseList}
        )
    )
"""
CSI_meas_config_for_3th_SCell_TDD_for_Release_in_TTTF_4CC_CA_in_UE_CON_MOD_RESP = \
    CSI_meas_config_for_Release_CA_in_UE_CON_MOD_RESP_template.format(
        ReportConfigToReleaseList_length=2,
        ReportConfigToReleaseList=(15, 23))

CSI_meas_config_for_2nd_SCell_TDD_for_Release_in_TTTF_4CC_CA_in_UE_CON_MOD_RESP = \
    CSI_meas_config_for_Release_CA_in_UE_CON_MOD_RESP_template.format(
        ReportConfigToReleaseList_length=2,
        ReportConfigToReleaseList=(14, 22))

CSI_meas_config_for_1st_SCell_FDD_for_Release_in_TTTF_4CC_CA_in_UE_CON_MOD_RESP = """
    spCellConfig contains
    (
        csi-MeasConfig contains
        (
            csi-ReportConfigToReleaseList is present
            and length(csi-ReportConfigToReleaseList) eq 1
            and csi-ReportConfigToReleaseList contains (13)
        )
    )
"""

CSI_meas_config_in_UE_CON_MOD_RESP_RELEASE_B5 = CSI_meas_config_for_Release_CA_in_UE_CON_MOD_RESP_template.format(
    ReportConfigToReleaseList_length=4,
    ReportConfigToReleaseList=(0, 13, 14, 15))

# Beamforming
CSI_meas_config_for_4CC_TTTF_CA_BF_BR_in_UE_CON_MOD_RESP = """
    spCellConfig contains
    (
        csi-MeasConfig contains
        (
            csi-ReportConfigToAddModList is present
            and length(csi-ReportConfigToAddModList) eq 5
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
                reportConfigId eq 22
                and carrier eq 2
                and reportQuantity contains (cri-RSRP is present)
            )
            and csi-ReportConfigToAddModList contains
            (
                reportConfigId eq 15
                and carrier eq 3
                and reportQuantity contains (cri-RI-PMI-CQI is present)
            )
            and csi-ReportConfigToAddModList contains
            (
                reportConfigId eq 23
                and carrier eq 3
                and reportQuantity contains (cri-RSRP is present)
            )
        )
    )
"""

CSI_meas_config_for_4CC_FTTT_CA_BF_BR_in_UE_CON_MOD_RESP = """
    spCellConfig contains
    (
        csi-MeasConfig contains
        (
            csi-ReportConfigToAddModList is present
            and length(csi-ReportConfigToAddModList) eq 6
            and csi-ReportConfigToAddModList contains
            (
                reportConfigId eq 13
                and carrier eq 1
                and reportQuantity contains (cri-RI-PMI-CQI is present)
            )
            and csi-ReportConfigToAddModList contains
            (
                reportConfigId eq 21
                and carrier eq 1
                and reportQuantity contains (cri-RSRP is present)
            )
            and csi-ReportConfigToAddModList contains
            (
                reportConfigId eq 14
                and carrier eq 2
                and reportQuantity contains (cri-RI-PMI-CQI is present)
            )
            and csi-ReportConfigToAddModList contains
            (
                reportConfigId eq 22
                and carrier eq 2
                and reportQuantity contains (cri-RSRP is present)
            )
            and csi-ReportConfigToAddModList contains
            (
                reportConfigId eq 15
                and carrier eq 3
                and reportQuantity contains (cri-RI-PMI-CQI is present)
            )
            and csi-ReportConfigToAddModList contains
            (
                reportConfigId eq 23
                and carrier eq 3
                and reportQuantity contains (cri-RSRP is present)
            )
        )
    )
"""

CSI_meas_config_with_beamforming_TTTF_4CC_CA_in_UE_CON_MOD_RESP = """
    spCellConfig contains
    (
        csi-MeasConfig contains
        (
            csi-ReportConfigToAddModList is present and length(csi-ReportConfigToAddModList) eq 5
            and csi-ReportConfigToAddModList contains
            (
                reportConfigId eq 13
                and carrier eq 1
                and pucch-CSI-ResourceList is present
                and pucch-CSI-ResourceList contains (pucch-Resource is present and pucch-Resource eq 19)
            )
            and csi-ReportConfigToAddModList contains
            (
                reportConfigId eq 14
                and carrier eq 2
                and pucch-CSI-ResourceList contains (pucch-Resource is present and pucch-Resource eq 21)
            )
            and csi-ReportConfigToAddModList contains
            (
                reportConfigId eq 22
                and carrier eq 2
                and pucch-CSI-ResourceList contains (pucch-Resource is present and pucch-Resource eq 22)
                and reportQuantity contains (ssb-Index-RSRP is present)
            )
            and csi-ReportConfigToAddModList contains
            (
                reportConfigId eq 15
                and carrier eq 3
                and pucch-CSI-ResourceList contains (pucch-Resource is present and pucch-Resource eq 23)
            )
            and csi-ReportConfigToAddModList contains
            (
                reportConfigId eq 23
                and carrier eq 3
                and pucch-CSI-ResourceList contains (pucch-Resource is present and pucch-Resource eq 24)
                and reportQuantity contains (ssb-Index-RSRP is present)
            )
        )
    )
"""

CSI_meas_config_for_4CC_TTTF_DB1a_UE1_CA_BF_in_UE_CON_MOD_RESP = """
    spCellConfig contains
    (
        csi-MeasConfig contains
        (
            csi-ReportConfigToAddModList is present
            and length(csi-ReportConfigToAddModList) eq 5
            and csi-ReportConfigToAddModList contains
            (
                reportConfigId eq 13
                and carrier eq 1
            )
            and csi-ReportConfigToAddModList contains
            (
                reportConfigId eq 14
                and carrier eq 2
            )
            and csi-ReportConfigToAddModList contains
            (
                reportConfigId eq 22
                and carrier eq 2
            )
            and csi-ReportConfigToAddModList contains
            (
                reportConfigId eq 15
                and carrier eq 3
            )
            and csi-ReportConfigToAddModList contains
            (
                reportConfigId eq 23
                and carrier eq 3
            )
        )
    )
"""

CSI_meas_config_for_4CC_TTFF_DB1a_UE2_CA_BF_in_UE_CON_MOD_RESP = """
    spCellConfig contains
    (
        csi-MeasConfig contains
        (
            csi-ReportConfigToAddModList is present
            and length(csi-ReportConfigToAddModList) eq 4
            and csi-ReportConfigToAddModList contains
            (
                reportConfigId eq 13
                and carrier eq 1
            )
            and csi-ReportConfigToAddModList contains
            (
                reportConfigId eq 14
                and carrier eq 2
            )
            and csi-ReportConfigToAddModList contains
            (
                reportConfigId eq 15
                and carrier eq 3
            )
            and csi-ReportConfigToAddModList contains
            (
                reportConfigId eq 23
                and carrier eq 3
            )
        )
    )
"""

CSI_meas_config_for_2CC_TT_DB1a_UE3_CA_BF_in_UE_CON_MOD_RESP = """
    spCellConfig contains
    (
        csi-MeasConfig contains
        (
            csi-ReportConfigToAddModList is present
            and length(csi-ReportConfigToAddModList) eq 2
            and csi-ReportConfigToAddModList contains
            (
                reportConfigId eq 13
                and carrier eq 1
            )
            and csi-ReportConfigToAddModList contains
            (
                reportConfigId eq 21
                and carrier eq 1
            )
        )
    )
"""

CSI_meas_config_for_4CC_FTTT_DB2b_UE1_CA_BF_in_UE_CON_MOD_RESP = """
    spCellConfig contains
    (
        csi-MeasConfig contains
        (
            csi-ReportConfigToAddModList is present
            and length(csi-ReportConfigToAddModList) eq 6
            and csi-ReportConfigToAddModList contains
            (
                reportConfigId eq 13
                and carrier eq 1
            )
            and csi-ReportConfigToAddModList contains
            (
                reportConfigId eq 21
                and carrier eq 1
            )
            and csi-ReportConfigToAddModList contains
            (
                reportConfigId eq 14
                and carrier eq 2
            )
            and csi-ReportConfigToAddModList contains
            (
                reportConfigId eq 22
                and carrier eq 2
            )
            and csi-ReportConfigToAddModList contains
            (
                reportConfigId eq 15
                and carrier eq 3
            )
            and csi-ReportConfigToAddModList contains
            (
                reportConfigId eq 23
                and carrier eq 3
            )
        )
    )
"""

CSI_meas_config_for_3CC_FFT_DB2b_UE2_CA_BF_in_UE_CON_MOD_RESP = """
    spCellConfig contains
    (
        csi-MeasConfig contains
        (
            csi-ReportConfigToAddModList is present
            and length(csi-ReportConfigToAddModList) eq 3
            and csi-ReportConfigToAddModList contains
            (
                reportConfigId eq 13
                and carrier eq 1
            )
            and csi-ReportConfigToAddModList contains
            (
                reportConfigId eq 14
                and carrier eq 2
            )
            and csi-ReportConfigToAddModList contains
            (
                reportConfigId eq 22
                and carrier eq 2
            )
        )
    )
"""

measurements_config_for_FFF_3CC_CA_in_RRC_Reconfiguration = """
    measConfig contains
    (
        measIdToRemoveList is present
        and length(measIdToRemoveList) eq 1
        and measIdToRemoveList contains (1)
        and reportConfigToAddModList contains
        (
            reportConfigId eq 2
            and
            eventId contains (eventA2 is present)
            and
            a2-Threshold contains (rsrq eq 49)
        )
        and
        reportConfigToAddModList contains
        (
            reportConfigId eq 3
            and
            eventId contains (eventA1 is present)
            and
            a1-Threshold contains (rsrp eq 80)
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
            freqBandIndicatorNR eq 71
        )
        and
        measIdToAddModList contains
        (
            measId eq 2
            and
            measObjectId eq 2
            and
            reportConfigId eq 2
        )
        and
        measIdToAddModList contains
        (
            measId eq 3
            and
            measObjectId eq 3
            and
            reportConfigId eq 2
        )
        and
        measIdToAddModList contains
        (
            measId eq 4
            and
            measObjectId eq 1
            and
            reportConfigId eq 3
        )
    )
    """

measurements_config_for_FTTT_4CC_CA_in_RRC_Reconfiguration = """
    measConfig contains
    (
        measIdToRemoveList is present
        and length(measIdToRemoveList) eq 3
        and measIdToRemoveList contains (4, 2, 3)
        and reportConfigToRemoveList contains (3)
        and length(reportConfigToRemoveList) eq 1
        and measObjectToRemoveList contains (2, 3)
        and
        measObjectToAddModList contains
        (
            measObjectId eq 4
            and
            freqBandIndicatorNR eq 41
        )
        and
        measObjectToAddModList contains
        (
            measObjectId eq 5
            and
            freqBandIndicatorNR eq 41
        )
        and
        measObjectToAddModList contains
        (
            measObjectId eq 6
            and
            freqBandIndicatorNR eq 77
        )
        and
        measIdToAddModList contains
        (
            measId eq 5
            and
            measObjectId eq 4
            and
            reportConfigId eq 2
        )
        and
        measIdToAddModList contains
        (
            measId eq 6
            and
            measObjectId eq 5
            and
            reportConfigId eq 2
        )
        and
        measIdToAddModList contains
        (
            measId eq 7
            and
            measObjectId eq 6
            and
            reportConfigId eq 2
        )
    )
    """

measurements_config_for_3th_TDD_SCell_Release_in_TTTF_4CC_CA_in_RRCReconfiguration = """
    rrcReconfiguration contains
    (
        measConfig contains
        (
            length(measObjectToRemoveList) eq 1
            and length(measObjectToAddModList) eq 1
            and length(measIdToRemoveList) eq 1
            and measIdToRemoveList contains (4)
        )
    )
"""

measurements_config_for_2nd_TDD_SCell_Release_in_TTTF_4CC_CA_in_RRCReconfiguration = """
    rrcReconfiguration contains
    (
        measConfig contains
        (
            length(measObjectToRemoveList) eq 1
            and length(measIdToRemoveList) eq 1
            and measIdToRemoveList contains (3)
        )
    )
"""

measurements_config_for_1st_FDD_SCell_Release_in_TTTF_4CC_CA_in_RRCReconfiguration = """
    rrcReconfiguration contains
    (
        measConfig contains
        (
            length(measObjectToRemoveList) eq 1
            and length(measIdToRemoveList) eq 1
            and measIdToRemoveList contains (2)
            and measIdToAddModList is present
            and measIdToAddModList contains
            (
                measId eq 5
                and measObjectId eq 1
                and reportConfigId eq 3
            )
        )
    )
"""

maxCodeRate_and_maxPayloadSize_config_TTTF_4CC_CA_in_UE_CON_MOD_RESP = """
    spCellConfig contains
    (
        pucch-Config contains
        (
            resourceSetToAddModList is present
            and resourceSetToAddModList contains
            (
                pucch-ResourceSetId eq 1
                and
                length(resourceList) eq 8
                and
                maxPayloadSize eq 20
            )
            and format3 is present
            and format3 contains (maxCodeRate is present and maxCodeRate eq "zeroDot15")
        )
    )
"""

A2_measurements_config_for_SCells_release_TTTF_4CC_CA_in_RRCReconfiguration = """
    rrcReconfiguration contains
    (
        measConfig contains
        (
            length(measObjectToAddModList) eq 3
            and length(reportConfigToRemoveList) eq 1
            and length(reportConfigToAddModList) eq 1
            and length(measIdToRemoveList) eq 1
            and length(measIdToAddModList) eq 3
            and measIdToAddModList contains
            (
                measId eq 2
                and measObjectId eq 2
                and reportConfigId eq 2
            )
            and measIdToAddModList contains
            (
                measId eq 3
                and measObjectId eq 3
                and reportConfigId eq 2
            )
            and measIdToAddModList contains
            (
                measId eq 4
                and measObjectId eq 4
                and reportConfigId eq 2
            )
        )
    )
"""

meas_config_in_RRC_Reconf_TFTT_B5 = """
    measConfig contains
    (
        measObjectToAddModList contains
        (
            measObjectId eq 2
            and
            freqBandIndicatorNR eq 71
        )
        and measObjectToAddModList contains
        (
            measObjectId eq 3
            and
            freqBandIndicatorNR eq 41
        )
        and measObjectToAddModList contains
        (
            measObjectId eq 4
            and
            freqBandIndicatorNR eq 77
        )
        and reportConfigToAddModList contains
        (
            reportConfigId eq 3
            and
            eventId contains (eventA2 is present)
            and
            a2-Threshold contains (rsrp eq 34)
        )
        and reportConfigToAddModList contains
        (
            reportConfigId eq 4
            and
            eventId contains (eventA2 is present)
            and
            a2-Threshold contains (rsrp eq 10)
        )
        and measIdToAddModList contains
        (
            measId eq 3
            and
            measObjectId eq 2
            and
            reportConfigId eq 3
        )
        and measIdToAddModList contains
        (
            measId eq 4
            and
            measObjectId eq 3
            and
            reportConfigId eq 3
        )
        and measIdToAddModList contains
        (
            measId eq 5
            and
            measObjectId eq 4
            and
            reportConfigId eq 3
        )
        and measIdToAddModList contains
        (
            measId eq 6
            and
            measObjectId eq 1
            and
            reportConfigId eq 4
        )
        and measIdToRemoveList is present
        and length(measIdToRemoveList) eq 1
        and measIdToRemoveList contains (2)
        and reportConfigToRemoveList contains (2)
    )
    """

A1_measurements_configuration_in_RRCReconfiguration_B5 = """
    measConfig contains
    (
        measObjectToAddModList contains
        (
            measObjectId eq 1
            and
            freqBandIndicatorNR eq 41
        )
        and reportConfigToAddModList contains
        (
            reportConfigId eq 1
            and
            eventId contains (eventA2 is present)
            and
            a2-Threshold contains (rsrp eq 33)
        )
        and reportConfigToAddModList contains
        (
            reportConfigId eq 2
            and
            eventId contains (eventA1 is present)
            and
            a1-Threshold contains (rsrp eq 80)
        )
        and measIdToAddModList contains
        (
            measId eq 1
            and measObjectId eq 1
            and reportConfigId eq 1
        )
        and measIdToAddModList contains
        (
            measId eq 2
            and measObjectId eq 1
            and reportConfigId eq 2
        )
    )
    """

meas_config_in_RRC_Reconf_FTTT_B5 = """
    measConfig contains
    (
        measObjectToRemoveList contains (1,3,4)
        and measObjectToAddModList contains
        (
            measObjectId eq 2
            and
            freqBandIndicatorNR eq 71
        )
        and reportConfigToAddModList contains
        (
            reportConfigId eq 5
            and
            eventId contains (eventA1 is present)
            and
            a1-Threshold contains (rsrp eq 80)
        )
        and reportConfigToRemoveList contains (1,3,4)
        and measIdToRemoveList contains (3,4,5,6,1)
        and measIdToAddModList contains
        (
            measId eq 7
            and
            measObjectId eq 2
            and
            reportConfigId eq 5
        )
    )
    """

HO_PREP_in_UE_CON_MOD_REQ = """
    (rrcReconfiguration contains
        (measConfig contains
            (CellGroupConfig contains
                (spCellConfig contains
                    (reconfigurationWithSync contains
                        (speCellConfigCommon contains
                            (physCellId eq 54)
                        )
                    )
                )
            )
        )
    )
    """

HO_PREP_in_UE_CON_MOD_REQ_B5 = """
    spCellConfig contains
    (reconfigurationWithSync contains
        (spCellConfigCommon contains
            (physCellId eq 54)
        )
    )
    """

# DB1a
A1_measurement_configuration_template = """
     measConfig contains
    (
        measObjectToAddModList contains
        (
            measObject contains
            (
                ssbFrequency eq {ssbFrequency}
                and freqBandIndicatorNR eq {freqBandIndicatorNR}
            )
        )
        and reportConfigToAddModList contains
            (
                reportConfigId eq 1
                and reportConfig contains
                (
                    reportConfigNR contains
                    (
                        reportType contains
                        (
                            eventTriggered contains
                            (
                                eventId contains
                                (
                                    eventA1 contains
                                    (
                                        a1-Threshold contains
                                        (
                                            rsrp is present
                                            and rsrp eq {rsrp_threshold}
                                        )
                                        and hysteresis eq {hysteresis}
                                        and timeToTrigger contains ("{timeToTrigger}")
                                    )
                                )
                            )
                        )
                    )
                )
            )
        and measIdToAddModList contains
            (
                measId eq 1
                and measObjectId eq 1
                and reportConfigId eq 1
            )
    )
"""

A1_measurement_configuration_for_PCell_TDD_DB1a = \
    A1_measurement_configuration_template.format(
        ssbFrequency=501150,
        freqBandIndicatorNR=41,
        rsrp_threshold=80,
        hysteresis=0,
        timeToTrigger="ms320")

A1_measurement_configuration_for_PCell_FDD_Db2b = \
    A1_measurement_configuration_template.format(
        ssbFrequency=392410,
        freqBandIndicatorNR=25,
        rsrp_threshold=80,
        hysteresis=0,
        timeToTrigger="ms320")

PDU_Session_ID_check_template = """
     radioBearerConfig contains
    (
        drb-ToAddModList contains
        (
            cnAssociation contains
            (
                sdap-Config contains
                (
                    pdu-Session eq {pdu_Session}
                )
            )
        )
    )
"""

PDU_Session_ID_check_for_PCell_TDD_DB1a = \
    PDU_Session_ID_check_template.format(
        pdu_Session=4)

PDU_Session_ID_check_for_PCell_FDD_DB2b = \
    PDU_Session_ID_check_template.format(
        pdu_Session=1)

measurementReport_in_UL_DCCH_Message_template = """
    UL-DCCH-Message contains
    (
        measurementReport contains
        (
            criticalExtensions contains
            (
                measResults contains
                (
                measId eq 1
                and measResultServingMOList contains
                (
                    measResultServingCell contains
                    (
                        physCellId eq {physCellId}
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
        )
    )
"""

measurementReport_in_UL_DCCH_Message_for_PCell_TDD_DB1a = \
    measurementReport_in_UL_DCCH_Message_template.format(
        physCellId=54,
        rsrp_threshold=90)

measurementReport_in_UL_DCCH_Message_for_PCell_FDD_DB2b = \
    measurementReport_in_UL_DCCH_Message_template.format(
        physCellId=51,
        rsrp_threshold=90)

A1_measurement_report_removal_DB1a_PCell_TDD = """
     measConfig contains
    (
        reportConfigToRemoveList contains (1)
        and measIdToRemoveList contains (1)
    )
"""
