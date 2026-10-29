A1_measurement_configuration_template = """
    measConfig contains
    (
        measObjectToAddModList contains
        (
            measObjectId eq {meas_object_id}
            and
            freqBandIndicatorNR eq {freq_band_IndicatorNR}
        )
        and reportConfigToAddModList contains
        (
            reportConfigId eq {report_config_id}
            and
            eventId contains (eventA1 is present)
            and
            a1-Threshold contains (rsrp eq {rsrp_threshold})
        )
        and measIdToAddModList contains
        (
            measId eq {meas_id}
            and measObjectId eq {meas_object_id}
            and reportConfigId eq {report_config_id}
        )
    )
    """

A1_measurement_configuration_at_the_UE_during_ICS_for_Scell_Addition = \
    A1_measurement_configuration_template.format(
        meas_object_id=1,
        freq_band_IndicatorNR=66,
        report_config_id=1,
        rsrp_threshold=70,
        meas_id=1)

A1_measurement_report_template = """
    measurementReport contains
    (
        measResults contains
        (
            measId eq {meas_id}
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
                    and rsrq eq {rsrq_threshold}
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
        meas_id=1,
        phys_cell_id=53,
        rsrp_threshold=90,
        rsrq_threshold=95)

selected_SCells_for_sCellToBeSetupModLIst_template = """
        CUtoDURRCInformation contains
        (
            allowedBC-ListMRDC contains
            (
                (bandCombinationIndex eq {bandCombinationIndex})
                and (allowedFeatureSetsList contains ({number_of_feature_sets}))
            )
        )
        and
        SCell-ToBeSetupMod-List is present and length(SCell-ToBeSetupMod-List) eq {number_of_selected_scells}
        {scell_1}
        {scell_2}
        {scell_3}
        {scell_4}
        {scell_5}
        """

SCell_ToBeSetupMod_List_template = """
        and SCell-ToBeSetupMod-List contains
        (
            (sCellIndex eq {scell_index})
            and (nRCellIdentity eq "{nRCellIdentity}")
        )
        """

selected_SCells_for_6CC_4F2T_UE_CA_in_UE_CON_MOD_REQ = selected_SCells_for_sCellToBeSetupModLIst_template.format(
    bandCombinationIndex=1,
    number_of_feature_sets=1,
    number_of_selected_scells=5,
    scell_1=SCell_ToBeSetupMod_List_template.format(scell_index=1,
                                                    nRCellIdentity="0b000000000000000000000100000000000001"),
    scell_2=SCell_ToBeSetupMod_List_template.format(scell_index=2,
                                                    nRCellIdentity="0b000000000000000000000100000000000010"),
    scell_3=SCell_ToBeSetupMod_List_template.format(scell_index=3,
                                                    nRCellIdentity="0b000000000000000000000100000000000100"),
    scell_4=SCell_ToBeSetupMod_List_template.format(scell_index=4,
                                                    nRCellIdentity="0b000000000000000000000100000000000101"),
    scell_5=SCell_ToBeSetupMod_List_template.format(scell_index=5,
                                                    nRCellIdentity="0b000000000000000000000100000000000111"))

selected_SCells_for_sCellToAddModList_template = """
    sCellToAddModList is present and length(sCellToAddModList) eq {number_of_selected_scells}
    {scell_1}
    {scell_2}
    {scell_3}
    {scell_4}
    {scell_5}
    and SelectedBandCombinationIndex eq "{SelectedBandCombinationIndex}"
    and (SelectedFeatureSetEntryIndex contains ("'00'H"))
    """

sCellToAddModList_template = """
    and sCellToAddModList contains
    (
        sCellIndex eq {scell_index}
        and sCellConfigCommon contains (physCellId eq {scell_physcellid})
    )
    """

selected_SCells_for_6CC_4F2T_UE_CA_in_UE_CON_MOD_RESP = \
    selected_SCells_for_sCellToAddModList_template.format(
        number_of_selected_scells=5,
        scell_1=sCellToAddModList_template.format(scell_index=1, scell_physcellid=51),
        scell_2=sCellToAddModList_template.format(scell_index=2, scell_physcellid=52),
        scell_3=sCellToAddModList_template.format(scell_index=3, scell_physcellid=54),
        scell_4=sCellToAddModList_template.format(scell_index=4, scell_physcellid=55),
        scell_5=sCellToAddModList_template.format(scell_index=5, scell_physcellid=57),
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

resourceSet1_6CC_4F2T = resourceSet1_template.format(
    set_length=2,
    Resource_List=(10, 11),
    maxPayloadSize=12)

resourceToAddModList_template = """
    resourceToAddModList contains {ResourceIdList}
