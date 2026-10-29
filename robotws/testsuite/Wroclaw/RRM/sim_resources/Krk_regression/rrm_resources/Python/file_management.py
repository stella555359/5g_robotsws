# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Mateusz Rzeczyca
:contact: mateusz.rzeczyca@nokia.com
:team: I_5GSC_SW_ENG_KRK_VRF_GMS
:email: I_5GSC_SW_ENG_KRK_VRF_GMS <I_5GSC_SW_ENG_KRK_VRF@internal.nsn.com>
"""

from robot.libraries.OperatingSystem import OperatingSystem
from robot.libraries.BuiltIn import BuiltIn
from robot.api import logger
from contextlib import contextmanager
from taf.transport.ssh import ssh as _ssh
from zipfile import ZipFile
import glob
import json
import os
from utilities import logger_console


@contextmanager
def ssh_session(ip_addr, username, password):
    """
    It yields ssh connection and finally closes it.

    :author: Adrianna Pienkowska
    :param ip_addr: remote ip address
    :param username: remote's username
    :param password: password to remote
    :return connection: an established ssh connection to remote
    """
    connection = _ssh()
    connection.connect_to(hostname=ip_addr, username=username, password=password)
    try:
        yield connection
    finally:
        connection.disconnect()


def download_files_from(ip_addr, username, password, files, local_path):
    """
    It dwonloads files from remote to the remote path

    :author: Mateusz Rzeczyca
    :modified: 12.07.2021 by Adrianna Pienkowska
    :param ip_addr: remote ip address
    :param username: remote's username
    :param password: password to remote
    :param files: a list of paths on remote to files which should be copied
    :param local_path: a path to which files should be copied
    :return: nothing
    """
    with ssh_session(ip_addr, username, password) as connection:
        connection.download_file(remote_path=files, local_path=local_path)


def upload_file_to(ip_addr, username, password, files, remote_path):
    """
    It uploads files from local to the remote path

    :author: Mateusz Rzeczyca
    :modified: 12.07.2021 by Adrianna Pienkowska
    :param ip_addr: remote ip address
    :param username: remote's username
    :param password: password to remote
    :param files: a list of paths on local device to files which should be copied
    :param remote_path: a remote path to which files should be copied
    :return: nothing
    """
    with ssh_session(ip_addr, username, password) as connection:
        connection.upload_file(local_path=files, remote_path=remote_path)


def upload_files_to_gnb(remote_path, files):
    """
    It uploads files from local to gNB's remote path

    :author: Mateusz Rzeczyca
    :param files: a list of paths on local device to files which should be copied
    :param remote_path: a remote path to which files should be copied
    :return: nothing
    """
    upload_file_to(
        ip_addr=BuiltIn().get_variable_value("${GNB_IP}"),
        username=BuiltIn().get_variable_value("${NOKIA_USERNAME}"),
        password=BuiltIn().get_variable_value("${NOKIA_PASS}"),
        files=files,
        remote_path=remote_path
    )


def upload_files_to_ap(remote_path, files):
    """
    It uploads files from local to AirPhone's remote path

    :author: Anna Bien
    :param files: a list of paths on local device to files which should be copied
    :param remote_path: a remote path to which files should be copied
    :return: nothing
    """
    upload_file_to(
        ip_addr=BuiltIn().get_variable_value("${AP_IP}"),
        username=BuiltIn().get_variable_value("${NOKIA_USERNAME}"),
        password=BuiltIn().get_variable_value("${NOKIA_PASS}"),
        files=files,
        remote_path=remote_path
    )


def copy_files_from_gnb(files, local_path):
    """Copies files from gNB to local path

    :author: Mateusz Rzeczyca
    :param files: a list of paths on gNB to files which should be copied
    :param local_path: a path to which files should be copied
    :return: nothing
    """
    download_files_from(
        ip_addr=BuiltIn().get_variable_value("${GNB_IP}"),
        username=BuiltIn().get_variable_value("${NOKIA_USERNAME}"),
        password=BuiltIn().get_variable_value("${NOKIA_PASS}"),
        files=files,
        local_path=local_path
    )


def copy_files_from_ap(files, local_path):
    """Copies files from AirPhone to local path

    :author: Mateusz Rzeczyca
    :param files: a list of paths on AP to files which should be copied
    :param local_path: a path to which files should be copied
    :return: nothing
    """
    download_files_from(
        ip_addr=BuiltIn().get_variable_value("${AP_IP}"),
        username=BuiltIn().get_variable_value("${NOKIA_USERNAME}"),
        password=BuiltIn().get_variable_value("${NOKIA_PASS}"),
        files=files,
        local_path=local_path
    )


def copy_files_from_local_to_local(src_local_paths, dst_local_path):
    """Copies all files from source to destination path.

    :param src_local_paths: list of all paths, which are pointing to some file
    :param dst_local_path: just destination path
    """
    for local in src_local_paths:
        logger.info("Copying {} to {}".format(local, dst_local_path), also_console=True)
        OperatingSystem().copy_file(source=local, destination=dst_local_path)


def load_json_file(path):
    """Loads json file and returns its content.

    :param path: path pointing to json file
    :return: content of json file
    """
    logger.info("Loading json file: {}".format(path), also_console=True)
    with open(path) as json_file:
        json_content = json.load(json_file)

    return json_content


def save_json_file(path, json_content):
    """Saves json contents at given path

    :param path: path, poiting to some .json file
    :param json_content: str with json contents.
    """
    logger.info("Saving json file: {}".format(path), also_console=True)
    with open(path, 'w') as json_file:
        json.dump(json_content, json_file)


def change_file_name(old_name, new_name):
    """
    It changes old file name to new file name. If the change is on the files in another directory, it needs
    a full path with old name and with new name.

    :author: Adrianna Pienkowska
    :param old_name: a path to the file with old name
    :param new_name: a path to the file's new name
    :return: nothing
    """
    os.rename(old_name, new_name)


def check_file_exists(local_path):
    """Checks if file exists locally and returns result in a True/False manner.

    :param local_path: path, which existence shall be checked
    :return: True if path exists, False otherwise
    """
    return True if OperatingSystem().get_file_size(path=local_path) != 0 else False


def check_path_exists(file_path):
    """
    It checks if the given file exists.

    :author: Jacek Kozmic
    :param file_path: a path to the file to check
    :return: nothing
    """
    return os.path.exists(file_path) if file_path else False


def assert_path_exists(file_path):
    """
    It assert if the given file exists.

    :author: Jacek Kozmic
    :param file_path: a path to the file to assert.
    :return: nothing
    """
    assert check_path_exists(file_path)


def unzip_file(file_path, destination):
    """
    It unzip a zip file to a given destination

    :author: Jacek Kozmic
    :param file_path: a path to the file to unzip
    :param destination: a path to a place to unpack the zip file
    :return: nothing
    """
    with ZipFile(file_path, 'r') as zip_file:
        zip_file.extractall(destination)


def get_latest_file(filepath_pattern):
    """Returns latest created file.

    :param filepath_pattern: path pointing to some extension, ex. /home/ute/*.pcap
    :return: latest file matching pattern
    """
    list_of_files = glob.glob(filepath_pattern)
    logger_console("Files in directory: {}".format(list_of_files))
    latest_file = max(list_of_files, key=os.path.getctime)
    return latest_file


def create_dir_at_output_dir(dir_name):
    """Creates new directory at ${OUTPUT_DIR} and returns path to it.

    :param dir_name: new directory name, which shall be created at ${OUTPUT_DIR}
    :return: newly created path
    """
    dir_to_create = os.path.join(BuiltIn().get_variable_value("${OUTPUT_DIR}"), dir_name)
    logger_console("Creating directory {}".format(dir_to_create))
    OperatingSystem().create_directory(dir_to_create)
    return dir_to_create
