"""
:copyright: Nokia Networks
:author: Damian Piasecki, Anna Bien
:maintainer: Damian Piasecki
:contact: damian.piasecki@nokia.com
"""

import re
import subprocess as sp
from os.path import join

import taf.analyzer.sherpa.interface as sherpacsvreader
from robot.api import logger
from ta5g_tshark import ta5g_tshark
from taf.converters.sherpa.interface import sherpa
from robot.errors import ExecutionFailed

from testsuite.Krakow.RRM.Airphone.resources.Python.common_gnb import handle_admin


ALIAS_TSHARK_SHERPA = 'sherpa_traces'


def validate_presence_sherpa_messages(sherpa_dir_path, validation_list):
    """
    Author: Mateusz Lesniak
    Contact: mateusz.lesniak@nokia.com
    Creation Date: 20.09.2022
    Modified Date: -

    Function used to validate occurrence of messages with appropriate values in Sherpa CSV log files.

    Args:
        sherpa_dir_path(str): Path to the Sherpa CSV log file
        validation_list(list): List of dictionaries with following structure:
        [
            {
            'sherpa_csv_name' :
                {
                    'column_name': ['column_value', ...],
                    ...,
                    'column_name': ['column_value', ...]
                }
            },
            ...,
            {
            'sherpa_csv_name' :
                {
                    'column_name': ['column_value', ...],
                    ...,
                    'column_name': ['column_value', ...]
                }
            }
        ]

        sherpa_csv_name - name of sherpa csv file
        column_name - name of column : message field name ex. INDEX-SHERPA
        column_value - list of values any of which must occur at least once ex. [0, 8].
                       Empty list means all values accepted but not None.

    Raises:
        ExecutionFailed: Missing required messages values

    Returns:
        None
    """
    sherpa_reader = sherpacsvreader.sherpa()
    not_founded_messages = []
    for sherpa_csv_file in validation_list:
        csv_filename = list(sherpa_csv_file.keys())[0]
        sherpa_csv_path = join(sherpa_dir_path, csv_filename)
        sherpa_reader.setup_reader(sherpa_csv_path)
        not_founded_messages_in_file = {csv_filename: []}
        for column_name, possible_column_values in sherpa_csv_file[csv_filename].items():
            not_founded_messages_in_file[csv_filename] = column_name
            column_values = sherpa_reader.get_values_for_column(column_name)
            column_values = list(filter(None, column_values))
            if column_values:
                if possible_column_values:
                    if not any(x in column_values for x in possible_column_values):
                        not_founded_messages.append(not_founded_messages_in_file.copy())
            else:
                not_founded_messages.append(not_founded_messages_in_file.copy())

    if not_founded_messages:
        for elem in not_founded_messages:
            csv_filename = list(elem.keys())[0]
            logger.warn("In {} following columns has no values or have bad values: {}"
                        .format(csv_filename, elem[csv_filename]))
        raise ExecutionFailed(message="Missing required messages values")


def validate_sherpa(file_path, column, messages=[]):
    """
    Author: Damian Zak
    Contact: damian.zak@nokia.com
    Creation Date: 27.01.2021
    Modified Date: -

    Function used to validate proper messages in Sherpa CSV log file

    Args:
        file_path(str): Path to the Sherpa CSV log file
        column(str): Name of the column in Sherpa CSV file in which you want to filter messages
        messages(list): List of messages you want to validate

    Raises:
        ExecutionFailed: Missing required RACH messages

    Returns:
        None
    """
    sherpa = sherpacsvreader.sherpa()
    sherpa.setup_reader(file_path)
    column_values = sherpa.get_values_for_column(column)

    messages_count = []

    for msg in messages:
        for col_val in column_values:
            filtered_msg = re.findall(r'^' + msg, col_val)
            if filtered_msg:
                messages_count.append(filtered_msg)
                break
    if len(messages_count) != len(messages):
        raise ExecutionFailed(message="Missing required RACH messages")


def configure_sherpa_application():
    """
    Configure Sherpa application to avoid error during pcap conversion.
    """
    sp.call(['sudo usermod -a -G sherpa ute'], shell=True)
    sp.call(['sudo setcap cap_net_raw,cap_net_admin=eip /opt/Nokia/Sherpa_5G_18/Sherpa'], shell=True)


@handle_admin
def activate_sherpa_traces(sherpa_type, source_ip='10.0.1.2', dscp=15, destination_ip='10.0.1.1',
                           destination_port=5679, timeout=60, *args, **kwargs):
    """
    Activate single sherpa traces type.

    :param sherpa_type:
    :param source_ip:
    :param dscp:
    :param destination_ip:
    :param destination_port:
    :param timeout:
    """
    status = kwargs["connection"].start_uplane_l2_trace(
        source_ip=source_ip,
        dscp=dscp,
        destination_ip=destination_ip,
        destination_port=destination_port,
        trace_type='Sherpa',
        up_sw=sherpa_type,
        timeout=timeout
    )
    return status


@handle_admin
def deactivate_sherpa_traces(sherpa_type, timeout=60, *args, **kwargs):
    """
    Deactivate single sherpa traces type.

    :param sherpa_type:
    :param timeout:
    """
    status = kwargs["connection"].stop_uplane_l2_trace(
        trace_type='Sherpa',
        up_sw=sherpa_type,
        timeout=timeout
    )
    return status


def start_collecting_sherpa_traces(sherpa_types, log_filename, log_dirpath, eth_interface='eth3',
                                   alias=ALIAS_TSHARK_SHERPA):
    """
    Setup collecting sherpa pcap logs.

    :param sherpa_types: (list)
    :param log_filename:
    :param log_dirpath:
    :param eth_interface:
    :param alias:
    """
    configure_sherpa_application()
    for sherpa_type in sherpa_types:
        activate_sherpa_traces(sherpa_type)
    ta5g_tshark().start_tshark(
        log_filename=log_filename,
        log_dirpath=log_dirpath,
        eth_interface=eth_interface,
        alias=alias
    )


def stop_collecting_sherpa_traces(sherpa_types, convert_to_csv=True, sherpa_pcap_file_path=None,
                                  sherpa_csv_dir=None, alias=ALIAS_TSHARK_SHERPA):
    """
    Teardown collecting sherpa pcap logs.

    :param sherpa_types:
    :param convert_to_csv:
    :param sherpa_pcap_file_path:
    :param sherpa_csv_dir:
    :param alias:
    """
    ta5g_tshark().stop_tshark(alias=alias)
    for sherpa_type in sherpa_types:
        deactivate_sherpa_traces(sherpa_type)
    if convert_to_csv:
        convert_sherpa_to_csv(sherpa_pcap_file_path, sherpa_csv_dir)


def convert_sherpa_to_csv(sherpa_pcap_file_path, sherpa_csv_dir):
    """
    Convert Sherpa .pcap to .csv (case when sherpa tool is available in localhost).

    :param sherpa_pcap_file_path:
    :param sherpa_csv_dir:
    """
    try:
        sherpa().create_sherpa_converter(
            name='sherpa',
            file_path_pattern=sherpa_pcap_file_path,
            output_path=sherpa_csv_dir
        )
        sherpa().setup(alias='sherpa')
        sherpa().convert(name='sherpa')
    finally:
        sherpa().teardown(alias='sherpa')
