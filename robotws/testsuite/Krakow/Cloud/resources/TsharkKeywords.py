from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from taf.rfrl.bts.devices.du.pm_counters import GnbPmCounter as GnbCounter
from taf.internal.sbts.admin.exceptions import AdminApiProcedureFailureException
from taf.rfrl.utilities.transfer_files import download_files
from robot.libraries.BuiltIn import BuiltIn
from moler.util.moler_test import MolerTest
from moler.device import DeviceFactory
import re
import json


class TsharkKeywords(object):
    def __init__(self):
        self._was_created = False
        self.x2_link_sniffer = None
        self.s1u_link_sniffer = None
        self.f1u_link_sniffer = None
        self.ue_tracker = None
        self.x2_sniffer_cmd = None
        self.s1u_sniffer_cmd = None
        self.f1u_sniffer_cmd = None
        self.ue_sniffer_cmd = None
        self.traffic_validator = None
        self.default_cmd_timeout = 600
        self.ue_serial_number = None
        self.ue_pcap_file_location = None
        self.app_server_traffic_address = None
        self.s1u_interface_address = None
        self.f1u_interface_address = None

    def start_traffic_sniffers(self):
        self._create_all_sniffers()
        self.x2_sniffer_cmd.start(timeout=self.default_cmd_timeout)
        self.s1u_sniffer_cmd.start(timeout=self.default_cmd_timeout)
        self.f1u_sniffer_cmd.start(timeout=self.default_cmd_timeout)
        self.ue_sniffer_cmd.start(timeout=self.default_cmd_timeout)

    def stop_traffic_sniffers_and_collect_results(self):
        self.x2_sniffer_cmd.break_cmd()
        self.s1u_sniffer_cmd.break_cmd()
        self.f1u_sniffer_cmd.break_cmd()
        self.ue_sniffer_cmd.break_cmd()
        self._collect_results_from_all_sniffers()
        self.traffic_validator = DeviceFactory.get_cloned_device("GNB0", "GNB0_traffic_validator",
                                                                 initial_state="PROXY_PC")

    def check_dl_traffic(self, data_ciphered):
        """
        Check if DL packets are ciphered correctly.

        :param data_ciphered: True if data is ciphered or False if not
        :return: None
        """
        tshark_cmd = self.traffic_validator.get_cmd(cmd_name="tshark", cmd_params={
            "options": """-r {} -Y "ip.dst == {} && gtp.message
             == 0xff && gtp.length > 500" -T  fields -e gtp.tpdu_data >> result""".format("/tmp/s1u.pcap",
                                                                                          self.s1u_interface_address)})
        tshark_cmd(timeout=50)
        data = self._get_tshark_result_data()
        if data:
            self._validate_packets_data_content(data, "3031323334353637383930313233343536373839", False)
        else:
            MolerTest.error("DL data packet on S1u doesn't contain expected data content", raise_exception=True)
        self._delete_result_file()
        tshark_cmd = self.traffic_validator.get_cmd(cmd_name="tshark", cmd_params={
            "options": """-r {} -Y "ip.src=={} && udp" -x -T json >> result""".
                                                    format("/tmp/UE.pcap",
                                                           self.app_server_traffic_address)})
        tshark_cmd(timeout=50)
        data = self._get_tshark_result_data(json_format=True)
        if data:
            self._validate_packets_data_content(data, "3031323334353637383930313233343536373839", False)
        else:
            MolerTest.error("DL data packet received on iPerf UE doesn't contain expected data content",
                            raise_exception=True)
        self._delete_result_file()
        tshark_cmd = self.traffic_validator.get_cmd(cmd_name="tshark", cmd_params={
            "options": """-r {} -Y "ip.src == {} && gtp.message
             == 0xff && gtp.length > 500" -T  fields -e gtp.tpdu_data >> result""".format("/tmp/f1u.pcap",
                                                                                          self.f1u_interface_address)})
        tshark_cmd(timeout=50)
        data = self._get_tshark_result_data()
        if data:
            self._validate_packets_data_content(data, "3031323334353637383930313233343536373839", data_ciphered)
        else:
            MolerTest.error("DL data packet on F1u doesn't contain expected data content", raise_exception=True)
        self._delete_result_file()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions()
    def check_ul_traffic(self, data_ciphered):
        """
        Check if UL packets are ciphered correctly.

        :param data_ciphered: True if data is ciphered or False if not
        :return: None
        """
        tshark_cmd = self.traffic_validator.get_cmd(cmd_name="tshark", cmd_params={
            "options": """-r {} -Y "ip.src == {} && gtp.message
            == 0xff && gtp.length > 500" -T  fields -e gtp.tpdu_data >> result""".format("/tmp/s1u.pcap",
                                                                                         self.s1u_interface_address)})
        tshark_cmd(timeout=50)
        data = self._get_tshark_result_data()
        if data:
            self._validate_packets_data_content(data, "3031323334353637383930313233343536373839", False)
        else:
            MolerTest.error("UL data packet on S1u doesn't contain expected data content", raise_exception=True)
        self._delete_result_file()
        tshark_cmd = self.traffic_validator.get_cmd(cmd_name="tshark", cmd_params={
            "options": """-r {} -Y "ip.dst == {} && gtp.message
             == 0xff && gtp.length > 500" -T  fields -e gtp.tpdu_data >> result""".format("/tmp/f1u.pcap",
                                                                                          self.f1u_interface_address)})
        tshark_cmd(timeout=50)
        data = self._get_tshark_result_data()
        if data:
            self._validate_packets_data_content(data, "3031323334353637383930313233343536373839", data_ciphered)
        else:
            MolerTest.error("UL data packet on F1u doesn't contain expected data content", raise_exception=True)
        self._delete_result_file()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions()
    def check_nea(self, n):
        """
        Check if information about NEA ciphering algorithm is sent over x2 link.

        :param n: number NEA version indicator
        :return: None
        """
        self._check_pattern_in_packet(r".*SgNBAdditionRequest.*RRC Reconfiguration$",
                                      "cipheringAlgorithm: nea{}".format(n))

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions()
    def check_nia(self, n):
        """
        Check if information about NIA ciphering algorithm is sent over x2 link.

        :param n: number NIA version indicator
        :return: None
        """
        self._check_pattern_in_packet(r".*SgNBAdditionRequest$", "128-NIA{}: Supported".format(n))

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions()
    def check_srb3(self):
        """
        Check if information about SRB3 support is sent over x2 link.

        :return: None
        """
        self._check_pattern_in_packet(r".*SgNBAdditionRequest$", "srb3: supported")

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions()
    def check_event_a3_rsrp(self):
        """
        Check if information about A4 RSRP event is sent over x2 link.

        :return: None
        """
        self._check_pattern_in_packet(r".*RRC Reconfiguration$", "a3-Offset")

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions()
    def check_sgnb_addition(self):
        """
        Check if information about DL traffic forwarding via GTP tunnel is sent over x2 link.

        :return: None
        """
        self._check_pattern_in_packet(r".*SgNBAdditionRequest.*RRC Reconfiguration$",
                                      "dL-Forwarding-GTPtunnelEndpoint")

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions()
    def check_long_drx_cycle(self):
        """
        Check if information about longDRX-Cycle support is sent over x2 link.

        :return: None
        """
        self._check_pattern_in_packet(r".*SgNBAdditionRequest$", "longDRX-Cycle: supported (0)")

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions()
    def check_sgnb_addition_reject(self):
        """
        Check if information about longDRX-Cycle support is sent over x2 link.

        :return: None
        """
        self._check_pattern_in_packet(r".*SgNBAdditionRequestReject$", "radioNetwork: tDCprep-expiry")

    def validate_drx_counters_are_correctly_managed(self):
        """
        Check if DRX counters M55308C11001, M55308C11002 are managed properly by BTS.

        :return: None
        """
        counters_check_number = 0
        while counters_check_number < 30:
            try:
                du_counters = GnbCounter()
                slots_ue_drx_active_dict = du_counters.get_counter("M55308C11001")["BTS"]["CELLS"]
                slots_ue_drx_sleep_dict = du_counters.get_counter("M55308C11002")["BTS"]["CELLS"]
                if self._get_drx_counters_values(slots_ue_drx_active_dict, slots_ue_drx_sleep_dict):
                    break
                else:
                    counters_check_number = counters_check_number + 1
            except AdminApiProcedureFailureException:
                counters_check_number = counters_check_number + 1
            MolerTest.sleep(30)
        else:
            MolerTest.error("DRX counters are NOT correctly managed", raise_exception=True)

    @load_moler_configuration_from_tl()
    def _create_all_sniffers(self):
        tl = BuiltIn().get_variable_value('${{{}}}'.format("tl"), None)
        self.ue_serial_number = tl.ues[0].serial_number
        self.ue_pcap_file_location = "{}UE.pcap".format(tl.ues[0].iperf_directory)
        self.app_server_traffic_address = tl.ues[0].iperf_details.network_interface_address
        self.s1u_interface_address = tl.gnbs[0].cu.s1u.v4
        self.f1u_interface_address = tl.gnbs[0].cu.f1u.v4
        self.x2_link_sniffer = DeviceFactory.get_cloned_device("ENB0_DU0", "ENB0_x2", initial_state="FCT")
        self.s1u_link_sniffer = DeviceFactory.get_cloned_device("GNB0_CU", "GNB0_CU_s1u", initial_state="UPUE")
        self.f1u_link_sniffer = DeviceFactory.get_cloned_device("GNB0_CU", "GNB0_CU_f1u", initial_state="UPUE")
        self.ue_traffic_sniffer = DeviceFactory.get_cloned_device("UE0_PC", "UE0_PC_traffic",
                                                                  initial_state="UNIX_REMOTE")

        self.x2_sniffer_cmd = self.x2_link_sniffer.get_cmd(cmd_name="tcpdump", cmd_params={
            "options": "-ni {} -w {} sctp -v".format("br1", "/tmp/x2.pcap")})
        s1u_sniffer_cmd = self.s1u_link_sniffer.get_cmd(cmd_name="tcpdump", cmd_params={
            "options": "-i backhaul -w {}".format("/tmp/s1u.pcap")})
        self.s1u_sniffer_cmd = self.s1u_link_sniffer.get_cmd(cmd_name="sudo",
                                                             cmd_params={"password": "",
                                                                         "cmd_object": s1u_sniffer_cmd})
        f1u_sniffer_cmd = self.f1u_link_sniffer.get_cmd(cmd_name="tcpdump", cmd_params={
            "options": "-i fronthaul -w {}".format("/tmp/f1u.pcap")})
        self.f1u_sniffer_cmd = self.f1u_link_sniffer.get_cmd(cmd_name="sudo",
                                                             cmd_params={"password": "",
                                                                         "cmd_object": f1u_sniffer_cmd})
        self.ue_sniffer_cmd = self.ue_traffic_sniffer.get_cmd(cmd_name="run_script", cmd_params={
            "script_command": "adb -s {} root;adb -s {} shell 'tcpdump -c 8000 -i any -w {}'".format(
                self.ue_serial_number, self.ue_serial_number, self.ue_pcap_file_location)})

    def _collect_results_from_all_sniffers(self):
        change_s1u_pcap_permissions = self.s1u_link_sniffer.get_cmd(cmd_name="chmod",
                                                                    cmd_params={"filename": "/tmp/s1u.pcap",
                                                                                "permission": "777"})
        change_f1u_pcap_permissions = self.f1u_link_sniffer.get_cmd(cmd_name="chmod",
                                                                    cmd_params={"filename": "/tmp/f1u.pcap",
                                                                                "permission": "777"})
        self.ue_traffic_sniffer.get_cmd(cmd_name="run_script", cmd_params={
            "script_command": "adb -s {} pull {}".format(self.ue_serial_number, self.ue_pcap_file_location)})()
        self.ue_traffic_sniffer.get_cmd(cmd_name="run_script", cmd_params={
            "script_command": "adb -s {} shell 'rm {}'".format(self.ue_serial_number, self.ue_pcap_file_location)})()
        self.s1u_link_sniffer.get_cmd(cmd_name="sudo",
                                      cmd_params={"password": "", "cmd_object": change_s1u_pcap_permissions})()
        self.f1u_link_sniffer.get_cmd(cmd_name="sudo",
                                      cmd_params={"password": "", "cmd_object": change_f1u_pcap_permissions})()
        download_files(local_dir="/tmp/", remote_file="x2.pcap", device_name="ENB0_x2", remote_dir="/tmp/",
                       from_state="FCT", timeout=self.default_cmd_timeout, remove_source_file=True)
        download_files(local_dir="/tmp/", remote_file="*.pcap", device_name="GNB0_CU_s1u", remote_dir="/tmp/",
                       from_state="UPUE", timeout=self.default_cmd_timeout, remove_source_file=True)
        download_files(local_dir="/tmp/", remote_file="UE.pcap", device_name="UE0_PC", remote_dir="/home/user-lab0/",
                       from_state="UNIX_REMOTE", timeout=self.default_cmd_timeout, remove_source_file=True)

    def _delete_result_file(self):
        rm_cmd = self.traffic_validator.get_cmd(cmd_name="rm", cmd_params={"file": "/home/ute/result"})
        rm_cmd()

    def _check_pattern_in_packet(self, packet_regex, pattern):
        if not self._was_created:
            self.traffic_validator = DeviceFactory.get_cloned_device("GNB0", "GNB0_tshark", initial_state="PROXY_PC")
        tshark_cmd = self.traffic_validator.get_cmd(cmd_name="tshark", cmd_params={
            "options": """ -Y "x2ap and frame.number=={}" -nVr {} | grep "{}"  >> result""".format(
                self._find_pattern_packet_numbers(packet_regex)[0], "/tmp/x2.pcap", pattern)})
        tshark_cmd(timeout=50)
        pattern_string_line = self._get_tshark_result_data()
        if pattern_string_line:
            MolerTest.info(pattern_string_line)
        else:
            MolerTest.error("'{}' string NOT found".format(pattern), raise_exception=True)
        self._delete_result_file()

    def _find_pattern_packet_numbers(self, pattern_regex):
        tshark_cmd = self.traffic_validator.get_cmd(cmd_name="tshark", cmd_params={
            "options": """ -Y "x2ap" -nr {} >> result""".format("/tmp/x2.pcap")})
        tshark_cmd(timeout=50)
        data = self._get_tshark_result_data()
        packet_numbers = []
        for packet in data:
            if re.match(pattern_regex, packet):
                packet_numbers = re.findall(r"\d+", packet)
        self._delete_result_file()
        if packet_numbers:
            return packet_numbers
        else:
            MolerTest.error("Cannot find packets match to pattern", raise_exception=True)

    def _validate_packets_data_content(self, data, expected_content, ciphered):
        packets_with_expected_content = 0
        packets_with_unrecognizable_content = 0
        for packet in data:
            if expected_content in packet:
                packets_with_expected_content = packets_with_expected_content + 1
            else:
                packets_with_unrecognizable_content = packets_with_unrecognizable_content + 1
        self._validate_content_scheme(ciphered, len(data), packets_with_expected_content,
                                      packets_with_unrecognizable_content)

    @staticmethod
    def _validate_content_scheme(ciphered, packets_number, non_ciphered_packets, ciphered_packets):
        if ciphered:
            if ciphered_packets == packets_number and non_ciphered_packets == 0:
                MolerTest.info("All {} packets contain expected content".format(packets_number))
            else:
                MolerTest.error("There are {} packets with unexpected content".format(non_ciphered_packets),
                                dump="Full packets content is located in '/home/ute/result'", raise_exception=True)
        else:
            if non_ciphered_packets == packets_number and ciphered_packets == 0:
                MolerTest.info("All {} packets contain expected content".format(packets_number))
            else:
                MolerTest.error("There are {} packets with unexpected content".format(ciphered_packets),
                                dump="Full packets content is located in '/home/ute/result'", raise_exception=True)

    @staticmethod
    def _get_drx_counters_values(slots_ue_drx_active_dict, slots_ue_drx_sleep_dict):
        time_stamps = sorted(slots_ue_drx_active_dict["NRCELL-1"]["NCELA"]["M55308C11001"].keys())
        slots_ue_drx_active = int(slots_ue_drx_active_dict["NRCELL-1"]["NCELA"]["M55308C11001"][time_stamps[-1]])
        slots_ue_drx_sleep = int(slots_ue_drx_sleep_dict["NRCELL-1"]["NCELA"]["M55308C11002"][time_stamps[-1]])
        if slots_ue_drx_active > 0 and slots_ue_drx_sleep > 0:
            MolerTest.info("DRX counters are correctly managed", dump={"SLOTS_UE_DRX_ACTIVE": slots_ue_drx_active,
                                                                       "SLOTS_UE_DRX_SLEEP": slots_ue_drx_sleep})
            return True
        else:
            MolerTest.info("Wait for counters change ...", dump={"SLOTS_UE_DRX_ACTIVE": slots_ue_drx_active,
                                                                 "SLOTS_UE_DRX_SLEEP": slots_ue_drx_sleep})
            return False

    @staticmethod
    def _get_tshark_result_data(json_format=False):
        with open('/home/ute/result') as f:
            if json_format:
                bytes_tab = []
                for packet in json.load(f):
                    bytes_tab.append(packet["_source"]["layers"]["frame_raw"][0])
                return bytes_tab
            else:
                return f.readlines()
