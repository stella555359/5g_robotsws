"""
This module contains functions to analyze TTI traces and verify data interruption time for UL and DL.
It also converts TTI traces from pcap to csv format.
It uses the eventdecoder converter to convert TTI traces from pcap to csv format,
and csv built-in library to analyze the csv file.

:author: Mateusz Potoniec
:contact: mateusz.potoniec@nokia.com
:maintainer: mateusz.potoniec@nokia.com
"""

import os
import csv
from datetime import datetime
from typing import List, Tuple

from robot.api import logger as robot_logger
from robot.api.deco import keyword
from taf.converters.eventdecoder import eventdecoder
from taf.rfrl.utilities.logger import custom_logger as logger


class RntiAreEqual(Exception):
    pass


class HOEventNotFound(Exception):
    pass


class DataEventNotFound(Exception):
    pass


class DataInteruptionTimeNotFound(Exception):
    pass


@keyword()
def verify_data_interuption_time_for_ul_and_dl(
        pcap_files_paths_list: List[str],
        ul_event_type: str = 'ulTdSchedSubcellData',
        ul_ho_event_value: float = 90.0,
        ul_data_event_value: float = 30.0,
        dl_event_type: str = 'dlTdSchedSubcellData',
        dl_ho_event_value: float = 99.0,
        dl_data_event_value: float = 40.0,
        csv_output_file_path: str = '/home/ute/LOGS/CRT_MANUAL_RUNS/ttis') -> Tuple[float, float]:

    """
    Verify data interruption time for UL and DL in TTI traces.

    :param files_path: The path to pcap files with TTI trace.
    :param ul_event_type: The event type to filter the data for UL.
           Either ulTdSchedSubcellData for UL or dlTdSchedSubcellData for DL.
    :param ul_ho_event_value: The value of the event type for handover for UL. Either 90.0 for UE or 99.0 for DL.
    :param ul_data_event_value: The value of the event type for data for UL. Either 30 for UE or 40 for DL.
    :param dl_event_type: The event type to filter the data for DL.
           Either ulTdSchedSubcellData for UL or dlTdSchedSubcellData for DL.
    :param dl_ho_event_value: The value of the event type for handover for DL. Either 90.0 for UE or 99.0 for DL.
    :param dl_data_event_value: The value of the event type for data for DL. Either 30 for UE or 40 for DL.
    :param csv_output_file_path: The path to the output csv file.

    :return: The data interruption time for UL and DL.

    :raises DataInteruptionTimeNotFound: If data interruption time for UL or DL is not found in the TTI traces.
    """

    data_interuption_time_ul = None
    data_interuption_time_dl = None
    pcap_files_paths_list.sort()
    logger.log_info_to_console(msg=f'Number of pcap files to analyze: {len(pcap_files_paths_list)}.', log_hierarchy=2)

    for pcap_file in pcap_files_paths_list:
        convert_tti_trace_from_pcap_to_csv(pcap_file, f'{csv_output_file_path}/excelCsv')
        ul_csv_files, dl_csv_files = _list_csv_files_in_directory(csv_output_file_path)

        if not data_interuption_time_ul:
            data_interuption_time_ul = analyze_tti_trace_csv_files(
                ul_csv_files,
                ul_event_type,
                ul_ho_event_value,
                ul_data_event_value
            )
        if not data_interuption_time_dl:
            data_interuption_time_dl = analyze_tti_trace_csv_files(
                dl_csv_files,
                dl_event_type,
                dl_ho_event_value,
                dl_data_event_value
            )

        if data_interuption_time_ul is not None and data_interuption_time_dl is not None:
            logger.log_info_to_console(
                msg=f'HO and data interruption time was found in file: {os.path.basename(pcap_file)}.',
                log_hierarchy=2
            )
            robot_logger.debug(f'HO and data interruption time was found in file: {os.path.basename(pcap_file)}.')
            break

    if data_interuption_time_ul is None or data_interuption_time_dl is None:
        raise DataInteruptionTimeNotFound(f'Data interruption time for UL or DL not found in the TTI traces, '
                                          f' UL: {data_interuption_time_ul}, DL: {data_interuption_time_dl}.')
    robot_logger.debug(f' Data interruption time UL: {data_interuption_time_ul} ms.')
    robot_logger.debug(f' Data interruption time DL: {data_interuption_time_dl} ms.')
    return data_interuption_time_ul, data_interuption_time_dl


