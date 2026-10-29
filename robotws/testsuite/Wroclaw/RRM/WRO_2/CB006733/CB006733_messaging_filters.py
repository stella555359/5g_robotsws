Meas_Config_With_A4_Measurements_Configuration_In_RRC_Reconf_template = """
    measConfig contains
    (
        {meas_objects}
        and
        reportConfigToAddModList contains
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
                                rsrp eq "TRUE"
                                and rsrq eq "TRUE"
                                and sinr eq "TRUE"
                            )
                            and eventId contains (eventA4 is present)
                            and a4-Threshold contains (rsrp eq 80)
                        )
                    )
                )
            )
        )
        and reportConfigToAddModList contains
        (
            reportConfigId eq 2
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
                                rsrp eq "TRUE"
                                and rsrq eq "TRUE"
                                and sinr eq "TRUE"
                            )
                            and eventId contains (eventA4 is present)
                            and a4-Threshold contains (rsrq eq 90)
                        )
                    )
                )
            )
        )
        {meas_1_2_1}
        {meas_2_3_2}
        {meas_3_4_1}
        {meas_4_4_2}
        {meas_5_5_1}
        {meas_6_6_2}
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

Meas_Config_With_A2_Measurements_Configuration_In_RRC_Reconf_A_B5_template = """
    drb-ToAddModList contains (pdu-Session eq 4)
    and measConfig contains
    (
        measObjectToAddModList contains
        (
            (measObjectId eq 1) and (ssbFrequency eq 506430) and (freqBandIndicatorNR eq 41)
        )
        and
        reportConfigToAddModList contains
        (
            reportConfigId eq 1
            and
            {report_config_a2}
        )
        and measIdToAddModList contains
        (
            measId eq 1
            and measObjectId eq 1
            and reportConfigId eq 1
        )
        and length(measObjectToAddModList) eq 1
        and length(reportConfigToAddModList) eq 1
        and length(measIdToAddModList) eq 1
    )
    and s-MeasureConfig contains
        (
            ssb-RSRP eq 127
        )
    """

Meas_Config_With_A4_Measurements_Configuration_In_RRC_Reconf_A_B5_template = """
    measConfig contains
    (
        {meas_objects}
        and
        reportConfigToAddModList contains
        (
            reportConfigId eq 2
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
                                rsrp eq "TRUE"
                                and rsrq eq "TRUE"
                                and sinr eq "TRUE"
                            )
                            and eventId contains
                            (
                                eventA4 is present
                                and reportOnLeave eq "TRUE"
                                and hysteresis eq 0
                                and timeToTrigger eq "ms320"
                            )
                            and reportAmount eq "r1"
                            and reportInterval eq "ms1024"
                            and rsType eq "ssb"
                            and a4-Threshold contains (rsrp eq 80)
                            and maxReportCells eq 8
                            and reportQuantityRS-Indexes contains
                            (
                                rsrp eq "TRUE"
                                and rsrq eq "TRUE"
                                and sinr eq "TRUE"
                            )
                        )
                    )
                )
            )
        )
        and
        reportConfigToAddModList contains
        (
            reportConfigId eq 3
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
                                rsrp eq "TRUE"
                                and rsrq eq "TRUE"
                                and sinr eq "TRUE"
                            )
                            and eventId contains
                            (
                                eventA4 is present
                                and reportOnLeave eq "TRUE"
                                and hysteresis eq 0
                                and timeToTrigger eq "ms320"
                            )
                            and reportAmount eq "r1"
                            and reportInterval eq "ms1024"
                            and rsType eq "ssb"
                            and a4-Threshold contains (rsrq eq 90)
                            and maxReportCells eq 8
                            and reportQuantityRS-Indexes contains
                            (
                                rsrp eq "TRUE"
                                and rsrq eq "TRUE"
                                and sinr eq "TRUE"
                            )
                        )
                    )
                )
            )
        )
        {meas_12_2_4}
        {meas_13_3_5}
        {meas_14_4_4}
        {meas_15_4_5}
        {meas_16_5_4}
        {meas_17_6_5}
        and measGapConfig contains
        (
            gapOffset eq 0
            and mgl eq "ms3"
            and mgrp eq "ms160"
            and mgta eq "ms0"
        )
    )
    """

Meas_Config_With_A4_Measurements_Configuration_In_RRC_Reconf_C_B27_template = """
    measConfig contains
    (
        {meas_objects}
        and
        reportConfigToAddModList contains
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
                                eventA4 is present
                            )

                            and a4-Threshold contains (rsrq is present)
                        )
                    )
                )
            )
        )
        and
        reportConfigToAddModList contains
        (
            reportConfigId eq 2
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
                                eventA4 is present
                            )
                            and a4-Threshold contains (rsrp is present)
                        )
                    )
                )
            )
        )
        {meas_1_2_1}
        {meas_2_3_2}
        {meas_3_3_1}
    )
    """
Meas_Config_With_A2_Measurement_Configuration_and_A1_A3_A5_Measurements_Deconfiguration_A_B5_template = """
    measConfig contains
    (
        measObjectToAddModList contains
        (
            (measObjectId eq 1) and (ssbFrequency eq 506430) and (freqBandIndicatorNR eq 41)
        )
        and reportConfigToAddModList contains
        (
            reportConfigId eq 9
            and
            {report_config_a2}
        )
        and measIdToAddModList contains
        (
            measId eq 29
            and measObjectId eq 1
            and reportConfigId eq 9
        )
        and measIdToRemoveList contains (18,19,20,21,22,23,24,25,26,27,28)
        and length(measIdToRemoveList) eq 11
        and reportConfigToRemoveList contains (6,7,8)
        and length(reportConfigToRemoveList) eq 3
        and measGapConfig contains
        (
            gapUE contains
             (
                 release is present
             )
        )
    )
"""

Meas_Config_With_A1_A3_A5_Measurements_Configuration_In_RRC_Reconf_A_B5_template = """
    measConfig contains
    (
        measObjectToAddModList contains
        (
            (measObjectId eq 1) and (ssbFrequency eq 506430) and (freqBandIndicatorNR eq 41)
        )
        and
        reportConfigToAddModList contains
        (
            reportConfigId eq 6
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
                                rsrp eq "TRUE"
                                and rsrq eq "TRUE"
                                and sinr eq "TRUE"
                            )
                            and eventId contains
                            (
                                eventA1 is present
                                and reportOnLeave eq "FALSE"
                                and hysteresis eq 0
                                and timeToTrigger eq "ms480"
                            )
                            and a1-Threshold contains (rsrp eq 60)
                            and maxReportCells eq 8
                            and reportQuantityRS-Indexes contains
                            (
                                rsrp eq "TRUE"
                                and rsrq eq "TRUE"
                                and sinr eq "TRUE"
                            )
                        )
                    )
                )
            )
        )
        and reportConfigToAddModList contains
        (
            reportConfigId eq 7
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
                                rsrp eq "TRUE"
                                and rsrq eq "TRUE"
                                and sinr eq "TRUE"
                            )
                            and eventId contains
                            (
                                eventA3 is present
                                and reportOnLeave eq "FALSE"
                                and hysteresis eq 0
                                and timeToTrigger eq "ms128"
                            )
                            and a3-Offset contains
                            (
                                rsrp is present
                                and rsrp eq 6
                            )
                            and maxReportCells eq 8
                            and reportQuantityRS-Indexes contains
                            (
                                rsrp eq "TRUE"
                                and rsrq eq "TRUE"
                                and sinr eq "TRUE"
                            )
                        )
                    )
                )
            )
        )
        and reportConfigToAddModList contains
        (
            reportConfigId eq 8
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
                                rsrp eq "TRUE"
                                and rsrq eq "TRUE"
                                and sinr eq "TRUE"
                            )
                            and eventId contains
                            (
                                eventA5 is present
                                and reportOnLeave eq "FALSE"
                                and hysteresis eq 0
                                and timeToTrigger eq "ms512"
                            )
                            and a5-Threshold1 contains
                            (
                                rsrq is present
                                and rsrq eq 30
                            )
                            and a5-Threshold2 contains
                            (
                                rsrq is present
                                and rsrq eq 70
                            )
                            and maxReportCells eq 8
                            and reportQuantityRS-Indexes contains
                            (
                                rsrp eq "TRUE"
                                and rsrq eq "TRUE"
                                and sinr eq "TRUE"
                            )
                        )
                    )
                )
            )
        )
        {meas_18_1_6}
        {meas_19_2_7}
        {meas_20_3_7}
        {meas_21_4_7}
        {meas_22_5_7}
        {meas_23_6_7}
        {meas_24_2_8}
        {meas_25_3_8}
        {meas_26_4_8}
        {meas_27_5_8}
        {meas_28_6_8}
        and measIdToRemoveList contains (1,2,3,4,5,6,7)
        and length(measIdToRemoveList) eq 7
        and reportConfigToRemoveList contains (1)
        and length(reportConfigToRemoveList) eq 1
    )
    """

Meas_Config_With_A2_Measurements_Configuration_In_RRC_Reconf_A_B12_template = """
    measConfig contains
    (
        {meas_objects}
        and
        reportConfigToAddModList contains
        (
            reportConfigId eq 3
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
                                rsrp eq "TRUE"
                                and rsrq eq "TRUE"
                                and sinr eq "TRUE"
                            )
                            and eventId contains (eventA2 is present)
                            and a2-Threshold contains (rsrq eq 49)
                        )
                    )
                )
            )
        )
        {meas_4_2_3}
        {meas_5_3_3}
    )
    """

Meas_Config_With_A4_Measurements_Configuration_In_RRC_Reconf_A_B12_template = """
    measConfig contains
    (
        {meas_objects}
        and
        reportConfigToAddModList contains
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
                                rsrp eq "TRUE"
                                and rsrq eq "TRUE"
                                and sinr eq "TRUE"
                            )
                            and eventId contains (eventA4 is present)
                            and a4-Threshold contains (rsrq eq 90)
                        )
                    )
                )
            )
        )
        and reportConfigToAddModList contains
        (
            reportConfigId eq 2
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
                                rsrp eq "TRUE"
                                and rsrq eq "TRUE"
                                and sinr eq "TRUE"
                            )
                            and eventId contains (eventA4 is present)
                            and a4-Threshold contains (rsrp eq 80)
                        )
                    )
                )
            )
        )
        {meas_1_2_1}
        {meas_2_3_2}
        {meas_3_3_1}
    )
    """

Meas_Config_With_A1_A3_A5_Measurements_Configuration_In_RRC_Reconf_B_B1_template = """
    measConfig contains
    (
        measObjectToAddModList contains
        (
            (measObjectId eq 1) and (ssbFrequency eq 506430) and (freqBandIndicatorNR eq 41)
        )
        and
        {meas_objects}
        and
        reportConfigToAddModList contains
        (
            reportConfigId eq 2
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
                                rsrp eq "TRUE"
                                and rsrq eq "TRUE"
                                and sinr eq "TRUE"
                            )
                            and eventId contains
                            (
                                eventA1 is present
                                and reportOnLeave eq "FALSE"
                                and hysteresis eq 0
                                and timeToTrigger eq "ms480"
                            )
                            and a1-Threshold contains (rsrp eq 60)
                            and maxReportCells eq 8
                            and reportQuantityRS-Indexes contains
                            (
                                rsrp eq "TRUE"
                                and rsrq eq "TRUE"
                                and sinr eq "TRUE"
                            )
                        )
                    )
                )
            )
        )
        and reportConfigToAddModList contains
        (
            reportConfigId eq 3
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
                                rsrp eq "TRUE"
                                and rsrq eq "TRUE"
                                and sinr eq "TRUE"
                            )
                            and eventId contains
                            (
                                eventA3 is present
                                and reportOnLeave eq "FALSE"
                                and hysteresis eq 0
                                and timeToTrigger eq "ms40"
                            )
                            and a3-Offset contains
                            (
                                rsrp is present
                                and rsrp eq 20
                            )
                            and maxReportCells eq 8
                            and reportQuantityRS-Indexes contains
                            (
                                rsrp eq "TRUE"
                                and rsrq eq "TRUE"
                                and sinr eq "TRUE"
                            )
                        )
                    )
                )
            )
        )
        and reportConfigToAddModList contains
        (
            reportConfigId eq 4
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
                                rsrp eq "TRUE"
                                and rsrq eq "TRUE"
                                and sinr eq "TRUE"
                            )
                            and eventId contains
                            (
                                eventA5 is present
                                and reportOnLeave eq "FALSE"
                                and hysteresis eq 0
                                and timeToTrigger eq "ms40"
                            )
                            and a5-Threshold1 contains
                            (
                                rsrp is present
                                and rsrp eq 51
                            )
                            and a5-Threshold2 contains
                            (
                                rsrp is present
                                and rsrp eq 62
                            )
                            and maxReportCells eq 8
                            and reportQuantityRS-Indexes contains
                            (
                                rsrp eq "TRUE"
                                and rsrq eq "TRUE"
                                and sinr eq "TRUE"
                            )
                        )
                    )
                )
            )
        )
        {meas_2_1_2}
        {meas_3_2_3}
        {meas_4_2_4}
        and measIdToRemoveList contains (1)
        and length(measIdToRemoveList) eq 1
        and reportConfigToRemoveList contains (1)
        and length(reportConfigToRemoveList) eq 1
        and measGapConfig contains
        (
            gapOffset eq 0
            and mgl eq "ms3"
            and mgrp eq "ms160"
            and mgta eq "ms0"
        )
    )
    """

Meas_Config_With_A4_Measurements_Configuration_In_RRC_Reconf_B_B1_template = """
    measConfig contains
    (
        measObjectToAddModList contains
        (
            (measObjectId eq 2) and (ssbFrequency eq 392410) and (freqBandIndicatorNR eq 25)
        )
        and
        {meas_objects}
        and
        reportConfigToAddModList contains
        (
            reportConfigId eq 5
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
                                rsrp eq "TRUE"
                                and rsrq eq "TRUE"
                                and sinr eq "TRUE"
                            )
                            and eventId contains
                            (
                                eventA4 is present
                                and reportOnLeave eq "TRUE"
                                and hysteresis eq 0
                                and timeToTrigger eq "ms320"
                            )
                            and reportAmount eq "r1"
                            and reportInterval eq "ms1024"
                            and rsType eq "ssb"
                            and a4-Threshold contains (rsrp eq 80)
                            and maxReportCells eq 8
                            and reportQuantityRS-Indexes contains
                            (
                                rsrp eq "TRUE"
                                and rsrq eq "TRUE"
                                and sinr eq "TRUE"
                            )
                        )
                    )
                )
            )
        )
        and
        reportConfigToAddModList contains
        (
            reportConfigId eq 6
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
                                rsrp eq "TRUE"
                                and rsrq eq "TRUE"
                                and sinr eq "TRUE"
                            )
                            and eventId contains
                            (
                                eventA4 is present
                                and reportOnLeave eq "TRUE"
                                and hysteresis eq 0
                                and timeToTrigger eq "ms320"
                            )
                            and reportAmount eq "r1"
                            and reportInterval eq "ms1024"
                            and rsType eq "ssb"
                            and a4-Threshold contains (rsrq eq 90)
                            and maxReportCells eq 8
                            and reportQuantityRS-Indexes contains
                            (
                                rsrp eq "TRUE"
                                and rsrq eq "TRUE"
                                and sinr eq "TRUE"
                            )
                        )
                    )
                )
            )
        )
        {meas_5_3_5}
        {meas_6_4_6}
        {meas_7_5_5}
        {meas_8_5_6}
        {meas_9_6_5}
        {meas_10_7_6}
        and measGapConfig contains
        (
            gapOffset eq 0
            and mgl eq "ms3"
            and mgrp eq "ms160"
            and mgta eq "ms0"
        )
    )
    """


Meas_Config_With_A1_A3_A5_Measurements_Deconfiguration_In_RRC_Reconf_B_B1 = """
    measConfig contains
     (
         measObjectToAddModList contains
         (
             (measObjectId eq 2) and (ssbFrequency eq 392410) and (freqBandIndicatorNR eq 25)
         )
        and measObjectToRemoveList contains (1)
        and length(measObjectToRemoveList) eq 1
        and reportConfigToRemoveList contains (2,3,4)
        and length(reportConfigToRemoveList) eq 3
        and measIdToRemoveList contains (2,3,4)
        and length(measIdToRemoveList) eq 3
        and measGapConfig contains
        (
            gapUE contains
             (
                 release is present
             )
        )
    )
    """

Meas_Config_With_A4_Measurements_Deconfiguration_In_RRC_Reconf_A_B12 = """
    measConfig contains
     (
        measIdToRemoveList contains (1,2,3)
        and length(measIdToRemoveList) eq 3
        and measGapConfig contains
        (
            gapUE contains
             (
                 release is present
             )
        )
    )
