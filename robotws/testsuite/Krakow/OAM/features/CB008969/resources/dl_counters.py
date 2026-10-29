"""
Keywords for Feature CB008969 Check DL counters from SOAP messages

:author: Elzbieta Tatoj
:maintainer: Jaroslaw Lezon
:contact: jaroslaw.lezon@nokia.com

"""

import logging
import re

from moler.exceptions import CommandFailure
from moler.device import DeviceFactory
from taf.rfrl.bts.devices.ru.ru_operations import GnbRuOperations
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl


def get_last_two_stats_values_from_file(ru, filepath, stats_name, raise_error_if_filepath_not_exist=False):
    """
    Get the last two DL counters values from the SOAP messages on the RU for the specified filepath and statistics.

    :param ru: Radio Unit device
    :param filepath: e.g. /run/UnitOAM_SOAP_Runtime_Log/UnitOAM_SOAP_Runtime_Log306.xml
    :param stats_name: e.g. receiverPcsStatusChangeCount,
                            receivedFecCorrectedCodewords,
                            receivedFecUncorrectedCodewords,
                            receivedCrcErroredFrames
    :param raise_error_if_filepath_not_exist: if set to 'True', will raise exception
    :return: e.g. ['timestamp value=2023-02-01T09:02:01',
                   'receiverPcsStatusChangeCount>2<',
                   'receiverPcsStatusChangeCount>3<']
    """
    ls_cmd = ru.get_cmd(cmd_name='ls', cmd_params={'path': filepath})
    output = None
    try:
        ls_cmd()
        dl_counters_cmd = ru.get_cmd(cmd_name='cat',
                                     cmd_params={'path': '',
                                                 'options': filepath +
                                                 ' | grep ' + stats_name +
                                                 ' | grep -oE "ethernetMonitor.[0-1]|'
                                                 'timestamp value.{20}|' + stats_name + '>[0-9]{1,}<"'
                                                                                        ' | tail -n 8'})
        output = dl_counters_cmd()['LINES']
        logging.debug('The last two statistics values taken from the content of the file "{}" are    {}'
                      .format(filepath, output))
        if output:
            output_dict = convert_output_into_dict(output)
            return output_dict
    except CommandFailure as e:
        if raise_error_if_filepath_not_exist:
            raise e
        logging.info('Oops! File "{}" doesn\'t exist.'.format(filepath))


def find_in_gz_files(ru, dir_name):
    """
    Find the last zipped file with the specified name, then unpack it and save without deleting the original.

    :param ru: Radio Unit device
    :param dir_name: e.g. /run/UnitOAM_SOAP_Runtime_Log
    :return: unzipped file path
    """
    last_log_gz_cmd = ru.get_cmd(cmd_name='ls',
                                 cmd_params={'options': ' -t ' + dir_name + '/*.gz | head -n 1', 'path': ''})
    try:
        last_log_gz_cmd_output = last_log_gz_cmd()
    except CommandFailure:
        logging.debug('Directory "{}" doesn\'t exist or there are no gz files inside '.format(dir_name))
        return None

    last_log_gz_list = list(last_log_gz_cmd_output['files'].keys())
    last_log_gz_name = last_log_gz_list[0] if last_log_gz_list else None
    logging.info('Last zipped file\'s name:   {}'.format(last_log_gz_name))

    gunzip_cmd = ru.get_cmd(cmd_name='gunzip',
                            cmd_params={'archive_name': [last_log_gz_name]})

    sudo_cmd = ru.get_cmd(cmd_name="sudo",
                          cmd_params={
                              "cmd_object": gunzip_cmd
                          })
    sudo_cmd()
    last_archive_log_unzipped = last_log_gz_name.rstrip('.gz')
    logging.info('Last unzipped file\'s name:   "{}"'.format(last_archive_log_unzipped))

    if last_archive_log_unzipped:
        return last_archive_log_unzipped


