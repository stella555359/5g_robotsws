"""
:author: Min Dai
:contact: min.b.dai@nokia-sbell.com
"""
import re
import os
import time
import logging
from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn
from taf.transport.ssh import ssh
from testsuite.Krakow.resources.NJ_Resources.Resources.python.DevNJ_UE.common.exceptions import CpcCannotConnect

get_iperf_id_cmd = "/bin/ps | grep iperf | grep -v grep | awk '{{print $1}}'"
get_iperf_id_cmd_android = "/bin/ps -ef | grep iperf | grep -v grep | awk '{{print $2}}'"
iperf_path = '/data/local/tmp/iperf'


class Iperf(object):

    def __init__(self, ue_info, ue_index):
        self.conn = None
        self.ue_index = ue_index
        self.ue_config = ue_info
        self.sshManager = ssh()
        self.app_server_conn = None
        self.ue_alias = "UE_{}".format(ue_index)
        self.ue_constr = self.ue_config.get('{}'.format(self.ue_alias)).get('CONSTRUCTOR_PARAMETERS')
        self.config = self.ue_constr.get('configuration')
        self.ue_pc_dict = {'cpc_ip': self.config['ue_pc_ip'], 'cpc_usr': self.config['login'],
                           'cpc_pwd': self.config['password'], 'sn': self.ue_constr['serial_number'],
                           'cpc_pyrodir': self.config['server_dir']}
        self.cpc_conn = None

    def get_and_kill_iperf_process_on_openwrt(self):
        """
        Send AT command to qualcomm UE

        :return <str> response of AT_COMMAND
        """
        self.sshManager.send_command(command=get_iperf_id_cmd, connection='SMA_{}'.format(self.ue_index))
        process_id = self.sshManager.read_output(connection='SMA_{}'.format(self.ue_index))
        iperf_process_id = process_id.split("\n")[0:-1]
        logger.info("iperf id on {} openwrt is {}".format(self.ue_alias, iperf_process_id))
        for item in iperf_process_id:
            logger.info("Begin to kill iperf process id {} on {} openwrt.".format(item, self.ue_alias))
            self.sshManager.send_command(command="kill -9 {}".format(item), connection='SMA_{}'.format(self.ue_index))
            time.sleep(2)

    def login_app_server(self, conn_alias):
        """
        This keyword used to remotely login App Server before data transfer, used for both SMAWave and Android UE.

        :param conn_alias : remotely login session alias
        """
        app_server_info = self.config.get('data_transfer').get('ssh')
        host_name = app_server_info.get('host')
        user_name = app_server_info.get('user')
        pass_word = app_server_info.get('password')
        i = 0
        while i < 5:
            try:
                i += 1
                self.app_server_conn = self.sshManager.connect_to(
                    hostname=host_name, username=user_name, password=pass_word, alias=conn_alias)
                return self.app_server_conn
            except Exception as e:
                ex = e
                time.sleep(20)
        else:
            assert False, "Login APP server:{} Failed, error msg is {}".format(host_name, ex)

    def calculate_and_verify_dl_tput(self, expect_t_put, deviation, protocol):
        """
        This keyword used to calculate and verify SMAWave UE Async DL T-Put.

        :param expect_t_put: desired average data transfer throughput
        :param deviation: acceptable deviation, format should be similar to 20%
        :param protocol: tcp or udp
        """
        dl_iperf_file = self.get_dl_iperf_file()
        if protocol.lower() == 'tcp':
            dt_dl_row_list = self.parse_iperf_trace_to_rows(file_to_be_parsed=dl_iperf_file, parallel_streams=True)
        else:
            dt_dl_row_list = self.parse_iperf_trace_to_rows(file_to_be_parsed=dl_iperf_file)
        t_put = self.count_average_throughput(iperf_row_list=dt_dl_row_list)
        self.check_tput_with_deviation(expect_tput=expect_t_put, average_tput=t_put,
                                       deviation=deviation)

    def calculate_and_verify_ul_tput(self, expect_t_put, deviation):
        """
        This keyword used to calculate and verify SMAWave UE Async UL T-Put.

        :param expect_t_put : desired average data transfer throughput
        :param deviation : acceptable deviation, format should be similar to 20%
        """

        ul_iperf_file = self.get_ul_iperf_file()
        dt_ul_row_list = self.parse_iperf_trace_to_rows(file_to_be_parsed=ul_iperf_file)
        t_put = self.count_average_throughput(iperf_row_list=dt_ul_row_list)
        self.check_tput_with_deviation(expect_tput=expect_t_put, average_tput=t_put,
                                       deviation=deviation)

    def get_dl_iperf_file(self):
        """
        Get down-link t-put iperf file
        """
        output_dir = BuiltIn().replace_variables('${OUTPUT_DIR}') + '/openwrt_iperf_{}.log'.format(self.ue_index)
        self.sshManager.download_file(remote_path='/tmp/openwrt_iperf_{}.log'.format(self.ue_index),
                                      local_path=output_dir,
                                      connection='SMA_{}'.format(self.ue_index))
        return output_dir

    def get_ul_iperf_file(self):
        """
        Get up-link t-put iperf file
        """
        if not self.app_server_conn:
            self.login_app_server('APP_Server_{}'.format(self.ue_index))
        ue_sn = self.ue_config.get('{}'.format(self.ue_alias)).get(
            'CONSTRUCTOR_PARAMETERS').get('serial_number')
        output_dir = BuiltIn().replace_variables('${OUTPUT_DIR}') + '/ute_iperf_{}.log'.format(self.ue_index)
        self.sshManager.download_file(remote_path='/tmp/ute_iperf_{}_{}.log'.format(self.ue_index, ue_sn),
                                      local_path=output_dir,
                                      connection='APP_Server_{}'.format(self.ue_index))
        return output_dir

    @staticmethod
    def parse_iperf_trace_to_rows(file_to_be_parsed, parallel_streams=False, get_datagram_loss=False):
        """
        Parses lines from iperf output file into specific rows

        :param file_to_be_parsed: iperf output file
        :param parallel_streams: parse it like parallel streams iperf output
        :param get_datagram_loss: get datagram loss
        :return: valid rows list without the last summary row
        """
        if os.path.exists(file_to_be_parsed):
            valid_rows, rows = [], []
            index = 0
            with open(file_to_be_parsed, 'r') as FH:
                for item in FH:
                    row = IperfServerReportRow(item, index, parallel_streams, get_datagram_loss)
                    if row.correct and 'nan' not in item:
                        rows.append(row)
                    index += 1
            if rows:
                logger.info("Rows parsed: \n {0}".format("\n".join([row.line for row in rows])))
                if parallel_streams:
                    if rows[-1].interval_start == '0.00' and rows[-1].interval_end != '1.00':
                        logging.debug("Summary row detected {0}.".format(rows[-1].line))
                        valid_rows = rows[:-3]
                    else:
                        valid_rows = rows
                    return valid_rows
                else:
                    if rows[-1].interval_start == '0.0' and rows[-1].interval_end != '1.0':
                        logging.debug("Summary row detected {0}.".format(rows[-1].line))
                        valid_rows = rows[:-1]
                    else:
                        valid_rows = rows
                    return valid_rows

            else:
                raise Exception("The parsed list is empty, data transfer can't be reached, please check!")
        else:
            raise Exception("The Iperf output file {0} is not exist!".format(file_to_be_parsed))

    @staticmethod
    def count_average_throughput(iperf_row_list):
        """
        Counts average throughput based on iperf server output

        :param iperf_row_list: list of IperfServerReportRow instances
        :return: average T-put based on iperf server output
        """
        tput_list = ["{0}{1}".format(row.bandwidth_amount, row.bandwidth_unit) for row in iperf_row_list]
        print("detailed traffic list: {0}".format(tput_list))
        bandwidth_amount = []
        for row in iperf_row_list:
            if row.bandwidth_unit == "M":
                bandwidth_amount.append(float(row.bandwidth_amount))
            elif row.bandwidth_unit == "G":
                bandwidth_amount.append(float(row.bandwidth_amount) * 1024)
            elif row.bandwidth_unit == "K":
                bandwidth_amount.append(float(row.bandwidth_amount) / 1024)
        total_tput = sum([float(row_bandwidth_amount) for row_bandwidth_amount in bandwidth_amount])
        average = round((total_tput / len(bandwidth_amount)), 1)
        average_tput = "{0}{1}".format(average, "M")
        return average_tput

    @staticmethod
    def check_tput_with_deviation(expect_tput, average_tput, deviation):
        """
        Check average throughput is in desired expected range

        :param expect_tput: expected throughput
        :param average_tput: actual average throughput
        :param deviation: acceptable deviation
        :return: True or False
        """
        number_of_deviation = deviation.rstrip('%')
        expect_tput = float(expect_tput.rstrip('M'))
        average_tput = float(average_tput.rstrip('M'))
        deviation_as_float = int(number_of_deviation)
        min_acceptable_tput = expect_tput - (expect_tput * deviation_as_float / 100)
        max_acceptable_tput = expect_tput + (expect_tput * deviation_as_float / 100)
        if average_tput < min_acceptable_tput or average_tput > max_acceptable_tput:
            raise Exception("Average T-Put [{0}] is NOT in desired range.expected range is {1}-{2}".format(
                average_tput, min_acceptable_tput, max_acceptable_tput))
        else:
            logger.info("Average T-Put [{0}] is in desired range.".format(average_tput))
            return 'Success'

    @staticmethod
    def count_average_jitter(iperf_row_list):
        """
        Counts average jitter based on iperf server output

        :param iperf_row_list: list of IperfServerReportRow instances
        :return: average jitter based on iperf server output
        """
        valid_row_list = [row for row in iperf_row_list if hasattr(row, 'udp_part')]
        if valid_row_list:
            jitter_unit = valid_row_list[1].jitter_unit
            total_jitter = sum([float(row.jitter) for row in valid_row_list])
            average_jitter = total_jitter / len(valid_row_list)
            return round(average_jitter, 4), jitter_unit

    @staticmethod
    def count_datagram_loss(iperf_row_list):
        """
        Counts percentage of lost datagram during UDP data transfer

        :param iperf_row_list: list of IperfServerReportRow instances
        :return: datagram loss rate and total datagram loss
        """
        valid_udp_rows = [row for row in iperf_row_list if hasattr(row, 'udp_part')]
        if valid_udp_rows:
            total_lost_datagrams = sum([int(row.lost_datagrams) for row in valid_udp_rows])
            total_datagrams = sum([int(row.total_datagrams) for row in valid_udp_rows])
            if total_datagrams == 0:
                logging.error('Server report: None of the datagram received')
                return None
            return total_lost_datagrams, round(float(total_lost_datagrams) / total_datagrams, 4) * 100

    def get_and_kill_iperf_process_on_remote(self, conn=None):
        """
        This keyword used to get iperf process on ute or ue pc and then kill them.

        :param conn : remotely login session alias
        """
        self.sshManager.send_command(command=get_iperf_id_cmd_android, connection=conn)
        process_id = self.sshManager.read_output(connection=conn)
        iperf_process_id = process_id.split("\n")[0:-1]
        logger.info("iperf id on remote is {}.".format(iperf_process_id))
        for item in iperf_process_id:
            logger.info("Begin to kill iperf process id {} on remote.".format(item))
            self.sshManager.send_command(command="kill -9 {}".format(item), connection=conn)
            time.sleep(2)

    def connect_to_control_pc(self, alias='cpc'):
        """
        Connect to control pc

        :param alias: the ip address of control PC
        """
        cpc_ip = self.ue_pc_dict.get('cpc_ip')
        cpc_usr = self.ue_pc_dict.get('cpc_usr')
        cpc_pwd = self.ue_pc_dict.get('cpc_pwd')

        i = 0
        while i < 5:
            try:
                i += 1
                self.cpc_conn = self.sshManager.connect_to(hostname=cpc_ip,
                                                           username=cpc_usr,
                                                           password=cpc_pwd,
                                                           alias=alias)
                return self.cpc_conn
            except Exception as e:
                logger.info("connect failed due to {}".format(e))
                time.sleep(20)
        else:
            raise CpcCannotConnect("CPC connection failed: {}/{}/{} !    WARN".format(cpc_ip, cpc_usr, cpc_pwd))

    def screen_action(self):
        """
        activate ue screen
        unlock ue screen
        """
        cpc_sn = self.ue_pc_dict.get('sn')
        self.sshManager.execute(command='adb -s {} shell input keyevent 224'.format(cpc_sn),
                                connection='cpc_{}'.format(self.ue_index), timeout=5)
        self.sshManager.execute(command='adb -s {} shell input swipe 300 1000 300 500'.format(cpc_sn),
                                connection='cpc_{}'.format(self.ue_index), timeout=5)

    def check_adb_version(self):
        """
        Check the ADB version
        """
        self.sshManager.send_command(command='adb version',
                                     connection='cpc_{}'.format(self.ue_index), timeout=5)
        result = self.sshManager.read_output(connection='cpc_{}'.format(self.ue_index))
        lines = result.splitlines()
        for line in lines:
            if "Android Debug Bridge" in line:
                version_line = line
                break
        adb_version = int(version_line[-2:])
        uepc_os_type = self.get_uepc_type('cpc_{}'.format(self.ue_index))
        if uepc_os_type == "Linux":
            allowed_version = 39
        else:
            allowed_version = 41
        assert adb_version >= allowed_version, "Check ADB Version Failed, not supported version"

    def get_uepc_type(self, cpc_alias):
        """
        Get the OS type of UE PC

        :param cpc_alias: the ssh connection to the ue pc
        """
        self.sshManager.send_command(command='uname', connection=cpc_alias, timeout=5)
        time.sleep(2)
        output_result = self.sshManager.read_output(connection=cpc_alias)
        os_type = output_result[0:5]
        return os_type

    def check_adb_devices_and_restart_adb_service(self):
        """
        Sometimes ue is adb offline. Reboot adb service first, then reboot UE PC as a workaround.
        """
        self.sshManager.execute(command='rm -rf {}'.format(self.ue_pc_dict.get('cpc_pyrodir')),
                                connection='cpc_{}'.format(self.ue_index), timeout=5)
        result = self.check_adb_devices_status(self.ue_pc_dict.get('sn'), 'cpc_{}'.format(self.ue_index))
        if result == "FAIL":
            self.adb_service_restart(self.ue_pc_dict.get('sn'), 'cpc_{}'.format(self.ue_index))
            logger.info("\nInfo:Restart adb service for {}!".format(self.ue_alias), also_console=True)
        result = self.check_adb_devices_status(self.ue_pc_dict.get('sn'), 'cpc_{}'.format(self.ue_index))
        if result == "FAIL":
            self.check_adb_devices_and_reboot_ue_pc()
            logger.info("\nCheck {} adb devices again and status return {}".format(self.ue_alias, result),
                        also_console=True)

    def check_adb_devices_status(self, serial_number, cpc_alias):
        """
        Check phone status by serial number

        :param serial_number: the serial number of phone
        :param cpc_alias: the ssh connection to the ue pc
        """
        self.sshManager.send_command(command='adb devices', connection=cpc_alias, timeout=5)
        time.sleep(2)
        result = self.sshManager.read_output(connection=cpc_alias)
        lines = result.splitlines()
        for line in lines:
            if serial_number in line:
                device_line = line
                break
        device_status = device_line[-6:]
        if device_status == "device":
            return_value = "PASS"
        else:
            return_value = "FAIL"
        return return_value

    def adb_service_restart(self, serial_number, cpc_alias):
        """
        Use adb command to recover adb service

        :param serial_number: the serial number of phone
        :param cpc_alias: the ssh connection to the ue pc
        """
        logger.info("\nInfo:Reboot ADB Service on {}!".format(cpc_alias), also_console=True)
        self.sshManager.execute(command='sudo adb -s {} kill-server'.format(serial_number), connection=cpc_alias)
        self.sshManager.execute(command='sudo adb -s {} start-server'.format(serial_number), connection=cpc_alias)
        time.sleep(2)

    def check_adb_devices_and_reboot_ue_pc(self):
        """
        Sometimes ue is adb offline, reboot UE PC as a workaround.
        """
        self.sshManager.execute(command='rm -rf {}'.format(self.ue_pc_dict.get('cpc_pyrodir')),
                                connection='cpc_{}'.format(self.ue_index), timeout=5)
        result = self.check_adb_devices_status(self.ue_pc_dict.get('sn'), 'cpc_{}'.format(self.ue_index))
        logger.info("\nInfo:Check adb devices status return {}".format(result), also_console=True)
        if result == "FAIL":
            self.reboot_windows_or_linux_uepc()
            logger.info("\nInfo:Reconnect to control pc of {}.".format(self.ue_alias), also_console=True)
            self.sshManager.disconnect(connection='cpc_{}'.format(self.ue_index))
            self.connect_to_control_pc('cpc_{}'.format(self.ue_index))
            self.check_adb_devices_status(self.ue_pc_dict.get('sn'), 'cpc_{}'.format(self.ue_index))

    def reboot_windows_or_linux_uepc(self):
        """
        Sometimes ue is adb offline, reboot UE PC as a workaround.
        """
        uepc_os_type = self.get_uepc_type('cpc_{}'.format(self.ue_index))
        logger.info("\nInfo:Reboot {} UEPC for {}, wait 90s!".format(uepc_os_type, self.ue_alias),
                    also_console=True)
        if uepc_os_type == "windo":
            self.sshManager.execute(command='shutdown /r /f', connection='cpc_{}'.format(self.ue_index), timeout=5)
        else:
            self.sshManager.execute(command='sudo reboot', connection='cpc_{}'.format(self.ue_index), timeout=5)
        time.sleep(90)
        self.connect_to_control_pc('cpc_{}'.format(self.ue_index))

    def remove_adb_logs(self):
        """
        Clean the ADB logs in the UE PC.
        """
        self.sshManager.execute(command='rm -rf /tmp/ADB_{}.log'.format(self.ue_index),
                                connection='cpc_{}'.format(self.ue_index), timeout=5)


