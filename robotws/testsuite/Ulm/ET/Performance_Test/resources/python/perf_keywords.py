
import json
import re
import traceback
import logging
import contextlib


from robot.libraries.BuiltIn import BuiltIn

import taf.sw.wtssim

from testsuite.Ulm.ET.Performance_Test.resources.python import perf_variables
from testsuite.Ulm.ET.Performance_Test.resources.python import wts_manager
from testsuite.Ulm.ET.Performance_Test.resources.python import perf_info

logger = logging.getLogger(__name__)

rbi = BuiltIn()
scf_prefixes = ['SCF_SET_VAR_', 'SCF_SET_VENDOR_', 'SCF_SET_LIST_', 'RDCFG_', 'SCF_CONFIGURE_', 'SCF_ENABLE_']

LUA_TABLE_SEPARATOR = r'!'
LUA_ARGS_SEPARATOR = r'%'
SCF_UNDERSCORE = r'0x5f'


include_in_lua_args = ['bearer_stats_collection', 'trf_direction', 'ul_datarate', 'dl_datarate', 'rate',
                       'trf_protocol', 'pdu_id', 'qfi_id', 'trf_id', 'packetsize', 'period_ms', 'active_cells',
                       'cell_max_ue', 'cell_ul_throughput', 'cell_dl_throughput', 'cell_trf_dir',
                       'num_cells_online', 'start_ue', 'end_ue', 'ue_per_cell', 'start_cell', 'end_cell',
                       'ue_nr_cap', 'registration_type', 'deregister_type', 'deregister_by', 'deregister_range_split',
                       'deregister_delay', 'deregister_retry', 'verify', 'duplex', 'ue_count_in_cell',
                       'pmc_verification_sublabel', 'egate_script_delay_per_vm',
                       'num_cells', 'start_amf', 'end_amf', 'plmn', 'trf_type', 'delay_bw_ue_attach',
                       'multiue_pdu_session_retry', 'Retry_IDLE_OFF_UE']


wts_manager_non_supported_params = [
    'entry', 'entry_args', 'custom_lua_file', 'trf_direction', 'pdu_id', 'qfi_id', 'trf_id',
    'packetsize', 'period_ms', 'cell_trf_dir', 'cell_dl_throughput', 'cell_ul_throughput', 'cell_trf_dir',
    'ue_nr_cap', 'registration_type', 'deregister_type', 'deregister_by', 'deregister_range_split',
    'deregister_delay', 'deregister_retry'
]


def setup_logger(logname='logger.log'):
    logging.basicConfig(
        format="%(asctime)s|%(levelname)s:%(message)s",
        filename=logname, encoding='utf-8',
        level=logging.DEBUG
    )


def convert_rf_dict_to_json(rf_dict,
                            json_safe_types=[
                                'str', 'list', 'robot.utils.dotdict.DotDict', 'bool', 'NoneType'],
                            indent=4):
    json_dict = {}
    for key, value in rf_dict.items():
        var_type = type(value)
        # rbi.log(f"key:{var_type}", console=True)
        if var_type in json_safe_types:
            json_dict[key] = value
        else:
            json_dict[key] = str(value)
    # rbi.log(f"json_dict:{json_dict}", console=True)
    return json.dumps(json_dict, indent=indent)


def get_scf_variables_from_dictionary(custom_dict={}, scf_dict={}):
    """Get SCF Variables from robot CLI args and testcase setup args, (robot CLI args takes priority)"""
    rbi.log("========== start: get_scf_variables_from_dictionary ==========")
    for key, value in custom_dict.items():
        for scf_prefix in scf_prefixes:
            if scf_prefix in key:
                rbi.log(f"    add to TP: {key} = {value}", level='DEBUG')
                scf_dict[key] = value
    rbi.log(f"    scf_dict: {scf_dict}", level='DEBUG')
    rbi.log("========== end: get_scf_variables_from_dictionary ==========")
    return scf_dict


def override_run_params_args_from_robot_cli(default_run_params, robot_cli_dict):
    """Get Variables from robot CLI args and override run params"""
    rbi.log("========== start: override_run_params_args_from_robot_cli ==========")
    for key, value in robot_cli_dict.items():
        if key.startswith("TC_"):
            param_key = key.split("_", maxsplit=1)[1]
            default_run_params[param_key] = value
            rbi.log(f"    set {param_key} = {value}", level='DEBUG')
    rbi.log("========== end: override_run_params_args_from_robot_cli ==========")
    return default_run_params


