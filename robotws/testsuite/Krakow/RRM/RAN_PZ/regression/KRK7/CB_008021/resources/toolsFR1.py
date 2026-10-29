from taf.sbts.oam.coam.admin.interface import admin
from robot.api import logger
from taf.rfrl.ue.custom_ues import AndroidUe
from robot.libraries.BuiltIn import BuiltIn
from taf.rfrl.ue.ue import Ue
from taf.transport.ssh.connection import connect
from generator_methods import SignalGenerator
from taf.transport.ssh.ssh_keywords import SSHManager
from collections import OrderedDict
from contextlib import contextmanager
from taf.transport.ssh import ssh
from taf.analyzer.pdml import PdmlReader, pdml
from convert_pcap_to_one_csv import convert_gnblog_to_csv

import datetime
import time
import re
import os


tl = BuiltIn().get_variable_value("${tl}")
work_dir = BuiltIn().get_variable_value("${work_directory}")


def save_dict_to_excel(dict_to_save, out_dir_path, file_name):
    import pandas as pd
    if not os.path.isdir(out_dir_path):
        os.makedirs(out_dir_path)
    df = pd.DataFrame.from_dict({(i, j): dict_to_save[i][j]
                                for i in dict_to_save.keys()
                                for j in dict_to_save[i].keys()},
                                orient='index')
    df.to_excel(f"{out_dir_path}/{file_name}.xlsx")


def find_pm_counters_by_time_stamp(time_stamp, pm_counters_dir, cell_list, out_dir_path, counters_ids):
    out_put_dict = {}
    for cell_id in cell_list:
        cell_pm_counters = get_pm_counters_for_cell(time_stamp, pm_counters_dir, "NRCELL-"+str(cell_id))
        cell_pm_counters = fill_in_missing_counters(cell_pm_counters, counters_ids, time_stamp)
        out_put_dict.update({"NRCELL-"+str(cell_id): cell_pm_counters})
    save_dict_to_excel(out_put_dict, out_dir_path, f'WEM_pm_counters_{time_stamp}')
    return out_put_dict


def get_pm_counters_for_cell(time_stamp, pm_counters_dir, cell_id):
    date_format = datetime.datetime.strptime(time_stamp, "%Y-%m-%d %H:%M:%S")
    unix_time = int(datetime.datetime.timestamp(date_format))
    pm_counters_id_dict = pm_counters_dir['BTS']['CELLS'][cell_id]['NRRIP']
    keys = pm_counters_id_dict.keys()
    key_list = list(keys)
    key_list = sorted(key_list)
    selected_values_dir = {}
    for id in key_list:
        zmienna = pm_counters_dir['BTS']['CELLS'][cell_id]['NRRIP'][id]
        for k, v in zmienna.items():
            if k == str(unix_time):
                selected_values_dir.update({id: {time_stamp: v}})
    return selected_values_dir


def fill_in_missing_counters(counters_dict, counters_ids, time_stamp):
    counters_ids = counters_ids.split(',')
    for id in counters_ids:
        counters_dict.setdefault(id, {time_stamp: 0.0})
    counters_dict = OrderedDict(sorted(counters_dict.items()))
    return counters_dict


def generate_names_of_counters():
    prefix = "M55360C"
    first_counter_id_set_1 = 0
    first_counter_id_set_2 = 1000
    last_counter_id_set_1 = 272
    last_counter_id_set_2 = 1272
    counter_id_list = []

    counter_id_set_1 = str(first_counter_id_set_1).zfill(5)
    counter_id_list.append(prefix + counter_id_set_1)

    for id in range(first_counter_id_set_1, last_counter_id_set_1):
        counter_id_set_1 = str(int(counter_id_set_1) + 1).zfill(len(counter_id_set_1))
        counter_id_list.append(prefix + counter_id_set_1)

    counter_id_set_2 = str(first_counter_id_set_2).zfill(5)
    counter_id_list.append(prefix + counter_id_set_2)

    for id in range(first_counter_id_set_2, last_counter_id_set_2):
        counter_id_set_2 = str(int(counter_id_set_2) + 1).zfill(len(counter_id_set_2))
        counter_id_list.append(prefix + counter_id_set_2)

    counter_id_string = ",".join(counter_id_list)

    return counter_id_string


