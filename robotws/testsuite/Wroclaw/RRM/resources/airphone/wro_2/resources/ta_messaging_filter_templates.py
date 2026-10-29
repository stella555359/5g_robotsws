import re

measurement_report_template = """
    measurementReport contains
    (
        measResults contains
        (
            measId eq {meas_id}
            and measResultServingMOList contains
            (
                servCellId eq {servCellId}
                and measResultServingCell contains
                (
                    physCellId eq {physCellId}
                    {measResult_template}
                )
            )
            {measResultNeighCells}
        )
    )
"""

measResult_template = """
                    and measResult contains
                    (
                        cellResults contains
                        (
                            resultsSSB-Cell contains
                            (
                                {measurement_type} eq {value}
                            )
                        )
                    )
"""

measResultNeighCells = """
and measResultNeighCells contains
            (
                measResultListNR contains
                (
                    physCellId eq {physCellId}
                    {measResult_template}
                )
                {additional_report}
            )
"""

measObjectToAddModList_template = """
measObjectToAddModList contains
        (
            (measObjectId eq {id}) and (ssbFrequency eq {freq}) and (freqBandIndicatorNR eq {band})
        )
"""

measConfig_template = """
    and measConfig contains
    (
        {measConfig_content}
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
    """

reportConfigToAddModList_template = """
 reportConfigToAddModList contains
 (
     reportConfigId eq {id}
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
                         {event_type} is present
                         and hysteresis eq {hysteresis}
                         and timeToTrigger eq {timeToTrigger}
                     )
                     and {event_detail} contains ({measurement_type} eq {value})
                 )
             )
         )
     )
)
"""

measIdToAddModList_template = """
measIdToAddModList contains
        (
            measId eq {meas_id}
            and measObjectId eq {meas_object_id}
            and reportConfigId eq {report_config_id}
        )
"""

measIdToRemoveList_template = """
    measIdToRemoveList contains ({measurement_ids})
    and length(measIdToRemoveList) eq {length}
"""

reportConfigToRemoveList_template = """
    reportConfigToRemoveList contains ({report_config_ids})
    and length(reportConfigToRemoveList) eq {length}
"""

measObjectToRemoveList_template = """
    measObjectToRemoveList contains ({meas_obj_ids})
    and length(measObjectToRemoveList) eq {length}
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

drx_config_release = """
mac-CellGroupConfig contains
(
    drx-Config is present
    and release is present
)
"""

drx_configuration_release_f1ap_request = "DRXConfigurationIndicator eq \"release\""


def meas_config(meas_object_list=[],
                meas_object_length=None,
                report_config_list=[],
                report_config_length=None,
                meas_id_list=[],
                meas_id_length=None,
                meas_id_to_remove=[],
                report_config_to_remove=[],
                meas_obj_to_remove=[]):

    meas_objects = ""
    for measurement in meas_object_list:
        if meas_objects != "":
            meas_objects = meas_objects + "\nand\n"
        meas_objects = meas_objects + measObjectToAddModList_template.format(
            id=measurement["id"], freq=measurement["freq"], band=measurement["band"])
    if meas_object_length:
        meas_objects = meas_objects + "\nand length(measObjectToAddModList) eq {}\n".format(meas_object_length)

    report_configs = ""
    for report_config in report_config_list:
        if report_configs != "":
            report_configs = report_configs + "\nand\n"
        report_configs = report_configs + reportConfigToAddModList_template.format(
            id=report_config["id"],
            event_type=report_config["event_type"],
            timeToTrigger=report_config["timeToTrigger"],
            hysteresis=report_config["hysteresis"],
            event_detail=report_config["event_detail"],
            measurement_type=report_config["measurement_type"],
            value=report_config["value"])
    if report_config_length:
        report_configs = report_configs + "\nand length(reportConfigToAddModList) eq {}\n".format(report_config_length)

    meas_ids = ""
    for meas_id in meas_id_list:
        if meas_ids != "":
            meas_ids = meas_ids + "\nand\n"
        meas_ids = meas_ids + measIdToAddModList_template.format(meas_id=meas_id["meas_id"],
                                                                 meas_object_id=meas_id["meas_object_id"],
                                                                 report_config_id=meas_id["report_config_id"])
    if meas_id_length:
        meas_ids = meas_ids + "\nand length(measIdToAddModList) eq {}\n".format(meas_id_length)

    meas_config = meas_objects + "\nand\n" + report_configs + "\nand\n" + meas_ids
    for i in range(0, 3):
        meas_config = re.sub("^\nand\n|\nand\n$", "", meas_config, count=2).replace('\n\n', '\n')

    if meas_id_to_remove:
        merged = ''.join(str(x) for x in meas_id_to_remove)
        meas_id_remove = measIdToRemoveList_template.format(measurement_ids=merged,
                                                            length=len(meas_id_to_remove))
        if meas_config != "":
            meas_config = meas_config + "\nand\n" + meas_id_remove
        else:
            meas_config = meas_id_remove

    if report_config_to_remove:
        merged = ''.join(str(x) for x in report_config_to_remove)
        report_config_id_remove = reportConfigToRemoveList_template.format(report_config_ids=merged,
                                                                           length=len(report_config_to_remove))
        if meas_config != "":
            meas_config = meas_config + "\nand\n" + report_config_id_remove
        else:
            meas_config = report_config_id_remove

    if meas_obj_to_remove:
        merged = ''.join(str(x) for x in meas_obj_to_remove)
        meas_obj_id_remove = measObjectToRemoveList_template.format(meas_obj_ids=merged,
                                                                    length=len(meas_obj_to_remove))
        if meas_config != "":
            meas_config = meas_config + "\nand\n" + meas_obj_id_remove
        else:
            meas_config = meas_obj_id_remove

    return meas_config
