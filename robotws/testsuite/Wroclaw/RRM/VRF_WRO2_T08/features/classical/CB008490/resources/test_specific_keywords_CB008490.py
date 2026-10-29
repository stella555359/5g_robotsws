import csv
import os
import re
import shutil
import subprocess
import tarfile
import time
from functools import wraps
from pathlib import Path

import paramiko
from robot.libraries.BuiltIn import BuiltIn
from ta_attenuator import ta_attenuator
from taf.collectors.btslog import btslog
from taf.collectors.core import core
from taf.collectors.tcpdump import tcpdump
from taf.converters.pcaptopdml import pcaptopdml
from taf.rfrl.utilities.logger.custom_logger import log_info_to_console
from taf.sbts.oam.coam.admin import admin
from taf.ue import *

from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.DeltaStore import DeltaStore
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.dcap import dcap
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.cleaners import clear_admin_api_logs

_attenuator = ta_attenuator()
admin = admin()
_builtin = BuiltIn()
btslog = btslog()
core = core()
deltaStore = DeltaStore()
_ute_ue = ue()
pcaptopdml = pcaptopdml()
dcap_alias = 'test_logs_dcap'
bts_log_profile = ['scf', 'ipCapture', 'immediateSnapshot']
gnb_log_profile = ['condor5gSyslog', 'Tracer_5g']
log_kwargs = {'gnb_custom_profile': gnb_log_profile,
              'bts_custom_profile': bts_log_profile,
              'bip_mirroring_time': 0,
              'wait_for_activation': True}
ues_info = {
    "UE_1": {"name": "QUALCOMM", "adb_id": "QUALCOMM"},
}
xn_link_mn_alarms = [("7311", "MRBTS-50859/NRBTS-50859/NRADJGNB-6")]
xn_link_sn_alarms = [("7107", "MRBTS-50856/NRBTS-50856/NRCELL-561"),
                     ("7107", "MRBTS-50856/NRBTS-50856/NRCELL-562"),
                     ("7107", "MRBTS-50856/NRBTS-50856/NRCELL-563"),
                     ("7107", "MRBTS-50856/NRBTS-50856/NRCELL-564"),
                     ("7107", "MRBTS-50856/NRBTS-50856/NRCELL-565"),
                     ("7107", "MRBTS-50856/NRBTS-50856/NRCELL-566"),
                     ("7107", "MRBTS-50856/NRBTS-50856/NRCELL-567"),
                     ("7107", "MRBTS-50856/NRBTS-50856/NRCELL-568")]


def clear_admin_logs():
    clear_admin_api_logs()


def _is_dcap_controller_started():
    log_info_to_console("Checking DCAP Controller status")
    health_check_status = subprocess.run(["utf_lab-controller", "status"], stdout=subprocess.PIPE,
                                         stderr=subprocess.PIPE)
    if health_check_status.returncode == 0:
        return True


def start_dcap_controller():
    start_status = subprocess.run(["utf_lab-controller", "start"], stdout=subprocess.PIPE,
                                  stderr=subprocess.PIPE)
    if start_status.returncode == 0:
        dcap_checks_attempts = 3
        for _ in range(dcap_checks_attempts):
            if _is_dcap_controller_started():
                return
            time.sleep(10)
        raise Exception("Starting Dcap Failed!")


def setup_dcap_controller():
    if not _is_dcap_controller_started():
        start_dcap_controller()


def dcap_logger(func=None, mplane='10.45.173.38'):
    if func is None:
        return lambda func: dcap_logger(func, mplane)

    @wraps(func)
    def wrapper(*args, **kwargs):
        dcap.connect_to(host="localhost", port="9443", user=None, passwd=None)
        current_traces = dcap._api.get_all_trace_info(connection="dcap_collector")
        for trace in current_traces:
            if trace.get("status") == "running" and trace.get("status_details") == "":
                dcap.stop_trace(trace.get("id"))
        log_info_to_console('Starting DCAP logging...')
        trace_id = dcap.start_new_trace(mplane=mplane, log_profile=log_kwargs, force=True)
        BuiltIn().set_test_variable("${TRACE_ID}", trace_id)
        try:
            status = func(*args, **kwargs)
        finally:
            log_info_to_console('Collecting logs...')
            target_dir = get_path()
            dcap.stop_trace(trace=trace_id, timeout=1500)
            dcap.download_logs(trace=trace_id, target_dir=target_dir, timeout=1500)
        return status
    return wrapper