def get_gnb_rad_params_from_dictionary(scf_dict):
    """
        to use in jenkins:
         -v RDCFG_0x5808B9:6 # comment
    """
    return get_rad_params_from_dictionary(scf_dict, "RDCFG")


def get_ap_rad_params_from_dictionary(scf_dict):
    """
        to use in jenkins:
         -v RDCFG_AP_0xFFFFFF:6 # comment
    """
    return get_rad_params_from_dictionary(scf_dict, "RDCFG_AP")


def get_rad_params_from_dictionary(scf_dict, prefix):
    """
        to use in jenkins:
         -v {prefix}_0xFFFFFF:6 # comment
    """
    rbi.log("========== start: rad_mods ==========")
    rad_mods = []
    for key, value in scf_dict.items():
        if value == 'null':
            rbi.log(f"(skipped) {key}", level='DEBUG')
            continue
        result = re.search(f'{prefix}_(0x\\w+)', key)
        if result:
            rad_mods.append(f"{result.group(1)}={value}")
        else:
            continue
    rbi.log(f"    vendor mods: {rad_mods}", level='DEBUG')
    rbi.log("========== end: rad_mods ==========")
    return rad_mods


def get_vendor_mods_from_dictionary(scf_dict):
    """
        to use in jenkins:
         -v SCF_SET_VENDOR_NRBTS_CsReductionFactorOlc:60       --> will set Vendor param to 60 for all NRBTS
         -v SCF_SET_VENDOR_NRBTS_i1_CsReductionFactorOlc:60       --> will set Vendor param to 60 for all NRBTS-1
        returns a dictionary: ex.
        {
            'pname' : <str>,
            'prev_val' : <str>,
            'value' : <str>,
            'dist' : <str>
        }
    """
    rbi.log("========== start: get_vendor_mods_from_dictionary ==========")
    vendor_mods = []
    for key, value in scf_dict.items():
        if value == 'null':
            rbi.log(f"(skipped) {key}", level='DEBUG')
            continue
        result1 = re.search(r'SCF_SET_VENDOR_([a-zA-Z\d]+)_i(.+)_([a-zA-Z\d]+)', key)
        result2 = re.search(r'SCF_SET_VENDOR_([a-zA-Z\d]+)_([a-zA-Z\d]+)', key)
        if result1:
            vendor_mods.append({
                'pname': result1.group(3),
                'prev_val': result1.group(2),
                'value': value,
                'dist': result1.group(1).replace(SCF_UNDERSCORE, '_')
            })
        elif result2:
            vendor_mods.append({
                'pname': result2.group(2),
                'prev_val': None,
                'value': value,
                'dist': result2.group(1).replace(SCF_UNDERSCORE, '_')
            })
        else:
            continue
    rbi.log(f"    vendor mods: {vendor_mods}", level='DEBUG')
    rbi.log("========== end: get_vendor_mods_from_dictionary ==========")
    return vendor_mods


def get_scf_mods_from_dictionary(scf_dict, action='SET'):
    """
        to use in jenkins:
        # SCF_SET_VAR_NRPMRNL_miNrPDCPCell
         -v SCF_SET_VAR_NRCELL_pname:123       --> will set NIDD pname to 123 for all nrcell
         -v SCF_SET_VAR_NRCELL_i1_pname:123    --> will set NIDD pname to 123 for nrcell-1
         -v SCF_RM_VAR_NRCELL_pname:null       --> will Remove NIDD pname for all nrcell

        returns a dictionary: ex.
        {
            'pname' : <str>,
            'regex' : <str>,
            'value' : <str>,
            'dist' : <str>
        }
    """
    rbi.log("========== start: get_scf_mods_from_dictionary ==========")
    scf_mods = []
    for key, value in scf_dict.items():
        if value == 'null':
            rbi.log(f"(skipped) {key}", level='DEBUG')
            continue
        result1 = re.search(f"SCF_{action}_VAR" + r'_([a-zA-Z\d]+)_i(\d+)_([a-zA-Z\d]+)', key)
        result2 = re.search(f"SCF_{action}_VAR" + r'_([a-zA-Z\d]+)_([a-zA-Z\d]+)', key)
        if result1:
            scf_mods.append({
                'pname': result1.group(3),
                'regex': result1.group(2),
                'value': value,
                'dist': result1.group(1).replace(SCF_UNDERSCORE, '_')
            })
        elif result2:
            scf_mods.append({
                'pname': result2.group(2),
                'regex': '[0-9]+',
                'value': value,
                'dist': result2.group(1).replace(SCF_UNDERSCORE, '_')
            })
        else:
            continue
    rbi.log(f"all scf mods: {scf_mods}", level='DEBUG')
    return scf_mods


