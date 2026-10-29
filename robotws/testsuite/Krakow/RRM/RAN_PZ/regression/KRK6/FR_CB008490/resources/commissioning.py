"""
Commissioning class for CB008490 test suite

:copyright:     Nokia Networks
:author:        Piotr Brzezicki
:maintainer:    Piotr Brzezicki
:contact:       piotr.brzezicki@nokia.com
:team:          VRF_KRK_T06
"""
import logging
import time
from pathlib import Path
from typing import Union, List, Dict

from taf.rfrl.bts.commissioning import perform_commissioning_on_gnb_to_onair_state, \
    perform_full_commissioning_on_gnb_asir_hub, wait_for_onair_on_all_dus
from taf.rfrl.bts.devices.du.commissioning import GnbCommissioning
from taf.rfrl.bts.devices.du.logs_collecting.btslog_collector import GnbBtslogCollector
from taf.rfrl.utilities.logger import custom_logger as logger
from taf.rfrl.utilities.robot.decorators import log_as_robot_keyword
from taf.rfrl.utilities.robot.general import set_robot_suite_variable, get_builtin_value
from taf.rfrl.utilities.robot.parallel_runner import run_parallel_in_robot

from .common import Misc, run_and_warn_on_exception
from .alarms import Alarms
from .variables.common import NUM_BTS_DEVICES

RUN_COMMISSIONING = not Misc.to_bool(get_builtin_value("skip_commissioning"), False)
COMMISSIONING_TIMEOUT = 800
UPDATE_TIMEOUT = 2400


@log_as_robot_keyword
def run_commissioning() -> None:
    """
    Performs commissioning sequence (BTS log collection, commissioning with alarm watching)
    if RUN_COMMISSIONING is set to true.

    :return: None
    """
    if RUN_COMMISSIONING:
        btslog = GnbBtslogCollector()
        run_and_warn_on_exception(btslog.start_collecting_btslog)()
        commissioning_with_watching_alarms()
        run_and_warn_on_exception(btslog.stop_collecting_btslog)()


@log_as_robot_keyword
def commissioning_with_watching_alarms() -> None:
    """
    Performs commissioning while watching alarms on both BTSes.

    Starts alarm watching, uploads SW config and commissions BTSes, then runs preparation teardown.
    Always stops watching alarms even if an exception occurs.

    :return: None
    """
    Alarms().watch_alarms_during_tl_prep()
    try:
        commission_asir_only()
    except Exception as e:
        logger.log_warn_to_console(f"Commissioning failed with Exception: {e}")
        set_robot_suite_variable('SUITE_SETUP_STATUS', False)
        raise
    finally:
        Alarms().stop_watching_alarms_for_all_btses()


@log_as_robot_keyword
def commission_asir_only():
    asir_scf_path = get_latest_asir_scf_xml_path(uca_executions_root_dir="/home/ute/.ute-ca/executions/",
                                                 filename="CB008490_GNB0_ASIR_SCF.xml")
    perform_full_commissioning_on_gnb_asir_hub(bts_id=0,
                                               scf_path=asir_scf_path)
    for bts_id in range(NUM_BTS_DEVICES):
        delay_for_checking_on_air = 20
        logging.debug("Sleep {} seconds before checking OnAir".format(delay_for_checking_on_air))
        time.sleep(delay_for_checking_on_air)
        wait_for_onair_on_all_dus(bts_id=bts_id, timeout=10 * 60)


@log_as_robot_keyword
def commission_btses(prefix_tag: str = None, parallel: bool = False) -> None:
    """
    Uploads swconfig and performs full commissioning on 2 BTSes.
    :param prefix_tag: str based on which files will be chosen
    :param parallel: bool to decide if commissioning to be done in parallel
    """
    list_of_functions = [{
        'function': perform_commissioning_on_gnb_to_onair_state,
        'function_kwargs': {'bts_id': 0,
                            'asir_hub': True,
                            'prefix_tag': prefix_tag,
                            'update_timeout': UPDATE_TIMEOUT,
                            'commissioning_timeout': COMMISSIONING_TIMEOUT},
        'device_name': 'GNB0'
    }, {
        'function': perform_commissioning_on_gnb_to_onair_state,
        'function_kwargs': {'bts_id': 1,
                            'asir_hub': False,
                            'prefix_tag': prefix_tag,
                            'update_timeout': UPDATE_TIMEOUT,
                            'commissioning_timeout': COMMISSIONING_TIMEOUT},
        'device_name': 'GNB1'
    }]
    if parallel:
        logger.log_info_to_console('Commissioning BTSes in parallel')
        run_parallel_in_robot(list_of_functions)
    else:
        logger.log_info_to_console('Commissioning BTSes in sequence')
        for func in list_of_functions:
            func['function'](**func['function_kwargs'])


