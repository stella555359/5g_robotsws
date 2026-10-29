# -*- coding:utf-8 -*-
# Licence Keeper manager ported from hifu.lan@nokia-sbell.com work

import telnetlib
import time
import paramiko
import logging


class LK_manager(object):
    _GET_LICENCE_QXDM_5G = "keep QXDM 5G"
    _GET_LICENCE_QXDM_4G = "keep QXDM 4G"
    _GET_LICENCE_QCAT_5G = "keep QCAT 5G"
    _GET_LICENCE_QCAT_4G = "keep QCAT 4G"
    _RELEASE_LICENCE_QXDM_5G = "drop QXDM 5G"
    _RELEASE_LICENCE_QXDM_4G = "drop QXDM 4G"
    _RELEASE_LICENCE_QCAT_5G = "drop QCAT 5G"
    _RELEASE_LICENCE_QCAT_4G = "drop QCAT 4G"
    _UNTIL_FLAG = b"LK>"
    _ENTER_FLAG = b"\r\n"
    app_runners_cache = {}
    default_alias = "default"

    def __init__(self):
        self.ssh_client = paramiko.SSHClient()
        self._connection = telnetlib.Telnet()
        self.disconnect_flag = True

    def prepare(
        self,
        hostname,
        ssh_username,
        ssh_password,
        lk_username,
        lk_password,
        lk_path=None,
        ssh_key_file_path=None,
        port='22',
        timeout=30,
    ):
        self.hostname = hostname
        self.username = ssh_username
        self.password = ssh_password
        self.lk_username = lk_username
        self.lk_password = lk_password
        self.lk_path = lk_path
        self.ssh_key_file_path = ssh_key_file_path
        self.port = port
        self.timeout = timeout
        self.run_lk()
        self._ssh_connect()
        self.stop_QualcommPackageManager_client()
        self._ssh_disconnect()
        time.sleep(5)
        self.connect(hostname=self.hostname)
        time.sleep(5)

    def is_connection_alive(self):
        """
        function to check if connection is stile alive
        """
        try:
            if self.ssh_client.get_transport() is not None:
                return self.ssh_client.get_transport().is_active()
        except Exception as e:
            logging.debug("Connection lost : %s" % e)
            return False

    def _ssh_connect(self):
        """
        start ssh connection to Ue PC
        """
        self.ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        self.ssh_client.connect(
            hostname=self.hostname,
            port='22',
            username=self.username,
            key_filename=self.ssh_key_file_path,
            password=self.password,
            look_for_keys=False,
            banner_timeout=180,
            timeout=self.timeout
        )

        return self.is_connection_alive()

    def _ssh_disconnect(self):
        """
        disconnect Ue PC ssh connection
        """
        if self.is_connection_alive():
            self.ssh_client.close()
            logging.debug("ssh connexion disconnected")

    def _perform_cmd_over_ssh(self, cmd_line, timeout=5):
        """
        function to transfer local files to remote host dir using scp

        cmd_line: str
            cmd line to execute

        :return
        str
            command line response

        :raise
        NotImplementedError
            Raise an error message if any IO error occurred during the transfer process.
        """
        if not self.is_connection_alive():
            self._ssh_connect()
        try:
            cmd_line = cmd_line.decode("unicode-escape").replace("\\", "/")
        except AttributeError:
            cmd_line = cmd_line.replace("\\", "/")
        logging.debug(cmd_line)
        try:
            stdin, stdout, stderr = self.ssh_client.exec_command(cmd_line)

            endtime = time.time() + timeout
            while not stdout.channel.eof_received:
                time.sleep(1)
                if time.time() > endtime:
                    stdout.channel.close()
                    break
            err = stderr.read()
            result = stdout.read()
            logging.debug(result)
            return err, result
        except Exception as exc:  # pylint: disable=broad-except
            error = "{!r}".format(exc)
            err = (
                ">>> Error while executing:\n"
                + cmd_line
                + "\n>>> Returned with error:\n"
                + str(error)
            )
            return err, ""

    def run_lk(self, timeout=30):
        """
        Function not in use with LK version 1.5
        :param timeout:
        :return:
        """
        cmd = r"cd {} && cygstart ClientMain.exe \r\n".format(self.lk_path)
        err, result = self._perform_cmd_over_ssh(cmd_line=cmd, timeout=timeout)
        logging.debug(result)

    def stop_QualcommPackageManager_client(self, timeout=30):
        self._kill_process(imagename="QualcommPackageManager.exe")

    def _kill_process(self, imagename="ClientMain.exe", timeout=30):
        """

        @param PIDs:
        @param timeout:
        @return:
        """
        cmd = (
            "ps -W | grep %s | awk '{print $1}' | while read line; do echo $line | xargs Kill -f; done;"
            % imagename
        )

        err, result = self._perform_cmd_over_ssh(cmd_line=cmd, timeout=timeout)
        logging.debug(result)

    def connect(self, hostname, port=6006):
        """Connect to the Licence Keeper client command line with specific port.

        :param host: str, IP address of the machine that provides
            port (probably the one that runs ClientMain.exe).
        :param port: int, The command port number

        This has to be run before sending any command or trying to disconnect.
        """
        try:
            self._connection.open(hostname, int(port))
            self.disconnect_flag = False
            logging.debug(
                "Connect to licence keeper {} successfully.".format(hostname)
            )
        except Exception:
            logging.debug("Connect to licence keeper {} failed.".format(hostname))
            raise Exception

    def disconnect(self):
        """Close connection to the Licence Keeper client command line."""
        self._connection.close()
        self.disconnect_flag = True
        logging.debug("Disconnect to licence keeper client.")

    def login(self, timeout=10, retry=3):
        """Login the Licence Keeper server.

        :param username: str, Username that Licence Keeper account.
        :param password: str, Password that Licence Keeper account.
        :param timeout: int, default 30 seconds.
        """
        timeout = int(timeout)
        retry = int(retry)
        command = "login {} {}".format(self.lk_username, self.lk_password)
        self._connection.read_until(self._UNTIL_FLAG, timeout=timeout)
        while retry:
            command_result = self._execute_command(command, timeout=timeout)
            if "Login success" in command_result:
                logging.debug("Login success.")
                break
            retry = retry - 1
        else:
            raise Exception("Login failure.")

    def logout(self, timeout=30, retry=3):
        """Logout the Licence Keeper server.

        :param timeout: int, default 30 seconds.
        """
        timeout = int(timeout)
        command = "logout"
        self._connection.read_until(self._UNTIL_FLAG, timeout=timeout)
        while retry:
            command_result = self._execute_command(command=command, timeout=timeout)
            if (
                "User already logged out" in command_result
                or "Logout success" in command_result
            ):
                logging.debug("Logout success.")
                break
            retry = retry - 1
        else:
            raise Exception(
                "Logout failure. with server error message: \n\t{}".format(
                    command_result
                )
            )

    def get_licence_qxdm_5g(self, timeout=30, retry=10):
        """
        Get QXDM 5G licence from the Licence Keeper server.
        :param timeout: int, default 30 seconds.
        :param retry: int, default 3.
        """
        self._get_licence_and_check(self._GET_LICENCE_QXDM_5G, timeout, retry)

    def get_licence_qcat_5g(self, timeout=30, retry=10):
        """
        Get QCAT 5G licence from the Licence Keeper server.
        :param timeout: int, default 30 seconds.
        :param retry: int, default 3.
        """
        self._get_licence_and_check(self._GET_LICENCE_QCAT_5G, timeout, retry)

    def release_licence_qxdm_5g(self, timeout=30, retry=10):
        """
        Release QXDM 5G licence from the Licence Keeper server.
        :param timeout: int, default 30 seconds.
        :param retry: int, default 3.
        """
        self._release_licence_and_check(self._RELEASE_LICENCE_QXDM_5G, timeout, retry)

    def release_licence_qcat_5g(self, timeout=30, retry=10):
        """
        Release QCAT 5G licence from the Licence Keeper server.
        :param timeout: int, default 30 seconds.
        :param retry: int, default 3.
        """
        self._release_licence_and_check(self._RELEASE_LICENCE_QCAT_5G, timeout, retry)

    def _get_licence_and_check(self, command, timeout, retry):
        timeout = int(timeout)
        retry = int(retry)
        fail_flag = True
        while retry:
            command_result = self._execute_command(command, timeout)
            if self._check_if_get_licence(command, command_result):
                fail_flag = False
                break
            retry = retry - 1
            time.sleep(30)
        if fail_flag:
            raise Exception("Got licence failed.")

    def _release_licence_and_check(self, command, timeout, retry):
        timeout = int(timeout)
        retry = int(retry)
        self._connection.read_until(self._UNTIL_FLAG, timeout=timeout).decode("ascii")
        while retry:
            command_result = self._execute_command(command, timeout)
            if self._check_if_release_licence(command, command_result):
                break
            retry = retry - 1
        else:
            raise Exception("Released licence failed.")

    def _execute_command(self, command, timeout):
        if self.disconnect_flag:
            raise Exception("You have not connected to the Licence Keeper client.")
        logging.debug("Command: {}".format(command))
        self._connection.write(command.encode("ascii") + self._ENTER_FLAG)
        command_result = self._connection.read_until(
            self._UNTIL_FLAG, timeout=timeout
        ).decode("ascii")
        logging.debug("Command result: \n{}".format(command_result))
        return command_result

    @staticmethod
    def _check_if_login(result):
        if "You are not logged in" in result:
            logging.debug("Need login firstly.")
            return True
        else:
            logging.debug("Already logged in.")
            return False

    def _check_if_get_licence(self, command, result):
        if self._check_if_login(result):
            raise Exception("Please login before get licence.")
        if command in result and "Got licence" in result:
            logging.debug("Got licence successfully.")
            return True
        else:
            logging.debug("Got licence failed.")
            return False

    @staticmethod
    def _check_if_release_licence(command, result):
        if command in result and "Released Licence successfully" in result:
            logging.debug("Released licence successfully.")
            return True
        else:
            logging.debug("Released licence failed.")
            return False