def create_syslog_collector(filename, vm_ip):
    executor = {"host": vm_ip,
                "user": "ute",
                "password": "Ut3pa5s#1be1"}
    btslog.create_btslog_collector(name="btslog", target_file_name=filename,
                                   executor=executor)
    btslog.setup_collectors("btslog")


def start_syslog():
    btslog.start_collectors("btslog")
    btslog.set_global_alias("btslog")


def create_tcpdump_collector():
    executor = {"host": "192.168.255.129",
                "user": "toor4nsn",
                "password": "oZPS0POrRieRtu"}
    tcpdump().create_tcpdump_collector(name="tcpdump", target_file_name="A2_redirect.pcap", options="sctp -i any -p",
                                       executor=executor)
    core.setup_collectors("tcpdump")


def start_tcp_dump():
    core.start_collectors("tcpdump")
    tcpdump().set_global_alias("tcpdump")


def stop_and_collect_tcp_dump(file_dir):
    core.stop_collectors("tcpdump")
    core.collect_collectors("tcpdump", target_dir=file_dir)
    core.teardown_collectors("tcpdump")


def tcp_collector(func):
    @wraps(func)
    def tcp_wrapper(*args, **kwargs):
        create_tcpdump_collector()
        start_tcp_dump()
        try:
            status = func(*args, **kwargs)
        finally:
            stop_and_collect_tcp_dump(get_path())
        return status
    return tcp_wrapper


def execute_graceful_shutdown(value, *args):
    log_info_to_console("Graceful shutdown...")
    try:
        admin.setup_admin(bts_host="10.42.47.9")
        cells_ids = [cell.get("id").get("configuration").split("/")[-1] for cell in admin.get_cells_info("nr")]
        for cell in args:
            if cell in cells_ids:
                admin.perform_parameter_recommissioning(f"MRBTS-50856/NRBTS-50856/{cell}",
                                                        parameter="administrativeState",
                                                        operation="update", value=value)
    finally:
        admin.teardown_admin()


def _file_reader(filename):
    with open(filename, 'r', encoding='cp1252') as f:
        for line in f:
            yield line


def attach(ue_name):
    _ute_ue.attach_ue(ue_name)
    log_info_to_console(f"{ue_name} attached!")


def get_path():
    return os.path.join(BuiltIn().get_variable_value("${OUTPUT_DIR}"), BuiltIn().get_variable_value("${TEST_NAME}"))


def convert_pdml():
    file_path = get_path()
    pcap_file = f'{BuiltIn().get_variable_value("${TESTNAME}")}.pcap'
    pcaptopdml.create_pcap_to_pdml_converter(name="pcap", file_path_pattern=f"{file_path}/{pcap_file}")
    pcaptopdml.convert("pcap")


def zip_results():
    file_path = get_path()
    shutil.make_archive(file_path, 'zip', file_path)
    shutil.rmtree(file_path)


def unzip_results():
    file_path = get_path()
    zip_files = [file for file in os.listdir(file_path) if file.endswith('.zip')]
    shutil.unpack_archive(f"{file_path}/{zip_files[0]}", file_path)


def find_pcap_files_in_subfolders():
    file_path = get_path()
    for root, _, files in os.walk(file_path):
        for file in files:
            if file.endswith(".pcap"):
                pcap_file_path = os.path.join(root, file)
                shutil.copy(pcap_file_path, f"{file_path}/{file_path.rpartition('/')[2]}.pcap")


