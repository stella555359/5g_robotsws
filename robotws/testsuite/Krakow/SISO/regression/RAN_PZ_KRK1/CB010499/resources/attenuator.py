"""
author/contact: jaroslaw.lezon@nokia.com, damian.silkowski@nokia.com
"""
import logging
from taf.hw.rf_attenuator import rf_attenuator
from taf.rfrl.utilities.tl_config import tl


class Attenuator:
    """
    Class for controlling the attenuator.
    """

    def __init__(self, attenuator_id=0):
        """
        Initialize the Attenuator instance.

        :param int attenuator_id: The attenuator number. Default is 0.

        :ivar dict _att_config: Configuration of the attenuator.
        :ivar int _min_attenuation: Minimum attenuation value. Default is 0.
        :ivar int _max_attenuation: Maximum attenuation value. Default is 110.
        :ivar str _att_alias: Alias for the attenuator, formed as 'att_' followed by the attenuator number.
        :ivar attenuator _attenuator: Instance of the attenuator interface.
        """
        self._att_config = tl.attenuators[attenuator_id]
        self._min_attenuation = 0
        self._max_attenuation = 110
        self._att_alias = f'att_{str(attenuator_id)}'
        self._attenuator = rf_attenuator()

    def init_attenuator(self):
        """
        Initialize attenuator.
        :return: None
        """
        self.att = self._attenuator.setup_attenuator(attenuator=self._att_config, alias=self._att_alias)

    def get_attenuator_all_ports_value(self):
        """
        Get the attenuation value for all ports.
        :return: None
        """
        for port in self._att_config.attenuation_port_numbers:
            att_p_value = self.read_port_attenuation(port)
            logging.info(f'attenuator port {port} value: {att_p_value}')

    def read_port_attenuation(self, port):
        """
        Get the attenuation value for the specified port.
        :param int port: Port number.
        :return: Attenuation value.
        """
        return self.att.read_port_attenuation(port)

    def set_attenuation_value_on_port(self, port, value_to_set):
        """
        Set the attenuation value for the specified port.
        :param int port: Port number.
        :param int value_to_set: Attenuation value to set.
        :return: None.
        """
        self.att.set_port_attenuation(port=port, attenuation_value=f'{str(value_to_set)}dB')
        current_value = self.read_port_attenuation(port=port)
        if int(current_value) != int(value_to_set):
            raise AttenuatorError('Cannot set attenuation value, check the device')

    def set_ports_state(self, ports_to_change=None, state='on'):
        """
        Turn on/off selected ports or all ports on attenuator.
        :param list ports_to_change: List of ports to change, if None - all ports.
        radio unit ID, if None - cells from all rus are returned
        :param str state: 'on' or 'off'.
        :return: None.
        """
        if state == 'on':
            attenuation_value = self._min_attenuation
        elif state == 'off':
            attenuation_value = self._max_attenuation
        else:
            raise ValueError('Wrong value of parameter state - available values: "on", "off"')

        if ports_to_change is None:
            ports_to_change = self._att_config.attenuation_port_numbers

        for port in ports_to_change:
            self.set_attenuation_value_on_port(port=port, value_to_set=attenuation_value)


class AttenuatorError(Exception):
    """
    Raised when some error occurs on the attenuator.
    """
    pass
