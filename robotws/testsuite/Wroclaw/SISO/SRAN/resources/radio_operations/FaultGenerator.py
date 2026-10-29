"""
:modified:20.03.2025

:author: Mateusz Kawka
:maintainer: Mateusz Kawka
:contact: mateusz.kawka@nokia.com
"""
from RadioInterface import RadioInterface
from robot.api import logger
import radio_variables as variables
import json
from exceptions import FaultNotSupported, FaultSensorNotDefined, KeyNotFoundInBinaryFile, \
    CalibrationDlPathFileNotFound, NotSupportedFaultSeverity, NotMatchPipeSensor, SfpOverrideFailed


class FaultGenerator(RadioInterface):
    def __init__(self):
        super(FaultGenerator, self).__init__()
        self.ru_ip = None
        self.ru_name = None
        self.ru_serial_number = None
        self.remote_host = None

    def _generate_fault_5_1(self, fault_id, **kwargs):

        logger.info(f"Generating fault {fault_id} for radio module {self.ru_name} from 5.1 family")

        if fault_id not in variables.SUPPORTED_FAULTS['5_1']:
            raise FaultNotSupported(fault_id)
        else:
            eval('self._generate_fault_5_1_' + fault_id)(**kwargs)

    def _generate_fault_6_1(self, fault_id, **kwargs):

        logger.info(f"Generating fault {fault_id} for radio module {self.ru_name} from 6.1 family")

        if fault_id not in variables.SUPPORTED_FAULTS['6_1']:
            raise FaultNotSupported(fault_id)
        else:
            eval('self._generate_fault_6_1_' + fault_id)(**kwargs)

    def _generate_fault_6_2(self, fault_id, **kwargs):

        logger.info(f"Generating fault {fault_id} for radio module {self.ru_name} from 6.2 family")

        if fault_id not in variables.SUPPORTED_FAULTS['6_2']:
            raise FaultNotSupported(fault_id)
        elif fault_id in '1920|1907':
            self._generate_fault_6_2_1907_1920()
        else:
            eval('self._generate_fault_6_2_' + fault_id)(**kwargs)

    def _generate_fault_8(self, fault_id, **kwargs):

        logger.info(f"Generating fault {fault_id} for radio module {self.ru_name} from RF8 family")

        if fault_id not in variables.SUPPORTED_FAULTS['8']:
            raise FaultNotSupported(fault_id)
        elif fault_id in '1920|1907':
            self._generate_fault_8_1907_1920()
        else:
            eval('self._generate_fault_8_' + fault_id)(**kwargs)

    def _recover_fault_5_1(self, fault_id, **kwargs):
        logger.info(f"Recovering fault {fault_id} for radio module {self.ru_name} from 5.1 family")

        if fault_id not in variables.SUPPORTED_FAULTS['5_1']:
            raise FaultNotSupported(fault_id)
        else:
            eval('self._recover_fault_5_1_' + fault_id)(**kwargs)

    def _recover_fault_6_1(self, fault_id, **kwargs):
        logger.info(f"Recovering fault {fault_id} for radio module {self.ru_name} from 6.1 family")

        if fault_id not in variables.SUPPORTED_FAULTS['6_1']:
            raise FaultNotSupported(fault_id)
        else:
            eval('self._recover_fault_6_1_' + fault_id)(**kwargs)

    def _recover_fault_6_2(self, fault_id, **kwargs):
        logger.info(f"Recovering fault {fault_id} for radio module {self.ru_name} from 6.2 family")

        if fault_id not in variables.SUPPORTED_FAULTS['6_2']:
            raise FaultNotSupported(fault_id)
        else:
            eval('self._recover_fault_6_2_' + fault_id)(**kwargs)

    def _recover_fault_8(self, fault_id, **kwargs):
        logger.info(f"Recovering fault {fault_id} for radio module {self.ru_name} from RF8 family")

        if fault_id not in variables.SUPPORTED_FAULTS['8']:
            raise FaultNotSupported(fault_id)
        else:
            eval('self._recover_fault_8_' + fault_id)(**kwargs)

    # ********** 5.1 FAULT GENERATE **********

    def _generate_fault_5_1_1901(self):
        """
        Fault 1901
        """
        self._send_command(
            'mv /mnt/factory/configs/unit/calibration_dlpath1.bin /mnt/factory/configs/unit/temp_filename')
        self._read_until_prompt('#')
        self._reboot_ru()

    def _generate_fault_5_1_1907(self):

        frmon_cmd_1 = '/ action create ConfigAccess /radio_op /module\n' \
                      '/radio_op action fetch DECODED "gc.bin" "/ram/gc.json"'
        frmon_cmd_2 = '/radio_op action store PERMANENT DECODED "gc.bin" "/ram/gc.json"\n' \
                      '/radio_op action update'
        self._send_command(
            f"echo $'{frmon_cmd_1}' | frmonShellClient localhost 2000")
        self._read_until_regexp('closed')
        self._send_command("""sed -i 's/."fbMinThreshold":.*/ "fbMinThreshold": -10,/g' /ram/gc.json""")
        self._read_until_prompt('#')
        self._send_command(
            f"echo $'{frmon_cmd_2}' | frmonShellClient localhost 2000")
        self._read_until_regexp('closed')
        self._reboot_ru()

    def _generate_fault_5_1_1910(self, **kwargs):

        if 'autonomous_reset' in kwargs:
            autonomous_reset = eval(kwargs['autonomous_reset'])
        else:
            autonomous_reset = True

        if autonomous_reset:
            ls_cmd = 'ls -ltd -- /run/coma/unit/*dlpath* | wc -l'
            self._send_command(ls_cmd)
            nr_of_dlpath = int(self._read_output().splitlines()[2])
            if type(nr_of_dlpath) is not int:
                raise CalibrationDlPathFileNotFound
        else:
            nr_of_dlpath = 1

        logger.debug(f"Decoding binary file calibration_dlpath1-{nr_of_dlpath}")

        for dlpath in range(1, nr_of_dlpath + 1):
            frmon_cmd_2 = f'/radio_op action store DECODED "unit/calibration_dlpath{dlpath}.bin" ' \
                          f'"/ram/calibration_dlpath{dlpath}.json"\n' \
                          '/radio_op action update'

            decoded_file = self._get_decoded_binary_file(f'unit/calibration_dlpath{dlpath}')

            for key in decoded_file['txVswr']:
                key['offset_filter_mB'] = 0

            sftp = self.client.open_sftp()
            with sftp.open(f"/ram/calibration_dlpath{dlpath}.json", 'w') as binary_file:
                json.dump(decoded_file, binary_file, indent=4)

            self._send_file_via_scp(
                direction='to_rmod', file_path=f'/ram/calibration_dlpath{dlpath}.json',
                destination_directory='/ram/')

            self._send_command(
                f"echo $'{frmon_cmd_2}' | frmonShellClient localhost 2000")
            self._read_until_regexp('closed')

    def _generate_fault_5_1_1911(self, **kwargs):

        if 'reboot_timeout' in kwargs:
            reboot_timeout = kwargs['reboot_timeout']
        else:
            reboot_timeout = 120

        frmon_cmd_2 = '/radio_op action store PERMANENT DECODED "faults.bin" "/ram/faults.json"\n' \
                      '/radio_op action update'
        frmon_cmd_3 = '/ action create RfSynthesizer /CI/RfSynthesizer_Rx1 /rf/rx1\n' \
                      '/CI/RfSynthesizer_Rx1 action force_unlock'

        decoded_file = self._get_decoded_binary_file('faults')

        for fault in decoded_file['faults']:
            if fault['faultId'] == 1263:
                fault['recoveryMaxRetires'] = 0

        sftp = self.client.open_sftp()
        with sftp.open("/ram/faults.json", 'w') as binary_file:
            json.dump(decoded_file, binary_file, indent=4)

        self._send_file_via_scp(
            direction='to_rmod', file_path='/ram/faults.json',
            destination_directory='/ram/')

        self._send_command(f"echo $'{frmon_cmd_2}' | frmonShellClient localhost 2000")
        self._read_until_regexp('closed')
        self._reboot_and_wait_for_ping(reboot_timeout, ping_down_timeout=60)

        self._open_connection_to_radio_module(self.ru_serial_number, self.remote_host)

        self._send_command(f"echo $'{frmon_cmd_3}' | frmonShellClient localhost 2000")
        self._read_until_regexp('closed')

    def _generate_fault_5_1_1927(self, **kwargs):
        """
        Fault 1927 visible in WebEM if actPipePowerDecreased1dBFaults is set to True
        """
        if 'severity' not in kwargs:
            raise KeyError("Missing 'severity' argument, use one of: ['Minor', 'Major'] !")
        elif kwargs['severity'] == 'Minor':
            self._generate_fault_5_1_temperature(sensor_type='Pipe', t_type='T_1dB', offset=0, **kwargs)
        elif kwargs['severity'] == 'Major':
            self._generate_fault_5_1_temperature(sensor_type='Pipe', t_type='T_3dB', offset=0, **kwargs)
        else:
            raise NotSupportedFaultSeverity('1927', kwargs['severity'])

    def _generate_fault_5_1_1932(self, **kwargs):

        if 'reboot_timeout' in kwargs:
            reboot_timeout = kwargs['reboot_timeout']
        else:
            reboot_timeout = 240

        tcs_name = self._get_name_of_tcs_file()
        frmon_cmd = f'/radio_op action store PERMANENT DECODED "{tcs_name}.bin" "/ram/{tcs_name}.json"\n' \
                    f'/radio_op action update'

        decoded_file = self._get_decoded_binary_file(tcs_name)
        decoded_file['tcs']['Nrpm_fail'] = 2
        decoded_file['tcs']['deltaTmulti'] = 120
        decoded_file['tcs']['deltaTctl'] = 120

        sftp = self.client.open_sftp()
        with sftp.open(f"/ram/{tcs_name}.json", 'w') as binary_file:
            json.dump(decoded_file, binary_file, indent=4)

        self._send_file_via_scp(
            direction='to_rmod', file_path=f'/ram/{tcs_name}.json',
            destination_directory='/ram/')

        self._send_command(f"echo $'{frmon_cmd}' | frmonShellClient localhost 2000")
        self._read_until_regexp('closed')

        self._reboot_and_wait_for_ping(reboot_timeout, ping_down_timeout=120)

        self._open_connection_to_radio_module(self.ru_serial_number, self.remote_host)

        self._generate_fault_5_1_temperature(sensor_type='Unit', t_type='Tblock', offset=1, code_type='Permanent')

    def _generate_fault_5_1_1933(self, **kwargs):

        if 'reboot_timeout' in kwargs:
            reboot_timeout = kwargs['reboot_timeout']
        else:
            reboot_timeout = 240

        if 'fan_early_notif' in kwargs:
            fan_early_notif = eval(kwargs['fan_early_notif'])
        else:
            fan_early_notif = True

        tcs_name = self._get_name_of_tcs_file()
        frmon_cmd = f'/radio_op action store PERMANENT DECODED "{tcs_name}.bin" "/ram/{tcs_name}.json"\n' \
                    f'/radio_op action update'

        frmon_cmd_2 = '/ action create FanDevice /radio_op_fan /fan/1\n' \
                      '/radio_op_fan set control_state TESTABILITY_SW\n' \
                      '/radio_op_fan action set_setpoint 0'

        decoded_file = self._get_decoded_binary_file(tcs_name)
        decoded_file['tcs']['Nrpm_fail'] = 2
        decoded_file['tcs']['deltaTmulti'] = 120
        decoded_file['tcs']['deltaTctl'] = 120

        sftp = self.client.open_sftp()
        with sftp.open(f"/ram/{tcs_name}.json", 'w') as binary_file:
            json.dump(decoded_file, binary_file, indent=4)

        self._send_file_via_scp(
            direction='to_rmod', file_path=f'/ram/{tcs_name}.json',
            destination_directory='/ram/')

        self._send_command(f"echo $'{frmon_cmd}' | frmonShellClient localhost 2000")
        self._read_until_regexp('closed')

        self._reboot_and_wait_for_ping(reboot_timeout, ping_down_timeout=60)

        self._open_connection_to_radio_module(self.ru_serial_number, self.remote_host)
        sensor = 'Unit_1933' if 'Unit_1933' in variables.TEMPERATURE_SENSORS.get(self.ru_name, {}) else 'Unit'

        if fan_early_notif is False:
            self._generate_fault_5_1_temperature(sensor_type=sensor, t_type='Tblock', offset=1, code_type='Permanent')

        if not (fan_early_notif and self.ru_name in ['AWHQN', 'AXEGHA']):
            self._generate_fault_5_1_temperature(sensor_type=sensor, t_type='Tblock', offset=1, code_type='Permanent')

        if self.ru_name in ['AWHQN', 'AXEGHA']:
            self._send_command('rad -mpw 0x120040 1')
            self._read_until_prompt('$|#')
        else:
            self._send_command(f"echo $'{frmon_cmd_2}' | frmonShellClient localhost 2000")
            self._read_until_regexp('closed')

    def _generate_fault_5_1_1936(self, **kwargs):
        """
        Fault 1936 visible in WebEM if enableUnitTemperatureHighAlarm is set to True
        """
        self._generate_fault_5_1_temperature(sensor_type='Pipe', t_type='Thigh', offset=1, **kwargs)

    def _generate_fault_5_1_1937(self, **kwargs):
        self._generate_fault_5_1_temperature(sensor_type='Unit', t_type='Tdanger', offset=5, **kwargs)

    def _generate_fault_5_1_1938(self, **kwargs):
        self._generate_fault_5_1_temperature(sensor_type='Pipe', t_type='Tdanger', offset=5, **kwargs)

    def _generate_fault_5_1_1940(self):
        """
        R&D fault, visible only in fault_history_log.txt
        """
        self._generate_recover_fault_5_1_1940(operation='FAULTY')

    def _generate_fault_5_1_1981(self):
        frmon_cmd_2 = '/radio_op action store PERMANENT DECODED "syscon_node0.bin" "/ram/syscon_node0.json"'

        data = self._get_decoded_binary_file('syscon_node0')

        for service in data['servicesDatabase']:
            if service['library'] == 'libcoco.so.lnk' and service['serviceId'] == 'port::0':
                service['startup_timeout_sec'] = 1200
                service['keepAlivePeriod_sec'] = 120
                service['recoveryAction'] = 'SendFault'
                service['faultId'] = 1295
                logger.debug(json.dumps(service, indent=4))

        sftp = self.client.open_sftp()
        with sftp.open("/ram/syscon_node0.json", 'w') as syscon_file:
            json.dump(data, syscon_file, indent=4)

        self._send_file_via_scp(
            direction='to_rmod', file_path='/ram/syscon_node0.json',
            destination_directory='/ram')

        self._send_command(f"echo $'{frmon_cmd_2}' | frmonShellClient localhost 2000")
        self._read_until_regexp('closed')
        self._reboot_ru()

    def _generate_fault_5_1_2928(self, **kwargs):
        frmon_cmd = f"action sfp_override_gpio {kwargs['sfp_id']} TX_FAULT true"
        self._generate_recover_fault_for_sfp(frmon_cmd, **kwargs)

    def _generate_fault_5_1_2929(self, **kwargs):
        frmon_cmd = f"action sfp_override_gpio {kwargs['sfp_id']} SIGNAL_LOSS true"

        if 'sfp_id' not in kwargs:
            raise ValueError("Argument for SFP identifier -> `sfp_id` <- must be provided !")

        cmd = '/ action create SfpInfo /radio_op_sfp\n' \
              f'/radio_op_sfp {frmon_cmd}'

        self._send_command(f"echo $'{cmd}' | frmonShellClient localhost 2000", delay=3)

    def _generate_fault_5_1_2931(self, **kwargs):
        self._generate_fault_5_1_2929(**kwargs)

    def _generate_fault_5_1_4658(self, **kwargs):
        if 'severity' not in kwargs:
            raise ValueError("Argument for fault severity -> `severity` <- must be provided !")

        byte = 0x74 if kwargs.get('severity').lower() == 'minor' else 0x70

        frmon_cmd = f"action sfp_override_memory {kwargs['sfp_id']} PAGE PAGE_1 {byte} DATA 0x40"
        self._generate_recover_fault_for_sfp(frmon_cmd, **kwargs)

    def _generate_fault_5_1_4698(self, **kwargs):
        if 'severity' not in kwargs:
            raise ValueError("Argument for fault severity -> `severity` <- must be provided !")

        byte = 0x74 if kwargs.get('severity').lower() == 'minor' else 0x70

        frmon_cmd = f"action sfp_override_memory {kwargs['sfp_id']} PAGE PAGE_1 {byte} DATA 0x80"
        self._generate_recover_fault_for_sfp(frmon_cmd, **kwargs)

    def _generate_fault_5_1_4699(self, **kwargs):
        if 'severity' not in kwargs:
            raise ValueError("Argument for fault severity -> `severity` <- must be provided !")

        byte = 0x74 if kwargs.get('severity').lower() == 'minor' else 0x70

        frmon_cmd = f"action sfp_override_memory {kwargs['sfp_id']} PAGE PAGE_1 {byte} DATA 0x04"
        self._generate_recover_fault_for_sfp(frmon_cmd, **kwargs)

    def _generate_fault_5_1_4700(self, **kwargs):
        if 'severity' not in kwargs:
            raise ValueError("Argument for fault severity -> `severity` <- must be provided !")

        byte = 0x74 if kwargs.get('severity').lower() == 'minor' else 0x70

        frmon_cmd = f"action sfp_override_memory {kwargs['sfp_id']} PAGE PAGE_1 {byte} DATA 0x01"
        self._generate_recover_fault_for_sfp(frmon_cmd, **kwargs)

    def _generate_fault_5_1_4701(self, **kwargs):
        if 'severity' not in kwargs:
            raise ValueError("Argument for fault severity -> `severity` <- must be provided !")

        byte = 0x75 if kwargs.get('severity').lower() == 'minor' else 0x71

        frmon_cmd = f"action sfp_override_memory {kwargs['sfp_id']} PAGE PAGE_1 {byte} DATA 0x40"
        self._generate_recover_fault_for_sfp(frmon_cmd, **kwargs)

    # ********** 5.1 RECOVER FAULT **********

    def _recover_fault_5_1_1901(self):
        self._send_command(
            'mv /mnt/factory/configs/unit/temp_filename /mnt/factory/configs/unit/calibration_dlpath1.bin')
        self._read_until_prompt('#')
        self._reboot_ru()

    def _recover_fault_5_1_1907(self):
        self._remove_runtime_config()

    def _recover_fault_5_1_1910(self):
        self._reboot_ru()

    def _recover_fault_5_1_1911(self):
        self._remove_runtime_config()

    def _recover_fault_5_1_1932(self):
        self._remove_runtime_config()

    def _recover_fault_5_1_1933(self):
        self._remove_runtime_config()

    def _recover_fault_5_1_1927(self, **kwargs):
        self._recover_fault_5_1_temperature(sensor_type='Pipe', **kwargs)

    def _recover_fault_5_1_1936(self, **kwargs):
        self._recover_fault_5_1_temperature(sensor_type='Pipe', **kwargs)

    def _recover_fault_5_1_1937(self, **kwargs):
        self._recover_fault_5_1_temperature(sensor_type='Unit', **kwargs)

    def _recover_fault_5_1_1938(self, **kwargs):
        self._recover_fault_5_1_temperature(sensor_type='Pipe', **kwargs)

    def _recover_fault_5_1_1940(self):
        self._generate_recover_fault_5_1_1940(operation='OFF')

    def _recover_fault_5_1_1981(self):
        self._remove_runtime_config()

    def _recover_fault_5_1_2928(self, **kwargs):
        frmon_cmd = f"action cancel_sfp_override_gpio {kwargs['sfp_id']}"
        self._generate_recover_fault_for_sfp(frmon_cmd, **kwargs)

    def _recover_fault_5_1_2929(self, **kwargs):
        self._recover_fault_5_1_2928(**kwargs)

    def _recover_fault_5_1_2931(self, **kwargs):
        self._recover_fault_5_1_2928(**kwargs)

    def _recover_fault_5_1_4698(self, **kwargs):
        frmon_cmd = f"action cancel_sfp_override_memory {kwargs['sfp_id']}"
        self._generate_recover_fault_for_sfp(frmon_cmd, **kwargs)

    def _recover_fault_5_1_4658(self, **kwargs):
        self._recover_fault_5_1_4698(**kwargs)

    def _recover_fault_5_1_4699(self, **kwargs):
        self._recover_fault_5_1_4698(**kwargs)

    def _recover_fault_5_1_4700(self, **kwargs):
        self._recover_fault_5_1_4698(**kwargs)

    def _recover_fault_5_1_4701(self, **kwargs):
        self._recover_fault_5_1_4698(**kwargs)

        # ********** GENERATE 6_X *********

    def _generate_fault_6_2_1901(self):
        """
        Fault 1901
        """
        self._send_command('sudo mount -o remount,rw /mnt/factory')
        self._read_until_prompt('$|#')
        self._send_command('sudo chmod 777 /mnt/factory/configs/unit/calibration_dlpath1.bin.md5')
        self._read_until_prompt('$|#')
        self._send_command(
            'sudo mv /mnt/factory/configs/unit/calibration_dlpath1.bin.md5 /mnt/factory/configs/unit/temp_md5_file')
        self._read_until_prompt('$|#')
        self._reboot_ru()

    def _generate_fault_6_2_1907_1920(self):
        logger.console("When generating FID 1907 or 1920 on 6.2 radio modules, both faults appear")

        frmon_cmd_1 = '/radio_op action store TEMPORARY DECODED "gc.bin" "/ram/gc.json"\n' \
                      '/radio_op action update'
        data = self._get_decoded_binary_file('gc')

        data['defaultCfg']['startup']['fbMinThreshold_min'] = -10
        data['defaultCfg']['runtime']['fbMinThreshold_min'] = -10
        data['defaultCfg']['fbLevelValidation']['enable'] = False

        sftp = self.client.open_sftp()
        with sftp.open(f"/{self.dir_for_file}/gc.json", 'w') as json_file:
            json.dump(data, json_file, indent=4)

        if self.tl_type == 'CloudRAN':
            cp_cmd = f'kubectl cp -n cran1 /tmp/gc.json {self.pod_name}-oamfh-0:' \
                     f'/tmp/gc.json -c ctr{self.name_space}-oamfh'
            logger.debug(f"Sending command: {cp_cmd}")
            stdin, stdout, stderr = self.client.exec_command(cp_cmd)
            logger.debug(f"Stdout from cmd: {stdout.read().decode()}")
            logger.debug(f"Stderr from cmd: {stderr.read().decode()}")

        self._send_file_via_scp(
            direction='to_rmod', file_path=f'/{self.dir_for_file}/gc.json', destination_directory='/ram/')

        self._send_command(
            f"echo $'{frmon_cmd_1}' | frmonShellClient localhost 2000")
        self._read_until_regexp('closed')
        # self._reboot_ru()

    def _generate_fault_6_2_1911(self):

        frmon_cmd_1 = '/radio_op action store PERMANENT DECODED "rxsupervision.bin" "/ram/rxsupervision.json"\n' \
                      '/radio_op action update'
        data = self._get_decoded_binary_file('rxsupervision')

        for index in range(len(data['rxSupervisionAlarm'])):
            data['rxSupervisionAlarm'][index]['lowPowerLevel'] = -50

        sftp = self.client.open_sftp()
        with sftp.open(f"/{self.dir_for_file}/rxsupervision.json", 'w') as json_file:
            json.dump(data, json_file, indent=4)

        if self.tl_type == 'CloudRAN':
            cp_cmd = f'kubectl cp -n cran1 /tmp/rxsupervision.json {self.pod_name}-oamfh-0:' \
                     f'/tmp/rxsupervision.json -c ctr{self.name_space}-oamfh'
            logger.debug(f"Sending command: {cp_cmd}")
            stdin, stdout, stderr = self.client.exec_command(cp_cmd)
            logger.debug(f"Stdout from cmd: {stdout.read().decode()}")
            logger.debug(f"Stderr from cmd: {stderr.read().decode()}")

        self._send_file_via_scp(
            direction='to_rmod', file_path=f'/{self.dir_for_file}/rxsupervision.json',
            destination_directory='/ram')
        self._send_command(
            f"echo $'{frmon_cmd_1}' | frmonShellClient localhost 2000")
        self._read_until_regexp('closed')
        self._reboot_ru()

    def _generate_fault_6_2_1927(self, **kwargs):
        logger.warn("Generating FID 1927 on 6.2 radio modules might not produce the expected result "
                    "or the fault might behave unpredictably!")
        if 'severity' not in kwargs:
            raise KeyError("Missing 'severity' argument, use one of: ['Minor', 'Major'] !")
        elif kwargs['severity'] == 'Minor':
            if self.ru_name in ['AHLOB', 'AHFII']:
                self._generate_fault_5_1_temperature(sensor_type='Pipe', t_type='Tprot', offset=2, **kwargs)
            elif self.ru_name in ['AHEGHA']:
                self._generate_fault_5_1_temperature(sensor_type='Pipe', t_type='Thigh', offset=0, **kwargs)
        elif kwargs['severity'] == 'Major':
            frmon_cmd = \
                '/radio_op action store PERMANENT DECODED "txpowercontrol_inst1.bin"' \
                ' "/ram/txpowercontrol_inst1.json"\n' \
                '/radio_op action update'

            data = self._get_decoded_binary_file('txpowercontrol_inst1')
            data['Tslope'] = 5.0
            # data['Thigh'] = 10.0
            data['Tprot'] = 15.0

            sftp = self.client.open_sftp()
            with sftp.open("/ram/txpowercontrol_inst1.json", 'w') as json_file:
                json.dump(data, json_file, indent=4)
                logger.debug(json.dumps(data, indent=2))

            self._send_file_via_scp(
                direction='to_rmod', file_path='/ram/txpowercontrol_inst1.json', destination_directory='/ram/')

            self._send_command(f"echo $'{frmon_cmd}' | frmonShellClient localhost 2000")
            self._read_until_regexp('closed')

            self._reboot_ru()
        else:
            raise NotSupportedFaultSeverity('1927', kwargs['severity'])

    def _generate_fault_6_2_4656(self, **kwargs):
        if 'sfp_id' not in kwargs:
            raise KeyError("Missing 'sfp_id' argument, use one of: [0, 1] !")
        elif kwargs['sfp_id'] in (0, 1):
            file_name = f"localsfp_inst{kwargs['sfp_id']}"
            frmon_cmd = f'/radio_op action store PERMANENT DECODED "{file_name}.bin" "/ram/{file_name}.json"\n' \
                        f'/radio_op action update'
        else:
            raise KeyError("Invalid value of 'sfp_id' argument, use one of: [0, 1] !")

        data = self._get_decoded_binary_file(file_name)
        data['compliance_codes']['basic_compliance_codes'][0] = 0
        for i in range(3):
            data['compliance_codes']['extended_compliance_codes'][i] = 0

        sftp = self.client.open_sftp()
        with sftp.open(f"/ram/{file_name}.json", 'w') as json_file:
            json.dump(data, json_file, indent=4)
            logger.debug(json.dumps(data, indent=2))

        self._send_file_via_scp(
            direction='to_rmod', file_path=f'/ram/{file_name}.json',
            destination_directory='/ram')
        self._send_command(
            f"echo $'{frmon_cmd}' | frmonShellClient localhost 2000")

        self._read_until_regexp('closed')
        self._reboot_ru()

    def _generate_fault_6_2_6921(self, **kwargs):
        if 'sfp_id' not in kwargs:
            raise KeyError("Missing 'sfp_id' argument, use one of: [1, 2] !")
        elif kwargs['sfp_id'] in (0, 1):
            file_name = f"localsfp_inst{kwargs['sfp_id']}"
            frmon_cmd = f'/radio_op action store PERMANENT DECODED "{file_name}.bin" "/ram/{file_name}.json"\n' \
                        f'/radio_op action update'
        else:
            raise KeyError("Invalid value of 'sfp_id' argument, use one of: [1, 2] !")

        data = self._get_decoded_binary_file(file_name)
        data['max_power_milliwatts'] = 500

        sftp = self.client.open_sftp()
        with sftp.open(f"/ram/{file_name}.json", 'w') as json_file:
            json.dump(data, json_file, indent=4)
            logger.debug(json.dumps(data, indent=2))

        self._send_file_via_scp(
            direction='to_rmod', file_path=f'/ram/{file_name}.json',
            destination_directory='/ram')
        self._send_command(
            f"echo $'{frmon_cmd}' | frmonShellClient localhost 2000")

        self._read_until_regexp('closed')
        self._reboot_ru()

    def _generate_fault_6_2_1932(self, **kwargs):
        self._generate_fault_5_1_1932(**kwargs)

    def _generate_fault_6_2_1933(self, **kwargs):
        self._generate_fault_5_1_1933(**kwargs)

    def _generate_fault_6_2_1936(self, **kwargs):
        self._generate_fault_5_1_1936(**kwargs)

    def _generate_fault_6_2_1937(self, **kwargs):
        self._generate_fault_5_1_1937(**kwargs)

    def _generate_fault_6_2_1938(self, **kwargs):
        self._generate_fault_5_1_1938(**kwargs)

    def _generate_fault_6_2_1940(self):
        self._generate_recover_fault_5_1_1940(operation='FAULTY')

    def _generate_fault_6_2_1981(self):
        self._generate_fault_5_1_1981()

    def _generate_fault_6_2_4658(self, **kwargs):
        self._generate_fault_5_1_4658(**kwargs)

    def _generate_fault_6_2_4698(self, **kwargs):
        self._generate_fault_5_1_4698(**kwargs)

        # ********** RECOVER 6_X **********

    def _recover_fault_6_2_1901(self):
        """
        Fault 1901
        """
        self._send_command('sudo mount -o remount,rw /mnt/factory')
        self._read_until_prompt('$|#')
        self._send_command('sudo chmod 777 /mnt/factory/configs/unit/temp_md5_file')
        self._read_until_prompt('$|#')
        self._send_command(
            'sudo mv /mnt/factory/configs/unit/temp_md5_file /mnt/factory/configs/unit/calibration_dlpath1.bin.md5')
        self._read_until_prompt('$|#')
        self._reboot_ru()

    def _recover_fault_6_2_1907(self):
        self._remove_runtime_config()

    def _recover_fault_6_2_1911(self):
        self._remove_runtime_config()

    def _recover_fault_6_2_1920(self):
        self._remove_runtime_config()

    def _recover_fault_6_2_1927(self):
        self._recover_fault_5_1_1927()

    def _recover_fault_6_2_1932(self):
        self._recover_fault_5_1_1932()

    def _recover_fault_6_2_1933(self):
        self._recover_fault_5_1_1933()

    def _recover_fault_6_2_1936(self):
        self._recover_fault_5_1_1936()

    def _recover_fault_6_2_1937(self):
        self._recover_fault_5_1_1937()

    def _recover_fault_6_2_1938(self):
        self._recover_fault_5_1_1938()

    def _recover_fault_6_2_1940(self):
        self._generate_recover_fault_5_1_1940(operation='OFF')

    def _recover_fault_6_2_1981(self):
        self._remove_runtime_config()

    def _recover_fault_6_2_4656(self):
        self._remove_runtime_config()

    def _recover_fault_6_2_4658(self, **kwargs):
        self._recover_fault_5_1_4658(**kwargs)

    def _recover_fault_6_2_4698(self, **kwargs):
        self._recover_fault_5_1_4698(**kwargs)

    def _recover_fault_6_2_6921(self):
        self._remove_runtime_config()

    # ********** GENERATE 8_X **********

    def _generate_fault_8_1901(self):
        self._generate_fault_6_2_1901()

    def _generate_fault_8_1907_1920(self):
        self._generate_fault_6_2_1907_1920()

    def _generate_fault_8_1911(self):
        self._generate_fault_6_2_1911()

    def _generate_fault_8_4656(self, **kwargs):
        if 'sfp_id' not in kwargs:
            raise KeyError("Missing 'sfp_id' argument, use one of: ['0', '1'] !")
        elif kwargs['sfp_id'] in (0, 1):
            file_name = f"port_sfp{kwargs['sfp_id']}"
            frmon_cmd = f'/radio_op action store PERMANENT DECODED "{file_name}.bin" "/ram/{file_name}.json"\n' \
                        f'/radio_op action update'
        else:
            raise KeyError("Invalid value of 'sfp_id' argument, use one of: ['0', '1'] !")

        data = self._get_decoded_binary_file(file_name)
        logger.debug(data)
        data['compliance_codes']['basic_compliance_codes'][0] = 0
        for i in range(3):
            data['compliance_codes']['extended_compliance_codes'][i] = 0

        sftp = self.client.open_sftp()
        with sftp.open(f"/ram/{file_name}.json", 'w') as json_file:
            json.dump(data, json_file, indent=4)
            logger.debug(json.dumps(data, indent=2))

        self._send_file_via_scp(
            direction='to_rmod', file_path=f'/ram/{file_name}.json',
            destination_directory='/ram')
        self._send_command(
            f"echo $'{frmon_cmd}' | frmonShellClient localhost 2000")

        self._read_until_regexp('closed')
        self._reboot_ru()

    def _generate_fault_8_6921(self, **kwargs):
        if 'sfp_id' not in kwargs:
            raise KeyError("Missing 'sfp_id' argument, use one of: ['0', '1'] !")
        elif kwargs['sfp_id'] in (0, 1):
            file_name = f"port_sfp{kwargs['sfp_id']}"
            frmon_cmd = f'/radio_op action store PERMANENT DECODED "{file_name}.bin" "/ram/{file_name}.json"\n' \
                        f'/radio_op action update'
        else:
            raise KeyError("Invalid value of 'sfp_id' argument, use one of: ['0', '1'] !")

        data = self._get_decoded_binary_file(file_name)
        data['max_power_milliwatts'] = 500

        sftp = self.client.open_sftp()
        with sftp.open(f"/ram/{file_name}.json", 'w') as json_file:
            json.dump(data, json_file, indent=4)
            logger.debug(json.dumps(data, indent=2))

        self._send_file_via_scp(
            direction='to_rmod', file_path=f'/ram/{file_name}.json',
            destination_directory='/ram')
        self._send_command(
            f"echo $'{frmon_cmd}' | frmonShellClient localhost 2000")

        self._read_until_regexp('closed')
        self._reboot_ru()

    def _generate_fault_8_4658(self, **kwargs):
        self._generate_fault_6_2_4658(**kwargs)

    def _generate_fault_8_4698(self, **kwargs):
        self._generate_fault_6_2_4698(**kwargs)

    def _generate_fault_8_2928(self, **kwargs):
        self._generate_fault_5_1_2928(**kwargs)

    def _generate_fault_8_2929(self, **kwargs):
        self._generate_fault_5_1_2929(**kwargs)

    def _generate_fault_8_4699(self, **kwargs):
        self._generate_fault_5_1_4699(**kwargs)

    def _generate_fault_8_4700(self, **kwargs):
        self._generate_fault_5_1_4700(**kwargs)

    def _generate_fault_8_4701(self, **kwargs):
        self._generate_fault_5_1_4701(**kwargs)

    def _generate_fault_8_1933(self, **kwargs):
        self._generate_fault_5_1_1933(**kwargs)

    def _generate_fault_8_1937(self, **kwargs):
        self._generate_fault_5_1_1937(**kwargs)

    # ********** RECOVER 8_X **********

    def _recover_fault_8_1901(self):
        self._recover_fault_6_2_1901()

    def _recover_fault_8_1907(self):
        self._recover_fault_6_2_1907()

    def _recover_fault_8_1920(self):
        self._recover_fault_6_2_1920()

    def _recover_fault_8_1911(self):
        self._recover_fault_6_2_1911()

    def _recover_fault_8_4656(self):
        self._remove_runtime_config()

    def _recover_fault_8_6921(self):
        self._remove_runtime_config()

    def _recover_fault_8_4658(self, **kwargs):
        self._recover_fault_6_2_4658(**kwargs)

    def _recover_fault_8_4698(self, **kwargs):
        self._recover_fault_6_2_4698(**kwargs)

    def _recover_fault_8_2928(self, **kwargs):
        self._recover_fault_5_1_2928(**kwargs)

    def _recover_fault_8_2929(self, **kwargs):
        self._recover_fault_5_1_2929(**kwargs)

    def _recover_fault_8_4699(self, **kwargs):
        self._recover_fault_5_1_4699(**kwargs)

    def _recover_fault_8_4700(self, **kwargs):
        self._recover_fault_5_1_4700(**kwargs)

    def _recover_fault_8_4701(self, **kwargs):
        self._recover_fault_5_1_4701(**kwargs)

    def _recover_fault_8_1933(self):
        self._recover_fault_5_1_1933()

    def _recover_fault_8_1937(self):
        self._recover_fault_5_1_1937()

    # ********** OTHER DEFs **********

    def _generate_fault_5_1_temperature(self, sensor_type, t_type, offset, **kwargs):

        if self.ru_name not in variables.TEMPERATURE_SENSORS:
            raise FaultSensorNotDefined(sensor_type, self.ru_name)

        if 'code_type' in kwargs:
            code_type = kwargs['code_type']
        else:
            code_type = 'Temporary'

        if code_type not in ['Temporary', 'Permanent']:
            raise KeyError

        tcs_name = self._get_name_of_tcs_file()
        # self._connect_to_soc_if_needed()
        inst_file = '5' if sensor_type == 'Unit' and self.ru_name in ['AAIB', 'AAFB'] else '1'
        frmon_cmd_1 = '/ action create ConfigAccess /radio_op /module\n' \
                      f'/radio_op action fetch DECODED "tcs_tempest_inst{inst_file}.bin"' \
                      f' "/ram/tcs_tempest_inst{inst_file}_default.json"\n' \
                      f'/radio_op action fetch DECODED "{tcs_name}.bin" "/ram/tcs_default.json"'
        frmon_cmd_2 = \
            f'/radio_op action store {code_type.upper()} DECODED "tcs_tempest_inst{inst_file}.bin" ' \
            f'"/ram/tcs_tempest_inst{inst_file}_default.json"\n' \
            '/radio_op action update'

        self._send_command(f"echo $'{frmon_cmd_1}' | frmonShellClient localhost 2000")
        self._read_until_regexp('closed')

        sensor_names_list = variables.TEMPERATURE_SENSORS[self.ru_name][sensor_type]
        sensor_name_temp_dict = dict()
        for sensor_name in sensor_names_list:
            sensor_temp = self._get_module_temp_on_ru(sensor_name)
            sensor_name_temp_dict[sensor_name] = sensor_temp

        self._send_file_via_scp_from_radio_module(file_path='/ram/tcs_default.json')
        self._send_file_via_scp_from_radio_module(file_path=f'/ram/tcs_tempest_inst{inst_file}_default.json')

        sftp = self.client.open_sftp()
        with sftp.open(f"/{self.dir_for_file}/tcs_default.json", "r") as tcs_file:
            data = json.load(tcs_file)
            if t_type == "T_1dB":
                if 'T_1db_sensor' in data['tcs']:
                    sensor_value = (
                        data['tcs']['T_1db_sensor'][0]
                        if isinstance(data['tcs']['T_1db_sensor'], list)
                        else data['tcs']['T_1db_sensor']
                    )
                    split_sensor = variables.TEMPERATURE_SENSORS[self.ru_name][sensor_type][0].split(':')[-1]
                    if sensor_value != split_sensor:
                        raise NotMatchPipeSensor(split_sensor, sensor_value)
            threshold = float(data['tcs'][t_type])

        sftp = self.client.open_sftp()
        with sftp.open(f"/{self.dir_for_file}/tcs_tempest_inst{inst_file}_default.json", "r") as json_file:
            data = json.load(json_file)

        logger.info(f"Threshold for {t_type}: {threshold}")
        for sensor in data['tempSensorHwInfo']:
            for sensor_name, sensor_temp in sensor_name_temp_dict.items():
                if sensor['sensorName'] == sensor_name:
                    sensor['tempOffset'] = threshold - float(sensor_temp) + offset
                    logger.info(f"Override offset value for sensor: {sensor_name} with real temperature: "
                                f"{float(sensor_temp)} to {threshold - float(sensor_temp) + offset}")

        with sftp.open(f"/{self.dir_for_file}/tcs_tempest_inst{inst_file}_default.json", 'w') as json_file:
            json.dump(data, json_file, indent=4)

        if self.tl_type == 'CloudRAN':
            self._copy_file_from_cran_vm_to_container(f"/{self.dir_for_file}/tcs_tempest_inst{inst_file}_default.json")

        self._send_file_via_scp(
            direction='to_rmod',
            file_path=f'/ram/tcs_tempest_inst{inst_file}_default.json',
            destination_directory='/ram')

        self._send_command(f"echo $'{frmon_cmd_2}' | frmonShellClient localhost 2000")
        self._read_until_regexp('closed')

        self._cleanup_file('tcs_default.json')
        self._cleanup_file(f'tcs_tempest_inst{inst_file}_default.json')

    def _recover_fault_5_1_temperature(self, sensor_type, **kwargs):

        if self.ru_name not in variables.TEMPERATURE_SENSORS:
            raise FaultSensorNotDefined(sensor_type, self.ru_name)

        if 'code_type' in kwargs:
            code_type = kwargs['code_type']
        else:
            code_type = 'Temporary'

        if code_type not in ['Temporary', 'Permanent']:
            raise KeyError

        inst_file = '5' if sensor_type == 'Unit' and self.ru_name in ['AAIB', 'AAFB'] else '1'
        # self._connect_to_soc_if_needed()
        frmon_cmd = '/ action create ConfigAccess /radio_op /module\n' \
                    f'/radio_op action fetch DECODED "tcs_tempest_inst{inst_file}.bin" ' \
                    f'"/ram/tcs_tempest_inst{inst_file}_default.json"'
        self._send_command(f"echo $'{frmon_cmd}' | frmonShellClient localhost 2000")
        self._read_until_regexp('closed')

        self._send_file_via_scp_from_radio_module(file_path=f'/ram/tcs_tempest_inst{inst_file}_default.json')

        sftp = self.client.open_sftp()
        with sftp.open(f"/{self.dir_for_file}/tcs_tempest_inst{inst_file}_default.json", "r") as json_file:
            data = json.load(json_file)

        sensor_names_list = variables.TEMPERATURE_SENSORS[self.ru_name][sensor_type]
        for sensor in data['tempSensorHwInfo']:
            if sensor['sensorName'] in sensor_names_list:
                logger.info(f"Restoring offset value for sensor: {sensor['sensorName']} to 0.0")
                sensor['tempOffset'] = 0

        with sftp.open(f"/{self.dir_for_file}/tcs_tempest_inst{inst_file}_default.json", 'w') as json_file:
            json.dump(data, json_file, indent=4)

        if self.tl_type == 'CloudRAN':
            self._copy_file_from_cran_vm_to_container(f"/{self.dir_for_file}/tcs_tempest_inst{inst_file}_default.json")

        self._send_file_via_scp(
            direction='to_rmod',
            file_path=f'/ram/tcs_tempest_inst{inst_file}_default.json',
            destination_directory='/ram')

        # self._connect_to_soc_if_needed()

        frmon_cmd = \
            f'/radio_op action store {code_type.upper()} DECODED "tcs_tempest_inst{inst_file}.bin" ' \
            f'"/ram/tcs_tempest_inst{inst_file}_default.json"\n' \
            '/radio_op action update'

        self._send_command(f"echo $'{frmon_cmd}' | frmonShellClient localhost 2000")
        self._read_until_regexp('closed')

        self._cleanup_file('tcs_default.json')
        self._cleanup_file(f'tcs_tempest_inst{inst_file}_default.json')

    def _remove_runtime_config(self):
        self._send_command('rad -mpw 0x120040 0')
        self._send_command('sudo rm -r /mnt/runtime/configs/*')
        output = self._read_until_prompt('#|$')
        if 'sudo: not found' in output:
            self._send_command('rm -r /mnt/runtime/configs/*')
            self._read_until_prompt('#|$')
        self._reboot_ru()

    def _generate_recover_fault_5_1_1940(self, operation):

        if 'Device' not in variables.TEMPERATURE_SENSORS[self.ru_name]:
            raise FaultSensorNotDefined('Device', self.ru_name)

        self._connect_to_soc_if_needed()
        frmon_cmd = '/ action create ConfigAccess /radio_op /module'
        self._send_command(f"echo $'{frmon_cmd}' | frmonShellClient localhost 2000")
        self._read_until_regexp('closed')

        temp_device = variables.TEMPERATURE_SENSORS[self.ru_name]['Device']
        logger.debug(f"Temperature device to override: {temp_device}")
        cmd_a = f"/ action create ThermometerDevice /radio_op_{temp_device} {temp_device}"
        cmd_b = f"/radio_op_{temp_device} action override {operation}"

        self._send_command(f"echo $'{cmd_a}' | frmonShellClient localhost 2000")
        self._read_until_regexp('closed')

        self._send_command(f"echo $'{cmd_b}' | frmonShellClient localhost 2000")
        self._read_until_regexp('closed')

    def _get_module_hostname(self):
        self._send_command('hostname')
        return self._read_until_prompt('#|$')

    def _connect_to_soc_if_needed(self):

        soc_hostnames_list = ['nahka', 'made2', 'aaib', 'aafb']
        module_hostname = self._get_module_hostname()
        if not any(soc in module_hostname for soc in soc_hostnames_list):
            logger.info("Connecting to first SoC via 192.168.101.2")
            self._send_command('ssh 192.168.101.2')
            output = self._read_until_regexp('fingerprint|Node1|Node0')
            if 'fingerprint' in output:
                logger.info("Found fingerprint, adding key to .known_hosts file")
                self._send_command('yes', delay=1)
                self._read_until_regexp('Node1|Node0')
            logger.info('Connected to SoC 192.168.101.2')

    def _override_values_in_binary_file(self, filename, values_dict, reset_ru, code_type):

        frmon_cmd = \
            f'/radio_op action store {code_type.upper()} DECODED "{filename}.bin" "/ram/{filename}.json"\n' \
            '/radio_op action update'

        data = self._get_decoded_binary_file(filename)

        for key, value in values_dict.items():
            if key in data:
                data[key] = value
            else:
                raise KeyNotFoundInBinaryFile(key, filename)

        sftp = self.client.open_sftp()

        with sftp.open(f"/{self.dir_for_file}/{filename}.json", 'w') as json_file:
            json.dump(data, json_file, indent=4)
            logger.debug(json.dumps(data, indent=2))

        if self.tl_type == 'CloudRAN':
            cp_cmd = f'kubectl cp -n cran1 /tmp/{filename}.json {self.pod_name}-oamfh-0:' \
                    f'/tmp/{filename}.json -c ctr{self.name_space}-oamfh'
            logger.debug(f"Sending command: {cp_cmd}")
            stdin, stdout, stderr = self.client.exec_command(cp_cmd)
            logger.debug(f"Stdout from cmd: {stdout.read().decode()}")
            logger.debug(f"Stderr from cmd: {stderr.read().decode()}")

        self._send_file_via_scp(
            direction='to_rmod', file_path=f'/{self.dir_for_file}/{filename}.json', destination_directory='/ram/')

        self._send_command(f"echo $'{frmon_cmd}' | frmonShellClient localhost 2000")
        self._read_until_regexp('closed')

        if reset_ru:
            self._reboot_ru()

    def _generate_recover_fault_for_sfp(self, cmd, **kwargs):
        if 'sfp_id' not in kwargs:
            raise ValueError("Argument for SFP identifier -> `sfp_id` <- must be provided !")

        frmon_cmd = '/ action create SfpInfo /radio_op_sfp\n' \
                    f'/radio_op_sfp {cmd}'
        self._send_command(f"echo $'{frmon_cmd}' | frmonShellClient localhost 2000", delay=2)

        output = self._read_until_regexp('closed')
        if 'OBJECT_DOES_NOT_EXIST' in output:
            raise SfpOverrideFailed()
