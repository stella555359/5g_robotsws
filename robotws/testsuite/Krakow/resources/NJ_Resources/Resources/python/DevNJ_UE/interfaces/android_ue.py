"""
:author: Min Dai
:contact: min.b.dai@nokia-sbell.com
"""
import re
import time
import subprocess
from robot.api import logger
from taf.rfrl.utilities.robot.general import get_builtin_instance
from ta_ue_plugin_android.uepc.ue_manager_exceptions import IperfServerStuckException
from ute_common_abstract_core.exceptions import AliasAlreadyAssignedError
from .common_ue import BasicUe
from ..common.ip import Ip
from ..common.iperf import Iperf
from ..common.at_command import AtCommand
from ..common.udp import Udp
from ..common.cell_info import CellInfo
from robot.libraries.BuiltIn import BuiltIn
from taf.transport.ssh import ssh

iperf_path = '/data/local/tmp/iperf'


class AndroidUe(BasicUe):
    def __init__(self, ue_index, ue_info, ue_version):
        """
        Class for all Android UE functions.
        """
        self.ue_index = ue_index
        self.ue_config = ue_info
        self.ue_version = ue_version
        self.ue_capability = self.ue_config.get('UE_{}'.format(self.ue_index)).get('CAPABILITIES')[-1]
        self.taf_ue = get_builtin_instance(instance_name="taf.ue")
        self.ue_alias = "UE_{}".format(ue_index)
        self.ue_test_pc = None
        self.ue_inuse = False
        self.ue_ip = None
        self.attach_5g_result = True
        self.adblog_flag = BuiltIn().replace_variables('${ADBLogFlag}') == str(True)
        logger.info("ADB Log Flag: {}, type: {}".format(self.adblog_flag, type(self.adblog_flag)))
        self.is_nsa = None
        self.iperf = Iperf(self.ue_config, self.ue_index)
        self.atcmd = AtCommand(self.ue_config, self.ue_index)
        self.udp = Udp()
        self.ip = Ip(self.ue_config)
        self.cell_info = CellInfo()
        self.sshManager = ssh()

    def __repr__(self):
        return self.ue_alias

    def attach_ue(self):
        """
        Attach UE
        """
        self.taf_ue.attach_ue(self.ue_alias)

    def detach_ue(self):
        """
        Detach UE
        """
        self.taf_ue.detach_ue(self.ue_alias)

    def reboot_ue(self, timeout_sec=90):
        """
        Reboot UE
        """
        self.iperf.connect_to_control_pc(alias='cpc_{}'.format(self.ue_index))
        logger.info("\nInfo:Reboot Android {} {}, wait 30s!".format(self.ue_alias, self.iperf.ue_pc_dict.get('sn')),
                    also_console=True)
        self.sshManager.execute(command="adb -s {} reboot".format(self.iperf.ue_pc_dict.get('sn')),
                                connection='cpc_{}'.format(self.ue_index))
        time.sleep(30)
        i = 0
        while i < 4:
            try:
                i += 1
                self.ue_ip = self.ip.fetch_android_ue_addr(self.iperf.ue_pc_dict.get('sn'), self.ue_index)
                break
            except Exception as e:
                ex = e
                time.sleep(5)
        else:
            assert self.ue_ip, "Fetch UE {} Address Failed after retrying for 20 seconds. " \
                               "The last error is: {}".format(self.ue_index, ex)
        time.sleep(10)
        logger.info("\n{} Reboot finished.".format(self.ue_alias), also_console=True)

    def require_ue(self, capabilities):
        """
        Prepares mandatory test environment.
        :param capabilities: Settings required by ue architecture.
                             Capabilities that UE has. like:
                             - REAL_UE
                             - REAL_ANDROID_UE
        """
        try:
            self.taf_ue.require_ue(self.ue_alias, capabilities=capabilities)
        except AliasAlreadyAssignedError:
            pass

    def reserve_ue(self):
        """
        Reserve UE
        """
        self.iperf.connect_to_control_pc(alias='cpc_{}'.format(self.ue_index))
        self.iperf.check_adb_version()
        self.iperf.check_adb_devices_and_restart_adb_service()
        logger.info("\n{} require.".format(self.ue_alias), also_console=True)
        self.require_ue(self.ue_capability)

    def ue_attach_and_start_adb_log(self, ue_index):
        """
        This function is used to perform android UE attach and capture ADB logs

        :param ue_index: UE identifier index
        """
        self.iperf.connect_to_control_pc(alias='cpc_{}'.format(self.ue_index))
        self.iperf.check_adb_version()
        self.iperf.check_adb_devices_and_restart_adb_service()
        self.iperf.remove_adb_logs()
        self.iperf.screen_action()
        try:
            logger.info("\n{} require.".format(self.ue_alias), also_console=True)
            self.require_ue(self.ue_capability)
        except Exception as e:
            logger.info("\n{} require failed, error msg is {}.".format(self.ue_alias, e), also_console=True)
        self.start_to_catch_ue_adb_logs(self.iperf.ue_pc_dict.get('sn'))
        logger.info("\n{} Detach begin!".format(self.ue_alias), also_console=True)
        self.detach_ue()
        time.sleep(10)
        logger.info("\n{} Attach begin!".format(self.ue_alias), also_console=True)
        self.attach_ue()
        self.ue_inuse = True
        time.sleep(30)

    def check_adb_devices_and_reboot_uepc(self):
        """
        Sometimes UE is "adb offline", reboot UE PC as a workaround.
        """
        try:
            self.iperf.check_adb_devices_and_reboot_ue_pc()
        except Exception as e:
            raise Exception("\nCheck ADB devices and reboot uepc failed, error msg is {}.".format(e))

    def fetch_ue_address(self):
        """
        This function is used to get Android assigned IP.
        """
        try:
            self.ip.fetch_android_ue_addr(self.iperf.ue_pc_dict.get('sn'), self.ue_index)
        except Exception as e:
            raise Exception("\nFetch UE address failed, error msg is {}.".format(e))

    def start_and_verify_dl_udp(self, dt_name, ue_index, direction, duration, iperf_throughput, protocol,
                                dl_expect_tput, dl_deviation):
        """
        Android down-link UDP call with Serial method.
        This function is used to perform and verify Android UE down-link data transfer.

        :param dt_name: name to be assigned to dats transfer
        :param ue_index: UE identifier index
        :param direction: dl
        :param duration: data transfer duration in robot time string format
        :param iperf_throughput: desired data transfer throughput, format should be e.g 80M
        :param protocol: udp
        :param dl_expect_tput: desired average data transfer throughput
        :param dl_deviation: acceptable deviation, format should be similar to 20%
        """
        if not self.attach_5g_result:
            assert False, "5G attach fail, DL tput will not start"
        logger.info("\nStart DL Data Transfer!", also_console=True)
        self.start_data_transfer(dt_name, direction, duration, iperf_throughput, protocol)
        time.sleep(10)
        self.check_data_transfer_is_alive(dt_name)
        self.await_data_transfer_finish(dt_name)
        logger.info("\nVerify DL Data Tput", also_console=True)
        try:
            self.verify_average_throughput_with_deviation(dt_name, dl_expect_tput, dl_deviation)
        except Exception as e:
            raise Exception("Verify Average Throughput With Deviation Failed: {}".format(e))

    def start_and_verify_ul_udp(self, dt_name, ue_index, direction, duration, iperf_ul_throughput, protocol,
                                ul_expect_tput, ul_deviation):
        """
        Android up-link UDP call with Serial method.
        This function is used to perform and verify Android UE up-link data transfer.

        :param dt_name: name to be assigned to dats transfer
        :param ue_index: UE identifier index
        :param direction: ul
        :param duration: data transfer duration in robot time string format
        :param iperf_ul_throughput: desired data transfer throughput, format should be e.g 80M
        :param protocol: udp
        :param ul_expect_tput: desired average data transfer throughput
        :param ul_deviation: acceptable deviation, format should be similar to 20%
        """
        if not self.attach_5g_result:
            assert False, "5G attach fail, DL tput will not start"
        logger.info("\nStart UL Data Transfer!", also_console=True)
        self.start_data_transfer(dt_name, direction, duration, iperf_ul_throughput, protocol)
        time.sleep(10)
        self.check_data_transfer_is_alive(dt_name)
        self.await_data_transfer_finish(dt_name)
        logger.info("\nVerify UL Data Tput", also_console=True)
        try:
            self.verify_average_throughput_with_deviation(dt_name, ul_expect_tput, ul_deviation)
        except Exception as e:
            raise Exception("Verify Average Throughput With Deviation Failed: {}".format(e))

    def android_start_dl_iperf_process_with_cmd(self, t_put, t_put_duration, size='20M'):
        """
        This keyword used to start iperf process on both UTE VM and UE PC for Android UE DL data transfer,
        need put iperf under /data/local/tmp firstly.

        :param t_put: desired data transfer throughput, format should be e.g 80M
        :param t_put_duration: data transfer duration in robot time string format
        :param size: size of data packet sent at the same time, default is 20M
        """
        logger.info("\nBegin to generate DL data transfer UDP port.", also_console=True)
        used_port_list = self.udp.get_occupied_udp_port_list()
        iperf_port_num = self.udp.get_available_udp_port(used_port_list)
        logger.info("\nThe UDP port used for DL data transfer is {}.".format(iperf_port_num), also_console=True)
        dl_cmd_on_ue_pc = 'adb -s {} shell {} -s -u -l1400 -w {} -i1 -p {} 2>&1 > /tmp/DL_iperf_{}.log'.format(
            self.iperf.ue_pc_dict.get('sn'), iperf_path, size, iperf_port_num, self.ue_index)
        logger.info("\nDL CMD on UE PC: {}".format(dl_cmd_on_ue_pc), also_console=True)
        self.sshManager.send_command(command=dl_cmd_on_ue_pc, connection='cpc_{}'.format(self.ue_index))
        time.sleep(1)
        logger.info("\nBegin to perform DL data traffic with throughput {}.".format(t_put), also_console=True)
        if not self.ue_ip:
            self.ue_ip = self.ip.fetch_android_ue_addr(self.iperf.ue_pc_dict.get('sn'), self.ue_index)
        iperf_cmd_on_app = 'iperf -c {} -u -i1 -l1400 -w {} -p {} -b {} -t {}'.format(self.ue_ip, size, iperf_port_num,
                                                                                      t_put, t_put_duration)
        logger.info("\nDL CMD on APP Server: {}".format(iperf_cmd_on_app), also_console=True)
        self.sshManager.execute(command=iperf_cmd_on_app, connection='APP_Server_{}'.format(self.ue_index))
        time.sleep(1)
        logger.info(
            "Successfully perform DL data traffic with throughput {} duration is {}.".format(t_put, t_put_duration),
            also_console=True)

    def android_start_ul_iperf_process_with_cmd(self, t_put, t_put_duration):
        """
        This keyword used to start iperf process on both UTE VM and UE PC for Android UE UL data transfer
        need put iperf under /data/local/tmp firstly.

        :param t_put: desired data transfer throughput, format should be e.g 80M
        :param t_put_duration: data transfer duration in robot time string format
        """
        # cpctmp = self.ue_pc_dict_list
        logger.info("\nBegin to generate UL data transfer UDP port.", also_console=True)
        used_port_list = self.udp.get_occupied_udp_port_list()
        ul_port_num = self.udp.get_available_udp_port(used_port_list)
        logger.info("\nThe UDP port used for UL data transfer is {}.".format(ul_port_num), also_console=True)
        logger.info("\nBegin to perform UL data traffic with T-Put {}.".format(t_put), also_console=True)
        if not self.ue_ip:
            self.ue_ip = self.ip.fetch_android_ue_addr(self.iperf.ue_pc_dict.get('sn'), self.ue_index)
        ul_cmd_on_ue_pc = 'adb -s {} shell {} -c {} -u -i1 -l1400 -p {} -t {} -b {}'.format(
            self.iperf.ue_pc_dict.get('sn'), iperf_path, self.ip.ute_iperf_itf_ip_dict.get(self.ue_index),
            ul_port_num, t_put_duration, t_put)
        logger.info("\nUL CMD on UE PC: {}".format(ul_cmd_on_ue_pc), also_console=True)
        self.sshManager.send_command(command=ul_cmd_on_ue_pc, connection='cpc_{}'.format(self.ue_index))
        ul_cmd_on_app_server = 'iperf -s -u -i1 -p {} -t {} 2>&1 > /tmp/UL_iperf_{}.log'.format(ul_port_num,
                                                                                                t_put_duration,
                                                                                                self.ue_index)
        logger.info("\nUL CMD on APP Server: {}".format(ul_cmd_on_app_server), also_console=True)
        self.sshManager.execute(command=ul_cmd_on_app_server, connection='APP_Server_{}'.format(self.ue_index))
        time.sleep(1)
        logger.info(
            "Successfully perform UL data traffic with throughput {} duration is {}.".format(t_put, t_put_duration),
            also_console=True)

    def start_dl_async_process(self, index, t_put, tput_dura, protocol, data_trans_name):
        """
        This keyword used to start DL Async process for some OAM operation, while data transfer is not interrupted.

        :param index: UE identifier index
        :param t_put: desired data transfer throughput, format should be e.g 80M
        :param tput_dura : data transfer duration in robot time string format
        :param protocol : tcp or udp
        :param data_trans_name : data transfer name for android UE
        """
        logger.info("\nTrigger Android {} Async DL data transfer.".format(self.ue_alias), also_console=True)
        self.start_data_transfer(dt_name=data_trans_name, direction='dl',
                                 duration=tput_dura, throughput=t_put, protocol=protocol)

    def start_ul_async_process(self, index, t_put, tput_dura, protocol, data_trans_name):
        """
        This keyword used to start UL Async process for some OAM operation, while data transfer is not interrupted.

        :param index: UE identifier index
        :param t_put: desired data transfer throughput, format should be e.g 80M
        :param tput_dura: data transfer duration in robot time string format
        :param protocol: tcp or udp
        :param data_trans_name: data transfer name for android UE
        """
        logger.info("\nTrigger Android {} Async UL data transfer.".format(self.ue_alias), also_console=True)
        self.start_data_transfer(dt_name=data_trans_name, direction='ul',
                                 duration=tput_dura, throughput=t_put, protocol=protocol)

    def calculate_and_verify_dl_async_tput(self, index, expect_tput, deviation, tput_dura,
                                           data_trans_name='dl_test', protocol='udp'):
        """
        This function is used to calculate and verify Android UE DL Async T-Put.

        :param index: UE identifier index
        :param expect_tput: desired average data transfer throughput
        :param deviation: acceptable deviation, format should be similar to 20%
        :param tput_dura: data transfer duration in robot time string format
        :param data_trans_name : data transfer name for android UE
        :param protocol: tcp or udp
        """
        logger.info("\nBegin to check whether Android {} DL Async data transfer is alive.".format(self.ue_alias),
                    also_console=True)
        self.check_data_transfer_is_alive(data_trans_name)
        logger.info("\nBegin to check whether Android {} DL Async data transfer is FINISHED.".format(self.ue_alias),
                    also_console=True)
        self.await_data_transfer_finish(data_trans_name)
        logger.info("\nAndroid {} DL Async data transfer is COMPLETED, begin to VERIFY its result.".format(
            self.ue_alias), also_console=True)
        try:
            self.verify_average_throughput_with_deviation(data_trans_name, expect_tput, deviation)
        except Exception as e:
            raise Exception("Verify Average Throughput With Deviation Failed: {}".format(e))

    def calculate_and_verify_ul_async_tput(self, index, expect_tput, deviation, tput_dura,
                                           data_trans_name='ul_test', protocol='udp'):
        """
        This function is used to calculate and verify Android UE UL Async T-Put, KW dev internal usage.

        :param index: UE identifier index
        :param expect_tput: desired average data transfer throughput
        :param deviation: acceptable deviation, format should be similar to 20%
        :param tput_dura: data transfer duration in robot time string format
        :param data_trans_name : data transfer name for android UE
        :param protocol: tcp or udp
        """
        logger.info("\nBegin to check whether Android {} UL Async data transfer is alive.".format(self.ue_alias),
                    also_console=True)
        self.check_data_transfer_is_alive(data_trans_name)
        logger.info("\nBegin to check whether Android {} UL Async data transfer is FINISHED.".format(self.ue_alias),
                    also_console=True)
        self.await_data_transfer_finish(data_trans_name)
        logger.info("\nAndroid {} UL Async data transfer is COMPLETED, begin to VERIFY its result.".format(
            self.ue_alias), also_console=True)
        try:
            self.verify_average_throughput_with_deviation(data_trans_name, expect_tput, deviation)
        except Exception as e:
            raise Exception("Verify Average Throughput With Deviation Failed: {}".format(e))

    def get_cell_id(self):
        """
        This function is used to get UE cell id from UE info.

        :return (str): ue cell id info
        """
        return self.taf_ue.get_ue_info(self.ue_alias, 'CELL_ID')

    def start_data_transfer(self, dt_name, direction, duration, throughput, protocol):
        """
        Start data transfer on UE. And Verifies that data transfer is started.

        :param dt_name: Data transfer alias, you must use it later on to reference given transfer.
        :param direction: Transfer direction: can be download or upload, eg. 'dl' or 'ul' or 'simultaneous_ul_dl'
        :param duration: Duration of data transferring, eg. '300s'
        :param throughput: desired data transfer throughput in iperf string format. e.g.  '100 MBytes/sec'
              :units:
                - 'bits/sec'
                - 'Kbits/sec'           1 000 bits/sec
                - 'Mbits/sec'       1 000 000 bits/sec
                - 'Gbits/sec'   1 000 000 000 bits/sec
                - 'Bytes/sec'               8 bits/sec
                - 'KBytes/sec'          1 000 Bytes/sec
                - 'MBytes/sec'      1 000 000 Bytes/sec
                - 'GBytes/sec'  1 000 000 000 Bytes/sec
              Note: not applicable to the TCP protocol (iperf 2)
        :param protocol: Data transfer protocol, can be only 'tcp', or 'udp'
        """
        self.taf_ue.start_data_transfer(
            dt_name=dt_name,
            ue_alias=self.ue_alias,
            direction=direction,
            duration=duration,
            throughput=throughput,
            protocol=protocol,
        )

    def await_data_transfer_finish(self, dt_name):
        """
        Awaits data transfer finish

        :param dt_name: Data transfer alias
        """
        self.taf_ue.await_data_transfer_finish(dt_name=dt_name)

    def check_data_transfer_is_alive(self, dt_name):
        """
        Checks if data transfer between client and server is progressing.

        :param dt_name: Data transfer alias
        :raises NoDataTransfer exception when there is no data transfer detection.
        """
        try:
            self.taf_ue.check_data_transfer_is_alive(dt_name=dt_name)
        except IperfServerStuckException as msg:
            raise Exception("There is no data transfer running between client and server! Error msg is {}".format(msg))

    def verify_average_throughput_with_deviation(self, dt_name, throughput, deviation):
        """
        Verifies average throughput with deviation

        :param dt_name: Data transfer alias
        :param throughput: Amount of data transfer throughput, eg. '558 Mbits/sec'
        :param deviation: Percentage of accepted data deviation, eg. '10%'
        """
        self.taf_ue.verify_average_throughput_with_deviation(dt_name, throughput, deviation)

    def is_exception_ue(self):
        """
        check UE type by serial number
        """
        exception_ue_list = ['ELS_AN00', 'TAS_AN00']
        self.iperf.connect_to_control_pc(alias='cpc_{}'.format(self.ue_index))
        device_type = self.get_adb_devices_type(serial_number=self.iperf.ue_pc_dict.get('sn'),
                                                cpc_alias='cpc_{}'.format(self.ue_index))

        return 'True' if device_type in exception_ue_list else 'False'

    def android_dl_traffic_with_cmd(self, duration, iperf_throughput, dl_expect_tput, dl_deviation, window_size):
        """
        This function is used to perform and verify Android UE UDP down-link data transfer without UE Manager

        :param duration: data transfer duration in robot time string format
        :param iperf_throughput: desired data transfer throughput, format should be e.g 80M
        :param dl_expect_tput: desired average data transfer throughput
        :param dl_deviation: acceptable deviation, format should be similar to 20%
        :param window_size: window size foe cmd, default is 20M
        """
        self.iperf.login_app_server(conn_alias='APP_Server_{}'.format(self.ue_index))
        self.android_start_dl_iperf_process_with_cmd(iperf_throughput, duration, window_size)
        self.iperf.get_and_kill_iperf_process_on_remote('cpc_{}'.format(self.ue_index))
        self.iperf.get_and_kill_iperf_process_on_remote('APP_Server_{}'.format(self.ue_index))
        try:
            self.android_ue_calculate_and_verify_dl_tput_with_cmd(dl_expect_tput, dl_deviation)
        except Exception as e:
            raise Exception("Calculate and verify DL throughput failed! Error msg is {}".format(e))
        self.sshManager.disconnect('APP_Server_{}'.format(self.ue_index))

    def android_ul_traffic_with_cmd(self, duration, iperf_ul_throughput, ul_expect_tput, ul_deviation):
        """
        This function is used to perform and verify Android UE UDP uplink data transfer without UE Manager

        :param duration: data transfer duration in robot time string format
        :param iperf_ul_throughput: desired data transfer throughput, format should be e.g 80M
        :param ul_expect_tput: desired average data transfer throughput
        :param ul_deviation: acceptable deviation, format should be similar to 20%
        """
        self.iperf.login_app_server(conn_alias='APP_Server_{}'.format(self.ue_index))
        self.android_start_ul_iperf_process_with_cmd(iperf_ul_throughput, duration)
        self.iperf.get_and_kill_iperf_process_on_remote('cpc_{}'.format(self.ue_index))
        self.iperf.get_and_kill_iperf_process_on_remote('APP_Server_{}'.format(self.ue_index))
        try:
            self.android_ue_calculate_and_verify_ul_tput_with_cmd(ul_expect_tput, ul_deviation)
        except Exception as e:
            raise Exception("Calculate and verify UL throughput failed! Error msg is {}".format(e))
        self.sshManager.disconnect('APP_Server_{}'.format(self.ue_index))

    def android_ue_calculate_and_verify_dl_tput_with_cmd(self, expect_tput, deviation):
        """
        This function is used to calculate and verify Android UE DL T-Put with deviation triggered by CMD

        :param expect_tput : desired average data transfer throughput
        :param deviation : acceptable deviation, format should be similar to 20%
        """
        output_dir = BuiltIn().replace_variables('${OUTPUT_DIR}') + '/DL_iperf_{}.log'.format(self.ue_index)
        self.sshManager.download_file(remote_path='/tmp/DL_iperf_{}.log'.format(self.ue_index),
                                      local_path=output_dir,
                                      connection='cpc_{}'.format(self.ue_index))
        dt_dl_row_list = self.iperf.parse_iperf_trace_to_rows(file_to_be_parsed=output_dir)
        t_put = self.iperf.count_average_throughput(iperf_row_list=dt_dl_row_list)
        return_result = self.iperf.check_tput_with_deviation(expect_tput=expect_tput, average_tput=t_put,
                                                             deviation=deviation)
        assert return_result == 'Success', "android_ue_calculate_and_verify_dl_tput_with_cmd failed"

    def android_ue_calculate_and_verify_ul_tput_with_cmd(self, expect_tput, deviation):
        """
        This function is used to calculate and verify Android UE UL T-Put with deviation triggered by CMD

        :param expect_tput : desired average data transfer throughput
        :param deviation : acceptable deviation, format should be similar to 20%
        """
        output_dir = BuiltIn().replace_variables('${OUTPUT_DIR}') + '/UL_iperf_{}.log'.format(self.ue_index)
        self.sshManager.download_file(remote_path='/tmp/UL_iperf_{}.log'.format(self.ue_index),
                                      local_path=output_dir,
                                      connection='APP_Server_{}'.format(self.ue_index))
        dt_ul_row_list = self.iperf.parse_iperf_trace_to_rows(file_to_be_parsed=output_dir)
        t_put = self.iperf.count_average_throughput(iperf_row_list=dt_ul_row_list)
        return_result = self.iperf.check_tput_with_deviation(expect_tput=expect_tput, average_tput=t_put,
                                                             deviation=deviation)
        logger.info("\n---return_result: {}---".format(return_result))
        assert return_result == 'Success', "android_ue_calculate_and_verify_ul_tput_with_cmd failed"

    def get_adb_devices_type(self, serial_number, cpc_alias):
        """
        check UE type by serial number
        """
        try:
            output_result = self.atcmd.send_at_cmd_to_ue('adb devices -l', cpc_alias)
            lines = output_result.splitlines()
            for line in lines:
                if serial_number in line:
                    device_line = line
                    break
            assert device_line, "Not found SN:{} in ADB devices".format(serial_number)
            device_col = device_line.split()
            uepc_os_type = self.get_uepc_type(cpc_alias)
            if uepc_os_type.lower() == 'linux':
                device_col_num = 4
            else:
                device_col_num = 3
            device_type = device_col[device_col_num][6:]
            return device_type
        except Exception as msg:
            raise Exception("Get the ADB device information failed! Error msg is {}".format(msg))

    def get_uepc_type(self, cpc_alias):
        """
        get the OS type of UE PC
        """
        try:
            output_result = self.atcmd.send_at_cmd_to_ue('uname', cpc_alias)
            os_type = output_result[0:5]
            return os_type
        except Exception as msg:
            raise Exception("Get the OS type of UE PC failed! Error msg is {}".format(msg))

    def ue_postcondition(self, ue_num):
        """
        This function is used to perform specific index Android UE teardown operation.
        """
        if self.ue_inuse:
            self.detach_ue()
            time.sleep(2)
            self.sshManager.disconnect(connection='cpc_{}'.format(self.ue_index))
            try:
                self.sshManager.disconnect(connection='APP_Server_{}'.format(self.ue_index))
            except Exception:
                pass

    def verify_5g_success_and_stop_adb_log(self, lte_cell_index):
        """
        This function is used to verify attached result via ADB log.

        :param lte_cell_index: the cell index which UE attach to
        """
        self.save_to_remote_and_stop_adb_logcat()
        if self.adblog_flag:
            self.attach_5g_result = False
        else:
            self.attach_5g_result = True
        self.adb_log_verify_for_all_ue_type(lte_cell_index)
        return self.attach_5g_result

    def save_to_remote_and_stop_adb_logcat(self):
        """
        Stop catching UE ADB log and save it to UTE.
        """
        if not self.adblog_flag:
            return
        logger.info("\nSave and stop ADB logcat for {}.".format(self.ue_alias), also_console=True)
        output_dir = BuiltIn().replace_variables('${OUTPUT_DIR}') + '/ADB_{}.log'.format(self.ue_index)
        self.sshManager.download_file(remote_path='/tmp/ADB_{}.log'.format(self.ue_index),
                                      local_path=output_dir,
                                      connection='cpc_{}'.format(self.ue_index))
        time.sleep(2)
        self.stop_all_adb_logcat_process_of_ue()

    def stop_all_adb_logcat_process_of_ue(self):
        """
        Stop catching UE ADB Logcat process
        """
        serial_number = self.iperf.ue_pc_dict.get('sn')
        uepc_os_type = self.get_uepc_type('cpc_{}'.format(self.ue_index))
        if uepc_os_type == 'windo':
            ps_command = 'adb -s {} shell ps'.format(serial_number)
        else:
            ps_command = 'ps -ef|grep {}'.format(serial_number)
        self.sshManager.send_command(command=ps_command, connection='cpc_{}'.format(self.ue_index))
        result = self.sshManager.read_output(connection='cpc_{}'.format(self.ue_index))
        result_pid = ((subprocess.check_output("echo '{}' | grep logcat | awk '{{print $2}}'".format(result),
                                               shell=True)).decode('utf-8')).splitlines()
        logger.info("\n---result_pid---:{}".format(result_pid))
        for line in result_pid:
            if uepc_os_type == 'windo':
                kill_command = 'adb -s {} shell kill -9 {}'.format(serial_number, line)
            else:
                kill_command = 'kill -9 {}'.format(line)
            self.sshManager.send_command(command=kill_command, connection='cpc_{}'.format(self.ue_index),
                                         timeout=5)

    def stop_adb_log(self):
        """
        Stop catching UE ADB log
        """
        if not self.adblog_flag:
            return
        try:
            self.iperf.connect_to_control_pc(alias='cpc_{}'.format(self.ue_index))
            self.stop_all_adb_logcat_process_of_ue()
        except Exception as msg:
            raise Exception("Stop ADB log failed! Error msg is {}".format(msg))

    def adb_log_verify_for_all_ue_type(self, cell_index):
        """
        Check ue attach result in ADB logs. Support Huawei and Qualcomm chipset UE.

        :param cell_index : cell index which support both NSA and SA mode
        """
        if not self.adblog_flag:
            return
        self.is_nsa = self.cell_info.bts_mode
        serial_number = self.iperf.ue_pc_dict.get('sn')
        if self.is_nsa == 'NSA':
            lte_cell_dict = self.cell_info.get_anchor_enb_info()
            cell_tmp = lte_cell_dict.get(cell_index)
        else:
            gnb_pci_list, gnb_cell_dict = self.cell_info.get_gnb_cell_info()
            logger.info("\n---gnb_pci_list---:{}".format(gnb_pci_list))
            logger.info("\n---gnb_cell_dict---:{}".format(gnb_cell_dict))
            logger.info("\n---cell_index---:{}, type:{}".format(cell_index, type(cell_index)))
            cell_tmp = gnb_cell_dict.get(cell_index)
        logger.info("\n---cell_tmp---:{}".format(cell_tmp))
        ue_android_ver = self.get_ue_android_version(serial_number=serial_number)
        is_hw = self.is_huawei_ue(serial_number=serial_number,
                                  cpc_alias='cpc_{}'.format(self.ue_index))
        if is_hw:
            self.adb_log_verify_for_huawei_ue_5g_setup(serial_number,
                                                       cell_tmp['pci'],
                                                       cell_tmp['nrarfcn'],
                                                       ue_android_ver,
                                                       gnb_pci_list)
        else:
            self.adb_log_verify_qualcomm_5g_ue_setup(cell_tmp['pci'],
                                                     cell_tmp['earfcn'],
                                                     ue_android_ver)
        logger.info("\n{} 5G Attached={}!".format(self.ue_alias, self.attach_5g_result), also_console=True)

    def get_ue_android_version(self, serial_number):
        """
        Get the Android version of UE
        """
        self.sshManager.send_command(
            command='adb -s {} shell getprop ro.build.version.release'.format(serial_number),
            connection='cpc_{}'.format(self.ue_index), timeout=5)
        result = self.sshManager.read_output(connection='cpc_{}'.format(self.ue_index))
        version = ((subprocess.check_output("echo '{}'|tr -d '\r\n'".format(result), shell=True)).
                   decode('utf-8')).strip()
        logger.info("\nUE android version is {}.".format(version), also_console=True)
        return version

    def is_huawei_ue(self, serial_number, cpc_alias):
        """
        check UE type by serial number

        :param serial_number: the serial number of phone
        :param cpc_alias: alias of cpc connection
        """
        device_type = self.get_adb_devices_type(serial_number=serial_number, cpc_alias=cpc_alias)
        if device_type == 'EVR_AN00' or device_type == 'TAS_AN00' or device_type == 'LIO_AN00':
            return True
        else:
            return False

    def adb_log_verify_for_huawei_ue_5g_setup(self, serial_number, lte_pci, lte_earfcn, ue_android_ver, gnb_pci_list):
        """
        ADB log verify for Huawei UE 5G setup

        :param serial_number: the serial number of phone
        :param lte_pci: LTE cell pci
        :param lte_earfcn: earfcnDL in the eNB bts
        :param ue_android_ver: UE android version
        :param gnb_pci_list: gNB PCI list
        """
        if self.is_nsa == 'NSA':
            self.verify_huawei_ue_4g_setup_by_adb_log(serial_number, lte_pci, lte_earfcn)
        else:
            self.verify_huawei_ue_5g_setup_by_adb_log(gnb_pci_list)
        logger.info("\nADB log verify for Huawei UE 5G setup.")
        if ue_android_ver == '9':
            self.check_huawei_5g_android_9_log(lte_pci)
        else:
            self.check_huawei_5g_android_10_log()

    def adb_log_verify_qualcomm_5g_ue_setup(self, lte_pci, lte_earfcn, ue_android_ver):
        """
        This function is used to verify 4G and 5G UE setup successfully via ADB log.

        :param lte_pci: LTE cell pci
        :param lte_earfcn: earfcnDL in the eNB bts
        :param ue_android_ver: UE android version
        """
        self.verify_qualcomm_4g_ue_setup_by_adb_log(lte_pci, lte_earfcn, ue_android_ver)
        cmd = "cat " + BuiltIn().replace_variables('${OUTPUT_DIR}') + \
              "/ADB_{}.log | grep is5GConnected | grep TCPBuffer | tail -1".format(self.ue_index)
        result = ((subprocess.check_output(cmd, shell=True)).decode('utf-8')).strip()
        logger.info("\n---result:{}---".format(result))
        pattern = re.compile(r'is5GConnected.? true')
        attach_result = pattern.search(result)
        logger.info("\n---attach_result:{}---".format(attach_result))
        if not attach_result:
            self.attach_5g_result = False
            raise Exception("\n{} attach to 5G failed!".format(self.ue_alias))
        else:
            self.attach_5g_result = True

    def verify_huawei_ue_4g_setup_by_adb_log(self, serial_number, lte_pci, lte_earfcn):
        """
        This function is used to verify 4G setup successfully via ADB log.

        :param serial_number: the serial number of phone

        :param lte_pci: LTE cell pci
        :param lte_earfcn: earfcnDL in the eNB bts
        """
        cmd1 = "grep 'current RAT is LTE' " + BuiltIn().replace_variables('${OUTPUT_DIR}') + \
               "/ADB_{}.log |tail -1".format(self.ue_index)
        result = ((subprocess.check_output(cmd1, shell=True)).decode('utf-8')).strip()
        if 'current RAT is LTE' not in result:
            raise Exception("Current RAT is not LTE!")
        cmd2 = "cat " + BuiltIn().replace_variables('${OUTPUT_DIR}') + \
               "/ADB_{}.log|grep mRegistered=YES|sed 's/INFO_LIST/\\n/g'>".format(self.ue_index) + \
               BuiltIn().replace_variables('${OUTPUT_DIR}') + "/adbtmp"
        subprocess.check_output(cmd2, shell=True)
        cmd3 = "cat " + BuiltIn().replace_variables('${OUTPUT_DIR}') + \
               "/adbtmp|sed 's/CellIdentityLte/\\n/g; s/CellSignalStrengthLte/\\n/g'|grep mPci|uniq"
        result = ((subprocess.check_output(cmd3, shell=True)).decode('utf-8')).strip()
        if 'mPci={}'.format(lte_pci) in result and 'mEarfcn={}'.format(lte_earfcn) in result:
            cmd = "rm -f " + BuiltIn().replace_variables('${OUTPUT_DIR}') + "/adbtmp"
            subprocess.check_output(cmd, shell=True)
        else:
            raise Exception("Check ADB log for pci and earfcn failed!")

    def verify_huawei_ue_5g_setup_by_adb_log(self, gnb_pci_list):
        """
        This function is used to check ADB log for pci and earfcn under NR SA scenario

        :param gnb_pci_list: gNB PCI list
        """
        cmd1 = "grep 'Network type NR' " + BuiltIn().replace_variables('${OUTPUT_DIR}') + \
               "/ADB_{}.log | tail -2".format(self.ue_index)
        result = ((subprocess.check_output(cmd1, shell=True)).decode('utf-8')).strip()
        if 'Network type NR' not in result:
            raise Exception("Current Network Type is not NR!")
        cmd2 = "cat " + BuiltIn().replace_variables('${OUTPUT_DIR}') + \
               "/ADB_{}.log|grep mRegistered=YES|sed 's/INFO_LIST/\\n/g'>".format(self.ue_index) + \
               BuiltIn().replace_variables('${OUTPUT_DIR}') + "/adbtmp"
        subprocess.check_output(cmd2, shell=True)
        cmd3 = "cat " + BuiltIn().replace_variables('${OUTPUT_DIR}') + \
               "/adbtmp|sed 's/CellIdentityNr/\\n/g; s/CellSignalStrengthNr/\\n/g'|grep mPci|uniq"
        result = ((subprocess.check_output(cmd3, shell=True)).decode('utf-8')).strip()
        matched_result = self.verify_adblog_result(item_list=gnb_pci_list, checked_string=result)
        if matched_result != "Match":
            raise Exception("Check ADB log for pci and earfcn failed!")
        else:
            cmd = "rm -f " + BuiltIn().replace_variables('${OUTPUT_DIR}') + "/adbtmp"
            subprocess.check_output(cmd, shell=True)

    @staticmethod
    def verify_adblog_result(item_list, checked_string):
        """
        This method used to check whether the item list appear in the checked_string.

        :param item_list : the items to be searched
        :param checked_string : ADB log string to be checked
        :return Match if find item in checked string, NotMatch otherwise
        """
        logger.info("The Item list to be verified is : {0}".format(item_list))
        for item in item_list:
            updated_string = "mPci = {0}".format(item)
            logger.info("Start to verify item : {0}".format(updated_string))
            if updated_string in checked_string:
                return "Match"
        return "NotMatch"

    def verify_qualcomm_4g_ue_setup_by_adb_log(self, lte_pci, lte_earfcn, ue_android_ver):
        """
        Verify 4G UE setup by ADB log.

        :param lte_pci: LTE cell pci
        :param lte_earfcn: earfcnDL in the eNB bts
        :param ue_android_ver: UE android version
        """
        if ue_android_ver == '9':
            self.check_qualcomm_4g_android_9_log(lte_pci, lte_earfcn)
        else:
            self.check_qualcomm_4g_android_10_log(lte_pci)

    def check_huawei_5g_android_9_log(self, lte_pci):
        """
        Verify 5G UE attach by ADB log.

        :param lte_pci: LTE cell pci
        """
        cmd = "cat " + BuiltIn().replace_variables('${OUTPUT_DIR}') + \
              "/ADB_{}.log | grep 'IS_CELL_ATTACHED=True' | grep GET_PCI={} | tail -1".format(self.ue_index, lte_pci)
        result = ((subprocess.check_output(cmd, shell=True)).decode('utf-8')).strip()
        if 'GET_NETWORK_TYPE=NR' in result:
            self.attach_5g_result = True
        else:
            self.attach_5g_result = False

    def check_huawei_5g_android_10_log(self):
        """
        Verify UE attach to 5G by ADB log.
        """
        cmd = "cat " + BuiltIn().replace_variables('${OUTPUT_DIR}') + \
              "/ADB_{}.log | grep -i 'converted_rat =' | tail -2".format(self.ue_index)
        result = ((subprocess.check_output(cmd, shell=True)).decode('utf-8')).strip()
        if '65' in result or '66' in result or '69' in result:
            self.attach_5g_result = True
        else:
            self.attach_5g_result = False

    def check_qualcomm_4g_android_9_log(self, lte_pci, lte_earfcn):
        """
        Verify UE attach to 4G by ADB log.

        :param lte_pci: LTE cell pci
        :param lte_earfcn: earfcnDL in the eNB bts
        :param ue_android_ver: UE android version
        """
        cmd = "cat " + BuiltIn().replace_variables('${OUTPUT_DIR}') + \
              "/ADB_{}.log | grep DATA_REGISTRATION |grep rat".format(self.ue_index)
        result = ((subprocess.check_output(cmd, shell=True)).decode('utf-8')).strip()
        adb_results = result.splitlines()
        adb_line = adb_results[-2]
        if 'rat = 14' in adb_line and 'earfcn = {}'.format(lte_earfcn) in adb_line \
                and 'pci = {}'.format(lte_pci) in adb_line:
            logger.info("check_qualcomm_4g_android_9_log pass")
        else:
            raise Exception("Check Qualcomm 4G Android 9 Log failed!, the ADB log line is {}".format(adb_line))

    def check_qualcomm_4g_android_10_log(self, lte_pci):
        """
        Verify UE attach to 4G by ADB log.
        """
        cmd = "cat " + BuiltIn().replace_variables('${OUTPUT_DIR}') + \
              "/ADB_{}.log | grep 'IS_CELL_ATTACHED=True' | grep GET_PCI={}|tail -1".format(self.ue_index, lte_pci)
        result = ((subprocess.check_output(cmd, shell=True)).decode('utf-8')).strip()
        if 'GET_PCI={}'.format(lte_pci) not in result:
            raise Exception("Check Qualcomm 4G Android 10 Log failed!, the ADB log check result is {}".format(result))

    def start_to_catch_ue_adb_logs(self, serial_number):
        """
        Catch the UE adb log for check UE setup.
        """
        if not self.adblog_flag:
            return
        logger.info("\nInfo:Start to catch ADB logs for {}".format(self.ue_alias), also_console=True)
        self.sshManager.send_command(command='adb -s {} logcat -c'.format(serial_number),
                                     connection='cpc_{}'.format(self.ue_index), timeout=5)
        self.sshManager.send_command(command='rm /tmp/ADB_{}.log'.format(self.ue_index),
                                     connection='cpc_{}'.format(self.ue_index), timeout=5)
        time.sleep(1)
        self.sshManager.send_command(
            command='nohup adb -s {} logcat -b all > /tmp/ADB_{}.log &'.format(serial_number, self.ue_index),
            connection='cpc_{}'.format(self.ue_index), timeout=5)
