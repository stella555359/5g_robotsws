"""
:modified:02.07.2025

:author: Mateusz Kawka
:maintainer: Mateusz Kawka
:contact: mateusz.kawka@nokia.com
"""
from robot.api import logger
import radio_variables as variables
import re
import json
import time
from tabulate import tabulate
from datetime import datetime
import FrmonInterface as frmon_interface
from RadioBaseConnection import RadioBaseConnection
from CloudRanConnection import CloudRanConnection
from exceptions import NotSupportedAntennaLineType, NotSupportedRadioUnit, NotFoundCustomMapping, CannotReadDAPDPower, \
    WrongAntennaMappingDAPD, ProcessIdNotFound, TooManyMatchingProcesses, SCPFileTransferFailure, \
    RadioModulePingTimeExceeded, CannotReadSfpInfoFromRu, RfLogsNotFound, RfLogsCoverageNotSupported, \
    TempOffsetSensorNotFound


class RadioInterface(RadioBaseConnection, CloudRanConnection):
    def __init__(self, FrmonInterface=None):
        super(RadioInterface, self).__init__()
        if FrmonInterface is None:
            FrmonInterface = frmon_interface.FrmonInterface(RadioInterface=self)
        self.frmon = FrmonInterface
        self.ru_serial_number = None
        self.ru_name = None
        self.ru_ip = None
        self.smod_ip = None
        self.smod_name = None
        self.tl_type = None
        self.pod_name = None
        self.name_space = None
        self.dir_for_file = None

    def get_antenna_lines_for_radio_module(self, ru_name, direction, type_of_ant='physical'):
        """
        KW returns antenna mapping for given product name and direction.
        Product name must be declared in RADIO_MODULES.
        Direction is TX or RX.
        Type of antenna lines:
        -> physical - returns antenna lines from ANTENNA_MAPPING without conversion, e.g. TXs AHFIG
        Dictionary: ([1, 2], [3, 4])
        Return: {'1NAHKA': [1, 2], '2NAHKA': [3, 4]}
        -> virtual - returns converted antenna lines for DAPD, e.g. TXs ARGA:
        Dictionary: ([1, 2, 3, 4], [5, 6])
        Return: {'1NAHKA': [1a, 2a, 3a, 4a], '2NAHKA': [5a, 6a]}
        -> frmon - returns converted antenna lines for FRMON, e.g. TXs AHPCDB
        Dictionary: [1, 3]
        Return: {'1NAHKA': [1,2,3,7,8,9]}
        """
        mapping = None
        ru_group = None
        ant_mapping = {}

        direction = direction.upper()
        if type_of_ant not in ['physical', 'virtual', 'frmon']:
            raise NotSupportedAntennaLineType(type_of_ant)

        if (ru_name in variables.CUSTOM_MAPPING) and (type_of_ant == 'frmon' or type_of_ant == 'virtual'):
            return self._get_custom_antenna_mapping(ru_name, type_of_ant, direction)

        for ru_class, ru_list in variables.RADIO_MODULES.items():
            if ru_name in ru_list:
                ru_group = ru_class
                txrx_mapping = variables.ANTENNA_MAPPING[ru_group]
                if direction == 'TX':
                    mapping = txrx_mapping['TX']
                elif direction == 'RX':
                    mapping = txrx_mapping['RX']

        if mapping:
            logger.debug(f"Found mapping for {direction}s {ru_name} -> {mapping}")
        else:
            raise NotSupportedRadioUnit(ru_name)

        if type_of_ant == 'frmon':
            if '1NAHKA' in ru_group or '1MADE' in ru_group:
                mapping = self.frmon.frmon_get_virtual_antenna_lines_for_radio(ru_group, mapping)
            elif '2MADE' in ru_group or '2NAHKA' in ru_group:
                mapping_1_soc = self.frmon.frmon_get_virtual_antenna_lines_for_radio(ru_group, mapping[0])
                mapping_2_soc = self.frmon.frmon_get_virtual_antenna_lines_for_radio(ru_group, mapping[1])
                mapping = (mapping_1_soc, mapping_2_soc)
        elif type_of_ant == 'virtual':
            if '1NAHKA' in ru_group or '1MADE' in ru_group:
                mapping = self.dapd_get_virtual_antenna_lines_for_ru(ru_group, mapping)
            elif '2MADE' in ru_group or '2NAHKA' in ru_group:
                mapping_1_soc = self.dapd_get_virtual_antenna_lines_for_ru(ru_group, mapping[0])
                mapping_2_soc = self.dapd_get_virtual_antenna_lines_for_ru(ru_group, mapping[1])
                mapping = (mapping_1_soc, mapping_2_soc)

        if '2NAHKA' in ru_group:
            ant_mapping['1NAHKA'] = mapping[0]
            ant_mapping['2NAHKA'] = mapping[1]
        elif '2MADE' in ru_group:
            ant_mapping['1MADE'] = mapping[0]
            ant_mapping['2MADE'] = mapping[1]
        elif '1NAHKA' in ru_group:
            ant_mapping['1NAHKA'] = mapping
        elif '1MADE' in ru_group:
            ant_mapping['1MADE'] = mapping
        else:
            ant_mapping = mapping

        logger.debug(ant_mapping)
        return ant_mapping

    @staticmethod
    def _get_custom_antenna_mapping(ru_name, type_of_ant, direction):

        ru_mapping = variables.CUSTOM_MAPPING.get(ru_name)
        for direct, mapping in ru_mapping.items():
            if direction in direct:
                if type_of_ant.lower() == 'frmon':
                    ru_mapping = mapping.get('FRMON')
                else:
                    ru_mapping = mapping.get('DAPD')
            else:
                raise NotFoundCustomMapping(direction, ru_name)

        temp_dict = {}
        for nahka, mapping in ru_mapping.items():
            maps = list(mapping.values())
            maps = [item for sublist in maps for item in sublist]
            temp_dict[nahka] = maps

        return temp_dict

    @staticmethod
    def get_bands_number(ru_name):

        ru_class = next((ru_class for ru_class, ru_list in variables.RADIO_MODULES.items() if ru_name in ru_list),
                        None)

        if ru_class is None:
            raise NotSupportedRadioUnit(ru_name)

        ru_group_split = ru_class.split('_')
        return re.findall(r'\d+', ru_group_split[-1])[0]

    @staticmethod
    def get_radio_family(ru_name):

        ru_family = ([k for k, v in variables.RADIO_MODULES.items() if ru_name in v])

        if len(ru_family) == 0:
            raise NotSupportedRadioUnit(ru_name)

        return ru_family[0].rsplit('_', 3)[0].replace('_', '.', 1)

    @staticmethod
    def _get_nr_frequency_by_nrarfcn(nrarfcn):
        if 0 < nrarfcn < 599000:
            delta_f_global = 5000
            f_ref_offset = 0
            n_ref_offset = 0
        elif 600000 < nrarfcn < 2016666:
            delta_f_global = 15000
            f_ref_offset = 3000000000
            n_ref_offset = 600000
        elif 2016667 < nrarfcn < 3279167:
            delta_f_global = 60000
            f_ref_offset = 24250000000
            n_ref_offset = 2016667
        else:
            raise Exception(f"Wrong NRARFCN value: {nrarfcn}")

        frequency = (f_ref_offset + delta_f_global * (nrarfcn - n_ref_offset)) / 1000000
        return frequency

    def _classical_prepare_to_send_file_via_scp(self, direction, file_path, destination_directory, **kwargs):
        lxc_container = self.get_lxc_container()
        openssh_version = self._get_openssh_version()
        if openssh_version >= 9.0:
            legacy_parameter = '-O'
        else:
            legacy_parameter = ''

        if 'username' in kwargs and 'password' in kwargs:
            username = kwargs['username']
            passwd = kwargs['password']
        elif self.ru_name in variables.RMOD_PASSWORDS and direction.lower() == 'to_smod':
            username = variables.RMOD_PASSWORDS[self.ru_name][0]
            passwd = variables.RMOD_PASSWORDS[self.ru_name][1]
        elif self.ru_name in variables.RMOD_PASSWORDS and direction.lower() == 'to_rmod':
            username = variables.RMOD_PASSWORDS[self.ru_name][0]
            passwd = variables.RMOD_PASSWORDS[self.ru_name][1]
        else:
            username = 'root'
            passwd = None

        if direction.lower() == 'to_smod':
            download_file_cmd = f"echo 'scp {legacy_parameter} {username}@{self.ru_ip}:" \
                                f"{file_path} {destination_directory}' | lxc-attach -n {lxc_container}"
        elif direction.lower() == 'to_rmod':
            download_file_cmd = f"echo 'scp {legacy_parameter} {file_path} {username}@{self.ru_ip}:" \
                                f"{destination_directory}' | lxc-attach -n {lxc_container}"
        else:
            raise KeyError(f"Not supported direction for Classical TL type -> {direction}, possible: to_smod, to_rmod")

        return username, passwd, download_file_cmd

    def _cloud_prepare_to_send_file_via_scp(self, direction, file_path, destination_directory):
        # openssh_version = self._get_openssh_version()
        # if openssh_version >= 9.0:
        #     legacy_parameter = '-O'
        # else:
        #     legacy_parameter = ''
        legacy_parameter = '-O'

        if self.ru_name in variables.RMOD_PASSWORDS:
            username = variables.RMOD_PASSWORDS[self.ru_name][0]
            passwd = variables.RMOD_PASSWORDS[self.ru_name][1]
        else:
            username = 'root'
            passwd = None

        if direction.lower() == 'to_container':
            download_file_cmd = f"kubectl exec -it -n cran1 {self.pod_name}-oamfh-0 -c ctr{self.name_space}-oamfh -- " \
                                f"scp -o BindAddress={self.ctr_src_ip} {legacy_parameter} {username}@{self.ru_ip}:" \
                                f"{file_path} {destination_directory}"
        elif direction.lower() == 'to_rmod':
            download_file_cmd = f"kubectl exec -it -n cran1 {self.pod_name}-oamfh-0 -c ctr{self.name_space}-oamfh -- " \
                                f"scp -o BindAddress={self.ctr_src_ip} {legacy_parameter} {file_path} " \
                                f"{username}@{self.ru_ip}:{destination_directory}"
        else:
            raise KeyError(f"Not supported direction for CloudRAN TL type -> {direction}, "
                           "possible: to_container, to_rmod")

        return username, passwd, download_file_cmd

    def _send_file_via_scp(self, direction, file_path, destination_directory, **kwargs):
        if self.tl_type == 'CloudRAN':
            username, passwd, download_file_cmd = \
                self._cloud_prepare_to_send_file_via_scp(direction, file_path, destination_directory)
        elif self.tl_type == 'Classical':
            username, passwd, download_file_cmd = \
                self._classical_prepare_to_send_file_via_scp(direction, file_path, destination_directory, **kwargs)
        else:
            raise Exception(f"Unknown TL type: {self.tl_type}")

        file_name = file_path.split('/')[-1]
        if username == 'serviceuser':
            self._send_command(f"sudo chown serviceuser /ram/{file_name}")

        new_shell = self.client.invoke_shell()
        new_shell.sendall(download_file_cmd + '\r')
        logger.info(f"Sent command:\n{download_file_cmd}\r")
        time.sleep(1)
        transfer_pass = False

        max_time = time.time() + 15
        while time.time() < max_time:
            if new_shell.recv_ready():
                output = new_shell.recv(9999).decode('ascii')
                if bool(re.search('fingerprint', output.replace(' ', ''))):
                    logger.info(f"Output from terminal:\n{output}")
                    logger.info(f"Sent command:\nyes\r")
                    new_shell.sendall('yes\r')
                if bool(re.search('[pP]assword', output.replace(' ', ''))):
                    logger.info(f"Output from terminal:\n{output}")
                    logger.info(f"Sent command:\n{passwd}\r")
                    new_shell.sendall(passwd + '\r')
                if '100%' in output:
                    logger.info(f"Output from terminal:\n{output}")
                    transfer_pass = True
                    break
            time.sleep(0.5)

        if username == 'serviceuser':
            self._send_command(f"sudo chown rfsw /ram/{file_name}")
            self._send_command('sudo su - rfsw')
            self._read_until_prompt('#|$')

        if transfer_pass:
            logger.info(f"SCP sending file: {file_path} to {destination_directory} "
                        f"on {direction.split('_')[-1]} completed!")
        else:
            logger.debug(output)
            raise SCPFileTransferFailure(file_path, destination_directory)

    def _get_openssh_version(self):
        cmd = 'ssh -V'
        stdin, stdout, stderr = self.client.exec_command(cmd, get_pty=True)
        openssh_raw = stdout.read().decode()
        openssh_ver = re.search(r'\d+\.\d+', openssh_raw).group()

        logger.debug(f'OpenSSH version: {openssh_ver}')

        return float(openssh_ver)

    def _get_module_temp_on_ru(self, sensor_name):
        self._prepare_logs_file_for_sensor(sensor_name)

        self._send_file_via_scp_from_radio_module('/ram/radio_op_temperatures.txt')

        sftp = self.client.open_sftp()
        with sftp.open(f"/{self.dir_for_file}/radio_op_temperatures.txt", "r") as f:
            for num, line in enumerate(f, 1):
                if num == 1:
                    headers = line.split()[1:-3]
                    sensor_index = headers.index(sensor_name)
                else:
                    numbers = re.findall(r'-?\d+\(-?\d+\)|-?\d+', line)
                    values = [temp.split('(')[0] for temp in numbers]

        module_temp_dict = dict(zip(headers, values))
        logger.debug(f'Dictionary with modules and temperature values:\n{module_temp_dict}')
        sensor_temp = values[sensor_index]
        logger.info(f'Sensor: {sensor_name} with temperature: {sensor_temp}')

        self._cleanup_file('radio_op_temperatures.txt')

        return sensor_temp

    def _prepare_logs_file_for_sensor(self, sensor_name):

        for attempt in range(20):
            logger.debug(f"Looking for temperatures logs - attempt {attempt}")
            self._send_command('cat /var/log/aasyslog/runtime_DEFAULT_CB.bin /var/log/aasyslog/runtime_DEFAULT.bin '
                               '/var/log/runtime.log '
                               f'| strings | grep TEMPTRACE | tail -6 | grep -A1 "{sensor_name}" '
                               '| sed "s/.*TEMPTRACE/TEMPTRACE/" > '
                               '/ram/radio_op_temperatures.txt')
            self._read_until_prompt('$|#')
            self._send_command('cat /ram/radio_op_temperatures.txt')
            output = self._read_until_prompt('$|#')
            if sensor_name in output:
                break
            time.sleep(5)
        else:
            raise RfLogsNotFound()

    def _reboot_ru(self):
        # regex \$\s*$ matches the prompt after reboot RF8
        check_reboot_pattern = re.compile(r"The system is going down for reboot NOW!|\$\s*$|"
                                          r"Interactive authentication required|send disconnect|closed by remote host")
        self._send_command('sudo systemctl reboot -i')
        output = self._read_output(delay=15)
        if check_reboot_pattern.search(output):
            logger.info("RU reboot done !")
        else:
            logger.info("First RU reboot may not have been performed. Retrying...")
            self._send_command('/sbin/reboot')
            output = self._read_output(delay=15)
            if check_reboot_pattern.search(output):
                logger.info("RU reboot done !")
            else:
                logger.warn("Reboot retried twice and may not have been performed !")

    def _send_file_via_scp_from_radio_module(self, file_path):
        file_name = file_path.split('/')[-1]
        if self.tl_type == 'CloudRAN':
            dir_for_file = 'tmp'
            self._send_file_via_scp(
                direction='to_container',
                file_path=file_path,
                destination_directory=f'/{dir_for_file}')
            cp_cmd = f'kubectl cp -n cran1 {self.pod_name}-oamfh-0:/tmp/{file_name} ' \
                     f'/tmp/{file_name} -c ctr{self.name_space}-oamfh'
            logger.debug(f'Sending command: {cp_cmd}')
            stdin, stdout, stderr = self.client.exec_command(cp_cmd)
            logger.debug(f"Stdout from cmd: {stdout.read().decode()}")
            logger.debug(f"Stderr from cmd: {stderr.read().decode()}")

        else:
            dir_for_file = 'ram'
            self._send_file_via_scp(
                direction='to_smod',
                file_path=f'{file_path}',
                destination_directory=f'/{dir_for_file}')

    def _download_tcs_file(self):

        tcs_name = self._get_name_of_tcs_file()

        frmon_cmd = '/ action create ConfigAccess /radio_op /module\n' \
                    f'/radio_op action fetch DECODED "{tcs_name}.bin" "/ram/tcs_default.json"'
        self._send_command(f"echo $'{frmon_cmd}' | frmonShellClient localhost 2000")
        self._read_until_regexp('closed')

        self._send_file_via_scp_from_radio_module('/ram/tcs_default.json')

        sftp = self.client.open_sftp()
        with sftp.open(f"/{self.dir_for_file}/tcs_default.json", "r") as tcs_file:
            json_file = json.load(tcs_file)['tcs']

        self._cleanup_file('tcs_default.json')

        return json_file

    def _get_name_of_tcs_file(self):
        cmd = 'ls /run/coma/type | grep tcs | grep -v tcs_faults'
        self._send_command(cmd)
        output = self._read_until_prompt('$|#')
        tcs_name = 'tcs_parameters' if 'tcs_parameters' in output else 'tcs'
        logger.debug(f"Name of TCS file: {tcs_name}")
        return tcs_name

    def _get_decoded_binary_file(self, filename):

        frmon_cmd = '/ action create ConfigAccess /radio_op /module\n' \
                    f'/radio_op action fetch DECODED "{filename}.bin" "/ram/{filename.split("/")[-1]}.json"'
        self._send_command(f"echo $'{frmon_cmd}' | frmonShellClient localhost 2000")
        self._read_until_regexp('closed')

        self._send_file_via_scp_from_radio_module(f"/ram/{filename.split('/')[-1]}.json")

        sftp = self.client.open_sftp()
        with sftp.open(f"/{self.dir_for_file}/{filename.split('/')[-1]}.json", "r") as binary_file:
            json_file = json.load(binary_file)

        self._cleanup_file(f"{filename.split('/')[-1]}.json")

        return json_file

    def _get_temperature_offset_for_sensor_name(self, sensor_name):
        json_file_content = self._get_decoded_binary_file('tempest_inst1')
        pretty_json = json.dumps(json_file_content, indent=4, ensure_ascii=False)
        logger.debug(f"Content of tempest_inst1.json: {pretty_json}")

        for sensor in json_file_content['tempSensorHwInfo']:
            if sensor['sensorName'] == sensor_name:
                logger.info(f"Temperature offset for sensor: {sensor_name} is: {sensor['tempOffset']}")
                return float(sensor['tempOffset'])
        else:
            raise TempOffsetSensorNotFound(sensor_name)

    def _get_tx_dapd_power(self, ru_name, print_table=True):
        antennas = self.get_antenna_lines_for_radio_module(ru_name, direction='TX', type_of_ant='virtual')
        ru_family = self.get_radio_family(ru_name)
        if ru_family == '6.1':
            logger.info("RU family 6.1 -> Connecting to first SoC via 192.168.101.2")
            self._send_command('ssh 192.168.101.2')
            self._read_until_prompt('$')
            logger.info('Connected to SoC 192.168.101.2')

        antennas = antennas.values()
        dapd_power_dict = dict()
        counter = 1
        for antenna in antennas:
            if counter == 2:
                self._read_output()
                logger.info("Connecting to second SoC via 192.168.101.3...")
                self._send_command('ssh 192.168.101.3')
                output = self._read_until_regexp('fingerprint|Node2')
                if 'fingerprint' in output:
                    logger.info("Found fingerprint, adding key to .known_hosts file")
                    self._send_command('y', delay=1)
                    self._read_until_regexp('Node2')
                logger.info('Connected to SoC 192.168.101.3')
            try:
                single_soc_power_dict = self._get_single_soc_dapd_power(antenna)
                dapd_power_dict.update(single_soc_power_dict)
            except Exception:
                raise CannotReadDAPDPower(ru_name)
            counter += 1

        if print_table:
            self._dapd_print_table_with_power(ru_name, dapd_power_dict)

        logger.info(dapd_power_dict)
        self.disconnect()
        return dapd_power_dict

    def _get_single_soc_dapd_power(self, antennas):

        temp_power_dict = dict()
        for antenna in antennas:
            self._send_command(f'dapd -vstat antenna{antenna}', delay=1)
            otp = self._read_until_prompt('#|$')
            if 'Fail' in otp:
                raise WrongAntennaMappingDAPD
            power = re.search(r'(?<=forwardPower = )\d+.\d+|-inf', otp).group(0)
            if 'inf' in power or '0.00' in power:
                temp_power_dict['ant' + antenna] = 'OFF'
            else:
                temp_power_dict['ant' + antenna] = float(power)

        return temp_power_dict

    @staticmethod
    def _dapd_print_table_with_power(ru_name, power_dict):

        values_count = len([x for x in power_dict.values() if x != 'OFF'])
        if values_count != 0:
            new_tb = tabulate(power_dict.items(), headers=["TX", "Power"], tablefmt="fancy_grid")
            logger.info(new_tb, also_console=True)
        else:
            logger.info("No power on any TX antenna line for RU: {}".
                        format(ru_name), also_console=True)

    @staticmethod
    def dapd_get_virtual_antenna_lines_for_ru(ru_group, ant_mapping):

        band = ru_group.split('_')[-1]
        band = re.findall(r'\d+', band)[0]
        logger.info(f"Number of bands for RU: {band}")

        virtual_ant_mapping = []
        for ant in ant_mapping:
            if band == '1':
                ant = str(ant) + 'a'
                virtual_ant_mapping.append(ant)
            elif band == '2':
                ant1 = str(ant) + 'a'
                ant2 = str(ant) + 'b'
                virtual_ant_mapping.extend([ant1, ant2])
            elif band == '3':
                ant1 = str(ant) + 'a'
                ant2 = str(ant) + 'b'
                ant3 = str(ant) + 'c'
                virtual_ant_mapping.extend([ant1, ant2, ant3])

        logger.info(f"Virtual mapping for DAPD:{virtual_ant_mapping}")
        return virtual_ant_mapping

    def _kill_process_on_radio_module(self, process_name, ru_family):
        if float(ru_family) >= 8:
            self._send_command(f'ps aux | grep {process_name} | grep -v grep')
        else:
            self._send_command(f'ps | grep {process_name} | grep -v grep')
        output = self._read_until_prompt('#|$').split('\r\r\n')
        process_id = None
        list_of_process_ids = list()
        for line in output:
            if process_name in line and '/' in line:
                process_id = re.search(r'\d+', line).group()
                list_of_process_ids.append(process_id)

        if process_id is None:
            raise ProcessIdNotFound(process_name)
        elif len(list_of_process_ids) > 1:
            raise TooManyMatchingProcesses(process_name)
        else:
            self._send_command(f'sudo kill -11 {process_id}', delay=2)
            logger.info(f"Process {process_name} with ID {process_id} killed, RU is going to reboot !")

    def _check_radio_module_ping(self, ru_ip, timeout, expect_ping):
        if expect_ping:
            is_ping = False
        else:
            is_ping = True

        if self.tl_type == 'CloudRAN':
            cmd = f"kubectl exec -it -n cran1 {self.pod_name}-oamfh-0 -c ctr{self.name_space}-oamfh -- " \
                  f"ping -c 1 {ru_ip}"
        else:
            container = self.get_lxc_container()
            cmd = f"""echo $"ping -c 1 {ru_ip}" | lxc-attach -n {container} """

        max_time = time.time() + int(timeout)
        while time.time() < max_time:
            stdin, stdout, stderr = \
                self.client.exec_command(cmd)
            ping_rc = stdout.channel.recv_exit_status()
            if ping_rc == 0 and expect_ping:
                logger.info(f"Ping status for host {ru_ip} is True")
                time.sleep(2)
                return
            elif ping_rc == 0 and not expect_ping:
                logger.debug("Still waiting for ping RC: 1 ")
                time.sleep(5)
            elif ping_rc == 1 and not expect_ping:
                logger.info(f"Ping status for host {ru_ip} is False")
                return
            else:
                logger.debug("Still waiting for ping RC: 0")
                time.sleep(5)

        if is_ping != expect_ping:
            raise RadioModulePingTimeExceeded(self.ru_name, self.ru_ip, expect_ping, timeout)

    def _wait_for_radio_module_not_pingable(self, ru_ip, timeout):
        self._check_radio_module_ping(ru_ip, timeout, expect_ping=False)

    def _wait_for_radio_module_pingable(self, ru_ip, timeout):
        self._check_radio_module_ping(ru_ip, timeout, expect_ping=True)

    def _override_crc32_hash_in_integrity_file(self, new_value):

        self._send_command('ls /mnt/runtime/swman | grep integrity_slot')
        swman_output = self._read_until_prompt('#|$')

        slots_no = re.findall(r'integrity_slot(\d+)', swman_output)
        logger.debug(f"SWman integrity slots {slots_no} will be overrided")

        current_value_dict = dict()
        for slot_no in slots_no:
            current_value = self._override_crc32_hash_in_integrity_file_single_slot(slot_no, new_value)
            current_value_dict[slot_no] = current_value

        logger.info(f"Current values in integrity slots: {current_value_dict}")
        return current_value_dict

    def _override_crc32_hash_in_integrity_file_single_slot(self, slot_no, new_value):
        self._send_file_via_scp(
            direction='to_smod',
            file_path=f'/mnt/runtime/swman/swman-integrity_slot{slot_no}.json',
            destination_directory='/ram')

        sftp = self.client.open_sftp()
        with sftp.open(f"/ram/swman-integrity_slot{slot_no}.json", "r") as swman_file:
            data = json.load(swman_file)

        current_value = data['entries'][0]['checksums'][0]['digest']

        data['entries'][0]['checksums'][0]['digest'] = new_value[slot_no]

        with sftp.open(f"/ram/swman-integrity_slot{slot_no}.json", 'w') as swman_file:
            json.dump(data, swman_file, indent=4)

        self._send_file_via_scp(
            direction='to_rmod', file_path=f'/ram/swman-integrity_slot{slot_no}.json',
            destination_directory='/mnt/runtime/swman/')

        logger.info(f"Current value: {current_value} was replaced by new value: {new_value[slot_no]} "
                    f"in file swman-integrity_slot{slot_no}.json")

        self._cleanup_file(f'swman-integrity_slot{slot_no}.json')

        return current_value

    def _get_sfp_info_from_radio_module(self, sfp_id):
        """
        Method for retrieving information about a specific SFP (Small Form-factor Pluggable) from the radio module.

        Args:
            sfp_id (str): The identifier of the SFP to retrieve information about.

        Returns:
            dict: A dictionary containing key-value pairs of the SFP information.

        Raises:
            CannotReadSfpInfoFromRu: If the method fails to read the SFP information from the radio unit.

        Note:
            The method sends a command to the radio module and waits for a response.
            The response is then parsed and the relevant information is extracted and returned as a dictionary.
        """

        frmon_cmd = '/ action create SfpInfo /radio_op_sfp\n' \
                    f'/radio_op_sfp action read_info {sfp_id}'
        self._send_command(f"echo $'{frmon_cmd}' | frmonShellClient localhost 2000")
        sfp_output = self._read_until_regexp('closed')

        result = re.search(r'done ok(.*?)connection closed', sfp_output, re.DOTALL)
        if result:
            extracted_string = result.group(1).strip()
        else:
            raise CannotReadSfpInfoFromRu(sfp_id)

        split_string = extracted_string.split()
        result_dict = dict()

        for i in range(0, len(split_string), 2):
            value = split_string[i + 1].strip('"')
            key = split_string[i].title()
            result_dict[key] = value

        logger.debug(result_dict)

        return result_dict

    def _change_fail_safe_mode(self, state):
        """
        Change the fail-safe mode based on the provided state.

        Args:
            state (str): The state to be set ('enable' or 'disable').
        Raises:
            Exception: If fail-safe mode cannot be changed successfully.
        """
        frmon_cmd = '/ action create ResetControl /CI/ResetControl/module /module\n' \
                    f'/CI/ResetControl/module action {state}_fail_safe_mode'
        self._send_command(f"echo $'{frmon_cmd}' | frmonShellClient localhost 2000")
        self._read_until_regexp('done ok')

    def _enable_fail_safe_mode(self, radio_reset):
        """
        Enable fail-safe mode.

        Calls _change_fail_safe_mode('enable').
        """
        self._change_fail_safe_mode(state='enable')
        if radio_reset:
            self._reboot_ru()

    def _disable_fail_safe_mode(self, radio_reset):
        """
        Disable fail-safe mode.

        Calls _change_fail_safe_mode('disable').
        """
        self._change_fail_safe_mode(state='disable')
        if radio_reset:
            self._reboot_ru()

    def _get_fail_safe_mode_status(self):
        """
        Retrieves the status of fail-safe mode on RU.

        This method sends a command to retrieve the fail-safe mode status on a Radio Module (RU).
        It constructs the command to be sent using FRMON shell client and extracts the status from the output.

        Returns:
            str: The status of fail-safe mode, either 'Enabled' or 'Disabled'.

        Raises:
            Exception: If fail-safe mode status extraction fails or if communication with FRMON fails.
        """
        frmon_cmd = '/ action create ResetControl /CI/ResetControl/module /module\n' \
                    '/CI/ResetControl/module get fail_safe_mode'
        self._send_command(f"echo $'{frmon_cmd}' | frmonShellClient localhost 2000")
        output = self._read_until_regexp('done ok')
        status = re.search(r'fail_safe_mode ==> done ok (\w+)', output).group(1).capitalize()
        logger.info(f'Fail-safe mode on RU status: {status}')

        return status

    def _collect_radio_module_snapshot(self, coverage):
        """
        Method for collecting snapshots from the radio module.

        Args:
            coverage (str): Specifies the range of logs to collect. Can take values 'Full' or 'Minor'.

        Returns:
            str: The name of the zip file containing the collected logs. The file name now includes the coverage type.

        Raises:
            RfLogsCoverageNotSupported: If the given coverage is not supported (other than 'Full' or 'Minor').

        Note:
            The method sends a command to the radio module and waits for a response.
            The response waiting time is 20 seconds.

        Example:
            _collect_radio_module_snapshot('Full') returns 'LOGS_Full_{self.ru_serial_number}_{timestamp}.zip'
        """
        timestamp = datetime.now().strftime("%d%m%y_%H%M")

        if coverage == 'Full':
            cmd = f'log -a -z LOGS_{coverage}_{self.ru_serial_number}_{timestamp}.zip'
        elif coverage == 'Minor':
            cmd = f'log -a -c minor -z LOGS_{coverage}_{self.ru_serial_number}_{timestamp}.zip'
        else:
            raise RfLogsCoverageNotSupported(coverage)

        self._send_command(cmd)
        self._read_until_prompt('#|$|>', timeout=120)

        return f'LOGS_{coverage}_{self.ru_serial_number}_{timestamp}.zip'

    def _enable_root_account_on_fhs(self):
        """
        This method enables the root account on FHS modules.

        It checks if the 'ru_name' attribute is 'MDEA'.
        If so, it sends a series of commands to enable the root account,
        including sending the username and password, setting a flag in the system configuration
        and rebooting the system.

        If the 'ru_name' attribute is not 'MDEA', it raises a KeyError indicating
        that this method only works with FHS modules.

        Raises:
            KeyError: If the 'ru_name' attribute is not 'MDEA', indicating that this method only works with FHS modules.

        """
        if self.ru_name in ['MDEA']:
            self._send_command(f'su {variables.username}')
            self._read_until_regexp('[Pp]assword')
            self._send_command(variables.password)
            self._read_until_prompt('#')
            self._send_command('echo 1 > /ffs/run/etc/ciflag')
            self._reboot_ru()
        else:
            raise KeyError(f'Keyword works only with FHS modules!')

    def _disable_root_account_on_fhs(self):
        """
        This method disables the root account on FHS modules.

        It checks if the 'ru_name' attribute is 'MDEA'.
        If so, it sends a command to disable the root account and reboot radio module.

        If the 'ru_name' attribute is not 'MDEA', it raises a KeyError indicating
        that this method only works with FHS modules.

        Raises:
            KeyError: If the 'ru_name' attribute is not 'MDEA', indicating that this method only works with FHS modules.

        """
        if self.ru_name in ['MDEA']:
            self._send_command('rm /ffs/run/etc/ciflag')
            self._read_until_prompt('#')
            self._reboot_ru()
        else:
            raise KeyError(f'Keyword works only with FHS modules!')

    def _reboot_and_wait_for_ping(self, reconnect_timeout, ping_down_timeout):
        """
        Reboots the radio module and waits for it to become pingable again.

        This method performs the following steps:
        1. Initiates a reboot of the radio module.
        2. Waits for the radio module to become non-pingable, indicating it has shut down.
        3. Waits for the radio module to become pingable again, indicating it has rebooted.
        4. Waits an additional 30 seconds to allow the radio module to complete its initialization.

        Parameters:
        reconnect_timeout (int): The maximum time (in seconds) to wait for the radio module
                                 to become pingable after rebooting.
        ping_down_timeout (int, optional): The maximum time (in seconds) to wait for the radio module
                                           to become non-pingable after initiating the reboot. Default is 60 seconds.
        """
        self._reboot_ru()
        logger.info(f"Waiting up to {ping_down_timeout}s to radio module down!")
        self._wait_for_radio_module_not_pingable(self.ru_ip, ping_down_timeout)
        logger.info(f"Waiting up to {reconnect_timeout}sec for radio module reconnection after reboot !")
        self._wait_for_radio_module_pingable(self.ru_ip, timeout=reconnect_timeout)
        logger.info("Waiting 30s for radio module to complete initialization !")
        time.sleep(30)

    def _cloud_file_cleanup(self, file_path):
        """
        Removes a specified file from a Cloud VM and an OAM container.

        This method attempts to remove a file from a Cloud VM by executing a command
        to delete the file at the given file path. If the file removal is successful,
        it logs a success message. It then proceeds to remove the same file from an
        OAM container using a Kubernetes command. If the file removal from the container
        is successful, it logs another success message.

        Args:
            file_path (str): The path of the file to be removed.

        Returns:
            None
        """
        container_rm_cmd = f"kubectl exec -it -n cran1 po-cran1-oamfh-0 -c ctr-cran1-oamfh -- rm -f {file_path}"
        stdin, stdout, stderr = self.client.exec_command(f'rm -f {file_path}')
        if stdout.channel.recv_exit_status() == 0:
            logger.info(f"File {file_path} removed successfully from Cloud VM!")
        stdin, stdout, stderr = self.client.exec_command(container_rm_cmd)
        if stdout.channel.recv_exit_status() == 0:
            logger.info(f"File {file_path} removed successfully from OAM container!")

    def _smod_file_cleanup(self, file_path):
        """
        Removes a specified file from an SMOD.

        This method attempts to remove a file from an SMOD by executing a command
        to delete the file at the given file path. If the file removal is successful,
        it logs a success message. Otherwise, it logs a failure message.

        Args:
            file_path (str): The path of the file to be removed.

        Returns:
            None
        """
        stdin, stdout, stderr = self.client.exec_command(f'rm -f {file_path}')
        if stdout.channel.recv_exit_status() == 0:
            logger.info(f"File {file_path} removed successfully from SMOD!")
        else:
            logger.info(f"Failed to remove file {file_path} from SMOD!")

    def _cleanup_file(self, filename):
        """
        Cleans up a specified file based on the type of the system (CloudRAN or SMOD).

        This method determines the type of the system (CloudRAN or SMOD) and calls
        the appropriate file cleanup method. If the system type is 'CloudRAN', it
        attempts to remove the file from the Cloud VM and OAM container. If the system
        type is not 'CloudRAN', it attempts to remove the file from the SMOD.

        Args:
            filename (str): The name of the file to be removed.

        Returns:
            None
        """
        if self.tl_type == 'CloudRAN':
            self._cloud_file_cleanup(f'/tmp/{filename}')
        else:
            self._smod_file_cleanup(f'/ram/{filename}')

    def _get_sensors_temperature_from_rf_logs(self):
        """
        Retrieves the temperature values of sensors from RF logs.

        This method performs the following steps:
        1. Prepares the logs file for the sensor named 'MODULE'.
        2. Sends the logs file from the radio module via SCP.
        3. Opens the logs file and reads the temperature values.
        4. Parses the temperature values and stores them in a dictionary.

        Returns:
            dict: A dictionary with module names as keys and their corresponding temperature values as values.

            Raises:
        Exception: If there is an issue with reading or parsing the logs file.
        """
        self._prepare_logs_file_for_sensor('MODULE')

        self._send_file_via_scp_from_radio_module('/ram/radio_op_temperatures.txt')

        sftp = self.client.open_sftp()
        with sftp.open(f"/{self.dir_for_file}/radio_op_temperatures.txt", "r") as f:
            for num, line in enumerate(f, 1):
                if num == 1:
                    headers = line.split()[1:-3]
                else:
                    numbers = re.findall(r'-?\d+\(-?\d+\)|-?\d+', line)
                    values = [temp.split('(')[0] for temp in numbers]

        module_temp_dict = dict(zip(headers, values))
        logger.debug(f'Dictionary with modules and temperature values:\n{module_temp_dict}')

        return module_temp_dict