def find_emil_files_in_subfolders():
    file_path = get_path()
    for root, _, files in os.walk(file_path):
        for file in files:
            if file.endswith(".lcbin"):
                emil_file_path = os.path.join(root, file)
                shutil.copy(emil_file_path, f"{file_path}/{file}")


def read_lines(file_path, file_name, call_flow_messages):
    for line in _file_reader(f"{file_path}/{file_name}"):
        counter = 0
        if len(call_flow_messages) == 0:
            return True
        if re.search(call_flow_messages[counter], line):
            call_flow_messages.pop(counter)
    if len(call_flow_messages) > 0:
        raise Exception("Incorrect_call_flow - ", call_flow_messages, " NOT FOUND")
    else:
        return True


def verify_syslog(parameters, file_localization="/btslog/btslogs_merged/btslog.LOG"):
    file_path = get_path()
    for key, value in parameters.items():
        matches = False
        for line in _file_reader(f"{file_path}{file_localization}"):
            if re.search(value, line):
                matches = True
        if matches is False:
            raise Exception(f'{key} not found in Syslog')


def one_cell_nrdcsn_unlocked(status):
    deltaStore.initialise_delta_store()
    deltaStore.add_param_to_delta("MRBTS-50856/NRBTS-50856/NRCELL-562", "administrativeState", status)
    deltaStore.add_param_to_delta("MRBTS-50856/NRBTS-50856/NRCELL-563", "administrativeState", status)
    deltaStore.add_param_to_delta("MRBTS-50856/NRBTS-50856/NRCELL-564", "administrativeState", status)
    deltaStore.add_param_to_delta("MRBTS-50856/NRBTS-50856/NRCELL-565", "administrativeState", status)
    deltaStore.add_param_to_delta("MRBTS-50856/NRBTS-50856/NRCELL-566", "administrativeState", status)
    deltaStore.add_param_to_delta("MRBTS-50856/NRBTS-50856/NRCELL-567", "administrativeState", status)
    deltaStore.add_param_to_delta("MRBTS-50856/NRBTS-50856/NRCELL-568", "administrativeState", status)
    try:
        admin.setup_admin(bts_host="10.42.47.9", timeout=180)
        delta = deltaStore.collect_delta_store()
        admin.perform_delta_recommissioning(delta)
    finally:
        admin.teardown_admin()


def verify_administrative_state(value, *args):
    log_info_to_console("Verifying administrative state...")
    try:
        admin.setup_admin(bts_host="10.42.47.9")
        cells_ids = [cell.get("id").get("configuration").split("/")[-1] for cell in admin.get_cells_info("nr")]
        for cell in args:
            if cell in cells_ids:
                admin.perform_parameter_recommissioning(f"MRBTS-50856/NRBTS-50856/{cell}",
                                                        parameter="administrativeState",
                                                        operation="update", value=value)
    finally:
        admin.teardown_admin()


def change_shutdown_timer(value):
    try:
        admin.setup_admin(bts_host="10.42.47.9")
        admin.perform_parameter_recommissioning("MRBTS-50856/NRBTS-50856",
                                                parameter='shutdownNogNBCellTmr',
                                                operation="update", value=value)
    finally:
        admin.teardown_admin()


def switch_overload_mode(value, parameter):
    log_info_to_console("Change Overloade...")
    try:
        admin.setup_admin(bts_host="10.45.173.38")
        admin.perform_parameter_recommissioning("MRBTS-50859/NRBTS-50859",
                                                parameter=parameter,
                                                operation="update", value=value)
    finally:
        admin.teardown_admin()


def change_fwa_value(value):
    try:
        admin.setup_admin(bts_host="10.45.173.38")
        admin.perform_parameter_recommissioning("MRBTS-50859/NRBTS-50859",
                                                parameter="identifiedFwaUeList",
                                                operation="update", value=[value])
    finally:
        admin.teardown_admin()


