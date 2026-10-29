"""
:copyright: Nokia Networks
:author: Justyna Balcerzak, Mateusz Adamek
:maintainer: Justyna Balcerzak, Mateusz Adamek
:contact: justyna.balcerzak@nokia.com, mateusz.adamek@nokia.com
"""
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.file_management \
    import get_latest_file
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.common_airphone import *
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.common_gnb import *
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.common_wts import (
    start_wts_and_wait_for_ready_state,
    copy_egate_console_log_to_specified_dir
)
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.utilities import (
    logger_debug, logger_info, logger_console, logger_console_info, logger_warning
)
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.swconfig \
    import GnbSwconfigManager, GnbFileManager
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.pm_counters \
    import get_measurement_period_from_scf
from robot.libraries.OperatingSystem import OperatingSystem
from ta5g_interface_tools import ta5g_interface_tools
from robot.errors import ExecutionFailed
from time import sleep, time
from variables import *
import netifaces
import json
import os
import re
import datetime
import math


def set_variables_based_on_deployment_and_release():
    capacity_unit = get_capability_unit_name()
    release = get_gnb_build_release(convert_to_trunk=True)
    BuiltIn().set_suite_variable("${UNIT_NAME}", capacity_unit)
    BuiltIn().set_suite_variable("${RELEASE}", release)


def get_test_prefix():
    tc_name = ta5g_interface_tools().get_robot_test_name()
    match = re.search(r'CB00(?P<feature>7227)-(?P<fsplit>\w)#(?P<tc>\d+)_.*', tc_name)
    prefix = "{}_{}{}".format(match.group("feature"), match.group("fsplit"), match.group("tc")) if match else tc_name
    BuiltIn().set_test_variable("${TEST_PREFIX}", prefix)
    return prefix


def get_test_prefix_number():
    test_prefix = get_test_prefix()
    return test_prefix[5::]


def add_rdL2HiPcmdTraceReportEnabled_flag_to_swconfig():
    flags = ['0x5A00A4=1']
    ensure_flags_existence_in_swconfig(flags=flags)


def ensure_gnb_files_flags_are_in_order():
    ensure_syslog_flags_existence_in_swconfig()
    ensure_cplane_flags_existence_in_swconfig()
    ensure_cp_runtime_ini_has_LoggingSeverity_set_on_trace()
    GnbSwconfigManager().log_swconfig_contents()


def adjust_parameters_using_delta(delta):
    perform_recomissioning_with_delta(path_to_delta=json.dumps(delta))


def cleanup_parameters_after_testcase(delta):
    adjust_parameters_using_delta(delta)


def copy_default_wts_config_from_current_deployment():
    wts_config_filename = "wts_{}.cfg".format(get_test_prefix())
    wts_config_path = os.path.join(EPCSIM_DIR_PATH, wts_config_filename)
    OperatingSystem().copy_file(source=DEFAULT_WTS_CONFIG_PATH, destination=wts_config_path)
    BuiltIn().set_test_variable("${WTS_CONFIG_PATH}", wts_config_path)
    return wts_config_path


def copy_wts_cfg_file_to_output_dir(wts_config_path=None, subdir="wts/"):
    output_dir = BuiltIn().get_variable_value("${OUTPUT_DIR}")
    if not wts_config_path:
        wts_config_path = BuiltIn().get_variable_value("${WTS_CONFIG_PATH}")
    if not subdir.endswith('/'):
        subdir += '/'
    OperatingSystem().copy_file(source=wts_config_path, destination=os.path.join(output_dir, subdir))


def setup_radiohead_and_wts_and_wait_for_mibsib_wrapper(
        wts_config_path,
        sib1_reception_dict,
        skip_reset=False,
        max_retries=4,
        edaemon_port=22222,
        egate_timeout=720
):
    ru_tries = mib_sib_tries = 0
    ru_tries_max = mib_sib_tries_max = max_retries
    while ru_tries < ru_tries_max and mib_sib_tries < mib_sib_tries_max:
        if ru_tries != 0 or mib_sib_tries != 0:
            logger_console_info("I will restart environment preparation")
        try:
            reset_units_and_wait_for_radio_head_online(skip_reset=skip_reset)
            start_wts_and_wait_for_ready_state(
                wts_config_filename=wts_config_path,
                sib_reception_dict=sib1_reception_dict,
                edaemon_port=edaemon_port,
                timeout=egate_timeout
            )
        except RadioHeadTimeoutException:
            logger_warning("RadioHeadTimeoutException occurred")
            ru_tries += 1
        except (ValueError, ExecutionFailed) as e:
            logger_warning("MibSibAcquisitionFailed exception occurred")
            ta5g_egate_instance = BuiltIn().get_library_instance('ta5g_egate')
            ta5g_egate_instance._ute_wtssim_instance.teardown_all_aliases_for_wts()
            mib_sib_tries += 1
        else:
            break

        if skip_reset is True:
            if ru_tries > 0:
                raise RadioHeadTimeoutException("RadioHeadTimeoutException occurred")
            if mib_sib_tries > 0:
                raise MibSibAcquisitionFailed("MIB-SIB Acquisition failed")

        if ru_tries >= ru_tries_max:
            raise RadioHeadTimeoutException("RadioHeadTimeoutException occurred over {} times".format(ru_tries_max))
        elif mib_sib_tries >= mib_sib_tries_max:
            raise MibSibAcquisitionFailed("MIB-SIB Acquisition failed over {} retries".format(mib_sib_tries))


