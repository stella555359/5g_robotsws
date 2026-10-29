import logging
from robot.api.deco import keyword
from robot.libraries.BuiltIn import BuiltIn
from taf.hw.rf_attenuator import rf_attenuator
from taf.rfrl.utilities.robot.general import get_builtin_value
from taf.rfrl.utilities.parsers.pcap_checker import VerificationError
from taf.analyzer.pcap.pcap_packet import PcapPacket
from ta_tshark_hex_parser import uesim_parser


_tl = get_builtin_value(param_name="tl")


@keyword()
def get_nr_cell_id_in_hex(nr_cell_id, hex_len=11):
    """
    The function dump nrcellid to hex format.

    :param nr_cell_id: cell's nrcellid in dec format
    :param hex_len: length of hex string after '0x'
    :return: cell's nrcellid in hex format
    """

    return "{0:#0{1}x}".format(int(nr_cell_id), hex_len)


@keyword
def setup_attenuator(tl_attenuator_index=0):
    """
    Setups RF attenuator from testline configuration file (__init.py__)

    :param tl_attenuator_index: number on list in __init.py__
    :return: None
    """

    rf_attenuator().setup_attenuator(attenuator=_tl.attenuators[tl_attenuator_index],
                                     alias=_tl.attenuators[tl_attenuator_index].serial_number)


@keyword()
def setup_all_attenuators():
    """
    Setups all RF attenuators from testline configuration file (__init.py__)"""

    for idx, _ in enumerate(_tl.attenuators):
        setup_attenuator(tl_attenuator_index=idx)
    set_maximum_attenuation_for_all_attenuators()


@keyword
def set_maximum_attenuation_for_all_ports(tl_attenuator_index=0):
    """
    Sets maximum attenuation for all ports of RF attenuator.

    :param tl_attenuator_index: number on list in __init.py__
    :return: None
    """

    att, attenuator_device = _get_attenuator_artifacts(tl_attenuator_index)
    value = attenuator_device.max_attenuation
    values = [value for _ in att.attenuation_port_numbers]
    logging.info(f"Setting {value} attenuation for ports: {att.attenuation_port_numbers}")
    rf_attenuator().set_ports_attenuation(ports=att.attenuation_port_numbers,
                                          values=values,
                                          attenuator_device=attenuator_device)


@keyword()
def set_maximum_attenuation_for_all_attenuators():
    """Sets maximum attenuation for all ports of all RF attenuators from testline configuration file (__init.py__)"""

    for idx, _ in enumerate(_tl.attenuators):
        set_maximum_attenuation_for_all_ports(tl_attenuator_index=idx)


@keyword
def set_attenuation_for_ru(radio_type, value):
    """
    Sets desired attenuation for all ports listed under RU.attenuation_ports. It is set for first RU of given type
    defined in testline configuration file (__init.py__)

    :param radio_type: RU.radio_type from __init.py__, e.g.: "AHEH"
    :param value: attenuation value to be set for all RU ports, e.g. 100dB
    :return: None
    """

    ru = _find_ru_in_testline(radio_type)
    ports = [port.port_no for port in ru.attenuation_ports]
    values = [value for _ in ru.attenuation_ports]
    taf_attenuator_device = rf_attenuator.configured_attenuators.get(ru.attenuation_ports[0].attenuator.serial_number)
    rf_attenuator().set_ports_attenuation(ports=ports,
                                          values=values,
                                          attenuator_device=taf_attenuator_device)


def verify_xpath_field_for_value(packet: PcapPacket, xpath: str, value: list):
    """
    KW verifies given list of values is returned when checking PCAP packet in PDML format using XPATH

    :param packet: taf.analyzer.pcap.pcap_packet.PcapPacket
    :param xpath: string in XPATH syntax defining PCAP packet field to be checked
    :param value: list of strings that is expected when checking PCAP packet field(s)
    :return: None
    """

    frame_no = packet.get_field_value_by_name('frame.number')
    real_value = packet.get_field_value_by_xpath(xpath)
    msg = f"Packet No: {frame_no} - Expecting in xpath {xpath} value {value} and real value is {real_value}"
    logging.info(msg)
    if real_value != value:
        raise VerificationError(msg)


