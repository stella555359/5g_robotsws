import os
import re
import shutil
import subprocess
import time

import paramiko
import requests
from robot.libraries.BuiltIn import BuiltIn
from ta_attenuator import ta_attenuator
from taf.analyzer.pdml import PdmlReader
from taf.converters.pcaptopdml import pcaptopdml
from taf.rfrl.utilities.logger.custom_logger import log_info_to_console
from taf.sbts.oam.coam.admin import admin_interface_context
from taf.ue import *

from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.dcap import dcap
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.nls import (
    change_nls_parameters, setup_nls_page_and_open_nrppa_parameter_page,
    teardown_nls_connection_and_restore_initial_values)
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.common_keywords.file_utils import file_reader
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.admin import Admin5G
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.cleaners import \
    clear_admin_api_logs
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.pm_counters import \
    wait_for_next_pm_interval_and_get_counters

_attenuator = ta_attenuator()
_builtin = BuiltIn()
_ute_ue = ue()
pcaptopdml = pcaptopdml()
dcap_alias = "test_logs_dcap"
pcap_file = "TC01_CB008281_Activation_and_deactivation.pcap"
pdml_file = "TC01_CB008281_Activation_and_deactivation.pdml"
wireshark_plugin_path = (
    "/home/ute/MN/UTE/robotws/testsuite/Wroclaw/RRM/VRF_WRO2_T08/" "features/classical/CB008281/resources/preferences"
)
counter_ids = ["M55125C00024", "M55125C00025"]
bts_log_profile = ["scf", "ipCapture", "immediateSnapshot"]
gnb_log_profile = ["condor5gSyslog"]
log_kwargs = {
    "gnb_custom_profile": gnb_log_profile,
    "bts_custom_profile": bts_log_profile,
    "bip_mirroring_time": 0,
    "wait_for_activation": True,
}
ues_info = {
    "UE_1": {"name": "S22", "adb_id": "S22"},
}
pm_counters_dict = {"M55125C00025": 0, "M55125C00024": 0}

ssh = paramiko.SSHClient()
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())


def set_nls_parameters():
    setup_nls_page_and_open_nrppa_parameter_page()
    change_nls_parameters("TimingAdvanceNR,SS_RSRP,SS_RSRQ", "OnDemand")


def teardown_nls():
    teardown_nls_connection_and_restore_initial_values()


def clear_admin_logs():
    clear_admin_api_logs()


def start_logging():
    trace_id = dcap.start_new_trace(mplane="10.45.173.38", log_profile=log_kwargs, force=True)
    return trace_id


def _is_dcap_controller_started():
    log_info_to_console("Checking DCAP Controller status")
    health_check_status = subprocess.run(
        ["utf_lab-controller", "status"], stdout=subprocess.PIPE, stderr=subprocess.PIPE
    )
    if health_check_status.returncode == 0:
        return True