def decide_on_wts_config_file_source(wts_config_path):
    if wts_config_path:
        OperatingSystem().copy_file(source=wts_config_path, destination=EPCSIM_DIR_PATH)
    else:
        wts_config_path = copy_default_wts_config_from_current_deployment()
    return wts_config_path


def add_nsa_specific_addresses():
    add_ip_addr_on_vm("10.0.1.131/24", "eth3")
    add_ip_addr_on_vm("10.0.1.132/24", "eth3")
    add_ip_addr_on_vm("10.0.1.133/24", "eth3")
    add_ip_addr_on_vm("10.0.1.134/24", "eth3")
    add_ip_addr_on_vm("10.0.1.135/24", "eth3")
    add_ip_addr_on_vm("10.0.1.136/24", "eth3")
    add_ip_addr_on_vm("10.0.1.137/24", "eth3")


def add_additional_specific_addresses():
    add_ip_addr_on_vm("10.0.2.1/24", "eth4")
    add_ip_addr_on_vm("10.0.2.2/24", "eth4")
    add_ip_addr_on_vm("10.0.2.3/24", "eth4")
    add_ip_addr_on_vm("10.0.2.4/24", "eth4")
    add_ip_addr_on_vm("10.0.2.5/24", "eth4")
    add_ip_addr_on_vm("10.0.3.151/24", "eth3")
    add_ip_addr_on_vm("10.0.3.153/24", "eth3")
    add_ip_addr_on_vm("10.0.1.112/24", "eth3")
    add_ip_addr_on_vm("10.0.1.121/24", "eth3")
    add_ip_addr_on_vm("192.168.6.252/24", "eth2")


def start_collecting_logs(prefix=""):
    log_dirpath = ta5g_interface_tools().get_robot_output_dir()
    if not prefix:
        prefix = get_test_prefix()
    collect_scf_file(prefix="before", subdir=prefix, name=prefix)
    ta5g_syslog = BuiltIn().get_library_instance('ta5g_syslog')
    ta5g_syslog.start_syslog_for_enb(logs_dirpath=log_dirpath + '/' + prefix,
                                     log_filename_prefix="syslog_gnb_{}_".format(prefix))
    setup_tshark_for_conventional_pcap()
    setup_tshark_for_l2_logs()
    sleep(2)


def start_syslog_logs(prefix=""):
    log_dirpath = ta5g_interface_tools().get_robot_output_dir()
    if not prefix:
        prefix = get_test_prefix()
    ta5g_syslog = BuiltIn().get_library_instance('ta5g_syslog')
    ta5g_syslog.start_syslog_for_enb(logs_dirpath=log_dirpath + '/' + prefix,
                                     log_filename_prefix="syslog_gnb_{}_".format(prefix))
    sleep(2)


def teardown_syslog_logs():
    ta5g_syslog = BuiltIn().get_library_instance('ta5g_syslog')
    ta5g_syslog.collect_syslog_results()
    ta5g_syslog.teardown_all_aliases_for_syslog()


def teardown_collecting_logs():
    ta5g_tshark = BuiltIn().get_library_instance('ta5g_tshark')
    ta5g_syslog = BuiltIn().get_library_instance('ta5g_syslog')
    ute_tshark = BuiltIn().get_library_instance('ute_tshark')
    ta5g_egate = BuiltIn().get_library_instance("ta5g_egate")
    ta5g_tshark.stop_tcpdump_on_remote_interface()
    ute_tshark.teardown_all_aliases_for_tshark()
    ta5g_syslog.collect_syslog_results()
    ta5g_syslog.teardown_all_aliases_for_syslog()
    ta5g_egate._ute_wtssim_instance.teardown_all_aliases_for_wts()
    test_prefix = get_test_prefix()
    copy_egate_console_log_to_specified_dir(subdirectory=test_prefix, prefix=test_prefix)
    collect_scf_file(prefix="after", subdir=test_prefix, name=test_prefix)


def change_rdL2LoTraceEnabled_rad_parameters(value=1):
    change_bts_rad_parameters(component=87, params="34:{}".format(value))
    sleep(2)


def change_rdPdcpPcmdTraceReportEnabled_rad_parameter(value=1):
    change_bts_rad_parameters(component=90, params="165:{}".format(value))
    sleep(2)


def read_json(delta_path):
    with open(delta_path) as user_file:
        parsed_json = json.load(user_file)
        return parsed_json


def change_delta_parameter(delta, distName, parameterName, value):
    for param in delta:
        if param["distName"] == distName:
            for param_elem in param["parameters"]:
                if param_elem["parameterName"] == parameterName:
                    old_value = param_elem["value"]
                    param_elem["value"] = value
                    new_value = param_elem["value"]
                    logger_console_info(
                        "Change in delta parameters {} {} old_value={} new_value={}".format(
                            distName, parameterName, old_value, new_value))
    return delta


