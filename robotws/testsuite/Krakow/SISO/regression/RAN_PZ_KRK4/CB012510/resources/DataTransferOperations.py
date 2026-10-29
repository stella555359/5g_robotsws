"""
Data Transfer Keywords
"""
from taf.hw.rf_attenuator.interface import rf_attenuator
from robot.libraries.BuiltIn import BuiltIn
from moler.device import DeviceFactory
from taf.rfrl.ue.connections.device_aliases import ue_pc
from taf.rfrl.utilities.robot.general import get_builtin_instance
from taf.rfrl.ue.iperf.tput_runner import ThroughputRunner
from taf.ue.rpc.mtk.interface import mtk
from taf.rfrl.bts.devices.du.commissioning import GnbCommissioning
from taf.rfrl.utilities.tl_config import get_global_bts_id
from moler.util.moler_test import MolerTest
from taf.rfrl.bts.devices.du.cell_operations import GnbCellOperations
import logging
import time
from taf.rfrl.ue.custom_ues import AndroidUe


class AttenuatorOperations(object):
    def __init__(self):
        self.tl = BuiltIn().get_variable_value('${{{}}}'.format("tl"), None)
        self.attenuator_device = rf_attenuator()

    def set_attenuation(self, configuration):
        """
        Set values to multiple attenuator's ports.
        :param configuration: attenuator configuration dictionary contained
        attenuator's port identifiers and corresponding attenuation values e.g.:
        configuration = {"port_identifiers":   [5, 6],
                         "attenuation_values": [20, 20]}
        :type  configuration: dict
        :return: None
        """

        self.attenuator_device.setup_attenuator(attenuator=self.tl.attenuator)
        ports = configuration["port_identifiers"]
        values = configuration["attenuation_values"]
        for i in range(len(ports)):
            self.attenuator_device.set_attenuation(
                port=ports[i],
                value=values[i])
            attenuation = self.attenuator_device.read_attenuation(port=ports[i])
            if attenuation != values[i]:
                MolerTest.error("Attenuation not changed")

    def set_max_attenuation_to_all_ports(self, number_of_ports=16, max_value=63):
        self.attenuator_device.setup_attenuator(attenuator=self.tl.attenuator)
        for port_id in range(1, int(number_of_ports) + 1):
            self.attenuator_device.set_attenuation(port=port_id, value=int(max_value))


