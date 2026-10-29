from taf.analyzer.pdml import PdmlReader
from robot.api import logger
import re


def check_if_asil(variable):
    return variable == 'ASIL AirScale Common'


def check_if_abil(variable):
    return variable == 'ABIL AirScale Capacity'


def check_if_asil_and_abil(asil, abil):
    return asil and abil


def pdml_path_from_pcap_path(pcap_path):
    pdml_path = pcap_path.replace('pcap', 'pdml')
    return pdml_path


def pdml_file_to_dict(file_name, field_name_list):
    """
    Extract specific packets from pdml file and creates dictonary

    Parameters
    ----------
    file_name: str
        path to pdml file
    field_name_list: list
        packets that have to be extracted from pdml file

    Returns
    -------
    dictonary
        key: packet number in pdml file
        value: dictonary of all parameters and their values from packet
    """
    with open(file_name, 'rb') as file_obj:
        actual_msc_dict = {}
        for num, pdml_entry in enumerate(PdmlReader(file_obj=file_obj)):
            for field_name in field_name_list:
                for value in pdml_entry.packet.findall(field_name):
                    if num not in actual_msc_dict.keys():
                        actual_msc_dict[num] = {}
                        actual_msc_dict[num]['packet_name_'] = field_name
                    name, val = separate_name_val_from_msg(value.showname)
                    actual_msc_dict[num][name] = val
        return actual_msc_dict


def pdml_file_to_list(file_name, field_name_list):
    """
    Extract specific packets from pdml file and creates dictonary

    Parameters
    ----------
    file_name: str
        path to pdml file
    field_name_list: list
        packets that have to be extracted from pdml file

    Returns
    -------
    list
        packets in strings from pdml file
    """
    with open(file_name) as file_obj:
        actual_msc_list = []
        for num, pdml_entry in enumerate(PdmlReader(file_obj=file_obj)):
            for field_name in field_name_list:
                if len(pdml_entry.packet.findall(field_name)) > 0:
                    actual_msc_list.append(pdml_entry)
        return actual_msc_list


def separate_name_val_from_msg(msg):
    """
    Creates dictonary from pdml file
    @_v

    Parameters
    ----------
    msg: str
        packet parameter, one-line message (ex. sfn (Uint16): 0x025c(604))

    Returns
    -------
    tuple
        (name, value) (ex. ('sfn', 0x25c))
    """
    name = re.match(r'^\S+', msg).group()
    value = re.search(r'(?<=: )[\w+.-]+', msg).group()
    return name, value


def get_packet(packet_dict, items, values):
    """
    Returns first packet that match with items and values

    Parameters
    ----------
    packets_dict: dict
        dictonary with packets from pdml file
    items_list
        tuple of items from packets in correct sequence, ex: ('patternId', 'sfc')
    values_list
        tuple of values from items in correct sequence

    Returns
    -------
    dictonary
        packet that has been found
    """
    for _, packet in packet_dict.items():
        if _packet_values_check(packet, items, values):
            return packet
    return None


def sequence_in_packets(packets_dict, items_list, values_list):
    """
    Check if sequence is in packet_dict

    Parameters
    ----------
    packets_dict: dict
        dictonary with packets from pdml file
    items_list
        list of items from packets in correct sequence, ex: ['patternId', 'sfc']
    values_list
        list of values from items in correct sequence

    Returns
    -------
    bool
        information if pattern has been found

    Example
    -------
    packet_dict:
    {.....,
    {'patternId': '0011', 'stf': 0x21c},
    {'item0': '1111', 'item1': 'aaaa'}, .......}

    items_list: ['stf', ('item1', 'item0')]     # in first packet of sequence chech item stf, in second item1 and item0
    # there is a feature that single items per packet could be without tuples

    values_list: ['0x21c', ('aaaa', '1111')]    # in first packet of sequence check value 0x21c,
    in second aaaa and 1111 (in order of items_list)
    """
    packets_nums = list(packets_dict.keys())
    packets_nums.sort()
    for index in range(len(packets_dict) - len(values_list) + 1):
        packets = []
        # gets every n packets, example: n = 2; packets: 1,5,7; loops: [1,5], [5,7]
        for num in packets_nums[index:index + len(values_list)]:
            packets.append(packets_dict[num])
        if _sequence_in_packets_helper(packets, items_list, values_list):
            return True
    return False


