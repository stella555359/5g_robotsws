from taf.config.testline.info import info
from taf.config.testline.info.exceptions import UserNotDefinedForSWLine
from robot.libraries.BuiltIn import BuiltIn
from taf.ul.bts_components.invoke_shell.InvokeShellHandler import InvokeSshHandler
from taf.ul.bts_components.invoke_shell.exceptions import (RmodConnectionError, ExpectedPhraseNotFoundError)
from taf.sbts.oam.coam.admin import admin as coam
from taf.sbts.oam.coam.admin.exceptions import DataNotAvailable
from time import sleep
from contextlib import contextmanager

import logging
import re

logging.basicConfig(level=logging.INFO, format='%(asctime)s %(levelname)s:%(message)s')

WEBEM_USERNAME = 'Nemuadmin'
WEBEM_PASSWORD = 'nemuuser'
MAX_EQUIPMENT_LEVEL = 4


class rmod_ssh():
    def __init__(self):
        logging.debug("\n***** Initializing rmod_ssh class *****")
        self.rmod_config_data = {}

    def setup_rmod_ssh_connection(self, rmod_sn, bts_alias,
                                  admin_log_dir='/tmp', rmod_ip_input=''):
        """
        Sets up an SSH connection to the specified RMOD.

        param mandatory: rmod_sn (str): Serial number of the RMOD. Based on it,
                                        rmod data (ip, fh_interface, etc.)
                                        will be retrieved from BTS.
        param mandatory: bts_alias (str): Alias of the BTS where the RMOD is connected.
        param optional: admin_log_dir (str): Directory on VM to store admin logs.
                                             By default stores in /tmp
        param optional: rmod_ip_input (str): IP address of the RMOD. Only to be used if
                                             we want to override the IP which is normally
                                             read from BTS.
        """
        self.prepare_connection_data(rmod_sn_input=rmod_sn, rmod_ip_input=rmod_ip_input,
                                     bts_alias=bts_alias, admin_log_dir=admin_log_dir
                                     )
        ssh_rmod = self.connect_to_rmod(rmod_sn=rmod_sn, rmod_config_data=self.rmod_config_data,
                                        via_vm_ip=self.rmod_config_data[rmod_sn]['via_vm_ip']
                                        )
        return ssh_rmod

    def execute_command_on_rmod(self, rmod_sn, command_for_rmod):
        """
        Executes a command on the specified RMOD via SSH.

        param mandatory: command_for_rmod (str): Command to be executed on the RMOD.
        param optional: rmod_sn (str): Serial number of the RMOD.
                                       In case ssh_rmod session is not usable,
                                       a session restart will be attempted.
        return: None
        """
        try:
            command_output = self.rmod_config_data[rmod_sn]['ssh_session'].send_command_and_return_output(
                command=command_for_rmod,
                slave_bts=self.rmod_config_data[rmod_sn]['connected_to_secondary_core']
                )
        except Exception:
            logging.debug("SSH session to RMOD not usable, setting up a new connection")
            self.rmod_config_data[rmod_sn]['ssh_session'].reconnect_ssh_session()
            command_output = self.rmod_config_data[rmod_sn]['ssh_session'].send_command_and_return_output(
                command=command_for_rmod,
                slave_bts=self.rmod_config_data[rmod_sn]['connected_to_secondary_core']
                )
        logging.debug(f"Command output: {command_output}")
        return command_output

    def teardown_rmod_ssh_connection(self, rmod_sn):
        """
        Tears down the SSH connection to the specified RMOD.

        param mandatory: rmod_sn (str): Serial number of the RMOD.
        return: None
        """
        self.close_rmod_connection(self.rmod_config_data[rmod_sn]['ssh_session'])

    def connect_to_rmod(self, rmod_sn, rmod_config_data, via_vm_ip='', switch_to_rfsw=False):
        """
        Connects to the specified RMOD via SSH.

        param mandatory: rmod_sn (str): Serial number of the RMOD.
        param mandatory: rmod_config_data (dict): Configuration data for the RMOD.
        param optional : via_vm_ip (str): IP address of the VM to connect through.
        param optional : switch_to_rfsw (bool): Flag to switch to RFSW user when running the command on RMOD.
        return: ssh_rmod (InvokeSshHandler): SSH handler for the connected RMOD.
        """
        try:
            ssh_rmod = connect_to_rmod_via_ssh(
                rmod_ip=rmod_config_data[rmod_sn]['rmod_ip'],
                rmod_username=rmod_config_data[rmod_sn]['rmod_username'],
                rmod_password=rmod_config_data[rmod_sn]['rmod_password'],
                smod_ip=rmod_config_data[rmod_sn]['bts_ip'],
                via_vm_ip=via_vm_ip,
                via_vm_username=rmod_config_data[rmod_sn]['via_vm_username'],
                secondary_core_flag=rmod_config_data[rmod_sn]['connected_to_secondary_core'],
                switch_to_rfsw=switch_to_rfsw
                )
        except RmodConnectionError:
            logging.debug("Connection to RMOD {} failed. RMOd data \n{}".format(
                rmod_sn,
                rmod_config_data[rmod_sn]
                ))
            raise
        rmod_config_data[rmod_sn]['ssh_session'] = ssh_rmod
        return ssh_rmod

    def close_rmod_connection(self, rmod_ssh):
        """
        Closes the SSH connection to the specified RMOD.

        param mandatory: rmod_ssh (InvokeSshHandler): SSH handler for the connected RMOD.
        return: None
        """
        logging.debug("\n***** Closing RMOD SSH connection *****")
        rmod_ssh.close_connection()
        logging.debug("RMOD SSH connection closed")

    def prepare_connection_data(self, rmod_sn_input, bts_alias,
                                rmod_ip_input='', admin_log_dir='/tmp'):
        """
        Prepares the connection data for the specified RMOD.

        param mandatory: rmod_sn_input (str): Serial number of the RMOD.
        param mandatory: bts_alias (str): Alias of the BTS where the RMOD is connected.
        param optional: rmod_ip_input (str): IP address of the RMOD.
        param optional: admin_log_dir (str): Directory to store admin logs.
        return: rmod_config_data (dict): Configuration data for the RMOD."""
        logging.debug("\n***** Preparing connection data *****")
        logging.debug(f"Inputs: {rmod_sn_input}{rmod_ip_input}{bts_alias}{admin_log_dir}")
        self.rmod_config_data = {}
        rmod_data = self.get_robot_config_variables(rmod_ip_input=rmod_ip_input,
                                                    rmod_sn_input=rmod_sn_input,
                                                    bts_alias=bts_alias
                                                    )
        self.rmod_config_data.update(rmod_data)
        sw_stream = self.get_sw_stream_from_bts(bts_alias=bts_alias,
                                                rmod_sn_input=rmod_sn_input,
                                                admin_log_dir=admin_log_dir
                                                )
        self.rmod_config_data[rmod_sn_input]['sw_stream'] = sw_stream
        rmod_data = self.get_ip_fh_interface_from_bts(bts_alias=bts_alias,
                                                      rmod_sn_input=rmod_sn_input,
                                                      admin_log_dir=admin_log_dir
                                                      )
        self.rmod_config_data[rmod_sn_input].update(rmod_data)
        logging.debug(f"Rmod data: {self.rmod_config_data}")
        sw_stream = self.rmod_config_data[rmod_sn_input]['sw_stream']
        fh_interface = self.rmod_config_data[rmod_sn_input]['fh_interface']
        rmod_type = self.rmod_config_data[rmod_sn_input]['rmod_type']
        rmod_username = self.rmod_config_data[rmod_sn_input]['rmod_username']
        rmod_password = self.rmod_config_data[rmod_sn_input]['rmod_password']
        rmod_credentials = get_custom_init_rmod_credentials_robot(
            sw_stream=sw_stream, rmod_type=rmod_type,
            fh_interface=fh_interface, rmod_username=rmod_username,
            rmod_password=rmod_password
        )
        secondary_core_flag = self.get_secondary_core_flag(rmod_sn_input=rmod_sn_input, bts_alias=bts_alias,
                                                           admin_log_dir=admin_log_dir)
        self.rmod_config_data[rmod_sn_input]['rmod_username'] = rmod_credentials['username']
        self.rmod_config_data[rmod_sn_input]['rmod_password'] = rmod_credentials['password']
        self.rmod_config_data[rmod_sn_input]['connected_to_secondary_core'] = secondary_core_flag
        logging.debug("Rmod data: {}".format(self.rmod_config_data))
        return self.rmod_config_data

    def get_robot_config_variables(self, rmod_sn_input, bts_alias, rmod_ip_input=""):
        """
        Retrieves the configuration variables for the specified RMOD from Robot Framework variables.

        param mandatory: rmod_sn_input (str): Serial number of the RMOD.
        param mandatory: bts_alias (str): Alias of the BTS where the RMOD is connected.
        param optional: rmod_ip_input (str): IP address of the RMOD.
                                             If given, it overrides the IP from Robot variables.
        return: rmod_config_data (dict): Configuration data for the RMOD.
        """
        logging.debug("\n***** Getting RMOD config variables *****")
        logging.debug(f"Inputs: {rmod_ip_input} {rmod_sn_input} {bts_alias}")

        interfaces_config = BuiltIn().get_variable_value("${INTERFACES}", None)
        logging.debug(f"RMOD_{rmod_sn_input}")
        rmod_config_dict = interfaces_config.get(f"RMOD_{rmod_sn_input}", "RMOD_SN_not_found")
        logging.debug(f"rmod_config_dict: {rmod_config_dict}")

        rmod_type = rmod_config_dict['RADIO_TYPE']
        rmod_username = rmod_config_dict['RADIO_SSH_USERNAME']
        rmod_password = rmod_config_dict['RADIO_SSH_PASSWORD']
        rmod_ip = rmod_ip_input or rmod_config_dict['RADIO_SSH_IP_ADDR']
        logging.debug(f"rmod vars: {rmod_type} {rmod_username} {rmod_password} {rmod_ip}")

        bts_alias_upper = bts_alias.upper()
        bts_alias_upper_robot_var = "${"+bts_alias_upper+"}"
        bts_config_dict = BuiltIn().get_variable_value(bts_alias_upper_robot_var, None)
        logging.debug(f"bts_config_dict: {bts_config_dict}")
        via_vm_ip = bts_config_dict[f"{bts_alias_upper}_PC_IP_ADDRESS"]\
            if bts_alias_upper != 'MASTER' else None
        via_vm_username = bts_config_dict[f"{bts_alias_upper}_PC_SSH_USERNAME"]\
            if bts_alias_upper != 'MASTER' else None
        via_vm_password = bts_config_dict[f"{bts_alias_upper}_PC_SSH_PASSWORD"]\
            if bts_alias_upper != 'MASTER' else None

        bts_ip = bts_config_dict[f"{bts_alias_upper}_IM_IP_ADDRESS"]
        master_bts_config_dict = BuiltIn().get_variable_value(f"${{MASTER}}", None)
        master_vm_ip = master_bts_config_dict["MASTER_PC_IP_ADDRESS"]

        rmod_config_data = {rmod_sn_input: {'rmod_type': rmod_type,
                                            'rmod_username': rmod_username,
                                            'rmod_password': rmod_password,
                                            'rmod_ip': rmod_ip,
                                            'bts_ip': bts_ip,
                                            'via_vm_ip': via_vm_ip,
                                            'via_vm_username': via_vm_username,
                                            'via_vm_password': via_vm_password,
                                            'master_vm_ip': master_vm_ip
                                            }
                            }
        return rmod_config_data

    def get_sw_stream_from_bts(self, rmod_sn_input, bts_alias, admin_log_dir="/tmp"):
        """
        Retrieves the software stream from the BTS for the specified RMOD.

        param mandatory: rmod_sn_input (str): Serial number of the RMOD.
        param mandatory: bts_alias (str): Alias of the BTS where the RMOD is connected.
        param: admin_log_dir (str): Directory to store admin logs.
        return: sw_stream (str): Software stream of the BTS.
        """
        logging.debug("\n***** Getting SW Stream from BTS *****")
        logging.debug(f"Inputs: {bts_alias} {rmod_sn_input} {admin_log_dir}")
        sw_stream = ""
        bts_ip = self.rmod_config_data[rmod_sn_input]["bts_ip"]
        via_vm_ip = self.rmod_config_data[rmod_sn_input]['via_vm_ip']
        via_vm_username = self.rmod_config_data[rmod_sn_input]['via_vm_username']
        via_vm_password = self.rmod_config_data[rmod_sn_input]['via_vm_password']
        with AdminConnectionManager(bts_alias, rmod_sn_input, bts_ip, via_vm_ip, via_vm_username,
                                    via_vm_password, admin_log_dir) as admin_alias:
            bts_sw_version = admin_alias.get_sw_version(connection=bts_alias)
            sw_match_groups = re.match(r"(SBTS[0-9]{2}R[0-9])_(?:ENB|FSM.)_[0-9_]+", bts_sw_version)
            sw_stream = sw_match_groups.group(1)
        if not sw_stream:
            logging.debug("No SW Stream found")
            raise SWStreamNotFound("SW Stream not found for RMOD")
        logging.debug(f"SW Stream: {sw_stream}")
        return sw_stream

    def get_ip_fh_interface_from_bts(self, rmod_sn_input, bts_alias, admin_log_dir="/tmp"):
        """
        Retrieves the FH interface and IP address from the BTS for the specified RMOD.

        param mandatory: rmod_sn_input (str): Serial number of the RMOD.
        param mandatory: bts_alias (str): Alias of the BTS where the RMOD is connected.
        param optional: admin_log_dir (str): Directory on VM to store admin logs.
        return: response (dict): Dictionary containing FH interface (CPRI/eCPRI) and IP address of the RMOD.
        """
        logging.debug("\n***** Getting RMOD FH Interface from BTS *****")
        logging.debug(f"Inputs: {bts_alias} {rmod_sn_input} {admin_log_dir}")
        bts_ip = self.rmod_config_data[rmod_sn_input]['bts_ip']
        via_vm_ip = self.rmod_config_data[rmod_sn_input]['via_vm_ip']
        via_vm_username = self.rmod_config_data[rmod_sn_input]['via_vm_username']
        via_vm_password = self.rmod_config_data[rmod_sn_input]['via_vm_password']
        fh_interface = ""
        ip = ""
        with AdminConnectionManager(bts_alias, rmod_sn_input, bts_ip, via_vm_ip, via_vm_username,
                                    via_vm_password, admin_log_dir) as admin_alias:
            rmod_id_list = admin_alias.get_ids_for_all(class_name='RMOD', connection=bts_alias)
            for rmod_id in rmod_id_list:
                rmod_info = admin_alias.get_parameters_for(class_name='RMOD',
                                                           connection=bts_alias,
                                                           id_num=rmod_id)
                if rmod_sn_input == rmod_info['serialNumber']:
                    fh_interface = 'eCPRI' if 'ecpri' in rmod_info['l3Protocol'].lower() else 'CPRI'
                    ip = self.rmod_config_data[rmod_sn_input]['rmod_ip']\
                        if self.rmod_config_data[rmod_sn_input]['rmod_ip']\
                        else rmod_info['ipAddress']
                    break

        if not fh_interface:
            logging.debug("No FH Interface found")
            raise RmodFhInterfaceNotFound("FH Interface not found for RMOD")
        if not ip:
            logging.debug("No RMOD IP Address found")
            raise RmodIpAddressNotFound("IP Address not found for RMOD")
        response = {"fh_interface": fh_interface, "rmod_ip": ip, "rmod_dn_r": rmod_id}
        logging.debug(f"FH Interface, IP, RMOD_ID: {response}")
        return response

    def get_parent_equipment_from_same_bts(self, bts_admin_instance, bts_alias, equipment_dn_r):
        """
        Retrieves all parent equipment connected to the same BTS for the specified equipment.

        param mandatory: bts_admin_instance (coam): Admin instance for the BTS.
        param mandatory: bts_alias (str): Alias of the BTS where the equipment is connected.
        param mandatory: equipment_dn_r (str): Distinguished name of the equipment.
        return: result (list): List of parent equipment distinguished names.
        """
        logging.debug(f"\n***** Get all parent equipment from same BTS for equipment {equipment_dn_r} *****")
        logging.debug(f"Inputs: {bts_alias} {equipment_dn_r}")
        result = []
        cablink_r_info = bts_admin_instance.get_managed_objects(class_name='CABLINK_R', connection=bts_alias)
        input_list = [equipment_dn_r]
        result = self.get_parent_equipment_from_cablink(cablink_r_info, input_list)
        if not result:
            logging.debug("No upper level equipment found.")
            raise ParentEquipmentNotFound("No upper level equipment found.")
        result.remove(equipment_dn_r)
        return result

    @staticmethod
    def get_cabinet(dn):
        return next((part for part in dn.split('/') if part.startswith('CABINET_R')), None)

    def get_parent_equipment_from_cablink(self, cablink_list, equipment_dn_r_list, level=None):
        """
        Recursively retrieves all parent equipment connected via cablinks.

        param mandatory: cablink_list (list): List of cablink managed objects.
        param mandatory: equipment_dn_r_list (list): List of distinguished names of the equipment.
        param optional: level (int): Current recursion level - DO NOT_POPULATE!
        return: result (list): List of parent equipment distinguished names.
        """
        level = 0 if not level else level
        logging.debug(f"Reached Level {level}")
        if level >= MAX_EQUIPMENT_LEVEL:
            logging.debug("Maximum equipment level reached. Returning.")
            return []

        same_connection_level_equipment = []
        remaining_cablinks = []

        for cablink in cablink_list:
            params = cablink.get('parameters', {})

            first_endpoint_dn = params.get('firstEndpointDN', '')
            first_endpoint_label = params.get('firstEndpointLabel', '')
            second_endpoint_dn = params.get('secondEndpointDN', '')
            second_endpoint_label = params.get('secondEndpointLabel', '')
            configuration_cablink = params.get('linkModeConfiguration') in [None, True]

            logging.debug(f"CABLINK check: {cablink}")

            peer_connected = bool(second_endpoint_dn) and second_endpoint_dn in equipment_dn_r_list
            if not peer_connected:
                remaining_cablinks.append(cablink)
                continue

            # exclude cablinks between SMODs
            if 'SMOD' in first_endpoint_dn and 'SMOD' in second_endpoint_dn:
                continue
            # exclude cablinks between BBMOD and RMOD if linkModeConfiguration is False
            if 'BBMOD' in first_endpoint_dn and 'RMOD' in second_endpoint_dn and not configuration_cablink:
                continue
            # exclude cross-cabinet SMOD-BBMOD cablinks without BACKPLANE label
            if 'SMOD' in first_endpoint_dn and 'BBMOD' in second_endpoint_dn:
                if (self.get_cabinet(first_endpoint_dn) != self.get_cabinet(second_endpoint_dn)
                        and first_endpoint_label != 'BACKPLANE'
                        and second_endpoint_label != 'BACKPLANE'):
                    continue

            same_connection_level_equipment.append(first_endpoint_dn)
            logging.debug(f"Found equipment at level {level}: {first_endpoint_dn}")

        all_upper_level_equipment_list = self.get_parent_equipment_from_cablink(
            remaining_cablinks,
            same_connection_level_equipment,
            level + 1
        ) if same_connection_level_equipment else []

        return all_upper_level_equipment_list + equipment_dn_r_list

    def _determine_cablink_eligibility(self, cablink_list):
        """
        Determines if the cablink's firstEndpointDN belongs to a FSMF - and excludes it.

        param mandatory: cablink_list (list): List of cablink managed objects.
        param mandatory: bts_alias (str): Alias of the BTS where the RMOD is connected.
        param mandatory: bts_admin_instance (object): Instance of the BTS admin.
        return: eligible_cablink_list (list): List of eligible cablinks.
        """
        eligible_cablink_list = []
        logging.debug(f"\n***** Filter eligible cablinks *****")
        for cablink in cablink_list:
            try:
                endpoint_dn = cablink['parameters']['firstEndpointDN']
                smod_r_product_name = bts_admin_instance.get_parameters(dist_name=endpoint_dn, pattern='productName',
                                                                        connection=bts_alias)
                logging.debug(f"SMOD R product name: {smod_r_product_name}")
                if 'FSMF' not in smod_r_product_name["productName"]:
                    eligible_cablink_list.append(cablink)
                else:
                    logging.debug(
                        f"{bts_alias} Cablink will be ignored... it belongs to {endpoint_dn} "
                        f"and product name is {smod_r_product_name}")
            except (KeyError, DataNotAvailable):
                continue
        return eligible_cablink_list

    def get_secondary_core_flag(self, rmod_sn_input, bts_alias, admin_log_dir="/tmp"):
        """
        Determines if the RMOD is connected to a secondary core.

        param mandatory: rmod_sn_input (str): Serial number of the RMOD.
        param mandatory: bts_alias (str): Alias of the BTS where the RMOD is connected.
        param optional: admin_log_dir (str): Directory to store admin logs.
        return: secondary_core_flag (bool): True if connected to secondary core, False otherwise.
        """
        logging.debug(f"\n***** Check BTS core where rmod {rmod_sn_input} is connected *****")
        logging.debug(f"Inputs: {rmod_sn_input} {bts_alias}")

        bts_ip = self.rmod_config_data[rmod_sn_input]['bts_ip']
        via_vm_ip = self.rmod_config_data[rmod_sn_input]['via_vm_ip']
        via_vm_username = self.rmod_config_data[rmod_sn_input]['via_vm_username']
        via_vm_password = self.rmod_config_data[rmod_sn_input]['via_vm_password']
        rmod_id = self.rmod_config_data[rmod_sn_input]['rmod_dn_r']
        with AdminConnectionManager(bts_alias, rmod_sn_input, bts_ip, via_vm_ip, via_vm_username,
                                    via_vm_password, admin_log_dir) as admin_alias:

            all_other_boards = self.get_parent_equipment_from_same_bts(admin_alias, bts_alias, rmod_id)
            smod_id = None
            for board_dn_r in all_other_boards:
                if 'SMOD_R' in board_dn_r:
                    smod_id = board_dn_r
                    break

            if not smod_id:
                logging.debug("No SMOD connected to RMOD found")
            logging.debug(f"SMOD connected to RMOD {rmod_sn_input} is {smod_id}")

            smod_dict = admin_alias.get_system_module_list(connection=bts_alias)
            smod_list = smod_dict['systemModules']
            for smod in smod_list:
                if smod['id']['internal'] == smod_id:
                    break

            if smod['id']['internal'] != smod_id:
                logging.debug("No valid SMOD found connected to RMOD")
            try:
                secondary_core_flag = smod['activeRole'] == 'Secondary'
            except KeyError:
                secondary_core_flag = False
            except Exception as e:
                logging.debug(f"Exception occurred while determining SMOD active role: {e}")
                raise SmodActiveRoleNotFound("Could not determine SMOD active role")
        return secondary_core_flag

    def _login_to_smod(self, rmod_session, login_command, slave_bts, timeout=10):
        """
        Helper method that logs in (via username and password) to SMOD through an existing RMOD session.

        param mandatory: rmod_session (InvokeSshHandler): RMOD SSH session handler used for connecting to SMOD.
        param mandatory: login_command (str): SSH command to initiate connection to SMOD
        param mandatory: slave_bts (bool): Flag indicating if RMOD is connected to secondary BTS core.
        param optional: timeout (int): Timeout in seconds for SSH login operations. Default is 10 seconds.
        return: str or bool: Returns command output string if login succeeds and "root@"
                            prompt is found, False if ExpectedPhraseNotFoundError occurs.
        """
        try:
            rmod_session.send_command_and_return_output(command=login_command, slave_bts=slave_bts,
                                                        expected_phrase="Password: ", timeout=timeout)
            ssh_login_stdout = rmod_session.send_command_and_return_output(command=f"oZPS0POrRieRtu",
                                                                           slave_bts=slave_bts,
                                                                           expected_phrase=f"root@",
                                                                           timeout=timeout)
            logging.debug(f"SSH login command to smod output: {ssh_login_stdout}")
            return ssh_login_stdout
        except ExpectedPhraseNotFoundError as e:
            logging.debug(f"Login cannot be established, exception raised: {e}")
            return False

    def _logout_from_smod(self, rmod_session, logout_command, slave_bts, timeout=10):
        """
        Helper method that logs out from an active SMOD SSH session by sending a logout command.

        param mandatory: rmod_session (InvokeSshHandler): RMOD SSH session handler used for connecting to SMOD.
        param mandatory: logout_command (str): Command to execute for logout (typically "exit").
        param mandatory: slave_bts (bool): Flag indicating if RMOD is connected to secondary BTS core.
        param optional: timeout (int): Timeout in seconds for logout operation. Default is 10.
        return: str or bool: Returns command output string if logout succeeds and "closed"
                            phrase is found, False if ExpectedPhraseNotFoundError occurs.
        """
        try:
            ssh_logout_stdout = rmod_session.send_command_and_return_output(command=logout_command,
                                                                            slave_bts=slave_bts,
                                                                            expected_phrase="closed",
                                                                            timeout=timeout)
            logging.debug(f"SSH logout command from smod output: {ssh_logout_stdout}")
            return ssh_logout_stdout
        except ExpectedPhraseNotFoundError as e:
            logging.debug(f"Logout cannot be established, exception raised: {e}")
            return False

    def execute_command_on_smod(self, rmod_session, rmod_sn, smod_ip, command_for_smod, expected_output,
                                slave_bts, timeout=20):
        """
        Method performs login and executes command on the SMOD via SSH through an existing RMOD session.Then logs out.

        param mandatory: rmod_session (InvokeSshHandler): RMOD SSH session handler used for connecting to SMOD.
        param mandatory: rmod_sn (str): Serial number of the RMOD.
        param mandatory: smod_ip (str): IP address of the SMOD to connect to via SSH.
        param mandatory: command_for_smod (str): Command parameter (currently not used in
                                                implementation - method executes predefined
                                                IP verification command).
        param mandatory: expected_output (str): Expected output string to verify on the SMOD.
        param mandatory: slave_bts (str): BTS management plane IP address to verify on the SMOD.
        param optional: timeout (int): Timeout in seconds for SSH login operation. Default is 20 seconds.
        return: bool: Returns True if login succeeds and BTS management plane IP is found
                     on SMOD, False if ExpectedPhraseNotFoundError exception occurs.
        """
        try:
            login_command = (
                f"ssh -o UserKnownHostsFile=/dev/null "
                f"-o GlobalKnownHostsFile=/dev/null "
                f"-o StrictHostKeyChecking=no "
                f"toor4nsn@{smod_ip} -p 49152"
            )
            self._login_to_smod(rmod_session, login_command, slave_bts, timeout=timeout)
            ssh_command_stdout = rmod_session.send_command_and_return_output(command=command_for_smod,
                                                                             slave_bts=slave_bts,
                                                                             expected_phrase=expected_output,
                                                                             timeout=10)
            logging.debug(f"From {rmod_sn} SSH Session, command on smod output: {ssh_command_stdout}")
            self._logout_from_smod(rmod_session=rmod_session, logout_command="exit",
                                   slave_bts=slave_bts,
                                   timeout=5)
            return True
        except ExpectedPhraseNotFoundError as e:
            logging.debug(f"Exception: {e}")
            return False

    def execute_command_on_smod_via_rmod(self, rmod_sn, smod_ip, command_for_smod, expected_output, timeout=20):
        """
        Executes a command on the specified SMOD via existing RMOD SSH session.

        param mandatory: rmod_sn (str): Serial number of the RMOD.
        param mandatory: smod_ip (str): IP address of the SMOD to connect to via SSH.
        param mandatory: command_for_smod (str): Command to be executed on the SMOD.
        param mandatory: expected_output (str): Expected output string to verify on the SMOD.
        param optional: timeout (int): Timeout in seconds for SSH operations. Default is 20.
        return: command_output (bool): Returns True if the command executes successfully
                                               and the expected phrase is found, False otherwise.
        """
        slave_bts = self.rmod_config_data[rmod_sn]['connected_to_secondary_core']
        try:
            command_output = self.execute_command_on_smod(self.rmod_config_data[rmod_sn]['ssh_session'], rmod_sn,
                                                          smod_ip, command_for_smod, expected_output,
                                                          slave_bts, timeout)
        except Exception:
            logging.debug("SSH session to RMOD not usable, setting up a new connection")
            self.rmod_config_data[rmod_sn]['ssh_session'].reconnect_ssh_session()
            command_output = self.execute_command_on_smod(self.rmod_config_data[rmod_sn]['ssh_session'], rmod_sn,
                                                          smod_ip, command_for_smod, expected_output, slave_bts,
                                                          timeout)

        logging.debug(f"Command output: {command_output}")
        return command_output


