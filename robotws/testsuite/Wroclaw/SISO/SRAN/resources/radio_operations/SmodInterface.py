"""
:modified:09.09.2024

:author: Mateusz Kawka
:maintainer: Mateusz Kawka
:contact: mateusz.kawka@nokia.com
"""

from BaseSSHConnection import BaseSSHConnection
from robot.api import logger
import re
from tabulate import tabulate


class SmodInterface(BaseSSHConnection):
    def __init__(self):
        super(SmodInterface, self).__init__()

    def _get_software_release_from_enb(self, partition, remote_host, full_build_name=False):
        """
        Connects to the ENB and retrieves the software release version from the specified partition.

        This method establishes a connection to the ENB, either directly or via a remote host, and retrieves
        the software release version from the specified partition ('active' or 'passive'). It executes a command
        to list files in the appropriate directory and searches for a file matching the pattern 'TargetBD'.
        If `full_build_name` is set to True, it retrieves the full build name from the XML file; otherwise,
        it retrieves the abbreviated build name.

        :param partition: The partition to retrieve the software release from ('active' or 'passive').
        :type partition: str
        :param remote_host: The hostname or IP address of the remote host. If None, connects directly to the ENB.
        :type remote_host: str, optional
        :param full_build_name: Optional. If True, retrieve the full build; otherwise, retrieve only release. Def: False
        :type full_build_name: bool

        :raises ValueError: If the partition is not 'active' or 'passive'.

        :return: The software release version.
        :rtype: str
        """
        if remote_host is None:
            self.connect_to_enb()
        else:
            self.connect_to_enb_via_remote_host(remote_host)

        if partition.lower() == 'active':
            cmd = 'ls /ffs/run | egrep "TargetBD" | head -1'
        elif partition.lower() == 'passive':
            cmd = 'ls /ffs/stb | egrep "TargetBD" | head -1'
        else:
            raise ValueError(f"Invalid partition: {partition}")
        stdin, stdout, stderr = self.client.exec_command(cmd)
        xml_file = stdout.read().decode()
        logger.debug(xml_file)
        if full_build_name:
            sw_version = re.search(r"TargetBD_([^.]*)\.xml", xml_file).group(1)
        else:
            sw_version = re.search(r"TargetBD_([A-Z0-9]+)_", xml_file).group(1)

        self.disconnect()

        return sw_version

    def _get_active_software_release_from_enb(self, remote_host, full_build_name=False):
        """
        Get the active software release from the ENB.

        This method retrieves the active software release from the ENB by connecting to it via SSH.
        If a `remote_host` is provided, it establishes a connection to the ENB through the remote host.
        It then executes a command to list files in the '/ffs/run' directory and searches for a file
        matching the pattern 'TargetBD'. If `full_build_name` is set to True, it retrieves the full
        build name from the XML file; otherwise, it retrieves the abbreviated build name.

        :param remote_host: The hostname or IP address of the remote host. If None, connects directly to the ENB.
        :type remote_host: str
        :param full_build_name: Optional. If True, retrieve the full build name;
                                          otherwise, retrieve the abbreviated build name. Defaults to False.
        :type full_build_name: bool

        :return: The active software release.
        :rtype: str
        """
        return self._get_software_release_from_enb('active', remote_host, full_build_name)

    def _get_passive_software_release_from_enb(self, remote_host, full_build_name=False):
        """
        Get the passive software release from the ENB.

        This method retrieves the passive software release from the ENB by connecting to it via SSH.
        If a `remote_host` is provided, it establishes a connection to the ENB through the remote host.
        It then executes a command to list files in the '/ffs/stb' directory and searches for a file
        matching the pattern 'TargetBD'. If `full_build_name` is set to True, it retrieves the full
        build name from the XML file; otherwise, it retrieves the abbreviated build name.

        :param remote_host: The hostname or IP address of the remote host. If None, connects directly to the ENB.
        :type remote_host: str
        :param full_build_name: Optional. If True, retrieve the full build name;
                                          otherwise, retrieve the abbreviated build name. Defaults to False.
        :type full_build_name: bool

        :return: The passive software release.
        :rtype: str
        """
        return self._get_software_release_from_enb('passive', remote_host, full_build_name)

    def _get_airscale_bbmod_mapping(self, remote_host, print_table):
        """
        Get the mapping between AirScale SMODs and BBMODs.

        This method establishes connections to the ENB and retrieves information about the BBMODs
        associated with each SMOD. If a `remote_host` is provided, it establishes connections through
        the remote host. It first retrieves data about the SMODs using the `get_modules_data` method
        and then establishes SSH tunnels to the BBMODs using the `set_ssh_tunnel_to_bbmod` method.
        It logs information about the BBMODs found and builds a mapping between SMODs and their associated BBMODs.
        If `print_table` is True, it prints the mapping as a formatted table.

        :param remote_host: The hostname or IP address of the remote host. If None, connects directly to the ENB.
        :type remote_host: str
        :param print_table: Whether to print the mapping table. Defaults to False.
        :type print_table: bool

        :return: A dictionary containing the mapping between SMODs and their associated BBMODs.
        :rtype: dict
        """
        bbmod_mapping_dict = {}

        if remote_host is None:
            self.connect_to_enb()
        else:
            self.connect_to_enb_via_remote_host(remote_host)

        master_smod_id_sn = self.get_modules_data()
        bbmod_mapping_dict[master_smod_id_sn] = []
        master_bb_aliases = self.get_list_of_bb_alias()

        for bb_alias in master_bb_aliases:
            try:
                self.set_ssh_tunnel_to_bbmod(self.hostname, bb_alias)
                bb_module_sn = self.get_modules_data()
                bbmod_mapping_dict[master_smod_id_sn].append(bb_module_sn)
                logger.info(f"BBMOD with alias {bb_alias}: {bb_module_sn}")
            except Exception:
                logger.error(f'Cannot connect with BBMOD {bb_alias}')

        if remote_host is None:
            self.connect_to_enb()
        else:
            self.connect_to_enb_via_remote_host(remote_host)
        hostname_2 = self.set_second_core_hostname()
        second_host_ping_rc = self.get_ping_status_for_host(hostname_2)

        if second_host_ping_rc == 0:
            logger.info(f"Found host on {hostname_2} !")
            self.set_ssh_tunnel_to_second_core(hostname_2)
            secondary_smod_id_sn = self.get_modules_data()
            secondary_bb_aliases = self.get_list_of_bb_alias()
            bbmod_mapping_dict[secondary_smod_id_sn] = []
            for bb_alias in secondary_bb_aliases:
                try:
                    self.set_ssh_tunnel_to_bbmod(hostname_2, bb_alias)
                    bb_module_sn = self.get_modules_data()
                    bbmod_mapping_dict[secondary_smod_id_sn].append(bb_module_sn)
                    logger.info(f"BBMOD with alias {bb_alias}: {bb_module_sn}")
                except Exception:
                    logger.error(f'Cannot connect with BBMOD {bb_alias}')

        new_tb = tabulate(bbmod_mapping_dict.items(),
                          headers=["SMOD", "BBMOD SN"], tablefmt="fancy_grid")
        logger.info(new_tb, also_console=print_table)

        self.disconnect()

        return bbmod_mapping_dict

    def get_modules_data(self):
        """
        Retrieve module name with serial number.

        This method retrieves the module name and serial number from the system information.
        It executes commands to extract the module serial number and module ID using the 'sysinfo'
        command and 'grep'. It then extracts the module serial number and module ID from the
        command output using regular expressions. If any error occurs during the extraction process,
        it returns 'Unknown' for both module name and serial number.

        :return: The module ID and serial number in the format '<module_id> <module_sn>'.
        :rtype: str
        """
        module_sn_cmd = 'sysinfo 2>/dev/null | grep -m 1 MODULE_SN'
        module_id_cmd = 'sysinfo 2>/dev/null | grep -m 1 MODULE_ID'

        stdin_sn, stdout_sn, stderr_sn = self.client.exec_command(module_sn_cmd)
        stdin_id, stdout_id, stderr_id = self.client.exec_command(module_id_cmd)
        try:
            module_sn = re.findall(r'(?<=\')(.*?)(?=\')', str(stdout_sn.read()))[0]
            module_id = re.findall(r'(?<=\')(.*?)(?=\')', str(stdout_id.read()))[0]
        except Exception:
            module_sn = 'Unknown'
            module_id = 'Unknown'

        return module_id + ' ' + module_sn

    def get_list_of_bb_alias(self):
        """
        Retrieve a list of baseband module aliases from the /etc/hosts file.

        This method executes a command on a remote server to parse the /etc/hosts file
        and extract entries matching the pattern 'fsp[1-9]s0icom'. It then returns a list
        of these aliases.

        :return: A list of baseband module aliases found in the /etc/hosts file.
        :rtype: list of str

        :raises Exception: If there is an error executing the command on the remote server.
        """
        hosts_cmd = """cat /etc/hosts | grep -o 'fsp[1-9]s0icom'"""
        stdin_hosts, stdout_hosts, stderr_hosts = self.client.exec_command(hosts_cmd)
        aliases = stdout_hosts.read().decode().splitlines()
        logger.debug(f"Baseband modules aliases: {aliases}")

        return aliases
