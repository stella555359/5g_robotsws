import re
import shutil
import subprocess
import tarfile
import time
from collections.abc import Callable
from functools import wraps

from robot import __version__ as robot_version
from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn
from robot.running import EXECUTION_CONTEXTS
from taf.collectors.btslog import btslog
from taf.config.scf import scf
from taf.hw.rf_attenuator import rf_attenuator
from taf.rfrl.bts.operations import verify_bts_is_up_and_on_air
from taf.rfrl.utilities.robot.general import get_builtin_instance
from taf.rfrl.utilities.test_config import set_test_case_log_path
from taf.rfrl.utilities.logger.custom_logger import log_info_to_console, log_banner_to_console
from taf.rfrl.utilities.robot.RobotWrapper import RobotWrapper
from taf.sbts.oam.coam.admin import admin
from taf.transport.ssh import ssh
from taf.ul.alarms_watchdog import alarms_watchdog

from testsuite.Wroclaw.RRM.VRF_WRO2_T08.features.classical.CB013773.resources.test_constants import *
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.allowed_alarms import allowed_alarms
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.dcap import dcap
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.admin import Admin5G
from testsuite.Wroclaw.RRM.resources.scout_report import add_scout_scf_id_to_test_data
from testsuite.Wroclaw.RRM.resources.syslog_checker import syslog_checker

admin_api = admin()
taf_ue = get_builtin_instance("taf.ue")
scf_manager = scf()
_btslog = btslog()
_builtin = BuiltIn()
_watchdog = alarms_watchdog()
_syslog_checker = syslog_checker()
ssh = ssh()
attenuator = rf_attenuator()
TEST_LOG_DIR: str
TEST_NAME: str


def logged_keyword(function: Callable) -> Callable:
    """
    A decorator that logs the execution of a function, including its arguments and return value.
    It also logs the Robot Framework version if the execution context is current.

    :param function: The function to be decorated.
    :type function: Callable
    :return: The wrapped function with logging capabilities.
    :rtype: Callable
    """

    @wraps(function)
    def logged_function(*args, **kwargs):
        """
        The wrapper function that logs the function name, arguments, and return value.

        :param args: Positional arguments passed to the function.
        :param kwargs: Keyword arguments passed to the function.
        :return: The result of the function execution.
        """
        arguments = " | ".join([f"{arg}" for arg in args] +
                               [f"{kwarg}={value}" for kwarg, value in kwargs.items()])
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


def create_syslog_collector(filename: str = "BtsLog.tgz") -> None:
    """
        Creates a syslog collector using the specified filename for the target log file.

        :param filename: The name of the target log file to be created. Defaults to "BtsLog.tgz".
        :type filename: str
        :return: None
    """
    executor = {"host": "10.42.53.76",
                "user": "ute",
                "password": "ute"}
    _btslog.create_btslog_collector(name="btslog", target_file_name=filename,
                                    executor=executor)
    _btslog.setup_collectors("btslog")


def start_syslog() -> None:
    """
    Starts the syslog collectors.
    :return: None
    """
    _btslog.start_collectors("btslog")
    _btslog.set_global_alias("btslog")


def stop_and_collect_syslog() -> None:
    """
    Stops the syslog collectors.
    :return: None
    """
    _btslog.stop_collectors("btslog")
    _btslog.collect_collectors("btslog", target_dir=TEST_LOG_DIR)
    _btslog.teardown_collectors("btslog")
    _extract_file()


def _extract_file() -> None:
    with tarfile.open(f"{TEST_LOG_DIR}/btslog/BtsLog.tgz", 'r') as tar:
        tar.extractall(TEST_LOG_DIR + "/btslog/")


@logged_keyword
def setup_dcap() -> None:
    """
    Sets up the DCAP connection and stops any running traces without status details.

    :return: None

    This function logs the connection attempt to DCAP, checks if the DCAP controller is started,
    and connects using predefined connection parameters. It retrieves all trace information and
    stops traces that are running but lack status details.

    """
    log_info_to_console("Connecting to DCAP")
    if not _is_dcap_controller_started():
        start_dcap_controller()
    dcap.connect_to(**DCAP_CONNECTION)
    current_traces = dcap._api.get_all_trace_info(connection="dcap_collector")
    for trace in current_traces:
        if trace.get("status") == "running" and trace.get("status_details") == "":
            dcap.stop_trace(trace.get("id"))