"""

A2_measurementReport_template = """
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
                    physCellId eq {physCellId}
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

A2_measurementReport_Cell2 = """
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
                    physCellId eq 54
                    and measResult contains
                    (
                        cellResults contains
                        (
                            resultsSSB-Cell contains
                            (
                                rsrp eq 90
                                and rsrq eq 0
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
                                rsrq eq 40
                            )
                        )
                    )
                )
            )
        )
    )
"""

A2_measurementReport_Cell3 = """
    measurementReport contains
    (
        measResults contains
        (
            measId eq 5
            and measResultServingMOList contains
            (
                servCellId eq 0
                and measResultServingCell contains
                (
                    physCellId eq 54
                    and measResult contains
                    (
                        cellResults contains
                        (
                            resultsSSB-Cell contains
                            (
                                rsrp eq 90
                                and rsrq eq 0
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
                                rsrq eq 35
                            )
                        )
                    )
                )
            )
        )
    )
"""

Meas_Config_With_A4_Measurements_Configuration_In_RRC_Reconf_B_B2_template = """
    measConfig contains
    (
        {meas_objects}
        and
        reportConfigToAddModList contains
        (
            reportConfigId eq 3
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
                                rsrp eq "TRUE"
                                and rsrq eq "TRUE"
                                and sinr eq "TRUE"
                            )
                            and eventId contains (eventA4 is present)
                            and a4-Threshold contains (rsrp eq 80)
                        )
                    )
                )
            )
        )
        and reportConfigToAddModList contains
        (
            reportConfigId eq 4
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
                                rsrp eq "TRUE"
                                and rsrq eq "TRUE"
                                and sinr eq "TRUE"
                            )
                            and eventId contains (eventA4 is present)
                            and a4-Threshold contains (rsrq eq 90)
                        )
                    )
                )
            )
        )
        {meas_15_9_3}
        {meas_16_10_4}
        {meas_17_11_3}
        {meas_18_11_4}
        {meas_19_12_3}
        {meas_20_13_4}
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

meas_objects_9_10_11_12_13 = """
        measObjectToAddModList contains
        (
            (measObjectId eq 9) and (ssbFrequency eq 392410) and (freqBandIndicatorNR eq 25)
        )
        and
        measObjectToAddModList contains
        (
            (measObjectId eq 10) and (ssbFrequency eq 430850) and (freqBandIndicatorNR eq 66)
        )
        and
        measObjectToAddModList contains
        (
            (measObjectId eq 11) and (ssbFrequency eq 125070) and (freqBandIndicatorNR eq 71)
        )
        and
        measObjectToAddModList contains
        (
            (measObjectId eq 12) and (ssbFrequency eq 529950) and (freqBandIndicatorNR eq 41)
        )
        and
        measObjectToAddModList contains
        (
            (measObjectId eq 13) and (ssbFrequency eq 623328) and (freqBandIndicatorNR eq 77)
        )
"""

A2_measurementReport_A_B5 = A2_measurementReport_template.format(
    physCellId=54,
    rsrp=20)

A2_measurementReport_B_B1 = A2_measurementReport_template.format(
    physCellId=54,
    rsrp=19)

A3_measurementReport_B_B1 = """
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
                    physCellId eq 54
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
                    physCellId eq 51
                    and measResult contains
                    (
                        cellResults contains
                        (
                            resultsSSB-Cell contains
                            (
                                rsrp eq 100
                            )
                        )
                    )
                )
            )
        )
    )
"""


A4_measurementReport_RSRQ_template = """
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
                    physCellId eq 54
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
                    physCellId eq 52
                    and measResult contains
                    (
                        cellResults contains
                        (
                            resultsSSB-Cell contains
                            (
                                rsrq eq {rsrq}
                            )
                        )
                    )
                )
            )
        )
    )
"""

A4_measurementReport_RSRQ = A4_measurementReport_RSRQ_template.format(
    rsrq=95)

A4_measurementReport_RSRP_template = """
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
                    physCellId eq 54
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
                    physCellId eq 53
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

A4_measurementReport_RSRP = A4_measurementReport_RSRP_template.format(
    rsrp=90)

A1_measurementReport_A_B5 = """
    measurementReport contains
    (
        measResults contains
        (
            measId eq 18
            and measResultServingMOList contains
            (
                servCellId eq 0
                and measResultServingCell contains
                (
                    physCellId eq 54
                    and measResult contains
                    (
                        cellResults contains
                        (
                            resultsSSB-Cell contains
                            (
                                rsrp eq 90
                            )
                        )
                    )
                )
            )
        )
    )
"""

SCellToBeSetupModList_A_B12 = """
    nonCriticalExtension contains
    (
        masterCellGroup contains
        (
            CONTAINING contains
            (
                sCellToAddModList contains
                (
                    sCellIndex eq 1
                    and sCellConfigCommon contains
                    (
                        physCellId eq 52
                    )
                )
                and sCellToAddModList contains
                (
                    sCellIndex eq 2
                    and sCellConfigCommon contains
                    (
                        physCellId eq 53
                    )
                )
            )
        )
    )
"""

SCellToRelease_A_B12_template = """
    rrcReconfiguration contains
    (
        measConfig contains
        (
            measObjectToRemoveList contains
            (
                {meas_object}
            )
        )
        and measConfig contains
        (
            measIdToRemoveList contains
            (
                {meas_id}
            )
        )
    )
    and rrcReconfiguration contains
    (
        nonCriticalExtension contains
        (
            masterCellGroup contains
            (
                CONTAINING contains
                (
                    sCellToReleaseList contains
                    (
                        {scell_index}
                    )
                )
            )
        )
    )
"""

LastSCellToRelease_A_B12_template = """
    rrcReconfiguration contains
    (
        measConfig contains
        (
            measObjectToRemoveList contains
            (
                {meas_object}
            )
        )
        and measConfig contains
        (
            reportConfigToRemoveList contains
            (
                {report_config}
            )
        )
        and measConfig contains
        (
            measIdToRemoveList contains
            (
                {meas_id}
            )
        )
    )
    and rrcReconfiguration contains
    (
        nonCriticalExtension contains
        (
            masterCellGroup contains
            (
                CONTAINING contains
                (
                    sCellToReleaseList contains
                    (
                        {scell_index}
                    )
                )
            )
        )
    )
"""

Meas_Config_With_A4_Measurements_2nd_Configuration_In_RRC_Reconf_A_B5_template = """
    measConfig contains
    (
        {meas_objects}
        {meas_A}
        {meas_B}
        {meas_C}
        {meas_D}
        {meas_E}
        {meas_F}
        and measGapConfig contains
        (
            gapOffset eq 0
            and mgl eq "ms3"
            and mgrp eq "ms160"
            and mgta eq "ms0"
        )
    )
    """

meas_objects_2_3_4_5_6 = """
        measObjectToAddModList contains
        (
            (measObjectId eq 2) and (ssbFrequency eq 392410) and (freqBandIndicatorNR eq 25)
        )
        and
        measObjectToAddModList contains
        (
            (measObjectId eq 3) and (ssbFrequency eq 430850) and (freqBandIndicatorNR eq 66)
        )
        and
        measObjectToAddModList contains
        (
            (measObjectId eq 4) and (ssbFrequency eq 125070) and (freqBandIndicatorNR eq 71)
        )
        and
        measObjectToAddModList contains
        (
            (measObjectId eq 5) and (ssbFrequency eq 529950) and (freqBandIndicatorNR eq 41)
        )
        and
        measObjectToAddModList contains
        (
            (measObjectId eq 6) and (ssbFrequency eq 623328) and (freqBandIndicatorNR eq 77)
        )
"""

