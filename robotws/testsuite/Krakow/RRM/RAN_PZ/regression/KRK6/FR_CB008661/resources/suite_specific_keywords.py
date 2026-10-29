"""
This module containing keywords for verifying average latency and operations on directories, zip and pcap files.
It includes functions to extract files from zip archives, list files in a directory, and split tcpdump files.
It also verifies the average latency against a given threshold.

:author: Mateusz Potoniec
:contact: mateusz.potoniec@nokia.com
:maintainer: mateusz.potoniec@nokia.com
"""

import os
import shlex
import zipfile
import subprocess
from typing import List

from robot.api import logger as robot_logger
from robot.api.deco import keyword


class AverageLatencyIsTooLarge(Exception):
    pass


@keyword()
def verify_average_latency(latencies: List[float], threshold: float) -> float:
    """
    Verify if the average latency is less than the given threshold.

    :param latencies: The list of latencies to calculate the average from.
    :param threshold: The threshold to compare the average latency with.

    :return: The average latency.
    """

    average_latency = round(sum(latencies) / len(latencies), 2)
    if float(average_latency) >= float(threshold):
        raise AverageLatencyIsTooLarge(
            f'Average latency: {average_latency} is too large. Should be less than {threshold}'
        )
    return average_latency


@keyword()
def extract_from_zip(zip_path: str, extract_to: str, extension: str = '.pcap') -> List[str]:
    """
    Extract files from a zip archive.

    :param zip_path: The path to the zip archive.
    :param extract_to: The path to the directory to extract files to.
    :param extension: The extension of the files to extract.

    :return: The list of extracted files.
    """

    extracted_files = []
    with zipfile.ZipFile(zip_path, 'r') as zip_ref:
        files_to_extract = [f for f in zip_ref.namelist() if f.endswith(extension)]

        for file in files_to_extract:
            file_name = os.path.basename(file)
            output_path = os.path.join(extract_to, file_name)
            os.makedirs(os.path.dirname(output_path), exist_ok=True)
            with zip_ref.open(file) as source, open(output_path, 'wb') as target:
                target.write(source.read())
            extracted_files.append(output_path)

    return extracted_files


@keyword()
def list_files_in_directory(directory: str, extension: str = None, extension_to_exclude: str = None) -> List[str]:
    """
    List files in a directory. If extension is not provided, all files are listed.

    :param directory: The path to the directory.
    :param extension: The extension of the files to list.
    :param extension_to_exclude: The extension of the files to exclude.

    :return: The list of files in the directory.
    """

    if extension:
        files_in_directory_paths = [
            os.path.join(directory, f) for f in os.listdir(directory) if f.endswith(extension)
        ]
    else:
        files_in_directory_paths = [
            os.path.join(directory, f) for f in os.listdir(directory) if os.path.isfile(os.path.join(directory, f))
        ]

    if extension_to_exclude:
        files_in_directory_paths = [
            f for f in files_in_directory_paths if not f.endswith(extension_to_exclude)
        ]

    robot_logger.debug(f"Files in directory: {files_in_directory_paths}")
    return files_in_directory_paths


@keyword()
def split_tcpdump_file(tcpdump_file_path: str, tcpdump_splited_file_path: str, lines_in_file: int = 50) -> List[str]:
    """
    The function splits the tcpdump.pcap file into several smaller ones.
    :param tcpdump_file_path: path to the original pcap file
    :param tcpdump_splited_file_path: name of new files
    :param lines_in_file: number of lines in each split file

    :return: list of splited files paths
    """

    tcpdump_splited_file_path_directory = os.path.dirname(tcpdump_splited_file_path)
    os.makedirs(tcpdump_splited_file_path_directory, exist_ok=True)
    cmd = f'tcpdump -r {tcpdump_file_path} -w {tcpdump_splited_file_path} -C {lines_in_file}'
    p = subprocess.Popen(shlex.split(cmd), stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    out, err = p.communicate()
    if p.returncode:
        robot_logger.warn(f"Cmd has exited with status code: {p.returncode}. Output: {err}")

    return list_files_in_directory(
        directory=tcpdump_splited_file_path_directory,
        extension=None,
        extension_to_exclude='.txt'
    )
