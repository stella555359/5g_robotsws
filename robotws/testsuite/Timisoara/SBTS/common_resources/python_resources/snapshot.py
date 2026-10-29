"""
:description: Keywords for Snapshot handling from hran_snapshot_analysis library
:copyright: Nokia Networks
:author: Anca Tatar
:contact: anca.tatar@nokia.com
:maintainer: I_BTSAUTO_DEV_TSR@internal.nsn.com
:contact: I_BTSAUTO_DEV_TSR@internal.nsn.com
"""

import zipfile
import tarfile
import json
import re

from os import path
from robot.api import logger
from six import BytesIO


def get_files_list_from_tar(tar_path):
    """
    Get files list archived in tar (no check nesting archives)
    :param tar_path: path to archive
    :return: list of files name
    """
    _files_list = []
    archive_tar = tarfile.open(name=tar_path)
    for member in archive_tar.getmembers():
        if member.name == '.':
            continue
        _files_list.append(path.join(tar_path, member.name.lstrip('./')))
    return _files_list


def get_data_from_snapshot(path_to_snapshot):
    """
    Check the content of snapshot.zip file and return a dictionary.
    The key is the file name, the value is a list with full path and file size.

    **Input Parameters:**
    +--------------------+------+------------------------------+
    | Parameter name     | Man. | Description                  |
    +====================+======+==============================+
    | path_to_snapshot   | Yes  | Path to snapshot.zip archive |
    +--------------------+------+------------------------------+

    | **Return value:**
    | A dictionary, where the key is the file name, and the value is a list containing file path and size.
    """
    if path.exists(path_to_snapshot):
        logger.info('Path to zip file: {}'.format(path_to_snapshot))
    else:
        raise NotExistPath(path_to_snapshot)
    ContentSnap = ContentSnapshot()
    file_dict = ContentSnap.content_zip(path_to_snapshot)
    if ContentSnap.broken_archives:
        logger.debug("There are {} broken archives in the snapshot.".format(len(ContentSnap.broken_archives)))
    return file_dict


def validate_snapshot_using_custom_data(file_from_zip, required_file_dict):
    """
    Check whether files defined in required_file_dict are in snapshot.zip file,
    Keyword get_data_from_snapshot should be used first.

    | **Full description:**
    | Structure required_file_dict specification file:
    |
    | {
    |     "mandatory_file": [
    |         ".*log1.txt",
    |         ".*file2.log"
    |     ],
    |      "not_mandatory_file": [
    |         ".*not_mandatory_file3.log",
    |         ".*file.txt"
    |     ]
    | }
    |
    | Keyword fails in case at least one mandatory file wasn't found.
    | Keyword fails when at least size of one file is equal zero.
    | Table with the result is always attached to the report.

    **Input Parameters:**

    +----------------------------+------+----------------------------------------------------------+
    | Parameter name             | Man. | Description                                              |
    +============================+======+==========================================================+
    | found_file_dict            | Yes  | Dictionary returned by keyword get_data_from_snapshot    |
    +----------------------------+------+----------------------------------------------------------+
    | path_to_json_spec_file     | Yes  | json file with specification                             |
    +----------------------------+------+----------------------------------------------------------+

    | **Return value:**
    | List containing Pattern, File location and Size of the file from zip
    """
    CheckSnap = CheckSnapshot(required_file_dict, input_dict=True)
    CheckSnap.validate_snapshot(file_from_zip)
    CheckSnap.final_verdict()
    return CheckSnap.create_table()


class NotExistPath(Exception):

    def __init__(self, path):
        super(NotExistPath, self).__init__('Path: {} doesn\'t exist.'.format(path))


class NotFoundMandatoryFile(Exception):

    def __init__(self):
        super(NotFoundMandatoryFile, self).__init__('Didn\'t find all mandatory files.')


class FileSizeEqualZero(Exception):

    def __init__(self):
        super(FileSizeEqualZero, self).__init__('File size equal 0 found.')


class ContentSnapshot(object):

    def __init__(self):
        self.file_dict = dict()
        self.broken_archives = list()

    def content_zip(self, path_to_zip, nested_path=''):
        '''
        Checking content of zip file, including all nested archives (tar and zip).
        :param path_to_zip: path to zip file
        :param nested_path: not mandatory
        :return: dictionary with all file in archive
        Dictionary key= file_name, val= [path, size file]
        '''
        archive_zip = zipfile.ZipFile(path_to_zip, 'r')
        for member in archive_zip.infolist():
            full_path = path.join(nested_path, member.filename)
            try:
                if member.filename.split('.')[-1] in ['zip']:
                    nested_zip = BytesIO(archive_zip.read(member))
                    self.content_zip(nested_zip, nested_path=full_path)
                elif member.filename.split('.')[-1] in ['tar']:
                    nested_tar = BytesIO(archive_zip.read(member))
                    self._content_tar(nested_tar, nested_path=full_path)
            except (zipfile.zlib.error, zipfile.BadZipfile, tarfile.ReadError):
                logger.debug(
                    'Can\'t open archive: {}, didn\'t check content. (Won\'t be returned)'.format(member.filename))
                self.broken_archives.append(member.filename)
            else:
                self.file_dict[path.split(member.filename)[-1]] = [full_path, member.file_size]

        return self.file_dict

    def _content_tar(self, path_to_tar, nested_path=''):
        archive_tar = tarfile.open(fileobj=path_to_tar)
        for member in archive_tar.getmembers():
            full_path = path.join(nested_path, member.name)
            try:
                if member.name.split('.')[-1] in ['zip']:
                    nested_zip = BytesIO(self._read(archive_tar.extractfile(member)))
                    self.content_zip(nested_zip, nested_path=full_path)
                elif member.name.split('.')[-1] in ['tar']:
                    nested_tar = BytesIO(self._read(archive_tar.extractfile(member)))
                    self._content_tar(nested_tar, nested_path=full_path)
            except (zipfile.zlib.error, zipfile.BadZipfile, tarfile.ReadError):
                logger.debug(
                    'Can\'t open archive: {}, didn\'t check content. (Won\'t be returned)'.format(member.name))
                self.broken_archives.append(member.name)
            else:
                self.file_dict[path.split(member.name)[-1]] = [full_path, member.size]

    def _read(self, readable_raw_IO_obj):
        return readable_raw_IO_obj.read()