@log_as_robot_keyword
def get_latest_asir_scf_xml_path(uca_executions_root_dir: Union[str, Path],
                                 filename: str = "CB008490_GNB0_ASIR_SCF.xml") -> str:
    """
    Return path to `filename` from the latest (highest-numbered) execution directory.

    Expected layout:
        executions_root_dir/
            1/...
            2/...
            10/...
    where execution directory names are integers.
                ../configs/topology_configs/node_1/
    We search execution dirs from highest to lowest and do recursive search inside each.
    :param uca_executions_root_dir: Root directory containing execution subdirectories.
    :param filename: Name of the file to search for.
    """
    root = Path(uca_executions_root_dir)

    if not root.exists():
        raise FileNotFoundError(f"Executions root dir does not exist: {root}")
    if not root.is_dir():
        raise NotADirectoryError(f"Executions root is not a directory: {root}")

    exec_dirs = []
    for p in root.iterdir():
        if p.is_dir() and p.name.isdigit():
            exec_dirs.append((int(p.name), p))

    exec_dirs.sort(key=lambda x: x[0], reverse=True)

    for exec_num, exec_dir in exec_dirs:
        logging.debug(f"Searching in execution dir {exec_num}: {exec_dir}")
        matches = list(exec_dir.rglob(filename))
        logging.debug(f"Found {len(matches)} matches in {exec_dir} for '{filename}'")
        if matches:
            selected = str(sorted(matches)[0])
            logger.log_info_to_console(f"Using ASIR SCF: {selected}")
            return selected

    tried = ", ".join(str(n) for n, _ in exec_dirs) if exec_dirs else "(no numeric execution dirs found)"
    raise FileNotFoundError(
        f"File '{filename}' not found under any execution dir in: {root}. "
        f"Checked execution numbers: {tried}"
    )


def commission_deltas(deltas: List[List], wait_onair: bool = True) -> None:
    """
    Commission multiple BTSes by applying their respective delta configurations.

    Each element in deltas is treated as the delta (list format) for the BTS whose
    index matches its position in the list (i.e. index == bts_id).

    Parameters:
        deltas: List of delta lists; position maps to bts_id.
        wait_onair: Whether to wait for the BTS to be on air after commissioning.

    Returns:
        None
    """
    for bts_id, delta in enumerate(deltas):
        perform_bts_delta_commissioning(delta=delta, bts_id=bts_id, wait_onair=wait_onair)


@log_as_robot_keyword
def check_bts_for_list_parameter_value_and_configure_if_needed(
        dist_name: str,
        param: str,
        list_params: list[str],
        expected_values: list[int],
        bts_id: int) -> bool:
    """
    Verifies list-type parameter items and commissions changes if any value differs.

    :param dist_name: SCF DN pattern (e.g. "MRBTS-{}/NRBTS-{}").
    :param param: Parent parameter name containing list items.
    :param list_params: List of item keys to verify.
    :param expected_values: Expected values mapped 1:1 to list_params.
    :param bts_id: BTS identifier.
    :return: True if commissioning performed (changes applied), False otherwise.
    """
    gnb_comm = GnbCommissioning()
    adjusted_dist_name = gnb_comm.adjust_dist_name(dist_name, bts_id)
    logger.log_info_to_console(f"Checking if {adjusted_dist_name}.{param}.{list_params} is {expected_values}")
    result = gnb_comm.get_parameters_by_dist_name(dist_name=dist_name,
                                                  parameter_list=[param],
                                                  bts_id=bts_id)
    logging.info(f'Get parameters results: {result}')
    commissioning_needed = False
    for list_param, expected_value in zip(list_params, expected_values):
        list_param_value = result['parameters'][param][0].get(list_param, None)
        msg = f'{adjusted_dist_name}.{param}.{list_param} = {list_param_value}'
        if list_param_value == expected_value:
            logging.info(f'{msg} -> no need to change parameter')
            continue

        logger.log_info_to_console(f'{msg} -> changing it to {expected_value}', log_hierarchy=2)
        result['parameters'][param][0][list_param] = expected_value
        commissioning_needed = True

    if commissioning_needed:
        delta = convert_to_delta_dict(result)
        perform_bts_delta_commissioning(delta=delta, bts_id=bts_id, wait_onair=True)
        return True
    return False


