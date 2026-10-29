import json
import os
import subprocess
import time
import zipfile

from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn
from taf.sbts.oam.coam.admin import admin
from taf.transport.ssh import ssh
from ute_tshark.interface import ute_tshark

from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.dcap import dcap, extract_logs
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.dcap.webemil_parser import decode_emil_and_save_as_json
from testsuite.Wroclaw.RRM.resources.log.log import blog

ute_tshark = ute_tshark()
api = admin()
_ssh = ssh()
_builtin = BuiltIn()

DCAP_PROFILE = {
                'gnb_custom_profile':  ["cp_5g", "Tracer_5g"],
                'bts_custom_profile':  ["scf"],
                'bip_mirroring_time':  0,
                'wait_for_activation': True}


def setup_dcap():
    blog("Connecting to DCAP")
    if not _is_dcap_controller_started():
        start_dcap_controller()
    dcap.connect_to(host="localhost", port='9443', user=None, passwd=None)
    current_traces = dcap._api.get_all_trace_info(connection="dcap_collector")
    for trace in current_traces:
        if trace.get("status") == "running" and trace.get("status_details") == "":
            dcap.stop_trace(trace.get("id"))


def dcap_teardown():
    dcap.teardown()


def _is_dcap_controller_started():
    blog("Checking DCAP Controller status")
    health_check_status = subprocess.run(["utf_lab-controller", "status"], stdout=subprocess.PIPE,
                                         stderr=subprocess.PIPE)
    blog(f"DCAP Controller status: {health_check_status.stdout.decode('utf-8')}\n"
         f" {health_check_status.stderr.decode('utf-8')}")
    if health_check_status.returncode == 0:
        return True


def start_dcap_controller():
    blog("Dcap controller starting")
    start_status = subprocess.run(["utf_lab-controller", "start"], stdout=subprocess.PIPE,
                                  stderr=subprocess.PIPE)
    blog(f"DCAP Controller start status: {start_status.stdout.decode('utf-8')}\n"
         f" {start_status.stderr.decode('utf-8')}")
    if start_status.returncode == 0:
        blog("All DCAP containers started successfully. ")
        dcap_checks_attempts = 3
        for _ in range(dcap_checks_attempts):
            if _is_dcap_controller_started():
                blog("DCAP health check passed.")
                return
            time.sleep(10)
        blog("DCAP containers failed.")
        raise Exception("Starting Dcap Failed!")


def dcap_start_new_trace():
    return dcap.start_new_trace(mplane="10.0.1.2", log_profile=DCAP_PROFILE, force=False, skip_pre_check=False)


def dcap_stop_trace_and_download_logs(trace_id, output_dir):
    blog("Stopping DCAP trace")
    dcap.stop_trace(trace=trace_id)
    blog("Downloading DCAP trace")
    trace_file = dcap.download_logs(trace=trace_id, target_dir=output_dir)
    blog(f"Extracting DCAP trace to {output_dir}")
    extract_logs(trace_file)


def prepare_emil_logs_as_json(directory):
    zip_files = [file for file in os.listdir(directory) if file.endswith('.zip')]
    for zip_file in zip_files:
        with zipfile.ZipFile(os.path.join(directory, zip_file)) as file:
            for zip_info in file.infolist():
                if zip_info.is_dir():
                    continue
                zip_info.filename = os.path.basename(zip_info.filename)
                if zip_info.filename.endswith('.5gm'):
                    file.extract(zip_info, directory)
                if zip_info.filename.endswith('.lcbin'):
                    file.extract(zip_info, directory)
    return decode_emil_and_save_as_json(directory, "127.0.0.1", "9443")


def verify_messages_in_json(expected_messages, file_name, source_dir=None):
    ute_test_results = BuiltIn().get_variable_value("${OUTPUT_DIR}")
    test_case_name = BuiltIn().get_variable_value("${TEST_NAME}")
    test_case_name_utf = "".join([test_case_name, "_UTF_logs"])
    if source_dir is None:
        source_dir = "/".join([ute_test_results, test_case_name_utf])

    file_path = "/".join([source_dir, file_name])
    with open(file_path, "r") as json_file:
        json_data = json.load(json_file)

    found_messages = []
    for row in json_data["emil_data"]["rows"]:

        if "JsonContent" in row:
            json_content = row["JsonContent"]
            json_content_str = json.dumps(json_content)

            for message in expected_messages:
                if message in json_content_str:
                    found_messages.append(message)
                    logger.debug(f"Found message: {message}")

        if "User_data" in row:
            user_data = row["User_data"]
            user_data_str = json.dumps(user_data)

            for message in expected_messages:
                if message in user_data_str:
                    found_messages.append(message)
                    logger.debug(f"Found message: {message}")

    for message in expected_messages:
        if message not in found_messages:
            logger.debug(f"Message {message} was not found")
            raise ValueError(f"Message {message} was not found in the JSON file")

    logger.info("All expected messages were found")


def merge_json_files(source_dir=None):
    ute_test_results = BuiltIn().get_variable_value("${OUTPUT_DIR}")
    test_case_name = BuiltIn().get_variable_value("${TEST_NAME}")
    test_case_name_utf = "_".join([test_case_name, "UTF_logs"])
    if source_dir is None:
        source_dir = "/".join([ute_test_results, test_case_name_utf])

    json_file_list = []
    for file_name in os.listdir(source_dir):
        if file_name.endswith(".json"):
            json_file_list.append(file_name)

    json_file_list.sort()

    merged_json_file = "UTF_logs_all.json"
    merged_json_file_path = "/".join([source_dir, merged_json_file])
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

        with open(merged_json_file_path, "w") as merged_json_ref:
            json.dump(merged_data, merged_json_ref, indent=4)
        return merged_json_file
    else:
        old_file_path = "/".join([source_dir, json_file_list[0]])
        return os.rename(old_file_path, merged_json_file_path)
