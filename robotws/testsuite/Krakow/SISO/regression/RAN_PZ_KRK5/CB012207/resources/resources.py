import ast
import json
import os
import random
import time
import zipfile
from taf.hw.pdu import pdu
from taf.rfrl.utilities.logger.custom_logger import log_info_to_console
from taf.rfrl.utilities.test_config import get_log_path
from testsuite.Krakow.resources.RAN_VRF_KRK5.python.bts_operations.bts_additional_logs.bts_additional_logs \
    import BtsAdditionalLogs


def get_folders_with_biplogs(case, logs_dir):
    result = dict()
    all_entries = os.listdir(logs_dir)
    folders = [entry for entry in all_entries if os.path.isdir('{}/{}'.format(logs_dir, entry))]
    biplog_folders = [x for x in folders if x.startswith(case)]
    biplog_folders = sorted(biplog_folders, key=lambda s: os.path.getmtime(os.path.join(logs_dir, s)))
    result['DL_tput'] = biplog_folders[-2]
    result['UL_tput'] = biplog_folders[-1]
    log_info_to_console('Folder with biplogs for case `{}` with DL tput: {}'.format(case, result['DL_tput']))
    log_info_to_console('Folder with biplogs for case `{}` with UL tput: {}'.format(case, result['UL_tput']))
    return result


def verify_bip_logs(logs_dir, bip_messages):
    logs_dir = '{}/l1l2_bip'.format(logs_dir)
    log_info_to_console('Verifying BIPs from {}'.format(logs_dir), log_hierarchy=2)
    files = [f for f in os.listdir(logs_dir) if os.path.isfile('{}/{}'.format(logs_dir, f))]
    for file in files:
        log_info_to_console('File {}'.format(file), log_hierarchy=2)
        if file.endswith(".pcap"):
            pcap_file_path = '{}/{}'.format(logs_dir, file)
            log_info_to_console('PCAP file {}'.format(pcap_file_path), log_hierarchy=2)
            divide_cmd = 'tcpdump -r {} -w {}/partial_{} -C 10'.format(pcap_file_path, logs_dir, file)
            log_info_to_console('Divide cmd {}'.format(divide_cmd), log_hierarchy=2)
            os.system(divide_cmd)
            new_files = [f for f in os.listdir(logs_dir) if f.startswith('partial_{}'.format(file))]
            random_pcap = random.choice(new_files)
            log_info_to_console('Random pcap file: {}'.format(random_pcap), log_hierarchy=3)
            new_files.remove(random_pcap)
            for new_file in new_files:
                os.remove('{}/{}'.format(logs_dir, new_file))
            random_pcap_file_path = '{}/{}'.format(logs_dir, random_pcap)
            log_info_to_console('Random pcap file path {}'.format(random_pcap_file_path), log_hierarchy=3)
            addit_logs = BtsAdditionalLogs()
            addit_logs.verify_messages_in_pcap(pcap_file=random_pcap_file_path, messages=bip_messages, log_type='bip')
    chown_cmd = 'sudo chown -R ute:ute {}'.format(logs_dir)
    os.system(chown_cmd)


def verify_emil_logs_from_xn_handover(dcap_host, emil_filter, zip_with_emil_log):
    gm_file = extract_5gm_file(emil_file_path=zip_with_emil_log)
    add_logs = BtsAdditionalLogs()
    decoded_content = add_logs.decode_emil_logs_with_dcap(emil_log=gm_file, emil_filter=emil_filter,
                                                          dcap_host=dcap_host)
    verify_messages_in_json(decoded_content=decoded_content, nr_of_messages=4)
    dcap_save_to_json(decoded_content=decoded_content, filename='{}/Emil/decoded_emil.json'.format(get_log_path()))


def dcap_save_to_json(decoded_content, filename):
    if isinstance(decoded_content, str):
        # evaluate str as dict to save properly as json
        decoded_content = ast.literal_eval(decoded_content)
    try:
        with open(filename, 'w', encoding='utf-8') as json_file:
            json.dump(decoded_content, json_file, indent=4)
        log_info_to_console('Emil data has been saved to {} successfully'.format(filename))
    except Exception as e:
        raise Exception('Error during saving data to {}: {}'.format(filename, e))
    return filename


def extract_5gm_file(emil_file_path):
    target_dir = '{}/Emil'.format(get_log_path())
    with zipfile.ZipFile(emil_file_path, 'r') as zip_ref:
        for file_name in zip_ref.namelist():
            if file_name.endswith('5gm'):
                zip_ref.extract(file_name, target_dir)
                return '{}/{}'.format(target_dir, file_name)
    return None


def verify_messages_in_json(decoded_content, nr_of_messages):
    error = None
    if decoded_content['emil_data']['rows']:
        nr_of_found_messages = 0
        for message in decoded_content['emil_data']['rows']:
            if "NRRRCMeasurementReport" in message["User_data"]:
                nr_of_found_messages += 1
        if nr_of_found_messages == nr_of_messages:
            log_info_to_console("Correct number of measurementReports: {}".format(nr_of_found_messages))
        else:
            error = "Wrong number of measurementReports: {}!={}".format(nr_of_found_messages, nr_of_messages)
    else:
        error = "No messages in emil log"
    if error:
        raise Exception(error)


def ue_power_reset():
    ue_pdu_alias = 'ue_pdu_alias'
    pdu_host = '10.255.10.158'

    ue_pdu = pdu()
    ue_pdu.setup_pdu(host=pdu_host, model='ATEN', alias=ue_pdu_alias)
    ue_pdu.power_off(port=1, pdu_device=ue_pdu_alias)
    log_info_to_console("UE is power off!!!", log_hierarchy=3)
    time.sleep(15)
    ue_pdu.power_on(port=1, pdu_device=ue_pdu_alias)
    log_info_to_console("UE is power on!!!", log_hierarchy=3)
    time.sleep(5)
