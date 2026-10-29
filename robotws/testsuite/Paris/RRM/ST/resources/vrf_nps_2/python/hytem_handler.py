"""
:copyright: Nokia Networks
:author: Annie Wong
:contact: annie.wongk@nokia.com
:Update: 17/05/2023 - Abderrahmane NEZROUK
"""
from robot.libraries.BuiltIn import BuiltIn
from taf.hw.rf_attenuator.devices.hytem.hytem_v5 import HytemV5 as Hytem
from taf.hw.rf_attenuator.exceptions import AttenuationDifferentThanExpected
import logging


def read_channels_attenuation(channels, attenuator_id=0):
    """
    Read the attenuation on the selected channels.
    :param channels: attenuator ports number, expected type list of integers
    """
    attenuator_id_int = int(attenuator_id)
    _config = BuiltIn().get_variable_value("${tl.attenuators}")
    attenuator_config = _config[attenuator_id_int]

    # attenuator_config has elements :
    #   attenuator_config.ip_addr
    #   attenuator_config.port
    #   attenuator_config.attenuator_ports (dico type)

    dico_all_ports = attenuator_config.attenuator_ports
    list_all_ports = [value.port_no for _, value in dico_all_ports.items()]
    if len(channels) > len(list_all_ports):
        raise ValueError("Channels nb {} exceeds radios count from configuration {}, check "
                         "tl.attenuator.attenuator_ports in config".format(len(channels),
                                                                           len(list_all_ports)))
    attenuator = Hytem(ip=attenuator_config.ip_addr, port=attenuator_config.port,
                       min_attenuation=0, max_attenuation=93.5)
    attenuator.connect(rf_ports_at_attenuator=list_all_ports)

    # hytem configured attenuator has elements :
    #   attenuator.ip
    #   attenuator.port
    #   attenuator.min_attenuation and max_attenuation
    #   attenuator.conns

    result = list()
    try:
        for port_id in channels:
            if isinstance(port_id, int):
                int_port_id = port_id
            else:
                int_port_id = int(port_id)
            current_db = attenuator.read_port_attenuation(port=int_port_id)
            result.append(current_db)
            logging.info('attenuator channel {}: attenuation={}'.format(port_id, current_db))
    finally:
        attenuator.disconnect(rf_ports_at_attenuator=list_all_ports)
    return result


def set_channels_attenuation(channels, signals, attenuator_id=0, verify=False):
    """
    Sets the attenuation on the selected channels.
    :param channels: attenuator ports number, expected type list of integers
    :param signals: attenuations value in db, float
    :raises: ProgrammableAttenuatorError when attenuation value wasn't correctly set on device.
    """
    attenuator_id_int = int(attenuator_id)
    _config = BuiltIn().get_variable_value("${tl.attenuators}")
    attenuator_config = _config[attenuator_id_int]

    dico_all_ports = attenuator_config.attenuator_ports
    list_all_ports = [value.port_no for _, value in dico_all_ports.items()]
    if len(channels) > len(list_all_ports):
        raise ValueError("Channels nb {} exceeds radios count from configuration {}, check "
                         "tl.attenuator.attenuator_ports in config".format(len(channels),
                                                                           len(list_all_ports)))
    attenuator = Hytem(ip=attenuator_config.ip_addr, port=attenuator_config.port,
                       min_attenuation=0, max_attenuation=93.5)
    attenuator.connect(rf_ports_at_attenuator=list_all_ports)

    try:
        for port_id, strength_db in zip(channels, signals):
            if isinstance(port_id, int):
                int_port_id = port_id
            else:
                int_port_id = int(port_id)
            # strength : float, not integer
            if isinstance(strength_db, float):
                float_strength_db = strength_db
            else:
                float_strength_db = float(strength_db)
            str_strength_db = f"{float_strength_db * 0.1:.2f}db"
            logging.info('set channel {} : attenuation = {}'.format(port_id, str_strength_db))
            attenuator.set_port_attenuation(port=int_port_id,
                                            attenuation_value=str_strength_db,
                                            confirm=False)
            if verify is True:
                current_db = attenuator.read_port_attenuation(port=int_port_id)
                logging.info('current channel {}: attenuation={}'.format(port_id, current_db))
                # in taf.hw.rf-attenuator-0.8.0, the read attenuation value was x10
                # since taf.hw.rf-attenuator-0.11.1, this is no more the case, read value=required set value
                # old: if float(current_db) != float_strength_db * 10:
                if float(current_db) != float_strength_db:
                    raise AttenuationDifferentThanExpected('Port{} expected value={}db but rf '
                                                           'Output={}'.format(int_port_id,
                                                                              float_strength_db,
                                                                              current_db))
    finally:
        attenuator.disconnect(rf_ports_at_attenuator=list_all_ports)


