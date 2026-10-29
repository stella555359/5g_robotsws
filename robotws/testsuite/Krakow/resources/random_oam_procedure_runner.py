import logging
import os.path
import random
import sys
import time
import traceback
import pprint
import copy
import shutil
from robot.libraries.BuiltIn import BuiltIn
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations, EnbDuOperations
from taf.rfrl.utilities.test_config import get_log_path
from taf.rfrl.utilities.messenger import send_email_with_default_template
from taf.rfrl.utilities.logger.custom_logger import log_info_to_console
from taf.rfrl.utilities.robot.RobotKWRunner import run_as_robot_kw
from taf.rfrl.utilities.robot.RobotWrapper import RobotWrapper
from taf.rfrl.utilities.parsers.json_parser import parse_json_string_to_dict
from taf.rfrl.utilities.robot.general import run_robot_keyword, import_resource_to_robot_framework_namespace, \
        get_builtin_value
from taf.rfrl.procedures.resources.python.OAM_KPI.oam_kpi_runner import run_site_reset_in_loop, \
        run_bts_power_on_in_loop, run_reset_bbmod_in_loop, run_reset_rmod_in_loop, run_power_reset_rmod_in_loop, \
        run_reset_hub_in_loop, run_reset_hub_in_loop_via_asir_cli, run_reset_ant_in_loop, \
        run_cell_block_unblock_in_loop, run_cell_lock_unlock_in_loop, run_rat_reset_in_loop, \
        run_bts_power_reset_via_api_in_loop
from taf.rfrl.bts.devices.du.commissioning import GnbCommissioning, EnbCommissioning
from taf.rfrl.ue.utilities import get_yaml_ue_config


import_resource_to_robot_framework_namespace('testsuite/Krakow/resources/RANDOM_PROCEDURE/'
                                             'E2E_TL_Activation_Reset_Test.robot')
_tl = get_builtin_value(param_name='tl')

oam_operation_settings = {
    'site_reset': {
        'method': run_site_reset_in_loop,
    },
    'bts_power_on': {
        'method': run_bts_power_on_in_loop,
    },
    'reset_bbmod': {
        'method': run_reset_bbmod_in_loop,
        'required_hw': 'bbmod'
    },
    'reset_rmod': {
        'method': run_reset_rmod_in_loop,
        'required_hw': 'rmod',
    },
    'power_reset_rmod': {
        'method': run_power_reset_rmod_in_loop,
        'required_hw': 'rmod',
        'kwargs': {
            'ru_id': 'random'
        }
    },
    'reset_hub': {
        'method': run_reset_hub_in_loop,
        'required_hw': 'asir'
    },
    'reset_hub_via_asir_cli': {
        'method': run_reset_hub_in_loop_via_asir_cli,
        'required_hw': 'asir'
    },
    'reset_ant': {
        'method': run_reset_ant_in_loop,
        'required_hw': 'asir'
    },
    'cell_block_unblock': {
        'method': run_cell_block_unblock_in_loop,
    },
    'cell_lock_unlock': {
        'method': run_cell_lock_unlock_in_loop,
    },
    'rat_reset': {
        'method': run_rat_reset_in_loop,
    },
    'E2E_TL_Activation_Reset': {
        'keyword': 'E2E_TL_Activation_Reset',
        "get_log_path": lambda: os.path.join(get_builtin_value('OUTPUTDIR'),
                                             get_builtin_value('TEST NAME').replace(' ', '_'))
    },
    'bts_power_reset_via_api': {
        'method': run_bts_power_reset_via_api_in_loop,
    },
}

_power_off_alarm = {
        'alarm_id': '7115',
        'fault_id': '4590',
        'fault_name': 'Fault signature for crash or failure',
        'severity': 'Warning',
        'fault_signature': {'category': 'POWER_OFF'}
    }


