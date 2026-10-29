"""
Data Transfer Keywords
"""
from taf.hw.rf_attenuator import rf_attenuator
from robot.libraries.BuiltIn import BuiltIn
from taf.rfrl.utilities.tl_config import get_global_bts_id
from moler.util.moler_test import MolerTest


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

    def set_max_attenuation_to_all_ports(self, number_of_ports=16, max_value=110):
        self.attenuator_device.setup_attenuator(attenuator=self.tl.attenuator)
        for port_id in range(1, int(number_of_ports) + 1):
            self.attenuator_device.set_attenuation(port=port_id, value=int(max_value))
