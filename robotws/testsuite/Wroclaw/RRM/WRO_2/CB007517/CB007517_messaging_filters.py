from testsuite.Wroclaw.RRM.WRO_2.resources.NSA_messaging_filters import RRC_Reconfiguration_Complete

RRCReconfCmp_in_SgnbModConf = f"""
    (MeNBtoSgNBContainer contains
        {RRC_Reconfiguration_Complete}
    )
    """


def get_filter_for_A4_measurements_configuration_in_SgNBModReq(report_config_id, meas_id_to_add_mod_list):
    filled_A4_measurements_configuration_in_SgNBModReq = f"""
        (SgNBtoMeNBContainer contains
            (CG-Config contains
                (scg-CellGroupConfig contains
                    (rrcReconfiguration contains
                        (measConfig contains
                            (measObjectToAddModList contains
                                (measObjectId eq 2
                                and measObject contains
                                    (measObjectNR contains
                                        ((ssbFrequency eq 2043739) and (freqBandIndicatorNR eq 258))
                                    )
                                )
                            and measObjectToAddModList contains
                                (measObjectId eq 3
                                and measObject contains
                                    (measObjectNR contains
                                        ((ssbFrequency eq 2079163) and (freqBandIndicatorNR eq 257))
                                    )
                                )
                            )
                        and measConfig contains
                            (reportConfigToAddModList contains
                                (reportConfigId eq {report_config_id}
                                and reportConfig contains
                                    (eventA4 is present
                                    and (a4-Threshold contains (rsrp eq 34))
                                    and (hysteresis eq 0)
                                    and (timeToTrigger eq "ms40")
                                    )
                                )
                            )
                        and measConfig contains
                            {meas_id_to_add_mod_list}
                        )
                        and measGapConfig is not present
                    )
                )
            )
        )
        """
    return filled_A4_measurements_configuration_in_SgNBModReq


def get_filter_for_A4_measurements_reconfiguration_in_SgNBModReq(meas_id_to_add_mod_list):
    filled_A4_measurements_reconfiguration_in_SgNBModReq = f"""
       (SgNBtoMeNBContainer contains
           (CG-Config contains
               (scg-CellGroupConfig contains
                   (rrcReconfiguration contains
                       (measConfig contains
                           {meas_id_to_add_mod_list}
                       and (measObjectToAddModList is not present)
                       and (reportConfigToAddModList is not present)
                       )
                       and measGapConfig is not present
                   )
               )
           )
       )
       """
    return filled_A4_measurements_reconfiguration_in_SgNBModReq


def get_filter_for_UEContextModificationResponse(content):
    UEContextModificationResponse = f"""
    (DUtoCURRCInformation contains
        (CellGroupConfig contains
            {content}
        )
    )
    """
    return UEContextModificationResponse


def get_measConfigSN(frequencies):
    assert len(frequencies) == 2  # temporary constraint
    meas_frequencies = f"""
                CG-Config contains
                    (measConfigSN contains
                        (measuredFrequenciesSN contains
                            (measuredFrequency eq {frequencies[0]})
                        and measuredFrequenciesSN contains
                            (measuredFrequency eq {frequencies[1]})
                        and length(measuredFrequenciesSN) eq {len(frequencies)}
                        )
                    )
    """
    return meas_frequencies


def get_filter_for_A2_measurement_configuration_in_SgNBAddReqAck(a2_threshold):
    A2_measurement_configuration_in_SgNBAddReqAck = f"""
        (SgNBtoMeNBContainer contains
            (CG-Config contains
                (scg-CellGroupConfig contains
                    (rrcReconfiguration contains
                        (measConfig contains
                            (measObjectToAddModList contains
                                (measObjectId eq 1
                                and measObject contains
                                    (measObjectNR contains
                                        ((ssbFrequency eq 636576)
                                        and (freqBandIndicatorNR eq 78))
                                    )
                                )
                            )
                        and measConfig contains
                            (reportConfigToAddModList contains
                                (reportConfigId eq 1
                                and reportConfig contains
                                    (eventA2 is present
                                    and (a2-Threshold contains ({a2_threshold[0]} eq {a2_threshold[1]}))
                                    and (hysteresis eq 0)
                                    and (timeToTrigger eq "ms480")
                                    )
                                )
                            )
                        and measConfig contains
                            (measIdToAddModList contains
                                (
                                    (measId eq 1)
                                    and (measObjectId eq 1)
                                    and (reportConfigId eq 1)
                                )
                            )
                        )
                        and measGapConfig is not present
                    )
                )
            )
        )
        """
    return A2_measurement_configuration_in_SgNBAddReqAck