def change_sn_cell_state(value):
    try:
        admin.setup_admin(bts_host="10.42.47.9")
        admin.perform_parameter_recommissioning("MRBTS-50856/NRBTS-50856/NRCELL-562",
                                                parameter="administrativeState",
                                                operation="update", value=value)
    finally:
        admin.teardown_admin()


def change_nrdc_flag(value):
    try:
        admin.setup_admin(bts_host="10.42.47.8")
        admin.perform_parameter_recommissioning("MRBTS-50858/NRBTS-50858/NRCELL-582",
                                                parameter="actNrDualConnectivity",
                                                operation="update", value=value)
    finally:
        admin.teardown_admin()


def change_xn_link_status(host: str, status: str) -> None:
    """
    Changes the Xn link status for a given host.

    :param host: Host IP address (mplane address).
    :type host: str
    :param status: Value for the administrativeState parameter.
    :type status: str
    :return: None
    """
    gnb_ip = 6 if host == "10.42.47.9" else 9
    deltaStore.initialise_delta_store()
    if gnb_ip == 6:
        deltaStore.add_param_to_delta(f"MRBTS-5085{gnb_ip}/NRBTS-5085{gnb_ip}/NRADJGNB-7",
                                      "administrativeState", status)
    deltaStore.add_param_to_delta(f"MRBTS-5085{gnb_ip}/NRBTS-5085{gnb_ip}/NRADJGNB-6",
                                  "administrativeState", status)
    try:
        admin.setup_admin(bts_host=host, timeout=180)
        delta = deltaStore.collect_delta_store()
        admin.perform_delta_recommissioning(delta)
    finally:
        admin.teardown_admin()


def change_nr_dc_sn_cell_status_and_xn_link(status):
    deltaStore.initialise_delta_store()
    deltaStore.add_param_to_delta("MRBTS-50856/NRBTS-50856/NRCELL-561", "administrativeState", status)
    deltaStore.add_param_to_delta("MRBTS-50856/NRBTS-50856/NRCELL-562", "administrativeState", status)
    deltaStore.add_param_to_delta("MRBTS-50856/NRBTS-50856/NRCELL-563", "administrativeState", status)
    deltaStore.add_param_to_delta("MRBTS-50856/NRBTS-50856/NRCELL-564", "administrativeState", status)
    deltaStore.add_param_to_delta("MRBTS-50856/NRBTS-50856/NRCELL-565", "administrativeState", status)
    deltaStore.add_param_to_delta("MRBTS-50856/NRBTS-50856/NRCELL-566", "administrativeState", status)
    deltaStore.add_param_to_delta("MRBTS-50856/NRBTS-50856/NRCELL-567", "administrativeState", status)
    deltaStore.add_param_to_delta("MRBTS-50856/NRBTS-50856/NRCELL-568", "administrativeState", status)
    try:
        admin.setup_admin(bts_host="10.42.47.9", timeout=180)
        delta = deltaStore.collect_delta_store()
        admin.perform_delta_recommissioning(delta)
    finally:
        admin.teardown_admin()


def block_xnlinks_and_cells() -> None:
    """
    Blocks Xn links and cells.

    :return: None
    """
    log_info_to_console("Blocking Xn links and cells...")
    change_xn_link_status("10.42.47.9", "Locked")
    time.sleep(60)
    confirm_all_xn_link_alarms_active()
    change_nr_dc_sn_cell_status_and_xn_link("Locked")
    change_xn_link_status("10.45.173.38", "Locked")
    time.sleep(60)
    confirm_all_xn_link_alarms_inactive()


def prepare_parameters_for_ue_inactivity(drbIn, drbRrc, srbIn):
    try:
        admin.setup_admin(bts_host="10.45.173.38")
        admin.perform_parameter_recommissioning("MRBTS-50859/NRBTS-50859",
                                                parameter="drbInactivityTimerSA",
                                                operation="update", value=drbIn)
        admin.perform_parameter_recommissioning("MRBTS-50859/NRBTS-50859",
                                                parameter="drbRrcInactInactivityTimerSA",
                                                operation="update", value=drbRrc)
        admin.perform_parameter_recommissioning("MRBTS-50859/NRBTS-50859",
                                                parameter="srbInactivityTimerSA",
                                                operation="update", value=srbIn)
    finally:
        admin.teardown_admin()