def increment_channels_attenuation(channels, step=1, attenuator_id=0, verify=False):
    """
    Sets the attenuation on the selected channels.
    :param channels: attenuator ports number, expected type list of integers
    :param step: attenuation value in db, float
    :raises: ProgrammableAttenuatorError when attenuation value wasn't correctly set on device.
    """
    attenuator_id_int = int(attenuator_id)
    _config = BuiltIn().get_variable_value("${tl.attenuators}")
    attenuator_config = _config[attenuator_id_int]

    dico_all_ports = attenuator_config.attenuator_ports
    list_all_ports = [value.port_no for _, value in dico_all_ports.items()]
    if len(channels) > len(list_all_ports):
        raise ValueError("Channels nb {} exceeds radios count from configuration {}, check "
                         "tl.attenuator.attenuator_ports in config".format(len(channels),
                                                                           len(list_all_ports)))
    attenuator = Hytem(ip=attenuator_config.ip_addr, port=attenuator_config.port,
                       min_attenuation=0, max_attenuation=93.5)
    attenuator.connect(rf_ports_at_attenuator=list_all_ports)

    try:
        result = list()
        for port_id in channels:
            logging.info('Increment attenuation on channel{}, step={}db'.format(port_id, step))
            if isinstance(port_id, int):
                int_port_id = port_id
            else:
                int_port_id = int(port_id)
            current_db = attenuator.read_port_attenuation(port=int_port_id)
            # old code (taf.hw.rf-attenuator-0.8.0): float_strength_db = float(current_db) * 0.1 + float(step)
            # but since taf.hw.rf-attenuator-0.11.1 : set value = read value, no more difference of unit
            float_strength_db = float(current_db + float(step)) * 0.1
            str_strength_db = f"{float_strength_db * 0.1:.2f}db"
            attenuator.set_port_attenuation(port=int_port_id,
                                            attenuation_value=str_strength_db,
                                            confirm=False)
            # old code (taf.hw.rf-attenuator-0.8.0): result.append(float_strength_db * 10)
            result.append(float_strength_db * 10)
        if verify is True:
            i = 0
            for port_id in channels:
                if isinstance(port_id, int):
                    int_port_id = port_id
                else:
                    int_port_id = int(port_id)
                current_db = attenuator.read_port_attenuation(port=int_port_id)
                logging.info('channel {} expected attenuation = {}, '
                             'current value = {}'.format(port_id, result[i], current_db))
                if float(current_db) != result[i]:
                    raise AttenuationDifferentThanExpected('Port{} expected value={} dbx10, '
                                                           'but rf Output='
                                                           '{}'.format(int_port_id,
                                                                       result[i],
                                                                       current_db))
                i += 1
    finally:
        attenuator.disconnect(rf_ports_at_attenuator=list_all_ports)
    return result


def decrement_channels_attenuation(channels, step=1, attenuator_id=0, verify=False):
    """
    Sets the attenuation on the selected channels.
    :param channels: attenuator ports number, expected type list of integers
    :param step: attenuation value in db, float
    :raises: ProgrammableAttenuatorError when attenuation value wasn't correctly set on device.
    """
    attenuator_id_int = int(attenuator_id)
    _config = BuiltIn().get_variable_value("${tl.attenuators}")
    attenuator_config = _config[attenuator_id_int]

    dico_all_ports = attenuator_config.attenuator_ports
    list_all_ports = [value.port_no for _, value in dico_all_ports.items()]
    if len(channels) > len(list_all_ports):
        raise ValueError("Channels nb {} exceeds radios count from configuration {}, check "
                         "tl.attenuator.attenuator_ports in config".format(len(channels),
                                                                           len(list_all_ports)))
    attenuator = Hytem(ip=attenuator_config.ip_addr, port=attenuator_config.port,
                       min_attenuation=0, max_attenuation=93.5)
    attenuator.connect(rf_ports_at_attenuator=list_all_ports)

    try:
        result = list()
        for port_id in channels:
            logging.info('Decrement attenuation on channel{}, step={}db'.format(port_id, step))
            if isinstance(port_id, int):
                int_port_id = port_id
            else:
                int_port_id = int(port_id)
            current_db = attenuator.read_port_attenuation(port=int_port_id)
            # old code (taf.hw.rf-attenuator-0.8.0): float_strength_db = float(current_db) * 0.1 - float(step
            float_strength_db = float(current_db - float(step)) * 0.1
            str_strength_db = f"{float_strength_db * 0.1:.2f}db"
            attenuator.set_port_attenuation(port=int_port_id,
                                            attenuation_value=str_strength_db,
                                            confirm=False)
            # old code (taf.hw.rf-attenuator-0.8.0): result.append(float_strength_db * 10)
            result.append(float_strength_db * 10)
        if verify is True:
            i = 0
            for port_id in channels:
                if isinstance(port_id, int):
                    int_port_id = port_id
                else:
                    int_port_id = int(port_id)
                current_db = attenuator.read_port_attenuation(port=int_port_id)
                logging.info('channel {} expected attenuation = {}, '
                             'current value = {}'.format(port_id, result[i], current_db))
                if float(current_db) != result[i]:
                    raise AttenuationDifferentThanExpected('Port{} expected value={} dbx10, but rf '
                                                           'Output={}'.format(int_port_id,
                                                                              result[i],
                                                                              current_db))
                i += 1
    finally:
        attenuator.disconnect(rf_ports_at_attenuator=list_all_ports)
    return result