class IperfServerReportRow(object):
    """Class representing row in Iperf report"""
    def __init__(self, line, index=-1, parallel_streams=False, get_datagram_loss=False):

        row_id_pattern = "SUM" if (parallel_streams and not get_datagram_loss) else u"\\s*(?P<id>\\d*)\\s*"
        pattern = u"\\[{}]\\s*(?P<interval_start>\\d*\\.\\d*)\\s*\\-\\s*(?P<interval_end>\\d*\\.\\d*)\\s*sec\\s*" \
                  u"(?P<transfer_amount>\\d*(\\.\\d*)?)\\s*(?P<transfer_unit>K|M|G|)Bytes\\s*" \
                  u"(?P<bandwidth_amount>\\d*\\.*\\d*)\\s*(?P<bandwidth_unit>K|M|G|)bits\\/sec" \
                  u"(?P<udp_part>\\s*(?P<jitter>\\d*\\.\\d*)\\s*(?P<jitter_unit>\\w*)\\s*" \
                  u"(?P<lost_datagrams>\\d*)\\/\\s*(?P<total_datagrams>\\d*)\\s*\\((?P<datagram_loss>\\d*. " \
                  u"\\d*|\\-nan)\\%*\\))*".format(row_id_pattern)

        self.pattern = re.compile(pattern, re.VERBOSE)
        m = re.search(self.pattern, line)
        self.line = line
        self.index = index
        if not m:
            self.correct = False
            return

        parameters = m.groupdict()
        for param, param_value in parameters.items():
            if param_value is not None:
                setattr(self, param, param_value)
        self.correct = True
