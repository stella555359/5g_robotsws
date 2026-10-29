selected_SCells_for_5CC_CA_in_UE_CON_MOD_REQ_template = """
        CUtoDURRCInformation contains
        (
            allowedBC-ListMRDC contains
            (
                (bandCombinationIndex eq {bandCombinationIndex})
                and (allowedFeatureSetsList contains (1))
            )
        )
        and
        SCell-ToBeSetupMod-List is present and length(SCell-ToBeSetupMod-List) eq 4
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
        and
        SCell-ToBeSetupMod-List contains
        (
            (sCellIndex eq 4) and (nRCellIdentity eq "{nRCellIdentity_4}") and (sCellULConfigured eq "ul")
        )
        """

selected_SCells_for_5CC_FFTTT_UE_CA_in_UE_CON_MOD_REQ_B3 = selected_SCells_for_5CC_CA_in_UE_CON_MOD_REQ_template.format(
    bandCombinationIndex=1,
    nRCellIdentity_1="0b000000000000000000000100000000000001",
    nRCellIdentity_2="0b000000000000000000000100000000000100",
    nRCellIdentity_3="0b000000000000000000000100000000000101",
    nRCellIdentity_4="0b000000000000000000000100000000000110")

selected_SCells_for_5CC_CA_in_UE_CON_MOD_RESP_template = """
    sCellToAddModList is present and length(sCellToAddModList) eq 4
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
      and sCellToAddModList contains
    (
        sCellIndex eq 4
        and sCellConfigCommon contains (physCellId eq {scell_physcellid_4})
    )
    and SelectedBandCombinationIndex eq "{SelectedBandCombinationIndex}"
    and (SelectedFeatureSetEntryIndex contains ("'00'H"))
    """

selected_SCells_for_5CC_FFTTT_UE_CA_in_UE_CON_MOD_RESP_B3 = \
    selected_SCells_for_5CC_CA_in_UE_CON_MOD_RESP_template.format(
        scell_physcellid_1=51,
        scell_physcellid_2=54,
        scell_physcellid_3=55,
        scell_physcellid_4=56,
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

resourceSet1_5CC_FFTTT = resourceSet1_template.format(
    set_length=2,
    Resource_List=(10, 11),
    maxPayloadSize=12)

resourceToAddModList_template = """
    resourceToAddModList contains {ResourceIdList}
"""

resourceToAddModList_5CC_FFTTT = resourceToAddModList_template.format(
    ResourceIdList=(10, 11, 19, 21, 22, 23, 24, 25, 26))


PUCCH_config_for_5CC_FFTTT_CA_BF_in_UE_CON_MOD_RESP_B3 = fill_PUCCH_config_in_UE_CON_MOD_RESP_template(
    resourceSet1_content=resourceSet1_5CC_FFTTT,
    resourceToAddModList_content=resourceToAddModList_5CC_FFTTT,
    resourceToAddModList_length=9)


# Beamforming
CSI_meas_config_for_5CC_FFTTT_CA_BF_in_UE_CON_MOD_RESP_B3 = """
    csi-MeasConfig contains
    (
        csi-ReportConfigToAddModList is present
        and length(csi-ReportConfigToAddModList) eq 7
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
            and reportQuantity contains (ssb-Index-RSRP is present)
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
            and reportQuantity contains (ssb-Index-RSRP is present)
        )
        and csi-ReportConfigToAddModList contains
        (
            reportConfigId eq 16
            and carrier eq 4
            and reportQuantity contains (cri-RI-PMI-CQI is present)
        )
        and csi-ReportConfigToAddModList contains
        (
            reportConfigId eq 24
            and carrier eq 4
            and reportQuantity contains (ssb-Index-RSRP is present)
        )
    )
    """
# AA_B6c
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
                                reportQuantityCell is present
                                and reportQuantityCell contains
                                (
                                rsrq eq "TRUE"
                                )
                                and eventId contains
                                (
                                    eventA1 contains
                                    (
                                        a1-Threshold contains
                                        (
                                            rsrp is present
                                            and rsrp eq {rsrp_threshold}
                                        )
                                        and hysteresis eq {hysteresis}
                                        and timeToTrigger eq "{timeToTrigger}"
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

A1_measurement_configuration_for_PCell_FDD_AAB6c = \
    A1_measurement_configuration_template.format(
        ssbFrequency=125070,
        freqBandIndicatorNR=71,
        rsrp_threshold=70,
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

PDU_Session_ID_check_for_PCell_FDD_AA_B6c = \
    PDU_Session_ID_check_template.format(
        pdu_Session=3)

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
                    and rsrq eq {rsrq_threshold}
                    )
                )
            )
        )
            )
        )
    )
