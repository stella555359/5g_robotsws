# -*- coding: utf-8 -*-
"""
Author: Liu, Renhui   Xiang, Liangliang
Contacts: renhui-david.liu@nokia-sbell.com    liang.xiang@nokia-sbell.com
Description: this script is used to
"""

import os
import re
import yaml
import tarfile
from pathlib import Path
from datetime import datetime
import lzma
import shutil
import zipfile


def create_local_directory(file_directory):
    """
    *Usage:*
        - Keyword
        - This keyword is used to create a directory locally if the directory does not exist.
    *Contact:*
        - renhui-david.liu@nokia-sbell.com
    """
    directory = Path(file_directory)
    directory.mkdir(parents=True, exist_ok=True)
    return directory


def create_local_file(file_directory, file_name):
    """
    *Usage:*
        - Keyword
        - This keyword is used to create a file locally if the file does not exist.
    *Contact:*
        - renhui-david.liu@nokia-sbell.com
    """
    directory = create_local_directory(file_directory)
    full_path = directory / file_name
    full_path.touch(exist_ok=True)
    return str(full_path)


def run_local_command(command):
    """
    *Usage:*
        - Keyword
        - This keyword is used to run a linux command locally.
    *Contact:*
        - renhui-david.liu@nokia-sbell.com
    *Args:*
        - command: a linux command
    """
    import subprocess
    print(f"The command to run is {command}")
    process = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                               executable='/bin/bash')
    stdout, stderr = process.communicate()
    result = stdout.decode()
    print("stdout:\n", result)
    if stderr:
        print("stderr:\n", stderr.decode())
    return result


def load_yaml_to_dict(file_path):
    """
    *Usage:*
        - Keyword
        - This keyword is used to load a YAML file to a dictionary if the YAML file represents a dictionary.
    *Contact:*
        - renhui-david.liu@nokia-sbell.com
    *Args:*
        - file_path: the YAML file path.
    """
    with open(file_path, 'r') as file:
        data = yaml.safe_load(file)
    return data


def create_yaml_file(file_path, content):
    """
    *Usage:*
        - Keyword
        - This keyword is used to create a YAML file.
    *Contact:*
        - renhui-david.liu@nokia-sbell.com
    *Args:*
        - file_path: the YAML file path.
        - content: the YAML file content.
    """
    content = dict(content)
    with open(file_path, 'w') as file:
        yaml.dump(content, file, default_flow_style=False)


def check_nested_attributes(base_object, attribute_path):
    """
    *Usage:*
        - Keyword
        - This keyword is used to check if nested attributes exist.
    *Contact:*
        - renhui-david.liu@nokia-sbell.com
    *Args:*
        - base_object: the base object.
        - attribute_path: the attribute path under the base object.
    """
    try:
        attributes = attribute_path.split('.')
        value = base_object
        for attr in attributes:
            if '[' in attr:
                attr, index = attr.split('[')
                index = int(index.rstrip(']'))
                value = getattr(value, attr)[index]
            else:
                value = getattr(value, attr)
        return str(value)
    except (AttributeError, IndexError):
        return 'NONE'


def get_current_date_time():
    current_date_time = datetime.now()
    return current_date_time.strftime("%Y-%m-%d_%H-%M-%S")


def find_files_with_postfix(directory, postfix):
    """
    *Usage:*
        - Find all files in the given directory with the specified postfix.
    *Args:*
        - directory: The directory to search in.
        - postfix: The postfix of the files to find.
    """
    matching_files = []
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith(postfix):
                matching_files.append(os.path.join(root, file))
    return matching_files