def get_custom_init_rmod_credentials_robot(sw_stream, rmod_type, fh_interface, rmod_username="", rmod_password=""):
    """
    Retrieves RMOD credentials based on provided parameters and defaults.

    param mandatory: sw_stream (str): Software stream of the BTS.
    param mandatory: rmod_type (str): Type of the RMOD.
    param mandatory: fh_interface (str): FH interface type.
    param optional: rmod_username (str or dict): RMOD username or dictionary of usernames.
    param optional: rmod_password (str or dict): RMOD password or dictionary of passwords.
    return: rmods_credentials_dict (dict): Dictionary containing RMOD username and password.
    """
    logging.debug("\n***** Getting RMOD credentials *****")
    logging.debug(f"Inputs: {sw_stream} {rmod_type} {fh_interface} {rmod_username} {rmod_password}")
    username = ''
    password = ''
    if isinstance(rmod_username, dict):
        for sw_stream_item in rmod_username.keys():
            if sw_stream and sw_stream_item != sw_stream:
                continue
            username = rmod_username[sw_stream_item]
            password = rmod_password[sw_stream_item]
            break
    if isinstance(rmod_username, str):
        username = rmod_username
        password = rmod_password
    if not rmod_username:
        for username in ['serviceuser', 'root']:
            try:
                default_serviceuser_password = info.get_ru_password(by_radio_type=rmod_type,
                                                                    fh_interface=fh_interface,
                                                                    username=username
                                                                    )
                password = default_serviceuser_password
                if password:
                    break
            except UserNotDefinedForSWLine:
                password = None
    rmods_credentials_dict = {'username': username, 'password': password}
    logging.debug(f"RMOD credentials: {rmods_credentials_dict}")
    return rmods_credentials_dict