def set_generator(generator_ip, frequency_val, amplitude_val, bandwidth_val):
    generator = SignalGenerator()
    generator.connect_to_generator(generator_ip, 5023)
    generator.execute_cmd(":FREQuency " + frequency_val)
    generator.execute_query(":FREQuency?")
    generator.execute_cmd(":AMPLitude " + amplitude_val)
    generator.execute_query(":AMPLitude?")
    generator.execute_cmd(":RADio:AWGN:RT:BWIDth " + bandwidth_val)
    generator.execute_query(":RADio:AWGN:RT:BWIDth?")
    generator.execute_cmd("RADio:AWGN:RT:STATe ON")
    generator.close_connections()


def run_generator(generator_ip):
    generator = SignalGenerator()
    generator.connect_to_generator(generator_ip, 5023)
    generator.execute_cmd(":OUTPut:STATe ON")
    generator.close_connections()
    logger.console("[{}] Generator running".format(datetime.datetime.now()))


def turn_off_generator(generator_ip):
    generator = SignalGenerator()
    generator.connect_to_generator(generator_ip, 5023)
    generator.execute_cmd(":OUTPut:STATe OFF")
    logger.console("[{}] Generator OFF".format(datetime.datetime.now()))
    generator.close_connections()


def open_gnb_loger_connection(pc_alias):
    gnbLoger = SSHManager()
    connection = gnbLoger.connect_to(hostname=tl.ues[0].ssh_connection_details.addr,
                                     username=tl.ues[0].ssh_connection_details.username,
                                     password=tl.ues[0].ssh_connection_details.password,
                                     alias=pc_alias,
                                     timeout=120.0)
    return gnbLoger, connection


def run_bip_log_collecting(gnbLoger, connection, duration):
    bip_log_cmd = "./gnb_logs_2.31/gnb_logs_2.31/gnb_logs.exe " + tl.gnbs[0].v4 + " -b " + duration
    logger.console("[{}] Collecting BIP log...".format(datetime.datetime.now()))
    cmd_output = gnbLoger.execute(command=bip_log_cmd, connection=connection, timeout="900s")
    return "[{}] Bip log collected".format(datetime.datetime.now())


def run_bip_log_collecting_end_dont_wait_for_outpu(gnbLoger, connection, duration):
    bip_log_cmd = "./gnb_logs_2.31/gnb_logs_2.31/gnb_logs.exe " + tl.gnbs[0].v4 + " -b " + duration
    logger.console("[{}] Collecting BIP log...".format(datetime.datetime.now()))
    gnbLoger.send_command(command=bip_log_cmd, timeout="900s", get_pty=False, connection=connection)


def download_bip_log(gnbLoger, connection, local_path):
    find_BIP_log_cmd = "find ./ -type f -iname \"gNB_*_BIP.zip\" -exec basename {} \\;"
    BIP_log_file = gnbLoger.execute(command=find_BIP_log_cmd, connection=connection, timeout="15s")
    BIP_log_file = BIP_log_file.split()
    BIP_log_file = " ".join(BIP_log_file)
    logger.console(f"BIP Log: {BIP_log_file}")
    if re.search("^gNB_.+_BIP.zip$", BIP_log_file):
        if not os.path.isdir(local_path):
            os.makedirs(local_path)
        gnbLoger.download_file(remote_path=f"./{BIP_log_file}",
                               local_path=f"{local_path}/{BIP_log_file}",
                               connection=connection)
        gnbLoger.execute(command=f"rm ./{BIP_log_file}", connection=connection, timeout="15s")
        return BIP_log_file
    else:
        raise NameError


def close_gnb_loger_connection(gnbLoger, connection):
    gnbLoger.disconnect(connection=connection)


