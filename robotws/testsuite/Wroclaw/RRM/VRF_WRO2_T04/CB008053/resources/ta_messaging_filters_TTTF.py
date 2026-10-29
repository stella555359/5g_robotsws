"""
:copyright: Nokia Networks
:authors:
    Michał Obszarny <michal.obszarny@nokia.com>
:maintainers:
    Michał Obszarny <michal.obszarny@nokia.com>
"""
selected_SCells_for_TTTF_4CC_CA_in_UE_CON_MOD_REQ = \
    """
    SCell-ToBeSetupMod-List is present and length(SCell-ToBeSetupMod-List) eq 3
    and
    SCell-ToBeSetupMod-List contains (sCellIndex eq 1)
    and
    SCell-ToBeSetupMod-List contains (sCellIndex eq 2)
    and
    SCell-ToBeSetupMod-List contains (sCellIndex eq 3)
    and
    not SCell-ToBeSetupMod-List contains (sCellIndex eq 4)
    """

selected_SCells_for_TTTF_3CC_CA_in_UE_CON_MOD_REQ = \
    """
    SCell-ToBeSetupMod-List is present and length(SCell-ToBeSetupMod-List) eq 2
    and
    SCell-ToBeSetupMod-List contains (sCellIndex eq 1)
    and
    SCell-ToBeSetupMod-List contains (sCellIndex eq 2)
    and
    not SCell-ToBeSetupMod-List contains (sCellIndex eq 3)
    """

added_SCells_for_TTTF_4CC_CA_in_UE_CON_MOD_RESP = \
    """
    sCellToAddModList is present and length(sCellToAddModList) eq 3
    and
    sCellToAddModList contains
    (
        sCellIndex eq 1 and sCellConfigCommon contains (physCellId eq 53)
    )
    and
    sCellToAddModList contains
    (
        sCellIndex eq 2 and sCellConfigCommon contains (physCellId eq 55)
    )
    and
    sCellToAddModList contains
    (
        sCellIndex eq 3 and sCellConfigCommon contains (physCellId eq 56)
    )
    and
    (not sCellToAddModList contains (sCellIndex eq 4))
    """

resourceSetToAddModList_for_BF_enabled_for_TTTF_4CC_CA_in_UE_CON_MOD_RESP = \
    """
    spCellConfig contains
    (
        pucch-Config contains
        (
            resourceSetToAddModList contains
            (
                pucch-ResourceSetId eq 1
                and
                length(resourceList) eq 8
                and
                resourceList contains (10, 11, 12, 13, 14, 15, 16, 17)
                and
                maxPayloadSize eq 20
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
        )
    )
    """

CSIReportConfigToAddModList_for_BF_enabled_for_TTTF_4CC_CA_in_UE_CON_MOD_RESP = \
    """
    csi-ReportConfigToAddModList is present and length(csi-ReportConfigToAddModList) eq 7
    and
    csi-ReportConfigToAddModList contains
    (
        reportConfigId eq 0
        and
        carrier is not present
        and
        pucch-CSI-ResourceList contains ((uplinkBandwidthPartId eq 1) and (pucch-Resource eq 9))
        and
        reportQuantity contains (cri-RI-PMI-CQI is present)
    )
    and
    csi-ReportConfigToAddModList contains
    (
        reportConfigId eq 2
        and
        carrier is not present
        and
        pucch-CSI-ResourceList contains ((uplinkBandwidthPartId eq 1) and (pucch-Resource eq 18))
        and
        reportQuantity contains (ssb-Index-RSRP is present)
    )
    and
    csi-ReportConfigToAddModList contains
    (
        reportConfigId eq 13
        and
        carrier eq 1
        and
        pucch-CSI-ResourceList contains ((uplinkBandwidthPartId eq 1) and (pucch-Resource eq 19))
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
        pucch-CSI-ResourceList contains ((uplinkBandwidthPartId eq 1) and (pucch-Resource eq 21))
        and
        reportQuantity contains (cri-RI-PMI-CQI is present)
    )
    and
    csi-ReportConfigToAddModList contains
    (
        reportConfigId eq 22
        and
        carrier eq 2
        and
        pucch-CSI-ResourceList contains ((uplinkBandwidthPartId eq 1) and (pucch-Resource eq 22))
        and
        reportQuantity contains (ssb-Index-RSRP is present)
    )
    and
    csi-ReportConfigToAddModList contains
    (
        reportConfigId eq 15
        and
        carrier eq 3
        and
        pucch-CSI-ResourceList contains ((uplinkBandwidthPartId eq 1) and (pucch-Resource eq 23))
        and
        reportQuantity contains (cri-RI-PMI-CQI is present)
    )
    and
    csi-ReportConfigToAddModList contains
    (
        reportConfigId eq 23
        and
        carrier eq 3
        and
        pucch-CSI-ResourceList contains ((uplinkBandwidthPartId eq 1) and (pucch-Resource eq 24))
        and
        reportQuantity contains (ssb-Index-RSRP is present)
    )
    """