def extract_files_from_zip_file(archive, directory, postfix='.pcap', substring=None):
    """
    Description: Get all required files from a zip file
    :param archive: a zip file
    :param directory: the directory to unzip file to
    :param postfix: the log filenames' postfix
    :param substring: require the log filename contains this substring
    :return: Return a list which includes all filenames with the postfix '.pcap'
    """
    import zipfile
    target_file_paths = []

    if not postfix and not substring:
        return target_file_paths

    with zipfile.ZipFile(archive, 'r') as zip_file:
        if postfix and substring:
            target_file_paths = [zip_file.extract(file, directory)
                                 for file in zip_file.namelist() if file.endswith(postfix) and substring in file]
        elif postfix:
            target_file_paths = [zip_file.extract(file, directory)
                                 for file in zip_file.namelist() if file.endswith(postfix)]
        else:
            target_file_paths = [zip_file.extract(file, directory)
                                 for file in zip_file.namelist() if substring in file]

    return target_file_paths


def extract_and_search_files(archive, directory, postfix='.pcap', substring=None):
    """
    Description: Get all required files from a zip file
    :param archive: a zip file
    :param directory: the directory to unzip file to
    :param postfix: the log filenames' postfix
    :param substring: require the log filename contains this substring
    :return: Return a list which includes all filenames with the postfix '.pcap'
    """

    target_file_paths = []

    if not postfix and not substring:
        return target_file_paths

    with zipfile.ZipFile(archive, 'r') as zip_file:
        for file in zip_file.namelist():
            zip_file.extract(file, directory)
            extracted_file_path = os.path.join(directory, file)

            if zipfile.is_zipfile(extracted_file_path):
                target_file_paths.extend(
                    extract_files_from_zip_file(extracted_file_path, directory, postfix, substring))
            elif postfix and substring and file.endswith(postfix) and substring in file:
                target_file_paths.append(os.path.abspath(extracted_file_path))
            elif postfix and file.endswith(postfix):
                target_file_paths.append(os.path.abspath(extracted_file_path))
            elif substring and substring in file:
                target_file_paths.append(os.path.abspath(extracted_file_path))
            if extracted_file_path not in target_file_paths:
                os.remove(extracted_file_path)

    return target_file_paths


def extract_files_from_nested_zip_file(archive, directory, filters):
    """
    Description: Get all required files from a nested zip file
    :param archive: a zip file
    :param directory: the directory to unzip file to
    :param filters: a list, such as [{postfix=x, substring=x}, {postfix=xx, substring=xx}]

    :return: Return a list which includes all the required filenames
    """
    archives = [archive]
    target_file_paths = []
    for filter in filters:
        target_file_paths = []
        for arc in archives:
            tmp = extract_files_from_zip_file(arc, directory,
                                              postfix=filter["postfix"], substring=filter["substring"])
            target_file_paths.extend(tmp)
        archives = target_file_paths
    return target_file_paths


def extract_xz_file(input_xz_file):
    """
    Extracts a file from a .xz compressed file.

    Args:
        input_xz_file (str): The path to the .xz file to be extracted.
    """
    if not input_xz_file.endswith('.xz'):
        return None

    output_file = input_xz_file[:-3]

    with lzma.open(input_xz_file, 'rb') as compressed_file:
        with open(output_file, 'wb') as decompressed_file:
            shutil.copyfileobj(compressed_file, decompressed_file)

    return output_file


def extract_files_from_tgz_file(archive, directory, postfix=None, substring=None):
    extracted_file_paths = []

    with tarfile.open(archive, 'r:gz') as archive:
        for member in archive.getmembers():
            is_matched = False
            if postfix and substring:
                if member.name.endswith(postfix) and substring in member.name:
                    is_matched = True
            elif postfix:
                if member.name.endswith(postfix):
                    is_matched = True
            elif substring:
                if substring in member.name:
                    is_matched = True
            if is_matched:
                archive.extract(member, directory)
                extracted_file_paths.append(os.path.join(directory, member.name))

    return extracted_file_paths


def get_custom_elements_using_regular_expression(file_path, line_regex, element_regex):
    matching_words = []
    compiled_line_regex = re.compile(line_regex)

    with open(file_path, 'r') as file:
        for line in file:
            if compiled_line_regex.search(line):
                words = re.findall(element_regex, line)
                # matching_words.extend(words)
                matching_words.append(words)

    return matching_words
