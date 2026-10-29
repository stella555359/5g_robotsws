import testsuite.Wroclaw.RRM.resources.rrm_fixture as fixture
from taf.hw.rf_attenuator import rf_attenuator
from robot.api import logger
from time import time
from time import sleep as python_sleep


interface = rf_attenuator()
available_ports = None
configured_attenuator = None


def initialise_attenuator():
    global available_ports, configured_attenuator, interface
    if configured_attenuator is None:
        attenuator_config = fixture.get_robot_variable('${tl.attenuator}')
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


def gradually_increase_attenuation(init_value=0, max_value=90, step=1, interval=0.2, port=None):
    check_if_initialised()
    ports = available_ports if not port else [int(port)] if not isinstance(port, list) else [int(p) for p in port]
    step = int(step)
    interval = float(interval)
    value = int(init_value)
    max_value = int(max_value)
    while value <= max_value:
        for port in ports:
            interface.set_attenuation(port=port, value=str(value) + 'dB', confirm=False,
                                      attenuator_device=configured_attenuator)
        value += step
        python_sleep(interval)


def gradually_decrease_attenuation(init_value=35, min_value=0, step=1, interval=0.2, port=None):
    ports = available_ports if not port else [int(port)] if not isinstance(port, list) else [int(p) for p in port]
    value = int(init_value)
    min_value = int(min_value)
    while value >= min_value:
        for port in ports:
            interface.set_attenuation(port=port, value=str(value)+'dB', confirm=False,
                                      attenuator_device=configured_attenuator)
        value = value - int(step)
        python_sleep(float(interval))


def perform_handover(initial_port, target_port, open_value=0, closed_value=90, period=120, interval=15):
    initial_port_values = linspace(open_value, closed_value, period/interval)
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


def linspace(start, stop, n):
    h = float(stop - start) / n
    return [int(start + h * i) for i in range(n + 1)]


def nullify_attenuation_on_all_ports():
    check_if_initialised()
    for port in available_ports:
        interface.set_attenuation(port=port, value='0dB', confirm=True, attenuator_device=configured_attenuator)


def check_if_initialised():
    if available_ports is None or configured_attenuator is None:
        raise AttenuatorNotConfigured


class AttenuatorNotConfigured(Exception):
    def __init__(self):
        pass

    def __str__(self):
        return "Have you called 'initialise attenuator' to setup required variables?"
