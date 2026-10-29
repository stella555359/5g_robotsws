import io
import os
import re
import json
import gzip
import subprocess
import zipfile
from datetime import datetime
from robot.api.deco import keyword
from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn
from taf.analyzer.pmcounter import PMCounterLogReader
from taf.rfrl.utilities.parsers.pcap_checker.checker import Checker, AwaitedMessage
from taf.rfrl.utilities.parsers.pcap_checker.inspectors import (
    HasInspector,
    NotHasInspector,
)
from taf.rfrl.utilities.parsers.pcap_checker.utils import PcapProvider
import testsuite.Wroclaw.RRM.resources.pcap_verification.tsharkWithLuaVerifier as tshark
from testsuite.Wroclaw.RRM.resources.pcap_verification.message_to_tree import (
    message_to_tree,
)


def extract_files_from_zip(
    file_pattern: str,
    source_dir: str = None,
    zip_filename: str = "dcap.zip",
    target_dir: str = None,
) -> list[str]:
    """
    Extracts files matching a pattern from a ZIP archive.

    param file_pattern (str): The pattern to match files in the ZIP archive.
    param source_dir (str, optional): The directory containing the ZIP archive.
    parm zip_filename (str, optional): The name of the ZIP archive. Defaults to "dcap.zip".
    param target_dir (str, optional): The directory to extract the files to.
    return list[str]: A list of paths to the extracted files.
    """

    ute_test_results = "/home/ute/test_results"
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
    else:
        target_dir = "/".join(
            [
                ute_test_results,
                test_suite_name,
                test_case_name,
                "_extracted",
                target_dir,
            ]
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
    nested_zip_pattern: str,
    source_dir: str = None,
    zip_filename: str = "dcap.zip",
    target_dir: str = None,
) -> None:
    """
    Extracts files from a nested ZIP archive, decompressing any nested GZIP files.

    param nested_zip_pattern (str): The pattern to match nested ZIP files within the main ZIP archive.
    param source_dir (str, optional): The directory containing the ZIP archive.
    param zip_filename (str, optional): The name of the ZIP archive. Defaults to "dcap.zip".
    param target_dir (str, optional): The directory to extract the files to.
    return None
    """
    ute_test_results = "/home/ute/test_results"
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