def run_random_oam_operations(operations=None, bts_type='GNB', bts_id=0, du_id=0, timeout=5 * 3600,
                              email_notification=True, operation_kwargs=None, random_seed=None,
                              l3_call=True, l3_call_keywords=None):
    """    Function is running random OAM operations in loop until timeout is reached
    :param operations: list, list of operations to run, if None all supported operations will be run
    :param bts_type: str, BTS type, GNB or ENB
    :param bts_id: int, BTS ID
    :param du_id: int, DU ID
    :param timeout: int, timeout in seconds
    :param email_notification: bool, if True email notification will be sent in case of failure
    :param operation_kwargs: dict, string additional kwargs for operations
    :param random_seed: int, seed for random number generator, used to select operations, hw, etc.
        eg:
            operation_kwargs = {
                'site_reset': {
                    'temp_allowed_alarms': [{
                        'alarm_id': '7115',
                        'fault_id': '4590',
                        'fault_name': 'Sample fault name'}],
                    'calculate_kpi': True
                },
                'reset_rmod': {
                    'temp_allowed_alarms': [{
                        'alarm_id': '1234',
                        'fault_id': '5678',
                        'fault_name': 'Sample fault name'}],
                    'calculate_kpi': False
                }
            }
            or JSON string
                operation_kwargs = {'site_reset': {'temp_allowed_alarms': [{'alarm_id': '7115', 'fault_id': '4590',
                'fault_name': 'Sample fault name'}], 'calculate_kpi': true}, 'reset_rmod': {'temp_allowed_alarms':
                [{'alarm_id': '1234', 'fault_id': '5678', 'fault_name': 'Sample fault name'}], 'calculate_kpi': false}}
    :param random_seed: int, seed for random number generator, used to select operations, hw, etc.
    :param l3_call: bool, if True L3 Call will be performed.
    :param l3_call_keywords: dict, string L3 Call Keywords with parameters.
        eg:
            l3_call_keywords = {
                "Prepare Ue for L3 Call": {
                    "capabilities": "REAL_UE"
                },
                "Verify L3 Call Data Transfer DL&UL": {
                    "duration": "60s",
                    "tput_dl": "100 Mbits/sec",
                    "tput_ul": "100 Mbits/sec",
                    "deviation": "99%"
                }
            }
    """
    if not random_seed:
        random_seed = random.randrange(sys.maxsize)
    random.seed(int(random_seed))

    if operation_kwargs and not isinstance(operation_kwargs, dict):
        operation_kwargs = parse_json_string_to_dict(operation_kwargs)
    configuration = _get_bts_configuration(bts_type, bts_id, du_id)

    if operations is None:
        operations = []
        for operation_name, operation_settings in oam_operation_settings.items():
            required_hw = operation_settings.get('required_hw')
            if required_hw is None or required_hw in configuration['hw']:
                operations.append(operation_name)
    else:
        if not isinstance(operations, (dict, list)):
            operations = parse_json_string_to_dict(operations)

    call_verification = True if _is_ue_defined() and l3_call else False
    if call_verification and not l3_call_keywords:
        ue_capabilities = _get_ue_capabilities()

    run_as_robot_kw(log_info_to_console, msg=f"Procedure will execute a random operation selected from: {operations}"
                                             f"{' with L3 call' if call_verification else ''}")
    run_as_robot_kw(log_info_to_console, msg=f"Random Seed: {random_seed}")
    run_as_robot_kw(log_info_to_console, msg=f"Timeout is set to:  {timeout} seconds")

    watchdog_logs_dir = f"{bts_type}{bts_id}_DU{du_id}_alarm_watchdog"
    timeout = int(timeout)
    elapsed_time = 0
    iteration = 0
    summary = {}
    any_iteration_failed = False
    start_time = time.monotonic()
    operations_backup = copy.copy(operations)
    # sequence_of_operations = []

    with RobotWrapper(wrap_name="FOR LOOP", wrap_type="for") as wrapper:
        while elapsed_time < timeout:

            operation = _choose_operation(operations, operations_backup)
            if operation not in summary:
                summary[operation] = {
                    'count': 0,
                    'passed': 0,
                    'failed': 0,
                    'failed_loop': []
                }

            iteration += 1
            summary[operation]['count'] += 1

            log_dir = f"{iteration}_{operation}"
            log_dir_path = os.path.join(get_log_path(), log_dir)
            watchdog_logs_dir_path = os.path.join(log_dir_path, watchdog_logs_dir)

            params = {
                'collect_passed_snapshot': True if summary[operation]['passed'] == 0 else False,
                '_robot_log_path': log_dir_path,
                '_watchdog_logs_dir': watchdog_logs_dir_path,
                'additional_allowed_alarms': [_power_off_alarm],
            }

            operation_kwargs_from_settings = oam_operation_settings[operation].get('kwargs')
            if operation_kwargs_from_settings:
                params.update(operation_kwargs_from_settings)

            if operation == 'rat_reset':
                rat_type = random.choice(configuration['supported_rat'])
                params['rat_type'] = rat_type

            if operation_kwargs:
                selected_operation_kwargs = operation_kwargs.get(operation)
                if selected_operation_kwargs:
                    params.update(selected_operation_kwargs)

            wrapper.create_level(f"LOOP{iteration}", wrap_type="foritem", level=2)
            run_as_robot_kw(log_info_to_console, msg="-" * 70)
            run_as_robot_kw(log_info_to_console, msg=f"[{iteration}] Selected operation: {operation.upper()}")
            # sequence_of_operations.append(
            #     {
            #         'operation': operation,
            #         'params': params,
            #         'iteration': iteration,
            #         'status': None,
            #     }
            # )
            try:
                # TODO - add id of device to oam kpi report
                if 'method' in oam_operation_settings[operation]:
                    method = oam_operation_settings[operation]['method']
                    run_as_robot_kw(method, **params)
                else:
                    keyword = oam_operation_settings[operation]['keyword']
                    run_robot_keyword(keyword)
                if call_verification:
                    if not l3_call_keywords:
                        _perform_l3_call(_prepare_default_l3_call_keywords(ue_capabilities))
                    else:
                        _perform_l3_call(l3_call_keywords)
                summary[operation]['passed'] += 1
            except Exception as e:
                any_iteration_failed = True
                summary[operation]['failed'] += 1
                summary[operation]['failed_loop'].append(log_dir)
                logging.error(f"[{iteration}] Error during operation {operation}")
                logging.debug(f"Details: {e}, \nTraceback: {traceback.format_exc()}")
                if email_notification:
                    _send_notification_email(loop=iteration, operation=operation)

            if 'get_log_path' in oam_operation_settings[operation]:
                shutil.copytree(oam_operation_settings[operation]['get_log_path'](), log_dir_path)
                shutil.rmtree(oam_operation_settings[operation]['get_log_path']())

            iteration_duration = time.monotonic() - start_time - elapsed_time
            elapsed_time = time.monotonic() - start_time

            run_as_robot_kw(log_info_to_console, msg="-" * 70)
            run_as_robot_kw(log_info_to_console, msg=f"[{iteration}] Procedure {operation.upper()} "
                                                     f"took {round(iteration_duration, 2)} seconds")
            run_as_robot_kw(log_info_to_console, msg=f"[{iteration}] Elapsed time: {round(elapsed_time, 2)}")
            run_as_robot_kw(log_info_to_console, msg=f"[{iteration}] Time left: {round(timeout - elapsed_time, 2)}")

            if elapsed_time > timeout:
                run_as_robot_kw(log_info_to_console, msg="Timeout reached - ending")
                break

    run_as_robot_kw(log_info_to_console, msg=f"Summary of OAM operations:\n{pprint.pformat(summary)}")
    # TODO:
    # save summary to json file
    # save sequence of executed operations to json file

    if any_iteration_failed:
        BuiltIn().run_keyword('FAIL', 'At least one of iteration FAILED - Please check the logs')


