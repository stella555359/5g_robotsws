# -*- coding: utf-8 -*-
"""
:description: Keywords for Zip handling from hran_extract library
:copyright: Nokia Networks
:author: Alexandru Stamp
:contact: alexandru.stamp@nokia.com
:maintainer: I_BTSAUTO_DEV_TSR@internal.nsn.com
:contact: I_BTSAUTO_DEV_TSR@internal.nsn.com
"""

import zipfile


def zip_file_list(archive):
    """
    Return a list of file names that the archive contain.
    :param archive: zip archive path
    :return: list of zip contents.
    """

    f = zipfile.ZipFile(archive)
    try:
        namelist = f.namelist()
    finally:
        f.close()
    return namelist


def zip_open_file(archive, filename):
    """
    Return the content of a file that the archive contains.
    :param archive: zip archive path
    :param filename: file that is contained in the archive
    :return: content of the specified file fron the archive.
    """

    f = zipfile.ZipFile(archive)
    try:
        content = f.read(filename)
    finally:
        f.close()
    return content
