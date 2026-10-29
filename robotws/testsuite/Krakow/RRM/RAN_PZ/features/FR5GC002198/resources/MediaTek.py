from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from taf.rfrl.utilities.transfer_files import download_files
from taf.rfrl.utilities.robot.general import get_builtin_value
from moler.util.moler_test import MolerTest
from moler.device import DeviceFactory
import moler.config
import datetime
import os
import re


class MediaTek(object):
    def __init__(self, path_mtk_moler_config='resources/moler_device/mtk_cfg.yml', ndis_interface_name="Ethernet 6"):
        self.cur_dir = get_builtin_value('SUITE_SOURCE')
        self.path_mtk_config = path_mtk_moler_config
        self.ndis_name = ndis_interface_name
        self.mtk_config_loaded = False
        self.tshark_output_path = None
        self.appserver_device = None
        self.tshark_device = None
        self.enb_pcap_name = None
        self.enb_pcap_dir = None
        self.enb_tcpdump = None
        self.ue_pc_device = None
        self.mtk_ipaddr = None
        self.enb_device = None
        self.at_device = None
        self.timeout = 180

    def _load_mediatek_moler_config(self):
        if not self.mtk_config_loaded:
            split_dir = self.cur_dir.split('/')
            mtk_config_abs_path = os.path.join('/'.join(split_dir[:-1]), self.path_mtk_config)
            MolerTest.info('MTK moler config loaded from yaml: {}'.format(mtk_config_abs_path))
            moler.config.load_config(config=mtk_config_abs_path)
            self.mtk_config_loaded = True

    def _create_at_device(self):
        self._load_mediatek_moler_config()
        self.at_device = DeviceFactory.get_device(name='AT_1', initial_state='UNIX_LOCAL')
        self.ue_pc_device = DeviceFactory.get_cloned_device("AT_1", "UE0_PC_AT", initial_state="UNIX_LOCAL")

    def _create_devices(self):
        self.appserver_device = DeviceFactory.get_device(name='APP_SERVER0_0', initial_state='UNIX_REMOTE')
        self.enb_device = DeviceFactory.get_device(name='ENB0_DU0', initial_state='FCT')
        self.tshark_device = DeviceFactory.get_cloned_device("GNB0_DU0", "GNB0_DU0_TSHARK", initial_state="PROXY_PC")

    def _at(self):
        try:
            at_cmd = self.at_device.get_cmd(cmd_name='at')
            at_cmd(timeout=self.timeout)
        except Exception as e:
            self.at_device.goto_state('UNIX_LOCAL')
            MolerTest.error('AT command execution Failure. Exception occurred: {}'.format(e),
                            raise_exception=True)

    def _verify_attach_state(self, attached=True):
        cgatt_cmd = self.at_device.get_cmd(cmd_name='get_attach_state')
        cgatt_state = None

        if attached:
            expected_state = 'attached'
        else:
            expected_state = 'detached'

        try:
            cgatt_state = cgatt_cmd(timeout=self.timeout)['state']
        except Exception as e:
            MolerTest.error("AT command execution failure. Exception occurred: {}".format(e),
                            raise_exception=True)

        if cgatt_state == expected_state:
            MolerTest.info("Mediatek UE Attach success.\n'AT+CGATT?' cmd result: {}".format(cgatt_state))
        else:
            MolerTest.error("MediaTek UE attach failure.\n'AT+CGATT?' cmd result: {}\nExpected result: {}".format(
                cgatt_state, expected_state), raise_exception=True)

    def attach(self):
        self._create_at_device()
        self.at_device.goto_state('AT_REMOTE', rerun=3)
        attach_cmd = self.at_device.get_cmd(cmd_name='attach')
        attach_cmd.command_string = "AT+EFUN=1"
        self._at()
        try:
            attach_cmd(timeout=self.timeout)
            MolerTest.sleep(10)  # Wait for attach procedure finish
            self._verify_attach_state()
        except Exception as e:
            MolerTest.error('Attach MediaTek UE Failure. Exception occurred: {}'.format(e))
        finally:
            self.at_device.goto_state('UNIX_REMOTE')

    @MolerTest.raise_background_exceptions()
    def detach(self):
        self._create_at_device()
        self.at_device.goto_state('AT_REMOTE', rerun=3)
        detach_cmd = self.at_device.get_cmd(cmd_name='detach')
        detach_cmd.command_string = "AT+EFUN=0"
        self._at()
        try:
            detach_cmd(timeout=self.timeout)
            MolerTest.sleep(10)  # Wait for detach procedure finish
            self._verify_attach_state(attached=False)
        except Exception as e:
            MolerTest.error('Detach MediaTek UE Failure. Exception occurred: {}'.format(e),
                            raise_exception=True)
        finally:
            self.at_device.goto_state('UNIX_LOCAL')

    def _enb_sniffer(self, interface="br1", msg_filter="sctp"):
        self.enb_tcpdump = self.enb_device.get_cmd(cmd_name="tcpdump", cmd_params={
            "options": "-ni {} -s0 -w /tmp/{} {} -v".format(interface, self.enb_pcap_name, msg_filter)})

    def _start_enb_tcpdump(self):
        self._create_devices()
        timestamp = datetime.datetime.now().strftime("%H_%M_%S")
        self.enb_pcap_name = "ENB_S1_ATTACH_LOG_{}.pcap".format(timestamp)
        self.enb_device.goto_state('FCT', rerun=3)
        self._enb_sniffer()
        self.enb_tcpdump.start(timeout=self.timeout)

    def _stop_enb_tcpdump(self):
        self.enb_tcpdump.break_cmd()

    def _download_pcap_from_enb(self):
        output_dir = get_builtin_value('LOG_PATH')
        download_files(local_dir=output_dir, remote_file=self.enb_pcap_name, device_name="ENB0_DU0",
                       remote_dir="/tmp/", from_state="FCT", timeout=self.timeout, remove_source_file=True)

    @load_moler_configuration_from_tl()
    def attach_with_log_collection(self):
        try:
            self._start_enb_tcpdump()
            self.attach()
        except Exception as e:
            MolerTest.error('Exception occurred during attach with eNB tcpdump collection procedure: {}'.format(e),
                            raise_exception=True)
        finally:
            self._stop_enb_tcpdump()
        self._download_pcap_from_enb()
        self._get_ip_address_from_pcap()
        self._update_ndis_interface()
        self._enable_ndis_interface()

    def _read_ip(self):
        pattern_ip = re.compile(r'(\d+\.\d+\.\d+\.\d+)')
        with open(self.tshark_output_path) as f:
            tshark_output = f.readlines()
        if tshark_output:
            MolerTest.info('Tshark output: {}'.format(tshark_output))
            for line in tshark_output:
                found_ip = re.search(pattern_ip, line)
                if found_ip:
                    self.mtk_ipaddr = found_ip.group(0)
                    MolerTest.info('UE IP address found in S1AP msg: {}'.format(self.mtk_ipaddr))
                    break
        else:
            MolerTest.error('Tshark result file is empty. UE IP address not found in InitialContextSetupRequestCheck '
                            'message. Check if tshark is installed properly and verify logs from attach: {}'
                            ''.format(self.enb_pcap_dir), raise_exception=True)

    def _get_ip_address_from_pcap(self):
        log_path = get_builtin_value('LOG_PATH')
        self.tshark_output_path = os.path.join(log_path, 'UE_IPADDR_TSHARK_OUTPUT.txt')
        self.enb_pcap_dir = os.path.join(log_path, self.enb_pcap_name)
        self.tshark_device.goto_state('PROXY_PC', rerun=3)
        tshark_cmd = self.tshark_device.get_cmd(cmd_name="tshark", cmd_params={
            "options": """-r {} -Y "s1ap.InitialContextSetupRequest_element" -T fields -e nas_eps.esm.pdn_ipv4  \
                > {}""".format(self.enb_pcap_dir, self.tshark_output_path)})
        tshark_cmd(timeout=self.timeout)
        self._read_ip()

    def _get_ndis_gateway(self):
        lst_ip = self.mtk_ipaddr.split('.')
        gateway = lst_ip[:-1] + [str(int(lst_ip[-1]) + 1)]
        return '.'.join(gateway)

    def _update_ndis_interface(self):
        gw_ip = self._get_ndis_gateway()
        cmd_set_ipaddr = 'netsh interface ipv4 set address name="{}" static {} mask=255.255.255.0 gateway={}'
        self.ue_pc_device.goto_state('UNIX_REMOTE', rerun=3)
        set_ndis_ipaddr = self.ue_pc_device.get_cmd(
            cmd_name="run_script",
            cmd_params={'script_command': cmd_set_ipaddr.format(self.ndis_name, self.mtk_ipaddr, gw_ip)})
        set_ndis_ipaddr(timeout=self.timeout)

    def _enable_ndis_interface(self, nsa=True):
        cmd_enable = 'AT+CGDATA="M-RNDIS",{},0'.format('0' if nsa else '1')
        self.at_device.goto_state('AT_REMOTE', rerun=3)
        enable_ndis = self.at_device.get_cmd(
            cmd_name="run_script",
            cmd_params={'script_command': cmd_enable})
        enable_ndis(timeout=self.timeout)
        MolerTest.sleep(20)  # Wait until interface change state to "Enabled"
        self.at_device.goto_state('UNIX_REMOTE', rerun=3)

    def release_ndis_interface(self, nsa=True):
        cmd_release = 'AT+EGLD={}'.format('0' if nsa else '1')
        self.at_device.goto_state('AT_REMOTE', rerun=3)
        release_ndis = self.at_device.get_cmd(
            cmd_name="run_script",
            cmd_params={'script_command': cmd_release})
        release_ndis(timeout=self.timeout)
        MolerTest.info('Remote NDIS interface was released.')
        self.at_device.goto_state('UNIX_REMOTE', rerun=3)

    def check_appserver_ndis_connection(self, after_ho=False, icmp_req=30):
        self._create_devices()
        self.appserver_device.goto_state('UNIX_REMOTE', rerun=3)
        cmd_ping = self.appserver_device.get_cmd(
            cmd_name="ping",
            cmd_params={'destination': self.mtk_ipaddr, 'options': '-c {}'.format(icmp_req)})
        ping_result = cmd_ping(timeout=int(icmp_req)*2)
        packet_loss = ping_result['packet_loss']
        check_phase = 'after HO' if after_ho else 'before HO'
        self.appserver_device.goto_state('UNIX_LOCAL', rerun=3)

        if packet_loss == 0:
            MolerTest.info('Connection between Appserver and Remote NDIS interface is alive "{}" procedure. '
                           '"{}"'.format(check_phase, ping_result))
        elif packet_loss <= 15:
            MolerTest.warning('ICMP packet loss "{}"% was detected during Appserver - Remote NDIS interface connection'
                              ' check "{}" procedure. "{}"'.format(ping_result['packet_loss'], check_phase,
                                                                   ping_result))
        else:
            MolerTest.error('Appserver - Remote NDIS PC_UE interface connection failure "{}" procedure. '
                            '"{}"'.format(check_phase, ping_result), raise_exception=True)