def schedule_delay(delay):
    delay = int(delay)
    current_time = datetime.datetime.now()
    rest_minute = 5 - current_time.minute % 5 - 1
    rest_seconds = 60 - current_time.second
    scheduled_delay = (rest_minute * 60 + rest_seconds) - delay
    if scheduled_delay < 0:
        time.sleep((rest_minute * 60 + rest_seconds) + (5 * 60 - delay))
    else:
        time.sleep(scheduled_delay)
    interval_start_time = datetime.datetime.now() + datetime.timedelta(seconds=delay)
    interval_start_time = interval_start_time.replace(second=0)
    return interval_start_time.strftime("%Y-%m-%d %H:%M:%S")


def get_gnb_logs_zip_name(gnb_logs_output):
    gnb_logs_zip_name = re.findall(r'BTS-.*_BIP', gnb_logs_output, re.MULTILINE)
    return gnb_logs_zip_name[0]


def compare_counters_and_bip_logs_result(counters_dict,
                                         bip_logs_dict,
                                         out_dir_path,
                                         file_name,
                                         cell_id,
                                         seconds_to_subtract):
    import pandas as pd
    counters_id = generate_names_of_counters()
    counters_id = counters_id.split(',')
    counters_list = []
    bip_logs_list = []
    div_list = []
    for k, v in counters_dict[f'NRCELL-{cell_id}'].items():
        counters_list.append(list(v.values())[0])
    for k, v in bip_logs_dict['avg'].items():
        bip_logs_list.append(v['val'])
    for k, v in bip_logs_dict['max'].items():
        bip_logs_list.append(v['val'])
    for i in range(len(bip_logs_list)):
        div_list.append(abs(counters_list[i]-bip_logs_list[i]))
    df = pd.DataFrame(list(zip(counters_id, div_list)), columns=['id', 'div'])
    df.to_csv(f"{out_dir_path}/{file_name}_div_output_cell{cell_id}_{seconds_to_subtract}.csv", index=False)
    return all(i <= 0.056 or i >= 70 for i in div_list)


def check_if_there_was_no_noise(counters_dict):
    for k, v in counters_dict['NRCELL-1'].items():
        if list(v.values())[0] != 0:
            return False
    return True


def check_if_rach_should_be_counted(actNrUlRipMeasurement_value):
    if "WithPRACH" in actNrUlRipMeasurement_value:
        return True
    elif "WithoutPRACH" in actNrUlRipMeasurement_value:
        return False
    else:
        return True


@contextmanager
def enb_connection():
    enb_connection = ssh()
    enb_connection.connect_to(
        hostname=tl.enbs[0].oam_ip.v4,
        username=tl.gnbs[0].cu.oam_ssh_connection_details.username,
        password=tl.gnbs[0].cu.oam_ssh_connection_details.password,
    )
    try:
        yield enb_connection
    finally:
        pass


def start_pcap_logs(interface="any", pcap_file="/tmp/input.pcap"):
    with enb_connection() as connection:
        connection.send_command("rm -rf {}".format(pcap_file))
        connection.send_command("tcpdump -i {} -w {} -n".format(interface, pcap_file))
        status = connection.execute("ps -ef | grep tcpdump | grep -v grep | grep {}".format(interface))
    logger.console(status)


def stop_pcap_logs():
    with enb_connection() as connection:
        connection.execute("pkill tcpdump")


def get_pcap_logs(remote_pcap_file="/tmp/input.pcap", file_name='test', dir_path=work_dir):
    pcap_file_name = '{}_{}.pcap'.format(file_name, datetime.datetime.now().strftime("%d%m%Y_%H%M%S"))
    full_pcap_path = os.path.join(dir_path, pcap_file_name)
    with enb_connection() as connection:
        connection.download_file(remote_path=remote_pcap_file, local_path=full_pcap_path)
        connection.execute("rm -rf {}".format(remote_pcap_file))
    return full_pcap_path


def __check_for_empty_file(file_path):
    if os.stat(file_path).st_size == 0:
        raise IOError("File is empty")


