nRCellIdentity1 = "0b000000000000000000000100000000000001"
nRCellIdentity2 = "0b000000000000000000000100000000000010"
nRCellIdentity3 = "0b000000000000000000000100000000000011"
nRCellIdentity4 = "0b000000000000000000000100000000000100"
nRCellIdentity5 = "0b000000000000000000000100000000000101"
nRCellIdentity6 = "0b000000000000000000000100000000000110"
nRCellIdentity7 = "0b000000000000000000000100000000000111"

selected_SCells_in_UE_CON_MOD_REQ_template = """
    SCell-ToBeSetupMod-List is present and length(SCell-ToBeSetupMod-List) eq {num_items}
    {scell_1}
    {scell_2}
    {scell_3}
    {scell_4}
    {scell_5}
    """

sCellsToBeSetupModList_template = """
    and
    SCell-ToBeSetupMod-List contains
    (
        (sCellIndex eq {num_sCells}) and (nRCellIdentity eq "{nRCellIdentity}") and (sCellULConfigured eq "none")
    )
    """

sCellsToBeSetupModList_with_UL_template = """
    and SCell-ToBeSetupMod-List contains
    (
        (sCellIndex eq {num_sCells}) and (nRCellIdentity eq "{nRCellIdentity}") and (sCellULConfigured eq "ul")
    )
    """

UE_CON_MOD_REQ_4CC_FFFT_CA_in_AB1_UE1_UE2 = \
    selected_SCells_in_UE_CON_MOD_REQ_template.format(
        num_items=3,
        scell_1=sCellsToBeSetupModList_template.format(num_sCells=1, nRCellIdentity=nRCellIdentity2),
        scell_2=sCellsToBeSetupModList_template.format(num_sCells=2, nRCellIdentity=nRCellIdentity3),
        scell_3=sCellsToBeSetupModList_template.format(num_sCells=3, nRCellIdentity=nRCellIdentity5),
        scell_4="",
        scell_5="")

UE_CON_MOD_REQ_4CC_FFFT_CA_in_AB1_UE3 = \
    selected_SCells_in_UE_CON_MOD_REQ_template.format(
        num_items=3,
        scell_1=sCellsToBeSetupModList_template.format(num_sCells=1, nRCellIdentity=nRCellIdentity2),
        scell_2=sCellsToBeSetupModList_template.format(num_sCells=2, nRCellIdentity=nRCellIdentity3),
        scell_3=sCellsToBeSetupModList_with_UL_template.format(num_sCells=3, nRCellIdentity=nRCellIdentity5),
        scell_4="",
        scell_5="")

UE_CON_MOD_REQ_4CC_FFFT_CA_in_AB1_UE4 = \
    selected_SCells_in_UE_CON_MOD_REQ_template.format(
        num_items=3,
        scell_1=sCellsToBeSetupModList_with_UL_template.format(num_sCells=1, nRCellIdentity=nRCellIdentity2),
        scell_2=sCellsToBeSetupModList_template.format(num_sCells=2, nRCellIdentity=nRCellIdentity4),
        scell_3=sCellsToBeSetupModList_template.format(num_sCells=3, nRCellIdentity=nRCellIdentity5),
        scell_4="",
        scell_5="")

UE_CON_MOD_REQ_5CC_FFFFT_CA_in_AB1_UE1_UE2 = \
    selected_SCells_in_UE_CON_MOD_REQ_template.format(
        num_items=4,
        scell_1=sCellsToBeSetupModList_template.format(num_sCells=1, nRCellIdentity=nRCellIdentity2),
        scell_2=sCellsToBeSetupModList_template.format(num_sCells=2, nRCellIdentity=nRCellIdentity3),
        scell_3=sCellsToBeSetupModList_template.format(num_sCells=3, nRCellIdentity=nRCellIdentity4),
        scell_4=sCellsToBeSetupModList_template.format(num_sCells=4, nRCellIdentity=nRCellIdentity5),
        scell_5="")

UE_CON_MOD_REQ_5CC_FFFFT_CA_in_AB1_UE3 = \
    selected_SCells_in_UE_CON_MOD_REQ_template.format(
        num_items=4,
        scell_1=sCellsToBeSetupModList_template.format(num_sCells=1, nRCellIdentity=nRCellIdentity2),
        scell_2=sCellsToBeSetupModList_template.format(num_sCells=2, nRCellIdentity=nRCellIdentity3),
        scell_3=sCellsToBeSetupModList_template.format(num_sCells=3, nRCellIdentity=nRCellIdentity4),
        scell_4=sCellsToBeSetupModList_with_UL_template.format(num_sCells=4, nRCellIdentity=nRCellIdentity5),
        scell_5="")

UE_CON_MOD_REQ_5CC_FFFFT_CA_in_AB1_UE4 = \
    selected_SCells_in_UE_CON_MOD_REQ_template.format(
        num_items=4,
        scell_1=sCellsToBeSetupModList_with_UL_template.format(num_sCells=1, nRCellIdentity=nRCellIdentity2),
        scell_2=sCellsToBeSetupModList_template.format(num_sCells=2, nRCellIdentity=nRCellIdentity3),
        scell_3=sCellsToBeSetupModList_template.format(num_sCells=3, nRCellIdentity=nRCellIdentity4),
        scell_4=sCellsToBeSetupModList_template.format(num_sCells=4, nRCellIdentity=nRCellIdentity5),
        scell_5="")

UE_CON_MOD_REQ_4CC_TFFF_CA_in_BB1 = \
    selected_SCells_in_UE_CON_MOD_REQ_template.format(
        num_items=3,
        scell_1=sCellsToBeSetupModList_template.format(num_sCells=1, nRCellIdentity=nRCellIdentity1),
        scell_2=sCellsToBeSetupModList_template.format(num_sCells=2, nRCellIdentity=nRCellIdentity2),
        scell_3=sCellsToBeSetupModList_template.format(num_sCells=3, nRCellIdentity=nRCellIdentity3),
        scell_4="",
        scell_5="")

UE_CON_MOD_REQ_5CC_TFFFF_CA_in_BB1_UE2 = \
    selected_SCells_in_UE_CON_MOD_REQ_template.format(
        num_items=4,
        scell_1=sCellsToBeSetupModList_template.format(num_sCells=1, nRCellIdentity=nRCellIdentity1),
        scell_2=sCellsToBeSetupModList_template.format(num_sCells=2, nRCellIdentity=nRCellIdentity2),
        scell_3=sCellsToBeSetupModList_template.format(num_sCells=3, nRCellIdentity=nRCellIdentity3),
        scell_4=sCellsToBeSetupModList_template.format(num_sCells=4, nRCellIdentity=nRCellIdentity4),
        scell_5="")

UE_CON_MOD_REQ_5CC_FFFFT_CA_in_AB4 = \
    selected_SCells_in_UE_CON_MOD_REQ_template.format(
        num_items=4,
        scell_1=sCellsToBeSetupModList_template.format(num_sCells=1, nRCellIdentity=nRCellIdentity2),
        scell_2=sCellsToBeSetupModList_template.format(num_sCells=2, nRCellIdentity=nRCellIdentity3),
        scell_3=sCellsToBeSetupModList_template.format(num_sCells=3, nRCellIdentity=nRCellIdentity4),
        scell_4=sCellsToBeSetupModList_with_UL_template.format(num_sCells=4, nRCellIdentity=nRCellIdentity5),
        scell_5="")

