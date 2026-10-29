"""
author/contact:   damian.silkowski@nokia.com, I_5G_TLM_WRO_GMS <I_5G_TLM_WRO@internal.nsn.com>
"""

from robot.libraries.BuiltIn import BuiltIn
from taf.hw.rf_attenuator.devices.jfw.jfw import JFW
import random

min_attenuation = 0
max_attenuation = 95
at_ip = BuiltIn().get_variable_value("${tl.attenuator.ip_addr}")
at_port = BuiltIn().get_variable_value("${tl.attenuator.port}")
at_port_numbers_range = BuiltIn().get_variable_value("${tl.attenuator.atpn")
attenuator_config = BuiltIn().get_variable_value("${tl.attenuator}")
attenuator = JFW(ip=attenuator_config.ip_addr, port=attenuator_config.port,
                 min_attenuation=min_attenuation, max_attenuation=max_attenuation)
attenuator_ports = attenuator_config.attenuator_ports


def _set_port_on_attenuator(port, value):
    """
    Private function to set port on attenuator
    :param port: port on attenuator to change
    :param value: 90db - high suppression, 0db - no suppression
    """
    attenuator.set_port_attenuation(port=port, attenuation_value=str(value) + 'db', confirm=False)


def turn_off_all_attenuation_port():
    """
    Function switched off all attenuator ports specific for TL (info from __init__.py)
    """
    attenuator.connect()
    try:
        for port in attenuator_ports:
            _set_port_on_attenuator(port, max_attenuation)
    finally:
        attenuator.disconnect()


def turn_on_all_attenuation_port():
    """
    Function switched on all attenuator ports specific for TL (info from __init__.py)
    """
    attenuator.connect()
    try:
        for port in attenuator_ports:
            _set_port_on_attenuator(port, min_attenuation)
    finally:
        attenuator.disconnect()


def _get_random_attenuation_port():
    """
    Private function to get random attenuator ports specific for TL (info from __init__.py)
    :return:
    """
    random_port = random.randrange(list(attenuator_ports.keys())[0], list(attenuator_ports.keys())[-1], 2)
    return [random_port, random_port + 1]


def turn_on_selected_attenuation_port(ports_to_change='random', min_attenuation=0, max_attenuation=90,):
    """
    Function to change ports on attenuator, user can choose ports to change or function will change random ports
    """
    if ports_to_change == 'random':
        ports_to_change_list = _get_random_attenuation_port()
    else:
        # ports_to_change = ports_to_change.replace(' ', '').replace('[', '').replace(']', '').split(',')
        ports_to_change_list = [int(elem) for elem in ports_to_change]

    attenuator.connect()

    try:
        turn_off_all_attenuation_port()
        for port_to_attenuate in attenuator_ports:
            for port_to_change in ports_to_change_list:
                if port_to_change in attenuator_ports:
                    if port_to_attenuate == port_to_change:
                        _set_port_on_attenuator(port_to_change, min_attenuation)
                else:
                    raise ValueError('Ports to change not in attenuator ports list')
    finally:
        attenuator.disconnect()
