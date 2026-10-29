from typing import Union
from robot.libraries.BuiltIn import BuiltIn
from robot.libraries.BuiltIn import logger
from taf.hw.rf_attenuator import rf_attenuator


def set_attenuator_to_values(attenuator=BuiltIn().get_variable_value("${tl.attenuator[0]}"),
                             port_att: dict[int, int] = {},
                             other: int = None):
    """
    This function sets attenuator to given values
    :param port_att - Dict of port: att_value
    :param other - value to set to all other inputs
    """
    rf_att = rf_attenuator()
    att_inst = rf_att.setup_attenuator(vendor=attenuator.vendor,
                                       ip_addr=attenuator.ip_addr,
                                       port=attenuator.port,
                                       attenuation_port_numbers=attenuator.attenuation_port_numbers)
    if port_att:
        for (port, value) in port_att.items():
            logger.trace(f"Set attenuation: {port=}, {value=}")
            att_inst.set_port_attenuation(port=int(port), attenuation_value=int(value))
    if other:
        for port in attenuator.attenuation_port_numbers:
            if port not in port_att.keys():
                logger.trace(f"Set others attenuation: {port=}, value={other}")
                att_inst.set_port_attenuation(port=port, attenuation_value=int(other))
    logger.info(f"Attenuator set to: {rf_att.read_ports_attenuation(attenuator.attenuation_port_numbers)}",
                also_console=True)