meas_objects_2_3_A4 = """
        measObjectToAddModList contains
        (
            (measObjectId eq 2) and (ssbFrequency eq 430850) and (freqBandIndicatorNR eq 66)
        )
        and
        measObjectToAddModList contains
        (
            (measObjectId eq 3) and (ssbFrequency eq 125070) and (freqBandIndicatorNR eq 71)
        )
"""

meas_objects_2_3_A2 = """
        measObjectToAddModList contains
        (
            (measObjectId eq 2) and (ssbFrequency eq 430850) and (freqBandIndicatorNR eq 66)
        )
        and
        measObjectToAddModList contains
        (
            (measObjectId eq 3) and (ssbFrequency eq 125070) and (freqBandIndicatorNR eq 71)
        )
"""


meas_object_2 = """
        measObjectToAddModList contains
        (
            (measObjectId eq 2) and (ssbFrequency eq 392410) and (freqBandIndicatorNR eq 25)
        )
"""

meas_object_3_4_5_6_7 = """
        measObjectToAddModList contains
        (
            (measObjectId eq 3) and (ssbFrequency eq 430850) and (freqBandIndicatorNR eq 66)
        )
        and
        measObjectToAddModList contains
        (
            (measObjectId eq 4) and (ssbFrequency eq 125070) and (freqBandIndicatorNR eq 71)
        )
        and
        measObjectToAddModList contains
        (
            (measObjectId eq 5) and (ssbFrequency eq 506430) and (freqBandIndicatorNR eq 41)
        )
        and
        measObjectToAddModList contains
        (
            (measObjectId eq 6) and (ssbFrequency eq 529950) and (freqBandIndicatorNR eq 41)
        )
        and
        measObjectToAddModList contains
        (
            (measObjectId eq 7) and (ssbFrequency eq 623328) and (freqBandIndicatorNR eq 77)
        )
"""

report_config_A2_template = """
            reportConfig contains
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
                                rsrp eq "TRUE"
                                and rsrq eq "TRUE"
                                and sinr eq "TRUE"
                            )
                            and eventId contains
                            (
                                eventA2 is present
                                and reportOnLeave eq "FALSE"
                                and hysteresis eq {hysteresis}
                                and timeToTrigger eq {time_to_trigger}
                            )
                            and a2-Threshold contains ({type} eq {rsr})
                            and maxReportCells eq 8
                            and reportQuantityRS-Indexes contains
                            (
                                rsrp eq "TRUE"
                                and rsrq eq "TRUE"
                                and sinr eq "TRUE"
                            )
                        )
                    )
                )
            )
"""

report_config_A2_A_B5 = report_config_A2_template.format(
    hysteresis=0,
    time_to_trigger="\"ms480\"",
    type="rsrp",
    rsr=34)

report_config_A2_B_B1 = report_config_A2_template.format(
    hysteresis=4,
    time_to_trigger="\"ms480\"",
    type="rsrp",
    rsr=33)

meas_id_to_add_mod_list_template = """
and measIdToAddModList contains
        (
            measId eq {meas_id}
            and measObjectId eq {meas_object_id}
            and reportConfigId eq {report_config_id}
        )
"""

meas_id_to_add_mod_list_wo_and_template = """
measIdToAddModList contains
        (
            measId eq {meas_id}
            and measObjectId eq {meas_object_id}
            and reportConfigId eq {report_config_id}
        )
"""


def fill_measIdToAddModList_element(template=meas_id_to_add_mod_list_template,
                                    meas_ID=None, meas_object_ID=None, report_config_ID=None):
    return template.format(meas_id=meas_ID, meas_object_id=meas_object_ID, report_config_id=report_config_ID)


def fill_measIdToAddModList_wo_and_element(template=meas_id_to_add_mod_list_wo_and_template,
                                           meas_ID=None, meas_object_ID=None, report_config_ID=None):
    return template.format(meas_id=meas_ID, meas_object_id=meas_object_ID, report_config_id=report_config_ID)


SCellToRelease_Cell2_A_B12 = SCellToRelease_A_B12_template.format(
    meas_object=2,
    meas_id=4,
    scell_index=1)

SCellToRelease_Cell3_A_B12 = LastSCellToRelease_A_B12_template.format(
    meas_object=3,
    report_config=3,
    meas_id=5,
    scell_index=2)

Meas_Config_With_A4_Measurements_2nd_Configuration_In_RRC_Reconf_A_B5 = \
    Meas_Config_With_A4_Measurements_2nd_Configuration_In_RRC_Reconf_A_B5_template.format(
        meas_objects=meas_objects_2_3_4_5_6,
        meas_A=fill_measIdToAddModList_element(meas_ID=40, meas_object_ID=2, report_config_ID=4),
        meas_B=fill_measIdToAddModList_element(meas_ID=41, meas_object_ID=3, report_config_ID=5),
        meas_C=fill_measIdToAddModList_element(meas_ID=42, meas_object_ID=4, report_config_ID=4),
        meas_D=fill_measIdToAddModList_element(meas_ID=43, meas_object_ID=4, report_config_ID=5),
        meas_E=fill_measIdToAddModList_element(meas_ID=44, meas_object_ID=5, report_config_ID=4),
        meas_F=fill_measIdToAddModList_element(meas_ID=45, meas_object_ID=6, report_config_ID=5))

Meas_Config_With_A1_A3_A5_Measurements_Configuration_In_RRC_Reconf_A_B5 = \
    Meas_Config_With_A1_A3_A5_Measurements_Configuration_In_RRC_Reconf_A_B5_template.format(
        meas_18_1_6=fill_measIdToAddModList_element(meas_ID=18, meas_object_ID=1, report_config_ID=6),
        meas_19_2_7=fill_measIdToAddModList_element(meas_ID=19, meas_object_ID=2, report_config_ID=7),
        meas_20_3_7=fill_measIdToAddModList_element(meas_ID=20, meas_object_ID=3, report_config_ID=7),
        meas_21_4_7=fill_measIdToAddModList_element(meas_ID=21, meas_object_ID=4, report_config_ID=7),
        meas_22_5_7=fill_measIdToAddModList_element(meas_ID=22, meas_object_ID=5, report_config_ID=7),
        meas_23_6_7=fill_measIdToAddModList_element(meas_ID=23, meas_object_ID=6, report_config_ID=7),
        meas_24_2_8=fill_measIdToAddModList_element(meas_ID=24, meas_object_ID=2, report_config_ID=8),
        meas_25_3_8=fill_measIdToAddModList_element(meas_ID=25, meas_object_ID=3, report_config_ID=8),
        meas_26_4_8=fill_measIdToAddModList_element(meas_ID=26, meas_object_ID=4, report_config_ID=8),
        meas_27_5_8=fill_measIdToAddModList_element(meas_ID=27, meas_object_ID=5, report_config_ID=8),
        meas_28_6_8=fill_measIdToAddModList_element(meas_ID=28, meas_object_ID=6, report_config_ID=8))

Meas_Config_With_A4_Measurements_Configuration_In_RRC_Reconf_C_B27 = \
    Meas_Config_With_A4_Measurements_Configuration_In_RRC_Reconf_C_B27_template.format(
        meas_objects=meas_objects_2_3_A4,
        meas_1_2_1=fill_measIdToAddModList_element(meas_ID=1, meas_object_ID=2, report_config_ID=1),
        meas_2_3_2=fill_measIdToAddModList_element(meas_ID=2, meas_object_ID=3, report_config_ID=2),
        meas_3_3_1=fill_measIdToAddModList_element(meas_ID=3, meas_object_ID=3, report_config_ID=1))

Meas_Config_With_A1_A3_A5_Measurements_Configuration_In_RRC_Reconf_B_B1 = \
    Meas_Config_With_A1_A3_A5_Measurements_Configuration_In_RRC_Reconf_B_B1_template.format(
        meas_objects=meas_object_2,
        meas_2_1_2=fill_measIdToAddModList_element(meas_ID=2, meas_object_ID=1, report_config_ID=2),
        meas_3_2_3=fill_measIdToAddModList_element(meas_ID=3, meas_object_ID=2, report_config_ID=3),
        meas_4_2_4=fill_measIdToAddModList_element(meas_ID=4, meas_object_ID=2, report_config_ID=4))

Meas_Config_With_A4_Measurements_Configuration_In_RRC_Reconf_B_B1 = \
    Meas_Config_With_A4_Measurements_Configuration_In_RRC_Reconf_B_B1_template.format(
        meas_objects=meas_object_3_4_5_6_7,
        meas_5_3_5=fill_measIdToAddModList_element(meas_ID=5, meas_object_ID=3, report_config_ID=5),
        meas_6_4_6=fill_measIdToAddModList_element(meas_ID=6, meas_object_ID=4, report_config_ID=6),
        meas_7_5_5=fill_measIdToAddModList_element(meas_ID=7, meas_object_ID=5, report_config_ID=5),
        meas_8_5_6=fill_measIdToAddModList_element(meas_ID=8, meas_object_ID=5, report_config_ID=6),
        meas_9_6_5=fill_measIdToAddModList_element(meas_ID=9, meas_object_ID=6, report_config_ID=5),
        meas_10_7_6=fill_measIdToAddModList_element(meas_ID=10, meas_object_ID=7, report_config_ID=6))

Meas_Config_With_A2_Measurements_Configuration_In_RRC_Reconf_A_B5 = \
    Meas_Config_With_A2_Measurements_Configuration_In_RRC_Reconf_A_B5_template.format(
        report_config_a2=report_config_A2_A_B5)

Meas_Config_With_A2_Measurements_Configuration_In_RRC_Reconf_B_B1 = \
    Meas_Config_With_A2_Measurements_Configuration_In_RRC_Reconf_A_B5_template.format(
        report_config_a2=report_config_A2_B_B1)

Meas_Config_With_A2_Measurement_Configuration_and_A1_A3_A5_Measurements_Deconfiguration_In_RRC_Reconf_A_B5 = \
    Meas_Config_With_A2_Measurement_Configuration_and_A1_A3_A5_Measurements_Deconfiguration_A_B5_template.format(
        report_config_a2=report_config_A2_A_B5)

Meas_Config_With_A2_Measurements_Configuration_In_RRC_Reconf_A_B12 = \
    Meas_Config_With_A2_Measurements_Configuration_In_RRC_Reconf_A_B12_template.format(
        meas_objects=meas_objects_2_3_A2,
        meas_4_2_3=fill_measIdToAddModList_element(meas_ID=4, meas_object_ID=2, report_config_ID=3),
        meas_5_3_3=fill_measIdToAddModList_element(meas_ID=5, meas_object_ID=3, report_config_ID=3))

Meas_Config_With_A4_Measurements_Configuration_In_RRC_Reconf = \
    Meas_Config_With_A4_Measurements_Configuration_In_RRC_Reconf_template.format(
        meas_objects=meas_objects_2_3_4_5_6,
        meas_1_2_1=fill_measIdToAddModList_element(meas_ID=1, meas_object_ID=2, report_config_ID=1),
        meas_2_3_2=fill_measIdToAddModList_element(meas_ID=2, meas_object_ID=3, report_config_ID=2),
        meas_3_4_1=fill_measIdToAddModList_element(meas_ID=3, meas_object_ID=4, report_config_ID=1),
        meas_4_4_2=fill_measIdToAddModList_element(meas_ID=4, meas_object_ID=4, report_config_ID=2),
        meas_5_5_1=fill_measIdToAddModList_element(meas_ID=5, meas_object_ID=5, report_config_ID=1),
        meas_6_6_2=fill_measIdToAddModList_element(meas_ID=6, meas_object_ID=6, report_config_ID=2))