@logged_keyword
def start_dcap_controller() -> None:
    """
    Starts the DCAP controller and performs health checks to ensure all containers are running successfully.

    :return: None

    This function initiates the DCAP controller using a subprocess call to the `utf_lab-controller`.
    It logs the start status and checks the health of the DCAP containers multiple times. If the containers
    fail to start, it raises an exception.
    """
    log_info_to_console("Dcap controller starting")
    start_status = subprocess.run(["utf_lab-controller", "start"], stdout=subprocess.PIPE,
                                  stderr=subprocess.PIPE)
    logger.debug(f"DCAP Controller start status: {start_status.stdout.decode('utf-8')}\n"
                 f" {start_status.stderr.decode('utf-8')}")
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


def _is_dcap_controller_started():
    log_info_to_console("Checking DCAP Controller status.")
    health_check_status = subprocess.run(["utf_lab-controller", "status"], stdout=subprocess.PIPE,
                                         stderr=subprocess.PIPE)
    logger.debug(f"DCAP Controller status: {health_check_status.stdout.decode('utf-8')}\n"
                 f" {health_check_status.stderr.decode('utf-8')}")
    if health_check_status.returncode == 0:
        return True


@logged_keyword
def dcap_stop_trace_and_download_logs(trace_id) -> None:
    """
    Stops a DCAP trace and downloads the associated logs to a specified directory.

    :param trace_id: The identifier of the trace to be stopped and downloaded.
    :type trace_id: str
    :return: None
    """
    log_info_to_console("Stopping DCAP trace.")
    dcap.stop_trace(trace=trace_id)
    log_info_to_console("Downloading DCAP trace.")
    dcap.download_logs(trace=trace_id, target_dir=TEST_LOG_DIR)


@logged_keyword
def attenuate_cell(cell, attenuation: int, step: int | None = None) -> bool:
    """
    Attenuates the specified cell to a given decibel level, optionally using a step value.

    :param cell: The identifier of the cell to be attenuated.
    :type cell: str
    :param attenuation: The target attenuation level in decibels.
    :type attenuation: int
    :param step: The step value for gradual attenuation. If not provided, attenuation is applied directly.
    :type step: int | None
    :return: True if the attenuation process completes successfully.
    :rtype: bool
    """
    log_info_to_console(f"Attenuating cell {cell} to {attenuation} dB.")
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
def initialize_attenuator() -> None:
    """
    Initializes the attenuator and sets attenuation.

    :return: None
    """
    log_info_to_console("Initializing attenuator.")
    attenuator.setup_attenuator(ATTENUATOR_CONFIG)
    attenuate_cell("NRCELL-210", 90)
    attenuate_cell("NRCELL-211", 90)
    attenuate_cell("NRCELL-212", 90)
    attenuate_cell("NRCELL-213", 90)


@logged_keyword
def prepare_ue() -> None:
    """
    Prepares the User Equipment (UE) for test execution.

    :return: None
    """
    log_info_to_console(f"Preparing UE with {UE.capabilities} for test execution.")
    taf_ue.require_ue(ue_alias="UE", capabilities=UE.capabilities)
    taf_ue.detach_ue(ue_alias="UE")


@logged_keyword
def set_parameters_for_all_cells(parameters_dict: dict) -> None:
    """
    Updates parameters for all cells based on the provided dictionary and performs delta recommissioning.

    :param parameters_dict: A dictionary containing parameter names and their corresponding values to be updated.
    :type parameters_dict: dict
    :return: None
    """
    admin_api.create_delta()
    for parameter, value in parameters_dict.items():
        log_info_to_console(f"Changing {parameter} value to {value}")
        for cell in CELLS:
            admin_api.append_parameter_update_to_delta(dist_name=f"{BTS_DISTNAME}/{cell}",
                                                       parameter=parameter,
                                                       value=value)
    admin_api.perform_delta_recommissioning(delta_file=admin_api.get_delta())
    admin_api.remove_all_delta_id()


def set_smoothing_effect(cell: str, mode: str) -> None:
    """
     Sets the smoothing effect for a specified cell and updates the parameter if it differs from the current setting.

     :param cell: The identifier of the cell for which the smoothing effect is to be set.
     :type cell: str
     :param mode: The mode to set for the smoothing effect.
     :type mode: str
     :return: None
     """
    SMOOTHING_EFFECT[0]["value"][0]["smoothingEffect"] = mode
    if mode != get_smoothing_effect_from_bts():
        log_info_to_console(f"Setting 'smoothingEffect' parameter to '{mode}'.")
        admin_api.perform_object_recommissioning(dist_name=f"{BTS_DISTNAME}/{cell}",
                                                 parameter=SMOOTHING_EFFECT,
                                                 operation='update',
                                                 timeout=300)
    _logged_sleep("For next EIRP window.", 60)