"""

resourceToAddModList_6CC_4F2T = resourceToAddModList_template.format(
    ResourceIdList=(10, 11, 19, 21, 23, 25, 26, 27, 28))

PUCCH_config_for_6CC_4F2T_CA_in_UE_CON_MOD_RESP = fill_PUCCH_config_in_UE_CON_MOD_RESP_template(
    resourceSet1_content=resourceSet1_6CC_4F2T,
    resourceToAddModList_content=resourceToAddModList_6CC_4F2T,
    resourceToAddModList_length=9)

csi_ReportConfigToAddModList_template = """
        and csi-ReportConfigToAddModList contains
        (
            reportConfigId eq {report_config_id}
            and carrier eq {carrier}
            and pucch-Resource eq {pucch_resource}
            and reportQuantity contains ({report_quantity_value} is present)
        )
    """


def fill_csiReportConfig_element(template=csi_ReportConfigToAddModList_template, report_config_ID=None,
                                 carrier=None, pucch_resource=None, report_quantity_value=None):
    return template.format(report_config_id=report_config_ID, carrier=carrier,
                           pucch_resource=pucch_resource, report_quantity_value=report_quantity_value)


csi_MeasConfig_for_csi_ReportConfigToAddModList_template = """
    csi-MeasConfig contains
    (
        csi-ReportConfigToAddModList is present
        and length(csi-ReportConfigToAddModList) eq {number_of_csi_report_configs}
        {csi_ReportConfig}
    )
    """

csi_ReportConfigToAddModList_6CC_4F_2T = [
    {"report_config_ID": 13, "carrier": 1, "pucch_resource": 19, "report_quantity_value": "cri-RI-PMI-CQI"},
    {"report_config_ID": 14, "carrier": 2, "pucch_resource": 21, "report_quantity_value": "cri-RI-PMI-CQI"},
    {"report_config_ID": 15, "carrier": 3, "pucch_resource": 23, "report_quantity_value": "cri-RI-PMI-CQI"},
    {"report_config_ID": 16, "carrier": 4, "pucch_resource": 25, "report_quantity_value": "cri-RI-PMI-CQI"},
    {"report_config_ID": 24, "carrier": 4, "pucch_resource": 26, "report_quantity_value": "ssb-Index-RSRP"},
    {"report_config_ID": 17, "carrier": 5, "pucch_resource": 27, "report_quantity_value": "cri-RI-PMI-CQI"},
    {"report_config_ID": 25, "carrier": 5, "pucch_resource": 28, "report_quantity_value": "ssb-Index-RSRP"}
]


def generate_csi_MeasConfig(csi_ReportConfigToAddModList):
    csi_ReportConfig_list = []
    for report_config in csi_ReportConfigToAddModList:
        csi_ReportConfig = fill_csiReportConfig_element(
            report_config_ID=report_config["report_config_ID"],
            carrier=report_config["carrier"],
            pucch_resource=report_config["pucch_resource"],
            report_quantity_value=report_config["report_quantity_value"]
        )
        csi_ReportConfig_list.append(csi_ReportConfig)

    csi_MeasConfig = csi_MeasConfig_for_csi_ReportConfigToAddModList_template.format(
        number_of_csi_report_configs=len(csi_ReportConfig_list),
        csi_ReportConfig="\n".join(csi_ReportConfig_list)
    )
    return csi_MeasConfig


csi_MeasConfig_for_6CC_4F2T_CA_in_UE_CON_MOD_RESP = generate_csi_MeasConfig(csi_ReportConfigToAddModList_6CC_4F_2T)

selected_SCells_for_6CC_3F3T_UE1_BB1_CA_in_UE_CON_MOD_REQ = selected_SCells_for_sCellToBeSetupModLIst_template.format(
    bandCombinationIndex=1,
    number_of_feature_sets=1,
    number_of_selected_scells=5,
    scell_1=SCell_ToBeSetupMod_List_template.format(scell_index=1,
                                                    nRCellIdentity="0b000000000000000000000100000000000001"),
    scell_2=SCell_ToBeSetupMod_List_template.format(scell_index=2,
                                                    nRCellIdentity="0b000000000000000000000100000000000100"),
    scell_3=SCell_ToBeSetupMod_List_template.format(scell_index=3,
                                                    nRCellIdentity="0b000000000000000000000100000000000101"),
    scell_4=SCell_ToBeSetupMod_List_template.format(scell_index=4,
                                                    nRCellIdentity="0b000000000000000000000100000000000110"),
    scell_5=SCell_ToBeSetupMod_List_template.format(scell_index=5,
                                                    nRCellIdentity="0b000000000000000000000100000000000111"))

selected_SCells_for_6CC_3F3T_UE2_BB1_CA_in_UE_CON_MOD_REQ = selected_SCells_for_sCellToBeSetupModLIst_template.format(
    bandCombinationIndex=1,
    number_of_feature_sets=1,
    number_of_selected_scells=5,
    scell_1=SCell_ToBeSetupMod_List_template.format(scell_index=1,
                                                    nRCellIdentity="0b000000000000000000000100000000000001"),
    scell_2=SCell_ToBeSetupMod_List_template.format(scell_index=2,
                                                    nRCellIdentity="0b000000000000000000000100000000000011"),
    scell_3=SCell_ToBeSetupMod_List_template.format(scell_index=3,
                                                    nRCellIdentity="0b000000000000000000000100000000000101"),
    scell_4=SCell_ToBeSetupMod_List_template.format(scell_index=4,
                                                    nRCellIdentity="0b000000000000000000000100000000000110"),
    scell_5=SCell_ToBeSetupMod_List_template.format(scell_index=5,
                                                    nRCellIdentity="0b000000000000000000000100000000000111"))

selected_SCells_for_6CC_4F2T_UE3_BB1_CA_in_UE_CON_MOD_REQ = selected_SCells_for_sCellToBeSetupModLIst_template.format(
    bandCombinationIndex=1,
    number_of_feature_sets=1,
    number_of_selected_scells=5,
    scell_1=SCell_ToBeSetupMod_List_template.format(scell_index=1,
                                                    nRCellIdentity="0b000000000000000000000100000000000001"),
    scell_2=SCell_ToBeSetupMod_List_template.format(scell_index=2,
                                                    nRCellIdentity="0b000000000000000000000100000000000011"),
    scell_3=SCell_ToBeSetupMod_List_template.format(scell_index=3,
                                                    nRCellIdentity="0b000000000000000000000100000000000100"),
    scell_4=SCell_ToBeSetupMod_List_template.format(scell_index=4,
                                                    nRCellIdentity="0b000000000000000000000100000000000101"),
    scell_5=SCell_ToBeSetupMod_List_template.format(scell_index=5,
                                                    nRCellIdentity="0b000000000000000000000100000000000111"))

selected_SCells_for_6CC_4F2T_UE4_BB1_CA_in_UE_CON_MOD_REQ = selected_SCells_for_sCellToBeSetupModLIst_template.format(
    bandCombinationIndex=1,
    number_of_feature_sets=1,
    number_of_selected_scells=5,
    scell_1=SCell_ToBeSetupMod_List_template.format(scell_index=1,
                                                    nRCellIdentity="0b000000000000000000000100000000000001"),
    scell_2=SCell_ToBeSetupMod_List_template.format(scell_index=2,
                                                    nRCellIdentity="0b000000000000000000000100000000000011"),
    scell_3=SCell_ToBeSetupMod_List_template.format(scell_index=3,
                                                    nRCellIdentity="0b000000000000000000000100000000000100"),
    scell_4=SCell_ToBeSetupMod_List_template.format(scell_index=4,
                                                    nRCellIdentity="0b000000000000000000000100000000000101"),
    scell_5=SCell_ToBeSetupMod_List_template.format(scell_index=5,
                                                    nRCellIdentity="0b000000000000000000000100000000000110"))

selected_SCells_for_4CC_4F_UE5_UE6_BB1_CA_in_UE_CON_MOD_REQ = selected_SCells_for_sCellToBeSetupModLIst_template.format(
    bandCombinationIndex=1,
    number_of_feature_sets=1,
    number_of_selected_scells=3,
    scell_1=SCell_ToBeSetupMod_List_template.format(scell_index=1,
                                                    nRCellIdentity="0b000000000000000000000100000000000001"),
    scell_2=SCell_ToBeSetupMod_List_template.format(scell_index=2,
                                                    nRCellIdentity="0b000000000000000000000100000000000011"),
    scell_3=SCell_ToBeSetupMod_List_template.format(scell_index=3,
                                                    nRCellIdentity="0b000000000000000000000100000000000100"),
    scell_4="",
    scell_5="")

selected_SCells_for_6CC_3F3T_UE1_BB1_CA_in_UE_CON_MOD_RESP = \
    selected_SCells_for_sCellToAddModList_template.format(
        number_of_selected_scells=5,
        scell_1=sCellToAddModList_template.format(scell_index=1, scell_physcellid=51),
        scell_2=sCellToAddModList_template.format(scell_index=2, scell_physcellid=54),
        scell_3=sCellToAddModList_template.format(scell_index=3, scell_physcellid=55),
        scell_4=sCellToAddModList_template.format(scell_index=4, scell_physcellid=56),
        scell_5=sCellToAddModList_template.format(scell_index=5, scell_physcellid=57),
        SelectedBandCombinationIndex="0x0000")

selected_SCells_for_6CC_3F3T_UE2_BB1_CA_in_UE_CON_MOD_RESP = \
    selected_SCells_for_sCellToAddModList_template.format(
        number_of_selected_scells=5,
        scell_1=sCellToAddModList_template.format(scell_index=1, scell_physcellid=51),
        scell_2=sCellToAddModList_template.format(scell_index=2, scell_physcellid=53),
        scell_3=sCellToAddModList_template.format(scell_index=3, scell_physcellid=55),
        scell_4=sCellToAddModList_template.format(scell_index=4, scell_physcellid=56),
        scell_5=sCellToAddModList_template.format(scell_index=5, scell_physcellid=57),
        SelectedBandCombinationIndex="0x0000")

selected_SCells_for_6CC_4F2T_UE3_BB1_CA_in_UE_CON_MOD_RESP = \
    selected_SCells_for_sCellToAddModList_template.format(
        number_of_selected_scells=5,
        scell_1=sCellToAddModList_template.format(scell_index=1, scell_physcellid=51),
        scell_2=sCellToAddModList_template.format(scell_index=2, scell_physcellid=53),
        scell_3=sCellToAddModList_template.format(scell_index=3, scell_physcellid=54),
        scell_4=sCellToAddModList_template.format(scell_index=4, scell_physcellid=55),
        scell_5=sCellToAddModList_template.format(scell_index=5, scell_physcellid=57),
        SelectedBandCombinationIndex="0x0000")

selected_SCells_for_6CC_4F2T_UE4_BB1_CA_in_UE_CON_MOD_RESP = \
    selected_SCells_for_sCellToAddModList_template.format(
        number_of_selected_scells=5,
        scell_1=sCellToAddModList_template.format(scell_index=1, scell_physcellid=51),
        scell_2=sCellToAddModList_template.format(scell_index=2, scell_physcellid=53),
        scell_3=sCellToAddModList_template.format(scell_index=3, scell_physcellid=54),
        scell_4=sCellToAddModList_template.format(scell_index=4, scell_physcellid=55),
        scell_5=sCellToAddModList_template.format(scell_index=5, scell_physcellid=56),
        SelectedBandCombinationIndex="0x0000")

selected_SCells_for_4CC_4F_UE5_UE6_BB1_CA_in_UE_CON_MOD_RESP = \
    selected_SCells_for_sCellToAddModList_template.format(
        number_of_selected_scells=3,
        scell_1=sCellToAddModList_template.format(scell_index=1, scell_physcellid=51),
        scell_2=sCellToAddModList_template.format(scell_index=2, scell_physcellid=53),
        scell_3=sCellToAddModList_template.format(scell_index=3, scell_physcellid=54),
        scell_4=" ",
        scell_5=" ",
        SelectedBandCombinationIndex="0x0000")

resourceSet1_4CC_4F = resourceSet1_template.format(
    set_length=2,
    Resource_List=(10, 11),
    maxPayloadSize=8)

resourceSet1_6CC_3F3T = resourceSet1_template.format(
    set_length=2,
    Resource_List=(10, 11),
    maxPayloadSize=12)

resourceToAddModList_4CC_4F = resourceToAddModList_template.format(
    ResourceIdList=(10, 11, 19, 21, 23))

resourceToAddModList_6CC_3F3T = resourceToAddModList_template.format(
    ResourceIdList=(10, 11, 19, 21, 23, 24, 25, 26, 27, 28))

PUCCH_config_for_4CC_4F_CA_in_UE_CON_MOD_RESP = fill_PUCCH_config_in_UE_CON_MOD_RESP_template(
    resourceSet1_content=resourceSet1_4CC_4F,
    resourceToAddModList_content=resourceToAddModList_4CC_4F,
    resourceToAddModList_length=5)

PUCCH_config_for_6CC_3F3T_CA_in_UE_CON_MOD_RESP = fill_PUCCH_config_in_UE_CON_MOD_RESP_template(
    resourceSet1_content=resourceSet1_6CC_4F2T,
    resourceToAddModList_content=resourceToAddModList_6CC_3F3T,
    resourceToAddModList_length=10)

csi_ReportConfigToAddModList_4CC_4F = [
    {"report_config_ID": 13, "carrier": 1, "pucch_resource": 19, "report_quantity_value": "cri-RI-PMI-CQI"},
    {"report_config_ID": 14, "carrier": 2, "pucch_resource": 21, "report_quantity_value": "cri-RI-PMI-CQI"},
    {"report_config_ID": 15, "carrier": 3, "pucch_resource": 23, "report_quantity_value": "cri-RI-PMI-CQI"}
]

csi_ReportConfigToAddModList_6CC_3F_3T = [
    {"report_config_ID": 13, "carrier": 1, "pucch_resource": 19, "report_quantity_value": "cri-RI-PMI-CQI"},
    {"report_config_ID": 14, "carrier": 2, "pucch_resource": 21, "report_quantity_value": "cri-RI-PMI-CQI"},
    {"report_config_ID": 15, "carrier": 3, "pucch_resource": 23, "report_quantity_value": "cri-RI-PMI-CQI"},
    {"report_config_ID": 23, "carrier": 3, "pucch_resource": 24, "report_quantity_value": "ssb-Index-RSRP"},
    {"report_config_ID": 16, "carrier": 4, "pucch_resource": 25, "report_quantity_value": "cri-RI-PMI-CQI"},
    {"report_config_ID": 24, "carrier": 4, "pucch_resource": 26, "report_quantity_value": "ssb-Index-RSRP"},
    {"report_config_ID": 17, "carrier": 5, "pucch_resource": 27, "report_quantity_value": "cri-RI-PMI-CQI"},
    {"report_config_ID": 25, "carrier": 5, "pucch_resource": 28, "report_quantity_value": "ssb-Index-RSRP"}
]

csi_MeasConfig_for_6CC_3F3T_CA_in_UE_CON_MOD_RESP = generate_csi_MeasConfig(csi_ReportConfigToAddModList_6CC_3F_3T)
csi_MeasConfig_for_4CC_4F_CA_in_UE_CON_MOD_RESP = generate_csi_MeasConfig(csi_ReportConfigToAddModList_4CC_4F)

measurements_config_for_FFFTTT_6CC_CA_in_RRC_Reconfiguration_A2_removal_AB16 = """
    measConfig contains
    (
        measObjectToAddModList is present
        and length(measObjectToAddModList) eq 2
        and measObjectToAddModList contains
        (
            measObjectId eq 1
            and
            freqBandIndicatorNR eq 66
        )
        and
        reportConfigToRemoveList is present
        and length(reportConfigToRemoveList) eq 1
        and reportConfigToRemoveList contains
        (
            1
        )
        and
        reportConfigToAddModList is present
        and length(reportConfigToAddModList) eq 3
        and reportConfigToAddModList contains
        (
            reportConfigId eq 2
            and
            eventId contains (eventA1 is present)
        )
         and reportConfigToAddModList contains
        (
            reportConfigId eq 3
            and
            eventId contains (eventA3 is present)
        )
        and reportConfigToAddModList contains
        (
            reportConfigId eq 4
            and
            eventId contains (eventA5 is present)
        )
        and
        measIdToRemoveList contains
        (
            1
        )
        and
        measIdToAddModList is present
        and length(measIdToAddModList) eq 3
        and measIdToAddModList contains
        (
            measId eq 2
            and
            measObjectId eq 1
            and
            reportConfigId eq 2
        )
        and measIdToAddModList contains
        (
            measId eq 3
            and
            measObjectId eq 7
            and
            reportConfigId eq 3
        )
        and measIdToAddModList contains
        (
            measId eq 4
            and
            measObjectId eq 7
            and
            reportConfigId eq 4
        )
        and measGapConfig contains
        (
            gapUE contains
            (
                setup is present
                and setup contains
                (
                    gapOffset eq 0
                    and mgl eq "ms3"
                    and mgrp eq "ms160"
                    and mgta eq "ms0"
                )
            )
        )
    )