class QualcommUeOperations(object):
    def __init__(self):
        self.tl = BuiltIn().get_variable_value('${{{}}}'.format("tl"), None)
        self.current_ue_config = None
        self.network_selecting_at_cmds = {"NR": ["AT+EFUN=0", "AT+ERAT=0", "AT+ERAT=15", "AT+E5GOPT=3", "AT+EFUN=1"],
                                          "LTE": ["AT+EFUN=0", "AT+ERAT=0", "AT+ERAT=3", "AT+EFUN=1"]}
        self.attach_at_commands = ["AT+EFUN=1"]
        self.detach_at_commands = ["AT+EFUN=0"]
        self.hostname = self.tl.ues[0].ssh_connection_details.addr
        self.username = self.tl.ues[0].ssh_connection_details.username
        self.password = self.tl.ues[0].ssh_connection_details.password
        self.port = self.tl.ues[0].server_port
        self.server_dir = self.tl.ues[0].server_dir
        self.python_path = self.tl.ues[0].python_path
        self.edb_file_path = self.tl.ues[0].edb_file_path
        self.apn_config = {"5gkrk2": {"starting_activity": "android.settings.DATA_ROAMING_SETTINGS",
                                      "key_events_combination": [20, 20, 20, 20, 20, 20, 20, 66, 20, 20, 20, 20,
                                                                 20, 20, 66, 61, 61, 66]},
                           "5gsakrk2": {"starting_activity": "android.settings.DATA_ROAMING_SETTINGS",
                                        "key_events_combination": [20, 20, 20, 20, 20, 20, 20, 66, 20, 20, 20,
                                                                   20, 20, 20, 66, 20, 61, 61, 66]}}

    def set_apn(self, apn_name, ue_id=0):
        ue_pc_device = DeviceFactory.get_device(name=ue_pc.format(ue_id), initial_state="UNIX_REMOTE")
        ue_serial_number = self.tl.ues[ue_id].serial_number
        start_activity_cmd = "adb -s {} shell 'am start -a {}'".format(ue_serial_number,
                                                                       self.apn_config[apn_name]["starting_activity"])
        stop_activity_cmd = "adb -s {} shell 'am force-stop {}'".format(ue_serial_number, "com.android.settings")
        ue_pc_device.get_cmd(cmd_name="run_script", cmd_params={'script_command': start_activity_cmd})()
        time.sleep(5)
        ue_pc_device.get_cmd(cmd_name="run_script", cmd_params={'script_command': start_activity_cmd})()
        for key_event in self.apn_config[apn_name]["key_events_combination"]:
            time.sleep(1)
            key_event_cmd = "adb -s {} shell 'input keyevent {}'".format(ue_serial_number, key_event)
            ue_pc_device.get_cmd(cmd_name="run_script", cmd_params={'script_command': key_event_cmd})()
        ue_pc_device.get_cmd(cmd_name="run_script", cmd_params={'script_command': stop_activity_cmd})()
        time.sleep(3)

    def lock_ue_screen(self, ue_id=0):
        ue_pc_device = DeviceFactory.get_device(name=ue_pc.format(ue_id), initial_state="UNIX_REMOTE")
        ue_serial_number = self.tl.ues[ue_id].serial_number
        lock_cmd = "adb -s {} shell 'input keyevent 3;input keyevent 26'".format(ue_serial_number)
        ue_pc_device.get_cmd(cmd_name="run_script", cmd_params={'script_command': lock_cmd})()

    def unlock_ue_screen(self, ue_id=0):
        ue_pc_device = DeviceFactory.get_device(name=ue_pc.format(ue_id), initial_state="UNIX_REMOTE")
        ue_serial_number = self.tl.ues[ue_id].serial_number
        lock_cmd = "adb -s {} shell 'input keyevent 26;sleep 1;input keyevent 82'".format(ue_serial_number)
        ue_pc_device.get_cmd(cmd_name="run_script", cmd_params={'script_command': lock_cmd})()

    def set_ue_configuration(self, network_type):
        if self.current_ue_config != network_type:
            if network_type == "NR":
                self.set_apn(apn_name="5gsakrk2")
            elif network_type == "LTE":
                self.set_apn(apn_name="5gkrk2")
            else:
                logging.error("Unsupported network_type: '{}'. 'NR' and 'LTE' supported only.")
                raise NetworkTypeNotSupportedException
            self.current_ue_config = network_type
        else:
            logging.info("UE settings reconfiguration skipped. Current UE configuration: '{}' as expected.".format(
                self.current_ue_config))

    @MolerTest.raise_background_exceptions()
    def run_at_commands(self, at_commands):
        """
        Run AT commands on MTK UE.

        :param list at_commands: list of AT commands
        :return: None
        """
        mtk_device = mtk()
        mtk_device.configure(hostname=self.hostname, port=self.port, username=self.username, password=self.password,
                             server_dir=self.server_dir, python_path=self.python_path)
        mtk_device.setup()
        mtk_device.create_proxy()
        mtk_device.connect_device(edb_file_path=self.edb_file_path)
        for command in at_commands:
            mtk_device.send_at_command(command)
            MolerTest.sleep(5)
        mtk_device.disconnect_device()
        mtk_device.teardown()

    @MolerTest.raise_background_exceptions()
    def run_at_command(self, at_command):
        """
        Run AT commands on MTK UE.

        :param list at_commands: list of AT commands
        :return: None
        """
        mtk_device = mtk()
        mtk_device.configure(hostname=self.hostname, port=self.port, username=self.username, password=self.password,
                             server_dir=self.server_dir, python_path=self.python_path)
        mtk_device.setup()
        mtk_device.create_proxy()
        mtk_device.connect_device(edb_file_path=self.edb_file_path)
        cmd_ret = mtk_device.send_at_command(at_command)
        mtk_device.disconnect_device()
        mtk_device.teardown()
        return cmd_ret

    @MolerTest.raise_background_exceptions()
    def prepare_ue_network_type(self, network_type, ue_id=0, airplane_mode_coordinates=None):
        """
        Select network and set apn on MTK UE.

        :param apn: APN name: "5gsakrk", "5gkrk", "5gkrk2"
        :param rat: RAT: "NR", "LTE", "WCDMA", "GSM"
        :return: None
        """
        android_ue = AndroidUe(ue_id=ue_id, airplane_mode_coordinates=airplane_mode_coordinates)
        for _ in range(5):
            self.set_ue_configuration(network_type)
            self.run_at_commands(self.network_selecting_at_cmds[network_type])
            MolerTest.sleep(10)
            ue_ip = android_ue.get_ue_ip()
            if ue_ip:
                MolerTest.info("UE IP:", dump=ue_ip)
                return
        MolerTest.error("UE_{} cannot get ip".format(ue_id), raise_exception=True)


