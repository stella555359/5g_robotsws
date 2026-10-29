import time
from robot.api import logger
from taf.hw.rf_attenuator import rf_attenuator as attenuator


class smart_attenuator(attenuator):

    def __init__(self):
        super(smart_attenuator, self).__init__()

    def execute_fading_scenario(self, attenuator_device, source_ports, target_ports,
                                fading_step, fading_interval, fading_min, fading_max):
        (source_ports, target_ports, fading_step, fading_interval, fading_min, fading_max) = \
            self._unify_parameters_before_fading_scenario(source_ports, target_ports, fading_step, fading_interval,
                                                          fading_min, fading_max)
        """
        The function executes fading scenario on attenuator device according to provided parameters
        :param attenuator_device: attenuator to set the attenuation value
        :param source_ports: list containing attenuator ports for which fading scenario will start from fading_min
        :param target_ports: list containing attenuator ports for which fading scenario will start from fading_max
        :param fading_step: attenuation value to be used at each step of fading scenario
        :param fading_interval: time interval in seconds e.g. '10s'
        :param fading_min: attenuation value from which fading scenario starts
        :param fading_max: attenuation value at which fading scenario ends
        :return: None
        """
        fading_up_value = fading_min[0]
        fading_down_value = fading_max[0]
        while True:
            if not fading_up_value > fading_max[0]:
                values_to_set = [str(fading_up_value) + 'dB' for _ in range(len(source_ports))]
                self.set_ports_attenuation(attenuator_device, source_ports, values_to_set)
                fading_up_value += fading_step[0]
            if not fading_down_value < fading_min[0]:
                values_to_set = [str(fading_down_value) + 'dB' for _ in range(len(source_ports))]
                self.set_ports_attenuation(attenuator_device, target_ports, values_to_set)
                fading_down_value -= fading_step[0]
            time.sleep(fading_interval)
            if fading_up_value > fading_max[0] and fading_down_value < fading_min[0]:
                values_to_set = [str(fading_max[0]) + 'dB' for _ in range(len(source_ports))]
                self.set_ports_attenuation(attenuator_device, source_ports, values_to_set)
                values_to_set = [str(fading_min[0]) + 'dB' for _ in range(len(source_ports))]
                self.set_ports_attenuation(attenuator_device, target_ports, values_to_set)
                break

    def set_ports_attenuation(self, attenuator_device, ports, values):
        """
        The function sets attenuator device ports to desired values
        :param attenuator_device: attenuator to set the attenuation value
        :param ports: list of attenuator ports
        :param values: list of attenuation values e.g. 10dB
        :return: None
        """
        if not isinstance(ports, list):
            ports = [int(ports)]
        if not isinstance(values, list):
            values = [values]
        if len(ports) != len(values):
            raise ValueError('Each port should have one value to set.')
        values = [str(self._unify_attenuation_value(value)[0]) + 'dB' for value in values]
        for port, value in zip(ports, values):
            logger.info('Setting the attenuation to {} on port {}.'.format(value, port))
            self.set_attenuation(port, value, attenuator_device=attenuator_device)

    def _unify_parameters_before_fading_scenario(self, source_ports, target_ports, fading_step, fading_interval,
                                                 fading_min, fading_max):
        """
        The function checks if attenuation parameters for fading scenario are proper.
        Parameters are casted to supported types.
        :param source_ports: list containing attenuator ports for which fading scenario will start from fading_min
        :param target_ports: list containing attenuator ports for which fading scenario will start from fading_max
        :param fading_step: attenuation value to be used at each step of fading scenario
        :param fading_interval: time interval in seconds e.g. '10s'
        :param fading_min: attenuation value from which fading scenario starts
        :param fading_max: attenuation value at which fading scenario ends
        :return: tuple containing unified fading scenario parameters
        """
        if not isinstance(source_ports, list):
            source_ports = [int(source_ports)]
        if not isinstance(target_ports, list):
            target_ports = [int(target_ports)]
        fading_min = self._unify_attenuation_value(fading_min)
        fading_max = self._unify_attenuation_value(fading_max)
        fading_step = self._unify_attenuation_value(fading_step)
        if fading_min[0] > fading_max[0]:
            raise ValueError('Minimum fading value should be lower or equal maximum fading value.')
        if fading_min[1] != fading_max[1] != fading_step[1]:
            raise ValueError('You should define common units (db or %) for "fading_min", "fading_max", "fading_step".')
        if str(fading_interval)[-1] != 's':
            raise ValueError('Define fading interval in seconds (e.g "10s").')
        fading_interval = int(fading_interval[:-1])
        return source_ports, target_ports, fading_step, fading_interval, fading_min, fading_max

    @staticmethod
    def _unify_attenuation_value(value):
        """
        The function checks if attenuation values is string in proper format
        :param value: attenuation value
        :return: tuple containing attenuation value and attenuation unit
        """
        if not isinstance(value, str) or len(value) < 2:
            raise TypeError('Attenuation value should be defined as string with units!')
        if value[-2:] == 'dB':
            return int(value[:-2]), value[-2:]
        if value[-1:] == '%':
            raise NotImplementedError('% are not supported yet.')
        raise ValueError('Attenuation value should be in % or dB: {}'.format(value))
