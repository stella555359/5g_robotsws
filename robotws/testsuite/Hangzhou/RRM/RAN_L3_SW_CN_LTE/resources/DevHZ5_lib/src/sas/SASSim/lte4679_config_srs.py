# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: lisen
:contact:lisen@nokia-sbell.com
:maintainer: None
:contact: lisen
"""
from robot.libraries.BuiltIn import BuiltIn
from libraries.ta_throughput import ta_throughput
from libraries.ta_ttitrace_support import ta_ttitrace_support
from libraries.ta_ttitrace import ta_ttitrace
from libraries.ta_ue_mobility import ta_ue_mobility
# from libraries.ta_setups_and_teardowns import ta_setups_and_teardowns
from resources.DevWro1.swconfig_flags import *
from libraries.ta_interface_tools import ta_interface_tools
from libraries.ta_ue_configuration import ta_ue_configuration
from libraries.ta_bearers import ta_bearers
from ta_dspi.dspi_tools.interface import dspi_tools
from libraries.ta_iphy_tti_trace import ta_iphy_tti_trace
from libraries.ta_cell_operations import ta_cell_operations
from libraries.ta_vm_management import ta_vm_management
from libraries.ta_enb import ta_enb
import tdd_ev_robotws.TdlteLib.enb_lib.ttitrace_control as ttitrace_utility
from libraries.ta_egate import ta_egate
from libraries.ta_commissioning import ta_commissioning
import time
import os

ROBOT_LIBRARY_SCOPE = 'GLOBAL'
ROM_DIRECTORY = "/rom/etc/sas/"
builtin = BuiltIn()
builtin.import_library('ute_wtssim')
builtin.import_library('ute_fsmaccess')
builtin.import_library('ute_pdu')
builtin.import_library('ute_tshark')
# builtin.import_library('libraries.ta_infomodel')
# builtin.import_library('libraries.ta_syslog')
builtin.import_variables('config')

current_path = os.path.dirname(os.path.abspath(__file__))
tti_file = os.path.join(ta_interface_tools.get_robot_output_dir(), 'ttitrace')
snapshot_file = ta_interface_tools.get_robot_output_dir()
swconfig_flags_list = SET_CCS_SYSLOG_O_MODE + SET_CCS_SYSLOG_IO_LEVEL_DBG
swconfig_flags_list.append("0x0012007f = 3")
swconfig_flags_list.append("0x1d0092 = 1")

ta_vm_management = ta_vm_management()
ta_ttitrace_support = ta_ttitrace_support()
ta_ttitrace = ta_ttitrace()
ta_ue_mobility = ta_ue_mobility()
# ta_setups_and_teardowns = ta_setups_and_teardowns()
ta_throughput = ta_throughput()
ta_ue_configuration = ta_ue_configuration()
ta_iphy_tti_trace = ta_iphy_tti_trace()
ta_bearers = ta_bearers()
dspi_tools = dspi_tools()
ta_cell_operations = ta_cell_operations()
# ta_enb = ta_enb()
ta_egate = ta_egate()


class ta_enb_extend_for_srs(ta_enb):
    def __init__(self):
        super(ta_enb_extend_for_srs, self).__init__()
        self.target_file_path = "/rom/etc/sas/"
        self.name_source_target = [
            ("nokia04.cert", "cbrsVendorCertChain.pem"),
            ("nokia04.key", "cbrsPrivKey.pem.crk"),
            ("ca.cert", "cbrsRootCACertificate.pem")
        ]

    def put_srs_file(self, input_file_path, remote_host=None):
        with self._ute_fsm_configurator(remote_host=remote_host) as fsm_instance:
            fsm_instance.execute_command_on_enb(cmd="rm -rf {}".format(self.target_file_path))
            fsm_instance.execute_command_on_enb(cmd="mkdir {}".format(self.target_file_path))
            for source, target in self.name_source_target:
                fsm_instance.put_enb_file(source=input_file_path + os.sep + source,
                                          destination=self.target_file_path + target)
            # fsm_instance.execute_command_on_enb(cmd="openssl x509 -noout -hash -in cbrsRootCACertificate.pem")
            fsm_instance.execute_command_on_enb(
                cmd="ln -s /rom/etc/sas/cbrsRootCACertificate.pem /rom/etc/sas/aaae4089.0")
            fsm_instance.execute_command_on_enb(cmd="chown btssw:btssw /rom/etc/sas/ -R")


ta_enb_extend_for_srs = ta_enb_extend_for_srs()


# def generate_delta_file_based_on_original_srs(host_ip, port="4433"):
#     builtin.log_to_console(host_ip)
#     delta_scfc_srs = "DeltaCommissioning_CBRS_enable.xml"
#     delta_scfc_file = ta_commissioning().find_scfc(delta_scfc_srs)
#     builtin.log_to_console(delta_scfc_file)
#     with open(delta_scfc_file, 'r+') as delta_scfc:
#         content = delta_scfc.read()
#         content = content.replace("{primarySASserver}", "{}:{}".format(host_ip, port))
#         delta_scfc.seek(0, 0)
#         delta_scfc.write(content)
#     ta_setups_and_teardowns.ta_commissioning_instance.find_and_send_delta_commissioning(scfc_name=delta_scfc_srs)


def prepare_cbrs(full_scfc, host_ip):
    full_path_scfc = ta_commissioning().find_scfc(full_scfc)
    add_host_ip_into_scfc(full_path_scfc, host_ip)
    install_mutual_certification_files()


def add_host_ip_into_scfc(full_path_scfc, host_ip, port="4433"):
    with open(full_path_scfc, 'r+') as fh:
        content = fh.read()
        content = content.replace("{primarySASserver}", "{}:{}".format(host_ip, port))
        fh.seek(0)
        fh.truncate()
        fh.write(content)


def install_mutual_certification_files(host_ip=None):
    current_script_abs_path = __file__[:__file__.rfind(os.sep)]
    ta_enb_extend_for_srs.put_srs_file(input_file_path=current_script_abs_path, remote_host=host_ip)