Meas_Config_With_A4_Measurements_Configuration_In_RRC_Reconf_A_B5 = \
    Meas_Config_With_A4_Measurements_Configuration_In_RRC_Reconf_A_B5_template.format(
        meas_objects=meas_objects_2_3_4_5_6,
        meas_12_2_4=fill_measIdToAddModList_element(meas_ID=2, meas_object_ID=2, report_config_ID=2),
        meas_13_3_5=fill_measIdToAddModList_element(meas_ID=3, meas_object_ID=3, report_config_ID=3),
        meas_14_4_4=fill_measIdToAddModList_element(meas_ID=4, meas_object_ID=4, report_config_ID=2),
        meas_15_4_5=fill_measIdToAddModList_element(meas_ID=5, meas_object_ID=4, report_config_ID=3),
        meas_16_5_4=fill_measIdToAddModList_element(meas_ID=6, meas_object_ID=5, report_config_ID=2),
        meas_17_6_5=fill_measIdToAddModList_element(meas_ID=7, meas_object_ID=6, report_config_ID=3))

Meas_Config_With_A4_Measurements_Configuration_In_RRC_Reconf_B_B2 = \
    Meas_Config_With_A4_Measurements_Configuration_In_RRC_Reconf_B_B2_template.format(
        meas_objects=meas_objects_9_10_11_12_13,
        meas_15_9_3=fill_measIdToAddModList_element(meas_ID=15, meas_object_ID=9, report_config_ID=3),
        meas_16_10_4=fill_measIdToAddModList_element(meas_ID=16, meas_object_ID=10, report_config_ID=4),
        meas_17_11_3=fill_measIdToAddModList_element(meas_ID=17, meas_object_ID=11, report_config_ID=3),
        meas_18_11_4=fill_measIdToAddModList_element(meas_ID=18, meas_object_ID=11, report_config_ID=4),
        meas_19_12_3=fill_measIdToAddModList_element(meas_ID=19, meas_object_ID=12, report_config_ID=3),
        meas_20_13_4=fill_measIdToAddModList_element(meas_ID=20, meas_object_ID=13, report_config_ID=4))


meas_objects_2_3_4_5 = """
        measObjectToAddModList contains
        (
            (measObjectId eq 2) and (ssbFrequency eq 392410) and (freqBandIndicatorNR eq 25)
        )
        and
        measObjectToAddModList contains
        (
            (measObjectId eq 3) and (ssbFrequency eq 430850) and (freqBandIndicatorNR eq 66)
        )
        and
        measObjectToAddModList contains
        (
            (measObjectId eq 4) and (ssbFrequency eq 529950) and (freqBandIndicatorNR eq 41)
        )
        and
        measObjectToAddModList contains
        (
            (measObjectId eq 5) and (ssbFrequency eq 636384) and (freqBandIndicatorNR eq 77)
        )
"""


Meas_Config_With_A4_Measurements_Configuration_In_RRC_Reconf_A_B11 = \
    Meas_Config_With_A4_Measurements_Configuration_In_RRC_Reconf_template.format(
        meas_objects=meas_objects_2_3_4_5,
        meas_1_2_1=fill_measIdToAddModList_element(meas_ID=1, meas_object_ID=2, report_config_ID=1),
        meas_2_3_2=fill_measIdToAddModList_element(meas_ID=2, meas_object_ID=3, report_config_ID=2),
        meas_3_4_1=fill_measIdToAddModList_element(meas_ID=3, meas_object_ID=4, report_config_ID=1),
        meas_4_4_2=fill_measIdToAddModList_element(meas_ID=4, meas_object_ID=5, report_config_ID=2),
        meas_5_5_1="",
        meas_6_6_2="")

Meas_Config_With_A4_Measurements_Deconfiguration_In_RRC_Reconf_A_B11 = """
    measConfig contains
     (
        measIdToRemoveList contains (5,6,7,8)
        and length(measIdToRemoveList) eq 4
        and reportConfigToRemoveList is not present
        and measObjectToRemoveList is not present
        and measGapConfig contains
        (
            gapUE contains
             (
                 release is present
             )
        )
    )
    """

report_config_A2_A_B11 = report_config_A2_template.format(
    hysteresis=0,
    time_to_trigger="\"ms2560\"",
    type="rsrq",
    rsr=49)

Meas_Config_With_A2_SCell_Release_Meas_Configuration_A_B11_template = """
    measConfig contains
    (
        measObjectToAddModList contains
        (
            (measObjectId eq 4) and (ssbFrequency eq 529950) and (freqBandIndicatorNR eq 41)
        )
        and measObjectToAddModList contains
        (
            (measObjectId eq 5) and (ssbFrequency eq 636384) and (freqBandIndicatorNR eq 77)
        )
        and reportConfigToAddModList contains
        (
            reportConfigId eq 3
            and
            {report_config_a2}
        )
        and measIdToAddModList contains
        (
            measId eq 9
            and measObjectId eq 4
            and reportConfigId eq 3
        )
        and measIdToAddModList contains
        (
            measId eq 10
            and measObjectId eq 5
            and reportConfigId eq 3
        )
    )
"""

Meas_Config_With_A2_SCell_Release_Meas_Configuration_A_B11 = \
    Meas_Config_With_A2_SCell_Release_Meas_Configuration_A_B11_template.format(
        report_config_a2=report_config_A2_A_B11)

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


selected_SCells_for_sCellToAddModList_A_B11 = \
    selected_SCells_for_sCellToAddModList_template.format(
        number_of_selected_scells=2,
        scell_1=sCellToAddModList_template.format(scell_index=1, scell_physcellid=55),
        scell_2=sCellToAddModList_template.format(scell_index=2, scell_physcellid=56),
        scell_3="",
        scell_4="",
        scell_5="")

Meas_Config_With_A4_Measurements_2nd_Configuration_In_RRC_Reconf_A_B11 = \
    Meas_Config_With_A4_Measurements_2nd_Configuration_In_RRC_Reconf_A_B5_template.format(
        meas_objects="",
        meas_A=fill_measIdToAddModList_wo_and_element(meas_ID=5, meas_object_ID=2, report_config_ID=1),
        meas_B=fill_measIdToAddModList_element(meas_ID=6, meas_object_ID=3, report_config_ID=2),
        meas_C=fill_measIdToAddModList_element(meas_ID=7, meas_object_ID=4, report_config_ID=1),
        meas_D=fill_measIdToAddModList_element(meas_ID=8, meas_object_ID=5, report_config_ID=2),
        meas_E="",
        meas_F="")

Meas_Config_With_A4_Measurements_Configuration_In_RRC_Reconf_B_B12_template = """
    measConfig contains
    (
        {meas_objects}
        and
        reportConfigToAddModList contains
        (
            reportConfigId eq 4
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
                                rsrp eq "TRUE"
                                and rsrq eq "TRUE"
                                and sinr eq "TRUE"
                            )
                            and eventId contains
                            (
                                eventA4 is present
                                and reportOnLeave eq "TRUE"
                                and hysteresis eq 0
                                and timeToTrigger eq "ms320"
                            )
                            and reportAmount eq "r1"
                            and reportInterval eq "ms1024"
                            and rsType eq "ssb"
                            and a4-Threshold contains (rsrq eq 90)
                            and maxReportCells eq 8
                            and reportQuantityRS-Indexes contains
                            (
                                rsrp eq "TRUE"
                                and rsrq eq "TRUE"
                                and sinr eq "TRUE"
                            )
                        )
                    )
                )
            )
        )
        and
        reportConfigToAddModList contains
        (
            reportConfigId eq 5
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
                                rsrp eq "TRUE"
                                and rsrq eq "TRUE"
                                and sinr eq "TRUE"
                            )
                            and eventId contains
                            (
                                eventA4 is present
                                and reportOnLeave eq "TRUE"
                                and hysteresis eq 0
                                and timeToTrigger eq "ms320"
                            )
                            and reportAmount eq "r1"
                            and reportInterval eq "ms1024"
                            and rsType eq "ssb"
                            and a4-Threshold contains (rsrp eq 80)
                            and maxReportCells eq 8
                            and reportQuantityRS-Indexes contains
                            (
                                rsrp eq "TRUE"
                                and rsrq eq "TRUE"
                                and sinr eq "TRUE"
                            )
                        )
                    )
                )
            )
        )
        {meas_4_2_4}
        {meas_5_3_5}
        {meas_6_3_4}
    )
    """

meas_objects_2_3 = """
        measObjectToAddModList contains
        (
            (measObjectId eq 2) and (ssbFrequency eq 430850) and (freqBandIndicatorNR eq 66)
        )
        and
        measObjectToAddModList contains
        (
            (measObjectId eq 3) and (ssbFrequency eq 125070) and (freqBandIndicatorNR eq 71)
        )
"""


Meas_Config_With_A4_Measurements_Configuration_In_RRC_Reconf_B_B12 = \
    Meas_Config_With_A4_Measurements_Configuration_In_RRC_Reconf_B_B12_template.format(
        meas_objects=meas_objects_2_3,
        meas_4_2_4=fill_measIdToAddModList_element(meas_ID=4, meas_object_ID=2, report_config_ID=4),
        meas_5_3_5=fill_measIdToAddModList_element(meas_ID=5, meas_object_ID=3, report_config_ID=5),
        meas_6_3_4=fill_measIdToAddModList_element(meas_ID=6, meas_object_ID=3, report_config_ID=4))

A4_measurementReport_RSRQ_B_B12_template = """
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
                    physCellId eq 54
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
                    physCellId eq 52
                    and measResult contains
                    (
                        cellResults contains
                        (
                            resultsSSB-Cell contains
                            (
                                rsrq eq {rsrq}
                            )
                        )
                    )
                )
            )
        )
    )
"""

A4_measurementReport_RSRQ_B_B12 = A4_measurementReport_RSRQ_B_B12_template.format(
    rsrq=95)

A4_measurementReport_RSRPANDRSRQ_B_B12_template = """
    measurementReport contains
    (
        measResults contains
        (
            measId eq 5
            and measResultServingMOList contains
            (
                servCellId eq 0
                and measResultServingCell contains
                (
                    physCellId eq 54
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
                    physCellId eq 53
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
        )
    )
"""

A4_measurementReport_RSRPANDRSRQ_B_B12 = A4_measurementReport_RSRPANDRSRQ_B_B12_template.format(
    rsrp=95,
    rsrq=95)

Meas_Config_With_A4_Measurements_Deconfiguration_In_RRC_Reconf_B_B12 = """
    measConfig contains
     (
        measIdToRemoveList contains (4,5,6)
        and length(measIdToRemoveList) eq 3
        and measGapConfig contains
        (
            gapUE contains
             (
                 release is present
             )
        )
    )
"""

Meas_Config_With_A2_Measurements_Configuration_In_RRC_Reconf_B_B12 = """
    measConfig contains
    (
        measObjectToAddModList contains
        (
            measObjectId eq 2
            and ssbFrequency eq 430850
            and freqBandIndicatorNR eq 66
        )
        and measObjectToAddModList contains
        (
            measObjectId eq 3
            and ssbFrequency eq 125070
            and freqBandIndicatorNR eq 71
        )
        and reportConfigToAddModList contains
        (
            reportConfigId eq 6
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
                                rsrp eq "TRUE"
                                and rsrq eq "TRUE"
                                and sinr eq "TRUE"
                            )
                            and eventId contains
                            (
                                eventA2 is present
                                and reportOnLeave eq "FALSE"
                                and hysteresis eq 0
                                and timeToTrigger eq "ms2560"
                            )
                            and reportAmount eq "r4"
                            and reportInterval eq "ms1024"
                            and rsType eq "ssb"
                            and a2-Threshold contains (rsrq eq 49)
                            and maxReportCells eq 8
                            and reportQuantityRS-Indexes contains
                            (
                                rsrp eq "TRUE"
                                and rsrq eq "TRUE"
                                and sinr eq "TRUE"
                            )
                        )
                    )
                )
            )
        )
        and reportConfigToAddModList contains
        (
            reportConfigId eq 7
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
                                rsrp eq "TRUE"
                                and rsrq eq "TRUE"
                                and sinr eq "TRUE"
                            )
                            and eventId contains
                            (
                                eventA2 is present
                                and reportOnLeave eq "FALSE"
                                and hysteresis eq 10
                                and timeToTrigger eq "ms480"
                            )
                            and reportAmount eq "r4"
                            and reportInterval eq "ms1024"
                            and rsType eq "ssb"
                            and a2-Threshold contains (rsrp eq 10)
                            and maxReportCells eq 8
                            and reportQuantityRS-Indexes contains
                            (
                                rsrp eq "TRUE"
                                and rsrq eq "TRUE"
                                and sinr eq "TRUE"
                            )
                        )
                    )
                )
            )
        )
        and measIdToAddModList contains
        (
            measId eq 7
            and measObjectId eq 2
            and reportConfigId eq 6
        )
        and measIdToAddModList contains
        (
            measId eq 8
            and measObjectId eq 3
            and reportConfigId eq 6
        )
        and measIdToAddModList contains
        (
            measId eq 9
            and measObjectId eq 1
            and reportConfigId eq 7
        )
    )
    """

