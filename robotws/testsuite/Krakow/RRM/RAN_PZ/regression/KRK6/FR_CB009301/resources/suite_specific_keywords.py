"""
Suite specific keywords for eCPRI and snapshot analysis.
This module provides keywords for checking eCPRI logs and analyzing snapshots.

:author: Karolina Pacia Mateusz Potoniec
:contact: karolina.pacia@nokia.com mateusz.potoniec@nokia.com
:maintainer: karolina.pacia@nokia.com mateusz.potoniec@nokia.com
"""

import glob
import os
import subprocess
from datetime import datetime
from typing import Dict, List
from uuid import uuid4

from robot.api import logger
from robot.api.deco import keyword

from taf.analyzer.pcap import pcap

from testsuite.Krakow.RRM.RAN_PZ.resources.egen.egen_logs_collector import EgenLogsCollector
from testsuite.Krakow.RRM.RAN_PZ.resources.snapshot_analyzer.snapshot_analyzer import SnapshotAnalyzer


_EGEN_LOGS_COLLECTOR_INSTANCE = None


class NoActionTypeMessagesError(Exception):
    pass


class InvalidDifferentActionTypeMessagesError(Exception):
    pass


class SnapshotAnalysisFailedError(Exception):
    pass


@keyword()
def get_current_time() -> datetime:
    """
    Get the current time.

    :return: Current time as a datetime object.
    """

    return datetime.now()


@keyword()
def check_snapshot(snapshot_file_path: str, time_from_test_start: datetime) -> None:
    """
    Check snapshot logs for session timeout and t12Min/t34Min values.

    :param snapshot_file_path: Path to the snapshot file.
    :param time_from_test_start: Time from the test start.
    """

    snapshot_analyzer = SnapshotAnalyzer(
        snapshot_file_path=snapshot_file_path,
        snapshot_tgz_files_to_check=['_syslog.tgz', '_L1_logs.tgz', '_crash.tgz'],
        time_from_test_start=time_from_test_start,
        snapshot_txt_file_list='snapshot_file_list.txt',
        tmin_minimum_value=1,
        tmin_maximum_value=1_000_000
    )
    snapshot_analyzer.analyze_l1_logs_in_snapshot()

    if any(result['found'] for result in snapshot_analyzer.results.values()):
        raise SnapshotAnalysisFailedError(
            f"Snapshot analysis failed: with file: {snapshot_file_path}"
        )


@keyword()
def start_egen_logs_collection(host: str = 'SKA-ZE14-23-P02.p02.ska-lab.nsn-rdnet.net', login: str = 'egenuser',
                               password: str = 'Nokia5g!', file_name: str = "egen_logs.pcap", timeout: int = 600):
    """
    Start the Egen logs collection.
    This keyword initializes the EgenLogsCollector and starts the logs collection.

    :param host: Hostname or IP address of the Egen device.
    :param login: Login for the Egen device.
    :param password: Password for the Egen device.
    :param file_name: Name of the file to save the logs.
    :param timeout: Timeout for the command execution.
    """

    global _EGEN_LOGS_COLLECTOR_INSTANCE

    cores = "1-4"
    ports = ["3:00.0", "3:00.1"]
    additional_options = "--constant-timing --terminate --filter-string 'is_ecpri == 1 && msgtype == 5'"

    _EGEN_LOGS_COLLECTOR_INSTANCE = EgenLogsCollector(
        host=host,
        login=login,
        password=password,
        file_name=file_name,
        cores=cores,
        ports=ports,
        additional_options=additional_options,
    )
    _EGEN_LOGS_COLLECTOR_INSTANCE.start_logs_collection(timeout=timeout)
    logger.debug(f"Created Egen logs collector global instance")


@keyword()
def stop_egen_logs_collection():
    """
    Stop the Egen logs collection.
    This keyword stops the logs collection by the EgenLogsCollector instance.
    """

    global _EGEN_LOGS_COLLECTOR_INSTANCE

    if _EGEN_LOGS_COLLECTOR_INSTANCE is not None:
        _EGEN_LOGS_COLLECTOR_INSTANCE.stop_logs_collection()
        _EGEN_LOGS_COLLECTOR_INSTANCE = None
        logger.debug("Egen logs collector global instance cleared")


@keyword()
def check_egen_ecpri_logs(pcap_file_path: str, number_of_packets_in_splitted_file: int = 20_000,
                          splited_files_directory: str = "/home/ute/LOGS/CRT_MANUAL_RUNS/egen_splited/",
                          threshold: str = '4%') -> None:
    """
    Check eCPRI logs for different action types and their message counts.

    :param pcap_file_path: Path to the pcap file.
    :param number_of_packets_in_splitted_file: Number of packets in each splitted file.
    :param splited_files_directory: Directory to save the splitted files.
    :param threshold: Percentage threshold for the difference in packet counts.

    :raises InvalidDifferentActionTypeMessagesError: If the difference in packet counts exceeds the threshold.
    """

    os.makedirs(splited_files_directory, exist_ok=True)
    action_types = {
        "Request": {"field_value": "0x00", "messages_count": 0},
        "Request with Follow Up": {"field_value": "0x01", "messages_count": 0},
        "Response": {"field_value": "0x02", "messages_count": 0},
        "Remote request with Follow Up": {"field_value": "0x04", "messages_count": 0},
        "Follow Up": {"field_value": "0x05", "messages_count": 0},
    }

    splitted_files = _split_pcap_file(
        input_file=pcap_file_path,
        output_prefix="egen_ecpri_splitted",
        chunk_size=number_of_packets_in_splitted_file,
        output_directory=splited_files_directory
    )
    logger.debug(f"Number of splitted files: {len(splitted_files)}")

    for file, number in zip(splitted_files, range(len(splitted_files))):
        logger.debug(f"Processing splitted file number: {number+1}, file path: {file}")
        action_types = _count_action_types_messages(action_types=action_types, pcap_file_path=file)
        os.remove(file)
    _check_action_types_messages(action_types=action_types, threshold=threshold)