def zip_back_gz_file(ru, dir_name):
    """
    Zip the file with the specified name, and delete the unpacked file.

    :param ru: Radio Unit device
    :param dir_name: e.g. /run/UnitOAM_SOAP_Runtime_Log
    """

    logging.info('Last unzipped file\'s name:   {}'.format(dir_name))

    gzip_cmd = ru.get_cmd(cmd_name='gzip',
                          cmd_params={'file_name': dir_name})

    sudo_cmd = ru.get_cmd(cmd_name="sudo",
                          cmd_params={
                              "cmd_object": gzip_cmd
                          })

    sudo_cmd()


def convert_output_into_dict(output):
    """
    Convert the list of strings from the output to a dictionary with the following structure:
    key->statistics name, value->list of collected last two values (integers). Skip the timestamp string.

    :param output: the output received from the "get_last_two_stats_values_from_file" function,
    :return: e.g. {'receivedCrcErroredFrames': [2, 3]}, True
    """
    output_dict = {}
    eth_monitor_order = []
    correct_order = True
    pattern = re.compile(r"(\w+)>([0-9]+)<")
    eth_monitor_pattern = re.compile(r"([A-Za-z]+\.)(\d)")
    for elem in output:
        match = pattern.search(elem)
        if match:
            stats_name = match.group(1)
            stats_value = match.group(2)
            if stats_value is not None:
                stats_value = int(stats_value)
            if stats_name not in output_dict:
                output_dict[stats_name] = [stats_value]
            else:
                output_dict[stats_name].append(stats_value)
        match_eth = eth_monitor_pattern.search(elem)
        if match_eth:
            stats_value = match_eth.group(2)
            if stats_value is not None:
                stats_value = int(stats_value)
                eth_monitor_order.append(stats_value)
    logging.info("SOAP statistics: {} Ethernet links order: {}".format(output_dict, eth_monitor_order))
    if eth_monitor_order[0] == 1:
        correct_order = False
    return output_dict, correct_order


@load_moler_configuration_from_tl()
def get_last_dl_counters_from_soap_on_ru(stats_name, update_ru_ip=False, gnb_id=0, du_id=0, ru_id=0):
    """
    Get the last two DL counters values from the SOAP messages on the RU for the specified statistics.

    :param stats_name: e.g. receiverPcsStatusChangeCount
    :param update_ru_ip: indicates if RU IP should be updated (e.g. after reboot). type: bool
    :param gnb_id: ID of gNB which should be checked in TL config; defaults to 0 (first gNB in config)
    :param du_id: ID of DU which should be checked in TL config; defaults to 0 (first DU in config)
    :param ru_id: ID of RU which should be checked in TL config; defaults to 0 (first RU in config)

    :return: e.g.   {'receiverPcsStatusChangeCount': [2, 3]}
    """
    ru_operations = GnbRuOperations()
    ru_name = ru_operations.ssh_ru_alias.format(gnb_id, du_id, ru_id)
    ru = DeviceFactory.get_device(ru_name)
    ru.goto_state('RU')

    logging.debug('<><><> Start collecting DL_counters_from_SOAP_messages_on_RU <><><>')
    first_filepath = '/run/Unit*/UnitOAM_SOAP_*.xml'
    stats_dict = get_last_two_stats_values_from_file(ru, first_filepath, stats_name)
    if stats_dict:
        return stats_dict

    second_try_dir_name = "/run/UnitOAM_SOAP_Runtime_Log"
    second_filepath = find_in_gz_files(ru, second_try_dir_name)
    if second_filepath:
        stats_dict = get_last_two_stats_values_from_file(ru, second_filepath, stats_name)
        zip_back_gz_file(ru, second_filepath)
    if stats_dict:
        return stats_dict

    third_try_dir_name = "/run/UnitOAM_SOAP_Startup_LBTS_OM*"
    third_filepath = find_in_gz_files(ru, third_try_dir_name)
    if third_filepath:
        stats_dict = get_last_two_stats_values_from_file(ru, third_filepath, stats_name,
                                                         raise_error_if_filepath_not_exist=True)
        zip_back_gz_file(ru, third_filepath)
    if stats_dict:
        return stats_dict
