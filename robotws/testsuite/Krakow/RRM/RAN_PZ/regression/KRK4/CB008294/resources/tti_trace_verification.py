"""
:copyright: Nokia Networks
:author: Damian Zak
:maintainer: Damian Zak
:contact: damian.zak@nokia.com
:team: MN_RAN_L2_SW_2_KRK_CntDlv_SG
"""

import json

from log_collection import get_test_log_dirpath
from testsuite.Krakow.RRM.RAN_PZ.regression.KRK4.resources.Python.utilities import logger_console_info


def _get_all_tti_events(path):
    with open(path, "r") as json_file:
        tti_even_list = json.load(json_file)["events"]
    return [event for event in tti_even_list]


def _get_data_for_k1_validation():
    k1_sfn, k1_slot, k1_value, harq_sfn, harq_slot, harq_dtx, harq_ack, msg4_index = 0, 0, 0, 0, 0, 0, 0, None
    log_dir_path = get_test_log_dirpath()
    all_tti_events = _get_all_tti_events(f"{log_dir_path}/tti_trace_attach/output.json")
    try:
        for index, event in enumerate(all_tti_events):
            if "dlHarqRxDataArray" in event.keys() and harq_sfn == 0:
                harq_sfn = event["dlHarqRxDataArray"]["body"]["eventHeader"]["sfn"]
                harq_slot = event["dlHarqRxDataArray"]["body"]["eventHeader"]["slot"]
                harq_dtx = event["dlHarqRxDataArray"]["body"]["nestedArray"][0]["dtx"]
                harq_ack = event["dlHarqRxDataArray"]["body"]["nestedArray"][0]["ackNack"]
            if "dlFdSchedData" in event.keys():
                if event["dlFdSchedData"]["body"]["dciFormat"] == "DL_10_MSG4" and k1_sfn == 0:
                    k1_sfn = event["dlFdSchedData"]["body"]["eventHeader"]["sfn"]
                    k1_slot = event["dlFdSchedData"]["body"]["eventHeader"]["slot"]
                    k1_value = event["dlFdSchedData"]["body"]["K1"]
    except KeyError as key:
        logger_console_info(f"Missing {key} field in TTI Trace")
        raise
    except TypeError:
        logger_console_info("dlHarqRxDataArray event occured before dlFdSchedData")
        raise
    return k1_sfn, k1_slot, k1_value, harq_sfn, harq_slot, harq_dtx, harq_ack


def msg4_slot_pattern_k1_value_validation(subframe_size=80):
    """
    Purpose of this function is to validate if MSG4 is scheduled with proper K1 values in slot pattern and if the
    value is correctly applied for Harq response time

    :param subframe_size: (int) Number of subframes(slots) in radio frame. (e.g. SCS 120 Khz = 80 subframe(slot) size)
    """
    logger_console_info("Start K1 validation")
    k1_sfn, k1_slot, k1_value, harq_sfn, harq_slot, harq_dtx, harq_ack = _get_data_for_k1_validation()
    if k1_value + k1_slot > subframe_size:
        k1_slot_plus_k1_value = k1_slot + k1_value - subframe_size
        k1_sfn_plus_k1_value = k1_sfn + 1
    else:
        k1_slot_plus_k1_value = k1_slot + k1_value
        k1_sfn_plus_k1_value = k1_sfn

    assert 6 <= k1_value <= 8, f"K1 value: {k1_value} is out of FR2 allowed range (6,8)"
    assert k1_slot_plus_k1_value == harq_slot and k1_sfn_plus_k1_value == harq_sfn, \
        f"Harq response didn't match K1 value.\nK1 value: {k1_value}\nK1 SFN,SLOT: {k1_sfn},{k1_slot}" \
        f"\nHarq SFN,SLOT: {harq_sfn},{harq_slot}"
    assert harq_ack == "ACK" and harq_dtx == "NON_DTX", \
        f"Harq transmission data incorrect: ackNack: {harq_ack}, HarqDtx: {harq_dtx}"
    logger_console_info(f"K1 validation success\nK1 value: {k1_value}"
                        f"\nK1 SFN,SLOT: {k1_sfn},{k1_slot}\nHarq SFN,SLOT: {harq_sfn},{harq_slot}")