"""

Meas_Config_for_6CC_FFFTTT_UE_CA_in_RRC_Reconfiguration_AB16 = """
    measConfig contains
    (
        measObjectToRemoveList contains (1,2,3,4,5,6)
        and measObjectToAddModList contains
        (
            measObjectId eq 7
            and measObject contains
            (
                measObjectNR contains
                (
                    ssbFrequency eq 389570
                    and freqBandIndicatorNR eq 25
                )
            )
        )
        and reportConfigToRemoveList contains (2,3,4)
        and measIdToRemoveList contains (2,3,4)
    )
"""

SCells_To_Remove_for_6CC_FFFTTT_UE_CA_in_UE_CONF_MOD_REQ_AB16 = """
    protocolIEs contains
    (
        SCell-ToBeRemoved-List contains
        (
            SCell-ToBeRemoved-Item contains
            (
                sCell-ID contains
                (
                    nRCellIdentity eq "0b000000000000000000000100000000000010"
                )
            )
        )
        and SCell-ToBeRemoved-List contains
        (
            SCell-ToBeRemoved-Item contains
            (
                sCell-ID contains
                (
                    nRCellIdentity eq "0b000000000000000000000100000000000100"
                )
            )
        )
        and SCell-ToBeRemoved-List contains
        (
            SCell-ToBeRemoved-Item contains
            (
                sCell-ID contains
                (
                    nRCellIdentity eq "0b000000000000000000000100000000000101"
                )
            )
        )
        and SCell-ToBeRemoved-List contains
        (
            SCell-ToBeRemoved-Item contains
            (
                sCell-ID contains
                (
                    nRCellIdentity eq "0b000000000000000000000100000000000110"
                )
            )
        )
        and SCell-ToBeRemoved-List contains
        (
            SCell-ToBeRemoved-Item contains
            (
                sCell-ID contains
                (
                    nRCellIdentity eq "0b000000000000000000000100000000000111"
                )
            )
        )
    )