class DataTransferKeywords(AttenuatorOperations, QualcommUeOperations):
    def __init__(self):
        AttenuatorOperations.__init__(self)
        QualcommUeOperations.__init__(self)
        self.ue_controlled = False
        self.ue = get_builtin_instance("ue")
        self.tput_runner = ThroughputRunner()
        self.bts_id = get_global_bts_id(bts_id=0, du_id=0)
        self.gnb_scf = GnbCommissioning()
        self.gnb_cell = GnbCellOperations()

    def attach_mtk_ue(self):
        self.run_at_commands(self.attach_at_commands)

    def detach_mtk_ue(self):
        self.run_at_commands(self.detach_at_commands)

    def start_dl_tcp_data_transfer(self, duration, expected_tput, tolerance):
        self.tput_runner.set_data_transfer_parameters(
            protocol="tcp", server_buffer_dl="", client_buffer_dl="", buffer_len_dl="", parallel_streams_dl="2",
            data_size_dl="", congestion="cubic", maximum_segment_size="1408")
        self.tput_runner.run_dl_traffic_with_ues_simultaneously(duration=duration)
        self.tput_runner.validate_current_throughput_values(
            transfers_to_validate="1", dl_tput=expected_tput, tolerance=tolerance)

    def start_ul_tcp_data_transfer(self, duration, expected_tput, tolerance):
        self.tput_runner.set_data_transfer_parameters(
            protocol="tcp", buffer_ul="", buffer_len_ul="", parallel_streams_ul="1", data_size_ul="",
            maximum_segment_size="1408")
        self.tput_runner.run_ul_traffic_with_ues_simultaneously(duration=duration)
        self.tput_runner.validate_current_throughput_values(
            transfers_to_validate="1", ul_tput=expected_tput, tolerance=tolerance)

    def start_tcp_data_transfer_separately_dl_and_ul(self, duration, expected_dl_tput, expected_ul_tput, tolerance,
                                                     attenuation_configuration, network_type):
        try:
            self.set_attenuation(configuration=attenuation_configuration)
            self.attach_mtk_ue()
            try:
                self.prepare_ue_network_type(network_type=network_type)
                self.start_dl_tcp_data_transfer(duration=duration, expected_tput=expected_dl_tput, tolerance=tolerance)
                self.start_ul_tcp_data_transfer(duration=duration, expected_tput=expected_ul_tput, tolerance=tolerance)
            finally:
                self.detach_mtk_ue()
        finally:
            self.set_max_attenuation_to_all_ports()


class UeAttachedToIncorrectCellException(Exception):
    pass


class NetworkTypeNotSupportedException(Exception):
    pass