def get_VM_ip():
    vm_iface_eth0 = netifaces.ifaddresses('eth0')
    VM_ADDRESS = vm_iface_eth0[netifaces.AF_INET][0]['addr']
    return VM_ADDRESS


def prepare_delta_for_tc_C05_C06_C014(delta_path):
    delta = read_json(delta_path)
    delta = change_delta_parameter(delta, distName="MRBTS-1/NRBTS-1", parameterName="actPCMDReport", value="true")
    delta = change_delta_parameter(delta, distName="MRBTS-1/NRBTS-1/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1",
                                   parameterName="actPCMDReporting", value="true")
    delta = change_delta_parameter(delta, distName="MRBTS-1/MNL-1/TCEADM-1/TCE-1", parameterName="tceIpAddress",
                                   value=get_VM_ip())
    delta = change_delta_parameter(delta, distName="MRBTS-1/MNL-1/TCEADM-1/TCE-1", parameterName="tcePortNumber",
                                   value="49148")
    adjust_parameters_using_delta(delta=delta)


def prepare_delta_for_tc_C004(delta_path):
    delta = read_json(delta_path)
    delta = change_delta_parameter(delta, distName="MRBTS-1/NRBTS-1", parameterName="actPCMDReport", value="false")
    delta = change_delta_parameter(delta,
                                   distName="MRBTS-1/NRBTS-1/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1",
                                   parameterName="actPCMDReporting", value="false")
    delta = change_delta_parameter(delta, distName="MRBTS-1/MNL-1/TCEADM-1/TCE-1", parameterName="tceIpAddress",
                                   value=get_VM_ip())
    delta = change_delta_parameter(delta, distName="MRBTS-1/MNL-1/TCEADM-1/TCE-1", parameterName="tcePortNumber",
                                   value="49148")
    adjust_parameters_using_delta(delta=delta)


def prepare_delta_for_tc_D003_D011_D004(delta_path):
    delta = read_json(delta_path)
    delta = change_delta_parameter(delta, distName="MRBTS-1/NRBTS-1", parameterName="actPCMDReport", value="false")
    delta = change_delta_parameter(delta, distName="MRBTS-1/NRBTS-1", parameterName="actIpThpt", value="true")
    delta = change_delta_parameter(delta, distName="MRBTS-1/NRBTS-1", parameterName="thpTimeCalc", value="enabled")
    delta = change_delta_parameter(delta, distName="MRBTS-1/MNL-1/TCEADM-1/TCE-1", parameterName="tceIpAddress",
                                   value=get_VM_ip())
    delta = change_delta_parameter(delta, distName="MRBTS-1/MNL-1/TCEADM-1/TCE-1", parameterName="tcePortNumber",
                                   value="49148")
    adjust_parameters_using_delta(delta=delta)


def add_ccs_decode_to_wireshark():
    basic_wireshark_path = "/usr/lib/x86_64-linux-gnu/wireshark/plugins"
    latest_path = get_latest_file(os.path.join(basic_wireshark_path, "*.*/epan"))
    ccs_decode = BuiltIn().get_variable_value("${CCS_DECODE_PATH}")
    OperatingSystem().run('sudo cp {} {}'.format(ccs_decode, latest_path))


def setup_tshark_for_l2_logs():
    ute_tshark_instance = BuiltIn().get_library_instance('ute_tshark')
    ute_tshark_instance.setup_tshark(interface="any", alias=ALIAS_TSHARK_VALIDATE)


def setup_tshark_for_conventional_pcap():
    ute_tshark_instance = BuiltIn().get_library_instance('ute_tshark')
    ute_tshark_instance.setup_tshark(interface="any", alias=ALIAS_TCPDUMP_GNB)


def wait_for_traffic_end(sec=60):
    sleep(sec)


def last_period_start_time(actual_time=time(), pm_period=5):
    pm_period_to_sec = pm_period*60
    first_value = int(actual_time/pm_period_to_sec)
    period_start_time = first_value * pm_period_to_sec
    t = datetime.datetime.utcfromtimestamp(period_start_time)
    ts = t.strftime('%Y-%m-%d %H:%M:%S')
    logger_debug(msg=period_start_time)
    logger_debug(msg=ts)
    return period_start_time


def check_pm_period_fill_factor(actual_time=time(), pm_period=5, min_time_to_start=60, delay_sec=10):
    pm_period_to_sec = pm_period*60
    first_value = int(actual_time/pm_period_to_sec)
    start_pm_period = first_value * pm_period_to_sec
    end_pm_period = start_pm_period + pm_period_to_sec

    time_ceil = math.ceil(actual_time)
    time_left = end_pm_period - time_ceil
    if time_left < min_time_to_start:
        sleep(int(time_left)+1)
        return check_pm_period_fill_factor(time(), pm_period, min_time_to_start, delay_sec)
    else:
        time_to_send_traffic = time_left + pm_period_to_sec + delay_sec
        return time_to_send_traffic


def count_start_traffic_time_with_advance(start_time, advance):
    return start_time + float(advance)