UE_CON_MOD_REQ_4CC_FFFT_CA_in_AB4 = \
    selected_SCells_in_UE_CON_MOD_REQ_template.format(
        num_items=3,
        scell_1=sCellsToBeSetupModList_template.format(num_sCells=1, nRCellIdentity=nRCellIdentity3),
        scell_2=sCellsToBeSetupModList_template.format(num_sCells=2, nRCellIdentity=nRCellIdentity4),
        scell_3=sCellsToBeSetupModList_template.format(num_sCells=3, nRCellIdentity=nRCellIdentity5),
        scell_4="",
        scell_5="")

UE_CON_MOD_REQ_5CC_FFFFT_CA_in_AB5 = \
    selected_SCells_in_UE_CON_MOD_REQ_template.format(
        num_items=4,
        scell_1=sCellsToBeSetupModList_template.format(num_sCells=1, nRCellIdentity=nRCellIdentity2),
        scell_2=sCellsToBeSetupModList_template.format(num_sCells=2, nRCellIdentity=nRCellIdentity3),
        scell_3=sCellsToBeSetupModList_template.format(num_sCells=3, nRCellIdentity=nRCellIdentity4),
        scell_4=sCellsToBeSetupModList_template.format(num_sCells=4, nRCellIdentity=nRCellIdentity5),
        scell_5="")

UE_CON_MOD_REQ_5CC_TFFFF_CA_in_BB4 = \
    selected_SCells_in_UE_CON_MOD_REQ_template.format(
        num_items=4,
        scell_1=sCellsToBeSetupModList_template.format(num_sCells=1, nRCellIdentity=nRCellIdentity1),
        scell_2=sCellsToBeSetupModList_template.format(num_sCells=2, nRCellIdentity=nRCellIdentity2),
        scell_3=sCellsToBeSetupModList_template.format(num_sCells=3, nRCellIdentity=nRCellIdentity3),
        scell_4=sCellsToBeSetupModList_template.format(num_sCells=4, nRCellIdentity=nRCellIdentity4),
        scell_5="")

UE_CON_MOD_REQ_5CC_TFFFF_CA_in_BB4_1 = \
    selected_SCells_in_UE_CON_MOD_REQ_template.format(
        num_items=2,
        scell_1=sCellsToBeSetupModList_template.format(num_sCells=5, nRCellIdentity=nRCellIdentity6),
        scell_2=sCellsToBeSetupModList_template.format(num_sCells=6, nRCellIdentity=nRCellIdentity7),
        scell_3="",
        scell_4="",
        scell_5="")

UE_CON_MOD_REQ_5CC_TFFFF_CA_in_BB5_UE5 = \
    selected_SCells_in_UE_CON_MOD_REQ_template.format(
        num_items=4,
        scell_1=sCellsToBeSetupModList_template.format(num_sCells=1, nRCellIdentity=nRCellIdentity1),
        scell_2=sCellsToBeSetupModList_with_UL_template.format(num_sCells=2, nRCellIdentity=nRCellIdentity2),
        scell_3=sCellsToBeSetupModList_template.format(num_sCells=3, nRCellIdentity=nRCellIdentity3),
        scell_4=sCellsToBeSetupModList_template.format(num_sCells=4, nRCellIdentity=nRCellIdentity4),
        scell_5="")

SCell_ToBeRemoved_List_template = """
   SCell-ToBeRemoved-List contains
   (
        SCell-ToBeRemoved-Item contains
        (
            sCell-ID contains
            (
                nRCellIdentity eq "{nRCellIdentity}"
            )
        )
    )
    {scell_1}
    {scell_2}
    {scell_3}
    {scell_4}
"""