@keyword(
    "verify ${pi_id} ${expected_value} in ${pm_file_pattern}.${moc} from ${timestamp}"
)
def verify_pm_counter(
    pi_id: str,
    expected_value: str,
    pm_file_pattern: str = None,
    moc: str = None,
    timestamp: str = None,
    source_dir: str = None,
) -> None:
    """
    Verifies the value of a PM counter against an expected value.

    param pi_id (str): The ID of the PM counter to verify.
    param expected_value (str): The expected value of the PM counter.
            This can include operators like "<", ">", "=", "SUM>", etc.
    param pm_file_pattern (str, optional): The pattern for PM files to search. Defaults to "PM.BTS*"
    param moc (str, optional): The MO and MO ID in the format "MO-MO_ID".
    param source_dir (str, optional): The directory containing the PM files.
    return None: True if the PM counter value matches the expected value, False otherwise.
    """

    if source_dir is None:
        ute_test_results = "/home/ute/test_results"
        test_suite_name = BuiltIn().get_variable_value("${SUITE NAME}")
        test_case_name = BuiltIn().get_variable_value("${TEST NAME}")
        source_dir = "/".join(
            [
                ute_test_results,
                test_suite_name,
                test_case_name,
                "_extracted/PERFMON_FILES/",
            ]
        )

    if pm_file_pattern is None:
        pm_file_pattern = "PM.BTS*"
    else:
        pm_file_pattern = "".join(["*", pm_file_pattern, "*"])

    remove_old_pm_files(source_dir, timestamp)

    match = re.match(r"([<>=]{1,2}|SUM>|SUM<|SUM>=)(\d+)", expected_value)
    operator, number = match.groups()
    number = float(number)
    mo, mo_id = moc.split("-")
    log_entries = list(
        PMCounterLogReader.from_dir(dir_path=source_dir, file_pattern=pm_file_pattern)
    )

    values_list = []
    pm_xpath = "//{}[@id='{}']//@{}".format(mo, mo_id, pi_id)
    for entry in log_entries:
        pi_value = entry.pm_setup.xpath(pm_xpath)

        if pi_value:
            logger.debug(
                "{} - {} - PI ID: {} value: {}".format(
                    entry.timestamp, moc, pi_id, pi_value
                )
            )
            values_list.extend(pi_value)

    if not values_list:
        logger.debug("{} does not exist.".format(pi_id))

    values_list = [float(value) for value in values_list]

    if operator == "=":
        assert any(value == number for value in values_list), logger.info(
            "{} is not equal to {}".format(pi_id, number)
        )
    elif operator == ">":
        assert any(value > number for value in values_list), logger.info(
            "{} is not greater than {}".format(pi_id, number)
        )
    elif operator == ">=":
        assert any(value >= number for value in values_list), logger.info(
            "{} is not greater or equal to {}".format(pi_id, number)
        )
    elif operator == "<":
        assert any(value < number for value in values_list), logger.info(
            "{} is not less than {}".format(pi_id, number)
        )
    elif operator == "<=":
        assert any(value <= number for value in values_list), logger.info(
            "{} is not less or equal to {}".format(pi_id, number)
        )
    elif operator == "SUM>":
        pi_sum = 0
        for value in values_list:
            pi_sum += value
        assert pi_sum > number, logger.info(
            "The sum of {} is not greater than {}. (value {})".format(
                pi_id, number, pi_sum
            )
        )
    elif operator == "SUM<":
        pi_sum = 0
        for value in values_list:
            pi_sum += value
        assert pi_sum < number, logger.info(
            "The sum of {} is greater than {}. (value {})".format(pi_id, number, pi_sum)
        )
    elif operator == "SUM>=":
        pi_sum = 0
        for value in values_list:
            pi_sum += value
        assert pi_sum >= number, logger.info(
            "The sum of {} is not equal or greater than {}. (value {})".format(pi_id, number, pi_sum)
        )
    else:
        return NotImplemented


def list_json_files(directory):
    """Zwraca liste absolutnych sciezek plików .json w podanym katalogu."""
    return [os.path.abspath(os.path.join(directory, f))
            for f in os.listdir(directory)
            if f.endswith('.json') and os.path.isfile(os.path.join(directory, f))]


def merge_json_files(source_dir: str = None) -> str:
    """
    Merges multiple JSON files in a directory into a single JSON file.

    param source_dir (str, optional): The directory containing the JSON files.
    return str: The path to the merged JSON file.
    """

    ute_test_results = "/home/ute/test_results"
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

        return merged_json_file_path
    else:
        logger.info("No need to merge anything")
        json_file_path = "/".join([source_dir, json_file_list[0]])
        return json_file_path


def verify_message_sequence_in_json(file_path: str, expected_messages: list) -> None:
    """
    Verifies if the expected message sequence is present in a JSON file.

    param file_path (str): Path to the JSON file.
    param expected_messages (list): List of expected messages.
    return None
    """
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

    for message in expected_messages:
        if message not in found_messages:
            logger.debug("Message {} was not found".format(message))
            raise ValueError

    logger.debug("Findings: {}.".format(found_messages))

    msg_found = False
    found_messages_iterator = iter(found_messages)
    for message in expected_messages:
        logger.debug("Attempting to find message: {}.".format(message))
        for found_message in found_messages_iterator:
            # logger.debug("Comparing against: {}.".format(found_message))
            if message == found_message:
                logger.debug("Message: {} was found.".format(message))
                msg_found = True
                break
            else:
                msg_found = False

    assert msg_found, logger.info("The message sequence was not found.")