def verify_xpath_field_is_empty(packet: PcapPacket, xpath: str):
    """
    KW verifies that empty list is returned when checking PCAP packet in PDML format using XPATH
    Returning empty list means that field we want to check does not exist

    :param packet: taf.analyzer.pcap.pcap_packet.PcapPacket
    :param xpath: string in XPATH syntax defining PCAP packet field to be checked
    :return: None
    """

    frame_no = packet.get_field_value_by_name('frame.number')
    real_value = packet.get_field_value_by_xpath(xpath)
    msg = f"Packet No: {frame_no} - Expecting that xpath {xpath} returns empty list and real value is {real_value}"
    logging.info(msg)
    if real_value:
        raise VerificationError(msg)


def verify_xpath_value_is_greater_or_equal(packet: PcapPacket, xpath: str, value: int):
    """
    KW verifies if given value is greater or equal to one returned when checking PCAP packet in PDML format using XPATH

    :param packet: taf.analyzer.pcap.pcap_packet.PcapPacket
    :param xpath: string in XPATH syntax defining PCAP packet field to be checked
    :param value: int that is expected when checking PCAP packet field
    :return: None
    """

    frame_no = packet.get_field_value_by_name('frame.number')
    real_value = int(packet.get_field_value_by_xpath(xpath)[0])
    msg = f"Packet No: {frame_no} - Expecting in xpath {xpath} that real value {real_value} is grater or equal {value}"
    logging.info(msg)
    if real_value >= value:
        return real_value
    else:
        raise VerificationError(msg)


def _get_attenuator_artifacts(tl_attenuator_index):
    """
    Gets attenuator artifacts from testline configuration variable.

    :param tl_attenuator_index: number on list in __init.py__
    :return: tuple of attenuator object form testline configuration __init__ and taf.hw.rf_attenuator object
    """

    tl_attenuator = _tl.attenuators[tl_attenuator_index]
    att_alias = tl_attenuator.serial_number
    taf_attenuator_device = rf_attenuator.configured_attenuators.get(att_alias)
    return tl_attenuator, taf_attenuator_device


def _find_ru_in_testline(radio_type):
    """
    Finds first RU object by its radio_type attribute (e.g. AHEH) in testline configuration file (__init.py__).

    :param radio_type: RU.radio_type from __init.py__, e.g.: "AHEH"
    :return: first object of RU form testline configuration __init__
    """

    for gnb in _tl.gnbs:
        for capacity_unit in gnb.dus[0].airscale.common_units[0].capacity_units:
            for ru in capacity_unit.rus:
                if radio_type.upper() == ru.radio_type.upper():
                    logging.info(f"Found RU: {ru}")
                    return ru

    raise ValueError(f"RU with radio type = {radio_type} not found int testline configuration file")


def get_and_log_field_value(packet: PcapPacket, xpath: str, console: bool = False):
    """
    Function for getting filed value by XPATH from PCAP packet with additional logging for debugging purposes

    :param packet: PCAP packet
    :param xpath: str in XPATH format to retrieve value of field(s)
    :param console: bool to decide if logs to be displayed on console
    """

    frame_no = packet.get_field_value_by_name('frame.number')
    real_value = packet.get_field_value_by_xpath(xpath)
    msg = (f'Packet Number: {frame_no}\n'
           f' XPath: {xpath}\n'
           f' Value: {real_value}\n')
    logging.info(msg)
    if console:
        BuiltIn().log_to_console(msg)
    return real_value


def list_contains_same_values(list_obj: [], value: any, length: int):
    """
    Function checks if list contains all the same values. Length of list is also checked

    :param list_obj: list to be checked
    :param value: value in list to be checked
    :param length: length of list to be checked
    """

    return list_obj.count(value) == length


def enforce_protocol(protocol: str):
    """
    Functions enforces rrc_protocol for a parser used by ta_messaging.

    :param protocol: either 'rrc' or 'nr-rrc'
    """
    uesim_parser.enforce_rrc_protocol(protocol)