"""

A1_measurement_PCell_FDD_AAB6c = \
    A1_measurement_report_template.format(
        phys_cell_id=53,
        rsrp_threshold=90,
        rsrq_threshold=50)

measurements_config_for_FFTTT_5CC_CA_in_RRC_Reconfiguration_A2_removal_B7 = """
    measConfig contains
    (
        measObjectToAddModList is present
        and length(measObjectToAddModList) eq 1
        and measObjectToAddModList contains
        (
            measObjectId eq 1
            and
            freqBandIndicatorNR eq 71
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
            measObjectId eq 2
            and
            reportConfigId eq 3
        )
        and measIdToAddModList contains
        (
            measId eq 4
            and
            measObjectId eq 2
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

DRX_Release_After_A2_B7 = """
    nonCriticalExtension contains
    (
        masterCellGroup contains
        (
             cellGroupId eq 0
            and mac-CellGroupConfig contains
            (
                drx-Config contains
                (
                    release contains
                    (
                        "NULL"
                    )
                )
                and skipUplinkTxDynamic eq "FALSE"
            )
        )
    )
"""

DRX_Configuration_for_5CC_FFTTT_UE_CA_in_UE_CON_MOD_REQ_B7 = """
    DRXCycle contains
    (
        longDRXCycleLength eq "ms40"
    )
"""

DRX_Configuration_for_5CC_FFTTT_UE_CA_in_UE_CON_MOD_RES_B7 = """
    DUtoCURRCInformation contains
        (
            CellGroupConfig contains
            (
                mac-CellGroupConfig contains
                (
                    drx-Config contains
                    (
                        drx-onDurationTimer contains (milliSeconds is present and milliSeconds eq "ms10" )
                        and drx-InactivityTimer eq "ms40"
                        and drx-HARQ-RTT-TimerDL eq 0
                        and drx-HARQ-RTT-TimerUL eq 0
                        and drx-RetransmissionTimerDL eq "sl16"
                        and drx-RetransmissionTimerUL eq "sl16"
                        and drx-SlotOffset eq 0
                        and drx-LongCycleStartOffset contains (ms40 is present and ms40 eq 0)
                    )
                )
                and mac-CellGroupConfig contains
                (
                    skipUplinkTxDynamic eq "FALSE"
                )
            )
        )
"""

DRX_Release_for_5CC_FFTTT_UE_CA_in_UE_CON_MOD_RES_B7 = """
    DUtoCURRCInformation contains
        (
            CellGroupConfig contains
            (
                mac-CellGroupConfig contains
                (
                    drx-Config contains
                    (
                        release contains
                        (
                            "NULL"
                        )
                    )
                    and skipUplinkTxDynamic eq "FALSE"
                )
            )
        )
"""

MEAS_GAP_Release_for_5CC_FFTTT_UE_CA_in_RRC_Reconfiguration_B1 = """
    measGapConfig is present
    and measGapConfig contains
    (
        gapUE contains
        (
            release is present
            and release contains ("NULL")
        )
    )
"""

Meas_Config_for_5CC_FFTTT_UE_CA_in_RRC_Reconfiguration_B1 = """
    measConfig contains
    (
        measObjectToRemoveList contains (1,2,3,4,5)
        and measObjectToAddModList contains
        (
            measObjectId eq 6
            and measObject contains
            (
                measObjectNR contains
                (
                    ssbFrequency eq 392410
                    and freqBandIndicatorNR eq 25
                )
            )
        )
        and reportConfigToRemoveList contains (2,3,4)
        and measIdToRemoveList contains (2,3,4)
    )
"""

SCells_To_Remove_for_5CC_FFTTT_UE_CA_in_UE_CONF_MOD_REQ_B1 = """
    protocolIEs contains
    (
        SCell-ToBeRemoved-List contains
        (
            SCell-ToBeRemoved-Item contains
            (
                sCell-ID contains
                (
                    nRCellIdentity eq "0b000000000000000000000100000000000001"
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
    )
"""

HO_Preparation_From_Cell_3_for_5CC_FFTTT_UE_CA_in_UE_CONF_MOD_REQ_B1 = """
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

HO_Performance_To_Cell_1_for_5CC_FFTTT_UE_CA_in_UE_CON_MOD_RES_B1 = """
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

SCells_To_Release_for_5CC_FFTTT_UE_CA_in_RRC_Reconfiguration_B1 = """
    sCellToReleaseList is present
    and sCellToReleaseList contains (1,2,3,4)
"""

selected_SCells_for_5CC_FFTTT_UE_CA_in_UE_CON_MOD_REQ_B1 = selected_SCells_for_5CC_CA_in_UE_CON_MOD_REQ_template.format(
    bandCombinationIndex=1,
    nRCellIdentity_1="0b000000000000000000000100000000000011",
    nRCellIdentity_2="0b000000000000000000000100000000000100",
    nRCellIdentity_3="0b000000000000000000000100000000000101",
    nRCellIdentity_4="0b000000000000000000000100000000000110")

selected_SCells_for_5CC_FFTTT_UE_CA_in_UE_CON_MOD_RESP_B1 = \
    selected_SCells_for_5CC_CA_in_UE_CON_MOD_RESP_template.format(
        scell_physcellid_1=53,
        scell_physcellid_2=54,
        scell_physcellid_3=55,
        scell_physcellid_4=56,
        SelectedBandCombinationIndex="0x0000")