# for test CB007517-A_B1
report_config_id_B1 = "1"
meas_id_to_add_mod_list_B1 = """(measIdToAddModList contains
            (
                (measId eq 1)
                and (measObjectId eq 2)
                and (reportConfigId eq 1)
            )
        and measIdToAddModList contains
            (
                (measId eq 2)
                and (measObjectId eq 3)
                and (reportConfigId eq 1)
            )
        )
"""
A4_measurements_configuration_in_SgNBModReq = get_filter_for_A4_measurements_configuration_in_SgNBModReq(
    report_config_id=report_config_id_B1, meas_id_to_add_mod_list=meas_id_to_add_mod_list_B1)

# for test CB007517-A_B4
report_config_id_B4 = "2"
meas_id_to_add_mod_list_B4 = """(measIdToAddModList contains
            (
                (measId eq 1)
                and (measObjectId eq 1)
                and (reportConfigId eq 1)
            )
            and measIdToAddModList contains
            (
                (measId eq 2)
                and (measObjectId eq 2)
                and (reportConfigId eq 2)
            )
            and measIdToAddModList contains
            (
                (measId eq 3)
                and (measObjectId eq 3)
                and (reportConfigId eq 2)
            )
        )
"""
A4_measurements_configuration_in_SgNBModReq_B4 = get_filter_for_A4_measurements_configuration_in_SgNBModReq(
    report_config_id=report_config_id_B4, meas_id_to_add_mod_list=meas_id_to_add_mod_list_B4)

A4_measurements_reconfiguration_in_SgNBModReq_B4 = get_filter_for_A4_measurements_reconfiguration_in_SgNBModReq(
    meas_id_to_add_mod_list_B4)

A2_measurement_threshold_B4 = ("rsrp", 90)
A2_measurements_configuration_in_SgNBAddReqAck = get_filter_for_A2_measurement_configuration_in_SgNBAddReqAck(
    A2_measurement_threshold_B4)

A4_measurements_deconfiguration_in_SgNBModReq = f"""
   (SgNBtoMeNBContainer contains
       (CG-Config contains
           (scg-CellGroupConfig contains
               (rrcReconfiguration contains
                   (measConfig contains
                       (
                       measIdToRemoveList contains (2,3)
                       and length(measIdToRemoveList) eq 2
                       )
                   and measConfig contains
                       (measIdToAddModList contains
                           (
                               (measId eq 1)
                               and (measObjectId eq 1)
                               and (reportConfigId eq 1)
                           )
                       )
                   and (measObjectToRemoveList is not present)
                   and (reportConfigToRemoveList is not present)
                   )
                   and measGapConfig is not present
               )
           )
       )
   )
   """

# for test CB007517-A_B14
A2_measurement_threshold_B14 = ("rsrp", 34)
A2_measurement_configuration_in_SgNBAddReqAck_B14 = get_filter_for_A2_measurement_configuration_in_SgNBAddReqAck(
    A2_measurement_threshold_B14)

report_config_id_B14 = "2"
meas_id_to_add_mod_list_B14 = """
        (measIdToAddModList contains
            (
                (measId eq 1)
                and (measObjectId eq 1)
                and (reportConfigId eq 1)
            )
            and measIdToAddModList contains
            (
                (measId eq 2)
                and (measObjectId eq 2)
                and (reportConfigId eq 2)
            )
        )
"""