def get_scf_list_mods_from_dictionary(scf_dict):
    """
        to use in jenkins:
         -v SCF_SET_LIST_NRCELL_list_pname:123       --> will set NIDD pname to 123 for all nrcell
         -v SCF_SET_LIST_NRCELL_i1_list_pname:123    --> will set NIDD pname to 123 for nrcell-1

        returns a dictionary: ex.
        {
            'pname' : <str>,
            'regex' : <str>,
            'value' : <str>,
            'list' : <str>,
            'dist' : <str>,
        }
    """
    scf_mods = []
    for key, value in scf_dict.items():
        if value == 'null':
            rbi.log(f"(skipped) {key}", level='DEBUG')
            continue
        result1 = re.search(r'SCF_SET_LIST_([a-z-A-Z0-9]+)_i([0-9]+)_([a-z-A-Z0-9]+)_([a-z-A-Z0-9]+)', key)
        result2 = re.search(r'SCF_SET_LIST_([a-z-A-Z0-9]+)_([a-z-A-Z0-9]+)_([a-z-A-Z0-9]+)', key)
        if result1:
            scf_mods.append({
                'pname': result1.group(4),
                'regex': result1.group(2),
                'value': value,
                'list': result1.group(3).replace(SCF_UNDERSCORE, '_'),
                'dist': result1.group(1).replace(SCF_UNDERSCORE, '_')
            })
        elif result2:
            scf_mods.append({
                'pname': result2.group(3),
                'regex': r"[0-9]+",
                'value': value,
                'list': result2.group(2).replace(SCF_UNDERSCORE, '_'),
                'dist': result2.group(1).replace(SCF_UNDERSCORE, '_')
            })
        else:
            continue
    rbi.log(f"    scf mods: {scf_mods}", level='DEBUG')
    rbi.log("========== end: get_scf_mods_from_dictionary ==========")
    return scf_mods