@logged_keyword
def get_backup_scf() -> None:
    """
    Retrieves the current SCF file and saves it as a backup.
    :return: None
    """
    admin_api.get_current_scf_file(f"{TEST_LOG_DIR}/backup_scf.xml")


@logged_keyword
def set_test_variables() -> None:
    """
    Sets global test variables including log directory and test name.
    :return: None
    """
    global TEST_LOG_DIR
    TEST_LOG_DIR = set_test_case_log_path()
    global TEST_NAME
    TEST_NAME = get_builtin_value("TEST_NAME")
    global TEST_VERIFICATION_RESULTS
    TEST_VERIFICATION_RESULTS = {}


@logged_keyword
def clear_test_log_dir() -> None:
    """
    Clears the test log directory.
    :return: None
    """
    try:
        shutil.rmtree(TEST_LOG_DIR)
    except FileNotFoundError:
        pass


def setup_bts_ssh_connection() -> None:
    """
    Sets up an SSH connection to the BTS.
    :return: None
    """
    ssh.connect_to("192.168.255.129", "toor4nsn", "oZPS0POrRieRtu", alias="bts_ssh")


@logged_keyword
def attach_ue(ue_alias: str = "UE") -> None:
    """
     Attaches the User Equipment (UE) to the network.

     :param ue_alias: The alias of the UE to be attached.
     :type ue_alias: str
     :return: None

    """
    log_info_to_console(f"Attaching UE {ue_alias}")
    taf_ue.attach_ue(ue_alias="UE")


@logged_keyword
def detach_ue(ue_alias: str = "UE") -> None:
    """
    Detaches the User Equipment (UE) from the network.

    :param ue_alias: The alias of the UE to be detached.
    :type ue_alias: str
    :return: None
    """
    log_info_to_console(f"Detaching UE {ue_alias}")
    taf_ue.detach_ue(ue_alias="UE")


@logged_keyword
def verify_test_results() -> None:
    """
    This function checks the test verification results and logs whether the test passed or failed.
    It raises an exception if the test fails.

    :return: None
    """
    if all(TEST_VERIFICATION_RESULTS.values()):
        log_info_to_console("Test passed")
        logger.debug(TEST_VERIFICATION_RESULTS)
    else:
        logger.error(f"Test failed!\n{TEST_VERIFICATION_RESULTS}")
        raise Exception("Test failed!")


def gather_snapshot() -> None:
    """
    Collects a snapshot from BTS.

    :return: None
    """
    with Admin5G() as api:
        log_info_to_console("Collecting snapshot!")
        admin_api.get_snapshot(f"{TEST_LOG_DIR}/snapshot.zip", connection=api)


def _logged_sleep(sleep_reason: str, seconds: int) -> None:
    log_info_to_console(f"Waiting {seconds}s: {sleep_reason}")
    time.sleep(seconds)


@logged_keyword
def start_logs_collection() -> None:
    """
    Initiates the collection of logs, including UTF and syslog.
    :return: None
    """
    global dcap_trace_id

    start_dcap_controller()
    dcap_trace_id = dcap.start_new_trace(mplane="10.44.224.9", log_profile=DCAP_PROFILE, force=True,
                                         skip_pre_check=True)
    create_syslog_collector()
    start_syslog()


@logged_keyword
def stop_logs_collection() -> None:
    """
    Stops the collection of logs and downloads the collected data.
    :return: None
    """
    stop_and_collect_syslog()
    dcap_stop_trace_and_download_logs(dcap_trace_id)


@logged_keyword
def get_smoothing_effect_from_bts() -> str:
    """
    Retrieves the smoothing effect parameter from the BTS for a specific cell.
    :return: The current smoothing effect setting.
    :rtype: str.
    """
    eirp_params = admin_api.get_parameter_by_distname(f"{BTS_DISTNAME}/NRCELL-210",
                                                      parameter_list=["eirpControl"])
    return eirp_params[0].get('parameters').get('eirpControl')[0].get('smoothingEffect')


