# -*- coding:utf-8 -*-
"""
:copyright: Nokia Networks
:author: Shifu Lan
:contact: shifu.lan@nokia-sbell.com
:maintainer: Shifu Lan
:contact: shifu.lan@nokia-sbell.com
"""
import logging
import telnetlib
import time
from taf.transport.ssh import ssh


class licence_keeper(object):
    _GET_LICENCE_QXDM_5G = 'keep QXDM 5G'
    _GET_LICENCE_QXDM_4G = 'keep QXDM 4G'
    _GET_LICENCE_QCAT_5G = 'keep QCAT 5G'
    _GET_LICENCE_QCAT_4G = 'keep QCAT 4G'
    _RELEASE_LICENCE_QXDM_5G = 'drop QXDM 5G'
    _RELEASE_LICENCE_QXDM_4G = 'drop QXDM 4G'
    _RELEASE_LICENCE_QCAT_5G = 'drop QCAT 5G'
    _RELEASE_LICENCE_QCAT_4G = 'drop QCAT 4G'
    _UNTIL_FLAG = b'LK>'
    _ENTER_FLAG = b'\n'
    app_runners_cache = {}
    default_alias = 'default'

    def __init__(self):
        self._connection = telnetlib.Telnet()
        self.disconnect_flag = True

    def create_ssh_runner(self, host, username, password, alias=None):
        """Create runner instance that runs the Licence Keeper client via ssh.

        :param host: str, Hostname of the machine that Licence Keeper client should be ran on.
        :param username: str, Username that will be used to connect to the host via ssh.
        :param password: str, Password that will be used to connect to the host via ssh.
        :param alias: - (optional) str, Alias of the instance, which will identify
            it when using other runner related keywords. If no alias is given,
            a default alias is used. There can be only only one runner instance
            with a given alias, if the same alias is used twice, the first
            runner will be lost.

        Note, ssh is disable on windows machines. In order to use the runner,
        you must enable it first with cygwin tool.
        """
        self._cache_runner(SshLKClientRunner(host, username, password), alias)

    def start_licence_keeper_client(self, path=None, alias=None):
        """Run Licence Keeper client via given runner.

        :param path: (optional) str, Path to ClientMain.exe image. By default,
            "/cygdrive/c/Users/tester/Desktop/QPM_LK1.3(Hangzhou)" is used.
        :param alias: (optional) str, Alias of the runner to use. If no alias is
            given, a default alias is used.
        """
        runner = self._lookup_runner_alias(alias)
        runner.run(path=path)
        logging.debug('Start QPM_LK client successfully.')

    def stop_licence_keeper_client(self, imagename=None, alias=None):
        """Tell the host to kill a process with the given imagename.

        :param imagename: (optional) str, The process name that will be killed.
            By default "ClientMain.exe" is used. This is the same name that is visible in
            Windows Task Manager.
        :param alias: (optional) str, Alias of the runner to use. If no alias is
            given, a default alias is used.

        This will raise ValueError if no process with given imagename was found
        on the host, or RuntimeError if it failed to kill the specified process.
        """
        self._lookup_runner_alias(alias).kill(imagename=imagename)

    def licence_keeper_client_is_running(self, imagename=None, alias=None):
        """Tell if the process with given imagename is running on the host.

        :param imagename: (optional) str,  The process name that will be checked.
            By default "ClientMain.exe" is used. This is the same name that is visible in
            Windows Task Manager.
        :param alias: (optional) str, Alias of the runner to use. If no alias is
            given, a default alias is used.
        :return: True if the process is running, False otherwise.
        """
        return self._lookup_runner_alias(alias).is_running(imagename=imagename)

    def disconnect_ssh_runner(self, alias=None):
        """Disconnect the ssh runner instance that runs the Licence Keeper client.
        :param alias: (optional) str, Alias of the runner to use. If no alias is
            given, a default alias is used.
        """
        self._lookup_runner_alias(alias).disconnect_ssh()

    def connect(self, host, port=6006):
        """Connect to the Licence Keeper client command line with specific port.

        :param host: str, IP address of the machine that provides
            port (probably the one that runs ClientMain.exe).
        :param port: int, The command port number

        This has to be run before sending any command or trying to disconnect.
        """
        try:
            self._connection.open(host, int(port))
            self.disconnect_flag = False
            logging.debug('Connect to licence keeper {} successfully.'.format(host))
        except Exception:
            logging.error('Connect to licence keeper {} failed.'.format(host))
            raise Exception

    def disconnect(self):
        """Close connection to the Licence Keeper client command line."""
        self._connection.close()
        self.disconnect_flag = True
        logging.debug('Disconnect to licence keeper client.')

    def login(self, username, password, timeout=30):
        """Login the Licence Keeper server.

        :param username: str, Username that Licence Keeper account.
        :param password: str, Password that Licence Keeper account.
        :param timeout: int, default 30 seconds.
        """
        timeout = int(timeout)
        command = 'login {} {}'.format(username, password)
        self._connection.read_until(self._UNTIL_FLAG, timeout=timeout)
        command_result = self._execute_command(command, timeout=timeout)
        if 'Login failure' not in command_result:
            logging.debug('Login success.')
        else:
            raise Exception('Login failure.')

    def logout(self, timeout=30):
        """Logout the Licence Keeper server.

        :param timeout: int, default 30 seconds.
        """
        timeout = int(timeout)
        command = 'logout'
        self._connection.read_until(self._UNTIL_FLAG, timeout=timeout)
        command_result = self._execute_command(command=command, timeout=timeout)
        if 'User already logged out' in command_result:
            logging.debug('Logout success.')
        else:
            raise Exception('Logout failure.')

    def get_licence_qxdm_5g(self, timeout=30, retry=3):
        """
        Get QXDM 5G licence from the Licence Keeper server.
        :param timeout: int, default 30 seconds.
        :param retry: int, default 3.
        """
        self._get_licence_and_check(self._GET_LICENCE_QXDM_5G, timeout, retry)

    def get_licence_qxdm_4g(self, timeout=30, retry=3):
        """
        Get QXDM 4G licence from the Licence Keeper server.
        :param timeout: int, default 30 seconds.
        :param retry: int, default 3.
        """
        self._get_licence_and_check(self._GET_LICENCE_QXDM_4G, timeout, retry)

    def get_licence_qcat_5g(self, timeout=30, retry=3):
        """
        Get QCAT 5G licence from the Licence Keeper server.
        :param timeout: int, default 30 seconds.
        :param retry: int, default 3.
        """
        self._get_licence_and_check(self._GET_LICENCE_QCAT_5G, timeout, retry)

    def get_licence_qcat_4g(self, timeout=30, retry=3):
        """
        Get QCAT 4G licence from the Licence Keeper server.
        :param timeout: int, default 30 seconds.
        :param retry: int, default 3.
        """
        self._get_licence_and_check(self._GET_LICENCE_QCAT_4G, timeout, retry)

    def release_licence_qxdm_5g(self, timeout=30, retry=3):
        """
        Release QXDM 5G licence from the Licence Keeper server.
        :param timeout: int, default 30 seconds.
        :param retry: int, default 3.
        """
        self._release_licence_and_check(self._RELEASE_LICENCE_QXDM_5G, timeout, retry)

    def release_licence_qxdm_4g(self, timeout=30, retry=3):
        """
        Release QXDM 4G licence from the Licence Keeper server.
        :param timeout: int, default 30 seconds.
        :param retry: int, default 3.
        """
        self._release_licence_and_check(self._RELEASE_LICENCE_QXDM_4G, timeout, retry)

    def release_licence_qcat_5g(self, timeout=30, retry=3):
        """
        Release QCAT 5G licence from the Licence Keeper server.
        :param timeout: int, default 30 seconds.
        :param retry: int, default 3.
        """
        self._release_licence_and_check(self._RELEASE_LICENCE_QCAT_5G, timeout, retry)

    def release_licence_qcat_4g(self, timeout=30, retry=3):
        """
        Release QCAT 4G licence from the Licence Keeper server.
        :param timeout: int, default 30 seconds.
        :param retry: int, default 3.
        """
        self._release_licence_and_check(self._RELEASE_LICENCE_QCAT_4G, timeout, retry)

    def _get_licence_and_check(self, command, timeout, retry):
        timeout = int(timeout)
        retry = int(retry)
        fail_flag = True
        self._connection.read_until(self._UNTIL_FLAG, timeout=timeout).decode('ascii')
        while retry:
            command_result = self._execute_command(command, timeout)
            if self._check_if_get_licence(command, command_result):
                fail_flag = False
                break
            retry = retry - 1
        if fail_flag:
            raise Exception('Got licence failed.')

    def _release_licence_and_check(self, command, timeout, retry):
        timeout = int(timeout)
        retry = int(retry)
        fail_flag = True
        self._connection.read_until(self._UNTIL_FLAG, timeout=timeout).decode('ascii')
        while retry:
            command_result = self._execute_command(command, timeout)
            if self._check_if_release_licence(command, command_result):
                fail_flag = False
                break
            retry = retry - 1
        if fail_flag:
            raise Exception('Released licence failed.')

    def _execute_command(self, command, timeout):
        if self.disconnect_flag:
            raise Exception('You have not connected to the Licence Keeper client.')
        logging.debug('Command: {}'.format(command))
        self._connection.write(command.encode('ascii') + self._ENTER_FLAG)
        command_result = self._connection.read_until(self._UNTIL_FLAG, timeout=timeout).decode('ascii')
        logging.debug('Command result: \n{}'.format(command_result))
        return command_result

    @staticmethod
    def _check_if_login(result):
        if 'You are not logged in' in result:
            logging.debug('Need login firstly.')
            return True
        else:
            logging.debug('Already logged in.')
            return False

    def _check_if_get_licence(self, command, result):
        if self._check_if_login(result):
            raise Exception('Please login before get licence.')
        if command in result and 'Got licence' in result:
            logging.debug('Got licence successfully.')
            return True
        else:
            logging.debug('Got licence failed.')
            return False

    @staticmethod
    def _check_if_release_licence(command, result):
        if command in result and 'Released Licence successfully' in result:
            logging.debug('Released licence successfully.')
            return True
        else:
            logging.debug('Released licence failed.')
            return False

    def _lookup_runner_alias(self, alias):
        if alias is None:
            alias = self.default_alias
        return self.app_runners_cache[alias]

    def _cache_runner(self, runner, alias):
        if alias is None:
            alias = self.default_alias
        self.app_runners_cache[alias] = runner

    def _decache_runner(self, alias):
        if alias is None:
            alias = self.default_alias
        del self.app_runners_cache[alias]


