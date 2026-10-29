import datetime
import json
import time
import os
import pytz
from contextlib import contextmanager
from robot.libraries.BuiltIn import BuiltIn
from robot.api import logger
from taf.nms.netact.facade import Netact
from taf.transport.ssh.ssh_keywords import SSHManager
from taf.transport.ssh import ssh
from taf.analyzer.pdml import PdmlReader, pdml
from bip_logs_parser import parse_bip_logs
from convert_pcap_to_one_csv_FR2 import convert_gnblog_to_csv
from ue_methodsFR2 import CallResources


tl = BuiltIn().get_variable_value("${tl}")
work_dir = BuiltIn().get_variable_value("${work_directory}")


def find_pm_counters_by_time_stamp(time_stamp, pm_counters_dir, cell_list):
    import pandas as pd
    out_put_dir = {}
    for cell_id in cell_list:
        pm_counters = get_pm_counters_for_cell(time_stamp, pm_counters_dir, "NRCELL-"+str(cell_id))
        out_put_dir.update({"NRCELL-"+str(cell_id): pm_counters})
    df = pd.DataFrame.from_dict({(i, j): out_put_dir[i][j]
                                for i in out_put_dir.keys()
                                for j in out_put_dir[i].keys()},
                                orient='index')
    mod_time = str(time_stamp)
    mod_time = str.replace(mod_time, ':', '-')
    mod_time = str.replace(mod_time, ' ', '_')
    file_name = work_dir + 'pm_counters_' + mod_time + '.xlsx'
    df.to_excel(file_name)
    return file_name


def get_pm_counters_for_cell(time_stamp, pm_counters_dir, cell_id):
    date_format = datetime.datetime.strptime(time_stamp, "%Y-%m-%d_%H:%M:%S")
    unix_time = int(datetime.datetime.timestamp(date_format))
    mrbts_id = BuiltIn().get_variable_value("${mrbts_id}")
    pm_counters_id_dir = pm_counters_dir['BTS']['MRBTS-'+mrbts_id]['NRBTS-'+mrbts_id][cell_id]['NRRIP']
    keys = pm_counters_id_dir.keys()
    key_list = list(keys)
    w = sorted(key_list)
    selected_values_dir = {}

    for nrrip_id in w:
        selected = pm_counters_dir['BTS']['MRBTS-'+mrbts_id]['NRBTS-'+mrbts_id][cell_id]['NRRIP'][nrrip_id]
        for k, v in selected.items():
            if k == str(unix_time):
                selected_values_dir.update({nrrip_id: {time_stamp: v}})
    return selected_values_dir


def generate_names_of_counters():
    prefix = "M55360C"
    first_counter_id_set_1 = 0
    last_counter_id_set_1 = 65
    first_counter_id_set_2 = 1000
    last_counter_id_set_2 = 1065
    counter_id_list = []

    counter_id_set_1 = str(first_counter_id_set_1).zfill(5)
    counter_id_list.append(prefix + counter_id_set_1)

    for counter in range(first_counter_id_set_1, last_counter_id_set_1):
        counter_id_set_1 = str(int(counter_id_set_1) + 1).zfill(len(counter_id_set_1))
        counter_id_list.append(prefix + counter_id_set_1)

    counter_id_set_2 = str(first_counter_id_set_2).zfill(5)
    counter_id_list.append(prefix + counter_id_set_2)

    for counter in range(first_counter_id_set_2, last_counter_id_set_2):
        counter_id_set_2 = str(int(counter_id_set_2) + 1).zfill(len(counter_id_set_2))
        counter_id_list.append(prefix + counter_id_set_2)

    counter_id_string = ",".join(counter_id_list)

    return counter_id_string


def verify_netact_pm_counters(netact_output, cell_list):
    logger.console("checking counters for " + str(len(cell_list)) + " cell(s)")
    if check_proper_zero_values(netact_output, cell_list):
        logger.info('PASS')
        return True
    else:
        logger.error('FAIL! Saving Output to netact_test.json')
        with open('netact_test.json', 'w') as file:
            json.dump(netact_output, file, indent=4)
        return False


