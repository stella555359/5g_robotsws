import os
import glob
import time
from timeout import Timeout
from robot.api import logger
from ta5g_enb import ta5g_enb
from ta5g_iphy import ta5g_iphy
from contextlib import contextmanager
from ute_fsmaccess import ute_fsmaccess
from ta5g_file_system import ta5g_file_system
from ta5g_admin_operations import ta_admin_interface
from ta5g_interface_tools import ta5g_interface_tools
from ta5g_setups_and_teardowns.teardown_executor import TeardownExecutor as teardown_executor
from six.moves import input

ta5g_iphy_instance = ta5g_iphy()
ta5g_enb_instance = ta5g_enb()


CPRT_DEBUG_ACTIVATION_COMMAND = 'echo -e "[control]\nLoggingSeverity=trace" > /ffs/run/cp_runtime.ini && ' \
                                'crasign /ffs/run/cp_runtime.ini'


@contextmanager
def gnb_fsm_access_manager(alias, teardown_session=True):
    fsm_access_instance = ute_fsmaccess()
    try:
        fsm_access_instance.setup_enb_fsm_access(alias=alias, host='192.168.255.129')
        yield fsm_access_instance
    finally:
        if teardown_session:
            fsm_access_instance.teardown_enb_fsm_access(alias=alias)
        else:
            pass


@contextmanager
def airphone_fsm_access_manager(alias, teardown_session=True):
    fsm_access_instance = ute_fsmaccess()
    try:
        fsm_access_instance.setup_wts_fsm_access(alias=alias)
        yield fsm_access_instance
    finally:
        if teardown_session:
            fsm_access_instance.teardown_wts_fsm_access(alias=alias)
        else:
            pass


def reboot_gnb_and_airphone():
    with airphone_fsm_access_manager('airphone_reboot', teardown_session=False) as airphone_access_instance:
        airphone_access_instance.start_command_on_wts('reboot', alias="airphone_reboot")

    with gnb_fsm_access_manager('gnb_reboot', teardown_session=False) as gnb_access_instance:
        gnb_access_instance.start_command_on_enb('reboot', alias="gnb_reboot")


def activate_cprt_trace_logging_level():
    with gnb_fsm_access_manager('gnb_debug') as gnb_access_instance:
        gnb_access_instance.start_command_on_enb(CPRT_DEBUG_ACTIVATION_COMMAND, alias="gnb_debug")


def crasign_file_on_bts(file_path):
    cmd = "crasign {}".format(file_path)
    with gnb_fsm_access_manager('gnb_reboot', teardown_session=False) as gnb_access_instance:
        gnb_access_instance.start_command_on_enb(cmd, alias="gnb_reboot")


def pause_execution_till_enter(message='Logging is started. For teardown logging press ENTER.'):
    logger.console('\n\n' + message)
    input()


def collect_other_debug_logs(output_dirpath=None, remote_host=None, iphy_lmp_ip='192.168.200.1'):
    if not output_dirpath:
        output_dirpath = ta5g_interface_tools().get_robot_output_dir() + '/additional_debug_files/'
    logger.console("Collecting additional debug files")
    teardown_executor.execute_teardown_methods(
        [
            (
                ta5g_enb_instance.get_targetbd_file,
                {"output_filepath": output_dirpath + '/targetbd_enb.xml', "remote_host": remote_host},
            ),
            (
                ta5g_iphy_instance.get_iphy_targetbd_file,
                {
                    "output_filepath": output_dirpath + '/' + 'targetbd_iphy.xml',
                    "remote_host": remote_host,
                    "iphy_lmp_ip": iphy_lmp_ip,
                },
            ),
            (
                ta5g_enb_instance.get_swconfig_file,
                {"output_filepath": output_dirpath + '/swconfig.txt', "remote_host": remote_host},
            ),
            (
                ta5g_iphy_instance.get_iphy_xml_file,
                {
                    "output_filepath": output_dirpath + '/' + 'iphy.xml',
                    "remote_host": remote_host,
                    "iphy_lmp_ip": iphy_lmp_ip,
                },
            ),
            (
                ta5g_enb_instance.get_scfc_file,
                {"output_filepath": output_dirpath + '/scf.xml'},
            ),
            (
                ta5g_enb_instance.get_extended_trs,
                {"output_filepath": output_dirpath + '/TRSExtendedLogs.tar.xz'}
            ),
        ]
    )


def collect_wts_sim_logs(output_dirpath=None):
    if not output_dirpath:
        output_dirpath = ta5g_interface_tools().get_robot_output_dir() + '/wts/'
    create_folder_if_not_exist(output_dirpath)
    ta5g_file_system().safe_copy_files(get_list_of_sim_logs_files(), output_dirpath)


def get_list_of_sim_logs_files():
    return glob.glob('/opt/iphy/latest/*.log*')


def create_folder_if_not_exist(file_path):
    directory = os.path.dirname(file_path)
    if not os.path.exists(directory):
        os.makedirs(directory)


def verify_x2_link_status(is_available=True, interval=10,
                          dist_name="/MRBTS-1/RAT-1/NRTS-4/NRBTS_L-1/LTEENB_L-0", timeout=60):
    logger.info("Verify X2 link Status", also_console=True)
    x2_link_availability = False
    with Timeout(timeout):
        with ta_admin_interface.admin_interface() as admin_client:
            while x2_link_availability != is_available:
                x2_link_status = admin_client.get_parameters(
                    dist_name=dist_name,
                    pattern="x2LinkStatus", depth=-1, timeout=timeout).get("x2LinkStatus", "Unavailable")
                logger.info("X2 link status is: {}".format(x2_link_status), also_console=True)
                time.sleep(interval)
                if x2_link_status == "Available":
                    x2_link_availability = True


def create_config_file_path_variable_name(filetype: str, name: str):
    """
    Function for creation of variable name for configuration file path

    :param filetype: scfc, iphy or cfg
    :param name: id of test case, e.g. tc1

    return: ${filetype_name} e.g. ${scfc_tc1}
    """

    return '${}{}_{}{}'.format('{', filetype, name, '}')
