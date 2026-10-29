import time
from taf.hw.rf_attenuator import rf_attenuator as attenuator
from taf.rfrl.utilities.tl_config import tl


class attenuator_keywords(object):
    def __init__(self):
        self.configured_attenuator = None
        self.interface = attenuator()
        self.available_ports = None
        self.attenuator_config = None

    def initialise_attenuator(self):
        """
        Initialize attenuator
        :return: None
        """
        if self.configured_attenuator is None:
            self.attenuator_config = tl.attenuator
            self.available_ports = self.attenuator_config.attenuator_ports.keys()
            self.configured_attenuator = self.interface.setup_attenuator(self.attenuator_config, alias='att_1')

    def set_attenuation(self, value_string, port=None, confirm=False):
        """
        Set attenuation to a given port
        :param value_string: attenuation value
        :param port: port to be attenuated
        :param confirm
        :return: None
        """
        self.check_if_initialised()
        if port:
            ports = [int(port)] if not isinstance(port, list) else [int(p) for p in port]
        else:
            ports = self.available_ports
        for port in ports:
            self.interface.set_attenuation(port=port, value=str(value_string) + 'dB', confirm=confirm,
                                           attenuator_device=self.configured_attenuator)

    def gradually_increase_attenuation(self, init_value=0, max_value=90, step=1, interval=0.2, port=None):
        """
            Set attenuation to a given port
            :param init_value: initial attenuation value
            :param port: port to be attenuated
            :param max_value:   maximum attenuation
            :param step:    attenuation difference
            :param interval:    interval between steps
            :return: None
            """
        self.check_if_initialised()
        ports = self.available_ports if not port else [int(p) for p in port]
        step = int(step)
        interval = float(interval)
        value = int(init_value)
        max_value = int(max_value)
        while value <= max_value:
            for port in ports:
                self.interface.set_attenuation(port=port, value=str(value) + 'dB', confirm=False,
                                               attenuator_device=self.configured_attenuator)
            value += step
            time.sleep(float(interval))

    def check_if_initialised(self):
        """
        Check if attenuator initialized
        :return: None
        """
        if self.available_ports is None or self.configured_attenuator is None:
            raise AttenuatorNotConfigured("Have you called 'initialise attenuator' to setup required variables?")


class AttenuatorNotConfigured(Exception):
    pass
