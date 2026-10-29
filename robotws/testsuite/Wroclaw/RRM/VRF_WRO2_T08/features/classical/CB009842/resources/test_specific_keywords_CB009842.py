import re
import shutil
import subprocess
import time
from functools import wraps
from pathlib import Path
from typing import Optional

from robot import __version__ as robot_version
from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn
from robot.running import EXECUTION_CONTEXTS
from taf.analyzer.pdml import pdml
from taf.config.scf import scf
from taf.hw.rf_attenuator import rf_attenuator
from taf.rfrl.utilities.robot.general import get_builtin_instance
from taf.rfrl.utilities.test_config import set_test_case_log_path
from taf.rfrl.utilities.logger.custom_logger import (log_banner_to_console,
                                                     log_info_to_console)
from taf.rfrl.utilities.robot.RobotWrapper import RobotWrapper
from taf.sbts.oam.coam.admin import admin
from taf.transport.ssh import ssh
from taf.ul.parser.pcap import pcap

from nls_page import NlsPage
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.features.classical.CB009842.resources.test_constants import *
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.features.classical.CB013773.resources.test_specific_keywords import (
    find_suspicious_prints_in_syslog)
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.dcap import (dcap,
                                                               extract_logs)
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.nls import (
    change_nls_parameters, setup_nls_page_and_open_nrppa_parameter_page,
    teardown_nls_connection_and_restore_initial_values, trigger_lcs)
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.admin import Admin5G
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.pm_counters import \
    wait_for_next_pm_interval_and_get_counters
from testsuite.Wroclaw.RRM.resources.scout_report import \
    add_scout_scf_id_to_test_data
from testsuite.Wroclaw.RRM.resources.syslog_checker import syslog_checker

_builtin = BuiltIn()
admin_api = admin()
taf_ue = get_builtin_instance("taf.ue")
scf_manager = scf()
ssh = ssh()
attenuator = rf_attenuator()
pcap = pcap()
pdml = pdml()
_syslog_checker = syslog_checker()
TEST_LOG_DIR: str
TEST_NAME: str
TEST_VERIFICATION_RESULTS: dict
nls_page: NlsPage


def logged_keyword(function):
    @wraps(function)
    def logged_function(*args, **kwargs):
        arguments = " | ".join([f"{arg}" for arg in args] + [f"{kwarg}={value}" for kwarg, value in kwargs.items()])
        function_formatted_name = " ".join([word.title() for word in function.__name__.split("_")])
        if EXECUTION_CONTEXTS.current:
            logger.info(f"Robot Framework version: {robot_version}", also_console=False)
            wrap_type = "keyword" if robot_version >= "5.0" else "kw"
            with RobotWrapper(f"{function_formatted_name}", wrap_type):
                logger.info(f"Arguments: [{arguments}]", also_console=False)
                result = function(*args, **kwargs)
                logger.info(f"Return: {result}", also_console=False)
                return result
        return function(*args, **kwargs)

    return logged_function


@logged_keyword
def attenuate_cell(cell, attenuation: int, step: Optional[int] = None):
    log_info_to_console(f"Attenuating cell {cell} to {attenuation} dB")
    cells_ports = CELLS_PORTS[cell]
    if step:
        initial_attenuation = attenuator.read_ports_attenuation(CELLS_PORTS[cell])
        if initial_attenuation[0] > attenuation:
            step = -step
        for partial_attenuation in range(int(initial_attenuation[0]), attenuation, step):
            attenuator.set_ports_attenuation(cells_ports, [partial_attenuation] * len(cells_ports), confirm=True)
    else:
        attenuator.set_ports_attenuation(cells_ports, [attenuation] * len(cells_ports), confirm=True)
    return True


@logged_keyword
def initialize_attenuator():
    log_info_to_console("Initializing attenuator")
    attenuator.setup_attenuator(ATTENUATOR_CONFIG)
    attenuate_cell("NRCEL-1", 90)
    attenuate_cell("NRCEL-2", 90)
    attenuate_cell("NRCEL-3", 90)


@logged_keyword
def prepare_ue():
    log_info_to_console(f"Preparing UE with {UE.capabilities} for test execution")
    taf_ue.require_ue(ue_alias="UE", capabilities=UE.capabilities)
    taf_ue.detach_ue(ue_alias="UE")