def verify_message_sequence_in_multiple_json_files(
    file_paths: list, expected_messages: list
) -> None:
    """
    Verifies if the expected message sequence is present in a list of JSON files.

    param file_paths (list): List of paths to the JSON files.
    param expected_messages (list): List of expected messages.
    return None
    """
    found_messages = []
    for file_path in file_paths:
        with open(file_path, "r") as json_file:
            json_data = json.load(json_file)

        for row in json_data["emil_data"]["rows"]:
            if "JsonContent" in row:
                json_content = row["JsonContent"]
                json_content_str = json.dumps(json_content)

                for message in expected_messages:
                    if message in json_content_str:
                        found_messages.append(message)

    # Check if all expected messages were found
    for message in expected_messages:
        if message not in found_messages:
            logger.debug("Message {} was not found in any of the files".format(message))
            raise ValueError("Message sequence not found in any of the files.")

    logger.debug("Findings: {}.".format(found_messages))

    # Check if the messages were found in the correct order
    msg_found = False
    found_messages_iterator = iter(found_messages)
    for message in expected_messages:
        logger.debug("Attempting to find message: {}.".format(message))
        for found_message in found_messages_iterator:
            # logger.debug("Comparing against: {}.".format(found_message))
            if message == found_message:
                logger.debug("Message: {} was found.".format(message))
                msg_found = True
                break
            else:
                msg_found = False
    assert msg_found, logger.info(
        "The message sequence was not found in the correct order."
    )


def get_device_id(imsi: str):
    """
    Fetches the device ID for a given IMSI using the Service Manager API.

    param imsi (str): The IMSI of the subscriber.
    return str | None: The device ID if found, otherwise None.
    """
    url = "http://10.78.62.141:80/services/ServiceManager/subscriber/getData/Device"
    headers = {
        "accept": "application/json",
        "Authorization": "Basic c21hZG1pbjpTcHMhc20w",
    }
    data = {"identities": [{"identityType": "IMSI", "value": imsi}]}

    curl_command = [
        "curl",
        "-k",
        "-X",
        "GET",
        url,
        "-H",
        f"accept: {headers['accept']}",
        "-H",
        f"Authorization: {headers['Authorization']}",
        "-d",
        json.dumps(data),
    ]

    try:
        result = subprocess.run(curl_command, capture_output=True, text=True)

        if result.returncode == 0:
            json_data = json.loads(result.stdout)
            if json_data:
                return json_data.get("id")
            else:
                return None
        else:
            logger.error(f"Failed to fetch device ID: {result.stderr}")
            return None

    except subprocess.SubprocessError as e:
        logger.error(f"Failed to run curl command: {e}")
        return None


def modify_qos_flow(imsi: str, key: str, value: str) -> bool:
    """
    Modifies the QoS flow for a given IMSI using the Service Manager API.

    param imsi (str): The IMSI of the subscriber.
    param key (str): The key of the custom data to modify.
    param value (str): The new value for the custom data.
    return bool: True if the modification was successful, False otherwise.
    """
    device_id = get_device_id(imsi)

    url = "http://10.78.62.141:80/services/ServiceManager/subscriber/updateCustomData/Device"
    headers = {
        "accept": "application/json",
        "Authorization": "Basic c21hZG1pbjpTcHMhc20w",
        "Content-Type": "application/json",
    }
    data = {
        "identities": [{"identityType": "IMSI", "value": imsi}],
        "id": device_id,
        "customData": {
            "entry": [{"key": key, "value": {"type": "STRING", "value": value}}]
        },
    }

    curl_command = [
        "curl",
        "-k",
        "-X",
        "PUT",
        url,
        "-H",
        f"accept: {headers['accept']}",
        "-H",
        f"Authorization: {headers['Authorization']}",
        "-H",
        f"Content-Type: {headers['Content-Type']}",
        "-d",
        json.dumps(data),
    ]

    try:
        result = subprocess.run(curl_command, capture_output=True, text=True)
        if result.returncode == 0:
            return True
        else:
            return False

    except Exception as e:
        logger.error(f"Failed to modify QoS Flow: {e}")
        return False