@keyword()
def analyze_tti_trace_csv_files(
        csv_file_list: List[str],
        event_type: str,
        ho_event_value: float,
        data_event_value: float) -> float:
    """
    Analyze TTI trace csv files to find data interruption time for either UL or DL.

    :param csv_file_list: The list of csv files with TTI traces.
    :param event_type: The event type to filter the data.
    :param ho_event_value: The value of the event type for handover.
    :param data_event_value: The value of the event type for data.

    :return: The data interruption time as float.
    """

    for csv_file in csv_file_list:
        logger.log_info_to_console(
            msg=f'Analyzing csv file: {os.path.basename(csv_file)} for data interruption time.',
            log_hierarchy=3
        )
        try:
            data_interuption_time = verify_data_interuption_time_in_tti_traces(
                csv_file,
                event_type,
                ho_event_value,
                data_event_value
            )

            logger.log_info_to_console(
                msg=f'HO and data interruption time was found in file: {os.path.basename(csv_file)}.',
                log_hierarchy=3
            )
            robot_logger.debug(f'HO and data interruption time was found in file: {os.path.basename(csv_file)}.')
            return data_interuption_time
        except (HOEventNotFound, RntiAreEqual, DataEventNotFound) as e:
            robot_logger.debug(f'HO event not found in file: {os.path.basename(csv_file)}, Reason: {e}.')
            continue
    return None


@keyword()
def convert_tti_trace_from_pcap_to_csv(pcap_path: str, output_path: str) -> None:
    """
    Convert TTI traces from pcap to csv.

    :param pcap_path: The path to the pcap file with TTI traces.
    :param output_path: The path to the output csv file.

    :return: None
    """
    logger.log_info_to_console(msg=f'Converting TTI trace from pcap: {pcap_path} to csv.', log_hierarchy=2)
    clean_directory_from_files_if_any_exist(os.path.dirname(output_path))

    event_decoder = eventdecoder()
    robot_logger.debug(f'Create event decoder converter for TTI traces.')
    event_decoder.create_eventdecoder_converter(
        name='ttitrace_converter_excelCsv',
        input_file_path=pcap_path,
        output_file_path=output_path,
        output_file_format='excelCsv',
        tti_dec_path='/home/ute/tti_decoder/tti-dec-bin',
    )
    robot_logger.debug(f'Convert TTI traces from pcap: {pcap_path} to csv.')
    event_decoder.convert(name='ttitrace_converter_excelCsv')
    robot_logger.debug(f'Conversion ended succesfully.')


@keyword()
def verify_data_interuption_time_in_tti_traces(csv_file_path: str, event_type: str, ho_event_value: float,
                                               data_event_value: float) -> float:
    """
    Verify data interruption time in TTI traces using the built-in csv library.

    :param csv_file_path: The path to the csv file with TTI traces.
    :param event_type: The event type to filter the data.
                       Either ulTdSchedSubcellData for UL or dlTdSchedSubcellData for DL.
    :param ho_event_value: The value of the event type for handover. Either 90.0 for UE or 99.0 for DL.
    :param data_event_value: The value of the event type for data. Either 30 for UE or 40 for DL.

    :return: The data interruption time.

    :raises HOEventNotFound: If HO event is not found in the csv file.
    :raises RntiAreEqual: If RNTI before and after HO are equal.
    """

    event_type = f'{event_type}.resReqClassPrio'
    ho_event_value = float(ho_event_value)
    data_event_value = float(data_event_value)

    last_event_before_ho, first_event_after_ho = _find_last_and_first_events_before_and_after_ho(
        csv_file_path,
        event_type,
        float(ho_event_value),
        float(data_event_value)
    )
    robot_logger.debug(f"Last event before HO RNTI: {last_event_before_ho['rnti']}")
    robot_logger.debug(f"First event after HO RNTI: {first_event_after_ho['rnti']}")
    robot_logger.debug(f"Last event before HO time: {last_event_before_ho['timeStamp']}")
    robot_logger.debug(f"First event after HO time: {first_event_after_ho['timeStamp']}")

    robot_logger.debug(f'Check if RNTI before and after HO are not equal.')
    if last_event_before_ho['rnti'] == first_event_after_ho['rnti']:
        logger.log_warn_to_console(msg=f'RNTI before and after HO are equal.', log_hierarchy=3)
        logger.log_warn_to_console(
            msg=f'Before HO RNTI: {last_event_before_ho["rnti"]}, After HO RNTI: {first_event_after_ho["rnti"]}',
            log_hierarchy=3
        )
        raise RntiAreEqual(f'RNTI before and after HO are equal., RNTI: {last_event_before_ho["rnti"]}')

    return _calculate_data_interuption_time_latency(
        last_event_before_ho['timeStamp'],
        first_event_after_ho['timeStamp']
    )