@logged_keyword
def perform_data_transfer_and_collect_stats() -> dict:
    """
    Performs data transfer and collects throughput statistics over defined cycles.

    :return: A dictionary containing throughput statistics for each cycle.
    :rtype: dict
    """
    tput_stats = {}
    cycles = {
        'cycle_1': (0, 60),
        'cycle_2': (60, 120),
        'cycle_3': (120, 180)
    }
    log_info_to_console(f"Data transfer in progress.")
    try:
        taf_ue.start_data_transfer(dt_name="DT_DL", ue_alias="UE", direction="DL", duration="180s",
                                   throughput="200Mbits/sec", packet_size='1400', protocol="udp")
        taf_ue.await_data_transfer_finish("DT_DL")
        for cycle_name, (omit, end) in cycles.items():
            tput_stats_kbps = re.split(r"[,;]", taf_ue.get_data_transfer_statistics(dt_name="DT_DL",
                                                                                    omit=omit,
                                                                                    end=end))
            tput_stats[cycle_name] = _convert_kbps_to_mbits(tput_stats_kbps)
            log_info_to_console(
                f"{cycle_name} Tput: Avg:{tput_stats[cycle_name][0]} Mbits/sec, "
                f"Min:{tput_stats[cycle_name][1]} Mbits/sec, "
                f"Max:{tput_stats[cycle_name][2]} Mbits/sec")
        return tput_stats
    except Exception as e:
        raise ValueError(f"No throughput statistics were collected during the test: {e}")


def _convert_kbps_to_mbits(tput_stats_kbps: list) -> list:
    return [round(float(value) / 1000000, 1) for value in tput_stats_kbps]


@logged_keyword
def verify_throughput_stats(tput_stats_feature_off: dict, tput_stats_feature_on: dict) -> None:
    """
    Verifies throughput statistics by comparing feature-off and feature-on scenarios.

    :param tput_stats_feature_off: Throughput statistics with the feature turned off.
    :type tput_stats_feature_off: dict
    :param tput_stats_feature_on: Throughput statistics with the feature turned on.
    :type tput_stats_feature_on: dict
    :return: None

    This function compares throughput statistics for different scenarios and logs the verification results.
    It updates the global `TEST_VERIFICATION_RESULTS` dictionary based on the verification outcome.
    """
    global tput_stats_off, tput_stats_on
    tput_stats_off = tput_stats_feature_off
    tput_stats_on = tput_stats_feature_on

    avg_tput_verdict = _verify_avg_tput_stats()
    max_tput_verdict = _verify_max_tput_stats()
    curve_tput_verdict = _verify_curve_tput_stats()
    if all([avg_tput_verdict, max_tput_verdict, curve_tput_verdict]):
        log_info_to_console("All throughput verifications were successful.")
        TEST_VERIFICATION_RESULTS['Throughput Stats Check'] = True
        return
    logger.error(f"Not all throughput verifications were successful. Avg: {avg_tput_verdict}, "
                 f"Max: {max_tput_verdict}, Curve: {curve_tput_verdict}", )
    TEST_VERIFICATION_RESULTS['Throughput Stats Check'] = False


def _verify_avg_tput_stats() -> bool:
    feature_off_result = _check_tput_each_cycle(tput_stats_off)
    feature_on_result = _check_tput_each_cycle(tput_stats_on)
    log_info_to_console(f"Avg throughput verification - Feature OFF/ON: {feature_off_result}/{feature_on_result}.")
    return all([feature_off_result, feature_on_result])


def _check_tput_each_cycle(cycles_dict: dict) -> bool:
    target_value = 72
    deviation_percentage = 0.05
    lower_bound = target_value * (1 - deviation_percentage)
    upper_bound = target_value * (1 + deviation_percentage)

    for _, tput_values in cycles_dict.items():
        avg_tput = tput_values[0]
        if not (lower_bound <= avg_tput <= upper_bound):
            return False
    return True


def _verify_max_tput_stats() -> bool:
    feature_off_result = _verify_max_tput_stats_feature_off()
    feature_on_result = _verify_max_tput_stats_feature_on()
    return all([feature_off_result, feature_on_result])


def _verify_curve_tput_stats() -> bool:
    tput_curve_verdict = _verify_tput_curve()
    log_info_to_console(f"Throughput curve verification: {tput_curve_verdict}.")
    return tput_curve_verdict


def _verify_max_tput_stats_feature_off() -> bool:
    target_value = 200
    deviation_percentage = 0.1
    lower_bound = target_value * (1 - deviation_percentage)
    upper_bound = target_value * (1 + deviation_percentage)

    for _, tput_values in tput_stats_off.items():
        max_tput = tput_values[2]
        if not (lower_bound <= max_tput <= upper_bound):
            return False
    return True