def _sequence_in_packets_helper(packets, items_list, values_list):
    for index, packet in enumerate(packets):
        if not _packet_values_check(packet, items_list[index], values_list[index]):
            return False
    return True


def _packet_values_check(packet, items, values):
    if type(items).__name__ != 'tuple':
        items = (items,)
    if type(values).__name__ != 'tuple':
        values = (values,)

    for index in range(len(items)):
        if not items[index] in packet.keys():
            return False
        item = packet[items[index]]
        value = str(values[index])
        match = re.search(value, item)

        if match is None:
            return False
        if len(match.group()) != len(item):
            return False
    return True


def sequence_in_packets_list(packets_list, items_list):
    """
    Check if sequence is in packet_list

    Parameters
    ----------
    packets_list: list
        list with packets (PdmlLogEntry) from pdml file
    items_list
        list of items from packets in correct sequence, ex: ['x2ap.SgNBAdditionRequest_element', ('item0', 'item1')]

    Returns
    -------
    bool
        information if sequence has been found
    """
    for index in range(len(packets_list) - len(items_list) + 1):
        if _sequence_in_packets_list_helper(packets_list[index:index + len(items_list)], items_list):
            return True
    return False


def _sequence_in_packets_list_helper(packets_list, items_list):
    for index, packet in enumerate(packets_list):
        if type(items_list[index]).__name__ != 'tuple':
            item_tuple = (items_list[index],)
        else:
            item_tuple = items_list[index]
        for item in item_tuple:
            if item not in str(packet):
                return False
    return True


def count_packets(packets_dict, items, values):
    """
    Returns count of packets that match with items and values

    Parameters
    ----------
    packets_dict: dict
        dictonary with packets from pdml file
    items_list
        tuple of items from packets in correct sequence, ex: ('patternId', 'sfc')
    values_list
        tuple of values from items in correct sequence

    Returns
    -------
    integer
        count of packets that has been found
    """
    counter = 0
    for _, packet in packets_dict.items():
        if _packet_values_check(packet, items, values):
            counter += 1
    return counter


def same_group_packets(packets_dict, packets, msg='sfn', value_regex=r'0x\w{4}'):
    """
    Check if exists group with the same msg in packets dict

    Ppackets_dict: dict
        dictonary with packets from pdml file
    packets: [(items, values), ...]
        list of packets to be in one group
    msg: str
        name of item in lookup for the same grouop
    value_regex:
        default value of msg value

    Returns
    -------
    bool
        information if group has been found

    Example
    -------
    packet_dict:
        {.....,
        {'patternId': '0011', 'stf': 0x21c},
        {'item0': '1111', 'item1': 'aaaa'}, .......}
    packets:
        [(('packet_name_', 'patternId_item_0'), ('DlData_PdcchSendReq', '0x0038')),
        (('packet_name_', 'patternId_item_0'), ('DlData_SsBlockSendReq', '0x003d'))]
    msg: 'rnti'
    value_regex: '0x|w{4}'
    """
    while True:
        packets_to_check = []
        for p in packets:
            packets_to_check.append(add_msg(p, msg, value_regex))

        items, values = packets_to_check[0]
        packet = get_packet(packets_dict, items, values)

        if packet is not None:
            if _same_group_packets(packets_dict, packets_to_check[1:]):
                return True
            value = packet[msg]
            value_regex = '(?!' + value + ')' + value_regex
        else:
            logger.debug('Packets not found')
            return False


def _same_group_packets(packets_dict, packets):
    if len(packets) == 0:
        return True
    items, values = packets[0]
    packet = get_packet(packets_dict, items, values)
    if packet is not None:
        return _same_group_packets(packets_dict, packets[1:])
    return False


def add_msg(packet, msg, value):
    items, values = packet
    items_list = list(items)
    items_list.append(msg)
    values_list = list(values)
    values_list.append(value)
    return tuple(items_list), tuple(values_list)
