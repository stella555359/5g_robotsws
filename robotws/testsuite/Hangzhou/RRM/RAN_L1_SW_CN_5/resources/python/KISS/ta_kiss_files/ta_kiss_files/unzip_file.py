# -*- coding: utf-8 -*-
"""
:created on: 03-30-2021

:copyright: Nokia
:author: Chen jin Emily
:contact: jin_emily.chen@nokia-sbell.com.cn
"""

import logging
import os
import gzip
import platform
from ArchiveLibrary.keywords import ArchiveKeywords
from .exception import KissFileException

TARS = ('.tar', '.tar.bz2', '.tar.gz', '.tgz', '.tz2', '.xz')
ZIPS = ('.docx', '.egg', '.jar', '.odg', '.odp', '.ods', '.xlsx', '.odt',
        '.pptx', '.zip')


class ArchiveFile(object):
    """unzip '.gz', '.tar', '.tar.bz2', '.tar.gz', '.tgz', '.tz2','.docx', '.egg', '.jar', '.odg',
             '.odp', '.ods', '.xlsx', '.odt', '.pptx', '.zip' file
    """
    def __init__(self):
        self._log = logging.getLogger(__name__)
        self._log.setLevel(logging.DEBUG)
        self._archive_inst = ArchiveKeywords()

    def un_gz(self, src_file, to_path=''):
        """unzip .gz file
        """
        g_file = gzip.GzipFile(src_file)
        if to_path is not '':
            path_name = to_path
        else:
            path_name = src_file.replace(".gz", "")
        path_dir = os.path.dirname(path_name)
        if not os.path.isdir(path_dir):
            os.makedirs(path_dir)
        open(path_name, "wb+").write(g_file.read())
        g_file.close()

    def unzip_single_file(self, src_file, path):
        """uncompress a single zip or tar.gz file
        """
        self._log.debug("file is:%s.", src_file)
        self._log.debug("path is:%s.", path)
        if src_file.endswith(".gz") and src_file.endswith(".tar.gz") is False:
            self.un_gz(src_file, path)
        elif src_file.endswith(".xz") and platform.system() != "Windows":
            os.system("unxz -k -f %s" % src_file)
        elif src_file.endswith(ZIPS + TARS):
            self._log.info((os.popen("7z x %s -y -o'%s'" % (src_file, path)).read()))
        else:
            self._log.debug("%s is not a compressed file", src_file)

    def deep_unzip_file(self, src_file, dest_path):
        """deep unzip a file
        """
        self.unzip_single_file(src_file, dest_path)
        for root, dirs, files in os.walk(dest_path):
            self._log.debug("root is:%s.", root)
            self._log.debug("dirs is:%s.", dirs)
            for sigle_file in files:
                self._log.debug("file is:%s.", sigle_file)
                if sigle_file.endswith(".gz") and sigle_file.endswith(".tar.gz") is False:
                    new_src_file = root + r'/' + sigle_file
                    self.un_gz(new_src_file)

                for file_type in ZIPS+TARS:
                    if sigle_file.endswith(file_type):
                        new_src_file = root + r'/' + sigle_file
                        new_dest_path = root + r'/' + sigle_file[0:sigle_file.rfind(file_type)]
                        self.deep_unzip_file(new_src_file, new_dest_path)


if __name__ == '__main__':
    pass
