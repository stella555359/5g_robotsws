import glob
import logging
import os
import re
import socket
import time
import taf.analyzer.sherpa.interface as sherpacsvreader
from taf.rfrl.utilities.robot.general import get_builtin_value, set_robot_suite_variable
from taf.collectors.l2stream3 import l2stream3
from taf.collectors.core import CollectorKeywords
from taf.collectors.tcpdump import tcpdump
from taf.converters.sherpa.interface import sherpa


_tl = get_builtin_value('tl')
csv_filename = "micro__l1l2Trace.csv"
sherpa_text_column = "TEXT"
regex_slot_type_78 = r'[sS]lot[tT]ype=78'


class SlotType78PresetInSherpaTrace(Exception):
    """Throws when SlotType 78 is preset in Sherpa Trace"""
    pass


class SlotType78NotPresetInSherpaTrace(Exception):
    """Throws when SlotType 78 is not preset in Sherpa Trace"""
    pass


class SlotType78PresetInUnexpectedSlotsInSherpaTrace(Exception):
    """Throws when SlotType 78 is preset in unexpected slots in Sherpa Trace"""
    pass


def slot_type_78_present_in_sherpa_log(sherpa_dir_path):
    """
    Checks if "slotType=78" is present in Sherpa trace

    :param str sherpa_dir_path: path to directory with parsed csv files
    :return: True when "slotType=78" is found in Sherpa trace
    """
    sherpa_reader = sherpacsvreader.sherpa()
    sherpa_csv_path = os.path.join(sherpa_dir_path, csv_filename)
    sherpa_reader.setup_reader(sherpa_csv_path)
    rows = sherpa_reader.get_values_for_column(column=sherpa_text_column,
                                               regex_filter=regex_slot_type_78)
    logging.info("Found matches: {}".format(rows))
    return len(rows) > 0


def slot_type_78_present_only_in_specified_slots_in_sherpa_log(sherpa_dir_path, slots):
    """
    Checks if "slotType=78" is present only in specified slots in Sherpa trace

    :param str sherpa_dir_path: path to directory with parsed csv files
    :param list[str] slots:
    :return: True when "slotType=78" is found only in specified slots in Sherpa trace
    """
    sherpa_reader = sherpacsvreader.sherpa()

    sherpa_csv_path = os.path.join(sherpa_dir_path, csv_filename)
    sherpa_reader.setup_reader(sherpa_csv_path)
    slots_regex = r'\d+\.{}'.format("|".join(slots))
    logging.info("Slot regex: {}".format(slots_regex))
    rows = sherpa_reader.get_rows_for_matching_column(column=sherpa_text_column, regex_filter=regex_slot_type_78)
    for row in rows:
        match = re.search(slots_regex, row["AIR TTI"])
        if match is None:
            logging.info("Found line that doesnt match regex {}: {}".format(slots_regex, row))
            return False
        logging.info("Found match {} in row: {}".format(match, row))
    return True


def verify_that_slot_type_78_is_not_used(collector_name):
    """
    Raises exception if "slotType=78" is found in Sherpa trace

    :param collector_name: name of collector used to gather Sherpa trace
    :return: None
    """
    sherpa_csv_dir_path = collect_sherpa_and_parse_to_csv(collector_name)
    if slot_type_78_present_in_sherpa_log(sherpa_csv_dir_path):
        msg = "SlotType=78 was found in Sherpa trace but it shouldn't!"
        raise SlotType78PresetInSherpaTrace(msg)


def verify_that_slot_type_78_is_used(collector_name):
    """
    Raises exception if "slotType=78" is not found at all or found in slots without CCE split in Sherpa trace

    :param collector_name: name of collector used to gather Sherpa trace
    :return: None
    """
    sherpa_csv_dir_path = collect_sherpa_and_parse_to_csv(collector_name)
    slots = ["02", "12"]
    if not slot_type_78_present_in_sherpa_log(sherpa_csv_dir_path):
        msg = "SlotType=78 was not found in Sherpa trace but it should"
        raise SlotType78NotPresetInSherpaTrace(msg)
    if not slot_type_78_present_only_in_specified_slots_in_sherpa_log(sherpa_csv_dir_path, slots):
        msg = "SlotType=78 was not found in Sherpa trace in slots different than {}".format(slots)
        raise SlotType78PresetInUnexpectedSlotsInSherpaTrace(msg)


def collect_sherpa_and_parse_to_csv(sherpa_collector_name):
    """
    Collect Sherpa trace locally to pcap then coverts pcap to csv

    :param sherpa_collector_name: name of collector used to gather Sherpa trace
    :return: path to directory with parsed csv files
    """
    start_sherpa_trace(collector_name=sherpa_collector_name)
    output_dir = get_builtin_value('LOG_PATH')
    logging.info("output dir: {}".format(output_dir))
    time.sleep(3)
    stop_and_collect_sherpa_trace(output_dir=output_dir, collector_name=sherpa_collector_name)
    sherpa_pcap = find_pcap_in_dir(os.path.join(output_dir, sherpa_collector_name))[0]
    convert_sherpa_to_csv(sherpa_pcap, output_dir)
    pcap_name = os.path.basename(os.path.splitext(sherpa_pcap)[0])
    logging.info("pcap name: {}".format(pcap_name))
    sherpa_csv_dir_path = os.path.join(output_dir, pcap_name)
    return sherpa_csv_dir_path