def _choose_operation(operations, operations_backup):
    if not operations_backup:
        operations_backup = copy.copy(operations)
    operation = random.choice(operations_backup)
    operations_backup.remove(operation)
    return operation


def _get_bts_configuration(bts_type='GNB', bts_id=0, du_id=0):
    btsc = GnbCommissioning() if bts_type == 'GNB' else EnbCommissioning()
    btsd = GnbDuOperations() if bts_type == 'GNB' else EnbDuOperations()
    bts_info = btsd.get_bts_info(bts_id, du_id)

    configurations = {
        'hw': [],
        'supported_rat': _get_supported_rat_types(bts_info),
    }
    if btsc.is_asir_configuration(bts_id=bts_id, du_id=du_id):
        configurations['hw'].append('asir')
        logging.debug(f"It is ASIR configuration")
    if _is_bbmod_in_configuration(bts_info):
        configurations['hw'].append('bbmod')
        logging.debug(f"BBMOD is defined")
    if _is_rmod_in_configuration(bts_info):
        configurations['hw'].append('rmod')
        logging.debug(f"RMOD is defined")

    return configurations


def _get_supported_rat_types(bts_info):
    possible_rats = ['lte', 'nr']
    supported_rats = []
    for rat in possible_rats:
        if bts_info['cells'][rat]:
            supported_rats.append(rat.upper())
    return supported_rats


