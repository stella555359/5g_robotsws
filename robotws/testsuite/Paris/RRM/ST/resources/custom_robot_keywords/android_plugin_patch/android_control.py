# -*- coding: utf-8 -*-
"""
:copyright: Nokia
:author: UTE UE Developers
:contact: ue-manager-developers@list.nokia.com
:maintainer: UTE UE Developers
"""
from __future__ import print_function

import logging
import os
import sys
import os.path
import time

from ta_ue_plugin_android.uepc.adb_cmd_runners import AdbCmdRunner
from ta_ue_plugin_android.uepc.adb_cmd_runners import get_public_adb_cmd_runner
from ta_ue_plugin_android.uepc.adb_proxy import MultiCmdUeShellRunner
from ta_ue_plugin_android.uepc.datatransfer.ue_control_dt import UeControlDt
from ta_ue_plugin_android.uepc.sleepy_loop_worker import SleepyLoopWorker
from ta_ue_plugin_android.uepc.ue_control_utils import UeControlUtils
from ta_ue_plugin_android.uepc.ue_manager_exceptions import CanNotChangeNetworkModeError, UeManagerException
from ta_ue_plugin_android.uepc.ue_manager_exceptions import NoCellIdError
from ta_ue_plugin_android.uepc.ue_manager_exceptions import NoCellIdUeIsDetachedError
from ta_ue_plugin_android.uepc.ue_manager_exceptions import NoIpError, CannotDetachError, CannotAttachError, \
    VoiceCallProcessingException
from ta_ue_plugin_android.uepc.ue_manager_exceptions import NotStartedConnectionException
from ta_ue_plugin_android.uepc.ue_manager_exceptions import RunningKeywordException
from ta_ue_plugin_android.uepc.ue_manager_exceptions import UnexpectedCmdResultException, FailToTurnOnWiFi, \
    FailToTurnOffWiFi, FailedToSwitchVolteException
from ta_ue_plugin_android.uepc.ue_manager_protocol import UeManagerProtocol
from ta_ue_plugin_android.uepc.ue_pc_logger import LoggerAdapter4EmptyExtra
from ta_ue_plugin_android.uepc.utils import MethodsQueue

LIMIT_MAXSIZE = 2500000  # added by abderrahmane.nezrouk@nokia.com to avoid crash