def create_inspector(inspector_definition: str) -> HasInspector | NotHasInspector:
    """
    Creates an inspector instance based on the provided definition.

    :param inspector_definition (str): A string containing the inspector type and key.
    :return HasInspector or NotHasInspector: The created inspector instance.
    """

    inspector_type, key = inspector_definition.split(":", 1)
    if inspector_type == "has":
        return HasInspector(key=key)
    elif inspector_type == "not_has":
        return NotHasInspector(key=key)
    else:
        raise ValueError(f"Unknown inspector type: {inspector_type}")


def create_awaited_message(
    name: str, find_by: list, verify_by: list = None
) -> AwaitedMessage:
    """
    Creates and returns an AwaitedMessage instance based on user-defined criteria.

    :param name (str): The name of the awaited message.
    :param find_by (list): A list specifying the inspectors to find the message.
    :param verify_by (list, optional): A list specifying the inspectors to verify the message.
    :return: An instance of AwaitedMessage.
    """

    find_by_inspectors = [create_inspector(inspector) for inspector in find_by]
    if verify_by:
        verify_by_inspectors = [create_inspector(inspector) for inspector in verify_by]
    else:
        verify_by_inspectors = []

    return AwaitedMessage(
        name=name, find_by=find_by_inspectors, verify_by=verify_by_inspectors
    )


def verify_message_sequence_in_pcap(
    file_path: str, display_filter: str, awaited_messages=None, forbidden_messages=None
) -> None:
    """
    Verifies the presence of expected messages and absence of forbidden messages in a pcap file.

    :param file_path (str): Path to the pcap file.
    :param display_filter (str): Wireshark display filter
    :param awaited_messages (list): List of expected messages.
    :param forbidden_messages (list, optional): List of forbidden messages.
    :return: None
    """
    if awaited_messages is None:
        awaited_messages = []

    if forbidden_messages is None:
        forbidden_messages = []

    try:
        pcap_provider = PcapProvider()
        checker = Checker(pcap_provider=pcap_provider)
        checker.expect_flow(
            pcap_file=file_path,
            display_filter=display_filter,
            awaited_messages=awaited_messages,
            forbidden_messages=forbidden_messages,
        )
    except Exception as e:
        logger.error(f"Error verifying message sequence in pcap file: {file_path}")
        logger.error(e)
        raise


def merge_pcap_files(
    input_files: list, output_file: str = "IPCapture_merged_trace.pcap"
) -> str:
    """
    Merges multiple pcap files in a directory into a single cap file.

    param input_files (list): A list containing the paths to input pcap files.
    param output_file (str, optional): The output file name. Defaults to "IPCapture_merged_trace.pcap"
    return str: The path to the merged pcap file.
    """

    ute_test_results = "/home/ute/test_results"
    test_suite_name = BuiltIn().get_variable_value("${SUITE NAME}")
    test_case_name = BuiltIn().get_variable_value("${TEST NAME}")
    output_file_path = "/".join(
        [
            ute_test_results,
            test_suite_name,
            test_case_name,
            "_extracted/IPCAPTURE_FILES",
            output_file,
        ]
    )

    if len(input_files) > 1:
        command = ["mergecap", "-w", output_file_path] + input_files

        process = subprocess.run(command, capture_output=True, text=True)
        if process.returncode == 0:
            logger.info(f"Merged {len(input_files)} pcap files into {output_file}")
            return output_file_path
        else:
            logger.error(f"Error merging pcap files: {process.stderr}")
    else:
        logger.info("No need to merge anything")
        return input_files[0]


def remove_old_pm_files(directory: str, timestamp: str) -> None:
    """
    Cleans up a specified directory by removing files that are older than a given timestamp

    param directory (str): string representing the path to the directory where the files are located.
    param timestamp (str): A string in the format "%Y%m%d.%H%M%S" representing the cutoff time.
        Files with timestamps earlier than this will be deleted.
    """
    timestamp = datetime.strptime(timestamp, "%Y%m%d.%H%M%S")

    for filename in os.listdir(directory):
        try:
            timestamp_str = filename.split(".")[2] + "." + filename.split(".")[3]
            file_time = datetime.strptime(timestamp_str, "%Y%m%d.%H%M%S")
            if file_time < timestamp:
                filepath = os.path.join(directory, filename)
                os.remove(filepath)
                logger.info(f"Deleted file: {filename}")
        except (IndexError, ValueError):
            continue


