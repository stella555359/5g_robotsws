import os
import io
import ast
import json
import re
import gzip
import zipfile
from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn


def get_dcap_bts_id(dcap_bts_info, host):
    for bts in dcap_bts_info:
        if host in bts.values():
            return bts["id"]


def get_dcap_trace_id(dcap_bts_info, host):
    for bts in dcap_bts_info:
        try:
            for info_trace in bts["latest_trace"]["targets"]:
                if host in info_trace.values():
                    return info_trace["trace_id"]
        except Exception:
            print("latest_trace not found")


def check_dcap_logs_status(info):
    return info["status"]


def create_cell_list(nrCells):
    cell_list = []
    if nrCells:
        nrCells = list(nrCells.split(" "))
        for cell in nrCells:
            cell_list.append(cell)
        return cell_list


def create_custom_profile_list(cp):
    cp_list = []
    if cp:
        cp = list(cp.split(" "))
        for profile in cp:
            cp_list.append(profile)
        return cp_list


def create_msg_list(msgs):
    msgs_list = []
    if msgs:
        msgs = list(msgs.split(" "))
        for msg in msgs:
            msgs_list.append(msg)
        return msgs_list


def get_5gm_file(fivegm_filename):
    """Returns name of 5gm file from given path."""
    extension = ".5gm"
    try:
        all_files = os.listdir(fivegm_filename)
        fivegm_files = [file for file in all_files if file.endswith(extension)]
        return fivegm_files
    except OSError as e:
        print(f"Error: {e}. Does .5gm file exist in that folder?")
        return []


def dcap_save_to_json(decoded_content: str, filename: str) -> None:
    """Creates json file `filename` from `decoded_content`."""
    print("decoded_content_type", type(decoded_content))
    if isinstance(decoded_content, str):
        # evaluate str as dict to save properly as json
        decoded_content = ast.literal_eval(decoded_content)
    try:
        with open(filename, "w", encoding="utf-8") as json_file:
            json.dump(decoded_content, json_file, indent=4)
        print(f"Data has been saved to {filename} successfully")
    except Exception as e:
        print(f"Error saving data to {filename}: {e}")


def find_value_by_key_dcap_json(dictionary, key):
    """Recursive function to find value of particular key in dcap json result file.
    Return None if key not found"""
    if isinstance(dictionary, dict):
        if key in dictionary:
            return dictionary[key]
        for k, v in dictionary.items():
            value = find_value_by_key_dcap_json(v, key)
            if value:
                return value
    elif isinstance(dictionary, list):
        for item in dictionary:
            value = find_value_by_key_dcap_json(item, key)
            if value:
                return value
    return None


def merge_json_files(source_dir=None):
    ute_test_results = BuiltIn().get_variable_value("${OUTPUT_DIR}")
    test_suite_name = BuiltIn().get_variable_value("${SUITE NAME}")
    test_case_name = BuiltIn().get_variable_value("${TEST NAME}")
    if source_dir is None:
        source_dir = "/".join(
            [ute_test_results, test_suite_name, test_case_name, "_extracted/CP_FILES"]
        )
    else:
        source_dir = "/".join(
            [ute_test_results, test_suite_name, test_case_name, source_dir, "CP_FILES"]
        )

    json_file_list = []
    for file_name in os.listdir(source_dir):
        if file_name.endswith(".json"):
            json_file_list.append(file_name)

    json_file_list.sort()
    logger.info("json_file_list.sort(): {}".format(json_file_list.sort()))
    merged_data = {
        "status": "ok",
        "emil_data": {"columns": [], "rows": []},
    }

    if len(json_file_list) > 1:
        for json_file in json_file_list:
            json_file_path = "/".join([source_dir, json_file])
            with open(json_file_path, "r") as json_ref:
                json_data = json.load(json_ref)

            merged_data["emil_data"]["columns"] = json_data["emil_data"]["columns"]
            merged_data["emil_data"]["rows"].extend(json_data["emil_data"]["rows"])

        merged_json_file = "controlPlane5g_merged_trace.json"
        merged_json_file_path = "/".join([source_dir, merged_json_file])
        with open(merged_json_file_path, "w") as merged_json_ref:
            json.dump(merged_data, merged_json_ref, indent=4)

        return merged_json_file
    else:
        logger.info("No need to merge anything")
        return json_file_list[0]