def _verify_max_tput_stats_feature_on() -> bool:
    target_value = 200
    deviation_percentage = 0.1

    for cycle, tput_values in enumerate(tput_stats_on.values()):
        lower_bound = target_value * (1 - deviation_percentage)
        upper_bound = target_value * (1 + deviation_percentage)
        max_tput = tput_values[2]
        if not (lower_bound <= max_tput <= upper_bound):
            return False
        if cycle == 0:
            target_value *= 0.7
        elif cycle == 1:
            target_value *= 0.5
    return True


def _verify_tput_curve() -> bool:
    for cycle in tput_stats_on.keys():
        log_info_to_console(f"Cycle {cycle}")
        feature_on_values = tput_stats_on[cycle]
        feature_off_values = tput_stats_off[cycle]

        for index in range(20, 40):
            if feature_on_values[index] <= feature_off_values[index]:
                return False
    return True


def test_setup() -> None:
    """
    Sets test variables, clears the test log directory, and prepares the test environment
    by initializing DCAP, verifying BTS status, and setting up SSH connections.

    :return: None
    """
    set_test_variables()
    clear_test_log_dir()
    log_banner_to_console(f"Executing Test Setup {TEST_NAME}.")
    setup_dcap()
    _watchdog.watch_alarms(allowed_alarms=allowed_alarms)
    verify_bts_is_operational()
    initialize_attenuator()
    prepare_ue()
    admin_api.setup_admin()
    setup_bts_ssh_connection()


def test_teardown() -> None:
    """
    Performs teardown steps such as detaching UE, verifying BTS status, collecting logs,
    and attenuating cells. It handles exceptions during each step and logs the outcome.

    :return: None
    """
    log_banner_to_console(f"Executing Test Teardown {TEST_NAME}")
    teardown_steps = [admin_api.teardown, detach_ue, verify_bts_is_operational,
                      collect_logs_and_close_connections, _watchdog.stop_watching_alarms,
                      add_scout_scf_id_to_test_data, find_suspicious_prints_in_syslog]
    for teardown_step in teardown_steps:
        try:
            log_info_to_console(f"Execution of  teardown step: {teardown_step.__qualname__}")
            teardown_step()
        except Exception as step_exception:
            log_info_to_console(f"Exception during teardown step: {teardown_step.__qualname__}")
            logger.debug(f"Exception during teardown step : {step_exception}")
    attenuate_cell("NRCELL-210", 90)
    attenuate_cell("NRCELL-211", 90)
    attenuate_cell("NRCELL-212", 90)
    attenuate_cell("NRCELL-213", 90)
    ssh.disconnect(connection="bts_ssh")


@logged_keyword
def collect_logs_and_close_connections() -> None:
    """
    Collects logs and closes connections if the test fails.

    :return: None
    """
    _builtin.run_keyword_if_test_failed("gather_snapshot")
    _builtin.run_keyword_if_test_failed("_recovery_logs")


@logged_keyword
def _recovery_logs() -> None:
    _builtin.run_keyword_and_ignore_error("stop_and_collect_syslog")


@logged_keyword
def verify_bts_is_operational() -> None:
    """
    Verifies that the BTS is operational and checks for detected alarms.

    :return: None
    """
    log_info_to_console(f"Verifying the status of BTS.")
    verify_bts_is_up_and_on_air()
    _watchdog.check_detected_alarms()


def tc01_cb013773_a_b1_lyapunov_smoothing_activated() -> None:
    """
    Performs the test case by starting log collection, setting smoothing effects, performing data transfer,
    verifying throughput statistics, and stopping log collection.

    :return: None
    """
    log_banner_to_console(f"Executing Test Case {TEST_NAME}.")
    start_logs_collection()
    set_smoothing_effect("NRCELL-210", "deactivated")
    attenuate_cell("NRCELL-210", 0)
    attach_ue(ue_alias="UE")
    tput_stats_feature_off = perform_data_transfer_and_collect_stats()
    set_smoothing_effect("NRCELL-210", "high")
    tput_stats_feature_on = perform_data_transfer_and_collect_stats()
    verify_throughput_stats(tput_stats_feature_off, tput_stats_feature_on)
    stop_logs_collection()
    verify_test_results()


def find_suspicious_prints_in_syslog() -> None:
    """Finds suspicious prints in syslog files for a test that passed."""
    _builtin.run_keyword_if_test_passed("_syslog_checker.find_suspicious_logs")
