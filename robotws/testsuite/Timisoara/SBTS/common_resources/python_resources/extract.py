import zipfile
import os
from robot.api import logger


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


def unzip(path_to_archive, path_to_unpacked=None):
    """
       Extract ZIP archive. It returns path to extracted archive directory.
       | **Return value:**
       | Path to extracted archive.

       **Example:**

       .. code-block:: robotframework

          ${path_to_unpacked}=  Unzip  /home/user/some_file.zip  /home/user/here_is_new_dir_to_extract

       """
    if not path_to_unpacked:
        path_to_unpacked = os.path.splitext(path_to_archive)[0] + "_unzipped"
    if _pre_check(path_to_archive, path_to_unpacked):
        with zipfile.ZipFile(path_to_archive, "r") as zip:
            zip.extractall(path_to_unpacked)
    return path_to_unpacked


def _pre_check(path_to_archive, path_to_unpacked=None):
    if not os.path.exists(path_to_archive):
        raise ArchiveNotExist(path_to_archive)
    if not os.path.isfile(path_to_archive):
        raise ArchiveOpenError(path_to_archive)
    if os.path.exists(path_to_unpacked):
        logger.trace("Directory " + str(path_to_unpacked) + " already exists.")
        if os.listdir(path_to_unpacked):
            logger.trace("Target dir is not empty. Files on the same names can be overwrite.")
    else:
        os.makedirs(path_to_unpacked)
    if not os.access(path_to_unpacked, os.R_OK):
        raise AccessPathError(path_to_unpacked)
    return True


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
