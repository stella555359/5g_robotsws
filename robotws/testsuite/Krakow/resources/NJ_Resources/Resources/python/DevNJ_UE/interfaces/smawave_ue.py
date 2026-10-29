"""
:author: Min Dai
:contact: min.b.dai@nokia-sbell.com
"""
import re
import time
from robot.api import logger
from .common_ue import BasicUe
from ..common.ip import Ip
from ..common.udp import Udp
from ..common.iperf import Iperf
from ..common.at_command import AtCommand
from ute_async import ute_async
from taf.transport.ssh import ssh

"""Module with AT commands for qualcomm prototypes"""
CHECK_CMD = 'atcmd /dev/ttyUSB2 115200 AT+COPS?'
ATTACH_CMD = 'atcmd /dev/ttyUSB2 115200 AT+CFUN=1'
DETACH_CMD = 'atcmd /dev/ttyUSB2 115200 AT+CFUN=4'
CHECK_ATTACH_CMD = 'atcmd /dev/ttyUSB2 115200 AT+GTCCINFO?'
CHECK_FREQ_LOCK_CMD = 'atcmd /dev/ttyUSB2 115200 AT+GTFREQLOCK?'
FREQ_LOCK_UNLOCK_CMD = 'atcmd /dev/ttyUSB2 115200 AT+GTFREQLOCK='
# SA_ENABLE_CMD = 'atcmd /dev/ttyUSB2 115200 AT+GTSET=\"5GSACTR\",1'
# SA_DISABLE_CMD = 'atcmd /dev/ttyUSB2 115200 AT+GTSET=\"5GSACTR\",0'
SA_ENABLE_CMD = "echo -e 'AT+GTSET=\"5GSACTR\",1\r' > /dev/ttyUSB2"
SA_DISABLE_CMD = "echo -e 'AT+GTSET=\"5GSACTR\",0\r' > /dev/ttyUSB2"
SA_CHECK_CMD = 'atcmd /dev/ttyUSB2 115200 AT+GTSET?'
APN_CMD = "atcmd /dev/ttyUSB2 115200 'AT+CGDCONT=1,\"IP\",\"{}\"'"
APN_CHECK_CMD = 'atcmd /dev/ttyUSB2 115200 AT+CGDCONT?'

comd_stop_cmd = '/etc/init.d/comd stop'
comd_start_cmd = '/etc/init.d/comd start'
firewall_stop_cmd = '/etc/init.d/firewall stop'
ipv4_pattern = '(?<![\\.\\d])(([1-9]?\\d|1\\d\\d|2[0-4]\\d|25[0-5])\\.)' \
               '{3}([1-9]?\\d|1\\d\\d|2[0-4]\\d|25[0-5])(?![\\.\\d])'
gateway_cmd = "ip route add 0.0.0.0/0 via {}"


