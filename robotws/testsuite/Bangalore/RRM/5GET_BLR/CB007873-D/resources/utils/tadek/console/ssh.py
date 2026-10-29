# -*- coding: utf-8 -*-
"""
:author: Jaroslaw Zima
:contact: jaroslaw.zima@nokia.com
:maintainer: I_TADEK_DEVS
:contact: I_TADEK_DEVS@internal.nsn.com
"""
import re

from robot.api import logger
from ..connections import Ssh

from .base import BaseConsole
from .config import ENB_IP, ENB_CREDENTIALS, IPHY_CREDENTIALS, IPHY_IP


class SshConsole(BaseConsole):
    """ Class for handling general telnet console """

    def __init__(self, console_name, jump_host=None, **kwargs):
        super(SshConsole, self).__init__(console_name)
        self._host = kwargs.get('address')
        self._port = kwargs.get('port')
        self._jump_host = jump_host
        self._authenticator = kwargs.get('authenticator')

    def execute_command(self, command):
        """ Executes command in ssh console
        :param str command: command that will be executed
        :return: output of command
        :rtype: str
        """
        # remove enclosing quotes for backward compatibility
        if command.startswith('"') and command.endswith('"'):
            command = command[1:-1]

        cmd = command.replace('"', '\\"').replace("$", "\\$")
        conn = Ssh(
            host=self._host,
            port=self._port,
            jump_host=self._jump_host,
            authenticator=self._authenticator,
        )
        return conn.execute_command('"%s"' % cmd)


class BoardConsole(SshConsole):
    """ Helper class for handling FSP/BBMOD consoles """

    def __init__(self, console_name, jump_host=None, **kwargs):
        super(BoardConsole, self).__init__(console_name, jump_host=jump_host, **kwargs)

    def _resolve_console_address(self, console_name_pattern):
        """ Gets ip address for given console name pattern from hosts file on FCT

        :param str console_name_pattern: regex pattern for console name
        :return: ip address to FSP
        :rtype: str
        """
        hosts_file_content = Ssh(ENB_IP, 22, authenticator=ENB_CREDENTIALS).execute_command('cat /etc/hosts')
        try:
            fsp_entry_line = re.search('(?m)^.*?' + console_name_pattern + '.*$', hosts_file_content).group(0)
        except AttributeError:
            raise Exception('There is no entry in hosts file for {}!'.format(console_name_pattern))
        fsp_ip_address = re.search(r'\d{1,3}(?:\.\d{1,3}){3}', fsp_entry_line).group(0)
        return fsp_ip_address

    def _check_connection_to_fsp_from_fct(self, console_name, fsp_ip_address):
        """ Checks if there is connection to given FSP from FCT.

        :param str fsp_ip_address: ip address of FSP
        """
        try:
            Ssh(ENB_IP, 22, authenticator=ENB_CREDENTIALS).execute_command('nc -z {} 22'.format(fsp_ip_address))
        except Exception:
            raise Exception('There is no connection to console {}! '.format(console_name))


class FsmConsole(BoardConsole):
    """ Class for handling FSM (ssh) console """

    def __init__(self, console_name, **kwargs):
        super(FsmConsole, self).__init__(console_name,
                                         address=ENB_IP,
                                         port=22,
                                         authenticator=ENB_CREDENTIALS)


class IphyConsole(BoardConsole):
    """ Class for handling IPHY (ssh) console """

    def __init__(self, console_name, **kwargs):
        super(IphyConsole, self).__init__(console_name,
                                          address=IPHY_IP,
                                          port=22,
                                          authenticator=IPHY_CREDENTIALS)


class FspConsole(BoardConsole):
    """ Class for handling FSP consoles """

    def __init__(self, console_name, **kwargs):
        proper_console_name = self._resolve_console_name(console_name)
        console_address = self._resolve_console_address(proper_console_name)
        self._check_connection_to_fsp_from_fct(console_name, console_address)
        jump_host = {'host': ENB_IP, 'port': 22, 'authenticator': ENB_CREDENTIALS}
        super(FspConsole, self).__init__(console_name,
                                         address=console_address,
                                         jump_host=jump_host,
                                         port=22,
                                         authenticator=ENB_CREDENTIALS)

    def _resolve_console_name(self, console_name):
        """ Resolves given fsp/fspj console name to proper name pattern that can be found in hosts file
        :param str console_name: name of console
        :return: `name pattern for console
        :rtype: str
        """
        fsp_code = console_name.split('-')[1]
        pattern = r'fsp[j]?[\-]?' + fsp_code
        logger.debug('Resolved console name pattern: {}'.format(pattern))
        return pattern


class BbmodConsole(BoardConsole):
    """ Class for handling Bbmod consoles """

    def __init__(self, console_name, **kwargs):
        proper_console_name = self._resolve_console_name(console_name)
        console_address = self._resolve_console_address(proper_console_name)
        self._check_connection_to_fsp_from_fct(console_name, console_address)
        jump_host = {'host': ENB_IP, 'port': 22, 'authenticator': ENB_CREDENTIALS}
        super(BbmodConsole, self).__init__(console_name,
                                           address=console_address,
                                           jump_host=jump_host,
                                           port=22,
                                           authenticator=ENB_CREDENTIALS)

    def _resolve_console_name(self, console_name):
        """ Resolves given bbmod console name to proper name pattern that can be found in hosts file
        :param str console_name: name of console
        :return: translated console name
        :rtype: str
        """
        fsm_hostname = Ssh(ENB_IP, 22, authenticator=ENB_CREDENTIALS).execute_command('hostname').strip()
        if 'fct-' in fsm_hostname:
            return self._resolve_bbmod_fsp_for_airscale(fsm_hostname, console_name)
        else:
            return self._resolve_bbmod_fsp_for_fsmr3(console_name)

    def _resolve_bbmod_fsp_for_fsmr3(self, console_name):
        """ Resolves bbmod name to name pattern that can be read from hosts file for FSMr3
        :param str console_name: bbmod name
        :return: proper name pattern that can be used in hosts file
        :rtype: str
        """
        bbmod_number = int(console_name.split('-')[1])
        fsp_name_pattern = r'fsp[\-]?' + str(bbmod_number + 1)
        logger.debug('Resolved console name pattern: {}'.format(fsp_name_pattern))
        if bbmod_number in (1, 2):
            return fsp_name_pattern
        else:
            raise ValueError('For FSMr3 only valid options are bbmod-1 and bbmod-2!')

    def _resolve_bbmod_fsp_for_airscale(self, fsm_hostname, console_name):
        """ Resolves bbmod name to name pattern that can be read from hosts file for AirScale
        :param fsm_hostname: System module's hostname
        :param str console_name: bbmod name
        :return: proper name pattern that can be used in hosts file
        :rtype: str
        """
        bbmod_number = int(console_name.split('-')[1])
        fsp_name_pattern = r'fsp[j]?[\-]?' + str(bbmod_number if '0a' in fsm_hostname else 4 + bbmod_number) + 'a'
        logger.debug('Resolved console name pattern: {}'.format(fsp_name_pattern))
        return fsp_name_pattern