@log_as_robot_keyword
def check_bts_for_parameter_value_and_configure_if_needed(
        dist_name: str,
        parameter_name: str,
        expected_value: list,
        bts_id: int = 0
) -> bool:
    """
    Checks BTS parameters in given MOC and sets is to expected value if it not already set
    :param dist_name: Management Object Class, e.g. MRBTS-{}/MNL-1/MNLENT-1/PMMNL-1
    :param parameter_name: SCF parameter name e.g. actZeroCounterSuppression
    :param expected_value: list with parameter value as str e.g. ['NR PMQAP sum Counters', 'NR non-PMQAP sum Counters']
    :param bts_id: The ID of the BTS (Base Transceiver Station) to check. Defaults to 0.
    :return: True when commissioning was performed to enable parameter
    """
    gnb_comm = GnbCommissioning()
    adjusted_dist_name = gnb_comm.adjust_dist_name(dist_name, bts_id)
    logger.log_info_to_console(f"Checking if {adjusted_dist_name}.{parameter_name} is {expected_value}")
    result = gnb_comm.get_parameters_by_dist_name(dist_name=dist_name,
                                                  parameter_list=[parameter_name],
                                                  bts_id=bts_id)
    logging.info(f'[{bts_id}] Get parameters results: {result}')
    param_value = result['parameters'].get(parameter_name, None)
    msg = f'{adjusted_dist_name}.{parameter_name} = {param_value}'
    if all(value in param_value for value in expected_value):
        logger.log_info_to_console(f'{msg} -> No need to change parameter')
        return False

    logger.log_info_to_console(f'{msg} -> changing to {expected_value}')
    result['parameters'][parameter_name] = expected_value
    delta = convert_to_delta_dict(result)
    perform_bts_delta_commissioning(delta=delta, bts_id=bts_id, wait_onair=True)
    return True


@log_as_robot_keyword
def convert_to_delta_dict(parameters_dict: dict, operation: str = "update") -> List:
    """
    Converting GnbCommissioning().get_parameters_by_dist_name format:
    {'distName': 'MRBTS-77018/NRBTS-77018/NRDRB-2', 'parameters': {'nrDcDrbParam': [
        {'actPrioXxAfterInactNrDc': False, 'actXxDuplicateTxNrDc': False, 'dlDataSplitBufBldUpThreshNrDc': 5,
         'dlDataSplitGainThresholdNrDc': 5, ...}]}}
    to delta format:
    [{"distName": "MRBTS-77018/NRBTS-77018/NRDRB-2",
      "operation": "update",
      "parameters": [{"parameterName": "nrDcDrbParam",
                      "value": [{"actPrioXxAfterInactNrDc": false, "actXxDuplicateTxNrDc": false...}],
                      "operation": "update"}]}]
    :param parameters_dict: input format
    :param operation: operation type to by applied for MOC and parameter
    :return: WebEm/Admin-CLI delta in JSON format
    """
    parameter_name = next(iter(parameters_dict['parameters']))
    delta = [{"distName": parameters_dict['distName'],
              "operation": operation,
              "parameters": [{"parameterName": parameter_name,
                              "value": parameters_dict['parameters'][parameter_name],
                              "operation": operation}]}]
    return delta


@log_as_robot_keyword
def perform_bts_delta_commissioning(delta: List[Dict], bts_id: int = 0, wait_onair: bool = True) -> None:
    """
    Perform delta commissioning on a single BTS.
    Applies the provided delta configuration (WebEM/Admin-CLI JSON format) using GnbCommissioning.
    Optionally waits until all cells on the BTS are on air.

    :param delta: Delta configuration list to apply.
    :param bts_id: BTS identifier.
    :param wait_onair: When True, wait until all cells are on air after commissioning.
    """
    logger.log_info_to_console(f"Performing bts_id={bts_id} commissioning with delta: {delta}", log_hierarchy=2)
    GnbCommissioning().perform_bts_delta_commissioning(delta=delta, bts_id=bts_id)
    if wait_onair:
        Misc().wait_for_all_cells_to_be_onair(bts_id=bts_id)
