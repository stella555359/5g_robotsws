"""
:copyright: Nokia Networks
:author: Bartlomiej Bienko
:contact: bartlomiej.bienko@nokia.com
:maintainer: Bartlomiej Bienko
:contact: bartlomiej.bienko@nokia.com

Module is purposed to change attenuation of attenuator from TL configuration during test.
"""

from robot.libraries.BuiltIn import BuiltIn

from taf.hw.rf_attenuator import rf_attenuator

tl = BuiltIn().get_variable_value("${{{}}}".format("tl"), None)
atten_from_tl = tl.attenuators[0]


class AttenuatorInterface:

    def __init__(self, main_port):
        """
        Warning - to make AttenuatorInterface work seamlessly turn off "Ethernet Connection" in JFW Interface
        """
        self._attenuator = rf_attenuator().setup_attenuator(
            ip_addr=atten_from_tl.ip_addr,
            port=atten_from_tl.port,
            attenuation_port_numbers=atten_from_tl.attenuation_port_numbers,
            vendor=atten_from_tl.vendor)
        self.main_port = main_port

    def get_current_attenuation(self, port_no=None):
        used_port = port_no if port_no else self.main_port
        return self._attenuator.read_port_attenuation(used_port)

    def attenuate(self, attenuation_value, port_no=None):
        used_port = port_no if port_no else self.main_port
        self._attenuator.set_port_attenuation(port=used_port, attenuation_value=attenuation_value)

    def disable_attenuation(self, port_no=None):
        """Sets attenuation of attenuator for 0dB; equivalent for attenuate('0dB')"""
        used_port = port_no if port_no else self.main_port
        self.attenuate(attenuation_value='0dB', port_no=used_port)
