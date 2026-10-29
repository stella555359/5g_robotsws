"""
:modified:02.07.2025

:author: Mateusz Kawka
:maintainer: Mateusz Kawka
:contact: mateusz.kawka@nokia.com
"""

from BaseSSHConnection import BaseSSHConnection
from robot.api import logger
from exceptions import CannotConnectToRemoteHost, NotFoundRadioModule, CannotConnectToRadioModule
import radio_variables as variables
from tabulate import tabulate
import paramiko


class CloudRanConnection(BaseSSHConnection):
    """
    This class represents a connection to a CloudRAN. It inherits from the BaseSSHConnection class.
    """
    def __init__(self):
        """
        Initializes the CloudRanConnection instance.
        """
        super(CloudRanConnection, self).__init__()
        self.pod_name = None
        self.name_space = None
        self.ctr_src_ip = None

    def _cloud_open_connection_to_radio_module(self, ru_serial_number, cloud_server_ip, **kwargs):
        """
        Opens a connection to a radio module in the Cloud RAN.

        Establishes a connection to the specified cloud server and searches for the radio module with the given serial.
        If found, it attempts to establish an SSH connection using credentials from `radio_variables.py` if available.
        Otherwise, it connects as root without credentials.

        :param ru_serial_number: The serial number of the radio unit.
        :type ru_serial_number: str
        :param cloud_server_ip: The cloud virtual machine.
        :type cloud_server_ip: str
        :param kwargs: Optional keyword arguments:
            - username (str): SSH username. Default is 'serviceuser'.
            - password (str): SSH password. If not provided, retrieved from radio_variables.py.
        :return: A tuple containing the radio unit name and IP address.
        :rtype: tuple
        """

        username = kwargs.get('username', 'serviceuser')
        password = kwargs.get('password', None)
        self.connect_to_cloud_server(cloud_server_ip)
        ru_name, ru_ip = self._cloud_find_connection_to_rmod(ru_serial_number)
        logger.info(f"Radio Unit {ru_name} with serial number {ru_serial_number} and IP {ru_ip} found in OAMFH "
                    f"container")
        self.ctr_src_ip = self._find_radio_container_source_ip(ru_ip)

        if ru_name in variables.RMOD_PASSWORDS and variables.RMOD_PASSWORDS[ru_name][0] == username:
            if not password:
                password = variables.RMOD_PASSWORDS[ru_name][1]
                logger.info(f"Logging as {username} based on credentials from radio_variables.py !")
            else:
                logger.info(f"Logging as {username} based on credentials given by user !")
            self._send_command(f'kubectl exec -it -n cran1 {self.pod_name}-oamfh-0 -c ctr{self.name_space}-oamfh -- '
                               f'ssh -b {self.ctr_src_ip} -q -oHostKeyAlgorithms=+ssh-rsa -o StrictHostKeyChecking=no '
                               f'-oPubkeyAcceptedKeyTypes=+ssh-rsa '
                               f'{username}@{ru_ip}')
            self._cloud_establish_ssh_connection_with_credentials(ru_name, password)
            self._send_command('sudo su - rfsw')
            self._read_until_prompt('#|$')
        elif ru_name in variables.RMOD_PASSWORDS_ROOT and variables.RMOD_PASSWORDS_ROOT[ru_name][0] == username:
            if not password:
                password = variables.RMOD_PASSWORDS_ROOT[ru_name][1]
                logger.info(f"Logging as {username} based on credentials from radio_variables.py !")
            else:
                logger.info(f"Logging as {username} based on credentials given by user !")
            self._send_command(f'kubectl exec -it -n cran1 {self.pod_name}-oamfh-0 -c ctr{self.name_space}-oamfh -- '
                               f'ssh -b {self.ctr_src_ip} -q -oHostKeyAlgorithms=+ssh-rsa -o StrictHostKeyChecking=no '
                               f'-oPubkeyAcceptedKeyTypes=+ssh-rsa '
                               f'{username}@{ru_ip}')
            self._cloud_establish_ssh_connection_with_credentials(ru_name, password)
            self._send_command('sudo su - rfsw')
            self._read_until_prompt('#|$')
        elif ru_name in variables.RMOD_PASSWORDS:
            password = variables.RMOD_PASSWORDS[ru_name][1]
            logger.info(f"Logging based on credentials from radio_variables.py !")
            self._send_command(f'kubectl exec -it -n cran1 {self.pod_name}-oamfh-0 -c ctr{self.name_space}-oamfh -- '
                               f'ssh -b {self.ctr_src_ip} -q -oHostKeyAlgorithms=+ssh-rsa -o StrictHostKeyChecking=no '
                               f'-oPubkeyAcceptedKeyTypes=+ssh-rsa '
                               f'{variables.RMOD_PASSWORDS[ru_name][0]}@{ru_ip}')
            self._cloud_establish_ssh_connection_with_credentials(ru_name, password)
        else:
            logger.info("Logging without credentials!")
            self._send_command(f'kubectl exec -it -n cran1 {self.pod_name}-oamfh-0 -c ctr{self.name_space}-oamfh -- '
                               f'ssh -b {self.ctr_src_ip} -q -oHostKeyAlgorithms=+ssh-rsa -o StrictHostKeyChecking=no '
                               f'-oPubkeyAcceptedKeyTypes=+ssh-rsa root@{ru_ip}')
            self._read_until_regexp('#')

        return ru_name, ru_ip

    def _cloud_establish_ssh_connection_with_credentials(self, ru_name, password=None):
        """
        Establishes an SSH connection with credentials.

        Handles fingerprint prompts and password authentication based on credentials stored in `radio_variables.py`.

        :param ru_name: The name of the radio unit.
        :type ru_name: str
        :param password: SSH password. If not provided, retrieved from radio_variables.py.
        :type ru_name: str
        """
        try:
            output = self._read_until_regexp('#|fingerprint|password')
        except Exception:
            raise CannotConnectToRadioModule

        if 'fingerprint' in output:
            logger.info("Found fingerprint, adding key to .known_hosts file")
            self._send_command('yes')
            self._read_until_regexp('password')
            self._send_command(password)
            self._read_until_prompt('#|$')
        elif 'password' in output:
            logger.info(f"Password request, entering: {password}")
            self._send_command(password)
            self._read_until_prompt('#|$')

    def _cloud_establish_ssh_connection_without_credentials(self):
        """
        Establishes an SSH connection without credentials.

        Handles fingerprint prompts and assumes passwordless SSH access.

        :raises CannotConnectToRadioModule: If the connection fails.
        """
        try:
            output = self._read_until_regexp('#|fingerprint')
        except Exception:
            raise CannotConnectToRadioModule

        if 'fingerprint' in output:
            logger.info("Found fingerprint, adding key to .known_hosts file")
            self._send_command('yes')
            self._read_until_prompt('#')

    def _get_pods_name(self):
        """
        Gets the name of the PODs and name space.

        :raises Exception: If the POD name cannot be found in the output.
        """
        pods_cmd = 'kubectl get pods -n cran1'
        self._send_command(pods_cmd)
        pods_output = self._read_until_regexp('NAME.*READY.*STATUS.*RESTARTS.*AGE')

        if 'po-cran1' in pods_output:
            return 'po-cran1', '-cran1'
        elif 'po-' in pods_output:
            return 'po', ''
        elif 'ute-cran1' in pods_output:
            return 'ute-cran1', '-cran1'
        elif 'ute-' in pods_output:
            return 'ute', ''
        else:
            raise Exception("Cannot find pods name in output")

    def connect_to_cloud_server(self, cloud_server_ip):
        """
        Connects to a cloud server virtual machine.

        :param cloud_server_ip: The cloud server virtual machine IP address.
        :type cloud_server_ip: str
        :raises CannotConnectToRemoteHost: If connection fails.
        """
        try:
            self.client.load_system_host_keys()
            self.client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            logger.info(f"Trying to connect to CloudRAN {cloud_server_ip} via "
                        f"{variables.cloud_server_username}:{variables.cloud_server_password}!")
            self.client.connect(hostname=cloud_server_ip,
                                username=variables.cloud_server_username,
                                password=variables.cloud_server_password)
            self.channel = self.client.invoke_shell()
            logger.info(f"Connection to remote host {cloud_server_ip} established!")
            self.pod_name, self.name_space = self._get_pods_name()
        except Exception:
            raise CannotConnectToRemoteHost(cloud_server_ip)

    def _cloud_get_ip_for_all_radio_modules(self, print_table=True):
        """
        Retrieves the IP addresses for all radio modules from a specific Kubernetes pod within the 'cran1' namespace and
        optionally prints them in a table format.
        It executes a command on the Kubernetes pod to fetch the contents of the
        'FRIps.txt' file, which contains IP addresses and serials of radio modules, and parses this data to create
        a dictionary mapping each serial number to its corresponding IP address.

        :param print_table: Determines whether to print the IP and serial number mapping in a table format.
        :type print_table: bool
        :rtype: dict
        :returns: A dict where each key is a serial number (str) and each value is the corresponding IP address (str).
        :raises: ConnectionError: If the command execution fails or the connection to the Kubernetes pod is lost
        """
        frips_cran_cmd = f"kubectl exec -it -n cran1 {self.pod_name}-oamfh-0 -c ctr{self.name_space}-oamfh -- cat " \
                         f"/mnt/ccs/run/config/FRIps.txt"
        logger.debug(f"Command is: {frips_cran_cmd}")

        rmod_ips_dict = {}
        stdin, stdout, stderr = self.client.exec_command(frips_cran_cmd)
        frips_output = stdout.readlines()
        logger.debug(f"""FRIps.txt content:\n{"".join(map(str, frips_output))}""")

        for rmod in frips_output:
            serial_number = rmod.split(';')[3].strip()
            ip = rmod.split(';')[2].strip()
            rmod_ips_dict[serial_number] = ip

        new_tb = tabulate(rmod_ips_dict.items(),
                          headers=["Serial number", "IP"], tablefmt="fancy_grid")
        logger.info(new_tb, also_console=print_table)

        return rmod_ips_dict

    def _cloud_find_connection_to_rmod(self, ru_serial_number):
        """
        Finds the connection details for a radio module in the Cloud RAN.

        :param ru_serial_number: The serial number of the Radio Unit to find.
        :type ru_serial_number: str
        :raises NotFoundRadioModule: If the radio module is not found.
        :return: A tuple containing the connection type and IP address of the RU.
        :rtype: tuple[str, str]
        """
        frips_cran_cmd = f"kubectl exec -it -n cran1 {self.pod_name}-oamfh-0 -c ctr{self.name_space}-oamfh -- cat " \
                         f"/mnt/ccs/run/config/FRIps.txt"
        logger.debug(f"Command is: {frips_cran_cmd}")

        stdin, stdout, stderr = self.client.exec_command(frips_cran_cmd)
        frips_output = stdout.readlines()
        logger.debug(f"""FRIps.txt content:\n{"".join(map(str, frips_output))}""")
        for line in frips_output:
            line = line.strip()
            parts = line.split(';')
            if parts[3] == ru_serial_number:
                return parts[4], parts[2]
        else:
            raise NotFoundRadioModule(ru_serial_number, module='OAMFH container')

    def _copy_file_from_cran_vm_to_container(self, file_path):
        """
        Copies a file from a CloudRAN virtual machine to a container.

        :param file_path: The path of the file to copy.
        :type file_path: str
        :rtype: None
        """
        copy_to_container_cmd = f'kubectl cp -n cran1 {file_path}' \
                                f' {self.pod_name}-oamfh-0:{file_path} ' \
                                f'-c ctr{self.name_space}-oamfh'
        logger.debug(f'Sending command: {copy_to_container_cmd}')
        stdin, stdout, stderr = self.client.exec_command(copy_to_container_cmd)
        logger.debug(f"Stdout from cmd: {stdout.read().decode()}")
        logger.debug(f"Stderr from cmd: {stderr.read().decode()}")

    def _find_radio_container_source_ip(self, ru_ip):
        """
        Finds CloudRAN OAMFH container source IP for radio connection.

        :param ru_ip: radio destination IP.
        :type ru_ip: str
        :rtype: ctr_src_ip: str
        """
        ifcs_cran_cmd = f"kubectl exec -it -n cran1 {self.pod_name}-oamfh-0 -c ctr{self.name_space}-oamfh -- " \
                        f"ip -4 -o addr show | awk '{{print $4}}' | cut -d/ -f1"
        logger.debug(f"Command is: {ifcs_cran_cmd}")

        stdin, stdout, stderr = self.client.exec_command(ifcs_cran_cmd)
        if_ips = stdout.read().decode().splitlines()

        for if_ip in if_ips:
            ping_cmd = f"kubectl exec -it -n cran1 {self.pod_name}-oamfh-0 -c ctr{self.name_space}-oamfh -- " \
                       f"ping -c 1 -I {if_ip} {ru_ip}"
            stdin, stdout, stderr = self.client.exec_command(ping_cmd)
            ping_rc = stdout.channel.recv_exit_status()
            if ping_rc == 0:
                logger.info(f"Found container source IP for RU connection: {if_ip}")
                return if_ip

        logger.error("Cannot find container source IP for RU connection!")
        raise CannotConnectToRadioModule()
