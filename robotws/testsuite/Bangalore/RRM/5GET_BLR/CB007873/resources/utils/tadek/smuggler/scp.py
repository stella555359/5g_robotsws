# -*- coding: utf-8 -*-
"""
:author: Bartosz Bugaj
:contact: bartosz.bugaj@nokia.com
:maintainer: I_TADEK_DEVS
:contact: I_TADEK_DEVS@internal.nsn.com
"""

import re

from robot.api import logger

from ..console import Console
from ..console.ssh import FspConsole, BbmodConsole
from .base import BaseSmuggler
from .config import ENB_IP, ENB_CREDENTIALS, IPHY_IP, IPHY_CREDENTIALS, JUMP_HOST_ENB


class ScpSmuggler(BaseSmuggler):
    """ Class for handling general scp copying """

    def __init__(self, smuggler_name, jump_host=None, **kwargs):
        """
        :param str smuggler_name: name of smuggler
        :param dict jump_host: dictionary with information regarding jump host, \
            keys are: \
            'host' - address to jump host, \
            'port' - port on jump host, \
            'authenticator' - authenticator used for jump host - for authentication format please see below
        :param kwargs: additional parameters if required (e.g. authenticator):
            :param dict|None authenticator: dictionary with parameters used to connect to target host. \
            Keys are: \
            'user' - user on remote host, \
            'password' - password used to establish connection. \
        """
        super(ScpSmuggler, self).__init__(smuggler_name)
        self._jump_host = jump_host
        self._authenticator = kwargs.get('authenticator')

    def copy_file(self, source, destination):
        """ Copies file from local source to local destination

        :param str source: remote or local path
        :param str destination: remote or local path
        :return:
        """
        logger.debug('Copying file from {} to {}'.format(source, destination))
        command = CommandBuilder(source=source,
                                 destination=destination,
                                 authenticator=self._authenticator,
                                 jump_host=self._jump_host,
                                 log_level='QUIET').build_scp_command()
        console_handler = Console('local')
        return console_handler.execute_command(command)


class FsmSmuggler(ScpSmuggler):
    """ Class for handling fsm copying """

    def __init__(self, smuggler_name):
        """
        :param str smuggler_name: name of smuggler
        """
        super(FsmSmuggler, self).__init__(smuggler_name)
        self._authenticator = ENB_CREDENTIALS


class IphySmuggler(ScpSmuggler):
    """ Class for handling iphy copying """

    def __init__(self, smuggler_name):
        """
        :param str smuggler_name: name of smuggler
        """
        super(IphySmuggler, self).__init__(smuggler_name)
        self._authenticator = IPHY_CREDENTIALS


class FspSmuggler(FsmSmuggler):
    """ Class for handling fsp copying """

    def __init__(self, smuggler_name):
        """
        :param str smuggler_name: name of smuggler
        """
        super(FspSmuggler, self).__init__(smuggler_name)
        self._jump_host = JUMP_HOST_ENB


class BbmodSmuggler(FsmSmuggler):
    """ Class for handling bbmod copying """

    def __init__(self, smuggler_name):
        """
        :param str smuggler_name: name of smuggler
        """
        super(BbmodSmuggler, self).__init__(smuggler_name)
        self._jump_host = JUMP_HOST_ENB


class CommandBuilder(object):
    """ Class for building scp command """

    BASE_SCP_COMMAND = '{password_prefix} scp {options} "{source}" "{destination}"'
    PROXY_COMMAND_OPTION = '-oProxyCommand="sshpass -p {password} ssh -W %h:%p -p 22 -oLogLevel="{log_level}" ' \
                           '{user}@{host}"'
    OPEN_SCP_OPTIONS = '-oStrictHostKeyChecking="no" -P 22 -oUserKnownHostsFile="/dev/null" -oLogLevel="{log_level}"'
    SSHPASS_PREFIX = 'sshpass -p {password}'

    def __init__(self, source, destination, authenticator, jump_host=None, log_level='QUIET'):
        self.source = source
        self.destination = destination
        self.authenticator = authenticator
        self._jump_host = jump_host
        self._log_level = log_level

    def build_scp_command(self):
        """ Build SCP command """
        source = self.resolve_user_and_host_for_location(self.source)
        destination = self.resolve_user_and_host_for_location(self.destination)
        if self._jump_host:
            proxy_command_option = self.build_proxy_command_option()
            open_scp_options = self.OPEN_SCP_OPTIONS.format(log_level=self._log_level)
            options = '{} {}'.format(open_scp_options, proxy_command_option)
        else:
            options = self.OPEN_SCP_OPTIONS.format(log_level=self._log_level)
        sshpass_prefix = self.SSHPASS_PREFIX.format(password=self.authenticator['password'])
        scp_command = self.BASE_SCP_COMMAND.format(password_prefix=sshpass_prefix,
                                                   options=options,
                                                   source=source,
                                                   destination=destination)
        return scp_command

    def build_proxy_command_option(self):
        """
        Creates -oProxyCommand ssh_option required for copying via jump_host.

        :param dict jump_host: dictionary with information regarding jump host, \
            keys are: \
            'host' - address to jump host, \
            'authenticator' - dictionary with parameters used to connect to jump host.
            authenticator keys: \
            'user' - user on remote host, \
            'password' - password used to establish connection. \
            If key and password are set, then key is used as authentication method.
        """
        proxy_command_option = self.PROXY_COMMAND_OPTION.format(
            password=self._jump_host['authenticator'].get('password'),
            log_level=self._log_level,
            user=self._jump_host['authenticator'].get('user'),
            host=self._jump_host['host']
        )
        return proxy_command_option

    def resolve_user_and_host_for_location(self, location):
        """ Resolves appropriate user and host for given location, e.g:
        iphy/rom/simmode/iphy.xml --> toor4nsn@192.168.200.1:/rom/simmode/iphy.xml
        """
        resolved_location = location
        if location.startswith('fsm'):
            user_host = '{}@{}:'.format(ENB_CREDENTIALS['user'], ENB_IP)
            resolved_location = location.replace('fsm', user_host, 1)
        elif location.startswith('iphy'):
            user_host = '{}@{}:'.format(IPHY_CREDENTIALS['user'], IPHY_IP)
            resolved_location = location.replace('iphy', user_host, 1)
        elif location.startswith('fsp'):
            resolved_name = re.findall('^([^/]+)/', location)[0]
            resolved_ip = FspConsole(resolved_name)._host
            user_host = '{}@{}:'.format(ENB_CREDENTIALS['user'], resolved_ip)
            resolved_location = location.replace(resolved_name, user_host, 1)
        elif location.startswith('bbmod'):
            resolved_name = re.findall('^([^/]+)/', location)[0]
            resolved_ip = BbmodConsole(resolved_name)._host
            user_host = '{}@{}:'.format(ENB_CREDENTIALS['user'], resolved_ip)
            resolved_location = location.replace(resolved_name, user_host, 1)
        return resolved_location
