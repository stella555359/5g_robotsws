"""
Copyright: Nokia Networks
Author: Riyad FERRAG
Email: riyad.ferrag@nokia.com
"""

import os
import json

from builtins import FileNotFoundError

# TAF Libraries:
from taf.analyzer.ttitrace_eventdecoder import TtitraceReader as TtitraceReaderEvtDec

MIN_FILE_SIZE = 24

RV2_ALLOWED_PRBS = {
    28: {9, 15, 21, 27},
    29: {12, 15, 21, 27},
    30: {12, 15, 21, 27},
    31: {15, 20, 27},
}


def ul_retx_check_v1(json_path_name: str, prnti: int = 65535, nrnti: int = 0) -> bool:
    """
    Check UL retransmissions in TTI trace file.
    Validates that RV = 2 only occurs with MCS = 31 and PRBs in [15, 20, 27].
    """
    all_conditions_met = True

    if not os.path.exists(json_path_name):
        raise FileNotFoundError(f"TTI trace ERROR: {json_path_name} doesn't exist.")

    if os.path.getsize(json_path_name) <= MIN_FILE_SIZE:
        print(f"TTI trace WARNING: {json_path_name} size <= {MIN_FILE_SIZE} bytes. "
              f"The file may be incomplete or corrupted.")

    with open(json_path_name, "rb") as file_obj:
        for i, event in enumerate(TtitraceReaderEvtDec(file_obj=file_obj)):
            if (
                event.type == "ulFdSchedData"
                and event.data["eventHeader"]["rnti"] not in [prnti, nrnti]
            ):
                sfn = event.data["eventHeader"]["sfn"]
                slot = event.data["eventHeader"]["slot"]
                rv = event.data["redundancyVersion"]
                mcs = event.data["rrmUlUsedMcs"]
                prbs = event.data["numOfPrb"]

                if rv == 2:
                    if not (mcs == 31 and prbs in [15, 20, 27]):
                        all_conditions_met = False
                        print(f"Conditions not met - RV = 2, sfn = {sfn}, slot = {slot}, "
                              f"MCS = {mcs}, PRBs = {prbs}")
                        break

    return all_conditions_met


def ul_retx_check_v2(json_path_name: str, prnti: int = 65535, nrnti: int = 0) -> bool:
    """
    Audit UL retransmissions in TTI trace file.
    Checks for RV = 2 with specific MCS and PRBs combinations:
    - If MCS == 31, PRBs must be in [15, 20, 27]
    - If MCS == 29, PRBs must be in [15, 12]
    """
    all_conditions_met = True

    if not os.path.exists(json_path_name):
        raise FileNotFoundError(f"TTI trace ERROR: {json_path_name} doesn't exist.")

    if os.path.getsize(json_path_name) <= MIN_FILE_SIZE:
        print(f"TTI trace WARNING: {json_path_name} size <= {MIN_FILE_SIZE} bytes. "
              f"The file may be incomplete or corrupted.")

    with open(json_path_name, "rb") as file_obj:
        for i, event in enumerate(TtitraceReaderEvtDec(file_obj=file_obj)):
            if (
                event.type == "ulFdSchedData"
                and event.data["eventHeader"]["rnti"] not in [prnti, nrnti]
            ):
                sfn = event.data["eventHeader"]["sfn"]
                slot = event.data["eventHeader"]["slot"]
                rv = event.data["redundancyVersion"]
                mcs = event.data["rrmUlUsedMcs"]
                prbs = event.data["numOfPrb"]

                if rv == 2:
                    if mcs == 31 and prbs not in [15, 20, 27]:
                        all_conditions_met = False
                        print(f"Conditions not met - RV = 2, MCS = 31, sfn = {sfn}, "
                              f"slot = {slot}, PRBs = {prbs}")
                        break
                    elif mcs == 29 and prbs not in [12, 15, 21, 27]:
                        all_conditions_met = False
                        print(f"Conditions not met - RV = 2, MCS = 29, sfn = {sfn}, "
                              f"slot = {slot}, PRBs = {prbs}")
                        break
                    elif mcs not in [29, 31]:
                        all_conditions_met = False
                        print(f"Conditions not met - RV = 2, unexpected MCS = {mcs}, "
                              f"sfn = {sfn}, slot = {slot}, PRBs = {prbs}")
                        break

    return all_conditions_met


def ul_retx_check_v3(json_path_name: str, prnti: int = 65535, nrnti: int = 0) -> bool:

    if not os.path.exists(json_path_name):
        raise FileNotFoundError(f"TTI trace ERROR: {json_path_name} doesn't exist.")

    if os.path.getsize(json_path_name) <= MIN_FILE_SIZE:
        print(f"TTI trace WARNING: {json_path_name} size <= {MIN_FILE_SIZE} bytes.")

    with open(json_path_name, "rb") as file_obj:
        for event in TtitraceReaderEvtDec(file_obj=file_obj):
            if (
                event.type == "ulFdSchedData"
                and event.data["eventHeader"]["rnti"] not in [prnti, nrnti]
            ):
                hdr = event.data["eventHeader"]
                rv = event.data["redundancyVersion"]
                mcs = event.data["rrmUlUsedMcs"]
                prbs = event.data["numOfPrb"]

                if rv == 2:
                    allowed_prbs = RV2_ALLOWED_PRBS.get(mcs)
                    if not allowed_prbs or prbs not in allowed_prbs:
                        print(
                            f"Conditions not met - RV = 2, MCS = {mcs}, "
                            f"sfn = {hdr['sfn']}, slot = {hdr['slot']}, PRBs = {prbs}"
                        )
                        return False

    return True