A2_measurementReport_PCell_Change = """
    measurementReport contains
    (
        measResults contains
        (
            measId eq 9
            and measResultServingMOList contains
            (
                servCellId eq 0
                and measResultServingCell contains
                (
                    physCellId eq 54
                    and measResult contains
                    (
                        cellResults contains
                        (
                            resultsSSB-Cell contains
                            (
                                rsrp eq 5
                                and rsrq eq 10
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
                                rsrp eq 90
                                and rsrq eq 90
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
                                rsrp eq 30
                                and rsrq eq 60
                            )
                        )
                    )
                )
            )
        )
    )
"""


Meas_Config_With_A4_and_A2_Measurements_Deconfiguration_In_RRC_Reconf_B_B12 = """
    measConfig contains
    (
        measObjectToRemoveList contains
        (
            1
        )
        and measObjectToRemoveList contains
        (
           3
        )
        and measObjectToAddModList contains
        (
            measObjectId eq 2
            and ssbFrequency eq 430850
            and freqBandIndicatorNR eq 66
        )
        and reportConfigToRemoveList contains
        (
            1
        )
        and reportConfigToRemoveList contains
        (
            4
        )
        and reportConfigToRemoveList contains
        (
            5
        )
        and reportConfigToRemoveList contains
        (
            6
        )
        and reportConfigToRemoveList contains
        (
            7
        )
        and measIdToRemoveList contains
        (
            7
        )
        and measIdToRemoveList contains
        (
            8
        )
        and measIdToRemoveList contains
        (
            9
        )
        and measIdToRemoveList contains
        (
            1
        )
    )
    and nonCriticalExtension contains
    (
        masterCellGroup contains
        (
            CONTAINING contains
            (
                sCellToReleaseList contains
                (
                    1
                )
                and sCellToReleaseList contains
                (
                    2
                )
            )
        )
    )
    """

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

selected_SCells_for_3CC_CA_in_UE_CON_MOD_REQ = selected_SCells_for_3CC_CA_in_UE_CON_MOD_REQ_template.format(
    nRCellIdentity_1="0b000000000000000000000100000000000010",
    nRCellIdentity_2="0b000000000000000000000100000000000011")

CSI_meas_config_for_3CC_CA_in_UE_CON_MOD_RESP = """
    csi-MeasConfig contains
    (
        csi-ReportConfigToAddModList is present
        and length(csi-ReportConfigToAddModList) eq 2
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
    )
    """

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

selected_SCells_for_3CC_UE_CA_in_UE_CON_MOD_RESP = \
    selected_SCells_for_3CC_CA_in_UE_CON_MOD_RESP_template.format(
        scell_physcellid_1=52,
        scell_physcellid_2=53)

HO_PREP_in_UE_CON_MOD_REQ = """
    spCellConfig contains
    (reconfigurationWithSync contains
        (spCellConfigCommon contains
            (physCellId eq 54)
        )
    )
    """

SCell_ToBeRemoved_List_in_UE_CON_MOD_REQ_template = """
        SCell-ToBeRemoved-List is present
        and length(SCell-ToBeRemoved-List) eq 2
        and SCell-ToBeRemoved-List contains
        (
            nRCellIdentity eq "{nRCellIdentity_1}"
        )
        and SCell-ToBeRemoved-List contains
        (
            nRCellIdentity eq "{nRCellIdentity_2}"
        )
        """

SCell_ToBeRemoved_List_in_UE_CON_MOD_REQ = \
    SCell_ToBeRemoved_List_in_UE_CON_MOD_REQ_template.format(
        nRCellIdentity_1="0b000000000000000000000100000000000010",
        nRCellIdentity_2="0b000000000000000000000100000000000011")

spCellConfig_in_UE_CON_MOD_RESP = """
    DUtoCURRCInformation contains
    (
        CellGroupConfig contains
        (
            spCellConfig contains
            (
                csi-MeasConfig contains
                (
                    csi-ReportConfigToReleaseList is present
                    and length(csi-ReportConfigToReleaseList) eq 4
                    and csi-ReportConfigToReleaseList contains (0, 2, 13, 14)
                )
            )
            and sCellToReleaseList is present
            and length(sCellToReleaseList) eq 2
            and sCellToReleaseList contains (1,2)
        )
    )
"""

Meas_Config_With_A4_Measurements_Configuration_In_RRC_Reconf_A_B12 = \
    Meas_Config_With_A4_Measurements_Configuration_In_RRC_Reconf_A_B12_template.format(
        meas_objects=meas_objects_2_3_A4,
        meas_1_2_1=fill_measIdToAddModList_element(meas_ID=1, meas_object_ID=2, report_config_ID=1),
        meas_2_3_2=fill_measIdToAddModList_element(meas_ID=2, meas_object_ID=3, report_config_ID=2),
        meas_3_3_1=fill_measIdToAddModList_element(meas_ID=3, meas_object_ID=3, report_config_ID=1))

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

selected_SCells_for_3CC_CA_in_UE_CON_MOD_REQ = selected_SCells_for_3CC_CA_in_UE_CON_MOD_REQ_template.format(
    nRCellIdentity_1="0b000000000000000000000100000000000010",
    nRCellIdentity_2="0b000000000000000000000100000000000011")

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

selected_SCells_for_3CC_UE_CA_in_UE_CON_MOD_RESP = \
    selected_SCells_for_3CC_CA_in_UE_CON_MOD_RESP_template.format(
        scell_physcellid_1=52,
        scell_physcellid_2=53)

SCell_ToBeRemoved_List_in_UE_CON_MOD_REQ_A_B12_template = """
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
"""

SCell_ToBeRemoved_List_in_UE_CON_MOD_REQ_Cell2_A_B12 = \
    SCell_ToBeRemoved_List_in_UE_CON_MOD_REQ_A_B12_template.format(
        nRCellIdentity="0b000000000000000000000100000000000010")

SCell_ToBeRemoved_List_in_UE_CON_MOD_REQ_Cell3_A_B12 = \
    SCell_ToBeRemoved_List_in_UE_CON_MOD_REQ_A_B12_template.format(
        nRCellIdentity="0b000000000000000000000100000000000011")

spCellConfig_in_UE_CON_MOD_RESP_Cell2_A_B12 = """
    sCellToReleaseList is present
    and length(sCellToReleaseList) eq 1
    and sCellToReleaseList contains (1)
"""

spCellConfig_in_UE_CON_MOD_RESP_Cell3_A_B12 = """
    sCellToReleaseList is present
    and length(sCellToReleaseList) eq 1
    and sCellToReleaseList contains (2)
"""

spCellConfig_in_UE_CON_MOD_RESP_A_B12 = """
    sCellToReleaseList is present
    and length(sCellToReleaseList) eq 2
    and sCellToReleaseList contains (1,2)
"""

Meas_Config_With_A4_Measurements_Configuration_In_RRC_Reconf_B_B10_template = """
    measConfig contains
    (
        {meas_objects}
        and
        reportConfigToAddModList contains
        (
            reportConfigId eq 9
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
                                rsrp eq "TRUE"
                                and rsrq eq "TRUE"
                                and sinr eq "TRUE"
                            )
                            and eventId contains (eventA4 is present)
                            and a4-Threshold contains (rsrp eq 80)
                        )
                    )
                )
            )
        )
        and reportConfigToAddModList contains
        (
            reportConfigId eq 10
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
                                rsrp eq "TRUE"
                                and rsrq eq "TRUE"
                                and sinr eq "TRUE"
                            )
                            and eventId contains (eventA4 is present)
                            and a4-Threshold contains (rsrq eq 90)
                        )
                    )
                )
            )
        )
        {meas_23_11_11}
        {meas_24_12_12}
        {meas_25_13_11}
        {meas_26_13_12}
        {meas_27_14_11}
        {meas_28_15_12}
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

meas_objects_11_12_13_14_15 = """
        measObjectToAddModList contains
        (
            (measObjectId eq 8) and (ssbFrequency eq 392410) and (freqBandIndicatorNR eq 25)
        )
        and
        measObjectToAddModList contains
        (
            (measObjectId eq 9) and (ssbFrequency eq 430850) and (freqBandIndicatorNR eq 66)
        )
        and
        measObjectToAddModList contains
        (
            (measObjectId eq 10) and (ssbFrequency eq 125070) and (freqBandIndicatorNR eq 71)
        )
        and
        measObjectToAddModList contains
        (
            (measObjectId eq 11) and (ssbFrequency eq 529950) and (freqBandIndicatorNR eq 41)
        )
        and
        measObjectToAddModList contains
        (
            (measObjectId eq 12) and (ssbFrequency eq 623328) and (freqBandIndicatorNR eq 77)
        )
