"""
:copyright: Nokia Networks
:author: Szlapa Marek
"""

import time

from testsuite.Krakow.SISO.regression.RAN_PZ_KRK2.FR_CB010652.resources.rf_attenuator_custom import \
    AttenuatorHandlerCustom as attenuator
from taf.rfrl.utilities.tl_config import tl


class AttenuatorHandler(object):
    def __init__(self, alias_prefix='ATTENUATOR'):
        self.alias_prefix = alias_prefix
        self.interface = attenuator()

    def initialise_attenuators(self):
        """
        Initialize attenuator
        :return: None
        """
        for idx, tl_attenuator in enumerate(tl.attenuators):
            self.interface.setup_attenuator(attenuator=tl_attenuator, alias=self.alias_prefix + str(idx))

    def set_max_attenuation_on_all_attenuators(self):
        """
        Set maximum attenuation value on all attenuators ports
        :return: None
        """
        for idx, tl_attenuator in enumerate(tl.attenuators):
            self.set_attenuation(value_string='100', att_id=idx,
                                 selected_ports=list(tl_attenuator.attenuator_ports.keys()),
                                 attenuation_unit='%')

    def set_attenuation(self, value_string, att_id, selected_ports, attenuation_unit='dB'):
        """
        Set attenuation to a given ports
        :param value_string:     attenuation value, e.g. 110 (without dB)
        :param att_id:           attenuator id
        :param selected_ports:   ports to be attenuated
        :param attenuation_unit: attenuation unit db or %
        :return: None
        """
        ports = [int(selected_ports)] if not isinstance(selected_ports, list) else [int(p) for p in selected_ports]
        for port in ports:
            self.interface.set_attenuation(port=port, value=str(value_string) + attenuation_unit,
                                           attenuator_device=self.alias_prefix + str(att_id))

    def gradually_increase_attenuation(self, att_id, selected_ports, init_value=0, max_value=100,
                                       step=10, interval=2):
        """
            Set attenuation to a given port
            :param att_id:          attenuator id
            :param init_value:      initial attenuation value
            :param max_value:       maximum attenuation
            :param step:            step of attenuation
            :param interval:        interval between steps
            :param selected_ports:  ports to be attenuated
            :return: None
            """
        ports = [int(p) for p in selected_ports]
        step = int(step)
        interval = float(interval)
        value = int(init_value)
        max_value = int(max_value)
        while value <= max_value:
            for port in ports:
                self.interface.set_attenuation(port=port, value=str(value) + '%',
                                               attenuator_device=self.alias_prefix + str(att_id))
            value += step
            time.sleep(float(interval))
