"""
:copyright: Nokia Networks
:author: Marek Kieltyka <marek.kieltyka@nokia.com>
:maintainer: Marek Kieltyka <marek.kieltyka@nokia.com>
"""

from os import path, mkdir
from shutil import copyfile
import time
import traceback
import pprint
import subprocess
import socket

from taf.gnb.oam.coam.cu.exception import AuthenticationFailed
from airphone import reset_airphone
from taf.internal.gnb.oam.coam.vdu.client.api_gw.v1 import ApiException
from ta5g_interface_tools import ta5g_interface_tools
from robot.libraries.BuiltIn import BuiltIn
from robot.api import logger
from urllib3.util.retry import MaxRetryError


REAL_GNB_ID = 2
VCU_IP = '192.168.100.129'
VDU_IP = '192.168.255.129'


def _log_message(message):
    print(message)
    logger.console(message)


def _elapsed(last_time):
    return time.time() - last_time


def reach_on_air_in_vran(lua_cfg, timeout=180):
    # TODO: NSA config detection without MIB
    logs_dirpath = ta5g_interface_tools().get_robot_output_dir()
    wts_log_path = path.join(logs_dirpath, 'wts/')
    if not path.exists(wts_log_path):
        mkdir(wts_log_path)
    copyfile(lua_cfg, '{}{}'.format(wts_log_path, lua_cfg.split('/')[-1]))

    ta5g_egate_instance = BuiltIn().get_library_instance('ta5g_egate')
    ta5g_egate_instance._ute_wtssim_instance.start_wts_applications(cfg_file=lua_cfg, timeout=60)
    ta5g_egate_instance._ute_wtssim_instance.execute_egate_command(cmd='start version_check=off', timeout=10)

    cells_count = get_cells_count_configured_on_vran_gnb()
    mib_cells_dict = {REAL_GNB_ID: [cell_id for cell_id in range(1, cells_count+1)]}

    ta5g_egate_instance.wait_for_information_block_reception_for_given_cells(
        cells=mib_cells_dict, infoblocktype='MasterInformationBlock', timeout=int(timeout))

    ta5g_egate_instance.wait_for_information_block_reception_for_given_cells(
        cells=mib_cells_dict, infoblocktype='SystemInformationBlockType1', timeout=int(timeout))


def reset_both_vcu_vdu_and_wait_for_configured(retry_count=3, timeout=1800):
    vdu_instance = BuiltIn().get_library_instance('vdu')
    vcu_instance = BuiltIn().get_library_instance('vcu')

    rmods_list = vdu_instance.get_rmods_status()
    rmods_ids = [rmod['id'] for rmod in rmods_list]

    exceptions = []
    start_time = time.time()
    elapsed = 0
    while retry_count > 0 and timeout - elapsed > 0:
        reboot_start = time.time()
        try:
            wait_until_du_is_pingable()
            vcu_instance.connect_to(host=VCU_IP, port='443', username='Nemuadmin', password='Nokia@123', secure=True)
            vdu_instance.connect_to(host=VDU_IP, port='443', username='Nemuadmin', password='Nokia@123', secure=True)

            elapsed = _elapsed(start_time)
            _log_message('START: Reset vCU and vDU')
            action_start = time.time()
            vdu_instance.reset_vdu()
            vcu_instance.reset_cu()
            time.sleep(300)   # TODO: optimize waiting time after vCU vDU reset
            action_stop = time.time()
            _log_message('STOP: Reset vCU and vDU successful after: {}'.format(int(action_stop - action_start)))

            vcu_instance.connect_to(host=VCU_IP, port='443', username='Nemuadmin', password='Nokia@123', secure=True)
            vdu_instance.connect_to(host=VDU_IP, port='443', username='Nemuadmin', password='Nokia@123', secure=True)
            elapsed = _elapsed(start_time)
            _log_message('START: Reset radios')
            action_start = time.time()
            operation_status = vdu_instance.reset_rmods(rmods_list=rmods_ids)
            op_status_id = operation_status['operation_id']
            reset_operation = vdu_instance.get_reset_rmods_operation_status(operation_id=op_status_id)
            while reset_operation['status'] != 'success':
                reset_operation = vdu_instance.get_reset_rmods_operation_status(operation_id=op_status_id)
                if reset_operation['status'] == 'failure':
                    _log_message('Reset radios FAILURE, rebooting AirPhone...')
                    reset_airphone()
                    break
                time.sleep(1)
            action_stop = time.time()
            _log_message('STOP: Reset radios successful after: {}'.format(int(action_stop - action_start)))

            elapsed = _elapsed(start_time)
            _log_message('START: Wait for radios')
            action_start = time.time()
            wait_until_du_is_pingable()
            check_vran_rmods_availability()
            action_stop = time.time()
            _log_message('STOP: Wait for radios successful after: {}'.format(int(action_stop - action_start)))

            elapsed = _elapsed(start_time)
            reboot_stop = time.time()
            _log_message('STOP: Reboot successful with additional actions after: {}'
                         .format(int(reboot_stop - reboot_start)))
            return
        except AuthenticationFailed as e:
            reboot_stop = time.time()
            exceptions.append(e)
            _log_message('EXC: Reboot failed after: {}s due to exception: {}'
                         .format(int(reboot_stop - reboot_start), e))
            traceback.print_exc()
            retry_count -= 1

    raise Exception('All reboot attempts ({}) failed due to:\n{}'
                    .format(len(exceptions), pprint.pformat(exceptions)))