"""

Meas_Config_With_A4_Measurements_Configuration_In_RRC_Reconf_B_B10 = \
    Meas_Config_With_A4_Measurements_Configuration_In_RRC_Reconf_B_B10_template.format(
        meas_objects=meas_objects_11_12_13_14_15,
        meas_23_11_11=fill_measIdToAddModList_element(meas_ID=21, meas_object_ID=8, report_config_ID=9),
        meas_24_12_12=fill_measIdToAddModList_element(meas_ID=22, meas_object_ID=9, report_config_ID=10),
        meas_25_13_11=fill_measIdToAddModList_element(meas_ID=23, meas_object_ID=10, report_config_ID=9),
        meas_26_13_12=fill_measIdToAddModList_element(meas_ID=24, meas_object_ID=10, report_config_ID=10),
        meas_27_14_11=fill_measIdToAddModList_element(meas_ID=25, meas_object_ID=11, report_config_ID=9),
        meas_28_15_12=fill_measIdToAddModList_element(meas_ID=26, meas_object_ID=12, report_config_ID=10))

Meas_Config_With_A2_A3_A5_Measurements_Configuration_In_RRC_Reconf_B_B10 = """
    measConfig contains
    (
        measObjectToAddModList contains
        (
            (measObjectId eq 4) and (ssbFrequency eq 506430) and (freqBandIndicatorNR eq 41)
        )
        and
        reportConfigToAddModList contains
        (
            reportConfigId eq 6
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
                                rsrp eq "TRUE"
                                and rsrq eq "TRUE"
                                and sinr eq "TRUE"
                            )
                            and eventId contains
                            (
                                eventA2 is present
                                and reportOnLeave eq "FALSE"
                                and hysteresis eq 0
                                and timeToTrigger eq "ms480"
                            )
                            and a2-Threshold contains (rsrp eq 34)
                            and maxReportCells eq 8
                            and reportQuantityRS-Indexes contains
                            (
                                rsrp eq "TRUE"
                                and rsrq eq "TRUE"
                                and sinr eq "TRUE"
                            )
                        )
                    )
                )
            )
        )
        and reportConfigToAddModList contains
        (
            reportConfigId eq 7
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
                                rsrp eq "TRUE"
                                and rsrq eq "TRUE"
                                and sinr eq "TRUE"
                            )
                            and eventId contains
                            (
                                eventA3 is present
                                and reportOnLeave eq "FALSE"
                                and hysteresis eq 0
                                and timeToTrigger eq "ms40"
                            )
                            and a3-Offset contains
                            (
                                rsrp is present
                                and rsrp eq 20
                            )
                            and maxReportCells eq 8
                            and reportQuantityRS-Indexes contains
                            (
                                rsrp eq "TRUE"
                                and rsrq eq "TRUE"
                                and sinr eq "TRUE"
                            )
                        )
                    )
                )
            )
        )
        and reportConfigToAddModList contains
        (
            reportConfigId eq 8
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
                                rsrp eq "TRUE"
                                and rsrq eq "TRUE"
                                and sinr eq "TRUE"
                            )
                            and eventId contains
                            (
                                eventA5 is present
                                and reportOnLeave eq "FALSE"
                                and hysteresis eq 0
                                and timeToTrigger eq "ms40"
                            )
                            and a5-Threshold1 contains
                            (
                                rsrp is present
                                and rsrp eq 51
                            )
                            and a5-Threshold2 contains
                            (
                                rsrp is present
                                and rsrp eq 62
                            )
                            and maxReportCells eq 8
                            and reportQuantityRS-Indexes contains
                            (
                                rsrp eq "TRUE"
                                and rsrq eq "TRUE"
                                and sinr eq "TRUE"
                            )
                        )
                    )
                )
            )
        )
        {meas_18_9_6}
        {meas_19_9_7}
        {meas_20_9_8}
    )
    """

Meas_Config_With_A2_A3_A5_Measurements_Configuration_In_RRC_Reconf_B_B10 = \
    Meas_Config_With_A2_A3_A5_Measurements_Configuration_In_RRC_Reconf_B_B10.format(
        meas_18_9_6=fill_measIdToAddModList_element(meas_ID=18, meas_object_ID=4, report_config_ID=6),
        meas_19_9_7=fill_measIdToAddModList_element(meas_ID=19, meas_object_ID=4, report_config_ID=7),
        meas_20_9_8=fill_measIdToAddModList_element(meas_ID=20, meas_object_ID=4, report_config_ID=8))

Meas_Config_With_A4_Measurements_Configuration_In_RRC_Reconf_B_B3_template = """
    measConfig contains
    (
        {meas_objects}
        and
        reportConfigToAddModList contains
        (
            reportConfigId eq 5
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
                                rsrp eq "TRUE"
                                and rsrq eq "TRUE"
                                and sinr eq "TRUE"
                            )
                            and eventId contains (eventA4 is present)
                            and a4-Threshold contains (rsrp eq 80)
                        )
                    )
                )
            )
        )
        and reportConfigToAddModList contains
        (
            reportConfigId eq 6
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
                                rsrp eq "TRUE"
                                and rsrq eq "TRUE"
                                and sinr eq "TRUE"
                            )
                            and eventId contains (eventA4 is present)
                            and a4-Threshold contains (rsrq eq 90)
                        )
                    )
                )
            )
        )
        {meas_33_10_5}
        {meas_34_11_6}
        {meas_35_12_5}
        {meas_36_12_6}
        {meas_37_13_5}
        {meas_38_14_6}
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

meas_objects_10_11_12_13_14 = """
        measObjectToAddModList contains
        (
            (measObjectId eq 10) and (ssbFrequency eq 392410) and (freqBandIndicatorNR eq 25)
        )
        and
        measObjectToAddModList contains
        (
            (measObjectId eq 11) and (ssbFrequency eq 430850) and (freqBandIndicatorNR eq 66)
        )
        and
        measObjectToAddModList contains
        (
            (measObjectId eq 12) and (ssbFrequency eq 125070) and (freqBandIndicatorNR eq 71)
        )
        and
        measObjectToAddModList contains
        (
            (measObjectId eq 13) and (ssbFrequency eq 529950) and (freqBandIndicatorNR eq 41)
        )
        and
        measObjectToAddModList contains
        (
            (measObjectId eq 14) and (ssbFrequency eq 623328) and (freqBandIndicatorNR eq 77)
        )
"""

Meas_Config_With_A4_Measurements_Configuration_In_RRC_Reconf_B_B3 = \
    Meas_Config_With_A4_Measurements_Configuration_In_RRC_Reconf_B_B3_template.format(
        meas_objects=meas_objects_10_11_12_13_14,
        meas_33_10_5=fill_measIdToAddModList_element(meas_ID=33, meas_object_ID=10, report_config_ID=5),
        meas_34_11_6=fill_measIdToAddModList_element(meas_ID=34, meas_object_ID=11, report_config_ID=6),
        meas_35_12_5=fill_measIdToAddModList_element(meas_ID=35, meas_object_ID=12, report_config_ID=5),
        meas_36_12_6=fill_measIdToAddModList_element(meas_ID=36, meas_object_ID=12, report_config_ID=6),
        meas_37_13_5=fill_measIdToAddModList_element(meas_ID=37, meas_object_ID=13, report_config_ID=5),
        meas_38_14_6=fill_measIdToAddModList_element(meas_ID=38, meas_object_ID=14, report_config_ID=6))

Meas_Config_With_A1_A3_A5_Measurements_Configuration_In_RRC_Reconf_B_B7_template = """
    measConfig contains
    (
        measObjectToAddModList contains
        (
            (measObjectId eq 1) and (ssbFrequency eq 506430) and (freqBandIndicatorNR eq 41)
        )
        and
        reportConfigToAddModList contains
        (
            reportConfigId eq 10
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
                                rsrp eq "TRUE"
                                and rsrq eq "TRUE"
                                and sinr eq "TRUE"
                            )
                            and eventId contains
                            (
                                eventA1 is present
                                and reportOnLeave eq "FALSE"
                                and hysteresis eq 0
                                and timeToTrigger eq "ms480"
                            )
                            and a1-Threshold contains (rsrp eq 60)
                            and maxReportCells eq 8
                            and reportQuantityRS-Indexes contains
                            (
                                rsrp eq "TRUE"
                                and rsrq eq "TRUE"
                                and sinr eq "TRUE"
                            )
                        )
                    )
                )
            )
        )
        and reportConfigToAddModList contains
        (
            reportConfigId eq 11
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
                                rsrp eq "TRUE"
                                and rsrq eq "TRUE"
                                and sinr eq "TRUE"
                            )
                            and eventId contains
                            (
                                eventA3 is present
                                and reportOnLeave eq "FALSE"
                                and hysteresis eq 0
                                and timeToTrigger eq "ms128"
                            )
                            and a3-Offset contains
                            (
                                rsrp is present
                                and rsrp eq 6
                            )
                            and maxReportCells eq 8
                            and reportQuantityRS-Indexes contains
                            (
                                rsrp eq "TRUE"
                                and rsrq eq "TRUE"
                                and sinr eq "TRUE"
                            )
                        )
                    )
                )
            )
        )
        and reportConfigToAddModList contains
        (
            reportConfigId eq 12
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
                                rsrp eq "TRUE"
                                and rsrq eq "TRUE"
                                and sinr eq "TRUE"
                            )
                            and eventId contains
                            (
                                eventA5 is present
                                and reportOnLeave eq "FALSE"
                                and hysteresis eq 0
                                and timeToTrigger eq "ms512"
                            )
                            and a5-Threshold1 contains
                            (
                                rsrq is present
                                and rsrq eq 30
                            )
                            and a5-Threshold2 contains
                            (
                                rsrq is present
                                and rsrq eq 70
                            )
                            and maxReportCells eq 8
                            and reportQuantityRS-Indexes contains
                            (
                                rsrp eq "TRUE"
                                and rsrq eq "TRUE"
                                and sinr eq "TRUE"
                            )
                        )
                    )
                )
            )
        )
        {meas_30_1_10}
        {meas_31_2_11}
        {meas_32_3_11}
        {meas_33_4_11}
        {meas_34_5_11}
        {meas_35_6_11}
        {meas_36_2_12}
        {meas_37_3_12}
        {meas_38_4_12}
        {meas_39_5_12}
        {meas_40_6_12}
        and measIdToRemoveList contains (29)
        and length(measIdToRemoveList) eq 1
        and reportConfigToRemoveList contains (9)
        and length(reportConfigToRemoveList) eq 1
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

Meas_Config_With_A2_Measurement_Restored_Configuration_In_RRC_Reconf_B_B7 = """
    measConfig contains
    (
        measObjectToAddModList contains
        (
            (measObjectId eq 1) and (ssbFrequency eq 506430) and (freqBandIndicatorNR eq 41)
        )
        and
        reportConfigToAddModList contains
        (
            reportConfigId eq 9
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
                                rsrp eq "TRUE"
                                and rsrq eq "TRUE"
                                and sinr eq "TRUE"
                            )
                            and eventId contains (eventA2 is present)
                            and a2-Threshold contains (rsrp eq 34)
                        )
                    )
                )
            )
        )
        and measIdToAddModList contains
        (
            measId eq 29
            and measObjectId eq 1
            and reportConfigId eq 9
        )
        and reportConfigToRemoveList contains (6,7,8)
        and length(reportConfigToRemoveList) eq 3
        and measIdToRemoveList contains (18,19,20,21,22,23,24,25,26,27,28)
        and length(measIdToRemoveList) eq 11
        and measGapConfig is not present
    )
    """

Meas_Config_With_A1_A3_A5_Measurements_Configuration_With_Meas_Gap_Recovery_In_RRC_Reconf_B_B7 = \
    Meas_Config_With_A1_A3_A5_Measurements_Configuration_In_RRC_Reconf_B_B7_template.format(
        meas_30_1_10=fill_measIdToAddModList_element(meas_ID=30, meas_object_ID=1, report_config_ID=10),
        meas_31_2_11=fill_measIdToAddModList_element(meas_ID=31, meas_object_ID=2, report_config_ID=11),
        meas_32_3_11=fill_measIdToAddModList_element(meas_ID=32, meas_object_ID=3, report_config_ID=11),
        meas_33_4_11=fill_measIdToAddModList_element(meas_ID=33, meas_object_ID=4, report_config_ID=11),
        meas_34_5_11=fill_measIdToAddModList_element(meas_ID=34, meas_object_ID=5, report_config_ID=11),
        meas_35_6_11=fill_measIdToAddModList_element(meas_ID=35, meas_object_ID=6, report_config_ID=11),
        meas_36_2_12=fill_measIdToAddModList_element(meas_ID=36, meas_object_ID=2, report_config_ID=12),
        meas_37_3_12=fill_measIdToAddModList_element(meas_ID=37, meas_object_ID=3, report_config_ID=12),
        meas_38_4_12=fill_measIdToAddModList_element(meas_ID=38, meas_object_ID=4, report_config_ID=12),
        meas_39_5_12=fill_measIdToAddModList_element(meas_ID=39, meas_object_ID=5, report_config_ID=12),
        meas_40_6_12=fill_measIdToAddModList_element(meas_ID=40, meas_object_ID=6, report_config_ID=12))

A1_measurementReport_B_B7 = """
    measurementReport contains
    (
        measResults contains
        (
            measId eq 30
            and measResultServingMOList contains
            (
                servCellId eq 0
                and measResultServingCell contains
                (
                    physCellId eq 54
                    and measResult contains
                    (
                        cellResults contains
                        (
                            resultsSSB-Cell contains
                            (
                                rsrp eq 90
                            )
                        )
                    )
                )
            )
        )
    )
"""
Meas_Config_With_A2_Measurement_Configuration_and_A1_A3_A5_Measurements_Deconfiguration_B_B7_template = """
    measConfig contains
    (
        measObjectToAddModList contains
        (
            (measObjectId eq 1) and (ssbFrequency eq 506430) and (freqBandIndicatorNR eq 41)
        )
        and reportConfigToAddModList contains
        (
            reportConfigId eq 13
            and
            {report_config_a2}
        )
        and measIdToAddModList contains
        (
            measId eq 41
            and measObjectId eq 1
            and reportConfigId eq 13
        )
        and measIdToRemoveList contains (30,31,32,33,34,35,36,37,38,39,40)
        and length(measIdToRemoveList) eq 11
        and reportConfigToRemoveList contains (10,11,12)
        and length(reportConfigToRemoveList) eq 3
        and measGapConfig contains
        (
            gapUE contains
             (
                 release is present
             )
        )
    )
