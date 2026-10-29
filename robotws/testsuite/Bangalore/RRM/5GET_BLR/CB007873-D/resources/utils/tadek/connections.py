# -*- coding: utf-8 -*-
"""
:author: Jaroslaw Zima
:contact: jaroslaw.zima@nokia.com
:maintainer: I_TADEK_DEVS
:contact: I_TADEK_DEVS@internal.nsn.com
"""
import datetime
import re
import subprocess
import telnetlib
import time

from contextlib import contextmanager
from robot.api import logger

from .errors import TimeoutError


class Telnet(object):
    """
    Telnet class
    """

    def __init__(self, host, port=23, prompt='#', timeout=10):
        """
        :param str host: address of host
        :param int port: port on which telnet connection will be made
        :param str prompt: console's prompt
        """
        self._client = None
        self._host = host
        self._port = port
        self._prompt = prompt
        self._timeout = timeout

    def start_connection(self):
        """ Starts connection to remote host """
        connected = False
        start = time.time()
        telnet = None
        while not connected:
            elapsed = time.time() - start
            try:
                telnet = telnetlib.Telnet(self._host, self._port)
                connected = True
            except Exception as e:
                if elapsed > self._timeout:
                    raise e
                time.sleep(0.1)
        self._client = telnet
        self._client.set_debuglevel(1)

    def execute_command(self, command, timeout=600):
        """ Executes command and waits till prompt. Returns output of command
        :param str command: command that will be executed
        :param int timeout: time to wait for command output
        :return: output of command
        :rtype: str
        """
        cmd = '{}\n'.format(command)
        self._client.write(cmd)
        return self._read_output_till_prompt(timeout)

    def execute_command_and_read_until_pattern(self, command, pattern, timeout=600):
        """ Executes command and waits till given pattern will appear
        :param command:
        :param str|re.Pattern pattern:
        :param timeout:
        :return: output of command till pattern
        :rtype: str
        """
        cmd = '{}\n'.format(command)
        self._client.write(cmd)
        try:
            index, match, text = self._client.expect([pattern], timeout)
            if index == -1:
                raise TimeoutError(timeout)
        except EOFError:
            raise TimeoutError(timeout)
        return text.lstrip(self._prompt)

    def stop_connection(self):
        """ Stops connection to remote host """
        self._client.close()

    @contextmanager
    def session(self):
        """ Wrap used for `with ... :` syntax.
        Starts connection do remote host, does something and then stops connection.
        """
        exc = None
        try:
            self.start_connection()
            yield self
        except Exception as e:
            exc = e  # pylint: disable-msg=E0702
        finally:
            if exc is not None:
                raise exc  # pylint: disable-msg=E0702
            self.stop_connection()

    def _read_output_till_prompt(self, timeout):
        """ Reads buffer till prompt appears in new line. If timeout is reached then exception is raised.
        :param int timeout: time to wait in seconds
        :return: content of buffer
        :rtype: str
        """
        output = ''
        start_time = datetime.datetime.now()
        while output.find('\n' + self._prompt) == -1:
            output += self._client.read_eager()
            self._check_timeout(start_time, timeout)
        return self._cut_out_prompts(output)

    def _check_timeout(self, start_time, timeout):
        """ Checks if timeout occurred. If yes, exception is raised
        :param datetime.datetime start_time:
        :param int timeout: time to wait in seconds
        """
        current_time = datetime.datetime.now()
        time_delta = current_time - start_time
        if time_delta.seconds >= timeout:
            raise TimeoutError(timeout)

    def _cut_out_prompts(self, cmd_output):
        """ Picks content from raw output of command (without prompts)
        :param str cmd_output: output of executed command
        :return: cleaned output
        :rtype: str
        """
        content_pattern = r'(?s)(?<={prompt})(.*)(?=\s{prompt})'.format(prompt=self._prompt)
        output = re.search(content_pattern, cmd_output).group(1)
        return output