def verify_RRCReconfiguration_complete(pcap_file_path, file_name='input', dir_path=work_dir):
    pdml_file_name = '{}_{}.pdml'.format(file_name, datetime.datetime.now().strftime("%d%m%Y_%H%M%S"))
    full_pdml_path = os.path.join(dir_path, pdml_file_name)
    cmd = "/usr/bin/tshark -r {} -Y x2ap -T pdml > {}".format(pcap_file_path, full_pdml_path)
    os.system(cmd)
    __check_for_empty_file(full_pdml_path)
    field_name_list = ["nr-rrc.measurementReport_element", "x2ap.SgNBChangeRequired_element",
                       "nr-rrc.RRCReconfiguration_element", "x2ap.SgNBAdditionRequest_element",
                       "nr-rrc.RRCReconfiguration_element", "x2ap.SgNBAdditionRequestAcknowledge_element",
                       "nr-rrc.RRCReconfiguration_element", "x2ap.SgNBChangeConfirm_element",
                       "x2ap.SgNBReconfigurationComplete", "nr-rrc.RRCReconfigurationComplete_element"]
    message_sequence = "SgNBAdditionRequest.*" \
                       "SgNBAdditionRequestAcknowledge.*" \
                       "RRCReconfiguration.*" \
                       "SgNBReconfigurationComplete.*" \
                       "RRCReconfigurationComplete"
    try:
        pdml().check_msc(full_pdml_path, field_name_list, message_sequence)
        logger.console("RRCReconfiguration captured")
    except AssertionError as e:
        logger.debug(e)
        raise AssertionError(f"RRCReconfiguration not captured {message_sequence}")


def extract_bwp_instance(pcap_file_path):
    out_path = pcap_file_path[:-5]+"_extracted.json"
    cmd = '/usr/bin/tshark -r {} -Y "nr-rrc.pucch_Config == 1" -T json > {}'.format(pcap_file_path, out_path)
    os.system(cmd)


def convert_gnb_logs_to_excel(gnb_logs_path, transmission_technology, threads=2):
    if transmission_technology == 'FDD':
        converted_dir = convert_gnblog_to_csv(path=gnb_logs_path, threads=threads, slots_per_frame=10)
    elif transmission_technology == 'TDD':
        converted_dir = convert_gnblog_to_csv(path=gnb_logs_path, threads=threads, slots_per_frame=20)
    return converted_dir


def split_csv_by_subcellid(path_to_dir):
    import pandas as pd
    log_files_name_list = os.listdir(path_to_dir)
    log_files_name_list = [name for name in log_files_name_list if "_merged_asfn" in name]
    log_files_name_list = sorted(log_files_name_list, reverse=True)
    subcell0id, subcell1id = None, None
    for file_name in log_files_name_list:
        csv_file = pd.read_csv(path_to_dir+'/'+file_name)
        csv_file.name = file_name
        if "_pusch" in file_name:
            subcell0id, subcell1id = identify_cell_id(csv_file)
        remove_rows_by_cell_id(csv_file, csv_file.name, 0, path_to_dir, subcell0id)
        remove_rows_by_cell_id(csv_file, csv_file.name, 1, path_to_dir, subcell1id)


def remove_rows_by_cell_id(csv_file, file_name, subcell, otuput_dir, cellid):
    csv_file = csv_file[csv_file["subcellid"] == subcell]
    logger.console(f"{otuput_dir}/cell{str(cellid)}_{file_name}")
    csv_file.to_csv(f"{otuput_dir}/cell{str(cellid)}_{file_name}", index=False)


def identify_cell_id(csv_file):
    subcell0id = None
    subcell1id = None
    first_row = csv_file.iloc[[1]]
    non_empty_columns = first_row.count(axis='columns').iloc[0]
    subcell_id = first_row["subcellid"].iloc[0]
    if (non_empty_columns == 117 and subcell_id == 0) or (non_empty_columns == 284 and subcell_id == 1):
        subcell0id = 86
        subcell1id = 186
        return subcell0id, subcell1id
    if (non_empty_columns == 117 and subcell_id == 1) or (non_empty_columns == 284 and subcell_id == 0):
        subcell0id = 186
        subcell1id = 86
        return subcell0id, subcell1id