"""

HO_Preparation_From_Cell_3_for_6CC_FFFTTT_UE_CA_in_UE_CONF_MOD_REQ_AB16 = """
    HandoverPreparationInformation contains
    (
        handoverPreparationInformation contains
        (
            rrcReconfiguration contains
            (
                nonCriticalExtension contains
                (
                    spCellConfig contains
                    (
                        reconfigurationWithSync contains
                        (
                            spCellConfigCommon contains
                            (
                                physCellId eq 53
                            )
                        )
                    )
                )
            )
        )
    )
"""

HO_Performance_To_Cell_1_for_6CC_FFFTTT_UE_CA_in_UE_CON_MOD_RES_AB16 = """
    CellGroupConfig is present and CellGroupConfig contains
    (
        spCellConfig is present and spCellConfig contains
        (
            spCellConfigCommon is present and spCellConfigCommon contains
            (
                physCellId eq 51
            )
        )
    )
"""

SCells_To_Release_for_6CC_FFFTTT_UE_CA_in_RRC_Reconfiguration_AB16 = """
    sCellToReleaseList is present
    and sCellToReleaseList contains (1,2,3,4,5)
"""

A1_measurement_configuration_for_PCell_FDD_AB15 = \
    A1_measurement_configuration_template.format(
        meas_object_id=1,
        freq_band_IndicatorNR=66,
        report_config_id=1,
        rsrp_threshold=70,
        meas_id=1)

selected_SCells_for_6CC_3F3T_UE3_AB15_CA_in_UE_CON_MOD_REQ = selected_SCells_for_sCellToBeSetupModLIst_template.format(
    bandCombinationIndex=2,
    number_of_feature_sets=1,
    number_of_selected_scells=5,
    scell_1=SCell_ToBeSetupMod_List_template.format(scell_index=1,
                                                    nRCellIdentity="0b000000000000000000000100000000000010"),
    scell_2=SCell_ToBeSetupMod_List_template.format(scell_index=2,
                                                    nRCellIdentity="0b000000000000000000000100000000000100"),
    scell_3=SCell_ToBeSetupMod_List_template.format(scell_index=3,
                                                    nRCellIdentity="0b000000000000000000000100000000000101"),
    scell_4=SCell_ToBeSetupMod_List_template.format(scell_index=4,
                                                    nRCellIdentity="0b000000000000000000000100000000000110"),
    scell_5=SCell_ToBeSetupMod_List_template.format(scell_index=5,
                                                    nRCellIdentity="0b000000000000000000000100000000000111"))

selected_SCells_for_6CC_3F3T_UE3_AB15_CA_in_UE_CON_MOD_RESP = \
    selected_SCells_for_sCellToAddModList_template.format(
        number_of_selected_scells=5,
        scell_1=sCellToAddModList_template.format(scell_index=1, scell_physcellid=52),
        scell_2=sCellToAddModList_template.format(scell_index=2, scell_physcellid=54),
        scell_3=sCellToAddModList_template.format(scell_index=3, scell_physcellid=55),
        scell_4=sCellToAddModList_template.format(scell_index=4, scell_physcellid=56),
        scell_5=sCellToAddModList_template.format(scell_index=5, scell_physcellid=57),
        SelectedBandCombinationIndex="0x0001")

A1_measurementReport_in_UL_DCCH_Message_for_PCell_Change = """
    measurementReport contains
    (
        measResults contains
        (
            measId eq 3
            and measResultServingMOList contains
            (
                servCellId eq 0
                and measResultServingCell contains
                (
                    physCellId eq 53
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
                                rsrp eq 9
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
                    physCellId eq 54
                    and measResult contains
                    (
                        cellResults contains
                        (
                            resultsSSB-Cell contains
                            (
                                rsrp eq 9
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
                    physCellId eq 55
                    and measResult contains
                    (
                        cellResults contains
                        (
                            resultsSSB-Cell contains
                            (
                                rsrp eq 9
                            )
                        )
                    )
                )
            )
            and measResultServingMOList contains
            (
                servCellId eq 4
                and measResultServingCell contains
                (
                    physCellId eq 56
                    and measResult contains
                    (
                        cellResults contains
                        (
                            resultsSSB-Cell contains
                            (
                                rsrp eq 95
                            )
                        )
                    )
                )
            )
            and measResultServingMOList contains
            (
                servCellId eq 5
                and measResultServingCell contains
                (
                    physCellId eq 57
                    and measResult contains
                    (
                        cellResults contains
                        (
                            resultsSSB-Cell contains
                            (
                                rsrp eq 9
                            )
                        )
                    )
                )
            )
        )
    )
"""

spCellConfig_in_UE_CON_MOD_RESP_AB15 = """
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
                        physCellId eq 56
                    )
                )
                and csi-MeasConfig contains
                (
                    csi-ReportConfigToReleaseList is present
                    and length(csi-ReportConfigToReleaseList) eq 9
                    and csi-ReportConfigToReleaseList contains (0, 13, 14, 15, 23, 16, 24, 17, 25)
                )
            )
            and sCellToReleaseList is present
            and length(sCellToReleaseList) eq 5
            and sCellToReleaseList contains (1,2,3,4,5)
        )
    )