@logged_keyword
def set_parameters_for_all_cells(parameters_dict: dict):
    admin_api.create_delta()
    for parameter, value in parameters_dict.items():
        log_info_to_console(f"Changing {parameter} value to {value}")
        for cell in CELLS:
            admin_api.append_parameter_update_to_delta(
                dist_name=f"{BTS_DISTNAME}/{cell}", parameter=parameter, value=value
            )
    admin_api.perform_delta_recommissioning(delta_file=admin_api.get_delta())
    admin_api.remove_all_delta_id()


@logged_keyword
def get_backup_scf():
    admin_api.get_current_scf_file(f"{TEST_LOG_DIR}/backup_scf.xml")


@logged_keyword
def set_test_variables():
    global TEST_LOG_DIR
    TEST_LOG_DIR = set_test_case_log_path()
    global TEST_NAME
    TEST_NAME = get_builtin_value("TEST_NAME")
    global TEST_VERIFICATION_RESULTS
    TEST_VERIFICATION_RESULTS = {}


@logged_keyword
def clear_test_log_dir():
    try:
        shutil.rmtree(TEST_LOG_DIR)
    except FileNotFoundError:
        pass


def test_setup():
    set_test_variables()
    clear_test_log_dir()
    log_banner_to_console(f"Executing Test Setup {TEST_NAME}")
    initialize_attenuator()
    prepare_ue()
    admin_api.setup_admin()
    setup_dcap()
    setup_bts_ssh_connection()
    setup_nls_page_and_open_nrppa_parameter_page()
    set_parameters_for_all_cells({"actUlNrEcIdPosMethod": "true", "actUlNrEcIdTAdv": "true"})


def setup_bts_ssh_connection():
    ssh.connect_to("192.168.255.129", "toor4nsn", "oZPS0POrRieRtu", alias="bts_ssh")


@logged_keyword
def setup_dcap():
    log_info_to_console("Connecting to DCAP")
    if not _is_dcap_controller_started():
        start_dcap_controller()
    dcap.connect_to(**DCAP_CONNECTION)
    current_traces = dcap._api.get_all_trace_info(connection="dcap_collector")
    for trace in current_traces:
        if trace.get("status") == "running" and trace.get("status_details") == "":
            dcap.stop_trace(trace.get("id"))


def _is_dcap_controller_started():
    log_info_to_console("Checking DCAP Controller status")
    health_check_status = subprocess.run(
        ["utf_lab-controller", "status"], stdout=subprocess.PIPE, stderr=subprocess.PIPE
    )
    logger.debug(
        f"DCAP Controller status: {health_check_status.stdout.decode('utf-8')}\n"
        f" {health_check_status.stderr.decode('utf-8')}"
    )
    if health_check_status.returncode == 0:
        return True