def _check_action_types_messages(action_types: Dict, threshold: str) -> None:
    """
    Check if the number of messages in different action types exceeds the threshold.

    :param action_types: Dictionary containing action types and their messages.
    :param threshold: Threshold for the difference in packet counts.

    :raises InvalidDifferentActionTypeMessagesError: If the difference in packet counts exceeds the threshold.
    :raises ValueError: If the action types dictionary is empty or has invalid keys.
    :raises TypeError: If the action types dictionary is not a dictionary.
    :raises KeyError: If the action types dictionary does not contain the expected keys.
    """

    for key, value in action_types.items():
        logger.debug(f"{key}: value: {value['field_value']}, packet length: {value['messages_count']}")

    threshold = float(threshold[:-1]) if threshold.endswith('%') else float(threshold)
    logger.debug(f"Checking action types Request and Response.")
    _check_percentage_of_action_types(
        first_action_type=action_types["Request"]["messages_count"],
        second_action_type=action_types["Response"]["messages_count"],
        threshold=threshold
    )
    logger.debug(f"Checking action types Request with Follow Up and Remote request with Follow Up.")
    _check_percentage_of_action_types(
        first_action_type=action_types["Request with Follow Up"]["messages_count"],
        second_action_type=action_types["Remote request with Follow Up"]["messages_count"],
        threshold=threshold
    )
    logger.debug(f"Checking action types Follow Up and Request with Follow Up.")
    _check_percentage_of_action_types(
        first_action_type=action_types["Follow Up"]["messages_count"],
        second_action_type=action_types["Request with Follow Up"]["messages_count"],
        threshold=threshold
    )
    logger.debug(f"All action types checked successfully.")


def _check_percentage_of_action_types(first_action_type: int, second_action_type: int, threshold: float) -> None:
    """
    Check if the percentage difference between two action types exceeds the threshold.

    :param first_action_type: Number of messages for the first action type.
    :param second_action_type: Number of messages for the second action type.
    :param threshold: Threshold for the difference in packet counts.

    :raises InvalidDifferentActionTypeMessagesError: If the difference in packet counts exceeds the threshold.
    """

    if first_action_type == 0 and second_action_type == 0:
        raise NoActionTypeMessagesError(
            f"Both action types have 0 messages. "
            f"First action type: {first_action_type}, Second action type: {second_action_type}"
        )

    difference = abs(first_action_type - second_action_type)
    highest_value = max(first_action_type, second_action_type)
    percentage = (difference / highest_value) * 100

    if percentage > threshold:
        raise InvalidDifferentActionTypeMessagesError(
            f"Action types differs more than {threshold}%. "
            f"Difference: {difference}, Highest value: {highest_value}, Difference in percentage: {percentage}%"
        )
    logger.debug(f"Action types differ less than {threshold}%. Difference in percentage: {percentage}%")


def _split_pcap_file(input_file, output_prefix, chunk_size, output_directory) -> List[str]:
    """
    Split a pcap file into smaller files.

    :param input_file: Path to the input pcap file.
    :param output_prefix: Prefix for the output files.
    :param chunk_size: Number of packets in each chunk.
    :param output_directory: Directory to save the output files.

    :return: List of paths to the split pcap files.
    """

    full_output_prefix = os.path.join(output_directory, output_prefix)
    cmd = ["editcap", "-c", str(chunk_size), input_file, full_output_prefix]
    subprocess.run(cmd, check=True)

    pattern = f"{full_output_prefix}_*"
    files = sorted(glob.glob(pattern))
    return files


def _count_action_types_messages(action_types: Dict, pcap_file_path) -> Dict:
    """
    Count the number of messages for each action type in the pcap file.

    :param action_types: Dictionary containing action types and their messages.
    :param pcap_file_path: Path to the pcap file.

    :return: Updated action types dictionary with message counts.

    """

    packets = _setup_pcp_verifier_and_get_packets(pcap_file=pcap_file_path, filters="ecpri")
    for packet in packets:
        try:
            for value in action_types.values():
                if packet.get_field_value_by_name('ecpri.actiontype')[0] == value["field_value"]:
                    value["messages_count"] += 1
        except (IndexError, KeyError) as e:
            logger.debug(f"Cannot get field value from packet. Probbably not ecpri packet.")
            continue

    del packets
    return action_types


def _setup_pcp_verifier_and_get_packets(pcap_file: str, filters: str) -> List:
    """
    Setups pcp verifier and gets packets based on passed pcap_file and filters params.

    :param pcap_file: Path to pcap file.
    :param filters: Filters for awited packets.

    :return: List contained all awited packets got from file
    """

    pcap_verifier_id = f"pcap_verifier_{uuid4().hex}"
    pcap_verifier = pcap()
    pcap_verifier.setup(infile=pcap_file, display_filter=filters, alias=pcap_verifier_id)
    packets = pcap_verifier.get_packets(pcap_parser=pcap_verifier_id)

    del pcap_verifier
    del pcap_verifier_id
    return packets
