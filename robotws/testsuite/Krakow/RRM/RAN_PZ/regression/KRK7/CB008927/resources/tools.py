from taf.hw.rf_attenuator import rf_attenuator
from moler.device import DeviceFactory
from moler.config import load_config
from datetime import datetime
from robot.api import logger
from typing import NoReturn
import json
import os


def filter_pcap_data(pcap_file: str,
                     result_dir: str,
                     fields_list: list = None,
                     filters_list: list = None,
                     options: list = None) -> str:
    result_file_name = f"pcap_filtered_data_{get_current_time()}.txt"
    if os.path.isfile(pcap_file):
        _load_moler_configuration("/home/ute/logs")
        my_unix = DeviceFactory.get_device(name='MyMachine')
        tshark_options = ""
        if filters_list:
            filters_options = '-2R "{}"'.format(' && '.join(filters_list))
            tshark_options = tshark_options + filters_options
        if fields_list:
            field_options = ' -T fields -e {}'.format(' -e '.join(fields_list))
            tshark_options = tshark_options + field_options
        if options:
            tshark_options = tshark_options + ' {}'.format(' '.join(options))
        cmd_options = "-r {} {} > {}".format(pcap_file, tshark_options, result_dir+"/"+result_file_name)
        ps_cmd = my_unix.get_cmd(cmd_name="tshark", cmd_params={'options': cmd_options})
        ps_cmd()
        return result_dir+"/"+result_file_name
    else:
        raise FileNotFoundError(f"\nFile {pcap_file} not found")


def check_pcap_messages(pcap_file_dir: str,
                        result_dir: str,
                        expected_result: list,
                        fields_list: list = None,
                        filters_list: list = None,
                        options: list = None) -> NoReturn:
    pcap_result = filter_pcap_data_and_convert_result_to_list(pcap_file_dir,
                                                              result_dir,
                                                              fields_list,
                                                              filters_list,
                                                              options)
    missing_messages = []
    achieved_result = pcap_result.copy()
    for message in expected_result:
        if message in pcap_result:
            pcap_result.remove(message)
        else:
            missing_messages.append(message)
    if missing_messages or pcap_result:
        raise Exception(f"\nPcap expected result: {expected_result} != PCap achieved result: {achieved_result}")


def get_pcap_file_from_dir(pcap_dir: str) -> str:
    if os.path.isfile(pcap_dir):
        raise NotADirectoryError(pcap_dir)
    if os.path.exists(pcap_dir):
        dir_content = os.listdir(pcap_dir)
        pcap_file = [pcap for pcap in dir_content if pcap.endswith(".pcap")]
        if len(pcap_file) == 0:
            raise FileNotFoundError(f"\n{pcap_dir} location doesn't contain pcap file")
        elif len(pcap_file) > 1:
            raise Exception(f"\n{pcap_dir} location contain more than one pcap file")
        else:
            return pcap_file[0]


def get_time_epoch_of_rrcreestablishment_message(pcap_file_dir: str, result_dir: str, time_epoch_no: int) -> str:
    filters_list = ["nr-rrc", "nr-rrc.c1", "nr-rrc.rrcReestablishmentRequest_element"]
    fields_list = ["frame.time_epoch"]
    all_time_epoch = filter_pcap_data_and_convert_result_to_list(pcap_file_dir, result_dir, fields_list, filters_list)
    return all_time_epoch[time_epoch_no-1]


def get_time_epoch_of_first_rrcreconfiguration_message(pcap_file_dir: str, result_dir: str, time_epoch_no: int) -> str:
    filters_list = ["nr-rrc", "nr-rrc.c1", "nr-rrc.pdsch_ConfigCommon", "nr-rrc.resourceAllocation"]
    fields_list = ["frame.time_epoch"]
    all_time_epoch = filter_pcap_data_and_convert_result_to_list(pcap_file_dir, result_dir, fields_list, filters_list)
    return all_time_epoch[time_epoch_no-1]


def filter_pcap_data_and_convert_result_to_list(pcap_file_dir: str,
                                                result_dir: str,
                                                fields_list: list = None,
                                                filters_list: list = None,
                                                options: list = None) -> list:
    pcap_file = get_pcap_file_from_dir(pcap_file_dir)
    pcap_file_path = pcap_file_dir + "/" + pcap_file
    pcap_data = filter_pcap_data(pcap_file_path, result_dir, fields_list, filters_list, options)
    with open(pcap_data) as r_file:
        pcap_result_file = r_file.read()
        filtered_data = pcap_result_file.strip().replace('\n', ',').split(',')
        logger.console(f"\n\nFiltered PCAP data: {filtered_data}")
        return filtered_data


def _load_moler_configuration(log_path) -> NoReturn:
    config = {
        'DEVICES': {
            'MyMachine': {
                'DEVICE_CLASS': 'moler.device.unixlocal.UnixLocal'
            }
        },
        'LOGGER': {
            'DATE_FORMAT': '%d %H:%M:%S',
            'DEBUG_LEVEL': 'INFO',
            'MODE': 'write',
            'PATH': log_path,
            'RAW_LOG': False,
        }
    }
    load_config(config=config)


def get_current_time() -> str:
    return datetime.now().strftime("%Y-%m-%d_%H:%M:%S:%f")


def compare_tput(before_tput: list, after_tput: list) -> NoReturn:
    for before, after in zip(before_tput, after_tput):
        if before > after:
            dif_pct = ((before - after) * 100) / before
            if dif_pct > 5:
                raise ValueError(f"Tptut before parameter changed is larger than after: {before} > {after}")


def prepare_parameters_delta(distname: str,
                             parameter: str,
                             value: str,
                             operation="update",
                             delta=None,
                             json_out=False) -> list:
    if not delta:
        delta = []
    delta.append(
        {
            "distName": distname,
            "operation": operation,
            "parameters": [
                {
                    "parameterName": parameter,
                    "value": value,
                    "operation": operation
                }
            ]
        }
    )
    if json_out:
        delta = json.dumps(delta)
    return delta


def setup_attenuation_for_nr_and_lte_cells(port, value):
    att = rf_attenuator()
    radio_rack = att.setup_attenuator(vendor='RadioRack',
                                      ip_addr='10.253.176.134',
                                      port=50000,
                                      attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11,
                                                                12, 13, 14, 15, 16])
    radio_rack.set_port_attenuation(port=port, attenuation_value=value)