SCell_ToBeRemoved_Item_template = """
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

sCellToBeRemoveList_AB5 = \
    SCell_ToBeRemoved_List_template.format(
        nRCellIdentity=nRCellIdentity3,
        scell_1="",
        scell_2="",
        scell_3="",
        scell_4=""
    )

sCellToBeRemoveList_BB4 = \
    SCell_ToBeRemoved_List_template.format(
        nRCellIdentity=nRCellIdentity1,
        scell_1=SCell_ToBeRemoved_Item_template.format(nRCellIdentity=nRCellIdentity2),
        scell_2=SCell_ToBeRemoved_Item_template.format(nRCellIdentity=nRCellIdentity3),
        scell_3=SCell_ToBeRemoved_Item_template.format(nRCellIdentity=nRCellIdentity4),
        scell_4=""
    )

sCellToBeRemoveList_BB5 = \
    SCell_ToBeRemoved_List_template.format(
        nRCellIdentity=nRCellIdentity1,
        scell_1=SCell_ToBeRemoved_Item_template.format(nRCellIdentity=nRCellIdentity1),
        scell_2=SCell_ToBeRemoved_Item_template.format(nRCellIdentity=nRCellIdentity2),
        scell_3=SCell_ToBeRemoved_Item_template.format(nRCellIdentity=nRCellIdentity3),
        scell_4=SCell_ToBeRemoved_Item_template.format(nRCellIdentity=nRCellIdentity4)
    )

# SCellToBeSetupModList in UEContextModificationResponse templates
selected_SCells_for_sCellToAddModList_template = """
    sCellToAddModList is present and length(sCellToAddModList) eq {number_of_selected_scells}
    {scell_1}
    {scell_2}
    {scell_3}
    {scell_4}
    {scell_5}
    """

sCellToAddModList_template = """
    and sCellToAddModList contains
    (
        sCellIndex eq {scell_index}
        and sCellConfigCommon contains (physCellId eq {scell_physcellid})
    )
    """

sCellToAddModList_AB1_4CC = \
    selected_SCells_for_sCellToAddModList_template.format(
        number_of_selected_scells=3,
        scell_1=sCellToAddModList_template.format(scell_index=1, scell_physcellid=52),
        scell_2=sCellToAddModList_template.format(scell_index=2, scell_physcellid=53),
        scell_3=sCellToAddModList_template.format(scell_index=3, scell_physcellid=55),
        scell_4="",
        scell_5="")

sCellToAddModList_AB1_4CC_UE4 = \
    selected_SCells_for_sCellToAddModList_template.format(
        number_of_selected_scells=3,
        scell_1=sCellToAddModList_template.format(scell_index=1, scell_physcellid=52),
        scell_2=sCellToAddModList_template.format(scell_index=2, scell_physcellid=54),
        scell_3=sCellToAddModList_template.format(scell_index=3, scell_physcellid=55),
        scell_4="",
        scell_5="")

sCellToAddModList_AB1_5CC = \
    selected_SCells_for_sCellToAddModList_template.format(
        number_of_selected_scells=4,
        scell_1=sCellToAddModList_template.format(scell_index=1, scell_physcellid=52),
        scell_2=sCellToAddModList_template.format(scell_index=2, scell_physcellid=53),
        scell_3=sCellToAddModList_template.format(scell_index=3, scell_physcellid=54),
        scell_4=sCellToAddModList_template.format(scell_index=4, scell_physcellid=55),
        scell_5="")

sCellToAddModList_BB1_4CC = \
    selected_SCells_for_sCellToAddModList_template.format(
        number_of_selected_scells=3,
        scell_1=sCellToAddModList_template.format(scell_index=1, scell_physcellid=51),
        scell_2=sCellToAddModList_template.format(scell_index=2, scell_physcellid=52),
        scell_3=sCellToAddModList_template.format(scell_index=3, scell_physcellid=53),
        scell_4="",
        scell_5="")

sCellToAddModList_BB1_5CC = \
    selected_SCells_for_sCellToAddModList_template.format(
        number_of_selected_scells=4,
        scell_1=sCellToAddModList_template.format(scell_index=1, scell_physcellid=51),
        scell_2=sCellToAddModList_template.format(scell_index=2, scell_physcellid=52),
        scell_3=sCellToAddModList_template.format(scell_index=3, scell_physcellid=53),
        scell_4=sCellToAddModList_template.format(scell_index=4, scell_physcellid=54),
        scell_5="")

sCellToAddModList_AB4_5CC = \
    selected_SCells_for_sCellToAddModList_template.format(
        number_of_selected_scells=4,
        scell_1=sCellToAddModList_template.format(scell_index=1, scell_physcellid=52),
        scell_2=sCellToAddModList_template.format(scell_index=2, scell_physcellid=53),
        scell_3=sCellToAddModList_template.format(scell_index=3, scell_physcellid=54),
        scell_4=sCellToAddModList_template.format(scell_index=4, scell_physcellid=55),
        scell_5="")

sCellToAddModList_AB4_4CC = \
    selected_SCells_for_sCellToAddModList_template.format(
        number_of_selected_scells=3,
        scell_1=sCellToAddModList_template.format(scell_index=1, scell_physcellid=53),
        scell_2=sCellToAddModList_template.format(scell_index=2, scell_physcellid=54),
        scell_3=sCellToAddModList_template.format(scell_index=3, scell_physcellid=55),
        scell_4="",
        scell_5="")

sCellToAddModList_AB5_after_A2 = \
    selected_SCells_for_sCellToAddModList_template.format(
        number_of_selected_scells=3,
        scell_1=sCellToAddModList_template.format(scell_index=1, scell_physcellid=52),
        scell_2=sCellToAddModList_template.format(scell_index=3, scell_physcellid=54),
        scell_3=sCellToAddModList_template.format(scell_index=4, scell_physcellid=55),
        scell_4="",
        scell_5="")

sCellToAddModList_BB4_5CC = \
    selected_SCells_for_sCellToAddModList_template.format(
        number_of_selected_scells=4,
        scell_1=sCellToAddModList_template.format(scell_index=1, scell_physcellid=51),
        scell_2=sCellToAddModList_template.format(scell_index=2, scell_physcellid=52),
        scell_3=sCellToAddModList_template.format(scell_index=3, scell_physcellid=53),
        scell_4=sCellToAddModList_template.format(scell_index=4, scell_physcellid=54),
        scell_5="")

sCellToAddModList_BB4_5CC_1 = \
    selected_SCells_for_sCellToAddModList_template.format(
        number_of_selected_scells=2,
        scell_1=sCellToAddModList_template.format(scell_index=5, scell_physcellid=56),
        scell_2=sCellToAddModList_template.format(scell_index=6, scell_physcellid=57),
        scell_3="",
        scell_4="",
        scell_5="")

sCellToAddModList_BB5_5CC = \
    selected_SCells_for_sCellToAddModList_template.format(
        number_of_selected_scells=4,
        scell_1=sCellToAddModList_template.format(scell_index=1, scell_physcellid=51),
        scell_2=sCellToAddModList_template.format(scell_index=2, scell_physcellid=52),
        scell_3=sCellToAddModList_template.format(scell_index=3, scell_physcellid=53),
        scell_4=sCellToAddModList_template.format(scell_index=4, scell_physcellid=54),
        scell_5="")

# csi-MeasConfig in UEContextModificationResponse templates
CSI_meas_config_in_UE_CON_MOD_RESP_template = """
    csi-ReportConfigToAddModList is present and length(csi-ReportConfigToAddModList) eq {number_of_csi_report}
    {report_config_1}
    {report_config_2}
    {report_config_3}
    {report_config_4}
    {report_config_5}
    {report_config_6}
    {report_config_7}
    """

csi_ReportConfigToAddModList_template = """
and csi-ReportConfigToAddModList contains
        (
            reportConfigId eq {report_configid}
            and carrier eq {carrier}
        )
        """

csi_ReportConfigToAddModList_After_Reconf_template = """
and csi-ReportConfigToAddModList contains
        (
            reportConfigId eq {report_configid}
        )
        """

CSI_meas_config_for_4CC_BF_FFFT_CA_in_UE_CON_MOD_RESP_AB1 = \
    CSI_meas_config_in_UE_CON_MOD_RESP_template.format(
        number_of_csi_report=4,
        report_config_1=csi_ReportConfigToAddModList_template.format(report_configid=13, carrier=1),
        report_config_2=csi_ReportConfigToAddModList_template.format(report_configid=14, carrier=2),
        report_config_3=csi_ReportConfigToAddModList_template.format(report_configid=15, carrier=3),
        report_config_4=csi_ReportConfigToAddModList_template.format(report_configid=23, carrier=3),
        report_config_5="",
        report_config_6="",
        report_config_7="")

CSI_meas_config_for_5CC_BF_FFFFT_CA_in_UE_CON_MOD_RESP_AB1 = \
    CSI_meas_config_in_UE_CON_MOD_RESP_template.format(
        number_of_csi_report=5,
        report_config_1=csi_ReportConfigToAddModList_template.format(report_configid=13, carrier=1),
        report_config_2=csi_ReportConfigToAddModList_template.format(report_configid=14, carrier=2),
        report_config_3=csi_ReportConfigToAddModList_template.format(report_configid=15, carrier=3),
        report_config_4=csi_ReportConfigToAddModList_template.format(report_configid=16, carrier=4),
        report_config_5=csi_ReportConfigToAddModList_template.format(report_configid=24, carrier=4),
        report_config_6="",
        report_config_7="")

CSI_meas_config_for_4CC_TFFF_CA_in_UE_CON_MOD_RESP_BB1 = \
    CSI_meas_config_in_UE_CON_MOD_RESP_template.format(
        number_of_csi_report=3,
        report_config_1=csi_ReportConfigToAddModList_template.format(report_configid=13, carrier=1),
        report_config_2=csi_ReportConfigToAddModList_template.format(report_configid=14, carrier=2),
        report_config_3=csi_ReportConfigToAddModList_template.format(report_configid=15, carrier=3),
        report_config_4="",
        report_config_5="",
        report_config_6="",
        report_config_7="")

CSI_meas_config_for_5CC_TFFFF_CA_in_UE_CON_MOD_RESP_BB1 = \
    CSI_meas_config_in_UE_CON_MOD_RESP_template.format(
        number_of_csi_report=4,
        report_config_1=csi_ReportConfigToAddModList_template.format(report_configid=13, carrier=1),
        report_config_2=csi_ReportConfigToAddModList_template.format(report_configid=14, carrier=2),
        report_config_3=csi_ReportConfigToAddModList_template.format(report_configid=15, carrier=3),
        report_config_4=csi_ReportConfigToAddModList_template.format(report_configid=16, carrier=4),
        report_config_5="",
        report_config_6="",
        report_config_7="")

CSI_meas_config_for_5CC_FFFFT_CA_in_UE_CON_MOD_RESP_AB4 = \
    CSI_meas_config_in_UE_CON_MOD_RESP_template.format(
        number_of_csi_report=5,
        report_config_1=csi_ReportConfigToAddModList_template.format(report_configid=13, carrier=1),
        report_config_2=csi_ReportConfigToAddModList_template.format(report_configid=14, carrier=2),
        report_config_3=csi_ReportConfigToAddModList_template.format(report_configid=15, carrier=3),
        report_config_4=csi_ReportConfigToAddModList_template.format(report_configid=16, carrier=4),
        report_config_5=csi_ReportConfigToAddModList_template.format(report_configid=24, carrier=4),
        report_config_6="",
        report_config_7="")

CSI_meas_config_for_4CC_FFFT_CA_in_UE_CON_MOD_RESP_AB4 = \
    CSI_meas_config_in_UE_CON_MOD_RESP_template.format(
        number_of_csi_report=4,
        report_config_1=csi_ReportConfigToAddModList_template.format(report_configid=13, carrier=1),
        report_config_2=csi_ReportConfigToAddModList_template.format(report_configid=14, carrier=2),
        report_config_3=csi_ReportConfigToAddModList_template.format(report_configid=15, carrier=3),
        report_config_4=csi_ReportConfigToAddModList_template.format(report_configid=23, carrier=3),
        report_config_5="",
        report_config_6="",
        report_config_7="")

CSI_meas_config_after_A2_for_in_UE_CON_MOD_RESP_AB5 = \
    CSI_meas_config_in_UE_CON_MOD_RESP_template.format(
        number_of_csi_report=5,
        report_config_1=csi_ReportConfigToAddModList_After_Reconf_template.format(report_configid=0),
        report_config_2=csi_ReportConfigToAddModList_template.format(report_configid=13, carrier=1),
        report_config_3=csi_ReportConfigToAddModList_template.format(report_configid=15, carrier=3),
        report_config_4=csi_ReportConfigToAddModList_template.format(report_configid=16, carrier=4),
        report_config_5=csi_ReportConfigToAddModList_template.format(report_configid=24, carrier=4),
        report_config_6="",
        report_config_7="")

spCellConfig_in_UE_CON_MOD_RESP_template = """
    DUtoCURRCInformation contains
    (
        CellGroupConfig contains
        (
            spCellConfig contains
            (
                csi-MeasConfig contains
                (
                    csi-ReportConfigToReleaseList is present
                    and length(csi-ReportConfigToReleaseList) eq {number}
                    and csi-ReportConfigToReleaseList contains ({csi_release})
                )
            )
            and sCellToReleaseList is present
            and length(sCellToReleaseList) eq {num_release}
            and sCellToReleaseList contains ({index})
        )
    )