target_cell_rsrp = 50
target_cell_hysteresis = 10
meas_id_to_add_mod_list_B14_target = """
        (measIdToAddModList contains
            (
                (measId eq 3)
                and (measObjectId eq 3)
                and (reportConfigId eq 1)
            )
            and measIdToAddModList contains
            (
                (measId eq 1)
                and (measObjectId eq 1)
                and (reportConfigId eq 2)
            )
        )
    """

DRX_setup_in_UEContextModReq_B14 = """
(DRXCycle contains
    (longDRXCycleLength eq "ms40")
)
"""

DRX_config_B14 = """
        (mac-CellGroupConfig contains
            (drx-Config contains (setup is present)
            and drx-Config contains
                (drx-onDurationTimer is present
                and drx-onDurationTimer contains
                    (milliSeconds is present
                    and milliSeconds eq "ms10"
                    )
                )
            and drx-Config contains
                (drx-InactivityTimer eq "ms40"
                and drx-RetransmissionTimerDL eq "sl16"
                and drx-RetransmissionTimerUL eq "sl16"
                )
            and drx-Config contains
                (drx-LongCycleStartOffset is present
                and drx-LongCycleStartOffset contains
                    (ms40 is present)
                )
            )
        )
"""

DRX_setup_in_UEContextModResp_B14 = get_filter_for_UEContextModificationResponse(DRX_config_B14)

DRX_setup_in_SgNBModificationRequired_B14 = f"""
(SgNBtoMeNBContainer contains
    (CG-Config contains
        (scg-CellGroupConfig contains
            (rrcReconfiguration contains
                (secondaryCellGroup contains
                    {DRX_config_B14}
                )
            )
        )
    )
)
"""

measurement_report_in_UEContextModReq_B14 = """
(measResultNeighCellListNR contains
    (physCellId eq 51
    and measResult contains
        (cellResults contains
            (resultsSSB-Cell contains
                (rsrp eq 40)
            )
        )
    )
)
"""

measurements_reconfiguration_in_SgNBModRequired = """
(value contains
    (Cause contains
        (radioNetwork eq "handover-desirable-for-radio-reasons")
    )
and SgNBtoMeNBContainer contains
    (CG-Config contains
        (scg-CellGroupConfig contains
            (rrcReconfiguration contains
                (measConfig contains
                    (measIdToAddModList contains
                        (measObjectId eq 3
                        and reportConfigId eq 1
                        and measId eq 3
                        )
                    and measObjectToAddModList contains
                        (measObjectId eq 3
                        and measObject contains
                            (measObjectNR contains
                                (ssbFrequency eq 645312
                                and freqBandIndicatorNR eq 78
                                )
                            )
                        )
                    and measIdToRemoveList contains (1,2)
                    and reportConfigToRemoveList contains (2)
                    and measObjectToRemoveList contains (1, 2)
                    )
                )
            )
        )
    )
)
"""

MeNB_coordinated_meas_gap_release = """
(measConfigMN contains
    (measGapConfig contains
        (release is present)
    )
)
"""

MeNB_coordinated_meas_gap_rel_in_UEContextModReq = f"""
(CUtoDURRCInformation contains
    (cg-ConfigInfo contains
        {MeNB_coordinated_meas_gap_release}
    )
)
"""

freq_source = (636576, 645312)
freq_target = (645312, 518599)

meas_frequencies_source_cell = get_measConfigSN(freq_source)
MeNB_coordinated_meas_gap_setup_in_SgNBModRequired_source_cell = f"""
    (SgNBtoMeNBContainer contains
        ({meas_frequencies_source_cell}
        )
    )
"""