def connect_to_rmod_via_ssh(rmod_ip, rmod_username, rmod_password,
                            smod_ip,
                            via_vm_ip, via_vm_username,
                            secondary_core_flag,
                            switch_to_rfsw=False):
    """
    Connects to the specified RMOD via SSH.

    param mandatory: rmod_ip (str): IP address of the RMOD.
    param mandatory: rmod_username (str): Username for RMOD SSH connection.
    param mandatory: rmod_password (str): Password for RMOD SSH connection.
    param mandatory: smod_ip (str): IP address of the SMOD.
    param mandatory: via_vm_ip (str): IP address of the VM to connect through.
    param mandatory: via_vm_username (str): Username for the VM to connect through.
    param mandatory: secondary_core_flag (bool): Flag to indicate if RMOD is connected to secondary core.
    param optional: switch_to_rfsw (bool): Flag to switch to RFSW after connection.
    return: ssh_handler (InvokeSshHandler): SSH handler for the connected RMOD.
    """
    logging.debug("\n***** Connecting to RMOD via SSH *****")
    logging.debug(f"Inputs: {rmod_ip} {rmod_username} {via_vm_ip} {secondary_core_flag} {switch_to_rfsw}")
    ssh_handler = InvokeSshHandler(smod_ip=smod_ip,
                                   proxy_vm_address=via_vm_ip,
                                   proxy_vm_username=via_vm_username
                                   )
    ssh_handler.connect_to_rmod(
        ip=rmod_ip,
        username=rmod_username,
        password=rmod_password,
        switch_to_rfsw=switch_to_rfsw,
        slave_bts=secondary_core_flag
    )
    logging.debug(f"Successfully connected to RMOD {rmod_ip} via SSH")
    return ssh_handler