def get_netact_pm_counters_nrulrip(measurement_hours):
    technology = "NRBTS-Nokia AirScale BTS 5G"
    measurement = "NR UL Received Interference Power"
    netact_counters = "ALL"
    filter_by = "MRBTS"
    mo_names = "PLMN-PLMN/MRBTS-77012"
    object_aggregation = "NRCEL"
    time_aggregation = "RAW"
    time_filter = "absolute"
    now_time = datetime.datetime.now(pytz.timezone('Europe/Warsaw'))
    end_time = now_time.replace(minute=(now_time.minute//5)*5, second=0, microsecond=0) - datetime.timedelta(minutes=10)
    start_time = end_time - datetime.timedelta(hours=measurement_hours) + datetime.timedelta(minutes=20)
    logger.console("Getting counters from " + str(start_time) + " to " + str(end_time))
    netact_name = "netact"
    web_url = BuiltIn().get_variable_value("${NETACT_NAME}")
    username = BuiltIn().get_variable_value("${USERNAME}")
    password = BuiltIn().get_variable_value("${PASSWORD}")
    netact = Netact()
    netact.add_web_url(web_url, username, password)

    netact_counters = netact.get_pm_counters(technology=technology,
                                             measurement=measurement,
                                             counters=netact_counters,
                                             filter_by=filter_by,
                                             mo_names=mo_names,
                                             object_aggregation=object_aggregation,
                                             time_aggregation=time_aggregation,
                                             time_filter=time_filter,
                                             alias=netact_name,
                                             start_time=start_time.replace(tzinfo=None),
                                             end_time=end_time.replace(tzinfo=None))
    if len(netact_counters) == 0:
        logger.error("Failed to download PM counters from NetAct, check connection and manually if counters exist")
    else:
        logger.console("Received " + str(len(netact_counters)) + " measurements")
    print(netact.clean_all())
    return netact_counters


def check_proper_zero_values(input_json, cell_list):
    import pandas as pd
    df = pd.DataFrame(input_json)
    cell_column = df.filter(regex='nrcel_name')
    avg_columns = df.filter(regex='AVG')
    max_columns = df.filter(regex='MAX')
    for cell in cell_list:
        if not cell_column.eq(str(cell)).any(axis=None):
            logger.error("Cell " + str(cell) + " is not present in PM counters!")
            return False
    if len(cell_column['nrcel_name'].value_counts().unique()) == 1:
        logger.console("All cells have the same amount of counters")
    else:
        logger.error("Not every cell has the same amount of counters")
        return False
    if (avg_columns.isnull()).all(axis=None):
        logger.console("All AVG counters are null")
    else:
        logger.error("AVG counters are not null!")
        return False
    if (max_columns.isnull()).all(axis=None):
        logger.console("All MAX counters are null")
    else:
        logger.error("MAX counters are not null!")
        return False
    return True


def run_bip_log_collecting(gnb_logger, connection, duration):
    bip_log_cmd = "./gnb_logs_2.31/gnb_logs_2.31/gnb_logs.exe " \
                  + tl.gnbs[0].cu.backhaul_site_oam_ip.v4.split("/")[0] \
                  + " -b " \
                  + duration
    logger.console("[{}] Collecting BIP log...".format(datetime.datetime.now()))
    gnb_logger.execute(command=bip_log_cmd, connection=connection, timeout="900s")
    return "[{}] Bip log collected".format(datetime.datetime.now())


def schedule_delay(delay):
    rerun = True
    while rerun:
        current_time = datetime.datetime.now().strftime("%M")
        rest_minute = 5 - int(current_time) % 5 - float(delay)

        current_time = datetime.datetime.now().strftime("%S")
        rest_seconds = 60 - int(current_time)

        scheduled_delay = rest_minute * 60 + rest_seconds

        if rest_minute < 0:
            rerun = True
            time.sleep(abs(scheduled_delay))
        else:
            rerun = False
            time.sleep(scheduled_delay)

    slot_start = datetime.datetime.now() + datetime.timedelta(seconds=int(150))
    return slot_start.strftime("%Y-%m-%d_%H:%M:%S")


def open_gnb_logger_connection(pc_alias):
    gnb_logger = SSHManager()
    hostname = BuiltIn().get_variable_value("${ue_pc_ip}")
    username = BuiltIn().get_variable_value("${ue_pc_user}")
    password = BuiltIn().get_variable_value("${ue_pc_password}")
    connection = gnb_logger.connect_to(hostname=hostname,
                                       username=username,
                                       password=password,
                                       alias=pc_alias,
                                       timeout=120.0)
    return gnb_logger, connection


def start_generating_max_tput(tput_direction, ue_alias, tput_duration):
    ue_call = CallResources()
    logger.console("\n[{}] Preparing UE to tput...".format(datetime.datetime.now()))
    if ue_alias == "UE_1":
        ue_call.prepare_ue_for_call(BuiltIn().get_variable_value("${real_ue_id}"),
                                    reboot_ue=False,
                                    timeout_reboot_ue=100,
                                    alias=ue_alias)
    else:
        ue_call.prepare_ue_for_call(BuiltIn().get_variable_value("${interference_ue_id}"),
                                    reboot_ue=False,
                                    timeout_reboot_ue=100,
                                    alias=ue_alias)
    ue_call.attach_ue(ue_alias)
    logger.console("\n[{}] Generating {} tput...".format(datetime.datetime.now(), tput_direction))
    ue_call.start_generating_max_tput(ue_alias, tput_direction, tput_duration)
    return ue_call


def stop_generating_tput(ue_call, ue_alias):
    ue_call.detach_ue(ue_alias)
    logger.console("[{}] UE Detached...".format(datetime.datetime.now()))


def close_gnb_logger_connection(gnb_logger, connection):
    gnb_logger.disconnect(connection=connection)


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


def start_pcap_logs(interface="any", pcap_file=work_dir+"input.pcap"):
    with enb_connection() as connection:
        connection.send_command("rm -rf {}".format(pcap_file))
        connection.send_command("tcpdump -i {} -w {} -n".format(interface, pcap_file))
        status = connection.execute("ps -ef | grep tcpdump | grep -v grep | grep {}".format(interface))
    logger.console(status)


def stop_pcap_logs():
    with enb_connection() as connection:
        connection.execute("pkill tcpdump")


def get_pcap_logs(remote_pcap_file=work_dir+"input.pcap", file_name='test', dir_path=work_dir):
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
        logger.console('RRCReconfiguration captured')
    except AssertionError as e:
        logger.debug(e)
        raise AssertionError('RRCReconfiguration not captured {}'.format(message_sequence))


def extract_bwp_instance(pcap_file_path):
    out_path = pcap_file_path[:-5]+"_extracted.json"
    cmd = '/usr/bin/tshark -r {} -Y "nr-rrc.pucch_Config == 1" -T json > {}'.format(pcap_file_path, out_path)
    os.system(cmd)


def convert_gnb_logs_to_excel(gnb_logs_path, slots_per_frame, threads=4):
    converted_dir = convert_gnblog_to_csv(path=gnb_logs_path, threads=threads, slots_per_frame=slots_per_frame)
    return converted_dir


def convert_bip_to_final_csv(path_to_dir,
                             puch_mode,
                             start_time,
                             end_time,
                             transmission_technology,
                             msg1FrequencyStart,
                             rach_avg,
                             result_dir):
    out_path = parse_bip_logs(path_to_dir,
                              puch_mode,
                              start_time,
                              end_time,
                              transmission_technology,
                              msg1FrequencyStart,
                              rach_avg,
                              result_dir)
    return out_path


def check_if_rach_should_be_counted(actNrUlRipMeasurement_value):
    if "WithPRACH" in actNrUlRipMeasurement_value:
        return True
    else:
        return False


def compare_bip_log_and_pm_counters(bip_log_path, pm_counters_path, threshold, counters_len):
    import pandas as pd
    pm_pd = pd.read_excel(pm_counters_path)
    bip_pd = pd.read_excel(bip_log_path)
    pm_values_orig = pm_pd.iloc[:, 2].tolist()
    pm_counters = pm_pd.iloc[:, 1].tolist()
    expanded_pm_values = []
    original_counter = 0

    for i in range(0, counters_len):
        counter_value = int(pm_counters[original_counter][-3:])
        if i == counter_value:
            expanded_pm_values.append(pm_values_orig[original_counter])
            original_counter += 1
        else:
            expanded_pm_values.append(0.0)
    expanded_pm_values.extend(pm_values_orig[original_counter:])
    pm_values = expanded_pm_values
    bip_values = bip_pd.iloc[:, 1].tolist()
    avg_cumulative_error_abs = 0
    avg_cumulative_error = 0
    avg_max_error_abs = 0
    avg_exceed_threshold_count = 0
    avg_mean_error = 0
    max_cumulative_error_abs = 0
    max_cumulative_error = 0
    max_max_error_abs = 0
    max_exceed_threshold_count = 0
    max_mean_error = 0
    check_pm_counter_min_value(pm_values_orig, bip_values)

    for avg_index, avg_value in enumerate(pm_values[0:counters_len]):
        avg_cumulative_error += pm_values[avg_index] - bip_values[avg_index]
        avg_cumulative_error_abs += abs(pm_values[avg_index] - bip_values[avg_index])
        if avg_max_error_abs < abs(pm_values[avg_index] - bip_values[avg_index]):
            avg_max_error_abs = abs(pm_values[avg_index] - bip_values[avg_index])
        if abs(pm_values[avg_index] - bip_values[avg_index]) > threshold:
            avg_exceed_threshold_count += 1
            print("PRB nr " + str(avg_index) + " exceeds avg threshold!")
        avg_mean_error = avg_cumulative_error_abs / counters_len

    for max_index, max_value in enumerate(pm_values[counters_len:(2 * counters_len)]):
        max_cumulative_error += pm_values[counters_len + max_index] - bip_values[counters_len + max_index]
        max_cumulative_error_abs += abs(pm_values[counters_len + max_index] - bip_values[counters_len + max_index])
        if max_max_error_abs < abs(pm_values[counters_len + max_index] - bip_values[counters_len + max_index]):
            max_max_error_abs = abs(pm_values[counters_len + max_index] - bip_values[counters_len + max_index])
        if abs(pm_values[counters_len + max_index] - bip_values[counters_len + max_index]) > threshold:
            max_exceed_threshold_count += 1
            print("PRB nr " + str(max_index) + " exceeds max threshold!")
        max_mean_error = max_cumulative_error_abs / counters_len

    print("avg_cumulative_error_abs:", avg_cumulative_error_abs)
    print("avg_cumulative_error:", avg_cumulative_error)
    print("avg_max_error_abs:", avg_max_error_abs)
    print("avg_exceed_threshold_count:", avg_exceed_threshold_count)
    print("avg_mean_error:", avg_mean_error)
    print("max_cumulative_error_abs:", max_cumulative_error_abs)
    print("max_cumulative_error:", max_cumulative_error)
    print("max_max_error_abs:", max_max_error_abs)
    print("max_exceed_threshold_count:", max_exceed_threshold_count)
    print("max_mean_error:", max_mean_error)

    return avg_exceed_threshold_count, max_exceed_threshold_count


def check_pm_counter_min_value(pm_values_orig, bip_values):
    MIN_COUNTER_VAL = -112.4
    orig_wrong_val = [counter for counter in pm_values_orig if counter < MIN_COUNTER_VAL]
    bip_wrong_val = [counter for counter in bip_values if counter < MIN_COUNTER_VAL]
    if orig_wrong_val:
        raise Exception(f"Minimum value in orig list exceeded: {orig_wrong_val}")
    elif bip_wrong_val:
        raise Exception(f"Minimum value in bip list exceeded: {bip_wrong_val}")


def find_pcap_file(path_to_work_dir):
    return os.path.join(path_to_work_dir, 'BipCollectorAdmin_GNB0_DU0')
