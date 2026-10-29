import logging
import os
import re
import time
from datetime import datetime
from xml.etree import ElementTree as ET
from moler.device import DeviceFactory
from taf.rfrl.bts.devices.generic_bts import login_logout
from taf.rfrl.bts.connections.device_aliases import ssh_bts_du
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations
from taf.rfrl.bts.devices.du.logs_collecting.basic_logs import GenericLog
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl


class sfpmonitoring(GnbDuOperations, GenericLog):
    def __init__(self):
        super(sfpmonitoring, self).__init__()
        self.unix = None

    @load_moler_configuration_from_tl()
    def _initialize_unix_device(self):
        self.unix = DeviceFactory.get_device('UnixLocal')

    @login_logout
    def initiate_sfp_monitoring(self, devices_list, device_to_verify, connection_state, boundaries, bts_id=0, du_id=0):
        """
        Initiates the SFP dynamic parameters monitoring for devices from the list and verifies if parameters
        dictionaries created after two measurements differ for specific device.
        :param devices_list:        list of runtime object devices for verification
        :param device_to_verify:    name of the specific device for verification
        :param connection_state:    connection state of the SFP for device. Possible values:   connected | notConnected
        :param boundaries:          list of tuples with boundary conditions for parameter values
        :param bts_id:              ID of the gNB, default 0
        :param du_id:               DU ID (Distributed Unit) - related to TestLine configuration - gnbs.dus[]
        :return:                    None
        """
        first_check_links, first_devices_links = self._get_links_tuple(connection_state=connection_state,
                                                                       devices=devices_list,
                                                                       bts_id=bts_id, du_id=du_id)
        logging.info(
            'LINKS FROM FIRST API REQUEST: {}'.format(first_devices_links))
        first_dict = self._check_parameters(
            links=first_check_links, device_links=first_devices_links[device_to_verify],
            connection_state=connection_state, boundaries=boundaries, dynamic=True)
        time.sleep(120)
        second_check_links, second_devices_links = self._get_links_tuple(connection_state=connection_state,
                                                                         devices=devices_list,
                                                                         bts_id=bts_id, du_id=du_id)
        logging.info(
            'LINKS FROM SECOND API REQUEST: {}'.format(second_devices_links))
        second_dict = self._check_parameters(
            links=second_check_links, device_links=second_devices_links[device_to_verify],
            connection_state=connection_state, boundaries=boundaries, dynamic=True)
        if first_dict == second_dict:
            raise Exception('Dictionaries with dynamic parameters should not be equal.\n'
                            'DICTIONARY FROM FIRST API CALL: {}\n'
                            'DICTIONARY FROM SECOND API CALL: {}'.format(first_dict, second_dict))

    @login_logout
    def verify_static_data_from_sfp_monitoring(self, devices_list, device_to_verify, connection_state, boundaries,
                                               bts_id=0, du_id=0):
        links, device_links = self._get_links_tuple(
            connection_state=connection_state, devices=devices_list, bts_id=bts_id, du_id=du_id)
        logging.info('LINKS FROM API REQUEST: {}'.format(device_links))
        self._check_parameters(links=links, device_links=device_links[device_to_verify],
                               connection_state=connection_state, boundaries=boundaries, dynamic=False)

    def _get_links_tuple(self, connection_state, devices, bts_id=0, du_id=0):
        """
        Returns the tuple consisting of SFP linkf
        """
        ret_devices_links = {}
        connection = self.rest_alias.format(bts_id, du_id)
        links = self.admin.get_sfp_links(
            action="getLinksWithParameters", connection=connection)
        for device in devices:
            device_links = self._get_device_sfp_links(
                links=links, connection_state=connection_state, device=device)
            ret_devices_links[device] = device_links
        return links, ret_devices_links

    @staticmethod
    def _get_device_sfp_links(links, connection_state, device):
        ret_dic = {}
        connection_links = links.get(connection_state, [])
        if connection_links:
            for i, link in enumerate(connection_links):
                tmp = []
                source = link.get('source', '')
                dest = link.get('destination', '')
                if device in source:
                    tmp.append('source')
                elif device in dest:
                    tmp.append('destination')
                ret_dic[i] = tmp
        return ret_dic

    def _check_parameters(self, links, device_links, connection_state, boundaries, dynamic=True):
        ret_dic = {}
        verify_function = self._verify_dynamic_parameters_have_valid_direction if dynamic else \
            self._verify_static_parameters_have_valid_direction
        for port, directions in device_links.items():
            dynamic_direction = verify_function(links=links, port=port,
                                                directions=directions,
                                                connection_state=connection_state,
                                                boundaries=boundaries)
            if dynamic_direction is not None:
                ret_dic[port] = dynamic_direction
            else:
                return
        return ret_dic

    def _verify_static_parameters_have_valid_direction(self, links, port, directions, connection_state, boundaries):
        parameters_names = ['temperatureHighAlarmThreshold',
                            'temperatureLowAlarmThreshold']
        parameter_dic_path = links[connection_state][port]['details']['thresholds']
        for direction in directions:
            static_params = []
            temperature_high_threshold = parameter_dic_path['temperatureHighAlarmThreshold'][direction]
            temperature_low_threshold = parameter_dic_path['temperatureLowAlarmThreshold'][direction]
            static_params.extend(
                [temperature_high_threshold, temperature_low_threshold])
            logging.debug('Static temperature parameters values: {}'.format(
                dict(zip(parameters_names, static_params))))
            for parameter, param_name, boundary in zip(static_params, parameters_names, boundaries):
                self._perform_test_of_parameter(
                    parameter=parameter, param_name=param_name, boundary=boundary)

    def _verify_dynamic_parameters_have_valid_direction(self, links, port, directions, connection_state, boundaries):
        parameter_names = ['moduleTemperature', 'TXSupplyVoltage',
                           'TXBiasCurrent', 'TXOpticalPower', 'RXOpticalPower']
        dynamic_direction = {}
        parameter_dic_path = links[connection_state][port]['data']['measurements']
        for direction in directions:
            dynamic_params = []
            initial_direction = 'initialSource' if direction == 'source' else 'initialDestination'
            module_temp = parameter_dic_path['moduleTemperature'][direction]
            tx_supply_voltage = parameter_dic_path['TXSupplyVoltage'][direction]
            tx_bias_current = parameter_dic_path['TXBiasCurrent'][direction]
            tx_optical_power = parameter_dic_path['TXOpticalPower'][initial_direction]
            rx_optical_power = parameter_dic_path['RXOpticalPower'][initial_direction]
            dynamic_params.extend([module_temp, tx_supply_voltage, tx_bias_current,
                                   tx_optical_power, rx_optical_power])
            logging.debug('Dynamic parameters values: {}'.format(
                dict(zip(parameter_names, dynamic_params))))
            for parameter, param_name, boundary in zip(dynamic_params, parameter_names, boundaries):
                self._perform_test_of_parameter(
                    parameter=parameter, param_name=param_name, boundary=boundary)
            dynamic_direction[direction] = dynamic_params
        return dynamic_direction

    @staticmethod
    def _perform_test_of_parameter(parameter, param_name, boundary):
        min_value, max_value = boundary
        parameter = parameter[0] if isinstance(parameter, list) else parameter
        if not min_value <= float(parameter) <= max_value:
            raise Exception('Wrong value of the parameter: {}\n'
                            'Expected to be between {} and {}'.format(param_name, min_value, max_value))

    @load_moler_configuration_from_tl()
    def check_quantity_of_rd_files(self, number_of_files=2, bts_id=0, du_id=0):
        """
        Checks if the quantity of the RD.BTS files located at BTS is bigger than given threshold.
        :param number_of_files:     Quantity threshold
        :param bts_id:              ID of the gNB, default 0
        :param du_id:               DU ID (Distributed Unit) - related to TestLine configuration - gnbs.dus[]
        :return:                    None
        """
        gnb = DeviceFactory.get_device(ssh_bts_du.format('GNB', bts_id, du_id))
        gnb.goto_state(state='FCT')
        quantity = len(self._ls_and_grep(
            device=gnb, ls_path='/tmp', search_pattern='RD.BTS'))
        logging.info('QUANTITY OF RD.BTS FILES: {}'.format(quantity))
        if quantity < number_of_files:
            raise Exception(
                'Number of RD.BTS files should be greater or equal to: {}. Current: {}'.format(number_of_files,
                                                                                               quantity))

    def get_parsed_rd_files(self, path, bts_id=0):
        self._initialize_unix_device()
        current_time = datetime.now().strftime('%Y%m%d-%H%M%S')
        snapshot_path = self.collect_snapshot(log_dir=path, bts_id=bts_id)
        logging.info('SNAPSHOT PATH: {}'.format(snapshot_path))
        snapshot_unzipped = self._unzip_snapshot(
            zip_file_path=snapshot_path, current_time=current_time)
        logging.info('SNAPSHOT UNZIPPED PATH: {}'.format(snapshot_unzipped))
        amia_slot = self.verify_amia_slot(bts_id=0, du_id=0)
        logging.info('AMIA SLOT: {}'.format(amia_slot))
        return self.parse_rd_files(unzipped_path=snapshot_unzipped, amia_slot=amia_slot)

    @load_moler_configuration_from_tl()
    def _unzip_snapshot(self, zip_file_path, current_time):
        zip_directory = os.path.dirname(zip_file_path)
        ret_path = os.path.join(zip_directory, current_time)
        self.unix.get_cmd(cmd_name='unzip',
                          cmd_params={
                              'zip_file': zip_file_path,
                              'extract_dir': ret_path
                          })()
        return ret_path

    @load_moler_configuration_from_tl()
    def verify_amia_slot(self, bts_id=0, du_id=0):
        """
        Returns the slot ID of the AMIA based on hostname. 1 if hostname equals to fct-0a, else 2.
        :param bts_id:              ID of the gNB, default 0
        :param du_id:               DU ID (Distributed Unit) - related to TestLine configuration - gnbs.dus[]
        :return:                    AMIA ID 1 or 2
        """
        gnb = DeviceFactory.get_device(ssh_bts_du.format('GNB', bts_id, du_id))
        hostname = gnb.get_cmd(cmd_name='hostname')()['hostname']
        return 1 if hostname.strip() == 'fct-0a' else 2

    @load_moler_configuration_from_tl()
    def parse_rd_files(self, unzipped_path, amia_slot):
        pattern = '_{}011_part_'.format(amia_slot)
        files = self._ls_and_grep(
            device=self.unix, ls_path=unzipped_path, search_pattern=pattern)
        logging.info('FOUND FILES: {}'.format(files))
        rd_files, unzipped_path_pm_path = self._get_correct_file_with_pm(
            files=files, unzipped_path=unzipped_path)
        logging.info('RD FILES: {}'.format(rd_files))
        return self._extract_and_parse_rd_files(rd_files=rd_files, unzipped_pm_path=unzipped_path_pm_path)

    def _get_correct_file_with_pm(self, files, unzipped_path):
        """
        Sorts the list of files, unzips the files to PM directory and returns a tuple containing of list of
        unzipped files and path to the directory.
        :param files:                       List of files to be sorted and iterated over
        :param unzipped_path:               Full path of files
        :return rd_files, unzipped_pm_path: Tuple of list of unzipped files and path to PM directory
        """
        part_no = re.compile(r'part_(?P<part_no>\d+)')
        files = sorted(files, key=lambda x: int(
            re.search(part_no, x).group('part_no')), reverse=True)
        logging.info('SORTED FILES: {}'.format(files))
        unzipped_pm_path = os.path.join(unzipped_path, 'PM')
        rd_files = []
        for _file in files:
            self.unix.get_cmd(cmd_name='unzip',
                              cmd_params={
                                  'zip_file': os.path.join(unzipped_path, _file),
                                  'extract_dir': unzipped_pm_path
                              })()
            unzipped_files = self._ls_and_grep(
                device=self.unix, ls_path=unzipped_pm_path, search_pattern='RD.BTS')
            if len(unzipped_files):
                rd_files.extend(unzipped_files)
                rd_files = list(set(rd_files))
            if len(rd_files) > 1:
                break
        return rd_files, unzipped_pm_path

    def _extract_and_parse_rd_files(self, rd_files, unzipped_pm_path):
        """
        Extracts the .gz archived rd_files and returns a list of parsed xml files.
        :param rd_files:            List of RD.BTS .gz archived files
        :param unzipped_pm_path:    Path to PM directory
        :returns parsed_files:      List of parsed xml files
        """
        parsed_files = []
        for rd_file in rd_files:
            self.unix.get_cmd(cmd_name='gzip',
                              cmd_params={
                                  'file_name': '',
                                  'options': '-d {}'.format(os.path.join(unzipped_pm_path, rd_file))
                              })()
            extracted_file = os.path.join(
                unzipped_pm_path, rd_file.rsplit('.gz')[0])
            parsed_files.append(ET.parse(extracted_file))
        logging.info('PARSED FILES: {}'.format(parsed_files))
        return parsed_files

    @staticmethod
    def _ls_and_grep(device, ls_path, search_pattern):
        """
        Performs ls command at the device and grep files by the pattern.
        :param device:          Device where to perform command
        :param ls_path:         Path for ls command
        :param search_pattern:  Pattern to grep by
        :return ret_list:       List containing grepped files
        """
        ret_list = []
        cmd_out = device.get_cmd(cmd_name='ls',
                                 cmd_params={
                                     'path': ls_path
                                 })()['files']
        for _key in cmd_out.keys():
            if search_pattern in _key:
                ret_list.append(_key)
        logging.debug('FILES AFTER LS AND GREP FOR {} DEVICE: {}'.format(
            device.name, ret_list))
        return ret_list

    @login_logout
    def check_counters_from_sfp_file_monitoring(self, parsed_files, device, boundaries, bts_id=0, du_id=0):
        """
        Checks the PM counters parameters values taken from SFP file monitoring.
        :param parsed_files:    List of parsed xml files
        :param device:          Device to check. Possible values: bbmod | rmod
        :param boundaries:      List of tuples of boundary conditions
        :param bts_id:              ID of the gNB, default 0
        :param du_id:               DU ID (Distributed Unit) - related to TestLine configuration - gnbs.dus[]
        """
        re_sfp = re.compile(r'(?P<sfp>SFP)\_R(?P<id>\-\d+)')
        device_info_dict = {}
        devices_info = self._get_device_info(
            device=device, bts_id=bts_id, du_id=du_id)
        for dev in devices_info:
            if dev['status']['usageState'] == 'Idle':
                continue
            sfps = []
            ports = dev['ports']
            for i in range(len(ports)):
                match = re.search(re_sfp, ports[i]['id']['internal'])
                if match:
                    sfps.append(
                        ''.join([match.group('sfp'), match.group('id')]))
            device_info_dict[dev['id']['configuration']] = sfps
        logging.debug('DEVICE INFO DICT: {}'.format(device_info_dict))
        for parsed_file in parsed_files:
            for mod in device_info_dict.keys():
                sfp_list = device_info_dict[mod]
                for sfp in sfp_list:
                    self._verify_from_xml(
                        parsed_file=parsed_file, mod=mod, sfp=sfp, boundaries=boundaries)

    def _verify_from_xml(self, parsed_file, mod, sfp, boundaries):
        """
        Performs test of parameters based on boundaries
        :param parsedfile:        XML parsed file to test
        :param mod:               Name of device with ID, eg. BBMOD-1
        :param sfp:               SFP string with ID, eg. SFP-1
        :param boundaries:        List of tuples of boundary conditions
        """
        logging.info('PARSING FILE: {}'.format(parsed_file))
        parameter_names = ['TEMPERATURE', 'XCVR_TX_SUPPLY_VOLTAGE', 'XCVR_TX_BIAS_CURRENT',
                           'XCVR_TX_PWR', 'XCVR_RX_OPT_PWR']
        measurement_type = 'SFPBM' if 'BBMOD' in mod else 'SFPRM'
        parameter_names = ['_'.join([measurement_type, param_name])
                           for param_name in parameter_names]
        xpath = './/*[DN="PLMN-PLMN/{}/{}"]..//*[@measurementType="{}"]/{}'.format(
            mod, sfp, measurement_type, '{}')
        root = parsed_file.getroot()
        for param_name, boundary in zip(parameter_names, boundaries):
            logging.info('XPATH: {}'.format(xpath.format(param_name)))
            parameter = root.find(xpath.format(param_name))
            if parameter is not None:
                parameter = float(parameter.text)
                self._perform_test_of_parameter(
                    parameter=parameter, param_name=param_name, boundary=boundary)

    @login_logout
    def _get_device_info(self, device, bts_id=0, du_id=0):
        connection = self.rest_alias.format(bts_id, du_id)
        hw_info = self.admin.get_detected_hw_info(connection=connection)
        return hw_info['basebandModules'] if device == 'bbmod' else hw_info['radioModules']['rmod']