def find_message_in_pcap(pcap_file: str, display_filter: str, arrival_time: str = None):
    """
    Locates and return a specific message from a PCAP file based on a given display filter and
    optional arrival time criteria.

    param pcap_file (str): A string representing the path to the PCAP file.
    param display_filter (str): A string used to specify the criteria for filtering network frames.
    param arrival_time (str, optional): A string representing a timestamp. If provided, the method will only return
        messages that have an arrival time later than this specified timestamp.
    return str: a string representing the message that matches the display filter and, if specified, arrives after
        the given timestamp. If no arrival time is provided, it returns the first message that matches the filter.
    """
    output = (
        tshark.TSharkCommandAssembler()
        .with_filter(display_filter)
        .with_pcap_file(pcap_file)
        .build()
    )
    frames = tshark.split_output_into_frames(output)

    trees = [message_to_tree(message) for message in frames]
    for index, message in enumerate(trees):
        logger.debug(f"Found: {message}")
        if arrival_time:
            msg_arrival_time = get_frame_arrival_time(message)
            if msg_arrival_time > arrival_time:
                logger.debug("The message arrived after specified timestamp")
                return message
            else:
                logger.debug(
                    "Discarding finding. The message arrived before specified timestamp"
                )
        else:
            return message


def get_frame_arrival_time(frame):
    """
    Extracts and returns the arrival time of a network frame from a given data structure.

    param frame (StrPatternDict): A list of strings
    return (str): A string representing the arrival time of the frame
    """
    arrival_time = frame.find("Arrival Time", engine="re").first()["val"]
    time = arrival_time.split(",")[1].strip().split(" ")[1]
    logger.info(f"Message arrival time: {time}")
    return time


def evaluate_message_processing_time(
    message_time1: str, message_time2: str, target: float
) -> float:
    """
    Calculate the time difference between two messages and check if it is within the target time.

    param message_time1 (str): A string representing the first timestamp in the format "%H:%M:%S.%f".
    param message_time2 (str): A string representing the second timestamp in the format "%H:%M:%S.%f".
    param target (float): A float representing the maximum acceptable processing time for the defined messages.
    return float: If within target, return 0. Otherwise, return the difference between target and measured time.
    """
    result = get_time_diff(message_time1, message_time2)
    logger.info(f"Measured processing time: {result}")
    if result < target:
        logger.info("The measured processing time is within the target value.")
        return 0
    else:
        logger.info(
            f"The processing time is higher than expected. \
                    Returning offset: {result} - {target} = {result-target}."
        )
        return result - target


def get_time_diff(message_time1: str, message_time2: str) -> float:
    """
    The get_time_diff method calculates the difference in time between two given timestamps and
    returns the result in milliseconds.

    message_time1 (str): A string representing the first timestamp in the format "%H:%M:%S.%f".
    message_time2 (str): A string representing the second timestamp in the format "%H:%M:%S.%f".
    return float: The difference between message_time2 and message_time1 in milliseconds.
    """
    start_timestamp = datetime.strptime(message_time1.rstrip("0"), "%H:%M:%S.%f")
    end_timestamp = datetime.strptime(message_time2.rstrip("0"), "%H:%M:%S.%f")
    return (end_timestamp - start_timestamp).total_seconds() * 1000