def change_a4_threshold(a4Thres):
    log_info_to_console("Change a4ThresholdNrDcSsbRsrp...")
    try:
        admin.setup_admin(bts_host="10.45.173.38")
        admin.perform_parameter_recommissioning("MRBTS-50859/NRBTS-50859/NRCELL-592/NRHOIF-35",
                                                parameter="a4MeasNrDcSsbRsrp",
                                                operation="update", value=[{'a4HysteresisNrDcSsbRsrp': '0',
                                                                            'a4ThresholdNrDcSsbRsrp': a4Thres,
                                                                            'a4TimeToTriggerNrDcSsbRsrp': 'ms320'}])
    finally:
        admin.teardown_admin()


def initialize_attenuator():
    yaml_file = _builtin.get_variable_value("${ABSTRACT_LIB_CONFIG}")
    _attenuator.load_attenuation_config(yaml_file)
    cells = list(_attenuator.cells_pool.cells_registry.keys())
    _attenuator.require_attenuator_setup_of(cells)
    _attenuator.set_attenuation_for_all_cells('90dB')


def release_attenuator():
    _attenuator.set_attenuation_for_all_cells('90dB')
    _attenuator.release_attenuator_cell(list(_attenuator.cells_pool.cells_registry.keys()))


def set_attenuation_for_cell(cell_alias, attenuation):
    _attenuator.set_attenuation(cell_alias=cell_alias, attenuation_value=attenuation)


def stop_and_collect_syslog(file_dir):
    btslog.stop_collectors("btslog")
    btslog.collect_collectors("btslog", target_dir=file_dir)
    btslog.teardown_collectors("btslog")
    extract_file()


def merge_syslog():
    file_path = get_path()
    path = file_path + "/btslog/btslogs_merged"
    log_files = [f for f in os.listdir(file_path + "/btslog/") if f.endswith(('.LOG', '.log'))]
    log_files_iter = iter(log_files)
    if len(log_files) == 0:
        raise ValueError('Should be minimum one LOG file in the current directory.')
    if not os.path.exists(path):
        os.mkdir(path)
    with open(os.path.join(path, "btslog.LOG"), 'w') as f:
        while True:
            try:
                iterator = next(log_files_iter)
                for line in _file_reader(file_path + "/btslog/" + iterator):
                    f.write(line)
            except StopIteration:
                break


def extract_file():
    file_path = get_path()
    with tarfile.open(f"{file_path}/btslog/BtsLog.tgz", 'r') as tar:
        tar.extractall(file_path + "/btslog/")


def find_syslog_files_from_dcap():
    file_path = get_path()
    dest_dir = os.path.join(file_path, 'btslog')
    Path(dest_dir).mkdir(exist_ok=True)
    for dirpath, dirnames, filenames in os.walk(file_path):
        for filename in filenames:
            if 'syslog' in filename:
                file_path = os.path.join(dirpath, filename)
                shutil.move(file_path, os.path.join(dest_dir, filename))
                log_info_to_console(f'Moved {file_path} to {dest_dir}')


def verify_pcap_flow(test_flow):
    file_path = get_path()
    read_lines(file_path, f'{BuiltIn().get_variable_value("${TEST_NAME}")}.pdml', test_flow)


def verify_syslog_for_no_nr_dc_setup():
    file_path = get_path()
    for line in _file_reader(f"{file_path}/btslog/btslogs_merged/btslog.LOG"):
        if "NrdcMnSideSnodeAddition" in line:
            raise Exception("NR-DC was established after HO")


