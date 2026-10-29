# -*- coding: utf-8 -*-
"""
:author: Bartosz Bugaj
:contact: bartosz.bugaj@nokia.com
:maintainer: I_TADEK_DEVS
:contact: I_TADEK_DEVS@internal.nsn.com
"""

from robot.api import logger

from ..console import Console
from .base import BaseSmuggler


class LocalSmuggler(BaseSmuggler):
    """ Class for handling local copying """

    def __init__(self, smuggler_name):
        """
        :param str smuggler_name: name of smuggler
        """
        super(LocalSmuggler, self).__init__(smuggler_name)

    def copy_file(self, source, destination):
        """ Copies file from local source to local destination with owner and group intact

        :param str source: local source path
        :param str destination: local destination path
        :return: list of performed copies
        :rtype: str
        """
        logger.debug('Copying file from {} to {}'.format(source, destination))
        command = 'sudo cp -vr "{src}" "{dst}"'.format(src=source, dst=destination)
        console_handler = Console('local')
        copied_files = console_handler.execute_command(command)

        self._change_owner_and_group(copied_files)
        return copied_files

    def _get_owner_and_group(self, path):
        """ Gets owner and group of the given file

        :param str path: path to file
        :return: owner and group of the file
        :rtype: tuple
        """
        command = 'stat -c "%U %G" "{path}"'.format(path=path)
        console_handler = Console('local')
        owner, group = console_handler.execute_command(command).split()
        return owner, group

    def _change_owner_and_group(self, copied_files):
        """ Changes owner and group of copied files

        :param str copied_files: list of performed copies
        """
        for copy in copied_files.splitlines():
            src, sep, dst = copy.partition('->')
            src, dst = src.strip("' "), dst.strip("' ")
            owner, group = self._get_owner_and_group(src)
            command = 'sudo chown {owner}:{group} "{dst}"'.format(owner=owner, group=group, dst=dst)
            console_handler = Console('local')
            console_handler.execute_command(command)
