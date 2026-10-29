import json
import os
from robot.libraries.BuiltIn import BuiltIn
from testsuite.Wroclaw.RRM.VRF_WRO2_T05.classical.regression.common_keywords.resource.dcap.dcap import (
    find_value_by_key_dcap_json,
)


def check_DFT_OFDM_value(expected_value, dcap_logs_path):
    all_files = os.listdir(dcap_logs_path)
    filtered_logs = [file for file in all_files if "filtered" in file]

    for filtered_log in filtered_logs:
        full_dcap_logs_path = f"{dcap_logs_path}/{filtered_log}"

        with open(full_dcap_logs_path, "r") as dcap_json:
            dcap_logs = json.load(dcap_json)

        for msg in dcap_logs["emil_data"]["rows"]:
            transformPrecoder_value = find_value_by_key_dcap_json(
                msg["JsonContent"], "transformPrecoder"
            )
            if transformPrecoder_value is not None:
                BuiltIn().log(
                    f'Found transformPrecoder value equal to {transformPrecoder_value} \
                    in message number: {msg["Order"]["VisibleID"]}'
                )
                return transformPrecoder_value == expected_value
    return False


def verify_ca_configured(dcap_logs_path):
    all_files = os.listdir(dcap_logs_path)
    filtered_logs = [file for file in all_files if "filtered" in file]

    for filtered_log in filtered_logs:
        full_dcap_logs_path = f"{dcap_logs_path}/{filtered_log}"

        with open(full_dcap_logs_path, "r") as dcap_json:
            dcap_logs = json.load(dcap_json)

        for msg in dcap_logs["emil_data"]["rows"]:
            sCellToAddModList = find_value_by_key_dcap_json(
                msg["JsonContent"], "sCellToAddModList"
            )
            if sCellToAddModList is not None:
                scells_physCellId = [
                    el["sCellConfigCommon"]["physCellId"] for el in sCellToAddModList
                ]
                BuiltIn().log(
                    f'Found sCellToAddModList with physCellId values equal to {scells_physCellId} \
                    in message number: {msg["Order"]["VisibleID"]}'
                )
                assert (
                    len(scells_physCellId) == 2
                ), f"Two Scells 100 and 506 should be configured. \
                    Currently list contain: {scells_physCellId}"
                return all(cell in scells_physCellId for cell in (100, 506))
    return False