def convert_emil_files_to_csv():
    host = "10.44.234.142"
    user = "wro5grrm"
    password = "5gpass!1"
    file_path = get_path()
    files = Path(file_path).glob('*.lcbin')
    for file in files:
        os.system(f"sshpass -p {password} scp {file} \
                    {user}@{host}:/cygdrive/c/Users/wro5grrm/Desktop/50859_Emil_convertion")
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        client.connect(host, username=user, password=password)
        stdin, stdout, stderr = client.exec_command(
         r'"C:/Program Files/Emil/Emil.exe" \
         "C:/Users/wro5grrm/Desktop/50859_Emil_convertion/*.lcbin" -ToCSV -AutoClose')
    finally:
        client.close()
    time.sleep(10)
    os.system(f'sshpass -p {password} scp {user}@{host}:/cygdrive/c/Users/wro5grrm/Desktop/50859_Emil_convertion/*.csv \
             {file_path}')
    os.system(
        f'sshpass -p {password} ssh {user}@{host} rm -rf /cygdrive/c/Users/wro5grrm/Desktop/50859_Emil_convertion/*')


def perform_rrc_resume():
    _ute_ue.start_data_transfer(dt_name="DT_DL", ue_alias='UE_1', duration='10s',
                                direction="dl", throughput="1000mbits/sec", protocol="udp", packet_size="1400")
    log_info_to_console("Traffic for UE")
    _ute_ue.await_data_transfer_finish(dt_name="DT_DL")
    _ute_ue.stop_data_transfer("DT_DL")


def change_tracking_area_dn_in_cells(ta_code):
    deltaStore.initialise_delta_store()
    deltaStore.add_param_to_delta("MRBTS-50856/NRBTS-50856/NRCELL-561", "trackingAreaDN",
                                  f"MRBTS-50856/NRBTS-50856/TRACKINGAREA-{ta_code}")
    deltaStore.add_param_to_delta("MRBTS-50856/NRBTS-50856/NRCELL-562", "trackingAreaDN",
                                  f"MRBTS-50856/NRBTS-50856/TRACKINGAREA-{ta_code}")
    try:
        admin.setup_admin(bts_host="10.42.47.9", timeout=60)
        delta = deltaStore.collect_delta_store()
        admin.perform_delta_recommissioning(delta)
    finally:
        admin.teardown_admin()


def verify_xn_links_and_cells_availability():
    try:
        admin.setup_admin(bts_host="10.42.47.9", timeout=120)
        cells = admin.get_parameter_by_class("NRCELL", parameter_list=["operationalState"])
        xnlinks = admin.get_parameter_by_class("XNLINK", parameter_list=["xnLinkStatus"])
    finally:
        admin.teardown_admin()
    for xnlink in xnlinks:
        assert xnlink.get("parameters").get("xnLinkStatus") == "available"
    for cell in cells:
        assert cell.get("parameters").get("operationalState") == "enabled"


def set_csv_limit_size():
    import sys
    max_int = sys.maxsize
    while True:
        try:
            csv.field_size_limit(max_int)
            break
        except OverflowError:
            max_int = int(max_int/10)


def verify_interaction_with_cb006733():
    reconfiguration_values = ["physCellId 592", "eventA3", "eventA5"]
    correct_flow = False
    cb006733_a4 = False
    file_path = get_path()
    set_csv_limit_size()
    csv_doc = list(Path(file_path).glob('50859*.csv'))
    with open(csv_doc[0], newline='') as f:
        file = csv.reader(f)
        for line in file:
            if line[2] == "RRCReconfiguration":
                if "eventA4" in line[-1]:
                    cb006733_a4 = True
                counter = 0
                for info_object in reconfiguration_values:
                    if info_object in line[-1]:
                        counter += 1
                if counter == len(reconfiguration_values):
                    correct_flow = True
    if not correct_flow or not cb006733_a4:
        raise Exception("Handover or events didn't occur")


