import re
import os
import logging
from moler.device import DeviceFactory
from taf.rfrl.bts.parsers.snapshot_analyzer import parse_snapshot_file_list
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl


def check_if_entry_exist_in_file(file_path, first_keyword, second_keyword=''):
    """
    Check if entry keywords exist in given file

    :param file_path: path to file to check
    :param str first_keyword: first keyword - keyword to check if exist in file
    :param str second_keyword: second keyword - keyword to check if exist in file (default value: '')
    :return: boolean
    """

    if not search_in_file(file_path, first_keyword, second_keyword):
        raise Exception("Entry with '{}' and '{}' not found".format(first_keyword, second_keyword))


def search_in_file(file_path, first_keyword, second_keyword=''):
    """
    Search if file contains given keywords

    :param file_path: path to file where search given keywords
    :param str first_keyword: first keyword - keyword to search in file
    :param str second_keyword: second keyword - keyword to search in file (default value: '')
    :return: str file name contains given keywords
    """

    with open(file_path, 'r') as file_content:
        for line in file_content:
            if first_keyword in line and second_keyword in line:
                return line.strip()


def search_file_in_snapshot(file_name_to_find, snapshot_path, primary_file_regex=re.compile("^BTS.*.zip")):
    """
    Search file in given snapshot

    :param: str file_name_to_find: file name to find in snapshot
    :param: snapshot_path: path to snapshot
    :return: return_file : searched file
    """

    output_dir = os.path.join(os.path.dirname(snapshot_path), "extracted_files")
    unpack_zip_file(snapshot_path, output_dir)
    file_name_to_find_regex = re.compile(file_name_to_find)

    all_snapshot_files = parse_snapshot_file_list(os.path.join(output_dir, 'snapshot_file_list.txt'))
    for files in all_snapshot_files:
        if primary_file_regex.search(files['file_name']):
            for secondary_file in files['sub_files']:
                if file_name_to_find_regex.search(secondary_file):
                    return_file = os.path.join(output_dir, files['file_name'], secondary_file)
                    logging.info("File was found: {0}".format(return_file))
                    return return_file
    raise Exception("Cannot find {} file".format(file_name_to_find))


def extract_file_from_snapshot(file_name_to_extract, snapshot_path, extracted_dir_name='extracted_files'):
    """
    Extract given file from snapshot

    :param str file_name_to_extract: file name to extract from snapshot
    :param snapshot_path: path to snapshot contains file to extract
    :param extracted_dir_name: path to extracted_files
    """

    extracted_dir_path = os.path.join(os.path.dirname(snapshot_path), extracted_dir_name)
    found_file = search_file_in_snapshot(file_name_to_extract, snapshot_path)
    primary_file = found_file.split("/")[-2]
    secondary_file = found_file.split("/")[-1]
    unpack_zip_file(os.path.join(extracted_dir_path, primary_file), extracted_dir_path)
    unpack_xz_file(os.path.join(extracted_dir_path, secondary_file))
    extracted_secondary_file_name = ".".join(secondary_file.split(".")[:-1])
    return os.path.join(extracted_dir_path, extracted_secondary_file_name)


def check_if_file_exist(file_name_to_find, snapshot_path):
    """
    Check if given file exist in snapshot

    :param str file_name_to_find: file name to find in snapshot
    :param snapshot_path: path to snapshot to check if given file exist
    :return: boolean
    """
    found_file = search_file_in_snapshot(file_name_to_find, snapshot_path)
    return os.path.exists(found_file)


@load_moler_configuration_from_tl()
def unpack_zip_file(file_path, output_dir):
    """
    Unpack file in zip format

    :param: file_path: path to file to unpack
    :param: output_dir: directory for extract file
    :return :None
    """

    device = DeviceFactory.get_device(name='UnixLocal')
    device.get_cmd(cmd_name='unzip', cmd_params={"zip_file": file_path, "options": "",
                                                 "extract_dir": output_dir, "overwrite": True})()


@load_moler_configuration_from_tl()
def unpack_xz_file(file_path):
    """
    Unpack file in xz format

    :param: file_path: path to file to unpack
    :param: output_dir: directory for extract file
    :return :None
    """

    device = DeviceFactory.get_device(name='UnixLocal')
    device.get_cmd(cmd_name='unxz', cmd_params={"xz_file": file_path, "options": "-f"})()