def calculate_values_for_common_run_dictionary_py(get_from_cli=True, **args):
    """
        This keywords populate the dictionary with the following keys
        num_cells, total_active_cells, end_ue, total_active_ue, pass_regexp, active_cells, entry_final
    """
    rbi.log("========== start: calculate_values_for_common_run_dictionary_py ==========", console=False)
    tp = rbi.get_variable_value('${TP}')
    meta = rbi.get_variable_value('${SUITE_METADATA}')
    workspace = rbi.get_variable_value('${WORKSPACE}')
    args = perf_variables.generate_robot_variable(perf_variables.TESTCASE_DICTIONARY) | {
        "traffic_sleep": tp['SET_TRAFFIC_SLEEP'],
        "kpi_tolerance": tp['CFG_KPI_TOLERANCE'],
        "tti_trace_duration": tp['CFG_TTI_TRACE_QUICK_DURATION'],
        "delay_snapshot_capture": tp['CFG_DELAY_SNAPSHOT_CAPTURE'],
        "duplex": meta["Duplex Mode Info"].lower(),
        "workspace": workspace,
    } | args
    list_type_int = [
        'active_cells', 'ue_count_in_cell', 'cell_max_ue',
        'cell_ul_throughput', 'cell_dl_throughput', 'cell_trf_dir', 'pdu_id', 'qfi_id', 'trf_id', 'expect_ue_count'
    ]
    should_be_integer = [
        'ue_per_cell', 'start_cell', 'end_cell', 'timeout',
        'tti_trace_duration', 'ul_datarate', 'dl_datarate',
    ]
    # This is used to overwrite values using the robot cli via jenkins
    if get_from_cli:
        suite_variables = rbi.get_variables(no_decoration=True)
        args = override_run_params_args_from_robot_cli(args, suite_variables)

    # convert to some types to int
    for key in should_be_integer:
        args[key] = int(args[key])

    # convert all comma to lua friendly separator
    for item in list_type_int:
        args[item] = args[item].split(",") if isinstance(args[item], str) else args[item]
        try:
            if isinstance(args[item], list):
                args[item] = [int(x) for x in args[item]]
        except ValueError:
            logger.debug("skipping '%s', not convertible to int", item)

    args['num_cells'] = (args['end_cell'] - args['start_cell']) + 1

    args['num_cells_online'] = args['num_cells'] if args['num_cells_online'] is None else args['num_cells_online']

    args['total_active_cells'] = args['num_cells'] if args['active_cells'] == ['all'] else len(args['active_cells'])

    if args['active_cells'] != ['all']:
        for cell in range(1, int(args['num_cells']) + 1):
            if cell not in args['active_cells']:
                args['inactive_cells'].append(cell)

    # overwrite ue_per_cell if cell_max_ue is used, then highest ue count will be default
    args['ue_per_cell'] = args['ue_per_cell'] if args['cell_max_ue'] == ["null"] else\
        max([int(i) if i != 'null' else 0 for i in args['cell_max_ue']])

    args['end_ue'] = args['num_cells'] * args['ue_per_cell'] \
        if args['end_ue'] == 'auto' else args['end_ue']

    args['total_active_ue'] = args['total_active_cells'] * args['ue_per_cell']
    if args['cell_max_ue'] != ['null']:
        args['total_active_ue'] = sum(int(i) for i in args['cell_max_ue'])

    args['active_cells'] = recalculate_active_cells_based_on_cell_max_ue(args['active_cells'], args['cell_max_ue'])

    args['cell_and_ue_mapping'] = calculate_attached_ue_id_to_cell_mapping(args)

    for direction_trf in ['ul', 'dl']:
        expected_tput = calculate_expected_tput(direction_trf, args)
        total_tput = round(sum(expected_tput) * perf_info.cell_stats_nr_mb_conversion_factor[args['rate']], 1)
        args[f'expected_{direction_trf}_cell_tput'] = expected_tput
        args[f'expected_{direction_trf}_total_tput'] = total_tput

    args['expected_total_ue'] = sum([len(i) for i in args['cell_and_ue_mapping']])

    if args['expect_ue_count'] != ["null"] and len(args['expect_ue_count']) == 1:
        args['expect_ue_count'] = args['expect_ue_count'] * args['num_cells']

    entry_regex = re.sub(r"\(.*\)", "", args["entry"])
    args['pass_regexp'] = args['pass_regexp'] if args['pass_regexp'] is not None \
        else f'({entry_regex} script completed)'

    lua_args = convert_dictionary_to_lua_parameter_string(list_type=list_type_int, **args)
    if args['entry_auto_args'] == 'false':
        if args['entry_args'] != "null":
            args['entry_final'] = f"{args['entry']}({args['entry_args']})"
        else:
            args['entry_final'] = args['entry']
    else:
        args['entry_final'] = f"{args['entry']}({lua_args})"

    rbi.log("========== end: calculate_values_for_common_run_dictionary_py ==========", console=False)
    rbi.set_test_variable('$common_run_args', args)
    return args


def pop_args_from_common_args(args, keys):
    for key in keys:
        if key in args:
            value = args.pop(key)
            logger.debug("key poped from common  args: %s=%s", key, value)
    return args


def merge_to_dictionary(original_dictionary, reversed=False, **args):
    return original_dictionary.copy() | args if not reversed else args | original_dictionary.copy()


def calculate_ue_count_in_cell(argp):
    args = argp.copy()
    ue_count: list = ["0" for _ in range(0, args['num_cells'])]
    if args['cell_max_ue'] != ['null']:
        for cell_index in range(0, args['num_cells']):
            try:
                if wts_manager.is_cell_included(cell_index + 1, args['active_cells']):
                    ue_count[cell_index] = int(args['cell_max_ue'][cell_index])
                else:
                    ue_count[cell_index] = 0
            except Exception as e:
                rbi.log(f"    calculate_ue_count_in_cell e={e}\n{traceback.format_exc()}", level='WARN', console=False)
    else:
        for cell_index in range(0, args['num_cells']):
            if wts_manager.is_cell_included(cell_index + 1, args['active_cells']):
                ue_count[cell_index] = int(args['ue_per_cell'])
    return ue_count


