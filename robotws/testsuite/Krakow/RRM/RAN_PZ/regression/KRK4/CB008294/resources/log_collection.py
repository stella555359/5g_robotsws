"""
:copyright: Nokia Networks
:author: Mateusz Plinta
:maintainer: Mateusz Plinta
:contact: mateusz.plinta@nokia.com
:team: MN_RAN_L2_SW_2_KRK_Vrf_SG
"""

import os
from robot.libraries.BuiltIn import BuiltIn

import testsuite.Krakow.RRM.RAN_PZ.regression.KRK4.resources.Python.common_gnb as common_gnb
import testsuite.Krakow.RRM.RAN_PZ.regression.KRK4.resources.Python.utilities as utilities
import testsuite.Krakow.RRM.RAN_PZ.regression.KRK4.resources.Python.common_wts as common_wts


def get_test_log_dirpath():
    output_dir = common_gnb.ta5g_interface_tools().get_robot_output_dir()
    suite_name = common_gnb.ta5g_interface_tools().get_robot_suite_name()
    test_name = common_gnb.ta5g_interface_tools().get_robot_test_name()
    return os.path.join(output_dir, suite_name, test_name)


def start_collecting_logs():
    alias = BuiltIn().get_variable_value("${TCPDUMP_ALIAS}")
    test_log_dirpath = get_test_log_dirpath()
    suite_name = common_gnb.ta5g_interface_tools().get_robot_suite_name()
    test_name = common_gnb.ta5g_interface_tools().get_robot_test_name()

    ta5g_syslog = BuiltIn().get_library_instance("ta5g_syslog")
    ta5g_tshark = BuiltIn().get_library_instance("ta5g_tshark")

    common_gnb.collect_scf_file(
        prefix="before",
        subdir=os.path.join(suite_name, test_name, "scfs"),
        name=utilities.get_current_date()
    )
    ta5g_syslog.start_syslog_for_enb(
        logs_dirpath=os.path.join(test_log_dirpath, "syslog"),
        log_filename_prefix="syslog_gnb_{}_".format(utilities.get_current_date())
    )
    _, log_path, _ = ta5g_tshark.start_tcpdump_on_remote_interface(
        log_filename_prefix="tcpdump_GNB_" + utilities.get_current_date(),
        log_dirpath=os.path.join(test_log_dirpath, "pcap"),
        alias=alias
    )
    BuiltIn().set_test_variable("${TCPDUMP_LOG_PATH}", log_path)


def teardown_collecting_logs():
    suite_name = common_gnb.ta5g_interface_tools().get_robot_suite_name()
    test_name = common_gnb.ta5g_interface_tools().get_robot_test_name()

    ta5g_syslog = BuiltIn().get_library_instance("ta5g_syslog")
    ta5g_egate = BuiltIn().get_library_instance("ta5g_egate")
    ta5g_tshark = BuiltIn().get_library_instance("ta5g_tshark")
    ute_tshark = BuiltIn().get_library_instance('ute_tshark')

    ta5g_syslog.collect_syslog_results()
    ta5g_syslog.teardown_all_aliases_for_syslog()
    ta5g_egate._ute_wtssim_instance.teardown_all_aliases_for_wts()
    common_wts.copy_egate_console_log_to_specified_dir(
        subdirectory=os.path.join(suite_name, test_name, "egate"),
        prefix=utilities.get_current_date()
    )
    common_gnb.collect_scf_file(
        prefix="after",
        subdir=os.path.join(suite_name, test_name, "scfs"),
        name=utilities.get_current_date()
    )
    ta5g_tshark.stop_tcpdump_on_remote_interface()
    ute_tshark.teardown_all_aliases_for_tshark()
