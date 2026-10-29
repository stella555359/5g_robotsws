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


class GitSmuggler(BaseSmuggler):
    """ Class for handling git copying """

    def __init__(self, smuggler_name, token):
        """
        :param str smuggler_name: name of smuggler
        :param str token: git user private_token to be used in wget command
        """
        super(GitSmuggler, self).__init__(smuggler_name)
        self._token = token

    def copy_file(self, source, destination):
        """ Copies file from git source to local destination. Copied file is not under version control.

        :param str source: git source path
        :param str destination: local destination path
        :return: output of command
        :rtype: str
        """
        logger.debug('Copying file from {} to {}'.format(source, destination))
        filename = source.split('/')[-1]
        command = 'wget -O {dst}/{filename} {repo_path}?private_token={token}'.\
            format(dst=destination, filename=filename, repo_path=source, token=self._token)
        console_handler = Console('local')
        return console_handler.execute_command(command).strip()