CSIReportConfigToAddModList_for_BF_enabled_with_CSI_BM_bundling_for_TTTF_4CC_CA_in_UE_CON_MOD_RESP = \
    """
    csi-ReportConfigToAddModList is present and length(csi-ReportConfigToAddModList) eq 7
    and
    csi-ReportConfigToAddModList contains
    (
        reportConfigId eq 0
        and
        carrier is not present
        and
        pucch-CSI-ResourceList contains ((uplinkBandwidthPartId eq 1) and (pucch-Resource eq 9))
        and
        reportQuantity contains (cri-RI-PMI-CQI is present)
    )
    and
    csi-ReportConfigToAddModList contains
    (
        reportConfigId eq 2
        and
        carrier is not present
        and
        pucch-CSI-ResourceList contains ((uplinkBandwidthPartId eq 1) and (pucch-Resource eq 9))
        and
        reportQuantity contains (ssb-Index-RSRP is present)
    )
    and
    csi-ReportConfigToAddModList contains
    (
        reportConfigId eq 13
        and
        carrier eq 1
        and
        pucch-CSI-ResourceList contains ((uplinkBandwidthPartId eq 1) and (pucch-Resource eq 19))
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
        pucch-CSI-ResourceList contains ((uplinkBandwidthPartId eq 1) and (pucch-Resource eq 21))
        and
        reportQuantity contains (cri-RI-PMI-CQI is present)
    )
    and
    csi-ReportConfigToAddModList contains
    (
        reportConfigId eq 22
        and
        carrier eq 2
        and
        pucch-CSI-ResourceList contains ((uplinkBandwidthPartId eq 1) and (pucch-Resource eq 21))
        and
        reportQuantity contains (ssb-Index-RSRP is present)
    )
    and
    csi-ReportConfigToAddModList contains
    (
        reportConfigId eq 15
        and
        carrier eq 3
        and
        pucch-CSI-ResourceList contains ((uplinkBandwidthPartId eq 1) and (pucch-Resource eq 23))
        and
        reportQuantity contains (cri-RI-PMI-CQI is present)
    )
    and
    csi-ReportConfigToAddModList contains
    (
        reportConfigId eq 23
        and
        carrier eq 3
        and
        pucch-CSI-ResourceList contains ((uplinkBandwidthPartId eq 1) and (pucch-Resource eq 23))
        and
        reportQuantity contains (ssb-Index-RSRP is present)
    )
    """

CSIRS_configuration_for_each_SCell = \
    """
    sCellToAddModList contains
    (
        sCellIndex eq 1
        and nzp-CSI-RS-ResourceToAddModList is present
        and nzp-CSI-RS-ResourceSetToAddModList contains
        (
            nzp-CSI-ResourceSetId eq 0
            and
            nzp-CSI-RS-Resources contains (0)
        )
        and nzp-CSI-RS-ResourceSetToAddModList contains
        (
            nzp-CSI-ResourceSetId eq 3
            and
            nzp-CSI-RS-Resources contains (2,3,4,5)
            and length(nzp-CSI-RS-Resources) eq 4
        )
        and csi-IM-ResourceToAddModList is present
        and csi-IM-ResourceSetToAddModList is present
        and csi-ResourceConfigToAddModList is present
    )
    and
    sCellToAddModList contains
    (
        sCellIndex eq 2
        and nzp-CSI-RS-ResourceToAddModList is present
        and nzp-CSI-RS-ResourceSetToAddModList contains
        (
            nzp-CSI-ResourceSetId eq 0
            and
            nzp-CSI-RS-Resources contains (0)
            and
            length(nzp-CSI-RS-Resources) eq 1
        )
        and nzp-CSI-RS-ResourceSetToAddModList contains
        (
            nzp-CSI-ResourceSetId eq 3
            and
            nzp-CSI-RS-Resources contains (2,3,4,5)
            and
            length(nzp-CSI-RS-Resources) eq 4
        )
        and nzp-CSI-RS-ResourceSetToAddModList contains
        (
            nzp-CSI-ResourceSetId eq 4
            and
            nzp-CSI-RS-Resources contains (6,7,8,9)
            and
            length(nzp-CSI-RS-Resources) eq 4
        )
        and csi-IM-ResourceToAddModList is present
        and csi-IM-ResourceSetToAddModList is present
        and csi-ResourceConfigToAddModList is present
    )
    and
    sCellToAddModList contains
    (
        sCellIndex eq 3
        and nzp-CSI-RS-ResourceToAddModList is present
        and nzp-CSI-RS-ResourceSetToAddModList contains
        (
            nzp-CSI-ResourceSetId eq 0
            and
            nzp-CSI-RS-Resources contains (0)
        )
        and nzp-CSI-RS-ResourceSetToAddModList contains
        (
            nzp-CSI-ResourceSetId eq 3
            and
            nzp-CSI-RS-Resources contains (2,3,4,5)
            and
            length(nzp-CSI-RS-Resources) eq 4
        )
        and nzp-CSI-RS-ResourceSetToAddModList contains
        (
            nzp-CSI-ResourceSetId eq 4
            and
            nzp-CSI-RS-Resources contains (6,7,8,9)
            and
            length(nzp-CSI-RS-Resources) eq 4
        )
        and csi-IM-ResourceToAddModList is present
        and csi-IM-ResourceSetToAddModList is present
        and csi-ResourceConfigToAddModList is present
    )
    """

