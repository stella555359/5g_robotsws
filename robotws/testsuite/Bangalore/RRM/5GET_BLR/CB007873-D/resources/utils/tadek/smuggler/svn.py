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


class SvnSmuggler(BaseSmuggler):
    """ Class for handling svn copying """

    def __init__(self, smuggler_name, authenticator):
        """
        :param str smuggler_name: name of smuggler.
        :param authenticator: dictionary with parameters used to connect to svn repository.
            Keys are: \
            'user' - user on remote host, \
            'password' - password used to establish connection. \
        """
        super(SvnSmuggler, self).__init__(smuggler_name)
        self._authenticator = authenticator

    def copy_file(self, source, destination):
        """ Copies file from svn source to local destination. Copied file is not under version control.

        :param str source: svn source path
        :param str destination: local destination directory path
        :return: output of command
        :rtype: str
        """
        logger.debug('Copying file from {} to {}'.format(source, destination))
        dst = destination + '/' + source.split('/')[-1]
        command = 'svn export --username "{user}" --password "{password}" "{src}" "{dst}"'\
            .format(src=source, dst=dst, user=self._authenticator['user'], password=self._authenticator['password'])
        console_handler = Console('local')
        return console_handler.execute_command(command)