def _is_bbmod_in_configuration(bts_info):
    if bts_info['basebandModules']:
        return True
    return False


def _is_rmod_in_configuration(bts_info):
    if bts_info['radioModules']['rmod']:
        return True
    return False


def _send_notification_email(loop, operation):
    body = f"LOOP {loop} Failed during operation {operation.upper()}<br>Please check the logs for more details"
    send_email_with_default_template(subject='[Action Required] Your iteration LOOP Failed',
                                     additional_info=body,
                                     add_team_email=False)


def _perform_l3_call(l3_call_keywords):
    exceptions = []
    if not isinstance(l3_call_keywords, dict):
        l3_call_keywords = parse_json_string_to_dict(l3_call_keywords)
    for keyword in l3_call_keywords:
        args = []
        if type(l3_call_keywords[keyword]) is list:
            args = (l3_call_keywords[keyword])
        elif type(l3_call_keywords[keyword]) is dict:
            for param in l3_call_keywords[keyword]:
                args.append(param + '=' + l3_call_keywords[keyword][param])
        run_as_robot_kw(log_info_to_console, msg=f"Running keyword: {keyword}")
        try:
            run_robot_keyword(keyword, *args)
        except Exception as e:
            exceptions.append(e)
    if exceptions:
        raise L3CallFailure(exceptions)


def _is_ue_defined():
    return True if _tl.ues or os.getenv("ABSTRACT_LIB_CONFIG") else False


def _get_ue_capabilities():
    capabilities = list()
    if os.getenv("ABSTRACT_LIB_CONFIG"):
        ues_config = get_yaml_ue_config()
        for ue_pool in ues_config['UE_POOLS']:
            inline_config = ues_config['UE_POOLS'][ue_pool]['inline_config']
            for ue_name in inline_config:
                capabilities.extend(ues_config['UE_POOLS'][ue_pool]['inline_config'][ue_name]['CAPABILITIES'])
    else:
        for ue in _tl.ues:
            capabilities.extend(ue.capabilities)
    return capabilities


def _prepare_default_l3_call_keywords(ue_capabilities):
    l3_call_keywords = {
        "Prepare Ue for L3 Call": {
            "capabilities": random.choice(ue_capabilities),
            "alias": "UE"
        },
        "Verify L3 Call Data Transfer DL&UL": {
            "duration": "60s", "tput_dl": "100 Mbits/sec", "tput_ul": "100 Mbits/sec", "deviation": "99%",
            "alias": "UE"
        },
        "Stop Using Ue": ["UE"]
    }
    return l3_call_keywords


class L3CallFailure(Exception):
    pass