class CheckSnapshot(object):

    def __init__(self, path_to_json_or_trbl_dict_or_dict, trbl=False, input_dict=False):
        self.trbl = trbl
        self.input_dict = input_dict
        if not self.trbl and not self.input_dict:
            self.data_dict = json.load(open(path_to_json_or_trbl_dict_or_dict, 'r'))
        elif self.input_dict and not self.trbl:
            self.data_dict = path_to_json_or_trbl_dict_or_dict
        elif self.trbl and not self.input_dict:
            self.data_dict = path_to_json_or_trbl_dict_or_dict
        self.result_dict = dict()
        self.not_found = list()
        self.empty_file = list()
        self.fail_test_not_found_file = False
        self.fail_test_zero_size_file = False

    def validate_snapshot(self, file_from_zip):
        '''
        Vaildate snapshot according to data obtained from trbl or csv file.
        :param file_from_zip: dictionary obtained from method content_zip()
        in class ContentSnapshot.
        '''
        for name_from_zip, path_size in file_from_zip.items():
            for key_j, val_j in self.data_dict.items():
                self._check_snapshot_content(key_j, name_from_zip, path_size, val_j)
        self.not_found = self._not_matched_file()
        self._log_not_found_file()
        self._log_zero_size_file()

    def create_table(self):
        '''
        Create table with three columns:
            Pattern: pattern used to search file.
            File: localization: Path to file in archive.
            Size: size file.
        :return: table.
        '''
        table = list()
        for key, value in self.result_dict.items():
            table.append([key, value[0][0], value[0][1]])
            [table.append(['', item[0], item[1]]) for item in value[1:]]
        if self.not_found:
            [table.append([item, ' - ', ' - ']) for item in self.not_found]
        return table

    def final_verdict(self):
        '''
        Final verdict, if didn't find at least one mandatory file raise
        NotFoundMandatoryFile error or if at least size of one file is equal
        zero raise FileSizeEqualZero.
        '''
        if self.fail_test_not_found_file:
            raise NotFoundMandatoryFile
        elif self.fail_test_zero_size_file:
            raise FileSizeEqualZero

    def _check_snapshot_content(self, key_j, name_from_zip, path_size, val_j):
        if not self.trbl:
            for name_file in val_j:
                if re.match(name_file, name_from_zip):
                    self._check_file(name_file, path_size)
        elif self.trbl:
            if re.match(key_j, name_from_zip):
                self._check_file(key_j, path_size, trbl_dict=val_j)

    def _check_file(self, name_file, path_size):
        if name_file not in self.result_dict:
            self.result_dict.setdefault(name_file, list()).append([path_size[0], path_size[1]])
            self._is_size_equal_zero(name_file, path_size)
        else:
            self.result_dict[name_file].append([path_size[0], path_size[1]])
            self._is_size_equal_zero(name_file, path_size)

    def _is_size_equal_zero(self, name_file, path_size):
        if int(path_size[1]) == 0:
            self.empty_file.append([name_file, path_size[0], path_size[1]])

    def _log_zero_size_file(self):
        if self.empty_file:
            for EmptyFile in self.empty_file:
                logger.error('{} {}'.format(path.split(EmptyFile[1])[-1], 'size file is equal 0!'))
                self.fail_test_zero_size_file = True

    def _log_not_found_file(self):
        if self.not_found:
            for NotFoundFile in self.not_found:
                if not self.trbl and NotFoundFile in self.data_dict['mandatory_file']:
                    logger.error('{} {}'.format(NotFoundFile, 'not found!'))
                    self.fail_test_not_found_file = True
                elif not self.trbl:
                    logger.debug('{} {}'.format(NotFoundFile, 'not found! (Not mandatory file)'))
                elif self.trbl and NotFoundFile in self.data_dict:
                    if self.data_dict[NotFoundFile]['mandatory_flag'] == '1':
                        logger.error('{} {}'.format(NotFoundFile, 'not found!'))
                        self.fail_test_not_found_file = True
                    else:
                        logger.debug('{} {}'.format(NotFoundFile, 'not found! (Not mandatory file)'))

    def _not_matched_file(self):
        not_matched_file = list()
        if not self.trbl:
            if len(self.result_dict) != (len(self.data_dict['mandatory_file']) +
                                         len(self.data_dict['not_mandatory_file'])):
                for key, value in self.data_dict.items():
                    for item in value:
                        self._append_if_not_in_result_dict(item, not_matched_file)
                return not_matched_file
        elif self.trbl:
            if len(self.result_dict) != len(self.data_dict):
                for key, value in self.data_dict.items():
                    self._append_if_not_in_result_dict(key, not_matched_file)
                return not_matched_file
        return False

    def _append_if_not_in_result_dict(self, file_name, not_matched_file):
        if file_name not in self.result_dict:
            not_matched_file.append(file_name)