def wait_until_du_is_pingable():
    du_pingable = False
    vdu_ip = get_ssh_du_ip_from_testline_init_file()

    _log_message('START: Wait until vDU is pingable')
    while not du_pingable:
        try:
            result = subprocess.check_output(["ping", "-c", "1", vdu_ip])
            if result:
                du_pingable = True
        except subprocess.CalledProcessError as e:
            pass
    _log_message('STOP: Wait until vDU is pingable')


def check_vran_rmods_availability():
    vdu_instance = BuiltIn().get_library_instance('vdu')

    _log_message('START: check_vran_rmods_availability')

    vdu_login_successful = False
    while not vdu_login_successful:
        try:
            _log_message('try login to vDU...')
            vdu_instance.connect_to(host=VDU_IP, port='443', username='Nemuadmin', password='Nokia@123', secure=True)
            vdu_login_successful = True
        except (MaxRetryError, ApiException):
            pass

    all_rmods_are_online = False
    while not all_rmods_are_online:  # TODO: throw Exception if rmod['availability_status'] == 'off line' for too long
        try:
            rmods_list = vdu_instance.get_rmods_status()
            online_rmods_count = 0

            for rmod in rmods_list:
                _log_message('check RMOD-{} {}, availability_status={}'.format(rmod['id'],
                                                                               rmod['product_name'],
                                                                               rmod['availability_status']))
                if rmod['availability_status'] == 'on line':
                    online_rmods_count += 1

            if online_rmods_count == len(rmods_list):
                all_rmods_are_online = True

            time.sleep(5)
        except (MaxRetryError, ApiException):
            time.sleep(10)

    _log_message('STOP: check_vran_rmods_availability')


def reach_onair_in_vran_with_retries(lua_cfg, retry_count=3, timeout=1800):
    vdu_instance = BuiltIn().get_library_instance('vdu')
    vcu_instance = BuiltIn().get_library_instance('vcu')
    ta5g_egate_instance = BuiltIn().get_library_instance('ta5g_egate')

    start_time = time.time()
    initial_timeout = timeout
    elapsed = 0
    reach_onair_timeout = 60
    exceptions = []
    while retry_count > 0 and timeout - elapsed > 0:
        reach_start = time.time()
        try:
            _log_message('START: Reach on Air, with max retry count: {}'.format(retry_count))
            reach_on_air_in_vran(lua_cfg=lua_cfg, timeout=reach_onair_timeout)
            reach_stop = time.time()
            _log_message('STOP: Reach onAir successful after: {}'.format(int(reach_stop - reach_start)))
            return
        except Exception as e:
            reach_stop = time.time()
            elapsed = _elapsed(start_time)
            exceptions.append(e)
            _log_message('EXC: Reach onAir took: {}s, failed due to: {}'.format(int(reach_stop - reach_start), e))
            traceback.print_exc()
        try:
            ta5g_egate_instance.teardown_egate_and_collect_logs()
        except Exception as e_t:
            _log_message('EXC: Teardown egate failed due to: {}, skipping it'.format(e_t))
            traceback.print_exc()

        reset_both_vcu_vdu_and_wait_for_configured(retry_count=retry_count,
                                                   timeout=initial_timeout-elapsed)
        retry_count -= 1
        elapsed = _elapsed(start_time)

        _log_message('STOP reach_onair_in_vran_with_retries: retry_count = {}, elapsed = {}, timeout - elapsed = {}'
                     .format(retry_count, int(elapsed), int(timeout - elapsed)))

        vdu_instance.connect_to(host=VDU_IP, port='443', username='Nemuadmin', password='Nokia@123', secure=True)
        vcu_instance.connect_to(host=VCU_IP, port='443', username='Nemuadmin', password='Nokia@123', secure=True)
    raise Exception('All reach on Air attempts ({}) failed due to:\n{}'
                    .format(len(exceptions), pprint.pformat(exceptions)))


