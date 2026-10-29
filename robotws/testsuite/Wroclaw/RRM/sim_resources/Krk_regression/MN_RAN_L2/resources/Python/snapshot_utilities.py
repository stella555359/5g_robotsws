"""
:copyright: Nokia Networks
:author: Mateusz Plinta, Damian Piasecki
:maintainer: Damian Piasecki
:contact: damian.piasecki@nokia.com
:team: MN_RAN_L2_SW_2_KRK_CntDlv_SG
"""

import zipfile
import tarfile
import errno
import re
import os
from io import BytesIO

from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.utilities \
    import logger_info, logger_console_info


def establish_file_extension(filename):
    is_zip = re.search(r'.*\.zip$', filename)
    is_tar = re.search(r'.*\.tar$', filename)
    is_tgz_or_tar_gz = re.search(r'.*\.tar\.gz$', filename) or re.search(r'.*\.tgz$', filename)
    return is_zip, is_tar, is_tgz_or_tar_gz


def get_path_with_dropped_extensions(path):
    extension_regex = r'(.*)((\.tar\.gz)|(\.tar)|(\.zip)|(\.xz)|(\.tgz)|(\.gz)|(\.\w{0,3}))$'
    elements = path.split("/")
    directories = []
    for elem in elements:
        if elem == ".":
            continue
        match = re.search(extension_regex, elem)
        if match:
            directories.append(match.group(1))
        else:
            directories.append(elem)
    return os.path.join(*directories)


def create_directories_from_path(path):
    if not os.path.exists(os.path.dirname(path)):
        try:
            os.makedirs(os.path.dirname(path))
        except OSError as exc:
            if exc.errno != errno.EEXIST:
                raise


def check_if_file_is_present_in_snapshot(pattern, file_name, output_dir, file_obj=None, path=None):
    if file_obj is None:
        file_obj = file_name
    file_list = []
    is_zip, is_tar, is_tgz_or_tar_gz = establish_file_extension(file_name)
    try:
        if is_zip:
            with zipfile.ZipFile(file_obj, "r") as file_instance:
                for name in file_instance.namelist():
                    logger_info(f"ZIP: {file_name} --- {name}")
                    try:
                        is_zip, is_tar, is_tgz_or_tar_gz = establish_file_extension(name)
                        if is_zip or is_tar or is_tgz_or_tar_gz:
                            inner_compressed_file = BytesIO(file_instance.read(name))
                            matched_files = check_if_file_is_present_in_snapshot(pattern=pattern,
                                                                                 file_name=name,
                                                                                 output_dir=output_dir,
                                                                                 file_obj=inner_compressed_file,
                                                                                 path=file_name)
                            file_list.extend(matched_files)
                    except zipfile.BadZipfile:
                        logger_console_info(f"BadZipFile: {inner_compressed_file} BadZipOuterFile: {name}")
                    if re.search(pattern, name):
                        logger_console_info("Found file: {}".format(os.path.join(path, name)))
                        out_file_path = os.path.join(output_dir, get_path_with_dropped_extensions(path), name)
                        create_directories_from_path(out_file_path)
                        with open(out_file_path, 'wb') as f:
                            f.write(file_instance.read(name))
                        file_list.append(out_file_path)
        elif is_tar or is_tgz_or_tar_gz:
            mode = "r:" if is_tar else "r:gz"
            with tarfile.open(fileobj=file_obj, mode=mode) as file_instance:
                for name in file_instance.getnames():
                    logger_info(f"TAR: {file_name} --- {name}")
                    try:
                        is_zip, is_tar, is_tgz_or_tar_gz = establish_file_extension(name)
                        if is_zip or is_tar or is_tgz_or_tar_gz:
                            inner_compressed_file = BytesIO(file_instance.extractfile(name).read())
                            matched_files = check_if_file_is_present_in_snapshot(pattern=pattern,
                                                                                 file_name=name,
                                                                                 output_dir=output_dir,
                                                                                 file_obj=inner_compressed_file,
                                                                                 path=file_name)
                            file_list.extend(matched_files)
                    except zipfile.BadZipfile:
                        logger_console_info(f"BadZipFile: {inner_compressed_file} BadZipOuterFile: {name}")
                    if re.search(pattern, name):
                        logger_console_info("Found file: {}".format(os.path.join(path, name)))
                        out_file_path = os.path.join(output_dir, get_path_with_dropped_extensions(path), name)
                        create_directories_from_path(out_file_path)
                        with open(out_file_path, 'wb') as f:
                            f.write(file_instance.extractfile(name).read())
                        file_list.append(out_file_path)
    except tarfile.ReadError:
        logger_info(f"{file_name} is empty!")
    return file_list