def calculate_expected_tput(direction, argp):
    rbi.log("========== start: calculate_expected_tput ==========", console=False)
    args = argp.copy()
    expected_tput = [0 for _ in range(0, args['num_cells'])]
    cell_tput_str = f"cell_{direction}_throughput"
    cell_trf_dir = args['cell_trf_dir']
    rbi.log(f"    - cell_trf_dir {cell_trf_dir}", console=False)
    for cell_index in range(0, args['num_cells']):
        datarate = args[f'{direction}_datarate']
        if args['cell_trf_dir'] != ['null']:
            if cell_trf_dir[cell_index] not in ['both', direction]:
                rbi.log(f"    - cell {cell_index + 1} skipped [1]", console=False)
                continue
            elif cell_trf_dir[cell_index] == 'null' and args['trf_direction'] not in ['both', direction]:
                rbi.log(f"    - cell {cell_index + 1} skipped [2]", console=False)
                continue
        if args[cell_tput_str] != ['null']:
            if args[cell_tput_str][cell_index] != 'null':
                datarate = args[cell_tput_str][cell_index]
        expected_tput[cell_index] = int(
            datarate) * len(args['cell_and_ue_mapping'][cell_index])
    rbi.log("========== end: calculate_expected_tput ==========", console=False)
    return expected_tput


def convert_dictionary_to_lua_parameter_string(include=include_in_lua_args, **argp):
    lua_args = {}
    command_args = ''
    list_type = argp["list_type"]
    for item in include:
        if item in argp.keys():
            lua_args[item] = argp[item]

    for key, value in lua_args.items():
        if key in list_type:
            value = LUA_TABLE_SEPARATOR.join([str(x) for x in value])
        command_args = f"{command_args}{LUA_ARGS_SEPARATOR}{key}={value}"
    command_args = command_args[1:].replace(' ', '')
    return command_args


def calculate_attached_ue_id_to_cell_mapping(args):
    if args['cell_and_ue_mapping'] == 'null':
        cells = [[] for _ in range(0, int(args['num_cells']))]
    else:
        # append to currently attached ue if exists
        cells = [i for i in args['cell_and_ue_mapping']]
    for ue_id in range(int(args['start_ue']), int(args['end_ue']) + 1):
        cell_id = wts_manager.get_cell_id_for_ue(ue_id, args['num_cells'])
        if not wts_manager.is_cell_included(cell_id, args['active_cells']):
            continue
        if args['cell_max_ue'] != ['null']:
            if len(cells[cell_id - 1]) >= int(args['cell_max_ue'][cell_id - 1]):
                continue
        cells[cell_id - 1].append(ue_id)
    return cells