def verify_correct_transition_and_setup_of_nr_dc():
    file_path = get_path()
    set_csv_limit_size()
    csv_doc = list(Path(file_path).glob('50859*.csv'))
    with open(csv_doc[0], newline='') as f:
        file = csv.reader(f)
        messages = set()
        ue_resume = False
        for row in file:
            if not ue_resume:
                if row[2] == "SNStatusTransfer":
                    raise Exception("NR-DC Established!")
                if row[2] == "RRCRelease":
                    content = row[-1].splitlines()
                    for i in range(len(content)):
                        if "ran-AreaCodeList {" in content[i] and '166' not in content[i + 1]:
                            raise Exception("Wrong RAN AreaCode")
                    messages.add(row[2])
                elif row[2] == "RRCResumeComplete":
                    messages.add(row[2])
                    ue_resume = True
            else:
                if row[2] == "SNStatusTransfer":
                    messages.add(row[2])
                elif row[2] == "RRCReconfiguration":
                    messages.add(row[2])
        if len(messages) != 4:
            raise Exception(f"Lack of message on list {messages}")


def set_ran_configuration(path):
    time.sleep(120)
    try:
        admin.setup_admin(bts_host="10.45.173.38", timeout=180)
        admin.perform_delta_recommissioning(f"{path}/delta_node2.json", timeout=700)
    finally:
        admin.teardown_admin()
    try:
        admin.setup_admin(bts_host="10.42.47.9", timeout=180)
        admin.perform_parameter_recommissioning(dist_name="MRBTS-50856/NRBTS-50856/SNSSAI-3",
                                                parameter="administrativeState",
                                                operation='update',
                                                value="Locked")
        admin.perform_parameter_recommissioning(dist_name="MRBTS-50856/NRBTS-50856/SNSSAI-4",
                                                parameter="administrativeState",
                                                operation='update',
                                                value="Locked")
        adjs = admin.get_parameter_by_class("NRADJGNB", parameter_list=["gNodeBId"])
        for adj in adjs:
            if adj.get("parameters").get("gNodeBId") == 50858:
                admin.perform_object_recommissioning(
                    dist_name=adj.get("distName"),
                    parameter=[],
                    operation="delete",
                    skip_parameter_relation_errors=False
                )
        admin.perform_delta_recommissioning(f"{path}/delta_node4.json", timeout=700)
    finally:
        admin.teardown_admin()
    time.sleep(120)


def perform_handover(src, dst, src_db=53, dst_db=0):
    set_attenuation_for_cell(dst, f"{dst_db}db")
    set_attenuation_for_cell(src, f"{src_db}db")
    time.sleep(10)


@dcap_logger
def graceful_shutdown_with_dcap_logging():
    attach('UE_1')
    execute_graceful_shutdown("Shutting Down", "NRCELL-561")
    time.sleep(150)


@dcap_logger
def overload_with_dcap_logging():
    attach('UE_1')
    time.sleep(20)
    switch_overload_mode("disabled", "gnbOvlProtMode")
    time.sleep(10)


@dcap_logger
def perform_handover_to_cell_unsupporting_nrdc():
    attach('UE_1')
    perform_handover("GNB_2_CELL_582", "GNB_1_CELL_591")


@dcap_logger
def perform_handover_to_cell_supporting_nrdc():
    attach('UE_1')
    perform_handover("GNB_2_CELL_582", "GNB_1_CELL_593")


@dcap_logger(mplane='10.42.47.8')
def perform_handover_to_cell_supporting_mfbi():
    attach('UE_1')
    perform_handover("GNB_1_CELL_591", "GNB_2_CELL_582")


@tcp_collector
def perform_reestablishment_to_cell_with_a2_redirect():
    attach('UE_1')
    perform_handover("GNB_1_CELL_591", "GNB_1_CELL_593", 90, 0)
    time.sleep(15)


@dcap_logger
def perform_handover_with_ue_not_in_fwa():
    attach('UE_1')
    perform_handover("GNB_1_CELL_591", "GNB_1_CELL_592", 42)