def extract_files_from_zip(
    file_pattern, source_dir=None, zip_filename="dcap.zip", target_dir=None
):
    ute_test_results = BuiltIn().get_variable_value("${OUTPUT_DIR}")
    test_suite_name = BuiltIn().get_variable_value("${SUITE NAME}")
    test_case_name = BuiltIn().get_variable_value("${TEST NAME}")
    if source_dir is None:
        source_dir = "/".join(
            [ute_test_results, test_suite_name, test_case_name, "dcap"]
        )
    else:
        source_dir = "/".join(
            [ute_test_results, test_suite_name, test_case_name, source_dir]
        )

    if target_dir is None:
        target_dir = "/".join(
            [ute_test_results, test_suite_name, test_case_name, "_extracted/CP_FILES"]
        )

    zip_file_path = os.path.join(source_dir, zip_filename)
    os.makedirs(os.path.dirname(target_dir), exist_ok=True)

    extracted_files = []
    with zipfile.ZipFile(zip_file_path, "r") as zip_ref:
        for file_info in zip_ref.infolist():
            if re.match(file_pattern, file_info.filename):
                if file_info.is_dir():
                    continue
                file_info.filename = os.path.basename(file_info.filename)
                file_path = "/".join([target_dir, file_info.filename])
                extracted_files.append(file_path)
                zip_ref.extract(file_info, target_dir)
                logger.debug(
                    "Extracted: {} to {}".format(file_info.filename, target_dir)
                )

    return extracted_files


def extract_zip_with_nested_gz(
    nested_zip_pattern,
    source_dir=None,
    zip_filename="dcap.zip",
    target_dir=None,
):
    ute_test_results = BuiltIn().get_variable_value("${OUTPUT_DIR}")
    test_suite_name = BuiltIn().get_variable_value("${SUITE NAME}")
    test_case_name = BuiltIn().get_variable_value("${TEST NAME}")

    if source_dir is None:
        source_dir = "/".join(
            [ute_test_results, test_suite_name, test_case_name, "dcap"]
        )
    else:
        source_dir = "/".join(
            [ute_test_results, test_suite_name, test_case_name, source_dir]
        )

    if target_dir is None:
        target_dir = "/".join(
            [ute_test_results, test_suite_name, test_case_name, "_extracted"]
        )

    # logger.debug('Logs directory: {}'.format(zip_directory))
    # logger.debug('Extraction directory: {}'.format(extraction_directory))

    zip_file_path = os.path.join(source_dir, zip_filename)
    extracted_data = {}

    with zipfile.ZipFile(zip_file_path, "r") as zip_ref:
        nested_zip_files = [
            file_info.filename
            for file_info in zip_ref.infolist()
            if re.match(nested_zip_pattern, file_info.filename)
            and file_info.filename.endswith(".zip")
        ]

        for nested_zip_filename in nested_zip_files:
            nested_zip_data = zip_ref.read(nested_zip_filename)

            with zipfile.ZipFile(io.BytesIO(nested_zip_data), "r") as nested_zip_ref:
                for nested_file_info in nested_zip_ref.infolist():
                    if nested_file_info.filename.endswith(".gz"):
                        gz_data = nested_zip_ref.read(nested_file_info.filename)

                        with gzip.GzipFile(
                            fileobj=io.BytesIO(gz_data), mode="rb"
                        ) as gz_file:
                            decompressed_data = gz_file.read()
                            extracted_data[nested_file_info.filename[:-3]] = (
                                decompressed_data
                            )

                            gz_file_path = "/".join(
                                [target_dir, nested_file_info.filename[:-3]]
                            )
                            os.makedirs(os.path.dirname(gz_file_path), exist_ok=True)

                            with open(gz_file_path, "wb") as extracted_file:
                                extracted_file.write(decompressed_data)

                                logger.debug(
                                    "Extracted: {} to {}".format(
                                        nested_file_info.filename, gz_file_path
                                    )
                                )


def verify_message_sequence_in_json(expected_messages, file_name, source_dir=None):
    ute_test_results = BuiltIn().get_variable_value("${OUTPUT_DIR}")
    test_suite_name = BuiltIn().get_variable_value("${SUITE NAME}")
    test_case_name = BuiltIn().get_variable_value("${TEST NAME}")
    if source_dir is None:
        source_dir = "/".join(
            [ute_test_results, test_suite_name, test_case_name, "_extracted/CP_FILES"]
        )
    else:
        source_dir = "/".join(
            [ute_test_results, test_suite_name, test_case_name, source_dir]
        )

    file_path = "/".join([source_dir, file_name])
    with open(file_path, "r") as json_file:
        json_data = json.load(json_file)

    found_messages = []
    for row in json_data["emil_data"]["rows"]:
        if "JsonContent" in row:
            json_content = row
            json_content_str = json.dumps(json_content)
            while expected_messages:
                current_message = expected_messages[0]
                if re.search(current_message, json_content_str, re.DOTALL):
                    found_messages.append(expected_messages.pop(0))
                else:
                    break

    logger.debug("found_messages: {}".format(found_messages))
    logger.debug("expected_messages: {}".format(expected_messages))
    assert len(expected_messages) == 0, logger.info("The message was not found or sequence not match.")