UE_NR_Capability_contains_simultaneousCSI_ReportsPerCC_4_and_simultaneousCSI_ReportsAllCC_20 = \
    """
    (
        phy-Parameters contains
            (
            csi-ReportFramework contains
                (
                simultaneousCSI-ReportsPerCC eq 4
                )
            )
        and
        supportedBandListNR contains
            (
            bandNR eq 25, csi-ReportFramework contains
                (
                simultaneousCSI-ReportsPerCC eq 4
                )
            )
        and
        supportedBandListNR contains
            (
            bandNR eq 66, csi-ReportFramework contains
                (
                simultaneousCSI-ReportsPerCC eq 4
                )
            )
        and
        supportedBandListNR contains
            (
            bandNR eq 71, csi-ReportFramework contains
                (
                simultaneousCSI-ReportsPerCC eq 4
                )
            )
        and
        supportedBandListNR contains
            (
            bandNR eq 41, csi-ReportFramework contains
                (
                simultaneousCSI-ReportsPerCC eq 4
                )
            )
        and
        supportedBandListNR contains
            (
            bandNR eq 77, csi-ReportFramework contains
                (
                simultaneousCSI-ReportsPerCC eq 4
                )
            )
        and
        supportedBandCombinationList-v1540 contains
            (
            ca-ParametersNR-v1540 contains
                    (
                    simultaneousCSI-ReportsAllCC eq 20
                    ),
            ca-ParametersNR-v1540 contains
                    (
                    simultaneousCSI-ReportsAllCC eq 20
                    ),
            ca-ParametersNR-v1540 contains
                    (
                    simultaneousCSI-ReportsAllCC eq 20
                    ),
            ca-ParametersNR-v1540 contains
                    (
                    simultaneousCSI-ReportsAllCC eq 20
                    ),
            ca-ParametersNR-v1540 contains
                    (
                    simultaneousCSI-ReportsAllCC eq 20
                    ),
            ca-ParametersNR-v1540 contains
                    (
                    simultaneousCSI-ReportsAllCC eq 20
                    ),
            ca-ParametersNR-v1540 contains
                    (
                    simultaneousCSI-ReportsAllCC eq 20
                    )
            )
    )
    """