A4_measurements_configuration_in_SgNBModReqAck_on_source_cell = f"""
        (SgNBtoMeNBContainer contains
            (CG-Config contains
                (scg-CellGroupConfig contains
                    (rrcReconfiguration contains
                        (measConfig contains
                            (measObjectToAddModList contains
                                (measObjectId eq 2
                                and measObject contains
                                    (measObjectNR contains
                                        ((ssbFrequency eq 645312) and (freqBandIndicatorNR eq 78))
                                    )
                                )
                            )
                        and measConfig contains
                            (reportConfigToAddModList contains
                                (reportConfigId eq {report_config_id_B14}
                                and reportConfig contains
                                    (eventA4 is present
                                    and (a4-Threshold contains (rsrp eq 34))
                                    and (hysteresis eq 0)
                                    and (timeToTrigger eq "ms40")
                                    )
                                )
                            )
                        and measConfig contains
                            {meas_id_to_add_mod_list_B14}
                        )
                        and measGapConfig is not present
                    )
                )
            and {meas_frequencies_source_cell}
            )
        )
        """

meas_frequencies_target_cell = get_measConfigSN(freq_target)
MeNB_coordinated_meas_gap_setup_in_SgNBModRequired_target_cell = f"""
    (SgNBtoMeNBContainer contains
        ({meas_frequencies_target_cell}
        )
    )
"""
A4_measurements_configuration_in_SgNBModReqAck_on_target_cell = f"""
        (SgNBtoMeNBContainer contains
            (CG-Config contains
                (scg-CellGroupConfig contains
                    (rrcReconfiguration contains
                        (measConfig contains
                            (measObjectToAddModList contains
                                (measObjectId eq 1
                                and measObject contains
                                    (measObjectNR contains
                                        ((ssbFrequency eq 518599) and (freqBandIndicatorNR eq 41))
                                    )
                                )
                            )
                        and measConfig contains
                            (reportConfigToAddModList contains
                                (reportConfigId eq {report_config_id_B14}
                                and reportConfig contains
                                    (eventA4 is present
                                    and (a4-Threshold contains (rsrp eq {target_cell_rsrp}))
                                    and (hysteresis eq {target_cell_hysteresis})
                                    and (timeToTrigger eq "ms40")
                                    )
                                )
                            )
                        and measConfig contains
                            {meas_id_to_add_mod_list_B14_target}
                        )
                        and measGapConfig is not present
                    )
                )
            and {meas_frequencies_target_cell}
            )
        )
        """

MeNB_coordinated_meas_gap_setup = """
                cg-ConfigInfo contains
                    (measConfigMN contains
                        (measGapConfig contains
                            (setup is present)
                            and setup contains
                                (gapOffset eq 13
                                and mgl eq "ms6"
                                and mgrp eq "ms20"
                                and mgta eq "ms0"
                                )
                            and gapPurpose eq "perUE"
                        )
                    )
"""

MeNB_coordinated_meas_gap_setup_in_SgNBModRequest = f"""
MeNBtoSgNBContainer contains
    ({MeNB_coordinated_meas_gap_setup}
    )
"""

MeNB_coordinated_meas_gap_setup_and_DRX_rel_in_UEContextModReq = f"""
CUtoDURRCInformation contains
    ({MeNB_coordinated_meas_gap_setup}
    )
and DRXConfigurationIndicator eq "release"
"""

DRX_release = """
        (mac-CellGroupConfig contains
            (drx-Config contains
                (release is present)
            )
        )
"""

DRX_release_in_UEContextModResp = get_filter_for_UEContextModificationResponse(DRX_release)

RRCReconfigurationCompleteIndicator = 'RRCReconfigurationCompleteIndicator eq "true"'
DUConfigurationQuery = 'GNB-DUConfigurationQuery eq "true"'
UEContextModReq_after_gaps_setup_and_DRX_release = f"""
    ({RRCReconfigurationCompleteIndicator}
    and {DUConfigurationQuery}
    )
"""

gap_pattern_B14 = "gp4"
gap_offset_B14 = 13
RRC_meas_gap_setup_B14 = f"""
rrcConnectionReconfiguration contains
    (measConfig contains
        (measGapConfig contains
            (setup is present
            and setup contains
                (gapOffset contains
                    ({gap_pattern_B14}-r15 is present
                    and {gap_pattern_B14}-r15 eq {gap_offset_B14}
                    )
                )
            )
            and fr1-Gap-r15 eq "FALSE"
        )
    )
"""