class Ssh(object):
    """
    SSH class
    """

    def __init__(self, host, port=22, jump_host=None, authenticator=None):
        """
        :param str host: address of target host
        :param int port: port on target host
        :param dict jump_host: dictionary with information regarding jump host, \
            keys are: \
            'host' - address to jump host, \
            'port' - port on jump host, \
            'authenticator' - authenticator used for jump host - for authentication format please see below
        :param dict authenticator: dictionary with parameters used to connect to target host. \
            Keys are: \
            'key' - path to rsa key, \
            'user' - user on remote host, \
            'password' - password used to establish connection. \
            If key and password are set, then key is used as authentication method.
        """
        self._host = host
        self._port = port
        self._jump_host = jump_host
        self._authenticator = authenticator

    def execute_command(self, command, log_level='QUIET', log_file=None):
        """ Executes shell command on target host

        :param str command: command that is executed on target host
        :param str log_level: value for ssh option -oLogLevel, \
            valid values: QUIET, FATAL, ERROR, INFO, VERBOSE, DEBUG, DEBUG1, DEBUG2, DEBUG3
        :param str|None log_file: if not None - path to log file that will be created
        :return: output of command
        :rtype: str
        """
        ssh_command = self._build_ssh_command(command, log_level=log_level, log_file=log_file)
        pipes = subprocess.Popen(ssh_command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        output, stderr = pipes.communicate()
        if stderr:
            logger.error(
                'ERROR occurred\n'
                'stderr: {}:\nRC: {}'.format(stderr.strip(), pipes.returncode)
            )
        if pipes.returncode != 0:
            exception = subprocess.CalledProcessError(pipes.returncode, ssh_command, output=output)
            raise exception
        return output.decode('utf-8')

    def execute_command_and_return_control(self, command, log_level='QUIET', log_file=None):
        """ Executes shell command on target host and return

        :param str command: command that is executed on target host
        :param str log_level: value for ssh option -oLogLevel, \
            valid values: QUIET, FATAL, ERROR, INFO, VERBOSE, DEBUG, DEBUG1, DEBUG2, DEBUG3
        :param str|None log_file: if not None - path to log file that will be created
        :return: output of command
        :rtype: str
        """
        ssh_command = self._build_ssh_command(command, log_level=log_level, log_file=log_file)
        try:
            subprocess.check_output(ssh_command, shell=True)
        except subprocess.CalledProcessError as e:
            error_msg = 'ERROR occurred\noutput: {}\nRC: {}'.format(e.output, e.returncode)
            logger.error(error_msg)
            raise e

    def _build_ssh_command(self,
                           command,
                           log_level='QUIET',
                           log_file=None,
                           strict_host_key_checking='no',
                           user_known_hosts_file='/dev/null'):
        """ Builds ssh connection with command that will be executed on target host

        :param str command: command that is executed on target host
        :param str log_level: (optional) value for ssh option -oLogLevel, \
            valid values: QUIET, FATAL, ERROR, INFO, VERBOSE, DEBUG, DEBUG1, DEBUG2, DEBUG3
        :param str log_file: (optional) if not None - path to log file that will be created
        :param str strict_host_key_checking: (optional)
        :param str user_known_hosts_file: (optional)
        :return:
        """
        command_options = {'port': self._port,
                           'strict_host_key_checking': strict_host_key_checking,
                           'user_known_hosts_file': user_known_hosts_file}
        if self._jump_host:
            command_options['jump_host'] = self._jump_host
        if log_file:
            command_options['log_file'] = log_file
        ssh_command = CommandBuilder().build_ssh_command(self._host,
                                                         command,
                                                         log_level=log_level,
                                                         authenticator=self._authenticator,
                                                         **command_options)
        return ssh_command


class CommandBuilder(object):
    """
    Command builder
    """

    BASE_SSH_COMMAND = '{password_prefix} ssh {options} {user}{host} {command}'
    OPEN_SSH_OPTIONS = {
        'port': '-p {}',
        'strict_host_key_checking': '-oStrictHostKeyChecking="{}"',
        'user_known_hosts_file': '-oUserKnownHostsFile="{}"',
        'log_file': '-E {}',
        'log_level': '-oLogLevel="{}"',
        'forward': '-W %h:%p',
        'identity_file': '-i {}',
        'proxy_command': '-oProxyCommand="{}"'
    }
    SSHPASS_PREFIX = 'sshpass -p {}'

    def __init__(self):
        self._log_level = None

    def build_ssh_command(self, host, command, log_level='QUIET', authenticator=None, jump_host=None, **kwargs):
        """ Builds atomic level ssh connection with command to be executed on target host

        :param str host: address of target host
        :param str command: command to be executed on target host
        :param str log_level: value for ssh option -oLogLevel, \
            valid values: QUIET, FATAL, ERROR, INFO, VERBOSE, DEBUG, DEBUG1, DEBUG2, DEBUG3
        :param dict|None jump_host: dictionary with information regarding jump host, \
            keys are: \
            'host' - address to jump host, \
            'port' - port on jump host, \
            'authenticator' - authenticator used for jump host - for authentication format please see below
        :param dict|None authenticator:dictionary with parameters used to connect to target host. \
            Keys are: \
            'key' - path to rsa key, \
            'user' - user on remote host, \
            'password' - password used to establish connection. \
            If key and password are set, then key is used as authentication method.
        :return: prepared command line ssh connection with options and command to be executed
        :rtype: str

        *Additional parameters**:
            :param int port: port on target host
            :param str log_file: path to log file
            :param str strict_host_key_checking: -oStrictHostKeyChecking (man ssh_config)
            :param str user_known_hosts_file: -oUserKnownHostsFile (man ssh_config)
        """
        self._log_level = log_level
        user_part, password_part, key_option = '', '', None
        options = self._prepare_options(kwargs)
        options.append(self.OPEN_SSH_OPTIONS.get('log_level').format(self._log_level))
        if jump_host:
            jump_host_option = self._jump_host_option(jump_host)
            options.append(jump_host_option)
        if authenticator:
            user_part = self._resolve_user_part(authenticator)
            password_part, key_option = self._resolve_authentication_option(authenticator)
        if key_option:
            options.append(key_option)
        options_part = ' '.join(options)
        command = self.BASE_SSH_COMMAND.format(command=command, password_prefix=password_part, options=options_part,
                                               user=user_part, host=host).strip()
        return command

    def _prepare_options(self, options_dictionary):
        """ Prepares strings that will be used in ssh command for each given option

        :param dict options_dictionary: dictionary with option key and its value.
        :return: list of resolved options
        :rtype: list
        """
        options = []
        for key, value in options_dictionary.items():
            option = self.OPEN_SSH_OPTIONS.get(key)
            if '{}' in option:
                option = option.format(value)
            options.append(option)
        return options

    def _jump_host_option(self, jump_host_dict):
        """ Option to set proxy command for ssh connection

        :param dict jump_host_dict: dictionary with information regarding jump host, \
            keys are: \
            'host' - address to jump host, \
            'port' - port on jump host, \
            'authenticator' - authenticator used for jump host - for authentication format please see below \
                'key' - path to rsa key, \
                'user' - user on jump host, \
                'password' - password used to establish connection. \
                If key and password are set, then key is used as authentication method.
        :return: prepared proxy command option (-oProxyCommand)
        :rtype: str
        """
        option = self.OPEN_SSH_OPTIONS.get('proxy_command')
        command_options = {'forward': None,
                           'port': jump_host_dict.get('port', 22)}
        proxy_command = self.build_ssh_command(jump_host_dict.get('host'), '', log_level=self._log_level,
                                               authenticator=jump_host_dict.get('authenticator'), **command_options)
        option = option.format(proxy_command)
        return option

    def _resolve_authentication_option(self, authenticator):
        """ Checks what kind of authentication options will be used for given connection

        :param dict authenticator: dictionary with authentication parameters
        :return: prepared key option and sshpass prefix, depending on authentication type. \
            As default, password part is empty string, and key option is None
        :rtype: tuple
        """
        password_part, key_option = '', None
        authentication_type = self._resolve_authentication_type(authenticator)
        if authentication_type == 'key_based':
            key_option = self.OPEN_SSH_OPTIONS.get('identity_file').format(authenticator.get('key'))
        elif authentication_type == 'password_based':
            password_part = self.SSHPASS_PREFIX.format(authenticator.get('password'))
        return password_part, key_option

    def _resolve_authentication_type(self, authenticator):
        """ Checks what kind of authentication type will be used for ssh connection

        :param dict authenticator: dictionary with authentication parameters
        :return: proper authentication type or None if authentication won't be used
        :rtype: str|None
        """
        authentication = None
        if authenticator:
            if 'key' in list(authenticator.keys()):
                authentication = 'key_based'
            elif 'password' in list(authenticator.keys()):
                authentication = 'password_based'
        return authentication

    def _resolve_user_part(self, authenticator):
        """ Checks if user was set in authenticator and creates proper user string for ssh connection

        :param dict authenticator: dictionary with authentication parameters
        :return: prepared user part for ssh connection
        :rtype: str
        """
        return authenticator.get('user') + '@' if 'user' in list(authenticator.keys()) else ''