"""

spCellConfig_in_UE_CON_MOD_RESP_BB5_template = """
    DUtoCURRCInformation contains
    (
        CellGroupConfig contains
        (
            spCellConfig is present
            and sCellToReleaseList is present
            and length(sCellToReleaseList) eq {num_release}
            and sCellToReleaseList contains ({index})
        )
    )
"""

CSI_Release_in_UE_CON_MOD_RESP_AB4 = \
    spCellConfig_in_UE_CON_MOD_RESP_template.format(
        number=1,
        csi_release="14",
        num_release=1,
        index=2
    )

SCell_Release_in_UE_CON_MOD_RESP_BB4 = \
    spCellConfig_in_UE_CON_MOD_RESP_template.format(
        number=2,
        csi_release="15, 16",
        num_release=4,
        index="1,2,3,4"
    )

SCell_Release_in_UE_CON_MOD_RESP_BB5 = \
    spCellConfig_in_UE_CON_MOD_RESP_BB5_template.format(
        num_release=4,
        index="1,2,3,4"
    )

# PUCCH config in UEContextModificationResponse templates
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

resourceToAddModList_template = """
    resourceToAddModList contains (pucch-ResourceId is present)
    and (pucch-ResourceId contains {ResourceIdList})
"""

resourceSet1 = resourceSet1_template.format(
    set_length=2,
    Resource_List=(10, 11),
    maxPayloadSize=8)

resourceSet1_BB1_UE1 = resourceSet1_template.format(
    set_length=8,
    Resource_List=(10, 11, 12, 13, 14, 15, 16, 17),
    maxPayloadSize=16)

resourceSet1_BB1_UE2 = resourceSet1_template.format(
    set_length=8,
    Resource_List=(10, 11, 12, 13, 14, 15, 16, 17),
    maxPayloadSize=20)

resourceToAddModList_4CC_FFFT = resourceToAddModList_template.format(
    ResourceIdList=(10, 11, 19, 21, 23, 24))

resourceToAddModList_5CC_FFFFT = resourceToAddModList_template.format(
    ResourceIdList=(10, 11, 19, 21, 23, 25, 26))

resourceToAddModList_4CC_TFFF = resourceToAddModList_template.format(
    ResourceIdList=(19, 21, 23))

resourceToAddModList_5CC_TFFFF = resourceToAddModList_template.format(
    ResourceIdList=(19, 21, 23, 25))

resourceToAddModList_4CC_FFFF_AB5 = resourceToAddModList_template.format(
    ResourceIdList=(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 19, 23, 25, 26))

PUCCH_config_for_4CC_FFFT_CA_in_UE_CON_MOD_RESP = fill_PUCCH_config_in_UE_CON_MOD_RESP_template(
    resourceSet1_content=resourceSet1,
    resourceToAddModList_content=resourceToAddModList_4CC_FFFT,
    resourceToAddModList_length=6)

PUCCH_config_for_5CC_FFFFT_CA_in_UE_CON_MOD_RESP = fill_PUCCH_config_in_UE_CON_MOD_RESP_template(
    resourceSet1_content=resourceSet1,
    resourceToAddModList_content=resourceToAddModList_5CC_FFFFT,
    resourceToAddModList_length=7)

PUCCH_config_for_4CC_TFFF_CA_in_UE_CON_MOD_RESP_BB1 = fill_PUCCH_config_in_UE_CON_MOD_RESP_template(
    resourceSet1_content=resourceSet1_BB1_UE1,
    resourceToAddModList_content=resourceToAddModList_4CC_TFFF,
    resourceToAddModList_length=3)

PUCCH_config_for_5CC_TFFFF_CA_in_UE_CON_MOD_RESP_BB1_UE2 = fill_PUCCH_config_in_UE_CON_MOD_RESP_template(
    resourceSet1_content=resourceSet1_BB1_UE2,
    resourceToAddModList_content=resourceToAddModList_5CC_TFFFF,
    resourceToAddModList_length=4)

PUCCH_config_for_5CC_FFFFT_CA_in_UE_CON_MOD_RESP_AB4 = fill_PUCCH_config_in_UE_CON_MOD_RESP_template(
    resourceSet1_content=resourceSet1,
    resourceToAddModList_content=resourceToAddModList_5CC_FFFFT,
    resourceToAddModList_length=7)

PUCCH_config_in_UE_CON_MOD_RESP_after_Reconf_template = """
    pucch-Config contains
    (
        resourceSetToAddModList is present
        and length(resourceSetToAddModList) eq 3
        and resourceSetToAddModList contains
        (
            pucch-ResourceSetId eq 0
            and
            length(resourceList) ge 8
        )
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
        and {resourceToAddModList_content}
        and length(resourceToAddModList) eq {resourceToAddModList_length}
    )
    """

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
            reportConfigId eq {report_configid_a1}
            and
            eventId contains (eventA1 is present)
            and
            a1-Threshold contains (rsrp eq {rsrp_threshold})
        )
        and measIdToAddModList contains
            (
                measId eq {meas_id_a1}
                and measObjectId eq {meas_obj_pcell}
                and reportConfigId eq {report_configid_a1}
            )
    )
"""

A2_measurement_configuration_template = """
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
            reportConfigId eq {report_configid_a2}
            and
            eventId contains (eventA2 is present)
            and
            a2-Threshold contains (rsrp eq {rsrp_threshold})
        )
        and measIdToAddModList contains
            (
                measId eq {meas_id_a2}
                and measObjectId eq {meas_obj_pcell}
                and reportConfigId eq {report_configid_a2}
            )
    )
"""

