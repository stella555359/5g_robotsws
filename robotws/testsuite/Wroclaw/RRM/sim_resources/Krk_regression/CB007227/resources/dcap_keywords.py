"""
:copyright: Nokia Networks
:author: Justyna Balcerzak, Mateusz Adamek
:maintainer: Justyna Balcerzak, Mateusz Adamek
:contact: justyna.balcerzak@nokia.com, mateusz.adamek@nokia.com
"""
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.CB007227.resources.suite_specific_keywords\
    import get_test_prefix
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.dcap_utilities import *
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.dcap import Dcap
from robot.libraries.OperatingSystem import OperatingSystem
from ta5g_interface_tools import ta5g_interface_tools
from variables import *
import glob
import os
import re


def enable_dcap():
    dcap_instance = Dcap()
    dcap_instance.start_dcap_basic_controller()


def configure_dcap():
    dcap_instance = Dcap()
    dcap_instance.create_dcap_session()


def start_dcap_emil_collecting():
    dcap_instance = Dcap()
    dcap_instance.check_if_bts_is_configured_in_dcap(ip=BTS_DETAILS['host'], timeout=60)
    trace_id = dcap_instance.start_new_trace(bts_details=BTS_DETAILS, gnb_custom_profile=TRACE_PROFILE_GNB_EMIL,
                                             control_plane_interface=True)
    return trace_id


def start_dcap_pcmd_and_emil_collecting():
    dcap_instance = Dcap()
    dcap_instance.check_if_bts_is_configured_in_dcap(ip=BTS_DETAILS['host'], timeout=60)
    trace_id = dcap_instance.start_new_trace(bts_details=BTS_DETAILS, gnb_custom_profile=TRACE_PROFILE_GNB_BOTH,
                                             bts_custom_profile=TRACE_PROFILE_BTS,
                                             control_plane_interface=True)
    return trace_id


def stop_dcap_collecting(trace_id):
    dcap_instance = Dcap()
    dcap_instance.create_dcap_session()
    dcap_instance.stop_trace(trace_id=trace_id)
    log_dirpath = os.path.join(ta5g_interface_tools().get_robot_output_dir(), get_test_prefix())
    OperatingSystem().create_directory(log_dirpath)
    dcap_instance.get_result_file(target_dir=log_dirpath,
                                  ip=BTS_DETAILS['host'], trace_id=trace_id)


def valid_trace_status(trace_output):
    regex_pattern = r"(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})"
    if "finish_time" in trace_output:
        if str(trace_output["finish_time"]) == "None":
            logger_console(msg="Trace not stopped")
            return False
        elif bool(re.search(regex_pattern, trace_output["finish_time"])):
            data_finish = re.search(regex_pattern, trace_output["finish_time"])
            data_finish = data_finish.group(0)
            logger_console(msg="Trace stopped {}".format(data_finish))
            return True


def stop_dcap_collecting_if_exist(ip=None, trace_id=None):
    logger_console(msg="Trace ID STOP IF exist 1: {}".format(trace_id))
    tracer_id = "tracer_id"
    dcap_instance = Dcap()
    dcap_instance.create_dcap_session()
    if ip is None:
        ip = BTS_DETAILS["host"]
    if trace_id is None:
        try:
            last_trace_id = dcap_instance.get_last_trace_id(ip=ip)
            trace_id = {tracer_id: last_trace_id}
        except ValueError:
            last_trace_id = None
    else:
        last_trace_id = trace_id[tracer_id]

    if last_trace_id is not None:
        dcap_output = dcap_instance.get_trace_status(trace_id=int(last_trace_id))
        if not valid_trace_status(trace_output=dcap_output):
            logger_console(msg="Stooping trace {} because existing".format(trace_id))
            dcap_instance.stop_trace(trace_id=trace_id)
            if valid_trace_status(trace_output=dcap_output):
                logger_console(msg="Trace {} was stopped".format(trace_id))


def extract_ipCapture_logs_from_dcap():
    log_dirpath = os.path.join(ta5g_interface_tools().get_robot_output_dir(), get_test_prefix())
    extract_dcap_logs(dcap_zip_dir=log_dirpath, output_dir=log_dirpath, logs_to_collect=['ipCapture'])


def stop_dcap_emil_collecting(trace_id):
    dcap_instance = Dcap()
    dcap_instance.create_dcap_session()
    dcap_instance.stop_trace(trace_id=trace_id)
    log_dirpath = os.path.join(ta5g_interface_tools().get_robot_output_dir(), get_test_prefix())
    OperatingSystem().create_directory(log_dirpath)
    dcap_instance.get_result_file(target_dir=log_dirpath,
                                  ip=BTS_DETAILS['host'], trace_id=trace_id)
    extract_dcap_logs(dcap_zip_dir=log_dirpath, output_dir=log_dirpath, logs_to_collect=['emil'])


def find_dcap_packages_in_directory():
    log_dirpath = os.path.join(ta5g_interface_tools().get_robot_output_dir(), get_test_prefix())
    dcap_files_paths = glob.glob(fr'{log_dirpath}/UTFLab_*.zip')
    sorted_file_paths = sorted(dcap_files_paths, reverse=False)
    return sorted_file_paths


def extract_ipCapture_from_all_dcap_packages():
    log_dirpath = os.path.join(ta5g_interface_tools().get_robot_output_dir(), get_test_prefix())
    dcap_files_paths = find_dcap_packages_in_directory()
    for index, dcap_file_path in enumerate(dcap_files_paths):
        new_directory = log_dirpath + '/step_' + str(index + 1)
        dir_exists = os.path.exists(new_directory)
        if not dir_exists:
            os.mkdir(new_directory)
        file_directory, file_name = os.path.split(dcap_file_path)
        os.rename(dcap_file_path, new_directory + "/" + file_name)
        extract_dcap_logs(dcap_zip_dir=new_directory,
                          output_dir=new_directory,
                          logs_to_collect=['ipCapture'])


def print_dcap_basic_controller_version():
    cmd = "DCAP_Basic_controller status"
    rc, output = OperatingSystem().run_and_return_rc_and_output(cmd)
    version_regex = r'RND API returned FB\d+\.\d+'
    matches = re.findall(version_regex, output)
    if len(matches) > 0:
        logger_console("DCAP version {}".format(matches[0]))