"""

Meas_Config_With_A2_Measurement_Configuration_and_A1_A3_A5_Measurements_Deconfiguration_In_RRC_Reconf_B_B7 = \
    Meas_Config_With_A2_Measurement_Configuration_and_A1_A3_A5_Measurements_Deconfiguration_B_B7_template.format(
        report_config_a2=report_config_A2_A_B5)

Meas_Config_With_A4_Measurements_2nd_Configuration_In_RRC_Reconf_B_B7 = \
    Meas_Config_With_A4_Measurements_2nd_Configuration_In_RRC_Reconf_A_B5_template.format(
        meas_objects="",
        meas_A=fill_measIdToAddModList_wo_and_element(meas_ID=42, meas_object_ID=2, report_config_ID=2),
        meas_B=fill_measIdToAddModList_element(meas_ID=43, meas_object_ID=3, report_config_ID=3),
        meas_C=fill_measIdToAddModList_element(meas_ID=44, meas_object_ID=4, report_config_ID=2),
        meas_D=fill_measIdToAddModList_element(meas_ID=45, meas_object_ID=4, report_config_ID=3),
        meas_E=fill_measIdToAddModList_element(meas_ID=46, meas_object_ID=5, report_config_ID=2),
        meas_F=fill_measIdToAddModList_element(meas_ID=47, meas_object_ID=6, report_config_ID=3))

meas_objects_2_3_4_5_BB16 = """
        measObjectToAddModList contains
        (
            (measObjectId eq 5) and (ssbFrequency eq 392410) and (freqBandIndicatorNR eq 25)
        )
        and
        measObjectToAddModList contains
        (
            (measObjectId eq 2) and (ssbFrequency eq 125070) and (freqBandIndicatorNR eq 71)
        )
        and
        measObjectToAddModList contains
        (
            (measObjectId eq 3) and (ssbFrequency eq 529950) and (freqBandIndicatorNR eq 41)
        )
        and
        measObjectToAddModList contains
        (
            (measObjectId eq 4) and (ssbFrequency eq 623328) and (freqBandIndicatorNR eq 77)
        )
"""

Meas_Config_With_A4_Measurements_Configuration_In_RRC_Reconf_B_B13 = \
    Meas_Config_With_A4_Measurements_Configuration_In_RRC_Reconf_template.format(
        meas_objects=meas_objects_2_3_4_5_BB16,
        meas_1_2_1=fill_measIdToAddModList_element(meas_ID=1, meas_object_ID=2, report_config_ID=1),
        meas_2_3_2=fill_measIdToAddModList_element(meas_ID=2, meas_object_ID=2, report_config_ID=2),
        meas_3_4_1=fill_measIdToAddModList_element(meas_ID=3, meas_object_ID=3, report_config_ID=1),
        meas_4_4_2=fill_measIdToAddModList_element(meas_ID=4, meas_object_ID=4, report_config_ID=2),
        meas_5_5_1=fill_measIdToAddModList_element(meas_ID=5, meas_object_ID=5, report_config_ID=1),
        meas_6_6_2="")


A4_measurementReport_with_two_measured_PCIs_BB13 = """
    measurementReport contains
    (
        measResults contains
        (
            measId eq 5
            and
            measResultNeighCells contains
            (
            measResultListNR contains
                (
                    physCellId eq 51
                    and measResult contains
                    (
                        cellResults contains
                        (
                            rsrp eq 95
                        )
                    )
                )
            )
            and
            measResultNeighCells contains
            (
            measResultListNR contains
                (
                    physCellId eq 52
                    and measResult contains
                    (
                        cellResults contains
                        (
                            rsrp eq 90
                        )
                    )
                )
            )
        )
    )
"""

Meas_Config_With_A4_Measurements_Deconfiguration_In_RRC_Reconf_B_B13 = """
    measConfig contains
     (
        measIdToRemoveList contains (1,2,3,4,5)
        and length(measIdToRemoveList) eq 5
        and measGapConfig contains
        (
            gapUE contains
             (
                 release is present
             )
        )
    )
"""

selected_SCells_for_2CC_CA_in_UE_CON_MOD_REQ_template = """
        SCell-ToBeSetupMod-List is present and length(SCell-ToBeSetupMod-List) eq 1
        and
        SCell-ToBeSetupMod-List contains
        (
            (sCellIndex eq {scell_index}) and (nRCellIdentity eq "{nRCellIdentity}")
        )
        """

selected_SCells_for_2CC_CA_in_UE_CON_MOD_REQ_BB13 = selected_SCells_for_2CC_CA_in_UE_CON_MOD_REQ_template.format(
    scell_index="1",
    nRCellIdentity="0b000000000000000000000100000000000001")

selected_SCells_for_sCellToAddModList_BB13 = \
    selected_SCells_for_sCellToAddModList_template.format(
        number_of_selected_scells=1,
        scell_1=sCellToAddModList_template.format(scell_index=1, scell_physcellid=51),
        scell_2="",
        scell_3="",
        scell_4="",
        scell_5="")

meas_object_5_for_SCell = """
        measObjectToAddModList contains
        (
            (measObjectId eq 5) and (ssbFrequency eq 392410) and (freqBandIndicatorNR eq 25)
        )
"""

SCell_Addition_With_Meas_Config_containging_A2_A6_Measurements_In_RRC_Reconf_B_B13_template = """
    measConfig contains
    (
        {meas_objects}
        and {report_config_A}
        and {report_config_B}
        {meas_A}
        {meas_B}
    )
    and
    {scell_addition}
    """

report_config_A2_SCell_release_B_B13 = report_config_A2_template.format(
    hysteresis=0,
    time_to_trigger="\"ms2560\"",
    type="rsrq",
    rsr=49)

report_config_A6_template = """
            reportConfig contains
            (
                reportConfigNR contains
                (
                    reportType contains
                    (
                        eventTriggered contains
                        (
                            eventId contains
                            (
                                eventA6 is present
                                and hysteresis eq {hysteresis}
                                and timeToTrigger eq {time_to_trigger}
                            )
                            and a6-Offset contains ({type} eq {rsr})
                            and reportInterval eq {report_interval}
                            and reportAmount eq {report_amount}
                        )
                    )
                )
            )