def start_sherpa_trace(collector_name):
    """
    Starts tcpdump on local test pc and then starts Sherpa trace streaming on gNB

    :param collector_name: name of collector used to start tcpdump and Sherpa trace
    :return: None
    """
    tcpdump_collector = collector_name + "_tcpdump"
    start_tcpdump_on_test_pc(collector=tcpdump_collector)
    start_sherpa_trace_stream(tcpdump_collector=tcpdump_collector, collector_name=collector_name)


def start_tcpdump_on_test_pc(interface='eth0', option='port 5678', collector="tcpdump"):
    """
    Starts tcpdump on local test pc

    :param interface: name of interface on which tcpdump will be collected
    :param option: tcpdump options to added to command
    :param collector: name of collector used to start tcpdump
    :return: None
    """
    testpc_ssh_config = {'host': _tl.test_pc.default_ssh_connection_details.addr,
                         'user': _tl.test_pc.default_ssh_connection_details.username,
                         'password': _tl.test_pc.default_ssh_connection_details.password}
    options = '-i {interface} {option}'.format(interface=interface, option=option)
    tcpdump_collector = tcpdump()
    tcpdump_collector.create_tcpdump_collector(name=collector, options=options, executor=testpc_ssh_config)
    tcpdump_collector.setup_collectors(names=collector)
    tcpdump_collector.start_collectors(names=collector)
    tcpdump_collector.set_suite_alias(collector)


def start_sherpa_trace_stream(tcpdump_collector, collector_name):
    """
    Starts Sherpa trace streaming

    :param tcpdump_collector: name of collector used to start tcpdump
    :param collector_name: name of collector used to start Sherpa trace streaming
    :return: None
    """
    src_ip = _tl.gnbs[0].cu.backhaul_site_oam_ip.v4
    dst_ip = get_test_pc_ip()
    executor = {'host': src_ip,
                'user': _tl.gnbs[0].cu.oam_http_connection_details.username,
                'password': _tl.gnbs[0].cu.oam_http_connection_details.password,
                'port': 443}
    logging.info('Executor: {}'.format(executor))
    l2_stream_config = {'trace_type': 'Sherpa'}
    sherpa_collector = l2stream3()
    sherpa_collector.create_sbts_l2stream_collector(name=collector_name, webservice=executor,
                                                    source_ip_addr=src_ip,
                                                    destination_ip_addr=dst_ip,
                                                    collector=tcpdump_collector,
                                                    l2_stream_configuration=[l2_stream_config],
                                                    start_timeout=30,
                                                    stop_timeout=30)
    core = CollectorKeywords()
    core.setup_collectors(names=collector_name)
    core.start_collectors(names=collector_name)
    core.set_suite_alias(collector_name)
    logging.info('Sherpa streaming started!')


def stop_and_collect_sherpa_trace(output_dir, collector_name):
    """
    Stops Sherpa trace and collects logs

    :param output_dir: path to directory where pcap with Sherpa trace will be stored
    :param collector_name: name of collector used to start Sherpa trace streaming
    :return: None
    """
    core = CollectorKeywords()
    core.stop_collectors(names=collector_name)
    core.collect_collectors(names=collector_name, target_dir=output_dir)


def stop_and_teardown_sherpa_trace(collector_name):
    """
    Stops Sherpa trace and teardowns the collector

    :param collector_name: name of collector used to start Sherpa trace streaming
    :return: None
    """
    core = CollectorKeywords()
    core.stop_collectors(names=collector_name)
    core.teardown_collectors(names=collector_name)


def convert_sherpa_to_csv(sherpa_pcap_file_path, sherpa_csv_dir):
    """
    Convert Sherpa .pcap to .csv (case when sherpa tool is available in localhost).

    :param sherpa_pcap_file_path: path to pcap file
    :param sherpa_csv_dir: path to directory where parsed csv will be stored
    :return: None
    """
    try:
        sherpa().create_sherpa_converter(
            name='sherpa_converter',
            file_path_pattern=sherpa_pcap_file_path,
            output_path=sherpa_csv_dir
        )
        sherpa().setup(alias='sherpa_converter')
        sherpa().convert(name='sherpa_converter')
    finally:
        sherpa().teardown(alias='sherpa_converter')


def find_pcap_in_dir(directory):
    """
    Performs searching of all pcap files in given directory and subdirectories.

    :param directory: directory to search
    :return: list of all found pcap files
    """
    files = glob.glob(fr'{directory}/**/*.pcap', recursive=True)
    logging.debug('Searching result: {}'.format(files))
    if len(files) == 0:
        raise FileNotFoundError(f'No pcap files in {directory} directory and subdirectories.')
    return files


def get_test_pc_ip():
    """
    Gets IP address (not FQDN) of test PC
    :return: IP address
    """
    vm_address = _tl.test_pc.default_ssh_connection_details.addr
    dst_ip = socket.gethostbyname(vm_address)
    return dst_ip


def remove_unused_gnb_from_tl_robot_variable():
    """
    Removes second gNB from 'tl' variable that common keywords won't check its state since it is not used for tests
    :return: None
    """
    tl_var = get_builtin_value('tl')
    logging.info('Initial tl variable: {}'.format(tl_var))
    del tl_var.gnbs[1]
    logging.info('Modified tl variable: {}'.format(tl_var))
    set_robot_suite_variable('tl', tl_var)
