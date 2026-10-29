"""
Data Transfer Keywords
"""
from taf.hw.rf_attenuator import rf_attenuator
from robot.libraries.BuiltIn import BuiltIn
from moler.util.moler_test import MolerTest
from moler.device import DeviceFactory
from taf.rfrl.ue.connections.device_aliases import ue_pc
import logging
import time


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
                MolerTest.error(f"Attenuation not changed on port: {ports[i]}", raise_exception=True)

    def set_max_attenuation_to_all_ports(self, number_of_ports=32, max_value=110):
        self.attenuator_device.setup_attenuator(attenuator=self.tl.attenuator)
        for port_id in range(13, int(number_of_ports) + 1):
            self.attenuator_device.set_attenuation(port=port_id, value=int(max_value))


class QualcommUeOperations(object):
    def __init__(self):
        self.tl = BuiltIn().get_variable_value('${{{}}}'.format("tl"), None)
        self.current_ue_config = None
        self.apn_config = {
            "5gkrk": {"starting_activity": "android.settings.DATA_ROAMING_SETTINGS",
                      "key_events_combination": [20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20,
                                                 19, 19, 66, 61, 61, 61, 66]},
            "5gsakrk": {"starting_activity": "android.settings.DATA_ROAMING_SETTINGS",
                        "key_events_combination": [20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20,
                                                   19, 19, 66, 61, 61, 61, 61, 61, 61, 66]}
        }
        self.network_type_config = {
            "NR": {"starting_activity": "android.settings.DATA_ROAMING_SETTINGS",
                   "key_events_combination": [20, 20, 20, 20, 20, 20, 66, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20,
                                              20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 66]},
            "LTE": {"starting_activity": "android.settings.DATA_ROAMING_SETTINGS",
                    "key_events_combination": [20, 20, 20, 20, 20, 20, 66, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20,
                                               66]}

        }

    def set_apn(self, apn_name, ue_id=0):
        ue_pc_device = DeviceFactory.get_device(name=ue_pc.format(ue_id), initial_state="UNIX_REMOTE")
        ue_serial_number = self.tl.ues[ue_id].serial_number
        start_activity_cmd = "adb -s {} shell 'am start -a {}'".format(ue_serial_number,
                                                                       self.apn_config[apn_name]["starting_activity"])
        stop_activity_cmd = "adb -s {} shell 'am force-stop {}'".format(ue_serial_number, "com.android.settings")
        ue_pc_device.get_cmd(cmd_name="run_script", cmd_params={'script_command': start_activity_cmd})()
        time.sleep(5)
        for key_event in self.apn_config[apn_name]["key_events_combination"]:
            time.sleep(1)
            key_event_cmd = "adb -s {} shell 'input keyevent {}'".format(ue_serial_number, key_event)
            ue_pc_device.get_cmd(cmd_name="run_script", cmd_params={'script_command': key_event_cmd})()
        ue_pc_device.get_cmd(cmd_name="run_script", cmd_params={'script_command': stop_activity_cmd})()
        time.sleep(3)

    def set_preferred_network_type(self, network_type, ue_id=0):
        ue_pc_device = DeviceFactory.get_device(name=ue_pc.format(ue_id), initial_state="UNIX_REMOTE")
        ue_serial_number = self.tl.ues[ue_id].serial_number
        start_activity_cmd = "adb -s {} shell 'am start -a {}'" \
            .format(ue_serial_number, self.network_type_config[network_type]["starting_activity"])
        stop_activity_cmd = "adb -s {} shell 'am force-stop {}'".format(ue_serial_number, "com.android.settings")

        ue_pc_device.get_cmd(cmd_name="run_script", cmd_params={'script_command': start_activity_cmd})()
        time.sleep(5)
        for key_event in self.network_type_config[network_type]["key_events_combination"]:
            time.sleep(0.8)
            key_event_cmd = "adb -s {} shell 'input keyevent {}'".format(ue_serial_number, key_event)
            ue_pc_device.get_cmd(cmd_name="run_script", cmd_params={'script_command': key_event_cmd})()
        ue_pc_device.get_cmd(cmd_name="run_script", cmd_params={'script_command': stop_activity_cmd})()

    def unlock_ue_screen(self, ue_id=0):
        ue_pc_device = DeviceFactory.get_device(name=ue_pc.format(ue_id), initial_state="UNIX_REMOTE")
        ue_serial_number = self.tl.ues[ue_id].serial_number
        lock_cmd = "adb -s {} shell 'input keyevent 26;sleep 1;input keyevent 82'".format(ue_serial_number)
        ue_pc_device.get_cmd(cmd_name="run_script", cmd_params={'script_command': lock_cmd})()

    def set_ue_configuration(self, network_type):
        if self.current_ue_config != network_type:
            self.unlock_ue_screen()
            if network_type == "NR":
                self.set_apn(apn_name="5gsakrk")
                self.set_preferred_network_type("NR")
            elif network_type == "LTE":
                self.set_apn(apn_name="5gkrk")
                self.set_preferred_network_type("LTE")
            else:
                logging.error("Unsupported network_type: '{}'. 'NR' and 'LTE' supported only.")
                raise NetworkTypeNotSupportedException(network_type)
            self.current_ue_config = network_type
        else:
            logging.info("UE settings reconfiguration skipped. Current UE configuration: '{}' as expected.".format(
                self.current_ue_config))


class NetworkTypeNotSupportedException(Exception):
    def __init__(self, network_type):
        message = f"Unsupported network_type: '{network_type}'. Only 'NR' and 'LTE' are supported."
        super().__init__(message)