A4_measurement_configuration_template = """
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
            reportConfigId eq {report_configid_a4}
            and
            eventId contains (eventA4 is present)
            and
            a4-Threshold contains (rsrp eq {rsrp_threshold})
        )
        and measIdToAddModList contains
            (
                measId eq {meas_id_a4}
                and measObjectId eq {meas_obj}
                and reportConfigId eq {report_configid_a4}
            )
    )
"""

A1_measurement_configuration_for_PCell_TDD = \
    A1_measurement_configuration_template.format(
        ssbFrequency=506190,
        freqBandIndicatorNR=41,
        rsrp_threshold=70,
        meas_id_a1=1,
        meas_obj_pcell=1,
        report_configid_a1=1
    )

A1_measurement_configuration_for_PCell_FDD = \
    A1_measurement_configuration_template.format(
        ssbFrequency=389090,
        freqBandIndicatorNR=25,
        rsrp_threshold=70,
        meas_id_a1=1,
        meas_obj_pcell=1,
        report_configid_a1=1
    )

A1_measurement_configuration_for_PCell_TDD_BB4 = \
    A1_measurement_configuration_template.format(
        ssbFrequency=510750,
        freqBandIndicatorNR=41,
        rsrp_threshold=50,
        meas_id_a1=1,
        meas_obj_pcell=1,
        report_configid_a1=1
    )

A1_measurement_configuration_for_PCell_TDD_BB5 = \
    A1_measurement_configuration_template.format(
        ssbFrequency=506190,
        freqBandIndicatorNR=41,
        rsrp_threshold=70,
        meas_id_a1=2,
        meas_obj_pcell=1,
        report_configid_a1=2
    )

A2_measurement_configuration_for_handover_BB5 = \
    A2_measurement_configuration_template.format(
        ssbFrequency=506190,
        freqBandIndicatorNR=41,
        rsrp_threshold=33,
        meas_id_a2=1,
        meas_obj_pcell=1,
        report_configid_a2=1
    )

A4_measurement_configuration_for_AB4 = \
    A4_measurement_configuration_template.format(
        ssbFrequency=438050,
        freqBandIndicatorNR=66,
        rsrp_threshold=80,
        meas_id_a4=2,
        meas_obj=2,
        report_configid_a4=2
    )

A1_measurementReport_template = """
    measurementReport contains
    (
        measResults contains
        (
            measId eq {meas_id_a1}
            and measResultServingMOList contains
            (
                servCellId eq 0
                and measResultServingCell contains
                (
                    physCellId eq {physCellId}
                    and measResult contains
                    (
                        cellResults contains
                        (
                            resultsSSB-Cell contains
                            (
                                rsrp eq {srsrp_a1}
                            )
                        )
                    )
                )
            )
        )
    )
"""

A1_measurementReport_for_PCell_TDD = \
    A1_measurementReport_template.format(
        meas_id_a1=1,
        physCellId=55,
        srsrp_a1=90
    )

A1_measurementReport_for_PCell_FDD_AB4 = \
    A1_measurementReport_template.format(
        meas_id_a1=1,
        physCellId=51,
        srsrp_a1=90
    )

A1_measurementReport_for_PCell_TDD_BB4 = \
    A1_measurementReport_template.format(
        meas_id_a1=1,
        physCellId=55,
        srsrp_a1=70
    )

A1_measurementReport_for_PCell_TDD_BB5 = \
    A1_measurementReport_template.format(
        meas_id_a1=2,
        physCellId=55,
        srsrp_a1=90
    )

A1_measurementReport_for_SCell_Change = \
    A1_measurementReport_template.format(
        meas_id_a1=6,
        physCellId=55,
        srsrp_a1=90
    )

A4_measurementReport_template = """
    measurementReport contains
    (
        measResults contains
        (
            measId eq {meas_id_a4}
            and measResultServingMOList contains
            (
                servCellId eq 0
                and measResultServingCell contains
                (
                    physCellId eq {physCellId_1}
                    and measResult contains
                    (
                        cellResults contains
                        (
                            resultsSSB-Cell is present
                        )
                    )
                )
            )
            and measResultNeighCells contains
            (
            measResultListNR contains
                (
                    physCellId eq {physCellId_2}
                    and measResult contains
                    (
                        cellResults contains
                        (
                            resultsSSB-Cell contains
                            (
                                rsrp eq {rsrp}
                            )
                        )
                    )
                )
            )
        )
    )
"""

A4_measurementReport_for_PCell_FDD_AB4 = \
    A4_measurementReport_template.format(
        meas_id_a4=3,
        physCellId_1=51,
        physCellId_2=52,
        rsrp=95
    )

A2_measurementReport_template = """
    measurementReport contains
    (
        measResults contains
        (
            measId eq {meas_id_a2}
            and measResultServingMOList contains
            (
                servCellId eq 0
                and measResultServingCell contains
                (
                    physCellId eq {physCellId_1}
                    and measResult contains
                    (
                        cellResults contains
                        (
                            resultsSSB-Cell contains
                            (
                                rsrp eq {rsrp}
                                and rsrq eq {rsrq}
                            )
                        )
                    )
                )
            )
            and {servCell1}
            and {servCell2}
            and {servCell3}
            and {servCell4}
        )
    )
"""

A2_measurementReport_BB5_template = """
    measurementReport contains
    (
        measResults contains
        (
            measId eq {meas_id_a2}
            and measResultServingMOList contains
            (
                servCellId eq 0
                and measResultServingCell contains
                (
                    physCellId eq {physCellId_1}
                    and measResult contains
                    (
                        cellResults contains
                        (
                            resultsSSB-Cell contains
                            (
                                rsrp eq {rsrp}
                                and rsrq eq {rsrq}
                            )
                        )
                    )
                )
            )
            and {servCell}
        )
    )
"""

measResultServingMOList_template = """
measResultServingMOList contains
            (
                servCellId eq {id}
                and measResultServingCell contains
                (
                    physCellId eq {physCellId}
                    and measResult contains
                    (
                        cellResults contains
                        (
                            resultsSSB-Cell contains
                            (
                                rsrp eq {srsrp}
                                and rsrq eq {srsrq}
                            )
                        )
                    )
                )
            )
"""

A2_measurementReport_AB5 = \
    A2_measurementReport_template.format(
        meas_id_a2=5,
        physCellId_1=51,
        rsrp=90,
        rsrq=90,
        servCell1=measResultServingMOList_template.format(id=1, physCellId=52, srsrp=60, srsrq=60),
        servCell2=measResultServingMOList_template.format(id=2, physCellId=53, srsrp=60, srsrq=60),
        servCell3=measResultServingMOList_template.format(id=3, physCellId=54, srsrp=60, srsrq=60),
        servCell4=measResultServingMOList_template.format(id=4, physCellId=55, srsrp=10, srsrq=10)
    )

A2_measurementReport_for_PCell_Change = \
    A2_measurementReport_BB5_template.format(
        meas_id_a2=7,
        physCellId_1=55,
        rsrp=5,
        rsrq=10,
        servCell=measResultServingMOList_template.format(id=3, physCellId=53, srsrp=70, srsrq=90)
    )