UE_NR_Capability_contains_simultaneousCSI_ReportsPerCC_4_and_simultaneousCSI_ReportsAllCC_12 = \
    """
    (
        phy-Parameters contains
            (
            csi-ReportFramework contains
                (
                simultaneousCSI-ReportsPerCC eq 4
                )
            )
        and
        supportedBandListNR contains
            (
            bandNR eq 25, csi-ReportFramework contains
                (
                simultaneousCSI-ReportsPerCC eq 4
                )
            )
        and
        supportedBandListNR contains
            (
            bandNR eq 66, csi-ReportFramework contains
                (
                simultaneousCSI-ReportsPerCC eq 4
                )
            )
        and
        supportedBandListNR contains
            (
            bandNR eq 71, csi-ReportFramework contains
                (
                simultaneousCSI-ReportsPerCC eq 4
                )
            )
        and
        supportedBandListNR contains
            (
            bandNR eq 41, csi-ReportFramework contains
                (
                simultaneousCSI-ReportsPerCC eq 4
                )
            )
        and
        supportedBandListNR contains
            (
            bandNR eq 77, csi-ReportFramework contains
                (
                simultaneousCSI-ReportsPerCC eq 4
                )
            )
        and
        supportedBandCombinationList-v1540 contains
            (
            ca-ParametersNR-v1540 contains
                    (
                    simultaneousCSI-ReportsAllCC eq 12
                    ),
            ca-ParametersNR-v1540 contains
                    (
                    simultaneousCSI-ReportsAllCC eq 12
                    ),
            ca-ParametersNR-v1540 contains
                    (
                    simultaneousCSI-ReportsAllCC eq 12
                    ),
            ca-ParametersNR-v1540 contains
                    (
                    simultaneousCSI-ReportsAllCC eq 12
                    ),
            ca-ParametersNR-v1540 contains
                    (
                    simultaneousCSI-ReportsAllCC eq 12
                    ),
            ca-ParametersNR-v1540 contains
                    (
                    simultaneousCSI-ReportsAllCC eq 12
                    ),
            ca-ParametersNR-v1540 contains
                    (
                    simultaneousCSI-ReportsAllCC eq 12
                    )
            )
    )
    """

added_SCells_for_TF_4CC_CA_in_UE_CON_MOD_RESP = \
    """
    sCellToAddModList is present and length(sCellToAddModList) eq 1
    and
    sCellToAddModList contains
    (
        sCellIndex eq 3 and sCellConfigCommon contains (physCellId eq 56)
    )
    and
    (not sCellToAddModList contains (sCellIndex eq 4))
    """

resourceSetToAddModList_for_BF_enabled_for_TF_4CC_CA_in_UE_CON_MOD_RESP = \
    """
    spCellConfig contains
    (
        pucch-Config contains
        (
            resourceSetToAddModList contains
            (
                pucch-ResourceSetId eq 1
                and
                length(resourceList) eq 8
                and
                resourceList contains (10, 11, 12, 13, 14, 15, 16, 17)
                and
                maxPayloadSize eq 12
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
        )
    )
    """

CSIReportConfigToAddModList_for_BF_enabled_for_TF_4CC_CA_in_UE_CON_MOD_RESP = \
    """
    csi-ReportConfigToAddModList is present and length(csi-ReportConfigToAddModList) eq 4
    and
    csi-ReportConfigToAddModList contains
    (
        reportConfigId eq 0
        and
        carrier is not present
        and
        pucch-CSI-ResourceList contains ((uplinkBandwidthPartId eq 1) and (pucch-Resource eq 9))
        and
        reportQuantity contains (cri-RI-PMI-CQI is present)
    )
    and
    csi-ReportConfigToAddModList contains
    (
        reportConfigId eq 2
        and
        carrier is not present
        and
        pucch-CSI-ResourceList contains ((uplinkBandwidthPartId eq 1) and (pucch-Resource eq 18))
        and
        reportQuantity contains (ssb-Index-RSRP is present)
    )
    and
    csi-ReportConfigToAddModList contains
    (
        reportConfigId eq 13
        and
        carrier eq 3
        and
        pucch-CSI-ResourceList contains ((uplinkBandwidthPartId eq 1) and (pucch-Resource eq 19))
        and
        reportQuantity contains (cri-RI-PMI-CQI is present)
    )
    and
    csi-ReportConfigToAddModList contains
    (
        reportConfigId eq 21
        and
        carrier eq 3
        and
        pucch-CSI-ResourceList contains ((uplinkBandwidthPartId eq 1) and (pucch-Resource eq 20))
        and
        reportQuantity contains (ssb-Index-RSRP is present)
    )
    """

# Scell change #
selected_SCells_for_TFFF_4CC_CA_SCells_addition_in_UE_CON_MOD_REQ = \
    """
    SCell-ToBeSetupMod-List is present and length(SCell-ToBeSetupMod-List) eq 3
    and
    SCell-ToBeSetupMod-List contains (sCellIndex eq 1)
    and
    SCell-ToBeSetupMod-List contains (sCellIndex eq 2)
    and
    SCell-ToBeSetupMod-List contains (sCellIndex eq 3)
    and
    not SCell-ToBeSetupMod-List contains (sCellIndex eq 4)
    """

selected_SCells_for_TTT_3CC_CA_SCells_addition_in_UE_CON_MOD_REQ = \
    """
    SCell-ToBeSetupMod-List is present and length(SCell-ToBeSetupMod-List) eq 2
    and
    SCell-ToBeSetupMod-List contains (sCellIndex eq 1)
    and
    SCell-ToBeSetupMod-List contains (sCellIndex eq 2)
    and
    not SCell-ToBeSetupMod-List contains (sCellIndex eq 3)
    """