"""

report_config_A6_SCell_Swap_B_B13 = report_config_A6_template.format(
    hysteresis=0,
    time_to_trigger="\"ms480\"",
    type="rsrp",
    rsr=6,
    report_interval="\"ms1024\"",
    report_amount="\"inf\"")

SCell_Addition_With_Meas_Config_containging_A2_A6_Measurements_In_RRC_Reconf_B_B13 = \
    SCell_Addition_With_Meas_Config_containging_A2_A6_Measurements_In_RRC_Reconf_B_B13_template.format(
        meas_objects=meas_object_5_for_SCell,
        report_config_A=report_config_A2_SCell_release_B_B13,
        report_config_B=report_config_A6_SCell_Swap_B_B13,
        meas_A=fill_measIdToAddModList_element(meas_ID=6, meas_object_ID=5, report_config_ID=3),
        meas_B=fill_measIdToAddModList_element(meas_ID=7, meas_object_ID=5, report_config_ID=4),
        scell_addition=selected_SCells_for_sCellToAddModList_BB13)

A6_measurementReport_SCell_Swap_BB13 = """
    measurementReport contains
    (
        measResults contains
        (
            measId eq 7
            and measResultServingMOList contains
            (
                measResultServingCell contains
                (
                    physCellId eq 54
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
                measResultServingCell contains
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
            and
            measResultNeighCells contains
            (
                measResultListNR contains
                (
                    physCellId eq 52
                    and measResult contains
                    (
                        cellResults contains
                        (
                            rsrp eq 95
                        )
                    )
                )
            )
        )
    )
"""

selected_SCells_for_2CC_CA_in_UE_CON_MOD_REQ_after_Scell_Swap_BB13 = \
    selected_SCells_for_2CC_CA_in_UE_CON_MOD_REQ_template.format(
        scell_index="2",
        nRCellIdentity="0b000000000000000000000100000000000010")

SCell_ToBeRemoved_List_in_UE_CON_MOD_REQ_after_Scell_Swap_BB13 = \
    SCell_ToBeRemoved_List_in_UE_CON_MOD_REQ_A_B12_template.format(
        nRCellIdentity="0b000000000000000000000100000000000001")

selected_SCells_for_sCellToAddModList_after_SCell_Swap_BB13 = \
    selected_SCells_for_sCellToAddModList_template.format(
        number_of_selected_scells=1,
        scell_1=sCellToAddModList_template.format(scell_index=2, scell_physcellid=52),
        scell_2="",
        scell_3="",
        scell_4="",
        scell_5="")

spCellConfig_in_UE_CON_MOD_RESP_Cell1_release_BB13 = spCellConfig_in_UE_CON_MOD_RESP_Cell2_A_B12

downlinkConfigCommon_in_UE_CON_MOD_RESP_after_SCell_Swap_B13 = """
    downlinkConfigCommon contains
    (
        absoluteFrequencySSB eq 392410
        and frequencyBandList contains (25)
    )
"""

measIdToAddModList_after_SCell_Swap_BB13_template = """
    {meas_A}
    {meas_B}
"""

measIdToAddModList_after_SCell_Swap_BB13 = \
    measIdToAddModList_after_SCell_Swap_BB13_template.format(
        meas_A=fill_measIdToAddModList_wo_and_element(meas_ID=6, meas_object_ID=5, report_config_ID=3),
        meas_B=fill_measIdToAddModList_element(meas_ID=7, meas_object_ID=5, report_config_ID=4),
    )

A1_measurementReport_RSRP_B_B14_template = """
    measurementReport contains
    (
        measResults contains
        (
            measId eq 1
            and measResultServingMOList contains
            (
                servCellId eq 8
                and measResultServingCell contains
                (
                    physCellId eq 54
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

A1_measurementReport_RSRP_B_B14 = A1_measurementReport_RSRP_B_B14_template.format(
    rsrp=90)

A1_Configuration_UE_CON_MOD_REQ_template = """
    cG-ConfigInfo contains
    (
        CG-ConfigInfo contains
        (
            candidateCellInfoListMN contains
            (
                ssbFrequency eq {ssbFrequency}
                and measResultNeighCellListNR contains
                (
                    physCellId eq {physCellId}
                )
            )
        )
    )
"""

A1_Configuration_UE_CON_MOD_REQ = A1_Configuration_UE_CON_MOD_REQ_template.format(
    ssbFrequency=506430,
    physCellId=54)

A1_Configuration_SgNBAdditionRequestAcknowledge = """
    SgNBtoMeNBContainer contains
    (
        CG-Config contains
        (
            criticalExtensions contains
            (
                cg-Config contains
                (
                    scg-CellGroupConfig contains
                    (
                        CONTAINING contains
                        (
                            criticalExtensions contains
                            (
                                rrcReconfiguration contains
                                (
                                    secondaryCellGroup contains
                                    (
                                        CONTAINING contains
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
                                            )
                                        )
                                    )
                                    and measConfig contains
                                    (
                                        measObjectToAddModList contains
                                        (
                                            measObjectId eq 1
                                            and measObject contains
                                            (
                                                measObjectNR contains
                                                (
                                                    ssbFrequency eq 506430
                                                    and freqBandIndicatorNR eq 41
                                                )
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
                                                                    a1-Threshold contains (rsrp eq 80)
                                                                    and hysteresis eq 0
                                                                    and timeToTrigger eq "ms320"
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
                                )
                            )
                        )
                    )
                )
            )
        )
    )
"""

successful_UE_reconfig_SgNBReconfigurationComplete = """
    ResponseInformationSgNBReconfComp contains
    (
        success-SgNBReconfComp contains
        (
            meNBtoSgNBContainer contains
            (
                RRCReconfigurationComplete contains
                (
                    criticalExtensions contains
                    (
                        rrcReconfigurationComplete is present
                    )
                )
            )
        )
    )
"""

selected_SCells_in_UE_CON_MOD_REQ_B_B14_template = """
   SCell-ToBeSetupMod-List contains
    (
        SCell-ToBeSetupMod-Item contains
        (
            sCellIndex eq 9
            and sCell-ID contains
            (
                nRCellIdentity eq "{nRCellIdentity}"
            )
        )
    )
"""

selected_SCells_in_UE_CON_MOD_REQ_B_B14 = \
    selected_SCells_in_UE_CON_MOD_REQ_B_B14_template.format(
        nRCellIdentity="0b000000000000000000000100000000000001")

selected_SCells_in_UE_CON_MOD_RES_B_B14 = """
    DUtoCURRCInformation contains
    (
        CellGroupConfig contains
        (
            spCellConfig contains
            (
                servCellIndex eq 8
            )
            and sCellToAddModList contains
            (
                sCellIndex eq 9
                and sCellConfigCommon contains
                (
                    physCellId eq 51
                )
            )
        )
    )
"""

measConfig_in_SgNBModificationRequired_B14 = """
SgNBtoMeNBContainer contains
    (
        spCellConfig contains
        (
            servCellIndex eq 8
        )
        and sCellToAddModList contains
        (
            sCellIndex eq 9
            and sCellConfigCommon contains
            (
                physCellId eq 51
            )
        )
        and measConfig contains
        (
            measObjectToAddModList contains
            (
                measObjectId eq 2
                and measObject contains
                (
                    measObjectNR contains
                    (
                        ssbFrequency eq 392410
                        and freqBandIndicatorNR eq 25
                    )
                )
            )
        )
        and measConfig contains
        (
            reportConfigToRemoveList contains (1)
        )
        and measConfig contains
        (
            reportConfigToAddModList contains
            (
                reportConfigId eq 2
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
                                    eventA2 contains
                                    (
                                        a2-Threshold contains (rsrq eq 49)
                                        and hysteresis eq 0
                                        and timeToTrigger eq "ms2560"
                                    )
                                )
                            )
                        )
                    )
                )
            )
        )
        and measConfig contains
        (
            measIdToRemoveList contains
            (
                1
            )
        )
        and measConfig contains
        (
            measIdToAddModList contains
            (
                measId eq 2
                and measObjectId eq 2
                and reportConfigId eq 2
            )
        )
    )
"""

RRCReconfCmp_in_SgnbModConf = """
    SgNBModificationConfirm contains
    (
        MeNBtoSgNBContainer contains
        (
            RRCReconfigurationComplete contains
            (
                criticalExtensions contains
                (
                    rrcReconfigurationComplete is present
                )
            )
        )
    )
"""

candidateCellInfoListMN_during_SgNBAdditionReq_template = """
    candidateCellInfoListMN contains
    (
        ssbFrequency eq {ssbFrequency_value}
        and measResultNeighCellListNR contains
        (
            physCellId eq {physCellId_value}
        )
    )
"""

candidateCellInfoListMN_during_SgNBAdditionReq = \
    candidateCellInfoListMN_during_SgNBAdditionReq_template.format(
        ssbFrequency_value=506430,
        physCellId_value=54
    )

candidateCellInfoListMN_during_SgNBAdditionReq_BB15 = \
    candidateCellInfoListMN_during_SgNBAdditionReq_template.format(
        ssbFrequency_value=392410,
        physCellId_value=51
    )

reconfigurationWithSync_template = """
    reconfigurationWithSync contains
    (
        physCellId eq {physCellId_value}
    )
"""

reconfigurationWithSync_sgnb_addition = \
    reconfigurationWithSync_template.format(
        physCellId_value=54
    )

meas_config_sgnb_addition_template = """
    measConfig contains
    (
        {meas_objects}
        and
        reportConfigToAddModList contains
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
                            eventId contains (eventA1 is present)
                            and a1-Threshold contains (rsrp eq 80)
                            and hysteresis eq 0
                            and timeToTrigger eq "ms320"
                        )
                    )
                )
            )
        )
        and
        {meas_A}
    )
"""

meas_objects_Cell4 = """
        measObjectToAddModList contains
        (
            (measObjectId eq 1) and (ssbFrequency eq 506430) and (freqBandIndicatorNR eq 41)
        )
"""

meas_config_sgnb_addition = \
    meas_config_sgnb_addition_template.format(
        meas_objects=meas_objects_Cell4,
        meas_A=fill_measIdToAddModList_wo_and_element(meas_ID=1, meas_object_ID=1, report_config_ID=1))

single_measurement_configuration_template = """
    measConfig contains
    (
        {meas_objects}
        and {report_config_A}
        {meas_A}
    )
    """

meas_object_1_for_HO_BB15 = """
        measObjectToAddModList contains
        (
            (measObjectId eq 1) and (ssbFrequency eq 392410) and (freqBandIndicatorNR eq 25)
        )
"""

report_config_A2_for_HO_BB15 = report_config_A2_template.format(
    hysteresis=0,
    time_to_trigger="\"ms480\"",
    type="rsrp",
    rsr=34)

A2_measurement_configuration_for_HO_B_B15 = \
    single_measurement_configuration_template.format(
        meas_objects=meas_object_1_for_HO_BB15,
        report_config_A=report_config_A2_for_HO_BB15,
        meas_A=fill_measIdToAddModList_element(meas_ID=1, meas_object_ID=1, report_config_ID=1))

reconfigurationWithSync_before_HO_BB15 = \
    reconfigurationWithSync_template.format(
        physCellId_value=51
    )

A2_measurementReport_B_B15 = A2_measurementReport_template.format(
    physCellId=51,
    rsrp=25)


measuredFrequenciesSN_NSA_template = """
        measuredFrequenciesSN contains
        (
            measuredFrequency eq {freq_1},measuredFrequency eq {freq_2}
        )
"""

measuredFrequenciesSN_NSA_BB15 = measuredFrequenciesSN_NSA_template.format(
    freq_1=392410,
    freq_2=506430)

measGapConfig_gaps_MeNB_configured_BB15 = """
measConfigMN contains
(
    measGapConfig contains
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
    and gapPurpose eq "perUE"
)
"""

reconfigurationWithSync_after_HO_BB15 = \
    reconfigurationWithSync_template.format(
        physCellId_value=54
    )


SgBModificationRequired_Meas_Config_With_A1_for_SCell_addition_after_HO_B_B15 = """
    measConfig contains
     (
         measObjectToAddModList contains
         (
             (measObjectId eq 2) and (ssbFrequency eq 506430) and (freqBandIndicatorNR eq 41)
         )
        and measObjectToRemoveList contains (1)
        and length(measObjectToRemoveList) eq 1
        and reportConfigToRemoveList contains (2,3)
        and length(reportConfigToRemoveList) eq 2
        and measIdToRemoveList contains (2,3)
        and length(measIdToRemoveList) eq 2
        and reportConfigToAddModList contains
        (
            reportConfigId eq 1
            and reportConfig contains
            (
                eventId contains
                (
                    eventA1 is present
                    and reportOnLeave eq "TRUE"
                    and hysteresis eq 0
                    and timeToTrigger eq "ms320"
                )
                and a1-Threshold contains (rsrp eq 80)
            )
        )
        and measIdToAddModList contains
        (
            measId eq 1
            and measObjectId eq 2
            and reportConfigId eq 1
        )
        and length(measObjectToAddModList) eq 1
        and length(reportConfigToAddModList) eq 1
        and length(measIdToAddModList) eq 1
    )
    """

meas_gap_release_after_HO_to_target_cell_B_B15 = """
    measConfigMN contains
    (
            measGapConfig is present
            and release is present
    )
"""

selected_SCells_for_sCellToAddModList_B_B15 = \
    selected_SCells_for_sCellToAddModList_template.format(
        number_of_selected_scells=1,
        scell_1=sCellToAddModList_template.format(scell_index=9, scell_physcellid=51),
        scell_2="",
        scell_3="",
        scell_4="",
        scell_5="")

selected_SCells_for_2CC_CA_in_UE_CON_MOD_REQ_after_HO_BB15 = \
    selected_SCells_for_2CC_CA_in_UE_CON_MOD_REQ_template.format(
        scell_index="9",
        nRCellIdentity="0b000000000000000000000100000000000001")

report_config_A2_SCell_release_B_B15 = report_config_A2_SCell_release_B_B13

SCell_Addition_With_Meas_Config_containing_A2_and_with_ScellToAddModList_template = """
    measConfig contains
    (
        {meas_objects}
        and {report_config_A}
        {meas_A}
        {reportConfigToRemoveList}
        {measIdToRemoveList}
    )
    and
    {scell_addition}
    """

meas_object_1_for_SCell = """
        measObjectToAddModList contains
        (
            (measObjectId eq 1) and (ssbFrequency eq 392410) and (freqBandIndicatorNR eq 25)
        )
"""

SCell_Addition_With_Meas_Config_containing_A2_and_with_ScellToAddModList_BB15 = \
    SCell_Addition_With_Meas_Config_containing_A2_and_with_ScellToAddModList_template.format(
        meas_objects=meas_object_1_for_SCell,
        report_config_A=report_config_A2_SCell_release_B_B15,
        meas_A=fill_measIdToAddModList_element(meas_ID=2, meas_object_ID=1, report_config_ID=2),
        reportConfigToRemoveList="and reportConfigToRemoveList contains (1) and length(reportConfigToRemoveList) eq 1",
        measIdToRemoveList="and measIdToRemoveList contains (1) and length(measIdToRemoveList) eq 1",
        scell_addition=selected_SCells_for_sCellToAddModList_B_B15)

SgNB_Modification_Request_Ack_with_A1_A3_meas_configuration_for_HO_BB15_template = """
    measConfig contains
    (
        {meas_objects}
        {report_config_A}
        {report_config_B}
        {meas_A}
        {meas_B}
        {reportConfigToRemoveList}
        {measIdToRemoveList}
    )
    """

meas_object_2_BB15 = """
        measObjectToAddModList contains
        (
            (measObjectId eq 2) and (ssbFrequency eq 506430) and (freqBandIndicatorNR eq 41)
        )
"""

report_config_A3_BB15 = """
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
                                eventA3 is present
                                and hysteresis eq 0
                                and timeToTrigger eq "ms64"
                            )
                            and a3-Offset contains
                            (
                                rsrp is present
                                and rsrp eq 15
                            )
                        )
                    )
                )
            )
"""

report_config_A1_for_HO_rollback_BB15 = """
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
                                eventA1 is present
                                and hysteresis eq 0
                                and timeToTrigger eq "ms480"
                            )
                            and a1-Threshold contains
                            (
                                rsrp is present
                                and rsrp eq 39
                            )
                        )
                    )
                )
            )
"""

SgNB_Modification_Request_Ack_with_A1_A3_meas_configuration_for_HO_BB15 = \
    SgNB_Modification_Request_Ack_with_A1_A3_meas_configuration_for_HO_BB15_template.format(
        meas_objects=meas_object_2_BB15,
        report_config_A=report_config_A3_BB15,
        report_config_B=report_config_A1_for_HO_rollback_BB15,
        meas_A=fill_measIdToAddModList_element(meas_ID=2, meas_object_ID=1, report_config_ID=2),
        meas_B=fill_measIdToAddModList_element(meas_ID=3, meas_object_ID=2, report_config_ID=3),
        reportConfigToRemoveList="and reportConfigToRemoveList contains (1) and length(reportConfigToRemoveList) eq 1",
        measIdToRemoveList="and measIdToRemoveList contains (1) and length(measIdToRemoveList) eq 1")

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


InitialContextSetup_qosFlowIdentifier_and_pDUSessionID_template = """
    qosFlowIdentifier eq {qosFlowIdentifier_value}
    and pDUSessionID eq {pDUSessionID_value}
    """

InitialContextSetupReq_C_B28 = InitialContextSetup_qosFlowIdentifier_and_pDUSessionID_template.format(
    qosFlowIdentifier_value=1,
    pDUSessionID_value=4)

InitialContextSetup_qosCharacteristics_template = """
    qosCharacteristics contains (fiveQI eq {fiveQI_value})
    """

InitialContextSetupRsp_C_B28 = InitialContextSetup_qosCharacteristics_template.format(
    fiveQI_value=6)