meas_Config_in_RRC_Reconf_template = """
    measConfig contains
    (
        measObjectToAddModList contains
        (
        measObjectId eq {measObjId_1}
        and
        freqBandIndicatorNR eq {freqBandInd_1}
        )
        {measObjId_2}
        {measObjId_3}
        {measObjId_4}
        {measObjId_5}
        {report_config_1}
        {report_config_2}
        {report_config_3}
        {meas_id_1}
        {meas_id_2}
        {meas_id_3}
        {meas_id_4}
        {meas_id_5}
        {meas_id_6}
        and measIdToRemoveList is present
        and length(measIdToRemoveList) eq {measIdToRemoveLenght}
        and measIdToRemoveList contains ({measIdToRemoveListNumId})
        and reportConfigToRemoveList contains ({reportConfigToRemoveNumId})
    )
    """

meas_Config_in_RRC_Reconf_After_A1_or_A2_template = """
    measConfig contains
    (
        measObjectToRemoveList contains ({measObjectToRemoveId})
        {measObjId_2}
        {measObjId_3}
        {measObjId_4}
        {measObjId_5}
        {report_config_1}
        {report_config_2}
        {report_config_3}
        {meas_id_1}
        {meas_id_2}
        {meas_id_3}
        {meas_id_4}
        {meas_id_5}
        {meas_id_6}
        and measIdToRemoveList is present
        and length(measIdToRemoveList) eq {measIdToRemoveLenght}
        and measIdToRemoveList contains ({measIdToRemoveListNumId})
    )
    """

meas_Config_in_RRC_Reconf_After_A2_PCell_Change_template = """
    measConfig contains
    (
        measObjectToRemoveList contains ({measObjectToRemoveId})
        {measObjId_2}
        {measObjId_3}
        {measObjId_4}
        {measObjId_5}
        {report_config_1}
        {report_config_2}
        {report_config_3}
        {meas_id_1}
        {meas_id_2}
        {meas_id_3}
        {meas_id_4}
        {meas_id_5}
        {meas_id_6}
        and measIdToRemoveList is present
        and length(measIdToRemoveList) eq {measIdToRemoveLenght}
        and measIdToRemoveList contains ({measIdToRemoveListNumId})
        and reportConfigToRemoveList contains ({reportConfigToRemoveNumId})
    )
    """

meas_Config_in_RRC_Reconf_template_BB5 = """
    measConfig contains
    (
        measObjectToAddModList contains
        (
        measObjectId eq {measObjId_1}
        and
        freqBandIndicatorNR eq {freqBandInd_1}
        )
        {measObjId_2}
        {measObjId_3}
        {measObjId_4}
        {measObjId_5}
        {report_config_1}
        {report_config_2}
        {report_config_3}
        {meas_id_1}
        {meas_id_2}
        {meas_id_3}
        {meas_id_4}
        {meas_id_5}
        {meas_id_6}
    )
    """

meas_Config_in_UEConModReq = """
    measConfig contains
    (
        measObjectToAddModList contains
        (
        measObjectId eq {measObjId_1}
        and
        freqBandIndicatorNR eq {freqBandInd_1}
        )
        {measObjId_2}
        {measObjId_3}
        {measObjId_4}
        {measObjId_5}
        {report_config_1}
        {report_config_2}
        {report_config_3}
        {meas_id_1}
        {meas_id_2}
        {meas_id_3}
        {meas_id_4}
        {meas_id_5}
        {meas_id_6}
    )
    """

meas_Config_with_gap_template = """
    measConfig contains
    (
        measIdToRemoveList contains ({measIdToRemoveListNumId})
        and measGapConfig contains
        (
            gapUE contains
             (
                 release is present
             )
        )
    )
    """

meas_Config_with_gap = \
    meas_Config_with_gap_template.format(
        measIdToRemoveListNumId=3
    )

meas_Object_template = """
    and measObjectToAddModList contains
    (
        measObjectId eq {measObjId}
        and
        freqBandIndicatorNR eq {freqBandInd}
    )"""

report_Config_template = """
    and reportConfigToAddModList contains
    (
        reportConfigId eq {reportConfigId}
        and
        eventId contains ({event_type} is present)
        and
        {type}-Threshold contains ({threshold_type} eq {threshold})
    )"""

meas_Id_template = """
    and measIdToAddModList contains
    (
        measId eq {measId}
        and
        measObjectId eq {measObjId}
        and
        reportConfigId eq {reportConfId}
    )"""

meas_config_in_RRC_Reconf_4CC_TFFF = \
    meas_Config_in_RRC_Reconf_template.format(
        measObjId_1=2,
        freqBandInd_1=25,
        measObjId_2=meas_Object_template.format(measObjId=3, freqBandInd=66),
        measObjId_3=meas_Object_template.format(measObjId=4, freqBandInd=66),
        measObjId_4="",
        measObjId_5="",
        report_config_1=report_Config_template.format(
            reportConfigId=2, event_type="eventA2", type="a2", threshold_type="rsrp", threshold=34),
        report_config_2="",
        report_config_3="",
        meas_id_1=meas_Id_template.format(measId=2, measObjId=2, reportConfId=2),
        meas_id_2=meas_Id_template.format(measId=3, measObjId=3, reportConfId=2),
        meas_id_3=meas_Id_template.format(measId=4, measObjId=4, reportConfId=2),
        meas_id_4="",
        meas_id_5="",
        meas_id_6="",
        measIdToRemoveLenght=1,
        measIdToRemoveListNumId=1,
        reportConfigToRemoveNumId=1
    )

meas_config_in_RRC_Reconf_5CC_TFFFF = \
    meas_Config_in_RRC_Reconf_template.format(
        measObjId_1=2,
        freqBandInd_1=25,
        measObjId_2=meas_Object_template.format(measObjId=3, freqBandInd=66),
        measObjId_3=meas_Object_template.format(measObjId=4, freqBandInd=66),
        measObjId_4=meas_Object_template.format(measObjId=5, freqBandInd=71),
        measObjId_5="",
        report_config_1=report_Config_template.format(
            reportConfigId=2, event_type="eventA2", type="a2", threshold_type="rsrp", threshold=34),
        report_config_2="",
        report_config_3="",
        meas_id_1=meas_Id_template.format(measId=2, measObjId=2, reportConfId=2),
        meas_id_2=meas_Id_template.format(measId=3, measObjId=3, reportConfId=2),
        meas_id_3=meas_Id_template.format(measId=4, measObjId=4, reportConfId=2),
        meas_id_4=meas_Id_template.format(measId=5, measObjId=5, reportConfId=2),
        meas_id_5="",
        meas_id_6="",
        measIdToRemoveLenght=1,
        measIdToRemoveListNumId=1,
        reportConfigToRemoveNumId=1
    )

meas_config_in_RRC_Reconf_5CC_TFFFF_BB5_after_A1 = \
    meas_Config_in_RRC_Reconf_template.format(
        measObjId_1=2,
        freqBandInd_1=25,
        measObjId_2=meas_Object_template.format(measObjId=3, freqBandInd=66),
        measObjId_3=meas_Object_template.format(measObjId=4, freqBandInd=66),
        measObjId_4=meas_Object_template.format(measObjId=5, freqBandInd=71),
        measObjId_5="",
        report_config_1=report_Config_template.format(
            reportConfigId=3, event_type="eventA2", type="a2", threshold_type="rsrp", threshold=34),
        report_config_2=report_Config_template.format(
            reportConfigId=4, event_type="eventA2", type="a2", threshold_type="rsrp", threshold=10),
        report_config_3="",
        meas_id_1=meas_Id_template.format(measId=3, measObjId=2, reportConfId=3),
        meas_id_2=meas_Id_template.format(measId=4, measObjId=3, reportConfId=3),
        meas_id_3=meas_Id_template.format(measId=5, measObjId=4, reportConfId=3),
        meas_id_4=meas_Id_template.format(measId=6, measObjId=5, reportConfId=3),
        meas_id_5=meas_Id_template.format(measId=7, measObjId=1, reportConfId=4),
        meas_id_6="",
        measIdToRemoveLenght=1,
        measIdToRemoveListNumId=2,
        reportConfigToRemoveNumId=2
    )