class SshLKClientRunner(object):
    default_path = r"/cygdrive/c/Users/tester/Desktop/QPM_LK1.3\(Hangzhou\)"
    default_imagename = 'ClientMain.exe'
    _RUN_LKC_PROCESS = 'cd {};./{} &\n'
    _KILL_LKC_PROCESS = '{} /FI "IMAGENAME eq {}" /F\n'
    _CHECK_LKC_PROCESS = '{} /FI "IMAGENAME eq {}"\n'

    def __init__(self, host, username, password, timeout=60.0):
        self.timeout = timeout
        self.ssh_connection = ssh()
        self.alias = 'ip:' + host + '_' + str(int(time.time() * 1000))
        self.ssh_connection.connect_to(hostname=host, username=username, password=password,
                                       alias=self.alias, timeout=timeout)

    def run(self, path=None):
        if path is None:
            path = self.default_path
        if self.is_running():
            logging.debug('Client is running, no need to start it.')
        else:
            run_lkc_cmd = self._RUN_LKC_PROCESS.format(path, self.default_imagename)
            self.ssh_connection.send_command(command=run_lkc_cmd, connection=self.alias)
            self._check_run_response()

    def _check_run_response(self):
        time.sleep(20)
        if self.is_running():
            logging.debug('Client is running, start it successfully.')
        else:
            logging.debug('Client start failed.')
            raise ValueError('Path contains illegal characters possibly.')

    def kill(self, imagename=None):
        if imagename is None:
            imagename = self.default_imagename
        kill_lkc_cmd = self._KILL_LKC_PROCESS.format('TASKKILL', imagename)
        self.ssh_connection.send_command(command=kill_lkc_cmd, connection=self.alias)
        response = self.ssh_connection.read_output(connection=self.alias)
        logging.debug(response)
        self._check_kill_response(response)

    @staticmethod
    def _check_kill_response(response):
        expected_responses = ['No tasks running with the specified criteria', 'could not be terminated']
        if expected_responses[0] in response:
            raise ValueError('no task with the specified imagename found.')
        elif expected_responses[1] in response:
            raise RuntimeError('the task could not be terminated.')

    def is_running(self, imagename=None):
        if imagename is None:
            imagename = self.default_imagename
        check_lkc_cmd = self._CHECK_LKC_PROCESS.format('TASKLIST', imagename)
        self.ssh_connection.send_command(command=check_lkc_cmd, connection=self.alias)
        response = self.ssh_connection.read_output(connection=self.alias)
        return self._parse_is_running_response(response)

    def disconnect_ssh(self):
        self.ssh_connection.disconnect(connection=self.alias)

    @staticmethod
    def _parse_is_running_response(response):
        expected_response = ['No tasks are running which match the specified criteria', 'Image Name']
        if expected_response[0] in response:
            return False
        elif expected_response[1] in response:
            return True
        else:
            raise RuntimeError('unexpected response: [{}].'.format(response))
