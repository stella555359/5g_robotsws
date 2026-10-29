from testsuite.Krakow.RRM.RAN_PZ.features.FRCB008072.resources.LicenseKeeper import LicenseKeeper
from testsuite.Krakow.RRM.RAN_PZ.features.FRCB008072.resources.Qualcomm import Qualcomm
from taf.rfrl.bts.devices.du.commissioning import GnbCommissioning as GnbScf
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations as GnbBbu
from testsuite.Krakow.resources.du_webem.du_webem_keywords import DuWebem
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from taf.rfrl.ue.parsers.qxdm_parser import QxdmLogParser
from taf.rfrl.utilities.robot.general import get_builtin_value
from taf.rfrl.ue.helpers import data_transfer
from moler.exceptions import CommandFailure
from taf.hw.rf_attenuator import rf_attenuator as attenuator
from moler.util.moler_test import MolerTest
from robot.libraries.BuiltIn import BuiltIn
from moler.device import DeviceFactory
from ute_ue import robot_api
import json
import time
import sys
import os
import re


class PuschKeywords:

    def __init__(self, ue_id=0, attenuator_id=0, attenuator_alias='jfw', ue_pc_source_path='c:/auto/',
                 encoding='iso-8859-15', qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe",
                 python_path="C:/Python38/python.exe", diag_com=7):
        self._PYTHON_VERSION = sys.version_info
        tl = BuiltIn().get_variable_value('${{{}}}'.format("tl"), None)
        self.uepc_log_path = os.path.join(ue_pc_source_path, 'logs')
        self.proxy_pc_log_path = get_builtin_value('OUTPUT_DIR')
        self.ue_data = robot_api.robot_api()
        self.lk = LicenseKeeper(ue_id=ue_id)
        self.qc = Qualcomm(ue_id=ue_id)
        self.attenuator = attenuator()
        self.du_webem = DuWebem()
        self.bbu = GnbBbu()
        self.scf = GnbScf()
        self.uepc_username = tl.ues[ue_id].ssh_connection_details.username
        self.uepc_password = tl.ues[ue_id].ssh_connection_details.password
        self.uepc_ipaddr = tl.ues[ue_id].ssh_connection_details.addr
        self.attenuator_config = tl.attenuator[attenuator_id]
        self.ue_serial = tl.ues[ue_id].serial_number
        self.python_path = python_path
        self.qcat_path = qcat_path
        self.diag_com = diag_com
        self.bts_id = self.bbu.get_global_bts_id()
        self.uepc_source_path = ue_pc_source_path
        self.attenuator_alias = attenuator_alias
        self.subdir_delta = 'resources/delta'
        self.log_collection_tracker = None
        self.initialized_attenuator = None
        self.initialized_devices = None
        self.hdf_log_name = 'qxdm.hdf'
        self.txt_log_proxy_pc = None
        self.path_delta_file = None
        self.hdf_log_path = None
        self.txt_log_path = None
        self.encoding = encoding
        self.script_path = None
        self.proxy_pc = None
        self.ue_id = ue_id
        self.ue_pc = None

    def get_qcat_licence(self):
        self.lk.get_qcat_licence()

    def release_qcat_licence(self):
        try:
            self.lk.release_qcat_licence()
        except Exception as e:
            MolerTest.warning('Licence Keeper released qcat licence with exception: {}'.format(e))

    def logout_from_licence_keeper(self):
        self.lk.logout()

    def switch_apn(self, apn_name):
        self.qc.switch_apn(apn_name=apn_name)
        self.qc.switch_airplane_mode()

    def switch_network_type(self, network_type):
        self.qc.switch_preferred_network_type(network_type)

    def enter_home_button(self):
        self.qc.enter_home_button()

    def lock_enb_ru(self, ru_distname):
        self.du_webem.update_parameter(dist_name=ru_distname,
                                       parameter_name='administrativeState',
                                       value='Locked')  # Lock eNB's RU to enable 5G SA attach

    @MolerTest.raise_background_exceptions()
    def prepare_ue_for_5g_attach(self, mode_5g, subnet):
        mode_5g = str(mode_5g)
        network_type = None
        apn = None
        if mode_5g == "NSA":
            apn = '5gkrk'
            network_type = 'NR_LTE'
        elif mode_5g == "SA":
            apn = '5gsakrk'
            network_type = 'NR_only'
        else:
            MolerTest.error('"SA" or "NSA" mode allowed only, {} given'.format(mode_5g), raise_exception=True)
        self.switch_network_type(network_type)
        self.switch_apn(apn_name=apn)
        self.reboot_qualcomm_ue(check_address=True, subnet=subnet)

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions()
    def reboot_qualcomm_ue(self, sleep_value=90, check_address=False, subnet=None):
        """
        Reboot UE by using moler device.

        :param sleep_value: int, amount of time to get full capability back after reboot
        :param check_address: bool, check if UE get ip address from subnet
        :param subnet: str, the first three octets of the expected subnet in decimal e.g. "10.84.170"
        :return:
        """
        self._create_moler_devices()
        cmd_reboot = self.ue_pc.get_cmd(cmd_name="bash",
                                        cmd_params={"bash": "adb -s {} reboot".format(self.ue_serial)})

        cmd_echo = self.ue_pc.get_cmd(cmd_name="echo",
                                      cmd_params={
                                          "text": "| adb -s {} shell 'ip -f inet addr show'".format(self.ue_serial),
                                          'text_in_quotation': False})

        cmd_echo_retry = self.ue_pc.get_cmd(cmd_name="echo",
                                            cmd_params={
                                                "text": "| adb -s {} shell 'ip -f inet addr show'".format(
                                                    self.ue_serial),
                                                'text_in_quotation': False})

        cmd_reboot_retry = self.ue_pc.get_cmd(cmd_name="bash",
                                              cmd_params={"bash": "adb -s {} reboot".format(self.ue_serial)})

        cmd_reboot(timeout=120)
        MolerTest.sleep(int(sleep_value))  # Wait until UE gets full capability back.
        if check_address:
            output_echo = cmd_echo(timeout=60)['RESULT']
            validation_result = self._validate_ue_ip(output_echo, subnet)
            if not validation_result:
                MolerTest.warning("UE did not get an IP address from expected subnet: '{}'".format(subnet))
                cmd_reboot_retry(timeout=120)
                MolerTest.info('UE reboot as recovery action performed')
                MolerTest.sleep(int(sleep_value))  # Wait until UE gets full capability back.
                output_echo_retry = cmd_echo_retry(timeout=60)['RESULT']
                validation_result_retry = self._validate_ue_ip(output_echo_retry, subnet)
                if not validation_result_retry:
                    MolerTest.error("UE IP address validation failed after reboot",
                                    dump="Output from '$adb shell ip -f inet addr show':\n{}".format(
                                        output_echo_retry), raise_exception=True)

    @staticmethod
    def _validate_ue_ip(cmd_output, subnet):
        _re_ip_addr = re.compile(r'^\s+inet\s({}\.\d+)/\d+\sscope\sglobal\srmnet_data\d$'.format(subnet))
        for line in cmd_output:
            if _re_ip_addr.search(line):
                MolerTest.info('UE got IP address: {} from expected subnet {}'.format(
                    _re_ip_addr.search(line).group(1), subnet))
                return True

    @MolerTest.raise_background_exceptions()
    def verify_bler_based_on_qtraces(self, max_allowed_bler, chipset_version, remove_logs=False):
        _qtraces = self._get_qtraces()
        _ul_qtraces = _qtraces[0]
        _dl_qtraces = _qtraces[1]
        _high_bler_ul_qtraces = []
        _high_bler_dl_qtraces = []
        supported_chipsets = ['sdx55', 'sdx60']

        if chipset_version == 'sdx60':
            _re_bler = re.compile(r'.*BLER.%:\s+(\d+)')
        elif chipset_version == 'sdx55':
            _re_bler = re.compile(r'.*BLER:\s+(\d+)%')
        else:
            _re_bler = None
            MolerTest.error(
                'Given Chipset version {} is not supported.\n'
                'Supported chipsets list: {}'.format(chipset_version, [chip for chip in supported_chipsets]),
                raise_exception=True)

        self._get_high_bler_qtraces(max_allowed_bler, _re_bler, _ul_qtraces, _high_bler_ul_qtraces)
        self._get_high_bler_qtraces(max_allowed_bler, _re_bler, _dl_qtraces, _high_bler_dl_qtraces)

        if _high_bler_ul_qtraces or _high_bler_dl_qtraces:
            MolerTest.error(
                'BLER values from captured Qtraces exceeded max allowed BLER: {}%\n'.format(max_allowed_bler),
                dump='High BLER UL Qtraces:\n {}\n\n'
                     'High BLER DL Qtraces:\n {}'.format(_high_bler_ul_qtraces, _high_bler_dl_qtraces),
                raise_exception=True)
        else:
            MolerTest.info('BLER value verification for Ul and DL Qtraces passed.\n '
                           'UL Qtraces:\n {}\n\nDL Qtraces:\n {}'.format(_ul_qtraces, _dl_qtraces))
        if remove_logs:
            self.remove_qxdm_logs()

    @staticmethod
    def _get_high_bler_qtraces(max_bler, bler_pattern, qtrace_input, high_bler_container):
        for qtrace in qtrace_input:
            if bler_pattern.search(qtrace):
                bler_value = bler_pattern.search(qtrace).group(1)
                if int(bler_value) > int(max_bler):
                    high_bler_container.append(qtrace)

    @MolerTest.raise_background_exceptions()
    def _get_qtraces(self):
        params = {}
        _ul_qtraces = []
        _dl_qtraces = []
        qtraces = [_ul_qtraces, _dl_qtraces]
        _re_dl_qtrace = re.compile(r'nr5g_mac_metric_qsh.c.*DL.*BLER.*')
        _re_ul_qtrace = re.compile(r'nr5g_mac_metric_qsh.c.*UL.*BLER.*')

        if self._PYTHON_VERSION[0] == 3:
            params['encoding'] = self.encoding
        with open(self.txt_log_proxy_pc, 'r', **params) as f:
            for line in f:
                if _re_dl_qtrace.search(line):
                    _dl_qtraces.append(line)
                elif _re_ul_qtrace.search(line):
                    _ul_qtraces.append(line)
        if _ul_qtraces and _dl_qtraces:
            return qtraces
        else:
            MolerTest.error('Qtraces check failure in qxdm log file: {}'.format(self.txt_log_proxy_pc),
                            raise_exception=True,
                            dump=[['UL qtraces not found' if not _ul_qtraces else 'UL qtraces OK'],
                                  ['DL qtraces not found' if not _dl_qtraces else 'DL qtraces OK']])

    @MolerTest.raise_background_exceptions()
    def verify_rrc_msg(self, mode_5g='SA', remove_logs=True):
        if mode_5g.upper() not in ['SA', 'NSA']:
            MolerTest.error('Improper value of mode_5g param.\n'
                            '"SA" or "NSA" mode allowed only, {} given'.format(mode_5g), raise_exception=True)

        rrc_msgs = self._get_rrc(mode_5g)
        if len(rrc_msgs) != 2:
            MolerTest.info('Captured RRC msgs:\n{}'.format(rrc_msgs))
            MolerTest.error('Wrong number of RRC Reconfiguration messages detected.'
                            '\nExpected: 2,\nDetected: {}'.format(len(rrc_msgs)), raise_exception=True)
        else:
            _msg = rrc_msgs[0]
            _succesor_msg = rrc_msgs[1]
            self._validate_transform_precoder(_msg, 'enabled')
            self._validate_reconfiguration_complete(_msg, mode_5g)
            self._validate_transform_precoder(_succesor_msg, 'disabled')
            self._validate_reconfiguration_complete(_succesor_msg, mode_5g)
            MolerTest.info('RRC msgs validation passed.\n{}\n\n{}'.format(_msg, _succesor_msg))
        if remove_logs:
            self.remove_qxdm_logs()

    @staticmethod
    @MolerTest.raise_background_exceptions()
    def _validate_transform_precoder(msg, expected_state):
        _re_transform_precoder = re.compile(r'\n\s+transformPrecoder\s(\w+),')
        match = _re_transform_precoder.search(msg)
        if match:
            if match.group(1) == expected_state:
                MolerTest.info('RRC Reconfiguration msg with transformPrecoder {} found'.format(match.group(1)))
                return True
            else:
                MolerTest.error('Unexpected transformPrecoder value found: {}.'
                                '\nExpected value: {}'.format(match.group(1), expected_state),
                                dump='Failed msg content:\n{}'.format(msg), raise_exception=True)
        else:
            MolerTest.error('transformPrecoder not found in RRC Reconfiguration msg.',
                            dump='Failed msg content:\n{}'.format(msg), raise_exception=True)

    @staticmethod
    @MolerTest.raise_background_exceptions()
    def _validate_reconfiguration_complete(msg, mode_5g):
        if mode_5g.upper() == 'NSA':
            re_reconfiguration_complete = re.compile(
                r'\n.*0xB0C0\s+LTE\sRRC\sOTA\sPacket\s+-+\s+UL_DCCH\s/\s(RRCConnectionReconfigurationComplete)\n')
        else:
            re_reconfiguration_complete = re.compile(
                r'\n.*0xB821\s+NR5G\sRRC\sOTA\sPacket\s+-+\s+UL_DCCH\s/\s(RRCConfiguration\sComplete)\n')

        match = re_reconfiguration_complete.search(msg)
        if match:
            MolerTest.info('{} msg found'.format(match.group(1)))
            return True
        else:
            MolerTest.error('RRCConfigurationComplete msg not found.',
                            dump='Failed msg content:\n{}'.format(msg), raise_exception=True)

    @MolerTest.raise_background_exceptions()
    def _get_rrc(self, mode_5g):
        params = {}
        if mode_5g.upper() == 'NSA':
            _re_rrc_pair = re.compile(
                r'\n.*0xB0C0\s+LTE\sRRC\sOTA\sPacket\s+-+\s+DL_DCCH\s/\sRRCConnectionReconfiguration(?:\s.*){172}}')
        else:
            _re_rrc_pair = re.compile(
                r'\n.*0xB821\s+NR5G\sRRC\sOTA\sPacket\s+-+\s+DL_DCCH\s/\sRRCReconfiguration(?:\s.*){166}')

        if self._PYTHON_VERSION[0] == 3:
            params['encoding'] = self.encoding
        with open(self.txt_log_proxy_pc, 'r', **params) as f:
            _all_msg = f.read()
            rrc_matches = re.findall(_re_rrc_pair, _all_msg)
        if rrc_matches:
            return rrc_matches
        else:
            MolerTest.error('RRC message not found. Check qxdm log file: {}'.format(self.txt_log_proxy_pc),
                            raise_exception=True)

    @MolerTest.raise_background_exceptions()
    def check_antenna_ports_based_on_mcs(self, threshold, mcs_ltt_check=False):
        ul_rows = self._filter_ul_rows_from_msgs()
        failed_rows_with_mcs_htt = []  # htt/ltt means higher/lower than threshold
        failed_rows_with_mcs_ltt = []
        passed_rows_with_mcs_htt = []
        passed_rows_with_mcs_ltt = []

        for row in ul_rows:
            mcs = row['DCI Info->UL->MCS']
            antenna_port = row['DCI Info->UL->Antenna Ports']
            if int(mcs) >= int(threshold):
                if int(antenna_port) != 0:
                    failed_rows_with_mcs_htt.append(row)
                else:
                    passed_rows_with_mcs_htt.append(row)
            else:
                if int(antenna_port) == 0:
                    failed_rows_with_mcs_ltt.append(row)
                else:
                    passed_rows_with_mcs_ltt.append(row)

        if failed_rows_with_mcs_htt or failed_rows_with_mcs_ltt:
            error_msg = []
            if failed_rows_with_mcs_htt:
                msg = '\nNonzero Antenna Ports values found in messages with MSC higher than threshold.' \
                      '\n{}'.format(failed_rows_with_mcs_htt)
                error_msg.append(msg)
            if failed_rows_with_mcs_ltt:
                msg = "\nZero Antenna Ports values found in messages with MSC lower than threshold." \
                      "\n{}".format(failed_rows_with_mcs_ltt)
                error_msg.append(msg)
            MolerTest.error('Antenna Ports values verification failure', dump=error_msg, raise_exception=True)
        else:
            if mcs_ltt_check is True:
                if passed_rows_with_mcs_ltt:
                    MolerTest.info('\nAntenna Ports values verification passed.\n\n'
                                   'Sample of rows from 0xB885 messages with dci_format=UL_0_1 contained:\n\n'
                                   '1) MCS value higher than Threshold {}:\n{}\n\n'
                                   '2) MCS value lower than Threshold {}:\n{}\n\n'
                                   ''.format(threshold, passed_rows_with_mcs_htt[:3], threshold,
                                             [passed_rows_with_mcs_ltt[:3] if len(passed_rows_with_mcs_ltt) >= 3 else
                                              passed_rows_with_mcs_ltt]))
                else:
                    MolerTest.error('Not found any rows from 0xB885 messages with dci_format=UL_0_1 '
                                    'contained MCS value lower than Threshold value {}. '
                                    'Verify if qxdm log collection period covers throughput period'.format(threshold))
            else:
                MolerTest.info('\nAntenna Ports values verification passed.\n\n'
                               'Sample of rows from 0xB885 messages with dci_format=UL_0_1 contained:\n\n'
                               '1) MCS value higher than Threshold {}:\n{}\n\n'
                               '2) MCS value lower than Threshold {}:\n{}\n\n'
                               ''.format(threshold, passed_rows_with_mcs_htt[:3], threshold,
                                         [passed_rows_with_mcs_ltt[:3] if len(passed_rows_with_mcs_ltt) >= 3 else
                                          passed_rows_with_mcs_ltt]))

    @MolerTest.raise_background_exceptions()
    def check_if_given_antenna_ports_not_exist(self, antenna_ports):
        ul_rows = self._filter_ul_rows_from_msgs()
        failed_rows = [row for row in ul_rows if int(row['DCI Info->UL->Antenna Ports']) == int(antenna_ports)]
        if failed_rows:
            MolerTest.error('Disallowed Antenna Ports value: {} found in messages'.format(antenna_ports),
                            raise_exception=True, dump=failed_rows)
        else:
            MolerTest.info('Antenna Ports value verification passed.\n'
                           'Sample of rows from 0xB885 messages with dci_format=UL_0_1:\n{}'.format(ul_rows[:3]))

    @MolerTest.raise_background_exceptions()
    def _filter_ul_rows_from_msgs(self, message_id='0xB885', dci_format='UL_0_1'):
        parsed_log = self._parse_qxdm_log()[message_id]
        all_rows = []

        for msg in parsed_log[:]:
            headers = msg['Records']['headers']
            for row in msg['Records']['values']:
                row_with_header = dict(zip(headers, row))
                all_rows.append(row_with_header)

        ul_rows = [row for row in all_rows if row['DCI Info->DCI Format'] == dci_format]

        if ul_rows:
            return ul_rows
        else:
            MolerTest.error('Not found any messages containing "UL_0_1" as header\'s "DCI Format" value ',
                            raise_exception=True, dump=parsed_log)

    def _parse_qxdm_log(self):
        parser = QxdmLogParser(file_path=self.proxy_pc_log_path, message_ids=['0xB885'])
        parser.parse()
        parsed_log = parser.ret
        return parsed_log

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions()
    def clear_uepc_log_dir(self):
        self._create_moler_devices()
        cmd_ls = self.ue_pc.get_cmd(cmd_name="echo",
                                    cmd_params={
                                        "text": "| ls -l {}".format(self.uepc_log_path),
                                        'text_in_quotation': False})

        rm_uepc_logs = self.ue_pc.get_cmd(cmd_name="rm",
                                          cmd_params={"file": self.uepc_log_path + '/*',
                                                      "options": "-v"})

        ls_output = cmd_ls(timeout=5)['RESULT']
        match = re.search(re.compile(r'total\s+(\d+)'), ls_output[0])
        if match:
            if int(match.group(1)) > 0:
                rm_uepc_logs(timeout=10)
                MolerTest.info('UE PC log directory was not empty. Clearing performed.')
            else:
                MolerTest.info('UE PC log directory is empty. No action required.')

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions()
    def convert_qxdm_log_and_upload_it_to_proxy_pc(self):
        self.convert_qxdm_log()
        self.upload_qxdm_log()
        MolerTest.info('\nUE PC .hdf log path: {}\nUE PC .txt log path: {}\nPROXY PC .txt log path: {}'.format(
            self.hdf_log_path, self.txt_log_path, self.txt_log_proxy_pc))

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions()
    def remove_qxdm_logs(self):
        self._create_moler_devices()
        ue_pc_rm_txt = self.ue_pc.get_cmd(cmd_name="rm",
                                          cmd_params={"file": self.txt_log_path})
        ue_pc_rm_hdf = self.ue_pc.get_cmd(cmd_name="rm",
                                          cmd_params={"file": self.hdf_log_path})
        ue_pc_rm_hdf(timeout=10)
        ue_pc_rm_txt(timeout=10)

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions()
    def upload_qxdm_log(self):
        self._create_moler_devices()
        self.txt_log_path = self.hdf_log_path.replace('.hdf', '.txt')
        self.txt_log_proxy_pc = self.txt_log_path.replace(self.uepc_log_path, self.proxy_pc_log_path)

        upload_log = self.proxy_pc.get_cmd(cmd_name="scp", cmd_params={
            "source": "{}@{}:{}".format(self.uepc_username, self.uepc_ipaddr, self.txt_log_path),
            "dest": self.proxy_pc_log_path,
            "password": self.uepc_password})

        upload_log(timeout=300)

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions()
    def convert_qxdm_log(self, error_regex=re.compile("error", re.IGNORECASE)):
        self._create_moler_devices()
        self.log_collection_tracker.await_done()
        cmd_convert = "'{}' -txt '{}'".format(self.qcat_path, self.hdf_log_path)
        convert_log = self.ue_pc.get_cmd(cmd_name="run_script", cmd_params={'script_command': cmd_convert,
                                                                            'error_regex': error_regex})
        try:
            convert_log(timeout=300)
        except CommandFailure as e:
            if r'The remote server returned an error: (404) Not Found' not in repr(e):
                raise e

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions()
    def collect_qxdm_log(self, duration, dmc_name='mac_dci_qtraces', log_name=None,
                         error_regex=re.compile(r'(Fail to connect port COM)|'
                                                r'(Unable to obtain ISF interface)|'
                                                r'(Unable to load the dmc)')):
        self._create_moler_devices()
        if not log_name:
            name = self.hdf_log_name
        else:
            name = log_name + '.hdf'
        self.hdf_log_path = os.path.join(self.uepc_log_path, name)

        if not self.script_path:
            self.script_path = os.path.join(self.uepc_source_path, 'QXDM5LogCatch.py')

        extension = '.dmc'
        dmc_file = '{}{}{}'.format(self.uepc_source_path, dmc_name, extension)

        cmd = "{} '{}' -t {} -p {} -c '{}' -s '{}'".format(self.python_path, self.script_path, duration, self.diag_com,
                                                           dmc_file, self.hdf_log_path)

        self.log_collection_tracker = self.ue_pc.get_cmd(cmd_name="run_script", cmd_params={'script_command': cmd,
                                                                                            'error_regex': error_regex
                                                                                            })
        self.log_collection_tracker.start(timeout=int(duration) * 2)

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions()
    def _create_moler_devices(self):
        if self.initialized_devices is None:
            self.ue_pc = DeviceFactory.get_device("UE{}_PC".format(self.ue_id), initial_state="UNIX_REMOTE")
            self.proxy_pc = DeviceFactory.get_cloned_device("GNB0", "GNB0_PROXY_PC", initial_state="PROXY_PC")
            self.initialized_devices = True

    def _connect_attenuator(self):
        if self.initialized_attenuator is None:
            self.attenuator.setup_attenuator(attenuator=self.attenuator_config, alias=self.attenuator_alias)
            self.initialized_attenuator = True

    def simulate_mobility_of_ue(self, port_id1, port_id2, at_min, at_max, interval, at_time):
        self.fade_attenuator(port_id1=port_id1, port_id2=port_id2, start_value=at_min, end_value=at_max,
                             interval=interval)
        MolerTest.sleep(at_time)
        self.fade_attenuator(port_id1=port_id1, port_id2=port_id2, start_value=at_max, end_value=at_min,
                             interval=interval)

    def fade_attenuator(self, port_id1, port_id2, start_value, end_value, interval):
        self._connect_attenuator()
        start_value = int(start_value)
        end_value = int(end_value)
        interval = int(interval)
        scenario_1 = self.attenuator.set_linear_fading_scenario(port=int(port_id1), start_value=start_value,
                                                                end_value=end_value, interval=interval,
                                                                attenuator_device=self.attenuator_alias)
        scenario_2 = self.attenuator.set_linear_fading_scenario(port=int(port_id2), start_value=start_value,
                                                                end_value=end_value, interval=interval,
                                                                attenuator_device=self.attenuator_alias)
        scenarios = [scenario_1, scenario_2]
        self.attenuator.set_ports_fading_attenuation(set_fading_scenarios=scenarios,
                                                     attenuator_device=self.attenuator_alias)

    @MolerTest.raise_background_exceptions()
    def verify_nr_cell_setup(self, cell_id, timeout=300, step=60):
        exception_msg = None
        counter = 0

        while counter <= timeout:
            try:
                self.bbu.verify_configuration_parameters_values(
                    param_dict={
                        "MRBTS-{}/NRBTS-{}/NRCELL-{}".format(self.bts_id, self.bts_id, cell_id): {
                            'administrativeState': 'Unlocked',
                            'operationalState': 'enabled'}})
            except Exception as e:
                MolerTest.info('Exception occurred: {}'.format(e))
                exception_msg = e
                time.sleep(step)
                counter += step
            else:
                MolerTest.info('NR Cell setup verification passed')
                break
        if counter > timeout:
            MolerTest.error('NR Cell setup failure. Exception occurred: {} '.format(exception_msg),
                            raise_exception=True)

    def verify_threshold(self, value, cell_id, name='ulDataDmrsFdmThres64QamMcs'):
        self.bbu.verify_configuration_parameters_values(
            param_dict={"MRBTS-{}/NRBTS-{}/NRCELL-{}".format(self.bts_id, self.bts_id, cell_id): {name: value}})

    @MolerTest.raise_background_exceptions()
    def verify_product_variant_planned(self):
        """
        22R3 Feature CB008797 verification.
        Check if productVariantPlanned parameter has sBTS value.
        """
        param_name = 'productVariantPlanned'
        expected_value = 'sBTS'
        active_release = self._check_active_sw
        if active_release != 'SBTS22R2':
            try:
                self.bbu.verify_configuration_parameters_values(
                    param_dict={
                        "MRBTS-{}/MNL-1".format(self.bts_id): {param_name: expected_value}})
            except Exception as e:
                MolerTest.error('Feature CB008797 verification failure. Parameter {} should have value {}. '
                                'Exception occurred: {}'.format(param_name, expected_value, e), raise_exception=True)
        else:
            MolerTest.info('{} verification skipped. Feature CB008797 was introduced in 22R3, gNB SW: {}'.format(
                param_name, active_release))

    @MolerTest.raise_background_exceptions()
    def perform_delta_commissioning(self, curdir_path, test_tag):
        active_release = self._check_active_sw()
        default_delta_path = os.path.join(curdir_path, self.subdir_delta)
        dedicated_delta_path = os.path.join(default_delta_path, active_release)
        if os.path.exists(dedicated_delta_path):
            self.path_delta_file = dedicated_delta_path
        else:
            self.path_delta_file = default_delta_path
        MolerTest.info('Delta file loaded from path: {}'.format(self.path_delta_file))
        delta_template = self._get_delta_file_content(self.path_delta_file, test_tag)
        self.scf.perform_bts_delta_commissioning(delta=delta_template, skip_parameter_relation_errors=False)

    @MolerTest.raise_background_exceptions()
    def _check_active_sw(self):
        active_sw = self.bbu.get_bts_sw_release_name()
        MolerTest.info('Active gNB SW release: {}'.format(active_sw))
        return active_sw

    @staticmethod
    @MolerTest.raise_background_exceptions()
    def _get_delta_file_content(path, tag):
        path_to_delta_file = os.path.join(path, "{}.json".format(tag))
        try:
            with open(path_to_delta_file) as f:
                delta_content = json.load(f)
                if delta_content:
                    return delta_content
                else:
                    MolerTest.error("Delta file is empty")
        except IOError:
            MolerTest.error("Delta file in '{}' NOT FOUND".format(path_to_delta_file))

    def get_average_tput_values(self, dt_name):
        return self.ue_data.get_average_throughput(dt_name=dt_name)

    def get_data_transfer_stats(self, direction):
        stats = self.ue_data.get_data_transfer_statistics('DT_{}'.format(direction))
        return stats

    @staticmethod
    def start_udp_bidir_data_transfer(duration, dl_tput, ul_tput, dt_name_dl="DT_DL", dt_name_ul="DT_UL"):
        data_transfer.start_data_transfer_on_real_ue(duration=duration, tput=dl_tput, dt_name=dt_name_dl,
                                                     direction='dl', protocol='udp', parallel_streams='1',
                                                     size_packet='1400B', buffer_client='4M', buffer_server='4M',
                                                     interval='1', qci=None, linux_congestion=None, ue_alias='UE',
                                                     multi_radio_bearer=False)

        data_transfer.start_data_transfer_on_real_ue(duration=duration, tput=ul_tput, dt_name=dt_name_ul,
                                                     direction='ul', protocol='udp', parallel_streams='1',
                                                     size_packet='1400B', buffer_client='2M', buffer_server='2M',
                                                     interval='1', qci=None, linux_congestion=None, ue_alias='UE',
                                                     multi_radio_bearer=False)

        time.sleep(10)  # Wait for throughput stabilization

    @staticmethod
    @MolerTest.raise_background_exceptions()
    def compare_average_throughput(avg_type_a, avg_type_b, direction, allowed_delta=0.5):
        type_a = round((float(avg_type_a) / 1000000), 2)
        type_b = round((float(avg_type_b) / 1000000), 2)
        if direction == 'UL':
            allowed_delta = allowed_delta
        else:
            allowed_delta = allowed_delta * 2

        if type_a < type_b:
            delta = round(type_b - type_a, 2)
            if delta < allowed_delta:
                MolerTest.info("Average {} TypeA tput value: {}Mbits/sec is lower than TypeB tput: {}Mbits/sec, but "
                               "difference between them {}Mbits/sec didn't exceed allowed range {}Mbits/sec"
                               "\nComparison passed".format(direction, type_a, type_b, delta, allowed_delta))
            else:
                MolerTest.error("\nAverage {} throughput comparison failed.\n"
                                "TypeA tput: {}Mbits/sec is lower than TypeB tput: {}Mbits/sec, difference exceeded "
                                "allowed range: {}Mbits/sec".format(direction, type_a, type_b, allowed_delta),
                                raise_exception=True)
        else:
            comparison_msg = ['higher than' if type_a > type_b else 'equal to']
            MolerTest.info("\nAverage {} throughput comparison passed\n"
                           "TypeA tput: {}Mbits/sec is {} TypeB tput: {}Mbits/sec".format(direction, type_a,
                                                                                          comparison_msg[0], type_b))
