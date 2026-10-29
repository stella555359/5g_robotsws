"""
:copyright: Nokia Networks
:author: Szymon Lange
:maintainer: Szymon Lange
:contact: szymon.lange@nokia.com
"""

import subprocess as sp

from ta5g_tshark import ta5g_tshark


def start_capturing_traffic_on_vm_interface(file_dir, file_name='tcpdump.pcap', vm_interface='eth3',
                                            capture_filter='', **kwargs):
    """
    :param file_dir:       (str) absolute path to log directory
    :param file_name:      (str) name of the .pcap file
    :param vm_interface:   (str) VM interface on which traffic should be captured
    :param capture_filter: (str) traffic filter for tshark
    """

    tshark_instance = ta5g_tshark()
    tshark_instance.start_tshark(
        log_filename=file_name,
        log_dirpath=file_dir,
        eth_interface=vm_interface,
        capture_filter=capture_filter,
        **kwargs
    )


def stop_capturing_traffic_on_vm(**kwargs):
    tshark_instance = ta5g_tshark()
    tshark_instance.stop_tshark(**kwargs)


def terminate_all_traffic_capture_on_vm():
    sp.call(['sudo', 'pkill', '-f', 'pcap'])


def start_capturing_wts_sctp_traffic(output_dir):
    start_capturing_traffic_on_vm_interface(
        file_dir=output_dir,
        file_name='tcpdump_wts_sctp.pcap',
        capture_filter='sctp',
        alias='tshark_sctp'
    )


def stop_capturing_wts_sctp_traffic():
    stop_capturing_traffic_on_vm(alias='tshark_sctp')


def convert_pcap_to_csv(input_file_path, fields_to_extract):
    """
    Convert .pcap file to .csv extracting defined columns

    :param input_file_path:    (str) absolute path to .pcap file
    :param fields_to_extract:  (str) columns to be included in csv, e.g. ['frame.protocols', 'ip.src', 'udp.srcport']
    :return out_file:          (str) absolute path to .csv file
    """

    out_file = input_file_path.replace(".pcap", ".csv")
    cmd = ['tshark', '-r', input_file_path, '-T', 'fields', '-E', 'header=y', '-E', 'separator=,', '-E',
           'quote=d', '-E', 'occurrence=a']
    for field in fields_to_extract:
        cmd += ['-e', field]
    with open(out_file, 'w') as f:
        sp.run(cmd, stdout=f)
    return out_file