meas_config_in_RRC_Reconf_5CC_TFFFF_BB5 = \
    meas_Config_in_RRC_Reconf_template_BB5.format(
        measObjId_1=1,
        freqBandInd_1=41,
        measObjId_2="",
        measObjId_3="",
        measObjId_4="",
        measObjId_5="",
        report_config_1=report_Config_template.format(
            reportConfigId=1, event_type="eventA2", type="a2", threshold_type="rsrp", threshold=33),
        report_config_2=report_Config_template.format(
            reportConfigId=2, event_type="eventA1", type="a1", threshold_type="rsrp", threshold=70),
        report_config_3="",
        meas_id_1=meas_Id_template.format(measId=1, measObjId=1, reportConfId=1),
        meas_id_2=meas_Id_template.format(measId=2, measObjId=1, reportConfId=2),
        meas_id_3="",
        meas_id_4="",
        meas_id_5="",
        meas_id_6=""
    )

meas_Config_in_UEConModReq_AB4 = \
    meas_Config_in_UEConModReq.format(
        measObjId_1=1,
        freqBandInd_1=25,
        measObjId_2=meas_Object_template.format(measObjId=2, freqBandInd=66),
        measObjId_3="",
        measObjId_4="",
        measObjId_5="",
        report_config_1=report_Config_template.format(
            reportConfigId=1, event_type="eventA1", type="a1", threshold_type="rsrp", threshold=70),
        report_config_2=report_Config_template.format(
            reportConfigId=2, event_type="eventA4", type="a4", threshold_type="rsrp", threshold=80),
        report_config_3="",
        meas_id_1=meas_Id_template.format(measId=1, measObjId=1, reportConfId=1),
        meas_id_2=meas_Id_template.format(measId=2, measObjId=2, reportConfId=2),
        meas_id_3="",
        meas_id_4="",
        meas_id_5="",
        meas_id_6=""
    )

meas_config_in_RRC_Reconf_5CC_FFFFT = \
    meas_Config_in_RRC_Reconf_template.format(
        measObjId_1=2,
        freqBandInd_1=66,
        measObjId_2=meas_Object_template.format(measObjId=3, freqBandInd=66),
        measObjId_3=meas_Object_template.format(measObjId=4, freqBandInd=71),
        measObjId_4=meas_Object_template.format(measObjId=5, freqBandInd=41),
        measObjId_5="",
        report_config_1=report_Config_template.format(
            reportConfigId=3, event_type="eventA2", type="a2", threshold_type="rsrp", threshold=34),
        report_config_2="",
        report_config_3="",
        meas_id_1=meas_Id_template.format(measId=4, measObjId=2, reportConfId=3),
        meas_id_2=meas_Id_template.format(measId=5, measObjId=3, reportConfId=3),
        meas_id_3=meas_Id_template.format(measId=6, measObjId=4, reportConfId=3),
        meas_id_4=meas_Id_template.format(measId=7, measObjId=5, reportConfId=3),
        meas_id_5="",
        meas_id_6="",
        measIdToRemoveLenght=1,
        measIdToRemoveListNumId=1,
        reportConfigToRemoveNumId=1
    )

meas_config_in_RRC_Reconf_4CC_FFFFT = \
    meas_Config_in_RRC_Reconf_template.format(
        measObjId_1=3,
        freqBandInd_1=66,
        measObjId_2=meas_Object_template.format(measObjId=4, freqBandInd=71),
        measObjId_3=meas_Object_template.format(measObjId=5, freqBandInd=41),
        measObjId_4="",
        measObjId_5="",
        report_config_1=report_Config_template.format(
            reportConfigId=3, event_type="eventA2", type="a2", threshold_type="rsrp", threshold=34),
        report_config_2="",
        report_config_3="",
        meas_id_1=meas_Id_template.format(measId=4, measObjId=3, reportConfId=3),
        meas_id_2=meas_Id_template.format(measId=5, measObjId=4, reportConfId=3),
        meas_id_3=meas_Id_template.format(measId=6, measObjId=5, reportConfId=3),
        meas_id_4="",
        meas_id_5="",
        meas_id_6="",
        measIdToRemoveLenght=1,
        measIdToRemoveListNumId=1,
        reportConfigToRemoveNumId=1
    )

meas_config_in_RRC_Reconf_5CC_FFFFT_AB5 = \
    meas_Config_in_RRC_Reconf_template.format(
        measObjId_1=2,
        freqBandInd_1=66,
        measObjId_2=meas_Object_template.format(measObjId=3, freqBandInd=66),
        measObjId_3=meas_Object_template.format(measObjId=4, freqBandInd=71),
        measObjId_4=meas_Object_template.format(measObjId=5, freqBandInd=41),
        measObjId_5="",
        report_config_1=report_Config_template.format(
            reportConfigId=2, event_type="eventA2", type="a2", threshold_type="rsrp", threshold=34),
        report_config_2="",
        report_config_3="",
        meas_id_1=meas_Id_template.format(measId=2, measObjId=2, reportConfId=2),
        meas_id_2=meas_Id_template.format(measId=3, measObjId=3, reportConfId=2),
        meas_id_3=meas_Id_template.format(measId=4, measObjId=4, reportConfId=2),
        meas_id_4=meas_Id_template.format(measId=5, measObjId=5, reportConfId=2),
        meas_id_5="",
        meas_id_6="",
        measIdToRemoveLenght=1,
        measIdToRemoveListNumId=1,
        reportConfigToRemoveNumId=1
    )

meas_config_in_RRC_Reconf_5CC_FFFFT_AB5_after_A2 = \
    meas_Config_in_RRC_Reconf_After_A1_or_A2_template.format(
        measObjectToRemoveId=3,
        measObjId_2=meas_Object_template.format(measObjId=1, freqBandInd=25),
        measObjId_3="",
        measObjId_4="",
        measObjId_5="",
        report_config_1="",
        report_config_2="",
        report_config_3="",
        meas_id_1="",
        meas_id_2="",
        meas_id_3="",
        meas_id_4="",
        meas_id_5="",
        meas_id_6="",
        measIdToRemoveLenght=1,
        measIdToRemoveListNumId=5
    )

meas_config_in_RRC_Reconf_5CC_TFFFF_BB4 = \
    meas_Config_in_RRC_Reconf_template.format(
        measObjId_1=2,
        freqBandInd_1=25,
        measObjId_2=meas_Object_template.format(measObjId=3, freqBandInd=66),
        measObjId_3=meas_Object_template.format(measObjId=4, freqBandInd=66),
        measObjId_4=meas_Object_template.format(measObjId=5, freqBandInd=71),
        measObjId_5="",
        report_config_1=report_Config_template.format(
            reportConfigId=2, event_type="eventA2", type="a2", threshold_type="rsrq", threshold=49),
        report_config_2=report_Config_template.format(
            reportConfigId=3, event_type="eventA1", type="a1", threshold_type="rsrp", threshold=80),
        report_config_3="",
        meas_id_1=meas_Id_template.format(measId=2, measObjId=2, reportConfId=2),
        meas_id_2=meas_Id_template.format(measId=3, measObjId=3, reportConfId=2),
        meas_id_3=meas_Id_template.format(measId=4, measObjId=4, reportConfId=2),
        meas_id_4=meas_Id_template.format(measId=5, measObjId=5, reportConfId=2),
        meas_id_5=meas_Id_template.format(measId=6, measObjId=1, reportConfId=3),
        meas_id_6="",
        measIdToRemoveLenght=1,
        measIdToRemoveListNumId=1,
        reportConfigToRemoveNumId=1
    )

