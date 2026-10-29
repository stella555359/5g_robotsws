# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Mateusz Rzeczyca
:contact: mateusz.rzeczyca@nokia.com
:team: I_5GSC_SW_ENG_KRK_VRF_GMS
:email: I_5GSC_SW_ENG_KRK_VRF_GMS <I_5GSC_SW_ENG_KRK_VRF@internal.nsn.com>
"""

from robot.libraries.OperatingSystem import OperatingSystem
from robot.libraries.BuiltIn import BuiltIn
import time
import os
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.file_management import (
    upload_files_to_gnb, upload_files_to_ap, check_file_exists, copy_files_from_local_to_local, change_file_name,
    create_dir_at_output_dir, copy_files_from_ap
)
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.background_script import \
    BackgroundScript
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.common_gnb import (
    run_on_gnb, run_on_ap, execute_command_on_the_remote
)
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.utilities import (
    get_current_date, logger_console
)


class BipExecutionFailure(Exception):
    pass


class BipNotFoundException(Exception):
    pass


class BipAsoeVars(object):
    CURDIR = '{}'.format(os.path.dirname(os.path.realpath(__file__)))
    BIP_UTE_TL_SCRIPT = '{}/bip_asoe.sh'.format(CURDIR)
    BIP_GNB_SCRIPT = '{}/start_port_mirroring.sh'.format(CURDIR)
    BIP_AP_START = "{}/bip_asoe_ap.sh".format(CURDIR)
    BIP_AP_STOP = "{}/bip_asoe_ap_pkill.sh".format(CURDIR)
    BIP_AP_LIST = [BIP_AP_START, BIP_AP_STOP]
    REMOTE_PC_IP = "10.83.178.24"
    REMOTE_PC_USERNAME = "ute"
    REMOTE_PC_PASSWORD = "ute"
    BIP_OUTPUT_FILE = "/home/ute/bip.pcap"
    BIP_AP_OUTPUT_FILE = "/ffs/run/logs/AP_BIP.pcap"


def _wait_for_bip_script_ready_state(times, msg):
    logger_console("{}".format(msg))
    time.sleep(times)


def _start_bip_script(script_name):
    rc, output = OperatingSystem().run_and_return_rc_and_output(script_name)
    if rc != 0:
        msg = "Unable to start script {} on UTE VM due to: \n{}".format(script_name, output)
        raise BipExecutionFailure(msg)


def _start_bip_ap_script(script_name):
    rc, output = run_on_ap(cmd=script_name)
    if rc != 0:
        msg = "Unable to start script {} on UTE VM due to: \n{}".format(script_name, output)
        raise BipExecutionFailure(msg)


def start_bip_collection_on_remote_pc():
    bips_remote_path = '/user/toor4nsn/'
    logger_console("Uploading {} to {} on gNB...".format(BipAsoeVars.BIP_GNB_SCRIPT, bips_remote_path))
    upload_files_to_gnb(remote_path=bips_remote_path, files=[BipAsoeVars.BIP_GNB_SCRIPT])

    remote_bip_filename = os.path.join(bips_remote_path, os.path.basename(BipAsoeVars.BIP_GNB_SCRIPT))
    logger_console("Giving executable permissions and running {} on gNB...".format(remote_bip_filename))
    run_on_gnb('chmod {} {}'.format('+x', remote_bip_filename))
    run_on_gnb('{}'.format(remote_bip_filename))

    BackgroundScript().start_background_script(_start_bip_script, (BipAsoeVars.BIP_UTE_TL_SCRIPT,))
    _wait_for_bip_script_ready_state(25, "Waiting for the BIPs logging script start...")


def stop_bip_collection_on_remote_pc(output_dir_name):
    _wait_for_bip_script_ready_state(5, "Stopping BIP capture...")
    BackgroundScript().terminate_background_script()

    _wait_for_bip_script_ready_state(5, "Waiting before filename change...")
    if not check_file_exists(local_path=BipAsoeVars.BIP_OUTPUT_FILE):
        raise BipNotFoundException("Unable to find {}".format(BipAsoeVars.BIP_OUTPUT_FILE))

    output_dir = os.path.join(BuiltIn().get_variable_value("${OUTPUT_DIR}"), output_dir_name)
    copy_files_from_local_to_local([BipAsoeVars.BIP_OUTPUT_FILE], output_dir)
    change_file_name(old_name=os.path.join(output_dir, os.path.basename(BipAsoeVars.BIP_OUTPUT_FILE)),
                     new_name=os.path.join(output_dir, "bip_asoe_{}.pcap".format(get_current_date())))


def pkill_tcpdump_on_remote_pc():
    logger_console("Killing tcpdump on remote PC...")
    time.sleep(5)
    execute_command_on_the_remote(cmd="sudo pkill tcpdump",
                                  hostname=BipAsoeVars.REMOTE_PC_IP,
                                  username=BipAsoeVars.REMOTE_PC_USERNAME,
                                  password=BipAsoeVars.REMOTE_PC_PASSWORD)


def start_bip_collection_on_ap():
    remote_path = '/user/toor4nsn/'
    logger_console("Uploading {} to {} on AP...".format(BipAsoeVars.BIP_AP_LIST, remote_path))
    upload_files_to_ap(remote_path=remote_path, files=BipAsoeVars.BIP_AP_LIST)

    remote_filename = os.path.join(remote_path, os.path.basename(BipAsoeVars.BIP_AP_START))
    logger_console("Giving executable permissions and running {} on AP...".format(remote_filename))
    run_on_ap('chmod {} {}'.format('+x', remote_filename))

    BackgroundScript().start_background_script(_start_bip_ap_script, (remote_filename,))
    _wait_for_bip_script_ready_state(10, "Waiting for the BIPs logging script start...")


def stop_bip_collection_on_ap(output_dir_name):
    remote_path = '/user/toor4nsn/'
    logger_console("Giving +x permissions and running {} on gNB...".format(BipAsoeVars.BIP_AP_STOP))
    remote_syscom_filename = os.path.join(remote_path, os.path.basename(BipAsoeVars.BIP_AP_STOP))
    run_on_ap('chmod {} {}'.format('+x', remote_syscom_filename))
    run_on_ap(cmd=remote_syscom_filename)

    _wait_for_bip_script_ready_state(5, "Stopping AP BIP capture...")
    BackgroundScript().terminate_background_script()

    bip_filename = "bip_asoe_{}.pcap".format(get_current_date())
    output_dir = create_dir_at_output_dir(output_dir_name)
    copy_files_from_ap(files=[BipAsoeVars.BIP_AP_OUTPUT_FILE], local_path=output_dir)
    change_file_name(old_name=os.path.join(output_dir, os.path.basename(BipAsoeVars.BIP_AP_OUTPUT_FILE)),
                     new_name=os.path.join(output_dir, bip_filename))
    logger_console("Moved collected log {} to {}".format(bip_filename, output_dir))
