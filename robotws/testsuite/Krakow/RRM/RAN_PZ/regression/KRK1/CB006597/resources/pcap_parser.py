import os
import logging
from taf.analyzer.pcap import pcap
from taf.rfrl.utilities.test_config import get_log_path


def initialize_pcap():
    return pcap()


def _get_pcap_file_name(pcap_dir, sub_dir=None):
    if not pcap_dir:
        pcap_dir = os.path.join(get_log_path(), sub_dir).strip()
    pcap_file = None
    for _file in os.listdir(pcap_dir):
        if _file.endswith('pcap') or _file.endswith('pcap0'):
            pcap_file = _file
            break
    return pcap_file


def check_pcap_entry_value(pcap_dir, display_filter, parameter=None, value=None):
    """
    Function to filter a given pcap file by parameter
    :param pcap_dir: location of pcap file to be searched
    :param display_filter: filter by which to filter packets
    :param  parameter: optional, field name in a packet
    :param  value: optional, field value in a packet
    :return: None
    """
    pcap = initialize_pcap()
    pcap_parser = pcap.setup(infile=os.path.join(pcap_dir, _get_pcap_file_name(pcap_dir)),
                             display_filter=display_filter)
    packets = pcap.get_packets(filter=display_filter, pcap_parser=pcap_parser)
    if packets:
        if parameter:
            param_values = pcap.get_field_value(field_name=parameter, fmt='showname',
                                                pcap_parser=pcap_parser)
            param_values = param_values[0][0].split(': ')
            logging.info('Value: ' + str(param_values))
            pcap_value = param_values[1]
            if str(value) in str(pcap_value):
                logging.info(param_values)
            else:
                raise WrongMessage("Wrong parameter value: {} is not {}".format(pcap_value, value))
    else:
        raise NoMessageInPcap("{} not found".format(display_filter))


def check_HO_messages(pcap_dir, message):
    """
    Function to filter a given pcap file by parameter
    :param pcap_dir: location of pcap file to be searched
    :param message: field name in a packet
    :return: filtered values
    """
    pcap = initialize_pcap()
    pcap_parser = pcap.setup(infile=os.path.join(pcap_dir, _get_pcap_file_name(pcap_dir)),
                             display_filter='xnap_16_5_0_2103_n03')
    packets = pcap.get_packets(filter=message, pcap_parser=pcap_parser)
    logging.info(packets)
    if packets:
        return pcap.get_field_value(field_name=message, fmt='showname',
                                    pcap_parser=pcap_parser)
    else:
        raise NoMessageInPcap("{} not found".format(message))


class NoMessageInPcap(Exception):
    pass


class WrongMessage(Exception):
    pass