class AdminConnectionManager:
    def __init__(self, bts_alias, rmod_sn_input,
                 bts_ip, via_vm_ip, via_vm_username, via_vm_password,
                 admin_log_dir):
        logging.debug("\n***** Entering Admin context manager *****")
        self.bts_alias = bts_alias
        self.bts_ip = bts_ip
        self.via_vm_ip = via_vm_ip
        self.via_vm_username = via_vm_username
        self.via_vm_password = via_vm_password
        self.admin_log_dir = admin_log_dir
        self.rmod_sn_input = rmod_sn_input

    def __enter__(self):
        self.admin_session = coam()
        self.alias = self.bts_alias + "_" + self.rmod_sn_input
        logging.debug(f"Create admin connection {self.alias}")
        self.admin_session.setup_admin(bts_host=self.bts_ip, username=WEBEM_USERNAME,
                                       password=WEBEM_PASSWORD,
                                       admin_api_log_dir=self.admin_log_dir,
                                       remote_host=self.via_vm_ip,
                                       remote_host_username=self.via_vm_username,
                                       remote_host_password=self.via_vm_password,
                                       name=self.alias
                                       )
        return self.admin_session

    def __exit__(self, exc_type, exc_value, traceback):
        logging.debug(f"Teardown admin connection {self.alias}")
        self.admin_session.teardown_admin(connection=self.alias)


class SmodActiveRoleNotFound(Exception):
    """Exception raised when SMOD active role is not found."""
    pass


class RmodFhInterfaceNotFound(Exception):
    """Exception raised when RMOD FH interface is not found."""
    pass


class ParentEquipmentNotFound(Exception):
    """Exception raised when parent equipment is not found."""
    pass


class RmodIpAddressNotFound(Exception):
    """Exception raised when RMOD IP address is not found."""
    pass


class SWStreamNotFound(Exception):
    """Exception raised when SW stream is not found."""
    pass
