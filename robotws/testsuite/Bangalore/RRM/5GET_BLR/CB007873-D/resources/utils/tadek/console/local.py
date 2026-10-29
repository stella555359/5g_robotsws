# -*- coding: utf-8 -*-
"""
:author: Jaroslaw Zima
:contact: jaroslaw.zima@nokia.com
:maintainer: I_TADEK_DEVS
:contact: I_TADEK_DEVS@internal.nsn.com
"""
import subprocess

from robot.api import logger

from .base import BaseConsole


class LocalConsole(BaseConsole):
    """ Class for handling local console """

    def execute_command(self, command):
        """ Executes given command in local console
        :param str command: command that will be executed
        :return: output of command
        :rtype: str
        """
        pipes = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        output, stderr = pipes.communicate()
        if pipes.returncode != 0:
            exception = subprocess.CalledProcessError(pipes.returncode, command, output=output)
            error_msg = 'ERROR occurred\nstderr: {}:\nRC: {}'.format(stderr.strip(), pipes.returncode)
            logger.error(error_msg)
            raise exception
        return output.decode('utf-8')