meas_config_in_RRC_Reconf_5CC_TFFFF_BB4_1 = \
    meas_Config_in_RRC_Reconf_After_A1_or_A2_template.format(
        measObjectToRemoveId="2,3,4,5",
        measObjId_2=meas_Object_template.format(measObjId=6, freqBandInd=77),
        measObjId_3=meas_Object_template.format(measObjId=7, freqBandInd=77),
        measObjId_4="",
        measObjId_5="",
        report_config_1="",
        report_config_2="",
        report_config_3="",
        meas_id_1=meas_Id_template.format(measId=7, measObjId=6, reportConfId=2),
        meas_id_2=meas_Id_template.format(measId=8, measObjId=7, reportConfId=2),
        meas_id_3="",
        meas_id_4="",
        meas_id_5="",
        meas_id_6="",
        measIdToRemoveLenght=5,
        measIdToRemoveListNumId="6,2,3,4,5"
    )

meas_config_in_RRC_Reconf_BB5_after_A2 = \
    meas_Config_in_RRC_Reconf_After_A2_PCell_Change_template.format(
        measObjectToRemoveId="1,2,3,5",
        measObjId_2="",
        measObjId_3="",
        measObjId_4=meas_Object_template.format(measObjId=4, freqBandInd=66),
        measObjId_5="",
        report_config_1="",
        report_config_2="",
        report_config_3="",
        meas_id_1="",
        meas_id_2="",
        meas_id_3="",
        meas_id_4="",
        meas_id_5="",
        meas_id_6="",
        measIdToRemoveLenght=6,
        measIdToRemoveListNumId="3,4,5,6,7,1",
        reportConfigToRemoveNumId="1,3,4"
    )

UE_CON_MOD_REQ_4CC_FFFT_CA_in_AB1_UE1_UE2 = \
    selected_SCells_in_UE_CON_MOD_REQ_template.format(
        num_items=3,
        scell_1=sCellsToBeSetupModList_template.format(num_sCells=1, nRCellIdentity=nRCellIdentity2),
        scell_2=sCellsToBeSetupModList_template.format(num_sCells=2, nRCellIdentity=nRCellIdentity3),
        scell_3=sCellsToBeSetupModList_template.format(num_sCells=3, nRCellIdentity=nRCellIdentity5),
        scell_4="",
        scell_5="")

ue_context_modification_string_filter_A1_A4 = """
{MeasConfig:{measIdToAddModList:[{measId:1,measObjectId:1,reportConfigId:1},{measId:2,measObjectId:2,reportConfigId:2}],
    measObjectToAddModList:[{measObject:{measObjectNR:{absThreshSS-BlocksConsolidation:{thresholdRSRP:0},
    freqBandIndicatorNR:25,offsetMO:{},quantityConfigIndex:1,referenceSignalConfig:{ssb-ConfigMobility:
        {deriveSSB-IndexFromCell:TRUE,ssb-ToMeasure:
        {setup:{shortBitmap:0b1000}}}},smtc1:{duration:sf5,periodicityAndOffset:{sf20:0}},ssbFrequency:389090,
        ssbSubcarrierSpacing:kHz15}},
        measObjectId:1},{measObject:{measObjectNR:{freqBandIndicatorNR:66,offsetMO:{},quantityConfigIndex:1,
        referenceSignalConfig:{ssb-ConfigMobility:{deriveSSB-IndexFromCell:TRUE}},smtc1:{duration:sf3,
        periodicityAndOffset:{sf5:0}},ssbFrequency:438050,ssbSubcarrierSpacing:kHz15}},measObjectId:2}],
    reportConfigToAddModList:[{reportConfig:{reportConfigNR:{reportType:{eventTriggered:{eventId:{eventA1:{a1-Threshold:
        {rsrp:70},hysteresis:0,reportOnLeave:TRUE,timeToTrigger:ms320}},
        includeBeamMeasurements:TRUE,maxNrofRS-IndexesToReport:8,
        maxReportCells:8,reportAmount:r4,reportInterval:ms1024,reportQuantityCell:{rsrp:TRUE,rsrq:TRUE,sinr:TRUE},
        reportQuantityRS-Indexes:{rsrp:TRUE,rsrq:TRUE,sinr:TRUE},rsType:ssb}}}},reportConfigId:1},
    {reportConfig:{reportConfigNR:{reportType:{eventTriggered:{eventId:{eventA4:{a4-Threshold:{rsrp:80},hysteresis:0,
        reportOnLeave:TRUE,timeToTrigger:ms320,useAllowedCellList:FALSE}},includeBeamMeasurements:TRUE,
        maxNrofRS-IndexesToReport:8,maxReportCells:8,reportAmount:r1,reportInterval:ms1024,
        reportQuantityCell:{rsrp:TRUE,rsrq:TRUE,sinr:TRUE},reportQuantityRS-Indexes:
        {rsrp:TRUE,rsrq:TRUE,sinr:TRUE},rsType:ssb}}}},reportConfigId:2}]}}"""

measGapConfig_check_if_present_string = """
{measGapConfig:{gapUE:setup{setup:[{gapOffset:0,mgl:ms3,mgrp:ms160,mgta:ms0}]}}
"""

measGapConfig_check_if_present = """
measGapConfig contains
(
    gapUE contains
    (
        setup is present
        and setup contains
        (
            gapOffset is present
            and mgl is present
            and mgrp is present
            and mgta is present
        )
    )
)
"""

remove_meas_gap_config = """
    measConfig contains
     (
        measGapConfig contains
        (
            gapUE contains
             (
                 release is present
             )
        )
    )
"""

buffer_monitoring_activate_dl = """
BufferMonitoringNotification contains
(
    BufferMonitoring eq "activate-dl"
)
"""

buffer_criterion_downlink = """
BufferCriterionNotification contains
(
    BufferCriterion eq "downlink"
)
"""

PUCCH_config_for_5CC_FFFF_CA_in_UE_CON_MOD_RESP_AB5 = PUCCH_config_in_UE_CON_MOD_RESP_after_Reconf_template.format(
    resourceSet1_content=resourceSet1,
    resourceToAddModList_content=resourceToAddModList_4CC_FFFF_AB5,
    resourceToAddModList_length=16)

HO_Information_in_UE_CON_MOD_REQ_template = """
    handoverPreparationInformation contains
    (
        sourceConfig contains
         (
             rrcReconfiguration contains
             (
                 criticalExtensions contains
                 (
                     rrcReconfiguration contains
                     (
                         nonCriticalExtension contains
                         (
                             masterCellGroup contains
                             (
                                 spCellConfig contains
                                 (
                                     reconfigurationWithSync contains
                                     (
                                         spCellConfigCommon contains
                                         (
                                             physCellId eq {pcell_id}
                                         )
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

HO_Information_in_UE_CON_MOD_REQ = HO_Information_in_UE_CON_MOD_REQ_template.format(
    pcell_id=55)
