"""
:copyright: Nokia Networks
:author: 'Monika Ceglarek'
:contact: 'monika.ceglarek@nokia.com'
:maintainer: 'Monika Ceglarek'
:contact: 'monika.ceglarek@nokia.com'
:version: 0.1
"""

import ta5g_iphy
import ta5g_testline_management
from robot.api import logger
from ta5g_interface_tools import ta5g_interface_tools, log_name
from ta5g_admin_operations import ta5g_admin_operations
from ta5g_egate import ta5g_egate


class cloud_bts_egate(ta5g_egate):

    @log_name(level="INFO")
    def reach_onair_aic(self, lua_cfg, logs_dirpath=None, timeout=180, check_edaemon_port=False, align_tac_values=True,
                        x2_setup_pass_regexp=".*", sim_cell_ids=None, wait_for_mib_and_sib=True,
                        version_check_toggle='on'):
        """
        This is modified method taken from ta5g_egate library.
        Run WTS application and start Core simulation. Wait until cells reach 'on air'. As a last step,
        try to setup X2AP interface with an option to check the result in AiC.
        :param lua_cfg: File path of .lua config file
        :param logs_dirpath: Directory for output logs
        :param timeout: Timeout for cells enabling, MIB and SIB1 reception
        :param check_edaemon_port: Default False, if True then function will search for port in lua_cfg
        :param align_tac_values: Default True, the function will align TAC values in .lua/.cfg file to scf
        :param x2_setup_pass_regexp: Default ".*", the function will set x2_setup_pass_regexp
        :param sim_cell_ids: list containing IDs of simulated cells
        :param wait_for_mib_and_sib: Default True, boolean parameter indicating whether checks for
               Master Information Block and System Information Block appearance should be run.
               Only to be used during test development.
        :param version_check_toggle: toggle for EGATE version check. Possible values 'on', 'off'. Default value 'on'.
        :return:
        """
        number_of_vdu = ta5g_admin_operations().get_number_of_vdu()
        if not logs_dirpath:
            logs_dirpath = ta5g_interface_tools().get_robot_output_dir()
        ta5g_testline_management.ta5g_testline_management.start_default_simulated_SANSA_interfaces()
        self.start_wts_and_store_config_file_in_logs_dir_aic(lua_cfg=lua_cfg, logs_dirpath=logs_dirpath,
                                                             check_edaemon_port=check_edaemon_port,
                                                             align_tac_values=align_tac_values)
        ta5g_iphy.ta5g_iphy().check_radios_availability_aic(timeout=timeout, number_of_vdu=number_of_vdu)
        ta5g_admin_operations().check_if_f1_links_available_aic()
        self._ute_wtssim_instance.execute_egate_command(cmd=f"start version_check={version_check_toggle}",
                                                        timeout=10)
        self.wait_for_all_cells_to_be_in_correct_states_es_aic(timeout=timeout)
        self._conditional_print_for_debugging(False, f"wait_for_mib_and_sib {wait_for_mib_and_sib}")
        if wait_for_mib_and_sib:
            self.wait_for_mib_reception_aic(cell_list=sim_cell_ids, timeout=timeout)
            self.wait_for_sib1_reception_aic(cell_list=sim_cell_ids, timeout=timeout)

        self._ute_wtssim_instance.execute_egate_command(cmd="enb_x2_link_up enb=1 target=2",
                                                        pass_regexp=x2_setup_pass_regexp,
                                                        timeout=5)

    @log_name(level="INFO")
    def wait_for_all_cells_to_be_in_correct_states_es_aic(self, timeout=180):
        """
        Waits for cells to be in correct state for configuration
        with energy saving configured and aic
        :param timeout: timeout for cells to be in correct state in seconds
        :return:
        """
        logger.console(f"Waiting {timeout} seconds for all cells to be in correct states.")
        ta5g_admin_operations().check_until_timeout(checking_func=self.check_all_cells_es, timeout=timeout)

    def check_all_cells_es(self):
        """
        Checks if cells are in correct state for configuration
        with energy saving configured and aic
        :return:
        """
        admin_operations = ta5g_admin_operations()
        with admin_operations.connect_to_vdu_aic() as vdu_connection:
            for cell_data in vdu_connection.get_vdu_cells_status():
                self._validate_cell_data(admin_operations, cell_data, vdu_connection)

    def _validate_cell_data(self, admin_operations, cell_data, vdu_connection):
        cell_info = vdu_connection.get_cell_specific_info(cell_data['dist_names']['config'])
        expected_states = self._expected_states(cell_info)
        for search_key in expected_states.keys():
            self._validate_value(admin_operations, cell_info, expected_states, search_key)

    def _validate_value(self, admin_operations, cell_info, expected_states, search_key):
        actual = self._set_actual(cell_info, search_key)
        self._conditional_print_for_debugging(False, f"Cell {cell_info['basicCell']['id']}, {search_key}={actual}")
        admin_operations.assert_equal(
            expected=expected_states[search_key].lower(), actual=actual,
            message=f"Cell with id {cell_info['basicCell']['id']} is {actual}"
                    f"\nCell should be {expected_states[search_key]}")

    @staticmethod
    def _set_actual(cell_info, search_key):
        if search_key == 'availabilityStatus':
            actual = cell_info[search_key].lower()
        else:
            actual = cell_info['basicCell'][search_key].lower()
        return actual

    @staticmethod
    def _expected_states(cell_info):
        if cell_info['energySavingState'] in ['notEnergySaving', 'reducedEnergySaving', 'switchingOff']:
            return {'operationalState': 'enabled', 'availabilityStatus': 'on line'}
        elif cell_info['energySavingState'] in ['energySaving', 'switchingOn']:
            return {'operationalState': 'disabled', 'availabilityStatus': 'off line'}
        else:
            raise Exception(f"Unidentified energy saving state: '{cell_info['energySavingState']}'.")

    @log_name(level="INFO")
    def wait_for_mib_reception_aic(self, timeout=180, cell_list=None):
        """
        This is modified method taken from ta5g_egate library.
        Waits for MasterInformationBlock to appear in EGATE.
        :param timeout: Timeout for MIB reception
        :param cell_list: list containing IDs of simulated cells
        :return:
        """
        if cell_list:
            mib_cells_dict = {2: [i for i in cell_list]}
        else:
            mib_cells_dict = self.determine_details_of_mib_aic()
        self.wait_for_information_block_reception_for_given_cells(
            cells=mib_cells_dict, infoblocktype='MasterInformationBlock', timeout=timeout)

    @log_name(level="INFO")
    def wait_for_sib1_reception_aic(self, timeout=60, cell_list=None):
        """
        This is modified method taken from ta5g_egate library.
        Waits for MasterInformationBlock to appear in EGATE.
        :param timeout: Timeout for SIB1 reception
        :param cell_list: list containing IDs of simulated cells
        :return:
        """
        if cell_list:
            cells_dict = {2: [i for i in cell_list]}
        else:
            cells_dict = self.determine_details_of_sibs1_to_check_aic()
        if cells_dict == {}:
            logger.info("NSA configuration, SIB1 turned off on gNB, omitting wait for sib reception", also_console=True)
            return True
        self.wait_for_information_block_reception_for_given_cells(
            cells=cells_dict, infoblocktype='SystemInformationBlockType1', timeout=timeout)

    @staticmethod
    def _conditional_print_for_debugging(condition, text):
        if condition:
            logger.console(text)
            logger.debug(text)
