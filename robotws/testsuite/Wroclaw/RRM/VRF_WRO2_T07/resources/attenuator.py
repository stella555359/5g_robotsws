from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.tl_config import tl
from taf.hw.rf_attenuator import rf_attenuator as taf_attenuator
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import logged_keyword, wait_until_function_succeeds
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.exceptions import TimeoutError
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log import blog
from time import sleep as python_sleep
from taf.hw.pdu import pdu
from time import sleep


class Attenuator:
    def __init__(self, with_initialisation=True):
        self._attenuator, self.available_ports, self.configured_attenuators = None, [], []
        if with_initialisation:
            self.initialise_attenuator()

    @logged_keyword
    def initialise_attenuator(self):
        self.initialise_attenuators()

    @logged_keyword
    def initialise_attenuators(self):
        _attenuator = taf_attenuator()
        if not self.configured_attenuators:
            try:
                for attenuator_id, attenuator in enumerate(tl.attenuators):
                    try:
                        try:
                            self.power_on_attenuator(attenuator)
                        except BaseException as e:
                            blog("Attenuator power on failed: {}".format(e), level='ERROR')
                        device = self.setup_attenuator(_attenuator, attenuator, attenuator_id)
                        self.configured_attenuators.append(device)
                    except TimeoutError as e:
                        blog("Setup attenuator failed, device will be restarted")
                        self.reboot_attenuator(attenuator)
                        self.configured_attenuators.append(
                            self.setup_attenuator(_attenuator, attenuator, attenuator_id))
                    self.available_ports.append(list(tl.attenuators[attenuator_id].attenuator_ports.keys()))
                    blog('Attenuators initialised successfully!')
                    self._attenuator = _attenuator
            except Exception as e:
                raise Exception('Attenuator could not be initialised! Error: {}'.format(e))
        else:
            blog('Attenuator already initialized.', level='WARN')

    @wait_until_function_succeeds(retry_time_in_seconds=300, retry_interval_in_seconds=120)
    @logged_keyword
    def setup_attenuator(self, _attenuator, attenuator, attenuator_id):
        device_setup = _attenuator.setup_attenuator(
            attenuator, alias='atten_{}'.format(attenuator_id + 1))
        return device_setup

    @logged_keyword
    def power_on_attenuator(self, attenuator):
        pdu_details = attenuator.pdu_port
        if not pdu_details:
            blog("Cannot power on attenuator. Missing pdu_port.")
            return
        _pdu = pdu()
        _pdu.setup_pdu(model=pdu_details.pdu)
        _pdu.power_on(port=pdu_details.port_no)
        sleep(30)

    @logged_keyword
    def reboot_attenuator(self, attenuator):
        pdu_details = attenuator.pdu_port
        _pdu = pdu()
        _pdu.setup_pdu(model=pdu_details.pdu)
        _pdu.reset_ports(ports=[pdu_details.port_no], time_interval=20)
        sleep(120)

    @logged_keyword
    def set_attenuation_on_specific_attenuator(self, value_string, ports, confirm, attenuator_id):
        ports = self.prepare_ports(ports, self.available_ports[attenuator_id])
        for port_number in ports:
            if port_number in self.available_ports[attenuator_id]:
                blog('Setting attenuation to "{}" on port: {} and attenuator no: {}'
                     .format(value_string, port_number, attenuator_id + 1))
                try:
                    self._attenuator.set_attenuation(port=port_number,
                                                     value=str(value_string) + 'dB', confirm=confirm,
                                                     attenuator_device=self.configured_attenuators[attenuator_id])
                except ValueError as e:
                    blog(e, level='ERROR')

    @logged_keyword
    def set_attenuation(self, value_string, ports=None, confirm=True, attenuator_id=None):
        self.check_initialisation()
        if tl.attenuators:
            if attenuator_id:
                self.set_attenuation_on_specific_attenuator(value_string, ports, confirm, int(attenuator_id)-1)
            else:
                doubled_ports = self.check_doubled_ports_in_attenuators(ports)
                if doubled_ports:
                    blog('There are the same ports definied for multiple attenuators! Duplicated port numbers: {}!'
                         .format(doubled_ports), level='ERROR')
                    raise self.AttenuatorDoubledPorts
                for attenuator_id, attenuator in enumerate(tl.attenuators):
                    self.set_attenuation_on_specific_attenuator(value_string, ports, confirm, attenuator_id)
        else:
            blog('There is no attenuator/attenuators objects in testline config!', level='ERROR')

    @logged_keyword
    def gradually_increase_attenuation(self, init_value=0, max_value=90, step=1, interval=0.2,
                                       ports=None, attenuator_id=None):
        self.check_initialisation()
        value = int(init_value)
        max_value = int(max_value)
        blog('Gradually increasing attenuation on ports: {}'.format(str(ports)))
        while value <= max_value:
            self.set_attenuation(value_string=value, ports=ports, attenuator_id=attenuator_id)
            value += int(step)
            python_sleep(float(interval))
        blog('Gradual increase done!')

    @logged_keyword
    def gradually_decrease_attenuation(self, init_value=35, min_value=0, step=1, interval=0.2,
                                       ports=None, attenuator_id=None):
        self.check_initialisation()
        value = int(init_value)
        min_value = int(min_value)
        blog('Gradually decreasing attenuation on ports: {}'.format(str(ports)))
        while value >= min_value:
            self.set_attenuation(value_string=value, ports=ports, attenuator_id=attenuator_id)
            value -= int(step)
            python_sleep(float(interval))
        blog('Gradual decrease done!')

    @logged_keyword
    def nullify_attenuation_on_all_ports(self):
        self.check_initialisation()
        for attenuator_id, attenuator in enumerate(tl.attenuators):
            try:
                self.set_attenuation(value_string='0dB', ports=self.available_ports[attenuator_id],
                                     attenuator_id=attenuator_id+1)
            except ValueError:
                blog('Attenuation set failed, trying again after 120s...', level='WARN')
                sleep(120)
                self.set_attenuation(value_string='0dB', ports=self.available_ports[attenuator_id],
                                     attenuator_id=attenuator_id+1)
            blog('Successfully nullified attenuation on ports: {0} for attenuator no: {1}'
                 .format(str(self.available_ports[attenuator_id]), attenuator_id + 1))

    @logged_keyword
    def attenuate_all_ports(self):
        self.check_initialisation()
        for attenuator_id, attenuator in enumerate(tl.attenuators):
            try:
                self.set_attenuation(value_string='90dB', ports=self.available_ports[attenuator_id],
                                     attenuator_id=attenuator_id + 1)
            except ValueError:
                blog('Attenuation set failed, trying again after 120s...', level='WARN')
                sleep(120)
                self.set_attenuation(value_string='90dB', ports=self.available_ports[attenuator_id],
                                     attenuator_id=attenuator_id + 1)
            blog('Successfully set attenuation on ports: {0} for attenuator no: {1}'
                 .format(str(self.available_ports[attenuator_id]), attenuator_id + 1))

    @logged_keyword
    def release_attenuators(self):
        self.check_initialisation()
        for attenuator_id, attenuator in enumerate(tl.attenuators):
            self.configured_attenuators[attenuator_id].disconnect()

    @logged_keyword
    def release_attenuator(self):
        self.release_attenuators()

    def check_initialisation(self):
        if not self.is_initialised():
            raise Exception('Attenuator has not been initialised! Use the initialise_attenuator method.')

    def is_initialised(self):
        init_result = []
        for attenuator_id, attenuator in enumerate(tl.attenuators):
            init_result.append(all(el is not None for el in (self._attenuator, self.available_ports[attenuator_id],
                                                             self.configured_attenuators[attenuator_id])))
        return all(init_result)

    def is_nested(self, nested_list):
        return any(isinstance(i, list) for i in nested_list)

    def prepare_ports(self, ports, available_ports):
        if ports is None:
            ports = available_ports
        if self.is_nested(ports):
            ports = sum(ports, [])
        return list(map(int, ports))

    def check_doubled_ports_in_attenuators(self, ports):
        temp_ports = []
        doubled_ports = []
        for attenuator_id, attenuator in enumerate(tl.attenuators):
            ports = self.prepare_ports(ports, self.available_ports[attenuator_id])
            for port_number in ports:
                if port_number in self.available_ports[attenuator_id]:
                    if port_number in temp_ports:
                        doubled_ports.append(port_number)
                    else:
                        temp_ports.append(port_number)
        return doubled_ports

    class AttenuatorDoubledPorts(Exception):
        def __init__(self):
            pass

        def __str__(self):
            return "Please specify attenuator by attenuator_id to avoid doubled ports!"