"""

meas_config_in_RRC_Reconf_3F3T_AB15 = """
    measConfig contains
    (
        measObjectToRemoveList contains (1,2,3,4,6)
        and measObjectToAddModList contains
        (
            measObjectId eq 5
            and
            freqBandIndicatorNR eq 77
        )
        and reportConfigToRemoveList contains (2)
        and measIdToRemoveList contains (2,3,4)
    )
    """

nonCriticalExtension_in_RRC_Reconf_3F3T_AB15 = """
    sCellToReleaseList is present
    and sCellToReleaseList contains (1,2,3,4,5)
"""

selected_SCells_for_6CC_3T3F_UE_CA_in_UE_CON_MOD_REQ_after_HO = \
    selected_SCells_for_sCellToBeSetupModLIst_template.format(
        bandCombinationIndex=2,
        number_of_feature_sets=1,
        number_of_selected_scells=5,
        scell_1=SCell_ToBeSetupMod_List_template.format(scell_index=1,
                                                        nRCellIdentity="0b000000000000000000000100000000000010"),
        scell_2=SCell_ToBeSetupMod_List_template.format(scell_index=2,
                                                        nRCellIdentity="0b000000000000000000000100000000000011"),
        scell_3=SCell_ToBeSetupMod_List_template.format(scell_index=3,
                                                        nRCellIdentity="0b000000000000000000000100000000000100"),
        scell_4=SCell_ToBeSetupMod_List_template.format(scell_index=4,
                                                        nRCellIdentity="0b000000000000000000000100000000000101"),
        scell_5=SCell_ToBeSetupMod_List_template.format(scell_index=5,
                                                        nRCellIdentity="0b000000000000000000000100000000000111"))

selected_SCells_for_6CC_3T3F_UE_CA_in_UE_CON_MOD_RESP_after_HO = \
    selected_SCells_for_sCellToAddModList_template.format(
        number_of_selected_scells=5,
        scell_1=sCellToAddModList_template.format(scell_index=1, scell_physcellid=52),
        scell_2=sCellToAddModList_template.format(scell_index=2, scell_physcellid=53),
        scell_3=sCellToAddModList_template.format(scell_index=3, scell_physcellid=54),
        scell_4=sCellToAddModList_template.format(scell_index=4, scell_physcellid=55),
        scell_5=sCellToAddModList_template.format(scell_index=5, scell_physcellid=57),
        SelectedBandCombinationIndex="0x0001")
