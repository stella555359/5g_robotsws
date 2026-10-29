"""
A fancy ute_wtssim wrapper

source /home/ute/DEVELOPMENT/env_activate
python /home/ute/DEVELOPMENT/robotws/testsuite/Ulm/ET/Performance_Test/resources/python/wts_manager.py \
    /home/ute/DEVELOPMENT/robotws/testsuite/Ulm/ET/Performance_Test/resources/json_scenario/basic.json \
    --start 1 \
    --ue_count 6

When to use:
  1. you have a complex scenario but does not need to be as fast as lua scripts
  2. you have large number of ues to setup and you want them in groups
"""

import argparse
import pathlib
import logging
import time
import json
import copy
import collections

from robot.libraries.BuiltIn import RobotNotRunningError, BuiltIn

import taf.sw.wtssim

_SW_WTSSIM_OBJ = None
_EGATE_OBJ = None
_COMMON_ALIAS = 'performance_egate_alias'
_EGATE_PORT = 10000
_DUPLICATE_CMD_SPC_STRING = '#'
_DEFAULT_CMD_TIMEOUT = '10s'

logger = logging.getLogger(__name__)


def send_ue_commands_from_json(json_file: str, **kwargs):
    """see send_ue_commands()

    Args:
        json_file (str): path to json file
    """
    with open(json_file, 'r', encoding='utf-8') as fstream:
        json_args = json.load(
            fstream, object_pairs_hook=collections.OrderedDict)
    json_args.update(kwargs)
    send_ue_commands(**json_args)


def send_ue_commands(**kwargs: collections.OrderedDict):
    """ Sends a complete set of commands to the egate with iterating ue ids

    Args:
        start (int): start ue id
        num_cells (int): total number of configured cells
        active_cells (list, optional): array that contains the used cells e.g. ["1", "3", "5", "7"].
                                       Defaults to use all cells.
        ue_count (int, optional): calculates end ue id, number of ues to send the command. Defaults to 1.
        end (int, optional): if set, then ue_count is ignored. Defaults to None.
        delay_per_ue (int, optional): sleep after every ue commands. Defaults to 0.
        delay_per_command (int, optional): sleep after every command. Defaults to 0.

        ** all `<ue>` value in the egate command parameter will be replaced with a ue id per iteration,
        **     this includes pass_regexp, and fail_regexp
        if duplicate command is needed on the dictionary, append a `#` to the start of the command name

    basic example usage:
        ue_args = {
            "ue_register": [{
                "id": "<ue>", "nwslice": 1, "pass_regexp": "Registered state.", "command_delay" : .5
            }],
            "ue_pdu_session_setup": [
                {"ue": "<ue>", "pdu": 1, "nwslice": 1,
                    "pass_regexp": 'Initial Context Setup Successful'}
            ],
            "trf_data_start": [
                {"ue": "<ue>", "dir": "ul", "qfi": 1, "kbps": 2000, "trf_id": 1, },
                {"ue": "<ue>", "dir": "ul", "qfi": 1, "kbps": 1000,  "trf_id": 1, }
            ]
        }
        send_ue_commands(testcase_args, 1, ue_count = 1, **ue_args)
    """
    start = int(kwargs.pop('start', 1))
    num_cells = int(kwargs.pop('num_cells', 1))
    ue_count = int(kwargs.pop('ue_count', 1))
    end = kwargs.pop('end', None)
    active_cells = kwargs.pop('active_cells', None)

    settings = kwargs.pop('settings', {})
    logger.info("settings: %s", settings)
    delay_before_command = kwargs.pop('delay_before_command', settings.pop('delay_before_command', 0))
    delay_per_ue = float(kwargs.pop('delay_per_ue', settings.pop('delay_per_ue', 0)))
    delay_per_command = float(kwargs.pop('delay_per_command', settings.pop('delay_per_command', 0)))
    continue_on_failure = settings.pop('continue_on_failure', False)
    timeout = kwargs.pop('timeout', settings.pop('timeout', _DEFAULT_CMD_TIMEOUT))

    if continue_on_failure:
        logger.warning("continue_on_failure is set to true")

    time.sleep(delay_before_command)
    if end is None:
        end = start + (ue_count * num_cells) - 1
    end = int(end)
    logger.debug("sending command for ue id %s - %s", start, end)
    logger.debug(json.dumps(kwargs, indent=4))
    for ueid in range(start, end + 1):
        if not is_ue_included(ueid, num_cells, active_cells):
            logger.debug("[skipped] ueid: %s", ueid)
            continue
        _process_commands(kwargs, delay_per_command, continue_on_failure, ueid, timeout)
        time.sleep(delay_per_ue)