@logged_keyword
def start_dcap_controller():
    log_info_to_console("Dcap controller starting")
    start_status = subprocess.run(["utf_lab-controller", "start"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    logger.debug(
        f"DCAP Controller start status: {start_status.stdout.decode('utf-8')}\n"
        f" {start_status.stderr.decode('utf-8')}"
    )
    if start_status.returncode == 0:
        log_info_to_console("All DCAP containers started successfully. ")
        dcap_checks_attempts = 3
        for _ in range(dcap_checks_attempts):
            if _is_dcap_controller_started():
                log_info_to_console("DCAP health check passed.")
                return
            time.sleep(10)
        logger.error("DCAP containers failed.")
        raise Exception("Starting Dcap Failed!")


@logged_keyword
def attach_ue(ue_alias="UE"):
    log_info_to_console(f"Attaching UE {ue_alias}")
    taf_ue.attach_ue(ue_alias="UE")


@logged_keyword
def detach_ue(ue_alias="UE"):
    log_info_to_console(f"Detaching UE {ue_alias}")
    taf_ue.detach_ue(ue_alias="UE")


@logged_keyword
def dcap_stop_trace_and_download_logs(trace_id, scenario=None):
    if scenario:
        target_dir = f"{TEST_LOG_DIR}/{scenario}"
    else:
        target_dir = TEST_LOG_DIR
    log_info_to_console("Stopping DCAP trace")
    dcap.stop_trace(trace=trace_id)
    log_info_to_console("Downloading DCAP trace")
    trace_file = dcap.download_logs(trace=trace_id, target_dir=target_dir)
    log_info_to_console(f"Extracting DCAP trace to {target_dir}")
    extract_logs(trace_file)


def start_tcpdump_collection():
    ssh.send_command("tcpdump -i any sctp -w /tmp/tcpdump.pcap", connection="bts_ssh", timeout=30)


def stop_tcpdump_collection():
    ssh.send_command("killall tcpdump", connection="bts_ssh", timeout=30)


def collect_tcpdump(target_dir):
    Path(target_dir).mkdir(parents=True, exist_ok=True)
    ssh.download_file("/tmp/tcpdump.pcap", f"{target_dir}/tcpdump_ssh.pcap", connection="bts_ssh")


@logged_keyword
def attach_ue_and_gather_logs(
        scenario: Optional[str] = None, with_vonr: bool = False, wait_for_rrc_inactive: bool = False
):
    log_info_to_console("Starting Dcap Trace")
    trace_id = dcap.start_new_trace(mplane="10.44.224.11", log_profile=DCAP_PROFILE, force=True, skip_pre_check=True)
    start_tcpdump_collection()
    logged_sleep("After tracing start", 15)
    attach_ue(ue_alias="UE")
    if wait_for_rrc_inactive:
        logged_sleep("Ue to go into RRC Inactive", 15)
    else:
        logged_sleep("After ue attach", 10)
    if with_vonr:
        start_vonr()
    trigger_lcs()
    logged_sleep("After LCS trigger", 15)
    if with_vonr:
        stop_vonr()
    detach_ue(ue_alias="UE")
    if scenario:
        target_dir = f"{TEST_LOG_DIR}/{scenario}"
    else:
        target_dir = TEST_LOG_DIR
    stop_tcpdump_collection()
    collect_tcpdump(target_dir)
    dcap_stop_trace_and_download_logs(trace_id, scenario)


@logged_keyword
def start_gathering_pm_counters(test_case: str):
    with Admin5G() as counter_api:
        log_info_to_console("Waiting for next pm interval, to start pm gathering")
        return wait_for_next_pm_interval_and_get_counters(
            admin_connection=counter_api, counter_ids=PM_COUNTERS[test_case]["ids"], timeout=960
        )


@logged_keyword
def stop_gathering_pm_counters(initial_pm_data, test_case: str):
    with Admin5G() as counter_api:
        log_info_to_console("Waiting for next pm interval, to stop pm gathering")
        return wait_for_next_pm_interval_and_get_counters(
            admin_connection=counter_api,
            counter_ids=PM_COUNTERS[test_case]["ids"],
            timeout=960,
            reference_point=initial_pm_data,
        )


@logged_keyword
def get_last_pm_counter_values(counter, pm_counter_values):
    latest_value = sum([value for timestamp, value in pm_counter_values])
    logger.debug(f"Latest value of counter {counter} is {latest_value}")
    return latest_value


@logged_keyword
def parse_counter_data(counter_data_dict: dict):
    return {
        counter.split("/")[-1]: get_last_pm_counter_values(counter, counter_data_dict[counter])
        for counter in counter_data_dict
    }


@logged_keyword
def check_if_proper_counters_incremented(final_pm_data: dict, test_case: str):
    final_pm_data = parse_counter_data(final_pm_data)
    for counter in PM_COUNTERS[test_case]["incrementation"].keys():
        if counter in final_pm_data.keys():
            if final_pm_data[counter] != PM_COUNTERS[test_case]["incrementation"][counter]:
                logger.error(
                    f"Counter {counter} wasn't incremented by {PM_COUNTERS[test_case]['incrementation'][counter]}"
                )
                TEST_VERIFICATION_RESULTS["Counter Check"] = False
        else:
            logger.error(f"Counter {counter} wasn't found in final PM data")
            TEST_VERIFICATION_RESULTS["Counter Check"] = False


@logged_keyword
def verify_counters(initial_pm_data: dict, test_case: str):
    log_info_to_console(f"Verifying PM Counters for {test_case}")
    counters = stop_gathering_pm_counters(initial_pm_data, test_case)
    check_if_proper_counters_incremented(counters, test_case)


def tc01_cb009842_a_b1_activation():
    log_banner_to_console(f"Executing Test Case {TEST_NAME} Scenario with active Flag actUlNrEcIdTAdv")
    initial_pm_data = start_gathering_pm_counters("CB009842_A_B1")
    attenuate_cell("NRCEL-1", 0)
    attenuate_cell("NRCEL-2", 10)
    change_nls_parameters(measurement_quantitiees="TimingAdvanceNR", report_characteristics="OnDemand")
    attach_ue_and_gather_logs("CB009842_active")
    verify_scenario("CB009842_A_B1_Active", f"{TEST_LOG_DIR}/CB009842_active")
    log_banner_to_console(f"Executing Test Case {TEST_NAME} Scenario with inactive Flag actUlNrEcIdTAdv")
    change_nls_parameters(measurement_quantitiees="TimingAdvanceNR", report_characteristics="OnDemand")
    set_parameters_for_all_cells({"actUlNrEcIdTAdv": "false"})
    attach_ue_and_gather_logs("CB009842_inactive")
    verify_scenario("CB009842_A_B1_Inactive", f"{TEST_LOG_DIR}/CB009842_inactive")
    verify_counters(initial_pm_data, "CB009842_A_B1")
    verify_test_results()


def tc01_cb009842_a_ec2_rejection_of_periodic_request():
    log_banner_to_console(f"Executing Test Case {TEST_NAME}")
    initial_data = start_gathering_pm_counters("CB009842_A_EC2")
    change_nls_parameters(measurement_quantitiees="TimingAdvanceNR", report_characteristics="Periodic")
    attenuate_cell("NRCEL-1", 0)
    attenuate_cell("NRCEL-2", 10)
    attach_ue_and_gather_logs()
    verify_scenario("CB009842_A_EC2", TEST_LOG_DIR)
    verify_counters(initial_data, "CB009842_A_EC2")
    verify_test_results()


def test_teardown():
    log_banner_to_console(f"Executing Test Teardown {TEST_NAME}")
    teardown_steps = [
        add_scout_scf_id_to_test_data,
        teardown_nls_connection_and_restore_initial_values,
        dcap.teardown,
        admin_api.teardown,
        detach_ue,
        find_suspicious_prints_in_syslog,
    ]
    for teardown_step in teardown_steps:
        try:
            log_info_to_console(f"Execution of  teardown step: {teardown_step.__qualname__}")
            teardown_step()
        except Exception as step_exception:
            log_info_to_console(f"Exception during teardown step: {teardown_step.__qualname__}")
            logger.debug(f"Exception during teardown step : {step_exception}")
    attenuate_cell("NRCEL-1", 90)
    attenuate_cell("NRCEL-2", 90)
    attenuate_cell("NRCEL-3", 90)
    ssh.disconnect(connection="bts_ssh")


@logged_keyword
def trigger_lcs():
    trigger_cmd = f"curl -v http://{LMF_CONNECTION_DETAILS['hostname']}:9210 -d @{LMF_FILE_PATH}"
    log_info_to_console(f"Triggering LCS with cmd: {trigger_cmd}")
    try:
        ssh.connect_to(**LMF_CONNECTION_DETAILS)
        ssh.execute(trigger_cmd)
    except Exception as e:
        logger.error(f"Failed to trigger LCS: {e}")
        raise
    finally:
        ssh.disconnect()


@logged_keyword
def verify_pcap(pcap_file: str, scenario_vars: dict):
    filtered_packets = {
        field: packet
        for field in scenario_vars.keys()
        for packet in pcap.get_field_value_by_name(
            load_pcap_with_filters(pcap_file), field_name=field, attribute_name="showname"
        )
    }
    logger.debug(f"Filtered Packets per field value {filtered_packets}")
    missing_msgs_per_field = {}
    log_info_to_console(f"Checking if all expected msgs were found in pcap")
    for field, searched_msg in scenario_vars.items():
        log_info_to_console(f"Checking if msg with field {field} and {searched_msg} in value is in pcap")
        if field not in filtered_packets.keys() or searched_msg not in filtered_packets[field]:
            missing_msgs_per_field[field] = searched_msg
    if any(missing_msg for missing_msg in missing_msgs_per_field.values()):
        logger.error(f"Given msg weren't found in pcap! {missing_msgs_per_field}")
        TEST_VERIFICATION_RESULTS["Pcap Check"] = False
        return
    log_info_to_console("All expected msgs were found in pcap")
    TEST_VERIFICATION_RESULTS["Pcap Check"] = True


@logged_keyword
def load_pcap_with_filters(pcap_file: str):
    pcap_cmd = f'tshark -r {pcap_file} -Y \'{PCAP_FILTERS}\' -T pdml > {pcap_file.rsplit(".pcap")[0]}.pdml'
    return pcap.load_pcap_file(pcap_file, command_template=pcap_cmd)


@logged_keyword
def verify_test_results():
    if all(TEST_VERIFICATION_RESULTS.values()):
        log_info_to_console("Test passed")
        logger.debug(TEST_VERIFICATION_RESULTS)
    else:
        logger.error(f"Test failed!\n{TEST_VERIFICATION_RESULTS}")
        raise Exception("Test failed!")


@logged_keyword
def verify_scenario(
        scenario: str,
        log_dir: str,
):
    verify_pcap(f"{log_dir}/tcpdump.pcap", PCAP_MSGS[scenario])
    if SYSLOG_PRINTS.get(scenario):
        verify_btslog(f"{log_dir}/syslog.LOG", SYSLOG_PRINTS[scenario])


@logged_keyword
def verify_btslog(log_file: str, expected_msgs: list):
    log_info_to_console("Checking if all expected prints were found in btslog")
    missing_prints = {expected_print: True for expected_print in expected_msgs}
    with open(log_file, "r") as btslog:
        for line in btslog:
            for expected_print in missing_prints:
                if missing_prints[expected_print]:
                    if re.search(expected_print, line):
                        missing_prints[expected_print] = False
    if any(missing_prints.values()):
        logger.error(
            f"Some prints weren't found in btslog!:"
            f" {[syslog_print for syslog_print, found in missing_prints.items() if found]}"
        )
        TEST_VERIFICATION_RESULTS["Syslog Check"] = False
        return
    log_info_to_console("All expected prints were found in btslog")
    TEST_VERIFICATION_RESULTS["Syslog Check"] = True


def set_counter_interval_to_5min():
    log_info_to_console("Changing counter interval to 5min")
    with Admin5G() as api:
        admin_api.create_delta()
        admin_api.append_parameter_update_to_delta(
            dist_name=f"{BTS_DISTNAME}/NRPMRNL-1", parameter="miNrNGCC", value="5min"
        )
        admin_api.append_parameter_update_to_delta(
            dist_name=f"{BTS_DISTNAME}/NRPMRNL-1", parameter="miNrF1CC", value="5min"
        )
        admin_api.append_parameter_update_to_delta(
            dist_name=f"{BTS_DISTNAME.split('/')[0]}/MNL-1/MNLENT-1/PMCADM-1",
            parameter="reportingIntervalPm",
            value="5min",
        )
        admin_api.perform_delta_recommissioning(delta_file=admin_api.get_delta(), connection=api)
        admin_api.remove_all_delta_id()


def set_counter_interval_to_15min():
    log_info_to_console("Changing counter interval to 15min")
    with Admin5G() as api:
        admin_api.create_delta()
        admin_api.append_parameter_update_to_delta(
            dist_name=f"{BTS_DISTNAME}/NRPMRNL-1", parameter="miNrNGCC", value="15min"
        )
        admin_api.append_parameter_update_to_delta(
            dist_name=f"{BTS_DISTNAME}/NRPMRNL-1", parameter="miNrF1CC", value="15min"
        )
        admin_api.append_parameter_update_to_delta(
            dist_name=f"{BTS_DISTNAME.split('/')[0]}/MNL-1/MNLENT-1/PMCADM-1",
            parameter="reportingIntervalPm",
            value="15min",
        )
        admin_api.perform_delta_recommissioning(delta_file=admin_api.get_delta(), connection=api)
        admin_api.remove_all_delta_id()


def gather_snapshot():
    with Admin5G() as api:
        log_info_to_console("Collecting snapshot!")
        admin_api.get_snapshot(f"{TEST_LOG_DIR}/snapshot.zip", connection=api)


@logged_keyword
def start_vonr(ue_alias: str = "UE"):
    log_info_to_console("Starting Voice Call to 0105 for 60s")
    taf_ue.start_voice_call("VC", ue_alias, "0105", duration="60s")


@logged_keyword
def stop_vonr():
    log_info_to_console("Stopping Voice Call!")
    taf_ue.stop_voice_call("VC")


def tc05_cb009842_a_b6_interaction_with_ss_rsrq_quantity_during_vonr_call():
    log_banner_to_console(f"Executing Test Case {TEST_NAME}")
    change_nls_parameters(
        measurement_quantitiees="TimingAdvanceNR,SS_RSRP,SS_RSRQ,Cell_ID", report_characteristics="OnDemand"
    )
    initial_pm_data = start_gathering_pm_counters("CB009842_A_B6")
    attenuate_cell("NRCEL-1", 0)
    attenuate_cell("NRCEL-2", 10)
    attach_ue_and_gather_logs(with_vonr=True)
    verify_scenario("CB009842_A_B6", TEST_LOG_DIR)
    verify_counters(initial_pm_data, "CB009842_A_B6")
    verify_test_results()


def tc09_cb009842_a_b3_alt1_nr_tadv_request_with_cb008225_inactive_ue_state_with_ss_rsrp_quantity():
    log_banner_to_console(f"Executing Test Case {TEST_NAME}")
    change_nls_parameters(
        measurement_quantitiees="TimingAdvanceNR,SS_RSRP,SS_RSRQ,Cell_ID", report_characteristics="OnDemand"
    )
    initial_pm_data = start_gathering_pm_counters("CB009842_A_B3")
    attenuate_cell("NRCEL-1", 0)
    attenuate_cell("NRCEL-2", 10)
    attach_ue_and_gather_logs(wait_for_rrc_inactive=True)
    verify_scenario("CB009842_A_B3", TEST_LOG_DIR)
    verify_rrc_inactive_scenario(f"{TEST_LOG_DIR}/tcpdump_ssh.pcap")
    verify_counters(initial_pm_data, "CB009842_A_B3")
    verify_test_results()


def activate_rrc_inactive_flag():
    log_info_to_console("Activating RRC Inactive Flag")
    with Admin5G() as api:
        admin_api.create_delta()
        admin_api.append_parameter_update_to_delta(
            dist_name=BTS_DISTNAME, parameter="actRrcInactState", value="intra-gNB"
        )
        admin_api.perform_delta_recommissioning(delta_file=admin_api.get_delta(), connection=api)
        admin_api.remove_all_delta_id()


def deactivate_rrc_inactive_flag():
    log_info_to_console("Deactivating RRC Inactive Flag")
    with Admin5G() as api:
        admin_api.create_delta()
        admin_api.append_parameter_update_to_delta(dist_name=BTS_DISTNAME, parameter="actRrcInactState", value="none")
        admin_api.perform_delta_recommissioning(delta_file=admin_api.get_delta(), connection=api)
        admin_api.remove_all_delta_id()


def logged_sleep(sleep_reason, seconds):
    log_info_to_console(f"Waiting {seconds}s : {sleep_reason}")
    time.sleep(seconds)


@logged_keyword
def verify_rrc_inactive_scenario(pcap_file: str):
    pdml_file = pcap_file.rsplit(".pcap")[0] + ".pdml"
    load_pcap_with_filters(pcap_file)
    try:
        pdml.check_msc(pdml_file, ["e1ap", "f1ap", "ngap", "nr-rrc"], RRC_INACTIVE_SEQUENCE)
    except AssertionError:
        logger.error("RRC Inactive sequence wasn't found in pcap")
        TEST_VERIFICATION_RESULTS["RRC Inactive Sequence"] = False
        return
    log_info_to_console("RRC Inactive proper sequence was found in pcap!")
    TEST_VERIFICATION_RESULTS["RRC Inactive Sequence"] = True
