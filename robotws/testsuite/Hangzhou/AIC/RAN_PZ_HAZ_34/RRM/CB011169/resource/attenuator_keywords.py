from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn as RobotBuiltIn
from taf.hw.rf_attenuator import attenuator
from time import sleep as python_sleep
from time import time


interface = attenuator()
available_ports = None
configured_attenuator = None


def get_robot_variable(variable_name):
    return RobotBuiltIn().get_variable_value(variable_name)


def check_if_initialised():
    if available_ports is None or configured_attenuator is None:
        raise AttenuatorNotConfigured


def initialise_attenuator():
    global available_ports, configured_attenuator, interface
    if configured_attenuator is None:
        attenuator_config = get_robot_variable('${tl.attenuator}')
        available_ports = attenuator_config.attenuator_ports.keys()
        configured_attenuator = interface.setup_attenuator(attenuator_config, alias='att_1')


def set_attenuation(value_string, port=None, confirm=False):
    check_if_initialised()
    if port:
        ports = [int(port)] if not isinstance(port, list) else [int(p) for p in port]
    else:
        ports = available_ports
    for port in ports:
        interface.set_attenuation(port=port, value=str(value_string) + 'dB', confirm=confirm,
                                  attenuator_device=configured_attenuator)


def linspace(start, stop, n):
    h = float(stop - start) / n
    return [int(start + h * i) for i in range(n + 1)]


def perform_handover(initial_port, target_port, open_value=0, closed_value=90, period=120, interval=15):
    initial_port_values = linspace(open_value, closed_value, period//interval)
    for value in initial_port_values:
        t0 = time()
        set_attenuation(value, initial_port, confirm=True)
        set_attenuation(closed_value - (value - open_value), target_port, confirm=True)
        t1 = time()
        if value == closed_value:
            return
        if interval - (t1 - t0) > 0:
            python_sleep(interval - (t1 - t0))
        else:
            logger.warn('Interval is too short. Handover will take longer than expected')


class AttenuatorNotConfigured(Exception):
    def __init__(self):
        pass

    def __str__(self):
        return "Have you called 'initialise attenuator' to setup required variables?"