def start_dcap_controller():
    start_status = subprocess.run(["utf_lab-controller", "start"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
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


def stop_and_collect_logs(trace_id):
    target_dir = get_path()
    log_zip = dcap.stop_trace(trace=trace_id, timeout=1500)
    log_zip = dcap.download_logs(trace=trace_id, target_dir=target_dir, timeout=1500)
    return log_zip


def execute_trigger_from_lmf_and_collect_logs():
    dcap.connect_to(host="localhost", port="9443", user=None, passwd=None)
    log_info_to_console("Starting PM counter...")
    pm_data = start_pm_counter()
    log_info_to_console("Starting DCAP logging...")
    trace_id = start_logging()
    BuiltIn().set_test_variable("${TRACE_ID}", trace_id)
    attach("UE_1")
    time.sleep(3)
    start_dl_and_ul("UE_1")
    log_info_to_console("Executing trigger on LMF - PASS scenario...")
    lmf_trigger("10.27.227.252", "root", "nls72NSN")
    output = stop_pm_counter(pm_data)
    check_pm_counters(pm_output=output, pm_counters=pm_counters_dict)
    log_info_to_console("Setting parameters for failure scenario")
    set_failure_scenario("591", "592")
    log_info_to_console("Executing trigger on LMF - FAILURE scenario")
    lmf_trigger("10.27.227.252", "root", "nls72NSN")
    time.sleep(10)
    log_info_to_console("Collecting logs...")
    log_zip = stop_and_collect_logs(trace_id)
    log_info_to_console("Stopping and veifying logs...")
    return log_zip


def check_pm_counters(pm_output, pm_counters):
    log_info_to_console(pm_output)
    for key in pm_output.keys():
        if key.rpartition("/")[2] in pm_counters:
            for f_value, s_value in pm_output[key]:
                if s_value >= 1:
                    pm_counters[key.rpartition("/")[2]] = s_value
    for key in pm_counters.keys():
        assert pm_counters[key] != 0


def attach(ue_name):
    log_info_to_console("Call is ongoing...")
    _ute_ue.attach_ue(ue_name)
    log_info_to_console("{} attached!".format(ue_name))


def collect_scf_before_test():
    log_info_to_console("Collecting backup SCF...")
    with Admin5G() as admin_api:
        admin_api.get_current_scf_file(_builtin.get_variable_value("${OUTPUT_DIR}"), "backup_scf.xml")


def get_path():
    return os.path.join(BuiltIn().get_variable_value("${OUTPUT_DIR}"), BuiltIn().get_variable_value("${TEST_NAME}"))


def disable_ecolab():
    cmd = "sudo touch /etc/ute/disable_ecolab"
    os.system(cmd)


def convert_pdml():
    file_path = get_path()
    log_info_to_console(file_path)
    pcaptopdml.create_pcap_to_pdml_converter(name="pcap", file_path_pattern="{}/{}".format(file_path, pcap_file))
    pcaptopdml.convert("pcap")


def zip_results():
    file_path = get_path()
    shutil.make_archive(file_path, "zip", file_path)
    shutil.rmtree(file_path)


def unzip_results():
    file_path = get_path()
    zip_files = [file for file in os.listdir(file_path) if file.endswith(".zip")]
    shutil.unpack_archive(f"{file_path}/{zip_files[0]}", file_path)


def find_pcap_files_in_dcap_folders():
    file_path = get_path()
    for root, _, files in os.walk(file_path):
        for file in files:
            if file.endswith(".pcap"):
                pcap_file_path = os.path.join(root, file)
                shutil.copy(pcap_file_path, f"{file_path}/{file_path.rpartition('/')[2]}.pcap")


def lmf_trigger(ip_address, username, password):
    directory = r"/root/Michal_H_Wro8_auto"
    command = f"curl -v http://{ip_address}:9210 -d @gjill-540017000000066.xml"
    try:
        ssh.connect(ip_address, username=username, password=password)
        stdin, stdout, stderr = ssh.exec_command(f"cd {directory} && {command}")
        stdout.channel.recv_exit_status()
    finally:
        ssh.close()


def read_lines(file_path, file_name, call_flow_messages):
    for line in file_reader("{}/{}".format(file_path, file_name)):
        counter = 0
        if len(call_flow_messages) == 0:
            return True
        if re.search(call_flow_messages[counter], line):
            call_flow_messages.pop(counter)
    if len(call_flow_messages) > 0:
        raise Exception("Incorrect_call_flow - ", call_flow_messages, " NOT FOUND")
    else:
        return True


def check_e_cid_measurements_flow():
    file_path = get_path()
    log_info_to_console(file_path)
    call_flow_messages = [
        "LocationReportingControl.*",
        "id-e-CIDMeasurementInitiation*",
        "E-CIDMeasurementInitiationRequest",
    ]
    read_lines(file_path, pdml_file, call_flow_messages)


def check_position_measurement():
    file_path = get_path()
    pdml_entries = PdmlReader.from_file("{}/{}".format(file_path, pdml_file))
    counter_rsrp, counter_rsrq = False, False
    for entry in pdml_entries:
        if "nrppa.measuredResults" in entry.packet:
            if not counter_rsrp:
                counter_rsrp = entry.packet.findall("nrppa.valueSS_RSRP_Cell")
            if not counter_rsrq:
                counter_rsrq = entry.packet.findall("nrppa.valueSS_RSRQ_Cell")
        if counter_rsrp and counter_rsrq:
            return
    raise Exception("Lack of nrppa")


def check_failure_case():
    file_path = get_path()
    pdml_entries = PdmlReader.from_file("{}/{}".format(file_path, pdml_file))
    for entry in pdml_entries:
        if "nrppa.unsuccessfulOutcome_element" in entry.packet:
            if "nrppa.E_CIDMeasurementInitiationFailure_element" in entry.packet:
                measfailure = entry.packet["nrppa.radioNetwork"].showname
                measfailure = measfailure.split(" ")
                assert measfailure[1] == "requested-item-not-supported"
                return True


def set_failure_scenario(*args):
    for cell_id in args:
        with Admin5G() as admin_api:
            admin_api.perform_parameter_recommissioning(
                f"MRBTS-50859/NRBTS-50859/NRCELL-{cell_id}",
                parameter="actUlNrEcIdPosMethod",
                operation="update",
                value="false",
                skip_parameter_relation_errors=False,
                should_activate=True,
                timeout=300,
            )


def verify_administrative_state(value, *args):
    log_info_to_console("Verifying administrative state...")
    with Admin5G() as admin_api:
        cells_ids = [cell.get("id").get("configuration").split("/")[-1] for cell in admin_api.get_cells_info("nr")]
        for cell in args:
            if cell in cells_ids:
                admin_api.perform_parameter_recommissioning(
                    f"MRBTS-50859/NRBTS-50859/{cell}",
                    parameter="administrativeState",
                    operation="update",
                    value=value,
                    skip_parameter_relation_errors=False,
                    should_activate=True,
                    timeout=300,
                )


def verify_feature_flag(*args):
    log_info_to_console("Verifying feature flag...")
    for cell in args:
        with Admin5G() as admin_api:
            admin_api.perform_parameter_recommissioning(
                f"MRBTS-50859/NRBTS-50859/{cell}",
                parameter="actUlNrEcIdPosMethod",
                operation="update",
                value="true",
                skip_parameter_relation_errors=False,
                should_activate=True,
                timeout=300,
            )


def start_pm_counter():
    with admin_interface_context() as admin_api:
        pm_data = wait_for_next_pm_interval_and_get_counters(
            counter_ids=counter_ids, admin_connection=admin_api, reference_point=None, timeout=960
        )
        return pm_data


def stop_pm_counter(pm_data):
    with admin_interface_context() as admin_api:
        output = wait_for_next_pm_interval_and_get_counters(
            counter_ids=counter_ids, admin_connection=admin_api, reference_point=pm_data, timeout=960
        )
        return output


def verify_mdt_cell_tracing():
    log_info_to_console("Please be aware that A_D cannot be PASS without CB008281_A_B logs")
    file_path = get_path()
    file_path = f"{file_path.rpartition('/')[0]}/TC01_CB008281_Activation_and_deactivation"
    pdml_entries = PdmlReader.from_file("{}/{}".format(file_path, pdml_file))
    for entry in pdml_entries:
        if "nsetapx.ueMeasRecord" in entry.packet:
            if "nsetapx.data_r1_element" in entry.packet:
                nset = entry.packet["nsetapx.purpose"].showname
                nset = nset.split(" ")
                assert nset[1] == "mdt"
                return True


def verify_rrc_reconfiguration_cell_tracing():
    file_path = get_path()
    file_path = f"{file_path.rpartition('/')[0]}/TC01_CB008281_Activation_and_deactivation"
    pdml_entries = PdmlReader.from_file("{}/{}".format(file_path, pdml_file))
    objects = []
    for entry in pdml_entries:
        if "nr-rrc.periodical_element" in entry.packet:
            freq = entry.packet.findall("nr-rrc.reportInterval")
            objects.append(str(freq))
            nset = entry.packet.findall("nr-rrc.reportAmount")
            objects.append(str(nset))
    if objects.__eq__("ms5120") and objects.__eq__("infinity"):
        return True
    else:
        raise Exception("Lack of ms5120 or infinity")


def prepare_wireshark():
    local_plugin_path = _download_nsetapx_plugin()
    _move_plugin_to_appropriate_directory(local_plugin_path, "4.0")
    file_path = wireshark_plugin_path
    shutil.copy(file_path, "/home/ute/.config/wireshark")


def _download_nsetapx_plugin():
    local_plugin_path = None
    version = "nsetapx-4.0-0.5.0-1.11.2+buster.so"
    repo_link = (
        "https://artifactory-espoo1.int.net.nokia.com/artifactory/"
        "wslte5g_plugins-local/NSETAP_X/nsetapx-1.11.2/{}".format(version)
    )
    try:
        local_plugin_path = _download_nsetapx(repo_link, version)
    except requests.RequestException as e:
        log_info_to_console("Failed to download plugin: {}".format(e))
    finally:
        return local_plugin_path


def _download_nsetapx(repo_link, version):
    local_plugin_path = "/tmp/{}".format(version)
    artifactory_key = "cmVmdGtuOjAxOjE3MjMxOTk0NDY6M0dCVm5vR2NDOVM1T25TMFlBN053UEtUdEt2"
    with requests.get(url=repo_link, stream=True, timeout=10, headers={"X-JFrog-Art-Api": artifactory_key}) as request:
        if request.status_code == 200:
            log_info_to_console("downloading nsetapx plugin")
            with open(local_plugin_path, "wb") as f:
                shutil.copyfileobj(request.raw, f, length=16 * 1024 * 1024)
        else:
            raise Exception("Invalid plugin link: '{}'".format(repo_link))
    return local_plugin_path


def _move_plugin_to_appropriate_directory(plugin_path, wireshark_ver):
    subprocess.call(
        ["sudo", "mv", plugin_path, "/usr/lib/x86_64-linux-gnu/wireshark/plugins/{}/epan/".format(wireshark_ver)]
    )


def start_dl_and_ul(ue):
    ul_value = "500 MBytes/sec"
    dl_value = "500 MBytes/sec"
    _ute_ue.start_data_transfer(
        dt_name="DT_DL",
        ue_alias=ue,
        duration="20s",
        direction="dl",
        throughput=dl_value,
        protocol="udp",
        packet_size="1400",
    )
    _ute_ue.start_data_transfer(
        dt_name="DT_UL",
        ue_alias=ue,
        duration="20s",
        direction="ul",
        throughput=ul_value,
        protocol="udp",
        packet_size="1400",
    )


def initialize_attenuator():
    yaml_file = _builtin.get_variable_value("${ABSTRACT_LIB_CONFIG}")
    _attenuator.load_attenuation_config(yaml_file)
    cells = list(_attenuator.cells_pool.cells_registry.keys())
    _attenuator.require_attenuator_setup_of(cells)
    _attenuator.set_attenuation_for_all_cells("90dB")


def release_attenuator():
    _attenuator.set_attenuation_for_all_cells("90dB")
    _attenuator.release_attenuator_cell(list(_attenuator.cells_pool.cells_registry.keys()))


def set_attenuation_for_cell(cell_alias, attenuation):
    _attenuator.set_attenuation(cell_alias=cell_alias, attenuation_value=attenuation)