class AndroidControl(UeControlDt):
    """TBC"""
    # pylint: disable=too-many-lines, too-many-instance-attributes, super-init-not-called, broad-except,
    # unnecessary-lambda
    LTE_CELL_ID_WORKAROUND_MODELS = ["Sony D6603", "LGE LG-F700S", "LGE LG-F700K", "LGE LG-F700L",
                                     "Unknown MSM8996 for arm64", "Samsung SM-G9008V",
                                     "Sony F8132"]
    QUALCOMM_PROTOTYPE_PATTERNS = ['QUALCOMM', 'Unknown MSM8996', 'Unknown MSM8994', 'MSM89', 'msmnile', 'SDM8']
    QMDL_FILEPATH = 'path to rrc logs on UEPC'
    RRC_LOGS_TXT_FILEPATHS = 'path to txt files created from qmdl file'

    def __init__(self, special_name_sufix=''):
        """
        Basic initialization.
        :param special_name_sufix:
        """
        raw_logger = logging.getLogger("ute_ue.uepc")
        self.logger = LoggerAdapter4EmptyExtra(raw_logger, {'area': 'UECONTROL'})

        self.logger.debug('UeControl constructed with special_name_sufix={}'.format(special_name_sufix))
        self.sn_number = False
        self.ueman = None
        self.diag_ue_runner_or_none = None
        self.is_iperf_shell_field = None
        self.ue_control_utils = UeControlUtils(self)
        self.rooted = "unknown"
        self.cached_ue_model_or_none = None
        self._oneway_error_to_raise = None
        self._oneway_value_to_return = None
        self.release_methods = MethodsQueue()
        self.is_qualcomm_prototype = None
        self.paths_to_rrc_logs = {}
        self.ip_interface = {'ip_version': 4, 'interface_name_pattern': None}
        self.ue_ip = None
        super(AndroidControl, self).__init__()

    def get_oneway_method_result(self):
        """
        Get result of pyro oneway method or raise error if occured.
        :return:
        """
        result = self._oneway_value_to_return
        if result:
            self._oneway_value_to_return = None
        if self._oneway_error_to_raise is not None:
            self._raise_oneway_error()
        return result

    def _raise_oneway_error(self):
        error = self._oneway_error_to_raise
        self._oneway_error_to_raise = None
        raise error  # pylint: disable=raising-bad-type

    def make_http(self, url):
        """
        Trigger HTTP request on Android UE
        :param url: HTTP url
        """
        self.logger.info('Triggering HTTP request on UE using url {}.'.format(url), extra={'ue_id': self.sn_number})
        self.ue_control_utils.http_request(url)
        self.logger.info('HTTP request triggered.', extra={'ue_id': self.sn_number})

    def start_ftp_data_transfer(self, direction, local_path, remote_path, ftp_ip, ftp_user=None, ftp_pass=None,
                                ftp_port=21):
        """
        Transfer a file from or to FTP server
        :return: cmd that issued transfer on UE, pid of the data transfer process on UE
        :param direction: 'dl' or 'ul'
        :param local_path: path on UE side
        :param remote_path: path on FTP server
        """
        self.logger.debug('Checking if UE is attached before FTP data transfer')
        if self.is_airplane_mode():
            raise NoCellIdUeIsDetachedError('Ue is not attached. Please perform attach before starting data transfer')
        self.logger.debug('Ue attached. Starting FTP data transfer')

        if direction == 'dl':
            self.logger.info('Starting a download of {} file from {} ftp server'.format(remote_path, ftp_ip),
                             extra={'ue_id': self.sn_number})
            cmd, pid = self.ue_control_utils.transfer_file_from_ftp(local_path, remote_path, ftp_ip, ftp_user,
                                                                    ftp_pass,
                                                                    ftp_port)
        else:
            self.logger.info('Starting an upload of {} file to {} directory on {} ftp server'.format(
                local_path, remote_path, ftp_ip), extra={'ue_id': self.sn_number})
            cmd, pid = self.ue_control_utils.transfer_file_to_ftp(local_path, remote_path, ftp_ip, ftp_user, ftp_pass,
                                                                  ftp_port)
        return cmd, pid

    def stop_ftp_data_transfer(self, pid):
        """
        Killing ongoing dt process by pid
        :param pid:
        :return:
        """
        self.kill_proc_by_pid_with_check(pid)

    def release_uplink_ftp_data_transfer(self, pid, ftp_ip, ftp_user, ftp_pass, ftp_remote_path):
        """Killing ongoing dt process by pid and removing file on FTP"""
        self.kill_proc_by_pid_with_check(pid)
        self.logger.debug('Trying to remove unfinished file on FTP server: {}'.format(ftp_remote_path))
        self.ue_control_utils.remove_file_on_ftp(ftp_ip, ftp_user, ftp_pass, ftp_remote_path)
        self.logger.debug('File deleted from FTP: {}'.format(ftp_remote_path))

    def release_downlink_ftp_data_transfer(self, pid, ue_local_path):
        """Killing ongoing dt process by pid and removing file on UE"""
        self.kill_proc_by_pid_with_check(pid)
        self.logger.debug('Trying to remove unfinished file on UE: {}'.format(ue_local_path))
        self.ue_control_utils.remove_file_on_android(ue_local_path)
        self.logger.debug('File deleted from UE: {}'.format(ue_local_path))

    def get_mobile_app_protocol_version(self):
        """
        Returns mobile app protocol version number.
        NOTICE version number is different than version. E.g. for UeManager Mobile 1.7.0 version number is 64

        :return:
        """
        return self.ueman.get_mobile_app_protocol_version()

    def is_reader_finish(self, out_reader):
        """Check if output from UE command reader is finished"""
        return out_reader.is_finish()

    def kill_process_with_phrase(self, process_phrase):
        """
        Kills process on UE with phrase provided.
        :param process_phrase: case insensitive process phrase
        :return:
        """
        self.ue_control_utils.kill_process_with_phrase(process_phrase)

    def kill_proc_by_pid_with_check(self, pid):
        """Kills process with pid"""
        self.ue_control_utils.kill_by_pid(pid)
        if not self.is_process_finished(pid):
            raise Exception('Failed to stop data transfer. Unable to kill process with PID: {}'.format(pid))

    def is_process_finished(self, pid):
        """
        Checks if process with pid is running
        Please note, the "ps PID" will return the header row too, for example:
        USER           PID  PPID     VSZ    RSS WCHAN            ADDR S NAME
        :param pid:
        :return:
        """
        cmd = 'ps {}'.format(pid)
        out = self.run_cmd_and_get_non_blocking_output(cmd)
        ps_out = self.ue_control_utils.non_blocking_to_string_by_blocking(out)
        self.logger.debug('Output from is_process_finished cmd "{}": {}'.format(cmd, ps_out))
        result_map = {0: None, 1: True}
        result = result_map.get(len(ps_out), False)
        if result is not None:
            return result
        raise Exception('Failed to confirm process is finished')

    def start_rrc(self, qcat_exe_path, diag_cfg_path):
        """
        Start diag_mdlog on Android UE - start collecting qmdl file with rrc messages from qualcomm chipset
        :param qcat_exe_path: path to QCAT exe on Windows UE PC
        :param diag_cfg_path: path to DIAG.cfg file on Windows UE PC (required to run diag_mdlog application on
        Android UE)
        """
        self.logger.debug('start collecting qmdl file, qcat: {}, DIAG: {}'.format(qcat_exe_path, diag_cfg_path),
                          extra={'ue_id': self.sn_number})
        if self.diag_ue_runner_or_none is not None:
            raise Exception('RRC logs are probably running!')
        self.diag_ue_runner_or_none = self._create_diag_ue_runner()
        self.diag_ue_runner_or_none.start_rrc(qcat_exe_path, diag_cfg_path)

    def set_is_qualcomm(self):
        """Set is_qualcomm_prototype according to yaml configuration file"""
        self.is_qualcomm_prototype = True
        self.ueman.is_qualcomm_prototype = True

    def am_i_qualcomm_prototype(self):
        """UE finds out that it is not real but only a prototype living in endless darkness of a Nokia lab"""
        ue_model = self.get_cached_ue_model()
        for qc_pattern in self.QUALCOMM_PROTOTYPE_PATTERNS:
            if qc_pattern in ue_model:
                self.is_qualcomm_prototype = True
                self.ueman.is_qualcomm_prototype = True

    def _create_diag_ue_runner(self):
        from ta_ue_plugin_android.uepc.rrc_messages import DiagUeRunnerFactory
        return DiagUeRunnerFactory().create_diag_ue_runner(self)

    def get_cached_ue_model(self):
        """
        Lazy get ue model. No need to wait after next calls.
        :return:
        """
        if self.cached_ue_model_or_none is None:
            self.cached_ue_model_or_none = self.get_ue_info("DEVICE_MODEL")
        return self.cached_ue_model_or_none

    def stop_rrc(self, qcat_analyzer=None, rrc_filter_file_path=None, mdm=None):
        """Stop diag_mdlog application on Android UE, convert qmdl to .txt and return path to txt file on UE PC"""
        self.logger.debug('Stop mdlog application', extra={'ue_id': self.sn_number})
        try:
            if self.diag_ue_runner_or_none is None:
                raise Exception('RRC logs are probably not running!')
            self.diag_ue_runner_or_none.stop_rrc(os.path.abspath('logs'), qcat_analyzer, rrc_filter_file_path, mdm)
        except Exception as ex:
            self._oneway_error_to_raise = ex

    def get_stop_rrc_result(self):
        """
        Raises error if stop rrc went wrong.
        :return: decoded_qmdl content
        """
        if self._oneway_error_to_raise is not None:
            self._raise_oneway_error()
        result = self.diag_ue_runner_or_none.get_stop_rrc_result()
        self.logger.info('Stop RRC result: {}'.format(result))
        if result:
            decoded_qmdl_filepath, analyzed_txt_filepaths = result
            self.paths_to_rrc_logs[self.QMDL_FILEPATH] = decoded_qmdl_filepath
            if analyzed_txt_filepaths is None:
                analyzed_txt_filepaths = []
            self.paths_to_rrc_logs[self.RRC_LOGS_TXT_FILEPATHS] = analyzed_txt_filepaths
            self.logger.debug('Paths of qmdl analysis by QCAT: {}'.format(analyzed_txt_filepaths))
            return self._parse_rrc(decoded_qmdl_filepath)
        return None

    def get_path_to_decoded_qmdl_file(self):
        """
        Returns path to decoded qmdl file on uepc if there is any.
        :return: string containing path to qmdl file on UEPC
        """
        if self.QMDL_FILEPATH in self.paths_to_rrc_logs:
            return self.paths_to_rrc_logs[self.QMDL_FILEPATH]
        return 'ERROR'

    def get_path_to_txt_files_created_from_qmdl(self):
        """
        Returns path to txt files created alongside the qmdl file with qxdm.
        :return: array containing paths as strings to .txt files created alongside qxdm file
        """
        if self.RRC_LOGS_TXT_FILEPATHS in self.paths_to_rrc_logs:
            return self.paths_to_rrc_logs[self.RRC_LOGS_TXT_FILEPATHS]
        return 'ERROR'

    def clean_up_after_rrc_logs(self):
        """
        Ensure everything is finished.
        :return:
        """
        try:
            self.diag_ue_runner_or_none.ensure_diag_mdlog_proc_is_ended()
            self.diag_ue_runner_or_none.cleanup_ue()
        finally:
            self.diag_ue_runner_or_none = None

    def _parse_rrc(self, decoded_filepath):
        # modified by abderrahmane.nezrouk@nokia.com to avoid memory crash
        decoded_lst = []
        with open(decoded_filepath, 'r') as f:
            for line in f:
                decoded_lst.append(line)
                if sys.getsizeof(decoded_lst) > LIMIT_MAXSIZE:
                    decoded_lst.append('.....')
                    return decoded_lst
        return decoded_lst

    def is_rooted(self):
        """
        Check if device is rooted.

        :return: if 'su' works on this UE
        """
        if self.is_qualcomm_prototype:
            self.rooted = True
            return self.rooted
        if self.rooted == "unknown":
            self.rooted = self._check_if_ue_is_rooted()
        self.logger.info('UE rooted state: {}'.format(self.rooted), extra={'ue_id': self.sn_number})
        return self.rooted

    def _check_if_ue_is_rooted(self):
        if self.ueman.is_cmd_session_supported_on_mobile():
            out = self.ueman.run_cmd_and_get_non_blocking_output('echo su_works', prog_name='su')
            return not UeControlUtils.check_output(out, 'su_works', timeout=5, time_step=0.2,
                                                   txt_to_fail='Permission denied')
        out = self.ueman.run_cmd_and_get_non_blocking_output(UeControlUtils.CMD_FOR_ROOT_CHECK)
        return UeControlUtils.check_output(out, 'su: not found')

    def start_ue_manager(self, sn_number):
        """
        Starts connection to UE via tcp socket and communicating with UeManager protocol
        :param sn_number: UE serial number
        :return: None
        """
        self.logger.debug('Connecting with UE manager', extra={'ue_id': self.sn_number})
        self.sn_number = sn_number
        self.ueman = UeManagerProtocol(self.sn_number)
        self.is_iperf_shell_field = self._execute_is_iperf_shell()
        self.logger.debug('Successfully connected with UE manager', extra={'ue_id': self.sn_number})

    def stop_ue_manager(self):
        """
        :param func:
        :return:
        """
        if self.ueman:
            self.ueman.close()
            del self.ueman
            self.ueman = None

    def clear_reconnect_queue(self):
        """Clears queue of msgs to resend on reconnect to UE."""
        self.ueman.clear_reconnect_queue()

    def get_current_technology_on_uepc(self):
        """
        Method is used by method AndroidUe::expect_technology

        :return:
        """
        return self.ueman.get_current_technology()

    def attach(self, timeout=30):
        """Make attach."""
        self.logger.info('UE Attach', extra={'ue_id': self.sn_number})
        airplane_mode_status = self.ueman.get_airplane_status()
        is_rooted = self.is_rooted()
        self.logger.info('Is UE rooted? Status = {}'.format(is_rooted))
        if airplane_mode_status == '1':
            self.ueman.attach(is_rooted)
        else:
            self.logger.info('UE already attached, no need to send adb commands (airplane mode status == 0).')
        self.ueman.set_mobile_data_settings('1')
        if not self.wait_for_attach(timeout):
            raise CannotAttachError("Airplane mode not changed")
        if not self._wait_until_cell_id_appear(timeout):
            raise CannotAttachError("Cell id not appeared")

    def turn_mobile_data(self, turn_on, timeout=30):
        """Turn on mobile data, confirm it by getting mobile data settings from UE."""
        mobile_data_switch_value = '1' if turn_on else '0'
        if self.ueman.get_mobile_data_settings() != mobile_data_switch_value:
            self.logger.debug('Mobile data settings on UE is {setting_on_ue} turning it {desired_setting}'.format(
                setting_on_ue='off' if turn_on else 'on', desired_setting='on' if turn_on else 'off'))
            self.ueman.set_mobile_data_settings(mobile_data_switch_value)
            _, succeed = self._loop_until_get_valid_value(
                timeout=timeout,
                lambda_get_value=self.ueman.get_mobile_data_settings,
                lambda_is_value_ok=lambda status: status == mobile_data_switch_value,
                msg_tmp='waiting for mobile data settings to turn to' + mobile_data_switch_value + ' now value = {}',
                refresh_time=1
            )
            return succeed
        self.logger.debug('Mobile data already turned {switch}, no need to turn it {switch} again.'.format(
            switch='on' if turn_on else 'off'))
        return True

    def wait_for_attach(self, timeout=10):
        """
        Wait for attach completion
        :param timeout: time allowed to complete attach
        :return:
        """
        self.logger.info('wait for UE attach', extra={'ue_id': self.sn_number})
        worker = SleepyLoopWorker(timeout=timeout)
        worker.set_get_value_callback(self.ueman.get_airplane_status)
        worker.set_value_validator(lambda airplane_mode_state: airplane_mode_state == '0')
        worker.set_log_value_callback(
            lambda airplane_mode_state: self.logger.info('Airplane Mode Status = {}'.format(airplane_mode_state)))
        _, success = worker.execute_work()
        self.logger.info('wait for attach, success = {}'.format(success), extra={'ue_id': self.sn_number})
        return success

    def _wait_until_cell_id_appear(self, timeout=20):
        worker = SleepyLoopWorker(timeout=timeout)
        worker.set_get_value_callback(self.ueman.get_cell_id)
        worker.set_value_validator(lambda ci: not self._cell_id_empty(ci))
        worker.set_log_value_callback(
            lambda ci: self.logger.debug('Wait for empty cell id after attach, now cell id = {}'.format(ci)))
        _, succeed = worker.execute_work()
        return succeed

    def detach(self, timeout=30):
        """
        :param func:
        :return:
        """
        self.logger.info('UE detach', extra={'ue_id': self.sn_number})
        if self.ueman.get_airplane_status() == '1':
            self.logger.info('UE already detached, no need to send adb commands (airplane mode status == 1).')
            return
        is_rooted = self.is_rooted()
        self.logger.info('Is UE rooted? Status = {}'.format(is_rooted))
        start_time = time.time()
        self.ueman.detach(is_rooted)
        _, succeed = self._loop_until_get_valid_value(
            timeout=timeout, lambda_get_value=lambda: (
                self.ueman.get_last_update_time_airplane_mode(), self.ueman.get_airplane_status()),
            lambda_is_value_ok=lambda time_and_status: time_and_status[0] >= start_time and time_and_status[1] == '1',
            msg_tmp='Last update time airplane mode = {}',
            refresh_time=1)
        if not succeed:
            raise CannotDetachError("Unable to turn on air plane mode")
        is_workaround_model = self.get_cached_ue_model() in self.LTE_CELL_ID_WORKAROUND_MODELS
        if is_workaround_model:
            time.sleep(3)
            return
        _, succeed = self._loop_until_get_valid_value(timeout=timeout,
                                                      lambda_get_value=self.ueman.get_cell_id,
                                                      lambda_is_value_ok=self._cell_id_empty,
                                                      msg_tmp='Wait for empty cell id after detach, now cell id = {}',
                                                      refresh_time=1)
        if not succeed and not is_workaround_model:
            pass
            # raise CannotDetachError("Cell id does not become empty, last cell id = " + str(last_cell_id))

    def _cell_id_empty(self, cell_id):
        return int(cell_id) in [0, -1, 2147483647]

    def _has_signal(self, signal_strength):
        return 'not attached' not in str.lower(str(signal_strength))

    def wait_for_call_finish(self, call_time):
        """
        :param func:
        :return:
        """
        self.logger.info("wait for finish call", extra={'ue_id': self.sn_number})
        end_time = time.time() + call_time
        while time.time() <= end_time:
            next_sleep = time.time() + 1
            calling_state = self.get_calling_state()
            self.logger.info("call step with step %d", call_time)
            if 'OUT' in calling_state or 'INC' in calling_state:
                to_sleep = next_sleep - time.time()
                if to_sleep > 0:
                    time.sleep(to_sleep)
                self.logger.info(calling_state)
                call_time -= 1
                continue
            elif 'IDL' in calling_state:
                self.logger.info("got IDL, break while")
                return 0
        self.logger.debug("call end_call", extra={'ue_id': self.sn_number})
        self.end_call()
        return 1

    def end_call(self):
        """End voice call"""
        self.ueman.end_call()

    def get_calling_state(self):
        """
        Gets calling state
        :return: IDL, OUT1235456, IN123456
        """
        return self.ueman.get_calling_state()

    def call(self, number, call_time):
        """
        :param func:
        :return:
        """
        self.make_call(number)
        if call_time is None:
            return
        time.sleep(2)
        self.wait_for_call_finish(int(call_time))

    def make_call(self, number, with_video=False):
        """
        Makes voice/video call to given number.
        :param number:
        :param with_video:
        """
        self.ueman.make_call(number, with_video)

    def wait_for_new_network_mode(self, new_mode, timeout=12):
        """
        Waits until appear given network mode.
        :param new_mode:
        :param timeout: maybe be float
        :return:
        """
        worker = SleepyLoopWorker(timeout=timeout)
        worker.set_get_value_callback(self.ueman.get_current_preferred_net)
        worker.set_value_validator(lambda mode: mode == new_mode)
        worker.set_log_value_callback(lambda mode: self.logger.info('Current network mode = {}'.format(mode)))
        if worker.is_already_achieved():
            self.logger.info('Current network mode = {}. No need to change.'.format(new_mode))
            return new_mode

        self.ueman.set_network(new_mode)
        result_mode, succeed = worker.execute_work()
        if not succeed:
            raise CanNotChangeNetworkModeError
        return result_mode

    def _change_network_mode_shell_based(self, network_mode):
        rawoutput = self.run_cmd_via_adb("shell", ["settings", "list", "global"])[0]

        entries = []
        for line in rawoutput.split('\n'):
            if "preferred_network_mode" in line:
                line_parsed = line.split("=")[0]
                if line_parsed:
                    entries.append(line_parsed)

        cmds = ["settings put global {} {}".format(entry, self.ueman.network_mode_names2nums[network_mode]) for entry
                in entries]

        multi_cmd_ue_shell_runner = MultiCmdUeShellRunner(self.sn_number, cmds, lambda x: True,
                                                          adb_runner=AdbCmdRunner())
        multi_cmd_ue_shell_runner.run_cmds()

        self.detach()
        self.attach()

    def change_network_mode(self, network_mode, network_mode_switch_method=None):
        """
        :param func:
        :return:
        """
        xposed = "xposed"
        network_mode_switch_methods_mapping = {
            xposed: self.wait_for_new_network_mode,
            "adb": self._change_network_mode_shell_based
        }
        if network_mode_switch_method is None:
            network_mode_switch_method = xposed
        else:
            network_mode_switch_method = network_mode_switch_method.strip().lower()
        if network_mode_switch_method not in network_mode_switch_methods_mapping:
            raise UeManagerException(
                "Unrecognized network mode switch method: '{}'".format(network_mode_switch_method))
        return network_mode_switch_methods_mapping[network_mode_switch_method](network_mode)

    def get_signal_strength(self, timeout=10):
        """
        :param func:
        :return:
        """
        # TODO: maybe enable user to set refresh_time ? now refresh_time = 1 second
        given_signal_strength, succeed = self._loop_until_get_valid_value(timeout=timeout,
                                                                          lambda_get_value=lambda:
                                                                          self.ueman.get_signal(),
                                                                          lambda_is_value_ok=lambda
                                                                              ss: self._has_signal(ss),
                                                                          msg_tmp='Signal strength = {}',
                                                                          refresh_time=1)
        if not succeed:
            return '-1'
        return given_signal_strength

    def get_enb_id(self, timeout=10):
        """

        :param timeout: int in seconds
        :return:
        """
        # TODO: maybe enable user to set refresh_time ? now refresh_time = 1 second
        given_enb_id, succeed = self._loop_until_get_valid_value(timeout=timeout,
                                                                 lambda_get_value=lambda: self.ueman.get_enb_id(),
                                                                 lambda_is_value_ok=lambda enb: enb != '-1',
                                                                 msg_tmp='eNB ID = {}',
                                                                 refresh_time=1)
        if not succeed:
            if self.is_airplane_mode():
                raise NoCellIdUeIsDetachedError('Can not get enb ID, because UE is detached')
            else:
                raise NoCellIdError('Can not get enb ID')
        return given_enb_id

    def get_cell_id(self, timeout=10):
        """

        :param timeout: int in seconds
        :return:
        """
        # TODO: maybe enable user to set refresh_time ? now refresh_time = 1 second
        given_cell_id, succeed = self._loop_until_get_valid_value(timeout=timeout,
                                                                  lambda_get_value=lambda: self.ueman.get_cell_id(),
                                                                  lambda_is_value_ok=lambda cid: cid != '-1',
                                                                  msg_tmp='Cell ID = {}',
                                                                  refresh_time=1)
        if not succeed:
            if self.is_airplane_mode():
                raise NoCellIdUeIsDetachedError('Can not get cell ID, because UE is detached')
            else:
                raise NoCellIdError('Can not get cell ID')
        return given_cell_id

    def get_ip(self, timeout=10):
        """
        Gets the UE IP
        :param timeout: time allowed to get the IP
        :return: UE IP string
        """
        ip, succeed = self._loop_until_get_valid_value(timeout=timeout,
                                                       lambda_get_value=lambda: self.ueman.get_ip(**self.ip_interface),
                                                       lambda_is_value_ok=lambda ip: ip is not None and ip != "",
                                                       msg_tmp='IP = {}',
                                                       refresh_time=1)
        if not succeed:
            raise NoIpError('Can not get IP')
        return ip

    def set_ip_interface_for_mobile_data(self, ip_version=4, interface_name_pattern=None):
        """
        Set ip interface details as a dict with schema: {'interface_name': NAME, 'ip_version': 4 or 6}
        It is used by get_ip method to retrieve desired UE IP
        :param ip_version: int: 4 or 6
        :param interface_name_pattern: interface name pattern to search for
        :return:
        """
        self.ip_interface = {'ip_version': ip_version, 'interface_name_pattern': interface_name_pattern}

    def check_voicemail_notification(self):
        """
        Returns number of voicemail notifications on UE
        :return:voicemail count
        """
        result = self.ueman.check_voicemail_notification()
        return result

    def clear_voicemail_notification(self):
        """
        Clears notification about voicemail. Check voicemail notificaiton will return 0 unless new voicemail
        appears. Also cleans on-screen
        voicemail notifications.
        :return:
        """
        return self.ueman.clear_voicemail_notification()

    def _loop_until_get_valid_value(self, timeout, lambda_get_value, lambda_is_value_ok, msg_tmp, refresh_time):
        """
        :maintainer: Jacek Skoczylas
        :contact: jacek.skoczylas@nokia.com
        """
        end_time = time.time() + float(timeout)
        while end_time >= time.time():
            value = lambda_get_value()
            self.logger.info(msg_tmp.format(value))
            if lambda_is_value_ok(value):
                return value, True
            time.sleep(refresh_time)
        return value, False

    def get_phone_number(self):
        """Returns phone number if present on SIM card."""
        return self.ueman.get_phone_number()

    def get_active_network_technology(self):
        """Returns active network technology."""
        return self.ueman.get_active_network_technology()

    def _get_ue_info_methods_dict(self):
        methods_dict = {'IMSI': self.ueman.get_imsi, 'IMEI': self.ueman.get_imei,
                        'ANDROID_VER': self.ueman.get_android_version,
                        'UE_OS_VER': self.ueman.get_android_version,
                        'DEVICE_MODEL': self.ueman.get_device_model, 'LAC': self.ueman.get_lac,
                        'MCC': self.ueman.get_mcc,
                        'MNC': self.ueman.get_mnc, 'PCI': self.ueman.get_pci, 'CELL_ID': self.get_cell_id,
                        'ENB_ID': self.get_enb_id,
                        'IP': self.get_ip,
                        'SIGNAL_STRENGTH': self.get_signal_strength,
                        'MOBILE_APP_VERSION': self.ueman.get_mobile_app_version}
        return methods_dict

    def get_ue_info(self, info, timeout=None):
        """

        :param info:
        :param timeout: string/int/float in seconds
        :return:
        """
        methods_dict = self._get_ue_info_methods_dict()
        if info not in methods_dict:
            raise ValueError(
                "unsupported info type %s, supported are: %s" % (info, ", ".join(list(methods_dict.keys()))))

        info_output = self._invoke_with_timeout_if_need(info, methods_dict, timeout)
        self.logger.info(info_output, extra={'ue_id': self.sn_number})
        return info_output

    def _invoke_with_timeout_if_need(self, info, methods_dict, timeout):
        """

        :param info:
        :param methods_dict:
        :param timeout: string/int/float in seconds
        :return:
        """
        if timeout is not None and info in ['CELL_ID', 'IP', 'SIGNAL_STRENGTH']:
            return methods_dict[info](timeout)
        return methods_dict[info]()

    def _create_ue_logs_file_handler(self, sn_number):
        logs = os.getcwd()
        self.logger.debug("UEMlogs: " + logs)
        ts = int(time.time())
        logs_filename = os.path.join(logs, 'UE_Manager_Protocol_Logs_{}_{}.txt'.format(sn_number, str(ts)))
        self.ueman.logger.addHandler(logging.FileHandler(logs_filename))

    def is_airplane_mode(self):
        """
        Check if airplane mode is on

        :return: bool
        """
        airplane_status = self.ueman.get_airplane_status()
        return airplane_status == '1'

    def ue_reboot_and_wait_until_it_boots(self, timeout=75):
        """Method reboot android UE and wait until it boots"""
        self.ueman.adb_reboot_and_wait_for_ue(timeout)
        self.logger.info('UE found in adb devices, waiting additional 15 seconds until system boots properly.',
                         extra={'ue_id': self.sn_number})
        time.sleep(15)
        self.logger.info('UE reboot completed', extra={'ue_id': self.sn_number})

    def adb_push_file(self, local_file_path, ue_file_path):
        """Method to push file to Android UE via ADB"""
        self.ueman.adb_push_file(local_file_path, ue_file_path)

    def adb_pull_file(self, local_file_path, ue_file_path):
        """Method to pull file from Android UE via ADB to UE PC"""
        self.ueman.adb_pull_file(local_file_path, ue_file_path)

    def restart_mobile_app(self):
        """Restart UE Manager Mobile application."""
        self.ueman.adb_restart_mobile()

    def run_cmd_via_adb(self, cmd, args_list):
        """Run adb command"""
        result, err = self.ueman.adb_run_cmd(cmd, args_list)
        return result, err

    def is_iperf_shell(self):
        """
        Check if there is iperf shell in /system/bin
        For test see: ute_ue/test/crt_android/local/uepc_test_data_transfers_manager.py test_is_iperf_shell()
        - Why ues this instance of _is_iperf_shell_by_adb_shell?
        - adb shell could be unstable when is calling to many times. Ue Manager has been created to not use adb shell.
        :return: bool
        """
        if self.ueman is None:
            raise NotStartedConnectionException("Please first call method start_ue_manager")
        return self.is_iperf_shell_field

    def _execute_is_iperf_shell(self, timeout=1.5):
        out_reader = self.ueman.run_cmd_and_get_non_blocking_output('iperf 2>&1', prog_name='sh')
        collected_output = []
        time_timeout = time.time() + timeout
        while True:
            result, return_now = self._reader_is_finish_or_timeout(out_reader, collected_output, time_timeout)
            if return_now:
                return result
            if not out_reader.has_line_without_blocking():
                time.sleep(0.01)
                continue
            lines = out_reader.read_lines()
            result, return_now = self._try_parse_lines_is_iperf_shell(lines)
            if return_now:
                return result
            collected_output += lines

    def _reader_is_finish_or_timeout(self, out_reader, collected_output, time_timeout):
        if out_reader.is_finish():
            return self._handle_can_not_parse_is_iperf_shell(collected_output), True
        if time.time() > time_timeout:
            return self._is_iperf_shell_by_adb_shell(), True
        return None, False

    def _try_parse_lines_is_iperf_shell(self, lines):
        """
        :param lines:
        :return: result, return_now
        """
        for line in lines:
            result, return_now = self._try_parse_line_is_iperf_shell(line)
            if return_now:
                return result, True
        return 0, False

    def _try_parse_line_is_iperf_shell(self, line):
        """
        :param line:
        :return: result, return_now
        """
        if "iperf: not found" in line or "iperf: inaccessible" in line:
            return False, True
        if "/data/data/com.magicandroidapps.iperf/bin/iperf" in line:
            return False, True
        if "iperf --help" in line and 'for more information' in line:
            return True, True
        # WARNING: generic atexit() called from legacy shared library
        # Usage: iperf [-s|-c host] [options]
        if "Usage: iperf" in line:
            return True, True
        return None, False

    def _handle_can_not_parse_is_iperf_shell(self, output):
        if self.ueman.is_cmd_session_supported_on_mobile():
            raise Exception("unrecognized iperf output: " + "\n".join(output))
        return self._is_iperf_shell_by_adb_shell()

    def _is_iperf_shell_by_adb_shell(self):
        """
        Check if there is iperf shell in /system/bin
        :return: bool
        """
        out = self._execute_iperf_shell_cmd()
        if "iperf: not found" in out or "iperf: inaccessible" in out:
            return False
        return True

    def _execute_iperf_shell_cmd(self):
        out = os.popen("adb -s %s shell iperf" % self.sn_number).read()
        return out

    def get_iperf_filename(self):
        """Return default iperf filename"""
        return "iperf"

    def run_cmd_and_get_non_blocking_output(self, cmd):
        """Run cmd"""
        if self.is_iperf_shell() and self.is_rooted():
            prog_name = 'su'
        else:
            prog_name = 'sh'
        return self.ueman.run_cmd_and_get_non_blocking_output(cmd, prog_name=prog_name)

    def run_cmd_and_get_output_lines(self, cmd):
        """Get output lines from non blocking reader"""
        reader = self.run_cmd_and_get_non_blocking_output(cmd)
        lines = self.ue_control_utils.non_blocking_to_string_by_blocking(reader)
        return lines

    def get_debug_id(self):
        """Return UE SN"""
        return self.sn_number

    def is_need_echos_validator_on_cmd(self):
        """Is need echos validator on cmd"""
        return False

    def is_able_to_linux_like_process_kill(self):
        """Is able to linux like process kill"""
        return True

    def turn_wifi_on(self):
        """
        Turns on wifi.
        :raises FailToTurnOnWiFi
        :raises UeManagerMobileVersionIncorrect if version of mobile app is too low
        :return: bool
        """
        result = self.ueman.turn_wifi_on()
        if result != 'success':
            if result != 'fail':
                raise UnexpectedCmdResultException(result)
            raise FailToTurnOnWiFi()
        return True

    def turn_wifi_off(self):
        """
        Turns off wifi.
        :raises FailToTurnOffWiFi
        :raises UeManagerMobileVersionIncorrect if version of mobile app is too low
        :return: bool
        """
        result = self.ueman.turn_wifi_off()
        if result != 'success':
            if result != 'fail':
                raise UnexpectedCmdResultException(result)
            raise FailToTurnOffWiFi()
        return True

    def send_sms(self, dest_number, text):
        """
        Send SMS to given number with given text.

        :param dest_number: Determine destination UE number
        :param text:
        :raises UeManagerMobileVersionIncorrect if version of mobile app is too low
        """
        self.ueman.send_sms(dest_number, text)

    def receive_sms(self):
        """
        Pop some SMS captured by mobile app.

        :raises UeManagerMobileVersionIncorrect if version of mobile app is too low
        :return: bool, string, string: success, fromAddress, msgBody
        """
        return self.ueman.receive_sms()

    def set_auto_call_answering(self, call_answering):
        """
        Set call answering to auto.

        :param call_answering:
        :return:
        """
        return self.ueman.set_auto_call_answering(call_answering)

    def is_auto_call_answering(self):
        """Check settings of auto answering mode."""
        return self.ueman.is_auto_call_answering()

    def get_voice_call_state(self, uri=None, return_none_if_no_uri=False):
        """
        :param uri:
        :return: STATE_DIALING, STATE_ACTIVE
        """
        try:
            uri = self._get_suppose_voice_call_uri(uri)
            return self.ueman.voice_call_get_state(uri)
        except Exception as e:
            if return_none_if_no_uri and "Not found call with uri: " in str(e):
                return None
            raise

    def _get_suppose_voice_call_uri(self, uri):
        if uri is None:
            uris = self.list_voice_calls_uris()
            if len(uris) != 1:
                raise DefaultVoiceCallUriUnsuficientException(uris)
            uri = uris[0]
        return uri

    def if_voice_call_state_dialing(self, uri=None):
        # type: (str) -> bool
        """
        Check if specified Voice Call is in state: STATE_DIALING

        :param uri: uri of specific Voice Call.
        :return: bool
        """
        return self.get_voice_call_state(uri) == 'STATE_DIALING'

    def if_voice_call_state_active(self, uri=None):
        # type: (str) -> bool
        """
        Check if specified Voice Call is in state: STATE_ACTIVE

        :param uri: uri of specific Voice Call.
        :return: bool
        """
        return self.get_voice_call_state(uri) == 'STATE_ACTIVE'

    def if_voice_call_state_holding(self, uri=None):
        # type: (str) -> bool
        """
        Check if specified Voice Call is in state: STATE_HOLDING

        :param uri: uri of specific Voice Call.
        :return: bool
        """
        return self.get_voice_call_state(uri) == 'STATE_HOLDING'

    def if_voice_call_state_ringing(self, uri=None):
        # type: (str) -> bool
        """
        Check if specified Voice Call is in state: STATE_HOLDING

        :param uri: uri of specific Voice Call.
        :return: bool
        """
        return self.get_voice_call_state(uri) == 'STATE_RINGING'

    def list_voice_calls_uris(self):
        # type: () -> list(str)
        """
        List uris of voice call on this UE.

        :return:
        """
        return self.ueman.list_voice_calls_uris()

    def voice_call_hold(self, uri=None):
        # type: (str) -> str
        """
        Perform hold specified Voice Call.

        :param uri: uri of specific Voice Call.
        :return: 'success' if ok
        """
        uri = self._get_suppose_voice_call_uri(uri)
        return self.ueman.voice_call_hold(uri)

    def voice_call_unhold(self, uri=None):
        # type: (str) -> str
        """
        Perform unhold specified Voice Call.

        :param uri: uri of specific Voice Call.
        :return: 'success' if ok
        """
        self.logger.info('Trying to retrieve / unhold Voice Call = {}'.format(uri))
        uri = self._get_suppose_voice_call_uri(uri)
        return self.ueman.voice_call_unhold(uri)

    def voice_call_answer_lagacy(self):
        """
        Answer ringing call on UE (legacy).
        :return:
        """
        self.ueman.answer_call()

    def voice_call_answer(self, uri=None, with_video=False):
        # type: (str) -> str
        """
        Perform answer specified Voice Call.

        :param uri: uri of specific Voice Call.
        :param with_video: Boolean to specify if answer with video on.
        :return: 'success' if ok
        """
        uri = self._get_suppose_voice_call_uri(uri)
        self.logger.info('Answering Voice Call = {}'.format(uri))
        return self.ueman.voice_call_answer(uri, with_video)

    def voice_call_upgrade(self, uri=None):
        # type: (str) -> str
        """
        Perform upgrade specified Voice Call.

        :param uri: uri of specific Voice Call.
        :return: 'success' if ok
        """
        uri = self._get_suppose_voice_call_uri(uri)
        self.logger.info('Upgrading Voice Call = {}'.format(uri))
        return self.ueman.voice_call_upgrade(uri)

    def voice_call_downgrade(self, uri=None):
        # type: (str) -> str
        """
        Perform downgrade specified Voice Call.

        :param uri: uri of specific Voice Call.
        :return: 'success' if ok
        """
        uri = self._get_suppose_voice_call_uri(uri)
        self.logger.info('Downgrading Voice Call = {}'.format(uri))
        return self.ueman.voice_call_downgrade(uri)

    def voice_call_disconnect(self, uri=None):
        # type: (str) -> str
        """
        Perform disconnect specified Voice Call.

        :param uri: uri of specific Voice Call.
        :return: 'success' if ok
        """
        uri = self._get_suppose_voice_call_uri(uri)
        self.logger.info('Disconnecting Voice Call = {}'.format(uri))
        return self.ueman.voice_call_disconnect(uri)

    def voice_call_get_conferencable_calls(self, uri):
        # type: (str) -> str
        """
        Perform disconnect specified Voice Call.

        :param uri: uri of specific Voice Call.
        :return: 'success' if ok
        """
        raw_result = self.ueman.voice_call_get_conferencable_calls(uri)
        return raw_result

    def voice_call_conference(self, uri1, uri2):
        # type: (str) -> str
        """
        Perform voice call conference from specified Voice Calls.

        :param uri: uri of specific Voice Call.
        :return: 'success' if ok
        """
        self.logger.info('Creating Voice Call Conference from: {} {}'.format(uri1, uri2))
        self.logger.info('URIs before conference: {}'.format(self.list_voice_calls_uris()))
        raw_result = self.ueman.voice_call_conference(uri1, uri2)
        self.logger.info('URIs after conference: {}'.format(self.list_voice_calls_uris()))
        return raw_result

    def send_ussd_message(self, ussd_request):
        """
        Send specified USSD request.

        :param ussd_request: Code to be sent.
        :return:
        """
        self.logger.info('Sending USSD request:{}'.format(ussd_request))
        self.ueman.send_ussd_message(ussd_request)

    def get_ussd_response(self, ussd_request_response=''):
        """
        Get response for given USSD response.

        :param ussd_request_response: USSD code for which we want to get a response.
        :return:
        """
        return self.ueman.get_ussd_response(ussd_request_response)

    def start_audio_playback(self, audio_file_path, alsa_amixer_cmd, cmd_runner=get_public_adb_cmd_runner()):
        """
        Starts audio playback for voice injection

        :param audio_file_path: path to sound file on UE
        :param alsa_amixer_cmd: command to run alsa mixer on UE. In case default provided command doesn't work,
        and You have discovered a working
        one
        :return:
        """
        self.logger.debug('start_audio_playback on android_control')
        cmd_runner = get_public_adb_cmd_runner()
        self.logger.info('Starting audio playback of file {}'.format(audio_file_path))
        alsa_possible_cmds = ['shell su -c "{}"'.format(alsa_amixer_cmd), 'shell su root "{}"'.format(alsa_amixer_cmd),
                              "shell  {}".format(alsa_amixer_cmd)]
        # TODO add su 0
        # TODO change iteration over possible su cmds, to fixed root check suffix at creation time
        for cmd in alsa_possible_cmds:
            self.logger.info('Trying to call {}.'.format(cmd))
            return_tuple = cmd_runner.adb_read_adb_output(self.sn_number, cmd)
            self.logger.info('Cmd output = {}'.format(return_tuple))
            if 'iface=' in return_tuple[0]:
                self.logger.info('Trying to play audio file {}'.format(audio_file_path))
                return self.ueman.start_audio_playback(audio_file_path)
        raise UeManagerException(
            'All attempts to call {} as root failed! Are You sure You\'re using rooted UE?'.format(alsa_amixer_cmd))

    def get_start_audio_playback_result(self):
        """
        Checks result of start audio playback, whether it has succeeded or failed.

        :return: Message from UE regarding success or failure of audio playback
        """
        return self.ueman.get_start_audio_playback_result()

    def stop_audio_playback(self):
        """
        Stops playing audio previously played on UE
        This won't stop audio playback from apps other than UeManager!
        :return:
        """
        self.logger.info('Stopping playing audio')
        self.ueman.stop_audio_playback()

    def kill_all_voice_calls(self):
        """
        Call all voice calls on UE.
        :return: String 'success' if ok.
        """
        if self.ueman.mobile_app_protocol_version < self.ueman.MIN_VERSION_TO_KILL_ALL_VOICE_CALL:
            raise UeManagerException("Cannot kill all voice calls UeManager mobile version is too old!")

        if self._is_android_version_lower_than(6):
            return self.ueman.end_call()
        return self.ueman.kill_all_voice_calls()

    def voice_call_start_recording(self):
        """
        Starting recording voice calls.
        :return: String 'success' if ok.
        """
        self.ueman.voice_call_start_recording()

    def voice_call_stop_recording(self, dump_to):
        """
        Stopping recording voice calls.
        :param dump_to: path on UE PC where to place the recording
        :return: String 'success' if ok.
        """
        self.ueman.voice_call_stop_recording()

        if not os.path.isabs(dump_to):
            dump_to = os.path.abspath(dump_to)
        if not os.path.exists(dump_to) or not os.path.isdir(dump_to):
            os.makedirs(dump_to)
        self.adb_pull_file(dump_to, "/sdcard/ue_manager/vcrec.3gp")

    def voice_call_send_dtmf(self, uri, character):
        """
        Send DTMF.
        :param uri: uri of specific Voice Call.
        :param character: DTMF character to send
        :return: String 'success' if ok.
        """
        raw_result = self.ueman.voice_call_send_dtmf(uri, character)
        return raw_result

    def voice_call_stop_dtmf(self, uri):
        """
        Stop DTMF.
        :param uri: uri of specific Voice Call.
        :return: String 'success' if ok.
        """
        raw_result = self.ueman.voice_call_stop_dtmf(uri)
        return raw_result

    def disconnect_all_my_voice_calls(self):
        """Disconnect all voice calls"""
        results_dict = {}
        uris = self.list_voice_calls_uris()
        if uris == ['null']:
            self.kill_all_voice_calls()
            return results_dict
        uris = [uri for uri in uris if uri != 'null']
        self.logger.debug('Voice Call URIs = {}'.format(uris))

        for uri in uris:
            try:
                self.logger.info('Disconnecting Voice Call: {}'.format(uri))
                result = self.voice_call_disconnect(uri)
                results_dict[uri] = result
                current_uris = self.list_voice_calls_uris()
                self.logger.debug('Current Voice Call URIs: {}'.format(current_uris))
            except VoiceCallProcessingException as ex:
                results_dict[uri] = {'msg': str(ex), 'exception': str(ex)}
        return results_dict

    def am_i_able_to_advanced_voice_calls(self):
        """
        Check if device can make advanced voice calls.

        :return: bool
        """
        return self.ueman.mobile_app_protocol_version >= self.ueman.MIN_VERSION_TO_ACTION_ON_SINGLE_VOICE_CALL

    def turn_volte_on(self):
        """Enable ability to make voLTE calls."""
        ue_model = self.get_cached_ue_model()
        if 'samsung' in ue_model.lower():
            self.logger.debug('Running samsung specific command to turn on VoLTE.')
            output, err = self.run_cmd_via_adb('shell', ['settings', 'put', 'system', 'voicecall_type', '0'])
            if err:
                raise FailedToSwitchVolteException(
                    'Cannot change VoLTE setting. Output: {} Error: {}'.format(output, err))
        self.logger.debug('Turning on VoLTE via global settings injection.')
        self.run_cmd_via_adb('shell', ['settings', 'put', 'global', 'volte_vt_enabled', '1'])

    def turn_volte_off(self):
        """Disable ability to make voLTE calls."""
        ue_model = self.get_cached_ue_model()
        if 'samsung' in ue_model.lower():
            self.logger.debug('Running samsung specific command to turn off VoLTE.')
            output, err = self.run_cmd_via_adb('shell', ['settings', 'put', 'system', 'voicecall_type', '1'])
            if err:
                raise FailedToSwitchVolteException(
                    'Cannot change VoLTE setting. Output: {} Error: {}'.format(output, err))
        self.logger.debug('Turning off VoLTE via global settings injection.')
        self.run_cmd_via_adb('shell', ['settings', 'put', 'global', 'volte_vt_enabled', '0'])

    def _is_android_version_lower_than(self, check_version):
        android_version = self.get_ue_info('ANDROID_VER')
        nums = android_version.split('.')
        if int(nums[0]) < int(check_version):
            return True
        return False

    def _add_release_method(self, method, *args, **kwargs):
        """
        Do all actions needed on UE before next usage
        :return:
        """
        if not hasattr(self, 'release_methods'):
            return
        self.release_methods.add_method(method, *list(args), **dict(kwargs))

    def release_ue(self):
        """Prepare UE for next test run"""
        self.release_methods.run_methods()
        self.stop_ue_manager()

    def validate_ue_info(self, info, expected_value):
        """
        Validates specified UE info
        Available values are:
        'IMSI' - IMSI number on UE
        'IMEI'- IMEI number on UE
        'ANDROID_VER' - Android version on UE presented as version integer (e.g. 26 for Android Oreo)
        'UE_OS_VER' - As above
        'DEVICE_MODEL' - UE device model
        'LAC' - lac
        'MCC' - mcc
        'MNC' - mnc
        'PCI' - pci
        'CELL_ID' - Cell UE is attached to
        'ENB_ID' - Interchageable with cell id, added for cosmetic reasons. Returns cell UE is attached to
        'IP' - IP address bound to UE
        'SIGNAL_STRENGTH' - Current signal strength
        :param info: Info type we want to check, e.g. IP, Cell ID etc.
        :param expected_value: Value that the specified info should have.
        :return: None
        """
        return self.get_ue_info(info)

    def log_ue_info(self, infos_list=None):
        """
        Logs specified UE infos.
        Available values are:
        Validates specified UE info
        Available values are:
        'IMSI' - IMSI number on UE
        'IMEI'- IMEI number on UE
        'ANDROID_VER' - Android version on UE presented as version integer (e.g. 26 for Android Oreo)
        'UE_OS_VER' - As above
        'DEVICE_MODEL' - UE device model
        'LAC' - lac
        'MCC' - mcc
        'MNC' - mnc
        'PCI' - pci
        'CELL_ID' - Cell UE is attached to
        'ENB_ID' - Interchageable with cell id, added for cosmetic reasons. Returns cell UE is attached to
        'IP' - IP address bound to UE
        'SIGNAL_STRENGTH' - Current signal strength
        You can put a list of values here to log several values at once.
        If no argument is provided, all info is logged by default.
        :param infos_list: List of infos to be logged, 'ALL' by default.
        :return: None
        """
        if infos_list is None:
            infos_list = ['ALL']
        if not isinstance(infos_list, list):
            infos_list = [infos_list]
        if infos_list[0] == "ALL":
            infos_list = self._get_ue_info_methods_dict().keys()
        info_string = ""
        for info in infos_list:
            info_value = self.get_ue_info(info)
            info_row = "{info_type} = {info_value}\n".format(info_type=info, info_value=info_value)
            self.logger.info(info_row)
            info_string += info_row
        return info_string

    def is_ip_interface_setup_supported(self):
        """Does device supports ip interface selection based on ip version and/or name pattern"""
        return True


class DefaultVoiceCallUriUnsuficientException(RunningKeywordException):
    """DefaultVoiceCallUriUnsuficientException"""

    def __init__(self, uris):
        """
        Basic initialization.
        :param uris:
        """
        super(DefaultVoiceCallUriUnsuficientException, self).__init__(
            "Now there is {} voice calls: {}".format(len(uris), uris))
        self.uris = uris
        raw_logger = logging.getLogger("ute_ue.uepc")
        self.logger = LoggerAdapter4EmptyExtra(raw_logger, {'area': 'UECONTROL'})

    def get_number_of_voice_calls(self):
        # type: () -> int
        """
        How many there were voice calls when this exception was raised?

        :return: int
        """
        return len(self.uris)

    def is_any_voice_call(self):
        # type: () -> bool
        """
        Are there were any voice call when this exception was raised?

        :return: bool
        """
        return self.get_number_of_voice_calls() > 0