def _process_commands(kwargs, delay_per_command, continue_on_failure, ueid, timeout):
    logger.debug("Commands for UE [ %s ]", ueid)
    print(f'===== UE: {ueid} =====')
    for command, parameters_arr in kwargs.items():
        try:
            _process_command(delay_per_command, ueid, command, parameters_arr, timeout)
        except taf.sw.wtssim.exception.NoRegexpMatch as e:
            if continue_on_failure:
                logger.warning("[UE %s] %s\n%s", ueid, command, e)
                break
            logger.error("[UE %s] %s ( %s )\n%s", ueid, command, parameters_arr, e)
            raise taf.sw.wtssim.exception.NoRegexpMatch from e


def _process_command(delay_per_command, ueid, command, parameters_arr, timeout):
    for parameters in parameters_arr:
        ueid_params = _replace_ue_id(ueid, parameters)
        send_command_to_egate(command, timeout=timeout, **ueid_params)
        logger.debug('delay per command: %s', delay_per_command)
        time.sleep(delay_per_command)


def send_command_to_egate(cmd: str, **kwargs):
    """send command to egate, basically just a wrapper for taf_wtssim

    Args:
        cmd (str): string command to be sent to egate
        command_delay (int, optional): sleep in seconds after sending the command. Defaults to 0.
        kwargs : command arguments for the egate command
    """
    command_delay = float(kwargs.pop('command_delay', 0))
    retries = int(kwargs.pop('retries', 0))
    max_retries = int(kwargs.pop('max_retries', 1))
    taf_wtssim_args = {
        "pass_regexp": kwargs.pop('pass_regexp', None),
        "fail_regexp": kwargs.pop('fail_regexp', None),
        "timeout": kwargs.pop('timeout', _DEFAULT_CMD_TIMEOUT),
        "alias": _COMMON_ALIAS,
    }
    wait_for_data = kwargs.pop('wait_for_data', False)
    continue_on_failure = kwargs.pop('continue_on_failure', False)
    args = _dictionary_to_params(**kwargs)
    egate_cmd = f"{cmd.replace(_DUPLICATE_CMD_SPC_STRING, '')} {args}"
    logger.debug("sending egate command: %s", egate_cmd)
    try:
        print(egate_cmd)
        if wait_for_data:
            output = get_egate_obj().execute_egate_command_and_wait_for_data(
                cmd=egate_cmd, **taf_wtssim_args)
        else:
            output = get_egate_obj().execute_egate_command(cmd=egate_cmd, **taf_wtssim_args)
    except taf.sw.wtssim.exception.NoRegexpMatch as e:
        if continue_on_failure:
            logger.warning("[EGATE FAIL] (NoRegexpMatch) %s", egate_cmd)
            time.sleep(command_delay)
        else:
            raise taf.sw.wtssim.exception.NoRegexpMatch from e
    except taf.internal.aliasing.exceptions.AliasLookupError as e:
        logger.warning("[EGATE FAIL] (AliasLookupError) %s\n%s", egate_cmd, e)
        if retries < max_retries:
            kwargs['retries'] = retries + 1
            logger.warning('[AliasLookupError] %s. Retrying... (%d/%d)',
                           egate_cmd, kwargs['retries'], max_retries)
            get_egate_obj(force_new=True)  # reset egate connection
            return send_command_to_egate(cmd, **kwargs)
        raise taf.internal.aliasing.exceptions.AliasLookupError from e
    time.sleep(command_delay)
    return output


def is_ue_included(ue_id: int, num_cells: int, active_cells: list) -> bool:
    """check if ue_id is included in the active cells

    Args:
        ue_id (int): ue id  to check
        num_cells (int): total cells configured_
        active_cells (list): array that contains the used cells e.g. ["1", "3", "5", "7"]
    Returns:
        bool: if the cell is used
    """
    if active_cells in [None, ['all'], 'null']:
        return True
    cell_id = get_cell_id_for_ue(ue_id, num_cells)
    return is_cell_included(cell_id, active_cells)