added_SCells_for_TFFF_4CC_CA_SCells_addition_in_UE_CON_MOD_RESP = \
    """
    sCellToAddModList is present and length(sCellToAddModList) eq 3
    and
    sCellToAddModList contains
    (
        sCellIndex eq 1 and sCellConfigCommon contains (physCellId eq 51)
    )
    and
    sCellToAddModList contains
    (
        sCellIndex eq 2 and sCellConfigCommon contains (physCellId eq 52)
    )
    and
    sCellToAddModList contains
    (
        sCellIndex eq 3 and sCellConfigCommon contains (physCellId eq 53)
    )
    and
    (not sCellToAddModList contains (sCellIndex eq 4))
    """

added_SCell_for_TF_2CC_CA_SCells_addition_in_UE_CON_MOD_RESP = \
    """
    sCellToAddModList is present and length(sCellToAddModList) eq 1
    and
    sCellToAddModList contains
    (
        sCellIndex eq 3 and sCellConfigCommon contains (physCellId eq 53)
    )
    and
    (not sCellToAddModList contains (sCellIndex eq 2))
    """

added_SCell_for_TT_2CC_CA_SCells_addition_in_UE_CON_MOD_RESP = \
    """
    sCellToAddModList is present and length(sCellToAddModList) eq 1
    and
    sCellToAddModList contains
    (
        sCellIndex eq 2 and sCellConfigCommon contains (physCellId eq 56)
    )
    and
    (not sCellToAddModList contains (sCellIndex eq 3))
    """

added_SCells_for_TTT_3CC_CA_SCells_addition_in_UE_CON_MOD_RESP = \
    """
    sCellToAddModList is present and length(sCellToAddModList) eq 2
    and
    sCellToAddModList contains
    (
        sCellIndex eq 1 and sCellConfigCommon contains (physCellId eq 55)
    )
    and
    sCellToAddModList contains
    (
        sCellIndex eq 2 and sCellConfigCommon contains (physCellId eq 56)
    )
    and
    (not sCellToAddModList contains (sCellIndex eq 3))
    """

selected_SCells_for_SCells_change_from_TFFF_to_TTT_CA_in_UE_CON_MOD_REQ = \
    """
    SCell-ToBeSetupMod-List is present and length(SCell-ToBeSetupMod-List) eq 2
    and
    SCell-ToBeSetupMod-List contains (sCellIndex eq 4)
    and
    SCell-ToBeSetupMod-List contains (sCellIndex eq 5)
    and
    not SCell-ToBeSetupMod-List contains (sCellIndex eq 6)
    """

selected_SCells_for_SCells_change_from_TTT_to_TFFF_CA_in_UE_CON_MOD_REQ = \
    """
    SCell-ToBeSetupMod-List is present and length(SCell-ToBeSetupMod-List) eq 3
    and
    SCell-ToBeSetupMod-List contains (sCellIndex eq 3)
    and
    SCell-ToBeSetupMod-List contains (sCellIndex eq 4)
    and
    SCell-ToBeSetupMod-List contains (sCellIndex eq 5)
    and
    not SCell-ToBeSetupMod-List contains (sCellIndex eq 6)
    """

added_SCells_in_SCells_change_from_TFFF_to_TTT_CA_in_UE_CON_MOD_RESP = \
    """
    sCellToAddModList is present and length(sCellToAddModList) eq 2
    and
    sCellToAddModList contains
    (
        sCellIndex eq 4 and sCellConfigCommon contains (physCellId eq 55)
    )
    and
    sCellToAddModList contains
    (
        sCellIndex eq 5 and sCellConfigCommon contains (physCellId eq 56)
    )
    and
    (not sCellToAddModList contains (sCellIndex eq 6))
    """

added_SCells_in_SCells_change_from_TTT_to_TFFF_CA_in_UE_CON_MOD_RESP = \
    """
    sCellToAddModList is present and length(sCellToAddModList) eq 3
    and
    sCellToAddModList contains
    (
        sCellIndex eq 3 and sCellConfigCommon contains (physCellId eq 51)
    )
    and
    sCellToAddModList contains
    (
        sCellIndex eq 4 and sCellConfigCommon contains (physCellId eq 52)
    )
    and
    sCellToAddModList contains
    (
        sCellIndex eq 5 and sCellConfigCommon contains (physCellId eq 53)
    )
    and
    (not sCellToAddModList contains (sCellIndex eq 6))
    """
