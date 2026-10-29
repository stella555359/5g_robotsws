# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:maintainer: Adrianna Pienkowska
:contact: adrianna.pienkowska@nokia.com
:team: I_5GSC_SW_ENG_KRK_VRF_GMS
:email: I_5GSC_SW_ENG_KRK_VRF_GMS <I_5GSC_SW_ENG_KRK_VRF@internal.nsn.com>
"""

import os
import json
import gzip
import glob
import errno
import shutil
import tarfile
import xml.etree.ElementTree as ETree
from zipfile import ZipFile, BadZipfile, ZIP_DEFLATED

from robot.api import logger
from taf.transport.ssh import ssh
from contextlib import contextmanager
from robot.libraries.BuiltIn import BuiltIn
from robot.libraries.OperatingSystem import OperatingSystem

from testsuite.Krakow.RRM.Airphone.resources.Python.utilities import (
    logger_console, logger_warning, logger_info
)


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
    connection = ssh()
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


def remove_file_from_ap(files: list):
    with ssh_session(ip_addr=BuiltIn().get_variable_value("${AP_IP}"),
                     username=BuiltIn().get_variable_value("${NOKIA_USERNAME}"),
                     password=BuiltIn().get_variable_value("${NOKIA_PASS}")) as connection:
        for file in files:
            stdout = connection.execute(f'rm -rf {file}')
            stdout = connection.execute(f'if [ -e {file} ]; then echo "EXIST"; fi')
            if "EXIST" in stdout:
                raise FileExistsError(f"File: {file} was not removing, File still exist")


def remove_file_from_gnb(files: list):
    with ssh_session(ip_addr=BuiltIn().get_variable_value("${GNB_IP}"),
                     username=BuiltIn().get_variable_value("${NOKIA_USERNAME}"),
                     password=BuiltIn().get_variable_value("${NOKIA_PASS}")) as connection:
        for file in files:
            stdout = connection.execute(f'rm -rf {file}')
            stdout = connection.execute(f'if [ -e {file} ]; then echo "EXIST"; fi')
            if "EXIST" in stdout:
                raise FileExistsError(f"File: {file} was not removing, File still exist")


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
    if not isinstance(src_local_paths, list):
        src_local_paths = [src_local_paths]

    for local in src_local_paths:
        logger_console(f'Copying {local} to {dst_local_path}')
        OperatingSystem().copy_file(source=local, destination=dst_local_path)


def move_files_from_local_to_local(src_local_paths, dst_local_path):
    """Copies all files from source to destination path.

    :param src_local_paths: list of all paths, which are pointing to some file
    :param dst_local_path: just destination path
    """
    if not isinstance(src_local_paths, list):
        src_local_paths = [src_local_paths]

    for local in src_local_paths:
        logger.info("Moving {} to {}".format(local, dst_local_path), also_console=True)
        OperatingSystem().move_file(source=local, destination=dst_local_path)


def load_json_file(path):
    """Loads json file and returns its content.

    :param path: path pointing to json file
    :return: content of json file
    """
    logger_console(f'Loading json file: {path}')
    with open(path) as json_file:
        json_content = json.load(json_file)

    return json_content


def save_json_file(path, json_content):
    """Saves json contents at given path

    :param path: path, poiting to some .json file
    :param json_content: str with json contents.
    """
    logger_console(f'Saving json file: {path}')
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


def ungzip_file(file_path, destination):
    """
    It unzip a gzip file to a given destination

    :author: Jacek Kozmic
    :param file_path: a path to the file to ungzip
    :param destination: a path to a place to unpack the gzip file
    :return: nothing
    """
    file_name = file_path.split('/')[-1].rstrip('.gz')
    new_file = os.path.join(destination, file_name)
    with gzip.open(file_path, 'rb') as f_in:
        with open(new_file, 'wb') as f_out:
            shutil.copyfileobj(f_in, f_out)


def unzip_file(file_path, destination):
    """
    It unzip a zip file to a given destination

    :author: Jacek Kozmic
    :param file_path: a path to the file to unzip
    :param destination: a path to a place to unpack the zip file
    :return: nothing
    """
    try:
        with ZipFile(file_path, 'r') as zip_file:
            zip_file.extractall(destination)
    except BadZipfile as error:
        ungzip_file(file_path, destination)


def get_latest_file(filepath_pattern):
    """Returns latest created file.

    :param filepath_pattern: path pointing to some extension, ex. /home/ute/*.pcap
    :return: latest file matching pattern
    """
    list_of_files = glob.glob(filepath_pattern)
    logger_console(f'Files in directory: {list_of_files}')
    latest_file = max(list_of_files, key=os.path.getctime)
    return latest_file


def create_dir_at_output_dir(dir_name, outputdir=None):
    """Creates new directory at ${OUTPUT_DIR} and returns path to it.

    :param dir_name: new directory name
    :param path: path where directory will be created. If None  the directory will be at ${OUTPUT_DIR}
    :return: newly created path
    """
    if outputdir is None:
        outputdir = BuiltIn().get_variable_value("${OUTPUT_DIR}")
    dir_to_create = os.path.join(outputdir, dir_name)
    logger_console(f'Creating directory {dir_to_create}')
    try:
        os.mkdir(dir_to_create)
    except OSError as e:
        if e.errno == errno.EEXIST:
            logger_warning(f'File exists error during {dir_to_create} creation: {e}')
        else:
            logger_warning(f'Other error during {dir_to_create} creation: {e}')
            raise e
    return dir_to_create


def create_dir(dir_name, path=None):
    """Creates new directory at path and returns a new path to it.

    :param dir_name: new directory name
    :param path: path where directory will be created. If None  the directory will be at ${OUTPUT_DIR}
    :return: newly created path
    """
    if path is None:
        path = BuiltIn().get_variable_value("${OUTPUT_DIR}")
    dir_to_create = os.path.join(path, dir_name)
    logger_console(f'Creating directory {dir_to_create}')
    OperatingSystem().create_directory(dir_to_create)
    return dir_to_create


def create_dir_from_file_path(dir_name, file_name_path):
    """Creates new directory at path and returns a new path to it.

    :param dir_name: new directory name
    :param path: path where directory will be created. If None  the directory will be at ${OUTPUT_DIR}
    :return: newly created path
    """
    if file_name_path is None:
        path = BuiltIn().get_variable_value("${OUTPUT_DIR}")
    path = os.path.dirname(file_name_path)
    dir_to_create = os.path.join(path, dir_name)
    logger_console(f'Creating directory {dir_to_create}')
    OperatingSystem().create_directory(dir_to_create)
    return dir_to_create


def list_all_files_in_directory(directory):
    """List all files existing in given directory and returns it

    :param: directory: directory name
    :return: list of all files in given dir
    """
    assert_path_exists(file_path=directory)
    files = os.listdir(directory)
    return files


def extract_tarfile_to_dir_and_remove(out_dir, file_path):
    """
    Extracts TAR archive to directory and deletes the file

    :param out_dir: full path to directory to which TAR is to be extracted
    :param file_path: full path to file to be extracted
    """
    if not os.path.exists(out_dir):
        os.mkdir(out_dir)
    with tarfile.open(file_path) as archive_file:
        try:
            archive_file.extractall(out_dir)
        except EOFError:
            msg = f'EOF exception caught during tar file extraction. This usually shouldn\'t cause any problem'
            logger_console(msg)
    os.remove(file_path)


def add_all_files_in_directory_to_zip(dir_path=None, separate=False):
    """ Adds all files and subdirectories to a zip archive. Can create separate archives for all subdirectories.
    :param dir_path: str, directory which should be archived
    :param separate: boolean, if set to True creates separate archives for all subdirectories.
    """
    if not dir_path:
        dir_path = BuiltIn().get_variable_value("${OUTPUT_DIR_TC}")
    dir_content = list(os.walk(dir_path))
    logger_console(os.listdir(dir_path))
    if not separate:
        current_zip = ZipFile(f"{dir_path}.zip", "w")
    for dirname, subdirs, files in dir_content[1:]:
        log_name = dirname.split("/")[-1]
        if separate:
            current_zip = ZipFile(f"{dir_path}/{log_name}.zip", "w")
        for filename in files:
            current_zip.write(os.path.join(dirname, filename), filename, compress_type=ZIP_DEFLATED)
        if separate:
            current_zip.close()
    if not separate:
        current_zip.close()


def add_all_logs_to_zip(dir_path=None, delete_added_files=False):
    """ Adds all logs to zip files.
    :param dir_path: str, directory with logs that shoule be archived
    :param delete_added_files: boolean, if True deletes directories which are alread archived
                               (but not the created archives)
    Requires robot variables:
    LOGS_DICT
    """
    if not dir_path:
        dir_path = BuiltIn().get_variable_value("${OUTPUT_DIR_TC}")
    logs_dict = BuiltIn().get_variable_value("${LOGS_DICT}")
    for log_name, logs_paths in logs_dict.items():
        current_zip = ZipFile(f"{dir_path}/{log_name}.zip", "w")
        for apath in logs_paths:
            log_filename = apath.split("/")[-1].split(".")[0]
            if 'SHERPA_CSV' == log_name:
                csv_dir_zip = ZipFile(f"{dir_path}/{log_filename}.zip", "w")
                for afile in os.listdir(apath):
                    filename = afile.split("/")[-1].split(".")[0]
                    csv_dir_zip.write(os.path.join(apath, afile), filename, compress_type=ZIP_DEFLATED)
                csv_dir_zip.close()
                current_zip.write(f"{dir_path}/{log_filename}.zip", log_filename, compress_type=ZIP_DEFLATED)
                OperatingSystem().remove_file(f"{dir_path}/{log_filename}.zip")
            else:
                current_zip.write(apath, log_filename, compress_type=ZIP_DEFLATED)
        current_zip.close()
        if delete_added_files:
            dir_to_delete = os.path.join(dir_path, log_name)
            OperatingSystem().remove_directory(dir_to_delete, recursive=True)


def download_artifactory_file(artifactory_url, filename, target_dir,
                              user='esupport', token='AP9S2AEm4AyeZLuopbUoJNE3gwo'):
    """
    Downloads package from artifactory.

    :param user: (str) username
    :param token: (str) token used to download file
    :param artifactory_url: (str) URL to artifactory repository
    :param filename: (str) Name of the file to be downloaded
    :param target_dir: (str) Destination where file will be downloaded
    :return file_path: (str) Path to downloaded file
    """

    file_path = os.path.join(target_dir, filename)
    if os.path.exists(file_path):
        logger_info('File is already downloaded. Skipping download.')
    else:
        url = os.path.join(artifactory_url, filename)
        os.system(f'cd {target_dir} && curl -u{user}:{token} -O "{url}"')
        logger_info(f'File downloaded at {file_path}')
    return file_path
