import os.path
import time
from robot.api import logger
from testsuite.Wroclaw.RRM.resources.log.helper import LogHelper
from taf.ul.log_collection import log_collection
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.utilities import get_robot_output_dir

bip_collector = log_collection()


def start_bip_collection_aic():

    names = 'LogsToCollect'
    config = {
              "BipLogs":  {"type": "bip",
                           "interface": "both"},
              "LogsToCollect": {
                      "type": "group",
                      "members": "BipLogs"
               }
              }
    bip_collector.create_collectors_using_testline_information(names=names,
                                                               configuration=config)
    bip_collector.setup_collectors(names=names)
    bip_collector.start_collectors(names=names)


def stop_bip_collection_aic(filename='bip', output_dir=None, vdu_id=0):
    if not output_dir:
        output_dir = get_robot_output_dir()
    names = 'LogsToCollect'
    bip_collector.stop_collectors(names=names)
    bip_collector.collect_collectors(names=names, target_dir=output_dir)

    bip_files = bip_collector.get_log_file('BIP', target_dir=output_dir, network_element=f'gnb_{vdu_id}')
    bip_collector.teardown_collectors('LogsToCollect')

    logger.info('BIP Files collected:')
    renamed_bip_files = []
    for f in bip_files:
        new_filename = os.path.basename(f).replace('tcpdump_l2rt', f'{filename}_l2rt')\
            .replace('tcpdump_l2nrt', f'{filename}_l2nrt')
        new_filepath = f'{output_dir}/{new_filename}'
        os.system(f'mv {f} {new_filepath}')
        renamed_bip_files.append(new_filepath)
        logger.info(new_filepath, also_console=True)
    return renamed_bip_files


def collect_bip_log_aic(filename='bip', num_of_sec=10, output_dir=None):
    start_bip_collection_aic()
    time.sleep(num_of_sec)
    bip_files = stop_bip_collection_aic(filename=filename, output_dir=output_dir)
    return bip_files


def bip_file_selector(file_list, bip_file_type=None):
    """
    :param file_list: list of pcap filepaths
    :param bip_file_type: l2rt or l2nrt
    """
    return next((f for f in file_list if bip_file_type in f), None)


def bip_finder(pcap_file, shark_filter):
    with LogHelper() as lh:
        finder = lh.add_pcap(
            pcap_file_path=pcap_file, lua=None, shark_filter=shark_filter,
            ts_output_data_file_path=None, clean_up_tmp_file=False
        )
    return finder