def run_testcase_in_loop(count: int, args, *keyword_calls) -> None:
    """Modified by AI: 2026-03-16 - Run a list of keywords in a loop for N iterations.

    Keywords are separated by the string 'AND'.
    Prefix a keyword name with 'COF:' to run it with 'Continue On Failure' semantics.
    After each iteration, sets args['setup_on_air'] to 'false' and detaches UEs.

    Args:
        count: Number of iterations to run.
        args: The test args dictionary (DotDict). Modified in-place between iterations.
        *keyword_calls: Keyword name and args, with 'AND' as separator between calls.

    Example (Robot Framework):
        perf_keywords.Run Testcase In Loop    3    ${args}
        ...    performance_multivm.Run MultiVM PET Testcase    ${args}    AND
        ...    COF:performance_multivm.Wait Until Expected UE Count Reached    ${args}    AND
        ...    COF:performance_multivm.Collect Traffic Logs    ${args}
    """
    original_label = args.get('label', '')
    # Modified by AI: 2026-03-18 - Track failed iterations with error details
    fail_count = 0
    iteration_failed = False
    failed_iterations = []

    # GHC: inline context manager for iteration cleanup
    @contextlib.contextmanager
    def _cleanup(i, n):
        nonlocal fail_count, iteration_failed
        iteration_failed = False
        if count > 1:
            rbi.log_to_console(f'========== START ITERATION {i}/{n} ==========')
        try:
            args['label'] = f'{original_label}_iter_{i}'
            yield

        except taf.sw.wtssim.exception.NoRegexpMatch as e:
            iteration_failed = True
            failed_iterations.append((i, f'NoRegexpMatch: {e}'))
            rbi.run_keyword_and_continue_on_failure(
                'FAIL', f'[run_testcase_in_loop] Iteration {i}/{n} failed with NoRegexpMatch: {e}'
            )
        except Exception as e:
            iteration_failed = True
            failed_iterations.append((i, str(e)))
            rbi.run_keyword_and_continue_on_failure(
                'FAIL', f'[run_testcase_in_loop] Iteration {i}/{n} failed: {e}'
            )
        finally:
            if count > 1:
                rbi.log_to_console('    [Iteration Teardown]')
                rbi.log_to_console('        - script_stop to stop any ongoing script on all VMs')
                rbi.run_keyword_and_ignore_error(
                    'performance_multivm.Execute Egate Command On All VMs',
                    'script_stop'
                )
                rbi.log_to_console('        - ue_deregister for all UEs with switch_off by ue')
                rbi.run_keyword_and_continue_on_failure(
                    'performance_multivm.Execute Egate Command On All VMs',
                    'ue_deregister id=all ue_deregister_type=switch_off by=ue'
                )
                if iteration_failed:
                    fail_count += 1
                rbi.log_to_console(f'========== COMPLETED ITERATION {i}/{n} ==========')

    # GHC: split *keyword_calls on 'AND' into keyword groups
    groups = []
    current: list = []
    for item in keyword_calls:
        if item == 'AND':
            if current:
                groups.append(current)
            current = []
        else:
            current.append(item)
    if current:
        groups.append(current)

    for i in range(1, int(count) + 1):
        with _cleanup(i, count):
            for group in groups:
                kw_name = group[0]
                # Modified by AI: 2026-03-17 - Replace %loopcount% placeholder with current iteration number
                kw_args = [a.replace(r'%loopcount%', str(i)) if isinstance(a, str) else a for a in group[1:]]
                # Modified by AI: 2026-03-18 - Save error and continue for both COF and non-COF keywords
                if kw_name.startswith('COF:'):
                    # GHC: use run_keyword_and_ignore_error to detect COF failures
                    status, error_msg = rbi.run_keyword_and_ignore_error(kw_name[4:], *kw_args)
                    if status == 'FAIL':
                        iteration_failed = True
                        failed_iterations.append((i, f'{kw_name[4:]}: {error_msg}'))
                else:
                    status, error_msg = rbi.run_keyword_and_ignore_error(kw_name, *kw_args)
                    if status == 'FAIL':
                        iteration_failed = True
                        failed_iterations.append((i, f'{kw_name}: {error_msg}'))
                        continue  # continue to next keyword group even if this one fails

    # Modified by AI: 2026-03-18 - Log final summary with failed iteration details
    total = int(count)
    rbi.log_to_console(
        f'[run_testcase_in_loop] Summary: {total - fail_count}/{total} iterations passed'
    )
    if failed_iterations:
        rbi.log_to_console('[run_testcase_in_loop] Failed iterations:')
        for iter_num, error in failed_iterations:
            rbi.log_to_console(f'    - Iteration {iter_num}: {error}')
        rbi.run_keyword_and_continue_on_failure(
            'Fail',
            f'[run_testcase_in_loop] {fail_count} out of {total} iterations failed.'
        )


def recalculate_active_cells_based_on_cell_max_ue(active_cells: list, cell_max_ue: list) -> list:
    """calculate active cells if they are used based on the  cell_max_ue args
    Args:
        active_cells (list): array that contains the used cells e.g. [1, 3, 5, 7]
        cell_max_ue (list, optional): array that contains max ues that can attach to a cell,
                                     if it is zero then treat it as not active cell
                                    e.x. [20, 0, 15, 0, 25]

    Returns:
        list: active_cells
    """
    if cell_max_ue in [['null'], None]:
        return active_cells
    for index, max_ue in enumerate(cell_max_ue):
        if max_ue == "0":
            if index in active_cells:
                active_cells.remove(index)
    return active_cells