def filter_scheduledBytesPerBearer_in_json(input_file_path, output_file_path, lc_id):
    """
    Filters a JSON file, retaining only specific items and discarding events if scheduledBearers
    do not contain lcId equal to lcId.

    :param input_file_path (str): Path to the input JSON file.
    :param output_file_path (str): Path to the output JSON file.
    :param lc_id (int): The lcId to filter scheduledBearers by.
    """
    with open(input_file_path, "r") as file:
        data = json.load(file)

    filtered_events = []

    for event in data.get("events", []):
        dlFdSchedData = event.get("dlFdSchedData")
        if dlFdSchedData:
            body = dlFdSchedData.get("body", {})
            event_header = body.get("eventHeader")
            scheduled_bearers = body.get("scheduledBearers", [])

            # Filter scheduledBearers based on user-defined lc_Id
            relevant_bearers = [
                bearer for bearer in scheduled_bearers if bearer.get("lcId") == lc_id
            ]

            # If relevant DRB exist, keep the event
            if relevant_bearers:
                filtered_event = {
                    "dlFdSchedData": {
                        "body": {
                            "eventHeader": event_header,
                            "scheduledBearers": relevant_bearers,
                        }
                    }
                }
                filtered_events.append(filtered_event)

    # Write the filtered events to the output file
    with open(output_file_path, "w") as file:
        json.dump({"events": filtered_events}, file, indent=4)

    if not filtered_events:
        logger.error(f"There is no dlFdSchedData event with lcId: {lc_id} ")
        raise ValueError


def find_last_data_pdu_before_nrdc_setup(json_file_path, lc_id, threshold):
    try:
        with open(json_file_path, "r") as file:
            data = json.load(file)

        events = data.get("events", [])
        last_event = None

        for event in reversed(events):
            dlFdSchedData = event.get("dlFdSchedData", {}).get("body", {})
            scheduledBearers = dlFdSchedData.get("scheduledBearers", [])

            for bearer in scheduledBearers:
                if (
                    bearer.get("lcId") == lc_id
                    and bearer.get("scheduledBytesPerBearer", 0) > threshold
                ):
                    last_event = {
                        "sfn": dlFdSchedData.get("eventHeader", {}).get("sfn"),
                        "slot": dlFdSchedData.get("eventHeader", {}).get("slot"),
                        "lcId": bearer.get("lcId"),
                        "scheduledBytesPerBearer": bearer.get(
                            "scheduledBytesPerBearer"
                        ),
                    }
                    break
            if last_event:
                break

        if not last_event:
            raise Exception("Event not found")

        return [
            {"sfn": last_event["sfn"]},
            {"slot": last_event["slot"]},
            {"lcId": last_event["lcId"]},
            {"scheduledBytesPerBearer": last_event["scheduledBytesPerBearer"]},
        ]

    except Exception as e:
        raise Exception(f"Error processing file: {str(e)}")


def find_first_data_pdu_after_nrdc_setup(json_file_path, lc_id, threshold):
    try:
        with open(json_file_path, "r") as file:
            data = json.load(file)

        events = data.get("events", [])
        first_event = None

        for event in events:
            dlFdSchedData = event.get("dlFdSchedData", {}).get("body", {})
            scheduledBearers = dlFdSchedData.get("scheduledBearers", [])

            for bearer in scheduledBearers:
                if (
                    bearer.get("lcId") == lc_id
                    and bearer.get("scheduledBytesPerBearer", 0) > threshold
                ):
                    first_event = {
                        "sfn": dlFdSchedData.get("eventHeader", {}).get("sfn"),
                        "slot": dlFdSchedData.get("eventHeader", {}).get("slot"),
                        "lcId": bearer.get("lcId"),
                        "scheduledBytesPerBearer": bearer.get(
                            "scheduledBytesPerBearer"
                        ),
                    }
                    break
            if first_event:
                break

        if not first_event:
            raise Exception("Event not found")

        return [
            {"sfn": first_event["sfn"]},
            {"slot": first_event["slot"]},
            {"lcId": first_event["lcId"]},
            {"scheduledBytesPerBearer": first_event["scheduledBytesPerBearer"]},
        ]

    except Exception as e:
        raise Exception(f"Error processing file: {str(e)}")


def get_time_diff_between_sfns(
    sfn1, slot1, sfn2, slot2, slots_per_sfn=20, slot_duration_ms=0.5, max_sfn=1024
):
    index1 = sfn1 * slots_per_sfn + slot1
    index2 = sfn2 * slots_per_sfn + slot2
    total_slots = max_sfn * slots_per_sfn

    diff_slots = (index2 - index1) % total_slots
    time_diff_ms = diff_slots * slot_duration_ms

    return time_diff_ms