def get_cells_count_configured_on_vran_gnb():
    vdu_instance = BuiltIn().get_library_instance('vdu')
    cells_count = len(vdu_instance.get_vdu_cells_status())
    return cells_count


def get_value_of_cu_moc_parameter(moc_to_modify, parameter):
    """
    :param str moc_to_modify: full MOC path, e.g. MRBTS-1/NRBTS-1/SERVEDAMF-3
    :param str parameter: unique NIDD parameter name which belongs to moc_to_modify
    """
    vcu_instance = BuiltIn().get_library_instance('vcu')
    vran_moc_dict = vcu_instance.search_parameters_of_current_plan(parameter_name=parameter,
                                                                   items_per_page=100, connection='default')
    # items_per_page enables FULL search

    for moc in vran_moc_dict['items']:
        if moc['distname'] == moc_to_modify:
            if moc['parameter']['simple_parameter']['name'] == parameter:
                return moc['parameter']['simple_parameter']['value']


def get_dict_of_parameters_for_vran_du_delta(params_list, op_type):
    available_operations = ('replace', 'add')
    if op_type not in available_operations:
        raise AssertionError("Bad operation type! Available operations:", available_operations)

    dict_of_params = {}

    for param_dict in params_list:
        parameter_path = param_dict['parameter_path']
        value = param_dict['value']

        if param_dict['operation_type'] == op_type:
            dict_of_params[parameter_path] = value

    return dict_of_params


def get_du_specifical_mo_uuid_via_dn(plan_id, full_mo_dn):
    vdu_instance = BuiltIn().get_library_instance('vdu')
    delta_plan_tree = vdu_instance.get_tree_of_delta_plan(plan_id=plan_id)
    name_list = full_mo_dn.split('/')
    mo_uuid = ''

    for name in name_list:
        for mo_info in delta_plan_tree:
            if mo_info['parent_mo_uuid'] is None:
                parent_mo_in_plan = ''
            else:
                parent_mo_in_plan = mo_info['parent_mo_uuid']
            if parent_mo_in_plan == mo_uuid and mo_info['name'] == name:
                mo_uuid = mo_info['mo_uuid']
                break

    return mo_uuid


def get_ssh_du_ip_from_testline_init_file():
    vran_tl_dir_name = socket.gethostname().replace("-", "_")
    du_conn_variable_name = "_vdu_k8s_connection_details"
    init_py_tl_filepath = "/home/ute/testline_configuration/{}/__init__.py".format(vran_tl_dir_name)

    try:
        init_py_tl_code = open(init_py_tl_filepath).readlines()
    except Exception:
        raise Exception("VRAN TL config file '{}' not found".format(init_py_tl_filepath))

    du_conn_variable_name_found = False
    du_ip = None
    for line in init_py_tl_code:
        if du_conn_variable_name_found:
            ip_addr_with_value = line.split(",")[0]
            du_ip = ip_addr_with_value.split("=")[1][1:-1]
            _log_message("Found DU IP {} in {} file".format(du_ip, init_py_tl_filepath))
            break
        if line.find(du_conn_variable_name) != -1:
            du_conn_variable_name_found = True

    return du_ip


def check_if_vran_counter_value_is_correct(latest_value, occurrences):
    if '>' in occurrences:
        return int(latest_value) > int(occurrences[1:])
    else:
        return int(latest_value) == int(occurrences)
