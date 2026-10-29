import os
import sys
import zipfile
import tarfile
import logging
from moler.cmd.unix.iptables import Iptables
from taf.rfrl.utilities.moler.general import parse_raw_command_output
from taf.rfrl.utilities.logger.custom_logger import log_info_to_console


def extract_snapshot(snapshot_path, file_name_to_find):
    """
    Extracts the snapshot to given location
    :param snapshot_path:         Local path to snapshot file
    :param file_name_to_find:    File to find in snapshot
    """
    extracted_path = snapshot_path.split(".")[0]
    f = zipfile.ZipFile(snapshot_path, 'r')
    f.extractall(extracted_path)
    logging.info("Snapshot files extracted to path : {}".format(extracted_path))
    for r, d, f in os.walk(extracted_path):
        for filename in f:
            if file_name_to_find in filename:
                my_tar = tarfile.open(os.path.join(r, filename))
                my_tar.extractall(extracted_path)
                my_tar.close()
    return extracted_path


def get_packets_count(extracted_snapshot_dir, chain, search_info):
    """
    Gets required packets count from file
    :param extracted_snapshot_dir:    Local path to extracted snapshot file
    :param chain:                     Chain name
    :param search_info:               Additional information about searched packets (dict - f.e. {'TARGET': 'ACCEPT'})
    Sample output from iptables assigned to file_content_res variable:
    'ICMP_INPUT_RATE_LIMIT': {'CHAIN': [{'BYTES': '56448',
                                         'DESTINATION': '0.0.0.0/0',
                                         'IN': '*',
                                         'OPT': '--',
                                         'OUT': '*',
                                         'PKTS': '2016',
                                         'PROT': 'icmp',
                                         'REST': 'limit: avg 100/sec burst 16',
                                         'SOURCE': '0.0.0.0/0',
                                         'TARGET': 'ACCEPT'},
                                        {'REST': 'limit: avg 100/sec burst 16'},
                                        {'BYTES': '504K',
                                         'DESTINATION': '0.0.0.0/0',
                                         'IN': '*',
                                         'OPT': '--',
                                         'OUT': '*',
                                         'PKTS': '17984',
                                         'PROT': 'icmp',
                                         'SOURCE': '0.0.0.0/0',
                                         'TARGET': 'DROP'}],
                              'REFERENCES': '2'},
    """
    file_content = open(os.path.join(extracted_snapshot_dir, "iptables")).read()
    file_content_res = parse_raw_command_output(Iptables, file_content)
    file_content_chain = file_content_res[chain]['CHAIN'][::-1]
    for param in file_content_chain:
        if all(key in param and search_info[key] in param[key] for key in search_info):
            return param['PKTS']
    raise Exception('There is no object in iptables {} with the given search parameters {}'.format(chain, search_info))


def verify_packets_count(accepted_packets_before, dropped_packets_before, accepted_packets_after, dropped_packets_after,
                         accepted_packets_range, dropped_packets_range):
    """
    Verifies if the accepted and dropped packets are within a given range
    :param accepted_packets_before:    Number of accepted packets before operation
    :param dropped_packets_before:     Number of dropped packets before operation
    :param accepted_packets_after:     Number of accepted packets after operation
    :param dropped_packets_after:      Number of dropped packets after operation
    :param accepted_packets_range:     Acceptable range of accepted packets (list, f.e. ['2016', '4032'])
    :param dropped_packets_range:      Acceptable range of dropped packets (list, f.e. ['15968', '17984'])
    """
    accepted_packets = int(accepted_packets_after) - int(accepted_packets_before)
    dropped_packets = int(dropped_packets_after) - int(dropped_packets_before)
    min_accepted_packets = int(accepted_packets_range[0])
    max_accepted_packets = int(accepted_packets_range[1])
    min_dropped_packets = int(dropped_packets_range[0])
    max_dropped_packets = int(dropped_packets_range[1])
    res = []
    if not min_accepted_packets <= accepted_packets <= max_accepted_packets:
        res.append('Number of accepted packets is incorrect. Expected value between: {} and {}, Actual value: {}'
                   .format(min_accepted_packets, max_accepted_packets, accepted_packets))
    if not min_dropped_packets <= dropped_packets <= max_dropped_packets:
        res.append('Number of dropped packets is incorrect. Expected value between: {} and {}, Actual value: {}'
                   .format(min_dropped_packets, max_dropped_packets, dropped_packets))
    if res:
        raise Exception(res)
    log_info_to_console(msg='Numbers of accepted and dropped packets are correct: {} and {}'
                        .format(accepted_packets, dropped_packets), log_hierarchy=1)
    log_info_to_console(msg='Accepted packets range: {} - {}'
                        .format(min_accepted_packets, max_accepted_packets), log_hierarchy=2)
    log_info_to_console(msg='Dropped packets range: {} - {}'
                        .format(min_dropped_packets, max_dropped_packets), log_hierarchy=2)


def get_current_python():
    return sys.executable