def _find_last_and_first_events_before_and_after_ho(csv_file_path: str, event_type: str, ho_event_value: float,
                                                    data_event_value: float) -> Tuple[dict, dict]:
    """
    Find the last event before handover and the first event after handover.

    :param csv_file_path: The path to the csv file with TTI traces.
    :param event_type: The event type to filter the data.
    :param ho_event_value: The value of the event type for handover.
    :param data_event_value: The value of the event type for data.

    :return: The last event before handover and the first event after handover.

    :raises HOEventNotFound: If HO event is not found in the csv file.
    :raises DataEventNotFound: If data event is not found in the csv file.
    """

    ho_index, last_event_before_ho, first_event_after_ho = None, None, None

    with open(csv_file_path, mode='r') as csv_file:
        reader = csv.DictReader(csv_file)
        rows = list(reader)

        ho_index = _find_ho_event_index(rows, event_type, ho_event_value)
        if ho_index is None:
            raise HOEventNotFound(f'HO event {ho_event_value} not found in the csv file.')
        robot_logger.debug(f'HO event found on index: {ho_index}')

        events_before_ho = rows[:ho_index]
        events_after_ho = rows[ho_index:]

        last_event_before_ho = _find_last_event_before_ho(events_before_ho, event_type, data_event_value)
        first_event_after_ho = _find_first_event_after_ho(events_after_ho, event_type, data_event_value)

    if not last_event_before_ho or not first_event_after_ho:
        logger.log_warn_to_console(
            msg=f'Could not find required events before or after HO in file: {os.path.basename(csv_file_path)}.',
            log_hierarchy=3
        )
        logger.log_warn_to_console(
            msg=f'Last event before HO: {last_event_before_ho}, First event after HO: {first_event_after_ho}.',
            log_hierarchy=3
        )
        raise DataEventNotFound("Could not find required events before or after HO.")
    return last_event_before_ho, first_event_after_ho


def _find_ho_event_index(events: List[dict], event_type: str, ho_event_value: float) -> int:
    """
    Find the index of the HO event in the list of events.

    :param events: The list of events.
    :param event_type: The event type to filter the data.
    :param ho_event_value: The value of the event type for handover.

    :return: The index of the HO event.
    """

    for index, row in enumerate(events):
        try:
            if float(row[event_type]) == ho_event_value:
                return index
        except ValueError:
            continue
    return None


def _find_last_event_before_ho(events_before_ho: List[dict], event_type: str, data_event_value: float) -> dict:
    """
    Find the last event before handover.

    :param events_before_ho: The list of events before handover.
    :param event_type: The event type to filter the data.
    :param data_event_value: The value of the event type for data.

    :return: The last event before handover.
    """

    for row in reversed(events_before_ho):
        try:
            if float(row[event_type]) == data_event_value:
                return row
        except ValueError:
            continue
    return None


def _find_first_event_after_ho(events_after_ho: List[dict], event_type: str, data_event_value: float) -> dict:
    """
    Find the first event after handover.

    :param events_after_ho: The list of events after handover.
    :param event_type: The event type to filter the data.
    :param data_event_value: The value of the event type for data.

    :return: The first event after handover.
    """

    for row in events_after_ho:
        try:
            if float(row[event_type]) == data_event_value:
                return row
        except ValueError:
            continue
    return None


def _calculate_data_interuption_time_latency(last_event_before_ho_time: str, first_event_after_ho_time: str) -> float:
    """
    Calculate the data interruption time latency between two events.

    :param last_event_before_ho_time: The last event before handover time.
    :param first_event_after_ho_time: The first event after handover time.

    :return: The data interruption time latency.
    """

    last_event_before_ho_time = datetime.strptime(last_event_before_ho_time, '%Y-%m-%d %H:%M:%S.%f')
    first_event_after_ho_time = datetime.strptime(first_event_after_ho_time, '%Y-%m-%d %H:%M:%S.%f')
    data_interuption_time_latency = (first_event_after_ho_time - last_event_before_ho_time).total_seconds() * 1000

    return data_interuption_time_latency


def _list_csv_files_in_directory(directory: str) -> Tuple[List[str], List[str]]:
    """
    List all csv files in the given directory.

    :param directory: The directory to search for csv files.
    :return: A tuple containing two lists: one for UL csv files and one for DL csv files.
    """
    ul_csv_files = [os.path.join(directory, f) for f in os.listdir(directory) if f.startswith('excelCsv_ul.')]
    dl_csv_files = [os.path.join(directory, f) for f in os.listdir(directory) if f.startswith('excelCsv_dl.')]
    logger.log_info_to_console(
            msg=f'Found {len(ul_csv_files)} UL and {len(dl_csv_files)} DL converted csv files.',
            log_hierarchy=2
        )
    robot_logger.debug(f' List of UL csv files: {ul_csv_files}, length: {len(ul_csv_files)}.')
    robot_logger.debug(f' List of DL csv files: {dl_csv_files}, length: {len(dl_csv_files)}.')
    return ul_csv_files, dl_csv_files


@keyword()
def clean_directory_from_files_if_any_exist(directory_path: str) -> bool:
    """
    Clean the given directory from files if any files exist.

    :param directory_path: The path to the directory to clean.
    :return: None
    """

    if not os.path.exists(directory_path):
        robot_logger.debug(f'Directory: {directory_path} does not exist. No cleaning needed.')
        return False

    files_in_path = os.listdir(directory_path)
    length_of_files_in_path = len(files_in_path)
    robot_logger.debug(f'There are {length_of_files_in_path} files in directory: {directory_path} before cleaning.')

    if length_of_files_in_path > 0:
        robot_logger.debug(f'Cleaning directory: {directory_path} from files: {files_in_path}.')
        for file in files_in_path:
            file_path = os.path.join(directory_path, file)
            os.remove(file_path)
        return True
    return False