@dcap_logger
def perform_transition_to_rrc_connected_with_change_a4_threshold_parameter():
    attach('UE_1')
    time.sleep(200)
    change_a4_threshold(0)
    perform_rrc_resume()
    time.sleep(20)


@dcap_logger
def perform_tracking_area_update():
    change_tracking_area_dn_in_cells(7151)
    time.sleep(10)


@tcp_collector
def unsuccessful_xn_setup() -> None:
    """
    Unblocks Xn links and cells.
    :return: None
    """
    log_info_to_console("Unblocking Xn links and cells...")
    change_xn_link_status("10.45.173.38", "Unlocked")
    time.sleep(120)
    change_xn_link_status("10.42.47.9", "Unlocked")
    time.sleep(120)
    change_nr_dc_sn_cell_status_and_xn_link("Unlocked")
    time.sleep(180)


def blocking_periodical_a4_activation():
    attach('UE_1')
    time.sleep(120)


def get_active_alarms_from_node(mplane: str) -> list[dict]:
    """
    Retrieves active alarms from a given node.

    :param mplane: The mPlane address.
    :type mplane: str
    :return: A list of dictionaries representing the active alarms.
    :rtype: list[dict]
    """
    try:
        admin.setup_admin(bts_host=mplane)
        return admin.get_active_alarms(timeout=30)
    finally:
        admin.teardown_admin()


def _find_active_alarms(mplane, *args):
    inactive_alarms = []
    active_alarms = get_active_alarms_from_node(mplane)
    for fault_id, object_distname in args:
        alarm_found = False
        for alarm in active_alarms:
            if alarm.get("faultId") == int(fault_id):
                for alarm_object in alarm.get("alarmingObjectIds", []):
                    if alarm_object.get("configuration") == object_distname:
                        alarm_found = True
                        break
            if alarm_found:
                break
        if not alarm_found:
            inactive_alarms.append((fault_id, object_distname))
    if inactive_alarms:
        log_info_to_console(f"Inactive alarms: {inactive_alarms}\n")
        return False
    return True


def confirm_all_xn_link_alarms_active() -> None:
    """
    Confirms that all expected Xn link alarms are active.

    :return: None
    :raises Exception: If not all expected alarms are active.
    """
    log_info_to_console(f"Checking if the expected alarms appeared...")
    master_node_result = _find_active_alarms("10.45.173.38", *xn_link_mn_alarms)
    secondary_node_result = _find_active_alarms("10.42.47.9", *xn_link_sn_alarms)
    if all([master_node_result, secondary_node_result]):
        log_info_to_console(f"All expected alarms appeared.")
        return
    raise Exception(f"Not all expected alarms appeared. MN: {master_node_result}, SN: {secondary_node_result}.")


def confirm_all_xn_link_alarms_inactive() -> None:
    """
    Confirms that all expected Xn link alarms are inactive.

    :return: None
    :raises Exception: If not all expected alarms are inactive.
    """
    log_info_to_console(f"checking if the expected alarms are inactive...")
    master_node_result = _find_active_alarms("10.45.173.38", *xn_link_mn_alarms)
    secondary_node_result = _find_active_alarms("10.42.47.9", *xn_link_sn_alarms)
    if not any([master_node_result, secondary_node_result]):
        log_info_to_console(f"All expected alarms are inactive.")
        return
    raise Exception(f"Not all expected alarms disappeared. MN: {master_node_result}, SN: {secondary_node_result}.")


@tcp_collector
def dynamic_removal_sn_cell_with_ue_attached():
    attach('UE_1')
    _ute_ue.start_data_transfer(dt_name="DT_DL", ue_alias='UE_1', duration='200s',
                                direction="dl", throughput="1000mbits/sec", protocol="udp", packet_size="1400")
    change_sn_cell_state("Locked")
    _ute_ue.await_data_transfer_finish(dt_name="DT_DL")
    _ute_ue.stop_data_transfer("DT_DL")
