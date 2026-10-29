"""
:modified:02.07.2025

:author: Mateusz Kawka
:maintainer: Mateusz Kawka
:contact: mateusz.kawka@nokia.com
"""

import paramiko
import radio_variables as variables
import time
import re
import os
from robot.api import logger
from exceptions import SendCommandFailure, OutputReadingError, \
    CannotConnectToRemoteHost, CannotConnectToEnb, ExpectedOutputNotFound, CannotDefineSecondHostname


class BaseSSHConnection(object):
    def __init__(self):
        super(BaseSSHConnection, self).__init__()
        self.hostname = variables.hostname
        self.username = variables.username
        self.password = variables.password
        self.client = paramiko.SSHClient()
        self.channel = None

    def connect_to_enb(self):
        """
        Set up connection to ENB via IP defined in variables.py

        This method establishes a connection to the ENB using the IP address
        defined in the 'variables.py' file. It sets up SSH connection parameters, including
        loading system host keys and setting the missing host key policy. Then, it attempts to
        connect to the ENB using the provided hostname, username, password, and a timeout of 5
        seconds. If the connection is successful, it invokes a shell on the remote host.

        :return: The paramiko SSH client object representing the established connection.
        :rtype: paramiko.SSHClient

        :raises CannotConnectToEnb: If the method fails to establish a connection to the ENB.
        """
        try:
            self.client.load_system_host_keys()
            self.client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            self.client.connect(hostname=self.hostname,
                                username=self.username,
                                password=self.password,
                                timeout=5)
            self.channel = self.client.invoke_shell()
            logger.info(f"Connection to local host {self.hostname} established!\nInvoke shell raised!")
            return self.client
        except Exception:
            raise CannotConnectToEnb(variables.hostname)

    def connect_to_enb_via_remote_host(self, remote_host):
        """
        Set up connection to ENB via remote host defined in `remote_host` parameter.

        This method establishes a connection to the ENB through a remote host.
        It loads system host keys and sets the missing host key policy for the SSH client. Then,
        it attempts to connect to the remote host using the provided `remote_host`, username 'ute',
        and SSH key file located at '/home/ute/.ssh/id_rsa'. If the connection to the remote host
        is successful, it sets up a direct TCP/IP channel to the ENB. Subsequently, it establishes
        a connection to the ENB using the provided `hostname`, `username`, `password`, and the
        previously created TCP/IP channel as the socket. If the connection to the ENB is successful,
        it invokes a shell on the remote host.

        :param remote_host: The hostname or IP address of the remote host.
        :type remote_host: str

        :return: The paramiko SSH client object representing the established connection.
        :rtype: paramiko.SSHClient

        :raises CannotConnectToRemoteHost: If the method fails to establish a connection to the
                                           specified remote host.
        :raises CannotConnectToEnb: If the method fails to establish a connection to the ENB.
        """
        try:
            host_key_path = '/home/ute/.ssh/known_hosts'
            if os.path.exists(host_key_path):
                os.system(f"ssh-keygen -R {remote_host} -f {host_key_path} > /dev/null 2>&1")
            self.client.load_system_host_keys()
            self.client.set_missing_host_key_policy(paramiko.AutoAddPolicy())

            self.client.connect(hostname=remote_host,
                                username='ute',
                                key_filename='/home/ute/.ssh/id_rsa')
            logger.info(f"Connection to remote host {remote_host} established!")
        except Exception:
            raise CannotConnectToRemoteHost(remote_host)
        try:
            if os.path.exists(host_key_path):
                os.system(f"ssh-keygen -R {self.hostname} -f {host_key_path} > /dev/null 2>&1")
            self.client.set_missing_host_key_policy(paramiko.WarningPolicy())  # WarningPolicy is alternative
            logger.debug("Set missing host key policy to WarningPolicy()")
            smod_1 = self.client.get_transport()
            dest_addr = (self.hostname, 22)
            local_addr = (remote_host, 22)
            smod_1_channel = smod_1.open_channel("direct-tcpip", dest_addr, local_addr)

            self.client.connect(
                hostname=self.hostname, username=variables.username,
                password=variables.password, sock=smod_1_channel, timeout=30)
            logger.info("Connected to SMOD {0} ({1}) via remote host {2}".
                        format(self._get_unit_id(), self.hostname, remote_host))
            self.channel = self.client.invoke_shell()
            return self.client
        except Exception:
            raise CannotConnectToEnb(self.hostname)

    def set_ssh_tunnel_to_second_core(self, hostname_2):
        """
        Set up SSH tunnel to the second core.

        This method sets up an SSH tunnel to the second core by establishing a direct TCP/IP
        channel between the current host and the specified `hostname_2` representing the second core.
        It opens a channel for the SSH tunnel, connects to the `hostname_2` using the provided
        username and password from the 'variables' module, and assigns the tunnel connection to
        the SSH client. If the connection is successful, it invokes a shell on the remote host.

        :param hostname_2: The hostname or IP address of the second core.
        :type hostname_2: str

        :return: The paramiko SSH client object representing the established connection.
        :rtype: paramiko.SSHClient

        :raises CannotConnectToEnb: If the method fails to establish a connection to the second core.
        """
        try:
            smod_2 = self.client.get_transport()
            dest_addr = (hostname_2, 22)
            local_addr = (self.hostname, 22)
            smod_2_channel = smod_2.open_channel("direct-tcpip", dest_addr, local_addr)
            self.client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            self.client.connect(
                hostname=hostname_2, username=variables.username, password=variables.password, sock=smod_2_channel)
            self.channel = self.client.invoke_shell()

            logger.info("Connected to SMOD {0} ({1}) via host {2}".
                        format(self._get_unit_id(), hostname_2, self.hostname))
            return self.client
        except Exception:
            raise CannotConnectToEnb(hostname_2)

    def set_ssh_tunnel_to_bbmod(self, smod_ip, bbmod_ip):
        """
        Set up SSH tunnel to the BBMOD (Baseband Module).

        This method establishes an SSH tunnel to the BBMOD by creating a direct TCP/IP channel
        between the SMOD and the BBMOD. It opens a channel for the SSH tunnel,
        connects to the BBMOD using the provided `bbmod_ip`, and assigns the tunnel connection
        to the SSH client. If the connection is successful, it invokes a shell on the remote host.

        :param smod_ip: The IP address of the SMOD (Service Module) where the tunnel originates.
        :type smod_ip: str
        :param bbmod_ip: The IP address of the BBMOD (Baseband Module) to connect to.
        :type bbmod_ip: str

        :return: The paramiko SSH client object representing the established connection.
        :rtype: paramiko.SSHClient

        :raises CannotConnectToEnb: If the method fails to establish a connection to the BBMOD.
        """
        try:
            transport = self.client.get_transport()
            dest_addr = (bbmod_ip, 22)
            local_addr = (smod_ip, 22)
            bbmod_channel = transport.open_channel("direct-tcpip", dest_addr, local_addr)
            self.client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            self.client.connect(
                hostname=bbmod_ip, username=variables.username, password=variables.password, sock=bbmod_channel)
            self.channel = self.client.invoke_shell()

            logger.info(f'Connected to BBMOD {self._get_unit_id()} ({bbmod_ip}) via {smod_ip}')
            return self.client
        except Exception:
            raise CannotConnectToEnb(bbmod_ip)

    def set_second_core_hostname(self):
        """
        Returns the hostname for the second SMOD.

        This method determines the hostname for the second SMOD based on the localhost's hostname
        and the aliases defined in the '/etc/hosts' file. If the hostname is 'fct-0a', it checks
        if the alias 'fct-4a' is present in the hosts file. If found, the hostname is set to 'fct-4a';
        otherwise, it defaults to '192.168.255.7'. Similar logic applies for other hostnames such as
        'fct-4a', 'asc-0a', and 'fct'. If the localhost's hostname does not match any expected values,
        it raises a 'CannotDefineSecondHostname' exception.

        :return: The hostname for the second SMOD.
        :rtype: str

        :raises CannotDefineSecondHostname: If the localhost's hostname does not match any expected values.
        """
        hosts_ips_cmd = 'cat /etc/hosts'
        localhost_cmd = 'hostname'

        stdin, stdout, stderr = self.client.exec_command(localhost_cmd)
        localhost = stdout.read().decode().strip()
        logger.debug(f"Localhost name: {localhost}")
        logger.info("Looking for alias to second core in file '/etc/hosts'")
        stdin, stdout, stderr = self.client.exec_command(hosts_ips_cmd)
        hosts = stdout.read().decode()
        if localhost == 'fct-0a':
            if 'fct-4a' in hosts:
                hostname_2 = 'fct-4a'
                logger.info("Found alias for AirScale: fct-4a")
            else:
                hostname_2 = '192.168.255.7'
                logger.info(f"Not found alias for second AirScale, hostname set as default to: {hostname_2}")
        elif localhost == 'fct-4a':
            if 'fct-0a' in hosts:
                hostname_2 = 'fct-0a'
                logger.info("Found alias for AirScale: fct-0a")
            else:
                hostname_2 = '192.168.255.7'
                logger.info(f"Not found alias for second AirScale, hostname set as default to: {hostname_2}")
        elif localhost == 'asc-0a':
            if 'asc-4a' in hosts:
                hostname_2 = 'asc-4a'
                logger.info("Found alias for AirScale: asc-4a")
            else:
                hostname_2 = '192.168.255.7'
                logger.info(f"Not found alias for second AirScale, hostname set as default to: {hostname_2}")
        elif localhost == 'fct':
            hostname_2 = '192.168.255.7'
            logger.info(f"Alias for second FSMF set to: {hostname_2}")
        else:
            raise CannotDefineSecondHostname

        return hostname_2

    def get_ping_status_for_host(self, hostname):
        """
        Returns the return code from ping to the given host.

        This method executes a ping command with a single packet to the specified `hostname`.
        It retrieves the return code of the ping operation and logs it. The return code indicates
        the success or failure of the ping operation.

        :param hostname: The hostname or IP address to ping.
        :type hostname: str

        :return: The return code from the ping operation.
        :rtype: int
        """
        stdin, stdout, stderr = self.client.exec_command("ping -c 1 " + hostname)
        ping_rc = stdout.channel.recv_exit_status()
        logger.info(f"RC for ping to {hostname} is {ping_rc}")

        return ping_rc

    def disconnect(self):
        """
        Close all connections to ENB and tunnels.

        This method closes the SSH connection to the ENB and any open tunnels. It terminates
        all active connections associated with the SSH client.

        :return: None
        """
        self.client.close()
        logger.info("SSH connection closed!")

    def _get_unit_id(self):
        """
        Get unit ID from System Module.

        This method retrieves the unit ID from the System Module by executing a command
        to read the unit ID file located at '/proc/device-tree/module-identity/unit-id'.
        It returns the unit ID as a string.

        :return: The unit ID obtained from the System Module.
        :rtype: str
        """
        stdin, stdout, stderr = self.client.exec_command('cat /proc/device-tree/module-identity/unit-id')
        return stdout.read().decode()

    def _send_command(self, command, delay=0):
        """
        Send a command over the SSH channel.

        This method sends a command over the SSH channel to the connected device. It also adds
        a delay if specified. The command is sent as bytes after encoding. After sending the command,
        a carriage return is also sent to execute the command.

        :param command: The command to be sent.
        :type command: str
        :param delay: Optional. Delay in seconds after sending the command. Defaults to 0.
        :type delay: int

        :raises SendCommandFailure: If there is a failure in sending the command.
        """
        try:
            self.channel.sendall(command)
            logger.info(f"Sent command:\n{command}")
            self.channel.send('\r')
            time.sleep(delay)
        except SendCommandFailure as e:
            raise e

    def _read_output(self, delay=0.5):
        """
        Read output from the SSH channel.

        This method reads output from the SSH channel, waiting for a specified delay before attempting
        to read. If there is available output to be read, it retrieves the response, decodes it as ASCII
        text, and replaces any decoding errors. The output is then logged and returned.

        :param delay: Optional. Delay in seconds before attempting to read output. Defaults to 0.5.
        :type delay: float

        :return: The output read from the terminal.
        :rtype: str

        :raises OutputReadingError: If there is an error in reading the output.
        """
        try:
            time.sleep(delay)
            if self.channel.recv_ready():
                resp = self.channel.recv(9999)
                output = resp.decode('ascii', errors='replace')
                logger.info(f"Output from terminal:\n{output}")
                return output
        except OutputReadingError as e:
            raise e

    def read_until(self, expected_output, timeout=20):
        """
        Read output from the SSH channel until the expected output is found or timeout is reached.

        This method continuously reads output from the SSH channel until the expected output is found
        or the specified timeout is reached. It calls the `_read_output` method to retrieve output from
        the terminal. If the output ends with the expected output, it returns the output. Otherwise,
        it continues to read until the timeout is reached.

        :param expected_output: The expected output to find.
        :type expected_output: str
        :param timeout: Optional. The timeout duration in seconds. Defaults to 5.
        :type timeout: int

        :return: The output read from the terminal.
        :rtype: str

        :raises ExpectedOutputNotFound: If the expected output is not found within the specified timeout.
        """
        max_time = time.time() + timeout

        while time.time() < max_time:
            output = self._read_output()
            if output is None:
                logger.debug(f"Still looking for expected output: {expected_output}")
                continue
            if output.replace(' ', '').endswith(expected_output):
                logger.info(f"Found expected output: '{expected_output}'")
                return output

        raise ExpectedOutputNotFound(expected_output, timeout)

    def _read_until_prompt(self, prompt, timeout=20):
        """
        Read output from the SSH channel until one of the specified prompts is found or timeout is reached.

        This method continuously reads output from the SSH channel until one of the specified prompts
        is found or the specified timeout is reached. It calls the `_read_output` method to retrieve
        output from the terminal. If the last character of the accumulated output matches any of the
        characters in the specified prompts, it returns the output. Otherwise, it continues to read until
        the timeout is reached.

        :param prompt: The list of expected prompt characters.
        :type prompt: str
        :param timeout: Optional. The timeout duration in seconds. Defaults to 5.
        :type timeout: int

        :return: The output read from the terminal.
        :rtype: str

        :raises ExpectedOutputNotFound: If none of the specified prompts are found within the specified timeout.
        """
        prompt = prompt.split('|')
        max_time = time.time() + timeout

        output = ''
        while time.time() < max_time:
            otp = self._read_output()
            if otp is None:
                logger.debug(f"Still looking for expected prompt: {prompt}")
                continue
            else:
                output += otp
            if output.replace(' ', '')[-1] in prompt:
                logger.info(f"Found expected prompt: '{output.replace(' ', '')[-1]}'")
                return output

        raise ExpectedOutputNotFound(prompt, timeout)

    def _read_until_regexp(self, regexp, timeout=20):
        """
        Read output from the SSH channel until the specified regular expression is found or timeout is reached.

        This method continuously reads output from the SSH channel until the specified regular expression
        is found in the accumulated output or the specified timeout is reached. It calls the `_read_output`
        method to retrieve output from the terminal. If the regular expression is found in the accumulated
        output, it returns the output. Otherwise, it continues to read until the timeout is reached.

        :param regexp: The regular expression pattern to search for.
        :type regexp: str
        :param timeout: Optional. The timeout duration in seconds. Defaults to 5.
        :type timeout: int

        :return: The output read from the terminal.
        :rtype: str

        :raises ExpectedOutputNotFound: If the specified regular expression is not found within the specified timeout.
        """
        max_time = time.time() + timeout

        output = ''
        while time.time() < max_time:
            otp = self._read_output()
            if otp is None:
                logger.debug(f"Still looking for expected regexp: {regexp}")
                continue
            else:
                output += otp
            if bool(re.search(regexp, output)):
                logger.info(f"Found expected regex: '{regexp}' in output")
                return output

        raise ExpectedOutputNotFound(regexp, timeout)