def is_cell_included(cell: int, active_cells: list) -> bool:
    """check if the cell is is used, based on the AP Pet UE to cells alignment in lua

    Args:
        cell (int): the cell to check.
        active_cells (list): array that contains the used cells e.g. ["1", "3", "5", "7"]
    Returns:
        bool: if the cell is used
    """
    if active_cells in [None, ['all'], 'null']:
        return True
    if int(cell) in [int(x) for x in active_cells]:
        return True
    return False


def get_cell_id_for_ue(ue_id: int, num_cells: int) -> int:
    """get the cell id mapping for the ue, based on the AP Pet UE to cells alignment in lua

    Args:
        ue_id (int): ue id to check
        num_cells (int): total cells configured

    Returns:
        int: cell_id
    """
    ue_cell = int(ue_id) % int(num_cells)
    if ue_cell == 0:
        ue_cell = int(num_cells)
    return ue_cell


def get_egate_obj(force_new=False):
    """get egate obj"""
    global _EGATE_OBJ  # pylint: disable=locally-disabled, W0603
    if _EGATE_OBJ is None or force_new:
        _EGATE_OBJ = _setup_egate_connection()
    return _EGATE_OBJ


def _replace_ue_id(ueid, parameters):
    deepcopy_p = copy.deepcopy(parameters)
    for key, value in deepcopy_p.items():
        if "<ue>" in str(value):
            deepcopy_p[key] = value.replace('<ue>', str(ueid))
    return deepcopy_p


def _dictionary_to_params(**kwargs):
    params = ''
    for key, value in kwargs.items():
        params = f"{params} {key}={value}"
    return params


def _setup_egate_connection():
    logger.debug('_setup_egate_connection: %s, %s', _EGATE_PORT, _COMMON_ALIAS)
    egate_object = taf.sw.wtssim.wtssim()
    egate_object.setup_egate(egate_port=_EGATE_PORT,
                             alias=_COMMON_ALIAS, save_egate=True)
    return egate_object


def get_taf_sw_wtssim_obj() -> taf.sw.wtssim.wtssim:
    global _SW_WTSSIM_OBJ  # pylint: disable=locally-disabled, W0603
    if _SW_WTSSIM_OBJ is None:
        try:
            _SW_WTSSIM_OBJ = BuiltIn().get_library_instance('taf.sw.wtssim')
        except RobotNotRunningError:
            logger.info('initializing taf.sw.wtssim.wtssim()')
            _SW_WTSSIM_OBJ = taf.sw.wtssim.wtssim()
    return _SW_WTSSIM_OBJ


def main():
    logger.info("wts_manager.py")
    parser = argparse.ArgumentParser(description='wts_manager.py')
    parser.add_argument('json')
    parser.add_argument('--start', default=1)
    parser.add_argument('--num_cells', default=1)
    parser.add_argument('--active_cells', default=None)
    parser.add_argument('--ue_count', default=1)
    parser.add_argument('--end', default=None)
    parser.add_argument('--delay_per_ue', default=None)
    parser.add_argument('--delay_per_command', default=None)
    parser.add_argument('--log_level', default="WARN")
    args = parser.parse_args()
    logging.basicConfig(
        format="%(asctime)s|%(levelname)-5.5s|%(module)s.%(funcName)s:%(lineno)d:%(message)s",
        encoding='utf-8',
        level=getattr(logging, args.log_level)
    )
    logger.debug("%s", args)
    jsondir = pathlib.Path(args.json)

    with open(jsondir, 'r', encoding='utf-8') as fstream:
        json_args = json.load(fstream, object_pairs_hook=collections.OrderedDict)
    ue_commands_args = vars(args)
    tmp_ue_commands_args = ue_commands_args.copy()
    for item, value in tmp_ue_commands_args.items():
        if value is None:
            ue_commands_args.pop(item)
    ue_commands_args.pop('json')
    ue_commands_args.pop('log_level')
    ue_commands_args.update(json_args)
    if isinstance(ue_commands_args.get('active_cells', None), str):
        ue_commands_args['active_cells'] = ue_commands_args.get(
            'active_cells').split(',')

    try:
        send_ue_commands(**ue_commands_args)
    except taf.sw.wtssim.exception.NoRegexpMatch:
        logger.error("Last Command Fail: NoRegexpMatch ")


if __name__ == "__main__":
    main()