class SmawaveUe(BasicUe):
    def __init__(self, ue_index, ue_info, ue_version):
        """
        Class for all SMAWave UE functions.
        """
        self.conn = None
        self.ue_index = ue_index
        self.ue_version = ue_version
        self.ue_config = ue_info
        self.ue_alias = "UE_{}".format(ue_index)
        self.ip = Ip(self.ue_config)
        self.udp = Udp()
        self.iperf = Iperf(self.ue_config, self.ue_index)
        self.atcmd = AtCommand(self.ue_config, self.ue_index)
        self.sshManager = ssh()
        self.ue_inuse = False
        self.ue_status = None
        self.dl_async_flag = None
        self.ul_async_flag = None
        self.dl_ue_async = None
        self.ul_ue_async = None

    def connect(self):
        """
        Setup connection with UE
        """
        try:
            ue_info = self.ue_config.get('{}'.format(self.ue_alias)).get(
                'CONSTRUCTOR_PARAMETERS').get('configuration')
            host_name = ue_info.get('ue_pc_ip')
            user_name = ue_info.get('login')
            pass_word = ue_info.get('password')
            self.conn = self.sshManager.connect_to(hostname=host_name, username=user_name, password=pass_word,
                                                   alias='SMA_{}'.format(self.ue_index))

        except ConnectionError as msg:
            raise Exception("Connect to UE failed with Error: {}".format(msg))
        return self.conn

    def disconnect(self):
        """
        Close connection with UE
        """
        self.sshManager.disconnect(connection=self.conn)
        self.conn = None

    def login_ue(self):
        """
        Login UE
        """
        return self.connect()

    def logout_ue(self):
        """
        Logout UE
        """
        return self.disconnect()

    def attach_ue(self):
        """
        This function is used to perform AT command to attach SMAWave UE.
        In order to increase the probability of successful attach, it will perform detach before each attach.
        """
        if not self.conn:
            self.login_ue()
        self.smawave_service_stop()
        logger.info("\nBegin to perform SMAWave {} detach.".format(self.ue_alias), also_console=True)
        self.atcmd.send_at_cmd_to_ue(DETACH_CMD, 'SMA_{}'.format(self.ue_index))
        time.sleep(5)
        logger.info("\nBegin to perform SMAWave {} attach.".format(self.ue_alias), also_console=True)
        self.atcmd.send_at_cmd_to_ue(ATTACH_CMD, 'SMA_{}'.format(self.ue_index))
        time.sleep(20)
        output = self.atcmd.send_at_cmd_to_ue(CHECK_CMD, 'SMA_{}'.format(self.ue_index))
        check_result = self.atcmd.verify_atcmd_output(output)
        logger.info("\n{} try to attach {} base station.".format(self.ue_alias, check_result), also_console=True)
        attach_status = self.atcmd.verify_attach_status(check_result)
        self.sshManager.send_command(command=comd_start_cmd, connection='SMA_{}'.format(self.ue_index))
        if attach_status == 'Attach':
            self.ue_inuse = True
        else:
            raise Exception("Attach Failed!")

    def detach_ue(self):
        """
        This function is used to perform AT command to detach SMAWave UE.
        """
        if not self.conn:
            self.login_ue()
        logger.info("\nBegin to perform SMAWave {} detach.".format(self.ue_alias), also_console=True)
        self.atcmd.send_at_cmd_to_ue(DETACH_CMD, 'SMA_{}'.format(self.ue_index))
        time.sleep(15)
        output = self.atcmd.send_at_cmd_to_ue(CHECK_CMD, 'SMA_{}'.format(self.ue_index))
        check_result = self.atcmd.verify_atcmd_output(output)
        assert check_result == 'Idle', "Detach Failed!"

    def reboot_ue(self):
        """
        This function is used to reboot SMAWave UE and re-login again to check its status after it bring up.
        """
        self.login_ue()
        logger.info("\nReboot SMAWave {}, wait 120s!".format(self.ue_alias), also_console=True)
        self.sshManager.execute(command='/sbin/reboot', connection='SMA_{}'.format(self.ue_index), timeout=5)
        time.sleep(120)
        logger.info("\nReconnect to SMAWave {}.".format(self.ue_alias), also_console=True)
        self.logout_ue()
        self.login_ue()
        self.sshManager.send_command(command=comd_stop_cmd, connection='SMA_{}'.format(self.ue_index))
        self.sshManager.send_command(command=firewall_stop_cmd, connection='SMA_{}'.format(self.ue_index))
        self.ue_status = self.smawave_check_status()
        self.logout_ue()

    def ue_attach_and_start_adb_log(self, ue_index):
        """
        This function is try to perform UE attach for max 5 times, if attach fail, it will raise error.
        No ADB log functions for SMAWave UE, this name is only used to align with the KW name of Android.
        """
        self.login_ue()
        self.smawave_service_stop()
        i = 0
        while i < 5:
            try:
                i += 1
                self.attach_ue()
                break
            except Exception as e:
                ex = e
                time.sleep(30)
        else:
            assert self.ue_inuse, "Attach UE {} Failed after retrying for 3 minutes. " \
                                  "The last error is: {}".format(self.ue_index, ex)
        logger.info("\nBegin to restart UE_{} openwrt comd service.".format(ue_index), also_console=True)
        self.sshManager.send_command(command=comd_start_cmd, connection='SMA_{}'.format(ue_index))
        time.sleep(30)

    def start_and_verify_dl_udp(self, dt_name, ue_index, direction, duration, iperf_throughput, protocol,
                                dl_expect_tput, dl_deviation):
        """
        SMAWave down-link UDP call with Serial method.
        This function is used to perform and verify SMAWave UE down-link data transfer.

        :param dt_name: name to be assigned to dats transfer, for compatible with Android, not used for SMAWave
        :param ue_index: UE identifier index
        :param direction: dl
        :param duration: data transfer duration in robot time string format
        :param iperf_throughput: desired data transfer throughput, format should be e.g 80M
        :param protocol: udp
        :param dl_expect_tput: desired average data transfer throughput
        :param dl_deviation: acceptable deviation, format should be similar to 20%
        """
        i = 0
        while i < 4:
            try:
                i += 1
                if not self.ip.sma_ue_addr_dict:
                    self.ip.fetch_smawave_ue_addr(self.ue_index)
                break
            except Exception as e:
                ex = e
                time.sleep(20)
        else:
            assert self.ip.sma_ue_addr_dict, "Fetch UE {} Address Failed after retrying for 3 minutes. " \
                                             "The last error is: {}".format(self.ue_index, ex)

        self.start_dl_iperf_process(
            protocol='udp', t_put=iperf_throughput, tput_dura=duration)
        self.iperf.get_and_kill_iperf_process_on_openwrt()
        self.iperf.calculate_and_verify_dl_tput(expect_t_put=dl_expect_tput, deviation=dl_deviation,
                                                protocol='udp')
        self.iperf.get_and_kill_iperf_process_on_openwrt()

    def start_and_verify_ul_udp(self, dt_name, ue_index, direction, duration, iperf_ul_throughput, protocol,
                                ul_expect_tput, ul_deviation):
        """
        SMAWave up-link UDP call with Serial method.
        This function is used to perform TCP uplink traffic

        :param dt_name: name to be assigned to dats transfer, for compatible with Android, not used for SMAWave
        :param ue_index: UE identifier index
        :param direction: ul
        :param duration: data transfer duration in robot time string format
        :param iperf_ul_throughput: desired data transfer throughput, format should be e.g 80M
        :param protocol: udp
        :param ul_expect_tput: desired average data transfer throughput
        :param ul_deviation: acceptable deviation, format should be similar to 20%
        """
        i = 0
        while i < 4:
            try:
                i += 1
                if not self.ip.sma_ue_addr_dict:
                    self.ip.fetch_smawave_ue_addr(self.ue_index)
                break
            except Exception as e:
                ex = e
                time.sleep(20)
        else:
            assert self.ip.sma_ue_addr_dict, "Fetch UE {} Address Failed after retrying for 3 minutes. " \
                                             "The last error is: {}".format(self.ue_index, ex)

        self.start_ul_iperf_process(
            protocol='udp', t_put=iperf_ul_throughput, tput_dura=duration)
        self.iperf.calculate_and_verify_ul_tput(expect_t_put=ul_expect_tput, deviation=ul_deviation)

    def start_and_verify_dl_tcp(self, dt_name, ue_index, direction, duration, iperf_throughput, protocol,
                                dl_expect_tput, dl_deviation):
        """
        SMAWave down-link TCP call with Serial method.
        This function is used to perform and verify SMAWave UE down-link data transfer.

        :param dt_name: name to be assigned to dats transfer, for compatible with Android, not used for SMAWave
        :param ue_index: UE identifier index
        :param direction: dl
        :param duration: data transfer duration in robot time string format
        :param iperf_throughput: desired data transfer throughput, format should be e.g 80M
        :param protocol: tcp
        :param dl_expect_tput: desired average data transfer throughput
        :param dl_deviation: acceptable deviation, format should be similar to 20%
        """
        i = 0
        while i < 4:
            try:
                i += 1
                if not self.ip.sma_ue_addr_dict:
                    self.ip.fetch_smawave_ue_addr(self.ue_index)
                break
            except Exception as e:
                ex = e
                time.sleep(20)
        else:
            assert self.ip.sma_ue_addr_dict, "Fetch UE {} Address Failed after retrying for 3 minutes. " \
                                             "The last error is: {}".format(self.ue_index, ex)

        self.start_dl_iperf_process(
            protocol='tcp', t_put=iperf_throughput, tput_dura=duration)
        self.iperf.get_and_kill_iperf_process_on_openwrt()
        self.iperf.calculate_and_verify_dl_tput(expect_t_put=dl_expect_tput, deviation=dl_deviation,
                                                protocol='tcp')
        self.iperf.get_and_kill_iperf_process_on_openwrt()

    def start_and_verify_ul_tcp(self, dt_name, ue_index, direction, duration, iperf_ul_throughput, protocol,
                                ul_expect_tput, ul_deviation):
        """
        SMAWave up-link TCP call with Serial method.
        This function is used to perform TCP uplink traffic

        :param dt_name: name to be assigned to dats transfer, for compatible with Android, not used for SMAWave
        :param ue_index: UE identifier index
        :param direction: ul
        :param duration: data transfer duration in robot time string format
        :param iperf_ul_throughput: desired data transfer throughput, format should be e.g 80M
        :param protocol: tcp
        :param ul_expect_tput: desired average data transfer throughput
        :param ul_deviation: acceptable deviation, format should be similar to 20%
        """
        i = 0
        while i < 4:
            try:
                i += 1
                if not self.ip.sma_ue_addr_dict:
                    self.ip.fetch_smawave_ue_addr(self.ue_index)
                break
            except Exception as e:
                ex = e
                time.sleep(20)
        else:
            assert self.ip.sma_ue_addr_dict, "Fetch UE {} Address Failed after retrying for 3 minutes. " \
                                             "The last error is: {}".format(self.ue_index, ex)

        self.start_ul_iperf_process(
            protocol='tcp', t_put=iperf_ul_throughput, tput_dura=duration)
        self.iperf.calculate_and_verify_ul_tput(expect_t_put=ul_expect_tput, deviation=ul_deviation)

    def dl_iperf_cmds(self, t_put, tput_dura, protocol, ping_flag, iperf_port_num):
        """
        Common method to send DL iperf command for both serial and asynchronous methods.
        """
        smawave_ue_addr = self.ip.get_epc_side_ipaddr(ip_addr_dict=self.ip.sma_ue_addr_dict,
                                                      ue_index=self.ue_index)
        is_ipv4 = re.match(ipv4_pattern, smawave_ue_addr)
        if is_ipv4 and protocol.lower() == 'tcp':
            dl_cmd_on_openwrt = '/usr/bin/iperf3 -s -p {} -i1 > /tmp/openwrt_iperf_{}.log 2>&1 &'.format(
                iperf_port_num, self.ue_index)
        elif not is_ipv4 and protocol.lower() == 'tcp':
            dl_cmd_on_openwrt = '/usr/bin/iperf3 -s -p {} -i1 -V > /tmp/openwrt_iperf_{}.log 2>&1 &'.format(
                iperf_port_num, self.ue_index)
        elif is_ipv4 and protocol.lower() == 'udp':
            dl_cmd_on_openwrt = '/usr/bin/iperf -s -u -l1400 -w10M -i1 -p {} > /tmp/openwrt_iperf_{}.log 2>&1 &'. \
                format(iperf_port_num, self.ue_index)
        elif not is_ipv4 and protocol.lower() == 'udp':
            dl_cmd_on_openwrt = '/usr/bin/iperf -s -u -l1400 -w10M -i1 -p {} -V > /tmp/openwrt_iperf_{}.log 2>&1 &'. \
                format(iperf_port_num, self.ue_index)
        else:
            assert False, "Not supported protocol:{}".format(protocol)
        logger.info("\ndl_cmd_on_openwrt: {}".format(dl_cmd_on_openwrt))
        self.sshManager.send_command(command=dl_cmd_on_openwrt, connection='SMA_{}'.format(self.ue_index))
        time.sleep(1)
        if ping_flag:
            app_server_addr = self.ip.get_epc_side_ipaddr(ip_addr_dict=self.ip.ute_iperf_itf_ip_dict,
                                                          ue_index=self.ue_index)
            ping_command = '/bin/ping -c 5 {}'.format(app_server_addr)
            logger.info("Begin to execute ping command {} on {}.".format(ping_command, self.ue_alias),
                        also_console=True)
            self.sshManager.send_command(command=ping_command, connection='SMA_{}'.format(self.ue_index))
        logger.info(
            "\nBegin to perform SMAwave {} DL data traffic with throughput {}.".format(self.ue_alias, t_put),
            also_console=True)

        if is_ipv4 and protocol.lower() == 'tcp':
            iperf_cmd_on_app = 'iperf3 -c {} -P 20 -p {} -t {} -i1 -M 1400 -l1400'.format(
                smawave_ue_addr, iperf_port_num, tput_dura)
        elif not is_ipv4 and protocol.lower() == 'tcp':
            iperf_cmd_on_app = 'iperf3 -c {} -P 20 -p {} -t {} -i1 -M 1400 -l1400 -V'.format(
                smawave_ue_addr, iperf_port_num, tput_dura)
        elif is_ipv4 and protocol.lower() == 'udp':
            iperf_cmd_on_app = 'iperf -c {} -u -i1 -l1400 -p {} -b {} -t {}'.format(
                smawave_ue_addr, iperf_port_num, t_put, tput_dura)
        elif not is_ipv4 and protocol.lower() == 'udp':
            iperf_cmd_on_app = 'iperf -c {} -u -i1 -l1400 -p {} -b {} -t {} -V'.format(
                smawave_ue_addr, iperf_port_num, t_put, tput_dura)
        else:
            assert False, "Not supported protocol:{}".format(protocol)
        logger.info("\niperf_cmd_on_app: {}".format(iperf_cmd_on_app))
        return iperf_cmd_on_app

    def ul_iperf_cmds(self, t_put, tput_dura, protocol, ul_port_num):
        """
        Common method to send UL iperf command for both serial and asynchronous methods.
        """
        ue_sn = self.ue_config.get('{}'.format(self.ue_alias)).get(
            'CONSTRUCTOR_PARAMETERS').get('serial_number')
        app_server_addr = self.ip.get_epc_side_ipaddr(ip_addr_dict=self.ip.ute_iperf_itf_ip_dict,
                                                      ue_index=self.ue_index)
        is_ipv4 = re.match(ipv4_pattern, app_server_addr)

        if is_ipv4 and protocol.lower() == 'tcp':
            ul_cmd_on_app_server = 'nohup iperf -s -p {} -t {} -i1 > /tmp/ute_iperf_{}_{}.log 2>&1 &'.format(
                ul_port_num, tput_dura, self.ue_index, ue_sn)
        elif not is_ipv4 and protocol.lower() == 'tcp':
            ul_cmd_on_app_server = 'nohup iperf -s -p {} -t {} -i1 -V > /tmp/ute_iperf_{}_{}.log 2>&1 &'.format(
                ul_port_num, tput_dura, self.ue_index, ue_sn)
        elif is_ipv4 and protocol.lower() == 'udp':
            ul_cmd_on_app_server = 'iperf -s -u -i1 -p {} -t {} > /tmp/ute_iperf_{}_{}.log'.format(
                ul_port_num, tput_dura, self.ue_index, ue_sn)
        elif not is_ipv4 and protocol.lower() == 'udp':
            ul_cmd_on_app_server = 'iperf -s -u -i1 -p {} -t {} -V > /tmp/ute_iperf_{}_{}.log'.format(
                ul_port_num, tput_dura, self.ue_index, ue_sn)
        else:
            assert False, "Not supported protocol:{}".format(protocol)
        if not self.iperf.app_server_conn:
            self.iperf.login_app_server('APP_Server_{}'.format(self.ue_index))
        logger.info("\nul_cmd_on_app_server: {}".format(ul_cmd_on_app_server))
        self.sshManager.send_command(command=ul_cmd_on_app_server, connection='APP_Server_{}'.format(self.ue_index))

        if is_ipv4 and protocol.lower() == 'tcp':
            ul_cmd_on_openwrt = '/usr/bin/iperf -c {} -p {} -t {} -i1 -M 1400 -l1400'.format(
                app_server_addr, ul_port_num, tput_dura)
        elif not is_ipv4 and protocol.lower() == 'tcp':
            ul_cmd_on_openwrt = '/usr/bin/iperf -c {} -p {} -t {} -i1 -M 1400 -l1400 -V'.format(
                app_server_addr, ul_port_num, tput_dura)
        elif is_ipv4 and protocol.lower() == 'udp':
            ul_cmd_on_openwrt = '/usr/bin/iperf -c {} -u -i1 -l1400 -p {} -t {} -b {}'.format(
                app_server_addr, ul_port_num, tput_dura, t_put)
        elif not is_ipv4 and protocol.lower() == 'udp':
            ul_cmd_on_openwrt = '/usr/bin/iperf -c {} -u -i1 -l1400 -p {} -t {} -b {} -V'.format(
                app_server_addr, ul_port_num, tput_dura, t_put)
        else:
            assert False, "Not supported protocol:{}".format(protocol)
        logger.info("\nul_cmd_on_openwrt: {}".format(ul_cmd_on_openwrt))
        return ul_cmd_on_openwrt

    def start_dl_async_process(self, index, t_put, tput_dura, protocol, data_trans_name, ping_flag=True):
        """
        Start SMAWave down-link iperf process with Asynchronous method.
        This function is used to start iperf process on both UTE VM and openwrt for SMAWave UE DL data transfer

        :param index: UE identifier index
        :param t_put: desired data transfer throughput, format should be e.g 80M
        :param tput_dura: data transfer duration
        :param protocol: tcp or udp
        :param data_trans_name: name to be assigned to dats transfer, for compatible with Android, not used for SMAWave
        :param ping_flag: ping flag for ping to the UE
        """
        logger.info("\nBegin to generate {} port for SMAwave UE DL data transfer.".format(protocol), also_console=True)
        used_port_list = self.udp.get_occupied_udp_port_list()
        iperf_port_num = self.udp.get_available_udp_port(used_port_list)
        logger.info("\nThe {} port used for SMAwave {} Async DL data transfer is {}.".format(
            protocol, self.ue_alias, iperf_port_num), also_console=True)
        iperf_cmd_on_app = self.dl_iperf_cmds(t_put, tput_dura, protocol, ping_flag, iperf_port_num)
        if not self.iperf.app_server_conn:
            self.iperf.login_app_server('APP_Server_{}'.format(self.ue_index))
        logger.info("Start to use ute-async to start iperf process for SMAWave {}.".format(self.ue_alias),
                    also_console=True)
        self.dl_ue_async = ute_async()
        self.dl_ue_async.start_async(library_name='taf.transport.ssh', keyword_name='execute',
                                     command=iperf_cmd_on_app, connection='APP_Server_{}'.format(self.ue_index),
                                     alias='DL_async_{}'.format(self.ue_index))
        logger.info(
            "\nAsync process has been started for SMAWave {}, you can perform other operations/keywords now.".format(
                self.ue_alias), also_console=True)
        self.dl_async_flag = True

    def start_ul_async_process(self, index, t_put, tput_dura, protocol, data_trans_name):
        """
        Start SMAWave up-link iperf process with Asynchronous method.
        This function is used to start iperf process on both UTE VM and openwrt for SMAWave UE UL data transfer

        :param index: UE identifier index
        :param t_put: desired data transfer throughput, format should be e.g 80M
        :param tput_dura: data transfer duration
        :param protocol: tcp or udp
        :param data_trans_name: name to be assigned to dats transfer, for compatible with Android, not used for SMAWave
        """
        logger.info(
            "Begin to generate {} port for SMAWave {} Async UL data transfer.".format(protocol, self.ue_alias),
            also_console=True)
        used_port_list = self.udp.get_occupied_udp_port_list()
        ul_port_num = self.udp.get_available_udp_port(used_port_list)
        logger.info(
            "\nThe {} port used for SMAWave {} async UL data transfer is {}".format(protocol, self.ue_alias,
                                                                                    ul_port_num), also_console=True)
        logger.info(
            "\nBegin to perform SMAWave {} async UL data transfer with T-Put {}.".format(self.ue_alias, t_put),
            also_console=True)
        ul_cmd_on_openwrt = self.ul_iperf_cmds(t_put, tput_dura, protocol, ul_port_num)
        self.ul_ue_async = ute_async()
        self.ul_ue_async.start_async(library_name='taf.transport.ssh', keyword_name='execute',
                                     command=ul_cmd_on_openwrt, connection='SMA_{}'.format(self.ue_index),
                                     alias='UL_async_{}'.format(self.ue_index))
        logger.info("\nSuccessfully perform SMAWave {} async UL data transfer with T-Put {} duration is {}.".format(
            self.ue_alias, t_put, tput_dura), also_console=True)
        self.ul_async_flag = True

    def calculate_and_verify_dl_async_tput(self, index, expect_tput, deviation, tput_dura,
                                           data_trans_name='dl_test', protocol='udp'):
        """
        This function is used to calculate and verify Async DL T-Put with deviation.

        :param index: UE identifier index
        :param expect_tput: desired average data transfer throughput
        :param deviation: acceptable deviation, format should be similar to 20%
        :param tput_dura: time interval which will be used for SMAWave waiting the async process completion
        :param data_trans_name: data transfer name for Android UE, not used for SMAWave UE
        :param protocol: tcp or udp
        """
        logger.info("\nAwait the completion of SMAwave {} Async DL data transfer, please wait a sec.".format(
            self.ue_alias), also_console=True)
        updated_tput_dura = tput_dura.strip('s')
        result = None
        i = 0
        while i < 2:
            try:
                i += 1
                result = self.dl_ue_async.wait_for_async_result(timeout=updated_tput_dura,
                                                                alias='DL_async_{}'.format(self.ue_index))
                break
            except Exception as e:
                ex = e
                time.sleep(1)
        else:
            assert "Client connecting" in result, "Waiting for async failed: {}!".format(ex)

        logger.info("SMAwave {} DL data transfer async result: {}.".format(self.ue_alias, result))
        dl_iperf_file = self.iperf.get_dl_iperf_file()
        self.iperf.get_and_kill_iperf_process_on_openwrt()
        if protocol.lower() == 'tcp':
            dt_dl_row_list = self.iperf.parse_iperf_trace_to_rows(
                file_to_be_parsed=dl_iperf_file, parallel_streams=True)
        else:
            dt_dl_row_list = self.iperf.parse_iperf_trace_to_rows(file_to_be_parsed=dl_iperf_file)
        t_put = self.iperf.count_average_throughput(iperf_row_list=dt_dl_row_list)
        return_result = self.iperf.check_tput_with_deviation(expect_tput=expect_tput, average_tput=t_put,
                                                             deviation=deviation)

    def calculate_and_verify_ul_async_tput(self, index, expect_tput, deviation, tput_dura,
                                           data_trans_name='ul_test', protocol='udp'):
        """
        This function is used to calculate and verify Async UL T-Put with deviation.

        :param index: UE identifier index
        :param expect_tput: desired average data transfer throughput
        :param deviation: acceptable deviation, format should be similar to 20%
        :param tput_dura: time interval which will be used for waiting the async process completion
        :param data_trans_name: data transfer name for Android UE, not used for SMAWave UE
        :param protocol: tcp or udp
        """
        logger.info("\nAwait the completion of SMAwave {} Async UL data transfer, please wait a sec.".format(
            self.ue_alias), also_console=True)
        updated_tput_dura = tput_dura.strip('s')
        result = None
        i = 0
        while i < 2:
            try:
                i += 1
                result = self.ul_ue_async.wait_for_async_result(timeout=updated_tput_dura,
                                                                alias='UL_async_{}'.format(self.ue_index))
                break
            except Exception as e:
                ex = e
                time.sleep(0.1)
        else:
            assert "Client connecting" in result, "Waiting for async failed: {}!".format(ex)

        logger.info("SMAwave {} async UL data transfer result: {}.".format(self.ue_alias, result))
        ul_iperf_file = self.iperf.get_ul_iperf_file()
        dt_ul_row_list = self.iperf.parse_iperf_trace_to_rows(file_to_be_parsed=ul_iperf_file)
        t_put = self.iperf.count_average_throughput(iperf_row_list=dt_ul_row_list)
        return_result = self.iperf.check_tput_with_deviation(expect_tput=expect_tput, average_tput=t_put,
                                                             deviation=deviation)

    def start_dl_iperf_process(self, protocol, t_put, tput_dura, ping_flag=True):
        """
        This function is used to start iperf process on both UTE VM and openwrt for SMAwave UE DL data transfer

        :param protocol: tcp or udp
        :param t_put: desired data transfer throughput, format should be e.g 80M
        :param tput_dura: data transfer duration in robot time string format
        :param ping_flag: ping flag for ping to the UE
        """
        logger.info("\nBegin to generate {} port for DL data transfer".format(protocol), also_console=True)
        used_port_list = self.udp.get_occupied_udp_port_list()
        iperf_port_num = self.udp.get_available_udp_port(used_port_list)
        logger.info(
            "\nThe {} port used for {} DL data transfer is {}.".format(protocol, self.ue_alias, iperf_port_num),
            also_console=True)
        iperf_cmd_on_app = self.dl_iperf_cmds(t_put, tput_dura, protocol, ping_flag, iperf_port_num)
        if not self.iperf.app_server_conn:
            self.iperf.login_app_server('APP_Server_{}'.format(self.ue_index))
        self.sshManager.execute(command=iperf_cmd_on_app, connection='APP_Server_{}'.format(self.ue_index))
        time.sleep(1)
        logger.info("\nSuccessfully perform {} DL data traffic with throughput {} duration is {}.".format(
            self.ue_alias, t_put, tput_dura), also_console=True)

    def start_ul_iperf_process(self, protocol, t_put, tput_dura):
        """
        This function is used to start iperf process on both UTE VM and openwrt for SMAWave UE UL data transfer

        :param protocol: tcp or udp
        :param t_put: desired data transfer throughput, format should be e.g 80M
        :param tput_dura: data transfer duration in robot time string format
        """
        logger.info("\nBegin to generate {} port for UL data transfer".format(protocol), also_console=True)
        used_port_list = self.udp.get_occupied_udp_port_list()
        ul_port_num = self.udp.get_available_udp_port(used_port_list)
        logger.info(
            "\nThe {} port used for {} UL data transfer is {}.".format(protocol, self.ue_alias, ul_port_num),
            also_console=True)
        logger.info(
            "\nBegin to perform {} UL data traffic with T-Put {}.".format(self.ue_alias, t_put),
            also_console=True)
        ul_cmd_on_openwrt = self.ul_iperf_cmds(t_put, tput_dura, protocol, ul_port_num)
        self.sshManager.execute(command=ul_cmd_on_openwrt, connection='SMA_{}'.format(self.ue_index))
        time.sleep(1)
        logger.info("\nSuccessfully perform {} UL data traffic with T-Put {} duration is {}.".format(
            self.ue_alias, t_put, tput_dura), also_console=True)

    def smawave_service_stop(self):
        """
        This function is used to stop openwrt COMD service.
        """
        service_list = [comd_stop_cmd, firewall_stop_cmd]
        for cmd in service_list:
            self.sshManager.send_command(command=cmd, connection='SMA_{}'.format(self.ue_index))
            time.sleep(2)
        self.smawave_check_status()

    def smawave_check_status(self):
        """
        This function is used to ensure SMAWave UE in un-attach status
        """
        logger.info("\nBegin to check SMAWave {} status.".format(self.ue_alias), also_console=True)
        output = self.atcmd.send_at_cmd_to_ue(CHECK_CMD, 'SMA_{}'.format(self.ue_index))
        result = self.atcmd.verify_atcmd_output(output)
        logger.info("\nCurrently the SMAWave {} status is {}.".format(self.ue_alias, result), also_console=True)
        return result

    def ue_postcondition(self, ue_num):
        """
        This function is used to perform specific index SMAWave UE teardown operation.
        """
        if not self.conn:
            self.login_ue()

        if self.ue_inuse:
            # add stop COMD process to ensure UE successfully detach
            self.sshManager.send_command(command=comd_stop_cmd, connection='SMA_{}'.format(self.ue_index))
            time.sleep(5)
            self.detach_ue()
            time.sleep(2)
        try:
            self.sshManager.send_command(command=comd_start_cmd, connection='SMA_{}'.format(self.ue_index))
        except Exception as e:
            raise (Exception("ERROR while start COMD:{}".format(e)))
        time.sleep(2)
        if self.ue_inuse:
            if self.dl_async_flag:
                self.dl_ue_async.stop_async(alias='DL_async_{}'.format(self.ue_index))
            if self.ul_async_flag:
                self.ul_ue_async.stop_async(alias='UL_async_{}'.format(self.ue_index))
            if self.ue_index == ue_num:
                self.dl_async_flag = False
                self.ul_async_flag = False
        time.sleep(2)
        rm_route_file_cmd = 'rm -f /tmp/ue_{}_route_table.txt'.format(self.ue_index)
        if self.ip.add_default_route_flag and self.ue_inuse:
            self.sshManager.send_command(command=rm_route_file_cmd, connection='SMA_{}'.format(self.ue_index))
        self.logout_ue()
        time.sleep(2)
        if self.iperf.app_server_conn:
            self.sshManager.disconnect(connection=self.iperf.app_server_conn)

    def get_frequency_locking_information(self):
        """
        This function is used to get the currently locked frequency.

        :return <dict>:
                locked frequency: {'4G': {'xfcn': '1650', 'pci': '310'}, '5G': {'xfcn': '636200', 'scs': '1'}}
             no frequency locked: {'4G': None, '5G': None}
        """
        try:
            if not self.conn:
                self.login_ue()

            self.sshManager.send_command(command=comd_stop_cmd, connection='SMA_{}'.format(self.ue_index))
            time.sleep(2)
            logger.info("\nBegin to query current frequency locking information", also_console=True)
            output = self.atcmd.send_at_cmd_to_ue(CHECK_FREQ_LOCK_CMD, 'SMA_{}'.format(self.ue_index))
            result = self.atcmd.parse_atcmd_locked_freq_info(output)
            logger.info("\nCurrently Locked Frequency Info : {}".format(result), also_console=True)
            for v in result.values():
                assert 'ongoing' not in str(v), "Get Frequency Locking Information Failed!"
            return result

        finally:
            self.sshManager.send_command(command=comd_start_cmd, connection='SMA_{}'.format(self.ue_index))
            self.logout_ue()

    def lock_4g_or_5g_frequency(self, tech, xfcn, pci_4g_or_scs_5g):
        """
        :param tech: 4G or 5G
        :param xfcn: DLEARFCN for 4G, ARFCN for 5G
        :param pci_4g_or_scs_5g: PCI for 4G, SCS for 5G (0 for 15KHZ, 1 for 30KHZ)
        """
        try:
            if not self.conn:
                self.login_ue()

            self.sshManager.send_command(command=comd_stop_cmd, connection='SMA_{}'.format(self.ue_index))
            time.sleep(2)
            logger.info("\nBegin to lock {} frequency".format(tech), also_console=True)
            if str(tech).lower() == '4g':
                lock_cmd = '{}0,1,{},{}'.format(FREQ_LOCK_UNLOCK_CMD, xfcn, pci_4g_or_scs_5g)
            elif str(tech).lower() == '5g':
                lock_cmd = '{}1,1,{},{}'.format(FREQ_LOCK_UNLOCK_CMD, xfcn, pci_4g_or_scs_5g)
            else:
                raise Exception("Not supported technology!")
            output = self.atcmd.send_at_cmd_to_ue(lock_cmd, 'SMA_{}'.format(self.ue_index))
            assert 'ERROR' not in str(output), "Lock Frequency Failed!"
            assert 'OK' in str(output), "Lock Frequency Failed!"
            logger.info("\nLock {} frequency Success".format(tech), also_console=True)

        finally:
            self.sshManager.send_command(command=comd_start_cmd, connection='SMA_{}'.format(self.ue_index))
            self.logout_ue()

    def unlock_4g_or_5g_frequency(self, tech):
        """
        :param tech: 4G or 5G
        """
        try:
            if not self.conn:
                self.login_ue()

            self.sshManager.send_command(command=comd_stop_cmd, connection='SMA_{}'.format(self.ue_index))
            time.sleep(2)
            logger.info("\nBegin to unlock {} frequency".format(tech), also_console=True)
            if str(tech).lower() == '4g':
                unlock_cmd = '{}0,0'.format(FREQ_LOCK_UNLOCK_CMD)
            elif str(tech).lower() == '5g':
                unlock_cmd = '{}1,0'.format(FREQ_LOCK_UNLOCK_CMD)
            else:
                raise Exception("Not supported technology!")
            output = self.atcmd.send_at_cmd_to_ue(unlock_cmd, 'SMA_{}'.format(self.ue_index))
            assert 'ERROR' not in str(output), "Unlock Frequency Failed!"
            assert 'OK' in str(output), "Unlock Frequency Failed!"
            logger.info("\nUnlock {} frequency Success".format(tech), also_console=True)

        finally:
            self.sshManager.send_command(command=comd_start_cmd, connection='SMA_{}'.format(self.ue_index))
            self.logout_ue()

    def fetch_ue_address(self):
        """
        This function is used to get SMAWave assigned IP.
        """
        try:
            self.ip.fetch_smawave_ue_addr(self.ue_index)
        except Exception as e:
            raise Exception("\nFetch UE address failed, error msg is {}.".format(e))

    def set_ue_sa_mode_disable(self):
        """
        This function is used to set SA mode to disabled.
        By default, SMAWave is SA enabled mode. The SA switch will be automatically set to enable after rebooting UE.
        """
        try:
            if not self.conn:
                self.login_ue()

            self.sshManager.send_command(command=comd_stop_cmd, connection='SMA_{}'.format(self.ue_index))
            time.sleep(2)
            logger.info("\nBegin to disable UE SA mode", also_console=True)
            output = self.atcmd.send_at_cmd_to_ue(SA_DISABLE_CMD, 'SMA_{}'.format(self.ue_index))
            # assert 'ERROR' not in str(output), "Disable UE SA Mode Failed!"
            # assert 'OK' in str(output), "Disable UE SA Mode Failed!"
            output = self.atcmd.send_at_cmd_to_ue(SA_CHECK_CMD, 'SMA_{}'.format(self.ue_index))
            result = self.atcmd.parse_atcmd_sa_mode_info(output)
            logger.info("\nCurrently SA mode : {}".format(result), also_console=True)
            if result != 'disable':
                raise Exception("\nDisable UE SA Mode Failed!")
            else:
                logger.info("\nDisable UE SA Mode Success", also_console=True)

        finally:
            self.sshManager.send_command(command=comd_start_cmd, connection='SMA_{}'.format(self.ue_index))
            self.logout_ue()

    def set_ue_sa_mode_enable(self):
        """
        This function is used to set SA mode to disabled.
        By default, SMAWave is SA enabled mode. The SA switch will be automatically set to enable after rebooting UE.
        """
        try:
            if not self.conn:
                self.login_ue()

            self.sshManager.send_command(command=comd_stop_cmd, connection='SMA_{}'.format(self.ue_index))
            time.sleep(2)
            logger.info("\nBegin to enable UE SA mode", also_console=True)
            output = self.atcmd.send_at_cmd_to_ue(SA_ENABLE_CMD, 'SMA_{}'.format(self.ue_index))
            # assert 'ERROR' not in str(output), "Enable UE SA Mode Failed!"
            # assert 'OK' in str(output), "Enable UE SA Mode Failed!"
            output = self.atcmd.send_at_cmd_to_ue(SA_CHECK_CMD, 'SMA_{}'.format(self.ue_index))
            result = self.atcmd.parse_atcmd_sa_mode_info(output)
            logger.info("\nCurrently SA mode : {}".format(result), also_console=True)
            if result != 'enable':
                raise Exception("\nEnable UE SA Mode Failed!")
            else:
                logger.info("\nEnable UE SA Mode Success", also_console=True)

        finally:
            self.sshManager.send_command(command=comd_start_cmd, connection='SMA_{}'.format(self.ue_index))
            self.logout_ue()

    def set_apn(self, apn_name):
        """
        Set APN on SMAWave UE.

        :param apn_name: APN name
        """
        try:
            if not self.conn:
                self.login_ue()

            self.sshManager.send_command(command=comd_stop_cmd, connection='SMA_{}'.format(self.ue_index))
            time.sleep(2)
            logger.info("\nBegin to set APN", also_console=True)
            self.atcmd.send_at_cmd_to_ue(APN_CMD.format(apn_name), 'SMA_{}'.format(self.ue_index))
            # self.reboot_ue()
            time.sleep(10)
            output = self.atcmd.send_at_cmd_to_ue(APN_CHECK_CMD, 'SMA_{}'.format(self.ue_index))
            logger.info("APN set to: {}".format(output), also_console=True)
            if f'"{apn_name}"' not in output:
                raise Exception("APN not changed")
        finally:
            self.sshManager.send_command(command=comd_start_cmd, connection='SMA_{}'.format(self.ue_index))
            self.logout_ue()

    def verify_attached_cell_id(self, cell_id):
        """
        Verify UE is attached to given cell.

        :param cell_id: cell ID
        """
        try:
            if not self.conn:
                self.login_ue()

            self.sshManager.send_command(command=comd_stop_cmd, connection='SMA_{}'.format(self.ue_index))
            time.sleep(2)
            output = self.atcmd.send_at_cmd_to_ue(CHECK_ATTACH_CMD, 'SMA_{}'.format(self.ue_index))
            cell_info = self.atcmd.parse_atcmd_cell_info_into_dict(output.splitlines())
            cell_info["cell_details"][0]["cell_id"] = int(cell_info["cell_details"][0]["cell_id"], 16)
            logger.info("Serving cell info: {}".format(cell_info), also_console=True)
            if cell_info["cell_details"][0]["cell_id"] != int(cell_id):
                raise Exception("UE is not attached to expected Cell ({}): {}".format(cell_id, cell_info))
        finally:
            self.sshManager.send_command(command=comd_start_cmd, connection='SMA_{}'.format(self.ue_index))
            self.logout_ue()
        return cell_info

    def set_default_gateway(self):
        """
        This function is used to add default gateway on SMAWave UE.
        """
        if not self.conn:
            self.login_ue()
        self.smawave_service_stop()
        output = self.atcmd.send_at_cmd_to_ue(APN_CHECK_CMD, 'SMA_{}'.format(self.ue_index))
        _re_ip = r"((\d+\.){3}\d+)"
        ip = re.search(_re_ip, output).group(0)
        gateway_ip = self._increment_ip_address(ip)
        self.sshManager.send_command(command=gateway_cmd.format(gateway_ip), connection='SMA_{}'.format(self.ue_index))
        self.sshManager.send_command(command=comd_start_cmd, connection='SMA_{}'.format(self.ue_index))

    def _increment_ip_address(self, ip):
        ip = ip.split('.')
        ip[-1] = str(int(ip[-1]) + 1)
        incremented_ip = ".".join(ip)
        return incremented_ip
