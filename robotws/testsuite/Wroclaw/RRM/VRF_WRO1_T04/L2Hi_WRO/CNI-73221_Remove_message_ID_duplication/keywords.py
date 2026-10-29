import shutil
from robot.errors import ExecutionFailed
import glob
import logging
import os
import time
from taf.rfrl.utilities.robot.general import get_builtin_value, set_robot_suite_variable
from taf.collectors.l2stream3 import l2stream3
from taf.collectors.core import CollectorKeywords
from taf.collectors.tcpdump import tcpdump
from taf.converters.sherpa.interface import sherpa

TRACE_FILE_NAME = 'tcpdump.pcap'
csv_filename = "micro__l1l2Trace.csv"
sherpa_text_column = "TEXT"
sherpa_collector_name = 'sherpa_trace'


def attach_nsa_ue_and_collect_sherpa_traces(collector_name=sherpa_collector_name):
    start_sherpa_trace(collector_name=collector_name)
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


def collect_sherpa_and_parse_to_csv(sherpa_collector_name):
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
    tcpdump_collector = collector_name + "_tcpdump"
    start_tcpdump_on_test_pc(collector=tcpdump_collector)
    start_sherpa_trace_stream(tcpdump_collector=tcpdump_collector, collector_name=collector_name)


def start_tcpdump_on_test_pc(interface='eth0', option='port 5678', collector="tcpdump"):
    options = '-i {interface} {option}'.format(interface=interface, option=option)
    tcpdump_collector = tcpdump()
    tcpdump_collector.create_tcpdump_collector(name=collector, options=options, sudo_password='ute')
    tcpdump_collector.set_suite_alias(collector)


def start_sherpa_trace_stream(tcpdump_collector, collector_name):
    executor = {'host': '192.168.255.129',
                'user': 'Nemuadmin',
                'password': 'nemuuser',
                'port': 443}
    logging.info('Executor: {}'.format(executor))
    l2_stream_config = {'trace_type': 'Sherpa'}
    sherpa_collector = l2stream3()
    sherpa_collector.create_sbts_l2stream_collector(name=collector_name, webservice=executor,
                                                    source_ip_addr='10.0.1.2',
                                                    destination_ip_addr='10.0.1.1',
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


def check_file_size(expected_file_size_bytes, trace_name, log_path):
    FILE_PATH = log_path + '/CNI-73221 Remove message ID duplication/' \
                'CNI-73221_Remove_message_ID_duplication_in_L2Log_interface_for_Sherpa_and_Component_trace/' \
                'l2stream3/tcpdump'
    new_file_path = log_path + '/' + trace_name + '/'
    shutil.move(FILE_PATH, new_file_path)
    file_size = int(os.path.getsize(new_file_path+TRACE_FILE_NAME))
    if file_size < int(expected_file_size_bytes):
        raise ExecutionFailed(
            message="The L2 trace file size {} is smaller that expected {}".format(file_size,
                                                                                   expected_file_size_bytes),
            continue_on_failure=True,
        )
