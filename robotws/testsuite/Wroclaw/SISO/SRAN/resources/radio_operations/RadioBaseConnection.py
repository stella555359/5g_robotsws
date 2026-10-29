"""
:modified:02.07.2025

:author: Mateusz Kawka
:maintainer: Mateusz Kawka
:contact: mateusz.kawka@nokia.com
"""

from BaseSSHConnection import BaseSSHConnection
from robot.api import logger
import radio_variables as variables
from tabulate import tabulate
import re
import time
from exceptions import NotSupportedRadioUnit, CannotConnectToRadioModule, NotFoundRadioModule, NotSupportedSmodUnit


class RadioBaseConnection(BaseSSHConnection):
    def __init__(self):
        super(RadioBaseConnection, self).__init__()

    def find_connection_to_rmod(self, ru_serial_number):
        """
        Searches for a radio module (RMod) connection using its serial number.

        This method attempts to find a radio module's connection details by searching through the FRIps.txt file
        on the eNodeB for a matching serial number. It checks both the primary and, if necessary, the secondary core
        for the radio module. If found, it returns the radio module's name, IP address, the unit ID of the module,
        and the hostname of the core where it was found. If the module is not found on the primary core, it attempts
        to find it on the secondary core by establishing an SSH tunnel. If the module is still not found, it raises
        a NotFoundRadioModule exception.

        :param ru_serial_number: The serial number of the radio unit to find.
        :type ru_serial_number: str
        :return: A tuple containing the radio module's name, IP address, unit ID, and hostname.
        :rtype: tuple
        :raises NotFoundRadioModule: If the radio module cannot be found on either the primary or secondary core.
        """
        frips_command = 'cat /rom/config/FRIps.txt'
        unit_id_command = 'cat /proc/device-tree/module-identity/unit-id'

        hostname_2 = self.set_second_core_hostname()
        stdin, stdout, stderr = self.client.exec_command(unit_id_command)
        unit_id_output = stdout.read().decode().replace('\x00', '')
        stdin, stdout, stderr = self.client.exec_command(frips_command)
        frips_output_1 = stdout.readlines()
        logger.debug(f"""FRIps.txt content:\n{"".join(map(str, frips_output_1))}""")
        rmod_line = None
        for line in frips_output_1:
            if line.split(';')[2] != '0.0.0.0' and line.split(';')[3] == ru_serial_number:
                rmod_line = line
                break

        if rmod_line is not None:
            rmod = rmod_line.replace('\n', '')
            logger.info(
                f"Found RMOD {rmod.split(';')[4]} with SN {rmod.split(';')[3]} -> "
                f"{rmod.split(';')[2]} on host: {variables.hostname} - {unit_id_output}"
            )

            return rmod.split(';')[4], rmod.split(';')[2], unit_id_output, variables.hostname

        else:
            ping_rc = self.get_ping_status_for_host(hostname_2)
            if ping_rc == 0:
                self.set_ssh_tunnel_to_second_core(hostname_2)
                stdin, stdout, stderr = self.client.exec_command(frips_command)
                frips_output_2 = stdout.readlines()
                logger.debug(f"""FRIps.txt content:\n{"".join(map(str, frips_output_2))}""")
                stdin, stdout, stderr = self.client.exec_command(unit_id_command)
                unit_id_output = stdout.read().decode().replace('\x00', '')
                rmod_line = None
                for line in frips_output_2:
                    if line.split(';')[2] != '0.0.0.0' and line.split(';')[3] == ru_serial_number:
                        rmod_line = line

                if rmod_line is not None:
                    rmod = rmod_line.replace('\n', '')
                    logger.info(
                        f"Found RMOD {rmod.split(';')[4]} with SN {rmod.split(';')[3]} -> "
                        f"{rmod.split(';')[2]} on host: {hostname_2} - {unit_id_output}"
                    )

                    return rmod.split(';')[4], rmod.split(';')[2], unit_id_output, hostname_2
                else:
                    raise NotFoundRadioModule(ru_serial_number)
            else:
                raise NotFoundRadioModule(ru_serial_number)

    @staticmethod
    def _validate_smod_name(smod_name):
        """
        Validates the name of a System Module (SMod) against a list of supported AirScale modules.

        This method checks if the provided SMod name starts with 'AS' (indicating it is an AirScale module)
        and then verifies if it is included in the list of supported AirScale modules. If the SMod name does not
        match any entry in the list of supported modules, it raises a NotSupportedSmodUnit exception.

        :param smod_name: The name of the System Module to validate.
        :type smod_name: str
        :raises NotSupportedSmodUnit: If the SMod name is not in the list of supported AirScale modules.
        """
        if smod_name.startswith('AS'):
            if smod_name not in variables.AIRSCALE_MODULES:
                raise NotSupportedSmodUnit(smod_name)

    def _open_connection_to_radio_module(self, ru_serial_number, remote_host=None, **kwargs):
        """
        Opens a connection to a specified radio module using either SSH or Telnet protocol.

        This method first attempts to find the connection details of the radio module using its serial number.
        It validates the system module name associated with the radio module to ensure it is supported.
        Depending on the radio module's name, it selects the appropriate port number for the connection.
        It then determines the protocol (SSH or Telnet) to use for the connection based on the radio module's name.
        If the protocol is Telnet, it checks if the system module is an AirScale module and either connects directly
        or through an LXC container. For SSH, it similarly decides the connection method based on the system module type
        and whether custom credentials are provided. It removes the known_hosts file before attempting SSH connections
        to avoid host verification failures. Finally,
        it logs the successful connection attempt and returns the connection details.

        :param ru_serial_number: The serial number of the radio unit to connect to.
        :type ru_serial_number: str
        :param remote_host: The IP address of the remote host to connect through, if applicable.
        :type remote_host: str, optional
        :param kwargs: Additional keyword arguments, can include 'username' and 'password' for SSH connections.
        :return: A tuple containing the radio unit name, IP address, system module name, and system module IP address.
        :rtype: tuple
        """
        if remote_host is None:
            self.connect_to_enb()
        else:
            self.connect_to_enb_via_remote_host(remote_host)

        ru_name, ru_ip, smod_name, smod_ip = self.find_connection_to_rmod(ru_serial_number)
        self._validate_smod_name(smod_name)
        port_number = '1307' if ru_name.startswith('U') else '2323'

        protocol = self.get_radio_module_protocol(ru_name)
        logger.info(
            f"Trying to connect radio module {ru_name} with SN {ru_serial_number} "
            f"and IP {ru_ip} via {protocol} protocol"
        )
        if protocol == 'Telnet':
            if smod_name in variables.AIRSCALE_MODULES:
                lxc_container = self.get_lxc_container()
                self._send_command(f'lxc-attach -n {lxc_container} telnet {ru_ip} {port_number}')
                self._read_until_prompt('$|>')
            else:
                self._send_command(f'telnet {ru_ip} {port_number}')
                self._read_until_prompt('$|>')
        elif protocol == 'SSH':
            if smod_name in variables.AIRSCALE_MODULES:
                lxc_container = self.get_lxc_container()
                if 'username' in kwargs and 'password' in kwargs:
                    logger.info(f"Logging with custom credentials: {kwargs['username']}={kwargs['password']}")
                    self._remove_known_hosts_file()
                    self._send_command(f"lxc-attach -n {lxc_container} ssh {kwargs['username']}@{ru_ip}")
                    self.establish_ssh_connection_with_credentials(ru_name, custom_pass=kwargs['password'])
                elif ru_name in variables.RMOD_PASSWORDS:
                    logger.info("Logging with credentials from radio_variables.py !")
                    self._remove_known_hosts_file()
                    self._send_command(
                        f'lxc-attach -n {lxc_container} ssh ' f'{variables.RMOD_PASSWORDS[ru_name][0]}@{ru_ip}'
                    )
                    self.establish_ssh_connection_with_credentials(ru_name)
                    if (
                        ru_name not in variables.RADIO_MODULES['FHS']
                        and variables.RMOD_PASSWORDS[ru_name][0] == 'serviceuser'
                    ):
                        self._send_command('sudo su - rfsw')
                        self._read_until_prompt('#|$')
                else:
                    self._remove_known_hosts_file()
                    self._send_command(f'lxc-attach -n {lxc_container} ssh {ru_ip}')
                    self.establish_ssh_connection_without_credentials()
            else:
                if ru_name in variables.RMOD_PASSWORDS:
                    self._remove_known_hosts_file()
                    self._send_command(f'ssh {variables.RMOD_PASSWORDS[ru_name][0]}@{ru_ip}')
                    self.establish_ssh_connection_with_credentials(ru_name)
                else:
                    self._remove_known_hosts_file()
                    self._send_command(f'ssh {ru_ip}')
                    self.establish_ssh_connection_without_credentials()

        logger.info(f"Connection to {ru_name} established!")
        return ru_name, ru_ip, smod_name, smod_ip

    def _remove_known_hosts_file(self):
        """
        Removes the known_hosts file to prevent SSH connection issues.

        This method attempts to remove the known_hosts file from the user's .ssh directory to avoid potential
        SSH connection issues related to host key verification. It executes a remote command to delete the file
        and checks for any errors during execution. If an error occurs, it logs the error. If the command executes
        successfully but the file does not exist, it handles the situation gracefully without raising an error.

        :rtype: None
        """
        logger.debug("Removing known_hosts file ...")
        stdin, stdout, stderr = self.client.exec_command('rm /user/toor4nsn/.ssh/known_hosts')
        error = stderr.read().decode()
        if error:
            logger.debug(f"Stderr from cmd: {error}")
        if stdout.channel.recv_exit_status() != 0 and 'No such file or directory' not in error:
            logger.warn(f"Cannot remove known_hosts due to: {error}")
        else:
            logger.debug("Known_hosts file removed correctly!")

    def establish_ssh_connection_without_credentials(self):
        """
        Establishes an SSH connection without using credentials, handling fingerprint verification.

        This method attempts to establish an SSH connection to a radio module without using credentials.
        It waits for a prompt indicating a request for fingerprint confirmation. If a fingerprint prompt is encountered,
        it automatically confirms it to add the key to the known_hosts file,
        thus bypassing the need for manual confirmation.
        This is particularly useful for automating SSH connections to new hosts. If the connection cannot be established
        or if an unexpected prompt is encountered, it raises a CannotConnectToRadioModule exception.

        :raises CannotConnectToRadioModule: If the connection attempt fails or encounters an unexpected prompt.
        """
        try:
            output = self._read_until_regexp('#|fingerprint')
        except Exception:
            raise CannotConnectToRadioModule

        if 'fingerprint' in output:
            logger.info("Found fingerprint, adding key to .known_hosts file")
            self._send_command('yes')
            self._read_until_prompt('#')

    def establish_ssh_connection_with_credentials(self, ru_name, custom_pass=None):
        """
        Establishes an SSH connection to a radio module using credentials.

        This method attempts to establish an SSH connection to a specified radio module. It waits for a prompt
        indicating either a request for a fingerprint confirmation or a password.
        If a fingerprint prompt is encountered, it automatically confirms it to add the key to the known_hosts file.
        Then, it waits for a password prompt and submits the password.
        The password used is either provided as an argument or fetched from a predefined dictionary
        based on the radio module's name. If a password prompt is directly encountered, the method submits the password
        immediately. The method raises an exception if it fails to establish a connection within a specified timeout.

        :param ru_name: The name of the radio unit to connect to.
        :type ru_name: str
        :param custom_pass: The password to use for the connection, if not using the default from the dictionary.
        :type custom_pass: str, optional
        :raises CannotConnectToRadioModule: If the connection attempt fails.
        """
        try:
            output = self._read_until_regexp('#|fingerprint|password', timeout=15)
        except Exception:
            raise CannotConnectToRadioModule

        if custom_pass is None:
            passwd = variables.RMOD_PASSWORDS[ru_name][1]
        else:
            passwd = custom_pass

        if 'fingerprint' in output:
            logger.info("Found fingerprint, adding key to .known_hosts file")
            self._send_command('yes')
            self._read_until_regexp('password')
            self._send_command(passwd)
            self._read_until_prompt('#|$')
        elif 'password' in output:
            logger.info(f"Password request, entering: {passwd}")
            self._send_command(passwd)
            self._read_until_prompt('#|$')

    def get_lxc_container(self, retry_count=3, retry_delay=5):
        """
        Attempts to find and return the name of an LXC container matching a specific pattern.

        This method executes the 'lxc-ls' command on the remote host to list all LXC containers,
        then searches the output for container names matching a predefined pattern (specifically,
        containers with names starting with '0x1' or '0x2' followed by '018'). If a matching container
        is found, its name is returned. The method retries the command a specified number of times
        (default is 3) with a delay between retries (default is 5 seconds) if the command fails or
        no matching container is found.

        :param retry_count: The number of times to retry the command if it fails or no match is found.
        :type retry_count: int
        :param retry_delay: The number of seconds to wait between retries.
        :type retry_delay: int
        :return: The name of the matching LXC container, or None if no match is found after all retries.
        :rtype: str or None
        """
        lxc_ls_command = 'lxc-ls'
        attempt = 0
        while attempt < retry_count:
            try:
                stdin, stdout, stderr = self.client.exec_command(lxc_ls_command, timeout=10)
                lxc_output = stdout.read().decode()
                lxc_container = re.findall(r'0x[1|2]018', lxc_output)[0]
                logger.info(f"LXC container to connect: {lxc_container}")
                return lxc_container
            except Exception as e:
                logger.debug(f"SSHException on attempt {attempt + 1}: {e}")
                attempt += 1
                time.sleep(retry_delay)
                return None

    @staticmethod
    def get_radio_module_protocol(ru_name):
        """
        Determines the protocol used to connect to a radio module based on its name.

        This method checks if the radio unit's name matches any of the names in the predefined lists
        for SSH or Telnet protocols. If a match is found, it returns the corresponding protocol name.
        If no match is found, it raises an exception indicating that the radio unit is not supported.

        :param ru_name: The name of the radio unit.
        :type ru_name: str
        :return: The protocol name ('SSH' or 'Telnet') used for the connection.
        :rtype: str
        :raises NotSupportedRadioUnit: If the radio unit's name does not match any in the predefined lists.
        """
        ssh_protocol = any(ru_name in rus for rus in variables.RADIO_MODULES.values())
        telnet_protocol = any(ru_name in rus for rus in variables.TELNET_MODULES.values())

        if ssh_protocol:
            return 'SSH'
        elif telnet_protocol:
            return 'Telnet'
        else:
            raise NotSupportedRadioUnit(ru_name)

    def _get_ip_for_all_radio_modules(self, remote_host=None, print_table=True):
        """
        Retrieves the IP addresses for all radio modules connected to the eNodeB.

        This method executes a command to fetch the FRIps.txt file content from the eNodeB, which contains
        the IP addresses of all connected radio modules. It then parses this content to extract the IP addresses
        and serial numbers of the radio modules. If a second core is present and reachable, it repeats the process
        for the second core. The method optionally prints a table of the serial numbers and IP addresses to the console.

        :param remote_host: The IP address of the remote host to connect through, if not connecting directly.
        :type remote_host: str, optional
        :param print_table: Flag indicating whether to print the table of IPs to the console.
        :type print_table: bool
        :return: A dictionary with hostnames as keys and another dictionary as values, which maps serials to IPs.
        :rtype: dict
        :raises NotFoundRadioModule: If no radio module is found for the given serial number.
        """
        frips_command = 'cat /rom/config/FRIps.txt'

        if remote_host is None:
            self.connect_to_enb()
        else:
            self.connect_to_enb_via_remote_host(remote_host)

        hostname_2 = self.set_second_core_hostname()
        rmod_ips = {'192.168.255.1': {}}

        stdin, stdout, stderr = self.client.exec_command(frips_command)
        frips_output_1 = stdout.readlines()
        logger.debug(f"""FRIps.txt content:\n{"".join(map(str, frips_output_1))}""")

        for rmod in frips_output_1:
            serial_number = rmod.split(';')[3]
            ip = rmod.split(';')[2]
            if ip != '0.0.0.0':
                rmod_ips[variables.hostname][serial_number] = ip

        rc_ping_second_core = self.get_ping_status_for_host(hostname_2)

        if rc_ping_second_core == 0:
            self.set_ssh_tunnel_to_second_core(hostname_2)
            rmod_ips[hostname_2] = {}
            stdin, stdout, stderr = self.client.exec_command(frips_command)
            frips_output_2 = stdout.readlines()
            logger.debug(f"""FRIps.txt content:\n{"".join(map(str, frips_output_2))}""")

            for rmod in frips_output_2:
                serial_number = rmod.split(';')[3]
                ip = rmod.split(';')[2]
                if ip != '0.0.0.0':
                    rmod_ips[hostname_2][serial_number] = ip
        else:
            logger.info("Not found second core !")

        for smod, ips_dict in zip(rmod_ips.keys(), rmod_ips.values()):
            new_tb = tabulate(ips_dict.items(), headers=[smod + "\n\nSerial number", "\n\nIP"], tablefmt="fancy_grid")
            logger.info(new_tb, also_console=print_table)

        self.disconnect()

        return rmod_ips

    def connect_to_soc(self, soc_ip):
        """
        Connects to a System-on-Chip (SoC) using SSH.

        :param soc_ip: The IP address of the SoC.
        :type soc_ip: str
        :rtype: None
        :raises: CannotConnectToRemoteHost: If connection fails.
        """
        logger.info(f"Connecting to SoC with IP {soc_ip}")
        self._send_command(f'ssh {soc_ip}')
        self._read_output()
