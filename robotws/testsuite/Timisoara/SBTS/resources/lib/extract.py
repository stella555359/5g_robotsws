# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: larry.ling@nokia-sbell.com
:maintainer: larry.ling@nokia-sbell.com
:contact:
"""

import os
import logging
import zipfile
import gzip


class extract(object):
    """
    A library that provides keywords that extract files from different types of archives.
    It supports .zip, .tar, tgz, gzip and .xz archives.

    .. note::

       If target path is not provided archive will be extracted
       in-place with the suffix added (hardcoded in this script).

    """

    EXTR_ARCH_SUFFIX = "__"

    def unzip(self, path_to_archive, path_to_unpacked=None):
        """
        Extract ZIP archive. It returns path to extracted archive directory.

        | **Author:** michal.kwasniewicz@nokia.com
        | **Maintainer:** piotr.stuglik@nokia.com
        | **Released with version:** ---

        **Input Parameters:**

        +--------------------+------+----------------------------------+
        | Parameter name     | Man. | Description                      |
        +====================+======+==================================+
        | path_to_archive    | Yes  | Path to ZIP archive              |
        +--------------------+------+----------------------------------+
        | path_to_unpacked   | No   | Path to save ZIP archive content |
        +--------------------+------+----------------------------------+

        | **Return value:**
        | Path to extracted archive.

        **Example:**

        .. code-block:: robotframework

           ${path_to_unpacked}=  Unzip  /home/user/some_file.zip  /home/user/here_is_new_dir_to_extract

        """

        if not path_to_unpacked:
            path_to_unpacked = os.path.splitext(path_to_archive)[0] + self.EXTR_ARCH_SUFFIX

        if self._pre_check(path_to_archive, path_to_unpacked):
            with zipfile.ZipFile(path_to_archive, "r") as zip:
                zip.extractall(path_to_unpacked)

        return path_to_unpacked

    @staticmethod
    def _pre_check(path_to_archive, path_to_unpacked=None):

        if not os.path.exists(path_to_archive):
            raise ArchiveNotExist(path_to_archive)

        if not os.path.isfile(path_to_archive):
            raise ArchiveOpenError(path_to_archive)

        if os.path.exists(path_to_unpacked):
            logging.info("Directory " + str(path_to_unpacked) + " already exists.")
            if os.listdir(path_to_unpacked) != []:
                logging.info("Target dir is not empty. Files on the same names can be overwrite.")
        else:
            os.makedirs(path_to_unpacked)

        if not os.access(path_to_unpacked, os.R_OK):
            raise AccessPathError(path_to_unpacked)

        return True


class ArchiveNotExist(Exception):

    def __init__(self, path_to_archive):
        self.path_to_archive = path_to_archive

    def __str__(self):
        return 'Archive ' + str(self.path_to_archive) + ' does not exist!'


class ArchiveOpenError(Exception):

    def __init__(self, path_to_archive):
        self.path_to_archive = path_to_archive

    def __str__(self):
        return 'Archive ' + str(self.path_to_archive) + ' could not be opened.'


class AccessPathError(Exception):

    def __init__(self, path_to_unpacked):
        self.path_to_unpacked = path_to_unpacked

    def __str__(self):
        return 'Directory: ' + str(self.path_to_unpacked) + ' access not permitted!'


class UnsupportedArchiveFormat(Exception):

    def __init__(self, path_to_archive):
        self.path_to_archive = path_to_archive

    def __str__(self):
        return 'Unsupported archive format ' + str(self.path_to_archive)
